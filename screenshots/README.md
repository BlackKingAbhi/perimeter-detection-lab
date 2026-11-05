# Screenshots / Evidence Checklist

Use these filenames so the README links work. Tick each item when the real screenshot is added.
Before committing, check no passwords, API keys or personal info are visible.

| ✓ | File | What it must show |
|---|---|---|
| ⬜ | `01-virtualbox-network-manager.png` | `lab-wan` NAT network and host-only network |
| ⬜ | `02-opnsense-interfaces-overview.png` | WAN, MGMT, USERS, DMZ up with correct IPs |
| ⬜ | `03-opnsense-firewall-rules-users.png` | USERS rule list |
| ⬜ | `04-opnsense-firewall-rules-dmz.png` | DMZ rule list |
| ⬜ | `05-web01-nginx-page-from-kali.png` | Lab web page loaded in Kali's browser |
| ⬜ | `06-wazuh-agents-active.png` | Agents page showing web01 (and fw01) Active |
| ⬜ | `07-wazuh-first-ssh-alert.png` | First failed-login alert |
| ⬜ | `08-suricata-alert-opnsense.png` | (Optional) Suricata alert in OPNsense |
| ⬜ | `09-suricata-alert-wazuh.png` | (Optional) Suricata alert in Wazuh |
| ⬜ | `10-nmap-scan-output.png` | Kali terminal with the Nmap results |
| ⬜ | `11-firewall-live-view-blocks.png` | Blocked scan packets in Live View |
| ⬜ | `12-wazuh-rule-100100-alert.png` | Custom rule 100100 alert with source IP |
| ⬜ | `13-web01-auth-log-failed.png` | `grep "Failed password"` output on web01 |
