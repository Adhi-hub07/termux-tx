#===============================================================================
#  net — Network Tools
#===============================================================================

cmd_net() {
  module_banner "net" "Network tools — scan, sniff, resolve, geoip"
  local sub="${1:-info}"; shift 2>/dev/null || true

  case "$sub" in
    info|myip)     net_myip;;
    resolve|dns)   net_resolve "$@";;
    scan|ports)    net_scan "$@";;
    geoip)         net_geoip "$@";;
    ping)          net_ping "$@";;
    traceroute)    net_traceroute "$@";;
    whois)         net_whois "$@";;
    speed)         net_speed;;
    wifi)          net_wifi;;
    interfaces)    net_ifaces;;
    listen|ports)  net_listen;;
    sniff)         net_sniff "$@";;
    dnsdump)       net_dnsdump "$@";;
    subdomain)     net_subdomain "$@";;
    headers)       net_headers "$@";;
    --json)        TX_JSON=true; net_myip;;
    -h|--help)
      echo "Usage: tx net <subcommand> [args]"
      echo "  info|myip              Show public IP & location"
      echo "  resolve <domain>       DNS resolution"
      echo "  scan <host> [ports]    Port scan"
      echo "  geoip <ip>             GeoIP lookup"
      echo "  ping <host>            Ping"
      echo "  traceroute <host>      Traceroute"
      echo "  whois <domain>         WHOIS lookup"
      echo "  speed                  Speed test"
      echo "  wifi                   WiFi info"
      echo "  interfaces|ifaces      Network interfaces"
      echo "  listen                 Listening ports"
      echo "  sniff [interface]      Packet capture"
      echo "  dnsdump <domain>       DNS enumeration"
      echo "  subdomain <domain>     Subdomain discovery"
      echo "  headers <url>          HTTP headers"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

net_myip() {
  log_section "Public IP"
  need_cmd curl || return 1
  local ip json
  ip=$(curl -s --connect-timeout 5 https://api.ipify.org 2>/dev/null || echo "N/A")
  echo -e "  IP        : ${BOLD}${GREEN}$ip${RESET}"
  json=$(curl -s --connect-timeout 5 "http://ip-api.com/json/${ip}" 2>/dev/null || echo "{}")
  echo "$json" | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(f'  ISP       : {d.get(\"isp\",\"N/A\")}')
  print(f'  Org       : {d.get(\"org\",\"N/A\")}')
  print(f'  Location  : {d.get(\"city\",\"?\")}, {d.get(\"region\",\"?\")}, {d.get(\"country\",\"?\")}')
  print(f'  Coords    : {d.get(\"lat\",\"?\")}, {d.get(\"lon\",\"?\")}')
  print(f'  Timezone  : {d.get(\"timezone\",\"N/A\")}')
except: pass" 2>/dev/null || true
}

net_resolve() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx net resolve <domain>"; return 1; }
  log_section "DNS — $domain"
  need_cmds dig host nslookup || true
  if command -v dig &>/dev/null; then
    echo -e "  ${BOLD}A Records:${RESET}"
    dig +short "$domain" A 2>/dev/null | while IFS= read -r ip; do echo -e "    $ip"; done
    echo -e "  ${BOLD}MX Records:${RESET}"
    dig +short "$domain" MX 2>/dev/null | while IFS= read -r mx; do echo -e "    $mx"; done
    echo -e "  ${BOLD}NS Records:${RESET}"
    dig +short "$domain" NS 2>/dev/null | while IFS= read -r ns; do echo -e "    $ns"; done
    echo -e "  ${BOLD}TXT Records:${RESET}"
    dig +short "$domain" TXT 2>/dev/null | while IFS= read -r txt; do echo -e "    $txt"; done
  elif command -v host &>/dev/null; then
    host -a "$domain" 2>/dev/null | head -20
  elif command -v nslookup &>/dev/null; then
    nslookup "$domain" 2>/dev/null
  fi
}

net_scan() {
  local host="${1:-localhost}" ports="${2:-1-1024}"
  log_section "Port Scan — $host"

  if command -v nmap &>/dev/null; then
    log_info "Scanning $host:$ports with nmap..."
    nmap -sT -sV -T4 --open "$host" -p "$ports" 2>/dev/null || nmap "$host" -p "$ports" 2>/dev/null
  elif command -v nc &>/dev/null; then
    log_info "Scanning $host with netcat..."
    local IFS=-
    if [[ "$ports" == *-* ]]; then
      local start="${ports%-*}" end="${ports#*-}"
      for p in $(seq "$start" "$end"); do
        timeout 1 bash -c "echo >/dev/tcp/$host/$p" 2>/dev/null && echo -e "  ${GREEN}OPEN${RESET}  $p"
      done
    else
      for p in ${ports//,/ }; do
        timeout 1 bash -c "echo >/dev/tcp/$host/$p" 2>/dev/null && echo -e "  ${GREEN}OPEN${RESET}  $p"
      done
    fi
  else
    log_info "Using bash TCP (basic scan)..."
    local IFS=-
    if [[ "$ports" == *-* ]]; then
      local start="${ports%-*}" end="${ports#*-}"
      for p in $(seq "$start" "$end"); do
        timeout 1 bash -c "echo >/dev/tcp/$host/$p" 2>/dev/null && echo -e "  ${GREEN}OPEN${RESET}  $p"
      done
    fi
  fi
}

net_geoip() {
  local ip="${1:-}"
  [[ -z "$ip" ]] && { log_error "Usage: tx net geoip <ip>"; return 1; }
  log_section "GeoIP — $ip"
  need_cmd curl || return 1
  curl -s "http://ip-api.com/json/$ip" 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(f'  IP        : {d.get(\"query\",\"N/A\")}')
  print(f'  Country   : {d.get(\"country\",\"N/A\")} ({d.get(\"countryCode\",\"\")})')
  print(f'  Region    : {d.get(\"regionName\",\"N/A\")}')
  print(f'  City      : {d.get(\"city\",\"N/A\")}')
  print(f'  ZIP       : {d.get(\"zip\",\"N/A\")}')
  print(f'  Coords    : {d.get(\"lat\",\"?\")}, {d.get(\"lon\",\"?\")}')
  print(f'  ISP       : {d.get(\"isp\",\"N/A\")}')
  print(f'  Org       : {d.get(\"org\",\"N/A\")}')
  print(f'  AS        : {d.get(\"as\",\"N/A\")}')
  print(f'  Timezone  : {d.get(\"timezone\",\"N/A\")}')
except: print('Lookup failed')
" 2>/dev/null
}

net_ping() {
  local host="${1:-8.8.8.8}" count="${2:-4}"
  log_section "Ping — $host"
  if command -v ping &>/dev/null; then
    ping -c "$count" "$host" 2>/dev/null || ping -c "$count" -W 3 "$host" 2>/dev/null || {
      log_error "Ping failed"
      return 1
    }
  else
    log_error "ping not installed"
    return 1
  fi
}

net_traceroute() {
  local host="${1:-google.com}"
  log_section "Traceroute — $host"
  need_cmds traceroute || return 1
  traceroute -n "$host" 2>/dev/null || traceroute "$host" 2>/dev/null
}

net_whois() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx net whois <domain>"; return 1; }
  log_section "WHOIS — $domain"
  need_cmd whois || return 1
  whois "$domain" 2>/dev/null | head -40
}

net_speed() {
  log_section "Speed Test"
  if command -v speedtest-cli &>/dev/null; then
    speedtest-cli --simple 2>/dev/null
  elif command -v speedtest &>/dev/null; then
    speedtest --simple 2>/dev/null
  else
    log_info "Testing download speed (fast.com method)..."
    need_cmd curl || return 1
    local start end size speed
    start=$(date +%s%N)
    size=$(curl -s -o /dev/null -w '%{size_download}' --connect-timeout 10 "https://proof.ovh.net/files/100Mb.dat" 2>/dev/null || echo 0)
    end=$(date +%s%N)
    speed=$(( size * 8 * 1000000000 / (end - start) / 1000000 ))
    echo -e "  Download  : ${BOLD}${speed} Mbps${RESET}"
  fi
}

net_wifi() {
  log_section "WiFi"
  if $IS_TERMUX && command -v termux-wifi-connectioninfo &>/dev/null; then
    termux-wifi-connectioninfo 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(f'  SSID      : {d.get(\"ssid\",\"N/A\")}')
  print(f'  BSSID     : {d.get(\"bssid\",\"N/A\")}')
  print(f'  Frequency : {d.get(\"frequency\",\"?\")} MHz')
  print(f'  RSSI      : {d.get(\"rssi\",\"?\")} dBm')
  speed = d.get('link_speed', d.get('linkspeed', None))
  if speed: print(f'  Speed     : {speed} Mbps')
except: pass" 2>/dev/null || true
    command -v termux-wifi-scaninfo &>/dev/null && {
      echo -e "  ${BOLD}Available Networks:${RESET}"
      termux-wifi-scaninfo 2>/dev/null | python3 -c "
import sys, json
try:
  nets = json.load(sys.stdin)
  for n in sorted(nets, key=lambda x: -x.get('level', -100))[:10]:
    print(f'  {n.get(\"ssid\",\"?\"):25s} {n.get(\"bssid\",\"?\")}  {n.get(\"level\",\"?\")} dBm')
except: pass" 2>/dev/null || true
    }
  elif command -v iwconfig &>/dev/null; then
    iwconfig 2>/dev/null | head -10
  elif command -v iw &>/dev/null; then
    iw dev 2>/dev/null
  else
    log_warn "No WiFi tools available"
  fi
}

net_ifaces() {
  log_section "Interfaces"
  if command -v ip &>/dev/null; then
    ip addr show 2>/dev/null | grep -E "^[0-9]|inet"
  else
    ifconfig 2>/dev/null || cat /proc/net/dev
  fi
}

net_listen() {
  log_section "Listening Ports"
  if command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null || ss -tln 2>/dev/null
  elif command -v netstat &>/dev/null; then
    netstat -tlnp 2>/dev/null || netstat -tln 2>/dev/null
  elif [[ -f /proc/net/tcp ]]; then
    log_info "Parsing /proc/net/tcp..."
    awk '{print $2}' /proc/net/tcp | while IFS=: read -r ip port; do
      echo -e "  0.0.0.0:$((0x$port))" 2>/dev/null
    done
  fi
}

net_sniff() {
  local iface="${1:-}"
  log_section "Packet Capture"
  need_cmd tcpdump || return 1
  if [[ -z "$iface" ]]; then
    iface=$(ip route 2>/dev/null | grep default | awk '{print $5}' | head -1)
    [[ -z "$iface" ]] && iface="wlan0"
  fi
  log_info "Sniffing on $iface (5 packets)..."
  log_warn "Root may be required"
  timeout 10 tcpdump -i "$iface" -c 5 -nn 2>/dev/null || {
    log_error "Failed. Try: sudo tx net sniff $iface"
    return 1
  }
}

net_dnsdump() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx net dnsdump <domain>"; return 1; }
  log_section "DNS Enumeration — $domain"
  need_cmds dig host || return 1
  for type in A AAAA MX NS TXT CNAME SOA; do
    local result
    result=$(dig +short "$domain" "$type" 2>/dev/null)
    [[ -n "$result" ]] && echo -e "  ${BOLD}$type:${RESET}" && echo "$result" | sed 's/^/    /'
  done
}

net_subdomain() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx net subdomain <domain>"; return 1; }
  log_section "Subdomain Discovery — $domain"
  need_cmd curl || return 1
  log_info "Querying crt.sh..."
  curl -s "https://crt.sh/?q=%25.$domain&output=json" 2>/dev/null | python3 -c "
import sys, json
try:
  data = json.load(sys.stdin)
  subs = set()
  for entry in data:
    name = entry.get('name_value','')
    for n in name.split('\\n'):
      n = n.strip().lower()
      if n.endswith('.$domain') or n == '$domain':
        subs.add(n)
  for s in sorted(subs)[:50]:
    print(f'  $s')
  print(f'\\n  Total: {len(subs)} subdomains')
except: print('No results')
" 2>/dev/null
}

net_headers() {
  local url="${1:-}"
  [[ -z "$url" ]] && { log_error "Usage: tx net headers <url>"; return 1; }
  log_section "HTTP Headers — $url"
  need_cmd curl || return 1
  curl -sI -L "$url" 2>/dev/null || curl -sI "$url" 2>/dev/null
}
