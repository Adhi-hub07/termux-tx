#===============================================================================
#  alias — Power Aliases Deployer
#===============================================================================

cmd_alias() {
  module_banner "alias" "Power aliases deployer"
  local sub="${1:-list}"; shift 2>/dev/null || true

  case "$sub" in
    list)      alias_list;;
    deploy)    alias_deploy;;
    add)       alias_add "$@";;
    remove)    alias_remove "$@";;
    backup)    alias_backup;;
    restore)   alias_restore;;
    --json)    TX_JSON=true; alias_list;;
    -h|--help)
      echo "Usage: tx alias <subcommand> [args]"
      echo "  list             Show current aliases"
      echo "  deploy           Deploy power aliases"
      echo "  add <name> <cmd> Add custom alias"
      echo "  remove <name>    Remove alias"
      echo "  backup           Backup aliases"
      echo "  restore          Restore aliases"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

alias_list() {
  log_section "Current Aliases"
  if [[ -f "$HOME/.bashrc" ]]; then
    grep "^alias" "$HOME/.bashrc" 2>/dev/null | sed 's/^/  /'
  fi
  if [[ -f "$HOME/.zshrc" ]]; then
    grep "^alias" "$HOME/.zshrc" 2>/dev/null | sed 's/^/  /'
  fi
  echo -e "\n${BOLD}Internal Aliases:${RESET}"
  alias 2>/dev/null | head -20 | sed 's/^/  /'
}

alias_deploy() {
  log_section "Deploy Power Aliases"
  local rcfile="$HOME/.bashrc"
  [[ -f "$HOME/.zshrc" ]] && rcfile="$HOME/.zshrc"

  cat >> "$rcfile" << 'EOF'

# ── TX Power Aliases ────────────────────────────────────────────────────────
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias cls='clear'
alias hist='history | tail -20'
alias ports='ss -tlnp'
alias myip='curl -s ifconfig.me'
alias paths='echo -e ${PATH//:/\\n}'
alias edit='nano'
alias txu='tx update'
alias txs='tx sys'
alias txn='tx net scan'
alias txp='tx pkg'
alias txf='tx fs'
alias txo='tx osint'
alias txsc='tx scan'
alias txex='tx exploit'
alias txpl='tx payload'
alias txcr='tx crypto'
alias txan='tx anon'
alias txbk='tx backup'
alias txth='tx theme'
alias txal='tx alias'
alias txfw='tx wf'
alias txph='tx phish'
alias txsr='tx secure'
alias txfx='tx forensic'
alias top='htop 2>/dev/null || top'
EOF

  log_success "Power aliases deployed to $rcfile"
  log_info "Run: source $rcfile"
}

alias_add() {
  local name="${1:-}" cmd="${2:-}"
  [[ -z "$name" ]] || [[ -z "$cmd" ]] && { log_error "Usage: tx alias add <name> <command>"; return 1; }
  local rcfile="$HOME/.bashrc"
  [[ -f "$HOME/.zshrc" ]] && rcfile="$HOME/.zshrc"
  echo "alias $name='$cmd'" >> "$rcfile"
  log_success "Alias added: $name='$cmd'"
}

alias_remove() {
  local name="${1:-}"
  [[ -z "$name" ]] && { log_error "Usage: tx alias remove <name>"; return 1; }
  local rcfile="$HOME/.bashrc"
  [[ -f "$HOME/.zshrc" ]] && rcfile="$HOME/.zshrc"
  sed -i "/^alias $name=/d" "$rcfile" 2>/dev/null
  log_success "Alias removed: $name"
}

alias_backup() {
  local dest="$HOME/.tx/aliases.bak"
  grep "^alias" "$HOME/.bashrc" 2>/dev/null > "$dest"
  grep "^alias" "$HOME/.zshrc" 2>/dev/null >> "$dest"
  log_success "Aliases backed up to $dest"
}

alias_restore() {
  local src="$HOME/.tx/aliases.bak"
  [[ ! -f "$src" ]] && { log_error "No backup found: $src"; return 1; }
  local rcfile="$HOME/.bashrc"
  [[ -f "$HOME/.zshrc" ]] && rcfile="$HOME/.zshrc"
  sed -i '/^# ── TX Power Aliases ──/,/^EOF$/d' "$rcfile" 2>/dev/null
  cat "$src" >> "$rcfile"
  log_success "Aliases restored from $src"
}
