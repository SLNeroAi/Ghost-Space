
<p align="center">
  <img src="assets/ghost-banner.png" alt="GHOST VPN Monitor" width="85%"/>
</p>

# 🕶️ GHOST VPN Monitor — v2.0  
> Lightweight VPN traffic monitor & dashboard — **Personal & Educational Use Only**  
> ❌ Commercial use or reselling is strictly prohibited. ✅ Give credit to the original author.

<p align="center">
  <img src="https://img.shields.io/badge/Version-2.0-blue?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Author-SL%20NeroAI-red?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Status-Stable-success?style=for-the-badge"/>
</p>

---

## ⚠️ IMPORTANT NOTE
**This repository and scripts are intended for learning and personal use only.**  
Do not resell. If you modify or redistribute, please reference the original author: **SL Nero-AI**.

---

## 🧾 Summary
GHOST VPN Monitor is a small web app (Flask backend + simple frontend) that collects local network/VPN usage metrics and displays them in a responsive, animated dashboard. It ships with an automated install script and optional Nginx reverse-proxy with Certbot support for HTTPS.

---

## ✅ Supported OS (tested)
- Ubuntu 20.04 / 22.04 / 24.04 LTS
- Debian 10 / 11 / 12

---

## 🧩 System Requirements
- CPU: 1 core (2+ recommended)
- RAM: 512 MB minimum (1 GB recommended)
- Disk: 500 MB free
- Ports: 80 (HTTP), 443 (HTTPS), 5000 (App)
- Root or sudo privileges

---

## 🚀 One-line Auto Install
```bash
sudo bash <(curl -s https://raw.githubusercontent.com/SLNeroAi/Ghost-Space/main/Ghost-Mx.sh)
```

---

## 🛠️ Step-by-Step Manual Install

1. **Update System**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl ufw build-essential
```

2. **Create Directories**
```bash
sudo useradd -r -s /bin/false ghostuser || true
sudo mkdir -p /opt/ghost-monitor
sudo chown ghostuser:ghostuser /opt/ghost-monitor
```

3. **Clone Repository**
```bash
sudo -u ghostuser git clone https://github.com/SLNeroAi/Ghost-Space.git /opt/ghost-monitor
cd /opt/ghost-monitor
```

4. **Install Python**
```bash
sudo apt install -y python3 python3-venv python3-pip
python3 -m venv /opt/ghost-monitor/venv
source /opt/ghost-monitor/venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate
```

5. **Environment File**
```ini
FLASK_ENV=production
FLASK_APP=app.py
APP_HOST=0.0.0.0
APP_PORT=5000
SECRET_KEY=change_this_secret
LOG_LEVEL=INFO
```

6. **Systemd Service**
```ini
[Unit]
Description=GHOST VPN Monitor
After=network.target

[Service]
User=ghostuser
Group=ghostuser
WorkingDirectory=/opt/ghost-monitor
EnvironmentFile=/opt/ghost-monitor/.env
ExecStart=/opt/ghost-monitor/venv/bin/gunicorn -w 3 -b 127.0.0.1:5000 wsgi:app
Restart=always

[Install]
WantedBy=multi-user.target
```

---

## 🌐 Access Panel
- **HTTP:** http://your-server-ip:5000  
- **HTTPS:** https://your-server-ip:5000 *(if SSL enabled)*

---

## 🔒 SSL (Nginx + Certbot)
```bash
sudo apt install -y nginx certbot python3-certbot-nginx
sudo certbot --nginx -d example.com
```

---

## 🌈 UI & Animations
```css
:root{
  --bg:#07111a;
  --panel:#0f1b23;
  --accent:#00bfff;
  --muted:#9aa6b2;
}
body{background:linear-gradient(180deg,var(--bg),#071827); color:var(--muted); font-family:Inter, sans-serif;}
.neon { color: var(--accent); text-shadow: 0 0 6px rgba(0,191,255,0.12), 0 6px 18px rgba(0,191,255,0.06); }
```
```js
const config = {
  type: 'line',
  data: { labels: times, datasets: [{ label: 'Download', data: values, borderColor: '#00bfff', fill: true }] },
  options: { animation: { duration: 800, easing: 'easeOutQuart' } }
}
```

---

## 👨‍💻 Author
**SL Nero-AI** — [GitHub](https://github.com/SLNeroAi)  
MIT License — Non-commercial use only.

<p align="center">
  <img src="https://img.shields.io/badge/Built%20With-Python%20%7C%20Flask-blue?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Designed%20For-Ubuntu%20%7C%20Debian-orange?style=for-the-badge"/>
</p>
