-- Seed data for HRMS development

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Create organization
INSERT INTO organizations (id, name, slug, timezone) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Acme Corp', 'acme-corp', 'Asia/Kolkata');

-- 2. Create locations
INSERT INTO locations (id, organization_id, name, address, latitude, longitude, geofence_radius_meters, allowed_wifi_ssids, timezone) VALUES
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'HQ Office', '123 Business Park, Mumbai', 19.0760, 72.8777, 200, '{"AcmeOffice-5G","AcmeOffice-2G"}', 'Asia/Kolkata'),
  ('b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Branch Office', '456 Tech Hub, Bangalore', 12.9716, 77.5946, 300, '{"AcmeBLR-5G"}', 'Asia/Kolkata');

-- 3. Create departments
INSERT INTO departments (id, organization_id, name, description) VALUES
  ('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Engineering', 'Software Engineering'),
  ('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Human Resources', 'HR & People Ops'),
  ('c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Finance', 'Finance & Accounting');

-- 4. Create HR policies
INSERT INTO hr_policies (id, organization_id, name, work_mode, location_enforced, office_wifi_enforced, wfh_fallback_on_outside_office, block_outside_office_checkin, idle_threshold_minutes, count_absent_as_lop, count_non_compliant_as_lop, weekend_days) VALUES
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Hybrid Policy', 'HYBRID', true, false, true, false, 30, true, false, '{0,6}'),
  ('d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Office Only Policy', 'OFFICE_ONLY', true, true, false, false, 30, true, false, '{0,6}'),
  ('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'WFH Policy', 'WFH_ALLOWED', false, false, true, false, 30, true, false, '{0,6}');

-- 5. Create holiday calendar
INSERT INTO holiday_calendars (id, organization_id, name, year, location_id) VALUES
  ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'India 2026', 2026, NULL);

INSERT INTO holidays (calendar_id, name, date, is_optional) VALUES
  ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Republic Day', '2026-01-26', false),
  ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Holi', '2026-03-17', false),
  ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Good Friday', '2026-04-03', false),
  ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Independence Day', '2026-08-15', false),
  ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Gandhi Jayanti', '2026-10-02', false),
  ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Diwali', '2026-10-20', false),
  ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Christmas', '2026-12-25', false);

-- 6. Create leave types
INSERT INTO leave_types (id, organization_id, name, code, is_paid, max_days_per_year, accrual_frequency, carry_forward_limit, max_balance, pro_rate_on_join) VALUES
  ('f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Annual Leave', 'AL', true, 18, 'MONTHLY', 5, 30, true),
  ('f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sick Leave', 'SL', true, 12, 'MONTHLY', 0, 12, false),
  ('f3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Casual Leave', 'CL', true, 6, 'YEARLY', 0, 6, true),
  ('f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Loss of Pay', 'LOP', false, 365, 'YEARLY', 0, 365, false);

-- 7. Create leave policies
INSERT INTO leave_policies (organization_id, name, leave_type_id, approval_flow, allow_negative_balance, min_notice_days) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Annual Leave Policy', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MANAGER_THEN_HR', false, 3),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sick Leave Policy', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MANAGER_ONLY', false, 0),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Casual Leave Policy', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MANAGER_ONLY', false, 1),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'LOP Policy', 'f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'HR_ONLY', true, 0);

-- ============================================================
-- 8. Create test users (4 employees with login credentials)
-- ============================================================
-- All passwords: password123
--
-- | Email             | Password     | Role     | Name           |
-- |-------------------|------------- |----------|----------------|
-- | admin@acme.com    | password123  | ADMIN    | Rajesh Kumar   |
-- | hr@acme.com       | password123  | HR       | Sneha Sharma   |
-- | rahul@acme.com    | password123  | EMPLOYEE | Rahul Patel    |
-- | priya@acme.com    | password123  | EMPLOYEE | Priya Nair     |

INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  is_super_admin, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
) VALUES
  -- Admin: Rajesh Kumar
  (
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-1111-1111-111111111111',
    'authenticated', 'authenticated',
    'admin@acme.com',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"organization_id":"a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11","full_name":"Rajesh Kumar","employee_code":"EMP-001","role":"ADMIN"}',
    false, now(), now(), '', '', '', ''
  ),
  -- HR: Sneha Sharma
  (
    '00000000-0000-0000-0000-000000000000',
    '22222222-2222-2222-2222-222222222222',
    'authenticated', 'authenticated',
    'hr@acme.com',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"organization_id":"a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11","full_name":"Sneha Sharma","employee_code":"EMP-002","role":"HR"}',
    false, now(), now(), '', '', '', ''
  ),
  -- Employee: Rahul Patel
  (
    '00000000-0000-0000-0000-000000000000',
    '33333333-3333-3333-3333-333333333333',
    'authenticated', 'authenticated',
    'rahul@acme.com',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"organization_id":"a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11","full_name":"Rahul Patel","employee_code":"EMP-003","role":"EMPLOYEE"}',
    false, now(), now(), '', '', '', ''
  ),
  -- Employee: Priya Nair
  (
    '00000000-0000-0000-0000-000000000000',
    '44444444-4444-4444-4444-444444444444',
    'authenticated', 'authenticated',
    'priya@acme.com',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"organization_id":"a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11","full_name":"Priya Nair","employee_code":"EMP-004","role":"EMPLOYEE"}',
    false, now(), now(), '', '', '', ''
  );

-- Create auth identities (required for email/password login)
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES
  ('11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111',
   '{"sub":"11111111-1111-1111-1111-111111111111","email":"admin@acme.com","email_verified":true}',
   'email', '11111111-1111-1111-1111-111111111111', now(), now(), now()),
  ('22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222',
   '{"sub":"22222222-2222-2222-2222-222222222222","email":"hr@acme.com","email_verified":true}',
   'email', '22222222-2222-2222-2222-222222222222', now(), now(), now()),
  ('33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333',
   '{"sub":"33333333-3333-3333-3333-333333333333","email":"rahul@acme.com","email_verified":true}',
   'email', '33333333-3333-3333-3333-333333333333', now(), now(), now()),
  ('44444444-4444-4444-4444-444444444444', '44444444-4444-4444-4444-444444444444',
   '{"sub":"44444444-4444-4444-4444-444444444444","email":"priya@acme.com","email_verified":true}',
   'email', '44444444-4444-4444-4444-444444444444', now(), now(), now());

-- ============================================================
-- 9. Update auto-created profiles with full employee details
-- ============================================================
-- The handle_new_user() trigger created basic profiles; now enrich them.

-- Rajesh Kumar — Admin, CTO, Engineering, Mumbai HQ, Hybrid policy
UPDATE profiles SET
  department_id  = 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  location_id    = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  hr_policy_id   = 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  designation    = 'Chief Technology Officer',
  joining_date   = '2024-01-15',
  phone          = '+91-9876543210'
WHERE user_id = '11111111-1111-1111-1111-111111111111';

-- Sneha Sharma — HR Manager, Human Resources, Mumbai HQ, Office Only policy
UPDATE profiles SET
  department_id  = 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  location_id    = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  hr_policy_id   = 'd2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  designation    = 'HR Manager',
  joining_date   = '2024-03-01',
  phone          = '+91-9876543211'
WHERE user_id = '22222222-2222-2222-2222-222222222222';

-- Rahul Patel — Software Engineer, Engineering, Bangalore, WFH policy
UPDATE profiles SET
  department_id  = 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  location_id    = 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  hr_policy_id   = 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  designation    = 'Software Engineer',
  joining_date   = '2024-06-10',
  phone          = '+91-9876543212',
  manager_id     = (SELECT id FROM profiles WHERE user_id = '11111111-1111-1111-1111-111111111111')
WHERE user_id = '33333333-3333-3333-3333-333333333333';

-- Priya Nair — Financial Analyst, Finance, Mumbai HQ, Hybrid policy
UPDATE profiles SET
  department_id  = 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  location_id    = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  hr_policy_id   = 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  designation    = 'Financial Analyst',
  joining_date   = '2025-01-20',
  phone          = '+91-9876543213',
  manager_id     = (SELECT id FROM profiles WHERE user_id = '22222222-2222-2222-2222-222222222222')
WHERE user_id = '44444444-4444-4444-4444-444444444444';

-- ============================================================
-- 10. Create payroll profiles (salary + bank details)
-- ============================================================

INSERT INTO payroll_profiles (user_id, organization_id, base_monthly_salary, currency, salary_structure, payment_method, bank_name, bank_account_number, bank_ifsc) VALUES
  -- Rajesh: ₹1,50,000/month with custom salary structure
  (
    '11111111-1111-1111-1111-111111111111',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    150000, 'INR',
    '{"earnings":[{"name":"Basic","amount":60000,"is_percentage":false},{"name":"HRA","amount":50,"is_percentage":true,"percentage_of":"Basic"},{"name":"Special Allowance","amount":60000,"is_percentage":false}],"deductions":[{"name":"EPF","amount":12,"is_percentage":true},{"name":"Professional Tax","amount":200,"is_percentage":false}]}',
    'BANK_TRANSFER', 'HDFC Bank', '50100123456789', 'HDFC0001234'
  ),
  -- Sneha: ₹85,000/month
  (
    '22222222-2222-2222-2222-222222222222',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    85000, 'INR',
    NULL,
    'BANK_TRANSFER', 'ICICI Bank', '60200234567890', 'ICIC0002345'
  ),
  -- Rahul: ₹60,000/month
  (
    '33333333-3333-3333-3333-333333333333',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    60000, 'INR',
    NULL,
    'BANK_TRANSFER', 'State Bank of India', '30100345678901', 'SBIN0003456'
  ),
  -- Priya: ₹55,000/month
  (
    '44444444-4444-4444-4444-444444444444',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    55000, 'INR',
    NULL,
    'BANK_TRANSFER', 'Axis Bank', '91700456789012', 'UTIB0004567'
  );

-- ============================================================
-- 11. Create leave balances for 2026
-- ============================================================

INSERT INTO leave_balances (user_id, organization_id, leave_type_id, year, total_accrued, total_used, total_pending, carry_forwarded) VALUES
  -- Rajesh Kumar (Admin) — AL: 18 accrued, 2 used, 3 carry-forward
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 18, 2, 0, 3),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 12, 1, 0, 0),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 6, 1, 0, 0),

  -- Sneha Sharma (HR) — AL: 18 accrued, 3 used, 2 carry-forward
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 18, 3, 0, 2),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 12, 0, 0, 0),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 6, 2, 0, 0),

  -- Rahul Patel (Employee) — AL: 18 accrued, 4 used, 1 pending
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 18, 4, 1, 0),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 12, 2, 0, 0),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 6, 1, 0, 0),

  -- Priya Nair (Employee) — AL: 18 accrued, 1 used
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 18, 1, 0, 0),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 12, 0, 0, 0),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2026, 6, 0, 0, 0);

-- ============================================================
-- 12. Seed attendance data for March 2026 (working days Mon-Fri)
-- ============================================================

-- March 2026: Weekdays are 2-6, 9-13, 16(Mon is holiday Holi on 17th actually 17=Tue),
-- Holi is 17th March (Tue) — holiday
-- Working days: 2,3,4,5,6,9,10,11,12,13,16,18,19,20,23,24,25,26,27,30,31
-- Weekends: 1,7,8,14,15,21,22,28,29

INSERT INTO attendance_days (user_id, organization_id, date, status, check_in_at, check_out_at, worked_minutes, idle_minutes, work_mode_detected, office_compliant) VALUES
  -- ===== Rajesh Kumar (Admin) — mostly PRESENT from office =====
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-02', 'PRESENT', '2026-03-02 09:05:00+05:30', '2026-03-02 18:10:00+05:30', 535, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-03', 'PRESENT', '2026-03-03 09:00:00+05:30', '2026-03-03 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-04', 'PRESENT', '2026-03-04 09:15:00+05:30', '2026-03-04 18:30:00+05:30', 535, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-05', 'WFH',     '2026-03-05 09:30:00+05:30', '2026-03-05 18:00:00+05:30', 490, 20, 'WFH', false),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-06', 'PRESENT', '2026-03-06 09:00:00+05:30', '2026-03-06 18:15:00+05:30', 535, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-09', 'PRESENT', '2026-03-09 08:55:00+05:30', '2026-03-09 18:00:00+05:30', 525, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-10', 'PRESENT', '2026-03-10 09:10:00+05:30', '2026-03-10 18:20:00+05:30', 530, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-11', 'LEAVE',   NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-12', 'LEAVE',   NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-13', 'PRESENT', '2026-03-13 09:00:00+05:30', '2026-03-13 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-16', 'PRESENT', '2026-03-16 09:00:00+05:30', '2026-03-16 18:00:00+05:30', 520, 20, 'OFFICE', true),
  -- 17 March = Holi (holiday)
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-17', 'HOLIDAY', NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-18', 'PRESENT', '2026-03-18 09:00:00+05:30', '2026-03-18 18:05:00+05:30', 525, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-19', 'PRESENT', '2026-03-19 09:00:00+05:30', '2026-03-19 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-20', 'PRESENT', '2026-03-20 09:00:00+05:30', '2026-03-20 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-23', 'PRESENT', '2026-03-23 09:00:00+05:30', '2026-03-23 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-24', 'WFH',     '2026-03-24 10:00:00+05:30', '2026-03-24 19:00:00+05:30', 500, 40, 'WFH', false),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-25', 'PRESENT', '2026-03-25 09:00:00+05:30', '2026-03-25 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-26', 'PRESENT', '2026-03-26 09:00:00+05:30', '2026-03-26 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-27', 'PRESENT', '2026-03-27 09:00:00+05:30', '2026-03-27 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-30', 'PRESENT', '2026-03-30 09:00:00+05:30', '2026-03-30 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-31', 'PRESENT', '2026-03-31 09:00:00+05:30', NULL, 0, 0, 'OFFICE', true),

  -- ===== Sneha Sharma (HR) — office strict, some late arrivals =====
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-02', 'PRESENT', '2026-03-02 09:00:00+05:30', '2026-03-02 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-03', 'PRESENT', '2026-03-03 09:30:00+05:30', '2026-03-03 18:30:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-04', 'PRESENT', '2026-03-04 09:00:00+05:30', '2026-03-04 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-05', 'PRESENT', '2026-03-05 09:10:00+05:30', '2026-03-05 18:10:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-06', 'PRESENT', '2026-03-06 09:00:00+05:30', '2026-03-06 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-09', 'PRESENT', '2026-03-09 09:00:00+05:30', '2026-03-09 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-10', 'LEAVE',   NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-11', 'LEAVE',   NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-12', 'LEAVE',   NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-13', 'PRESENT', '2026-03-13 09:00:00+05:30', '2026-03-13 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-16', 'PRESENT', '2026-03-16 09:00:00+05:30', '2026-03-16 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-17', 'HOLIDAY', NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-18', 'PRESENT', '2026-03-18 09:00:00+05:30', '2026-03-18 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-19', 'PRESENT', '2026-03-19 09:00:00+05:30', '2026-03-19 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-20', 'PRESENT', '2026-03-20 09:00:00+05:30', '2026-03-20 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-23', 'PRESENT', '2026-03-23 09:00:00+05:30', '2026-03-23 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-24', 'PRESENT', '2026-03-24 09:00:00+05:30', '2026-03-24 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-25', 'ABSENT',  NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-26', 'PRESENT', '2026-03-26 09:00:00+05:30', '2026-03-26 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-27', 'PRESENT', '2026-03-27 09:00:00+05:30', '2026-03-27 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-30', 'PRESENT', '2026-03-30 09:00:00+05:30', '2026-03-30 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-31', 'PRESENT', '2026-03-31 09:00:00+05:30', NULL, 0, 0, 'OFFICE', true),

  -- ===== Rahul Patel (Employee) — remote worker, WFH policy =====
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-02', 'WFH',     '2026-03-02 09:30:00+05:30', '2026-03-02 18:30:00+05:30', 500, 40, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-03', 'WFH',     '2026-03-03 09:15:00+05:30', '2026-03-03 18:15:00+05:30', 500, 40, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-04', 'WFH',     '2026-03-04 10:00:00+05:30', '2026-03-04 19:00:00+05:30', 480, 60, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-05', 'WFH',     '2026-03-05 09:00:00+05:30', '2026-03-05 18:00:00+05:30', 510, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-06', 'ABSENT',  NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-09', 'WFH',     '2026-03-09 09:00:00+05:30', '2026-03-09 18:00:00+05:30', 500, 40, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-10', 'WFH',     '2026-03-10 09:00:00+05:30', '2026-03-10 18:00:00+05:30', 510, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-11', 'WFH',     '2026-03-11 09:30:00+05:30', '2026-03-11 18:30:00+05:30', 490, 50, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-12', 'WFH',     '2026-03-12 09:00:00+05:30', '2026-03-12 18:00:00+05:30', 510, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-13', 'WFH',     '2026-03-13 09:00:00+05:30', '2026-03-13 18:00:00+05:30', 510, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-16', 'LEAVE',   NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-17', 'HOLIDAY', NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-18', 'WFH',     '2026-03-18 09:00:00+05:30', '2026-03-18 18:00:00+05:30', 510, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-19', 'WFH',     '2026-03-19 09:00:00+05:30', '2026-03-19 18:00:00+05:30', 510, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-20', 'WFH',     '2026-03-20 09:30:00+05:30', '2026-03-20 18:00:00+05:30', 480, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-23', 'WFH',     '2026-03-23 09:00:00+05:30', '2026-03-23 18:00:00+05:30', 510, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-24', 'PRESENT', '2026-03-24 09:00:00+05:30', '2026-03-24 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-25', 'WFH',     '2026-03-25 09:00:00+05:30', '2026-03-25 18:00:00+05:30', 510, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-26', 'WFH',     '2026-03-26 09:00:00+05:30', '2026-03-26 18:00:00+05:30', 510, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-27', 'WFH',     '2026-03-27 09:00:00+05:30', '2026-03-27 18:00:00+05:30', 510, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-30', 'WFH',     '2026-03-30 09:00:00+05:30', '2026-03-30 18:00:00+05:30', 510, 30, 'WFH', false),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-31', 'WFH',     '2026-03-31 09:00:00+05:30', NULL, 0, 0, 'WFH', false),

  -- ===== Priya Nair (Employee) — hybrid, mostly office =====
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-02', 'PRESENT', '2026-03-02 09:00:00+05:30', '2026-03-02 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-03', 'PRESENT', '2026-03-03 09:15:00+05:30', '2026-03-03 18:15:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-04', 'WFH',     '2026-03-04 09:00:00+05:30', '2026-03-04 17:30:00+05:30', 490, 20, 'WFH', false),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-05', 'PRESENT', '2026-03-05 09:00:00+05:30', '2026-03-05 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-06', 'PRESENT', '2026-03-06 09:00:00+05:30', '2026-03-06 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-09', 'PRESENT', '2026-03-09 09:00:00+05:30', '2026-03-09 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-10', 'PRESENT', '2026-03-10 09:00:00+05:30', '2026-03-10 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-11', 'WFH',     '2026-03-11 09:00:00+05:30', '2026-03-11 18:00:00+05:30', 500, 40, 'WFH', false),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-12', 'PRESENT', '2026-03-12 09:00:00+05:30', '2026-03-12 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-13', 'PRESENT', '2026-03-13 09:00:00+05:30', '2026-03-13 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-16', 'PRESENT', '2026-03-16 09:00:00+05:30', '2026-03-16 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-17', 'HOLIDAY', NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-18', 'PRESENT', '2026-03-18 09:00:00+05:30', '2026-03-18 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-19', 'LEAVE',   NULL, NULL, 0, 0, 'UNKNOWN', NULL),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-20', 'PRESENT', '2026-03-20 09:00:00+05:30', '2026-03-20 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-23', 'PRESENT', '2026-03-23 09:00:00+05:30', '2026-03-23 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-24', 'WFH',     '2026-03-24 09:00:00+05:30', '2026-03-24 18:00:00+05:30', 500, 40, 'WFH', false),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-25', 'PRESENT', '2026-03-25 09:00:00+05:30', '2026-03-25 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-26', 'PRESENT', '2026-03-26 09:00:00+05:30', '2026-03-26 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-27', 'PRESENT', '2026-03-27 09:00:00+05:30', '2026-03-27 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-30', 'PRESENT', '2026-03-30 09:00:00+05:30', '2026-03-30 18:00:00+05:30', 520, 20, 'OFFICE', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-31', 'PRESENT', '2026-03-31 09:00:00+05:30', NULL, 0, 0, 'OFFICE', true);

-- ============================================================
-- 13. Seed leave requests (mix of approved, pending, rejected)
-- ============================================================

INSERT INTO leave_requests (user_id, organization_id, leave_type_id, start_date, end_date, total_days, reason, status, approved_by, approved_at) VALUES
  -- Rajesh: 2 days Annual Leave (approved) — matches his attendance LEAVE on Mar 11-12
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
   'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-11', '2026-03-12', 2,
   'Family event — attending cousin''s wedding', 'APPROVED',
   '22222222-2222-2222-2222-222222222222', '2026-03-06 14:00:00+05:30'),

  -- Sneha: 3 days Annual Leave (approved) — matches her LEAVE on Mar 10-12
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
   'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-10', '2026-03-12', 3,
   'Personal travel — pre-planned vacation', 'APPROVED',
   '11111111-1111-1111-1111-111111111111', '2026-03-05 16:00:00+05:30'),

  -- Rahul: 1 day Casual Leave (approved) — matches LEAVE on Mar 16
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
   'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-16', '2026-03-16', 1,
   'Personal appointment — doctor visit', 'APPROVED',
   '22222222-2222-2222-2222-222222222222', '2026-03-13 10:00:00+05:30'),

  -- Rahul: 1 day Annual Leave (PENDING) — future request
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
   'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-04-10', '2026-04-10', 1,
   'Need to handle apartment lease renewal', 'PENDING',
   NULL, NULL),

  -- Priya: 1 day Sick Leave (approved) — matches LEAVE on Mar 19
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
   'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-19', '2026-03-19', 1,
   'Feeling unwell — fever and cold', 'APPROVED',
   '22222222-2222-2222-2222-222222222222', '2026-03-19 09:30:00+05:30'),

  -- Priya: 2 day Annual Leave (REJECTED)
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
   'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-02-14', '2026-02-15', 2,
   'Short trip for Valentine''s Day', 'REJECTED',
   '22222222-2222-2222-2222-222222222222', '2026-02-10 11:00:00+05:30');

-- ============================================================
-- 14. Seed notifications
-- ============================================================

INSERT INTO notifications (user_id, organization_id, type, title, message, is_read) VALUES
  -- For Rajesh (admin)
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'LEAVE_APPROVED', 'Leave Approved', 'Your Annual Leave for Mar 11–12 has been approved by Sneha Sharma.', true),
  ('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'LEAVE_APPLIED', 'New Leave Request', 'Rahul Patel has applied for 1 day Annual Leave on Apr 10.', false),

  -- For Sneha (HR)
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'LEAVE_APPROVED', 'Leave Approved', 'Your Annual Leave for Mar 10–12 has been approved by Rajesh Kumar.', true),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'LEAVE_APPLIED', 'New Leave Request', 'Rahul Patel has applied for 1 day Annual Leave on Apr 10.', false),
  ('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'NON_COMPLIANT', 'Non-Compliance Alert', 'Rahul Patel was marked absent on Mar 6 without leave application.', false),

  -- For Rahul (employee)
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'LEAVE_APPROVED', 'Leave Approved', 'Your Casual Leave for Mar 16 has been approved by Sneha Sharma.', true),
  ('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'IDLE_THRESHOLD', 'Idle Alert', 'You were idle for 45 minutes on Mar 4. Please stay active during work hours.', false),

  -- For Priya (employee)
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'LEAVE_APPROVED', 'Leave Approved', 'Your Sick Leave for Mar 19 has been approved by Sneha Sharma.', true),
  ('44444444-4444-4444-4444-444444444444', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'LEAVE_REJECTED', 'Leave Rejected', 'Your Annual Leave for Feb 14–15 was rejected. Reason: Team deadline conflict.', true);

-- ============================================================
-- 15. Seed anonymous feedback
-- ============================================================

INSERT INTO anonymous_feedback (organization_id, user_hash, category, content, moderation_status) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', encode(extensions.digest('user1-salt', 'sha256'), 'hex'), 'work-environment', 'The office AC temperature is always too cold. Can we adjust it to a more comfortable level?', 'PENDING'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', encode(extensions.digest('user2-salt', 'sha256'), 'hex'), 'management', 'Team standup meetings are running too long. Can we keep them under 15 minutes?', 'APPROVED'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', encode(extensions.digest('user3-salt', 'sha256'), 'hex'), 'general', 'Really appreciate the new WFH policy — it has improved work-life balance significantly!', 'APPROVED');

-- ============================================================
-- Done! Test Credentials Summary:
-- ============================================================
--
-- ┌──────────────────┬──────────────┬──────────┬───────────────────────┬──────────────┐
-- │ Email            │ Password     │ Role     │ Name                  │ Salary (INR) │
-- ├──────────────────┼──────────────┼──────────┼───────────────────────┼──────────────┤
-- │ admin@acme.com   │ password123  │ ADMIN    │ Rajesh Kumar (CTO)    │ ₹1,50,000    │
-- │ hr@acme.com      │ password123  │ HR       │ Sneha Sharma (HR Mgr) │ ₹85,000      │
-- │ rahul@acme.com   │ password123  │ EMPLOYEE │ Rahul Patel (SDE)     │ ₹60,000      │
-- │ priya@acme.com   │ password123  │ EMPLOYEE │ Priya Nair (Analyst)  │ ₹55,000      │
-- └──────────────────┴──────────────┴──────────┴───────────────────────┴──────────────┘
--
-- Run `npx supabase db reset` to apply this seed data.
