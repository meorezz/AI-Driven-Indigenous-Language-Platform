const Database = require('better-sqlite3');
const path = require('path');
const fs = require('fs');

const dataDir = path.join(__dirname, '..', 'data');
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
}

const dbPath = path.join(dataDir, 'app.db');
const db = new Database(dbPath);

// Enable WAL mode for better concurrent read performance
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

function initialize() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS regions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      map_coordinates TEXT
    );

    CREATE TABLE IF NOT EXISTS languages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      region_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      native_name TEXT,
      speaker_count INTEGER DEFAULT 0,
      status TEXT DEFAULT 'active',
      FOREIGN KEY (region_id) REFERENCES regions(id)
    );

    CREATE TABLE IF NOT EXISTS categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon TEXT,
      description TEXT
    );

    CREATE TABLE IF NOT EXISTS concepts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER NOT NULL,
      language_id INTEGER NOT NULL,
      word TEXT NOT NULL,
      translation TEXT NOT NULL,
      pronunciation_guide TEXT,
      audio_url TEXT,
      image_url TEXT,
      FOREIGN KEY (category_id) REFERENCES categories(id),
      FOREIGN KEY (language_id) REFERENCES languages(id)
    );

    CREATE TABLE IF NOT EXISTS contributions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      language_id INTEGER NOT NULL,
      concept_id INTEGER,
      contributor_type TEXT NOT NULL,
      audio_url TEXT,
      word TEXT,
      translation TEXT,
      status TEXT DEFAULT 'pending',
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (language_id) REFERENCES languages(id),
      FOREIGN KEY (concept_id) REFERENCES concepts(id)
    );

    CREATE TABLE IF NOT EXISTS reports (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      concept_id INTEGER NOT NULL,
      report_type TEXT NOT NULL,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (concept_id) REFERENCES concepts(id)
    );

    CREATE TABLE IF NOT EXISTS user_progress (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      concept_id INTEGER NOT NULL,
      score INTEGER DEFAULT 0,
      attempts INTEGER DEFAULT 0,
      last_practiced TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (concept_id) REFERENCES concepts(id)
    );
  `);
}

initialize();

module.exports = db;
