const express = require('express');
const cors = require('cors');
const app = express();
const port = 8080;

app.use(cors());
app.use(express.json());

app.post('/context', (req, res) => {
  const query = req.body.query || 'default';
  const context = {
    type: 'text',
    content: `🔍 You searched for: ${query}. This is your local MCP server response.`
  };
  res.json(context);
});

app.listen(port, () => console.log(`✅ MCP Server running at http://localhost:${port}/context`));

app.get('/health', (req, res) => {
  res.json({ status: "✅ MCP Server healthy", timestamp: new Date() });
});
