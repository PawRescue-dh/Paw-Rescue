import 'reflect-metadata';
import { config } from 'dotenv';
import { DataSource } from 'typeorm';
import { Report, Shelter, User } from './entities';
import { InitialSchema1790000000000 } from './migrations/1790000000000-InitialSchema';

config();

export const databaseOptions = () => ({
  type: 'postgres' as const,
  host: process.env.DB_HOST ?? 'localhost',
  port: Number(process.env.DB_PORT ?? 5432),
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  entities: [User, Report, Shelter],
  migrations: [InitialSchema1790000000000],
  synchronize: false,
});

export default new DataSource(databaseOptions());
