#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod credentials;
mod idle;
mod ping;

use std::sync::{Arc, Mutex};
use tauri::{
    command, CustomMenuItem, Manager, SystemTray, SystemTrayEvent,
    SystemTrayMenu, SystemTrayMenuItem,
};

const DEFAULT_API_BASE: &str = "https://ejyptenkuaemprlraoxl.supabase.co/functions/v1";
const DEFAULT_ANON_KEY: &str = "sb_publishable_-J3wOPfqMpLmN2yJLTpebg_q9UUievn";

#[derive(Clone, serde::Serialize, serde::Deserialize, Debug)]
pub struct AppState {
    pub api_base: String,
    pub access_token: Option<String>,
    pub refresh_token: Option<String>,
    pub user_email: Option<String>,
    pub checked_in: bool,
    pub device_session_id: Option<String>,
}

impl Default for AppState {
    fn default() -> Self {
        Self {
            api_base: std::env::var("HRMS_API_BASE")
                .unwrap_or_else(|_| DEFAULT_API_BASE.to_string()),
            access_token: None,
            refresh_token: None,
            user_email: None,
            checked_in: false,
            device_session_id: None,
        }
    }
}

/// Called from the login UI to pass auth tokens to the Rust backend
#[command]
fn set_auth_token(
    access_token: String,
    refresh_token: String,
    email: String,
    state: tauri::State<'_, Arc<Mutex<AppState>>>,
    app: tauri::AppHandle,
) -> Result<String, String> {
    // Save to OS keychain
    credentials::save_token(&access_token)?;
    credentials::save_refresh_token(&refresh_token)?;

    // Update in-memory state
    {
        let mut s = state.lock().unwrap();
        s.access_token = Some(access_token.clone());
        s.refresh_token = Some(refresh_token);
        s.user_email = Some(email.clone());
    }

    // Register device session in the background
    let state_clone = state.inner().clone();
    tauri::async_runtime::spawn(async move {
        if let Err(e) = register_device_session(&state_clone).await {
            eprintln!("[device] Failed to register session: {}", e);
        }
    });

    // Update tray menu to show logged-in state
    let _ = app.tray_handle().set_menu(build_tray_menu(false, Some(&email)));

    Ok("ok".to_string())
}

fn build_tray_menu(checked_in: bool, email: Option<&str>) -> SystemTrayMenu {
    let user_label = match email {
        Some(e) => format!("Signed in: {}", e),
        None => "Not signed in".to_string(),
    };

    let status = if checked_in {
        "● Checked In"
    } else {
        "○ Not Checked In"
    };

    let mut menu = SystemTrayMenu::new()
        .add_item(CustomMenuItem::new("user", &user_label).disabled())
        .add_item(CustomMenuItem::new("status", status).disabled())
        .add_native_item(SystemTrayMenuItem::Separator);

    if email.is_some() {
        if !checked_in {
            menu = menu.add_item(CustomMenuItem::new("checkin", "☀ Check In"));
        } else {
            menu = menu.add_item(CustomMenuItem::new("checkout", "🌙 Check Out"));
        }
        menu = menu.add_native_item(SystemTrayMenuItem::Separator);
        menu = menu.add_item(CustomMenuItem::new("signout", "Sign Out"));
    } else {
        menu = menu.add_item(CustomMenuItem::new("login", "Sign In..."));
    }

    menu = menu
        .add_native_item(SystemTrayMenuItem::Separator)
        .add_item(CustomMenuItem::new("about", "About HRMS Agent"))
        .add_item(CustomMenuItem::new("quit", "Quit"));
    menu
}

fn show_login_window(app: &tauri::AppHandle) {
    if let Some(win) = app.get_window("login") {
        let _ = win.show();
        let _ = win.set_focus();
    }
}

fn main() {
    let state = Arc::new(Mutex::new(AppState::default()));

    // Try loading saved token from keychain
    let has_token = if let Ok(token) = credentials::load_token() {
        let mut s = state.lock().unwrap();
        s.access_token = Some(token);
        if let Ok(rt) = credentials::load_refresh_token() {
            s.refresh_token = Some(rt);
        }
        true
    } else {
        false
    };

    let initial_email = if has_token {
        Some("saved session".to_string())
    } else {
        None
    };

    let tray = SystemTray::new()
        .with_menu(build_tray_menu(false, initial_email.as_deref()));
    let tray_tooltip = "HRMS Agent";

    let state_for_tray = state.clone();
    let state_for_setup = state.clone();

    tauri::Builder::default()
        .manage(state.clone())
        .invoke_handler(tauri::generate_handler![set_auth_token])
        .system_tray(tray.with_tooltip(tray_tooltip))
        .on_system_tray_event(move |app, event| {
            if let SystemTrayEvent::MenuItemClick { id, .. } = event {
                let state = state_for_tray.clone();
                match id.as_str() {
                    "login" => {
                        show_login_window(app);
                    }
                    "signout" => {
                        let _ = credentials::delete_token();
                        let _ = credentials::delete_refresh_token();
                        let mut s = state.lock().unwrap();
                        s.access_token = None;
                        s.refresh_token = None;
                        s.user_email = None;
                        s.checked_in = false;
                        let _ = app.tray_handle().set_menu(build_tray_menu(false, None));
                    }
                    "checkin" => {
                        let handle = app.clone();
                        tauri::async_runtime::spawn(async move {
                            match do_checkin(&state).await {
                                Ok(_) => {
                                    let email = {
                                        let mut s = state.lock().unwrap();
                                        s.checked_in = true;
                                        s.user_email.clone()
                                    };
                                    let _ = handle.tray_handle().set_menu(
                                        build_tray_menu(true, email.as_deref()),
                                    );
                                    // Start ping loop
                                    let st2 = state.clone();
                                    tauri::async_runtime::spawn(async move {
                                        ping::start_ping_loop(st2).await;
                                    });
                                }
                                Err(e) => eprintln!("Check-in failed: {}", e),
                            }
                        });
                    }
                    "checkout" => {
                        let handle = app.clone();
                        tauri::async_runtime::spawn(async move {
                            match do_checkout(&state).await {
                                Ok(_) => {
                                    let email = {
                                        let mut s = state.lock().unwrap();
                                        s.checked_in = false;
                                        s.user_email.clone()
                                    };
                                    let _ = handle.tray_handle().set_menu(
                                        build_tray_menu(false, email.as_deref()),
                                    );
                                }
                                Err(e) => eprintln!("Check-out failed: {}", e),
                            }
                        });
                    }
                    "about" => {
                        let _ = tauri::api::shell::open(
                            &app.shell_scope(),
                            "https://hrms-nine-omega.vercel.app",
                            None,
                        );
                    }
                    "quit" => std::process::exit(0),
                    _ => {}
                }
            }
        })
        .on_window_event(|event| {
            // Intercept window close to hide instead of quit
            if let tauri::WindowEvent::CloseRequested { api, .. } = event.event() {
                event.window().hide().unwrap();
                api.prevent_close();
            }
        })
        .setup(move |app| {
            // If no saved token, show login window on startup
            if !has_token {
                show_login_window(&app.handle());
            }

            // Start idle detection
            let idle_state = state_for_setup.clone();
            tauri::async_runtime::spawn(async move {
                idle::start_idle_detection(idle_state).await;
            });
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running HRMS Agent");
}

async fn register_device_session(state: &Arc<Mutex<AppState>>) -> Result<(), String> {
    let (api_base, token) = {
        let s = state.lock().unwrap();
        (s.api_base.clone(), s.access_token.clone())
    };

    let token = token.ok_or("Not logged in")?;
    let device_name = hostname::get()
        .map(|h| h.to_string_lossy().to_string())
        .unwrap_or_else(|_| "unknown-device".to_string());

    let device_os = if cfg!(target_os = "macos") {
        "macos"
    } else if cfg!(target_os = "windows") {
        "windows"
    } else {
        "linux"
    };

    let client = reqwest::Client::new();
    let res = client
        .post(format!("{}/device-exchange-token", api_base))
        .header("Authorization", format!("Bearer {}", token))
        .json(&serde_json::json!({
            "device_name": device_name,
            "device_os": device_os,
        }))
        .send()
        .await
        .map_err(|e| e.to_string())?;

    if res.status().is_success() {
        let body: serde_json::Value = res.json().await.map_err(|e| e.to_string())?;
        if let Some(session_id) = body.get("session_id").and_then(|v| v.as_str()) {
            let mut s = state.lock().unwrap();
            s.device_session_id = Some(session_id.to_string());
        }
        println!("✓ Device session registered");
        Ok(())
    } else {
        let body = res.text().await.unwrap_or_default();
        Err(format!("Device registration failed: {}", body))
    }
}

/// Refresh the access token using the stored refresh token.
/// Returns true if refresh succeeded, false otherwise.
pub async fn refresh_auth_token(state: &Arc<Mutex<AppState>>) -> bool {
    let (refresh_token, api_base) = {
        let s = state.lock().unwrap();
        (s.refresh_token.clone(), s.api_base.clone())
    };

    let refresh_token = match refresh_token {
        Some(rt) => rt,
        None => return false,
    };

    // Supabase auth refresh endpoint
    let supabase_url = api_base
        .replace("/functions/v1", "");
    let anon_key =
        std::env::var("HRMS_ANON_KEY").unwrap_or_else(|_| DEFAULT_ANON_KEY.to_string());

    let client = reqwest::Client::new();
    let res = client
        .post(format!("{}/auth/v1/token?grant_type=refresh_token", supabase_url))
        .header("apikey", &anon_key)
        .header("Content-Type", "application/json")
        .json(&serde_json::json!({ "refresh_token": refresh_token }))
        .send()
        .await;

    match res {
        Ok(response) if response.status().is_success() => {
            if let Ok(body) = response.json::<serde_json::Value>().await {
                let new_access = body.get("access_token").and_then(|v| v.as_str());
                let new_refresh = body.get("refresh_token").and_then(|v| v.as_str());

                if let (Some(at), Some(rt)) = (new_access, new_refresh) {
                    let _ = credentials::save_token(at);
                    let _ = credentials::save_refresh_token(rt);

                    let mut s = state.lock().unwrap();
                    s.access_token = Some(at.to_string());
                    s.refresh_token = Some(rt.to_string());

                    println!("[auth] Token refreshed successfully");
                    return true;
                }
            }
            false
        }
        _ => {
            eprintln!("[auth] Token refresh failed");
            false
        }
    }
}

async fn do_checkin(state: &Arc<Mutex<AppState>>) -> Result<(), String> {
    let (api_base, token) = {
        let s = state.lock().unwrap();
        (s.api_base.clone(), s.access_token.clone())
    };

    let token = token.ok_or("Not logged in")?;
    let client = reqwest::Client::new();
    let res = client
        .post(format!("{}/attendance-checkin", api_base))
        .header("Authorization", format!("Bearer {}", token))
        .json(&serde_json::json!({ "source": "AGENT" }))
        .send()
        .await
        .map_err(|e| e.to_string())?;

    if res.status() == 401 {
        // Try refreshing token and retry once
        if refresh_auth_token(state).await {
            let new_token = state.lock().unwrap().access_token.clone().unwrap_or_default();
            let retry = client
                .post(format!("{}/attendance-checkin", api_base))
                .header("Authorization", format!("Bearer {}", new_token))
                .json(&serde_json::json!({ "source": "AGENT" }))
                .send()
                .await
                .map_err(|e| e.to_string())?;

            if !retry.status().is_success() {
                let body = retry.text().await.unwrap_or_default();
                return Err(format!("Check-in failed after refresh: {}", body));
            }
        } else {
            return Err("Check-in failed: unauthorized, token refresh failed".to_string());
        }
    } else if !res.status().is_success() {
        let body = res.text().await.unwrap_or_default();
        return Err(format!("Check-in failed: {}", body));
    }

    println!("✓ Checked in successfully");
    Ok(())
}

async fn do_checkout(state: &Arc<Mutex<AppState>>) -> Result<(), String> {
    let (api_base, token) = {
        let s = state.lock().unwrap();
        (s.api_base.clone(), s.access_token.clone())
    };

    let token = token.ok_or("Not logged in")?;
    let client = reqwest::Client::new();
    let res = client
        .post(format!("{}/attendance-checkout", api_base))
        .header("Authorization", format!("Bearer {}", token))
        .json(&serde_json::json!({}))
        .send()
        .await
        .map_err(|e| e.to_string())?;

    if res.status() == 401 {
        // Try refreshing token and retry once
        if refresh_auth_token(state).await {
            let new_token = state.lock().unwrap().access_token.clone().unwrap_or_default();
            let retry = client
                .post(format!("{}/attendance-checkout", api_base))
                .header("Authorization", format!("Bearer {}", new_token))
                .json(&serde_json::json!({}))
                .send()
                .await
                .map_err(|e| e.to_string())?;

            if !retry.status().is_success() {
                let body = retry.text().await.unwrap_or_default();
                return Err(format!("Check-out failed after refresh: {}", body));
            }
        } else {
            return Err("Check-out failed: unauthorized, token refresh failed".to_string());
        }
    } else if !res.status().is_success() {
        let body = res.text().await.unwrap_or_default();
        return Err(format!("Check-out failed: {}", body));
    }

    println!("✓ Checked out successfully");
    Ok(())
}
