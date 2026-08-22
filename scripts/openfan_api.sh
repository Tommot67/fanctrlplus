#!/bin/bash
# Shared OpenFAN API backend.  Values passed to this file are configuration
# values, never shell code; URLs are constructed here to keep the control loop
# independent from the controller transport.

openfan_base_url() {
  local host="$1" port="$2"
  host="${host%/}"
  if [[ "$host" != http://* && "$host" != https://* ]]; then
    host="http://$host"
  fi
  # A port included in the host takes precedence over the optional port field.
  if [[ -n "$port" && "$host" != *://*:* ]]; then
    host="$host:$port"
  fi
  printf '%s/api/v0' "$host"
}

openfan_request() {
  curl -fsS --connect-timeout 2 --max-time 5 "$1" 2>/dev/null
}

openfan_set_pwm() {
  local type="$1" host="$2" port="$3" channel="$4" pwm="$5"
  local percent=$(( (pwm * 100 + 127) / 255 ))
  (( percent < 0 )) && percent=0
  (( percent > 100 )) && percent=100
  local base
  base=$(openfan_base_url "$host" "$port")
  # Both OpenFAN generations use /set; Micro always exposes fan 0.
  [[ "$type" == "openfan_micro" ]] && channel=0
  openfan_request "$base/fan/$channel/set?value=$percent" >/dev/null
}

openfan_get_status() {
  local type="$1" host="$2" port="$3" channel="$4" body
  local base
  base=$(openfan_base_url "$host" "$port")
  [[ "$type" == "openfan_micro" ]] && channel=0
  body=$(openfan_request "$base/fan/status") || return 1

  if [[ "$type" == "openfan_micro" ]]; then
    OPENFAN_RPM=$(printf '%s' "$body" | sed -n 's/.*"rpm"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p')
    OPENFAN_PERCENT=$(printf '%s' "$body" | sed -n 's/.*"pwm_percent"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p')
  else
    OPENFAN_RPM=$(printf '%s' "$body" | sed -n "s/.*\"$channel\"[[:space:]]*:[[:space:]]*\\([0-9][0-9]*\\).*/\\1/p")
    OPENFAN_PERCENT=""
  fi
  [[ "$OPENFAN_RPM" =~ ^[0-9]+$ ]]
}
