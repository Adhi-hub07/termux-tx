#===============================================================================
#  secure — Security Audit & Hardening
#===============================================================================

cmd_secure() {
  module_banner "secure" "Security audit & hardening"
  local sub="${1:-audit}"; shift 2>/dev/null || true

  case "$sub" in
    audit|check)   secure_audit;;
    suid)          secure_suid;;
    ssh)           secure_ssh;;
    perm|perms)    secure_perms "$@";;
    firewall)      secure_firewall;;
    selinux)       secure_selinux;;
    app|apps)      secure_apps;;
    network)       secure_network;;
    password)      secure_password "$@";;
    malware)       secure_malware;;
    --json)        TX_JSON=true; secure_audit;;
    -h|--help)
      echo "Usage: tx secure <subcommand> [args]"
      echo "  audit|check    Full security audit"
      echo "  suid           Find SUID/SGID files"
      echo "  ssh            Check SSH security"
      echo "  perms <path>   Check permissions"
      echo "  firewall       Firewall status"
      echo "  selinux        SELinux status"
      echo "  apps           Check app permissions"
      echo "  network        Network security"
      echo "  password <pwd> Password strength check"
      echo "  malware        Basic malware scan"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

secure_audit() {
  log_section "Security Audit"
  log_banner "System"

  # SUID files
  echo -e "\n${YELLOW}SUID Files:${RESET}"
  find / -type f -perm -4000 2>/dev/null | head -10 | sed 's/^/  /'
  [[ $(find / -type f -perm -4000 2>/dev/null | wc -l) -gt 10 ]] && echo "  ... and more"

  # SSH
  if [[ -f /etc/ssh/sshd_config ]]; then
    echo -e "\n${YELLOW}SSH Config:${RESET}"
    grep -E "^PermitRootLogin|^PasswordAuthentication|^Port" /etc/ssh/sshd_config 2>/dev/null | sed 's/^/  /'
  fi

  # Open ports
  echo -e "\n${YELLOW}Open Ports:${RESET}"
  if command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null | tail -n+2 | head -10 | sed 's/^/  /'
  fi

  # World writable files
  echo -e "\n${YELLOW}World-Writable:${RESET}"
  find / -type f -perm -o+w -not -path "/proc/*" -not -path "/sys/*" 2>/dev/null | head -10 | sed 's/^/  /'

  # No owner files
  echo -e "\n${YELLOW}Orphaned Files:${RESET}"
  find / -nouser -o -nogroup 2>/dev/null | head -10 | sed 's/^/  /'

  # Termux specific
  if $IS_TERMUX; then
    echo -e "\n${YELLOW}Termux Security:${RESET}"
    echo -e "  Storage Access: $(ls /sdcard 2>/dev/null && echo ${GREEN}Yes${RESET} || echo ${RED}No${RESET})"
    echo -e "  API Available: $(command -v termux-toast &>/dev/null && echo ${GREEN}Yes${RESET} || echo ${YELLOW}No${RESET})"
  fi

  log_banner "Audit Complete"
}

secure_suid() {
  log_section "SUID/SGID Files"
  log_info "SUID:"
  find / -type f -perm -4000 2>/dev/null | sed 's/^/  /'
  echo -e "\n${BOLD}SGID:${RESET}"
  find / -type f -perm -2000 2>/dev/null | sed 's/^/  /'
}

secure_ssh() {
  log_section "SSH Security"
  if [[ -f /etc/ssh/sshd_config ]]; then
    grep -v "^#" /etc/ssh/sshd_config 2>/dev/null | grep -v "^$" | sed 's/^/  /'
  fi
  echo -e "\n${BOLD}SSH Keys:${RESET}"
  ls -la "$HOME/.ssh/" 2>/dev/null || echo "  No SSH keys found"
}

secure_perms() {
  local path="${1:-/}"
  log_section "Permissions — $path"
  stat "$path" | sed 's/^/  /'
  find "$path" -maxdepth 2 -type f -perm -o+w 2>/dev/null | head -20 | while IFS= read -r f; do
    echo -e "  ${RED}Writable${RESET}: $f"
  done
}

secure_firewall() {
  log_section "Firewall"
  if command -v iptables &>/dev/null; then
    need_root || return 1
    iptables -L -n 2>/dev/null | head -30
  elif command -v nft &>/dev/null; then
    nft list ruleset 2>/dev/null | head -30
  elif command -v ufw &>/dev/null; then
    ufw status verbose 2>/dev/null
  else
    log_warn "No firewall detected"
    if confirm "Install iptables?" "n"; then
      $IS_TERMUX && pkg install -y iptables 2>/dev/null || sudo apt install -y iptables 2>/dev/null
    fi
  fi
}

secure_selinux() {
  log_section "SELinux"
  if command -v getenforce &>/dev/null; then
    echo -e "  Status: ${BOLD}$(getenforce)${RESET}"
    sestatus 2>/dev/null | head -5 | sed 's/^/  /'
  else
    [[ -f /proc/self/attr/current ]] && echo -e "  Context: $(cat /proc/self/attr/current 2>/dev/null)" || echo "  SELinux not available"
  fi
}

secure_apps() {
  log_section "App Security"
  if $IS_TERMUX && command -v pm &>/dev/null; then
    log_info "Apps with SMS permission:"
    pm list packages -3 -p android.permission.RECEIVE_SMS 2>/dev/null | sed 's/^/  /'
    log_info "Apps with CALL permission:"
    pm list packages -3 -p android.permission.CALL_PHONE 2>/dev/null | sed 's/^/  /'
    log_info "Apps with LOCATION permission:"
    pm list packages -3 -p android.permission.ACCESS_FINE_LOCATION 2>/dev/null | sed 's/^/  /'
  else
    log_info "Checking suid apps..."
    secure_suid | head -15
  fi
}

secure_network() {
  log_section "Network Security"
  echo -e "\n${BOLD}Open Ports:${RESET}"
  ss -tlnp 2>/dev/null | tail -n+2 | head -10
  echo -e "\n${BOLD}DNS:${RESET}"
  cat /etc/resolv.conf 2>/dev/null | sed 's/^/  /'
  echo -e "\n${BOLD}ARP Table:${RESET}"
  arp -n 2>/dev/null | head -10
  echo -e "\n${BOLD}Routing:${RESET}"
  ip route 2>/dev/null | head -10
}

secure_password() {
  local pwd="${1:-}"
  [[ -z "$pwd" ]] && read -r -s -p "  Enter password: " pwd && echo
  log_section "Password Strength"
  local len=${#pwd}
  local score=0
  echo -e "  Length    : ${BOLD}$len${RESET}"
  [[ $len -ge 8 ]] && score=$((score+25)) && echo -e "  ${GREEN}✓${RESET} Length >= 8"
  [[ $len -ge 12 ]] && score=$((score+25))
  [[ "$pwd" =~ [a-z] ]] && [[ "$pwd" =~ [A-Z] ]] && score=$((score+25)) && echo -e "  ${GREEN}✓${RESET} Mixed case"
  [[ "$pwd" =~ [0-9] ]] && score=$((score+15)) && echo -e "  ${GREEN}✓${RESET} Contains number"
  [[ "$pwd" =~ [^a-zA-Z0-9] ]] && score=$((score+10)) && echo -e "  ${GREEN}✓${RESET} Contains special char"
  echo ""
  local color="$RED"
  [[ $score -ge 50 ]] && color="$YELLOW"
  [[ $score -ge 75 ]] && color="$GREEN"
  echo -e "  Score     : ${color}${score}%${RESET}"
}

secure_malware() {
  log_section "Malware Scan"
  log_info "Checking for suspicious files..."
  local found=false
  # Check for SUID shells
  for f in /bin/sh /bin/bash /bin/dash /bin/zsh; do
    if [[ -f "$f" ]] && [[ -u "$f" ]]; then
      echo -e "  ${RED}SUID shell: $f${RESET}"
      found=true
    fi
  done
  # Look for suspicious scripts
  for d in /tmp /dev/shm /var/tmp; do
    local suspect
    suspect=$(find "$d" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.pl" \) 2>/dev/null | head -5)
    if [[ -n "$suspect" ]]; then
      echo -e "  ${YELLOW}Suspicious files in $d:${RESET}" && echo "$suspect" | sed 's/^/    /'
      found=true
    fi
  done
  # Check cron
  for crondir in /etc/cron* /var/spool/cron; do
    [[ -d "$crondir" ]] && ls "$crondir" 2>/dev/null | head -10 | while IFS= read -r f; do
      echo -e "  Cron: $crondir/$f"
      found=true
    done
  done
  $found || log_success "No obvious threats detected"
}
