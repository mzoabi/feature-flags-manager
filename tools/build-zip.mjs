// Builds the publishable extension ZIP into dist/feature-flags-manager.zip.
// The ZIP contains only the runtime files, with manifest.json at the root,
// so it can be uploaded directly to the Chrome Web Store or Microsoft Edge Add-ons.
//
// Usage: npm run build
import { createWriteStream, existsSync, mkdirSync, rmSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import archiver from 'archiver';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const distDir = join(root, 'dist');
const outFile = join(distDir, 'feature-flags-manager.zip');
const sourceDir = process.argv[2] || 'src';

// Runtime files/folders that make up the published extension.
const FILES = ['manifest.json', `${sourceDir}/popup.html`, `${sourceDir}/popup.css`, `${sourceDir}/popup.js`];
const DIRS = [`${sourceDir}/icons`];

for (const entry of [...FILES, ...DIRS]) {
  if (!existsSync(join(root, entry))) {
    console.error(`Missing required path: ${entry}`);
    process.exit(1);
  }
}

mkdirSync(distDir, { recursive: true });
if (existsSync(outFile)) rmSync(outFile);

const output = createWriteStream(outFile);
const archive = archiver('zip', { zlib: { level: 9 } });

output.on('close', () => {
  const kb = (archive.pointer() / 1024).toFixed(1);
  console.log(`Built ${outFile} (${kb} KB)`);
});
archive.on('warning', (err) => {
  throw err;
});
archive.on('error', (err) => {
  throw err;
});

archive.pipe(output);
for (const file of FILES) archive.file(join(root, file), { name: file });
for (const dir of DIRS) archive.directory(join(root, dir), dir.replace(`${sourceDir}/`, ''));
await archive.finalize();
