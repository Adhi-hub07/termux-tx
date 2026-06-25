#===============================================================================
#  auto — Automation & Scheduled Tasks
#===============================================================================

cmd_auto() {
  module_banner "auto" "Automation & scheduled tasks"
  local sub="${1:-help}"; shift 2>/dev/null || true

  case "$sub" in
    list)          auto_list;;
    add)           auto_add "$@";;
    remove|rm)     auto_remove "$@";;
    run)           auto_run "$@";;
    watch)         auto_watch "$@";;
    monitor)       auto_monitor "$@";;
    cleanup)       auto_cleanup "$@";;
    --json)        TX_JSON=true; auto_list;;
    -h|--help)
      echo "Usage: tx auto <subcommand> [args]"
      echo "  list               List scheduled tasks"
      echo "  add <name> <cmd>   Add scheduled task"
      echo "  remove <name>      Remove task"
      echo "  run <name>         Run task now"
      echo "  watch <cmd>        Watch command every N seconds"
      echo "  monitor            Monitor system resources"
      echo "  cleanup            Auto-cleanup task"
      echo ""
      echo "  Tasks are stored in ~/.tx/tasks/"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

auto_list() {
  log_section "Scheduled Tasks"
  local task_dir="$HOME/.tx/tasks"
  mkdir -p "$task_dir"
  if [[ -z "$(ls -A "$task_dir" 2>/dev/null)" ]]; then
    echo "  No tasks. Use 'tx auto add <name> <cmd>' to create one."
    return 0
  fi
  for task in "$task_dir"/*; do
    local name interval cmd
    name=$(basename "$task")
    interval=$(grep "^# interval:" "$task" 2>/dev/null | cut -d: -f2- | xargs)
    cmd=$(grep "^# cmd:" "$task" 2>/dev/null | cut -d: -f2- | xargs)
    echo -e "  ${GREEN}$name${RESET}"
    [[ -n "$interval" ]] && echo -e "    Interval: $interval"
    [[ -n "$cmd" ]] && echo -e "    Command: $cmd"
    echo -e "    File: $task"
    echo ""
  done
}

auto_add() {
  local name="${1:-}" cmd="${2:-}"
  [[ -z "$name" ]] || [[ -z "$cmd" ]] && { log_error "Usage: tx auto add <name> <command>"; return 1; }
  local task_dir="$HOME/.tx/tasks"
  mkdir -p "$task_dir"
  local task_file="$task_dir/$name"
  cat > "$task_file" << EOF
#!/usr/bin/env bash
# name: $name
# cmd: $cmd
# interval: manual

$cmd
EOF
  chmod +x "$task_file"
  log_success "Task created: $name"
}

auto_remove() {
  local name="${1:-}"
  [[ -z "$name" ]] && { log_error "Usage: tx auto remove <name>"; return 1; }
  rm -f "$HOME/.tx/tasks/$name" && log_success "Task removed: $name" || log_error "Task not found: $name"
}

auto_run() {
  local name="${1:-}"
  [[ -z "$name" ]] && { log_error "Usage: tx auto run <name>"; return 1; }
  local task="$HOME/.tx/tasks/$name"
  [[ ! -f "$task" ]] && { log_error "Task not found: $name"; return 1; }
  log_section "Running Task — $name"
  bash "$task" 2>&1
}

auto_watch() {
  local cmd="${*:-}"
  [[ -z "$cmd" ]] && { log_error "Usage: tx auto watch <command>"; return 1; }
  log_section "Watching: $cmd"
  while true; do
    clear 2>/dev/null || true
    echo -e "${CYAN}[$(date '+%H:%M:%S')]${RESET} Running: $cmd"
    echo ""
    eval "$cmd"
    sleep 2
  done
}

auto_monitor() {
  log_section "System Monitor (Ctrl+C to stop)"
  while true; do
    clear 2>/dev/null || true
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}  TX System Monitor — $(date '+%H:%M:%S')              ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""
    # CPU
    echo -e "${BOLD}CPU:${RESET}"
    local cpu
    cpu=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' || echo "N/A")
    echo -e "  Usage: ${cpu}%"
    # RAM
    echo -e "${BOLD}Memory:${RESET}"
    free -h 2>/dev/null | grep Mem | awk '{printf "  Used: %s / %s\n", $3, $2}'
    # Processes
    echo -e "${BOLD}Top Processes:${RESET}"
    ps aux 2>/dev/null | sort -k3 -rn | head -5 | awk '{printf "  %-6s %-5s %s\n", $2, $3"%", $11}'
    # Uptime
    echo -e "${BOLD}Uptime:${RESET}"
    uptime 2>/dev/null | sed 's/^/  /'
    sleep 3
  done
}

auto_cleanup() {
  log_section "Auto Cleanup"
  local freed=0
  # Temp files > 7 days
  local before after
  before=$(du -sb /tmp 2>/dev/null | awk '{print $1}')
  find /tmp -type f -atime +7 -delete 2>/dev/null || true
  find /tmp -type f -size +100M -delete 2>/dev/null || true
  after=$(du -sb /tmp 2>/dev/null | awk '{print $1}')
  freed=$(( freed + before - after ))
  # TX logs older than 7 days
  find "$HOME/.tx/logs" -name "*.log" -mtime +7 -delete 2>/dev/null || true
  # TX cache
  rm -rf "$HOME/.tx/cache"/* 2>/dev/null || true
  log_success "Freed $(( freed / 1048576 )) MB"
}
