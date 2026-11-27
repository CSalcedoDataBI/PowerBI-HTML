<#
.SYNOPSIS
  Fails when a package's report uses a custom visual it does not register.

.DESCRIPTION
  Every visual.json whose visualType is a public custom visual (an id ending in a
  32-character hex GUID, such as deneb… or htmlContent…) must be listed in the
  report's definition/report.json publicCustomVisuals. Otherwise Power BI shows
  "To see this custom visual, add it to this report first" on that page.
  Run it before presenting or pushing any package:
    pwsh -NoProfile -File tools/check-package.ps1 <VisualFolder>
#>
param([Parameter(Mandatory)][string]$Package)

$fail = 0
$reports = Get-ChildItem -Path $Package -Recurse -Directory -Filter '*.Report'
if (-not $reports) { Write-Error "No *.Report folder under $Package"; exit 2 }

foreach ($rep in $reports) {
  $reportJson = Join-Path $rep.FullName 'definition/report.json'
  if (-not (Test-Path $reportJson)) { continue }   # leftover folder (only a local .pbi cache)
  $registered = @((Get-Content $reportJson -Raw | ConvertFrom-Json).publicCustomVisuals)
  Get-ChildItem (Join-Path $rep.FullName 'definition/pages') -Recurse -Filter visual.json | ForEach-Object {
    $type = (Get-Content $_.FullName -Raw | ConvertFrom-Json).visual.visualType
    if ($type -match '[0-9A-F]{32}$' -and $registered -notcontains $type) {
      Write-Host "FAIL $($_.FullName): custom visual '$type' is not in publicCustomVisuals of $reportJson"
      $fail++
    }
  }
}

# The Thank You page and every link must point to this repo, never to the Deneb one.
Get-ChildItem -Path $Package -Recurse -Filter visual.json | Where-Object { $_.FullName -notmatch '\\\.pbi\\' } |
  Select-String -SimpleMatch 'PowerBI-Deneb' | ForEach-Object {
    Write-Host "FAIL $($_.Path): links to PowerBI-Deneb, not PowerBI-HTML"
    $fail++
  }

if ($fail) { exit 1 }
Write-Host "OK: every custom visual is registered"
