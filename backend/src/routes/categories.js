const express = require('express');
const router = express.Router();
const db = require('../database');

// GET /api/categories - list all categories
router.get('/', (req, res) => {
  try {
    const categories = db.prepare('SELECT * FROM categories').all();
    res.json(categories);
  } catch (err) {
    console.error('Error fetching categories:', err.message);
    res.status(500).json({ error: 'Failed to fetch categories' });
  }
});

// GET /api/categories/:id/concepts?language_id=X - get concepts for category + language
router.get('/:id/concepts', (req, res) => {
  try {
    const { language_id } = req.query;

    if (!language_id) {
      return res.status(400).json({ error: 'language_id query parameter is required' });
    }

    const category = db.prepare('SELECT * FROM categories WHERE id = ?').get(req.params.id);
    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }

    const concepts = db
      .prepare(
        'SELECT * FROM concepts WHERE category_id = ? AND language_id = ?'
      )
      .all(req.params.id, language_id);

    res.json({ ...category, concepts });
  } catch (err) {
    console.error('Error fetching category concepts:', err.message);
    res.status(500).json({ error: 'Failed to fetch category concepts' });
  }
});

module.exports = router;
