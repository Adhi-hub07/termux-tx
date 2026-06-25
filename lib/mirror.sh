#===============================================================================
#  mirror — Mirror Speed Test & Selector
#===============================================================================

cmd_mirror() {
  module_banner "mirror" "Mirror speed test & selector"
  local sub="${1:-test}"; shift 2>/dev/null || true

  case "$sub" in
    test|speed)    mirror_test;;
    set|select)    mirror_set "$@";;
    list)          mirror_list;;
    best)          mirror_best;;
    --json)        TX_JSON=true; mirror_list;;
    -h|--help)
      echo "Usage: tx mirror <subcommand>"
      echo "  test|speed   Test mirror speeds"
      echo "  set <url>    Set mirror"
      echo "  list         List mirrors"
      echo "  best         Auto-select fastest"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

mirror_test() {
  log_section "Mirror Speed Test"
  local mirrors=()
  if $IS_TERMUX; then
    mirrors=(
      "https://packages.termux.dev/apt/termux-main"
      "https://termux.astra.in.th/apt/termux-main"
      "https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main"
      "https://termux.mentality.rip/apt/termux-main"
      "https://grimler.se/termux/apt/termux-main"
    )
  elif command -v apt &>/dev/null; then
    mirrors=($(grep -oP 'https?://[^/]+' /etc/apt/sources.list 2>/dev/null | sort -u))
  fi
  [[ ${#mirrors[@]} -eq 0 ]] && mirrors=("https://google.com")
  for m in "${mirrors[@]}"; do
    local time
    time=$(curl -s -o /dev/null -w "%{time_total}" --connect-timeout 5 "$m" 2>/dev/null || echo "999")
    printf "  %-60s ${GREEN}%.2fs${RESET}\n" "$m" "$time"
  done
}

mirror_set() {
  local url="${1:-}"
  [[ -z "$url" ]] && { log_error "Usage: tx mirror set <url>"; return 1; }
  log_section "Set Mirror — $url"
  if $IS_TERMUX; then
    termux-change-repo "$url" 2>/dev/null || {
      sed -i "s|^deb .*|deb $url main stable|" "$PREFIX/etc/apt/sources.list" 2>/dev/null
      apt update 2>/dev/null
    }
    log_success "Mirror set to $url"
  else
    log_warn "Only for Termux"
  fi
}

mirror_list() {
  log_section "Mirrors"
  if $IS_TERMUX; then
    grep -oP 'https?://[^ ]+' "$PREFIX/etc/apt/sources.list" 2>/dev/null | sed 's/^/  /'
  else
    grep -oP 'https?://[^ ]+' /etc/apt/sources.list 2>/dev/null | head -10 | sed 's/^/  /'
  fi
}

mirror_best() {
  log_section "Finding Best Mirror..."
  mirror_test | sort -k2 -n | head -1 | awk '{print $1}' | while IFS= read -r url; do
    log_success "Fastest: $url"
    if confirm "Set this mirror?" "y"; then
      mirror_set "$url"
    fi
  done
}
