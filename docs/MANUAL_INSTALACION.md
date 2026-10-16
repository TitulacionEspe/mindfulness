# Manual de instalacion - Nidara

## 1. Requisitos

Para ejecutar el proyecto en desarrollo se necesita:

- Git.
- Dart SDK.
- FVM (Flutter Version Manager).
- Un emulador Android, dispositivo fisico o entorno de escritorio compatible con Flutter.
- Credenciales validas de un proyecto Supabase.

El proyecto utiliza la version estable de Flutter definida en [`.fvmrc`](../.fvmrc). FVM evita que todos los integrantes usen versiones diferentes del SDK.

## 2. Obtener el proyecto

En PowerShell, clona el repositorio y entra a su carpeta:

```powershell
git clone https://github.com/TitulacionEspe/mindfulness.git
cd mindfulness
```

Si FVM no esta instalado, ejecuta una sola vez:

```powershell
dart pub global activate fvm
```

Instala el SDK requerido y las dependencias del proyecto:

```powershell
fvm install
fvm flutter pub get
```

## 3. Configurar Supabase

En la raiz del proyecto crea un archivo llamado `.env`. Este archivo no debe subirse al repositorio. Agrega las credenciales de tu proyecto Supabase:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_clave_anon_publica
```

Usa solamente la clave anon en la aplicacion cliente. La clave `service_role` es privada y nunca debe incluirse en el archivo `.env` de una aplicacion distribuida.

Para un entorno nuevo, aplica el esquema y las politicas de la carpeta `Supabase/` desde el panel SQL de Supabase o mediante el CLI. La guia tecnica completa esta en [README-dev.md](README-dev.md).

## 4. Ejecutar la aplicacion

Con un dispositivo o emulador disponible, ejecuta:

```powershell
fvm flutter run
```

Para comprobar los dispositivos detectados antes de iniciar, usa:

```powershell
fvm flutter devices
```

## 5. Generar una APK (Android)

Para una prueba local:

```powershell
fvm flutter build apk --debug
```

Para una compilacion de distribucion, con la firma de Android previamente configurada:

```powershell
fvm flutter build apk --release
```

La APK generada se encuentra en `build/app/outputs/flutter-apk/`.

## 6. Verificacion basica

Antes de entregar cambios, ejecuta:

```powershell
fvm dart format .
fvm flutter analyze
fvm flutter test
```

Si la aplicacion no inicia, verifica que `.env` exista y que `SUPABASE_URL` y `SUPABASE_ANON_KEY` tengan valores validos. Si FVM no se reconoce en la terminal, cierra y vuelve a abrir PowerShell despues de instalarlo.

