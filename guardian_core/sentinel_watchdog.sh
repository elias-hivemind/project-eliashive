#!/bin/bash
while true; do
  docker ps | grep -q guardian-ui || docker compose up -d
  sleep 120
done
