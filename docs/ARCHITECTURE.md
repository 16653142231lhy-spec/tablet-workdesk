# Architecture

Tablet Workdesk is a small orchestration layer around existing open-source
components. It does not replace Termux, Debian, TigerVNC, noVNC, websockify, or
AVNC. It gives them a repeatable default shape for low-cost Android tablets.

## Runtime Layers

1. Android owns the physical device, display, Bluetooth keyboard, mouse, and
   client apps.
2. Termux provides the package manager, command entry points, and Android bridge.
3. Debian proot provides the Linux desktop environment and office tools.
4. TigerVNC serves the XFCE desktop on localhost.
5. AVNC or noVNC connects to the local VNC server.

## Main Commands

- `office` starts the default client path.
- `office-vnc` starts only the direct VNC path.
- `office-stop` stops VNC/noVNC and desktop processes.
- `office-status` prints process and port status.
- `debian` opens the Debian proot shell.
- `bakoffice` creates a Debian rootfs backup archive.
- `upoffice` updates packages and noVNC/websockify sources.

## Security Model

The default VNC and noVNC services bind to `127.0.0.1`. This makes the
passwordless VNC mode acceptable for a local-device workflow. If a user changes
the bind address, they must add authentication and understand the network risk.

## Why VNC First

Termux:X11 can render a native desktop, but on some tablets input is less
reliable when routed through Termux:X11. VNC/noVNC lets Android or the browser
own input first, which is often more stable with Bluetooth keyboards and mice.

## Update Boundaries

The installer currently resets noVNC and websockify to the latest upstream HEAD
when updating. Future releases should add pinned version profiles for better
reproducibility.
