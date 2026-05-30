#!/bin/bash

Partition=${1:-/}

if [ -d "$Partition" ];then
    disk_usage=$(df "$Partition" | awk 'NR==2 {print $5} | tr -d "%")
else 
    echo "Partition not exist. Please provide a valid partition."
    exit 1
fi

if [ "$disk_usage" -gt 80 ]; then
  echo "Disk space over 80% used. Please free up some space."
fi
