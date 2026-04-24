-- Migración: PGS-10 Gestión de recordatorios personalizados
-- Fecha: 2026-04-23
-- Descripción: Añade tipos de recordatorio y asegura RLS.

-- 1. Crear el tipo enumerado para recordatorios si no existe
DO $$ BEGIN
    CREATE TYPE reminder_type AS ENUM ('sleep_induction', 'routine_start', 'brief_relaxation');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Añadir la columna a la tabla existente
ALTER TABLE public.reminders 
ADD COLUMN IF NOT EXISTS type reminder_type NOT NULL DEFAULT 'routine_start';

-- 3. Habilitar RLS para recordatorios
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;

-- 4. Crear política de acceso (idempotente)
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'reminders' 
        AND policyname = 'Pacientes gestionan sus recordatorios'
    ) THEN
        CREATE POLICY "Pacientes gestionan sus recordatorios" 
        ON public.reminders FOR ALL 
        TO authenticated 
        USING (auth.uid() = patient_id);
    END IF;
END $$;
