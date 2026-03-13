const express = require('express');
const router = express.Router();
const db = require('../database');

const VALID_REPORT_TYPES = ['wrong_pronunciation', 'wrong_translation', 'wrong_image', 'other'];

// POST /api/reports - submit report
router.post('/', (req, res) => {
  try {
    const { concept_id, report_type } = req.body;

    if (!concept_id || !report_type) {
      return res.status(400).json({ error: 'concept_id and report_type are required' });
    }

    if (!VALID_REPORT_TYPES.includes(report_type)) {
      return res.status(400).json({
        error: `report_type must be one of: ${VALID_REPORT_TYPES.join(', ')}`,
      });
    }

    // Validate concept exists
    const concept = db.prepare('SELECT id FROM concepts WHERE id = ?').get(concept_id);
    if (!concept) {
      return res.status(404).json({ error: 'Concept not found' });
    }

    const result = db
      .prepare(
        `INSERT INTO reports (concept_id, report_type, created_at)
         VALUES (?, ?, datetime('now'))`
      )
      .run(concept_id, report_type);

    const report = db
      .prepare('SELECT * FROM reports WHERE id = ?')
      .get(result.lastInsertRowid);

    res.status(201).json(report);
  } catch (err) {
    console.error('Error creating report:', err.message);
    res.status(500).json({ error: 'Failed to create report' });
  }
});

module.exports = router;
