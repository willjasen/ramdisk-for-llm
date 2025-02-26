#!/bin/bash

SIZE_MB=49152                   # Size of the RAM disk in MB (48 GB)
RAMDISK_MOUNT=/mnt/ramdisk      # Mount point for the RAM disk
# Source directory to sync to the RAM disk
SOURCE_DIR=/mnt/pinokio/api/stable-diffusion-webui-forge.git/app/models/Stable-diffusion;

# Text colors
GREEN="\e[32m"
RESET="\e[0m"

# Function to create the RAM disk
create_ramdisk() {
    # Create the mount point directory if it doesn't exist
    mkdir -p $RAMDISK_MOUNT

    # Mount the RAM disk
    mount -t tmpfs -o size=${SIZE_MB}M tmpfs $RAMDISK_MOUNT
    echo -e "${GREEN}RAM disk created at ${RAMDISK_MOUNT} with size ${SIZE_MB}MB${RESET}"

    # Rsync the directory to the RAM disk, following symlinks
    rsync -aP --copy-links $SOURCE_DIR/* $RAMDISK_MOUNT/.
    if [ $? -ne 0 ]; then
        echo -e "${GREEN}Rsync interrupted. Exiting...${RESET}"
        exit 1
    fi
    echo -e "${GREEN}Directory ${SOURCE_DIR} synced to RAM disk at ${RAMDISK_MOUNT}${RESET}"

    # Calculate and output the total number of gigabytes copied
    total_size=$(du -sh $RAMDISK_MOUNT | cut -f1)
    echo -e "${GREEN}Total size of ${RAMDISK_MOUNT}: ${total_size}${RESET}"

    # Rename the original directory
    mv $SOURCE_DIR ${SOURCE_DIR}.original

    # Create a new symlink pointing to the RAM disk
    ln -s $RAMDISK_MOUNT $SOURCE_DIR
    echo -e "${GREEN}Symlink ${SOURCE_DIR} now points to ${RAMDISK_MOUNT}${RESET}"
}

# Function to undo the RAM disk
undo_ramdisk() {
    # Rsync the directory back to the original location
    #rsync -aP $RAMDISK_MOUNT/ ${SOURCE_DIR}.original/
    #echo "Directory ${RAMDISK_MOUNT} synced back to ${SOURCE_DIR}.original"

    # Remove the symlink
    rm $SOURCE_DIR

    # Restore the original directory name
    mv ${SOURCE_DIR}.original $SOURCE_DIR
    echo -e "${GREEN}Original directory ${SOURCE_DIR} has been restored${RESET}"

    # Unmount the RAM disk
    umount $RAMDISK_MOUNT
    echo -e "${GREEN}RAM disk at ${RAMDISK_MOUNT} unmounted${RESET}"
}

# Check for command line argument
if [ "$1" == "undo" ]; then
    undo_ramdisk
else
    create_ramdisk
fi
