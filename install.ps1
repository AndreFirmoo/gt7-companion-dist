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

# Origin EXATA da plataforma web (sem barra final — é o que o navegador envia).
# O companion lê isto de <data_dir>/config.json; data_dir = %USERPROFILE%\.gt7-companion.
$webOrigin = "https://telemetry.nerdhelpsolucoes.com"

New-Item -ItemType Directory -Force -Path $dir | Out-Null

Write-Host "Baixando $asset ..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $bin

# remove a "marca da web" para reduzir o aviso do SmartScreen (binário não assinado)
Unblock-File -Path $bin -ErrorAction SilentlyContinue

# aponta o companion para a plataforma web (senão o navegador é bloqueado por CORS/PNA).
# WriteAllText grava UTF-8 SEM BOM — o json.load do companion não tolera BOM.
$dataDir = Join-Path $env:USERPROFILE ".gt7-companion"
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
$config = '{ "web_origins": ["' + $webOrigin + '"] }'
[System.IO.File]::WriteAllText((Join-Path $dataDir "config.json"), $config)
Write-Host "Conectado à plataforma: $webOrigin" -ForegroundColor Green

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
