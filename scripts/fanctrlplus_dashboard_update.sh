#!/bin/bash
# fanctrlplus_dashboard_update.sh - 实时更新 Dashboard 所需的 RPM 和 PWM
plugin="fanctrlplus"
source "$(dirname "$0")/openfan_api.sh"
cfg_path="/boot/config/plugins/$plugin"
tmp_path="/var/tmp/$plugin"

mkdir -p "$tmp_path"

while true; do
  for cfg in "$cfg_path"/${plugin}_*.cfg; do
    [[ -f "$cfg" ]] || continue

    source "$cfg"
    [[ "$service" != "1" ]] && continue
    [[ -z "$controller" || -z "$custom" ]] && continue

    controller_type="${controller_type:-hwmon}"
    # Local PWM paths use the matching fanX_input file; OpenFAN uses its API.
    if [[ "$controller_type" == "hwmon" && "$controller" =~ pwm([0-9]+)$ ]]; then
      fan_index="${BASH_REMATCH[1]}"
      fan_path="$(dirname "$controller")/fan${fan_index}_input"
      rpm="-"
      [[ -f "$fan_path" ]] && rpm=$(< "$fan_path")
      pwm_val="-"
      [[ -f "$controller" ]] && pwm_val=$(< "$controller")
    elif [[ "$controller_type" == "openfan" || "$controller_type" == "openfan_micro" ]]; then
      rpm="-"; pwm_val="-"
      if openfan_get_status "$controller_type" "$openfan_host" "$openfan_port" "$openfan_channel"; then
        rpm="$OPENFAN_RPM"
        if [[ "$OPENFAN_PERCENT" =~ ^[0-9]+$ ]]; then
          pwm_val=$(( (OPENFAN_PERCENT * 255 + 50) / 100 ))
        else
          # Standard API has no PWM status. Keep the last command visible.
          [[ -f "$tmp_path/pwm_${plugin}_${custom}" ]] && pwm_val=$(< "$tmp_path/pwm_${plugin}_${custom}")
        fi
      fi
    else
      continue
    fi

    # ✅ 写入RPM文件
    echo "$rpm" > "$tmp_path/rpm_${plugin}_${custom}"

    # ✅ 写入PWM文件
    echo "$pwm_val" > "$tmp_path/pwm_${plugin}_${custom}"

    # ✅ 状态判断
    if [[ "$rpm" =~ ^[0-9]+$ ]] && (( rpm > 0 )); then
      echo "Running" > "$tmp_path/status_${plugin}_${custom}"
    else
      echo "Stopped" > "$tmp_path/status_${plugin}_${custom}"
    fi
  done

  sleep 5  # dashboard 刷新频率，不影响风扇控制逻辑
done
