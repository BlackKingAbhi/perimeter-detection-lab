# 01 — Architecture, IP Plan and Resource Allocation

> Read this first. Engineers plan the addresses and the resources **before** they build anything.

## 1. What we are building (in one paragraph)

A small office network in VirtualBox. An **OPNsense firewall** sits in the middle and splits the
network into separate zones. A **Kali Linux** "staff laptop" lives in the USERS zone, an **Ubuntu web
server** lives in the DMZ, and a **Wazuh** server lives in the MGMT (management) zone. Every packet
between zones must pass through the firewall, so the firewall can allow, block and log it. Wazuh
collects logs from the web server (and optionally from the firewall) and raises alerts when it sees
suspicious activity such as a port scan or repeated failed SSH logins.

## 2. Network topology

```
                         Internet (through your laptop)
                                    |
                     VirtualBox "NAT Network": lab-wan  10.0.50.0/24
                                    |
                              em0 (WAN, DHCP)
                       +-----------------------------+
                       |        fw01 (OPNsense)      |
                       |  firewall + router + (IDS)  |
                       +--+------------+----------+--+
                 em2      |        em3 |          | em1
          10.10.10.1/24   |  10.10.20.1/24        | 10.10.99.1/24
                          |            |          |
   Internal net "lab-users"   Internal net "lab-dmz"   Host-only network (MGMT)
                          |            |          |
                   +------+---+  +-----+----+  +--+-----------+   your Windows laptop
                   |  kali01  |  |  web01   |  |  wazuh01     |   10.10.99.2 (browser
                   | DHCP .100|  | .10      |  |  .10 (SIEM)  |   for the GUIs)
                   | -.199    |  | nginx+SSH|  |              |
                   +----------+  +----------+  +--------------+
```

A drawn version of this goes in `diagrams/topology.png` (draw it in draw.io / diagrams.net and save the
`.drawio` source file next to it).

### Why this design (be ready to say this in an interview)

| Decision | Reason |
|---|---|
| Three zones (USERS, DMZ, MGMT) instead of one flat network | **Segmentation.** If one zone is compromised, the firewall limits where the attacker can go next. |
| Web server in a **DMZ** | Servers that others connect to are the most exposed. Isolating them protects staff machines. |
| Kali is in USERS, not on the "internet" side | Models a compromised staff laptop. Its traffic to the DMZ **must** cross the firewall, so we can log and inspect it. |
| MGMT is a VirtualBox **host-only** network | Your Windows laptop becomes the admin workstation. You open the OPNsense and Wazuh web pages from your normal browser, and no extra VM is needed. |
| OPNsense (not pfSense) | Free, has a normal ISO download, has Suricata built in, and has an official Wazuh agent plugin. |

## 3. IP addressing plan

| Zone | VirtualBox network type & name | Subnet | Gateway | Hosts |
|---|---|---|---|---|
| WAN ("internet") | NAT Network `lab-wan` | 10.0.50.0/24 (VirtualBox DHCP) | 10.0.50.1 (VirtualBox) | fw01 WAN (DHCP) |
| MGMT | Host-only network | 10.10.99.0/24 | 10.10.99.1 | fw01 10.10.99.1, wazuh01 10.10.99.10, laptop 10.10.99.2 |
| USERS | Internal network `lab-users` | 10.10.10.0/24 | 10.10.10.1 | kali01 via DHCP (10.10.10.100–199) |
| DMZ | Internal network `lab-dmz` | 10.10.20.0/24 | 10.10.20.1 | web01 10.10.20.10 (static) |

**Beginner notes**

- `/24` means the first 3 numbers are the network and the last number is the host, so there are 254 usable addresses.
- The **gateway** is the router address a machine sends traffic to when the destination is outside its own subnet. Here, that is always the firewall.
- **Static** means you type the address in by hand (servers need a fixed address). **DHCP** means the firewall hands out an address automatically (fine for user laptops).

## 4. VM resource allocation (for a 16 GB RAM, Ryzen 5 laptop)

Windows 11 itself needs about **4–5 GB**. That leaves about **11 GB** for VMs.

| VM | OS | vCPU | RAM | Disk (dynamic) | Adapters, **in this order** |
|---|---|---|---|---|---|
| fw01 | OPNsense (current stable release) | 2 | 2 GB (3 GB with Suricata) | 20 GB | 1: NAT Network `lab-wan` · 2: Host-only · 3: Internal `lab-users` · 4: Internal `lab-dmz` |
| web01 | Ubuntu Server 24.04 LTS | 1 | 1 GB | 15 GB | 1: Internal `lab-dmz` |
| wazuh01 | Ubuntu Server 24.04 LTS | 2–4 | 5–6 GB | 50 GB | 1: Host-only |
| kali01 | Kali Linux (pre-built VirtualBox image) | 2 | 2 GB | (image default) | 1: Internal `lab-users` |

> Wazuh's official all-in-one recommendation is 4 vCPU and 8 GB RAM. On 16 GB we use 5–6 GB, which
> is enough for a 2-agent lab but is **below the official recommendation**, so state that in the README.
> If the dashboard is very slow, give wazuh01 6 GB and run fewer VMs at once (see below).

### You do NOT need everything running at once

| Lab stage | VMs running | Approx. RAM |
|---|---|---|
| Build firewall + web server | fw01, web01, kali01 | ~5 GB |
| Install Wazuh | fw01, wazuh01 | ~8 GB |
| Testing + detection (main demo) | fw01, web01, wazuh01, kali01 | ~10–11 GB |
| Suricata (optional) | same as above, fw01 at 3 GB | ~11–12 GB |

**Tips to save resources**

- Close Chrome tabs and other heavy apps during the full-lab stage.
- Use **dynamically allocated** disks so they only use real disk space as they fill.
- Start VMs in this order: fw01 → wazuh01 → web01 → kali01. Shut down in reverse.
- Use VirtualBox **headless start** (right-click → Start → Headless Start) for servers; you will SSH into them or use the web GUIs instead.

## 5. Traffic that must be allowed (final rule set)

Covered in detail in [`../configurations/opnsense/firewall-rules.md`](../configurations/opnsense/firewall-rules.md).

| From → To | Allow | Why |
|---|---|---|
| USERS → DMZ | TCP 80, 443 to web01 | Staff need the website, nothing else |
| USERS → MGMT | nothing | Staff must never reach admin interfaces |
| USERS → internet | DNS to firewall, TCP 80/443 | Normal browsing and updates |
| DMZ → MGMT | TCP 1514–1515 to wazuh01 only | Wazuh agent traffic |
| DMZ → USERS | nothing | A hacked server must not reach staff machines |
| DMZ → internet | DNS to firewall, NTP, TCP 80/443 | Updates and time sync |
| MGMT → anywhere | allowed | Admin access, including SSH to web01 |

## 6. Scope limits (deliberately kept small)

- No site-to-site VPN, no automatic blocking (active response), no high availability.
- Suricata is **optional** and in IDS (alert-only) mode.
- All testing is done only against VMs inside this isolated lab.
