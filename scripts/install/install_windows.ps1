<#
GTDZ - Installation des outils de développement (Windows 11).
Installe via winget : Git, Python 3.12, Godot 4.x, Blender,
puis crée l'environnement Python .venv avec les dépendances de osm/.
N'exécute rien d'autre. À lancer dans PowerShell (admin conseillé) :
    powershell -ExecutionPolicy Bypass -File scripts\install\install_windows.ps1
#>
$ErrorActionPreference = "Stop"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget introuvable. Installer 'App Installer' depuis le Microsoft Store, puis relancer."
}

function Install-WingetPackage {
    param([string]$Id, [string]$Name)
    Write-Host ">> $Name..." -ForegroundColor Cyan
    winget list --id $Id -e --accept-source-agreements | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   deja installe, on passe."
        return
    }
    winget install --id $Id -e --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "Echec d'installation de $Name (winget code $LASTEXITCODE)." }
}

Install-WingetPackage -Id "Git.Git" -Name "Git"
Install-WingetPackage -Id "Python.Python.3.12" -Name "Python 3.12"
Install-WingetPackage -Id "GodotEngine.GodotEngine" -Name "Godot Engine 4.x (GDScript)"
Install-WingetPackage -Id "BlenderFoundation.Blender" -Name "Blender"

# Environnement Python du projet (outils OSM).
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Warning "python pas encore dans le PATH (terminal a rouvrir). Relance ce script ensuite pour creer .venv."
    exit 0
}
Write-Host ">> Environnement Python .venv..." -ForegroundColor Cyan
python -m venv "$repo\.venv"
& "$repo\.venv\Scripts\python.exe" -m pip install --upgrade pip
& "$repo\.venv\Scripts\python.exe" -m pip install -r "$repo\osm\requirements.txt"

Write-Host ""
Write-Host "Installation terminee." -ForegroundColor Green
Write-Host "Etapes suivantes : ouvrir game\project.godot dans Godot (F5 pour jouer)."
Write-Host "Voir docs\01_setup.md pour la suite (build, VPS, OSM)."
