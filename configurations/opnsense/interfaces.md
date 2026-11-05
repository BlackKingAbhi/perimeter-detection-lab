# OPNsense Interface Assignments (fw01)

| VirtualBox adapter | Attached to | FreeBSD name | OPNsense name | Description | IPv4 | DHCP server |
|---|---|---|---|---|---|---|
| Adapter 1 | NAT Network `lab-wan` | em0 | WAN | WAN | DHCP (10.0.50.x) | — |
| Adapter 2 | Host-only | em1 | LAN | MGMT | 10.10.99.1/24 | off |
| Adapter 3 | Internal `lab-users` | em2 | OPT1 | USERS | 10.10.10.1/24 | on, .100–.199 |
| Adapter 4 | Internal `lab-dmz` | em3 | OPT2 | DMZ | 10.10.20.1/24 | off |

WAN options: "Block private networks" **off**, "Block bogon networks" **off** (lab WAN is private address space).
Web GUI / SSH listen interface: **MGMT only**.

Fill in after the build (MAC addresses help you prove the mapping is correct):

| FreeBSD name | MAC address (from VirtualBox) | Verified matches console? |
|---|---|---|
| em0 | | ⬜ |
| em1 | | ⬜ |
| em2 | | ⬜ |
| em3 | | ⬜ |
