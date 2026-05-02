require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();

// ─── Middleware ───────────────────────────────────────────────────────────────
app.use(cors({ origin: '*' }));           // Open CORS — Flutter + web dashboard
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logger
app.use((req, _res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
  next();
});

// ─── Routes ──────────────────────────────────────────────────────────────────
app.use('/api/auth',       require('./routes/auth'));
app.use('/api/districts',  require('./routes/districts'));
app.use('/api/alerts',     require('./routes/alerts'));
app.use('/api/contract',   require('./routes/contracts'));
app.use('/api/schemes',    require('./routes/schemes'));
app.use('/api/projects',   require('./routes/projects'));
app.use('/api/risk-score', require('./routes/riskScore'));
app.use('/api',            require('./routes/reports'));     // POST /api/report, /api/inspection
app.use('/api/invoice',    require('./routes/invoices'));
app.use('/api/milestone',  require('./routes/milestones'));
app.use('/api/payments',    require('./routes/payments'));
app.use('/api/blockchain',  require('./routes/blockchain'));

// ─── Health check ─────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), service: 'TRACE Backend' });
});

// ─── 404 handler ─────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: `Route not found: ${req.method} ${req.path}` });
});

// ─── Global error handler ─────────────────────────────────────────────────────
app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// ─── Start ────────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`\n🚀 TRACE Backend running on http://localhost:${PORT}`);
  console.log(`📋 Health check: http://localhost:${PORT}/health`);
  console.log(`\nAPI Endpoints:`);
  console.log(`  POST /api/auth/login`);
  console.log(`  GET  /api/districts`);
  console.log(`  GET  /api/alerts`);
  console.log(`  GET  /api/contract/:id`);
  console.log(`  GET  /api/schemes/:districtId`);
  console.log(`  GET  /api/risk-score/:id?type=project|scheme`);
  console.log(`  POST /api/report`);
  console.log(`  POST /api/inspection`);
  console.log(`  POST /api/invoice`);
  console.log(`  POST /api/milestone`);
  console.log(`  GET  /api/payments/:contractId\n`);
});
