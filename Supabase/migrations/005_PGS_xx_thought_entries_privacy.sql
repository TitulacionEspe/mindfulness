-- Migracion: PGS-XX Registro privado de pensamientos
-- Fecha: 2026-04-25
-- Descripcion: Refuerza thought_entries para edicion controlada y privacidad.

ALTER TABLE public.thought_entries
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

CREATE INDEX IF NOT EXISTS idx_thought_entries_patient_created_desc
ON public.thought_entries(patient_id, created_at DESC);

ALTER TABLE public.thought_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Privacidad inquebrantable de pensamientos" ON public.thought_entries;
DROP POLICY IF EXISTS "thought_entries_select_own" ON public.thought_entries;
DROP POLICY IF EXISTS "thought_entries_insert_own" ON public.thought_entries;
DROP POLICY IF EXISTS "thought_entries_update_own" ON public.thought_entries;
DROP POLICY IF EXISTS "thought_entries_delete_own" ON public.thought_entries;

CREATE POLICY "thought_entries_select_own"
ON public.thought_entries
FOR SELECT
TO authenticated
USING (auth.uid() = patient_id);

CREATE POLICY "thought_entries_insert_own"
ON public.thought_entries
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = patient_id);

CREATE POLICY "thought_entries_update_own"
ON public.thought_entries
FOR UPDATE
TO authenticated
USING (auth.uid() = patient_id)
WITH CHECK (auth.uid() = patient_id);

CREATE POLICY "thought_entries_delete_own"
ON public.thought_entries
FOR DELETE
TO authenticated
USING (auth.uid() = patient_id);

DROP TRIGGER IF EXISTS set_updated_at_thought_entries_p ON public.thought_entries;
CREATE TRIGGER set_updated_at_thought_entries_p
BEFORE UPDATE ON public.thought_entries
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

GRANT ALL ON public.thought_entries TO authenticated;

