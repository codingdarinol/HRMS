import { createClient } from '@supabase/supabase-js';
import { SUPABASE_SECRET_KEY, SUPABASE_URL } from './_supabase-env.mjs';

const s = createClient(SUPABASE_URL, SUPABASE_SECRET_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

// Reset all seed users to password123
const users = [
  { email: 'admin@acme.com', id: '70008bea-12c3-4730-9715-fa2d0c0ceb0d' },
  { email: 'hr@acme.com', id: '22222222-2222-2222-2222-222222222222' },
  { email: 'rahul@acme.com', id: '33333333-3333-3333-3333-333333333333' },
  { email: 'priya@acme.com', id: '44444444-4444-4444-4444-444444444444' },
];

for (const u of users) {
  const { error } = await s.auth.admin.updateUserById(u.id, { password: 'password123' });
  if (error) console.log(`❌ ${u.email}: ${error.message}`);
  else console.log(`✅ ${u.email} → password123`);
}
