# 04 — DMZ Web Server (web01: Ubuntu Server 24.04 + Nginx + SSH)

## Step 1 — Create the VM

| Setting | Value |
|---|---|
| Name | `web01` |
| Type | Linux / Ubuntu (64-bit) |
| Memory / CPU | 1024 MB / 1 vCPU |
| Disk | 15 GB, dynamically allocated |
| Network | Adapter 1: Internal Network `lab-dmz` |
| Optical drive | Ubuntu Server 24.04 ISO |

## Step 2 — Install Ubuntu Server

Go through the installer with the defaults, except for these settings:

- **Network** → edit `enp0s3` → IPv4 **Manual**:
  - Subnet `10.10.20.0/24`, Address `10.10.20.10`, Gateway `10.10.20.1`, Name servers `10.10.20.1`.
- **Profile**: name `admin01`, server name `web01`, and a long password (store it in a password manager).
- **SSH**: tick **Install OpenSSH server**.
- Featured snaps: none.

Reboot and remove the ISO when asked.

> The firewall must already be running, or the installer cannot reach the Ubuntu mirrors. If the
> mirror test fails, check that DMZ rule 5 (TCP 80/443 out) exists and that fw01 is up.

## Step 3 — Update and install Nginx

Log in as `admin01` on the VM console, then run:

```bash
sudo apt update && sudo apt full-upgrade -y   # refresh package lists, then install all updates
sudo apt install -y nginx                     # install the Nginx web server (starts automatically)
sudo timedatectl set-timezone Asia/Kolkata    # use the same time zone as the rest of the lab
timedatectl                                   # check "System clock synchronized: yes"
```

**Why the clock matters:** a SIEM puts events from different machines in order by timestamp. If the
clocks disagree, your incident timeline will be wrong.

## Step 4 — Publish the lab web page

Copy [`../configurations/nginx/index.html`](../configurations/nginx/index.html) to the server, or create it directly:

```bash
sudo nano /var/www/html/index.html   # paste the file content, save with Ctrl+O, exit with Ctrl+X
sudo nginx -t                        # check the Nginx configuration for syntax errors
sudo systemctl reload nginx          # apply changes without dropping connections
```

Optionally, apply the small hardening file [`../configurations/nginx/security-headers.conf`](../configurations/nginx/security-headers.conf):

```bash
sudo cp security-headers.conf /etc/nginx/conf.d/security-headers.conf
sudo nginx -t && sudo systemctl reload nginx
```

## Step 5 — SSH settings

For the failed-login test we leave **password login enabled for now**, with a long, strong password,
so the test produces real "Failed password" log lines and cannot succeed.

After testing, harden SSH with [`../configurations/ssh/99-lab-hardening.conf`](../configurations/ssh/99-lab-hardening.conf)
(key-only login). See the file for the exact steps. **Set up your SSH key first, or you will lock yourself out.**

## Step 6 — Record a baseline

```bash
sudo ss -tulpn          # list listening TCP/UDP ports and the program behind each
```

You should see only `:22` (sshd) and `:80` (nginx). Save the output into `docs/hosts-web01.md`.
You can also run [`../scripts/web01-baseline.sh`](../scripts/web01-baseline.sh), which collects this and more.

## Verification

| From | Command | Expected |
|---|---|---|
| web01 | `systemctl status nginx --no-pager` | `active (running)` |
| web01 | `curl -I http://localhost` | `HTTP/1.1 200 OK` |
| web01 | `curl -I https://ubuntu.com` | a response (internet through the firewall works) |
| kali01 | `curl http://10.10.20.10` | the lab HTML page |
| laptop (MGMT) | `ssh admin01@10.10.20.10` | asks for a password |

Screenshot: `screenshots/05-web01-nginx-page-from-kali.png`
