# Maintainer Workflow

Use this checklist before tagging a release.

## Local Checks

Run from the repository root:

```sh
bash scripts/check-repo.sh
```

On Windows PowerShell:

```powershell
.\scripts\check-repo.ps1
```

## Release Checklist

- Review installer changes manually.
- Run syntax checks.
- Confirm README install flow still matches script behavior.
- Update troubleshooting docs if a failure mode changed.
- Create or update a compatibility note for any tested device.
- Tag a release only after the public branch passes checks.
- Upload release notes that mention user-visible changes and known limits.

## Issue Triage

For device-specific reports, ask for:

- Android version.
- Termux source.
- Client app.
- Command and log excerpt.
- Whether the issue occurs in `office-vnc` or only in `office`.

## Public Maintenance Signals

Keep these current so users and reviewers can understand the project state:

- README and install guide.
- Roadmap issues.
- Changelog.
- Device compatibility table.
- Security notes.
- Release tags.
