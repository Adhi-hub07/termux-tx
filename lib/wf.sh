#===============================================================================
#  wf — WiFi Audit Tools
#===============================================================================

cmd_wf() {
  module_banner "wf" "WiFi audit & security tools"
  local sub="${1:-help}"; shift 2>/dev/null || true

  case "$sub" in
    scan|list)     wf_scan;;
    info)          wf_info;;
    deauth)        wf_deauth "$@";;
    handshake)     wf_handshake "$@";;
    crack)         wf_crack "$@";;
    monitor)       wf_monitor "$@";;
    managed)       wf_managed "$@";;
    airodump)      wf_airodump "$@";;
    --json)        TX_JSON=true; wf_scan;;
    -h|--help)
      echo "Usage: tx wf <subcommand> [args]"
      echo "  scan|list         Scan WiFi networks"
      echo "  info              Current connection info"
      echo "  deauth <bssid>    Deauth attack (requires root)"
      echo "  handshake <bssid> Capture handshake"
      echo "  crack <cap>       Crack WPA handshake"
      echo "  monitor           Enable monitor mode"
      echo "  managed           Disable monitor mode"
      echo "  airodump <iface>  Airodump runner"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

wf_scan() {
  log_section "WiFi Networks"
  if command -v iw &>/dev/null; then
    iw dev 2>/dev/null | grep -E "Interface" | awk '{print $2}' | while IFS= read -r iface; do
      echo -e "\n${BOLD}$iface:${RESET}"
      iw dev "$iface" scan 2>/dev/null | grep -E "SSID|signal|freq|BSS" | head -30
    done
  elif command -v iwlist &>/dev/null; then
    for iface in /sys/class/net/*; do
      local name
      name=$(basename "$iface")
      echo -e "\n${BOLD}$name:${RESET}"
      iwlist "$name" scan 2>/dev/null | grep -E "ESSID|Signal|Frequency|Address" | head -30
    done
  elif $IS_TERMUX && command -v termux-wifi-scaninfo &>/dev/null; then
    termux-wifi-scaninfo 2>/dev/null | python3 -c "
import sys, json
try:
  nets = json.load(sys.stdin)
  for n in sorted(nets, key=lambda x: -x.get('level', -100)):
    print(f'  {n.get(\"ssid\",\"?\"):30s} {n.get(\"bssid\",\"?\")}  {n.get(\"frequency\",\"?\")}MHz  {n.get(\"level\",\"?\")}dBm')
except: pass
" 2>/dev/null
  else
    log_warn "No WiFi scanning tools available"
    log_info "Install: iw (pkg install iw) or root for better scanning"
  fi
}

wf_info() {
  log_section "Current Connection"
  if $IS_TERMUX && command -v termux-wifi-connectioninfo &>/dev/null; then
    termux-wifi-connectioninfo 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  for k,v in d.items():
    print(f'  {k}: {v}')
except: pass
" 2>/dev/null
  elif command -v iwconfig &>/dev/null; then
    iwconfig 2>/dev/null | head -10
  elif command -v iw &>/dev/null; then
    iw dev 2>/dev/null | grep -E "ssid|freq|signal"
  fi
}

wf_monitor() {
  local iface="${1:-wlan0}"
  log_section "Monitor Mode — $iface"
  need_root || return 1
  need_cmd airmon-ng || {
    log_info "Installing aircrack-ng..."
    if $IS_TERMUX; then pkg install -y aircrack-ng 2>/dev/null
    else sudo apt install -y aircrack-ng 2>/dev/null; fi
  }
  airmon-ng start "$iface" 2>/dev/null
}

wf_managed() {
  local iface="${1:-wlan0mon}"
  log_section "Managed Mode — $iface"
  need_root || return 1
  airmon-ng stop "$iface" 2>/dev/null
}

wf_deauth() {
  local bssid="${1:-}" iface="${2:-wlan0mon}"
  [[ -z "$bssid" ]] && { log_error "Usage: tx wf deauth <bssid> [iface]"; return 1; }
  log_section "Deauth Attack — $bssid"
  need_root || return 1
  need_cmd aireplay-ng || return 1
  log_warn "Sending deauth packets to $bssid..."
  aireplay-ng -0 5 -a "$bssid" "$iface" 2>/dev/null
}

wf_handshake() {
  local bssid="${1:-}" channel="${2:-1}" iface="${3:-wlan0mon}"
  [[ -z "$bssid" ]] && { log_error "Usage: tx wf handshake <bssid> [channel] [iface]"; return 1; }
  log_section "Capture Handshake — $bssid"
  need_root || return 1
  need_cmd airodump-ng || return 1
  log_info "Listening on $iface for handshake..."
  airodump-ng -c "$channel" --bssid "$bssid" -w /tmp/handshake "$iface" 2>/dev/null &
  local pid=$!
  sleep 15
  kill "$pid" 2>/dev/null
  log_success "Output: /tmp/handshake-01.cap"
}

wf_crack() {
  local cap="${1:-/tmp/handshake-01.cap}" wordlist="${2:-/usr/share/wordlists/rockyou.txt}"
  [[ ! -f "$cap" ]] && { log_error "CAP file not found: $cap"; return 1; }
  log_section "Crack WPA — $cap"
  need_cmd aircrack-ng || return 1
  if [[ -f "$wordlist" ]]; then
    aircrack-ng -w "$wordlist" "$cap" 2>/dev/null
  else
    log_warn "Wordlist not found: $wordlist"
    log_info "Download: curl -L -o /tmp/wordlist.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10k-most-common.txt"
  fi
}

wf_airodump() {
  local iface="${1:-wlan0mon}"
  log_section "Airodump — $iface"
  need_root || return 1
  need_cmd airodump-ng || return 1
  airodump-ng "$iface" 2>/dev/null
}
