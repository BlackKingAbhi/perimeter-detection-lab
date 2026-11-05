# 08 — Troubleshooting Common Problems

Work from the bottom of the stack up: **VM powered on → cable/adapter → IP address → gateway → firewall rule → service**.

## VirtualBox and the host

| Symptom | Likely cause | Fix |
|---|---|---|
| VM won't start: "VT-x/AMD-V is not available" | Virtualisation off in the BIOS | Enable SVM Mode in the BIOS/UEFI |
| VMs very slow, turtle icon in the status bar | Hyper-V in use | `bcdedit /set hypervisorlaunchtype off` (admin PowerShell), then reboot. Note the impact on WSL2/Docker. |
| Laptop freezes, heavy disk activity | RAM over-committed | Run fewer VMs (see the table in 01-architecture.md); lower wazuh01 to 5 GB only if needed |
| Host-only network missing | Adapter not created | File → Tools → Network Manager → Host-only Networks → Create |

## OPNsense

| Symptom | Likely cause | Fix |
|---|---|---|
| Can't open `https://10.10.99.1` | Wrong interface mapping, or laptop host-only IP not 10.10.99.2 | Compare MACs at the console; run `ipconfig` on Windows |
| WAN has no IP | Adapter 1 not on `lab-wan` NAT Network | Fix the adapter; console option 2 → WAN → DHCP |
| Clients have no internet, but the firewall can ping out | Missing pass rule, or "Block private networks" still on WAN | Check the rules; untick both WAN block options |
| Kali gets no IP (169.254.x.x) | DHCP not enabled on USERS, or Kali's adapter on the wrong network | Enable DHCP on USERS; Kali adapter = Internal `lab-users` |
| Rule doesn't seem to work | Rule on the wrong interface, or wrong order (first match wins) | Rules go on the interface traffic **enters**; drag to reorder; **Apply** |
| See what is being blocked | — | Firewall → Log Files → Live View (enable **Log** on block rules) |

## Ubuntu (web01 / wazuh01)

| Symptom | Command to diagnose | Fix |
|---|---|---|
| No network | `ip a`, `ip route`, `cat /etc/netplan/*.yaml` | Fix the netplan file, then `sudo netplan apply` |
| DNS fails, but `ping 1.1.1.1` works | `resolvectl status` | DNS server must be the firewall's address in that zone |
| `apt update` hangs | `curl -I http://archive.ubuntu.com` | Allow TCP 80/443 out for that zone |
| Nginx not reachable | `systemctl status nginx`, `sudo ss -tlnp \| grep :80` | `sudo systemctl enable --now nginx`; check the USERS→DMZ rule |
| `nginx -t` fails | Read the error line number | Fix the typo in the named file |

Example netplan for web01 (`/etc/netplan/50-cloud-init.yaml`, YAML is indentation-sensitive, use spaces only):

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses: [10.10.20.10/24]
      routes:
        - to: default
          via: 10.10.20.1
      nameservers:
        addresses: [10.10.20.1]
```

## Wazuh

| Symptom | Diagnose | Fix |
|---|---|---|
| Dashboard won't load | `systemctl status wazuh-dashboard wazuh-indexer` | Wait 2–3 min after boot; give the VM more RAM; check `free -h` |
| Indexer keeps crashing | `sudo journalctl -u wazuh-indexer -n 50` | Usually low memory. Raise RAM or close other VMs. |
| Agent "Never connected" | On the agent: `sudo tail /var/ossec/logs/ossec.log`; `nc -zv 10.10.99.10 1514` | Allow DMZ→WAZUH01 TCP 1514–1515; check the manager IP in the agent's ossec.conf |
| Agent registration rejected | Compare versions | Agent version must be ≤ manager version |
| No SSH alerts | On web01: `sudo grep auth.log /var/ossec/etc/ossec.conf` | Add the auth.log `<localfile>` block; restart the agent |
| Custom rule not firing | `sudo /var/ossec/bin/wazuh-logtest` | Check XML syntax (`sudo /var/ossec/bin/wazuh-analysisd -t`), rule ID range, restart the manager |
| Manager won't restart after a rule change | `sudo /var/ossec/bin/wazuh-analysisd -t` | Shows the XML error; fix it and restart |

## Time problems

Events appear at the wrong time in Wazuh → run `timedatectl` on every VM. All should show the same
time zone and `System clock synchronized: yes`. Make sure the DMZ allows UDP 123 (NTP).

**Write every problem you hit and how you fixed it in `docs/build-log.md`.** Interviewers love real troubleshooting stories.
