/**
 * Test: can an authenticated user read their own profile?
 * Uses real signIn to get a session token, then tests profile reads.
 */

import { createClient } from '@supabase/supabase-js';
import { SUPABASE_PUBLISHABLE_KEY, SUPABASE_URL } from './_supabase-env.mjs';

const testUsers = [
  { email: 'admin@acme.com', password: 'password123' },
  { email: 'hr@acme.com', password: 'password123' },
  { email: 'rahul@acme.com', password: 'password123' },
];

async function testUser({ email, password }) {
  const client = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // Sign in
  const { data: authData, error: authError } = await client.auth.signInWithPassword({ email, password });
  if (authError) {
    console.log(`  ❌ Sign-in FAILED for ${email}: ${authError.message}`);
    return;
  }
  console.log(`  ✅ Signed in as ${email} (uid=${authData.user.id})`);

  // Try to read own profile
  const { data: profile, error: profError } = await client
    .from('profiles')
    .select('id, user_id, email, role, organization_id')
    .eq('user_id', authData.user.id)
    .single();

  if (profError) {
    console.log(`  ❌ Profile READ FAILED (user_id match): ${profError.message} [code=${profError.code}]`);
  } else {
    console.log(`  ✅ Profile found: role=${profile.role}, org=${profile.organization_id}`);
  }

  // Try reading attendance
  const { data: att, error: attError } = await client
    .from('attendance_days')
    .select('id, date')
    .eq('user_id', authData.user.id)
    .limit(3);

  if (attError) {
    console.log(`  ❌ Attendance READ FAILED: ${attError.message}`);
  } else {
    console.log(`  ✅ Attendance rows: ${att?.length ?? 0}`);
  }

  // Sign out
  await client.auth.signOut();
}

async function main() {
  for (const user of testUsers) {
    console.log(`\n--- Testing ${user.email} ---`);
    await testUser(user);
  }
}

main().catch(console.error);
