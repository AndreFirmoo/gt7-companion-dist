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

### macOS e Linux

Abra o **Terminal**, cole a linha abaixo e tecle Enter:

```bash
curl -fsSL https://raw.githubusercontent.com/AndreFirmoo/gt7-companion-dist/Master/install.sh | bash
```

Isso baixa o programa, cria um atalho **GT7 Companion** (na Área de Trabalho no macOS / no
menu de aplicativos no Linux) e já abre. **Da próxima vez é só duplo-clique no atalho.**

### Windows

Abra o **PowerShell**, cole e tecle Enter:

```powershell
irm https://raw.githubusercontent.com/AndreFirmoo/gt7-companion-dist/Master/install.ps1 | iex
```

> Prefere sem comando? Baixe o `.exe` na aba **[Releases](../../releases/latest)** e dê
> duplo-clique. Se aparecer o aviso do SmartScreen: **Mais informações → Executar assim mesmo**.

---

## Como usar

1. Ligue o **PS5 com o Gran Turismo 7 aberto**, na **mesma rede** do computador.
2. Abra o atalho **GT7 Companion** — uma janela mostra `escutando em http://127.0.0.1:8765`.
3. Abra a **plataforma no Chrome ou Edge** — ela detecta o Companion sozinha e começa a
   mostrar a telemetria ao vivo.

Para **encerrar**, feche a janela do Companion (ou tecle `Ctrl+C` nela).

## Atualizar

Rode o **mesmo comando de instalação** de novo — ele baixa a versão mais nova por cima.

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
chmod +x gt7-companion-linux-x86_64
./gt7-companion-linux-x86_64
```

**macOS:**
```bash
chmod +x gt7-companion-macos-arm64
xattr -d com.apple.quarantine gt7-companion-macos-arm64   # libera o Gatekeeper
./gt7-companion-macos-arm64
```

**Windows:** duplo-clique no `.exe` → *Mais informações → Executar assim mesmo*.

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
