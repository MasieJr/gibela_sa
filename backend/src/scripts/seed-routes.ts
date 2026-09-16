import { Pool } from 'pg';
import 'dotenv/config';

type RouteSeed = {
  name: string;
  originRankId: number;
  destinationRankId: number;
  fare?: number;
};

type TaxiRank = {
  id: number;
  name: string;
  lng: number;
  lat: number;
};

const routes: RouteSeed[] = [
  // Johannesburg CBD (Bree / Noord) <-> Soweto (Bara)
  {
    name: 'Bree to Bara',
    originRankId: 74,
    destinationRankId: 35,
    fare: 22,
  },
  {
    name: 'Bara to Bree',
    originRankId: 35,
    destinationRankId: 74,
    fare: 22,
  },
  {
    name: 'Noord to Bara',
    originRankId: 33,
    destinationRankId: 35,
    fare: 22,
  },
  {
    name: 'Bara to Noord',
    originRankId: 35,
    destinationRankId: 33,
    fare: 22,
  },

  // Johannesburg CBD <-> Randburg
  {
    name: 'Bree to Randburg',
    originRankId: 74,
    destinationRankId: 39,
    fare: 25,
  },
  {
    name: 'Randburg to Bree',
    originRankId: 39,
    destinationRankId: 74,
    fare: 25,
  },
  {
    name: 'Noord to Randburg',
    originRankId: 33,
    destinationRankId: 39,
    fare: 25,
  },
  {
    name: 'Randburg to Noord',
    originRankId: 39,
    destinationRankId: 33,
    fare: 25,
  },

  // Johannesburg CBD <-> Alexandra
  {
    name: 'Noord to Alexandra',
    originRankId: 33,
    destinationRankId: 60,
    fare: 20,
  },
  {
    name: 'Alexandra to Noord',
    originRankId: 60,
    destinationRankId: 33,
    fare: 20,
  },
  {
    name: 'Bree to Alexandra',
    originRankId: 74,
    destinationRankId: 60,
    fare: 20,
  },
  {
    name: 'Alexandra to Bree',
    originRankId: 60,
    destinationRankId: 74,
    fare: 20,
  },

  // Alexandra <-> Sandton
  {
    name: 'Alexandra to Sandton',
    originRankId: 60,
    destinationRankId: 212,
    fare: 16,
  },
  {
    name: 'Sandton to Alexandra',
    originRankId: 212,
    destinationRankId: 60,
    fare: 16,
  },

  // Randburg <-> Sandton
  {
    name: 'Randburg to Sandton',
    originRankId: 39,
    destinationRankId: 212,
    fare: 18,
  },
  {
    name: 'Sandton to Randburg',
    originRankId: 212,
    destinationRankId: 39,
    fare: 18,
  },

  // Johannesburg CBD <-> Germiston
  {
    name: 'Noord to Germiston',
    originRankId: 33,
    destinationRankId: 107,
    fare: 22,
  },
  {
    name: 'Germiston to Noord',
    originRankId: 107,
    destinationRankId: 33,
    fare: 22,
  },

  // Johannesburg CBD <-> Kempton Park
  {
    name: 'Noord to Kempton Park',
    originRankId: 33,
    destinationRankId: 123,
    fare: 28,
  },
  {
    name: 'Kempton Park to Noord',
    originRankId: 123,
    destinationRankId: 33,
    fare: 28,
  },

  // Tembisa <-> Kempton Park
  {
    name: 'Tembisa to Kempton Park',
    originRankId: 236,
    destinationRankId: 123,
    fare: 18,
  },
  {
    name: 'Kempton Park to Tembisa',
    originRankId: 123,
    destinationRankId: 236,
    fare: 18,
  },

  // Tembisa <-> Midrand
  {
    name: 'Tembisa to Midrand',
    originRankId: 236,
    destinationRankId: 149,
    fare: 20,
  },
  {
    name: 'Midrand to Tembisa',
    originRankId: 149,
    destinationRankId: 236,
    fare: 20,
  },

  // Midrand <-> Randburg
  {
    name: 'Midrand to Randburg',
    originRankId: 149,
    destinationRankId: 39,
    fare: 26,
  },
  {
    name: 'Randburg to Midrand',
    originRankId: 39,
    destinationRankId: 149,
    fare: 26,
  },

  // Centurion <-> Pretoria Central
  {
    name: 'Centurion to Pretoria Central',
    originRankId: 78,
    destinationRankId: 172,
    fare: 20,
  },
  {
    name: 'Pretoria Central to Centurion',
    originRankId: 172,
    destinationRankId: 78,
    fare: 20,
  },

  // Rosebank <-> Sandton
  {
    name: 'Rosebank to Sandton',
    originRankId: 7,
    destinationRankId: 212,
    fare: 16,
  },
  {
    name: 'Sandton to Rosebank',
    originRankId: 212,
    destinationRankId: 7,
    fare: 16,
  },

  // Randburg <-> Fourways
  {
    name: 'Randburg to Fourways',
    originRankId: 39,
    destinationRankId: 214,
    fare: 18,
  },
  {
    name: 'Fourways to Randburg',
    originRankId: 214,
    destinationRankId: 39,
    fare: 18,
  },

  // Randburg <-> Cosmo City
  {
    name: 'Randburg to Cosmo City',
    originRankId: 39,
    destinationRankId: 82,
    fare: 17,
  },
  {
    name: 'Cosmo City to Randburg',
    originRankId: 82,
    destinationRankId: 39,
    fare: 17,
  },

  // Fourways <-> Diepsloot
  {
    name: 'Fourways to Diepsloot',
    originRankId: 214,
    destinationRankId: 86,
    fare: 16,
  },
  {
    name: 'Diepsloot to Fourways',
    originRankId: 86,
    destinationRankId: 214,
    fare: 16,
  },

  // Bree <-> Diepsloot
  {
    name: 'Bree to Diepsloot',
    originRankId: 74,
    destinationRankId: 86,
    fare: 30,
  },
  {
    name: 'Diepsloot to Bree',
    originRankId: 86,
    destinationRankId: 74,
    fare: 30,
  },

  // Bree <-> Roodepoort
  {
    name: 'Bree to Roodepoort',
    originRankId: 74,
    destinationRankId: 180,
    fare: 22,
  },
  {
    name: 'Roodepoort to Bree',
    originRankId: 180,
    destinationRankId: 74,
    fare: 22,
  },

  // Roodepoort <-> Krugersdorp
  {
    name: 'Roodepoort to Krugersdorp',
    originRankId: 180,
    destinationRankId: 128,
    fare: 18,
  },
  {
    name: 'Krugersdorp to Roodepoort',
    originRankId: 128,
    destinationRankId: 180,
    fare: 18,
  },

  // Bara <-> Southgate Mall
  {
    name: 'Bara to Southgate',
    originRankId: 35,
    destinationRankId: 218,
    fare: 15,
  },
  {
    name: 'Southgate to Bara',
    originRankId: 218,
    destinationRankId: 35,
    fare: 15,
  },

  // Bree <-> Southgate Mall
  {
    name: 'Bree to Southgate',
    originRankId: 74,
    destinationRankId: 218,
    fare: 18,
  },
  {
    name: 'Southgate to Bree',
    originRankId: 218,
    destinationRankId: 74,
    fare: 18,
  },

  // Bree <-> Lenasia
  {
    name: 'Bree to Lenasia',
    originRankId: 74,
    destinationRankId: 12,
    fare: 28,
  },
  {
    name: 'Lenasia to Bree',
    originRankId: 12,
    destinationRankId: 74,
    fare: 28,
  },

  // Lenasia <-> Trade Route Mall
  {
    name: 'Lenasia to Trade Route Mall',
    originRankId: 12,
    destinationRankId: 238,
    fare: 13,
  },
  {
    name: 'Trade Route Mall to Lenasia',
    originRankId: 238,
    destinationRankId: 12,
    fare: 13,
  },

  // Bree <-> Alberton
  {
    name: 'Bree to Alberton',
    originRankId: 74,
    destinationRankId: 205,
    fare: 20,
  },
  {
    name: 'Alberton to Bree',
    originRankId: 205,
    destinationRankId: 74,
    fare: 20,
  },

  // Germiston <-> Alberton
  {
    name: 'Germiston to Alberton',
    originRankId: 107,
    destinationRankId: 205,
    fare: 15,
  },
  {
    name: 'Alberton to Germiston',
    originRankId: 205,
    destinationRankId: 107,
    fare: 15,
  },

  // Germiston <-> Vosloorus
  {
    name: 'Germiston to Vosloorus',
    originRankId: 107,
    destinationRankId: 13,
    fare: 20,
  },
  {
    name: 'Vosloorus to Germiston',
    originRankId: 13,
    destinationRankId: 107,
    fare: 20,
  },

  // Bree <-> Vosloorus
  {
    name: 'Bree to Vosloorus',
    originRankId: 74,
    destinationRankId: 13,
    fare: 26,
  },
  {
    name: 'Vosloorus to Bree',
    originRankId: 13,
    destinationRankId: 74,
    fare: 26,
  },

  // Germiston <-> Boksburg
  {
    name: 'Germiston to Boksburg',
    originRankId: 107,
    destinationRankId: 68,
    fare: 16,
  },
  {
    name: 'Boksburg to Germiston',
    originRankId: 68,
    destinationRankId: 107,
    fare: 16,
  },

  // Boksburg <-> Benoni
  {
    name: 'Boksburg to Benoni',
    originRankId: 68,
    destinationRankId: 65,
    fare: 16,
  },
  {
    name: 'Benoni to Boksburg',
    originRankId: 65,
    destinationRankId: 68,
    fare: 16,
  },

  // Benoni <-> Daveyton
  {
    name: 'Benoni to Daveyton',
    originRankId: 65,
    destinationRankId: 199,
    fare: 18,
  },
  {
    name: 'Daveyton to Benoni',
    originRankId: 199,
    destinationRankId: 65,
    fare: 18,
  },

  // Benoni <-> Springs
  {
    name: 'Benoni to Springs',
    originRankId: 65,
    destinationRankId: 192,
    fare: 18,
  },
  {
    name: 'Springs to Benoni',
    originRankId: 192,
    destinationRankId: 65,
    fare: 18,
  },

  // Midrand <-> Mall of Africa
  {
    name: 'Midrand to Mall of Africa',
    originRankId: 149,
    destinationRankId: 140,
    fare: 14,
  },
  {
    name: 'Mall of Africa to Midrand',
    originRankId: 140,
    destinationRankId: 149,
    fare: 14,
  },

  // Pretoria Central <-> Menlyn Park
  {
    name: 'Pretoria Central to Menlyn',
    originRankId: 172,
    destinationRankId: 146,
    fare: 18,
  },
  {
    name: 'Menlyn to Pretoria Central',
    originRankId: 146,
    destinationRankId: 172,
    fare: 18,
  },

  // Pretoria Central <-> Mabopane
  {
    name: 'Pretoria Central to Mabopane',
    originRankId: 172,
    destinationRankId: 138,
    fare: 28,
  },
  {
    name: 'Mabopane to Pretoria Central',
    originRankId: 138,
    destinationRankId: 172,
    fare: 28,
  },

  // Pretoria Central <-> Soshanguve
  {
    name: 'Pretoria Central to Soshanguve',
    originRankId: 172,
    destinationRankId: 187,
    fare: 30,
  },
  {
    name: 'Soshanguve to Pretoria Central',
    originRankId: 187,
    destinationRankId: 172,
    fare: 30,
  },

  // Pretoria Central <-> Atteridgeville
  {
    name: 'Pretoria Central to Atteridgeville',
    originRankId: 172,
    destinationRankId: 62,
    fare: 18,
  },
  {
    name: 'Atteridgeville to Pretoria Central',
    originRankId: 62,
    destinationRankId: 172,
    fare: 18,
  },

  // Pretoria Central <-> Mamelodi (Denneboom)
  {
    name: 'Pretoria Central to Denneboom',
    originRankId: 172,
    destinationRankId: 83,
    fare: 20,
  },
  {
    name: 'Denneboom to Pretoria Central',
    originRankId: 83,
    destinationRankId: 172,
    fare: 20,
  },

  // Vereeniging <-> Vanderbijlpark
  {
    name: 'Vereeniging to Vanderbijlpark',
    originRankId: 242,
    destinationRankId: 241,
    fare: 16,
  },
  {
    name: 'Vanderbijlpark to Vereeniging',
    originRankId: 241,
    destinationRankId: 242,
    fare: 16,
  },

  // Vereeniging <-> Evaton
  {
    name: 'Vereeniging to Evaton',
    originRankId: 242,
    destinationRankId: 227,
    fare: 18,
  },
  {
    name: 'Evaton to Vereeniging',
    originRankId: 227,
    destinationRankId: 242,
    fare: 18,
  },
  // Cresta Mall <-> Randburg
  {
    name: 'Randburg to Cresta Mall',
    originRankId: 39,
    destinationRankId: 217,
    fare: 15,
  },
  {
    name: 'Cresta Mall to Randburg',
    originRankId: 217,
    destinationRankId: 39,
    fare: 15,
  },

  // Cresta Mall <-> Bree (Johannesburg CBD)
  {
    name: 'Bree to Cresta Mall',
    originRankId: 74,
    destinationRankId: 217,
    fare: 20,
  },
  {
    name: 'Cresta Mall to Bree',
    originRankId: 217,
    destinationRankId: 74,
    fare: 20,
  },

  // Cresta Mall <-> Noord (Johannesburg CBD)
  {
    name: 'Noord to Cresta Mall',
    originRankId: 33,
    destinationRankId: 217,
    fare: 20,
  },
  {
    name: 'Cresta Mall to Noord',
    originRankId: 217,
    destinationRankId: 33,
    fare: 20,
  },

  // Cresta Mall <-> Rosebank
  {
    name: 'Rosebank to Cresta Mall',
    originRankId: 7,
    destinationRankId: 217,
    fare: 17,
  },
  {
    name: 'Cresta Mall to Rosebank',
    originRankId: 217,
    destinationRankId: 7,
    fare: 17,
  },

  // Cresta Mall <-> Roodepoort
  {
    name: 'Roodepoort to Cresta Mall',
    originRankId: 180,
    destinationRankId: 217,
    fare: 18,
  },
  {
    name: 'Cresta Mall to Roodepoort',
    originRankId: 217,
    destinationRankId: 180,
    fare: 18,
  },

  // Cresta Mall <-> Clearwater Mall
  {
    name: 'Cresta Mall to Clearwater Mall',
    originRankId: 217,
    destinationRankId: 80,
    fare: 16,
  },
  {
    name: 'Clearwater Mall to Cresta Mall',
    originRankId: 80,
    destinationRankId: 217,
    fare: 16,
  },

  // Cresta Mall <-> Cosmo City
  {
    name: 'Cosmo City to Cresta Mall',
    originRankId: 82,
    destinationRankId: 217,
    fare: 18,
  },
  {
    name: 'Cresta Mall to Cosmo City',
    originRankId: 217,
    destinationRankId: 82,
    fare: 18,
  },
];

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

/**
 * Get the actual taxi rank and its PostGIS coordinates.
 */
async function getTaxiRank(rankId: number): Promise<TaxiRank> {
  const result = await pool.query(
    `
    SELECT
      id,
      name,
      ST_X(location) AS lng,
      ST_Y(location) AS lat
    FROM public.taxi_ranks
    WHERE id = $1
    `,
    [rankId],
  );

  if (result.rows.length === 0) {
    throw new Error(`Taxi rank ${rankId} not found`);
  }

  const row = result.rows[0];

  if (row.lng == null || row.lat == null) {
    throw new Error(`Taxi rank ${rankId} (${row.name}) has no location`);
  }

  return {
    id: Number(row.id),
    name: row.name,
    lng: Number(row.lng),
    lat: Number(row.lat),
  };
}

/**
 * Ask OSRM to generate the road geometry between the two ranks.
 */
async function getRouteGeometry(
  start: [number, number],
  end: [number, number],
) {
  const url =
    `https://router.project-osrm.org/route/v1/driving/` +
    `${start[0]},${start[1]};${end[0]},${end[1]}` +
    `?geometries=geojson&overview=full`;

  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(`OSRM returned ${response.status}`);
  }

  const data = await response.json();

  const route = data.routes?.[0];

  if (!route?.geometry) {
    throw new Error('OSRM returned no route geometry');
  }

  return route.geometry;
}

async function seedRoute(route: RouteSeed) {
  // 1. Get actual rank locations
  const origin = await getTaxiRank(route.originRankId);
  const destination = await getTaxiRank(route.destinationRankId);

  console.log(
    `\n${route.name}`,
    `\n  ${origin.name}`,
    `\n  -> ${destination.name}`,
  );

  const start: [number, number] = [origin.lng, origin.lat];

  const end: [number, number] = [destination.lng, destination.lat];

  // 2. Generate LineString using rank coordinates
  const geometry = await getRouteGeometry(start, end);

  /*
   * OSRM snaps coordinates to nearby routable roads.
   *
   * Force the LineString endpoints to the exact taxi-rank
   * coordinates so the line visually touches the rank markers.
   */
  geometry.coordinates[0] = start;
  geometry.coordinates[geometry.coordinates.length - 1] = end;

  // 3. Insert/update route
  await pool.query(
    `
    INSERT INTO public.routes (
      name,
      origin_rank_id,
      destination_rank_id,
      geometry,
      fare,
      verified,
      created_at,
      updated_at
    )
    VALUES (
      $1,
      $2,
      $3,
      ST_SetSRID(
        ST_GeomFromGeoJSON($4),
        4326
      ),
      $5,
      false,
      NOW(),
      NOW()
    )

    ON CONFLICT (
      origin_rank_id,
      destination_rank_id
    )

    DO UPDATE SET
      name = EXCLUDED.name,
      geometry = EXCLUDED.geometry,
      fare = EXCLUDED.fare,
      verified = false,
      updated_at = NOW()
    `,
    [
      route.name,
      route.originRankId,
      route.destinationRankId,
      JSON.stringify(geometry),
      route.fare ?? null,
    ],
  );

  console.log(`  ✓ Seeded`);
}

async function main() {
  console.log(`Seeding ${routes.length} routes...`);

  for (const route of routes) {
    try {
      await seedRoute(route);

      // Be polite to the public OSRM server
      await new Promise((resolve) => setTimeout(resolve, 300));
    } catch (error) {
      console.error(`  ✗ Failed ${route.name}:`, error);
    }
  }

  console.log('\nFinished.');
}

main()
  .catch((error) => {
    console.error('Fatal error:', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await pool.end();
  });
