const express = require('express');
const fs = require('fs-extra');
const app = express();
const port = 5051;

app.use(express.static('public'));

app.get('/data', async (_, res) => {
  try {
    const log = await fs.readJson('/opt/mcp-server/prompt_log.json');
    const stats = log.map(entry => ({
      t: new Date(entry.timestamp).toLocaleString(),
      q: entry.query,
    }));
    res.json(stats);
  } catch (e) {
    res.status(500).json({ error: 'Failed to load logs' });
  }
});

app.listen(port, () => console.log(`📈 Claude Dashboard live at http://localhost:${port}`));
