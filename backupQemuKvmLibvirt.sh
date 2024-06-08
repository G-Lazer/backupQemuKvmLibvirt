#!/bin/bash

#REMINDER: Must use sudo and VM name is case sensitive.

# Check if a VM name and backup path are entered.
if [ $# -lt 2 ]; then
    echo "Usage: $0 <VM_NAME> <BACKUP_PATH>"
    exit 1
fi

# Assign the first command-line argument to VM_NAME.
VM_NAME="$1"
# Assign the second command-line argument to BACKUP_PATH.
BACKUP_PATH="$2"

# Optional: Stop the VM before backing up. Comment this out if not needed.
echo "Stopping the VM..."
virsh shutdown "$VM_NAME"
while [ "$(virsh domstate $VM_NAME)" != "shut off" ]; do
  sleep 5
done

echo "VM is shut down. Proceeding with the backup."

# Backup the XML file to retain VM configuration.
XML_FILE="$BACKUP_PATH/$VM_NAME.xml"
virsh dumpxml "$VM_NAME" > "$XML_FILE"
echo "VM configuration saved to $XML_FILE"

# Backup the .qcow2 QEMU disk image file.
DISK_PATHS=$(virsh domblklist "$VM_NAME" --details | grep file | awk '{print $4}' | grep '\.qcow2$')

for DISK_PATH in $DISK_PATHS; do
    BACKUP_FILE="$BACKUP_PATH/$(basename $DISK_PATH)"
    echo "Backing up $DISK_PATH to $BACKUP_FILE"
    cp "$DISK_PATH" "$BACKUP_FILE"
done

# Optional: Restart the VM. Comment this out if not needed.
echo "Starting the VM..."
virsh start "$VM_NAME"

echo "Backup completed successfully."