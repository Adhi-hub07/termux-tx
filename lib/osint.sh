#===============================================================================
#  osint — OSINT Reconnaissance
#===============================================================================

cmd_osint() {
  module_banner "osint" "OSINT — recon, email, domain, ip, social"
  local sub="${1:-help}"; shift 2>/dev/null || true

  case "$sub" in
    domain)        osint_domain "$@";;
    ip)            osint_ip "$@";;
    email)         osint_email "$@";;
    phone)         osint_phone "$@";;
    social|user)   osint_social "$@";;
    breach)        osint_breach "$@";;
    dns)           osint_dns "$@";;
    subdomain)     osint_subdomain "$@";;
    cert|ssl)      osint_cert "$@";;
    github)        osint_github "$@";;
    shodan)        osint_shodan "$@";;
    whois)         osint_whois "$@";;
    web|website)   osint_web "$@";;
    wayback)       osint_wayback "$@";;
    all)           osint_all "$@";;
    -h|--help)
      echo "Usage: tx osint <subcommand> [target]"
      echo "  domain <domain>    Domain recon (DNS, WHOIS, SSL, subdomains)"
      echo "  ip <ip>            IP recon (GeoIP, RDAP, DNS)"
      echo "  email <email>      Email recon (breach, social)"
      echo "  phone <number>     Phone lookup"
      echo "  social <username>  Social media search"
      echo "  breach <email>     Data breach lookup"
      echo "  dns <domain>       DNS enumeration"
      echo "  subdomain <domain> Subdomain discovery"
      echo "  cert <domain>      Certificate transparency"
      echo "  github <user>      GitHub recon"
      echo "  shodan <ip>        Shodan lookup"
      echo "  whois <domain>     WHOIS lookup"
      echo "  web <url>          Website recon"
      echo "  wayback <domain>   Wayback Machine history"
      echo "  all <domain>       Full domain recon"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

osint_domain() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx osint domain <domain>"; return 1; }
  log_section "Domain Recon — $domain"
  need_cmd curl || return 1

  # DNS
  echo -e "\n${BOLD}DNS Records:${RESET}"
  for type in A AAAA MX NS TXT; do
    local result
    result=$(dig +short "$domain" "$type" 2>/dev/null)
    [[ -n "$result" ]] && echo -e "  $type:" && echo "$result" | sed 's/^/    /'
  done

  # WHOIS
  echo -e "\n${BOLD}WHOIS:${RESET}"
  if command -v whois &>/dev/null; then
    whois "$domain" 2>/dev/null | grep -E "Registrar|Creation|Expir|Name Server|Registrant|Admin|Tech" | head -10 | sed 's/^/  /'
  fi

  # SSL Cert
  echo -e "\n${BOLD}Certificate:${RESET}"
  curl -s "https://crt.sh/?q=%25.$domain&output=json" 2>/dev/null | python3 -c "
import sys, json
try:
  data = json.load(sys.stdin)
  subs = set()
  for e in data:
    for n in e.get('name_value','').split('\\n'):
      if n: subs.add(n.lower())
  print('  Subdomains from certs:')
  for s in sorted(subs)[:20]:
    print(f'    $s')
  if len(subs) > 20: print(f'    ... and {len(subs)-20} more')
except: print('  No cert data')
" 2>/dev/null

  # Wayback
  echo -e "\n${BOLD}Wayback URLs:${RESET}"
  curl -s "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=text&fl=original&limit=10" 2>/dev/null | sed 's/^/  /'
}

osint_ip() {
  local ip="${1:-}"
  [[ -z "$ip" ]] && { log_error "Usage: tx osint ip <ip>"; return 1; }
  log_section "IP Recon — $ip"
  need_cmd curl || return 1

  curl -s "http://ip-api.com/json/$ip" 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  for k,v in d.items():
    print(f'  {k}: {v}')
except: print('Lookup failed')
" 2>/dev/null
}

osint_email() {
  local email="${1:-}"
  [[ -z "$email" ]] && { log_error "Usage: tx osint email <email>"; return 1; }
  log_section "Email Recon — $email"
  need_cmd curl || return 1

  # Breach check via leak-lookup (public API)
  echo -e "\n${BOLD}Breach Check:${RESET}"
  local domain="${email#*@}"
  if command -v haveibeenpwned &>/dev/null; then
    haveibeenpwned "$email" 2>/dev/null
  else
    curl -s "https://leak-check.net/api/v2/check?email=$email" 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  if d.get('breaches'):
    for b in d['breaches']: print(f'  ${RED}BREACHED${RESET}: {b}')
  else: print('  No known breaches')
except: print('  Check failed')
" 2>/dev/null || echo "  Install haveibeenpwned or use breach module"
  fi

  # Domain MX
  echo -e "\n${BOLD}Mail Server:${RESET}"
  dig +short "$domain" MX 2>/dev/null | head -5 | sed 's/^/  /'

  # Google search for email
  echo -e "\n${BOLD}Google Dork:${RESET}"
  log_info "Searching for \"$email\"..."
  curl -s "https://www.google.com/search?q=%22$email%22" -A "Mozilla/5.0" 2>/dev/null | grep -oP '(?<=<h3>)[^<]+' | head -5 | sed 's/^/  /'
}

osint_phone() {
  local phone="${1:-}"
  [[ -z "$phone" ]] && { log_error "Usage: tx osint phone <number>"; return 1; }
  log_section "Phone Lookup — $phone"
  need_cmd curl || return 1

  curl -s "https://phonevalidation.abstractapi.com/v1/?api_key=demo&phone=$phone" 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  for k,v in d.items():
    print(f'  $k: $v')
except: print('Lookup failed')
" 2>/dev/null || echo "  API requires key, trying local format check..."
  echo -e "  Number    : ${BOLD}$phone${RESET}"
  echo -e "  Length    : ${BOLD}${#phone}${RESET}"
}

osint_social() {
  local username="${1:-}"
  [[ -z "$username" ]] && { log_error "Usage: tx osint social <username>"; return 1; }
  log_section "Social Media — $username"
  need_cmd curl || return 1

  local platforms=(
    "GitHub:https://github.com/$username"
    "Twitter/X:https://twitter.com/$username"
    "Instagram:https://instagram.com/$username"
    "Reddit:https://reddit.com/user/$username"
    "YouTube:https://youtube.com/@$username"
    "LinkedIn:https://linkedin.com/in/$username"
    "TikTok:https://tiktok.com/@$username"
    "Facebook:https://facebook.com/$username"
    "Medium:https://medium.com/@$username"
    "Dev.to:https://dev.to/$username"
  )

  for entry in "${platforms[@]}"; do
    local name="${entry%%:*}"
    local url="${entry#*:}"
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" -A "Mozilla/5.0" --connect-timeout 5 "$url" 2>/dev/null)
    if [[ "$code" == "200" ]] || [[ "$code" == "301" ]] || [[ "$code" == "302" ]]; then
      echo -e "  ${GREEN}FOUND${RESET}  $name: $url"
    else
      echo -e "  ${DIM}--${RESET}    $name"
    fi
  done
}

osint_breach() {
  local email="${1:-}"
  [[ -z "$email" ]] && { log_error "Usage: tx osint breach <email>"; return 1; }
  log_section "Breach Check — $email"
  need_cmd curl || return 1

  curl -s "https://leak-check.net/api/v2/check?email=$email" 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  if d.get('breaches'):
    print(f'  ${RED}Found in breaches:${RESET}')
    for b in d['breaches']: print(f'    - $b')
  else:
    print(f'  ${GREEN}No known breaches${RESET}')
except: print('  API unavailable')
" 2>/dev/null
}

osint_dns() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx osint dns <domain>"; return 1; }
  log_section "DNS Enumeration — $domain"
  need_cmds dig host || return 1

  for type in A AAAA CNAME MX NS TXT SOA SRV; do
    local out
    out=$(dig +short "$domain" "$type" 2>/dev/null)
    [[ -n "$out" ]] && echo -e "  ${BOLD}$type:${RESET}" && echo "$out" | sed 's/^/    /'
  done
}

osint_subdomain() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx osint subdomain <domain>"; return 1; }
  log_section "Subdomain Discovery — $domain"
  need_cmd curl || return 1

  log_info "crt.sh..."
  curl -s "https://crt.sh/?q=%25.$domain&output=json" 2>/dev/null | python3 -c "
import sys, json
try:
  data = json.load(sys.stdin)
  subs = set()
  for e in data:
    for n in e.get('name_value','').split('\\n'):
      n = n.strip().lower()
      if n: subs.add(n)
  for s in sorted(subs)[:50]:
    print(f'  $s')
  if len(subs) > 50: print(f'  ... and {len(subs) - 50} more')
except: print('  No results')
" 2>/dev/null
}

osint_cert() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx osint cert <domain>"; return 1; }
  log_section "Certificate Transparency — $domain"
  need_cmd curl || return 1

  curl -s "https://crt.sh/?q=$domain&output=json" 2>/dev/null | python3 -c "
import sys, json
try:
  data = json.load(sys.stdin)
  for e in data[:20]:
    print(f'  {e.get(\"common_name\",\"?\")} | {e.get(\"not_before\",\"?\")} - {e.get(\"not_after\",\"?\")}')
  if len(data) > 20: print(f'  ... {len(data)} total')
except: print('  No cert data')
" 2>/dev/null
}

osint_github() {
  local user="${1:-}"
  [[ -z "$user" ]] && { log_error "Usage: tx osint github <username>"; return 1; }
  log_section "GitHub Recon — $user"
  need_cmd curl || return 1

  curl -s "https://api.github.com/users/$user" 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  if d.get('message','') == 'Not Found': print('  ${RED}User not found${RESET}')
  else:
    for k in ['login','name','company','blog','location','email','bio','public_repos','followers','following','created_at']:
      if d.get(k): print(f'  $k: {d[k]}')
except: print('  API error')
" 2>/dev/null
}

osint_shodan() {
  local ip="${1:-}"
  [[ -z "$ip" ]] && { log_error "Usage: tx osint shodan <ip>"; return 1; }
  log_section "Shodan Lookup — $ip"
  need_cmd curl || return 1
  log_warn "Requires Shodan API key. Set SHODAN_API_KEY env var."
  if [[ -n "${SHODAN_API_KEY:-}" ]]; then
    curl -s "https://api.shodan.io/shodan/host/$ip?key=$SHODAN_API_KEY" 2>/dev/null | python3 -m json.tool 2>/dev/null
  else
    curl -s "https://internetdb.shodan.io/$ip" 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(f'  IP: {d.get(\"ip\",\"N/A\")}')
  print(f'  Ports: {d.get(\"ports\",[])}')
  print(f'  Hostnames: {d.get(\"hostnames\",[])}')
  print(f'  Tags: {d.get(\"tags\",[])}')
except: print('  No public data')
" 2>/dev/null
  fi
}

osint_whois() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx osint whois <domain>"; return 1; }
  log_section "WHOIS — $domain"
  need_cmd whois || return 1
  whois "$domain" 2>/dev/null | grep -E "^[[:alnum:]]" | head -30
}

osint_web() {
  local url="${1:-}"
  [[ -z "$url" ]] && { log_error "Usage: tx osint web <url>"; return 1; }
  log_section "Website Recon — $url"
  need_cmd curl || return 1

  echo -e "\n${BOLD}Headers:${RESET}"
  curl -sI -L "$url" 2>/dev/null | head -20 | sed 's/^/  /'

  echo -e "\n${BOLD}Technologies:${RESET}"
  curl -s "https://whatcms.org/API/Endpoint?url=$url" 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(f'  CMS: {d.get(\"cms\",\"Unknown\")}')
except: print('  API unavailable')
" 2>/dev/null || log_info "Install whatcms or wappalyzer for tech detection"

  echo -e "\n${BOLD}Email Extraction:${RESET}"
  curl -sL "$url" 2>/dev/null | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort -u | head -10 | sed 's/^/  /'

  echo -e "\n${BOLD}Links:${RESET}"
  curl -sL "$url" 2>/dev/null | grep -oP 'href="[^"]*"' | cut -d'"' -f2 | sort -u | head -15 | sed 's/^/  /'
}

osint_wayback() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx osint wayback <domain>"; return 1; }
  log_section "Wayback Machine — $domain"
  need_cmd curl || return 1

  curl -s "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=text&fl=original,timestamp&limit=30" 2>/dev/null | sed 's/^/  /'
}

osint_all() {
  local target="${1:-}"
  [[ -z "$target" ]] && { log_error "Usage: tx osint all <domain/ip>"; return 1; }
  log_section "Full OSINT — $target"

  # Check if it's an IP or domain
  if [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    osint_ip "$target"
    osint_shodan "$target"
  else
    osint_domain "$target"
    osint_subdomain "$target"
    osint_dns "$target"
    osint_whois "$target"
    osint_web "https://$target"
    osint_wayback "$target"
  fi
}
