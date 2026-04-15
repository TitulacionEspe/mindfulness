# 🧠 AGENTS.md – Guía Técnica del Proyecto

## 📌 Propósito

Este documento define las reglas técnicas, arquitectura y lineamientos de desarrollo del sistema de mindfulness e higiene del sueño.

Debe ser seguido por cualquier desarrollador que participe en el proyecto.

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

## 🧪 Buenas Prácticas

- Código limpio (Clean Code)
- Separación de responsabilidades
- Evitar lógica en la UI
- Manejo de errores centralizado
- Uso de estados (loading, error, success)

---

## 📌 Convenciones

### Naming

- snake_case → backend
- camelCase → Dart

### Archivos

- auth_service.dart
- user_model.dart

---

## 🚫 Anti-patrones a evitar

- Lógica en Widgets
- Acceso directo a Supabase desde UI
- Código duplicado
- Ignorar manejo de errores

---

## 🧠 Consideraciones UX

- Uso nocturno → modo oscuro
- Interacción mínima
- Flujo simple (≤ 3 pasos)
- Baja carga cognitiva

---

## 🔄 Flujo de Desarrollo y Calidad (CI/CD Local)

Para garantizar la estabilidad del proyecto y que los Pull Requests pasen los checks de GitHub Actions, **es obligatorio** validar los cambios localmente antes de realizar un `push`.

### 🛠️ Comandos de Validación Obligatoria

Antes de enviar tus cambios, ejecuta esta secuencia de comandos (usando `fvm`):

1. **Formato:** Corregir el estilo del código.
   ```bash
   fvm dart format .
   ```
2. **Análisis Estático:** Verificar que no haya errores de linting o lógica.
   ```bash
   fvm flutter analyze
   ```
3. **Pruebas:** Asegurar que no hay regresiones.
   ```bash
   fvm flutter test
   ```

### 🚩 Reglas de Oro

- **No Push con Errores:** Nunca hagas `push` si alguno de los comandos anteriores falla. Arregla los problemas primero.
- **Consistencia de SDK:** Usa siempre `fvm` para ejecutar comandos de Flutter/Dart para asegurar que todos usamos la misma versión.
- **Commits Limpios:** Si el CI falla por formato, aplica `dart format .` y añade ese cambio a tu commit.

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
