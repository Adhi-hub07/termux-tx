#!/usr/bin/env bash
#===============================================================================
#  TX - Uninstaller
#===============================================================================
set -euo pipefail

RED='\e[31m'; GREEN='\e[32m'; YELLOW='\e[33m'; CYAN='\e[36m'; BOLD='\e[1m'; RESET='\e[0m'

echo ""
echo -e "${YELLOW}[!] TX Uninstaller${RESET}"
echo ""

if [[ -n "${TERMUX_VERSION:-}" ]]; then
  PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
else
  PREFIX="/usr/local"
fi

INSTALL_DIR="${PREFIX}/share/tx"
BIN_LINK="${PREFIX}/bin/tx"

confirm() {
  local prompt="${1:-Continue?}"
  echo -ne "${YELLOW}[?]${RESET} ${prompt} (y/N) "
  read -r yn
  [[ "$yn" == "y" ]] || [[ "$yn" == "Y" ]]
}

confirm "Remove TX?" || exit 0

# Remove files
rm -rf "$INSTALL_DIR" 2>/dev/null && echo -e "  ${GREEN}✓${RESET} Removed $INSTALL_DIR"
rm -f "$BIN_LINK" 2>/dev/null && echo -e "  ${GREEN}✓${RESET} Removed $BIN_LINK"

# Remove config
if confirm "Remove config files (~/.tx/)? this includes backups"; then
  rm -rf "$HOME/.tx" 2>/dev/null && echo -e "  ${GREEN}✓${RESET} Removed ~/.tx/"
fi

# Remove aliases
if confirm "Remove TX aliases from .bashrc/.zshrc?"; then
  sed -i '/# ── TX Power Aliases ──/,/^EOF$/d' "$HOME/.bashrc" 2>/dev/null || true
  sed -i '/# ── TX Power Aliases ──/,/^EOF$/d' "$HOME/.zshrc" 2>/dev/null || true
  echo -e "  ${GREEN}✓${RESET} Aliases removed"
fi

# Remove completion
sed -i '/tx-completion/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/tx-completion/d' "$HOME/.zshrc" 2>/dev/null || true

echo ""
echo -e "${GREEN}[+] TX has been removed${RESET}"
echo ""
