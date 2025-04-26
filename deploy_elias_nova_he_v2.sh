#!/bin/bash

echo "[0] NOVA,HE — FULL Flask Self-Healing + Load Balancer Auto Diagnostic — FIXED VERSION"

# === CONFIG ===
DOMAIN="eliasnorth.com"
PROJECT_ID="mirrorone-456514"
LOAD_BALANCER_IP="35.190.126.179"
BACKEND_SERVICE_NAME="eliasnorth-backend"
SSL_CERT_NAME="eliasnorth-ssl"
FLASK_APP_PATH="/home/ec2-user/ai_website_builder.py"
INSTANCE_NAME="elias-north"
ZONE="us-central1-a"

# === STEP 1: DNS CHECK ===
echo "[1] Checking DNS propagation..."
DNS_IP=$(dig +short $DOMAIN)

if [[ "$DNS_IP" == "$LOAD_BALANCER_IP" ]]; then
    echo "[PASS] DNS A record matches Load Balancer IP ($LOAD_BALANCER_IP)"
else
    echo "[FAIL] DNS mismatch! Expected $LOAD_BALANCER_IP but got $DNS_IP"
fi

# === STEP 2: BACKEND HEALTH CHECK ===
echo "[2] Checking Load Balancer backend health..."
LB_STATUS=$(gcloud compute backend-services get-health $BACKEND_SERVICE_NAME --global --project=$PROJECT_ID --format="value(status.healthStatus[0].healthState)")

if [[ "$LB_STATUS" == "HEALTHY" ]]; then
    echo "[PASS] Backend is HEALTHY"
else
    echo "[WARN] Backend is $LB_STATUS — attempting automatic recovery..."

    echo "[2a] Restarting Flask app without log file (silent mode)..."
    pkill -f ai_website_builder.py || true
    nohup python3 $FLASK_APP_PATH >/dev/null 2>&1 &
    sleep 10

    echo "[2b] Retesting backend health..."
    LB_STATUS=$(gcloud compute backend-services get-health $BACKEND_SERVICE_NAME --global --project=$PROJECT_ID --format="value(status.healthStatus[0].healthState)")
    if [[ "$LB_STATUS" == "HEALTHY" ]]; then
        echo "[PASS] Backend recovered successfully!"
    else
        echo "[FAIL] Backend still UNHEALTHY after fix attempt."
    fi
fi

# === STEP 3: SSL STATUS CHECK ===
echo "[3] Checking SSL certificate status..."
SSL_STATUS=$(gcloud compute ssl-certificates describe $SSL_CERT_NAME --global --project=$PROJECT_ID --format="value(managed.status)")

if [[ "$SSL_STATUS" == "ACTIVE" ]]; then
    echo "[PASS] SSL certificate is ACTIVE"
else
    echo "[INFO] SSL cert is still provisioning or errored ($SSL_STATUS)"
fi

# === STEP 4: FINAL WEBSITE TESTS ===
echo "[4] Testing Load Balancer IP..."
curl -I http://$LOAD_BALANCER_IP || echo "[FAIL] Load Balancer IP test failed."

echo "[5] Testing domain access ($DOMAIN)..."
curl -I https://$DOMAIN || echo "[FAIL] Domain access test failed."

# === STEP 5: SUMMARY ===
echo ""
echo "[SUMMARY]"
echo "Domain IP: $DNS_IP"
echo "Load Balancer Health: $LB_STATUS"
echo "SSL Status: $SSL_STATUS"
echo "Website URL: https://$DOMAIN"
echo "[DONE] Full self-healing diagnostic complete."
