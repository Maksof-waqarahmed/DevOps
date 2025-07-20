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

## 📖 Script Explanation (Line-by-Line)

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
