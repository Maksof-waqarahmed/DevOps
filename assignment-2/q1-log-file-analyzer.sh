#!/bin/bash

# Check if a log file was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <log_file_path>"
    exit 1
fi

LOG_FILE="$1"

# Check if file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File '$LOG_FILE' not found!"
    exit 1
fi

# Metadata
ANALYZED_ON=$(date)
FILE_SIZE_BYTES=$(stat -c%s "$LOG_FILE")
FILE_SIZE_HUMAN=$(du -h "$LOG_FILE" | cut -f1)

# Count messages
ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE")
WARNING_COUNT=$(grep -c "WARNING" "$LOG_FILE")
INFO_COUNT=$(grep -c "INFO" "$LOG_FILE")

# Extract and count top 5 error messages (excluding timestamp)
TOP_ERRORS=$(grep "ERROR" "$LOG_FILE" | sed -E 's/.*ERROR:? ?//' | sort | uniq -c | sort -nr | head -n 5)

# Find first and last error
FIRST_ERROR=$(grep "ERROR" "$LOG_FILE" | head -n 1)
LAST_ERROR=$(grep "ERROR" "$LOG_FILE" | tail -n 1)

# Error frequency by hour
declare -A hour_buckets
for hour in 00 04 08 12 16 20; do hour_buckets[$hour]=0; done

grep "ERROR" "$LOG_FILE" | while read -r line; do
    timestamp=$(echo "$line" | grep -oE '\[([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2})' | cut -d' ' -f2 | cut -d']' -f1)
    hour=${timestamp:0:2}
    case "$hour" in
        00|01|02|03) ((hour_buckets["00"]++)) ;;
        04|05|06|07) ((hour_buckets["04"]++)) ;;
        08|09|10|11) ((hour_buckets["08"]++)) ;;
        12|13|14|15) ((hour_buckets["12"]++)) ;;
        16|17|18|19) ((hour_buckets["16"]++)) ;;
        20|21|22|23) ((hour_buckets["20"]++)) ;;
    esac
done

# Save report
REPORT_FILE="log_analysis_$(date +%Y%m%d_%H%M%S).txt"
{
    echo "===== LOG FILE ANALYSIS REPORT ====="
    echo "File: $LOG_FILE"
    echo "Analyzed on: $ANALYZED_ON"
    echo "Size: $FILE_SIZE_HUMAN ($FILE_SIZE_BYTES bytes)"
    echo ""
    echo "MESSAGE COUNTS:"
    echo "ERROR: $ERROR_COUNT messages"
    echo "WARNING: $WARNING_COUNT messages"
    echo "INFO: $INFO_COUNT messages"
    echo ""
    echo "TOP 5 ERROR MESSAGES:"
    echo "$TOP_ERRORS" | sed 's/^/  /'
    echo ""
    echo "ERROR TIMELINE:"
    echo "First error: $FIRST_ERROR"
    echo "Last error:  $LAST_ERROR"
    echo ""
    echo "Error frequency by hour:"
    for bucket in 00 04 08 12 16 20; do
        count=${hour_buckets[$bucket]}
        bar=$(printf "%0.s█" $(seq 1 $((count / 10 + 1))))
        echo "$bucket-$(printf "%02d" $((10#$bucket + 4))): $bar ($count)"
    done
    echo ""
    echo "Report saved to: $REPORT_FILE"
} | tee "$REPORT_FILE"
