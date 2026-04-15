-- ============================================
-- RBAC Test Users - Development Seeds
-- ============================================
-- Purpose: Set up test users with different roles to verify RLS and Navigation.
-- WARNING: Delete this file before production deployment.

/* 
  STEP 1: Create 3 users in your Supabase Dashboard (Authentication > Users)
  - admin@test.com
  - professional@test.com
  - patient@test.com
  
  STEP 2: Copy their IDs (UUIDs) and replace the placeholders below.
*/

-- 1. Set ADMIN role
UPDATE public.profiles 
SET role = 'admin', full_name = 'Test Admin'
WHERE id = '6083d6d9-e32c-4e47-9139-12c104f6032e';

-- 2. Set PROFESSIONAL role
UPDATE public.profiles 
SET role = 'professional', full_name = 'Test Professional'
WHERE id = '0bf5bd4c-84ef-446d-ae18-9a6c6e429bf9';

-- 3. Set PATIENT role (Optional, as trigger sets it by default)
UPDATE public.profiles 
SET role = 'patient', full_name = 'Test Patient'
WHERE id = 'd7980534-65f4-49f3-b8e1-4c631df5cddd';

-- 4. Verify Roles
SELECT 
    p.id as profile_id, 
    u.email, 
    p.role, 
    p.full_name 
FROM public.profiles p
JOIN auth.users u ON p.id = u.id;
