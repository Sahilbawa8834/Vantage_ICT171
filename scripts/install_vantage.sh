#!/usr/bin/env bash
# ============================================================
#  Vantage - one-shot installer for the droplet
#  Sahil Bawa, Murdoch ICT171, 2026 S1
#
#  Run this once on the server with sudo. It puts the check
#  script in /usr/local/bin, sets up the data directory, adds
#  the cron entry, and runs the first check so status.json
#  exists right away.
#
#  Usage on the droplet:
#    sudo bash install_vantage.sh
# ============================================================

set -e

# Where the script will live on the server
INSTALL_TARGET="/usr/local/bin/vantage_check.sh"
SOURCE_SCRIPT="$(dirname "$0")/vantage_check.sh"
LOG_FILE="/var/log/vantage.log"

# Confirm we can see the source file
if [ ! -f "$SOURCE_SCRIPT" ]; then
  echo "Could not find vantage_check.sh next to this installer."
  echo "Run this from the scripts/ directory you scp'd up."
  exit 1
fi

# Pre-flight: make sure the commands the check script needs are present.
echo "==> Pre-flight checks"
MISSING_CMDS=()
for cmd in curl sha256sum awk sed top free df uptime; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    MISSING_CMDS+=("$cmd")
  fi
done
if [ ${#MISSING_CMDS[@]} -gt 0 ]; then
  echo "Missing required commands: ${MISSING_CMDS[*]}"
  echo "Install them with apt before continuing."
  exit 1
fi
echo "    All required commands present."

echo "==> Installing vantage_check.sh to $INSTALL_TARGET"
cp "$SOURCE_SCRIPT" "$INSTALL_TARGET"
chmod +x "$INSTALL_TARGET"

echo "==> Creating data directory at /var/lib/vantage"
mkdir -p /var/lib/vantage

echo "==> Touching log file at $LOG_FILE"
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

echo "==> Adding cron entry (runs every 5 minutes)"
# Replace any existing vantage cron line with the fresh one
( crontab -l 2>/dev/null | grep -v "vantage_check.sh" ; \
  echo "*/5 * * * * $INSTALL_TARGET >> $LOG_FILE 2>&1" ) | crontab -

echo "==> Running first check now to generate status.json"
"$INSTALL_TARGET"

echo "==> Validating status.json"
if command -v python3 >/dev/null 2>&1; then
  if python3 -c "import json,sys; json.load(open('/var/www/html/status.json'))" 2>/dev/null; then
    echo "    status.json is valid JSON."
  else
    echo "    WARNING: status.json failed to parse as JSON."
    echo "    Inspect /var/www/html/status.json before relying on it."
    exit 2
  fi
else
  echo "    python3 not present; skipping JSON validation."
fi

echo ""
echo "Done. Vantage is now running every 5 minutes."
echo ""
echo "Useful commands:"
echo "  cat /var/www/html/status.json     # see the latest results"
echo "  tail -f /var/log/vantage.log      # watch checks as they run"
echo "  crontab -l                        # confirm the cron entry"
echo "  rm /var/lib/vantage/baseline.sha256   # reset the integrity baseline"
