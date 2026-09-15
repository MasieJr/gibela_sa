import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { DatabaseModule } from './database/database.module';
import { RoutesModule } from './routes/routes.module';
import { WalkingModule } from './walking/walking.module';
import { PlacesModule } from './places/places.module';
import { JourneysModule } from './journeys/journeys.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    DatabaseModule,
    RoutesModule,
    // WalkingModule,
    PlacesModule,
    JourneysModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
