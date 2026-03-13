const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded audio files
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

// Routes
const regionsRouter = require('./routes/regions');
const languagesRouter = require('./routes/languages');
const categoriesRouter = require('./routes/categories');
const conceptsRouter = require('./routes/concepts');
const contributionsRouter = require('./routes/contributions');
const reportsRouter = require('./routes/reports');
const aiRouter = require('./routes/ai');

app.use('/api/regions', regionsRouter);
app.use('/api/languages', languagesRouter);
app.use('/api/categories', categoriesRouter);
app.use('/api/concepts', conceptsRouter);
app.use('/api/contributions', contributionsRouter);
app.use('/api/reports', reportsRouter);
app.use('/api/ai', aiRouter);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err.message);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});

module.exports = app;
