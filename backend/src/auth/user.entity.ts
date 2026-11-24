import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100 })
  name: string;

  @Column({ length: 254, unique: true })
  email: string;

  @Column({ name: 'password_hash' })
  passwordHash: string;

  @Column({ type: 'enum', enum: ['Ciudadano', 'Albergue'] })
  role: 'Ciudadano' | 'Albergue';

  @Column({ type: 'varchar', length: 30, nullable: true })
  phone: string | null;

  @Column({ name: 'privacy_accepted_at', type: 'timestamp', nullable: true })
  privacyAcceptedAt: Date | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
