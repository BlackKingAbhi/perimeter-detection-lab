# 09 — Resume Entry, Interview Questions and Demo Script

## Resume entry

**Small Office Network Security & Monitoring Lab** | OPNsense, Wazuh, Suricata, Ubuntu, Kali Linux, VirtualBox
*(Fill in the bracketed numbers from your real results. Do not add this to your resume until the lab works.)*

- Designed a segmented virtual network (USERS, DMZ, MGMT zones) behind an OPNsense firewall with a
  least-privilege, default-deny rule set, and documented the IP plan and rule rationale.
- Deployed an Nginx web server on Ubuntu Server 24.04 in a DMZ and hardened SSH to key-only access.
- Deployed Wazuh SIEM with agents collecting authentication and web logs; wrote and tested a custom
  rule mapped to MITRE ATT&CK T1110.001 that detected [N] repeated SSH failures within [X] seconds.
- Ran controlled Nmap scans and failed-login simulations inside the isolated lab, and wrote [2]
  incident reports covering detection, investigation, verdict and recommended response.
- *(If done)* Integrated Suricata IDS on the DMZ interface and explained why only the DMZ is set as the home network.

## Interview questions (with short model answers)

1. **Why did you split the network into zones? Why not one flat network?**
   Segmentation limits lateral movement. If a user laptop is compromised, the firewall only lets it
   reach the web server on ports 80/443. It can't reach management interfaces or other systems.

2. **What is a DMZ, and why is the web server in it?**
   A DMZ is a separate zone for servers that others connect to. They are the most exposed, so
   isolating them means a compromised server can't reach staff machines (DMZ → USERS is denied).

3. **How does OPNsense decide whether to allow a packet?**
   Rules are checked on the interface where traffic enters, top to bottom, and the first match wins.
   Anything not explicitly allowed is dropped. It is stateful, so return traffic is allowed automatically.

4. **Why did you untick "Block private networks" on the WAN?**
   The lab's "internet" uses 10.0.50.0/24, a private range. With that option on, the firewall would
   drop legitimate traffic from its own upstream network.

5. **How does a Wazuh agent get logs to the manager, and what had to be open on the firewall?**
   The agent reads local log files such as `/var/log/auth.log` and sends them over TCP 1514
   (registration on 1515). I allowed only web01 → wazuh01 on those ports from the DMZ.

6. **Explain your custom rule 100100 line by line.**
   It triggers on built-in rule 5760 (SSH authentication failed). `frequency=5` and `timeframe=60`
   mean it fires on 5 failures in 60 seconds, and `same_srcip` means they must come from one IP.
   Level 10 makes it high severity, and it is tagged with MITRE T1110.001. I tested it with `wazuh-logtest` before deploying it.

7. **After the failed-login alert, how did you confirm the attacker didn't get in?**
   I searched web01's `/var/log/auth.log` for `Accepted` entries from the source IP after the
   failures. There were none, so the verdict was "true positive, unsuccessful attempt".

8. **Why can a port scan be hard to see in a host-based SIEM, and how did you address that?**
   A scan mostly touches closed or filtered ports, which create no application log on the host. You see it
   at the network layer instead, in firewall block logs or an IDS like Suricata.

9. **IDS vs IPS? Why did you run Suricata in IDS mode?**
   An IDS alerts and an IPS also blocks inline. I used IDS mode to learn the alerts and tune false
   positives first. Blocking with untuned rules can break legitimate traffic.

10. **What would you improve in a real deployment?**
    Key-only SSH everywhere, MFA on admin interfaces, central NTP, automated response after tuning,
    TLS on the web server, longer log retention, and alerts sent to a ticketing system.

## Demo script (about 3 minutes)

| Time | Show | Say |
|---|---|---|
| 0:00 | Topology diagram | "This is a small office network with three zones behind an OPNsense firewall: users, DMZ and management." |
| 0:20 | OPNsense rules (USERS tab) | "Users can reach only the website on 80/443. Everything else internal is blocked and logged." |
| 0:45 | Kali: `curl http://10.10.20.10` | "The website works from the user zone…" |
| 1:00 | Kali: `sudo nmap -sV 10.10.20.10` + Live View | "…but a scan only finds the web port. The firewall log shows the blocked probes." |
| 1:30 | Failed SSH attempts (from the allowed test path) | "Now I simulate password guessing by typing wrong passwords several times." |
| 1:50 | Wazuh: rule 5760 alerts → rule 100100 | "Wazuh raises an alert for each failure, then my custom rule fires once there are five from one IP in a minute, mapped to MITRE T1110." |
| 2:20 | web01: `grep Accepted /var/log/auth.log` | "During investigation I confirm there was no successful login, so it's a true positive but an unsuccessful attempt." |
| 2:40 | Incident report | "I documented it with a timeline, evidence, verdict, and recommendations such as key-only SSH." |
