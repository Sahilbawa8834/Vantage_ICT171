#!/usr/bin/env bash
# ============================================================
#  Vantage - admin basic-auth setup helper
#  Sahil Bawa, Murdoch ICT171, 2026 S1
#
#  Run this once on the droplet (as root):
#    sudo bash setup_admin_auth.sh
#
#  It does the safe half of the admin-auth setup:
#    1. Installs apache2-utils (which provides htpasswd)
#    2. Creates /etc/nginx/.htpasswd with one user
#    3. Reminds you of the Nginx location block you still need
#       to paste into /etc/nginx/sites-available/default
#
#  It does NOT edit Nginx config automatically. That you do
#  by hand with nano so nothing gets silently broken.
# ============================================================

set -e

HTPASSWD_FILE="/etc/nginx/.htpasswd"
ADMIN_USER="admin"

echo "==> Installing apache2-utils (provides htpasswd)"
apt update -qq
apt install -y apache2-utils

echo ""
echo "==> Creating $HTPASSWD_FILE with user '$ADMIN_USER'"
echo "    You will be prompted to enter and confirm a password."
echo ""
htpasswd -c "$HTPASSWD_FILE" "$ADMIN_USER"

echo ""
echo "==> Locking down file permissions on $HTPASSWD_FILE"
chown root:www-data "$HTPASSWD_FILE"
chmod 640 "$HTPASSWD_FILE"

echo ""
echo "==> Done."
echo ""
echo "Next step (manual, by design):"
echo ""
echo "  sudo nano /etc/nginx/sites-available/default"
echo ""
echo "Inside the server {} block(s), add this location block:"
echo ""
cat <<'EOF'
    location /admin/ {
        auth_basic           "Vantage Admin";
        auth_basic_user_file /etc/nginx/.htpasswd;
        try_files            $uri $uri/ /admin/index.html;
    }
EOF
echo ""
echo "Then validate and reload:"
echo ""
echo "  sudo nginx -t"
echo "  sudo systemctl reload nginx"
echo ""
echo "Verify from your Mac (should ask for password):"
echo "  curl -I https://vantageproject.me/admin/"
echo ""
