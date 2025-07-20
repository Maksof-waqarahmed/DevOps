**log file analyzer bash script**:

---

## 📄 Log File Analyzer Bash Script

### 🧠 Script Overview

This Bash script analyzes a log file and provides a comprehensive report including:

* Count of `ERROR`, `WARNING`, and `INFO` messages
* Top 5 most common error messages
* First and last error messages with timestamps
* Error frequency based on time slots (hourly analysis)
* A generated summary report saved as a `.txt` file

---

## 🚀 How to Use

```bash
./log_analyzer.sh <log_file_path>
```

**Example:**

```bash
./log_analyzer.sh /var/log/app.log
```

---

## 📖 Script Explanation

### 1. **Shebang Line**

```bash
#!/bin/bash
```

Tells the system to execute the script using the Bash shell.

---

### 2. **Check if File Argument Is Provided**

```bash
if [ -z "$1" ]; then
    echo "Usage: $0 <log_file_path>"
    exit 1
fi
```

* If the first argument (file path) is empty, show usage help and exit.

---

### 3. **Check If File Exists**

```bash
LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File '$LOG_FILE' not found!"
    exit 1
fi
```

* Stores the file path in `LOG_FILE`
* Checks if the file actually exists using `-f`

---

### 4. **Get File Metadata**

```bash
ANALYZED_ON=$(date)
FILE_SIZE_BYTES=$(stat -c%s "$LOG_FILE")
FILE_SIZE_HUMAN=$(du -h "$LOG_FILE" | cut -f1)
```

* `date`: Current system date and time
* `stat`: File size in bytes
* `du -h`: Human-readable file size (like 15.4MB)

---

### 5. **Count Log Message Types**

```bash
ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE")
WARNING_COUNT=$(grep -c "WARNING" "$LOG_FILE")
INFO_COUNT=$(grep -c "INFO" "$LOG_FILE")
```

Counts how many lines contain the keywords `ERROR`, `WARNING`, and `INFO`.

---

### 6. **Find Top 5 Error Messages**

```bash
TOP_ERRORS=$(grep "ERROR" "$LOG_FILE" | sed -E 's/.*ERROR:? ?//' | sort | uniq -c | sort -nr | head -n 5)
```

**Breakdown:**

* `grep`: Extracts all ERROR lines
* `sed`: Removes everything before and including "ERROR:"
* `sort`: Sorts all messages
* `uniq -c`: Counts duplicate messages
* `sort -nr`: Sorts counts in descending order
* `head -n 5`: Shows top 5 most frequent errors

---

### 7. **Get First and Last Error**

```bash
FIRST_ERROR=$(grep "ERROR" "$LOG_FILE" | head -n 1)
LAST_ERROR=$(grep "ERROR" "$LOG_FILE" | tail -n 1)
```

* Extracts the first and last occurrence of ERROR

---

### 8. **Error Frequency by Hour Buckets**

```bash
declare -A hour_buckets
for hour in 00 04 08 12 16 20; do hour_buckets[$hour]=0; done
```

Defines time buckets:

* 00–04
* 04–08
* 08–12
* 12–16
* 16–20
* 20–24

```bash
grep "ERROR" "$LOG_FILE" | while read -r line; do
    timestamp=$(echo "$line" | grep -oE '\[([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2})' | cut -d' ' -f2 | cut -d']' -f1)
    hour=${timestamp:0:2}
```

* Extracts the hour portion from the timestamp (e.g., 14 from `[2025-07-12 14:03:27]`)

```bash
    case "$hour" in
        00|01|02|03) ((hour_buckets["00"]++)) ;;
        04|05|06|07) ((hour_buckets["04"]++)) ;;
        08|09|10|11) ((hour_buckets["08"]++)) ;;
        12|13|14|15) ((hour_buckets["12"]++)) ;;
        16|17|18|19) ((hour_buckets["16"]++)) ;;
        20|21|22|23) ((hour_buckets["20"]++)) ;;
    esac
done
```

Adds each error to the corresponding 4-hour bucket.

---

### 9. **Generate Report Filename**

```bash
REPORT_FILE="log_analysis_$(date +%Y%m%d_%H%M%S).txt"
```

Creates a unique report filename using the current timestamp.

---

### 10. **Print and Save Final Report**

```bash
{ ... } | tee "$REPORT_FILE"
```

* Prints the report to the terminal
* Saves the same output to a `.txt` file

---

## 📊 Sample Output

```
===== LOG FILE ANALYSIS REPORT =====
File: /var/log/application.log
Analyzed on: Fri Jul 12 14:32:15 EDT 2025
Size: 15.4MB (16128547 bytes)

MESSAGE COUNTS:
ERROR: 328 messages
WARNING: 1253 messages
INFO: 8792 messages

TOP 5 ERROR MESSAGES:
 182 - Database connection failed: timeout
  56 - Invalid authentication token provided

ERROR TIMELINE:
First error: [2025-07-10 02:14:32] Database connection failed: timeout
Last error:  [2025-07-12 14:03:27] Failed to write to disk: Permission denied

Error frequency by hour:
00-04: ███████ (72)
04-08: ██ (23)
08-12: ████████████ (120)
12-16: ██████ (63)
16-20: ███ (34)
20-24: ████ (16)

Report saved to: log_analysis_20250712_143215.txt
```

---

## ✅ Notes

* This script assumes log entries contain timestamps in the format: `[YYYY-MM-DD HH:MM:SS]`

---
---

# 🖥️ System Health Monitor Dashboard - Bash Script

This script provides a **real-time system health monitoring dashboard** directly in the terminal. It displays CPU, memory, disk, and network statistics, refreshes every few seconds, and uses color and ASCII visuals to represent system usage. It also logs anomalies like CPU/memory spikes or low disk space.

---

## 🚀 Features

* Live dashboard in the terminal
* ASCII-based usage bars
* Color-coded warnings (Green: OK, Yellow: Warning, Red: Critical)
* Anomaly logging
* Hotkeys for:

  * Changing refresh rate
  * Filtering metrics
  * Exiting the program

---

## 📂 Files

* `monitor.sh` – Main script file
* `alerts.log` – Stores anomaly logs

---

## 🧠 Script Breakdown (Line-by-Line Explanation)

```bash
#!/bin/bash
```

Declares that the script will be run using Bash shell.

---

```bash
REFRESH_RATE=3
```

Sets the default refresh rate (in seconds) for updating the dashboard.

---

```bash
LOG_FILE="./alerts.log"
```

Specifies the path to the log file where alerts will be stored.

---

```bash
trap "tput cnorm; clear; exit" SIGINT
```

Handles Ctrl+C (SIGINT). It resets cursor visibility (`tput cnorm`), clears the screen, and exits cleanly.

---

```bash
tput civis
```

Hides the cursor for better visual appearance.

---

### 🧩 Helper Functions

```bash
draw_bar() {
    local value=$1
    local max_width=50
    local filled=$(( (value * max_width) / 100 ))
    local empty=$(( max_width - filled ))

    printf "%s%s" "$(printf '█%.0s' $(seq 1 $filled))" "$(printf '░%.0s' $(seq 1 $empty))"
}
```

Creates a bar chart for percentage values:

* `value`: current percentage (e.g., 75%)
* Fills bar with `█` and remaining with `░`

---

```bash
get_color() {
    local percent=$1
    if [ $percent -lt 50 ]; then
        echo -e "\033[0;32m"  # Green
    elif [ $percent -lt 75 ]; then
        echo -e "\033[1;33m"  # Yellow
    else
        echo -e "\033[0;31m"  # Red
    fi
}
```

Returns a color code based on percentage value:

* Green for <50%, Yellow for <75%, Red for >=75%

---

```bash
log_alert() {
    echo "[$(date '+%H:%M:%S')] $1" >> $LOG_FILE
}
```

Appends alert messages to the `alerts.log` file with timestamps.

---

## 🔄 Main Loop

```bash
while true; do
```

Infinite loop to continuously update system metrics every few seconds.

---

### 🖥️ System Metrics

```bash
clear
echo -e "╔════════════ SYSTEM HEALTH MONITOR v1.0 ════════════╗  [R]efresh rate: ${REFRESH_RATE}s"
echo -e "║ Hostname: $(hostname) \t Date: $(date '+%Y-%m-%d') ║  [F]ilter: All"
echo -e "║ Uptime: $(uptime -p) ║  [Q]uit"
echo -e "╚═══════════════════════════════════════════════════════════════════════╝"
```

Displays the dashboard header with:

* Hostname
* Date
* Uptime
* Refresh rate and hotkey labels

---

### 🧠 CPU Usage

```bash
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d'.' -f1)
COLOR=$(get_color $CPU_USAGE)
TOP_PROC=$(ps -eo comm,%cpu --sort=-%cpu | head -n 4 | tail -n 3)
```

* Gets current CPU usage (`100 - idle %`)
* Gets top 3 CPU-consuming processes
* Chooses color based on usage

```bash
echo -en "CPU USAGE: $CPU_USAGE% "
draw_bar $CPU_USAGE
echo -e " ${COLOR}[$([[ $CPU_USAGE -lt 75 ]] && echo OK || ([[ $CPU_USAGE -lt 85 ]] && echo WARNING || echo CRITICAL))]\033[0m"
echo "$TOP_PROC"
```

* Draws a CPU usage bar

* Shows health status

* Lists top processes

* Logs if CPU > 80%:

```bash
[ $CPU_USAGE -gt 80 ] && log_alert "CPU usage exceeded 80% ($CPU_USAGE%)"
```

---

### 💾 Memory Usage

```bash
MEM=$(free -m | awk '/Mem:/ {print $3, $2}')
USED=$(echo $MEM | cut -d' ' -f1)
TOTAL=$(echo $MEM | cut -d' ' -f2)
MEM_PERCENT=$(( 100 * USED / TOTAL ))
COLOR=$(get_color $MEM_PERCENT)
```

* Gets memory used and total
* Calculates percentage
* Selects color

```bash
echo -en "MEMORY: ${USED}MB/${TOTAL}MB (${MEM_PERCENT}%) "
draw_bar $MEM_PERCENT
echo -e " ${COLOR}[$([[ $MEM_PERCENT -lt 75 ]] && echo OK || ([[ $MEM_PERCENT -lt 85 ]] && echo WARNING || echo CRITICAL))]\033[0m"
```

* Logs if memory > 75%:

```bash
[ $MEM_PERCENT -gt 75 ] && log_alert "Memory usage exceeded 75% (${MEM_PERCENT}%)"
```

---

### 🗂️ Disk Usage

```bash
df -h | awk 'NR>1 {print $6, $5}' | while read mount usage; do
    percent=$(echo $usage | tr -d '%')
    COLOR=$(get_color $percent)
    echo -en "  $mount : $usage "
    draw_bar $percent
    echo -e " ${COLOR}[$([[ $percent -lt 75 ]] && echo OK || ([[ $percent -lt 85 ]] && echo WARNING || echo CRITICAL))]\033[0m"
    [ $percent -gt 75 ] && log_alert "Disk usage on $mount exceeded 75% ($usage)"
done
```

* Loops through each mounted disk
* Draws usage bar
* Logs if usage > 75%

---

### 🌐 Network Usage

```bash
NET_DEV="eth0"
RX1=$(cat /sys/class/net/$NET_DEV/statistics/rx_bytes)
TX1=$(cat /sys/class/net/$NET_DEV/statistics/tx_bytes)
sleep 1
RX2=$(cat /sys/class/net/$NET_DEV/statistics/rx_bytes)
TX2=$(cat /sys/class/net/$NET_DEV/statistics/tx_bytes)
```

* Gets bytes received/transmitted before and after 1 second to calculate speed.

```bash
RX_RATE=$(( (RX2 - RX1) / 1024 / 1024 ))
TX_RATE=$(( (TX2 - TX1) / 1024 / 1024 ))
```

* Converts to MB/s

```bash
COLOR_RX=$(get_color $RX_RATE)
COLOR_TX=$(get_color $TX_RATE)
echo -e "eth0 (in) : ${RX_RATE} MB/s "
draw_bar $RX_RATE
echo -e " ${COLOR_RX}[OK]\033[0m"

echo -e "eth0 (out): ${TX_RATE} MB/s "
draw_bar $TX_RATE
echo -e " ${COLOR_TX}[OK]\033[0m"
```

---

### 📊 Load Average & Alerts

```bash
echo -e "\nLOAD AVERAGE: $(uptime | awk -F'load average: ' '{print $2}')"
```

Displays the 1/5/15-minute system load averages.

```bash
echo -e "\nRECENT ALERTS:"
tail -n 5 $LOG_FILE
```

Shows the last 5 alerts from the log.

---

### ⌨️ User Input & Sleep

```bash
read -t $REFRESH_RATE -n 1 key
```

* Waits for user input for `REFRESH_RATE` seconds.

```bash
case $key in
    q|Q) tput cnorm; clear; exit ;;
    r|R) read -p "Enter new refresh rate: " REFRESH_RATE ;;
    f|F) echo "Filtering is not implemented yet." ;;
    h|H) echo "Help: R - Refresh rate, F - Filter, Q - Quit" ;;
esac
```

* Implements key actions:

  * `q`: quit
  * `r`: change refresh rate
  * `f`: (placeholder)
  * `h`: help

---

## 🛠️ How to Run

```bash
chmod +x monitor.sh
./monitor.sh
```

---

## 📘 Sample Output

```text
╔════════════ SYSTEM HEALTH MONITOR v1.0 ════════════╗  [R]efresh rate: 3s
║ Hostname: webserver-prod1          Date: 2025-07-12 ║  [F]ilter: All
║ Uptime: 43 days, 7 hours, 13 minutes               ║  [Q]uit
╚═══════════════════════════════════════════════════════════════════════╝

CPU USAGE: 67% ██████████████████████████████░░░░░░░░░░░░░ [WARNING]
  Process: mongod (22%), nginx (18%), node (15%)

MEMORY: 5.8GB/8GB (73%) █████████████████████████████░░░░░ [WARNING]
...

RECENT ALERTS:
[14:25:12] CPU usage exceeded 80% (83%)
```

---