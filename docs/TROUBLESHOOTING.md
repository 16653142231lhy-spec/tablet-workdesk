# Troubleshooting

This page collects checks that help turn device-specific failures into
reproducible issues.

## First Checks

Run these inside Termux:

```sh
office-status
```

If the desktop fails to start, inspect logs:

```sh
ls -la ~/tablet-workdesk/logs
cat ~/tablet-workdesk/logs/office-vnc.log
cat ~/tablet-workdesk/logs/office-novnc.log
```

## VNC Port Does Not Open

Check whether port `5901` is listening:

```sh
cat /proc/net/tcp /proc/net/tcp6 | grep -i ':170D'
```

If it is missing, stop stale processes and retry:

```sh
office-stop
office-vnc
```

## noVNC Port Does Not Open

Check whether port `6080` is listening:

```sh
cat /proc/net/tcp /proc/net/tcp6 | grep -i ':17C0'
```

Then open this URL on the same Android device:

```text
http://127.0.0.1:6080/vnc.html
```

## AVNC Does Not Open Automatically

Confirm AVNC is installed and its package name is available:

```sh
cmd package list packages | grep -i avnc
```

If automatic launch fails, use the direct VNC profile in AVNC:

```text
Host: 127.0.0.1
Port: 5901
Password: none
```

## Keyboard Or Mouse Input Is Unstable

Use the VNC/noVNC path instead of Termux:X11. The project defaults to this
because Android or the browser handles input first.

When opening an issue, include:

- Android version.
- Tablet model and RAM.
- Termux source and version.
- Client app: AVNC, Chrome/noVNC, or another VNC viewer.
- The command that failed.
- The relevant log excerpt.
