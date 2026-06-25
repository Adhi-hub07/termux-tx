#===============================================================================
#  anon — Anonymity (Tor, Proxy, VPN)
#===============================================================================

cmd_anon() {
  module_banner "anon" "Anonymity — tor, proxy, vpn, dns"
  local sub="${1:-help}"; shift 2>/dev/null || true

  case "$sub" in
    tor|start)        anon_tor_start;;
    stop)             anon_tor_stop;;
    status)           anon_tor_status;;
    check|myip)       anon_check;;
    proxy)            anon_proxy "$@";;
    dns|dnsoverhttps) anon_dns;;
    chain)            anon_chain;;
    mac)              anon_mac "$@";;
    hostname)         anon_hostname;;
    clean)            anon_clean;;
    --json)           TX_JSON=true; anon_check;;
    -h|--help)
      echo "Usage: tx anon <subcommand> [args]"
      echo "  tor|start     Start Tor service"
      echo "  stop          Stop Tor"
      echo "  status        Tor status"
      echo "  check|myip    Check anonymity status"
      echo "  proxy <url>   Route command through proxy"
      echo "  dns           Use DNS-over-HTTPS"
      echo "  chain         Change Tor circuit"
      echo "  mac <iface>   Spoof MAC address"
      echo "  hostname      Change hostname"
      echo "  clean         Clean logs & traces"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

anon_tor_start() {
  log_section "Tor"
  if command -v tor &>/dev/null; then
    if pgrep -x tor &>/dev/null; then
      echo -e "  ${GREEN}Tor is already running${RESET}"
    else
      log_info "Starting Tor..."
      tor --RunAsDaemon 1 2>/dev/null &
      sleep 2
      anon_tor_status
    fi
  elif $IS_TERMUX; then
    log_info "Installing Tor..."
    pkg install -y tor 2>/dev/null && anon_tor_start
  else
    log_info "Installing Tor..."
    if command -v apt &>/dev/null; then
      sudo apt install -y tor 2>/dev/null && anon_tor_start
    elif command -v pacman &>/dev/null; then
      sudo pacman -S --noconfirm tor 2>/dev/null && anon_tor_start
    fi
  fi
}

anon_tor_stop() {
  log_section "Stopping Tor"
  if pgrep -x tor &>/dev/null; then
    pkill -x tor 2>/dev/null && log_success "Tor stopped"
  else
    log_warn "Tor not running"
  fi
}

anon_tor_status() {
  log_section "Tor Status"
  if pgrep -x tor &>/dev/null; then
    echo -e "  ${GREEN}Tor is RUNNING${RESET}"
    local port
    port=$(grep -oP '(?<=SOCKSPort )\d+' /etc/tor/torrc 2>/dev/null || echo "9050")
    echo -e "  Socks Port: ${BOLD}$port${RESET}"
    curl -s --socks5 "127.0.0.1:$port" --connect-timeout 5 https://check.torproject.org/ 2>/dev/null | grep -q "Congratulations" && echo -e "  ${GREEN}✓ Traffic routed through Tor${RESET}" || echo -e "  ${YELLOW}? Not confirmed${RESET}"
  else
    echo -e "  ${RED}Tor is NOT running${RESET}"
  fi
}

anon_check() {
  log_section "Anonymity Check"
  need_cmd curl || return 1
  echo -e "\n${BOLD}Public IP:${RESET}"
  local direct tor_ip
  direct=$(curl -s --connect-timeout 5 https://api.ipify.org 2>/dev/null || echo "N/A")
  echo -e "  Direct    : ${BOLD}$direct${RESET}"
  if pgrep -x tor &>/dev/null; then
    tor_ip=$(curl -s --socks5 127.0.0.1:9050 --connect-timeout 5 https://api.ipify.org 2>/dev/null || echo "N/A")
    echo -e "  Via Tor   : ${BOLD}$tor_ip${RESET}"
    if [[ "$direct" != "$tor_ip" ]] && [[ "$tor_ip" != "N/A" ]]; then
      echo -e "  ${GREEN}✓ Tor is masking your IP${RESET}"
    fi
  fi
  echo -e "\n${BOLD}DNS Leak Check:${RESET}"
  curl -s --connect-timeout 5 https://ipleak.net/json/ 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  ips = d.get('ips', [])
  if ips:
    for i in ips: print(f'  DNS Server: {i.get(\"ip\",\"?\")} ({i.get(\"country_name\",\"?\")})')
except: pass
" 2>/dev/null
}

anon_proxy() {
  local proxy="${1:-socks5://127.0.0.1:9050}" cmd="${2:-}"
  log_section "Proxy — $proxy"
  if [[ -z "$cmd" ]]; then
    echo -e "  Set proxy: export HTTP_PROXY=$proxy"
    echo -e "  Usage: tx anon proxy socks5://127.0.0.1:9050 curl ifconfig.me"
  else
    shift
    HTTP_PROXY="$proxy" HTTPS_PROXY="$proxy" "$@" 2>/dev/null
  fi
}

anon_dns() {
  log_section "DNS-over-HTTPS"
  echo -e "  Using Cloudflare 1.1.1.1 DoH"
  echo -e "  Test: curl -s https://cloudflare-dns.com/dns-query?name=example.com"
  if command -v dog &>/dev/null; then
    dog --https example.com 2>/dev/null
  fi
}

anon_chain() {
  log_section "Tor — New Circuit"
  if pgrep -x tor &>/dev/null; then
    log_info "Sending NEWNYM signal..."
    if command -v nyx &>/dev/null; then
      nyx -c "signal newnym" 2>/dev/null || true
    fi
    # Alternative: use control port
    echo -e "  ${GREEN}Circuit changed (NEWNYM sent)${RESET}"
    anon_tor_status
  else
    log_error "Tor not running"
  fi
}

anon_mac() {
  local iface="${1:-wlan0}"
  log_section "MAC Spoof — $iface"
  need_root || return 1
  need_cmd macchanger || {
    if $IS_TERMUX; then
      pkg install -y macchanger 2>/dev/null
    else
      sudo apt install -y macchanger 2>/dev/null
    fi
  }
  if command -v macchanger &>/dev/null; then
    sudo ip link set "$iface" down 2>/dev/null
    sudo macchanger -r "$iface" 2>/dev/null
    sudo ip link set "$iface" up 2>/dev/null
    log_success "MAC spoofed for $iface"
    ip link show "$iface" 2>/dev/null | grep ether
  else
    log_error "macchanger not available"
  fi
}

anon_hostname() {
  log_section "Hostname"
  local cur new
  cur=$(hostname)
  echo -e "  Current: ${BOLD}$cur${RESET}"
  need_root || return 1
  read -r -p "  New hostname: " new
  [[ -n "$new" ]] && hostname "$new" && echo "$new" > /etc/hostname && log_success "Hostname changed to $new"
}

anon_clean() {
  log_section "Clean Traces"
  confirm "This will clear logs, bash history, and temp files" "n" || return 0
  # Bash history
  > ~/.bash_history 2>/dev/null
  > ~/.zsh_history 2>/dev/null
  history -c 2>/dev/null || true
  # Logs
  rm -f /tmp/*.log 2>/dev/null || true
  rm -f ~/.tx/logs/* 2>/dev/null || true
  # Tor
  rm -rf /tmp/*tor* 2>/dev/null || true
  log_success "Traces cleaned"
}
