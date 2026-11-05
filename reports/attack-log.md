# Attack Log (Ground Truth)

Everything run from Kali, with exact times. Compare this with what the SIEM detected.

| # | Test | Command(s) | Source IP | Target | Start (IST) | End (IST) | Notes |
|---|---|---|---|---|---|---|---|
| A1 | Host discovery | `sudo nmap -sn 10.10.20.0/24` | 10.10.10.___ | 10.10.20.0/24 | | | |
| A2 | Service scan | `sudo nmap -sV 10.10.20.10` | 10.10.10.___ | 10.10.20.10 | | | Ports found: |
| B1 | Failed SSH logins (manual, ×6) | `ssh admin01@10.10.20.10` (wrong password) | 10.10.10.___ | 10.10.20.10 | | | Any success? (must be no) |
| C1 | IDS test page (optional) | `curl http://testmynids.org/uid/index.html` (on web01) | 10.10.20.10 | external | | | |
