#===============================================================================
#  motd — Custom Login Banner
#===============================================================================

cmd_motd() {
  module_banner "motd" "Custom login message"
  local sub="${1:-show}"; shift 2>/dev/null || true

  case "$sub" in
    show)      motd_show;;
    set)       motd_set "$@";;
    reset)     motd_reset;;
    random)    motd_random;;
    ascii)     motd_ascii "$@";;
    --json)    TX_JSON=true; motd_show;;
    -h|--help)
      echo "Usage: tx motd <subcommand> [msg]"
      echo "  show            Show current MOTD"
      echo "  set <msg>       Set custom MOTD"
      echo "  reset           Reset to default"
      echo "  random          Random MOTD"
      echo "  ascii <art>     Set ASCII art MOTD"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

motd_show() {
  log_section "Current MOTD"
  if $IS_TERMUX; then
    cat "$PREFIX/etc/motd" 2>/dev/null || echo "  No MOTD set"
  elif [[ -f /etc/motd ]]; then
    cat /etc/motd 2>/dev/null
  else
    echo "  No MOTD file found"
  fi
}

motd_set() {
  local msg="${*:-Welcome to TX}"
  log_section "Set MOTD"
  if $IS_TERMUX; then
    echo -e "$msg" > "$PREFIX/etc/motd" && log_success "MOTD set"
  elif is_root; then
    echo -e "$msg" > /etc/motd && log_success "MOTD set"
  else
    echo -e "$msg" > "$HOME/.hushlogin" 2>/dev/null
    echo "export MOTD='$msg'" >> "$HOME/.bashrc"
    log_success "MOTD added to .bashrc"
  fi
}

motd_reset() {
  log_section "Reset MOTD"
  if $IS_TERMUX; then
    cp "$PREFIX/etc/motd.default" "$PREFIX/etc/motd" 2>/dev/null || log_warn "No default MOTD backup"
  fi
  rm -f "$HOME/.hushlogin"
  sed -i '/^export MOTD=/d' "$HOME/.bashrc" 2>/dev/null
  log_success "MOTD reset"
}

motd_random() {
  local quotes=(
    "Stay hungry, stay foolish."
    "With great power comes great responsibility."
    "The quieter you become, the more you can hear."
    "Hack the planet!"
    "Terminal is the ultimate playground."
    "Keep calm and pwn on."
    "I'm in."
    "Access granted."
    "Rooted."
    "TX is watching."
  )
  local idx=$((RANDOM % ${#quotes[@]}))
  motd_set "${quotes[$idx]}"
}

motd_ascii() {
  local art="${1:-hacker}"
  log_section "ASCII MOTD"
  case "$art" in
    hacker)
      motd_set "$(cat << 'EOF'
  ╔══════════════════════════════════╗
  ║     ⚡ TX - Termux eXecutive ⚡  ║
  ║     Advanced Cybersecurity CLI    ║
  ╚══════════════════════════════════╝
EOF
)"
      ;;
    skull)
      motd_set "$(cat << 'EOF'
        ▄▄▄▄▄▄▄▄▄▄▄
       ▀▀▀▀▀▀▀▀▀▀▀▀▀
      ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
     ███████████████████
     ██            ████
    ███  ██    ██  ███
    ███            ███
    ███  ████████  ███
     ██   ██████   ██
      ██          ██
       ▀██████████▀
EOF
)"
      ;;
    dragon|tx)
      motd_set "$(cat << 'EOF'
  ████████╗██╗  ██╗     ███████╗██╗  ██╗███████╗ ██████╗
  ╚══██╔══╝██║  ██║     ██╔════╝╚██╗██╔╝██╔════╝██╔════╝
     ██║   ███████║     █████╗   ╚███╔╝ █████╗  ███████╗
     ██║   ██╔══██║     ██╔══╝   ██╔██╗ ██╔══╝  ██╔═══██╗
     ██║   ██║  ██║     ███████╗██╔╝ ██╗███████╗╚██████╔╝
     ╚═╝   ╚═╝  ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝
EOF
)"
      ;;
    *)
      log_error "Unknown ASCII art: $art"
      echo "Available: hacker, skull, dragon/tx"
      return 1
      ;;
  esac
  log_success "ASCII MOTD set: $art"
}
