/**
 * One-time script: resync profiles.user_id (and all related tables)
 * to match the actual Supabase auth user IDs by joining on email.
 *
 * Run once: node scripts/fix-user-ids.mjs
 */

import { createClient } from '@supabase/supabase-js';
import { SUPABASE_SECRET_KEY, SUPABASE_URL } from './_supabase-env.mjs';

const supabase = createClient(SUPABASE_URL, SUPABASE_SECRET_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

async function main() {
  console.log('🔍 Fetching all auth users...');
  const { data: { users }, error: listErr } = await supabase.auth.admin.listUsers({ perPage: 1000 });
  if (listErr) throw listErr;
  console.log(`   Found ${users.length} auth user(s)`);

  // Build email → actual auth id map
  const emailToAuthId = new Map(users.map((u) => [u.email.toLowerCase(), u.id]));

  console.log('\n🔍 Fetching all profiles...');
  const { data: profiles, error: profErr } = await supabase
    .from('profiles')
    .select('id, user_id, email');
  if (profErr) throw profErr;
  console.log(`   Found ${profiles.length} profile(s)`);

  // Build mapping: old_user_id → new_user_id (only where they differ)
  const mapping = [];
  for (const p of profiles) {
    const newId = emailToAuthId.get(p.email.toLowerCase());
    if (newId && newId !== p.user_id) {
      mapping.push({ old: p.user_id, new: newId, email: p.email });
    }
  }

  if (mapping.length === 0) {
    console.log('\n✅ All user_ids already match — nothing to fix!');
    return;
  }

  console.log(`\n⚡ Found ${mapping.length} mismatched user_id(s):`);
  mapping.forEach((m) => console.log(`   ${m.email}: ${m.old} → ${m.new}`));

  // Tables to fix: column name is always "user_id"
  const tables = [
    'profiles',
    'attendance_days',
    'attendance_events',
    'leave_balances',
    'leave_requests',
    'payroll_profiles',
    'payslips',
    'notifications',
    'device_sessions',
    'audit_logs',
    'anonymous_feedback',
  ];

  for (const m of mapping) {
    console.log(`\n🔧 Fixing rows for ${m.email} (${m.old} → ${m.new})...`);
    for (const table of tables) {
      const { count, error } = await supabase
        .from(table)
        .update({ user_id: m.new })
        .eq('user_id', m.old)
        .select('*', { count: 'exact', head: true });

      if (error) {
        // Some tables might not have user_id or no rows — skip gracefully
        if (error.code !== 'PGRST116') {
          console.warn(`   ⚠️  ${table}: ${error.message}`);
        }
      } else {
        const rows = count ?? 0;
        if (rows > 0) console.log(`   ✅ ${table}: updated ${rows} row(s)`);
      }
    }
  }

  console.log('\n🎉 Done! All user_ids are now in sync.');
}

main().catch((err) => {
  console.error('❌ Fatal error:', err);
  process.exit(1);
});
