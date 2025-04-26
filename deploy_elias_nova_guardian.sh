#!/bin/bash

echo "[0] NOVA,HE — FULL Flask Self-Healing + Load Balancer Auto Diagnostic — SILENT GUARDIAN MODE"

# === CONFIG ===
DOMAIN="eliasnorth.com"
PROJECT_ID="mirrorone-456514"
LOAD_BALANCER_IP="35.190.126.179"
BACKEND_SERVICE_NAME="eliasnorth-backend"
SSL_CERT_NAME="eliasnorth-ssl"
FLASK_APP_PATH="/home/ec2-user/ai_website_builder.py"
INSTANCE_NAME="elias-north"
ZONE="us-central1-a"
LOG_FILE="$HOME/nova_guardian.log"
ALERT_EMAIL="novaassistant@proton.me"

# === STEP 0: Create log if missing ===
touch $LOG_FILE

# === INFINITE LOOP ===
while true; do
    echo "[$(date)] NovaGuardian Cycle Start" >> $LOG_FILE

    # STEP 1: DNS CHECK
    DNS_IP=$(dig +short $DOMAIN)
    if [[ "$DNS_IP" == "$LOAD_BALANCER_IP" ]]; then
        echo "[$(date)] [PASS] DNS OK" >> $LOG_FILE
    else
        echo "[$(date)] [FAIL] DNS mismatch! Got $DNS_IP" >> $LOG_FILE
    fi

    # STEP 2: BACKEND HEALTH CHECK
    LB_STATUS=$(gcloud compute backend-services get-health $BACKEND_SERVICE_NAME --global --project=$PROJECT_ID --format="value(status.healthStatus[0].healthState)")
    if [[ "$LB_STATUS" == "HEALTHY" ]]; then
        echo "[$(date)] [PASS] Backend Healthy" >> $LOG_FILE
    else
        echo "[$(date)] [WARN] Backend Unhealthy — Auto-repair initiated..." >> $LOG_FILE
        pkill -f ai_website_builder.py || true
        nohup python3 $FLASK_APP_PATH >/dev/null 2>&1 &
        sleep 10
        LB_STATUS=$(gcloud compute backend-services get-health $BACKEND_SERVICE_NAME --global --project=$PROJECT_ID --format="value(status.healthStatus[0].healthState)")
        if [[ "$LB_STATUS" == "HEALTHY" ]]; then
            echo "[$(date)] [PASS] Backend recovered after restart." >> $LOG_FILE
        else
            echo "[$(date)] [FAIL] Backend still unhealthy after recovery." >> $LOG_FILE
            echo "Backend Unhealthy — Human intervention needed." | mail -s "NovaGuardian Alert" $ALERT_EMAIL
        fi
    fi

    # STEP 3: SSL CERT CHECK
    SSL_STATUS=$(gcloud compute ssl-certificates describe $SSL_CERT_NAME --global --project=$PROJECT_ID --format="value(managed.status)")
    if [[ "$SSL_STATUS" == "ACTIVE" ]]; then
        echo "[$(date)] [PASS] SSL Cert Active" >> $LOG_FILE
    else
        echo "[$(date)] [WARN] SSL Cert not ready ($SSL_STATUS)" >> $LOG_FILE
    fi

    # STEP 4: Site Check
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN)
    if [[ "$HTTP_CODE" == "200" ]]; then
        echo "[$(date)] [PASS] Site loaded OK ($HTTP_CODE)" >> $LOG_FILE
    else
        echo "[$(date)] [WARN] Site returned code: $HTTP_CODE" >> $LOG_FILE
    fi

    echo "[$(date)] NovaGuardian Cycle End" >> $LOG_FILE
    echo "" >> $LOG_FILE

    sleep 300
done
