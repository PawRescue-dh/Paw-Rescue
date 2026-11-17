import 'dotenv/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { DataSource, DataSourceOptions } from 'typeorm';
import { User } from '../auth/user.entity';
import { Report } from '../reports/report.entity';

const getBaseConfig = (): DataSourceOptions => ({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  username: process.env.DB_USERNAME || process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || process.env.DB_PASS || 'postgres',
  database: process.env.DB_DATABASE || process.env.DB_NAME || 'paw_rescue',
  entities: [User, Report],
  synchronize: true,
});

export const databaseOptions = (): TypeOrmModuleOptions => ({
  ...getBaseConfig(),
  autoLoadEntities: true,
});

const dataSource = new DataSource(getBaseConfig());
export default dataSource;