#!/bin/bash
# Update Cloudflare DNS record and notify on Telegram when public IPv4 changes.

# Configuration
TELEGRAM_CHAT_ID="your_chat_id" # Replace with your Telegram chat ID
TELEGRAM_BOT_TOKEN="your_bot_token" # Replace with your Telegram bot token

CLOUDFLARE_API_TOKEN="your_api_token" # Replace with your Cloudflare API token
CLOUDFLARE_ZONE_ID="your_zone_id" # Replace with your Cloudflare zone ID
CLOUDFLARE_RECORD_ID="your_record_id" # Replace with your Cloudflare DNS record ID
CLOUDFLARE_RECORD_NAME="your_record_name" # Replace with your Cloudflare DNS record name

IP_FILE="$HOME/.cache/ipv4"

# Ensure cache dir exists
mkdir -p "$(dirname "$IP_FILE")"

# Fetch current IP and hostname
CURRENT_IP=$(curl -s https://v4.ident.me)
HOSTNAME=$(hostname -s)

# Exit with error if IP fetch fails
if [[ -z "$CURRENT_IP" ]]; then
  echo "Failed to fetch current IP."
  exit 1
fi

# First run: no previous IP
if [[ ! -f "$IP_FILE" ]]; then
  echo "No previous IP found. Saving current IP: $CURRENT_IP"
  echo "$CURRENT_IP" > "$IP_FILE"
  exit 0
fi

PREVIOUS_IP=$(<"$IP_FILE")

# IP unchanged
if [[ "$CURRENT_IP" == "$PREVIOUS_IP" ]]; then
  echo "IP unchanged: $CURRENT_IP"
  exit 0
fi

# IP changed
echo "IP changed: $PREVIOUS_IP → $CURRENT_IP"
echo "$CURRENT_IP" > "$IP_FILE"

# Update Cloudflare DNS record
RESPONSE=$(curl -s https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$CLOUDFLARE_RECORD_ID \
  -X PATCH \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -d "{\"name\":\"$CLOUDFLARE_RECORD_NAME\",\"ttl\":300,\"type\":\"A\",\"content\":\"$CURRENT_IP\",\"proxied\":false}"
)

if echo "$RESPONSE" | grep -q '"success":true'; then
  echo "Cloudflare DNS updated successfully."
  CLOUDFLARE_STATUS="updated"
else
  echo "Cloudflare DNS update failed."
  echo "$RESPONSE"
  CLOUDFLARE_STATUS="failed to update"
fi

# Send Telegram message
MESSAGE="🌐 *${HOSTNAME}*: public IP changed 🌐
Old: \`${PREVIOUS_IP}\`
New: \`${CURRENT_IP}\`
Cloudflare DNS: \`${CLOUDFLARE_STATUS}\`"

TELEGRAM_API_URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"

curl -s -X POST "$TELEGRAM_API_URL" \
  -d chat_id="$TELEGRAM_CHAT_ID" \
  -d parse_mode="MarkdownV2" \
  --data-urlencode text="$MESSAGE" > /dev/null

echo "Telegram notification sent."
