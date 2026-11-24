# Guía de pruebas de PawRescue

Documento de apoyo para la actividad "Tipos de pruebas para garantizar el correcto
funcionamiento de una aplicación móvil".

## Tipos de prueba aplicados

| Tipo | Qué se verifica | Dónde / cómo se ejecuta |
|------|-----------------|--------------------------|
| Funcionales | Registro, login, creación y consulta de reportes, cambio de estado | `backend`: `npm test` (auth.service, reports.service, reports.controller) |
| Seguridad | Acceso sin token, token manipulado o falso, rol sin permiso, validación de entradas, hash de contraseñas | `backend`: `jwt-auth.guard.spec.ts`, `dto.validation.spec.ts`, `reports.controller.spec.ts` |
| UI Testing | Pantallas Login y Registro, navegación, mensajes de validación | `mobile`: `flutter test` (login_screen_test, register_screen_test) |
| Rendimiento | El listado `GET /reports` ya no envía la foto en base64 y está limitado a 200 registros | Comparar con `curl -w "%{size_download} %{time_total}\n"` antes/después |
| Regresión | Todo lo anterior corre en cada PR en GitHub Actions | `.github/workflows/ci.yml` |

## Cómo ejecutar

```bash
# Backend (Node 24)
cd backend && npm ci && npm test -- --runInBand

# Móvil
cd mobile && flutter pub get && flutter analyze && flutter test
```

## Pruebas manuales en emulador / dispositivo (tomar capturas)

1. Instalar el APK (artifact `pawrescue-app-release` de GitHub Actions o `flutter build apk --release --dart-define=API_URL=<URL>`).
2. Registro con datos válidos e inválidos (correo mal escrito, contraseña de menos de 8 caracteres).
3. Login con `ana@pawrescue.com` / `Password123!` (Ciudadano) y `carlos@pawrescue.com` / `Rescate2026!` (Albergue).
4. Crear un reporte con foto y GPS; verlo en el mapa.
5. Con el usuario Albergue: abrir un reporte y cambiar el estado a "En atención" / "Resuelto".

## Pruebas de seguridad con curl

```bash
API=https://TU-API.onrender.com
curl -i $API/reports                                  # esperado: 401 sin token
curl -i -H "Authorization: Bearer falso" $API/reports # esperado: 401
curl -i -X POST $API/auth/register -H "Content-Type: application/json" \
  -d '{"name":"X","email":"malo","password":"1","role":"Admin"}'   # esperado: 400
```

## Hallazgos corregidos (para el reporte)

| # | Hallazgo | Tipo | Corrección |
|---|----------|------|------------|
| 1 | `GET/POST /reports` aceptaban peticiones sin sesión | Seguridad | `JwtAuthGuard` en todo el módulo de reportes |
| 2 | Cuerpos sin validar (`any`): urgencia, coordenadas y rol arbitrarios | Seguridad / Funcional | DTOs con `class-validator` y `ValidationPipe` (whitelist) |
| 3 | El listado devolvía todas las fotos en base64 | Rendimiento | Listado sin foto + `GET /reports/:id` para el detalle y límite de 200 |
| 4 | El rol Albergue no tenía función | Funcional | `PATCH /reports/:id/status` (403 para Ciudadano) y botones en el mapa |
| 5 | El APK apuntaba a `localhost` | Instalación / Compatibilidad | `API_URL` por `--dart-define` y timeouts de 60 s para Render |
| 6 | Build de Render fallaba con Node 18 | Instalación | Dockerfile en `node:22-alpine` y `npm ci` |
