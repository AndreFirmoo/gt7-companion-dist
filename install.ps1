# Instalador do GT7 Companion — Windows.
#
# Baixa o .exe da última release, cria um atalho na Área de Trabalho e já abre.
# Rode de novo a qualquer momento para atualizar.
#
# Uso (cole no PowerShell):
#   irm https://raw.githubusercontent.com/AndreFirmoo/gt7-companion-dist/Master/install.ps1 | iex

$ErrorActionPreference = "Stop"

$repo  = "AndreFirmoo/gt7-companion-dist"
$asset = "gt7-companion-windows-x86_64.exe"
$dir   = Join-Path $env:LOCALAPPDATA "gt7-companion"
$bin   = Join-Path $dir "gt7-companion.exe"
$url   = "https://github.com/$repo/releases/latest/download/$asset"

New-Item -ItemType Directory -Force -Path $dir | Out-Null

Write-Host "Baixando $asset ..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $bin

# remove a "marca da web" para reduzir o aviso do SmartScreen (binário não assinado)
Unblock-File -Path $bin -ErrorAction SilentlyContinue

# atalho na Área de Trabalho
$desktop  = [Environment]::GetFolderPath("Desktop")
$shortcut = Join-Path $desktop "GT7 Companion.lnk"
$ws = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut($shortcut)
$lnk.TargetPath = $bin
$lnk.Description = "GT7 Companion"
$lnk.Save()

Write-Host "Instalado em: $bin" -ForegroundColor Green
Write-Host "Atalho criado: $shortcut" -ForegroundColor Green
Write-Host ""
Write-Host "Para usar: abra o GT7 no PS5 (mesma rede), depois abra a plataforma no Chrome ou Edge."
Write-Host "Abrindo agora..." -ForegroundColor Cyan
& $bin
