#!/usr/bin/env node
/**
 * Upload artworks.json to Cloud Firestore via REST API.
 * Uses document ID = artwork.id (e.g. "local_001")
 *
 * Usage: node scripts/upload_to_firestore.js
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

const PROJECT_ID = 'renaart-ded29';
const COLLECTION = 'artworks';

// Get access token from Firebase CLI config
function getToken() {
  const configPath = path.join(
    process.env.HOME || process.env.USERPROFILE,
    '.config', 'configstore', 'firebase-tools.json'
  );
  const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
  return config.tokens.access_token;
}

// Convert JS value to Firestore Value format
function toFirestoreValue(val) {
  if (val === null || val === undefined) return { nullValue: null };
  if (typeof val === 'boolean') return { booleanValue: val };
  if (typeof val === 'number') {
    return Number.isInteger(val)
      ? { integerValue: val.toString() }
      : { doubleValue: val };
  }
  if (typeof val === 'string') return { stringValue: val };
  if (Array.isArray(val)) {
    return { arrayValue: { values: val.map(toFirestoreValue) } };
  }
  if (typeof val === 'object') {
    const fields = {};
    for (const [k, v] of Object.entries(val)) {
      fields[k] = toFirestoreValue(v);
    }
    return { mapValue: { fields } };
  }
  return { stringValue: String(val) };
}

function toFirestoreDoc(obj) {
  const fields = {};
  for (const [k, v] of Object.entries(obj)) {
    fields[k] = toFirestoreValue(v);
  }
  return { fields };
}

function commitBatch(token, writes) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify({ writes });
    const options = {
      hostname: 'firestore.googleapis.com',
      path: `/v1/projects/${PROJECT_ID}/databases/(default)/documents:commit`,
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    };
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(JSON.parse(data));
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${data}`));
        }
      });
    });
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

async function main() {
  const token = getToken();
  const jsonPath = path.join(__dirname, '..', 'renaart', 'assets', 'data', 'artworks.json');
  const artworks = JSON.parse(fs.readFileSync(jsonPath, 'utf-8'));

  console.log(`Uploading ${artworks.length} artworks to Firestore...`);

  // Firestore commit limit: 500 operations per batch
  const BATCH_SIZE = 200;
  let uploaded = 0;

  for (let i = 0; i < artworks.length; i += BATCH_SIZE) {
    const chunk = artworks.slice(i, i + BATCH_SIZE);
    const writes = chunk.map((artwork) => {
      const docId = artwork.id || `local_${uploaded}`;
      return {
        update: {
          name: `projects/${PROJECT_ID}/databases/(default)/documents/${COLLECTION}/${docId}`,
          ...toFirestoreDoc(artwork),
        },
      };
    });

    await commitBatch(token, writes);
    uploaded += chunk.length;
    console.log(`  Uploaded ${uploaded}/${artworks.length}`);
  }

  console.log(`\nDone! ${uploaded} artworks uploaded to Firestore collection '${COLLECTION}'.`);
}

main().catch(console.error);
