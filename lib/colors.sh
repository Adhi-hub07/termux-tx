#===============================================================================
#  Colors & Styling
#===============================================================================

if [[ "${TX_NO_COLOR:-false}" == "true" ]] || [[ ! -t 1 ]]; then
  RESET=""; BOLD=""; DIM=""; ITALIC=""; UNDERLINE=""; BLINK=""; INVERT=""
  BLACK=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""; WHITE=""
  BG_BLACK=""; BG_RED=""; BG_GREEN=""; BG_YELLOW=""; BG_BLUE=""; BG_MAGENTA=""; BG_CYAN=""; BG_WHITE=""
else
  RESET="\e[0m"; BOLD="\e[1m"; DIM="\e[2m"; ITALIC="\e[3m"; UNDERLINE="\e[4m"; BLINK="\e[5m"; INVERT="\e[7m"
  BLACK="\e[30m"; RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; MAGENTA="\e[35m"; CYAN="\e[36m"; WHITE="\e[37m"
  BG_BLACK="\e[40m"; BG_RED="\e[41m"; BG_GREEN="\e[42m"; BG_YELLOW="\e[43m"; BG_BLUE="\e[44m"; BG_MAGENTA="\e[45m"; BG_CYAN="\e[46m"; BG_WHITE="\e[47m"
  BRIGHT_BLACK="\e[90m"; BRIGHT_RED="\e[91m"; BRIGHT_GREEN="\e[92m"; BRIGHT_YELLOW="\e[93m"; BRIGHT_BLUE="\e[94m"; BRIGHT_MAGENTA="\e[95m"; BRIGHT_CYAN="\e[96m"; BRIGHT_WHITE="\e[97m"
fi
