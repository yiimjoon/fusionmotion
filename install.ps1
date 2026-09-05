[CmdletBinding()]
param([switch]$PackageOnly)
$ErrorActionPreference = "Stop"
$sourceDir = Join-Path $PSScriptRoot "package/Edit"
$macroSourceDir = Join-Path $PSScriptRoot "package/Fusion/Macros"
$distDir = Join-Path $PSScriptRoot "dist"
$zipPath = Join-Path $distDir "FusionMotion.zip"
$drfx = Join-Path $distDir "FusionMotion.drfx"
foreach ($source in @($sourceDir, $macroSourceDir)) {
    if (!(Test-Path -LiteralPath $source -PathType Container)) { throw "Missing package folder: $source" }
}
if (!$PackageOnly) {
    $targetDir = Join-Path $env:APPDATA "Blackmagic Design/DaVinci Resolve/Support/Fusion/Templates/Edit"
    $macroTargetDir = Join-Path $env:APPDATA "Blackmagic Design/DaVinci Resolve/Support/Fusion/Macros"
    New-Item -ItemType Directory -Force -Path $targetDir, $macroTargetDir | Out-Null
    Copy-Item -Path (Join-Path $sourceDir "*") -Destination $targetDir -Recurse -Force
    Copy-Item -Path (Join-Path $macroSourceDir "*") -Destination $macroTargetDir -Recurse -Force
    Write-Host "Installed Edit presets: $targetDir"
    Write-Host "Installed Fusion macros (including CodexTypo): $macroTargetDir"
}
New-Item -ItemType Directory -Force -Path $distDir | Out-Null
foreach ($artifact in @($zipPath, $drfx)) {
    if (Test-Path -LiteralPath $artifact) { Remove-Item -LiteralPath $artifact -Force }
}
Compress-Archive -LiteralPath $sourceDir -DestinationPath $zipPath -Force
Rename-Item -LiteralPath $zipPath -NewName (Split-Path $drfx -Leaf)
Write-Host "Created Edit-only DRFX: $drfx"
Write-Host "Fusion macros are installed separately by this script (without -PackageOnly)."
