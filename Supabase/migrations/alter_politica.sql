-- 1. Permitir que los profesionales inserten nuevas asignaciones
CREATE POLICY "Los profesionales pueden asignar tareas" 
ON public.assignments 
FOR INSERT 
TO authenticated 
WITH CHECK (
  auth.uid() = professional_id 
);

-- 2. Permitir que tanto el paciente como el profesional vean las asignaciones
CREATE POLICY "Ver asignaciones propias" 
ON public.assignments 
FOR SELECT 
TO authenticated 
USING (
  auth.uid() = professional_id OR auth.uid() = patient_id
);

-- 3. Permitir que el paciente actualice el estado (completar tarea)
CREATE POLICY "Pacientes pueden completar sus tareas" 
ON public.assignments 
FOR UPDATE 
TO authenticated 
USING (auth.uid() = patient_id)
WITH CHECK (auth.uid() = patient_id);