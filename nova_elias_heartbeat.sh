#!/bin/bash
# Simple heartbeat ping from Nova to Elias every hour

while true; do
    curl -X POST http://localhost:5050/nova_to_elias -H "Content-Type: application/json" -d '{"ping": "alive", "timestamp": "'$(date)'"}' >> ~/eliashive_repo/logs/heartbeat.log 2>&1
    sleep 3600  # Send heartbeat every hour
done
