import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('report_comments')
export class ReportComment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  reportId: string;

  @Column({ type: 'varchar', length: 100 })
  authorName: string;

  @Column({ type: 'varchar', length: 20 })
  authorRole: string;

  @Column('text')
  text: string;

  @CreateDateColumn()
  createdAt: Date;
}
