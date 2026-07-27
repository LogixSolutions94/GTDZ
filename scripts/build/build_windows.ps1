<#
GTDZ - Build headless Windows.
Prérequis : templates d'export installés une première fois via l'éditeur Godot
(Éditeur > Gérer les modèles d'export > Télécharger et installer).
Usage :
    powershell -ExecutionPolicy Bypass -File scripts\build\build_windows.ps1
Si Godot n'est pas dans le PATH, définir GODOT_PATH vers l'exécutable.
#>
$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

$godotExe = $env:GODOT_PATH
if (-not $godotExe) {
    $cmd = Get-Command godot -ErrorAction SilentlyContinue
    if ($cmd) { $godotExe = $cmd.Source }
}
if (-not $godotExe) {
    throw "Godot introuvable. Ajoute-le au PATH ou definis GODOT_PATH (ex: `$env:GODOT_PATH='C:\...\Godot_v4.5-stable_win64.exe')."
}

New-Item -ItemType Directory -Force "$repo\builds\windows" | Out-Null
Write-Host ">> Export Windows Desktop..." -ForegroundColor Cyan
& $godotExe --headless --path "$repo\game" --export-release "Windows Desktop" "$repo\builds\windows\GTDZ.exe"
if ($LASTEXITCODE -ne 0) { throw "Export Godot en echec (code $LASTEXITCODE). Templates installes ?" }

Write-Host "Build OK : builds\windows\GTDZ.exe" -ForegroundColor Green
