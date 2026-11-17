import { Controller, Get, Post, Body } from '@nestjs/common';
import { ReportsService } from './reports.service';

@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Post()
  create(@Body() body: any) {
    return this.reportsService.create(body);
  }

  @Get()
  findAll() {
    return this.reportsService.findAll();
  }
}