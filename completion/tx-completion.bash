#!/usr/bin/env bash
#===============================================================================
#  TX - Bash Tab Completion
#===============================================================================

_tx_completions() {
  local cur prev words cword
  _init_completion || return

  local commands="sys net pkg fs proc backup termux theme mirror secure motd alias scan osint exploit payload crypto anon forensic phish wf auto update help"

  if [[ $cword -eq 1 ]]; then
    mapfile -t COMPREPLY < <(compgen -W "$commands" -- "$cur")
    return
  fi

  # Subcommands per command
  case "${words[1]}" in
    sys)
      local subs="all cpu ram disk battery kernel network packages sensors users uptime temp info"
      ;;
    net)
      local subs="info resolve scan geoip ping traceroute whois speed wifi interfaces listen sniff dnsdump subdomain headers myip ports"
      ;;
    pkg)
      local subs="update upgrade install remove search list info clean deps files add"
      ;;
    fs)
      local subs="usage du largest tree count find search perms link mount trash clean split merge checksum df"
      ;;
    proc)
      local subs="list top kill mem cpu tree search count io zombie service ps memory htop"
      ;;
    backup)
      local subs="create restore list apps sms termux config"
      ;;
    termux)
      local subs="toast notification tts battery clipboard sensor camera sms call contact location wifi torch vibrate speech storage micro media-scan"
      ;;
    theme)
      local subs="list apply random font font-list create reset"
      ;;
    mirror)
      local subs="test set list best speed select"
      ;;
    secure)
      local subs="audit suid ssh perms firewall selinux apps network password malware check"
      ;;
    motd)
      local subs="show set reset random ascii"
      ;;
    alias)
      local subs="list deploy add remove backup restore"
      ;;
    scan)
      local subs="quick full service version udp ping top subnet vuln cve os banner firewall stealth"
      ;;
    osint)
      local subs="domain ip email phone social breach dns subdomain cert github shodan whois web wayback all"
      ;;
    exploit)
      local subs="revshell php upload lfi sqli xss cmd rfi deserialization searchsploit msf reverse"
      ;;
    payload)
      local subs="android windows linux web mac stager download dns php"
      ;;
    crypto)
      local subs="hash encrypt decrypt encode decode base64 base32 hex rot13 xor genkey ssl gpg checksum cipher"
      ;;
    anon)
      local subs="tor start stop status check proxy dns chain mac hostname clean myip"
      ;;
    forensic)
      local subs="timeline recover metadata strings hex filetype binwalk volatility"
      ;;
    phish)
      local subs="server page ngrok cloudflared mask sms start"
      ;;
    wf)
      local subs="scan info deauth handshake crack monitor managed airodump list"
      ;;
    auto)
      local subs="list add remove run watch monitor cleanup"
      ;;
    help)
      local subs="$commands"
      ;;
  esac

  if [[ -n "$subs" ]]; then
    mapfile -t COMPREPLY < <(compgen -W "$subs" -- "$cur")
  fi
}

complete -F _tx_completions tx
