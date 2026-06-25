#===============================================================================
#  proc — Process Manager
#===============================================================================

cmd_proc() {
  module_banner "proc" "Process manager"
  local sub="${1:-list}"; shift 2>/dev/null || true

  case "$sub" in
    list|ps)       proc_list;;
    top|htop)      proc_top;;
    kill)          proc_kill "$@";;
    mem|memory)    proc_memory;;
    cpu)           proc_cpu_top;;
    tree)          proc_tree;;
    search)        proc_search "$@";;
    count)         proc_count;;
    io)            proc_io;;
    zombie)        proc_zombie;;
    service)       proc_service "$@";;
    --json)        TX_JSON=true; proc_list;;
    -h|--help)
      echo "Usage: tx proc <subcommand> [args]"
      echo "  list|ps         List processes"
      echo "  top             Interactive process viewer"
      echo "  kill <pid>      Kill process"
      echo "  mem|memory      Memory hogs"
      echo "  cpu             CPU hogs"
      echo "  tree            Process tree"
      echo "  search <q>      Search processes"
      echo "  count           Process count"
      echo "  io              I/O stats"
      echo "  zombie          Find zombie processes"
      echo "  service <name>  Service management"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

proc_list() {
  log_section "Processes"
  ps aux 2>/dev/null | head -30 || ps -ef 2>/dev/null | head -30
}

proc_top() {
  if command -v htop &>/dev/null; then
    htop 2>/dev/null
  elif command -v top &>/dev/null; then
    top 2>/dev/null
  fi
}

proc_kill() {
  local pid="${1:-}"
  local sig="${2:-TERM}"
  [[ -z "$pid" ]] && { log_error "Usage: tx proc kill <pid> [signal]"; return 1; }
  log_info "Sending $sig to PID $pid..."
  kill "-$sig" "$pid" 2>/dev/null && log_success "Killed $pid" || log_error "Failed to kill $pid"
}

proc_memory() {
  log_section "Memory Hogs"
  ps aux 2>/dev/null | sort -k4 -rn | head -10 | awk '{printf "  %-8s %-6s %-6s %-4s %s\n", $2, $3"%", $4"%", $6, $11}'
}

proc_cpu_top() {
  log_section "CPU Hogs"
  ps aux 2>/dev/null | sort -k3 -rn | head -10 | awk '{printf "  %-8s %-6s %-6s %s\n", $2, $3"%", $4"%", $11}'
}

proc_tree() {
  if command -v pstree &>/dev/null; then
    pstree 2>/dev/null
  else
    ps -ejH 2>/dev/null | head -40 || ps ax --forest 2>/dev/null | head -40
  fi
}

proc_search() {
  local q="${1:-}"
  [[ -z "$q" ]] && { log_error "Usage: tx proc search <query>"; return 1; }
  log_section "Searching: $q"
  ps aux 2>/dev/null | grep -i "$q" | grep -v grep
}

proc_count() {
  log_section "Process Count"
  local total running sleeping zombie
  total=$(ps aux 2>/dev/null | wc -l)
  running=$(ps aux 2>/dev/null | awk '{print $8}' | grep -c R || echo 0)
  sleeping=$(ps aux 2>/dev/null | awk '{print $8}' | grep -c S || echo 0)
  zombie=$(ps aux 2>/dev/null | awk '{print $8}' | grep -c Z || echo 0)
  echo -e "  Total     : ${BOLD}$total${RESET}"
  echo -e "  Running   : ${GREEN}$running${RESET}"
  echo -e "  Sleeping  : ${DIM}$sleeping${RESET}"
  echo -e "  Zombie    : ${RED}$zombie${RESET}"
}

proc_io() {
  log_section "I/O Stats"
  if command -v iotop &>/dev/null; then
    need_root && iotop -n 1 -b 2>/dev/null
  else
    cat /proc/diskstats 2>/dev/null | head -20 || log_warn "No I/O stats available"
  fi
}

proc_zombie() {
  log_section "Zombie Processes"
  local zombies
  zombies=$(ps aux 2>/dev/null | awk '{if($8=="Z") print $0}')
  if [[ -n "$zombies" ]]; then
    echo "$zombies"
  else
    log_success "No zombie processes"
  fi
}

proc_service() {
  local svc="${1:-list}" action="${2:-}"
  log_section "Service: $svc"
  if command -v systemctl &>/dev/null; then
    case "$svc" in
      list) systemctl list-units --type=service 2>/dev/null | head -30;;
      start|stop|restart|status)
        [[ -z "$action" ]] && { log_error "Usage: tx proc service <name> <start|stop|restart|status>"; return 1; }
        systemctl "$svc" "$action" 2>/dev/null;;
      *) log_error "Unknown service action";;
    esac
  elif command -v service &>/dev/null; then
    case "$svc" in
      list) service --status-all 2>/dev/null;;
      *) service "$svc" "${action:-status}" 2>/dev/null;;
    esac
  else
    log_warn "No service manager found"
  fi
}
