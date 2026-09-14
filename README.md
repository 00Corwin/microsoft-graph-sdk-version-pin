# Microsoft Graph SDK Version Pin

A PowerShell maintenance script for rolling back or pinning the Microsoft Graph
PowerShell SDK to a known version.

The script was created around a version-regression scenario and has been
sanitised so it contains no server names or tenant details.

## Example

Preview a rollback from `2.34.0` to `2.33.0`:

```powershell
.\Set-MicrosoftGraphSdkVersion.ps1 `
    -DesiredVersion 2.33.0 `
    -RemoveVersion 2.34.0 `
    -Scope AllUsers `
    -WhatIf
```

Remove `-WhatIf` after review.

## Notes

Close other PowerShell sessions that may have Graph modules loaded. Test the
target version with the scripts that depend on the Graph SDK before restoring
normal update processes.
