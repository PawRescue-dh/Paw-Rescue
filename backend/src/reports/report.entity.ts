import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('reports')
export class Report {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  species: string; // Perro, Gato, Otro

  @Column()
  urgency: string; // Baja, Media, Alta, Crítica

  @Column('text')
  description: string;

  @Column('double precision')
  latitude: number;

  @Column('double precision')
  longitude: number;

  @Column({
    type: 'geometry',
    spatialFeatureType: 'Point',
    srid: 4326,
    nullable: true,
  })
  location: any;

  @Column({ type: 'text', nullable: true })
  photoBase64: string;

  @Column({ default: 'Pendiente' })
  status: string;

  /** Ciudadano que creó el reporte. */
  @Column({ type: 'uuid', nullable: true })
  reporterId: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true })
  reporterName: string | null;

  @CreateDateColumn()
  createdAt: Date;
}
