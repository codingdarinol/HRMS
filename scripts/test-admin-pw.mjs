import { createClient } from '@supabase/supabase-js';
import { SUPABASE_PUBLISHABLE_KEY, SUPABASE_URL } from './_supabase-env.mjs';

const s = createClient(
  SUPABASE_URL,
  SUPABASE_PUBLISHABLE_KEY,
  { auth: { autoRefreshToken: false, persistSession: false } }
);
for (const pwd of ['admin123456', 'password123', 'Admin123!', 'admin123']) {
  const { data, error } = await s.auth.signInWithPassword({ email: 'admin@acme.com', password: pwd });
  if (!error) { console.log('Works:', pwd, 'uid=', data.user.id); break; }
  else console.log('Fail:', pwd, '-', error.message);
}
