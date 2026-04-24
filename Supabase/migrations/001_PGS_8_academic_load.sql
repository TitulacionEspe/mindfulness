-- Migración: PGS-8 Soporte para carga académica
-- Fecha: 2026-04-23
-- Descripción: Añade columna para bitmask de días de mayor carga académica.

ALTER TABLE public.patient_settings 
ADD COLUMN IF NOT EXISTS academic_load_days SMALLINT DEFAULT 0;

COMMENT ON COLUMN public.patient_settings.academic_load_days IS 'Bitmask de los días de mayor carga académica (1=Lun, 2=Mar, 4=Mie, 8=Jue, 16=Vie, 32=Sab, 64=Dom)';
