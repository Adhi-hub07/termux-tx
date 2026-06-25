#===============================================================================
#  termux — Termux API Bridge
#===============================================================================

cmd_termux() {
  module_banner "termux" "Termux API bridge"
  local sub="${1:-help}"; shift 2>/dev/null || true

  case "$sub" in
    toast)          termux_toast "$@";;
    notification)   termux_notif "$@";;
    tts)            termux_tts "$@";;
    battery)        termux_battery;;
    clipboard)      termux_clipboard "$@";;
    sensor)         termux_sensor "$@";;
    camera)         termux_camera "$@";;
    sms)            termux_sms "$@";;
    call)           termux_call "$@";;
    contact)        termux_contact;;
    location)       termux_location;;
    wifi)           termux_wifi;;
    torch)          termux_torch "$@";;
    vibrate)        termux_vibrate "$@";;
    speech)         termux_speech;;
    storage)        termux_storage;;
    micro)          termux_micro "$@";;
    media-scan)     termux_media;;
    --json)         TX_JSON=true; termux_battery;;
    -h|--help)
      echo "Usage: tx termux <subcommand> [args]"
      echo "  toast <msg>        Show toast notification"
      echo "  notification <msg> Show persistent notification"
      echo "  tts <text>         Text-to-speech"
      echo "  battery            Battery status"
      echo "  clipboard [text]   Clipboard get/set"
      echo "  sensor [type]      Sensor data"
      echo "  camera [id]        Take photo"
      echo "  sms                List recent SMS"
      echo "  call <number>      Make call"
      echo "  contact            List contacts"
      echo "  location           GPS location"
      echo "  wifi               WiFi info"
      echo "  torch [on|off]     Flashlight toggle"
      echo "  vibrate [ms]       Vibrate device"
      echo "  speech             Speech recognition"
      echo "  storage            Setup storage access"
      echo "  micro <file>       Record audio"
      echo "  media-scan         Scan media files"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

termux_toast() {
  local msg="${*:-Hello from TX!}"
  command -v termux-toast &>/dev/null && termux-toast "$msg" || log_warn "termux-api not installed"
}

termux_notif() {
  local title="${1:-TX}" msg="${2:-Notification from TX}"
  command -v termux-notification &>/dev/null && termux-notification --title "$title" --content "$msg" --priority high || log_warn "termux-api not installed"
}

termux_tts() {
  local text="${*:-Hello from TX}"
  command -v termux-tts-speak &>/dev/null && termux-tts-speak "$text" || log_warn "termux-api not installed"
}

termux_battery() {
  log_section "Battery"
  command -v termux-battery-status &>/dev/null && termux-battery-status 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  for k,v in d.items(): print(f'  {k}: {v}')
except: pass
" 2>/dev/null || log_warn "termux-api not installed"
}

termux_clipboard() {
  if [[ $# -gt 0 ]]; then
    command -v termux-clipboard-set &>/dev/null && echo "$*" | termux-clipboard-set && log_success "Copied to clipboard"
  else
    command -v termux-clipboard-get &>/dev/null && termux-clipboard-get || log_warn "termux-api not installed"
  fi
}

termux_sensor() {
  local type="${1:--list}"
  command -v termux-sensor &>/dev/null && termux-sensor -s "$type" 2>/dev/null || log_warn "termux-api not installed"
}

termux_camera() {
  local cam="${1:-0}"
  command -v termux-camera-photo &>/dev/null && termux-camera-photo "/sdcard/DCIM/tx-photo-$(date +%s).jpg" "$cam" && log_success "Photo taken" || log_warn "termux-api not installed"
}

termux_sms() {
  log_section "SMS"
  command -v termux-sms-list &>/dev/null && termux-sms-list 2>/dev/null | python3 -c "
import sys, json
try:
  msgs = json.load(sys.stdin)
  for m in msgs[:10]:
    print(f'  {m.get(\"number\",\"?\")}: {m.get(\"body\",\"?\")[:60]}')
except: pass
" 2>/dev/null || log_warn "termux-api not installed"
}

termux_call() {
  local number="${1:-}"
  [[ -z "$number" ]] && { log_error "Usage: tx termux call <number>"; return 1; }
  command -v termux-telephony-call &>/dev/null && termux-telephony-call "$number" || log_warn "termux-api not installed"
}

termux_contact() {
  log_section "Contacts"
  command -v termux-contact-list &>/dev/null && termux-contact-list 2>/dev/null | python3 -c "
import sys, json
try:
  contacts = json.load(sys.stdin)
  for c in contacts[:20]:
    print(f'  {c.get(\"name\",\"?\")} - {c.get(\"number\",\"?\")}')
except: pass
" 2>/dev/null || log_warn "termux-api not installed"
}

termux_location() {
  log_section "Location"
  command -v termux-location &>/dev/null && termux-location 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(f'  Lat: {d.get(\"latitude\",\"?\")}')
  print(f'  Lon: {d.get(\"longitude\",\"?\")}')
  print(f'  Acc: {d.get(\"accuracy\",\"?\")}m')
  print(f'  Alt: {d.get(\"altitude\",\"?\")}m')
except: pass" || log_warn "termux-api not installed"
}

termux_wifi() {
  log_section "WiFi"
  command -v termux-wifi-connectioninfo &>/dev/null && {
    echo -e "\n${BOLD}Current Connection:${RESET}"
    termux-wifi-connectioninfo 2>/dev/null | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  for k in ['ssid','bssid','frequency','rssi','ip']:
    if d.get(k): print(f'  {k}: {d[k]}')
except: pass"
    echo -e "\n${BOLD}Available Networks:${RESET}"
    termux-wifi-scaninfo 2>/dev/null | python3 -c "
import sys, json
try:
  nets = json.load(sys.stdin)
  for n in sorted(nets, key=lambda x: -x.get('level', -100))[:10]:
    print(f'  {n[\"ssid\"]:25s} {n[\"bssid\"]}  {n.get(\"level\",0):>4}dBm')
except: pass" 2>/dev/null
  } || log_warn "termux-api not installed"
}

termux_torch() {
  local state="${1:-on}"
  command -v termux-torch &>/dev/null && termux-torch "$state" && log_success "Torch $state" || log_warn "termux-api not installed"
}

termux_vibrate() {
  local ms="${1:-500}"
  command -v termux-vibrate &>/dev/null && termux-vibrate -d "$ms" || log_warn "termux-api not installed"
}

termux_speech() {
  log_section "Speech Recognition"
  command -v termux-speech-rec &>/dev/null && echo "Listening..." && termux-speech-rec 2>/dev/null | python3 -c "
import sys, json; d=json.load(sys.stdin)
if d: print(f'  You said: {d}')
" 2>/dev/null || log_warn "termux-api not installed"
}

termux_storage() {
  command -v termux-setup-storage &>/dev/null && termux-setup-storage && log_success "Storage access granted" || log_warn "termux-api not installed"
}

termux_micro() {
  local file="${1:-/sdcard/Music/tx-record-$(date +%s).mp3}"
  command -v termux-microphone-record &>/dev/null && termux-microphone-record -f "$file" || termux-microphone-record -d || log_warn "termux-api not installed"
}

termux_media() {
  command -v termux-media-scan &>/dev/null && termux-media-scan /sdcard/DCIM/ && termux-media-scan /sdcard/Music/ && log_success "Media scanned" || log_warn "termux-api not installed"
}
