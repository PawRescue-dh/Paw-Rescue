import { IsIn } from 'class-validator';

export const REPORT_STATUSES = ['Pendiente', 'En atención', 'Resuelto'] as const;

export class UpdateStatusDto {
  @IsIn(REPORT_STATUSES)
  status: (typeof REPORT_STATUSES)[number];
}
