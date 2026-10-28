import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { databaseOptions } from './database/data-source';


@Module({
  imports: [
    // Esto le dice a NestJS que cargue el archivo .env y esté disponible en toda la app
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({ useFactory: databaseOptions }),

  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
