#===============================================================================
#  crypto — Encryption, Hash, Encode/Decode
#===============================================================================

cmd_crypto() {
  module_banner "crypto" "Encryption, hashing, encoding & decoding"
  local sub="${1:-help}"; shift 2>/dev/null || true

  case "$sub" in
    hash)         crypto_hash "$@";;
    encrypt)      crypto_encrypt "$@";;
    decrypt)      crypto_decrypt "$@";;
    encode)       crypto_encode "$@";;
    decode)       crypto_decode "$@";;
    base64)       crypto_base64 "$@";;
    base32)       crypto_base32 "$@";;
    hex)          crypto_hex "$@";;
    rot13)        crypto_rot13 "$@";;
    xor)          crypto_xor "$@";;
    genkey|key)   crypto_genkey "$@";;
    ssl)          crypto_ssl "$@";;
    gpg)          crypto_gpg "$@";;
    checksum)     crypto_checksum "$@";;
    cipher)       crypto_cipher "$@";;
    --json)       TX_JSON=true; crypto_hash "$@";;
    -h|--help)
      echo "Usage: tx crypto <subcommand> [args]"
      echo "  hash <algo> <str/file>   Hash a string or file"
      echo "  encrypt <method> <data>  Encrypt data"
      echo "  decrypt <method> <data>  Decrypt data"
      echo "  encode <type> <data>     Encode data"
      echo "  decode <type> <data>     Decode data"
      echo "  base64 <str>             Base64 encode"
      echo "  base32 <str>             Base32 encode"
      echo "  hex <str>                Hex encode"
      echo "  rot13 <str>              ROT13 cipher"
      echo "  xor <str> <key>          XOR cipher"
      echo "  genkey [bits]            Generate crypto keys"
      echo "  ssl <domain>             SSL certificate info"
      echo "  gpg <file>               GPG encrypt/decrypt"
      echo "  checksum <file>          Compute all hashes"
      echo "  cipher <type>            List supported ciphers"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

crypto_hash() {
  local algo="${1:-sha256}" data="${2:-}"
  [[ -z "$data" ]] && { log_error "Usage: tx crypto hash <algo> <str|file>"; return 1; }
  log_section "Hash — $algo"
  local result=""
  if [[ -f "$data" ]]; then
    result=$(openssl dgst "-$algo" "$data" 2>/dev/null | awk '{print $NF}' || "${algo}sum" "$data" 2>/dev/null | awk '{print $1}')
  else
    result=$(echo -n "$data" | openssl dgst "-$algo" 2>/dev/null | awk '{print $NF}' || echo -n "$data" | "${algo}sum" 2>/dev/null | awk '{print $1}')
  fi
  echo -e "  ${BOLD}${algo^^}:${RESET} $result"
}

crypto_encrypt() {
  local method="${1:-aes-256-cbc}" data="${2:-}"
  [[ -z "$data" ]] && { log_error "Usage: tx crypto encrypt <method> <data>"; return 1; }
  log_section "Encrypt — $method"
  need_cmd openssl || return 1
  local result
  result=$(echo -n "$data" | openssl enc "-$method" -base64 -pbkdf2 -pass pass:tx-pass 2>/dev/null)
  echo -e "  ${BOLD}Encrypted:${RESET} $result"
}

crypto_decrypt() {
  local method="${1:-aes-256-cbc}" data="${2:-}"
  [[ -z "$data" ]] && { log_error "Usage: tx crypto decrypt <method> <data>"; return 1; }
  log_section "Decrypt — $method"
  need_cmd openssl || return 1
  local result
  result=$(echo "$data" | openssl enc "-$method" -d -base64 -pbkdf2 -pass pass:tx-pass 2>/dev/null)
  echo -e "  ${BOLD}Decrypted:${RESET} $result"
}

crypto_encode() {
  local type="${1:-base64}" data="${2:-}"
  [[ -z "$data" ]] && { log_error "Usage: tx crypto encode <type> <data>"; return 1; }
  case "$type" in
    base64) crypto_base64 "$data";;
    base32) crypto_base32 "$data";;
    hex)    crypto_hex "$data";;
    url)    echo -n "$data" | python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read()))" 2>/dev/null;;
    *)      log_error "Unknown encoding: $type";;
  esac
}

crypto_decode() {
  local type="${1:-base64}" data="${2:-}"
  [[ -z "$data" ]] && { log_error "Usage: tx crypto decode <type> <data>"; return 1; }
  case "$type" in
    base64) echo -n "$data" | base64 -d 2>/dev/null || echo -n "$data" | python3 -c "import sys,base64; print(base64.b64decode(sys.stdin.read()).decode())" 2>/dev/null;;
    base32) echo -n "$data" | base32 -d 2>/dev/null;;
    hex)    echo -n "$data" | xxd -r -p 2>/dev/null || python3 -c "import sys; print(bytes.fromhex(sys.stdin.read().strip()).decode())" 2>/dev/null;;
    url)    echo -n "$data" | python3 -c "import sys,urllib.parse; print(urllib.parse.unquote(sys.stdin.read()))" 2>/dev/null;;
    *)      log_error "Unknown decoding: $type";;
  esac
}

crypto_base64() {
  local data="${1:-}"
  [[ -z "$data" ]] && read -r data
  echo -n "$data" | base64 2>/dev/null || echo -n "$data" | python3 -c "import sys,base64; print(base64.b64encode(sys.stdin.buffer.read()).decode())" 2>/dev/null
}

crypto_base32() {
  local data="${1:-}"
  [[ -z "$data" ]] && read -r data
  echo -n "$data" | base32 2>/dev/null
}

crypto_hex() {
  local data="${1:-}"
  [[ -z "$data" ]] && read -r data
  echo -n "$data" | xxd -p 2>/dev/null || echo -n "$data" | python3 -c "import sys; print(sys.stdin.buffer.read().hex())" 2>/dev/null
}

crypto_rot13() {
  local data="${1:-}"
  [[ -z "$data" ]] && read -r data
  echo "$data" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
}

crypto_xor() {
  local data="${1:-}" key="${2:-key}"
  [[ -z "$data" ]] && { log_error "Usage: tx crypto xor <data> <key>"; return 1; }
  python3 -c "
import sys
data = '$data'
key = '$key'
result = ''.join(chr(ord(c) ^ ord(key[i % len(key)])) for i, c in enumerate(data))
print(result)
" 2>/dev/null
}

crypto_genkey() {
  local bits="${1:-2048}"
  log_section "Key Generation — ${bits} bits"
  need_cmd openssl || return 1
  echo -e "\n${BOLD}RSA Private Key:${RESET}"
  openssl genrsa "$bits" 2>/dev/null | head -10
  echo "..."
  echo -e "\n${BOLD}RSA Public Key:${RESET}"
  openssl rsa -pubout 2>/dev/null <<< "$(openssl genrsa "$bits" 2>/dev/null)" | head -5
  echo "..."
}

crypto_ssl() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { log_error "Usage: tx crypto ssl <domain>"; return 1; }
  log_section "SSL Certificate — $domain"
  need_cmd openssl || return 1
  echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | openssl x509 -text -noout 2>/dev/null | head -40
}

crypto_gpg() {
  local file="${1:-}"
  local action="${2:-encrypt}"
  [[ -z "$file" ]] && { log_error "Usage: tx crypto gpg <file> <encrypt|decrypt>"; return 1; }
  log_section "GPG — $action $file"
  if [[ "$action" == "encrypt" ]]; then
    gpg -c "$file" 2>/dev/null && log_success "Encrypted: ${file}.gpg"
  else
    gpg -d "$file" 2>/dev/null
  fi
}

crypto_checksum() {
  local file="${1:-}"
  [[ -z "$file" ]] && { log_error "Usage: tx crypto checksum <file>"; return 1; }
  [[ ! -f "$file" ]] && { log_error "File not found: $file"; return 1; }
  log_section "Checksums — $file"
  for algo in md5 sha1 sha256 sha512; do
    if command -v "${algo}sum" &>/dev/null; then
      echo -e "  ${BOLD}${algo^^}:${RESET} $("${algo}sum" "$file" 2>/dev/null | awk '{print $1}')"
    fi
  done
}

crypto_cipher() {
  log_section "Available Ciphers"
  need_cmd openssl || return 1
  openssl enc -ciphers 2>/dev/null | column || openssl list -cipher-algorithms 2>/dev/null | head -20
}
