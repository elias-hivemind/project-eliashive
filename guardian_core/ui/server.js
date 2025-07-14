const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send(\`
    <h2>🧠 Claude/Grok/Gemini UI active</h2>
    <pre>\${JSON.stringify({
      claude: process.env.CLAUDE_API_KEY?.slice(0, 8),
      grok: process.env.GROK_API_KEY?.slice(0, 8),
      gemini: process.env.GEMINI_API_KEY?.slice(0, 8),
      openai: process.env.OPENAI_API_KEY?.slice(0, 8)
    }, null, 2)}</pre>
  \`)
})

app.listen(port, () => console.log("[🧠 Claude UI live on port", port, "]"))
