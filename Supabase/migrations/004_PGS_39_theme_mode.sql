-- Migracion: PGS-39 Tema visual claro/oscuro
-- Fecha: 2026-04-25
-- Descripcion: Agrega preferencia global de tema por perfil y alinea el
-- default de configuracion nocturna con Light Mode por defecto.

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS theme_mode TEXT NOT NULL DEFAULT 'light'
CHECK (theme_mode IN ('light', 'dark'));

COMMENT ON COLUMN public.profiles.theme_mode IS 'Preferencia visual global del usuario: light o dark.';

ALTER TABLE public.patient_settings
ALTER COLUMN dark_mode_enforced SET DEFAULT FALSE;
