const express = require('express');
const router = express.Router();
const db = require('../database');

// POST /api/ai/pronunciation-check - mock AI pronunciation checking
router.post('/pronunciation-check', (req, res) => {
  try {
    const { audio_data, concept_id } = req.body;

    if (!audio_data || !concept_id) {
      return res
        .status(400)
        .json({ error: 'audio_data and concept_id are required' });
    }

    const concept = db.prepare('SELECT * FROM concepts WHERE id = ?').get(concept_id);
    if (!concept) {
      return res.status(404).json({ error: 'Concept not found' });
    }

    // Generate a mock score with realistic distribution
    const score = generateMockScore();
    const feedback = generateFeedback(score, concept);
    const phonetic_tips = generatePhoneticTips(score, concept);

    res.json({
      score,
      feedback,
      phonetic_tips,
    });
  } catch (err) {
    console.error('Error in pronunciation check:', err.message);
    res.status(500).json({ error: 'Failed to process pronunciation check' });
  }
});

// POST /api/ai/analyze-contributions - mock AI analysis
router.post('/analyze-contributions', (req, res) => {
  try {
    const contributions = db
      .prepare(
        "SELECT c.*, l.name as language_name FROM contributions c JOIN languages l ON c.language_id = l.id WHERE c.status = 'pending' ORDER BY c.created_at DESC LIMIT 50"
      )
      .all();

    // Group contributions by similar words
    const wordGroups = {};
    contributions.forEach((c) => {
      const key = (c.word || 'unknown').toLowerCase();
      if (!wordGroups[key]) {
        wordGroups[key] = [];
      }
      wordGroups[key].push(c);
    });

    const grouped_pronunciations = Object.entries(wordGroups).map(
      ([word, items]) => ({
        word,
        count: items.length,
        language: items[0].language_name,
        contributions: items.map((i) => ({
          id: i.id,
          contributor_type: i.contributor_type,
          audio_url: i.audio_url,
        })),
      })
    );

    // Mock anomalies
    const anomalies = contributions
      .filter(() => Math.random() < 0.1)
      .map((c) => ({
        contribution_id: c.id,
        reason: pickRandom([
          'Audio quality below threshold',
          'Translation does not match known references',
          'Possible duplicate entry',
          'Pronunciation significantly differs from other samples',
        ]),
        confidence: Math.round(Math.random() * 40 + 60),
      }));

    // Mock flagged for review
    const flagged_for_review = contributions
      .filter(() => Math.random() < 0.15)
      .map((c) => ({
        contribution_id: c.id,
        word: c.word,
        language: c.language_name,
        flag_reason: pickRandom([
          'New word not in existing database',
          'Multiple conflicting translations submitted',
          'Contributor marked as first-time',
          'Regional dialect variation detected',
        ]),
      }));

    res.json({
      grouped_pronunciations,
      anomalies,
      flagged_for_review,
    });
  } catch (err) {
    console.error('Error analyzing contributions:', err.message);
    res.status(500).json({ error: 'Failed to analyze contributions' });
  }
});

// --- Helper functions ---

function generateMockScore() {
  // Weighted distribution: most scores between 50-90
  const rand = Math.random();
  if (rand < 0.1) return Math.round(Math.random() * 30 + 10); // 10-40 (poor)
  if (rand < 0.3) return Math.round(Math.random() * 20 + 40); // 40-60 (fair)
  if (rand < 0.7) return Math.round(Math.random() * 20 + 60); // 60-80 (good)
  return Math.round(Math.random() * 20 + 80); // 80-100 (excellent)
}

function generateFeedback(score, concept) {
  if (score >= 85) {
    return `Excellent pronunciation of "${concept.word}"! Your intonation and vowel sounds are very close to native speakers.`;
  }
  if (score >= 70) {
    return `Good attempt at "${concept.word}". Your pronunciation is understandable but could use some refinement on specific syllables.`;
  }
  if (score >= 50) {
    return `Fair pronunciation of "${concept.word}". Focus on the pronunciation guide: "${concept.pronunciation_guide}". Try to match the syllable stress more closely.`;
  }
  return `Keep practicing "${concept.word}". Review the pronunciation guide "${concept.pronunciation_guide}" and try speaking more slowly, focusing on each syllable.`;
}

function generatePhoneticTips(score, concept) {
  const tips = [];
  const guide = concept.pronunciation_guide || '';

  if (score < 85) {
    tips.push(`Break the word into syllables: "${guide}"`);
  }
  if (score < 70) {
    tips.push('Try speaking more slowly and emphasize each vowel sound');
    tips.push(`Listen to the reference audio for "${concept.word}" and repeat`);
  }
  if (score < 50) {
    tips.push('Start by practicing individual syllables before the full word');
    tips.push('Record yourself and compare with the reference pronunciation');
    tips.push('Pay attention to the stress pattern in the word');
  }

  if (tips.length === 0) {
    tips.push('Your pronunciation is very accurate. Keep practicing to maintain fluency!');
  }

  return tips;
}

function pickRandom(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

module.exports = router;
