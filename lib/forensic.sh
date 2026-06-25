#===============================================================================
#  forensic — Forensic Analysis
#===============================================================================

cmd_forensic() {
  module_banner "forensic" "Forensic analysis helpers"
  local sub="${1:-help}"; shift 2>/dev/null || true

  case "$sub" in
    timeline)      forensic_timeline "$@";;
    recover)       forensic_recover "$@";;
    metadata)      forensic_metadata "$@";;
    strings)       forensic_strings "$@";;
    hex|hexdump)   forensic_hex "$@";;
    filetype)      forensic_filetype "$@";;
    binwalk)       forensic_binwalk "$@";;
    volatility)    forensic_volatility "$@";;
    --json)        TX_JSON=true; forensic_metadata;;
    -h|--help)
      echo "Usage: tx forensic <subcommand> [file]"
      echo "  timeline <dir>    Build file timeline"
      echo "  recover <dev>     Recover deleted files"
      echo "  metadata <file>   Extract file metadata"
      echo "  strings <file>    Extract strings"
      echo "  hex <file>        Hex dump"
      echo "  filetype <file>   Detect file type"
      echo "  binwalk <file>    Analyze firmware"
      echo "  volatility <file> Memory analysis"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

forensic_timeline() {
  local dir="${1:-.}"
  log_section "File Timeline — $dir"
  find "$dir" -type f -printf '%TY-%Tm-%Td %TH:%TM:%TS %s %p\n' 2>/dev/null | sort -r | head -50
}

forensic_recover() {
  local dev="${1:-}"
  [[ -z "$dev" ]] && { log_error "Usage: tx forensic recover <device>"; return 1; }
  log_section "Recover — $dev"
  need_root || return 1
  need_cmd foremost || {
    log_info "Installing foremost..."
    if $IS_TERMUX; then pkg install -y foremost 2>/dev/null
    else sudo apt install -y foremost 2>/dev/null; fi
  }
  foremost -i "$dev" -o "$HOME/forensic-recovery" 2>/dev/null
}

forensic_metadata() {
  local file="${1:-}"
  [[ -z "$file" ]] && { log_error "Usage: tx forensic metadata <file>"; return 1; }
  [[ ! -f "$file" ]] && { log_error "File not found: $file"; return 1; }
  log_section "Metadata — $file"

  # File info
  file "$file" | sed 's/^/  File: /'
  stat "$file" | head -10 | sed 's/^/  /'

  # Exif
  if command -v exiftool &>/dev/null; then
    exiftool "$file" 2>/dev/null | head -30 | sed 's/^/  /'
  elif command -v exif &>/dev/null; then
    exif "$file" 2>/dev/null | sed 's/^/  /'
  fi

  # Media info
  if command -v mediainfo &>/dev/null; then
    mediainfo "$file" 2>/dev/null | head -20 | sed 's/^/  /'
  fi
}

forensic_strings() {
  local file="${1:-}"
  local min="${2:-6}"
  [[ -z "$file" ]] && { log_error "Usage: tx forensic strings <file> [min-len]"; return 1; }
  log_section "Strings — $file (min $min chars)"
  if command -v strings &>/dev/null; then
    strings -n "$min" "$file" 2>/dev/null | head -100
  fi
}

forensic_hex() {
  local file="${1:-}"
  [[ -z "$file" ]] && { log_error "Usage: tx forensic hex <file>"; return 1; }
  need_cmd xxd || return 1
  xxd "$file" 2>/dev/null | head -50
}

forensic_filetype() {
  local file="${1:-}"
  [[ -z "$file" ]] && { log_error "Usage: tx forensic filetype <file>"; return 1; }
  file "$file" 2>/dev/null
  xxd -l 64 "$file" 2>/dev/null | head -4
}

forensic_binwalk() {
  local file="${1:-}"
  [[ -z "$file" ]] && { log_error "Usage: tx forensic binwalk <file>"; return 1; }
  if command -v binwalk &>/dev/null; then
    binwalk "$file" 2>/dev/null
  else
    log_info "Installing binwalk..."
    if $IS_TERMUX; then pkg install -y binwalk 2>/dev/null
    else pip install binwalk 2>/dev/null; fi
  fi
}

forensic_volatility() {
  local file="${1:-}"
  [[ -z "$file" ]] && { log_error "Usage: tx forensic volatility <memory.dump>"; return 1; }
  if command -v vol &>/dev/null || command -v volatility &>/dev/null; then
    log_info "Running volatility..."
    (vol -f "$file" imageinfo 2>/dev/null || volatility -f "$file" imageinfo 2>/dev/null)
  else
    log_warn "Volatility not installed"
    log_info "Install: pip install volatility3"
  fi
}
