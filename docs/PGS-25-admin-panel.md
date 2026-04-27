# PGS-25 - Panel de administracion

## Alcance implementado

El panel administrativo queda separado del modulo Paciente y del modulo
Profesional. El acceso se valida por rol en Flutter y por RLS/RPC en Supabase.

## Puntos de integracion preparados para modulo Profesional

- `system_settings.professional_module_enabled`: bandera para habilitar el
  modulo Profesional cuando el equipo lo integre.
- `system_settings.patient_professional_assignment_enabled`: bandera para
  activar la asignacion Paciente-Profesional desde administracion.
- `system_settings.content_validation_enabled`: bandera para exigir validacion
  profesional antes de publicar contenidos.
- `profiles.role = 'professional'`: alta y habilitacion de cuentas
  profesionales desde la vista de roles.
- `admin_overview_metrics()`: funcion agregada para metricas operativas no
  sensibles que puede alimentar dashboards futuros sin exponer pensamientos ni
  autopercepciones individuales.

## Reglas de seguridad

- La migracion `007_PGS_25_admin_panel.sql` impide dejar el sistema sin al
  menos un administrador activo.
- Las acciones sobre usuarios y contenidos usan RLS con `public.is_admin()`.
- Los datos privados de pacientes siguen aislados. El panel consulta metricas
  agregadas mediante RPC y no lista `thought_entries`, `self_assessments` ni
  `sleep_logs` individuales.

## Validacion UX

- H1: todas las vistas administrativas tienen estados de carga, exito y error.
- H5: cambios de rol, estado de cuenta, publicacion/desactivacion de contenidos
  y recursos multimedia requieren confirmacion.
- H8: la interfaz usa Nocturne Minimalist con superficies tonales, sin imagenes
  de fondo ni decoracion visual innecesaria.
