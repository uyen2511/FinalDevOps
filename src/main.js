require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const os = require('os');
const productRoutes = require('./routes/productRoutes');
const dataSource = require('./services/dataSource');
const uiRoutes = require('./routes/uiRoutes');
const path = require('path');
const fs = require('fs');

// ADD: Prometheus
const client = require('prom-client');

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ================= PROMETHEUS =================
client.collectDefaultMetrics({ prefix: 'app_' });

// ================= VIEW + STATIC =================
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');
app.use(express.static(path.join(__dirname, 'public')));

// ================= ROUTES =================
app.use('/', uiRoutes);
app.use('/products', productRoutes);

//  ADD: API test endpoint (dùng cho demo + frontend nếu cần)
app.get('/api', (req, res) => {
  res.json({
    message: 'App running!',
    version: process.env.APP_VERSION || 'v1.0.0',
    pod: os.hostname()
  });
});

//  ADD: HEALTH CHECK (K8s bắt buộc)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    uptime: process.uptime()
  });
});

//  ADD: METRICS (Prometheus scrape)
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

const PORT = process.env.PORT || 3000;

async function start() {
  // Tạo folder uploads
  const uploadsDir = path.join(__dirname, 'public', 'uploads');
  if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
    console.log(`Created uploads directory at ${uploadsDir}`);
  }

  // MongoDB connect
  const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/products_db';
  let usingMongo = false;

  try {
    await mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 3000
    });
    usingMongo = true;
    console.log('Connected to MongoDB');
  } catch (err) {
    usingMongo = false;
    console.log('MongoDB failed → fallback in-memory');
  }

  await dataSource.init(usingMongo);

  app.listen(PORT, () => {
    console.log(`Running at http://localhost:${PORT}`);
    console.log(`Pod: ${os.hostname()}`);
    console.log(`Data source: ${dataSource.isMongo ? 'mongodb' : 'memory'}`);
  });
}

start();

module.exports = app;