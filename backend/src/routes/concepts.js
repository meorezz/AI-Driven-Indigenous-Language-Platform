const express = require('express');
const router = express.Router();
const db = require('../database');

// GET /api/concepts?language_id=X&category_id=Y - list concepts with filters
router.get('/', (req, res) => {
  try {
    const { language_id, category_id } = req.query;
    let query = 'SELECT * FROM concepts WHERE 1=1';
    const params = [];

    if (language_id) {
      query += ' AND language_id = ?';
      params.push(language_id);
    }

    if (category_id) {
      query += ' AND category_id = ?';
      params.push(category_id);
    }

    const concepts = db.prepare(query).all(...params);
    res.json(concepts);
  } catch (err) {
    console.error('Error fetching concepts:', err.message);
    res.status(500).json({ error: 'Failed to fetch concepts' });
  }
});

// GET /api/concepts/:id - get single concept
router.get('/:id', (req, res) => {
  try {
    const concept = db.prepare('SELECT * FROM concepts WHERE id = ?').get(req.params.id);

    if (!concept) {
      return res.status(404).json({ error: 'Concept not found' });
    }

    // Include related language and category info
    const language = db
      .prepare('SELECT id, name, native_name FROM languages WHERE id = ?')
      .get(concept.language_id);
    const category = db
      .prepare('SELECT id, name, icon FROM categories WHERE id = ?')
      .get(concept.category_id);

    res.json({ ...concept, language, category });
  } catch (err) {
    console.error('Error fetching concept:', err.message);
    res.status(500).json({ error: 'Failed to fetch concept' });
  }
});

// POST /api/concepts/:id/progress - save user progress
router.post('/:id/progress', (req, res) => {
  try {
    const { user_id, score, attempts } = req.body;

    if (!user_id || score === undefined) {
      return res.status(400).json({ error: 'user_id and score are required' });
    }

    const concept = db.prepare('SELECT id FROM concepts WHERE id = ?').get(req.params.id);
    if (!concept) {
      return res.status(404).json({ error: 'Concept not found' });
    }

    // Upsert progress
    const existing = db
      .prepare('SELECT * FROM user_progress WHERE user_id = ? AND concept_id = ?')
      .get(user_id, req.params.id);

    if (existing) {
      db.prepare(
        `UPDATE user_progress
         SET score = ?, attempts = ?, last_practiced = datetime('now')
         WHERE user_id = ? AND concept_id = ?`
      ).run(score, attempts || existing.attempts + 1, user_id, req.params.id);
    } else {
      db.prepare(
        `INSERT INTO user_progress (user_id, concept_id, score, attempts, last_practiced)
         VALUES (?, ?, ?, ?, datetime('now'))`
      ).run(user_id, req.params.id, score, attempts || 1);
    }

    const progress = db
      .prepare('SELECT * FROM user_progress WHERE user_id = ? AND concept_id = ?')
      .get(user_id, req.params.id);

    res.json(progress);
  } catch (err) {
    console.error('Error saving progress:', err.message);
    res.status(500).json({ error: 'Failed to save progress' });
  }
});

module.exports = router;
