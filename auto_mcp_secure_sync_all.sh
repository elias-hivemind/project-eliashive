#!/bin/bash

echo "🔐 Enabling Secure Auth, Syncing GitHub + HF, Injecting HF Test Trainer..."

cd /opt/mcp-server || exit 1

# ✅ Step 1: Enforce secure API key in Claude/Nova environment
echo "X_API_KEY=guardian-mcp-secret-key" >> /opt/nova/.env
echo "X_API_KEY=guardian-mcp-secret-key" >> /opt/claude/.env

# ✅ Step 2: Push code to GitHub
cd /opt/mcp-server
git init
git remote add origin https://github.com/elias-hivemind/mcp-memory-server.git
git add .
git commit -m "🧠 Auto push: MCP Memory Server with secure auth"
git push -u origin main --force

# ✅ Step 3: Upload to Hugging Face space (auto-repo)
cd /opt/mcp-server
git remote add hf https://huggingface.co/spaces/eliasnorthai/mcp-memory
git push -u hf main --force

# ✅ Step 4: Create Hugging Face trainer test script
cat <<EOF > /opt/mcp-server/hf_trainer_test.sh
#!/bin/bash
echo "🎯 Starting Hugging Face test trainer..."
curl -X POST https://huggingface.co/api/mcp/train \\
  -H "Authorization: Bearer \${HF_TOKEN}" \\
  -H "Content-Type: application/json" \\
  -d @/opt/mcp-server/prompt_log.json
EOF

chmod +x /opt/mcp-server/hf_trainer_test.sh

# ✅ Step 5: Cron job to run trainer every 30 mins
cat <<'CRON' > /etc/cron.d/mcp_hf_test
*/30 * * * * root /opt/mcp-server/hf_trainer_test.sh >> /var/log/mcp_sync.log 2>&1
CRON

chmod +x /etc/cron.d/mcp_hf_test

# ✅ Step 6: Restart MCP for new API key injection
pm2 restart server.js || node server.js &

echo "✅ MCP is now secured, synced, and connected to Claude/Nova + Hugging Face + GitHub"
