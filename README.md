# TX — Termux eXecutive 🚀

> **Advanced Cybersecurity CLI Tool for Termux & Linux**  
> Automation · OSINT · Scanning · Exploitation · Anonymity · System Power

![Version](https://img.shields.io/badge/version-2.0.0-brightgreen)
![Platform](https://img.shields.io/badge/platform-Termux%20|%20Linux-blue)
![License](https://img.shields.io/badge/license-MIT-red)
[![GitHub](https://img.shields.io/badge/github-Adhi--hub07/termux--tx-181717?logo=github)](https://github.com/Adhi-hub07/termux-tx)

---

## 📋 Table of Contents

- [Quick Install](#-quick-install)
- [What is TX?](#-what-is-tx)
- [All Commands — Full Reference](#-all-commands--full-reference)
  - [tx sys — System Information](#1-tx-sys--system-information)
  - [tx net — Network Toolkit](#2-tx-net--network-toolkit)
  - [tx scan — Port Scanning & Vulnerability Detection](#3-tx-scan--port-scanning--vulnerability-detection)
  - [tx osint — OSINT Reconnaissance](#4-tx-osint--osint-reconnaissance)
  - [tx exploit — Exploit Helpers & Reverse Shells](#5-tx-exploit--exploit-helpers--reverse-shells)
  - [tx payload — Payload Generator](#6-tx-payload--payload-generator)
  - [tx crypto — Encryption, Hashing & Encoding](#7-tx-crypto--encryption-hashing--encoding)
  - [tx anon — Anonymity & Privacy](#8-tx-anon--anonymity--privacy)
  - [tx wf — WiFi Audit Tools](#9-tx-wf--wifi-audit-tools)
  - [tx phish — Phishing Framework (Educational)](#10-tx-phish--phishing-framework-educational)
  - [tx forensic — Forensic Analysis](#11-tx-forensic--forensic-analysis)
  - [tx pkg — Package Manager](#12-tx-pkg--package-manager)
  - [tx fs — File System Tools](#13-tx-fs--file-system-tools)
  - [tx proc — Process Manager](#14-tx-proc--process-manager)
  - [tx backup — Backup & Restore](#15-tx-backup--backup--restore)
  - [tx termux — Termux API Bridge](#16-tx-termux--termux-api-bridge)
  - [tx theme — Terminal Themes & Fonts](#17-tx-theme--terminal-themes--fonts)
  - [tx mirror — Mirror Speed Test & Selector](#18-tx-mirror--mirror-speed-test--selector)
  - [tx secure — Security Audit & Hardening](#19-tx-secure--security-audit--hardening)
  - [tx motd — Custom Login Banner](#20-tx-motd--custom-login-banner)
  - [tx alias — Power Aliases Deployer](#21-tx-alias--power-aliases-deployer)
  - [tx auto — Automation & Scheduled Tasks](#22-tx-auto--automation--scheduled-tasks)
  - [tx update — Update TX](#23-tx-update--update-tx)
- [Options & Flags](#-options--flags)
- [Command Chaining](#-command-chaining)
- [Configuration](#-configuration)
- [Tab Completion](#-tab-completion)
- [Project Structure](#-project-structure)
- [Requirements](#-requirements)
- [Uninstall](#-uninstall)
- [Legal Disclaimer](#-legal-disclaimer)

---

## ⚡ Quick Install

### One-Line Install (Recommended)
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Adhi-hub07/termux-tx/master/install.sh)"
```

### Manual Install
```bash
git clone https://github.com/Adhi-hub07/termux-tx.git
cd termux-tx
bash install.sh
```

After install, just type `tx` in your terminal.

---

## 🎯 What is TX?

**TX (Termux eXecutive)** is an all-in-one advanced cybersecurity CLI tool designed for **Termux** (Android) and **Linux**. It brings together **25+ modules** covering:

| Category | Modules |
|----------|---------|
| 🖥️ **System** | System info, file management, process management, package management |
| 🌐 **Network** | DNS resolution, port scanning, GeoIP, WHOIS, speed test, packet capture |
| 🔍 **OSINT** | Domain/email/phone recon, social media search, breach lookup, Shodan, certificate transparency |
| ⚡ **Exploitation** | Reverse shell one-liners, LFI/SQLi/XSS testing, Metasploit integration |
| 📦 **Payloads** | Android/Windows/Linux/macOS payload generation, web shells, download cradles |
| 🔐 **Crypto** | Hashing (MD5/SHA1/SHA256/SHA512), AES encryption, Base64/32/Hex/ROT13/XOR |
| 🕵️ **Anonymity** | Tor routing, proxy support, DNS-over-HTTPS, MAC spoofing, trace cleaning |
| 📡 **WiFi** | Network scanning, deauth attacks, handshake capture, WPA cracking |
| 🎣 **Phishing** | HTTP phishing server, credential capture, ngrok/Cloudflare tunnels, URL masking |
| 🔬 **Forensics** | File timeline, metadata extraction, hex dump, binwalk, file recovery |
| 🛡️ **Security** | SUID/SGID audit, SSH config check, firewall status, malware scan, password strength |
| 📱 **Termux** | Toast notifications, SMS, camera, sensors, GPS, clipboard, WiFi, torch, TTS |
| 🎨 **Customization** | Themes (Dracula, Nord, Cyberpunk, Hacker, etc.), fonts, MOTD banner, aliases |
| ⏰ **Automation** | Scheduled tasks, system monitoring, file watching, auto-cleanup |

---

## 📖 All Commands — Full Reference

### 1. `tx sys` — System Information

Get complete system information about your device.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `all` (default) | Show everything |
| `cpu` | CPU model, cores, frequency |
| `ram` / `mem` | Memory usage with progress bar |
| `disk` | Storage partitions and usage |
| `battery` | Battery level, status, temperature |
| `kernel` | Kernel version, OS, architecture |
| `network` | Network interfaces and IPs |
| `packages` | Count of installed packages |
| `sensors` | Sensor data (Termux) |
| `users` | Logged in users, UID, groups |
| `uptime` | System uptime |
| `temp` | CPU/thermal temperatures |

**Examples:**
```bash
tx sys              # Full system info
tx sys cpu          # CPU details only
tx sys ram          # Memory usage with progress bar
tx sys battery      # Battery info
tx sys --json       # JSON output
```

**Termux-specific:** Detects Android device model, manufacturer, Android version via `getprop`.

---

### 2. `tx net` — Network Toolkit

Network diagnostics and analysis tools.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `info` / `myip` | Public IP, ISP, location, coordinates |
| `resolve` / `dns` `<domain>` | Full DNS resolution (A, AAAA, MX, NS, TXT records) |
| `scan` / `ports` `<host>` `[ports]` | TCP port scan with nmap or bash TCP |
| `geoip` `<ip>` | GeoIP lookup with ISP, org, ASN |
| `ping` `<host>` `[count]` | ICMP ping |
| `traceroute` `<host>` | Network route tracing |
| `whois` `<domain>` | WHOIS domain lookup |
| `speed` | Internet speed test |
| `wifi` | WiFi connection info + available networks (Termux) |
| `interfaces` / `ifaces` | All network interfaces |
| `listen` | Listening ports on the device |
| `sniff` `[interface]` | Packet capture with tcpdump |
| `dnsdump` `<domain>` | DNS record enumeration |
| `subdomain` `<domain>` | Subdomain discovery via crt.sh |
| `headers` `<url>` | HTTP response headers |

**Examples:**
```bash
tx net                     # Public IP info
tx net resolve example.com  # DNS records
tx net geoip 8.8.8.8       # GeoIP lookup
tx net sniff wlan0         # Packet capture
tx net subdomain google.com # Subdomain discovery
tx net speed                # Speed test
tx net headers https://example.com  # HTTP headers
```

---

### 3. `tx scan` — Port Scanning & Vulnerability Detection

Comprehensive port scanning with multiple modes.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `quick` / `fast` `<host>` | Quick scan of common ports |
| `full` `<host>` | Full scan (1-65535) |
| `service` `<host>` | Service version detection |
| `version` `<host>` | Aggressive version detection |
| `udp` `<host>` | UDP scan |
| `ping` `<host>` `[cidr]` | Ping sweep across subnet |
| `top` `<host>` | Top 100 ports scan |
| `subnet` `<cidr>` | Subnet host discovery |
| `vuln` `<host>` | NSE vulnerability scripts |
| `cve` `<host>` | CVE detection with vulners |
| `os` `<host>` | OS fingerprinting |
| `banner` `<host>` `[ports]` | Banner grabbing |
| `firewall` `<host>` | Firewall detection (ACK scan) |
| `stealth` `<host>` | SYN stealth scan (requires root) |

**Examples:**
```bash
tx scan quick 192.168.1.1      # Quick port scan
tx scan full scanme.nmap.org   # Full port scan
tx scan vuln 10.0.0.5          # Vulnerability scan
tx scan os 192.168.1.1         # OS detection
tx scan stealth targets.com    # Stealth SYN scan
tx scan ping 192.168.1.0/24    # Ping sweep
tx scan banner 10.0.0.1 "21 22 80"  # Banner grab
```

**Fallback:** If nmap is not installed, uses bash built-in TCP for basic scanning.

---

### 4. `tx osint` — OSINT Reconnaissance

Open-source intelligence gathering across multiple sources.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `domain` `<domain>` | Full domain recon (DNS + WHOIS + SSL + Wayback) |
| `ip` `<ip>` | IP recon (GeoIP, ISP, org, ASN) |
| `email` `<email>` | Email breach check, MX records, Google search |
| `phone` `<number>` | Phone number lookup |
| `social` / `user` `<username>` | Social media presence check (10 platforms) |
| `breach` `<email>` | Data breach lookup |
| `dns` `<domain>` | DNS enumeration (A, AAAA, CNAME, MX, NS, TXT, SOA, SRV) |
| `subdomain` `<domain>` | Subdomain discovery via crt.sh |
| `cert` / `ssl` `<domain>` | Certificate transparency logs |
| `github` `<username>` | GitHub user profile info via API |
| `shodan` `<ip>` | Shodan IoT lookup (requires API key) |
| `whois` `<domain>` | WHOIS record |
| `web` / `website` `<url>` | Website recon (headers, tech, emails, links) |
| `wayback` `<domain>` | Wayback Machine historical URLs |
| `all` `<domain>` | Full recon — runs all domain checks |

**Social Media Checked:**
GitHub, Twitter/X, Instagram, Reddit, YouTube, LinkedIn, TikTok, Facebook, Medium, Dev.to

**Examples:**
```bash
tx osint all example.com          # Full domain recon
tx osint social johndoe           # Social media presence
tx osint email user@example.com   # Email breach check
tx osint shodan 8.8.8.8          # Shodan lookup
tx osint web https://example.com  # Website recon
tx osint github octocat           # GitHub profile
```

---

### 5. `tx exploit` — Exploit Helpers & Reverse Shells

Penetration testing helpers and exploit templates.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `revshell` / `reverse` `<ip>` `<port>` | Generate reverse shell one-liners (15 types) |
| `php` `<ip>` `<port>` | PHP reverse shell code |
| `upload` `<file>` `<url>` | File upload via curl |
| `lfi` / `file` `<url>` `<file>` | Local File Inclusion testing |
| `sqli` / `sql` `<url>` `<param>` | SQL Injection testing with timing |
| `xss` `<url>` `<param>` | XSS payload examples |
| `cmd` / `command` `<url>` `<cmd>` | Command injection testing |
| `rfi` `<url>` `<shell_url>` | Remote File Inclusion testing |
| `deserialization` | Insecure deserialization payload examples (PHP/Java/Python) |
| `searchsploit` `<query>` | Search Exploit-DB |
| `msf` `<module>` | Metasploit module information |

**Reverse Shell Types Generated:**
bash, python, nc, ncat, php, perl, ruby, lua, openssl, powershell, awk, tcl, java, telnet, socat

**Examples:**
```bash
tx exploit revshell 10.0.0.5 4444   # All reverse shell one-liners
tx exploit sqli http://target.com/page.php id  # SQLi test
tx exploit lfi http://target.com/index.php?file= /etc/passwd  # LFI test
tx exploit searchsploit apache 2.4  # Search Exploit-DB
tx exploit xss http://target.com/search q  # XSS payloads
```

---

### 6. `tx payload` — Payload Generator

Generate payloads for penetration testing engagements.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `android` `<lhost>` `<lport>` | Android meterpreter APK |
| `windows` `<lhost>` `<lport>` | Windows meterpreter EXE |
| `linux` `<lhost>` `<lport>` | Linux meterpreter ELF |
| `web` / `php` | Web shell payloads (PHP, ASP, Python) |
| `mac` / `macos` `<lhost>` `<lport>` | macOS meterpreter MACHO |
| `stager` `<lhost>` `<lport>` | Staged payloads (shellcode, Python, PowerShell) |
| `download` `<url>` | Download cradles (PowerShell, bash, Python, PHP, Java) |
| `dns` `<domain>` | DNS tunneling tools and commands |

**Examples:**
```bash
tx payload android 10.0.0.5 4444   # Generate Android APK
tx payload web                      # Show web shells
tx payload stager 10.0.0.5 4444    # Show staged payloads
tx payload download http://evil.com/payload.exe  # Download cradles
```

**Note:** Requires `msfvenom` (from Metasploit) for Android/Windows/Linux payload generation.

---

### 7. `tx crypto` — Encryption, Hashing & Encoding

Cryptographic operations with OpenSSL and Python backends.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `hash` `<algo>` `<str/file>` | Hash a string or file (sha256, md5, sha1, sha512, etc.) |
| `encrypt` `<method>` `<data>` | Encrypt data (AES-256-CBC, etc.) with password |
| `decrypt` `<method>` `<data>` | Decrypt data |
| `encode` `<type>` `<data>` | Encode (base64, base32, hex, url) |
| `decode` `<type>` `<data>` | Decode (base64, base32, hex, url) |
| `base64` `<str>` | Base64 encode |
| `base32` `<str>` | Base32 encode |
| `hex` `<str>` | Hex encode |
| `rot13` `<str>` | ROT13 cipher |
| `xor` `<str>` `<key>` | XOR cipher |
| `genkey` `[bits]` | Generate RSA key pair |
| `ssl` `<domain>` | SSL certificate info |
| `gpg` `<file>` `<encrypt|decrypt>` | GPG encrypt/decrypt |
| `checksum` `<file>` | All checksums for a file |
| `cipher` | List available OpenSSL ciphers |

**Examples:**
```bash
tx crypto hash sha256 "hello world"          # SHA256 hash
tx crypto hash md5 /path/to/file             # MD5 of file
tx crypto base64 "hello"                     # Base64 encode
tx crypto decode base64 aGVsbG8=            # Base64 decode
tx crypto rot13 "uryyb"                      # ROT13 decode
tx crypto xor "secret" "key"                 # XOR cipher
tx crypto encrypt aes-256-cbc "secret data"  # Encrypt
tx crypto ssl google.com                     # SSL cert info
tx crypto checksum /path/to/file            # All hashes
tx crypto genkey 4096                        # Generate RSA key
```

---

### 8. `tx anon` — Anonymity & Privacy

Route traffic through Tor, change MAC addresses, clean traces.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `tor` / `start` | Start Tor service |
| `stop` | Stop Tor |
| `status` | Tor status and IP check |
| `check` / `myip` | Compare direct IP vs Tor IP, DNS leak test |
| `proxy` `<url>` `[cmd]` | Route command through proxy |
| `dns` / `dnsoverhttps` | Use DNS-over-HTTPS |
| `chain` | Request new Tor circuit (NEWNYM) |
| `mac` `<iface>` | Spoof MAC address |
| `hostname` | Change system hostname |
| `clean` | Clear bash history, logs, temp files, Tor traces |

**Examples:**
```bash
tx anon              # Start/check Tor
tx anon check        # Verify anonymity
tx anon chain        # New Tor circuit
tx anon mac wlan0    # Spoof MAC
tx anon clean        # Clear traces
```

---

### 9. `tx wf` — WiFi Audit Tools

WiFi network auditing and security assessment.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `scan` / `list` | Scan WiFi networks |
| `info` | Current connection info |
| `deauth` `<bssid>` `[iface]` | Deauth attack (requires root + aircrack-ng) |
| `handshake` `<bssid>` `[channel]` `[iface]` | Capture WPA handshake |
| `crack` `<cap>` `[wordlist]` | Crack WPA handshake |
| `monitor` `[iface]` | Enable monitor mode |
| `managed` `[iface]` | Disable monitor mode |
| `airodump` `[iface]` | Live airodump-ng |

**Examples:**
```bash
tx wf scan                  # List networks
tx wf info                  # Current connection
tx wf monitor               # Enable monitor mode
tx wf deauth AA:BB:CC:DD:EE:FF  # Deauth attack
tx wf handshake AA:BB:CC:DD:EE:FF 6  # Capture handshake
tx wf crack /tmp/handshake-01.cap /path/to/wordlist.txt  # Crack
```

**Note:** Most WiFi features require **root access** and `aircrack-ng`.

---

### 10. `tx phish` — Phishing Framework (Educational)

> ⚠ **For authorized security testing and education only!**

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `server` / `start` `[port]` | Start HTTP credential harvesting server |
| `page` `<type>` | Generate phishing page (login, facebook, instagram, twitter) |
| `ngrok` `[port]` | Start ngrok tunnel for local server |
| `cloudflared` `[port]` | Start Cloudflare tunnel |
| `mask` `<url>` | URL masking and shortener techniques |
| `sms` `<number>` | SMS phishing techniques (educational) |

**Examples:**
```bash
tx phish server 8080              # Start phishing server
tx phish page login               # Generate login page
tx phish ngrok 8080               # Start ngrok tunnel
tx phish page facebook            # Facebook clone page
```

**Captured credentials are logged to** `/tmp/phish_log.txt`.

---

### 11. `tx forensic` — Forensic Analysis

Digital forensics helpers for file analysis.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `timeline` `<dir>` | Build file modification timeline |
| `recover` `<dev>` | Recover deleted files (foremost) |
| `metadata` `<file>` | Extract metadata (EXIF, stat, file info) |
| `strings` `<file>` `[min-len]` | Extract strings from binary |
| `hex` / `hexdump` `<file>` | Hex dump with xxd |
| `filetype` `<file>` | Detect file type and magic bytes |
| `binwalk` `<file>` | Analyze firmware/binaries |
| `volatility` `<file>` | Memory dump analysis |

**Examples:**
```bash
tx forensic metadata photo.jpg       # EXIF data
tx forensic strings binary.bin 8     # Strings from binary
tx forensic timeline /home/user      # File timeline
tx forensic hex /tmp/memdump.raw     # Hex dump
tx forensic recover /dev/sdb1        # Recover deleted files
```

---

### 12. `tx pkg` — Package Manager

Cross-platform package management wrapper.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `update` | Update package lists |
| `upgrade` | Upgrade all packages |
| `install` `<pkg>` `[packages...]` | Install package(s) |
| `remove` / `rm` `<pkg>` | Remove package(s) |
| `search` `<query>` | Search for packages |
| `list` | List installed packages with count |
| `info` `<pkg>` | Package details |
| `clean` | Clean package cache |
| `deps` `<pkg>` | Show package dependencies |
| `files` `<pkg>` | Files owned by package |

**Supported Package Managers:**
- Termux: `pkg` / `apt` / `dpkg`
- Debian/Ubuntu: `apt` / `dpkg`
- Arch: `pacman`
- Fedora/RHEL: `dnf` / `rpm`

**Examples:**
```bash
tx pkg update                    # Update repos
tx pkg install nmap              # Install nmap
tx pkg search python             # Search Python packages
tx pkg list                      # All installed packages
tx pkg info openssl              # Package info
tx pkg deps curl                 # Dependencies
tx pkg files nginx               # Files owned by nginx
```

---

### 13. `tx fs` — File System Tools

File system management, analysis, and cleanup.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `usage` / `df` | Disk usage overview |
| `du` `<path>` | Directory size |
| `largest` `[n]` | Top N largest files |
| `tree` `[path]` `[depth]` | Directory tree |
| `count` `[path]` | File/directory/symlink counts |
| `find` `<pattern>` `[path]` | Find files by name |
| `search` `<pattern>` `[path]` | Search file contents |
| `perm` / `perms` `[path]` | Permission audit (SUID, SGID, world-writable) |
| `link` / `symlink` `[path]` | Find broken/valid symlinks |
| `mount` | Mounted filesystems |
| `trash` `<file>` | Move file to trash (~/.trash/) |
| `clean` | Clean temp files, trash, cache |
| `split` `<file>` `[size]` | Split large file |
| `merge` `<file>` | Merge split parts |
| `checksum` `<file>` | MD5, SHA1, SHA256, SHA512 |

**Examples:**
```bash
tx fs                     # Disk usage
tx fs largest 30          # Top 30 largest files
tx fs tree /home 2        # Directory tree (2 levels)
tx fs perms /usr          # Permission audit
tx fs search "password" ~/docs  # Search contents
tx fs clean               # Free up space
tx fs checksum file.zip   # All hashes
tx fs split bigfile.iso 50m  # Split into 50MB parts
```

---

### 14. `tx proc` — Process Manager

Process monitoring and management.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `list` / `ps` | List all processes |
| `top` / `htop` | Interactive process viewer |
| `kill` `<pid>` `[signal]` | Kill process (default SIGTERM) |
| `mem` / `memory` | Top 10 memory-consuming processes |
| `cpu` | Top 10 CPU-consuming processes |
| `tree` | Process hierarchy tree |
| `search` `<query>` | Search for processes |
| `count` | Process count (total, running, sleeping, zombie) |
| `io` | Disk I/O stats |
| `zombie` | Find zombie processes |
| `service` `<name>` `[action]` | Service management (systemd/sysvinit) |

**Examples:**
```bash
tx proc                      # List processes
tx proc mem                  # Memory hogs
tx proc cpu                  # CPU hogs
tx proc kill 1234            # Kill process
tx proc tree                 # Process tree
tx proc service nginx restart  # Restart nginx
tx proc zombie               # Check for zombies
```

---

### 15. `tx backup` — Backup & Restore

System and application backup management.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `create` `[name]` | Create full backup (home, packages, configs) |
| `restore` `<backup>` | Restore from backup |
| `list` | List all backups |
| `apps` | Backup installed apps/packages list |
| `sms` | Backup SMS messages (Termux) |
| `termux` | Backup Termux configuration |
| `config` | Backup configuration files |

**Backup Location:** `~/.tx/backups/`

**What gets backed up:**
- Home directory (compressed)
- Package selections
- SSH keys, bashrc, zshrc, gitconfig

**Examples:**
```bash
tx backup create my-backup     # Create backup
tx backup list                 # List backups
tx backup termux               # Termux-specific backup
tx backup config               # Config files backup
tx backup apps                 # Save app list
tx backup restore ~/.tx/backups/my-backup  # Restore
```

---

### 16. `tx termux` — Termux API Bridge

Interface with Android device features via Termux API.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `toast` `<msg>` | Show toast notification |
| `notification` `<title>` `<msg>` | Persistent notification |
| `tts` `<text>` | Text-to-speech |
| `battery` | Battery status (level, temp, health) |
| `clipboard` `[text]` | Get or set clipboard |
| `sensor` `[type]` | Sensor data (accelerometer, gyro, etc.) |
| `camera` `[id]` | Take photo |
| `sms` | List recent SMS messages |
| `call` `<number>` | Make phone call |
| `contact` | List all contacts |
| `location` | GPS coordinates |
| `wifi` | WiFi connection + scan |
| `torch` `[on|off]` | Flashlight toggle |
| `vibrate` `[ms]` | Vibrate device |
| `speech` | Speech recognition |
| `storage` | Setup storage access |
| `micro` `[file]` | Record audio |
| `media-scan` | Scan media files |

**Examples:**
```bash
tx termux battery              # Battery status
tx termux toast "Hello from TX"  # Toast notification
tx termux location             # GPS location
tx termux torch on             # Flashlight on
tx termux sms                  # Read SMS
tx termux clipboard "copied!"  # Set clipboard
tx termux tts "system compromised"  # Text to speech
tx termux sensor accelerometer # Read sensor
tx termux camera 0             # Take photo
```

**Requires:** `termux-api` package (`pkg install termux-api`)

---

### 17. `tx theme` — Terminal Themes & Fonts

Customize your Termux terminal appearance.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `list` | List available themes |
| `apply` `<name>` | Apply a theme |
| `random` | Apply a random theme |
| `font` `<name>` | Change font (downloads from termux-font) |
| `font-list` | List available fonts |
| `create` `[name]` | Create custom theme interactively |
| `reset` | Reset to default |

**Built-in Themes:**

| Theme | Style |
|-------|-------|
| `default` | Termux default dark |
| `green` | Matrix-style green on black |
| `amber` | Fallout-style amber |
| `dracula` | Dracula dark purple |
| `monokai` | Monokai dark |
| `nord` | Nord cool blue |
| `tokyo-night` | Tokyo Night |
| `cyberpunk` | Cyberpunk 2077 neon |
| `hacker` | Green-on-black hacker style |

**Examples:**
```bash
tx theme list                  # Show all themes
tx theme apply dracula         # Apply Dracula
tx theme apply cyberpunk       # Apply Cyberpunk
tx theme apply hacker          # Hacker green
tx theme random                # Random theme
tx theme font FiraCode         # Change font
tx theme create mytheme        # Interactive creation
tx theme reset                 # Back to default
```

---

### 18. `tx mirror` — Mirror Speed Test & Selector

Find and set the fastest package repository mirror.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `test` / `speed` | Test all mirror speeds |
| `set` / `select` `<url>` | Set a specific mirror |
| `list` | Show current mirrors |
| `best` | Auto-select the fastest mirror |

**Examples:**
```bash
tx mirror test        # Test all mirrors
tx mirror best        # Auto-select fastest
tx mirror set https://mirror.example.com/termux  # Manual set
```

---

### 19. `tx secure` — Security Audit & Hardening

Comprehensive security assessment and hardening.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `audit` / `check` | Full security audit (SUID, SSH, ports, world-writable, orphans) |
| `suid` | Find all SUID/SGID files |
| `ssh` | Check SSH configuration |
| `perm` / `perms` `<path>` | Check file permissions |
| `firewall` | Firewall status (iptables/nftables/ufw) |
| `selinux` | SELinux status and context |
| `apps` | Check app permissions (Termux) |
| `network` | Network security (open ports, DNS, ARP, routing) |
| `password` `<pwd>` | Password strength assessment |
| `malware` | Basic malware scan (SUID shells, suspicious files, cron) |

**Examples:**
```bash
tx secure                 # Full audit
tx secure suid            # Find SUID files
tx secure ssh             # SSH config check
tx secure firewall        # Firewall rules
tx secure password "P@ssw0rd123!"  # Check password strength
tx secure malware         # Malware scan
tx secure audit           # Full security audit
```

---

### 20. `tx motd` — Custom Login Banner

Set a custom message-of-the-day displayed on terminal login.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `show` | Show current MOTD |
| `set` `<msg>` | Set custom MOTD message |
| `reset` | Reset to default |
| `random` | Random cyber quote |
| `ascii` `<art>` | Set ASCII art MOTD |

**ASCII Art Options:**
- `hacker` — Hacker-style border
- `skull` — Skull ASCII art
- `dragon` / `tx` — TX logo

**Examples:**
```bash
tx motd                        # Show current
tx motd set "Welcome to the Matrix"
tx motd random                 # Random quote
tx motd ascii skull            # Skull banner
tx motd ascii dragon           # TX Dragon banner
tx motd reset                  # Back to default
```

---

### 21. `tx alias` — Power Aliases Deployer

Deploy a comprehensive set of productivity aliases.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `list` | Show current aliases |
| `deploy` | Deploy all power aliases to bashrc/zshrc |
| `add` `<name>` `<cmd>` | Add custom alias |
| `remove` `<name>` | Remove alias |
| `backup` | Backup aliases to ~/.tx/ |
| `restore` | Restore aliases from backup |

**Aliases deployed:**
```
ll → ls -lah       la → ls -A         l → ls -CF
..  → cd ..        ... → cd ../..     .... → cd ../../..
grep → grep --color=auto  (and fgrep, egrep)
ip → ip -color=auto  df → df -h  du → du -h  free → free -h
ports → ss -tlnp   myip → curl -s ifconfig.me  paths → echo PATH
txs → tx sys       txn → tx net scan  txp → tx pkg
txo → tx osint     txsc → tx scan     txex → tx exploit
txpl → tx payload  txcr → tx crypto   txan → tx anon
txfw → tx wf       txph → tx phish    txsr → tx secure
```

**Examples:**
```bash
tx alias deploy       # Add all aliases to .bashrc
tx alias myip         # Show your IP
tx alias add serve "python3 -m http.server 8080"
tx alias backup       # Backup aliases
tx alias list         # Show current aliases
```

---

### 22. `tx auto` — Automation & Scheduled Tasks

Create, run, and manage automated tasks.

**Subcommands:**

| Subcommand | Description |
|------------|-------------|
| `list` | List all tasks |
| `add` `<name>` `<cmd>` | Create a new task |
| `remove` / `rm` `<name>` | Delete a task |
| `run` `<name>` | Execute a task |
| `watch` `<cmd>` | Watch command every 2 seconds |
| `monitor` | Real-time system resource monitor |
| `cleanup` | Auto-cleanup (temp files, logs, cache) |

**Examples:**
```bash
tx auto add backup "tar czf /sdcard/backup.tar.gz ~"
tx auto run backup                # Execute task
tx auto watch "date && uptime"    # Watch date/uptime
tx auto monitor                   # Real-time system monitor
tx auto cleanup                   # Clean temp files
tx auto list                      # List all tasks
```

**Task location:** `~/.tx/tasks/` — each task is an executable script.

---

### 23. `tx update` — Update TX

Update TX to the latest version from GitHub.

```bash
tx update
```

Pulls the latest code from the repository.

---

## 🚩 Options & Flags

These flags work globally with any command:

| Flag | Description |
|------|-------------|
| `--json` | Output in JSON format |
| `--verbose` / `-v` | Verbose/debug output |
| `--force` / `-f` | Force operations (skip confirmations) |
| `--no-color` | Disable colored output |
| `-h` / `--help` | Show help for any command |
| `-V` / `--version` | Show TX version |

**Examples:**
```bash
tx sys --json           # System info as JSON
tx --force pkg remove nginx  # Remove without asking
tx scan --json 192.168.1.1  # JSON scan results
tx --verbose osint domain example.com  # Debug output
tx crypto --no-color hash sha256 test  # No colors
```

---

## 🔗 Command Chaining

Run multiple commands in sequence:

```bash
# Auto-chaining (next arg is a valid command):
tx sys net scan

# Explicit chaining:
tx --chain sys net scan
tx + sys net scan
```

---

## ⚙️ Configuration

TX uses a config file at `~/.tx/config`. Create it to customize behavior:

```bash
# TX Configuration — ~/.tx/config

TX_JSON=false              # Default JSON mode
TX_VERBOSE=false           # Verbose logging
TX_FORCE=false             # Skip all confirmations
TX_NO_COLOR=false          # Disable colors
TX_EDITOR=nano             # Default editor
TX_TIMEOUT=10              # Network timeout (seconds)
TX_TOR_PORT=9050           # Tor SOCKS port
TX_PHISH_PORT=8080         # Phishing server port
TX_THEME="default"         # Default theme
TX_LPORT="4444"            # Default listen port
```

---

## 🔄 Tab Completion

Bash tab completion is automatically installed. After install:

```bash
tx <TAB>              # Shows all commands
tx sys <TAB>          # Shows sys subcommands
tx net <TAB>          # Shows net subcommands
```

Completion file: `/data/data/com.termux/files/usr/share/tx/completion/tx-completion.bash` (Termux)

---

## 📁 Project Structure

```
termux-tx/
├── tx                        # Main executable (entry point)
├── install.sh                # One-command installer
├── uninstall.sh              # Clean removal
├── config/
│   └── tx.conf               # Default configuration template
├── completion/
│   └── tx-completion.bash    # Bash tab completion
└── lib/
    ├── colors.sh             # ANSI color definitions
    ├── core.sh               # Core utilities (logging, spinner, progress, confirm, deps)
    ├── banner.sh             # ASCII banner with tips
    ├── sys.sh                # System information (CPU, RAM, disk, battery, sensors)
    ├── net.sh                # Network tools (DNS, geoip, scan, speed, sniff)
    ├── scan.sh               # Port scanning (quick, full, vuln, stealth, OS)
    ├── osint.sh              # OSINT recon (domain, email, social, breach, shodan)
    ├── exploit.sh            # Exploit helpers (revshells, LFI, SQLi, XSS)
    ├── payload.sh            # Payload generator (android, windows, linux, stagers)
    ├── crypto.sh             # Encryption, hashing, encoding (AES, Base64, XOR)
    ├── anon.sh               # Anonymity (Tor, proxy, MAC spoof, DNS-over-HTTPS)
    ├── wf.sh                 # WiFi audit (scan, deauth, handshake, crack)
    ├── phish.sh              # Phishing framework (server, pages, tunnels)
    ├── forensic.sh           # Forensics (timeline, metadata, strings, hex)
    ├── pkg.sh                # Package manager wrapper (apt, pacman, dnf)
    ├── fs.sh                 # File system tools (du, tree, perms, checksum)
    ├── proc.sh               # Process manager (ps, top, kill, service)
    ├── backup.sh             # Backup & restore (home, apps, SMS, configs)
    ├── termux.sh             # Termux API (toast, battery, camera, SMS, sensors)
    ├── theme.sh              # Themes & fonts (Dracula, Cyberpunk, Hacker, etc.)
    ├── mirror.sh             # Mirror speed test & selector
    ├── secure.sh             # Security audit (SUID, SSH, firewall, malware)
    ├── motd.sh               # Login banner (ASCII art, quotes)
    ├── alias.sh              # Power aliases deployer
    └── auto.sh               # Automation (tasks, watch, monitor, cleanup)
```

---

## 🔧 Requirements

### Minimum
- **bash** >= 4.0 (most systems have this)
- **curl** (auto-installed by installer)
- **git** (auto-installed by installer)

### Optional (for extended features)
| Feature | Package |
|---------|---------|
| Port scanning with nmap | `nmap` |
| Packet capture | `tcpdump` |
| Speed test | `speedtest-cli` |
| Payload generation | `metasploit` |
| WHOIS lookups | `whois` |
| DNS tools | `dnsutils` (dig, nslookup) |
| SSL/TLS | `openssl` |
| WiFi audit | `aircrack-ng`, `iw` |
| File recovery | `foremost` |
| Firmware analysis | `binwalk` |
| Tor anonymity | `tor` |
| Termux API | `termux-api` |
| GPG encryption | `gnupg` |

TX will prompt to install missing dependencies when needed.

---

## ❌ Uninstall

### Quick Uninstall
```bash
tx update          # Get latest uninstaller
# Or use the local one:
bash /data/data/com.termux/files/usr/share/tx/uninstall.sh
```

### Manual Uninstall
```bash
rm -rf /data/data/com.termux/files/usr/share/tx  # Remove TX files
rm /data/data/com.termux/files/usr/bin/tx        # Remove symlink
rm -rf ~/.tx                                      # Remove configs/backups
```

---

## ⚠️ Legal Disclaimer

```
╔══════════════════════════════════════════════════════════════╗
║  THIS TOOL IS FOR AUTHORIZED SECURITY TESTING AND          ║
║  EDUCATIONAL PURPOSES ONLY.                                ║
║                                                            ║
║  Users are solely responsible for complying with all       ║
║  applicable local, state, national, and international laws.║
║                                                            ║
║  Unauthorized access to computer systems is illegal.       ║
║  The author assumes no liability for misuse.               ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 📞 Contact & Links

- **GitHub Repository:** [github.com/Adhi-hub07/termux-tx](https://github.com/Adhi-hub07/termux-tx)
- **Issues & Feature Requests:** [Open an Issue](https://github.com/Adhi-hub07/termux-tx/issues)
- **Author:** Adhi-hub07

---

## ⭐ Show Your Support

If you find TX useful, give it a star on GitHub ⭐

---

**Made with ⚡ for the cybersecurity community**

```
TX > /dev/null 2>&1 && echo "The terminal is yours."
```
