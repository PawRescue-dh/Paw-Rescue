import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

/** Registro de acciones: reportes, adopciones, comentarios, cambios de estado... */
@Entity('activities')
export class Activity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /** reporte | estado | comentario | mascota | adopcion */
  @Column({ type: 'varchar', length: 30 })
  type: string;

  @Column('text')
  message: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  actorName: string | null;

  @Column({ type: 'varchar', length: 20, nullable: true })
  actorRole: string | null;

  @Column({ type: 'varchar', length: 64, nullable: true })
  refId: string | null;

  @CreateDateColumn()
  createdAt: Date;
}
