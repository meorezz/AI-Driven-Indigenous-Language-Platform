const express = require('express');
const router = express.Router();
const db = require('../database');

// POST /api/contributions - submit contribution
router.post('/', (req, res) => {
  try {
    const { language_id, concept_id, contributor_type, word, translation, audio_url } = req.body;

    if (!language_id || !contributor_type) {
      return res
        .status(400)
        .json({ error: 'language_id and contributor_type are required' });
    }

    // Validate language exists
    const language = db.prepare('SELECT id FROM languages WHERE id = ?').get(language_id);
    if (!language) {
      return res.status(404).json({ error: 'Language not found' });
    }

    // Validate concept if provided
    if (concept_id) {
      const concept = db.prepare('SELECT id FROM concepts WHERE id = ?').get(concept_id);
      if (!concept) {
        return res.status(404).json({ error: 'Concept not found' });
      }
    }

    const result = db
      .prepare(
        `INSERT INTO contributions (language_id, concept_id, contributor_type, word, translation, audio_url, status, created_at)
         VALUES (?, ?, ?, ?, ?, ?, 'pending', datetime('now'))`
      )
      .run(
        language_id,
        concept_id || null,
        contributor_type,
        word || null,
        translation || null,
        audio_url || null
      );

    const contribution = db
      .prepare('SELECT * FROM contributions WHERE id = ?')
      .get(result.lastInsertRowid);

    res.status(201).json(contribution);
  } catch (err) {
    console.error('Error creating contribution:', err.message);
    res.status(500).json({ error: 'Failed to create contribution' });
  }
});

// GET /api/contributions?language_id=X - list contributions
router.get('/', (req, res) => {
  try {
    const { language_id } = req.query;
    let contributions;

    if (language_id) {
      contributions = db
        .prepare('SELECT * FROM contributions WHERE language_id = ? ORDER BY created_at DESC')
        .all(language_id);
    } else {
      contributions = db
        .prepare('SELECT * FROM contributions ORDER BY created_at DESC')
        .all();
    }

    res.json(contributions);
  } catch (err) {
    console.error('Error fetching contributions:', err.message);
    res.status(500).json({ error: 'Failed to fetch contributions' });
  }
});

module.exports = router;
