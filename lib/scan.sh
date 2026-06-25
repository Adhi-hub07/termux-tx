#===============================================================================
#  scan — Port Scan, Service Detect, Vuln Check
#===============================================================================

cmd_scan() {
  module_banner "scan" "Port scan, service detection & vulnerability checks"
  local sub="${1:-quick}"; shift 2>/dev/null || true

  case "$sub" in
    quick|fast)    scan_quick "$@";;
    full)          scan_full "$@";;
    service)       scan_service "$@";;
    version)       scan_version "$@";;
    udp)           scan_udp "$@";;
    ping)          scan_ping "$@";;
    top)           scan_top "$@";;
    subnet)        scan_subnet "$@";;
    vuln)          scan_vuln "$@";;
    cve)           scan_cve "$@";;
    os)            scan_os "$@";;
    banner)        scan_banner "$@";;
    firewall)      scan_firewall "$@";;
    stealth)       scan_stealth "$@";;
    --json)        TX_JSON=true; scan_quick "$@";;
    -h|--help)
      echo "Usage: tx scan <subcommand> [host]"
      echo "  quick <host>      Quick scan (top ports)"
      echo "  full <host>       Full port scan (1-65535)"
      echo "  service <host>    Service version detection"
      echo "  version <host>    Aggressive version detect"
      echo "  udp <host>        UDP scan"
      echo "  ping <host>       Ping sweep"
      echo "  top <host>        Top 100 ports"
      echo "  subnet <cidr>     Scan subnet"
      echo "  vuln <host>       Vulnerability scan"
      echo "  cve <host>        CVE lookup"
      echo "  os <host>         OS detection"
      echo "  banner <host>     Banner grabbing"
      echo "  firewall <host>   Firewall detection"
      echo "  stealth <host>    Stealth SYN scan"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

scan_quick() {
  local host="${1:-localhost}"
  log_section "Quick Scan — $host"
  need_cmd nmap && {
    nmap -T4 --open "$host" 2>/dev/null
    return
  }
  log_info "Nmap not found, using bash TCP..."
  for p in 21 22 23 25 53 80 110 143 443 445 993 995 1433 1521 2049 3306 3389 5432 5900 6379 8080 8443 27017; do
    timeout 1 bash -c "echo >/dev/tcp/$host/$p" 2>/dev/null && echo -e "  ${GREEN}OPEN${RESET}  $p"
  done
}

scan_full() {
  local host="${1:-localhost}"
  log_section "Full Scan — $host (1-65535)"
  need_cmd nmap || return 1
  nmap -p- -T4 --open "$host" 2>/dev/null
}

scan_service() {
  local host="${1:-localhost}"
  log_section "Service Detection — $host"
  need_cmd nmap || return 1
  nmap -sV -T4 --open "$host" 2>/dev/null
}

scan_version() {
  local host="${1:-localhost}"
  log_section "Aggressive Version — $host"
  need_cmd nmap || return 1
  nmap -sV --version-intensity 9 -T4 "$host" 2>/dev/null
}

scan_udp() {
  local host="${1:-localhost}"
  log_section "UDP Scan — $host"
  need_cmd nmap || return 1
  nmap -sU -T4 --open "$host" 2>/dev/null
}

scan_ping() {
  local host="${1:-192.168.1.0/24}"
  log_section "Ping Sweep — $host"
  need_cmd nmap && {
    nmap -sn -T4 "$host" 2>/dev/null
    return
  }
  local subnet="${host%/*}"
  local prefix="${subnet%.*}"
  for i in $(seq 1 254); do
    { ping -c1 -W1 "$prefix.$i" 2>/dev/null | grep -q "bytes from" && echo "  ${GREEN}UP${RESET}  $prefix.$i"; } &
  done
  wait
}

scan_top() {
  local host="${1:-localhost}"
  log_section "Top 100 Ports — $host"
  need_cmd nmap || return 1
  nmap --top-ports 100 -T4 --open "$host" 2>/dev/null
}

scan_subnet() {
  local cidr="${1:-192.168.1.0/24}"
  log_section "Subnet Scan — $cidr"
  need_cmd nmap || return 1
  nmap -T4 -sn "$cidr" 2>/dev/null | grep "report for" | awk '{print "  "$NF}'
}

scan_vuln() {
  local host="${1:-localhost}"
  log_section "Vulnerability Scan — $host"
  need_cmd nmap || return 1
  nmap --script vuln -T4 "$host" 2>/dev/null
}

scan_cve() {
  local host="${1:-localhost}"
  log_section "CVE Scan — $host"
  need_cmd nmap || return 1
  nmap --script vulners -T4 "$host" 2>/dev/null
}

scan_os() {
  local host="${1:-localhost}"
  log_section "OS Detection — $host"
  need_cmd nmap || return 1
  nmap -O -T4 "$host" 2>/dev/null
}

scan_banner() {
  local host="${1:-localhost}"
  log_section "Banner Grabbing — $host"
  local ports="${2:-21 22 25 80 110 443 8080}"
  for p in $ports; do
    timeout 2 bash -c "exec 3<>/dev/tcp/$host/$p && echo -e 'HEAD / HTTP/1.0\r\n\r\n' >&3 && cat <&3" 2>/dev/null | head -5 | while IFS= read -r line; do
      echo -e "  [$p] $line"
    done
  done
}

scan_firewall() {
  local host="${1:-localhost}"
  log_section "Firewall Detection — $host"
  need_cmd nmap || return 1
  nmap -sA -T4 "$host" 2>/dev/null
}

scan_stealth() {
  local host="${1:-localhost}"
  log_section "Stealth SYN Scan — $host"
  need_root || return 1
  need_cmd nmap || return 1
  nmap -sS -T4 --open "$host" 2>/dev/null
}
