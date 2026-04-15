-- ============================================
-- RLS (Row Level Security) Policies for Profiles Table
-- ============================================
-- Purpose: Ensure users can ONLY access their own profile data
-- Applied to table: public.profiles
-- NOTE: This script is idempotent - safe to run multiple times.

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

-- ============================================
-- Create policies (idempotent)
-- ============================================

-- 1. SELECT policy: Users can only see their own profile
CREATE POLICY "Users can view own profile"
ON public.profiles
FOR SELECT
USING (
  auth.uid() = id
);

-- 2. INSERT policy: Users can only insert their own profile (during signup)
CREATE POLICY "Users can insert own profile"
ON public.profiles
FOR INSERT
WITH CHECK (
  auth.uid() = id
);

-- 3. UPDATE policy: Users can only update their own profile
CREATE POLICY "Users can update own profile"
ON public.profiles
FOR UPDATE
USING (
  auth.uid() = id
)
WITH CHECK (
  auth.uid() = id
);

-- 4. DELETE policy: Users can only delete their own profile
CREATE POLICY "Users can delete own profile"
ON public.profiles
FOR DELETE
USING (
  auth.uid() = id
);

-- ============================================
-- TRIGGER: Auto-create profile on signup
-- (Recommended server-side approach - more robust than Flutter code)
-- ============================================
-- This function automatically creates a profile when a user signs up.
-- Uses SECURITY DEFINER so it runs with elevated privileges,
-- bypassing RLS. This ensures the profile is ALWAYS created.

CREATE OR REPLACE FUNCTION public.create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, role, segment, full_name, is_active)
  VALUES (NEW.id, 'patient', 'student', NULL, TRUE);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists (idempotent)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.create_user_profile();

-- ============================================
-- Grant permissions to authenticated users
-- ============================================
GRANT ALL ON public.profiles TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;
