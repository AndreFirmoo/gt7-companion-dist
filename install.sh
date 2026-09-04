#!/usr/bin/env bash
# Instalador do GT7 Companion — macOS e Linux.
#
# Baixa o binário certo da última release, cria um atalho de duplo-clique
# (Área de Trabalho no macOS / menu de aplicativos no Linux) e já abre o programa.
# Rode de novo a qualquer momento para atualizar para a versão mais nova.
#
# Uso (copie e cole no Terminal):
#   curl -fsSL https://raw.githubusercontent.com/AndreFirmoo/gt7-companion-dist/Master/install.sh | bash
set -euo pipefail

REPO="AndreFirmoo/gt7-companion-dist"
DATA_DIR="$HOME/.gt7-companion"
INSTALL_DIR="$DATA_DIR/bin"
BIN="$INSTALL_DIR/gt7-companion"

# Origin EXATA da plataforma web (sem barra final — é o que o navegador envia no
# header Origin). O companion só aceita a web cuja origin estiver aqui; mudar de
# domínio = trocar esta linha (nenhum rebuild do binário é necessário).
WEB_ORIGIN="https://app.apexracetelemetry.com.br"

say() { printf '\033[1;36m›\033[0m %s\n' "$*"; }
ok()  { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

# --- descobre o asset certo para este sistema -------------------------------
os="$(uname -s)"
arch="$(uname -m)"
case "$os" in
  Darwin)
    case "$arch" in
      arm64)  asset="gt7-companion-macos-arm64" ;;
      x86_64) asset="gt7-companion-macos-x86_64" ;;
      *) die "Arquitetura de macOS não suportada: $arch" ;;
    esac ;;
  Linux)
    case "$arch" in
      x86_64|amd64) asset="gt7-companion-linux-x86_64" ;;
      *) die "No Linux só existe build x86_64 (o seu é '$arch'). Não há binário disponível." ;;
    esac ;;
  *) die "Este instalador é só para macOS e Linux. No Windows use o instalador install.ps1 ou o .exe da aba Releases." ;;
esac

url="https://github.com/$REPO/releases/latest/download/$asset"

# --- baixa (atômico: .tmp -> mv) --------------------------------------------
say "Baixando $asset (pode levar um tempo, ~100 MB)…"
mkdir -p "$INSTALL_DIR"
if ! curl -fL --progress-bar -o "$BIN.tmp" "$url"; then
  rm -f "$BIN.tmp"
  die "Não consegui baixar $asset. Esse build pode não existir na última release."
fi

# --- confere a integridade ANTES de dar permissão/remover quarentena ---------
# SHA256SUMS é publicado pela esteira de release (assinado via Sigstore; ver README).
sums_url="https://github.com/$REPO/releases/latest/download/SHA256SUMS"
if ! curl -fsSL -o "$INSTALL_DIR/SHA256SUMS" "$sums_url"; then
  rm -f "$BIN.tmp"
  die "Não consegui baixar o SHA256SUMS da release; instalação abortada (nada foi instalado)."
fi
expected="$(awk -v name="$asset" '$2 == name || $2 == "*" name {print $1}' "$INSTALL_DIR/SHA256SUMS" | head -1)"
[ -n "$expected" ] || { rm -f "$BIN.tmp"; die "SHA256SUMS não lista $asset; instalação abortada."; }
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$BIN.tmp" | awk '{print $1}')"
else
  actual="$(shasum -a 256 "$BIN.tmp" | awk '{print $1}')"
fi
if [ "$actual" != "$expected" ]; then
  rm -f "$BIN.tmp"
  die "Hash do $asset não confere com o SHA256SUMS da release (esperado $expected, baixado $actual). Nada foi instalado."
fi
ok "Integridade conferida (SHA-256 bate com a release)"
mv -f "$BIN.tmp" "$BIN"
chmod +x "$BIN"

# macOS: remove a quarentena para o Gatekeeper não bloquear (binário sem certificado de código;
# a integridade já foi conferida acima contra o SHA256SUMS assinado da release)
if [ "$os" = "Darwin" ]; then
  xattr -dr com.apple.quarantine "$BIN" 2>/dev/null || true
fi
ok "Instalado em: $BIN"

# --- aponta o companion para a plataforma web -------------------------------
# Escreve <data_dir>/config.json com a origin da web. Sem isto, o navegador na
# web de produção seria bloqueado por CORS/PNA ao falar com o companion local.
mkdir -p "$DATA_DIR"
printf '{ "web_origins": ["%s"] }\n' "$WEB_ORIGIN" > "$DATA_DIR/config.json"
ok "Conectado à plataforma: $WEB_ORIGIN"

# --- cria um atalho de duplo-clique -----------------------------------------
create_mac_launcher() {
  local launcher="$HOME/Desktop/GT7 Companion.command"
  cat > "$launcher" <<EOF
#!/usr/bin/env bash
# Atalho do GT7 Companion — duplo-clique para abrir. Feche a janela para encerrar.
clear
echo "Iniciando o GT7 Companion…"
exec "$BIN"
EOF
  chmod +x "$launcher"
  xattr -dr com.apple.quarantine "$launcher" 2>/dev/null || true
  ok "Atalho criado: ~/Desktop/GT7 Companion.command (duplo-clique para abrir)"
}

create_linux_launcher() {
  local apps="$HOME/.local/share/applications"
  local entry
  entry="[Desktop Entry]
Type=Application
Name=GT7 Companion
Comment=Captura a telemetria do Gran Turismo 7
Exec=\"$BIN\"
Terminal=true
Categories=Game;Utility;
"
  mkdir -p "$apps"
  printf '%s' "$entry" > "$apps/gt7-companion.desktop"
  chmod +x "$apps/gt7-companion.desktop"
  if [ -d "$HOME/Desktop" ]; then
    printf '%s' "$entry" > "$HOME/Desktop/gt7-companion.desktop"
    chmod +x "$HOME/Desktop/gt7-companion.desktop"
    gio set "$HOME/Desktop/gt7-companion.desktop" metadata::trusted true 2>/dev/null || true
  fi
  ok "Atalho criado no menu de aplicativos (procure por 'GT7 Companion')"
}

if [ "$os" = "Darwin" ]; then create_mac_launcher; else create_linux_launcher; fi

# --- pronto: já abre ---------------------------------------------------------
printf '\n'
ok "Tudo pronto!"
cat <<'EOF'

Para usar:
  1. Ligue o PS5 com o Gran Turismo 7 aberto, na MESMA rede deste computador.
  2. Abra a plataforma no Chrome ou Edge — ela detecta o Companion sozinha.
     (Firefox e Safari não funcionam — é limitação do navegador.)

Da próxima vez, é só usar o atalho "GT7 Companion".
Abrindo agora… (feche a janela ou tecle Ctrl+C para encerrar)
EOF
printf '\n'
exec "$BIN"
