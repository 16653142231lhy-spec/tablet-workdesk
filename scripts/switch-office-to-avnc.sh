#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

mkdir -p "$HOME/tablet-workdesk"

cat > "$HOME/tablet-workdesk/office-avnc.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

am force-stop com.gaurav.avnc >/dev/null 2>&1 || true
"$HOME/tablet-workdesk/office-vnc.sh" --quiet
nohup sh -c 'sleep 1; am start -n com.gaurav.avnc/.UriReceiverActivity -a android.intent.action.VIEW -d "vnc://127.0.0.1:5901" >/dev/null 2>&1' >/dev/null 2>&1 &
echo "Workdesk ready via AVNC"
EOF

chmod +x "$HOME/tablet-workdesk/office-avnc.sh"

cat > "$PREFIX/bin/office" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec "$HOME/tablet-workdesk/office-avnc.sh" "$@"
EOF

chmod +x "$PREFIX/bin/office"

cat > /sdcard/Download/tablet-workdesk-usage.txt <<'EOF'
Tablet Workdesk

Main command:
  office

Main client:
  AVNC

Stop:
  office-stop

Status:
  office-status

Fallback direct VNC:
  office-vnc
  Address: 127.0.0.1
  Port: 5901
  Password: none
EOF

echo "switch_ok" > /sdcard/Download/office-avnc-switch.txt
office
