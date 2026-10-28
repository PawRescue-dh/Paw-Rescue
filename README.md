# PawRescue-App

Aplicación móvil para reportar animales en situación de calle y apoyar su rescate.

## PAW-2: PostgreSQL y PostGIS

Requisitos: Node.js 24, Docker con contenedores Linux y el puerto 5432 disponible.

1. Copiar `backend/.env.example` a `backend/.env` sin sobrescribir configuraciones existentes y configurar DB_USER, DB_PASSWORD, DB_NAME, DB_HOST y DB_PORT.
2. Desde la raíz del repositorio:

```sh
docker compose --env-file backend/.env up -d
```

El parámetro `--env-file` permite que Docker Compose resuelva las variables del servicio. Si otro PostgreSQL ocupa el puerto 5432, cambiar el puerto publicado en docker-compose.yml y DB_PORT. No borrar volúmenes existentes para resolver conflictos de puerto.

3. Desde `backend`:

```sh
npm ci
npm run db:migrate
npm run db:seed
npm run db:verify
npm run start:dev
```

### Esquema y migraciones

- `users`: UUID, nombre, correo único normalizado, password_hash, rol Ciudadano/Albergue y fecha de creación.
- `reports`: UUID, referencia al usuario, especie canine/feline, descripción, urgencia low/medium/high, estado active/resolved, ubicación, referencia opcional a foto y fecha.
- `shelters`: UUID, usuario responsable único, nombre, dirección y ubicación.
- Las ubicaciones usan GEOGRAPHY(POINT,4326); las coordenadas se expresan como longitud, latitud.
- reports tiene un índice GiST para consultas geográficas. Las relaciones tienen claves foráneas.
- TypeORM usa migraciones explícitas con synchronize: false.

`npm run db:migrate` aplica las migraciones pendientes. `npm run db:revert` revierte la última migración y puede eliminar tablas: usar únicamente en una base descartable.

### Datos de prueba

Configurar `SEED_PASSWORD` con al menos 8 caracteres, un número y un símbolo, máximo 72 bytes UTF-8. El seed crea `ciudadano@example.test` y `albergue@example.test`, con esa contraseña protegida mediante bcrypt de coste 12. También crea un albergue y dos reportes de coordenadas conocidas.

El seed está deshabilitado con NODE_ENV=production. Repetirlo actualiza las contraseñas de esas dos cuentas de prueba sin duplicar sus reportes.

`npm run db:verify` requiere ejecutar primero el seed. Comprueba la recuperación de coordenadas y que una consulta de radio de 5 km incluya el reporte cercano y excluya el lejano.

### Validación

Desde backend:

```sh
npm run lint
npm test -- --runInBand
npm run build
npm run db:migrate
npm run db:seed
npm run db:verify
npm run test:e2e -- --runInBand
```

El workflow usa una base descartable PostgreSQL 15 + PostGIS 3.4 para comprobar migraciones, seed, consulta geográfica y arranque HTTP de NestJS. Su ejecución en GitHub debe confirmarse en el PR.

### Continuación del Sprint 2

PAW-3 implementará registro, login, validación de contraseña, JWT y protección de rutas sobre la entidad User. PAW-5 implementará las pantallas Flutter y consumirá esa API. El esquema y seed de PAW-2 no incluyen esos endpoints ni pantallas.

Después de integrar PAW-2 en develop, cada compañero debe actualizar develop y crear su propia rama `featured/...`. PAW-5 puede avanzar con formularios y respuestas simuladas mientras se implementa PAW-3; deben acordar el contrato de la API entre ambos responsables.
