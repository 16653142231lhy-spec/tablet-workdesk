#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

log() {
  printf '\n[tablet-workdesk] %s\n' "$*"
}

APP_ROOT="$HOME/tablet-workdesk"
LOG_DIR="$APP_ROOT/logs"
SHARE_DIR="$HOME/linux-share"
DEBIAN_NAME="debian"
DOWNLOAD_DIR="/sdcard/Download"

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

mkdir -p "$APP_ROOT" "$LOG_DIR" "$SHARE_DIR"
chmod 700 "$SHARE_DIR"

log "Install Termux packages"
pkg update -y
pkg upgrade -y
pkg install -y proot-distro pulseaudio git curl wget python procps net-tools

if [ ! -d "$PREFIX/var/lib/proot-distro/installed-rootfs/$DEBIAN_NAME" ]; then
  log "Install Debian rootfs"
  proot-distro install "$DEBIAN_NAME"
else
  log "Debian rootfs already exists"
fi

log "Write Debian bootstrap"
cat > "$SHARE_DIR/tablet-workdesk-debian-setup.sh" <<'DEBIAN_SETUP'
#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

clone_or_update() {
  local url="$1"
  local dir="$2"

  if [ -d "$dir/.git" ]; then
    git -C "$dir" fetch --depth 1 origin
    git -C "$dir" reset --hard FETCH_HEAD
  else
    rm -rf "$dir"
    git clone --depth 1 "$url" "$dir"
  fi
}

apt update
apt full-upgrade -y
apt install -y \
  xfce4 xfce4-terminal dbus-x11 \
  tigervnc-standalone-server tigervnc-common \
  xauth x11-utils x11-xserver-utils \
  thunar gvfs file-roller p7zip-full unzip zip \
  libreoffice libreoffice-l10n-zh-cn firefox-esr \
  fonts-noto-cjk fonts-noto-color-emoji \
  fcitx5 fcitx5-chinese-addons fcitx5-frontend-gtk3 fcitx5-frontend-qt5 \
  git curl wget ca-certificates python3 locales procps net-tools

if grep -q '^# *zh_CN.UTF-8 UTF-8' /etc/locale.gen 2>/dev/null; then
  sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
fi
locale-gen zh_CN.UTF-8 || true
update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 || true

mkdir -p /opt /root/.config/autostart /root/.config/tigervnc /tmp/runtime-root
chmod 700 /root/.config/tigervnc /tmp/runtime-root

clone_or_update https://github.com/novnc/noVNC.git /opt/novnc
mkdir -p /opt/novnc/utils
clone_or_update https://github.com/novnc/websockify.git /opt/novnc/utils/websockify

cat > /root/.config/autostart/light-locker.desktop <<'LOCKER'
[Desktop Entry]
Type=Application
Name=Light Locker
Exec=true
Hidden=true
X-GNOME-Autostart-enabled=false
LOCKER

cat > /root/.config/tigervnc/xstartup <<'XSTARTUP'
#!/usr/bin/env bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export USER=root
export HOME=/root
export DISPLAY=:2
export XAUTHORITY=/root/.Xauthority
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
export XDG_RUNTIME_DIR=/tmp/runtime-root
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SAL_USE_VCLPLUGIN=gtk3
export NO_AT_BRIDGE=1
export LIBGL_ALWAYS_SOFTWARE=1
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
fcitx5 -d >/dev/null 2>&1 || true
exec dbus-launch --exit-with-session startxfce4
XSTARTUP
chmod +x /root/.config/tigervnc/xstartup

cat > /usr/local/bin/tablet-workdesk-vnc-run <<'VNC_RUN'
#!/usr/bin/env bash
set -euo pipefail
export USER=root
export HOME=/root
export DISPLAY=:2
export XAUTHORITY=/root/.Xauthority
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p /root/.config/tigervnc /tmp/runtime-root /tmp/.X11-unix
chmod 700 /root/.config/tigervnc /tmp/runtime-root

pkill -f 'Xtigervnc :2' >/dev/null 2>&1 || true
rm -f /tmp/.X2-lock /tmp/.X11-unix/X2 /root/.config/tigervnc/office-vnc.log /root/.config/tigervnc/xstartup.log "$XAUTHORITY"
touch "$XAUTHORITY"
chmod 600 "$XAUTHORITY"
COOKIE="$(mcookie)"
xauth -f "$XAUTHORITY" add :2 . "$COOKIE"
xauth -f "$XAUTHORITY" add "$(hostname)/unix:2" . "$COOKIE" || true
xauth -f "$XAUTHORITY" add localhost/unix:2 . "$COOKIE" || true

Xtigervnc :2 \
  -interface 127.0.0.1 \
  -localhost=1 \
  -UseIPv6=0 \
  -rfbport 5901 \
  -SecurityTypes None \
  -geometry 1920x1200 \
  -depth 16 \
  -desktop 'Tablet Workdesk' \
  -AlwaysShared \
  -DisconnectClients=0 \
  -FrameRate=30 \
  -CompareFB=2 \
  -auth "$XAUTHORITY" \
  > /root/.config/tigervnc/office-vnc.log 2>&1 &
XVNC_PID=$!

for _ in $(seq 1 50); do
  [ -S /tmp/.X11-unix/X2 ] && break
  kill -0 "$XVNC_PID" 2>/dev/null || {
    cat /root/.config/tigervnc/office-vnc.log >&2
    exit 4
  }
  sleep 0.2
done

DISPLAY=:2 XAUTHORITY="$XAUTHORITY" /root/.config/tigervnc/xstartup > /root/.config/tigervnc/xstartup.log 2>&1 &
XSTART_PID=$!

trap 'kill "$XSTART_PID" "$XVNC_PID" 2>/dev/null || true; rm -f /tmp/.X2-lock /tmp/.X11-unix/X2' INT TERM EXIT
wait "$XVNC_PID"
VNC_RUN
chmod +x /usr/local/bin/tablet-workdesk-vnc-run

cat > /usr/local/bin/tablet-workdesk-novnc-run <<'NOVNC_RUN'
#!/usr/bin/env bash
set -euo pipefail
pkill -f 'websockify.*127.0.0.1:6080' >/dev/null 2>&1 || true
exec /opt/novnc/utils/websockify/run --web /opt/novnc 127.0.0.1:6080 127.0.0.1:5901
NOVNC_RUN
chmod +x /usr/local/bin/tablet-workdesk-novnc-run

cat > /usr/local/bin/tablet-workdesk-update-github <<'UPDATE_GH'
#!/usr/bin/env bash
set -euo pipefail
git -C /opt/novnc fetch --depth 1 origin
git -C /opt/novnc reset --hard FETCH_HEAD
git -C /opt/novnc/utils/websockify fetch --depth 1 origin
git -C /opt/novnc/utils/websockify reset --hard FETCH_HEAD
UPDATE_GH
chmod +x /usr/local/bin/tablet-workdesk-update-github

apt clean
DEBIAN_SETUP
chmod +x "$SHARE_DIR/tablet-workdesk-debian-setup.sh"

log "Bootstrap Debian packages and official GitHub components"
proot-distro login "$DEBIAN_NAME" --isolated --bind "$SHARE_DIR:/mnt/share" -- bash /mnt/share/tablet-workdesk-debian-setup.sh

log "Clean old experiment wrappers"
rm -f \
  "$HOME/start-office.sh" \
  "$HOME/app-store.sh" \
  "$HOME/office-menu.sh" \
  "$HOME/xfce-start-stable.sh" \
  "$HOME/office-novnc" \
  "$HOME/office-novnc-stop" \
  "$HOME/office-novnc-status" \
  "$HOME/office-vnc" \
  "$HOME/office-vnc-stop" \
  "$HOME/office-vnc-status" \
  "$HOME/debian.sh" \
  "$HOME/install-app.sh" \
  "$HOME/search-app.sh" \
  "$HOME/update-office-linux.sh" \
  "$HOME/backup-office-linux.sh"

rm -f \
  "$PREFIX/bin/office" \
  "$PREFIX/bin/menu" \
  "$PREFIX/bin/apps" \
  "$PREFIX/bin/debian" \
  "$PREFIX/bin/i" \
  "$PREFIX/bin/s" \
  "$PREFIX/bin/bakoffice" \
  "$PREFIX/bin/upoffice" \
  "$PREFIX/bin/office-novnc" \
  "$PREFIX/bin/office-novnc-stop" \
  "$PREFIX/bin/office-novnc-status" \
  "$PREFIX/bin/office-vnc" \
  "$PREFIX/bin/office-vnc-stop" \
  "$PREFIX/bin/office-vnc-status" \
  "$PREFIX/bin/vncoffice" \
  "$PREFIX/bin/stopvnc"

log "Write final Termux-side commands"
cat > "$APP_ROOT/office-vnc.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

quiet="${1:-}"
mkdir -p "$HOME/tablet-workdesk/logs" "$HOME/linux-share"

proot-distro login debian --isolated -- bash -lc 'pkill -f "Xtigervnc :2|tablet-workdesk-vnc-run" >/dev/null 2>&1 || true; rm -f /tmp/.X2-lock /tmp/.X11-unix/X2' || true
nohup proot-distro login debian --isolated --bind "$HOME/linux-share:/mnt/share" -- /usr/local/bin/tablet-workdesk-vnc-run > "$HOME/tablet-workdesk/logs/office-vnc.log" 2>&1 &
sleep 6

if ! cat /proc/net/tcp /proc/net/tcp6 2>/dev/null | grep -qi ':170D'; then
  echo "VNC backend failed to start. Run: office-status"
  exit 4
fi

if [ "$quiet" != "--quiet" ]; then
  cat <<'STATUS'
Direct VNC ready
  Address: 127.0.0.1
  Port: 5901
  Password: none
STATUS
fi
EOF

cat > "$APP_ROOT/office-novnc.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

URL='http://127.0.0.1:6080/vnc.html?autoconnect=1&resize=scale&host=127.0.0.1&port=6080'
mkdir -p "$HOME/tablet-workdesk/logs" "$HOME/linux-share"

"$HOME/tablet-workdesk/office-vnc.sh" --quiet
proot-distro login debian --isolated -- bash -lc 'pkill -f "websockify.*127.0.0.1:6080" >/dev/null 2>&1 || true' || true
nohup proot-distro login debian --isolated -- /usr/local/bin/tablet-workdesk-novnc-run > "$HOME/tablet-workdesk/logs/office-novnc.log" 2>&1 &
sleep 3

if ! cat /proc/net/tcp /proc/net/tcp6 2>/dev/null | grep -qi ':17C0'; then
  echo "noVNC bridge failed to start. Run: office-status"
  exit 5
fi

am start -a android.intent.action.VIEW -d "$URL" >/dev/null 2>&1 || true

cat <<EOF2
Workdesk ready
  Browser URL: $URL
  Main command: office
  Stop command: office-stop
EOF2
EOF

cat > "$APP_ROOT/office-stop.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

proot-distro login debian --isolated -- bash -lc 'pkill -f "websockify.*127.0.0.1:6080" >/dev/null 2>&1 || true; pkill -f "Xtigervnc :2|tablet-workdesk-vnc-run" >/dev/null 2>&1 || true; rm -f /tmp/.X2-lock /tmp/.X11-unix/X2' || true
echo "Workdesk stopped."
EOF

cat > "$APP_ROOT/office-avnc.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

am force-stop com.gaurav.avnc >/dev/null 2>&1 || true
"$HOME/tablet-workdesk/office-vnc.sh" --quiet
# Delay foreground launch until this shell returns, so Termux does not steal focus back.
nohup sh -c 'sleep 1; am start -n com.gaurav.avnc/.UriReceiverActivity -a android.intent.action.VIEW -d "vnc://127.0.0.1:5901" >/dev/null 2>&1' >/dev/null 2>&1 &

cat <<'EOF2'
Workdesk ready
  Client: AVNC
  Address: 127.0.0.1
  Port: 5901
EOF2
EOF

cat > "$APP_ROOT/office-status.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "== local ports =="
cat /proc/net/tcp /proc/net/tcp6 2>/dev/null | grep -Ei ':(170D|17C0)' || true
echo
echo "== processes =="
ps -A | grep -E 'Xtigervnc|websockify|xfce4-session|xfdesktop|xfwm4|xfce4-panel' || true
echo
echo "== termux logs =="
tail -60 "$HOME/tablet-workdesk/logs/office-vnc.log" 2>/dev/null || true
echo
tail -60 "$HOME/tablet-workdesk/logs/office-novnc.log" 2>/dev/null || true
echo
echo "== debian logs =="
proot-distro login debian --isolated -- bash -lc 'echo ---server---; tail -60 /root/.config/tigervnc/office-vnc.log 2>/dev/null || true; echo ---xstartup---; tail -60 /root/.config/tigervnc/xstartup.log 2>/dev/null || true'
EOF

cat > "$APP_ROOT/debian.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec proot-distro login debian --isolated --bind "$HOME/linux-share:/mnt/share"
EOF

cat > "$APP_ROOT/install-app.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
if [ "$#" -eq 0 ]; then
  echo "usage: i <package> [package ...]"
  exit 1
fi
exec proot-distro login debian --isolated -- apt install -y "$@"
EOF

cat > "$APP_ROOT/search-app.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
if [ "$#" -eq 0 ]; then
  echo "usage: s <keyword>"
  exit 1
fi
exec proot-distro login debian --isolated -- apt-cache search "$*"
EOF

cat > "$APP_ROOT/bakoffice.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
out="$HOME/linux-share/debian-tablet-workdesk-$(date +%Y%m%d-%H%M%S).tar.xz"
proot-distro backup debian --output "$out"
echo "Backup written: $out"
EOF

cat > "$APP_ROOT/upoffice.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
pkg update -y
pkg upgrade -y
proot-distro login debian --isolated -- bash -lc 'apt update && apt full-upgrade -y && /usr/local/bin/tablet-workdesk-update-github && apt clean'
echo "Tablet workdesk updated."
EOF

chmod +x \
  "$APP_ROOT/office-vnc.sh" \
  "$APP_ROOT/office-novnc.sh" \
  "$APP_ROOT/office-avnc.sh" \
  "$APP_ROOT/office-stop.sh" \
  "$APP_ROOT/office-status.sh" \
  "$APP_ROOT/debian.sh" \
  "$APP_ROOT/install-app.sh" \
  "$APP_ROOT/search-app.sh" \
  "$APP_ROOT/bakoffice.sh" \
  "$APP_ROOT/upoffice.sh"

for pair in \
  "office office-avnc.sh" \
  "office-stop office-stop.sh" \
  "office-status office-status.sh" \
  "office-vnc office-vnc.sh" \
  "debian debian.sh" \
  "i install-app.sh" \
  "s search-app.sh" \
  "bakoffice bakoffice.sh" \
  "upoffice upoffice.sh"
do
  set -- $pair
  cat > "$PREFIX/bin/$1" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
exec "\$HOME/tablet-workdesk/$2" "\$@"
EOF
  chmod +x "$PREFIX/bin/$1"
done

log "Write user-facing usage note"
cat > "$DOWNLOAD_DIR/tablet-workdesk-usage.txt" <<'EOF'
Tablet Workdesk

Main command:
  office

Stop:
  office-stop

Status:
  office-status

Fallback direct VNC:
  office-vnc
  Address: 127.0.0.1
  Port: 5901
  Password: none

Other commands:
  debian
  i <package>
  s <keyword>
  bakoffice
  upoffice

Main path:
  AVNC opens local VNC session automatically.
EOF

rm -f \
  "$DOWNLOAD_DIR/finish-office-linux.sh" \
  "$DOWNLOAD_DIR/pkg.sh" \
  "$DOWNLOAD_DIR/termux-office-usage.txt" \
  "$DOWNLOAD_DIR/termux-office-status.txt" \
  "$DOWNLOAD_DIR/termux-office-ux-status.txt" \
  "$DOWNLOAD_DIR/termux-office-gui-status.txt" \
  "$DOWNLOAD_DIR/termux-office-command-status.txt" \
  "$DOWNLOAD_DIR/office-vnc-status.txt" \
  "$DOWNLOAD_DIR/office-novnc-status.txt" \
  "$DOWNLOAD_DIR/office-vnc-debug.txt" \
  "$DOWNLOAD_DIR/office-vnc-direct-debug.txt" \
  "$DOWNLOAD_DIR/office-vnc-live-debug.txt" \
  "$DOWNLOAD_DIR/termux-x11-mouse-fix.txt" \
  "$DOWNLOAD_DIR/termux-x11-office-final.txt" \
  "$DOWNLOAD_DIR/termux-x11-office-stabilize.txt"

log "Install finished"
echo
echo "Run: office"
echo "Usage note: $DOWNLOAD_DIR/tablet-workdesk-usage.txt"
