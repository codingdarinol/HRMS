/**
 * One-time script: close any attendance_days rows where check_in_at is set
 * but check_out_at is NULL and the date is in the past (not today IST).
 *
 * This cleans up seed data and any real orphaned records so users don't see
 * phantom "already checked in" state when loading the dashboard.
 *
 * Usage:  node scripts/close-orphaned-checkins.mjs
 */

import { SUPABASE_SECRET_KEY, SUPABASE_URL } from './_supabase-env.mjs';

// Today in IST (Asia/Kolkata, UTC+5:30)
const todayIST = new Date().toLocaleDateString('en-CA', { timeZone: 'Asia/Kolkata' });
console.log(`Today IST: ${todayIST}`);

const headers = {
  apikey: SUPABASE_SECRET_KEY,
  Authorization: `Bearer ${SUPABASE_SECRET_KEY}`,
  'Content-Type': 'application/json',
  Prefer: 'return=representation',
};

// 1. Fetch all orphaned rows (check_in_at IS NOT NULL, check_out_at IS NULL, date < today)
const fetchRes = await fetch(
  `${SUPABASE_URL}/rest/v1/attendance_days?select=id,date,check_in_at,idle_minutes&check_in_at=not.is.null&check_out_at=is.null&date=lt.${todayIST}`,
  { headers }
);

if (!fetchRes.ok) {
  const txt = await fetchRes.text();
  console.error('Fetch failed:', fetchRes.status, txt);
  process.exit(1);
}

const rows = await fetchRes.json();
console.log(`Found ${rows.length} orphaned check-in(s) to close.`);

if (rows.length === 0) {
  console.log('Nothing to do.');
  process.exit(0);
}

let closed = 0;
let failed = 0;

for (const row of rows) {
  // Close at end-of-day IST: use 18:00 IST as default checkout (work day end)
  const checkOutISO = new Date(`${row.date}T18:00:00+05:30`).toISOString();
  const checkInMS = new Date(row.check_in_at).getTime();
  const checkOutMS = new Date(checkOutISO).getTime();
  const rawMinutes = Math.round((checkOutMS - checkInMS) / 60000);
  const idleMinutes = row.idle_minutes ?? 0;
  const workedMinutes = Math.max(0, rawMinutes - idleMinutes);

  const patchRes = await fetch(
    `${SUPABASE_URL}/rest/v1/attendance_days?id=eq.${row.id}`,
    {
      method: 'PATCH',
      headers,
      body: JSON.stringify({
        check_out_at: checkOutISO,
        worked_minutes: workedMinutes,
      }),
    }
  );

  if (patchRes.ok) {
    console.log(
      `  ✓ Closed ${row.id} (date=${row.date}, worked=${workedMinutes}min)`
    );
    closed++;
  } else {
    const txt = await patchRes.text();
    console.error(`  ✗ Failed ${row.id}:`, patchRes.status, txt);
    failed++;
  }
}

console.log(`\nDone. Closed: ${closed}, Failed: ${failed}`);
