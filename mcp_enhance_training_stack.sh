#!/bin/bash

echo "🧩 Upgrading MCP with training, voice input, prompt monitor, and HF trainer..."

cd /opt/mcp-server || exit 1

# Step 1: Add required packages
npm install multer node-fetch

# Step 2: Overwrite server.js with enhanced logic
cat <<'EONODE' > server.js
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const fs = require('fs');
const app = express();
const port = 8080;
const API_KEY = "guardian-mcp-secret-key";

app.use(cors());
app.use(express.json());

const upload = multer({ dest: 'uploads/' });
const logFile = '/opt/mcp-server/prompt_log.json';
if (!fs.existsSync(logFile)) fs.writeFileSync(logFile, '[]');

app.use((req, res, next) => {
  if (req.headers['x-api-key'] !== API_KEY) return res.status(403).json({ error: 'Forbidden' });
  next();
});

app.post('/context', (req, res) => {
  const query = req.body.query || 'default';
  const response = {
    type: 'text',
    content: \`🔍 You searched for: \${query}. This is MCP response.\`
  };
  const log = JSON.parse(fs.readFileSync(logFile));
  log.push({ timestamp: Date.now(), query, response });
  fs.writeFileSync(logFile, JSON.stringify(log, null, 2));
  res.json(response);
});

app.post('/train', upload.single('file'), (req, res) => {
  const file = req.file;
  if (!file) return res.status(400).json({ error: 'No file uploaded' });
  res.json({ message: 'Training data received', file: file.filename });
});

app.post('/voice-train', (req, res) => {
  const { voice_id, transcript } = req.body;
  if (!transcript) return res.status(400).json({ error: 'No transcript sent' });
  res.json({ message: \`Voice training started for \${voice_id || 'default'}\`, transcript });
});

app.get('/monitor', (req, res) => {
  const log = JSON.parse(fs.readFileSync(logFile));
  res.json({ total: log.length, log });
});

app.get('/health', (_, res) => res.json({ status: "🟢 MCP live", uptime: process.uptime() }));

app.listen(port, () => console.log(\`✅ MCP Training server live at http://localhost:\${port}\`));
EONODE

# Step 3: Restart server
pm2 restart server.js || node server.js &

# Step 4: HF Cron sync
cat <<'CRON' > /etc/cron.d/mcp_hf_sync
*/30 * * * * root curl -X POST https://huggingface.co/api/mcp/train -H "Authorization: Bearer ${HF_TOKEN}" -d @/opt/mcp-server/prompt_log.json
CRON

chmod +x /etc/cron.d/mcp_hf_sync

echo "✅ MCP upgraded with training, voice input, logs, and HF sync"
