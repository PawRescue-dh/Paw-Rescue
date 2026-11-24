import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

export const PET_STATUS = {
  Available: 'Disponible',
  Reserved: 'Reservada',
  Adopted: 'Adoptada',
} as const;

@Entity('pets')
export class Pet {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 60 })
  name: string;

  @Column({ type: 'varchar', length: 20 })
  species: string; // Perro, Gato, Otro

  @Column({ type: 'varchar', length: 40 })
  age: string; // "2 años"

  @Column({ type: 'varchar', length: 20 })
  sex: string; // Macho, Hembra

  @Column({ type: 'varchar', length: 20 })
  size: string; // Pequeño, Mediano, Grande

  @Column('text')
  description: string;

  /** Estado de salud: "Sano y vacunado", "En recuperación"... */
  @Column({ type: 'varchar', length: 120 })
  health: string;

  @Column({ type: 'text', nullable: true })
  photoBase64: string | null;

  @Column({ type: 'uuid', nullable: true })
  shelterId: string | null;

  @Column({ type: 'varchar', length: 100 })
  shelterName: string;

  @Column({ type: 'varchar', length: 30 })
  shelterPhone: string;

  /** Disponible | Reservada (alguien la eligió) | Adoptada */
  @Column({ type: 'varchar', length: 20, default: PET_STATUS.Available })
  status: string;

  @Column({ type: 'uuid', nullable: true })
  adopterId: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true })
  adopterName: string | null;

  @Column({ type: 'varchar', length: 30, nullable: true })
  adopterPhone: string | null;

  @Column({ type: 'varchar', length: 254, nullable: true })
  adopterEmail: string | null;

  @Column({ type: 'timestamp', nullable: true })
  adoptedAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;
}
