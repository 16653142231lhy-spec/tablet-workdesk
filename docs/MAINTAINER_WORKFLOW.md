# Maintainer Workflow

Use this checklist before tagging a release.

## Local Checks

Run from the repository root:

```sh
bash -n scripts/install-tablet-workdesk.sh
bash -n scripts/finalize-office-lite-avnc.sh
bash -n scripts/switch-office-to-avnc.sh
bash -n scripts/tune-office-light.sh
```

On Windows PowerShell:

```powershell
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
  "$PWD\scripts\deploy-to-tablet.ps1",
  [ref]$tokens,
  [ref]$errors
) > $null
if ($errors.Count) { $errors; exit 1 }
```

Check shell scripts keep LF line endings:

```sh
if grep -RIl $'\r' scripts/*.sh; then
  echo "CRLF found in shell scripts"
  exit 1
fi
```

## Release Checklist

- Review installer changes manually.
- Run syntax checks.
- Confirm README install flow still matches script behavior.
- Update troubleshooting docs if a failure mode changed.
- Create or update a compatibility note for any tested device.
- Tag a release only after the public branch passes checks.

## Issue Triage

For device-specific reports, ask for:

- Android version.
- Termux source.
- Client app.
- Command and log excerpt.
- Whether the issue occurs in `office-vnc` or only in `office`.
