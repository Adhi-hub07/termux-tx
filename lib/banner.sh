#===============================================================================
#  Banner — Cyber-themed ASCII Art
#===============================================================================

banner_show() {
  local w
  w=$(tput cols 2>/dev/null || echo 80)
  local is_small=false
  [[ $w -lt 70 ]] && is_small=true

  echo -e "${CYAN}"
  if $is_small; then
    echo "  ████████╗██╗  ██╗"
    echo "  ╚══██╔══╝██║  ██║"
    echo "     ██║   ███████║"
    echo "     ██║   ██╔══██║"
    echo "     ██║   ██║  ██║"
    echo "     ╚═╝   ╚═╝  ╚═╝"
  else
    echo ""
    echo "  ████████╗██╗  ██╗     ███████╗██╗  ██╗███████╗ ██████╗"
    echo "  ╚══██╔══╝██║  ██║     ██╔════╝╚██╗██╔╝██╔════╝██╔════╝"
    echo "     ██║   ███████║     █████╗   ╚███╔╝ █████╗  ███████╗"
    echo "     ██║   ██╔══██║     ██╔══╝   ██╔██╗ ██╔══╝  ██╔═══██╗"
    echo "     ██║   ██║  ██║     ███████╗██╔╝ ██╗███████╗╚██████╔╝"
    echo "     ╚═╝   ╚═╝  ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝"
  fi
  echo -e "${RESET}"

  echo -e "  ${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "  ${BOLD}${CYAN}║${RESET}  ${GREEN}TX${RESET} — ${BOLD}Termux eXecutive${RESET} ${DIM}v${TX_VERSION}${RESET}               ${BOLD}${CYAN}║${RESET}"
  echo -e "  ${BOLD}${CYAN}║${RESET}  ${YELLOW}⚡ Advanced Cybersecurity CLI${RESET}              ${BOLD}${CYAN}║${RESET}"
  echo -e "  ${BOLD}${CYAN}║${RESET}  ${MAGENTA}${RESET} github.com/Adhi-hub07/termux-tx${RESET}         ${BOLD}${CYAN}║${RESET}"
  echo -e "  ${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"

  if ! $is_small; then
    echo ""
    echo -e "  ${DIM}Type ${RESET}${GREEN}tx help${RESET}${DIM} for commands  │  ${RESET}${CYAN}tx <cmd>${RESET}${DIM} to run  │  ${RESET}${YELLOW}tx sys net scan${RESET}${DIM} to chain${RESET}"
    echo ""
    # Random tip
    local tips=(
      "Use ${GREEN}tx scan --quick${RESET} for fast port scanning"
      "Use ${GREEN}tx osint --domain example.com${RESET} for recon"
      "Use ${GREEN}tx anon --tor${RESET} to route through Tor"
      "Use ${GREEN}tx payload --android${RESET} to generate payloads"
      "Use ${GREEN}tx secure --audit${RESET} for security audit"
      "Use ${GREEN}tx crypto --hash sha256${RESET} to hash files"
      "Use ${GREEN}tx wf --scan${RESET} for WiFi auditing"
      "Use ${GREEN}tx phish --server${RESET} to start phishing server"
    )
    local tip_idx=$(( RANDOM % ${#tips[@]} ))
    echo -e "  ${DIM}💡 Tip: ${RESET}${tips[$tip_idx]}${RESET}"
  fi
  echo ""
}

# ── Module banner ────────────────────────────────────────────────────────────
module_banner() {
  local name="$1" desc="$2"
  echo ""
  echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${RESET}"
  echo -e "${CYAN}│${RESET}  ${BOLD}${GREEN}tx ${name}${RESET} ${DIM}— ${desc}${RESET}"
  echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${RESET}"
  echo ""
}
