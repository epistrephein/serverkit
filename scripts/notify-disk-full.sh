#!/bin/bash
# Notify on high disk usage via Telegram.

# Configuration
TELEGRAM_CHAT_ID="your_chat_id" # Replace with your Telegram chat ID
TELEGRAM_BOT_TOKEN="your_bot_token" # Replace with your Telegram bot token

THRESHOLD=80
MOUNT_POINT="/"

# Get usage percentage
USAGE=$(df -P "$MOUNT_POINT" | awk 'NR==2 {gsub("%",""); print $5}')
HOSTNAME=$(hostname -s)

# Disk usage below threshold
if (( USAGE < THRESHOLD )); then
  echo "Disk usage is at ${USAGE}% - below threshold (${THRESHOLD}%)."
  exit 0
fi

# Disk usage above threshold
echo "Disk usage is at ${USAGE}% - above threshold (${THRESHOLD}%)."

# Send Telegram message
MESSAGE="📦 *${HOSTNAME}*: disk usage warning 📦
Mount point: \`${MOUNT_POINT}\`
Usage: \`${USAGE}%\`
Threshold: \`${THRESHOLD}%\`"

TELEGRAM_API_URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"

curl -s -X POST "$TELEGRAM_API_URL" \
  -d chat_id="$TELEGRAM_CHAT_ID" \
  -d parse_mode="MarkdownV2" \
  --data-urlencode text="$MESSAGE" > /dev/null

echo "Telegram notification sent."
