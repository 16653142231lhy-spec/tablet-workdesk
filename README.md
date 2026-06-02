# Tablet Workdesk

Tablet Workdesk turns an Android tablet into a lightweight Linux office desktop
using Termux, Debian proot, TigerVNC, noVNC, and AVNC/Chrome as clients.

It was built for low-cost study and development setups where a student may have
an Android tablet and keyboard, but not a full laptop. The goal is a repeatable
one-command workspace for writing documents, browsing, editing files, and using
basic Linux tools.

## Why This Exists

Termux:X11 is powerful, but input behavior can be unstable on some tablets when
Bluetooth keyboard and mouse events are routed through Android. Tablet Workdesk
uses VNC/noVNC as the main path so Android or the browser owns input first.

The current flow is:

- Main path: `office` opens an AVNC-backed desktop.
- Browser fallback: Chrome + noVNC on `127.0.0.1:6080`.
- Direct fallback: VNC on `127.0.0.1:5901`.
- Debug path: Termux:X11 is intentionally kept out of the default flow.

## Features

- Installs a Debian proot rootfs through Termux.
- Builds an XFCE desktop with Chinese locale and input support.
- Adds LibreOffice, Firefox ESR, file tools, fonts, and common utilities.
- Uses official noVNC and websockify sources from GitHub.
- Provides simple commands: `office`, `office-stop`, `office-status`,
  `office-vnc`, `debian`, `i`, `s`, `bakoffice`, and `upoffice`.
- Keeps VNC and noVNC bound to localhost by default.

## Requirements

- Android tablet or phone with Termux.
- Termux installed from F-Droid or GitHub, not Google Play.
- Optional but recommended: AVNC or Chrome.
- Optional for PC deployment: ADB and PowerShell.
- Several GB of free storage for Debian, XFCE, LibreOffice, and browser packages.

## Install

From a PC with ADB:

```powershell
.\scripts\deploy-to-tablet.ps1 -OpenTermux
```

Then run this inside Termux:

```sh
bash /sdcard/Download/tw.sh
```

Manual copy also works: place `scripts/install-tablet-workdesk.sh` on the
tablet as `/sdcard/Download/tw.sh`, then run the same Termux command above.

## Daily Use

Start the desktop:

```sh
office
```

Stop it:

```sh
office-stop
```

Check status:

```sh
office-status
```

Use direct VNC fallback:

```sh
office-vnc
```

## Repository Layout

- `scripts/install-tablet-workdesk.sh` is the main Termux-side installer.
- `scripts/deploy-to-tablet.ps1` pushes the installer through ADB.
- `scripts/finalize-office-lite-avnc.sh` switches an installed environment to
  the current AVNC-first lite path.
- `scripts/switch-office-to-avnc.sh` changes the main `office` command to AVNC.
- `scripts/tune-office-light.sh` applies lower-resource VNC/XFCE settings.

## Security Notes

The default VNC mode uses no password because it binds to localhost only. Do not
change the bind address to `0.0.0.0` unless you also add authentication and
understand the network exposure.

The installer downloads packages and clones upstream noVNC/websockify sources.
Review the script before running it on a device that contains sensitive data.

## Roadmap

- Add tested device profiles for low-RAM tablets.
- Add a minimal install profile without LibreOffice.
- Add screenshots and a short troubleshooting guide.
- Add shell lint checks and safer update rollback.

## Related Projects

- noVNC: https://github.com/novnc/noVNC
- websockify: https://github.com/novnc/websockify
- Termux: https://github.com/termux/termux-app
- AVNC: https://github.com/gujjwal00/avnc
