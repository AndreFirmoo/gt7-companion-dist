# GT7 Companion

[![Última versão](https://img.shields.io/github/v/release/AndreFirmoo/gt7-companion-dist?display_name=tag&label=vers%C3%A3o&color=06b6d4)](../../releases/latest)
[![Baixar](https://img.shields.io/badge/⬇_baixar-Releases-22c55e)](../../releases/latest)

O **GT7 Companion** é um programinha que roda no seu computador, **descobre o seu PS5 na
rede** e captura a telemetria do **Gran Turismo 7**. Ele não tem login nem mexe na internet:
quem conversa com a plataforma é o seu navegador.

> **Use Chrome ou Edge.** Firefox e Safari não conseguem falar com o Companion (limitação
> deles, não dá para contornar).

---

## Instalar (jeito fácil — 1 comando)

Copie o comando de instalação **na plataforma** (app.apexracetelemetry.com.br → Companion). Ele é
assim, com a `<ref>` sendo um commit fixo deste repositório — nunca uma branch:

### macOS e Linux

```bash
curl -fsSL https://raw.githubusercontent.com/AndreFirmoo/gt7-companion-dist/<ref>/install.sh | bash
```

Isso baixa o programa da release que o instalador conhece, confere a integridade, cria um atalho
**GT7 Companion** (na Área de Trabalho no macOS / no menu de aplicativos no Linux) e já abre.
**Da próxima vez é só duplo-clique no atalho.**

### Windows

```powershell
irm https://raw.githubusercontent.com/AndreFirmoo/gt7-companion-dist/<ref>/install.ps1 | iex
```

> Prefere sem comando? Baixe o `.exe` na aba **[Releases](../../releases/latest)**, confira o hash
> (seção abaixo) e dê duplo-clique. Se aparecer o aviso do SmartScreen: **Mais informações →
> Executar assim mesmo**.

---

## Integridade e assinatura

Cada release publica `SHA256SUMS` (hash de cada binário) e `SHA256SUMS.sigstore.json` (assinatura
Sigstore keyless gerada e verificada pela esteira de build). Os instaladores acima **pinam a
release e o SHA-256 do próprio `SHA256SUMS`**, e conferem o hash do binário antes de instalar; se
qualquer coisa não bater, nada é instalado. **A assinatura Sigstore só é conferida pelo instalador
se você tiver o `cosign` (≥ 3.0) instalado** — sem ele, a raiz de confiança é o hash embutido no
instalador, servido pela plataforma.

Para verificar você mesmo (cosign ≥ 3.0; baixe `SHA256SUMS` e `SHA256SUMS.sigstore.json` da release):

```bash
cosign verify-blob --bundle SHA256SUMS.sigstore.json \
  --certificate-identity-regexp 'github.com/AndreFirmoo/raceTelemetry/.github/workflows/companion-release.yml' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com SHA256SUMS
sha256sum -c SHA256SUMS --ignore-missing            # Linux
shasum -a 256 -c SHA256SUMS --ignore-missing        # macOS
Get-FileHash -Algorithm SHA256 .\gt7-companion-windows-x86_64.exe   # Windows: compare com o SHA256SUMS
```

## Como usar

1. Ligue o **PS5 com o Gran Turismo 7 aberto**, na **mesma rede** do computador.
2. Abra o atalho **GT7 Companion** — uma janela mostra `escutando em http://127.0.0.1:8765`.
3. Abra a **plataforma no Chrome ou Edge** — ela detecta o Companion sozinha e começa a
   mostrar a telemetria ao vivo.

Para **encerrar**, feche a janela do Companion (ou tecle `Ctrl+C` nela).

## Atualizar

Copie o comando de instalação **atual** na plataforma e rode de novo — cada versão do instalador
pina a release que instala.

---

## Instalação manual (sem o script)

Baixe o arquivo do seu sistema (download direto da última release):

| Sistema | Download direto |
|---|---|
| Linux (Ubuntu/Debian…), 64-bit Intel/AMD | [`gt7-companion-linux-x86_64`](../../releases/latest/download/gt7-companion-linux-x86_64) |
| macOS Apple Silicon (M1/M2/M3…) | [`gt7-companion-macos-arm64`](../../releases/latest/download/gt7-companion-macos-arm64) |
| Windows 64-bit | [`gt7-companion-windows-x86_64.exe`](../../releases/latest/download/gt7-companion-windows-x86_64.exe) |

> Todos os arquivos e versões anteriores ficam na aba **[Releases](../../releases/latest)**.

**Linux:**
```bash
sha256sum gt7-companion-linux-x86_64        # compare com a linha do SHA256SUMS da release
chmod +x gt7-companion-linux-x86_64
./gt7-companion-linux-x86_64
```

**macOS:**
```bash
shasum -a 256 gt7-companion-macos-arm64     # compare com a linha do SHA256SUMS da release
chmod +x gt7-companion-macos-arm64
xattr -d com.apple.quarantine gt7-companion-macos-arm64   # libera o Gatekeeper
./gt7-companion-macos-arm64
```

**Windows:** duplo-clique no `.exe` → *Mais informações → Executar assim mesmo*.

> **Importante na instalação manual:** o instalador de 1 linha já conecta o Companion à
> plataforma automaticamente. Se você baixar manualmente, crie o arquivo
> `~/.gt7-companion/config.json` (no Windows: `%USERPROFILE%\.gt7-companion\config.json`) com:
>
> ```json
> { "web_origins": ["https://app.apexracetelemetry.com.br"] }
> ```
>
> Sem isso, a plataforma no navegador não consegue se comunicar com o Companion.

---

## Requisitos

- Navegador **Chrome ou Edge**.
- **PS5 e computador na mesma rede** local.
- **Linux:** arquitetura `x86_64` (confira com `uname -m`), Ubuntu 22.04 ou mais novo.
- **macOS:** Apple Silicon (arm64). Macs Intel podem não ter build disponível.

---

## Não funcionou?

| Sintoma | O que fazer |
|---|---|
| Aviso *"app não identificado"* (macOS) ou *SmartScreen* (Windows) | É esperado — o programa não é assinado. macOS: clique com o botão direito → **Abrir**. Windows: **Mais informações → Executar assim mesmo**. |
| A plataforma não encontra o Companion | Use **Chrome ou Edge** e confirme que a janela do Companion está aberta (`escutando em 127.0.0.1:8765`). |
| Não acha o PS5 / sem dados ao vivo | PS5 e PC na mesma rede? GT7 aberto no console? Se você tiver firewall ativo (raro no desktop), libere o tráfego UDP da sua rede local. |
| Linux: `Permission denied` | Faltou `chmod +x` no binário (o instalador já faz isso). |
| Linux: `Exec format error` | Você baixou o binário de outra arquitetura. Precisa ser `x86_64`. |
| Linux: `... GLIBC_2.xx not found` | Sua distro é mais antiga que a do build. Atualize o sistema. |
| `address already in use` (porta 8765) | Já há um Companion aberto. Feche o anterior. |

---

### Sobre os avisos de segurança

Os binários **não são assinados digitalmente** (assinatura/notarização é um passo futuro),
por isso macOS e Windows alertam na primeira execução. É seguro autorizar a abertura — o
código-fonte vive em repositório privado e o build é automático pelo CI.
