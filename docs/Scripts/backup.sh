#!/bin/bash

folder_name="/home/krystian"
user_name="krystian"
actual_date=$(date +%Y-%m-%d)

mkdir -p /backup 

tar -czf "/backup/backup_${user_name}_${actual_date}.tar.gz" "$folder_name"

find /backup -type f -name "*.tar.gz" -mtime +7 -delete
