# Metodologia visual y accesibilidad

Este documento resume la justificacion metodologica de la identidad visual del sistema de mindfulness e higiene del sueno, junto con las funciones de accesibilidad implementadas en la aplicacion.

## 1. Enfoque visual

La interfaz utiliza un sistema de colores de baja saturacion, contrastes controlados y capas tonales para reducir la fatiga visual en uso nocturno. La jerarquia visual no depende de sombras fuertes ni de colores intensos, sino de diferencias entre superficies, bordes y acentos suaves.

La fuente de verdad del tema es `AppColors`, y su aplicacion global se centraliza en `AppTheme`. Esto evita inconsistencias entre pantallas y facilita mantener una experiencia uniforme.

## 2. Justificacion del sistema cromatico

La paleta principal se construyo para un contexto de uso sensible: estudiantes o usuarios que interactuan con la app en horarios nocturnos, con cansancio visual o en entornos de baja iluminacion.

La seleccion cromatica responde a estos criterios:

- reducir el deslumbramiento asociado a superficies claras de alta luminancia;
- evitar colores saturados o neon que aumenten la estimulacion visual;
- conservar una lectura clara mediante contrastes adecuados entre texto y fondo;
- representar estados de la interfaz con codigos semanticos consistentes;
- mantener una estetica tranquila y no invasiva, coherente con el objetivo de higiene del sueno.

En la practica, el proyecto usa cuatro paletas:

- `darkPalette`: version nocturna principal, base de la experiencia Nocturne.
- `lightPalette`: version clara funcional para uso diurno.
- `colorBlindLightPalette`: variante clara con ajuste para soporte rojo-verde.
- `colorBlindDarkPalette`: variante oscura con ajuste para soporte rojo-verde.

## 3. Mapa de tokens de color

Los siguientes tokens se reutilizan en todo el proyecto. El identificador ayuda a documentar cada color de forma estable, aun cuando la paleta activa cambie por tema o por accesibilidad.

| ID | Token | darkPalette | lightPalette | colorBlindLightPalette | colorBlindDarkPalette |
| --- | --- | --- | --- | --- | --- |
| T01 | `background` | `#141315` | `#F8F6FA` | `#F8F7F3` | `#151412` |
| T02 | `surface` | `#201F21` | `#FFFFFBFF` | `#FFFFFCF7` | `#211F1C` |
| T03 | `surfaceLowest` | `#0F0E10` | `#FFFFFF` | `#FFFFFF` | `#100F0E` |
| T04 | `surfaceLow` | `#1C1B1D` | `#F2EEF5` | `#F0EDE6` | `#1D1B19` |
| T05 | `surfaceHigh` | `#2B292C` | `#E9E4ED` | `#E6E2D8` | `#2C2925` |
| T06 | `surfaceHighest` | `#363437` | `#DED8E3` | `#DAD5CA` | `#39352F` |
| T07 | `surfaceBright` | `#3A383B` | `#FFFFFBFF` | `#FFFFFCF7` | `#403C35` |
| T08 | `textPrimary` | `#E6E1E4` | `#211F24` | `#211F1A` | `#EEE8DD` |
| T09 | `textSecondary` | `#CAC4CD` | `#5E5864` | `#5B574E` | `#D1C8BA` |
| T10 | `outline` | `#948F97` | `#746D79` | `#777064` | `#9A9284` |
| T11 | `outlineVariant` / `navBorder` | `#49454D` | `#C9C1CE` | `#C9C0B4` | `#504A42` |
| T12 | `lavender` | `#D1C4E9` | `#6F5C91` | `#6B5CA5` | `#D0C3FF` |
| T13 | `mint` | `#B2DFDB` | `#006B63` | `#006E9C` | `#8FD8FF` |
| T14 | `tertiary` | `#F3E6B0` | `#6A5D16` | `#8A5A00` | `#FFD08A` |
| T15 | `tertiaryContainer` | `#D6CA96` | `#F3E6B0` | `#F2D28A` | `#D2A54B` |
| T16 | `tertiaryOnContainer` | `#5D552B` | `#2B2500` | `#2B1A00` | `#4C3300` |
| T17 | `buttonPrimary` | `#B2DFDB` | `#006B63` | `#006E9C` | `#8FD8FF` |
| T18 | `buttonPrimaryText` | `#053734` | `#FFFFFFFF` | `#FFFFFFFF` | `#00344D` |
| T19 | `error` | `#FFB4AB` | `#BA1A1A` | `#A8326E` | `#FFB1D0` |
| T20 | `successBg` | `#26B2DFDB` | `#2611736B` | `#26006E9C` | `#268FD8FF` |
| T21 | `warningBg` | `#26D1C4E9` | `#266F5C91` | `#266B5CA5` | `#26D0C3FF` |
| T22 | `tertiaryBg` | `#26D6CA96` | `#266A5D16` | `#268A5A00` | `#26FFD08A` |
| T23 | `secondaryContainer` | `#224E4B` | `#D4EFEB` | `#DCEFFD` | `#174D65` |

### Lectura rapida de la tabla

- `background` y `surface` definen el lienzo principal.
- `surfaceLow`, `surfaceHigh` y `surfaceHighest` construyen la profundidad tonal.
- `textPrimary` y `textSecondary` controlan la jerarquia de lectura.
- `lavender`, `mint` y `tertiary` son los acentos funcionales.
- `successBg`, `warningBg` y `tertiaryBg` son fondos de estado con opacidad baja.
- `buttonPrimary` y `buttonPrimaryText` definen la accion principal.
- `outlineVariant` / `navBorder` estabiliza bordes, divisores y navegacion inferior.

## 4. Uso semantico en la interfaz

El sistema asigna significado a cada acento para que el usuario no dependa solo del color:

- `pending`: usa `warningBg` + texto `lavender`.
- `completed`: usa `successBg` + texto `mint`.
- `expired` o alerta no critica: usa `tertiaryBg` + texto `tertiaryOnContainer`.
- error bloqueante: usa `error` + texto de alto contraste.

Este enfoque mejora la comprension rapida del estado, especialmente en pantallas pequenas o en condiciones de cansancio.

## 5. Accesibilidad implementada

La aplicacion incorpora tres medidas concretas de accesibilidad:

### 5.1 Cambio de tema

El usuario puede alternar entre tema claro y oscuro mediante `ThemeMode.light` y `ThemeMode.dark`. La preferencia se persiste y se aplica de forma global a traves de `ThemeViewModel`, `ThemePreferencesRepository` y `AppTheme`.

Objetivo:

- permitir uso diurno y nocturno;
- reducir brillo en contextos de descanso;
- mantener consistencia visual entre sesiones.

### 5.2 Cambio de tamano de fuente

La app permite ajustar la escala tipografica en pasos discretos de `0.90`, `1.00`, `1.10`, `1.20` y `1.30`.

Objetivo:

- facilitar la lectura a usuarios con distinta agudeza visual;
- mejorar la comodidad sin romper el layout;
- cumplir con el principio de escalabilidad tipografica.

### 5.3 Soporte para daltonismo rojo-verde

Se implemento un modo de apoyo visual denominado `redGreenSupport`, pensado para la deficiencia cromatica mas comun. La interfaz cambia a una variante cromatica alternativa que no depende solo de la distincion entre rojo y verde.

Objetivo:

- evitar que el estado de una accion dependa exclusivamente del matiz;
- reforzar la lectura mediante tono, contraste y texto;
- mantener la funcionalidad del sistema de estados sin perder identidad visual.

## 6. Sustento metodologico

La decision de usar una paleta oscura y tonal se apoya en tres ideas:

1. Las interfaces oscuras son adecuadas para entornos de baja iluminacion y uso nocturno.
2. Los colores desaturados reducen la vibracion optica y ayudan a conservar legibilidad.
3. La accesibilidad visual no debe depender solo del color, sino tambien del contraste, el texto y los estados semanticos.

Esto hace que la identidad visual sea compatible con un sistema orientado al sueno, la calma y la baja carga cognitiva.

## 7. Referencias utiles para citar en la metodologia

- [Apple Human Interface Guidelines - Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
- [Material Design - Dark theme](https://m2.material.io/design/color/dark-theme.html)
- [Material Design - Color contrast and accessibility](https://m3.material.io/foundations/designing/color-contrast)
- [W3C WCAG 2.2 - Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
- [W3C WCAG 2.2 - Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html)
- [W3C WCAG - Use of Color](https://www.w3.org/WAI/WCAG21/Understanding/use-of-color.html)
- [National Eye Institute - Color Blindness](https://www.nei.nih.gov/eye-health-information/eye-conditions-and-diseases/color-blindness)
- [PubMed - Effects of smartphone use with and without blue light at night](https://pubmed.ncbi.nlm.nih.gov/28017916/)

## 8. Nota para la tesis

Si este texto se usa en la redaccion academica, conviene explicar que el sistema visual no busca un efecto estetico decorativo, sino una respuesta funcional al contexto de uso: baja iluminacion, cansancio visual, lectura rapida y necesidad de accesibilidad.
