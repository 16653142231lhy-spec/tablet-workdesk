#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

mkdir -p "$HOME/tablet-workdesk/logs"

cat > "$HOME/tablet-workdesk/office-vnc.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

quiet="${1:-}"
mkdir -p "$HOME/tablet-workdesk/logs" "$HOME/linux-share"

pkill -f "termux-x11" >/dev/null 2>&1 || true
proot-distro login debian --isolated -- bash -lc 'pkill -f "websockify.*127.0.0.1:6080|Xtigervnc :2|tablet-workdesk-vnc-run|xfce4-session|xfwm4|xfdesktop|xfce4-panel" >/dev/null 2>&1 || true; rm -f /tmp/.X2-lock /tmp/.X11-unix/X2' || true

cat > "$HOME/linux-share/tablet-workdesk-vnc-lite.sh" <<'LITE'
#!/usr/bin/env bash
set -euo pipefail
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
exec dbus-launch --exit-with-session xfce4-session
XSTARTUP
chmod +x /root/.config/tigervnc/xstartup

cat > /usr/local/bin/tablet-workdesk-vnc-run <<'RUN'
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
  -geometry 1366x768 \
  -depth 16 \
  -desktop 'Tablet Workdesk Lite' \
  -AlwaysShared \
  -DisconnectClients=0 \
  -FrameRate=24 \
  -CompareFB=1 \
  -auth "$XAUTHORITY" \
  > /root/.config/tigervnc/office-vnc.log 2>&1 &
XVNC_PID=$!
for _ in $(seq 1 50); do
  [ -S /tmp/.X11-unix/X2 ] && break
  kill -0 "$XVNC_PID" 2>/dev/null || exit 4
  sleep 0.2
done
DISPLAY=:2 XAUTHORITY="$XAUTHORITY" /root/.config/tigervnc/xstartup > /root/.config/tigervnc/xstartup.log 2>&1 &
sleep 4
DISPLAY=:2 xfconf-query -c xfce4-desktop -p /desktop-icons/style -s 0 >/dev/null 2>&1 || true
DISPLAY=:2 xfconf-query -c xfwm4 -p /general/use_compositing -s false >/dev/null 2>&1 || true
pkill -f xfdesktop >/dev/null 2>&1 || true
trap 'pkill -f xfdesktop >/dev/null 2>&1 || true; kill "$XVNC_PID" 2>/dev/null || true; rm -f /tmp/.X2-lock /tmp/.X11-unix/X2' INT TERM EXIT
wait "$XVNC_PID"
RUN
chmod +x /usr/local/bin/tablet-workdesk-vnc-run
LITE
chmod +x "$HOME/linux-share/tablet-workdesk-vnc-lite.sh"

proot-distro login debian --isolated --bind "$HOME/linux-share:/mnt/share" -- bash /mnt/share/tablet-workdesk-vnc-lite.sh

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
  Mode: lite
STATUS
fi
EOF

chmod +x "$HOME/tablet-workdesk/office-vnc.sh"

echo "tune_ok" > /sdcard/Download/office-lite.txt
office
