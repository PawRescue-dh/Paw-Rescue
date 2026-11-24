import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('adoption_requests')
export class AdoptionRequest {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  petId: string;

  @Column({ type: 'uuid' })
  citizenId: string;

  @Column({ type: 'varchar', length: 100 })
  citizenName: string;

  @Column({ type: 'varchar', length: 254 })
  citizenEmail: string;

  @Column({ type: 'varchar', length: 30 })
  citizenPhone: string;

  @Column({ type: 'text', nullable: true })
  message: string | null;

  /** Pendiente | Aprobada | Rechazada */
  @Column({ type: 'varchar', length: 20, default: 'Pendiente' })
  status: string;

  @CreateDateColumn()
  createdAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  decidedAt: Date | null;
}
