import { Pool } from 'pg';
import 'dotenv/config';

type Corridor = {
  name: string;
  origin: string;
  destination: string;
  start: [number, number]; // [lng, lat]
  end: [number, number]; // [lng, lat]
};

// These are bootstrap corridors for development/testing.
// They are NOT claimed to be verified taxi paths.
// All records are inserted as "unverified".
const corridors: Corridor[] = [
  {
    name: 'Randburg - Sandton',
    origin: 'Randburg',
    destination: 'Sandton',
    start: [27.9948, -26.0936],
    end: [28.0567, -26.1076],
  },
  {
    name: 'Sandton - Alexandra',
    origin: 'Sandton',
    destination: 'Alexandra',
    start: [28.0567, -26.1076],
    end: [28.1039, -26.1047],
  },
  {
    name: 'Alexandra - Johannesburg CBD',
    origin: 'Alexandra',
    destination: 'Johannesburg CBD',
    start: [28.1039, -26.1047],
    end: [28.0473, -26.2041],
  },
  {
    name: 'Alexandra - Randburg',
    origin: 'Alexandra',
    destination: 'Randburg',
    start: [28.1039, -26.1047],
    end: [27.9948, -26.0936],
  },
  {
    name: 'Sandton - Randburg - Fourways',
    origin: 'Sandton',
    destination: 'Fourways',
    start: [28.0567, -26.1076],
    end: [28.0107, -26.0203],
  },
  {
    name: 'Fourways - Diepsloot',
    origin: 'Fourways',
    destination: 'Diepsloot',
    start: [28.0107, -26.0203],
    end: [27.9148, -25.9361],
  },
  {
    name: 'Randburg - Diepsloot',
    origin: 'Randburg',
    destination: 'Diepsloot',
    start: [27.9948, -26.0936],
    end: [27.9148, -25.9361],
  },
  {
    name: 'Johannesburg CBD - Soweto',
    origin: 'Johannesburg CBD',
    destination: 'Soweto',
    start: [28.0473, -26.2041],
    end: [27.8587, -26.2485],
  },
  {
    name: 'Soweto - Roodepoort',
    origin: 'Soweto',
    destination: 'Roodepoort',
    start: [27.8587, -26.2485],
    end: [27.8988, -26.1625],
  },
  {
    name: 'Soweto - Sandton',
    origin: 'Soweto',
    destination: 'Sandton',
    start: [27.8587, -26.2485],
    end: [28.0567, -26.1076],
  },
  {
    name: 'Johannesburg CBD - Bruma',
    origin: 'Johannesburg CBD',
    destination: 'Bruma',
    start: [28.0473, -26.2041],
    end: [28.104, -26.1882],
  },
  {
    name: 'Johannesburg CBD - Eastgate',
    origin: 'Johannesburg CBD',
    destination: 'Eastgate',
    start: [28.0473, -26.2041],
    end: [28.1176, -26.183],
  },
  {
    name: 'Johannesburg CBD - Wynberg',
    origin: 'Johannesburg CBD',
    destination: 'Wynberg',
    start: [28.0473, -26.2041],
    end: [28.0869, -26.0959],
  },
  {
    name: 'Wynberg - Sandton',
    origin: 'Wynberg',
    destination: 'Sandton',
    start: [28.0869, -26.0959],
    end: [28.0567, -26.1076],
  },
  {
    name: 'Johannesburg CBD - Rosebank',
    origin: 'Johannesburg CBD',
    destination: 'Rosebank',
    start: [28.0473, -26.2041],
    end: [28.0377, -26.1467],
  },
  {
    name: 'Rosebank - Sandton',
    origin: 'Rosebank',
    destination: 'Sandton',
    start: [28.0377, -26.1467],
    end: [28.0567, -26.1076],
  },
  {
    name: 'Johannesburg CBD - Midrand',
    origin: 'Johannesburg CBD',
    destination: 'Midrand',
    start: [28.0473, -26.2041],
    end: [28.1263, -25.9895],
  },
  {
    name: 'Alexandra - Midrand',
    origin: 'Alexandra',
    destination: 'Midrand',
    start: [28.1039, -26.1047],
    end: [28.1263, -25.9895],
  },
  {
    name: 'Alexandra - Edenvale',
    origin: 'Alexandra',
    destination: 'Edenvale',
    start: [28.1039, -26.1047],
    end: [28.1528, -26.1406],
  },
  {
    name: 'Sandton - Sunninghill',
    origin: 'Sandton',
    destination: 'Sunninghill',
    start: [28.0567, -26.1076],
    end: [28.0592, -26.0347],
  },
];

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

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

  if (!data.routes?.[0]?.geometry) {
    throw new Error('OSRM returned no route geometry');
  }

  return data.routes[0].geometry;
}

async function main() {
  for (const corridor of corridors) {
    try {
      const geometry = await getRouteGeometry(corridor.start, corridor.end);

      await pool.query(
        `
        INSERT INTO taxi_routes
          ( name, origin, destination, geometry, status, created_at, updated_at)
        VALUES
          ($1, $2, $3,  ST_SetSRID(ST_GeomFromGeoJSON($4), 4326), 'unverified', NOW(), NOW())
        ON CONFLICT (id) DO UPDATE SET
          name = EXCLUDED.name,
          origin = EXCLUDED.origin,
          destination = EXCLUDED.destination,
          geometry = EXCLUDED.geometry,
          status = 'unverified',
          updated_at = NOW()
        `,
        [
          corridor.name,
          corridor.origin,
          corridor.destination,
          JSON.stringify(geometry),
        ],
      );

      console.log(`Seeded: ${corridor.name}`);
    } catch (error) {
      console.error(`Failed: ${corridor.name}`, error);
    }
  }

  await pool.end();
}

main().catch(async (error) => {
  console.error(error);
  await pool.end();
  process.exit(1);
});
