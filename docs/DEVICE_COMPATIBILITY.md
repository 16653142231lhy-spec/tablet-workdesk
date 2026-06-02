# Device Compatibility

Tablet Workdesk needs real device reports. Please add results through the
device report issue template.

## Compatibility Matrix

| Device | Android | RAM | Termux Source | Client | Result | Notes |
| --- | --- | ---: | --- | --- | --- | --- |
| Maintainer development device | Unknown | Unknown | F-Droid/GitHub Termux expected | AVNC / Chrome noVNC | In progress | Initial scripts were built from this local workflow. Public reports needed. |

## What To Report

- Device model.
- Android version.
- RAM and free storage.
- Termux source: F-Droid, GitHub, or another source.
- Client used: AVNC, Chrome/noVNC, direct VNC, or another VNC viewer.
- Whether `office`, `office-vnc`, `office-stop`, and `office-status` work.
- Any package, locale, or input-method failures.

## Target Profiles

- Standard profile: Debian + XFCE + LibreOffice + Firefox ESR.
- Lite profile: lower resolution, lower frame rate, no desktop icons.
- Planned minimal profile: no LibreOffice and no browser inside Debian.
