const express = require('express');
const router = express.Router();
const db = require('../database');

// GET /api/regions - list all regions
router.get('/', (req, res) => {
  try {
    const regions = db.prepare('SELECT * FROM regions').all();
    const parsed = regions.map((r) => ({
      ...r,
      map_coordinates: r.map_coordinates ? JSON.parse(r.map_coordinates) : null,
    }));
    res.json(parsed);
  } catch (err) {
    console.error('Error fetching regions:', err.message);
    res.status(500).json({ error: 'Failed to fetch regions' });
  }
});

// GET /api/regions/:id - get region with its languages
router.get('/:id', (req, res) => {
  try {
    const region = db.prepare('SELECT * FROM regions WHERE id = ?').get(req.params.id);
    if (!region) {
      return res.status(404).json({ error: 'Region not found' });
    }

    region.map_coordinates = region.map_coordinates
      ? JSON.parse(region.map_coordinates)
      : null;

    const languages = db
      .prepare('SELECT * FROM languages WHERE region_id = ?')
      .all(req.params.id);

    res.json({ ...region, languages });
  } catch (err) {
    console.error('Error fetching region:', err.message);
    res.status(500).json({ error: 'Failed to fetch region' });
  }
});

module.exports = router;
