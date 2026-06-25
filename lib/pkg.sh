#===============================================================================
#  pkg — Package Manager
#===============================================================================

cmd_pkg() {
  module_banner "pkg" "Package manager wrapper"
  local sub="${1:-list}"; shift 2>/dev/null || true

  case "$sub" in
    update)      pkg_update;;
    upgrade)     pkg_upgrade;;
    install|add) pkg_install "$@";;
    remove|rm)   pkg_remove "$@";;
    search)      pkg_search "$@";;
    list)        pkg_list;;
    info)        pkg_info "$@";;
    clean)       pkg_clean;;
    deps)        pkg_deps "$@";;
    files)       pkg_files "$@";;
    --json)      TX_JSON=true; pkg_list;;
    -h|--help)
      echo "Usage: tx pkg <subcommand> [args]"
      echo "  update           Update package lists"
      echo "  upgrade          Upgrade all packages"
      echo "  install <pkg>    Install package(s)"
      echo "  remove <pkg>     Remove package(s)"
      echo "  search <q>       Search packages"
      echo "  list             List installed packages"
      echo "  info <pkg>       Package info"
      echo "  clean            Clean package cache"
      echo "  deps <pkg>       Show dependencies"
      echo "  files <pkg>      Files owned by package"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

pkg_update() {
  log_section "Updating package lists"
  if $IS_TERMUX; then
    pkg update 2>/dev/null || apt update 2>/dev/null
  elif command -v apt &>/dev/null; then
    sudo apt update 2>/dev/null
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sy 2>/dev/null
  elif command -v dnf &>/dev/null; then
    sudo dnf check-update 2>/dev/null
  fi
  log_success "Package lists updated"
}

pkg_upgrade() {
  log_section "Upgrading packages"
  confirm "Upgrade all packages?" "y" || return 0
  if $IS_TERMUX; then
    pkg upgrade -y 2>/dev/null || apt upgrade -y 2>/dev/null
  elif command -v apt &>/dev/null; then
    sudo apt upgrade -y 2>/dev/null
  elif command -v pacman &>/dev/null; then
    sudo pacman -Su --noconfirm 2>/dev/null
  elif command -v dnf &>/dev/null; then
    sudo dnf upgrade -y 2>/dev/null
  fi
  log_success "Upgrade complete"
}

pkg_install() {
  [[ $# -eq 0 ]] && { log_error "Usage: tx pkg install <package> [packages...]"; return 1; }
  log_section "Installing: $*"
  if $IS_TERMUX; then
    pkg install -y "$@" 2>/dev/null || apt install -y "$@" 2>/dev/null
  elif command -v apt &>/dev/null; then
    sudo apt install -y "$@" 2>/dev/null
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm "$@" 2>/dev/null
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$@" 2>/dev/null
  fi
  log_success "Installed: $*"
}

pkg_remove() {
  [[ $# -eq 0 ]] && { log_error "Usage: tx pkg remove <package> [packages...]"; return 1; }
  confirm "Remove $*?" || return 0
  if $IS_TERMUX; then
    pkg uninstall "$@" 2>/dev/null || apt remove -y "$@" 2>/dev/null
  elif command -v apt &>/dev/null; then
    sudo apt remove -y "$@" 2>/dev/null
  elif command -v pacman &>/dev/null; then
    sudo pacman -R --noconfirm "$@" 2>/dev/null
  elif command -v dnf &>/dev/null; then
    sudo dnf remove -y "$@" 2>/dev/null
  fi
  log_success "Removed: $*"
}

pkg_search() {
  local q="${1:-}"
  [[ -z "$q" ]] && { log_error "Usage: tx pkg search <query>"; return 1; }
  log_section "Searching: $q"
  if $IS_TERMUX; then
    pkg search "$q" 2>/dev/null || apt-cache search "$q" 2>/dev/null
  elif command -v apt-cache &>/dev/null; then
    apt-cache search "$q" 2>/dev/null
  elif command -v pacman &>/dev/null; then
    pacman -Ss "$q" 2>/dev/null
  elif command -v dnf &>/dev/null; then
    dnf search "$q" 2>/dev/null
  fi
}

pkg_list() {
  log_section "Installed Packages"
  if $IS_TERMUX; then
    dpkg --list 2>/dev/null | grep '^ii' | awk '{printf "  %-30s %s\n", $2, $3}' | head -50
    local total
    total=$(dpkg --list 2>/dev/null | grep -c '^ii' || echo 0)
    echo -e "\n  ${DIM}Total: $total packages${RESET}"
  elif command -v dpkg &>/dev/null; then
    dpkg --list 2>/dev/null | grep '^ii' | awk '{printf "  %-30s %s\n", $2, $3}' | head -50
    local total
    total=$(dpkg --list 2>/dev/null | grep -c '^ii' || echo 0)
    echo -e "\n  ${DIM}Total: $total packages${RESET}"
  elif command -v pacman &>/dev/null; then
    pacman -Q 2>/dev/null | head -50
  elif command -v rpm &>/dev/null; then
    rpm -qa 2>/dev/null | head -50
  fi
}

pkg_info() {
  local pkg="${1:-}"
  [[ -z "$pkg" ]] && { log_error "Usage: tx pkg info <package>"; return 1; }
  log_section "Package Info — $pkg"
  if $IS_TERMUX && command -v apt-cache &>/dev/null; then
    apt-cache show "$pkg" 2>/dev/null
  elif command -v apt-cache &>/dev/null; then
    apt-cache show "$pkg" 2>/dev/null
  elif command -v pacman &>/dev/null; then
    pacman -Qi "$pkg" 2>/dev/null || pacman -Si "$pkg" 2>/dev/null
  fi
}

pkg_clean() {
  log_section "Cleaning package cache"
  if $IS_TERMUX; then
    apt clean 2>/dev/null
    apt autoremove -y 2>/dev/null
  elif command -v apt &>/dev/null; then
    sudo apt clean 2>/dev/null
    sudo apt autoremove -y 2>/dev/null
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sc --noconfirm 2>/dev/null
  fi
  log_success "Cache cleaned"
}

pkg_deps() {
  local pkg="${1:-}"
  [[ -z "$pkg" ]] && { log_error "Usage: tx pkg deps <package>"; return 1; }
  log_section "Dependencies — $pkg"
  if command -v apt-cache &>/dev/null; then
    apt-cache depends "$pkg" 2>/dev/null
  elif command -v pactree &>/dev/null; then
    pactree "$pkg" 2>/dev/null
  fi
}

pkg_files() {
  local pkg="${1:-}"
  [[ -z "$pkg" ]] && { log_error "Usage: tx pkg files <package>"; return 1; }
  log_section "Files — $pkg"
  if $IS_TERMUX; then
    dpkg -L "$pkg" 2>/dev/null
  elif command -v dpkg &>/dev/null; then
    dpkg -L "$pkg" 2>/dev/null
  elif command -v pacman &>/dev/null; then
    pacman -Ql "$pkg" 2>/dev/null
  fi
}
