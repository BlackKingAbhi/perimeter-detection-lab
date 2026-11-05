# Small Office Network Security & Monitoring Lab

A beginner-friendly, single-laptop security lab: an **OPNsense** firewall segments a small office
network into USERS, DMZ and MGMT zones; an **Ubuntu** web server sits in the DMZ; **Wazuh** collects
and analyses logs; **Kali Linux** is used for controlled tests (Nmap scans and failed SSH logins)
**only against lab machines**; **Suricata** IDS is optional.

> **Project status:** 📝 Documentation and configurations written. Lab build **not yet verified**.
> Each item below is ticked only after it has been tested and evidenced with screenshots.

<!-- Add after the build: ![Topology](diagrams/topology.png) -->

## Topology

```
                 Internet (NAT Network lab-wan, 10.0.50.0/24)
                                  |
                          [ fw01 — OPNsense ]
            +---------------------+---------------------+
            |                     |                     |
     USERS 10.10.10.0/24    DMZ 10.10.20.0/24     MGMT 10.10.99.0/24
     kali01 (DHCP)          web01 .10              wazuh01 .10
                            nginx + SSH            laptop browser .2
```

All traffic between zones crosses the firewall, where it can be allowed, blocked and logged.

## What I built

- [ ] Segmented network with a default-deny, least-privilege OPNsense rule set ([rules](configurations/opnsense/firewall-rules.md))
- [ ] Nginx web server in a DMZ, with SSH hardened to key-only after testing
- [ ] Wazuh all-in-one SIEM with an agent on web01 (and optionally on the firewall)
- [ ] Custom Wazuh rule for repeated SSH failures, mapped to MITRE ATT&CK T1110.001 ([rule](detection-rules/local_rules.xml))
- [ ] Controlled tests with written incident reports ([reports](reports/))
- [ ] *(Optional)* Suricata IDS on the DMZ interface

## Tools and versions

| Component | Role | Version (fill in from the build) |
|---|---|---|
| Oracle VirtualBox | Hypervisor | 7.x |
| OPNsense | Firewall / router / IDS host | |
| Ubuntu Server | web01, wazuh01 | 24.04 LTS |
| Nginx | Web server | |
| Wazuh | SIEM (manager, indexer, dashboard, agent) | 4.x |
| Kali Linux | Testing workstation | |
| Suricata | IDS (optional, built into OPNsense) | |

## Resource plan (16 GB RAM laptop)

| VM | vCPU | RAM | Disk |
|---|---|---|---|
| fw01 | 2 | 2 GB (3 GB with Suricata) | 20 GB |
| web01 | 1 | 1 GB | 15 GB |
| wazuh01 | 2–4 | 5–6 GB | 50 GB |
| kali01 | 2 | 2 GB | image default |

The peak is about 10–12 GB with everything running. VMs don't all need to run at once; see
[01-architecture.md](docs/01-architecture.md#you-do-not-need-everything-running-at-once).
Note that wazuh01 runs below Wazuh's official recommendation of 4 vCPU and 8 GB, which is fine for a 2-agent lab.

## Detection results

| Test | MITRE | Expected detection | Result |
|---|---|---|---|
| Nmap host discovery and service scan | T1046 | Firewall block log, Suricata (optional) | ⬜ not yet run |
| Repeated failed SSH logins (manual) | T1110.001 | Wazuh 5760/5710 → custom 100100 | ⬜ not yet run |
| IDS test page (optional) | — | Suricata attack-response rule | ⬜ not yet run |

Full details are in [detection-coverage.md](reports/detection-coverage.md).

## Repository structure

```
├── README.md
├── docs/               Step-by-step guides (01–09), build log, host record
├── configurations/     Firewall rules, interfaces, nginx, SSH and Wazuh agent configs
├── scripts/            Read-only helper scripts (baseline, connectivity check, Wazuh health)
├── detection-rules/    Custom Wazuh rules + test samples
├── reports/            Attack log, detection coverage, incident reports, evidence
├── screenshots/        Evidence screenshots (checklist inside)
└── diagrams/           Topology diagram
```

## How to reproduce

1. [Architecture, IP plan and resources](docs/01-architecture.md)
2. [Prepare Windows and VirtualBox](docs/02-virtualbox-setup.md)
3. [Build the OPNsense firewall](docs/03-opnsense-setup.md) → [apply the rules](configurations/opnsense/firewall-rules.md)
4. [DMZ web server](docs/04-ubuntu-web-server.md)
5. [Wazuh SIEM and agents](docs/05-wazuh-setup.md)
6. [Suricata IDS (optional)](docs/06-suricata-optional.md)
7. [Testing procedure](docs/07-testing-procedure.md)
8. [Troubleshooting](docs/08-troubleshooting.md)
9. [Interview prep and demo script](docs/09-interview-prep.md)

## What broke and how I fixed it

See [docs/build-log.md](docs/build-log.md). *(To be filled in during the build.)*

## Limitations (stated honestly)

- Single-laptop lab with simulated users and very little traffic.
- Wazuh runs below its recommended resources.
- Suricata uses free ET Open rules only, in alert-only mode, with no TLS inspection.
- No automated blocking, VPN or high availability. These are deliberately out of scope for this beginner version.
- Short monitoring window, so alert tuning is minimal.

## Safety and ethics

All testing targets only VMs inside isolated VirtualBox internal networks that I own and control.
No real systems or third-party networks are scanned or accessed. Secrets and raw firewall
config exports are never committed (see `.gitignore`).
