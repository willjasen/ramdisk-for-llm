#!/bin/bash

SIZE_MB=40960               # Size of the RAM disk in MB
MOUNT_POINT=/mnt/ramdisk    # Mount point for the RAM disk
# Source directory to sync to the RAM disk
SOURCE_DIR=/mnt/pinokio/drive/drives/peers/d1740527291592

# Green text variable
GREEN="\e[32m"
RESET="\e[0m"

# Function to create the RAM disk
create_ramdisk() {
    # Create the mount point directory if it doesn't exist
    mkdir -p $MOUNT_POINT

    # Mount the RAM disk
    mount -t tmpfs -o size=${SIZE_MB}M tmpfs $MOUNT_POINT
    echo -e "${GREEN}RAM disk created at ${MOUNT_POINT} with size ${SIZE_MB}MB${RESET}"

    # Rsync the directory to the RAM disk, following symlinks
    rsync -aP --copy-links $SOURCE_DIR/* $MOUNT_POINT/.
    echo -e "${GREEN}Directory ${SOURCE_DIR} synced to RAM disk at ${MOUNT_POINT}${RESET}"

    # Rename the original directory
    mv $SOURCE_DIR ${SOURCE_DIR}.original

    # Create a new symlink pointing to the RAM disk
    ln -s $MOUNT_POINT $SOURCE_DIR
    echo -e "${GREEN}Symlink ${SOURCE_DIR} now points to ${MOUNT_POINT}${RESET}"
}

# Function to undo the RAM disk
undo_ramdisk() {
    # Rsync the directory back to the original location
    #rsync -aP $MOUNT_POINT/ ${SOURCE_DIR}.original/
    #echo "Directory ${MOUNT_POINT} synced back to ${SOURCE_DIR}.original"

    # Remove the symlink
    rm $SOURCE_DIR

    # Restore the original directory name
    mv ${SOURCE_DIR}.original $SOURCE_DIR
    echo -e "${GREEN}Original directory ${SOURCE_DIR} has been restored${RESET}"

    # Unmount the RAM disk
    umount $MOUNT_POINT
    echo -e "${GREEN}RAM disk at ${MOUNT_POINT} unmounted${RESET}"
}

# Check for command line argument
if [ "$1" == "undo" ]; then
    undo_ramdisk
else
    create_ramdisk
fi
