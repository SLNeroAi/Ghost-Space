#!/bin/bash
# @fileOverview Check usage stats of GHOST VPN
# @author MasterHide
# @Copyright © 2025 x404 MASTER™
# @license MIT
#
# You may not reproduce or distribute this work, in whole or in part, 
# without the express written consent of the copyright owner.


set -euo pipefail

# -------- UI: Menu --------
show_menu() {
    echo "Welcome to GHOST VPN Installer/Uninstaller"
    echo "Please choose an option:"
    echo "1. Run GHOST VPN (Install)"
    echo "2. Uninstall GHOST VPN"
    echo "3. Exit"
}

while true; do
    show_menu
    read -p "Enter your choice [1-3]: " CHOICE
    case $CHOICE in
        1) echo "Proceeding with GHOST VPN installation..."; break ;;
        2)
            echo "Uninstalling GHOST VPN..."
            # UPDATED: Use the new raw path for the uninstaller script (rm-Ghost-Mx.sh)
            bash <(curl -s https://raw.githubusercontent.com/SLNeroAi/Ghost-Space/main/rm-Ghost-Mx.sh) 
            echo "GHOST VPN has been uninstalled."
            exit 0
            ;;
        3) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice. Please select a valid option [1-3]." ;;
    esac
done

# -------- Auto-detect username (no prompt) --------
# Prefer SUDO_USER when run via sudo; fall back to whoami; final fallback: logname.

USERNAME="${SUDO_USER:-$(whoami)}"

# If we are truly root (whoami == root), trust whoami instead of SUDO_USER
if [[ "$(whoami)" == "root" ]]; then
  USERNAME="root"
fi

# If still unset or weird, try logname and other fallbacks
if [[ -z "$USERNAME" || "$USERNAME" == "unknown" ]]; then
  POSSIBLE_USER="$(logname 2>/dev/null || true)"
  if [[ -n "${POSSIBLE_USER:-}" && "${POSSIBLE_USER}" != "root" ]]; then
    USERNAME="$POSSIBLE_USER"
  else
    POSSIBLE_USER="$(who -m 2>/dev/null | awk '{print $1}' || true)"
    if [[ -n "$POSSIBLE_USER" ]]; then
      USERNAME="$POSSIBLE_USER"
    fi
  fi
fi

# Resolve home directory
HOME_DIR=$(eval echo "~$USERNAME")
PROJECT_DIR="ghost-vpn-monitor" # New consistent directory name
SERVICE_NAME="ghost-vpn" # New service name

# Validate home directory
if [[ ! -d "$HOME_DIR" ]]; then
  if [[ -d "/root" ]]; then
    USERNAME="root"
    HOME_DIR="/root"
  else
    echo "User '$USERNAME' does not have a valid home directory ($HOME_DIR)."
    exit 1
  fi
fi

# Print detected user in yellow
echo -e "✅ Auto-detected system user: \033[1;33m$USERNAME\033[0m"



# -------- Ask for domain & port (same UX) --------
read -p "Enter your server domain (e.g. your_domain.com): " DOMAIN
read -p "Enter the port (default: 5000): " PORT
PORT=${PORT:-5000}

# -------- Version (same UX) --------
read -p "Enter the version to install (e.g., v1.0.1) or leave blank for latest: " VERSION
VERSION="${VERSION:-latest}"

# -------- System deps --------
echo "Updating packages..."
sudo apt update
echo "Installing required dependencies..."
sudo apt install -y python3-pip python3-venv git sqlite3 socat unzip curl

# -------- Download GHOST VPN (Logic updated for new directory name and repository) --------
echo "Downloading GHOST VPN version $VERSION..."
if [ "$VERSION" = "latest" ]; then
    # UPDATED: Use the new repository path
    DOWNLOAD_URL="https://github.com/SLNeroAi/Ghost-Space/archive/refs/heads/main.zip"
else
    # UPDATED: Use the new repository path
    DOWNLOAD_URL="https://github.com/SLNeroAi/Ghost-Space/archive/refs/tags/$VERSION.zip"
fi

cd "$HOME_DIR"
if curl -L "$DOWNLOAD_URL" -o temp_download.zip; then
    echo "Download successful. Extracting files..."
    unzip -o temp_download.zip -d "$HOME_DIR"
    
    # Find the extracted directory name, which should now contain Ghost-Space-main
    EXTRACTED_DIR=$(ls -1 "$HOME_DIR" | grep -E "^Ghost-Space-(main|${VERSION})" | head -n 1) 
    
    # Fallback/Cleanup check
    if [[ -z "$EXTRACTED_DIR" ]]; then
        # Try finding any directory that starts with Ghost-Space-
        EXTRACTED_DIR=$(ls -1 "$HOME_DIR" | grep -E "^Ghost-Space-" | head -n 1)
    fi

    # Cleanup old/existing folder and rename
    rm -rf "$HOME_DIR/$PROJECT_DIR"
    mv "$HOME_DIR/$EXTRACTED_DIR" "$HOME_DIR/$PROJECT_DIR"
    rm temp_download.zip
else
    echo "Failed to download GHOST VPN version $VERSION. Exiting."
    exit 1
fi

# -------- Verify repo structure (UPDATED: Check for gmx_builders.py) --------
if [ ! -d "$HOME_DIR/$PROJECT_DIR/templates" ]; then
  echo "Templates directory not found in repo. Exiting."
  exit 1
fi
if [ ! -f "$HOME_DIR/$PROJECT_DIR/app.py" ]; then
  echo "ERROR: app.py not found in repo at $HOME_DIR/$PROJECT_DIR/app.py"
  echo "Please ensure the repository structure is correct."
  exit 1
fi
if [ ! -f "$HOME_DIR/$PROJECT_DIR/gmx_builders.py" ]; then
  echo "ERROR: gmx_builders.py not found in repo at $HOME_DIR/$PROJECT_DIR/gmx_builders.py"
  echo "Please ensure the repository structure is correct."
  exit 1
fi

# -------- Python venv + deps --------
echo "Setting up the Python virtual environment..."
cd "$HOME_DIR/$PROJECT_DIR"
python3 -m venv venv
source venv/bin/activate
echo "Installing Python dependencies..."
pip install --upgrade pip
if [ -f "requirements.txt" ]; then
  pip install -r requirements.txt
else
  # Pin Flask + Werkzeug to compatible versions
  pip install "flask==2.2.5" "werkzeug==2.2.3" gunicorn psutil requests
fi
deactivate


# -------- SSL setup (robust + fixed acme.sh path) --------
SSL_CONTEXT=""
CERT_DIR="/var/lib/$SERVICE_NAME/certs" # Use new service name
sudo mkdir -p "$CERT_DIR"
sudo chown -R "$USERNAME:$USERNAME" "$CERT_DIR"

if [[ -f "$CERT_DIR/$DOMAIN.cer" && -f "$CERT_DIR/$DOMAIN.cer.key" ]]; then
    echo "Valid SSL certificate already exists."
    SSL_CONTEXT="--certfile=$CERT_DIR/$DOMAIN.cer --keyfile=$CERT_DIR/$DOMAIN.cer.key"
else
    echo "Generating SSL certificate..."
    # Install acme.sh (idempotent)
    curl https://get.acme.sh | sh -s email="$USERNAME@$DOMAIN" || true

    # Resolve acme.sh path correctly (works even when run with sudo)
    ACME="$HOME/.acme.sh/acme.sh"
    if [[ "$HOME" == "/root" && -n "${SUDO_USER:-}" ]]; then
        ACME="/home/$SUDO_USER/.acme.sh/acme.sh"
    fi
    # Fallback to HOME_DIR if needed
    if [[ ! -x "$ACME" && -n "${HOME_DIR:-}" ]]; then
        ACME="$HOME_DIR/.acme.sh/acme.sh"
    fi
    # Final fallback
    if [[ ! -x "$ACME" ]]; then
        ACME="$HOME/.acme.sh/acme.sh"
    fi

    # Use Let's Encrypt
    "$ACME" --set-default-ca --server letsencrypt || true

    # Best-effort: open 80/443 (won't fail script if ufw absent)
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw allow 80/tcp || true
        sudo ufw allow 443/tcp || true
    fi

    # Best-effort: free up port 80 during issuance
    sudo systemctl stop nginx 2>/dev/null || true
    sudo systemctl stop apache2 2>/dev/null || true

    ISSUE_OK=0
    # Try HTTP-01 (standalone on :80)
    if "$ACME" --issue --force --standalone -d "$DOMAIN" \
        --fullchain-file "$CERT_DIR/$DOMAIN.cer" \
        --key-file "$CERT_DIR/$DOMAIN.cer.key"; then
        ISSUE_OK=1
    else
        echo "HTTP-01 failed, retrying with IPv6 standalone..."
        if "$ACME" --issue --force --standalone --listen-v6 -d "$DOMAIN" \
            --fullchain-file "$CERT_DIR/$DOMAIN.cer" \
            --key-file "$CERT_DIR/$DOMAIN.cer.key"; then
            ISSUE_OK=1
        else
            echo "IPv6 standalone failed, trying ALPN on :443..."
            if "$ACME" --issue --force --alpn -d "$DOMAIN" \
                --fullchain-file "$CERT_DIR/$DOMAIN.cer" \
                --key-file "$CERT_DIR/$DOMAIN.cer.key"; then
                ISSUE_OK=1
            fi
        fi
    fi

    # Fix ownership & set SSL_CONTEXT when we have certs
    if [[ $ISSUE_OK -eq 1 && -f "$CERT_DIR/$DOMAIN.cer" && -f "$CERT_DIR/$DOMAIN.cer.key" ]]; then
        sudo chown "$USERNAME:$USERNAME" "$CERT_DIR/$DOMAIN.cer" "$CERT_DIR/$DOMAIN.cer.key" || true
        echo "SSL certificates generated successfully."
        SSL_CONTEXT="--certfile=$CERT_DIR/$DOMAIN.cer --keyfile=$CERT_DIR/$DOMAIN.cer.key"
    else
        echo "Failed to generate SSL certificates. Continuing without SSL."
        SSL_CONTEXT=""
    fi
fi
# -------- end SSL setup --------

# -------- DB permissions (same as before) --------
echo "Setting permissions for the database file..."
if [ -f "/etc/x-ui/x-ui.db" ]; then
  sudo chmod 644 /etc/x-ui/x-ui.db
  sudo chown "$USERNAME:$USERNAME" /etc/x-ui/x-ui.db
else
  echo "WARNING: /etc/x-ui/x-ui.db not found. The app will still start, but usage queries will fail until the DB exists."
fi

# -------- systemd service (uses repo's app.py) --------
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

# Stop existing service if running
if systemctl is-active --quiet $SERVICE_NAME; then
    echo "Stopping existing GHOST VPN service..."
    sudo systemctl stop $SERVICE_NAME
fi

echo "Setting up systemd service..."
sudo tee "$SERVICE_FILE" >/dev/null <<EOL
[Unit]
Description=GHOST VPN Web Monitor
After=network.target

[Service]
User=$USERNAME
WorkingDirectory=$HOME_DIR/$PROJECT_DIR
Environment="DB_PATH=/etc/x-ui/x-ui.db"
ExecStart=/bin/bash -lc 'source $HOME_DIR/$PROJECT_DIR/venv/bin/activate && exec gunicorn -w 4 -b 0.0.0.0:$PORT $SSL_CONTEXT app:app'
Restart=always
RestartSec=5
StandardOutput=append:/var/log/$SERVICE_NAME.log
StandardError=append:/var/log/$SERVICE_NAME.log
SyslogIdentifier=$SERVICE_NAME

[Install]
WantedBy=multi-user.target
EOL

echo "Enabling the service to start on boot..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

# -------- Final messages --------
PROTO="http"
[ -n "$SSL_CONTEXT" ] && PROTO="https"
echo "Installation complete! GHOST VPN is Running Now at $PROTO://$DOMAIN:$PORT"
[ -z "$SSL_CONTEXT" ] && echo "SSL is disabled. (Cert generation failed or not present.)"
