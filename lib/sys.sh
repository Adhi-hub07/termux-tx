#===============================================================================
#  sys — System Information
#===============================================================================

cmd_sys() {
  module_banner "sys" "System information & device details"
  local sub="${1:-all}"

  case "$sub" in
    info|all)  sys_all;;
    cpu)       sys_cpu;;
    ram|mem)   sys_ram;;
    disk)      sys_disk;;
    battery)   sys_battery;;
    kernel)    sys_kernel;;
    network)   sys_network;;
    packages)  sys_packages;;
    sensors)   sys_sensors;;
    users)     sys_users;;
    uptime)    sys_uptime;;
    temp)      sys_temp;;
    --json)    TX_JSON=true; sys_all;;
    -h|--help)
      echo "Usage: tx sys [subcommand]"
      echo "  all       Show everything (default)"
      echo "  cpu       CPU details"
      echo "  ram       Memory usage"
      echo "  disk      Disk usage"
      echo "  battery   Battery info"
      echo "  kernel    Kernel version"
      echo "  network   Network interfaces"
      echo "  packages  Installed packages count"
      echo "  sensors   Sensor data"
      echo "  users     Logged in users"
      echo "  uptime    System uptime"
      echo "  temp      Temperature"
      ;;
    *) log_error "Unknown subcommand: $sub"; exit 1;;
  esac
}

sys_all() {
  [[ "$IS_TERMUX" == true ]] && sys_termux_device
  sys_kernel
  sys_cpu
  sys_ram
  sys_disk
  sys_uptime
  sys_battery
  sys_temp
  sys_network
  [[ "$IS_TERMUX" == true ]] && sys_sensors
  sys_packages
  sys_users
}

sys_kernel() {
  log_section "Kernel & OS"
  echo -e "  OS        : ${BOLD}$(uname -o 2>/dev/null || echo 'N/A')${RESET}"
  echo -e "  Kernel    : ${BOLD}$(uname -r)${RESET}"
  echo -e "  Arch      : ${BOLD}$(uname -m)${RESET}"
  echo -e "  Hostname  : ${BOLD}$(uname -n)${RESET}"
  if $IS_TERMUX; then
    echo -e "  Termux    : ${BOLD}${TERMUX_VERSION:-N/A}${RESET}"
  fi
}

sys_termux_device() {
  log_section "Device"
  local device manu model android
  device=$(getprop ro.product.device 2>/dev/null || echo "N/A")
  manu=$(getprop ro.product.manufacturer 2>/dev/null || echo "N/A")
  model=$(getprop ro.product.model 2>/dev/null || echo "N/A")
  android=$(getprop ro.build.version.release 2>/dev/null || echo "N/A")
  echo -e "  Device    : ${BOLD}$device${RESET}"
  echo -e "  Model     : ${BOLD}$manu $model${RESET}"
  echo -e "  Android   : ${BOLD}$android${RESET}"
}

sys_cpu() {
  log_section "CPU"
  if [[ -f /proc/cpuinfo ]]; then
    local cores model
    cores=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "N/A")
    model=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ *//' || echo "N/A")
    echo -e "  Model     : ${BOLD}$model${RESET}"
    echo -e "  Cores     : ${BOLD}$cores${RESET}"
    local freq
    freq=$(awk '{sum+=$1; count++} END {if(count>0) printf "%.0f", sum/count/1000}' /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null)
    [[ -n "$freq" ]] && echo -e "  Freq      : ${BOLD}${freq} MHz${RESET}"
  else
    echo -e "  ${DIM}CPU info not available${RESET}"
  fi
}

sys_ram() {
  log_section "Memory"
  if [[ -f /proc/meminfo ]]; then
    local total avail used pct
    total=$(awk '/^MemTotal:/{printf "%.0f", $2/1024}' /proc/meminfo)
    avail=$(awk '/^MemAvailable:/{printf "%.0f", $2/1024}' /proc/meminfo)
    used=$(( total - avail ))
    pct=$(( used * 100 / total ))
    echo -e "  Total     : ${BOLD}${total} MB${RESET}"
    echo -e "  Used      : ${YELLOW}${used} MB${RESET}"
    echo -e "  Available : ${GREEN}${avail} MB${RESET}"
    progress_bar "$used" "$total" 30
    echo ""
    local swap_total swap_used
    swap_total=$(awk '/^SwapTotal:/{printf "%.0f", $2/1024}' /proc/meminfo)
    swap_used=$(awk '/^SwapUsed:/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)
    [[ $swap_total -gt 0 ]] && echo -e "  Swap      : ${BOLD}${swap_used}${RESET} / ${swap_total} MB"
  else
    echo -e "  ${DIM}Memory info not available${RESET}"
  fi
}

sys_disk() {
  log_section "Storage"
  if command -v df &>/dev/null; then
    df -h 2>/dev/null | grep -v "tmpfs\|devtmpfs\|overlay" | while IFS= read -r line; do
      echo -e "  $line"
    done
  fi
}

sys_uptime() {
  log_section "Uptime"
  if [[ -f /proc/uptime ]]; then
    local sec days hrs mins
    sec=$(awk '{printf "%.0f", $1}' /proc/uptime)
    days=$(( sec / 86400 ))
    hrs=$(( (sec % 86400) / 3600 ))
    mins=$(( (sec % 3600) / 60 ))
    echo -e "  ${BOLD}${days}d ${hrs}h ${mins}m${RESET}"
  fi
}

sys_battery() {
  log_section "Battery"
  local bat_path="/sys/class/power_supply"
  if [[ -d "$bat_path" ]]; then
    for bat in "$bat_path"/BAT* "$bat_path"/battery; do
      [[ ! -d "$bat" ]] && continue
      local cap status
      cap=$(cat "$bat/capacity" 2>/dev/null || echo "N/A")
      status=$(cat "$bat/status" 2>/dev/null || echo "N/A")
      echo -e "  Capacity  : ${BOLD}${cap}%${RESET}"
      echo -e "  Status    : ${BOLD}$status${RESET}"
      progress_bar "$cap" 100 30
      echo ""
    done
    # Try Android method
    if $IS_TERMUX && command -v termux-battery-status &>/dev/null; then
      termux-battery-status 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(f'  Android: {d.get(\"percentage\",\"?\")}% ({d.get(\"status\",\"?\")})')
except: pass" 2>/dev/null || true
    fi
  else
    # Android fallback
    if $IS_TERMUX && command -v termux-battery-status &>/dev/null; then
      termux-battery-status 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(f'  Level     : {d.get(\"percentage\",\"?\")}%')
  print(f'  Status    : {d.get(\"status\",\"?\")}')
  print(f'  Temp      : {d.get(\"temperature\",\"?\")}°C')
except: pass" 2>/dev/null || echo -e "  ${DIM}No battery info${RESET}"
    else
      echo -e "  ${DIM}No battery info${RESET}"
    fi
  fi
}

sys_temp() {
  log_section "Temperature"
  local found=false
  for f in /sys/class/thermal/thermal_zone*/temp; do
    [[ ! -f "$f" ]] && continue
    local temp name
    temp=$(cat "$f" 2>/dev/null)
    name=$(cat "${f%/temp}/type" 2>/dev/null || echo "unknown")
    temp=$(( temp / 1000 ))
    local color="$GREEN"
    [[ $temp -gt 60 ]] && color="$YELLOW"
    [[ $temp -gt 80 ]] && color="$RED"
    echo -e "  ${name}: ${color}${temp}°C${RESET}"
    found=true
  done
  $found || echo -e "  ${DIM}No thermal info${RESET}"
}

sys_network() {
  log_section "Network"
  for iface in /sys/class/net/*; do
    [[ ! -d "$iface" ]] && continue
    local name ip mac
    name=$(basename "$iface")
    ip=$(ip -4 addr show "$name" 2>/dev/null | awk '/inet /{print $2}' | head -1)
    mac=$(cat "$iface/address" 2>/dev/null || echo "N/A")
    local state
    state=$(cat "$iface/operstate" 2>/dev/null || "unknown")
    local color="$DIM"
    [[ "$state" == "up" ]] && color="$GREEN"
    echo -e "  ${color}${name}${RESET}: ip=${BOLD}${ip:-N/A}${RESET} mac=${DIM}${mac}${RESET} [${color}${state}${RESET}]"
  done
}

sys_sensors() {
  log_section "Sensors"
  if command -v termux-sensor &>/dev/null; then
    termux-sensor -s 2>/dev/null | head -30 || echo -e "  ${DIM}No sensors${RESET}"
  else
    echo -e "  ${DIM}Install termux-api for sensors${RESET}"
  fi
}

sys_packages() {
  log_section "Packages"
  local count=0
  if $IS_TERMUX && command -v dpkg &>/dev/null; then
    count=$(dpkg --list 2>/dev/null | grep -c '^ii' || echo 0)
    echo -e "  Termux    : ${BOLD}$count${RESET} packages"
  fi
  if command -v dpkg &>/dev/null && ! $IS_TERMUX; then
    count=$(dpkg --list 2>/dev/null | grep -c '^ii' || echo 0)
    echo -e "  dpkg      : ${BOLD}$count${RESET}"
  fi
  if command -v pacman &>/dev/null; then
    count=$(pacman -Q 2>/dev/null | wc -l || echo 0)
    echo -e "  pacman    : ${BOLD}$count${RESET}"
  fi
}

sys_users() {
  log_section "Users"
  who 2>/dev/null | while IFS= read -r line; do
    echo -e "  $line"
  done
  [[ -z "$(who 2>/dev/null)" ]] && echo -e "  ${DIM}No other users logged in${RESET}"
  echo -e "  UID       : ${BOLD}$(id -u)${RESET}"
  echo -e "  User      : ${BOLD}$(whoami)${RESET}"
  echo -e "  Groups    : ${BOLD}$(id -Gn 2>/dev/null | tr ' ' ',')${RESET}"
}
