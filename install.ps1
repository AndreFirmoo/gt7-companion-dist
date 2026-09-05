# Instalador do GT7 Companion — Windows.
#
# Baixa o .exe da release PINADA abaixo, confere o SHA256SUMS dela contra o hash embutido
# aqui, cria um atalho na Área de Trabalho e já abre. Atualizar = rodar o comando de
# instalação que a plataforma mostra (ele aponta para o instalador da versão nova).
#
# Uso: copie o comando da página da plataforma (app.apexracetelemetry.com.br → Companion). Ele
# referencia este script por um COMMIT fixo deste repositório — nunca por branch.

$ErrorActionPreference = "Stop"
# Windows PowerShell 5.1: sem isto o download pode cair em TLS 1.0 e ser recusado pelo GitHub
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo  = "AndreFirmoo/gt7-companion-dist"
$asset = "gt7-companion-windows-x86_64.exe"
$dir   = Join-Path $env:LOCALAPPDATA "gt7-companion"
$bin   = Join-Path $dir "gt7-companion.exe"
# Release que este instalador instala e o SHA-256 do SHA256SUMS dela (raiz de confiança).
# Preenchidos pela esteira de release (raceTelemetry, companion-release.yml, job `release`).
$releaseTag = "companion-v1.3.1"
$sumsSha256 = "c083a139fc8839e7fd469549cf90070686a29f18c732d14f1a8dcdec2aa03628"
$base = "https://github.com/$repo/releases/download/$releaseTag"

# Origin EXATA da plataforma web (sem barra final — é o que o navegador envia).
# O companion lê isto de <data_dir>/config.json; data_dir = %USERPROFILE%\.gt7-companion.
$webOrigin = "https://app.apexracetelemetry.com.br"

if (-not $sumsSha256) { throw "Este instalador não tem raiz de confiança (sumsSha256 vazio). Use o comando de instalação da plataforma." }
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$tmp  = "$bin.tmp"
$sums = Join-Path $dir "SHA256SUMS.tmp"
try {
  # manifesto primeiro: precisa bater com o hash embutido ANTES de qualquer binário
  Write-Host "Baixando o manifesto de integridade da release $releaseTag ..." -ForegroundColor Cyan
  Invoke-WebRequest -Uri "$base/SHA256SUMS" -OutFile $sums -UseBasicParsing
  $sumsActual = (Get-FileHash -Algorithm SHA256 -Path $sums).Hash.ToLower()
  if ($sumsActual -ne $sumsSha256.ToLower()) {
    throw "O SHA256SUMS da release não é o que este instalador conhece (esperado $sumsSha256). Nada foi instalado — obtenha o comando de instalação de novo na plataforma."
  }

  Write-Host "Baixando $asset ..." -ForegroundColor Cyan
  Invoke-WebRequest -Uri "$base/$asset" -OutFile $tmp -UseBasicParsing

  # confere a integridade ANTES de instalar (Get-Content -Raw: texto, mesmo se o servidor mandar octet-stream)
  $expected = $null
  foreach ($line in ((Get-Content -Raw -Path $sums) -split "`n")) {
    $parts = $line.Trim() -split "\s+", 2
    if ($parts.Count -eq 2 -and ($parts[1].TrimStart('*') -eq $asset)) { $expected = $parts[0].ToLower() }
  }
  if (-not $expected) { throw "SHA256SUMS da release não lista $asset; nada foi instalado." }
  $actual = (Get-FileHash -Algorithm SHA256 -Path $tmp).Hash.ToLower()
  if ($actual -ne $expected) { throw "Hash do $asset não confere com a release (esperado $expected, baixado $actual). Nada foi instalado." }
  Write-Host "Integridade conferida (SHA-256 $actual bate com a release $releaseTag)" -ForegroundColor Green
  Move-Item -Force $tmp $bin
} finally {
  Remove-Item -Force -ErrorAction SilentlyContinue $tmp, $sums
}

# remove a "marca da web" para reduzir o aviso do SmartScreen (binário sem certificado de código;
# a integridade foi conferida contra o SHA256SUMS cujo hash está embutido neste script)
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
