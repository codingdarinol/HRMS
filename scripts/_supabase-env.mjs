import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, '..');

loadEnvFile(path.join(repoRoot, '.env.local'));
loadEnvFile(path.join(repoRoot, '.env'));

function loadEnvFile(filePath) {
  if (!fs.existsSync(filePath)) {
    return;
  }

  const content = fs.readFileSync(filePath, 'utf8');
  for (const rawLine of content.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) {
      continue;
    }

    const separatorIndex = line.indexOf('=');
    if (separatorIndex === -1) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    if (!key || process.env[key]) {
      continue;
    }

    let value = line.slice(separatorIndex + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }

    process.env[key] = value;
  }
}

function requireEnv(name, aliases = []) {
  const value = [name, ...aliases]
    .map((key) => process.env[key])
    .find(Boolean);

  if (!value) {
    throw new Error(
      `Missing ${name}. Set it in the shell or add it to .env.local/.env.`
    );
  }

  return value;
}

export const SUPABASE_URL = requireEnv('NEXT_PUBLIC_SUPABASE_URL');
export const SUPABASE_PUBLISHABLE_KEY = requireEnv(
  'NEXT_PUBLIC_SUPABASE_ANON_KEY',
  ['SUPABASE_ANON_KEY']
);
export const SUPABASE_SECRET_KEY = requireEnv(
  'SUPABASE_SERVICE_ROLE_KEY',
  ['SUPABASE_SECRET_KEY']
);
