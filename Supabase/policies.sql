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
DROP POLICY IF EXISTS "Admins can delete profiles" ON public.profiles;
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
DECLARE
    default_role public.user_role := 'patient';
    default_segment public.user_segment := 'student';
    metadata_full_name TEXT;
BEGIN
    -- Extract metadata with safety checks
    IF NEW.raw_user_meta_data IS NOT NULL THEN
        metadata_full_name := NEW.raw_user_meta_data ->> 'full_name';
        
        -- Optional: Override defaults if provided in metadata
        IF NEW.raw_user_meta_data ? 'role' THEN
            default_role := (NEW.raw_user_meta_data ->> 'role')::public.user_role;
        END IF;
        
        IF NEW.raw_user_meta_data ? 'segment' THEN
            default_segment := (NEW.raw_user_meta_data ->> 'segment')::public.user_segment;
        END IF;
    END IF;

    -- Insert into public.profiles
    INSERT INTO public.profiles (id, role, segment, full_name, is_active)
    VALUES (
        NEW.id, 
        default_role, 
        default_segment, 
        metadata_full_name, 
        TRUE
    );
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
-- RLS (Row Level Security) Policies for Consents Table
-- ============================================
-- Purpose: Ensure users can only manage their own ethical consents
-- Applied to table: public.consents

-- Enable RLS on consents table
ALTER TABLE public.consents ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they already exist (idempotent)
DROP POLICY IF EXISTS "Users can view own consents" ON public.consents;
DROP POLICY IF EXISTS "Users can insert own consents" ON public.consents;

-- 1. SELECT policy: Users can only see their own consent records
CREATE POLICY "Users can view own consents"
ON public.consents FOR SELECT
USING (auth.uid() = patient_id);

-- 2. INSERT policy: Users can only insert their own consent
CREATE POLICY "Users can insert own consents"
ON public.consents FOR INSERT
WITH CHECK (auth.uid() = patient_id);

-- Index to prevent duplicate consents for the same version by the same user
CREATE UNIQUE INDEX IF NOT EXISTS idx_consents_unique_user_version 
ON public.consents (patient_id, document_version);

-- Grant permissions
GRANT ALL ON public.consents TO authenticated;

-- ============================================
-- Grant permissions
-- ============================================
GRANT ALL ON public.profiles TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;
