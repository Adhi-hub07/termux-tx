#===============================================================================
#  backup — Backup & Restore
#===============================================================================

cmd_backup() {
  module_banner "backup" "Backup & restore"
  local sub="${1:-help}"; shift 2>/dev/null || true

  case "$sub" in
    create|backup)   backup_create "$@";;
    restore)         backup_restore "$@";;
    list)            backup_list;;
    apps)            backup_apps;;
    sms)             backup_sms;;
    termux)          backup_termux;;
    config)          backup_config;;
    --json)          TX_JSON=true; backup_list;;
    -h|--help)
      echo "Usage: tx backup <subcommand> [args]"
      echo "  create [name]    Create backup"
      echo "  restore <file>   Restore from backup"
      echo "  list             List backups"
      echo "  apps             Backup app list"
      echo "  sms              Backup SMS (Android)"
      echo "  termux           Backup Termux config"
      echo "  config           Backup system configs"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

backup_create() {
  local name="${1:-tx-backup-$(date +%Y%m%d-%H%M%S)}"
  local dest="$HOME/.tx/backups/$name"
  mkdir -p "$dest"
  log_section "Creating Backup — $name"
  log_info "Backing up home directory..."
  tar czf "$dest/home.tar.gz" --exclude ".tx" --exclude ".cache" "$HOME" 2>/dev/null &
  log_info "Backing up package list..."
  if $IS_TERMUX; then
    dpkg --get-selections > "$dest/packages.txt" 2>/dev/null
  fi
  # Config files
  [[ -d "$HOME/.ssh" ]] && cp -r "$HOME/.ssh" "$dest/" 2>/dev/null
  [[ -f "$HOME/.bashrc" ]] && cp "$HOME/.bashrc" "$dest/"
  [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$dest/"
  [[ -f "$HOME/.gitconfig" ]] && cp "$HOME/.gitconfig" "$dest/"
  wait
  log_success "Backup saved: $dest"
  du -sh "$dest"
}

backup_restore() {
  local backup="${1:-}"
  [[ -z "$backup" ]] && { log_error "Usage: tx backup restore <backup-path>"; return 1; }
  log_section "Restore — $backup"
  confirm "This will overwrite files in $HOME" || return 0
  if [[ -f "$backup/home.tar.gz" ]]; then
    tar xzf "$backup/home.tar.gz" -C / 2>/dev/null
    log_success "Home restored"
  fi
  if [[ -f "$backup/packages.txt" ]] && $IS_TERMUX; then
    dpkg --set-selections < "$backup/packages.txt" 2>/dev/null
    apt-get dselect-upgrade -y 2>/dev/null
    log_success "Packages restored"
  fi
  log_success "Restore complete"
}

backup_list() {
  log_section "Backups"
  local backup_dir="$HOME/.tx/backups"
  if [[ -d "$backup_dir" ]]; then
    ls -lh "$backup_dir" | awk 'NR>1 {printf "  %-30s %s\n", $NF, $5}'
  else
    log_info "No backups found"
  fi
}

backup_apps() {
  log_section "App Backup"
  if $IS_TERMUX && command -v pm &>/dev/null; then
    pm list packages -3 2>/dev/null | sort > "$HOME/.tx/apps.txt"
    local count
    count=$(wc -l < "$HOME/.tx/apps.txt")
    log_success "Saved $count user apps to ~/.tx/apps.txt"
    head -20 "$HOME/.tx/apps.txt" | sed 's/^/  /'
  elif command -v dpkg &>/dev/null; then
    dpkg --get-selections > "$HOME/.tx/apps.txt"
    log_success "Saved packages to ~/.tx/apps.txt"
  else
    log_warn "Cannot list apps"
  fi
}

backup_sms() {
  log_section "SMS Backup"
  if $IS_TERMUX && command -v termux-sms-list &>/dev/null; then
    termux-sms-list 2>/dev/null > "$HOME/.tx/sms.json"
    log_success "SMS saved to ~/.tx/sms.json"
  else
    log_warn "termux-sms-list not available"
    log_info "pkg install termux-api"
  fi
}

backup_termux() {
  log_section "Termux Backup"
  local dest="$HOME/.tx/backups/termux-$(date +%Y%m%d)"
  mkdir -p "$dest"
  # Termux home
  tar czf "$dest/termux-home.tar.gz" -C "$HOME" .bashrc .zshrc .termux 2>/dev/null || true
  # Packages
  dpkg --get-selections > "$dest/packages.txt" 2>/dev/null
  # Fonts & themes
  [[ -d "$HOME/.termux" ]] && cp -r "$HOME/.termux" "$dest/" 2>/dev/null
  log_success "Termux backup: $dest"
  du -sh "$dest"
}

backup_config() {
  log_section "Config Backup"
  local dest="$HOME/.tx/backups/config-$(date +%Y%m%d)"
  mkdir -p "$dest"
  for cfg in .bashrc .zshrc .profile .gitconfig .ssh .vimrc .tmux.conf .config/nvim; do
    if [[ -e "$HOME/$cfg" ]]; then
      cp -r "$HOME/$cfg" "$dest/" 2>/dev/null && echo -e "  ${GREEN}✓${RESET} $cfg" || echo -e "  ${YELLOW}?${RESET} $cfg"
    fi
  done
  log_success "Config backup: $dest"
}
