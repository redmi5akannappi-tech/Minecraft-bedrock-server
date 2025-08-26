#!/bin/bash
while true; do
    # Get CPU usage %
    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    
    if (( $(echo "$cpu < 20" | bc -l) )); then
        echo "[AutoBackup] Low load ($cpu%), running backup..."
        /server/backup.sh
        sleep 3600   # wait 1h before next backup
    else
        echo "[AutoBackup] High load ($cpu%), retrying in 5m"
        sleep 300
    fi
done
