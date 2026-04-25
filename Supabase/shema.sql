-- ==============================================================================
-- ESQUEMA DE BASE DE DATOS SUPABASE - SISTEMA MINDFULNESS E HIGIENE DEL SUEÑO
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- PASO 1: Inicialización de Extensiones y Tipos de Datos (ENUMs)
-- ------------------------------------------------------------------------------
-- La extensión "uuid-ossp" es requerida para generar IDs únicos globales (UUIDs).
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- La extensión "pgcrypto" prepara la base de datos para cifrar datos sensibles (diarios de pensamiento).
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Creación de Tipos de Datos Enumerados (ENUMs) para optimizar el almacenamiento y evitar errores.
CREATE TYPE user_role AS ENUM ('patient', 'professional', 'admin');
CREATE TYPE user_segment AS ENUM ('student', 'teacher', 'military', 'admin_staff');
CREATE TYPE routine_category AS ENUM ('relaxation', 'breathing', 'sleep_induction', 'soundscape');
CREATE TYPE session_status AS ENUM ('completed', 'skipped', 'interrupted');
CREATE TYPE assessment_context AS ENUM ('pre_session', 'post_session', 'standalone');
CREATE TYPE flag_status AS ENUM ('active', 'reviewed', 'closed');
CREATE TYPE assignment_status AS ENUM ('pending', 'completed', 'expired');

-- ------------------------------------------------------------------------------
-- PASO 2: Dominio de Identidad, Perfiles y Consentimiento Ético
-- ------------------------------------------------------------------------------
-- Tabla de perfiles. Se enlaza automáticamente a auth.users de Supabase.
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL DEFAULT 'patient',
    segment user_segment NOT NULL DEFAULT 'student',
    full_name TEXT,
    theme_mode TEXT NOT NULL DEFAULT 'light' CHECK (theme_mode IN ('light', 'dark')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Tabla para el registro auditable del consentimiento ético de no diagnóstico.
CREATE TABLE public.consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    document_version TEXT NOT NULL,
    terms_accepted BOOLEAN NOT NULL CHECK (terms_accepted = TRUE),
    accepted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tabla para configuraciones del paciente (ej. forzar interfaz oscura en la noche).
CREATE TABLE public.patient_settings (
    patient_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    habitual_bedtime TIME WITHOUT TIME ZONE,
    habitual_wake_time TIME WITHOUT TIME ZONE,
    dark_mode_enforced BOOLEAN NOT NULL DEFAULT FALSE,
    preferred_voice TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Configuración de recordatorios para usar la aplicación.
CREATE TABLE public.reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    trigger_time TIME WITHOUT TIME ZONE NOT NULL,
    days_of_week SMALLINT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- ------------------------------------------------------------------------------
-- PASO 3: Dominio Clínico y Catálogos de Rutinas
-- ------------------------------------------------------------------------------
-- Catálogo central de rutinas. Se restringe a sesiones cortas (max 45 min = 2700s).
CREATE TABLE public.routines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    category routine_category NOT NULL,
    duration_seconds INTEGER NOT NULL CHECK (duration_seconds > 0 AND duration_seconds <= 2700),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Metadatos para vincular los archivos de audio almacenados en Supabase Storage.
CREATE TABLE public.routine_assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    routine_id UUID NOT NULL REFERENCES public.routines(id) ON DELETE CASCADE,
    storage_bucket TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    file_type TEXT,
    file_size_bytes BIGINT
);

-- Parámetros dinámicos para los ejercicios de respiración en la app Flutter.
CREATE TABLE public.breathing_patterns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    routine_id UUID NOT NULL REFERENCES public.routines(id) ON DELETE CASCADE,
    inhale_sec INTEGER NOT NULL CHECK (inhale_sec > 0),
    hold_in_sec INTEGER NOT NULL CHECK (hold_in_sec >= 0),
    exhale_sec INTEGER NOT NULL CHECK (exhale_sec > 0),
    hold_out_sec INTEGER NOT NULL CHECK (hold_out_sec >= 0),
    cycles_recommended INTEGER NOT NULL DEFAULT 5
);

-- ------------------------------------------------------------------------------
-- PASO 4: Dominio Transaccional y Monitoreo Histórico
-- ------------------------------------------------------------------------------
-- Historial de uso: qué rutinas inicia y termina el usuario.
CREATE TABLE public.activity_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    routine_id UUID NOT NULL REFERENCES public.routines(id),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    status session_status NOT NULL DEFAULT 'interrupted',
    notes TEXT
);

-- Escala de autopercepción de estrés/ansiedad pre y post rutina.
CREATE TABLE public.self_assessments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.activity_sessions(id) ON DELETE SET NULL,
    context assessment_context NOT NULL,
    emotion_id TEXT NOT NULL, 
    intensity INTEGER NOT NULL CHECK (intensity >= 1 AND intensity <= 10),
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Diario de sueño (Sleep Logs) para registrar tiempos e interrupciones en la noche.
CREATE TABLE public.sleep_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    log_date DATE NOT NULL DEFAULT CURRENT_DATE,
    bed_time TIMESTAMPTZ NOT NULL,
    wake_time TIMESTAMPTZ NOT NULL,
    sleep_latency_min INTEGER CHECK (sleep_latency_min >= 0),
    wake_after_sleep_onset_min INTEGER CHECK (wake_after_sleep_onset_min >= 0),
    sleep_quality_rating INTEGER CHECK (sleep_quality_rating >= 1 AND sleep_quality_rating <= 5),
    disturbances TEXT,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- PASO 5: Dominio de Alta Confidencialidad y Gestión Institucional
-- ------------------------------------------------------------------------------
-- Diario íntimo. Guarda el texto cifrado (ciphertext) para la catarsis en crisis.
CREATE TABLE public.thought_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content_ciphertext TEXT NOT NULL, 
    key_id UUID, 
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Alertas internas (Flags) por si se detecta texto de riesgo para la vida del usuario.
CREATE TABLE public.risk_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    source_entry_id UUID REFERENCES public.thought_entries(id) ON DELETE SET NULL,
    flag_type TEXT NOT NULL,
    detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status flag_status NOT NULL DEFAULT 'active',
    resolution_notes TEXT
);

-- Asignación oficial de rutinas desde un profesional de la ESPE hacia un estudiante.
CREATE TABLE public.assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    professional_id UUID NOT NULL REFERENCES public.profiles(id),
    routine_id UUID NOT NULL REFERENCES public.routines(id),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    target_completion DATE,
    status assignment_status NOT NULL DEFAULT 'pending'
);

-- Mensajes motivacionales configurables desde la administración.
CREATE TABLE public.content_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category TEXT NOT NULL,
    message_body TEXT NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- PASO 6: Triggers de Actualización e Índices de Rendimiento
-- ------------------------------------------------------------------------------
-- Función genérica para sellar la hora de actualización.
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Asignación de los disparadores a tablas mutables.
CREATE TRIGGER set_updated_at_profiles
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_settings
    BEFORE UPDATE ON public.patient_settings
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Índices B-Tree para consultas y filtros rápidos desde la App.
CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_patient_settings_patient ON public.patient_settings(patient_id);
CREATE INDEX idx_routines_category ON public.routines(category);
CREATE INDEX idx_routine_assets_routine ON public.routine_assets(routine_id);
CREATE INDEX idx_activity_sessions_patient ON public.activity_sessions(patient_id);
CREATE INDEX idx_self_assessments_patient ON public.self_assessments(patient_id);
CREATE INDEX idx_thought_entries_patient ON public.thought_entries(patient_id);
CREATE INDEX idx_assignments_composite ON public.assignments(professional_id, patient_id);
CREATE INDEX idx_sleep_logs_patient_date ON public.sleep_logs(patient_id, log_date DESC);

-- ------------------------------------------------------------------------------
-- PASO 7: Seguridad a Nivel de Fila (RLS - Supabase Auth Policies)
-- ------------------------------------------------------------------------------

-- Habilitar RLS es estricto en Supabase para evitar fugas de datos hacia clientes anónimos.
ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breathing_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.patient_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.self_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sleep_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.thought_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;

-- 7.1 Políticas de Acceso Público de Lectura (Catálogo general)
CREATE POLICY "Acceso lectura catálogo rutinas" ON public.routines FOR SELECT TO authenticated USING (is_active = TRUE);
CREATE POLICY "Acceso lectura patrones respiración" ON public.breathing_patterns FOR SELECT TO authenticated USING (true);
CREATE POLICY "Acceso lectura mensajes" ON public.content_messages FOR SELECT TO authenticated USING (is_active = TRUE);

-- 7.2 Políticas Transaccionales de Pacientes (Aislamiento de Información)
-- Verifica mediante auth.uid() de Postgres que un usuario sólo obtenga SUS registros.
CREATE POLICY "Visualiza sus propias sesiones" ON public.activity_sessions FOR SELECT TO authenticated USING (auth.uid() = patient_id);
CREATE POLICY "Visualiza sus propias autoevaluaciones" ON public.self_assessments FOR SELECT TO authenticated USING (auth.uid() = patient_id);
CREATE POLICY "Visualiza su diario de sueño" ON public.sleep_logs FOR SELECT TO authenticated USING (auth.uid() = patient_id);
CREATE POLICY "Modifica sus configuraciones" ON public.patient_settings FOR ALL TO authenticated USING (auth.uid() = patient_id);

-- Restringe las inserciones para que nadie suplante el ID de otra persona.
CREATE POLICY "Inserta sus propias sesiones" ON public.activity_sessions FOR INSERT TO authenticated WITH CHECK (auth.uid() = patient_id);
CREATE POLICY "Inserta su autoevaluación" ON public.self_assessments FOR INSERT TO authenticated WITH CHECK (auth.uid() = patient_id);
CREATE POLICY "Inserta registro de sueño" ON public.sleep_logs FOR INSERT TO authenticated WITH CHECK (auth.uid() = patient_id);

-- 7.3 Privacidad Extrema para el Diario Intimo
-- Ni siquiera el profesional de Bienestar Universitario tiene permiso de leer esto.
CREATE POLICY "Privacidad inquebrantable de pensamientos" ON public.thought_entries FOR ALL TO authenticated USING (auth.uid() = patient_id);

-- 7.4 Políticas Multitenantes (Profesionales monitorizando a los pacientes asignados)
-- Utilizamos SECURITY DEFINER para que la evaluación sea de muy bajo impacto y no escanee todo.
CREATE OR REPLACE FUNCTION public.is_assigned_professional(target_patient_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.assignments 
    WHERE professional_id = auth.uid() 
      AND patient_id = target_patient_id
      AND status = 'pending'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Permite a un paciente y a su profesional ver las asignaciones mutuas.
CREATE POLICY "Acceso a asignaciones conjuntas" ON public.assignments FOR SELECT 
TO authenticated USING (professional_id = auth.uid() OR patient_id = auth.uid());

-- Permite al profesional autorizado por el sistema institucional leer el cumplimiento de las rutinas de SU estudiante sin violar RLS.[3]
CREATE POLICY "Auditoría de cumplimiento a pacientes" ON public.activity_sessions FOR SELECT 
TO authenticated USING (auth.uid() = patient_id OR public.is_assigned_professional(patient_id));));
