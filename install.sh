#!/usr/bin/env bash
#===============================================================================
#  TX - Termux eXecutive Installer
#===============================================================================
set -euo pipefail

BOLD='\e[1m'; RESET='\e[0m'
RED='\e[31m'; GREEN='\e[32m'; YELLOW='\e[33m'; CYAN='\e[36m'

echo ""
echo -e "${CYAN}  ████████╗██╗  ██╗     ███████╗██╗  ██╗███████╗ ██████╗${RESET}"
echo -e "${CYAN}  ╚══██╔══╝██║  ██║     ██╔════╝╚██╗██╔╝██╔════╝██╔════╝${RESET}"
echo -e "${CYAN}     ██║   ███████║     █████╗   ╚███╔╝ █████╗  ███████╗${RESET}"
echo -e "${CYAN}     ██║   ██╔══██║     ██╔══╝   ██╔██╗ ██╔══╝  ██╔═══██╗${RESET}"
echo -e "${CYAN}     ██║   ██║  ██║     ███████╗██╔╝ ██╗███████╗╚██████╔╝${RESET}"
echo -e "${CYAN}     ╚═╝   ╚═╝  ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝${RESET}"
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║${RESET}  TX — Termux eXecutive v2.0                              ${BOLD}${CYAN}║${RESET}"
echo -e "${BOLD}${CYAN}║${RESET}  Advanced Cybersecurity CLI for Termux & Linux          ${BOLD}${CYAN}║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# ── Detect environment ──────────────────────────────────────────────────────
if [[ -n "${TERMUX_VERSION:-}" ]]; then
  ENV="termux"
  PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
elif [[ -f /system/build.prop ]] && command -v getprop &>/dev/null; then
  ENV="android"
  PREFIX="/data/data/com.termux/files/usr"
else
  ENV="linux"
  PREFIX="/usr/local"
fi

INSTALL_DIR="${PREFIX}/share/tx"
BIN_DIR="${PREFIX}/bin"

echo -e "${YELLOW}[!] Detected environment: ${BOLD}${ENV}${RESET}"
echo ""

# ── Dependencies ────────────────────────────────────────────────────────────
echo -e "${CYAN}[*] Checking dependencies...${RESET}"
MISSING=() ; DEPS=(curl git)
for dep in "${DEPS[@]}"; do
  if command -v "$dep" &>/dev/null; then
    echo -e "  ${GREEN}✓${RESET} $dep"
  else
    echo -e "  ${YELLOW}✗${RESET} $dep (will install)"
    MISSING+=("$dep")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo ""
  echo -e "${CYAN}[*] Installing missing dependencies...${RESET}"
  case "$ENV" in
    termux) pkg install -y "${MISSING[@]}" 2>/dev/null ;;
    *) sudo apt install -y "${MISSING[@]}" 2>/dev/null || true ;;
  esac
fi

# ── Install TX ──────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}[*] Installing TX...${RESET}"

# Get the directory where install.sh is located
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || SRC_DIR=""
# Handle pipe install: bash <(curl ...) → BASH_SOURCE points to /proc/self/fd
if [[ ! -f "$SRC_DIR/tx" ]] || [[ "$SRC_DIR" == /proc/* ]] || [[ "$SRC_DIR" == /dev/* ]]; then
  echo -e "${YELLOW}[!] Detected pipe install. Cloning repo first...${RESET}"
  TMP_DIR=$(mktemp -d)
  git clone --depth 1 https://github.com/Adhi-hub07/termux-tx.git "$TMP_DIR" 2>/dev/null || {
    echo -e "${RED}[-] Git clone failed. Install git and try again.${RESET}"
    exit 1
  }
  SRC_DIR="$TMP_DIR"
fi

# Create install directories
mkdir -p "$INSTALL_DIR/lib" "$INSTALL_DIR/tools" "$INSTALL_DIR/config" "$INSTALL_DIR/completion"

# Copy files
cp -r "$SRC_DIR/lib"/* "$INSTALL_DIR/lib/" 2>/dev/null && echo -e "  ${GREEN}✓${RESET} Libraries installed"
cp -r "$SRC_DIR/tools"/* "$INSTALL_DIR/tools/" 2>/dev/null || true
cp -r "$SRC_DIR/config"/* "$INSTALL_DIR/config/" 2>/dev/null || true

# Install main script
cp "$SRC_DIR/tx" "$INSTALL_DIR/tx"
chmod +x "$INSTALL_DIR/tx"

# Create symlink
ln -sf "$INSTALL_DIR/tx" "$BIN_DIR/tx"
chmod +x "$BIN_DIR/tx"

# Tab completion
if [[ -f "$SRC_DIR/completion/tx-completion.bash" ]]; then
  cp "$SRC_DIR/completion/tx-completion.bash" "$INSTALL_DIR/completion/"
fi

# ── Post-install ────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}[+] TX installed successfully!${RESET}"
echo -e "${GREEN}[+] Type ${BOLD}tx${RESET}${GREEN} to get started${RESET}"

# Verify
if command -v tx &>/dev/null; then
  echo -e "${GREEN}[+] ${BOLD}tx${RESET}${GREEN} is ready at $(which tx)${RESET}"
else
  echo -e "${YELLOW}[!] Please restart your terminal or run:${RESET}"
  echo -e "  ${BOLD}exec \$SHELL${RESET}"
fi

# Setup completion
if [[ -n "${BASH_VERSION:-}" ]]; then
  comp_file="$INSTALL_DIR/completion/tx-completion.bash"
  if [[ -f "$comp_file" ]]; then
    local rcfile="$HOME/.bashrc"
    [[ "$ENV" == "termux" ]] && rcfile="$HOME/.bashrc"
    if ! grep -q "tx-completion" "$rcfile" 2>/dev/null; then
      echo "source $comp_file" >> "$rcfile"
      echo -e "${GREEN}[+] Tab completion added to $rcfile${RESET}"
    fi
  fi
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║${RESET}  Run ${BOLD}tx help${RESET} for all commands                        ${CYAN}║${RESET}"
echo -e "${CYAN}║${RESET}  Run ${BOLD}tx sys${RESET} for system info                         ${CYAN}║${RESET}"
echo -e "${CYAN}║${RESET}  Follow: ${BOLD}github.com/Adhi-hub07/termux-tx${RESET}           ${CYAN}║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""
