import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

export enum UserRole {
  Citizen = 'Ciudadano',
  Shelter = 'Albergue',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ length: 100 }) name: string;
  @Column({ unique: true, length: 254 }) email: string;
  @Column({ name: 'password_hash', select: false }) passwordHash: string;
  @Column({ type: 'enum', enum: UserRole, enumName: 'user_role' })
  role: UserRole;
  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;
}

@Entity('reports')
export class Report {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'user_id', type: 'uuid' }) userId: string;
  @Column() species: string;
  @Column({ type: 'text' }) description: string;
  @Column() urgency: string;
  @Column({ default: 'active' }) status: string;
  @Column({ type: 'geography', spatialFeatureType: 'Point', srid: 4326 })
  location: { type: 'Point'; coordinates: [number, number] };
  @Column({ name: 'photo_url', type: 'text', nullable: true }) photoUrl:
    string | null;
  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;
}

@Entity('shelters')
export class Shelter {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'user_id', type: 'uuid', unique: true }) userId: string;
  @Column() name: string;
  @Column({ type: 'text' }) address: string;
  @Column({ type: 'geography', spatialFeatureType: 'Point', srid: 4326 })
  location: { type: 'Point'; coordinates: [number, number] };
}
