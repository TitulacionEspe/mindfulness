-- =============================================================================
-- PGS-9: Biblioteca de rutinas de relajacion y contenido mindfulness
-- =============================================================================
-- Objetivo:
-- - Poblar el catalogo inicial de rutinas propias.
-- - Mantener lectura autenticada del catalogo y patrones de respiracion.
-- - Evitar dependencia de APIs externas para contenido principal.

BEGIN;

ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breathing_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Acceso lectura catalogo rutinas" ON public.routines;
CREATE POLICY "Acceso lectura catalogo rutinas"
ON public.routines
FOR SELECT
TO authenticated
USING (is_active = TRUE);

DROP POLICY IF EXISTS "Acceso lectura patrones respiracion" ON public.breathing_patterns;
CREATE POLICY "Acceso lectura patrones respiracion"
ON public.breathing_patterns
FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Acceso lectura assets rutinas" ON public.routine_assets;
CREATE POLICY "Acceso lectura assets rutinas"
ON public.routine_assets
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.routines r
    WHERE r.id = routine_assets.routine_id
      AND r.is_active = TRUE
  )
);

DROP POLICY IF EXISTS "Inserta sus propias sesiones" ON public.activity_sessions;
CREATE POLICY "Inserta sus propias sesiones"
ON public.activity_sessions
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = patient_id);

DROP POLICY IF EXISTS "Visualiza sus propias sesiones" ON public.activity_sessions;
CREATE POLICY "Visualiza sus propias sesiones"
ON public.activity_sessions
FOR SELECT
TO authenticated
USING (auth.uid() = patient_id);

INSERT INTO public.routines (
  id,
  title,
  description,
  category,
  duration_seconds,
  is_active
) VALUES
(
  '11111111-1111-4111-8111-111111111111',
  'Respiracion 4-6',
  'Ejercicio breve para bajar el ritmo antes de dormir: inhala cuatro segundos y exhala seis segundos, sin retener el aire.',
  'breathing',
  180,
  TRUE
),
(
  '22222222-2222-4222-8222-222222222222',
  'Respiracion 4-7-8',
  'Practica de respiracion con pausa suave. Si la retencion incomoda, reduce el tiempo o vuelve a respiracion natural.',
  'breathing',
  240,
  TRUE
),
(
  '33333333-3333-4333-8333-333333333333',
  'Relajacion muscular breve',
  'Recorrido corporal sencillo para tensar y soltar grupos musculares, reduciendo activacion fisica antes del descanso.',
  'relaxation',
  360,
  TRUE
),
(
  '44444444-4444-4444-8444-444444444444',
  'Escaneo corporal nocturno',
  'Atencion gradual desde la cabeza hasta los pies para reconocer sensaciones sin juzgarlas y preparar el descanso.',
  'sleep_induction',
  300,
  TRUE
),
(
  '55555555-5555-4555-8555-555555555555',
  'Visualizacion de descanso',
  'Guia corta para imaginar un lugar seguro y tranquilo, con respiracion estable y cierre progresivo del dia.',
  'sleep_induction',
  300,
  TRUE
),
(
  '66666666-6666-4666-8666-666666666666',
  'Silencio ambiental',
  'Sesion sin guia verbal para permanecer en calma, observar la respiracion y dejar que el cuerpo reduzca el ritmo.',
  'soundscape',
  480,
  TRUE
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  duration_seconds = EXCLUDED.duration_seconds,
  is_active = EXCLUDED.is_active;

DELETE FROM public.breathing_patterns
WHERE routine_id IN (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222'
);

INSERT INTO public.breathing_patterns (
  routine_id,
  inhale_sec,
  hold_in_sec,
  exhale_sec,
  hold_out_sec,
  cycles_recommended
) VALUES
(
  '11111111-1111-4111-8111-111111111111',
  4,
  0,
  6,
  0,
  10
),
(
  '22222222-2222-4222-8222-222222222222',
  4,
  7,
  8,
  0,
  8
);

CREATE INDEX IF NOT EXISTS idx_breathing_patterns_routine
ON public.breathing_patterns(routine_id);

CREATE INDEX IF NOT EXISTS idx_activity_sessions_patient_started
ON public.activity_sessions(patient_id, started_at DESC);

COMMIT;
