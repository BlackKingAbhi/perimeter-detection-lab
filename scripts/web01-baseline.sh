#!/usr/bin/env bash
# web01-baseline.sh — record what web01 looks like BEFORE testing.
# Run on web01:  bash web01-baseline.sh > baseline-$(date +%F).txt
# Read-only: it changes nothing on the server.

set -u

section() { printf '\n===== %s =====\n' "$1"; }

section "Host and time"
hostname                      # machine name
date                          # current time (compare with other VMs)
timedatectl | grep -E "Time zone|synchronized"

section "IP addresses and default route"
ip -brief address             # one line per interface with its IP
ip route | grep default       # which gateway traffic leaves through (should be 10.10.20.1)

section "Listening ports (expect only 22 and 80)"
sudo ss -tulpn                # TCP/UDP ports in LISTEN state and the owning program

section "Service status"
for svc in nginx ssh wazuh-agent; do
  printf '%-12s %s\n' "$svc" "$(systemctl is-active "$svc" 2>/dev/null)"
done

section "SSH effective settings"
sudo sshd -T 2>/dev/null | grep -E "^(passwordauthentication|permitrootlogin|maxauthtries|allowusers)"

section "Recent failed SSH logins (last 10)"
sudo grep "Failed password" /var/log/auth.log 2>/dev/null | tail -n 10 || echo "none"

section "Recent successful SSH logins (last 10)"
sudo grep "Accepted" /var/log/auth.log 2>/dev/null | tail -n 10 || echo "none"
