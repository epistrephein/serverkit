#!/bin/bash
# Notify on public IPv4 change via Telegram.

# Configuration
TELEGRAM_CHAT_ID="your_chat_id" # Replace with your Telegram chat ID
TELEGRAM_BOT_TOKEN="your_bot_token" # Replace with your Telegram bot token

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

# Send Telegram message
MESSAGE="🌐 *${HOSTNAME}*: public IP changed 🌐
Old: \`${PREVIOUS_IP}\`
New: \`${CURRENT_IP}\`"

TELEGRAM_API_URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"

curl -s -X POST "$TELEGRAM_API_URL" \
  -d chat_id="$TELEGRAM_CHAT_ID" \
  -d parse_mode="MarkdownV2" \
  --data-urlencode text="$MESSAGE" > /dev/null

echo "Telegram notification sent."
