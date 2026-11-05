# 03 — Build the OPNsense Firewall (fw01)

## Step 1 — Create the VM

VirtualBox → **New**:

| Setting | Value |
|---|---|
| Name | `fw01` |
| Type / Version | BSD / FreeBSD (64-bit) |
| Memory | 2048 MB (raise to 3072 MB later if you enable Suricata) |
| Processors | 2 |
| Disk | 20 GB, VDI, dynamically allocated |

Then open **Settings → Network** and set the adapters **in this exact order**:

| Adapter | Attached to | Name | OPNsense will call it |
|---|---|---|---|
| 1 | NAT Network | `lab-wan` | `em0` → WAN |
| 2 | Host-only Adapter | (your host-only adapter) | `em1` → LAN, renamed MGMT |
| 3 | Internal Network | `lab-users` | `em2` → USERS |
| 4 | Internal Network | `lab-dmz` | `em3` → DMZ |

For adapters 3 and 4, under **Advanced**, set **Promiscuous Mode: Allow VMs**. Suricata needs this
later. Write down each adapter's **MAC address**, because you will match them in Step 3.

Settings → **Storage** → empty optical drive → choose the extracted OPNsense `.iso`.

## Step 2 — Install

1. Start the VM. At the login prompt use user `installer`, password `opnsense`.
2. Pick your keyboard, then **Install (UFS)**, then select the 20 GB disk.
3. Set a **strong root password**. Store it in a password manager, **never** in the repo.
4. When finished, remove the ISO (Devices → Optical Drives → Remove disk) and reboot.

## Step 3 — Assign interfaces (console menu)

Log in as `root`. Choose **option 1) Assign interfaces**:

- Configure LAGGs? **No**. Configure VLANs? **No**.
- WAN = `em0`, LAN = `em1`, Optional 1 = `em2`, Optional 2 = `em3`.

**Check the MACs:** the console shows each interface's MAC address. Compare them with the VirtualBox
adapters. A swapped interface is the most common first-day mistake.

## Step 4 — Set the LAN (management) address

Console **option 2) Set interface IP address** → choose LAN:

- IPv4 via DHCP? **No**. Address `10.10.99.1`, subnet bits `24`, no upstream gateway.
- IPv6: No. Enable DHCP server on LAN? **No**. Revert to HTTP? **No**.

**Why LAN = management:** OPNsense automatically adds an *anti-lockout rule* on LAN, so you can always
reach the web GUI from this network.

## Step 5 — Run the setup wizard from your laptop

Open `https://10.10.99.1` in your Windows browser. Accept the certificate warning (it's a self-signed
certificate, which is normal for a lab). Log in as `root`.

| Wizard page | Value |
|---|---|
| Hostname / Domain | `fw01` / `lab.local` |
| DNS servers | leave empty (use DHCP from WAN) |
| Time zone | Asia/Kolkata (or yours) |
| WAN type | DHCP |
| **Block RFC1918 private networks** | **untick** |
| **Block bogon networks** | **untick** |
| LAN IP | 10.10.99.1 / 24 (already set) |

**Why untick the two WAN boxes:** our "internet" (10.0.50.0/24) is itself a private range. With
"Block private networks" ticked, the firewall would drop replies coming from it. This is a classic
interview question.

## Step 6 — Name and enable the zones

**Interfaces → Assignments**: click LAN and set Description `MGMT`. Then:

| Interface | Description | Enable | IPv4 type | Address |
|---|---|---|---|---|
| OPT1 (`em2`) | USERS | ✔ | Static IPv4 | 10.10.10.1 / 24 |
| OPT2 (`em3`) | DMZ | ✔ | Static IPv4 | 10.10.20.1 / 24 |

Click **Save** and then **Apply changes** each time.

## Step 7 — DHCP for USERS

Recent OPNsense versions offer **Dnsmasq** (or Kea / ISC DHCP on older ones) under **Services**. Use
whichever your version shows as the default:

- Interface **USERS**, range `10.10.10.100` – `10.10.10.199`.

**Why:** Kali gets an address automatically, like a staff laptop would.

## Step 8 — Disable hardware offloading

**Interfaces → Settings**: make sure **Hardware CRC**, **Hardware TSO** and **Hardware LRO** are all
**disabled** (ticked "disable"). Save and reboot when asked.

**Why:** offloading on virtual NICs can corrupt what Suricata sees, and can break traffic in IPS mode.

## Step 9 — Admin access only from MGMT

**System → Settings → Administration**: set **Listen Interfaces** to `MGMT` only. If you enable SSH
on the firewall, do the same there.

## Step 10 — Firewall rules

Apply the rule set in [`../configurations/opnsense/firewall-rules.md`](../configurations/opnsense/firewall-rules.md).

## Step 11 — Back up the config (out of git!)

**System → Configuration → Backups → Download configuration.** Keep the XML file on your laptop.
It contains password hashes, so the `.gitignore` already blocks `*.xml` exports in `configurations/opnsense/`.

## Verification

| Test | Expected result |
|---|---|
| **Interfaces → Overview** | WAN has a 10.0.50.x address; MGMT, USERS and DMZ are up with the addresses above |
| From Kali (after creating it): `ip a` | an address in 10.10.10.100–199 |
| From Kali: `ping -c 3 10.10.10.1` | replies |
| From Kali: `sudo apt update` | works (NAT out through the WAN works) |
| From Kali browser: `https://10.10.10.1` | **does not** load (GUI is MGMT-only) |

Screenshots: `screenshots/02-opnsense-interfaces-overview.png`, `screenshots/03-opnsense-firewall-rules-users.png`,
`screenshots/04-opnsense-firewall-rules-dmz.png`.

## Create the Kali VM

VirtualBox → **File → Import Appliance** (or Add for a `.vbox` image) → choose the Kali VirtualBox
image. Then set: 2 vCPU, 2048 MB RAM, **one** adapter on Internal Network `lab-users`. Default login
is shown on the Kali download page. Change the password after the first login (`passwd`).
