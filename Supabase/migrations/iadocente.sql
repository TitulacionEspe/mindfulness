-- Tabla para el historial del Asistente Creativo IA (Solo Profesionales)
CREATE TABLE public.professional_ia_chat (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  professional_id uuid NOT NULL,
  role text NOT NULL CHECK (role = ANY (ARRAY['user'::text, 'assistant'::text])),
  content text NOT NULL,
  category text DEFAULT 'general', -- Para filtrar por 'guia', 'visualizacion', 'notas'
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  
  CONSTRAINT professional_ia_chat_pkey PRIMARY KEY (id),
  CONSTRAINT professional_ia_chat_prof_id_fkey FOREIGN KEY (professional_id) REFERENCES public.profiles(id) ON DELETE CASCADE
);

-- Habilitar RLS (Seguridad a nivel de fila)
ALTER TABLE public.professional_ia_chat ENABLE ROW LEVEL SECURITY;

-- Política: Los profesionales solo pueden ver SU propio historial
CREATE POLICY "Professionals can manage their own IA chat history" 
ON public.professional_ia_chat
FOR ALL 
USING (auth.uid() = professional_id);
