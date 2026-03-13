const express = require('express');
const router = express.Router();
const db = require('../database');

// GET /api/languages - list all (with optional ?region_id filter)
router.get('/', (req, res) => {
  try {
    const { region_id } = req.query;
    let languages;

    if (region_id) {
      languages = db
        .prepare('SELECT * FROM languages WHERE region_id = ?')
        .all(region_id);
    } else {
      languages = db.prepare('SELECT * FROM languages').all();
    }

    res.json(languages);
  } catch (err) {
    console.error('Error fetching languages:', err.message);
    res.status(500).json({ error: 'Failed to fetch languages' });
  }
});

// GET /api/languages/:id - get language with categories that have concepts
router.get('/:id', (req, res) => {
  try {
    const language = db
      .prepare('SELECT * FROM languages WHERE id = ?')
      .get(req.params.id);

    if (!language) {
      return res.status(404).json({ error: 'Language not found' });
    }

    // Get categories that have concepts for this language
    const categories = db
      .prepare(
        `SELECT DISTINCT c.* FROM categories c
         INNER JOIN concepts co ON co.category_id = c.id
         WHERE co.language_id = ?`
      )
      .all(req.params.id);

    // For each category, include concept count
    const categoriesWithCount = categories.map((cat) => {
      const count = db
        .prepare(
          'SELECT COUNT(*) as count FROM concepts WHERE category_id = ? AND language_id = ?'
        )
        .get(cat.id, req.params.id);
      return { ...cat, concept_count: count.count };
    });

    res.json({ ...language, categories: categoriesWithCount });
  } catch (err) {
    console.error('Error fetching language:', err.message);
    res.status(500).json({ error: 'Failed to fetch language' });
  }
});

module.exports = router;
