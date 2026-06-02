# Install

This guide describes the current supported install path.

## Before You Start

Use Termux from F-Droid or GitHub. The Google Play version of Termux is not a
supported target because it is outdated and restricted.

Recommended:

- Android tablet or phone.
- Hardware keyboard and mouse, if using it as a desk setup.
- Several GB of free storage.
- AVNC or Chrome installed on Android.
- Stable network during the first install.

Optional:

- A Windows PC with ADB for pushing the installer.

## Path A: Deploy From Windows With ADB

Connect the tablet with USB debugging enabled, then run:

```powershell
.\scripts\deploy-to-tablet.ps1 -OpenTermux
```

This pushes the installer to:

```text
/sdcard/Download/tw.sh
```

Then run inside Termux:

```sh
bash /sdcard/Download/tw.sh
```

## Path B: Manual Copy

Copy this file to the Android tablet:

```text
scripts/install-tablet-workdesk.sh
```

Save it as:

```text
/sdcard/Download/tw.sh
```

Then run inside Termux:

```sh
bash /sdcard/Download/tw.sh
```

## After Install

Start the main desktop path:

```sh
office
```

Check status:

```sh
office-status
```

Stop all desktop services:

```sh
office-stop
```

Use direct VNC fallback:

```sh
office-vnc
```

## Network Ports

Default ports are local-only:

| Service | Address | Port |
| --- | --- | ---: |
| VNC | `127.0.0.1` | `5901` |
| noVNC | `127.0.0.1` | `6080` |

Do not expose these ports to a public network without authentication.

## Expected Result

The installer creates a Debian proot desktop with XFCE, TigerVNC, noVNC,
websockify, common office tools, Chinese locale support, and simple Termux-side
commands.

## Uninstall

The project does not yet ship a full uninstall command. For now, remove the
created command wrappers and Debian proot rootfs manually only if you understand
the Termux paths involved. A safer uninstall command is tracked in the roadmap.
