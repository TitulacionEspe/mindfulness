-- ============================================
-- RLS (Row Level Security) Policies & Hardening
-- ============================================
-- Purpose: Consolidate all security policies, triggers and indexes
-- Applied to: public schema
-- NOTE: This script is idempotent - safe to run multiple times.

-- ============================================
-- 1. Helper Functions for RBAC
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
-- 2. Profiles Table Hardening
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can delete profiles" ON public.profiles;
DROP POLICY IF EXISTS "Professionals can view assigned patients" ON public.profiles;

CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "Admins can view all profiles" ON public.profiles FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins can update all profiles" ON public.profiles FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins can delete profiles" ON public.profiles FOR DELETE USING (public.is_admin());

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

-- ============================================
-- 3. TRIGGER: Auto-create profile on signup (Improved from PGS-6)
-- ============================================
CREATE OR REPLACE FUNCTION public.create_user_profile()
RETURNS TRIGGER AS $$
DECLARE
    default_role public.user_role := 'patient';
    default_segment public.user_segment := 'student';
    metadata_full_name TEXT;
BEGIN
    -- Extract metadata with safety checks from Supabase Auth
    IF NEW.raw_user_meta_data IS NOT NULL THEN
        metadata_full_name := NEW.raw_user_meta_data ->> 'full_name';
        
        IF NEW.raw_user_meta_data ? 'role' THEN
            default_role := (NEW.raw_user_meta_data ->> 'role')::public.user_role;
        END IF;
        
        IF NEW.raw_user_meta_data ? 'segment' THEN
            default_segment := (NEW.raw_user_meta_data ->> 'segment')::public.user_segment;
        END IF;
    END IF;

    INSERT INTO public.profiles (id, role, segment, full_name, is_active)
    VALUES (NEW.id, default_role, default_segment, metadata_full_name, TRUE);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.create_user_profile();

-- ============================================
-- 4. Consents & Privacy Hardening
-- ============================================
ALTER TABLE public.consents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own consents" ON public.consents;
DROP POLICY IF EXISTS "Users can insert own consents" ON public.consents;

CREATE POLICY "Users can view own consents" ON public.consents FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Users can insert own consents" ON public.consents FOR INSERT WITH CHECK (auth.uid() = patient_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_consents_unique_user_version ON public.consents (patient_id, document_version);

-- ============================================
-- 5. Reminders & Settings Hardening
-- ============================================
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own reminders" ON public.reminders;
CREATE POLICY "Users can manage own reminders" ON public.reminders FOR ALL USING (auth.uid() = patient_id);

-- ============================================
-- 6. Risk Flags Hardening (Sensitive Isolation)
-- ============================================
ALTER TABLE public.risk_flags ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own risk flags" ON public.risk_flags;
DROP POLICY IF EXISTS "Professionals can view assigned risk flags" ON public.risk_flags;

CREATE POLICY "Users can view own risk flags" ON public.risk_flags FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Professionals can view assigned risk flags" 
ON public.risk_flags FOR SELECT 
USING (public.is_assigned_professional(patient_id));

-- ============================================
-- 7. Thought Entries Hardening (Private Emotional Discharge)
-- ============================================
ALTER TABLE public.thought_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Privacidad inquebrantable de pensamientos" ON public.thought_entries;
DROP POLICY IF EXISTS "thought_entries_select_own" ON public.thought_entries;
DROP POLICY IF EXISTS "thought_entries_insert_own" ON public.thought_entries;
DROP POLICY IF EXISTS "thought_entries_update_own" ON public.thought_entries;
DROP POLICY IF EXISTS "thought_entries_delete_own" ON public.thought_entries;

CREATE POLICY "thought_entries_select_own" ON public.thought_entries
FOR SELECT TO authenticated
USING (auth.uid() = patient_id);

CREATE POLICY "thought_entries_insert_own" ON public.thought_entries
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = patient_id);

CREATE POLICY "thought_entries_update_own" ON public.thought_entries
FOR UPDATE TO authenticated
USING (auth.uid() = patient_id)
WITH CHECK (auth.uid() = patient_id);

CREATE POLICY "thought_entries_delete_own" ON public.thought_entries
FOR DELETE TO authenticated
USING (auth.uid() = patient_id);

CREATE INDEX IF NOT EXISTS idx_thought_entries_patient_created_desc
ON public.thought_entries(patient_id, created_at DESC);

-- ============================================
-- 8. Operational Triggers & Performance
-- ============================================
-- Ensure all tables have updated_at triggers (Idempotent)
CREATE TRIGGER set_updated_at_profiles_p BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_consents_p BEFORE UPDATE ON public.consents FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_reminders_p BEFORE UPDATE ON public.reminders FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_risk_flags_p BEFORE UPDATE ON public.risk_flags FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
DROP TRIGGER IF EXISTS set_updated_at_thought_entries_p ON public.thought_entries;
CREATE TRIGGER set_updated_at_thought_entries_p BEFORE UPDATE ON public.thought_entries FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Ensure indexes for sensitive lookups
CREATE INDEX IF NOT EXISTS idx_risk_flags_patient ON public.risk_flags(patient_id);
CREATE INDEX IF NOT EXISTS idx_reminders_patient ON public.reminders(patient_id);
CREATE INDEX IF NOT EXISTS idx_consents_patient ON public.consents(patient_id);

-- ============================================
-- 9. Permissions & Final Grants
-- ============================================
GRANT ALL ON public.profiles TO authenticated;
GRANT ALL ON public.consents TO authenticated;
GRANT ALL ON public.reminders TO authenticated;
GRANT ALL ON public.risk_flags TO authenticated;
GRANT ALL ON public.thought_entries TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;
