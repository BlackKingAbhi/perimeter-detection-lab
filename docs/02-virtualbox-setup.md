# 02 — Prepare Windows and VirtualBox

## Step 1 — Check virtualisation is enabled

1. Press `Ctrl + Shift + Esc` → **Performance** tab → **CPU**.
2. Look for **Virtualization: Enabled**.
3. If it says Disabled, reboot into the BIOS/UEFI (often `F2` or `Del` at boot) and enable **SVM Mode** (that is AMD's name for AMD-V).

**Why:** VirtualBox needs hardware virtualisation to run 64-bit VMs at a usable speed.

**Common problem:** VMs are extremely slow or show a green turtle icon in the status bar. This means
Windows Hyper-V is in use. Open PowerShell **as Administrator** and check:

```powershell
# Shows whether the hypervisor is set to launch at boot
bcdedit /enum | findstr -i hypervisorlaunchtype
```

If you do not need WSL2, Docker Desktop or Windows Sandbox, you can turn it off and reboot:

```powershell
# Stop the Windows hypervisor from starting at boot (reversible: set it back to auto)
bcdedit /set hypervisorlaunchtype off
```

Write down what you found in `docs/build-log.md`.

## Step 2 — Install VirtualBox

Download the current **7.x** release for Windows hosts from <https://www.virtualbox.org/wiki/Downloads>
and install with the default options.

## Step 3 — Download the images (and verify them)

| Software | Where | Notes |
|---|---|---|
| OPNsense | <https://opnsense.org/download/> | Choose **amd64** and image type **dvd**. It downloads as `.iso.bz2`; extract it with 7-Zip. |
| Ubuntu Server 24.04 LTS | <https://ubuntu.com/download/server> | Used for web01 and wazuh01. |
| Kali Linux | <https://www.kali.org/get-kali/#kali-virtual-machines> | Choose the pre-built **VirtualBox** image (faster than installing from ISO). |

**Verify the checksum** (proves the file was not corrupted or tampered with). In PowerShell:

```powershell
# Prints the SHA-256 hash of the file; compare it with the one on the download page
Get-FileHash .\ubuntu-24.04.x-live-server-amd64.iso -Algorithm SHA256
```

Record each hash and "matches: yes" in `docs/build-log.md`.

## Step 4 — Create the lab networks

Open VirtualBox → **File → Tools → Network Manager**.

### 4a. NAT Network (our fake "internet")

- Tab **NAT Networks** → **Create**.
- Name: `lab-wan`, IPv4 prefix: `10.0.50.0/24`, **Enable DHCP: on**.

**Why a NAT Network and not plain NAT:** a NAT Network is a small shared network with internet access.
It behaves like a real ISP connection for the firewall's WAN port.

### 4b. Host-only network (MGMT)

- Tab **Host-only Networks** → **Create**.
- Adapter: **Configure Adapter Manually**, IPv4 address `10.10.99.2`, mask `255.255.255.0`.
- **DHCP Server: off** (tab DHCP Server → untick Enable Server).

**Why:** this gives your Windows laptop the address 10.10.99.2 on the management network, so your normal
browser can open the firewall and Wazuh web pages. DHCP is off because the addresses are static.

### 4c. Internal networks (USERS and DMZ)

Nothing to create. Internal networks exist as soon as you type a name (`lab-users`, `lab-dmz`) into a
VM's network adapter. They have **no** connection to your laptop or the internet, so only the firewall
can route them.

## Verification

- [ ] Task Manager shows virtualisation enabled.
- [ ] Network Manager shows the `lab-wan` NAT network and one host-only network.
- [ ] In PowerShell, `ipconfig` shows a "VirtualBox Host-Only" adapter with `10.10.99.2`.
- [ ] Checksums are recorded in the build log.

Screenshot to save: `screenshots/01-virtualbox-network-manager.png`
