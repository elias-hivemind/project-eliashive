#!/bin/bash

echo "[0] DEPLOYING ELIASNORTH.COM STATIC SITE TO GOOGLE CLOUD..."

# === CONFIG ===
PROJECT_ID="thinking-digit-449116-n0"
BUCKET_NAME="eliasnorth-static-site"
REGION="us-east1"
INDEX_FILE="/tmp/eliasnorth_index.html"
KEY_PATH="/home/ec2-user/credentials/nova_gemini_service_account.json"

# === STEP 1: Auth ===
echo "[1] Authenticating..."
export GOOGLE_APPLICATION_CREDENTIALS="$KEY_PATH"
gcloud auth activate-service-account --key-file="$KEY_PATH"

# === STEP 2: Set Project ===
echo "[2] Setting project..."
gcloud config set project "$PROJECT_ID"

# === STEP 3: Create GCS Bucket ===
echo "[3] Creating bucket..."
gsutil mb -p "$PROJECT_ID" -c standard -l "$REGION" "gs://$BUCKET_NAME/" || echo "[!] Bucket may already exist, skipping..."

# === STEP 4: Generate Homepage ===
echo "[4] Writing homepage..."
cat << HTML > "$INDEX_FILE"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Elias North AI Services</title>
  <style>
    body { background: #1a2526; color: white; font-family: sans-serif; text-align: center; margin: 0; }
    .navbar { background: #2c3e50; padding: 10px 0; }
    .navbar a { color: #e74c3c; margin: 0 15px; text-decoration: none; }
    .content { padding: 50px; }
    .content h1 { font-size: 48px; }
    .content p { font-size: 24px; }
    .content button { background: #c0392b; color: white; border: none; padding: 10px 20px; font-size: 18px; cursor: pointer; }
  </style>
</head>
<body>
  <div class="navbar">
    <a href="#">Home</a><a href="#">Builder</a><a href="#">Videos</a><a href="#">Services</a>
    <a href="#">About</a><a href="#">Contact</a><a href="#">Admin</a>
  </div>
  <div class="content">
    <h1>Launch YOUR Brand WITH AI</h1>
    <p>Websites, videos, social — all automated.</p>
    <button>Try the Builder</button>
  </div>
</body>
</html>
HTML

# === STEP 5: Upload File ===
echo "[5] Uploading homepage..."
gsutil cp "$INDEX_FILE" "gs://$BUCKET_NAME/index.html"

# === STEP 6: Enable Web Hosting ===
echo "[6] Configuring web hosting..."
gsutil web set -m index.html "gs://$BUCKET_NAME"

# === STEP 7: Make Public ===
echo "[7] Making public..."
gsutil iam ch allUsers:objectViewer "gs://$BUCKET_NAME"

# === DONE ===
echo "[DONE] Website is now LIVE:"
echo "https://storage.googleapis.com/$BUCKET_NAME/index.html"
