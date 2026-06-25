# TX — Termux eXecutive 🚀

> **Advanced Cybersecurity CLI Tool for Termux & Linux**  
> Automation · OSINT · Scanning · Exploitation · Anonymity · System Power

![Version](https://img.shields.io/badge/version-2.0.0-brightgreen)
![Platform](https://img.shields.io/badge/platform-Termux%20|%20Linux-blue)
![License](https://img.shields.io/badge/license-MIT-red)

---

## ⚡ One-Line Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Adhi-hub07/termux-tx/master/install.sh)"
```

Or clone and install:

```bash
git clone https://github.com/Adhi-hub07/termux-tx.git
cd termux-tx
bash install.sh
```

---

## 🎯 Commands Overview

| Command | Description |
|---------|-------------|
| `tx sys` | System info — device, CPU, RAM, disk, battery, sensors |
| `tx net` | Network toolkit — DNS, port scan, geoip, whois, speed test |
| `tx scan` | Port scanner — quick, full, vuln, stealth, OS detection |
| `tx osint` | OSINT recon — domain, email, phone, social media, breaches |
| `tx exploit` | Exploit helpers — reverse shells, LFI, SQLi, XSS |
| `tx payload` | Payload generator — Android, Windows, Linux, stagers |
| `tx crypto` | Encryption, hashing, encoding, SSL, GPG |
| `tx anon` | Anonymity — Tor, proxy, MAC spoof, DNS-over-HTTPS |
| `tx wf` | WiFi audit — scanning, deauth, handshake capture |
| `tx phish` | Phishing framework — server, pages, tunnels (educational) |
| `tx forensic` | Forensic analysis — timeline, recovery, metadata, strings |
| `tx pkg` | Package manager — install, remove, search, clean |
| `tx fs` | File system — disk usage, largest files, perms, checksum |
| `tx proc` | Process manager — kill, top, memory/cpu hogs, services |
| `tx backup` | Backup & restore — home, apps, SMS, configs |
| `tx termux` | Termux API — toast, sensor, camera, location, SMS |
| `tx theme` | Themes & fonts — Dracula, Nord, Cyberpunk, Hacker, more |
| `tx mirror` | Mirror speed test & auto-select best mirror |
| `tx secure` | Security audit — SUID, SSH, firewall, malware scan |
| `tx motd` | Custom login banner with ASCII art |
| `tx alias` | Power aliases deployer |
| `tx auto` | Automation — tasks, watch, system monitor |
| `tx update` | Update TX to latest version |

---

## 🖥️ Usage Examples

```bash
# System info
tx sys

# Quick port scan
tx scan quick 192.168.1.1

# Full domain OSINT
tx osint all example.com

# Generate reverse shell
tx exploit revshell 10.0.0.5 4444

# Start Tor anonymity
tx anon tor

# Apply a cyber theme
tx theme apply cyberpunk

# Chain commands together
tx sys net scan

# JSON output
tx sys --json
```

---

## 📁 Project Structure

```
termux-tx/
├── tx                    # Main executable
├── install.sh            # One-command installer
├── uninstall.sh          # Clean removal
├── config/
│   └── tx.conf           # Default configuration
├── completion/
│   └── tx-completion.bash # Bash tab completion
└── lib/
    ├── colors.sh          # ANSI color definitions
    ├── core.sh            # Core utilities (logging, spinner, etc.)
    ├── banner.sh          # ASCII banners
    ├── sys.sh             # System module
    ├── net.sh             # Network module
    ├── scan.sh            # Port scanning module
    ├── osint.sh           # OSINT module
    ├── exploit.sh         # Exploit helpers
    ├── payload.sh         # Payload generator
    ├── crypto.sh          # Encryption / hashing
    ├── anon.sh            # Anonymity module
    ├── wf.sh              # WiFi audit
    ├── phish.sh           # Phishing framework
    ├── forensic.sh        # Forensic analysis
    ├── pkg.sh             # Package manager
    ├── fs.sh              # File system
    ├── proc.sh            # Process manager
    ├── backup.sh          # Backup & restore
    ├── termux.sh          # Termux API bridge
    ├── theme.sh           # Themes & fonts
    ├── mirror.sh          # Mirror selector
    ├── secure.sh          # Security audit
    ├── motd.sh            # MOTD banner
    ├── alias.sh           # Power aliases
    └── auto.sh            # Automation
```

---

## 🔧 Requirements

- **Termux** (Android) or **Linux** (any distro)
- **bash** >= 4.0
- **curl**, **git** (auto-installed by installer)

---

## ⚠️ Legal Disclaimer

This tool is for **authorized security testing and educational purposes only**.  
Users are responsible for complying with applicable laws.  
Unauthorized access to systems is illegal.

---

## 📞 Contact

- GitHub: [github.com/Adhi-hub07/termux-tx](https://github.com/Adhi-hub07/termux-tx)
- Author: Adhi-hub07

---

**Made with ⚡ for the cybersecurity community**
