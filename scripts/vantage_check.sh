#!/usr/bin/env bash
# ============================================================
#  Vantage - Stage 1 check script
#  Sahil Bawa, Murdoch ICT171, 2026 S1
#  https://github.com/Sahilbawa8834/Vantage_ICT171
#
#  This is the script that actually runs the checks. Cron
#  fires it every 5 minutes. It writes the results into
#  /var/www/html/admin/status.json which the admin page reads.
#  The admin/ directory is protected by Nginx basic auth so
#  the JSON is not publicly readable.
#
#  Scope: scans only the host's own assets.
# ============================================================

set -u

export LC_ALL=C
export LANG=C

# --- Settings --------------------------------------------------------------
TARGET_URL="https://vantageproject.me/"
STATUS_FILE="/var/www/html/admin/status.json"
BASELINE_FILE="/var/lib/vantage/baseline.sha256"

mkdir -p /var/lib/vantage
mkdir -p /var/www/html/admin

# --- Server self-check (CHK-07) -------------------------------------------
UPTIME_HUMAN=$(uptime -p | sed 's/up //')
CPU_PCT=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEM_PCT=$(free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100}')
DISK_PCT=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
LOAD_AVG=$(uptime | awk -F'load average: ' '{print $2}' | tr -d ',')

UPTIME_HUMAN=${UPTIME_HUMAN:-unknown}
CPU_PCT=${CPU_PCT:-0}
MEM_PCT=${MEM_PCT:-0}
DISK_PCT=${DISK_PCT:-0}
LOAD_AVG=${LOAD_AVG:-0.00 0.00 0.00}

# --- Uptime check (CHK-01) -------------------------------------------------
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" --max-time 8 "$TARGET_URL")
HTTP_TIME_MS=$(curl -o /dev/null -s -w "%{time_total}" --max-time 8 "$TARGET_URL" | awk '{printf "%.0f", $1*1000}')

if [ "$HTTP_CODE" = "200" ]; then
  UPTIME_STATUS="OK"
  UPTIME_GRADE="A"
  UPTIME_SEV="low"
  UPTIME_DETAIL="HTTP $HTTP_CODE in ${HTTP_TIME_MS} ms"
else
  UPTIME_STATUS="DOWN"
  UPTIME_GRADE="F"
  UPTIME_SEV="critical"
  UPTIME_DETAIL="HTTP $HTTP_CODE - server not responding normally"
fi

# --- Security headers audit (CHK-03) --------------------------------------
HEADERS=$(curl -sI --max-time 8 "$TARGET_URL")
MISSING=()
echo "$HEADERS" | grep -qi "^strict-transport-security:" || MISSING+=("HSTS")
echo "$HEADERS" | grep -qi "^content-security-policy:" || MISSING+=("CSP")
echo "$HEADERS" | grep -qi "^x-frame-options:" || MISSING+=("X-Frame-Options")
echo "$HEADERS" | grep -qi "^x-content-type-options:" || MISSING+=("X-Content-Type-Options")
echo "$HEADERS" | grep -qi "^referrer-policy:" || MISSING+=("Referrer-Policy")

MISSING_COUNT=${#MISSING[@]}
case $MISSING_COUNT in
  0) HEADER_GRADE="A"; HEADER_SEV="low"; HEADER_STATUS="OK" ;;
  1) HEADER_GRADE="B"; HEADER_SEV="low"; HEADER_STATUS="OK" ;;
  2) HEADER_GRADE="C"; HEADER_SEV="medium"; HEADER_STATUS="WARN" ;;
  3) HEADER_GRADE="D"; HEADER_SEV="medium"; HEADER_STATUS="WARN" ;;
  *) HEADER_GRADE="F"; HEADER_SEV="high"; HEADER_STATUS="WARN" ;;
esac

if [ "$MISSING_COUNT" -eq 0 ]; then
  HEADER_DETAIL="All recommended headers present."
else
  HEADER_DETAIL="Missing: $(printf '%s, ' "${MISSING[@]}" | sed 's/, $//')"
fi

# --- Content integrity (CHK-04) -------------------------------------------
if [ "$HTTP_CODE" != "200" ]; then
  INTEGRITY_STATUS="SKIP"
  INTEGRITY_GRADE="-"
  INTEGRITY_SEV="low"
  INTEGRITY_DETAIL="Skipped: target returned HTTP $HTTP_CODE."
else
  CURRENT_HASH=$(curl -s --max-time 8 "$TARGET_URL" | sha256sum | awk '{print $1}')
  if [ ! -f "$BASELINE_FILE" ]; then
    echo "$CURRENT_HASH" > "$BASELINE_FILE"
    INTEGRITY_STATUS="OK"
    INTEGRITY_GRADE="A"
    INTEGRITY_SEV="low"
    INTEGRITY_DETAIL="Baseline established this run."
  else
    BASELINE_HASH=$(cat "$BASELINE_FILE")
    if [ "$CURRENT_HASH" = "$BASELINE_HASH" ]; then
      INTEGRITY_STATUS="OK"
      INTEGRITY_GRADE="A"
      INTEGRITY_SEV="low"
      INTEGRITY_DETAIL="Hash matches baseline. No drift."
    else
      INTEGRITY_STATUS="WARN"
      INTEGRITY_GRADE="C"
      INTEGRITY_SEV="medium"
      INTEGRITY_DETAIL="Homepage content changed since baseline (review)."
    fi
  fi
fi

# --- TLS certificate expiry check (CHK-02) --------------------------------
TLS_HOST="vantageproject.me"
CERT_END_DATE=$(echo | openssl s_client -servername "$TLS_HOST" -connect "$TLS_HOST:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

if [ -n "$CERT_END_DATE" ]; then
  CERT_END_EPOCH=$(date -d "$CERT_END_DATE" "+%s" 2>/dev/null)
  NOW_EPOCH=$(date "+%s")

  if [ -n "$CERT_END_EPOCH" ]; then
    DAYS_LEFT=$(( (CERT_END_EPOCH - NOW_EPOCH) / 86400 ))

    if [ "$DAYS_LEFT" -ge 30 ]; then
      TLS_GRADE="A"
      TLS_STATUS="OK"
      TLS_SEV="low"
    elif [ "$DAYS_LEFT" -ge 14 ]; then
      TLS_GRADE="B"
      TLS_STATUS="WARN"
      TLS_SEV="medium"
    else
      TLS_GRADE="F"
      TLS_STATUS="WARN"
      TLS_SEV="high"
    fi

    TLS_DETAIL="Certificate valid. Expires in ${DAYS_LEFT} days."
  else
    TLS_GRADE="F"
    TLS_STATUS="FAIL"
    TLS_SEV="high"
    TLS_DETAIL="Could not parse certificate expiry date."
  fi
else
  TLS_GRADE="F"
  TLS_STATUS="FAIL"
  TLS_SEV="high"
  TLS_DETAIL="Could not read TLS certificate."
fi

# --- Write the JSON dashboard reads ----------------------------------------
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TARGET_DOMAIN=$(echo "$TARGET_URL" | awk -F[/:] '{print $4}')

cat > "$STATUS_FILE" <<EOF
{
  "generated_at": "$NOW",
  "target": "$TARGET_DOMAIN",
  "host": {
    "uptime_human": "$UPTIME_HUMAN",
    "cpu_percent": $CPU_PCT,
    "mem_percent": $MEM_PCT,
    "disk_percent": $DISK_PCT,
    "load_avg": "$LOAD_AVG"
  },
  "checks": [
    {
      "id": "CHK-01",
      "name": "Uptime",
      "status": "$UPTIME_STATUS",
      "grade": "$UPTIME_GRADE",
      "severity": "$UPTIME_SEV",
      "detail": "$UPTIME_DETAIL"
    },
    {
      "id": "CHK-02",
      "name": "TLS expiry",
      "status": "$TLS_STATUS",
      "grade": "$TLS_GRADE",
      "severity": "$TLS_SEV",
      "detail": "$TLS_DETAIL"
    },
    {
      "id": "CHK-03",
      "name": "Security headers",
      "status": "$HEADER_STATUS",
      "grade": "$HEADER_GRADE",
      "severity": "$HEADER_SEV",
      "detail": "$HEADER_DETAIL"
    },
    {
      "id": "CHK-04",
      "name": "Content integrity",
      "status": "$INTEGRITY_STATUS",
      "grade": "$INTEGRITY_GRADE",
      "severity": "$INTEGRITY_SEV",
      "detail": "$INTEGRITY_DETAIL"
    },
    {
      "id": "CHK-07",
      "name": "Server self-check",
      "status": "OK",
      "grade": "A",
      "severity": "low",
      "detail": "CPU ${CPU_PCT}% · Mem ${MEM_PCT}% · Disk ${DISK_PCT}%"
    }
  ]
}
EOF

chmod 644 "$STATUS_FILE"

echo "[$(date -u +%T)] vantage_check ran. Headers missing: $MISSING_COUNT. HTTP: $HTTP_CODE."