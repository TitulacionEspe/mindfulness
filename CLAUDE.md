# CLAUDE.md

Guía para agentes que trabajan en este repositorio. **`AGENTS.md` es la guía vinculante** de diseño, arquitectura y reglas de UX; este archivo la resume y añade lo operativo.

## Qué es

App **Flutter** de mindfulness e higiene del sueño para la comunidad universitaria (tesis ESPE). Enfoque **no clínico**. Backend **Supabase** (PostgreSQL + Auth + Storage) con RLS estricto.

## Stack y arquitectura

- **Flutter** gestionado con **FVM** (`.fvmrc` → stable). Usa siempre `fvm flutter ...`.
- **Arquitectura MVVM** con **Provider** (`ChangeNotifier`). Sin lógica de negocio en widgets.
- Capas: `models/` (datos), `services/` o `*_repository.dart` (acceso a Supabase/HTTP), `viewmodels/` (estado: `loading`/`error`/`success`), `views/` (UI).
- Providers globales se registran en `lib/main.dart` (`MultiProvider`).
- Backend: tablas en `Supabase/shema.sql` + migraciones numeradas en `Supabase/migrations/`. Toda tabla con RLS por `auth.uid()`.

## Comandos (CI obligatorio antes de cada commit)

```bash
fvm flutter pub get
fvm dart format .
fvm flutter analyze
fvm flutter test
```

Ejecutar la app: `fvm flutter run` (requiere `.env` con `SUPABASE_URL` y `SUPABASE_ANON_KEY`).

## Reglas de diseño (Nocturne Minimalist)

- **PROHIBIDO** `Colors.white`, `Colors.black` o hex sueltos. Usar siempre **`AppColors`** (`lib/core/theme/app_colors.dart`) y `AppTheme`.
- Validar cambios de UI contra las **10 heurísticas de Nielsen** (feedback de estado, prevención de errores, minimalismo).
- Táctiles ≥44px, radios 16–24, textos ≥14px, sin imágenes/gradientes complejos.
- Texto de UI en **español**; nombres de código y comentarios en **inglés**.

## Secretos

- Credenciales en `.env` (cargado con `flutter_dotenv`), nunca commiteado. No hardcodear claves.
- **Claves de APIs de IA NO van en la app**: viven como *secrets* de Supabase para las Edge Functions (ver `supabase/functions/`).

## Módulo de chat de acompañamiento "Asistente de Nidara"

- Edge Function `supabase/functions/emotional-chat/` → Google Gemini Flash (secret `GEMINI_API_KEY`).
- Tabla `chat_messages` (migración `008_*`), privada por usuario vía RLS.
- Flutter: `chat_message_model.dart`, `chat_repository.dart`, `chat_viewmodel.dart`, `views/modulo_paciente/chat_view.dart`.
- Comportamiento: acompaña y alienta, **no diagnostica**; ante riesgo sugiere agendar cita (módulo de citas) y muestra líneas de emergencia.
