# Supabase Schema – Documento técnico de referencia

**Archivo origen:** `Supabase/shema.sql`

Este documento resume el esquema SQL actual, columnas por tabla, índices y políticas RLS, además de recomendaciones operativas para desarrollo y despliegue.

---

## 1. Extensiones y tipos

- Extensiones: `uuid-ossp`, `pgcrypto`.
- ENUMs definidos: `user_role`, `user_segment`, `routine_category`, `session_status`, `assessment_context`, `flag_status`, `assignment_status`.

## 2. Tablas y columnas (referencia rápida)

### `public.profiles`

| Columna    | Tipo         | Notas                                            |
| ---------- | ------------ | ------------------------------------------------ |
| id         | UUID PK      | FK -> `auth.users(id)`; ON DELETE CASCADE        |
| role       | user_role    | default 'patient'                                |
| segment    | user_segment | default 'student'                                |
| full_name  | TEXT         |                                                  |
| theme_mode | TEXT         | default 'light'; valores 'light', 'dark'         |
| created_at | TIMESTAMPTZ  | default NOW()                                    |
| updated_at | TIMESTAMPTZ  | default NOW(); trigger `set_updated_at_profiles` |
| is_active  | BOOLEAN      | default TRUE                                     |

### `public.consents`

| Columna          | Tipo        | Notas                                   |
| ---------------- | ----------- | --------------------------------------- |
| id               | UUID PK     | default uuid_generate_v4()              |
| patient_id       | UUID        | FK -> `public.profiles(id)`             |
| document_version | TEXT        | versión del documento de consentimiento |
| terms_accepted   | BOOLEAN     | CHECK (terms_accepted = TRUE)           |
| accepted_at      | TIMESTAMPTZ | default NOW()                           |

### `public.patient_settings`

| Columna            | Tipo        | Notas                                            |
| ------------------ | ----------- | ------------------------------------------------ |
| patient_id         | UUID PK     | FK -> `public.profiles(id)`                      |
| habitual_bedtime   | TIME        | horario preferido para dormir                    |
| habitual_wake_time | TIME        | horario de despertar                             |
| dark_mode_enforced | BOOLEAN     | default FALSE                                    |
| preferred_voice    | TEXT        | voz TTS preferida                                |
| updated_at         | TIMESTAMPTZ | default NOW(); trigger `set_updated_at_settings` |

### `public.reminders`

| Columna      | Tipo        | Notas                                      |
| ------------ | ----------- | ------------------------------------------ |
| id           | UUID PK     | default uuid_generate_v4()                 |
| patient_id   | UUID        | FK -> `public.profiles(id)`                |
| trigger_time | TIME        | hora del recordatorio                      |
| days_of_week | SMALLINT    | formato bitmask sugerido (0-127) para días |
| is_active    | BOOLEAN     | default TRUE                               |
| created_at   | TIMESTAMPTZ | default NOW()                              |

### `public.routines`

| Columna          | Tipo             | Notas                         |
| ---------------- | ---------------- | ----------------------------- |
| id               | UUID PK          | default uuid_generate_v4()    |
| title            | TEXT             | NOT NULL                      |
| description      | TEXT             |                               |
| category         | routine_category | ENUM                          |
| duration_seconds | INTEGER          | CHECK >0 AND <=2700 (≤45 min) |
| is_active        | BOOLEAN          | default TRUE                  |
| created_at       | TIMESTAMPTZ      | default NOW()                 |

### `public.routine_assets`

| Columna         | Tipo    | Notas                       |
| --------------- | ------- | --------------------------- |
| id              | UUID PK | default uuid_generate_v4()  |
| routine_id      | UUID    | FK -> `public.routines(id)` |
| storage_bucket  | TEXT    | bucket en Supabase Storage  |
| storage_path    | TEXT    | ruta del archivo            |
| file_type       | TEXT    | MIME o extensión            |
| file_size_bytes | BIGINT  | tamaño en bytes             |

### `public.breathing_patterns`

| Columna            | Tipo    | Notas                       |
| ------------------ | ------- | --------------------------- |
| id                 | UUID PK | default uuid_generate_v4()  |
| routine_id         | UUID    | FK -> `public.routines(id)` |
| inhale_sec         | INTEGER | > 0                         |
| hold_in_sec        | INTEGER | ≥ 0                         |
| exhale_sec         | INTEGER | > 0                         |
| hold_out_sec       | INTEGER | ≥ 0                         |
| cycles_recommended | INTEGER | default 5                   |

### `public.activity_sessions`

| Columna      | Tipo           | Notas                       |
| ------------ | -------------- | --------------------------- |
| id           | UUID PK        | default uuid_generate_v4()  |
| patient_id   | UUID           | FK -> `public.profiles(id)` |
| routine_id   | UUID           | FK -> `public.routines(id)` |
| started_at   | TIMESTAMPTZ    | default NOW()               |
| completed_at | TIMESTAMPTZ    | nullable                    |
| status       | session_status | ENUM DEFAULT 'interrupted'  |
| notes        | TEXT           | notas libres del usuario    |

### `public.self_assessments`

| Columna     | Tipo               | Notas                                                    |
| ----------- | ------------------ | -------------------------------------------------------- |
| id          | UUID PK            | default uuid_generate_v4()                               |
| patient_id  | UUID               | FK -> `public.profiles(id)`                              |
| session_id  | UUID               | FK -> `public.activity_sessions(id)`; ON DELETE SET NULL |
| context     | assessment_context | ENUM (pre_session/post_session/standalone)               |
| emotion_id  | TEXT               | referencia libre o a catálogo futuro                     |
| intensity   | INTEGER            | CHECK 1..10                                              |
| recorded_at | TIMESTAMPTZ        | default NOW()                                            |

### `public.sleep_logs`

| Columna                    | Tipo        | Notas                         |
| -------------------------- | ----------- | ----------------------------- |
| id                         | UUID PK     | default uuid_generate_v4()    |
| patient_id                 | UUID        | FK -> `public.profiles(id)`   |
| log_date                   | DATE        | default CURRENT_DATE          |
| bed_time                   | TIMESTAMPTZ | hora de acostarse             |
| wake_time                  | TIMESTAMPTZ | hora de despertarse           |
| sleep_latency_min          | INTEGER     | CHECK >= 0                    |
| wake_after_sleep_onset_min | INTEGER     | CHECK >= 0                    |
| sleep_quality_rating       | INTEGER     | CHECK 1..5                    |
| disturbances               | TEXT        | descripción de interrupciones |
| recorded_at                | TIMESTAMPTZ | default NOW()                 |

### `public.thought_entries`

| Columna            | Tipo        | Notas                                                       |
| ------------------ | ----------- | ----------------------------------------------------------- |
| id                 | UUID PK     | default uuid_generate_v4()                                  |
| patient_id         | UUID        | FK -> `public.profiles(id)`                                 |
| content_ciphertext | TEXT        | contenido cifrado (no texto plano)                          |
| key_id             | UUID        | identificador de clave para desencriptado (gestión externa) |
| created_at         | TIMESTAMPTZ | default NOW()                                               |

### `public.risk_flags`

| Columna          | Tipo        | Notas                              |
| ---------------- | ----------- | ---------------------------------- |
| id               | UUID PK     | default uuid_generate_v4()         |
| patient_id       | UUID        | FK -> `public.profiles(id)`        |
| source_entry_id  | UUID        | FK -> `public.thought_entries(id)` |
| flag_type        | TEXT        | e.g., 'suicidal_ideation'          |
| detected_at      | TIMESTAMPTZ | default NOW()                      |
| status           | flag_status | ENUM DEFAULT 'active'              |
| resolution_notes | TEXT        | notas de seguimiento               |

### `public.assignments`

| Columna           | Tipo              | Notas                       |
| ----------------- | ----------------- | --------------------------- |
| id                | UUID PK           | default uuid_generate_v4()  |
| patient_id        | UUID              | FK -> `public.profiles(id)` |
| professional_id   | UUID              | FK -> `public.profiles(id)` |
| routine_id        | UUID              | FK -> `public.routines(id)` |
| assigned_at       | TIMESTAMPTZ       | default NOW()               |
| target_completion | DATE              | fecha objetivo              |
| status            | assignment_status | ENUM DEFAULT 'pending'      |

### `public.content_messages`

| Columna      | Tipo        | Notas                      |
| ------------ | ----------- | -------------------------- |
| id           | UUID PK     | default uuid_generate_v4() |
| category     | TEXT        | e.g., 'motivation'         |
| message_body | TEXT        | contenido del mensaje      |
| version      | INTEGER     | default 1                  |
| is_active    | BOOLEAN     | default TRUE               |
| created_at   | TIMESTAMPTZ | default NOW()              |

---

## 3. Triggers, funciones e índices

- Función: `public.handle_updated_at()` aplicada a tablas que contienen `updated_at`.
- Función: `public.is_assigned_professional(target_patient_id UUID)` que devuelve boolean para políticas de auditoría.
- Índices: `idx_profiles_role`, `idx_patient_settings_patient`, `idx_routines_category`, `idx_routine_assets_routine`, `idx_activity_sessions_patient`, `idx_self_assessments_patient`, `idx_thought_entries_patient`, `idx_assignments_composite`, `idx_sleep_logs_patient_date`.

## 4. Políticas RLS (resumen operativo)

- RLS habilitado en todas las tablas sensibles.
- Políticas públicas (lectura) para catálogos: `routines`, `breathing_patterns`, `content_messages` (sólo items `is_active = TRUE`).
- Políticas restrictivas por paciente: `activity_sessions`, `self_assessments`, `sleep_logs` sólo accesibles cuando `auth.uid() = patient_id`.
- Inserciones protegidas: `WITH CHECK (auth.uid() = patient_id)` para evitar suplantaciones.
- `thought_entries`: política "Privacidad inquebrantable" — sólo el dueño (auth.uid() = patient_id) puede leer/insertar/actualizar.

### Ejemplo de política (pseudo-SQL) para `activity_sessions`:

```sql
CREATE POLICY "Visualiza sus propias sesiones"
  ON public.activity_sessions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = patient_id);
```

## 5. Pruebas recomendadas (RLS y seguridad)

- Crear cuentas de prueba: patient_x, professional_y, admin_z.
- Validar que `patient_x` solo ve sus `activity_sessions` y `sleep_logs`.
- Intentar inserciones con `patient_id` diferente y comprobar que FALLAN por `WITH CHECK`.

## 6. Consideraciones de cifrado y gestión de claves

- `thought_entries.content_ciphertext` debe contener datos cifrados con clave gestionada externamente (KMS).
- Guardar sólo `key_id` en la DB; la desencriptación debe hacerse en backend con acceso controlado.
- Rotación de claves y registro de eventos de desencriptado.

## 7. Sugerencias operativas y mejoras futuras

- Añadir `created_by`/`updated_by` para auditoría si el rol administrativo necesita trazabilidad.
- Agregar tabla de `audit_logs` para registrar accesos sensibles (lecturas de `thought_entries`).
- Automatizar migrations con herramienta (sqitch, flyway, migrate) y agregar CI que aplique migraciones a staging.

---

Referencia: ver `Supabase/shema.sql` para la definición completa y `docs/` para requisitos y planificación.
