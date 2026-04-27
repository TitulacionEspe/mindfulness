-- =============================================================================
-- PGS-25: Panel de administracion del sistema
-- =============================================================================
-- Objetivo:
-- - Habilitar gestion administrativa de usuarios, roles, cuentas, contenidos,
--   recursos multimedia, configuracion global, consentimientos y metricas.
-- - Mantener aislamiento de informacion sensible: las metricas admin son
--   agregadas y no exponen pensamientos privados ni registros emocionales
--   individualizados.

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Perfiles: correo, estado operativo y proteccion de ultimo admin activo
-- ---------------------------------------------------------------------------

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS email TEXT;

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS account_status TEXT NOT NULL DEFAULT 'active'
CHECK (account_status IN ('active', 'inactive', 'blocked'));

UPDATE public.profiles
SET account_status = CASE WHEN is_active THEN 'active' ELSE 'inactive' END
WHERE account_status IS NULL;

CREATE INDEX IF NOT EXISTS idx_profiles_role_status
ON public.profiles(role, account_status);

CREATE INDEX IF NOT EXISTS idx_profiles_email_lower
ON public.profiles(LOWER(email))
WHERE email IS NOT NULL;

CREATE OR REPLACE FUNCTION public.ensure_active_admin_remains()
RETURNS TRIGGER AS $$
DECLARE
  remaining_admins INTEGER;
BEGIN
  IF TG_OP = 'DELETE' THEN
    IF OLD.role = 'admin' AND OLD.is_active = TRUE AND OLD.account_status = 'active' THEN
      SELECT COUNT(*)
      INTO remaining_admins
      FROM public.profiles
      WHERE id <> OLD.id
        AND role = 'admin'
        AND is_active = TRUE
        AND account_status = 'active';

      IF remaining_admins = 0 THEN
        RAISE EXCEPTION 'No se puede dejar el sistema sin un administrador activo.';
      END IF;
    END IF;
    RETURN OLD;
  END IF;

  IF NEW.account_status IS DISTINCT FROM OLD.account_status THEN
    NEW.is_active := NEW.account_status = 'active';
  ELSIF NEW.is_active IS DISTINCT FROM OLD.is_active THEN
    NEW.account_status := CASE WHEN NEW.is_active THEN 'active' ELSE 'inactive' END;
  END IF;

  IF OLD.role = 'admin'
     AND OLD.is_active = TRUE
     AND OLD.account_status = 'active'
     AND (
       NEW.role <> 'admin'
       OR NEW.is_active = FALSE
       OR NEW.account_status <> 'active'
     ) THEN
    SELECT COUNT(*)
    INTO remaining_admins
    FROM public.profiles
    WHERE id <> OLD.id
      AND role = 'admin'
      AND is_active = TRUE
      AND account_status = 'active';

    IF remaining_admins = 0 THEN
      RAISE EXCEPTION 'No se puede dejar el sistema sin un administrador activo.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS protect_active_admin_update ON public.profiles;
CREATE TRIGGER protect_active_admin_update
BEFORE UPDATE OF role, is_active, account_status ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.ensure_active_admin_remains();

DROP TRIGGER IF EXISTS protect_active_admin_delete ON public.profiles;
CREATE TRIGGER protect_active_admin_delete
BEFORE DELETE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.ensure_active_admin_remains();

CREATE OR REPLACE FUNCTION public.create_user_profile()
RETURNS TRIGGER AS $$
DECLARE
    default_role public.user_role := 'patient';
    default_segment public.user_segment := 'student';
    metadata_full_name TEXT;
BEGIN
    IF NEW.raw_user_meta_data IS NOT NULL THEN
        metadata_full_name := NEW.raw_user_meta_data ->> 'full_name';

        IF NEW.raw_user_meta_data ? 'segment' THEN
            default_segment := (NEW.raw_user_meta_data ->> 'segment')::public.user_segment;
        END IF;
    END IF;

    INSERT INTO public.profiles (
      id,
      email,
      role,
      segment,
      full_name,
      is_active,
      account_status
    )
    VALUES (
      NEW.id,
      NEW.email,
      default_role,
      default_segment,
      metadata_full_name,
      TRUE,
      'active'
    )
    ON CONFLICT (id) DO UPDATE SET
      email = EXCLUDED.email,
      updated_at = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.create_user_profile();

-- ---------------------------------------------------------------------------
-- 2. Auditoria administrativa
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.admin_audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  target_table TEXT NOT NULL,
  target_id UUID,
  action TEXT NOT NULL,
  previous_value JSONB,
  new_value JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.admin_audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can read audit logs" ON public.admin_audit_logs;
CREATE POLICY "Admins can read audit logs"
ON public.admin_audit_logs
FOR SELECT
TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can insert audit logs" ON public.admin_audit_logs;
CREATE POLICY "Admins can insert audit logs"
ON public.admin_audit_logs
FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_created
ON public.admin_audit_logs(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_target
ON public.admin_audit_logs(target_table, target_id);

CREATE OR REPLACE FUNCTION public.log_profile_admin_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.role IS DISTINCT FROM NEW.role
     OR OLD.is_active IS DISTINCT FROM NEW.is_active
     OR OLD.account_status IS DISTINCT FROM NEW.account_status THEN
    INSERT INTO public.admin_audit_logs (
      actor_id,
      target_table,
      target_id,
      action,
      previous_value,
      new_value
    )
    VALUES (
      auth.uid(),
      'profiles',
      NEW.id,
      'profile_admin_update',
      jsonb_build_object(
        'role', OLD.role,
        'is_active', OLD.is_active,
        'account_status', OLD.account_status
      ),
      jsonb_build_object(
        'role', NEW.role,
        'is_active', NEW.is_active,
        'account_status', NEW.account_status
      )
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS audit_profile_admin_changes ON public.profiles;
CREATE TRIGGER audit_profile_admin_changes
AFTER UPDATE OF role, is_active, account_status ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.log_profile_admin_changes();

-- ---------------------------------------------------------------------------
-- 3. Contenidos y recursos administrables
-- ---------------------------------------------------------------------------

ALTER TABLE public.routines
ADD COLUMN IF NOT EXISTS content_status TEXT NOT NULL DEFAULT 'active'
CHECK (content_status IN ('draft', 'active', 'inactive'));

ALTER TABLE public.routines
ADD COLUMN IF NOT EXISTS is_visible_to_patients BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE public.routines
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE public.routines
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL;

ALTER TABLE public.routines
ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL;

UPDATE public.routines
SET content_status = CASE WHEN is_active THEN 'active' ELSE 'inactive' END
WHERE content_status IS NULL;

DROP TRIGGER IF EXISTS set_updated_at_routines_admin ON public.routines;
CREATE TRIGGER set_updated_at_routines_admin
BEFORE UPDATE ON public.routines
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.routine_assets
ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE public.routine_assets
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE public.routine_assets
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

DROP TRIGGER IF EXISTS set_updated_at_routine_assets_admin ON public.routine_assets;
CREATE TRIGGER set_updated_at_routine_assets_admin
BEFORE UPDATE ON public.routine_assets
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.content_messages
ADD COLUMN IF NOT EXISTS title TEXT;

ALTER TABLE public.content_messages
ADD COLUMN IF NOT EXISTS content_status TEXT NOT NULL DEFAULT 'active'
CHECK (content_status IN ('draft', 'active', 'inactive'));

ALTER TABLE public.content_messages
ADD COLUMN IF NOT EXISTS is_visible_to_patients BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE public.content_messages
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

DROP TRIGGER IF EXISTS set_updated_at_content_messages_admin ON public.content_messages;
CREATE TRIGGER set_updated_at_content_messages_admin
BEFORE UPDATE ON public.content_messages
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX IF NOT EXISTS idx_routines_admin_status
ON public.routines(content_status, is_visible_to_patients);

CREATE INDEX IF NOT EXISTS idx_routine_assets_active
ON public.routine_assets(routine_id, is_active);

-- ---------------------------------------------------------------------------
-- 4. Configuracion global y documentos institucionales
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.system_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  settings_key TEXT NOT NULL UNIQUE DEFAULT 'global',
  default_theme TEXT NOT NULL DEFAULT 'light' CHECK (default_theme IN ('light', 'dark')),
  dark_mode_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  responsible_use_notice TEXT NOT NULL DEFAULT 'Esta aplicacion promueve bienestar y no reemplaza atencion profesional.',
  general_orientation_message TEXT NOT NULL DEFAULT 'Usa las rutinas como apoyo de autocuidado y busca ayuda profesional si lo necesitas.',
  recommended_session_duration_minutes INTEGER NOT NULL DEFAULT 10 CHECK (recommended_session_duration_minutes BETWEEN 1 AND 45),
  professional_module_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  patient_professional_assignment_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  content_validation_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  active_consent_version TEXT NOT NULL DEFAULT '1.0.0',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.system_settings (settings_key)
VALUES ('global')
ON CONFLICT (settings_key) DO NOTHING;

DROP TRIGGER IF EXISTS set_updated_at_system_settings_admin ON public.system_settings;
CREATE TRIGGER set_updated_at_system_settings_admin
BEFORE UPDATE ON public.system_settings
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TABLE IF NOT EXISTS public.legal_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  document_type TEXT NOT NULL CHECK (document_type IN ('consent', 'responsible_use')),
  version TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  content_status TEXT NOT NULL DEFAULT 'draft' CHECK (content_status IN ('draft', 'active', 'inactive')),
  is_current BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (document_type, version)
);

INSERT INTO public.legal_documents (
  document_type,
  version,
  title,
  body,
  content_status,
  is_current
) VALUES
(
  'consent',
  '1.0.0',
  'Consentimiento informado',
  'El sistema es una herramienta de bienestar y no realiza diagnostico ni reemplaza atencion profesional.',
  'active',
  TRUE
),
(
  'responsible_use',
  '1.0.0',
  'Aviso de uso responsable',
  'Usa la aplicacion como apoyo de autocuidado. Si presentas malestar intenso o riesgo, contacta a un profesional o servicio de emergencia.',
  'active',
  TRUE
)
ON CONFLICT (document_type, version) DO NOTHING;

DROP TRIGGER IF EXISTS set_updated_at_legal_documents_admin ON public.legal_documents;
CREATE TRIGGER set_updated_at_legal_documents_admin
BEFORE UPDATE ON public.legal_documents
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_documents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can manage system settings" ON public.system_settings;
CREATE POLICY "Admins can manage system settings"
ON public.system_settings
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage legal documents" ON public.legal_documents;
CREATE POLICY "Admins can manage legal documents"
ON public.legal_documents
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Authenticated users can read current legal documents" ON public.legal_documents;
CREATE POLICY "Authenticated users can read current legal documents"
ON public.legal_documents
FOR SELECT
TO authenticated
USING (content_status = 'active' AND is_current = TRUE);

-- ---------------------------------------------------------------------------
-- 5. Politicas RLS admin para catalogos base
-- ---------------------------------------------------------------------------

ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breathing_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can manage routines" ON public.routines;
CREATE POLICY "Admins can manage routines"
ON public.routines
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage routine assets" ON public.routine_assets;
CREATE POLICY "Admins can manage routine assets"
ON public.routine_assets
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage breathing patterns" ON public.breathing_patterns;
CREATE POLICY "Admins can manage breathing patterns"
ON public.breathing_patterns
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage content messages" ON public.content_messages;
CREATE POLICY "Admins can manage content messages"
ON public.content_messages
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Tighten patient catalog visibility while preserving existing policy names.
DROP POLICY IF EXISTS "Acceso lectura catalogo rutinas" ON public.routines;
DROP POLICY IF EXISTS "Acceso lectura catÃ¡logo rutinas" ON public.routines;
CREATE POLICY "Acceso lectura catalogo rutinas"
ON public.routines
FOR SELECT
TO authenticated
USING (
  is_active = TRUE
  AND content_status = 'active'
  AND is_visible_to_patients = TRUE
);

DROP POLICY IF EXISTS "Acceso lectura assets rutinas" ON public.routine_assets;
CREATE POLICY "Acceso lectura assets rutinas"
ON public.routine_assets
FOR SELECT
TO authenticated
USING (
  is_active = TRUE
  AND EXISTS (
    SELECT 1
    FROM public.routines r
    WHERE r.id = routine_assets.routine_id
      AND r.is_active = TRUE
      AND r.content_status = 'active'
      AND r.is_visible_to_patients = TRUE
  )
);

DROP POLICY IF EXISTS "Acceso lectura mensajes" ON public.content_messages;
CREATE POLICY "Acceso lectura mensajes"
ON public.content_messages
FOR SELECT
TO authenticated
USING (
  is_active = TRUE
  AND content_status = 'active'
  AND is_visible_to_patients = TRUE
);

-- ---------------------------------------------------------------------------
-- 6. Metricas agregadas no sensibles para dashboard admin
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.admin_overview_metrics()
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Acceso administrativo requerido.';
  END IF;

  SELECT jsonb_build_object(
    'total_users', (SELECT COUNT(*) FROM public.profiles),
    'patients', (SELECT COUNT(*) FROM public.profiles WHERE role = 'patient'),
    'professionals', (SELECT COUNT(*) FROM public.profiles WHERE role = 'professional'),
    'admins', (SELECT COUNT(*) FROM public.profiles WHERE role = 'admin'),
    'active_accounts', (SELECT COUNT(*) FROM public.profiles WHERE is_active = TRUE AND account_status = 'active'),
    'inactive_accounts', (SELECT COUNT(*) FROM public.profiles WHERE account_status = 'inactive'),
    'blocked_accounts', (SELECT COUNT(*) FROM public.profiles WHERE account_status = 'blocked'),
    'routines_total', (SELECT COUNT(*) FROM public.routines),
    'routines_active', (SELECT COUNT(*) FROM public.routines WHERE content_status = 'active' AND is_visible_to_patients = TRUE),
    'messages_active', (SELECT COUNT(*) FROM public.content_messages WHERE content_status = 'active' AND is_visible_to_patients = TRUE),
    'assets_total', (SELECT COUNT(*) FROM public.routine_assets),
    'sessions_total', (SELECT COUNT(*) FROM public.activity_sessions),
    'sessions_completed', (SELECT COUNT(*) FROM public.activity_sessions WHERE status = 'completed'),
    'active_days_30', (
      SELECT COUNT(DISTINCT DATE(started_at))
      FROM public.activity_sessions
      WHERE started_at >= NOW() - INTERVAL '30 days'
    ),
    'users_by_role', (
      SELECT COALESCE(jsonb_object_agg(role::TEXT, total), '{}'::JSONB)
      FROM (
        SELECT role, COUNT(*) AS total
        FROM public.profiles
        GROUP BY role
      ) role_counts
    ),
    'activity_by_period', (
      SELECT COALESCE(jsonb_agg(item ORDER BY item->>'date'), '[]'::JSONB)
      FROM (
        SELECT jsonb_build_object(
          'date', DATE(started_at)::TEXT,
          'sessions', COUNT(*)
        ) AS item
        FROM public.activity_sessions
        WHERE started_at >= CURRENT_DATE - INTERVAL '6 days'
        GROUP BY DATE(started_at)
      ) activity
    )
  )
  INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.admin_overview_metrics() TO authenticated;

GRANT ALL ON public.profiles TO authenticated;
GRANT ALL ON public.routines TO authenticated;
GRANT ALL ON public.routine_assets TO authenticated;
GRANT ALL ON public.breathing_patterns TO authenticated;
GRANT ALL ON public.content_messages TO authenticated;
GRANT ALL ON public.system_settings TO authenticated;
GRANT ALL ON public.legal_documents TO authenticated;
GRANT ALL ON public.admin_audit_logs TO authenticated;

COMMIT;
