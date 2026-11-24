import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { ActivityModule } from '../activity/activity.module';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';
import { Report } from './report.entity';
import { ReportComment } from './report-comment.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Report, ReportComment]), AuthModule, ActivityModule],
  controllers: [ReportsController],
  providers: [ReportsService],
})
export class ReportsModule {}
