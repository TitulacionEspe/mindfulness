-- ============================================
-- RLS (Row Level Security) Policies for Profiles Table
-- ============================================
-- Purpose: Implement Role-Based Access Control (RBAC)
-- Applied to table: public.profiles
-- NOTE: This script is idempotent - safe to run multiple times.

-- ============================================
-- Helper Functions for RBAC
-- ============================================

-- Function to get the current user's role
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS public.user_role AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Function to check if the current user is an admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
  SELECT role = 'admin' FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Function to check if the current user is a professional
CREATE OR REPLACE FUNCTION public.is_professional()
RETURNS boolean AS $$
  SELECT role = 'professional' FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- ============================================
-- Enable RLS on profiles table (idempotent)
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Drop existing policies if they already exist
-- ============================================
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Professionals can view assigned patients" ON public.profiles;

-- ============================================
-- Create policies (RBAC)
-- ============================================

-- 1. SELECT policies
CREATE POLICY "Users can view own profile"
ON public.profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
ON public.profiles FOR SELECT
USING (public.is_admin());

-- Professionals can view patients assigned to them (logic placeholder for assignments table)
CREATE POLICY "Professionals can view assigned patients"
ON public.profiles FOR SELECT
USING (
  public.is_professional() AND (
    EXISTS (
      SELECT 1 FROM public.assignments 
      WHERE professional_id = auth.uid() AND patient_id = public.profiles.id
    )
  )
);

-- 2. INSERT policy
CREATE POLICY "Users can insert own profile"
ON public.profiles FOR INSERT
WITH CHECK (auth.uid() = id);

-- 3. UPDATE policies
CREATE POLICY "Users can update own profile"
ON public.profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can update all profiles"
ON public.profiles FOR UPDATE
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 4. DELETE policy
CREATE POLICY "Admins can delete profiles"
ON public.profiles FOR DELETE
USING (public.is_admin());

-- ============================================
-- TRIGGER: Auto-create profile on signup
-- ============================================
CREATE OR REPLACE FUNCTION public.create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, role, segment, full_name, is_active)
  VALUES (NEW.id, 'patient', 'student', NULL, TRUE);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ensure trigger exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.create_user_profile();

-- ============================================
-- Grant permissions
-- ============================================
GRANT ALL ON public.profiles TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;
