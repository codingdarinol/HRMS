import { createClient } from '@supabase/supabase-js';
import { SUPABASE_PUBLISHABLE_KEY, SUPABASE_URL } from './_supabase-env.mjs';

const s = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

const { data: auth } = await s.auth.signInWithPassword({ email: 'admin@acme.com', password: 'admin123456' });
console.log('uid =', auth.user.id);

// Test 1: read profile by user_id
const { data: p1, error: e1 } = await s.from('profiles')
  .select('id, user_id, email, role, organization_id')
  .eq('user_id', auth.user.id)
  .single();
console.log('Profile by user_id:', p1 ?? `ERROR: ${e1?.message}`);

// Test 2: read attendance
const { data: att, error: e2 } = await s.from('attendance_days')
  .select('date, status').limit(3);
console.log('Attendance:', att ?? `ERROR: ${e2?.message}`);

// Test 3: check session getUser
const { data: { user }, error: e3 } = await s.auth.getUser();
console.log('getUser uid:', user?.id ?? `ERROR: ${e3?.message}`);
