#!/bin/bash

echo "[0] EliasHive GitHub Sync — Nova Sentinel Integration Activated"

# === CONFIG ===
GITHUB_USER="elias-hivemind"
REPO_NAME="project-eliashive"
GITHUB_URL="https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git"
LOCAL_REPO_DIR="$HOME/eliashive_repo"
COMMIT_MESSAGE="Auto-sync: $(date +'%Y-%m-%d %H:%M:%S')"
SENTINEL_LOG="$HOME/nova_guardian.log"
TOKEN_FILE="$HOME/credentials/github_personal_token.txt"

# === STEP 1: READ TOKEN ===
if [ ! -f "$TOKEN_FILE" ]; then
    echo "[ERROR] GitHub token not found at $TOKEN_FILE"
    exit 1
fi
GITHUB_TOKEN=$(cat $TOKEN_FILE)

# === STEP 2: SETUP LOCAL GIT ===
echo "[1] Preparing local Git workspace..."
mkdir -p $LOCAL_REPO_DIR
cd $LOCAL_REPO_DIR

if [ ! -d ".git" ]; then
    echo "[1a] Initializing Git repository..."
    git init
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
    git branch -M main
fi

# === STEP 3: COPY PROJECT FILES (adjust paths as needed) ===
echo "[2] Copying Elias files into repo..."
rsync -av --exclude=".git" --exclude="__pycache__" ~/ai_website_builder.py $LOCAL_REPO_DIR/
rsync -av --exclude=".git" --exclude="__pycache__" ~/deploy_elias*.sh $LOCAL_REPO_DIR/

# === STEP 4: COMMIT & PUSH ===
echo "[3] Committing and pushing to GitHub..."
git add .
git commit -m "$COMMIT_MESSAGE" || echo "[INFO] Nothing new to commit."
git push -u origin main || echo "[ERROR] Push failed. Please verify authentication."

echo "[DONE] GitHub sync complete."
