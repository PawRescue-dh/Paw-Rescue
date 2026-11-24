import { Module, OnModuleInit } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { ActivityModule } from '../activity/activity.module';
import { Pet } from './pet.entity';
import { AdoptionRequest } from './adoption-request.entity';
import { PetsService } from './pets.service';
import { PetsController } from './pets.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Pet, AdoptionRequest]), AuthModule, ActivityModule],
  controllers: [PetsController],
  providers: [PetsService],
})
export class PetsModule implements OnModuleInit {
  constructor(private readonly pets: PetsService) {}

  async onModuleInit() {
    if (process.env.SEED_DEMO_DATA === 'true') {
      await this.pets.seedDemo();
    }
  }
}
