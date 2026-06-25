#===============================================================================
#  theme — Terminal Themes & Fonts
#===============================================================================

cmd_theme() {
  module_banner "theme" "Terminal themes & fonts"
  local sub="${1:-list}"; shift 2>/dev/null || true

  case "$sub" in
    list)          theme_list;;
    apply)         theme_apply "$@";;
    random)        theme_random;;
    font)          theme_font "$@";;
    font-list)     theme_font_list;;
    create)        theme_create "$@";;
    reset)         theme_reset;;
    --json)        TX_JSON=true; theme_list;;
    -h|--help)
      echo "Usage: tx theme <subcommand> [name]"
      echo "  list               List available themes"
      echo "  apply <name>       Apply a theme"
      echo "  random             Apply random theme"
      echo "  font <name>        Change font"
      echo "  font-list          List available fonts"
      echo "  create [name]      Create new theme"
      echo "  reset              Reset to default"
      ;;
    *) log_error "Unknown: $sub"; exit 1;;
  esac
}

theme_list() {
  log_section "Available Themes"
  if [[ -d "$HOME/.termux" ]]; then
    for f in "$HOME/.termux"/colors*.properties; do
      [[ -f "$f" ]] && echo "  $(basename "$f" .properties)"
    done
  fi
  # Built-in themes
  echo -e "\n${BOLD}Built-in:${RESET}"
  cat << 'THEMES'
  default      - Termux default (dark)
  light        - Light theme
  green        - Matrix green
  amber        - Fallout amber
  dracula      - Dracula dark
  monokai      - Monokai dark
  nord         - Nord cool
  solarized    - Solarized dark
  one-dark     - Atom One Dark
  tokyo-night  - Tokyo Night
  gruvbox      - Gruvbox dark
  cyberpunk    - Cyberpunk 2077
  synthwave    - Synthwave '84
  hacker       - Green on black
THEMES
}

theme_apply() {
  local name="${1:-default}"
  log_section "Apply Theme — $name"
  if [[ -d "$HOME/.termux" ]]; then
    local theme_file="$HOME/.termux/colors.properties"
    case "$name" in
      default)
        cat > "$theme_file" << 'EOF'
background=#111111
foreground=#ffffff
cursor=#ffffff
color0=#111111
color1=#cc342b
color2=#198844
color3=#fba922
color4=#3971ed
color5=#a36ac7
color6=#3971ed
color7=#c5c8c6
color8=#969896
color9=#cc342b
color10=#198844
color11=#fba922
color12=#3971ed
color13=#a36ac7
color14=#3971ed
color15=#ffffff
EOF
        ;;
      green)
        cat > "$theme_file" << 'EOF'
background=#000000
foreground=#00ff00
cursor=#00ff00
color0=#000000
color1=#00ff00
color2=#00ff00
color3=#00ff00
color4=#00ff00
color5=#00ff00
color6=#00ff00
color7=#00ff00
color8=#005500
color9=#00ff00
color10=#00ff00
color11=#00ff00
color12=#00ff00
color13=#00ff00
color14=#00ff00
color15=#55ff55
EOF
        ;;
      amber)
        cat > "$theme_file" << 'EOF'
background=#000000
foreground=#ffb000
cursor=#ffb000
color0=#000000
color1=#ffb000
color2=#ffb000
color3=#ffb000
color4=#ffb000
color5=#ffb000
color6=#ffb000
color7=#ffb000
color8=#665500
color9=#ffb000
color10=#ffb000
color11=#ffb000
color12=#ffb000
color13=#ffb000
color14=#ffb000
color15=#ffcc00
EOF
        ;;
      dracula)
        cat > "$theme_file" << 'EOF'
background=#282a36
foreground=#f8f8f2
cursor=#f8f8f2
color0=#21222c
color1=#ff5555
color2=#50fa7b
color3=#f1fa8c
color4=#bd93f9
color5=#ff79c6
color6=#8be9fd
color7=#f8f8f2
color8=#6272a4
color9=#ff6e6e
color10=#69ff94
color11=#ffffa5
color12=#d6acff
color13=#ff92df
color14=#a4ffff
color15=#ffffff
EOF
        ;;
      monokai)
        cat > "$theme_file" << 'EOF'
background=#272822
foreground=#f8f8f2
cursor=#f8f8f2
color0=#272822
color1=#f92672
color2=#a6e22e
color3=#f4bf75
color4=#66d9ef
color5=#ae81ff
color6=#a1efe4
color7=#f8f8f2
color8=#75715e
color9=#f92672
color10=#a6e22e
color11=#f4bf75
color12=#66d9ef
color13=#ae81ff
color14=#a1efe4
color15=#f9f8f5
EOF
        ;;
      nord)
        cat > "$theme_file" << 'EOF'
background=#2e3440
foreground=#d8dee9
cursor=#d8dee9
color0=#3b4252
color1=#bf616a
color2=#a3be8c
color3=#ebcb8b
color4=#81a1c1
color5=#b48ead
color6=#88c0d0
color7=#e5e9f0
color8=#4c566a
color9=#bf616a
color10=#a3be8c
color11=#ebcb8b
color12=#81a1c1
color13=#b48ead
color14=#8fbcbb
color15=#eceff4
EOF
        ;;
      tokyo-night)
        cat > "$theme_file" << 'EOF'
background=#1a1b26
foreground=#a9b1d6
cursor=#c0caf5
color0=#1d202f
color1=#f7768e
color2=#9ece6a
color3=#e0af68
color4=#7aa2f7
color5=#bb9af7
color6=#7dcfff
color7=#a9b1d6
color8=#414868
color9=#f7768e
color10=#9ece6a
color11=#e0af68
color12=#7aa2f7
color13=#bb9af7
color14=#7dcfff
color15=#c0caf5
EOF
        ;;
      cyberpunk)
        cat > "$theme_file" << 'EOF'
background=#000000
foreground=#00ffff
cursor=#00ffff
color0=#000000
color1=#ff0066
color2=#00ff00
color3=#ffff00
color4=#0066ff
color5=#ff00ff
color6=#00ffff
color7=#cccccc
color8=#333333
color9=#ff0066
color10=#00ff00
color11=#ffff00
color12=#0066ff
color13=#ff00ff
color14=#00ffff
color15=#ffffff
EOF
        ;;
      hacker)
        cat > "$theme_file" << 'EOF'
background=#050505
foreground=#00ff41
cursor=#00ff41
color0=#000000
color1=#00ff41
color2=#00ff41
color3=#00ff41
color4=#00ff41
color5=#00ff41
color6=#00ff41
color7=#00ff41
color8=#005a00
color9=#00ff41
color10=#00ff41
color11=#00ff41
color12=#00ff41
color13=#00ff41
color14=#00ff41
color15=#00ff41
EOF
        ;;
      *)
        log_error "Theme not found: $name"
        return 1
        ;;
    esac
    log_success "Theme applied: $name"
    if command -v termux-reload-settings &>/dev/null; then
      termux-reload-settings && log_success "Termux settings reloaded"
    fi
  else
    log_warn "Termux not detected. Applying to terminal..."
    echo -e "\nSet your terminal colors manually using the hex values."
    log_info "For bash: export PS1='\[\e[38;5;46m\]\u\[\e[0m\]@\[\e[38;5;46m\]\h\[\e[0m\]:\[\e[38;5;46m\]\w\[\e[0m\]\$ '"
  fi
}

theme_random() {
  local themes=(default green amber dracula monokai nord tokyo-night cyberpunk hacker)
  local choice=${themes[RANDOM % ${#themes[@]}]}
  log_info "Random theme: $choice"
  theme_apply "$choice"
}

theme_font() {
  local font="${1:-}"
  [[ -z "$font" ]] && { log_error "Usage: tx theme font <name>"; return 1; }
  log_section "Font — $font"
  if [[ -d "$HOME/.termux" ]]; then
    local url
    url="https://github.com/termux/termux-font/raw/master/fonts/$font.ttf"
    curl -sL "$url" -o "$HOME/.termux/font.ttf" 2>/dev/null && log_success "Font applied: $font" || log_error "Font not found: $font"
    command -v termux-reload-settings &>/dev/null && termux-reload-settings
  else
    log_info "Fonts can be found at: https://github.com/termux/termux-font"
  fi
}

theme_font_list() {
  log_section "Available Fonts"
  curl -s "https://api.github.com/repos/termux/termux-font/contents/fonts" 2>/dev/null | python3 -c "
import sys, json
try:
  data = json.load(sys.stdin)
  for f in data:
    name = f.get('name','')
    if name.endswith('.ttf'):
      print(f'  {name.replace(\".ttf\",\"\")}')
except: print('  Failed to fetch')
" 2>/dev/null || log_warn "Could not fetch font list"
}

theme_create() {
  local name="${1:-mytheme}"
  log_section "Create Theme — $name"
  echo -e "Enter hex colors (without #):"
  local -A colors
  colors[bg]="background"
  colors[fg]="foreground"
  colors[0]="color0 (black)"
  colors[1]="color1 (red)"
  colors[2]="color2 (green)"
  colors[3]="color3 (yellow)"
  colors[4]="color4 (blue)"
  colors[5]="color5 (magenta)"
  colors[6]="color6 (cyan)"
  colors[7]="color7 (white)"

  local file="$HOME/.termux/colors-$name.properties"
  > "$file"
  for key in bg fg 0 1 2 3 4 5 6 7; do
    read -r -p "  ${colors[$key]}: " val
    val="${val:-000000}"
    echo "${colors[$key]%% *}=#$val" >> "$file"
  done
  log_success "Theme saved: $file"
}

theme_reset() {
  log_section "Reset Theme"
  rm -f "$HOME/.termux/colors.properties" "$HOME/.termux/font.ttf" 2>/dev/null
  command -v termux-reload-settings &>/dev/null && termux-reload-settings
  log_success "Theme reset to default"
}
