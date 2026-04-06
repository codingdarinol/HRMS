/**
 * Diagnostic script: print auth users and profiles to understand DB state
 */

import { createClient } from '@supabase/supabase-js';
import { SUPABASE_SECRET_KEY, SUPABASE_URL } from './_supabase-env.mjs';

const supabase = createClient(SUPABASE_URL, SUPABASE_SECRET_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

async function main() {
  const { data: { users } } = await supabase.auth.admin.listUsers({ perPage: 1000 });
  console.log('=== AUTH USERS ===');
  users.forEach(u => console.log(`  id=${u.id}  email=${u.email}  confirmed=${!!u.email_confirmed_at}`));

  const { data: profiles } = await supabase.from('profiles').select('id, user_id, email, role, organization_id');
  console.log('\n=== PROFILES ===');
  if (!profiles?.length) {
    console.log('  ⚠️  NO PROFILES FOUND (RLS might be blocking even service role, or table is empty)');
  } else {
    profiles.forEach(p => console.log(`  profile_id=${p.id}  user_id=${p.user_id}  email=${p.email}  role=${p.role}  org=${p.organization_id}`));
  }

  // Also try fetching attendance to see if data exists
  const { data: att, error: attErr } = await supabase.from('attendance_days').select('id, user_id, date').limit(5);
  console.log('\n=== ATTENDANCE (first 5) ===');
  if (attErr) console.log('  Error:', attErr.message);
  else if (!att?.length) console.log('  No attendance records found');
  else att.forEach(a => console.log(`  user_id=${a.user_id}  date=${a.date}`));

  // Check leave balances
  const { data: lb, error: lbErr } = await supabase.from('leave_balances').select('id, user_id, balance').limit(5);
  console.log('\n=== LEAVE BALANCES (first 5) ===');
  if (lbErr) console.log('  Error:', lbErr.message);
  else if (!lb?.length) console.log('  No leave balance records found');
  else lb.forEach(l => console.log(`  user_id=${l.user_id}  balance=${l.balance}`));
}

main().catch(console.error);
