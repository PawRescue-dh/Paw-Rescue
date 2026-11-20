import { hash } from 'bcryptjs';
import dataSource from './data-source';

async function main() {
  await dataSource.initialize();
  try {
    switch (process.argv[2]) {
      case 'migrate':
        await dataSource.runMigrations({ transaction: 'all' });
        console.log('Migraciones completadas.');
        break;
      case 'revert':
        await dataSource.undoLastMigration({ transaction: 'all' });
        break;
      case 'seed': {
        if (process.env.NODE_ENV === 'production')
          throw new Error('Seed deshabilitado en producción.');
        const password = process.env.SEED_PASSWORD;
        if (
          !password ||
          Buffer.byteLength(password, 'utf8') > 72 ||
          !/^(?=.*[0-9])(?=.*[^A-Za-z0-9\s]).{8,}$/.test(password)
        ) {
          throw new Error(
            'Configura SEED_PASSWORD: mínimo 8 caracteres, un número y un símbolo; máximo 72 bytes.',
          );
        }
        const passwordHash = await hash(password, 12);
        await dataSource.transaction(async (manager) => {
          const users: { id: string }[] = await manager.query(
            `INSERT INTO users (name,email,password_hash,role)
            VALUES ('Ciudadano de prueba','ciudadano@example.test',$1,'Ciudadano')
            ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash RETURNING id`,
            [passwordHash],
          );
          const shelters: { id: string }[] = await manager.query(
            `INSERT INTO users (name,email,password_hash,role)
            VALUES ('Albergue de prueba','albergue@example.test',$1,'Albergue')
            ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash RETURNING id`,
            [passwordHash],
          );
          await manager.query(
            `INSERT INTO shelters (user_id,name,address,location)
            VALUES ($1,'Albergue de prueba','Ciudad de México',ST_SetSRID(ST_MakePoint(-99.1332,19.4326),4326)::geography)
            ON CONFLICT (user_id) DO NOTHING`,
            [shelters[0].id],
          );
          for (const [id, longitude] of [
            ['00000000-0000-4000-8000-000000000001', -99.1332],
            ['00000000-0000-4000-8000-000000000002', -100.1332],
          ]) {
            await manager.query(
              `INSERT INTO reports (id,user_id,species,description,urgency,location)
              VALUES ($1,$2,'canine','Reporte de prueba','high',ST_SetSRID(ST_MakePoint($3,19.4326),4326)::geography)
              ON CONFLICT (id) DO NOTHING`,
              [id, users[0].id, longitude],
            );
          }
        });
        console.log('Seed completado.');
        break;
      }
      case 'verify': {
        const rows: { id: string; longitude: number; latitude: number }[] =
          await dataSource.query(`SELECT id,
          ST_X(location::geometry) AS longitude, ST_Y(location::geometry) AS latitude FROM reports
          WHERE id IN ('00000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000002')
          AND ST_DWithin(location,ST_SetSRID(ST_MakePoint(-99.1332,19.4326),4326)::geography,5000)`);
        if (
          rows.length !== 1 ||
          rows[0].id !== '00000000-0000-4000-8000-000000000001' ||
          Math.abs(rows[0].longitude + 99.1332) > 0.000001 ||
          Math.abs(rows[0].latitude - 19.4326) > 0.000001
        ) {
          throw new Error(
            'Falló la verificación geoespacial. Ejecuta primero el seed.',
          );
        }
        console.log(
          'Coordenadas recuperadas; reporte cercano incluido y lejano excluido del radio de 5 km.',
        );
        break;
      }
      default:
        throw new Error('Usa migrate, revert, seed o verify.');
    }
  } finally {
    await dataSource.destroy();
  }
}

void main().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
