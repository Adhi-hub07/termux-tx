#===============================================================================
#  Core Utility Functions
#===============================================================================

# ── Logging ──────────────────────────────────────────────────────────────────
log_info()    { echo -e "${CYAN}[*]${RESET} $*"; }
log_success() { echo -e "${GREEN}[+]${RESET} $*"; }
log_warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
log_error()   { echo -e "${RED}[-]${RESET} $*" >&2; }
log_debug()   { [[ "${TX_VERBOSE:-false}" == "true" ]] && echo -e "${DIM}[debug]${RESET} $*"; return 0; }
log_banner()  { echo -e "${CYAN}═══════════════════════════════════════════════════════════════${RESET}"; echo -e "${BOLD}${CYAN}  ▸ $*${RESET}"; echo -e "${CYAN}───────────────────────────────────────────────────────────────────${RESET}"; }
log_section() { echo ""; echo -e "${BOLD}${BLUE}┌─ $*${RESET}"; echo -e "${BLUE}├${RESET}${DIM}──────────────────────────────────────────────────────────────${RESET}"; }

# ── Spinner ──────────────────────────────────────────────────────────────────
spinner() {
  local msg="$1" cmd="$2" pid
  local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

  echo -ne "${CYAN}${spin[0]}${RESET} ${msg}... "
  eval "$cmd" &>/dev/null &
  pid=$!

  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    echo -ne "\r${CYAN}${spin[i]}${RESET} ${msg}... "
    i=$(( (i+1) % 10 ))
    sleep 0.1
  done
  wait "$pid"
  local rc=$?

  if [[ $rc -eq 0 ]]; then
    echo -e "\r${GREEN}✓${RESET} ${msg}... ${GREEN}done${RESET}"
  else
    echo -e "\r${RED}✗${RESET} ${msg}... ${RED}failed${RESET}"
  fi
  return $rc
}

# ── Progress bar ─────────────────────────────────────────────────────────────
progress_bar() {
  local current="$1" total="$2" width="${3:-40}"
  local pct=$(( current * 100 / total ))
  local filled=$(( current * width / total ))
  local empty=$(( width - filled ))

  printf "\r${CYAN}[${RESET}"
  printf "${GREEN}%${filled}s${RESET}" "" | tr ' ' '█'
  printf "${DIM}%${empty}s${RESET}" "" | tr ' ' '░'
  printf "${CYAN}]${RESET} %3d%%" "$pct"
  [[ $current -eq $total ]] && echo
}

# ── Confirm prompt ───────────────────────────────────────────────────────────
confirm() {
  local prompt="${1:-Continue?}"
  local default="${2:-n}"
  local yn

  if [[ "${TX_FORCE:-false}" == "true" ]]; then
    return 0
  fi

  local hint
  [[ "$default" == "y" ]] && hint="Y/n" || hint="y/N"

  echo -ne "${YELLOW}[?]${RESET} ${prompt} (${hint}) "
  read -r yn
  yn="${yn:-$default}"

  [[ "$yn" == "y" ]] || [[ "$yn" == "Y" ]] || [[ "$yn" == "yes" ]]
}

# ── Check dependencies ──────────────────────────────────────────────────────
need_cmd() {
  local cmd="$1" pkg="${2:-$1}"
  if ! command -v "$cmd" &>/dev/null; then
    log_warn "Missing: $cmd"
    log_info "Install: ${BOLD}${pkg}${RESET}"
    if confirm "Install $pkg now?" "y"; then
      if $IS_TERMUX; then
        pkg install -y "$pkg" 2>/dev/null
      else
        if command -v apt &>/dev/null; then
          sudo apt install -y "$pkg" 2>/dev/null
        elif command -v pacman &>/dev/null; then
          sudo pacman -S --noconfirm "$pkg" 2>/dev/null
        elif command -v dnf &>/dev/null; then
          sudo dnf install -y "$pkg" 2>/dev/null
        fi
      fi
      return $?
    fi
    return 1
  fi
  return 0
}

need_cmds() {
  local fail=0
  for dep in "$@"; do
    need_cmd "$dep" || fail=1
  done
  return $fail
}

# ── Root check ──────────────────────────────────────────────────────────────
is_root() { [[ $EUID -eq 0 ]]; }
need_root() {
  if ! is_root; then
    log_error "Root required for this operation"
    return 1
  fi
}

# ── Run & log ───────────────────────────────────────────────────────────────
run_silent() {
  local logfile="$LOG_DIR/$(date +%Y%m%d-%H%M%S)-${TX_CMD:-unknown}.log"
  "$@" > "$logfile" 2>&1
  local rc=$?
  if [[ $rc -ne 0 ]]; then
    log_error "Command failed (exit $rc). Log: $logfile"
    if confirm "Show log?" "n"; then
      cat "$logfile"
    fi
  fi
  return $rc
}

cmd_exists() { command -v "$1" &>/dev/null; }

# ── Check Internet ──────────────────────────────────────────────────────────
check_net() {
  if cmd_exists curl; then
    curl -s --connect-timeout 3 https://google.com >/dev/null 2>&1 && return 0
  fi
  if cmd_exists wget; then
    wget -q --timeout=3 https://google.com -O /dev/null 2>&1 && return 0
  fi
  if cmd_exists ping; then
    ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1 && return 0
  fi
  return 1
}

# ── JSON output ──────────────────────────────────────────────────────────────
json_out() {
  if [[ "${TX_JSON:-false}" == "true" ]]; then
    echo "$1"
    exit 0
  fi
}
