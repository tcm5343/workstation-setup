#!/usr/bin/env bash

# Requirements:
# - Must run script as root
# - Must have both veracrypt and rsync installed
# - Must be ran on Unix based systems
# - Both volumes must have the same password

# sudo ./veracrypt_backup.sh /drives/Primary/Volumes/Personal_v2_1 /drives/Secondary/Volumes/Personal_v2_1

prepare_volumes_for_exit() {
	# dismount volumes
	veracrypt -d
	echo "Volumes dismounted"

	# delete mount points
	rm -r "$source_mount_point"
	rm -r "$backup_mount_point"
	echo "Mount points purged"
}

# make sure all volumes are removed before starting
veracrypt -d

# check that 2 params are passed
if [ $# -ne 2 ]; then
    echo "Error: 2 parameters are required [source_volume_path] [backup_volume_path]" >&2
    exit 1
fi

echo "Enter the password for the veracrypt volume: "
read -s veracrypt_password

# path to veracrypt volumes
source_volume_path="$1"
backup_volume_path="$2"

# generate random mount point
source_mount_point="/mnt/$(uuidgen)"
backup_mount_point="/mnt/$(uuidgen)"

# flag to determine if drives are mounted
source_volume_mounted=0
backup_volume_mounted=0

# create mount points
mkdir -p "$source_mount_point"
mkdir -p "$backup_mount_point"

echo "Beginning to mount volumes"
veracrypt -t --mount "$source_volume_path" "$source_mount_point" -p "$veracrypt_password" --non-interactive

# checks that the source volume mounted
while read -r -u9 drive_number volume_location vc_mapper mount_location; do
    if [ "$volume_location" == "$source_volume_path" ] && [ "$mount_location" == "$source_mount_point" ]; then
        echo "Source volume mounted"
        source_volume_mounted=1
    else
        echo "Error: source volume not mounted" >&2
		prepare_volumes_for_exit
	    exit 1
    fi
done 9< <(veracrypt -t -l)

veracrypt -t --mount "$backup_volume_path" "$backup_mount_point" -p "$veracrypt_password" --non-interactive

# checks both the source and backup volumes are mounted
# http://mywiki.wooledge.org/BashFAQ/001#source
while read -r -u9 drive_number volume_location vc_mapper mount_location; do
    if [ "$volume_location" == "$source_volume_path" ] && [ "$mount_location" == "$source_mount_point" ]; then
        source_volume_mounted=1
    elif [ "$volume_location" == "$backup_volume_path" ] && [ "$mount_location" == "$backup_mount_point" ]; then
        echo "Backup volume mounted"
	    backup_volume_mounted=1
    else
        echo "Error: source or backup volume not mounted" >&2
        prepare_volumes_for_exit
        exit 1
    fi
done 9< <(veracrypt -t -l)

if [ "$source_volume_mounted" -eq 1 ] && [ "$backup_volume_mounted" -eq 1 ]
then 
    echo "Volumes mounted, beginning rsync"
    sudo rsync -hrtq --exclude-from='/drives/Primary/exclude.txt' --delete --force $source_mount_point/ $backup_mount_point
    echo "rsync complete"
else 
    echo 'Error: Drives were not mounted successfully, skipping rsync' >&2
fi

prepare_volumes_for_exit

echo "Complete"

