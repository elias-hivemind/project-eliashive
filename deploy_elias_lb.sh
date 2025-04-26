#!/bin/bash

echo "[0] EliasNorth Load Balancer Setup — Using Elias Account"

# === CONFIG ===
PROJECT_ID="elias-access-project"  # Set to the correct project ID tied to elias.north.ai@gmail.com
REGION="us-central1"
ZONE="us-central1-a"
INSTANCE_GROUP="elias-instance-group"
STATIC_IP_NAME="eliasnorth-static-ip"
BACKEND_SERVICE_NAME="eliasnorth-backend"
HEALTH_CHECK_NAME="eliasnorth-health-check"
URL_MAP_NAME="eliasnorth-url-map"
HTTPS_PROXY_NAME="eliasnorth-https-proxy"
FORWARDING_RULE_NAME="eliasnorth-https-rule"
SSL_CERT_NAME="eliasnorth-ssl"
DOMAIN="eliasnorth.com"
CREDENTIAL_JSON="/home/ec2-user/credentials/elias-access-service-account.json"

echo "[1] Authenticating using Elias service account..."
gcloud auth activate-service-account --key-file=$CREDENTIAL_JSON
gcloud config set project $PROJECT_ID

echo "[2] Enabling core APIs..."
gcloud services enable compute.googleapis.com \
                      cloudcdn.googleapis.com \
                      iam.googleapis.com \
                      servicemanagement.googleapis.com \
                      serviceusage.googleapis.com \
                      aiplatform.googleapis.com \
                      cloudresourcemanager.googleapis.com

echo "[3] Reserving Static IP..."
gcloud compute addresses create $STATIC_IP_NAME \
  --ip-version=IPV4 --global

echo "[4] Creating Health Check..."
gcloud compute health-checks create http $HEALTH_CHECK_NAME \
  --port=80 --request-path=/ --global

echo "[5] Creating Backend Service..."
gcloud compute backend-services create $BACKEND_SERVICE_NAME \
  --protocol=HTTP --health-checks=$HEALTH_CHECK_NAME --global

echo "[6] Attaching Instance Group..."
gcloud compute backend-services add-backend $BACKEND_SERVICE_NAME \
  --instance-group=$INSTANCE_GROUP \
  --instance-group-zone=$ZONE \
  --global

echo "[7] Creating URL Map..."
gcloud compute url-maps create $URL_MAP_NAME \
  --default-service=$BACKEND_SERVICE_NAME

echo "[8] Creating SSL Certificate..."
gcloud compute ssl-certificates create $SSL_CERT_NAME \
  --domains=$DOMAIN --global

echo "[9] Creating HTTPS Proxy..."
gcloud compute target-https-proxies create $HTTPS_PROXY_NAME \
  --ssl-certificates=$SSL_CERT_NAME \
  --url-map=$URL_MAP_NAME

echo "[10] Creating Global Forwarding Rule..."
gcloud compute forwarding-rules create $FORWARDING_RULE_NAME \
  --address=$STATIC_IP_NAME \
  --global \
  --target-https-proxy=$HTTPS_PROXY_NAME \
  --ports=443

echo "[11] Fetching Reserved IP..."
gcloud compute addresses describe $STATIC_IP_NAME \
  --global --format="get(address)"

echo "[DONE] Point your A record at the IP above in Namecheap."
