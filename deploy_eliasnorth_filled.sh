#!/bin/bash
set -e
REGION="us-east-1"
PRIMARY_INSTANCE_ID="i-1234567890abcdef0"
BACKUP_INSTANCE_ID="i-backup12345678"
HOSTED_ZONE_ID="Z1234567890ABCDEFG"
AWS_ACCOUNT_ID="123456789012"
DOMAIN_NAME="eliasnorth.com"

echo "[+] Installing dependencies..."
sudo yum install -y aws-cli jq || sudo apt install -y awscli jq

echo "[+] Writing homepage..."
mkdir -p /home/ec2-user/elias_site
cat > /home/ec2-user/elias_site/index.html <<EOP
<!DOCTYPE html>
<html>
<head><title>Elias North AI</title></head>
<body style='background:#0a0a0f;color:#fff;font-family:sans-serif;text-align:center;padding:5em;'>
<h1>Elias North AI Services</h1>
<p>Websites, videos, and social automation — fully powered by AI.</p>
<button style='padding:1em;background:#f64c4c;color:#fff;border:none;border-radius:5px;'>Try the Builder</button>
</body>
</html>
EOP

echo "[+] Restarting Nginx..."
sudo systemctl restart nginx

echo "[+] Allocating EIP..."

echo "[+] Associating EIP..."
aws ec2 associate-address --region $REGION --instance-id $PRIMARY_INSTANCE_ID --allocation-id $ALLOCATION_ID

echo "[+] Updating Route 53..."
cat > route53.json <<EOR
{{
  "Changes": [{{
    "Action": "UPSERT",
    "ResourceRecordSet": {{
      "Name": "eliasnorth.com",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [{{"Value": "$PUBLIC_IP"}}]
    }}
  }}]
}}
EOR

aws route53 change-resource-record-sets --region $REGION --hosted-zone-id $HOSTED_ZONE_ID --change-batch file://route53.json
rm -f route53.json
echo "SUCCESS: EliasNorth is live at http://eliasnorth.com pointing to $PUBLIC_IP"
PUBLIC_IP="3.17.31.205"
ALLOCATION_ID="eipalloc-0ee82f2dd73308859"
