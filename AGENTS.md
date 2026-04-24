# ðŸ§  AGENTS.md â€“ GuÃ­a TÃ©cnica del Proyecto

## ðŸ“Œ PropÃ³sito

Este documento define las reglas tÃ©cnicas, arquitectura y lineamientos de desarrollo del sistema de mindfulness e higiene del sueÃ±o.

Debe ser seguido por cualquier desarrollador que participe en el proyecto.

---

# Contexto del Proyecto
Eres un Agente de IA experto en Desarrollo Frontend MÃ³vil y UX/UI. EstÃ¡s asistiendo en la creaciÃ³n de una aplicaciÃ³n de mindfulness e higiene del sueÃ±o para la comunidad universitaria. 
El objetivo principal del sistema es reducir la carga cognitiva, evitar la fatiga visual nocturna y permitir interacciones rÃ¡pidas en condiciones de estrÃ©s, cansancio o iluminaciÃ³n nula. 

# ðŸ› ï¸ Reglas Mandatorias de Desarrollo (Protocolo de Calidad)
Antes de realizar cualquier cambio en el cÃ³digo o diseÃ±o, TODO colaborador (humano o IA) DEBE seguir este protocolo:

1. **Consulta de Skills**: Es obligatorio leer y activar las skills de `@flutter-*` y `@ui-ux-pro-max` para asegurar que las soluciones sigan las mejores prÃ¡cticas de arquitectura (MVVM) y diseÃ±o adaptativo.
2. **EvaluaciÃ³n HeurÃ­stica**: Todo cambio en la interfaz debe ser validado contra las **10 HeurÃ­sticas de Nielsen**. Especial atenciÃ³n a:
   - **H1: Visibilidad del estado**: Siempre mostrar carga/feedback.
   - **H5: PrevenciÃ³n de errores**: DiÃ¡logos de confirmaciÃ³n en acciones crÃ­ticas.
   - **H8: EstÃ©tica Minimalista**: Respetar el sistema "Nocturne" (sin ruidos visuales).
3. **Consistencia de Color**: PROHIBIDO el uso de `Colors.white`, `Colors.black` o hexadecimales sueltos. Se debe usar estrictamente `AppColors`.
4. **VerificaciÃ³n de CI Local**: Antes de cada commit, se debe ejecutar `fvm flutter analyze` y `fvm flutter test` para asegurar un PR limpio.

# 1. Sistema de DiseÃ±o (Design System: Nocturne Minimalist)
TODOS los componentes visuales que generes deben utilizar ESTRICTAMENTE los siguientes valores. 

## Paleta de Colores (Fuente de verdad en AppColors)
- Fondo principal (background): #141315
- Superficie base (surface): #201F21
- Superficies tonales:
  - surfaceLowest: #0F0E10
  - surfaceLow: #1C1B1D
  - surfaceHigh: #2B292C
  - surfaceHighest: #363437
- Texto principal (textPrimary): #E6E1E4
- Texto secundario (textSecondary): #CAC4CD
- Borde/contorno (outlineVariant / navBorder): #49454D
- Acento pendiente (lavender): #D1C4E9
- Acento completado (mint): #B2DFDB
- Acento terciario (tertiary): #F3E6B0
- Error suave (error): #FFB4AB
- PROHIBICION ESTRICTA: Nunca utilices tonos de azul oscuro (navy/midnight blue), colores neon o hexadecimales sueltos fuera de AppColors.

### Estados UI (obligatorio)
- pending: fondo warningBg (lavender al 15%) + texto lavender
- completed: fondo successBg (mint al 15%) + texto mint
- expired/alerta no critica: fondo tertiaryBg + texto tertiaryOnContainer
- Errores bloqueantes: error + texto textPrimary con contraste valido
## TipografÃ­a (Accesibilidad WCAG Nivel A)
- Familia: Inter (o Roboto por defecto del sistema).
- TÃ­tulos: 24px - 32px, Bold (700).
- Cuerpo: 16px, Regular (400). Line-height generoso para lectura nocturna.
- SubtÃ­tulos: 14px, Medium (500).
- Botones: 16px, SemiBold (600).

## Componentes y GeometrÃ­a
- Tarjetas (Cards): Sin bordes, radio de esquina (border-radius) de 16px a 24px. Padding interno mÃ­nimo de 20px.
- Botones Primarios: Fondo `#B2DFDB`, Texto `#1E1A24`.
- Botones Secundarios (Ghost): Fondo transparente o `#2A2532`, Borde `#D1C4E9`, Texto `#D1C4E9`.
- Indicadores de Estado: Chips con fondo al 15% de opacidad del color de acento y texto sÃ³lido.
- Sombras: Ninguna o extremadamente sutil. La jerarquÃ­a se logra por "Tonal Layering" (contraste de colores de superficie), no por elevaciÃ³n Z tradicional.

# 2. Reglas de Desarrollo UX/UI (Do's and Don'ts)

## QUÃ‰ HACER (DO's)
- **TamaÃ±os TÃ¡ctiles:** Todo elemento interactivo (botones, Ã­conos, tarjetas clickeables) DEBE tener un tamaÃ±o mÃ­nimo de 44x44px.
- **Flujos Cortos:** DiseÃ±a interfaces donde la acciÃ³n principal se logre en menos de 3 pasos (ej. iniciar una sesiÃ³n de meditaciÃ³n).
- **Feedback Inmediato:** Aplica la heurÃ­stica de "Visibilidad del estado del sistema". Muestra claramente estados de "Cargando", "Pendiente" y "Completado".
- **Manejo Offline:** Estructura el frontend asumiendo que la conectividad puede ser intermitente. Si falla la red, el diseÃ±o debe mostrar una ruta para "usar contenido offline" de forma elegante.
- **Consistencia:** MantÃ©n la barra de navegaciÃ³n inferior (Bottom Navigation Bar) estÃ¡tica con las secciones: Home, Tareas, Citas, Logros, Perfil.

## QUÃ‰ NO HACER (DON'Ts)
- **NUNCA** uses imÃ¡genes fotogrÃ¡ficas, gradientes complejos, ilustraciones detalladas ni texturas como fondo. El diseÃ±o debe ser 100% minimalista y basado en colores sÃ³lidos.
- **NUNCA** generes modales invasivos o pop-ups que bloqueen el flujo en medio de una rutina de sueÃ±o.
- **NO** utilices textos pequeÃ±os (<14px) o fuentes con bajo contraste que violen los estÃ¡ndares WCAG Nivel A.
- **NO** satures la pantalla de informaciÃ³n. Si hay muchos datos (como en el mÃ³dulo administrativo o de psicÃ³logo), utiliza un scroll limpio y agrupa en tarjetas (cards) colapsables o en listas espaciadas.

# 3. Directrices de CÃ³digo Frontend
- **Modularidad:** Genera el cÃ³digo separando la UI de la lÃ³gica de negocio. Utiliza componentes reutilizables (ej. `CustomCard`, `StatusChip`, `PrimaryButton`).
- **Clean Code:** MantÃ©n el cÃ³digo libre de estilos "harcodeados" (inline styles). Si el framework lo permite, define la paleta de colores y la tipografÃ­a en un archivo de tema global (ThemeData o similar) y llama a esas variables.
- **Estado de Pantalla:** Al crear una nueva vista, estructura la pantalla principal en tres secciones claras: Header (Saludo/TÃ­tulo), Body (Contenido/Tarjetas) y Footer (NavegaciÃ³n si aplica).

---

## ðŸ—ï¸ Arquitectura General

El sistema utiliza una arquitectura basada en:

- Frontend desacoplado (Flutter)
- Backend como servicio (Supabase)
- Arquitectura interna: MVVM

---

## ðŸ“± Arquitectura Flutter (MVVM)

Se utiliza el patrÃ³n **Model-View-ViewModel**, con separaciÃ³n clara de responsabilidades:

### ðŸ”¹ Model

- Representa la estructura de datos
- Mapea datos de Supabase

### ðŸ”¹ View

- UI (pantallas Flutter)
- No contiene lÃ³gica de negocio

### ðŸ”¹ ViewModel

- Maneja estado
- Orquesta lÃ³gica
- Conecta View con Services

---

## ðŸ“‚ Estructura de Carpetas

lib/
â”‚
â”œâ”€â”€ core/ # ConfiguraciÃ³n global
â”‚ â”œâ”€â”€ constants/
â”‚ â”œâ”€â”€ utils/
â”‚ â”œâ”€â”€ theme/
â”‚
â”œâ”€â”€ services/ # ComunicaciÃ³n externa (Supabase)
â”‚ â”œâ”€â”€ auth_service.dart
â”‚ â”œâ”€â”€ database_service.dart
â”‚
â”œâ”€â”€ features/ # MÃ³dulos del sistema
â”‚
â”‚ â”œâ”€â”€ auth/
â”‚ â”‚ â”œâ”€â”€ data/
â”‚ â”‚ â”œâ”€â”€ domain/
â”‚ â”‚ â”œâ”€â”€ presentation/
â”‚
â”‚ â”œâ”€â”€ profile/
â”‚ â”œâ”€â”€ sleep/
â”‚ â”œâ”€â”€ routines/
â”‚ â”œâ”€â”€ tracking/
â”‚
â”œâ”€â”€ models/ # Entidades del sistema
â”‚
â”œâ”€â”€ viewmodels/ # LÃ³gica de presentaciÃ³n
â”‚
â”œâ”€â”€ main.dart

---

## ðŸ”Œ IntegraciÃ³n con Supabase

### Auth

- Registro: signUp
- Login: signInWithPassword

### Database

- PostgreSQL
- Acceso mediante API Supabase

### Seguridad

- RLS (Row Level Security)
- Usuario solo accede a su informaciÃ³n

---

## ðŸ” Reglas de Seguridad

- No almacenar contraseÃ±as localmente
- Validar datos en frontend y backend
- Aplicar RLS en todas las tablas
- No exponer errores internos

---

## ðŸ“Š Modelado de Datos

Tablas principales:

- profiles
- sleep_settings
- sessions
- thoughts
- emotions

---

## ðŸ”„ Flujo de Datos

1. View solicita acciÃ³n
2. ViewModel procesa lÃ³gica
3. Service interactÃºa con Supabase
4. Resultado vuelve al ViewModel
5. View se actualiza

---

## ðŸ”’ Seguridad y Modelo de Datos (PGS-7 Hardening)

El sistema aplica un aislamiento estricto de los datos. Todo el esquema de base de datos (`Supabase/shema.sql`) y seguridad (`Supabase/policies.sql`) debe ser idempotente y reproducible.

### ðŸ›¡ï¸ PolÃ­ticas RLS Mandatorias

| Entidad | Regla de Acceso | JustificaciÃ³n |
| :--- | :--- | :--- |
| **`profiles`** | `auth.uid() = id` | Privacidad de identidad. |
| **`thought_entries`** | `auth.uid() = patient_id` | **Aislamiento Total.** Solo el dueÃ±o tiene acceso (ni siquiera el profesional). |
| **`sleep_logs`** | `auth.uid() = patient_id` | Datos de salud privados. |
| **`risk_flags`** | `auth.uid() = patient_id` OR `is_assigned_professional()` | SupervisiÃ³n Ã©tica del paciente por un profesional. |
| **`consents`** | `auth.uid() = patient_id` | Registro legal inmutable. |

### ðŸ› ï¸ Triggers de Integridad

- **AuditorÃ­a:** Todas las tablas transaccionales tienen un trigger `handle_updated_at` que actualiza automÃ¡ticamente la columna `updated_at`.
- **Identidad:** El trigger `on_auth_user_created` captura metadatos del registro (como `full_name`) y crea el perfil en la base de datos de forma atÃ³mica.

### ðŸ“Š OptimizaciÃ³n (Ãndices)

- Las claves forÃ¡neas (`patient_id`, `routine_id`) deben tener Ã­ndices B-Tree para optimizar las consultas del Dashboard.
- Las tablas con filtros por fecha (`sleep_logs`, `activity_sessions`) deben usar Ã­ndices descendentes.

---

## ðŸ§ª Buenas PrÃ¡cticas de CÃ³digo limpia (Clean Code)

- SeparaciÃ³n de responsabilidades: No mezclar lÃ³gica de Supabase en los Widgets.
- Uso de estados: Siempre manejar estados de `loading`, `error` y `success` en los ViewModels.
- **ValidaciÃ³n de CI:** No realizar push si el linter (`flutter analyze`) o el formateador (`dart format`) fallan.

---

## ðŸ” Flujo de Trabajo en Jira

1. Crear historia en Jira.
2. Descomponer en subtareas.
3. Implementar siguiendo el patrÃ³n MVVM.
4. **Validar CI localmente (Format, Analyze, Test).**
5. Crear PR y esperar a que el CI de GitHub confirme el Ã©xito.
6. Merge a develop/main.

---

## ðŸ§ª Testing (Futuro)

- Unit testing
- Integration testing
- EvaluaciÃ³n UX:
  - SUS
  - UEQ
  - AttrakDiff

---

## ðŸ“Œ Nota Final

Este proyecto estÃ¡ diseÃ±ado bajo principios de:

- DiseÃ±o Centrado en el Usuario (DCU)
- Arquitectura limpia
- Escalabilidad futura

Cualquier cambio en arquitectura debe documentarse aquÃ­.


