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

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}