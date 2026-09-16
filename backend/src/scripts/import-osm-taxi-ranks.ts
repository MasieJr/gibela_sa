import 'dotenv/config';
import { Pool } from 'pg';

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL is not defined');
}

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const OVERPASS_SERVERS = [
  'https://overpass.kumi.systems/api/interpreter',
  'https://overpass-api.de/api/interpreter',
];

/**
 * Rough Johannesburg bounding box:
 *
 * south, west, north, east
 *
 * This intentionally covers a little more than the City of Johannesburg
 * so we can inspect the data first and filter later.
 */
const SOUTH = -26.35;
const WEST = 27.7;
const NORTH = -25.85;
const EAST = 28.35;

const query = `
[out:json][timeout:90];

(
  node["amenity"="taxi"](${SOUTH},${WEST},${NORTH},${EAST});
  way["amenity"="taxi"](${SOUTH},${WEST},${NORTH},${EAST});
  relation["amenity"="taxi"](${SOUTH},${WEST},${NORTH},${EAST});
);

out center tags;
`;

interface OverpassElement {
  type: 'node' | 'way' | 'relation';
  id: number;

  lat?: number;
  lon?: number;

  center?: {
    lat: number;
    lon: number;
  };

  tags?: {
    name?: string;
    operator?: string;
    description?: string;
    capacity?: string;
    suburb?: string;
    taxi?: string;
    'taxi:type'?: string;
    'addr:suburb'?: string;
    'addr:city'?: string;
    'addr:street'?: string;
    [key: string]: string | undefined;
  };
}

interface OverpassResponse {
  elements: OverpassElement[];
}

function getCoordinates(element: OverpassElement) {
  const latitude = element.lat ?? element.center?.lat;
  const longitude = element.lon ?? element.center?.lon;

  if (latitude === undefined || longitude === undefined) {
    return null;
  }

  return {
    latitude,
    longitude,
  };
}

function getRankName(element: OverpassElement) {
  const tags = element.tags ?? {};

  return tags.name ?? tags.operator ?? `Unnamed Taxi Rank ${element.id}`;
}

function buildDescription(element: OverpassElement) {
  const tags = element.tags ?? {};

  const parts: string[] = [];

  if (tags.description) {
    parts.push(tags.description);
  }

  if (tags['addr:street']) {
    parts.push(tags['addr:street']);
  }

  const suburb = tags['addr:suburb'] ?? tags.suburb;

  if (suburb) {
    parts.push(suburb);
  }

  if (tags.operator) {
    parts.push(`Operator: ${tags.operator}`);
  }

  if (tags.capacity) {
    parts.push(`Capacity: ${tags.capacity}`);
  }

  return parts.length > 0 ? parts.join(' · ') : null;
}

async function ensureDatabaseStructure() {
  console.log('Checking taxi_ranks table structure...');

  await pool.query(`
    ALTER TABLE taxi_ranks
    ADD COLUMN IF NOT EXISTS source VARCHAR(50);
  `);

  await pool.query(`
    ALTER TABLE taxi_ranks
    ADD COLUMN IF NOT EXISTS source_id VARCHAR(100);
  `);

  await pool.query(`
    ALTER TABLE taxi_ranks
    ADD COLUMN IF NOT EXISTS osm_type VARCHAR(20);
  `);

  await pool.query(`
    ALTER TABLE taxi_ranks
    ADD COLUMN IF NOT EXISTS verified BOOLEAN DEFAULT FALSE;
  `);

  await pool.query(`
    CREATE UNIQUE INDEX IF NOT EXISTS taxi_ranks_source_source_id_unique
    ON taxi_ranks(source, source_id)
    WHERE source_id IS NOT NULL;
  `);

  console.log('Database structure ready.');
}

async function fetchFromServer(
  server: string,
): Promise<OverpassResponse | null> {
  console.log(`Trying Overpass server: ${server}`);

  const controller = new AbortController();

  const timeout = setTimeout(() => {
    controller.abort();
  }, 75_000);

  try {
    const response = await fetch(server, {
      method: 'POST',

      headers: {
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',

        Accept: 'application/json',

        'User-Agent': 'GibelaSA/1.0',
      },

      body: `data=${encodeURIComponent(query)}`,

      signal: controller.signal,
    });

    if (!response.ok) {
      const body = await response.text();

      console.warn(
        `Overpass server returned ${response.status} ${response.statusText}`,
      );

      console.warn(body.substring(0, 500));

      return null;
    }

    const data = (await response.json()) as OverpassResponse;

    console.log(`Successfully fetched data from ${server}`);

    return data;
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      console.warn(`Request timed out for ${server}`);

      return null;
    }

    console.warn(`Failed to contact ${server}`);

    console.warn(error);

    return null;
  } finally {
    clearTimeout(timeout);
  }
}

async function fetchOverpassData() {
  for (const server of OVERPASS_SERVERS) {
    const result = await fetchFromServer(server);

    if (result) {
      return result;
    }
  }

  throw new Error('All Overpass servers failed.');
}

async function saveTaxiRank(element: OverpassElement) {
  const coordinates = getCoordinates(element);

  if (!coordinates) {
    console.warn(`Skipping ${element.type}/${element.id}: no coordinates`);

    return false;
  }

  const { latitude, longitude } = coordinates;

  const name = getRankName(element);

  const description = buildDescription(element);

  const sourceId = `${element.type}/${element.id}`;

  await pool.query(
    `
    INSERT INTO taxi_ranks (
      name,
      location,
      description,
      source,
      source_id,
      osm_type,
      verified
    )

    VALUES (
      $1,

      ST_SetSRID(
        ST_MakePoint(
          $2,
          $3
        ),
        4326
      ),

      $4,
      'OSM',
      $5,
      $6,
      FALSE
    )

    ON CONFLICT (
      source,
      source_id
    )

    WHERE source_id IS NOT NULL

    DO UPDATE SET

      name =
        EXCLUDED.name,

      location =
        EXCLUDED.location,

      description =
        EXCLUDED.description,

      osm_type =
        EXCLUDED.osm_type;
    `,
    [name, longitude, latitude, description, sourceId, element.type],
  );

  console.log(`✓ ${name} (${latitude}, ${longitude})`);

  return true;
}

async function main() {
  console.log('');
  console.log('====================================');

  console.log('GibelaSA OSM Taxi Rank Import');

  console.log('====================================');

  console.log('');

  try {
    await ensureDatabaseStructure();

    console.log('');

    console.log('Fetching Johannesburg taxi ranks from OpenStreetMap...');

    console.log(`Bounding box: ${SOUTH}, ${WEST}, ${NORTH}, ${EAST}`);

    console.log('');

    const data = await fetchOverpassData();

    const elements = data.elements ?? [];

    console.log('');

    console.log(`Found ${elements.length} taxi rank features.`);

    console.log('');

    let imported = 0;
    let skipped = 0;
    let failed = 0;

    for (const element of elements) {
      try {
        const success = await saveTaxiRank(element);

        if (success) {
          imported++;
        } else {
          skipped++;
        }
      } catch (error) {
        failed++;

        console.error(`✗ Failed to import ${element.type}/${element.id}`);

        if (error instanceof Error) {
          console.error(error.message);
        } else {
          console.error(error);
        }
      }
    }

    console.log('');

    console.log('====================================');

    console.log('Import completed');

    console.log('====================================');

    console.log(`Total OSM features: ${elements.length}`);

    console.log(`Imported / updated: ${imported}`);

    console.log(`Skipped: ${skipped}`);

    console.log(`Failed: ${failed}`);

    console.log('');
  } finally {
    await pool.end();
  }
}

main().catch((error) => {
  console.error('');

  console.error('====================================');

  console.error('Import failed');

  console.error('====================================');

  console.error(error);

  process.exitCode = 1;
});
