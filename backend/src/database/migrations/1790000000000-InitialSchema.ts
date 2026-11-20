import type { MigrationInterface, QueryRunner } from 'typeorm';

export class InitialSchema1790000000000 implements MigrationInterface {
  async up(runner: QueryRunner): Promise<void> {
    await runner.query(`CREATE EXTENSION IF NOT EXISTS postgis`);
    await runner.query(
      `CREATE TYPE user_role AS ENUM ('Ciudadano', 'Albergue')`,
    );
    await runner.query(`CREATE TABLE users (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      name varchar(100) NOT NULL,
      email varchar(254) NOT NULL UNIQUE CHECK (email = lower(trim(email))),
      password_hash varchar NOT NULL,
      role user_role NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await runner.query(`CREATE TABLE reports (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id uuid NOT NULL REFERENCES users(id),
      species varchar NOT NULL CHECK (species IN ('canine', 'feline')),
      description text NOT NULL,
      urgency varchar NOT NULL CHECK (urgency IN ('low', 'medium', 'high')),
      status varchar NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'resolved')),
      location geography(Point,4326) NOT NULL,
      photo_url text,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await runner.query(
      `CREATE INDEX reports_location_idx ON reports USING gist(location)`,
    );
    await runner.query(`CREATE TABLE shelters (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id uuid NOT NULL UNIQUE REFERENCES users(id),
      name varchar NOT NULL,
      address text NOT NULL,
      location geography(Point,4326) NOT NULL
    )`);
  }

  async down(runner: QueryRunner): Promise<void> {
    await runner.query('DROP TABLE shelters');
    await runner.query('DROP TABLE reports');
    await runner.query('DROP TABLE users');
    await runner.query('DROP TYPE user_role');
  }
}
