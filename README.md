# 🧠 Sistema de Mindfulness e Higiene del Sueño - ESPE

## 📌 Descripción del Proyecto

Este proyecto consiste en el diseño y desarrollo de un sistema integral de apoyo a la higiene del sueño y la autorregulación emocional, dirigido a la comunidad universitaria de la Universidad de las Fuerzas Armadas ESPE.

La solución está compuesta por:

- 📱 Aplicación móvil (Flutter) para el usuario final (Paciente)
- 🧑‍⚕️ Módulo profesional para Bienestar Universitario
- ⚙️ Backend serverless basado en Supabase

El sistema tiene un enfoque **no clínico**, orientado a promover hábitos saludables mediante prácticas como:

- Ejercicios de respiración guiada
- Rutinas de relajación
- Reproducción de audios
- Registro de pensamientos
- Autopercepción emocional
- Seguimiento de hábitos de sueño

---

## 👤 Usuario del Sistema

El sistema está dirigido al **Paciente**, definido como:

> Cualquier miembro de la comunidad universitaria de la ESPE (estudiantes, docentes, personal militar o administrativo) que utilice la aplicación para mejorar su bienestar.

---

## 🎯 Objetivo

Desarrollar una herramienta digital accesible, usable y centrada en el usuario que permita:

- Mejorar la calidad del sueño
- Reducir el estrés nocturno
- Fomentar la autorregulación emocional

---

## 🚀 Cómo Empezar (Setup Local)

Para colaborar en este proyecto, es **obligatorio** utilizar **FVM** (Flutter Version Manager) para garantizar la consistencia de la versión del SDK entre todos los desarrolladores.

### 📋 Prerrequisitos

- **Flutter SDK** (gestionado vía FVM)
- **Dart SDK** (^3.11.0)
- **Git**
- **FVM:** `dart pub global activate fvm`

### 🛠️ Pasos de Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/TitulacionEspe/mindfulness.git
   cd mindfulness
   ```
2. **Instalar la versión de Flutter del proyecto:**
   ```bash
   fvm install
   ```
3. **Obtener dependencias:**
   ```bash
   fvm flutter pub get
   ```
4. **Configurar variables de entorno:**
   Copia `.env.example` a `.env` y completa las llaves de Supabase (no compartas este archivo).

### 🧪 Validación de Calidad (CI Local)

Antes de realizar cualquier commit o push, **debes** ejecutar la secuencia de validación:
```bash
fvm dart format .
fvm flutter analyze
fvm flutter test
```

---

## 📂 Mapa de Documentación (`docs/`)

Para entender profundamente el sistema, consulta los siguientes documentos en la carpeta `docs/`:

| Documento | Propósito |
| :--- | :--- |
| [**ERS.md**](./docs/ERS.md) | Especificación de Requisitos del Sistema (Funcionales y No Funcionales). |
| [**PLANIFICACION.md**](./docs/PLANIFICACION.md) | Cronograma, hitos y hoja de ruta del MVP. |
| [**README-dev.md**](./docs/README-dev.md) | Guía técnica detallada para desarrolladores y setup de Supabase. |
| [**STORAGE-routines.md**](./docs/STORAGE-routines.md) | Protocolo de manejo de archivos de audio en Supabase Storage. |
| [**METODOLOGIA_VISUAL.md**](./docs/METODOLOGIA_VISUAL.md) | Justificación metodológica de la paleta de colores y accesibilidad implementada. |
| [**Diseno_Centrado_Usuario.md**](./docs/Diseno_Centrado_Usuario_Presentacion.md) | Guía de UX, accesibilidad y modo nocturno. |
| [**MANUAL_USUARIO.md**](./docs/MANUAL_USUARIO.md) | Guia breve para el uso de Nidara por pacientes, profesionales y administradores. |
| [**MANUAL_INSTALACION.md**](./docs/MANUAL_INSTALACION.md) | Pasos para preparar, configurar y ejecutar el proyecto localmente. |

---

## 🏗️ Arquitectura del Sistema

El sistema sigue una arquitectura moderna basada en:

### 🔹 Frontend (Flutter)
- **Patrón:** MVVM (Model-View-ViewModel).
- **Gestión de Estado:** `provider`.
- **Estilo:** `AppTheme` centralizado (enfocado en modo oscuro).

### 🔹 Backend (Supabase BaaS)
- **PostgreSQL:** Base de datos relacional con RLS (Row Level Security) estricto.
- **Auth:** Gestión de identidad y perfiles automáticos vía triggers.
- **Storage:** Almacenamiento de audios con URLs firmadas (TTL).

---

## 🔒 Reglas de Seguridad y Datos

- **Aislamiento Total:** El acceso a datos transaccionales (sesiones, sueño, diarios) está restringido por `auth.uid()`.
- **Diario Íntimo:** Los pensamientos se almacenan mediante cifrado asimétrico/KMS (ver ERS).
- **Consentimiento:** Todo usuario debe aceptar el consentimiento informado antes de usar la app.

---

## 📚 Autor y Tesis
**Proyecto de Tesis – Ingeniería en Software**  
Universidad de las Fuerzas Armadas ESPE  
*Investigador principal y desarrolladores.*
