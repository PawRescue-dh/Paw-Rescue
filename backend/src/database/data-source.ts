import 'dotenv/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { DataSource, DataSourceOptions } from 'typeorm';
import { User } from '../auth/user.entity';
import { Report } from '../reports/report.entity';

const LOCAL_HOSTS = ['localhost', '127.0.0.1', 'db', 'postgres'];

/**
 * SSL: se activa con DB_SSL=true, o automáticamente cuando el host no es local
 * (Supabase, Render, etc.). DB_SSL=false lo fuerza apagado.
 */
const useSsl = (host: string): boolean => {
  if (process.env.DB_SSL === 'true') return true;
  if (process.env.DB_SSL === 'false') return false;
  return !LOCAL_HOSTS.includes(host);
};

const getBaseConfig = (): DataSourceOptions => {
  const host = process.env.DB_HOST || 'localhost';
  return {
    type: 'postgres',
    host,
    port: parseInt(process.env.DB_PORT || '5432', 10),
    username: process.env.DB_USERNAME || process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || process.env.DB_PASS || 'postgres',
    database: process.env.DB_DATABASE || process.env.DB_NAME || 'paw_rescue',
    entities: [User, Report],
    synchronize: true,
    ssl: useSsl(host) ? { rejectUnauthorized: false } : false,
  };
};

export const databaseOptions = (): TypeOrmModuleOptions => ({
  ...getBaseConfig(),
  autoLoadEntities: true,
});

const dataSource = new DataSource(getBaseConfig());
export default dataSource;
