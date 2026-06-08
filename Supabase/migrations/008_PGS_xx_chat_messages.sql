-- Migracion: PGS-XX Chatbot de acompanamiento emocional
-- Fecha: 2026-06-01
-- Descripcion: Historial privado del chat empatico. Aislamiento total por usuario
--              (ni profesionales ni admins pueden leerlo), igual que thought_entries.

CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  risk_level TEXT CHECK (risk_level IN ('none', 'low', 'high')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_patient_created_desc
ON public.chat_messages(patient_id, created_at DESC);

ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "chat_messages_select_own" ON public.chat_messages;
DROP POLICY IF EXISTS "chat_messages_insert_own" ON public.chat_messages;
DROP POLICY IF EXISTS "chat_messages_delete_own" ON public.chat_messages;

CREATE POLICY "chat_messages_select_own"
ON public.chat_messages
FOR SELECT
TO authenticated
USING (auth.uid() = patient_id);

CREATE POLICY "chat_messages_insert_own"
ON public.chat_messages
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = patient_id);

CREATE POLICY "chat_messages_delete_own"
ON public.chat_messages
FOR DELETE
TO authenticated
USING (auth.uid() = patient_id);

-- Los mensajes son inmutables: no se permite UPDATE (no se crea politica de UPDATE).

GRANT SELECT, INSERT, DELETE ON public.chat_messages TO authenticated;
