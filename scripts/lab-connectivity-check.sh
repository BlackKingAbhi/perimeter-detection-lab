#!/usr/bin/env bash
# lab-connectivity-check.sh — verify the firewall rules behave as designed.
# Run from kali01 (USERS zone):  bash lab-connectivity-check.sh
# Only touches lab addresses. Uses ping, curl and nc (netcat) with short timeouts.

set -u

WEB01=10.10.20.10
WAZUH01=10.10.99.10
FW_USERS=10.10.10.1

pass=0; fail=0
check() {   # usage: check "description" expected(allow|deny) command...
  local desc=$1 expected=$2; shift 2
  if "$@" >/dev/null 2>&1; then result=allow; else result=deny; fi
  if [[ $result == "$expected" ]]; then
    printf '[PASS] %-45s expected=%-5s got=%s\n' "$desc" "$expected" "$result"; ((pass++))
  else
    printf '[FAIL] %-45s expected=%-5s got=%s\n' "$desc" "$expected" "$result"; ((fail++))
  fi
}

check "Ping own gateway (firewall)"      allow ping -c 2 -W 2 "$FW_USERS"
check "HTTP to web01 (TCP 80)"           allow curl -s -m 5 -o /dev/null "http://$WEB01"
check "SSH to web01 (TCP 22)"            deny  nc -z -w 3 "$WEB01" 22
check "Ping wazuh01 (MGMT)"              deny  ping -c 2 -W 2 "$WAZUH01"
check "Wazuh dashboard (MGMT 443)"       deny  nc -z -w 3 "$WAZUH01" 443
check "Firewall GUI from USERS (443)"    deny  nc -z -w 3 "$FW_USERS" 443
check "Internet HTTPS (updates)"         allow curl -s -m 8 -o /dev/null https://kali.org

printf '\nResult: %d passed, %d failed\n' "$pass" "$fail"
echo "Note: expected values assume the FINAL least-privilege rules (configurations/opnsense/firewall-rules.md)."
