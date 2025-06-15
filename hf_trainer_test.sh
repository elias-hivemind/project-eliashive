#!/bin/bash
echo "🎯 Starting Hugging Face test trainer..."
curl -X POST https://huggingface.co/api/mcp/train \
  -H "Authorization: Bearer ${HF_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @/opt/mcp-server/prompt_log.json
