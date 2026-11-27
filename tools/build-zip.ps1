<#
.SYNOPSIS
  Builds <Folder>/<Folder>.zip: pbip/ without the local .pbi caches, the loose measure and the README.
    pwsh -NoProfile -File tools/build-zip.ps1 <Folder>
#>
param([Parameter(Mandatory)][string]$Folder)
$src = Resolve-Path $Folder
$name = Split-Path $src -Leaf
$tmp = Join-Path ([IO.Path]::GetTempPath()) "zip-$name"
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory (Join-Path $tmp 'pbip') -Force | Out-Null
Copy-Item (Join-Path $src "pbip/$name.pbip") (Join-Path $tmp 'pbip')
foreach ($part in "$name.Report", "$name.SemanticModel") {
  robocopy (Join-Path $src "pbip/$part") (Join-Path $tmp "pbip/$part") /E /XD .pbi /NFL /NDL /NJH /NJS | Out-Null
}
Get-ChildItem $src -File -Include *.dax, README.md -Name | ForEach-Object { Copy-Item (Join-Path $src $_) $tmp }
Compress-Archive -Force -Path (Join-Path $tmp '*') -DestinationPath (Join-Path $src "$name.zip")
Write-Host "zip: $(Join-Path $src "$name.zip") ($([math]::Round((Get-Item (Join-Path $src "$name.zip")).Length / 1KB)) KB)"
