<#
.SYNOPSIS
    Pins the Microsoft Graph PowerShell SDK to a specified version.

.DESCRIPTION
    Unloads imported Microsoft.Graph modules, optionally removes an explicitly
    specified problem version from installed Microsoft.Graph packages, installs
    the requested umbrella Microsoft.Graph version, and verifies the result.

.PARAMETER DesiredVersion
    Microsoft.Graph version to install.

.PARAMETER RemoveVersion
    Specific version to remove before installation.

.PARAMETER Scope
    PowerShellGet installation scope.

.EXAMPLE
    .\Set-MicrosoftGraphSdkVersion.ps1 `
        -DesiredVersion 2.33.0 `
        -RemoveVersion 2.34.0 `
        -WhatIf
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [version]$DesiredVersion,

    [version]$RemoveVersion,

    [ValidateSet('CurrentUser','AllUsers')]
    [string]$Scope = 'AllUsers'
)

if (-not (Get-Command Get-InstalledModule -ErrorAction SilentlyContinue)) {
    throw 'PowerShellGet is required.'
}

# Unload current Graph modules from this PowerShell process.
Get-Module Microsoft.Graph* |
    Sort-Object Name -Descending |
    Remove-Module -Force -ErrorAction SilentlyContinue

if ($RemoveVersion) {
    $InstalledToRemove = @(
        Get-InstalledModule -Name 'Microsoft.Graph*' -AllVersions -ErrorAction SilentlyContinue |
            Where-Object { $_.Version -eq $RemoveVersion }
    )

    foreach ($Module in $InstalledToRemove) {
        $Target = "$($Module.Name) $($Module.Version)"

        if ($PSCmdlet.ShouldProcess($Target, 'Uninstall module version')) {
            Uninstall-Module `
                -Name $Module.Name `
                -RequiredVersion $Module.Version `
                -Force `
                -ErrorAction Stop
        }
    }
}

if ($PSCmdlet.ShouldProcess("Microsoft.Graph $DesiredVersion", "Install module in $Scope scope")) {
    Install-Module `
        -Name Microsoft.Graph `
        -RequiredVersion $DesiredVersion `
        -Scope $Scope `
        -AllowClobber `
        -Force `
        -ErrorAction Stop
}

$Installed = @(
    Get-InstalledModule -Name 'Microsoft.Graph*' -AllVersions -ErrorAction SilentlyContinue |
        Sort-Object Name, Version
)

$Installed |
    Select-Object Name, Version, InstalledLocation |
    Format-Table -AutoSize

$Umbrella = $Installed |
    Where-Object {
        $_.Name -eq 'Microsoft.Graph' -and
        $_.Version -eq $DesiredVersion
    } |
    Select-Object -First 1

if (-not $Umbrella -and -not $WhatIfPreference) {
    throw "Microsoft.Graph $DesiredVersion was not found after installation."
}

Write-Output "Requested Microsoft.Graph version: $DesiredVersion"
