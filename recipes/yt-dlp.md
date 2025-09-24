# yt-dlp

yt-dlp is a command-line program to download videos from YouTube and other video
sites. It is a fork of the now inactive youtube-dl project, with additional
features and fixes.

```bash
# Install yt-dlp globally
pip install --user yt-dlp
```

```bash
# Create directories
mkdir -p ~/.local/share/yt-dlp
mkdir -p ~/.config/yt-dlp
mkdir -p ~/files/downloads/yt-dlp
```

Configuration file: `~/.config/yt-dlp/config`

```bash
--force-ipv4
--continue
--ignore-errors
--add-metadata
--restrict-filenames
--fragment-retries 'infinite'
--prefer-ffmpeg
--merge-output-format mp4
--limit-rate 50M
--sleep-interval 5
--download-archive "/home/epistrephein/.local/share/yt-dlp/yt-dlp.log"
--format "bestvideo[ext=mp4][protocol^=http]+bestaudio[ext=m4a]/best[ext=mp4][protocol^=http]/best"
--exec-before-download "mkdir -p /home/epistrephein/files/downloads/yt-dlp/%(extractor)s/"
--output "/home/epistrephein/files/downloads/yt-dlp/%(extractor)s/%(uploader)s-%(upload_date)s-%(id)s-%(title).150B.%(ext)s"
```

Re-encoding command (optional):

```bash
--exec "ffmpeg -loglevel warning -y -i {} -c:v libx264 -preset veryfast -crf 23 -c:a aac -movflags +faststart {}_reencoded.mp4 && mv {}_reencoded.mp4 {}"
```

---

### Instagram tool

```bash
#!/usr/bin/env bash
set -euo pipefail

# Display usage if no argument is provided
if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <url>"
  exit 0
fi

URL="$1"
COOKIES_FILE="$HOME/.local/share/yt-dlp/instagram.cookies"

# Check if cookies file exists
if [[ ! -f "$COOKIES_FILE" ]]; then
  echo "Error: cookies file not found at $COOKIES_FILE"
  exit 1
fi

# Run yt-dlp with custom options
yt-dlp --cookies "$COOKIES_FILE" \
  --embed-thumbnail \
  --download-archive "$HOME/.local/share/yt-dlp/insta-dlp.log" \
  --exec "ffmpeg -loglevel warning -y -i {} -c:v libx264 -preset veryfast -crf 23 -c:a aac -movflags +faststart {}_reencoded.mp4 && mv {}_reencoded.mp4 {}" \
  "$URL"
```

### Batch tool

```bash
#!/usr/bin/env bash
# Downloads videos via yt-dlp from a batch list.

set -euo pipefail

BATCH_FILE="$HOME/.local/share/yt-dlp/batch.txt"

# Check if batch file exists or is empty
if [[ ! -f "$BATCH_FILE" ]]; then
  echo "Error: batch file not found at $BATCH_FILE"
  exit 1
elif [[ ! -s "$BATCH_FILE" ]]; then
  echo "Error: batch file is empty at $BATCH_FILE"
  exit 1
fi

# Process each URL using yt-dlp
yt-dlp \
  --download-archive "$HOME/.local/share/yt-dlp/batch-dlp.log" \
  --batch-file "$BATCH_FILE"
```
