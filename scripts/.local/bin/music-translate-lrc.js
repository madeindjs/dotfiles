#!/usr/bin/env node
/**
 * translate-lrc.js
 *
 * Translates .lrc lyrics files to French using Ollama Cloud.
 * For each $file.lrc in the target directory:
 *   - skip if $file.fr.lrc already exists
 *   - skip if the lyrics are already detected to be in French
 *   - delete $file.lrc if no matching music file exists (unless it is French)
 *   - otherwise translate and write $file.fr.lrc
 *
 * Usage:
 *   OLLAMA_API_KEY=xxx node translate-lrc.js /path/to/music
 *
 * No external dependencies: only Node.js built-in fetch and fs.
 */

const fs = require("fs");
const path = require("path");

const HOST = process.env.OLLAMA_HOST || "https://ollama.com";
const API_KEY = process.env.OLLAMA_API_KEY;
const MODEL = process.env.OLLAMA_MODEL || "ministral-3:14b";
const CONCURRENCY = parseInt(process.env.OLLAMA_CONCURRENCY || "4", 10);

const MUSIC_EXTENSIONS = [".flac", ".mp3", ".m4a", ".aac", ".ogg", ".wav", ".wma", ".opus"];

// French words that strongly indicate the lyrics are already in French.
// Includes common articles, pronouns, prepositions, conjunctions, auxiliaries,
// and high-frequency adverbs/content words. Words are stored without accents so
// the detector works on both ASCII and accented input.
const FRENCH_INDICATORS = new Set([
  "ai", "ailleurs", "ainsi", "alors", "apres", "aucun", "aucune", "aussi",
  "autant", "autour", "autre", "autres", "aux", "avant", "avec", "beaucoup",
  "bien", "bon", "bonne", "car", "ce", "cela", "ces", "cet", "cette",
  "ceux", "chaque", "chez", "comme", "contre", "dans", "de", "deja",
  "depuis", "des", "donc", "du", "elle", "elles", "en", "encore", "enfin",
  "entre", "es", "est", "et", "ete", "eux", "faire", "fait", "faut", "fois",
  "grace", "heure", "homme", "ici", "il", "ils", "jamais", "je", "jour",
  "juste", "la", "laquelle", "le", "lequel", "les", "leur", "leurs", "lui",
  "ma", "main", "maintenant", "mais", "mal", "maniere", "me", "meme", "mes",
  "mien", "mienne", "miennes", "miens", "moins", "mon", "mot", "moi",
  "mort", "ne", "noir", "nom", "non", "nos", "notre", "nous", "nouveau",
  "nouvelle", "nuit", "on", "ont", "ou", "par", "parce", "pas", "peu",
  "peut", "peux", "plus", "plutot", "pour", "pourquoi", "premier", "pres",
  "presque", "puis", "quand", "que", "quel", "quelle", "quelles", "quels",
  "qui", "quoi", "rien", "sa", "sans", "se", "ses", "si", "sien", "soi",
  "soit", "son", "sont", "sous", "souvent", "suis", "sur", "ta", "tandis",
  "tant", "te", "tel", "telle", "telles", "tels", "temps", "tes", "toi",
  "ton", "toujours", "tous", "tout", "toute", "toutes", "tres", "trois",
  "tu", "un", "une", "va", "vai", "vais", "vas", "vers", "vie", "voici",
  "voila", "voir", "vont", "vos", "votre", "vous", "vu", "yeux",
]);

// English function words used to avoid false positives on English lyrics that
// happen to contain a couple of French-sounding words.
const ENGLISH_INDICATORS = new Set([
  "a", "an", "and", "are", "as", "at", "be", "been", "being", "but", "by",
  "can", "could", "did", "do", "does", "doing", "done", "for", "from",
  "had", "has", "have", "he", "her", "here", "him", "his", "how", "i", "if",
  "in", "is", "it", "its", "may", "might", "must", "my", "no", "not", "of",
  "on", "one", "or", "our", "out", "shall", "she", "should", "so", "some",
  "such", "than", "that", "the", "their", "them", "then", "there", "these",
  "they", "this", "those", "to", "too", "up", "us", "was", "we", "were",
  "what", "when", "where", "which", "while", "who", "whom", "whose", "why",
  "will", "with", "would", "you", "your",
]);

function extractWords(text) {
  // Remove LRC timestamps and metadata tags, then split into lowercase words.
  return text
    .replace(/\[.*?\]/g, " ")
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .split(/[^a-z0-9']+/)
    .map((w) => w.replace(/^'+|'+(?=s?$)/g, ""))
    .filter((w) => w.length > 1);
}

function isFrench(text) {
  const words = extractWords(text);
  if (words.length === 0) return false;

  let french = 0;
  let english = 0;
  for (const word of words) {
    if (FRENCH_INDICATORS.has(word)) french++;
    if (ENGLISH_INDICATORS.has(word)) english++;
  }

  // Heuristic: enough French indicators, very few English indicators, and a
  // reasonable share of the lyric words are French indicators.
  return french >= 3 && english <= 1 && french / words.length >= 0.15;
}

const SYSTEM_PROMPT = `You are a lyrics translator specialized in adapting song lyrics to French while strictly preserving the LRC timestamped format.

Rules:
1. Every input line starts with an LRC timestamp like [mm:ss.xx]. Keep these timestamps exactly as they appear, in the same order, on the same lines.
2. Preserve all blank lines, instrumental markers (♪, ♫, etc.), and any non-lyric symbols exactly where they are.
3. Translate only the sung text into natural, singable French. Match the original syllable count and line length as closely as possible so the French version can be sung to the same melody.
4. Do not add extra comments, headers, explanations, or markdown formatting.
5. Do not merge or split timestamped lines.
6. If a line is empty after the timestamp, leave it empty.
7. Return ONLY the translated LRC content, nothing else.

Input format example:
[00:12.34] Original line
[00:15.67] Another line

Expected output format:
[00:12.34] Ligne originale
[00:15.67] Une autre ligne`;

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function translateLrc(text) {
  const url = `${HOST.replace(/\/$/, "")}/v1/chat/completions`;
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${API_KEY}`,
    },
    body: JSON.stringify({
      model: MODEL,
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: text },
      ],
      temperature: 0.3,
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(
      `Ollama API error: ${response.status} ${response.statusText}\n${body}`
    );
  }

  const data = await response.json();
  const content = data.choices?.[0]?.message?.content;
  if (!content) {
    throw new Error(`Unexpected API response: ${JSON.stringify(data)}`);
  }

  return content.trim();
}

async function* walk(dir) {
  const entries = await fs.promises.readdir(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      yield* walk(fullPath);
    } else if (entry.isFile()) {
      yield { dir, filename: entry.name, fullPath };
    }
  }
}

async function* collectTranslateTasks(dir) {
  for await (const { dir: fileDir, filename, fullPath: basePath } of walk(dir)) {
    if (!filename.endsWith(".lrc")) continue;
    // Skip already-French LRC files
    if (filename.endsWith(".fr.lrc")) continue;

    const baseName = filename.slice(0, -4); // strip trailing .lrc
    const frenchPath = path.join(fileDir, `${baseName}.fr.lrc`);
    const relativePath = path.relative(dir, basePath);

    // Already translated -> skip
    try {
      await fs.promises.access(frenchPath);
      console.log(`[SKIP] ${relativePath}: ${baseName}.fr.lrc already exists`);
      continue;
    } catch {
      // french file does not exist; proceed
    }

    // Read the original lyrics once for language detection and (if needed) translation
    let originalText;
    try {
      originalText = await fs.promises.readFile(basePath, "utf-8");
    } catch (err) {
      console.error(`[ERROR] ${relativePath}: failed to read file: ${err.message}`);
      continue;
    }

    // If the lyrics are already French, leave the file untouched
    if (isFrench(originalText)) {
      console.log(`[SKIP] ${relativePath}: lyrics already in French`);
      continue;
    }

    // Find matching music file
    let musicPath = null;
    for (const ext of MUSIC_EXTENSIONS) {
      const candidate = path.join(fileDir, `${baseName}${ext}`);
      try {
        await fs.promises.access(candidate);
        musicPath = candidate;
        break;
      } catch {
        // keep looking
      }
    }

    if (!musicPath) {
      console.log(`[DELETE] ${relativePath}: no matching music file found`);
      try {
        await fs.promises.unlink(basePath);
        console.log(`         removed ${relativePath}`);
      } catch (err) {
        console.error(`         failed to remove ${relativePath}: ${err.message}`);
      }
      continue;
    }

    yield { fileDir, baseName, frenchPath, relativePath, originalText };
  }
}

async function runWithConcurrency(tasks, concurrency) {
  const pending = [...tasks];
  const running = new Set();

  while (pending.length > 0 || running.size > 0) {
    while (running.size < concurrency && pending.length > 0) {
      const task = pending.shift();
      const promise = task()
        .catch((err) => console.error(`[ERROR] unexpected task failure: ${err.message}`))
        .finally(() => running.delete(promise));
      running.add(promise);
    }

    if (running.size > 0) {
      await Promise.race(running);
    }
  }
}

async function processDirectory(dir) {
  const tasks = [];
  for await (const task of collectTranslateTasks(dir)) {
    tasks.push(task);
  }

  const translateJobs = tasks.map(
    ({ fileDir, baseName, frenchPath, relativePath, originalText }) =>
      async () => {
        const targetRelative = path.relative(dir, frenchPath);
        console.log(`[TRANSLATE] ${relativePath} -> ${baseName}.fr.lrc`);
        try {
          const translated = await translateLrc(originalText);
          await fs.promises.writeFile(frenchPath, translated, "utf-8");
          console.log(`            wrote ${targetRelative}`);
        } catch (err) {
          console.error(`            failed: ${err.message}`);
        }
      }
  );

  await runWithConcurrency(translateJobs, CONCURRENCY);
}

(async () => {
  const targetDir = process.argv[2] || ".";
  const resolvedDir = path.resolve(targetDir);

  if (!API_KEY) {
    console.error("Error: OLLAMA_API_KEY environment variable is required.");
    process.exit(1);
  }

  try {
    await fs.promises.access(resolvedDir);
  } catch {
    console.error(`Error: directory not found: ${resolvedDir}`);
    process.exit(1);
  }

  console.log(`Processing directory: ${resolvedDir}`);
  console.log(`Ollama host: ${HOST}`);
  console.log(`Model: ${MODEL}\n`);

  await processDirectory(resolvedDir);

  console.log("\nDone.");
})();
