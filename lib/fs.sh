#===============================================================================
#  fs — File System Tools
#===============================================================================

cmd_fs() {
  module_banner "fs" "File system & disk tools"
  local sub="${1:-usage}"; shift 2>/dev/null || true

  case "$sub" in
    usage|df)      fs_usage;;
    du)            fs_du "$@";;
    largest)       fs_largest;;
    tree)          fs_tree "$@";;
    count)         fs_count "$@";;
    find)          fs_find "$@";;
    search)        fs_search "$@";;
    perm|perms)    fs_perms "$@";;
    link|symlink)  fs_symlink "$@";;
    mount)         fs_mount;;
    trash)         fs_trash "$@";;
    clean)         fs_clean;;
    split)         fs_split "$@";;
    merge)         fs_merge "$@";;
    checksum)      fs_checksum "$@";;
    --json)        TX_JSON=true; fs_usage;;
    -h|--help)
      echo "Usage: tx fs <subcommand> [args]"
      echo "  usage|df          Disk usage overview"
      echo "  du <path>         Directory size"
      echo "  largest [n]       Show largest files/folders"
      echo "  tree [path]       Directory tree"
      echo "  count [path]      File/folder counts"
      echo "  find <pattern>    Find files"
      echo "  search <pattern>  Search file contents"
      echo "  perms <path>      File permissions audit"
      echo "  link <target>     Find symlinks"
      echo "  mount             Mounted filesystems"
      echo "  trash [file]      Move to trash"
      echo "  clean             Clean temp/cache"
      echo "  split <file>      Split large file"
      echo "  merge <file>      Merge split parts"
      echo "  checksum <file>   Compute hashes"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

fs_usage() {
  log_section "Disk Usage"
  df -h 2>/dev/null | grep -v "tmpfs\|devtmpfs\|overlay" || df -h 2>/dev/null
}

fs_du() {
  local path="${1:-.}"
  log_section "Directory Size — $path"
  du -sh "$path" 2>/dev/null
}

fs_largest() {
  local n="${1:-20}"
  log_section "Top $n Largest Files"
  if command -v ncdu &>/dev/null; then
    log_info "Launching ncdu..."
    ncdu 2>/dev/null && return 0
  fi
  find "${1:-$HOME}" -xdev -type f -size +1M 2>/dev/null | head -5 >/dev/null
  if command -v du &>/dev/null; then
    find "${1:-$HOME}" -xdev -type f -size +10M 2>/dev/null -exec du -Sh {} + 2>/dev/null | sort -rh | head -"$n" | awk '{printf "  %-10s %s\n", $1, $2}'
  fi
}

fs_tree() {
  local path="${1:-.}" depth="${2:-3}"
  if command -v tree &>/dev/null; then
    tree -L "$depth" -h "$path" 2>/dev/null
  else
    find "$path" -maxdepth "$depth" 2>/dev/null | while IFS= read -r f; do
      local indent=${f//[^\/]/}
      indent="${indent//\//  }"
      echo -e "  ${indent}$(basename "$f")"
    done
  fi
}

fs_count() {
  local path="${1:-.}"
  log_section "File Counts — $path"
  local dirs files links
  dirs=$(find "$path" -type d 2>/dev/null | wc -l)
  files=$(find "$path" -type f 2>/dev/null | wc -l)
  links=$(find "$path" -type l 2>/dev/null | wc -l)
  echo -e "  Directories : ${BOLD}$dirs${RESET}"
  echo -e "  Files       : ${BOLD}$files${RESET}"
  echo -e "  Symlinks    : ${BOLD}$links${RESET}"
  echo -e "  Total       : ${BOLD}$(( dirs + files + links ))${RESET}"
}

fs_find() {
  local pattern="${1:-}"
  local path="${2:-.}"
  [[ -z "$pattern" ]] && { log_error "Usage: tx fs find <pattern> [path]"; return 1; }
  log_section "Finding: $pattern"
  find "$path" -name "*$pattern*" 2>/dev/null | head -50
}

fs_search() {
  local pattern="${1:-}"
  local path="${2:-.}"
  [[ -z "$pattern" ]] && { log_error "Usage: tx fs search <pattern> [path]"; return 1; }
  log_section "Searching contents for: $pattern"
  grep -r --color=always -l "$pattern" "$path" 2>/dev/null | head -30
}

fs_perms() {
  local path="${1:-.}"
  log_section "Permission Audit — $path"
  log_info "SUID files:"
  find "$path" -type f -perm -4000 2>/dev/null | head -10 | sed 's/^/  /'
  log_info "SGID files:"
  find "$path" -type f -perm -2000 2>/dev/null | head -10 | sed 's/^/  /'
  log_info "World-writable:"
  find "$path" -perm -o+w 2>/dev/null | head -10 | sed 's/^/  /'
  log_info "No owner:"
  find "$path" -nouser -o -nogroup 2>/dev/null | head -10 | sed 's/^/  /'
}

fs_symlink() {
  local path="${1:-.}"
  log_section "Symlinks — $path"
  find "$path" -type l -xtype l 2>/dev/null | head -20 | while IFS= read -r link; do
    local target
    target=$(readlink "$link" 2>/dev/null)
    echo -e "  ${RED}BROKEN${RESET} $link -> $target"
  done
  echo ""
  find "$path" -type l -xtype f 2>/dev/null | head -20 | while IFS= read -r link; do
    local target
    target=$(readlink "$link" 2>/dev/null)
    echo -e "  ${GREEN}OK${RESET} $link -> $target"
  done
}

fs_mount() {
  log_section "Mounted Filesystems"
  mount -l 2>/dev/null | column -t || mount 2>/dev/null
}

fs_trash() {
  local file="${1:-}"
  [[ -z "$file" ]] && { log_error "Usage: tx fs trash <file>"; return 1; }
  local trash="$HOME/.trash"
  mkdir -p "$trash"
  local dest="$trash/$(basename "$file")-$(date +%Y%m%d%H%M%S)"
  mv "$file" "$dest" && log_success "Moved to trash: $dest" || log_error "Failed to trash $file"
}

fs_clean() {
  log_section "Cleanup"
  local freed=0
  # Temp files
  if [[ -d /tmp ]]; then
    local before
    before=$(du -sb /tmp 2>/dev/null | awk '{print $1}')
    find /tmp -type f -atime +7 -delete 2>/dev/null || true
    local after
    after=$(du -sb /tmp 2>/dev/null | awk '{print $1}')
    freed=$(( freed + (before - after) ))
  fi
  # Trash
  local trash="$HOME/.trash"
  if [[ -d "$trash" ]]; then
    local tsize
    tsize=$(du -sb "$trash" 2>/dev/null | awk '{print $1}')
    if confirm "Empty trash ($(( tsize / 1048576 )) MB)?" "n"; then
      rm -rf "$trash"/*
      freed=$(( freed + tsize ))
    fi
  fi
  # Cache
  if [[ -d "$HOME/.cache" ]]; then
    local csize
    csize=$(du -sb "$HOME/.cache" 2>/dev/null | awk '{print $1}')
    if confirm "Clean cache ($(( csize / 1048576 )) MB)?" "n"; then
      rm -rf "$HOME/.cache"/*
      freed=$(( freed + csize ))
    fi
  fi
  log_success "Freed $(( freed / 1048576 )) MB"
}

fs_split() {
  local file="${1:-}" size="${2:-100m}"
  [[ -z "$file" ]] && { log_error "Usage: tx fs split <file> [size]"; return 1; }
  log_section "Splitting: $file"
  split -b "$size" "$file" "${file}.part." && log_success "Split into ${file}.part.*"
}

fs_merge() {
  local base="${1:-}"
  [[ -z "$base" ]] && { log_error "Usage: tx fs merge <basefile>"; return 1; }
  log_section "Merging: ${base}.part.*"
  cat "${base}.part".* > "$base" && log_success "Merged to $base"
}

fs_checksum() {
  local file="${1:-}"
  [[ -z "$file" ]] && { log_error "Usage: tx fs checksum <file>"; return 1; }
  [[ ! -f "$file" ]] && { log_error "File not found: $file"; return 1; }
  log_section "Checksums — $file"
  for algo in md5 sha1 sha256 sha512; do
    if command -v "${algo}sum" &>/dev/null; then
      local hash
      hash=$("${algo}sum" "$file" 2>/dev/null | awk '{print $1}')
      echo -e "  ${BOLD}$(echo "$algo" | tr '[:lower:]' '[:upper:]'):${RESET} $hash"
    fi
  done
}
