# Build Log

Dated notes written **while** building. Record what you did, what broke, and how you fixed it.
This becomes your troubleshooting story for interviews.

| Date | Phase | What I did | Problem | Fix / lesson |
|---|---|---|---|---|
| YYYY-MM-DD | Prep | Installed VirtualBox 7.x; virtualisation enabled: yes/no | | |
| YYYY-MM-DD | Prep | Checksums: OPNsense ✅/❌, Ubuntu ✅/❌, Kali ✅/❌ | | |
| | Firewall | | | |
| | Web server | | | |
| | Wazuh | | | |
| | Suricata (optional) | | | |
| | Testing | | | |

## Software versions used (fill in from the actual VMs)

| Component | Version | How I checked |
|---|---|---|
| VirtualBox | | Help → About |
| OPNsense | | Dashboard → System information |
| Ubuntu Server | 24.04.x | `lsb_release -a` |
| Nginx | | `nginx -v` |
| OpenSSH | | `ssh -V` |
| Wazuh manager | | `sudo /var/ossec/bin/wazuh-control info` |
| Wazuh agent (web01) | | same command on web01 |
| Kali Linux | | `cat /etc/os-release` |
| Nmap | | `nmap --version` |
| Suricata (optional) | | OPNsense → Intrusion Detection |
