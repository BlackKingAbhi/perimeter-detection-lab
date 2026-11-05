# OPNsense Firewall Rules (hand-copied, sanitised)

> We publish a hand-written copy of the rules, **not** the raw config export. The raw XML export
> contains password hashes and certificates.

## How OPNsense evaluates rules (learn this)

1. Rules are applied on the interface where traffic **enters** the firewall. So "USERS → DMZ" rules go on the **USERS** tab.
2. Rules are checked **top to bottom**. The **first match wins**.
3. Anything that does not match a pass rule is **dropped** (default deny).
4. Rules are **stateful**: once a connection is allowed, its reply traffic is allowed automatically.

## Aliases (Firewall → Aliases)

Aliases are named groups of addresses or ports. They make rules readable and easy to change.

| Name | Type | Content |
|---|---|---|
| `WEB01` | Host(s) | 10.10.20.10 |
| `WAZUH01` | Host(s) | 10.10.99.10 |
| `WEB_PORTS` | Port(s) | 80, 443 |
| `WAZUH_PORTS` | Port(s) | 1514, 1515 |
| `RFC1918` | Network(s) | 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 |

## Rules on the USERS interface

| # | Action | Proto | Source | Destination | Port | Description |
|---|---|---|---|---|---|---|
| 1 | Pass | TCP/UDP | USERS net | This Firewall | 53 | DNS to firewall |
| 2 | Pass | TCP | USERS net | WEB01 | WEB_PORTS | Staff can open the website |
| 3 | Block (log) | any | USERS net | RFC1918 | any | No other internal access (incl. MGMT) |
| 4 | Pass | TCP | USERS net | any | WEB_PORTS | Browsing / updates to the internet |

Rule 3 comes **before** rule 4, so "any destination on 80/443" cannot be used to reach internal hosts.
Tick **Log** on the block rule, so blocked attempts show in **Firewall → Log Files → Live View**.

## Rules on the DMZ interface

| # | Action | Proto | Source | Destination | Port | Description |
|---|---|---|---|---|---|---|
| 1 | Pass | TCP/UDP | DMZ net | This Firewall | 53 | DNS to firewall |
| 2 | Pass | UDP | DMZ net | any | 123 | NTP time sync |
| 3 | Pass | TCP | WEB01 | WAZUH01 | WAZUH_PORTS | Wazuh agent → manager |
| 4 | Block (log) | any | DMZ net | RFC1918 | any | DMZ must not reach USERS/MGMT |
| 5 | Pass | TCP | DMZ net | any | WEB_PORTS | OS updates |

## Rules on the MGMT interface

| # | Action | Proto | Source | Destination | Port | Description |
|---|---|---|---|---|---|---|
| — | (Anti-lockout, automatic) | TCP | any | MGMT address | 443, 80 | Always keep GUI access |
| 1 | Pass | any | MGMT net | any | any | Admin network can reach everything |

## Rules on WAN

No pass rules. All unsolicited inbound traffic from the "internet" is dropped by default.

## Optional: a temporary "as-found" policy for comparison

For a before/after story, you can **first** run the tests with a single `pass any → any` rule on USERS
and DMZ, record the results, then replace it with the rules above and repeat. If you do this, write
the results in `reports/before-after.md`. Only record what actually happened.

## Verification

| From | Command | Expected |
|---|---|---|
| kali01 | `curl -I http://10.10.20.10` | `HTTP/1.1 200 OK` |
| kali01 | `nc -zv -w 3 10.10.20.10 22` | timed out / fails (SSH not allowed from USERS) |
| kali01 | `ping -c 2 10.10.99.10` | no reply |
| web01 | `nc -zv -w 3 <kali-ip> 22` (Kali's 10.10.10.x address) | fails (DMZ → USERS blocked) |
| laptop (MGMT) | `ssh admin01@10.10.20.10` | works |
| OPNsense Live View | | block entries for the denied tests above |

> Note: with these final rules, Kali **cannot** reach SSH on web01. For the failed-login test in
> `docs/07-testing-procedure.md`, run that test either before tightening the rules, or from your
> laptop on MGMT. The procedure explains both options.
