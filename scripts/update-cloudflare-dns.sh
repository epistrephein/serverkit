#!/bin/bash
# Update Cloudflare DNS record and notify on Telegram when public IPv4 changes.

# Configuration
TELEGRAM_CHAT_ID="your_chat_id" # Replace with your Telegram chat ID
TELEGRAM_BOT_TOKEN="your_bot_token" # Replace with your Telegram bot token

CLOUDFLARE_API_TOKEN="your_api_token" # Replace with your Cloudflare API token
CLOUDFLARE_ZONE_ID="your_zone_id" # Replace with your Cloudflare zone ID
CLOUDFLARE_RECORD_IDS=("record_id_a" "record_id_b") # Replace with your Cloudflare DNS record IDs
CLOUDFLARE_RECORD_NAMES=("a.example.com" "b.example.com") # Replace with your Cloudflare DNS record names

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
CLOUDFLARE_STATUS_LIST=()

for i in "${!CLOUDFLARE_RECORD_NAMES[@]}"; do
  RECORD_ID="${CLOUDFLARE_RECORD_IDS[$i]}"
  RECORD_NAME="${CLOUDFLARE_RECORD_NAMES[$i]}"

  RESPONSE=$(curl -s https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$RECORD_ID \
    -X PATCH \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -d "{\"name\":\"$RECORD_NAME\",\"ttl\":1,\"type\":\"A\",\"content\":\"$CURRENT_IP\",\"proxied\":false}"
  )

  if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "Cloudflare DNS $RECORD_NAME updated successfully."
    CLOUDFLARE_STATUS_LIST+=("✅$RECORD_NAME")
  else
    echo "Cloudflare DNS $RECORD_NAME update failed."
    echo "$RESPONSE"
    CLOUDFLARE_STATUS_LIST+=("❌$RECORD_NAME")
  fi
done

# Send Telegram message
CLOUDFLARE_STATUS=$(IFS=, ; echo "${CLOUDFLARE_STATUS_LIST[*]}")

MESSAGE="🌐 *${HOSTNAME}*: public IP changed 🌐
Old: \`${PREVIOUS_IP}\`
New: \`${CURRENT_IP}\`
DNS: \`${CLOUDFLARE_STATUS}\`"

TELEGRAM_API_URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"

curl -s -X POST "$TELEGRAM_API_URL" \
  -d chat_id="$TELEGRAM_CHAT_ID" \
  -d parse_mode="MarkdownV2" \
  --data-urlencode text="$MESSAGE" > /dev/null

echo "Telegram notification sent."
