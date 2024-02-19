#!/bin/bash

while read -r -u9 drive_number volume_location vc_mapper mount_location; do
    formatted_volume_location="$volume_location"
    formatted_mount_location="$mount_location"
    echo "$formatted_mount_location"
    if [ "$formatted_volume_location" == "$source_volume_path" ] && [ "$formatted_mount_location" == "$source_mount_point" ]; then
        source_volume_mounted=1
    elif [ "$formatted_volume_location" == "$backup_volume_path" ] && [ "$formatted_mount_location" == "$backup_mount_point" ]; then
        echo "Backup volume mounted"
	    backup_volume_mounted=1
    else
        echo "Error: source or backup volume not mounted"
    fi
done 9< <(veracrypt -t -l)

