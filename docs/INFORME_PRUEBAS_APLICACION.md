# Informe de pruebas de la aplicacion

**Proyecto:** Sistema de mindfulness e higiene del sueno  
**Fecha de ejecucion:** 2026-07-07  
**Alcance:** pruebas automatizadas ejecutadas localmente sobre la base de codigo Flutter del repositorio.

## 1. Resumen ejecutivo

Se ejecuto la bateria de pruebas automatizadas del proyecto con exito.

- Comando principal ejecutado: `fvm flutter test --reporter expanded`
- Analisis estatico ejecutado: `fvm flutter analyze`
- Resultado de pruebas: **99 casos aprobados**
- Archivos de prueba analizados: **29**
- Fallos en pruebas: **0**
- Errores de analisis estatico: **0**

> Nota: al finalizar la ejecucion aparecio un mensaje del entorno de Flutter/Kernel (`Can't load Kernel binary: Invalid kernel binary format version.`), pero no afecto el resultado final de la suite: todas las pruebas pasaron y el analisis no reporto incidencias.

## 2. Tipos de prueba ejecutados

| Tipo de prueba | Archivos | Casos | Resultado |
| --- | ---: | ---: | --- |
| Unitarias | 18 | 75 | Aprobadas |
| Widget / UI | 11 | 24 | Aprobadas |
| Integracion | 0 | 0 | No aplican en esta bateria |
| **Total** | **29** | **99** | **Aprobadas** |

## 3. Resumen por agrupacion funcional

| Agrupacion | Archivos | Casos | Observacion |
| --- | ---: | ---: | --- |
| `core` | 3 | 12 | Utilidades y verificacion de tema / texto |
| `features` | 4 | 16 | Autenticacion y panel administrativo |
| `services` | 1 | 3 | Cifrado de pensamientos |
| `viewmodels` | 10 | 44 | Logica de estado y validaciones de pantalla |
| `widgets` | 10 | 23 | Pruebas de interfaz y renderizado |
| `widget_test.dart` | 1 | 1 | Smoke test basico de la app |
| **Total** | **29** | **99** |  |

## 4. Inventario detallado de pruebas

| Archivo | Agrupacion | Tipo | Casos |
| --- | --- | --- | ---: |
| `test/core/theme/app_visual_mode_test.dart` | `core` | Unit | 3 |
| `test/core/utils/ai_parser_test.dart` | `core` | Unit | 5 |
| `test/core/utils/text_limit_utils_test.dart` | `core` | Unit | 4 |
| `test/features/admin/admin_panel_viewmodel_test.dart` | `features` | Unit | 4 |
| `test/features/auth/auth_validators_test.dart` | `features` | Unit | 6 |
| `test/features/auth/error_mapping_test.dart` | `features` | Unit | 2 |
| `test/features/auth/register_use_case_test.dart` | `features` | Unit | 4 |
| `test/services/thought_encryption_service_test.dart` | `services` | Unit | 3 |
| `test/viewmodels/accessibility_viewmodel_test.dart` | `viewmodels` | Unit | 7 |
| `test/viewmodels/appointments_viewmodel_test.dart` | `viewmodels` | Unit | 2 |
| `test/viewmodels/auth_password_reset_test.dart` | `viewmodels` | Unit | 3 |
| `test/viewmodels/auth_viewmodel_test.dart` | `viewmodels` | Unit | 2 |
| `test/viewmodels/patient_history_viewmodel_test.dart` | `viewmodels` | Unit | 5 |
| `test/viewmodels/routines_viewmodel_test.dart` | `viewmodels` | Unit | 3 |
| `test/viewmodels/self_assessments_viewmodel_test.dart` | `viewmodels` | Unit | 3 |
| `test/viewmodels/sleep_logs_viewmodel_test.dart` | `viewmodels` | Unit | 4 |
| `test/viewmodels/theme_viewmodel_test.dart` | `viewmodels` | Unit | 7 |
| `test/viewmodels/thought_entries_viewmodel_test.dart` | `viewmodels` | Unit | 8 |
| `test/widget_test.dart` | `widget_test.dart` | Widget | 1 |
| `test/widgets/admin_home_screen_test.dart` | `widgets` | Widget | 1 |
| `test/widgets/consent_screen_test.dart` | `widgets` | Widget | 2 |
| `test/widgets/patient_feature_guide_view_test.dart` | `widgets` | Widget | 2 |
| `test/widgets/patient_history_view_test.dart` | `widgets` | Widget | 4 |
| `test/widgets/patient_home_view_test.dart` | `widgets` | Widget | 2 |
| `test/widgets/patient_profile_view_test.dart` | `widgets` | Widget | 1 |
| `test/widgets/register_screen_test.dart` | `widgets` | Widget | 4 |
| `test/widgets/self_assessment_flow_test.dart` | `widgets` | Widget | 1 |
| `test/widgets/theme_selector_test.dart` | `widgets` | Widget | 2 |
| `test/widgets/thought_entries_view_test.dart` | `widgets` | Widget | 4 |

## 5. Cobertura funcional observada

La bateria cubre estas areas del sistema:

- autenticacion y validaciones de registro;
- recuperacion de contrasena;
- preferencias de tema;
- preferencias de accesibilidad;
- historial de paciente;
- flujo de sesiones y autoevaluaciones;
- registros de sueno;
- entrada y gestion de pensamientos;
- cifrado de contenido sensible;
- panel administrativo;
- pruebas de widgets principales de paciente y autenticacion.

## 6. Hallazgos relevantes

- La suite automatizada esta estable y sin fallos al momento de esta ejecucion.
- Se valida tanto logica de negocio como renderizado UI.
- No se detectaron errores por `flutter analyze`.
- No hay pruebas de integracion registradas en la carpeta `test/` en esta ejecucion.

## 7. Interpretacion para la tesis

Este resultado sirve como respaldo tecnico para demostrar que la aplicacion:

- mantiene validaciones funcionales en capas de negocio;
- conserva estabilidad visual en componentes clave;
- soporta configuraciones de accesibilidad y tema;
- cuenta con verificacion automatizada antes de entrega.

## 8. Evidencia resumida

| Indicador | Valor |
| --- | ---: |
| Archivos de prueba | 29 |
| Casos aprobados | 99 |
| Casos fallidos | 0 |
| Advertencias de analisis | 0 |
| Pruebas unitarias | 75 |
| Pruebas de widget | 24 |
| Pruebas de integracion | 0 |

## 9. Comandos ejecutados

```bash
fvm flutter test --reporter expanded
fvm flutter analyze
```

Si necesitas, este informe se puede ampliar despues con una seccion de criterios de aceptacion, cobertura por modulo o evidencia de capturas de ejecucion.
