# 🧠 AGENTS.md – Guía Técnica del Proyecto

## 📌 Propósito

Este documento define las reglas técnicas, arquitectura y lineamientos de desarrollo del sistema de mindfulness e higiene del sueño.

Debe ser seguido por cualquier desarrollador que participe en el proyecto.

---

# Contexto del Proyecto
Eres un Agente de IA experto en Desarrollo Frontend Móvil y UX/UI. Estás asistiendo en la creación de una aplicación de mindfulness e higiene del sueño para la comunidad universitaria. 
El objetivo principal del sistema es reducir la carga cognitiva, evitar la fatiga visual nocturna y permitir interacciones rápidas en condiciones de estrés, cansancio o iluminación nula. 

# 🛠️ Reglas Mandatorias de Desarrollo (Protocolo de Calidad)
Antes de realizar cualquier cambio en el código o diseño, TODO colaborador (humano o IA) DEBE seguir este protocolo:

1. **Consulta de Skills**: Es obligatorio leer y activar las skills de `@flutter-*` y `@ui-ux-pro-max` para asegurar que las soluciones sigan las mejores prácticas de arquitectura (MVVM) y diseño adaptativo.
2. **Evaluación Heurística**: Todo cambio en la interfaz debe ser validado contra las **10 Heurísticas de Nielsen**. Especial atención a:
   - **H1: Visibilidad del estado**: Siempre mostrar carga/feedback.
   - **H5: Prevención de errores**: Diálogos de confirmación en acciones críticas.
   - **H8: Estética Minimalista**: Respetar el sistema "Nocturne" (sin ruidos visuales).
3. **Consistencia de Color**: PROHIBIDO el uso de `Colors.white`, `Colors.black` o hexadecimales sueltos. Se debe usar estrictamente `AppColors`.
4. **Verificación de CI Local**: Antes de cada commit, se debe ejecutar `fvm flutter analyze` y `fvm flutter test` para asegurar un PR limpio.

# 1. Sistema de Diseño (Design System: Nocturne Minimalist)
TODOS los componentes visuales que generes deben utilizar ESTRICTAMENTE los siguientes valores. 

## Paleta de Colores
- Fondo Principal (Floor): `#1E1A24` (Gris grafito/púrpura muy oscuro)
- Fondo de Tarjetas (Surface): `#2A2532`
- Texto Principal (H1/H2/Body): `#E6E1EB` (Blanco suave)
- Texto Secundario/Metadata: `#9E95A3`
- Acento Neutro/Pendiente (Lavender): `#D1C4E9`
- Acento Éxito/Completado (Mint): `#B2DFDB`
- Borde superior de navegación: `#362F3D`
- **PROHIBICIÓN ESTRICTA:** Nunca utilices tonos de azul oscuro (ej. navy, midnight blue) ni colores vibrantes/neón.

## Tipografía (Accesibilidad WCAG Nivel A)
- Familia: Inter (o Roboto por defecto del sistema).
- Títulos: 24px - 32px, Bold (700).
- Cuerpo: 16px, Regular (400). Line-height generoso para lectura nocturna.
- Subtítulos: 14px, Medium (500).
- Botones: 16px, SemiBold (600).

## Componentes y Geometría
- Tarjetas (Cards): Sin bordes, radio de esquina (border-radius) de 16px a 24px. Padding interno mínimo de 20px.
- Botones Primarios: Fondo `#B2DFDB`, Texto `#1E1A24`.
- Botones Secundarios (Ghost): Fondo transparente o `#2A2532`, Borde `#D1C4E9`, Texto `#D1C4E9`.
- Indicadores de Estado: Chips con fondo al 15% de opacidad del color de acento y texto sólido.
- Sombras: Ninguna o extremadamente sutil. La jerarquía se logra por "Tonal Layering" (contraste de colores de superficie), no por elevación Z tradicional.

# 2. Reglas de Desarrollo UX/UI (Do's and Don'ts)

## QUÉ HACER (DO's)
- **Tamaños Táctiles:** Todo elemento interactivo (botones, íconos, tarjetas clickeables) DEBE tener un tamaño mínimo de 44x44px.
- **Flujos Cortos:** Diseña interfaces donde la acción principal se logre en menos de 3 pasos (ej. iniciar una sesión de meditación).
- **Feedback Inmediato:** Aplica la heurística de "Visibilidad del estado del sistema". Muestra claramente estados de "Cargando", "Pendiente" y "Completado".
- **Manejo Offline:** Estructura el frontend asumiendo que la conectividad puede ser intermitente. Si falla la red, el diseño debe mostrar una ruta para "usar contenido offline" de forma elegante.
- **Consistencia:** Mantén la barra de navegación inferior (Bottom Navigation Bar) estática con las secciones: Home, Tareas, Citas, Logros, Perfil.

## QUÉ NO HACER (DON'Ts)
- **NUNCA** uses imágenes fotográficas, gradientes complejos, ilustraciones detalladas ni texturas como fondo. El diseño debe ser 100% minimalista y basado en colores sólidos.
- **NUNCA** generes modales invasivos o pop-ups que bloqueen el flujo en medio de una rutina de sueño.
- **NO** utilices textos pequeños (<14px) o fuentes con bajo contraste que violen los estándares WCAG Nivel A.
- **NO** satures la pantalla de información. Si hay muchos datos (como en el módulo administrativo o de psicólogo), utiliza un scroll limpio y agrupa en tarjetas (cards) colapsables o en listas espaciadas.

# 3. Directrices de Código Frontend
- **Modularidad:** Genera el código separando la UI de la lógica de negocio. Utiliza componentes reutilizables (ej. `CustomCard`, `StatusChip`, `PrimaryButton`).
- **Clean Code:** Mantén el código libre de estilos "harcodeados" (inline styles). Si el framework lo permite, define la paleta de colores y la tipografía en un archivo de tema global (ThemeData o similar) y llama a esas variables.
- **Estado de Pantalla:** Al crear una nueva vista, estructura la pantalla principal en tres secciones claras: Header (Saludo/Título), Body (Contenido/Tarjetas) y Footer (Navegación si aplica).

---

## 🏗️ Arquitectura General

El sistema utiliza una arquitectura basada en:

- Frontend desacoplado (Flutter)
- Backend como servicio (Supabase)
- Arquitectura interna: MVVM

---

## 📱 Arquitectura Flutter (MVVM)

Se utiliza el patrón **Model-View-ViewModel**, con separación clara de responsabilidades:

### 🔹 Model

- Representa la estructura de datos
- Mapea datos de Supabase

### 🔹 View

- UI (pantallas Flutter)
- No contiene lógica de negocio

### 🔹 ViewModel

- Maneja estado
- Orquesta lógica
- Conecta View con Services

---

## 📂 Estructura de Carpetas

lib/
│
├── core/ # Configuración global
│ ├── constants/
│ ├── utils/
│ ├── theme/
│
├── services/ # Comunicación externa (Supabase)
│ ├── auth_service.dart
│ ├── database_service.dart
│
├── features/ # Módulos del sistema
│
│ ├── auth/
│ │ ├── data/
│ │ ├── domain/
│ │ ├── presentation/
│
│ ├── profile/
│ ├── sleep/
│ ├── routines/
│ ├── tracking/
│
├── models/ # Entidades del sistema
│
├── viewmodels/ # Lógica de presentación
│
├── main.dart

---

## 🔌 Integración con Supabase

### Auth

- Registro: signUp
- Login: signInWithPassword

### Database

- PostgreSQL
- Acceso mediante API Supabase

### Seguridad

- RLS (Row Level Security)
- Usuario solo accede a su información

---

## 🔐 Reglas de Seguridad

- No almacenar contraseñas localmente
- Validar datos en frontend y backend
- Aplicar RLS en todas las tablas
- No exponer errores internos

---

## 📊 Modelado de Datos

Tablas principales:

- profiles
- sleep_settings
- sessions
- thoughts
- emotions

---

## 🔄 Flujo de Datos

1. View solicita acción
2. ViewModel procesa lógica
3. Service interactúa con Supabase
4. Resultado vuelve al ViewModel
5. View se actualiza

---

## 🔒 Seguridad y Modelo de Datos (PGS-7 Hardening)

El sistema aplica un aislamiento estricto de los datos. Todo el esquema de base de datos (`Supabase/shema.sql`) y seguridad (`Supabase/policies.sql`) debe ser idempotente y reproducible.

### 🛡️ Políticas RLS Mandatorias

| Entidad | Regla de Acceso | Justificación |
| :--- | :--- | :--- |
| **`profiles`** | `auth.uid() = id` | Privacidad de identidad. |
| **`thought_entries`** | `auth.uid() = patient_id` | **Aislamiento Total.** Solo el dueño tiene acceso (ni siquiera el profesional). |
| **`sleep_logs`** | `auth.uid() = patient_id` | Datos de salud privados. |
| **`risk_flags`** | `auth.uid() = patient_id` OR `is_assigned_professional()` | Supervisión ética del paciente por un profesional. |
| **`consents`** | `auth.uid() = patient_id` | Registro legal inmutable. |

### 🛠️ Triggers de Integridad

- **Auditoría:** Todas las tablas transaccionales tienen un trigger `handle_updated_at` que actualiza automáticamente la columna `updated_at`.
- **Identidad:** El trigger `on_auth_user_created` captura metadatos del registro (como `full_name`) y crea el perfil en la base de datos de forma atómica.

### 📊 Optimización (Índices)

- Las claves foráneas (`patient_id`, `routine_id`) deben tener índices B-Tree para optimizar las consultas del Dashboard.
- Las tablas con filtros por fecha (`sleep_logs`, `activity_sessions`) deben usar índices descendentes.

---

## 🧪 Buenas Prácticas de Código limpia (Clean Code)

- Separación de responsabilidades: No mezclar lógica de Supabase en los Widgets.
- Uso de estados: Siempre manejar estados de `loading`, `error` y `success` en los ViewModels.
- **Validación de CI:** No realizar push si el linter (`flutter analyze`) o el formateador (`dart format`) fallan.

---

## 🔁 Flujo de Trabajo en Jira

1. Crear historia en Jira.
2. Descomponer en subtareas.
3. Implementar siguiendo el patrón MVVM.
4. **Validar CI localmente (Format, Analyze, Test).**
5. Crear PR y esperar a que el CI de GitHub confirme el éxito.
6. Merge a develop/main.

---

## 🧪 Testing (Futuro)

- Unit testing
- Integration testing
- Evaluación UX:
  - SUS
  - UEQ
  - AttrakDiff

---

## 📌 Nota Final

Este proyecto está diseñado bajo principios de:

- Diseño Centrado en el Usuario (DCU)
- Arquitectura limpia
- Escalabilidad futura

Cualquier cambio en arquitectura debe documentarse aquí.
