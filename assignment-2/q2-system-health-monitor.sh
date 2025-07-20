#!/bin/bash

# Constants for color codes
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"
BOLD="\033[1m"

REFRESH_RATE=3
LOG_FILE="./alerts.log"
FILTER="ALL"

print_header() {
  clear
  echo -e "${BOLD}╔════════════ SYSTEM HEALTH MONITOR v1.0 ════════════╗  [R]efresh rate: ${REFRESH_RATE}s"
  echo -e "║ Hostname: $(hostname)          Date: $(date '+%Y-%m-%d') ║  [F]ilter: $FILTER"
  echo -e "║ Uptime: $(uptime -p | sed 's/up //')$(printf "%34s║" '')  [Q]uit"
  echo -e "╚═══════════════════════════════════════════════════════════════════════╝${RESET}"
}

get_status_color() {
  local percent=$1
  if [ "$percent" -lt 60 ]; then
    echo -e "$GREEN"
  elif [ "$percent" -lt 80 ]; then
    echo -e "$YELLOW"
  else
    echo -e "$RED"
  fi
}

log_alert() {
  echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

draw_bar() {
  local percent=$1
  local filled=$(($percent / 2))
  local empty=$((50 - filled))
  printf "%s" "$(printf '█%.0s' $(seq 1 $filled))"
  printf "%s" "$(printf '░%.0s' $(seq 1 $empty))"
}

display_metrics() {
  # CPU Usage
  CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
  CPU_INT=${CPU%.*}
  CPU_COLOR=$(get_status_color "$CPU_INT")
  CPU_BAR=$(draw_bar "$CPU_INT")
  echo -e "CPU USAGE: ${CPU_INT}% ${CPU_BAR}${CPU_COLOR} [$(status_label "$CPU_INT")]${RESET}"
  echo -e "  Process: $(ps -eo comm,%cpu --sort=-%cpu | head -n 4 | tail -n +2 | xargs)"

  # Memory Usage
  MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
  MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
  MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))
  MEM_COLOR=$(get_status_color "$MEM_PERCENT")
  MEM_BAR=$(draw_bar "$MEM_PERCENT")
  echo -e "\nMEMORY: ${MEM_USED}MB/${MEM_TOTAL}MB (${MEM_PERCENT}%) ${MEM_BAR}${MEM_COLOR} [$(status_label "$MEM_PERCENT")]${RESET}"
  echo -e "  Free: $(free -m | awk '/Mem:/ {print $4}')MB | Cache: $(free -m | awk '/Mem:/ {print $6}')MB | Buffers: $(free -m | awk '/Mem:/ {print $7}')MB"

  # Disk Usage
  echo -e "\nDISK USAGE:"
  df -h | awk 'NR>1 && $6 ~ "^/$|^/var/log$|^/home$" { 
    percent = substr($5, 1, length($5)-1)
    color = percent < 60 ? "'$GREEN'" : (percent < 80 ? "'$YELLOW'" : "'$RED'")
    bar = ""
    for(i=0;i<percent/2;i++) bar=bar "█"
    for(i=percent/2;i<50;i++) bar=bar "░"
    status = percent < 60 ? "[OK]" : (percent < 80 ? "[WARNING]" : "[CRITICAL]")
    printf "  %-8s: %3s%% %s%s %s%s\n", $6, percent, bar, color, status, "'$RESET'"
    if (percent >= 75) system("echo \"["strftime("%H:%M:%S")"] Disk usage on "$6" exceeded 75% ("percent"%)\" >> " "'$LOG_FILE'")
  }'

  # Network
  RX=$(cat /sys/class/net/eth0/statistics/rx_bytes)
  TX=$(cat /sys/class/net/eth0/statistics/tx_bytes)
  sleep 1
  RX2=$(cat /sys/class/net/eth0/statistics/rx_bytes)
  TX2=$(cat /sys/class/net/eth0/statistics/tx_bytes)
  RX_MB=$(( (RX2 - RX) / 1024 / 1024 ))
  TX_MB=$(( (TX2 - TX) / 1024 / 1024 ))

  RX_COLOR=$(get_status_color "$RX_MB")
  TX_COLOR=$(get_status_color "$TX_MB")
  RX_BAR=$(draw_bar "$RX_MB")
  TX_BAR=$(draw_bar "$TX_MB")

  echo -e "\nNETWORK:"
  echo -e "  eth0 (in) : ${RX_MB} MB/s ${RX_BAR}${RX_COLOR} [OK]${RESET}"
  echo -e "  eth0 (out): ${TX_MB} MB/s ${TX_BAR}${TX_COLOR} [OK]${RESET}"

  # Load Average
  echo -e "\nLOAD AVERAGE: $(uptime | awk -F'load average:' '{ print $2 }')"

  # Alerts
  echo -e "\nRECENT ALERTS:"
  tail -n 5 "$LOG_FILE"
}

status_label() {
  local percent=$1
  if [ "$percent" -lt 60 ]; then
    echo "OK"
  elif [ "$percent" -lt 80 ]; then
    echo "WARNING"
  else
    echo "CRITICAL"
  fi
}

run_dashboard() {
  while true; do
    print_header
    display_metrics
    echo -e "\nPress 'r' to change refresh rate, 'f' to toggle filter, 'q' to quit"
    read -t $REFRESH_RATE -n 1 input
    case $input in
      r|R)
        echo -ne "\nEnter new refresh rate (seconds): "
        read new_rate
        if [[ "$new_rate" =~ ^[0-9]+$ ]]; then
          REFRESH_RATE=$new_rate
        fi ;;
      f|F)
        FILTER="ALL" ;; # Placeholder if filters are implemented later
      q|Q)
        clear; exit ;;
    esac
  done
}

# Start monitoring
touch "$LOG_FILE"
run_dashboard
