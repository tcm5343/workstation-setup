#!/bin/bash

# backs up my primary drive to the secondary drive

RSYNC_OPTS=(
  --human-readable
  --archive
  --verbose
  --delete
  --stats
  --exclude-from="/media/miller/Primary/exclude.txt"
)

USB_SRC="/run/media/miller/miller64"
PRIMARY="/media/miller/Primary"
SECONDARY="/media/miller/Secondary"

echo -e "\nStarting backup process..."

# backup USB drive to Primary drive
if [[ -d "$USB_SRC" && -d "$PRIMARY" ]]; then
  echo "Backing up USB to Primary..."
  tree "$PRIMARY/miller64" > "$PRIMARY/miller64/tree.txt"
  sudo rsync "${RSYNC_OPTS[@]}" "$USB_SRC/" "$PRIMARY/miller64"
  USB_STATUS="complete"
else
  echo "USB backup skipped (drive not found)"
  USB_STATUS="skipped"
fi

# backup Primary drive to Secondary drive
if [[ -d "$PRIMARY" && -d "$SECONDARY" ]]; then
  echo "Backing up Primary to Secondary..."
  tree "$PRIMARY" > "$PRIMARY/tree.txt"
  sudo rsync "${RSYNC_OPTS[@]}" "$PRIMARY/" "$SECONDARY"
  PRIMARY_STATUS="complete"
else
  echo "Primary drive backup skipped (drive not found)"
  PRIMARY_STATUS="skipped"
fi

# Summary
echo -e "\nrsync has completed:\n"
echo "• USB backup:      $USB_STATUS"
echo "• Primary backup:  $PRIMARY_STATUS"

