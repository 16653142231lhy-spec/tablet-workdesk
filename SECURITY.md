# Security Policy

Tablet Workdesk starts local desktop services inside Termux and Debian proot.
The default configuration binds VNC and noVNC to `127.0.0.1`.

## Supported Scope

Security reports are in scope when they affect:

- Local VNC/noVNC exposure.
- Installer behavior that could unexpectedly run remote code.
- Unsafe file permissions created by the scripts.
- Sensitive data leakage through logs or generated files.

## Reporting

Please open a GitHub issue if the report does not contain private exploit
details. If it does, contact the maintainer privately first and provide:

- A short impact summary.
- Reproduction steps.
- Affected script or command.
- Suggested mitigation, if known.

## User Responsibilities

- Review scripts before running them.
- Do not expose VNC/noVNC ports to a public network without authentication.
- Do not run the installer on a device that contains sensitive data unless you
  are comfortable with Termux package installation and Debian proot setup.
