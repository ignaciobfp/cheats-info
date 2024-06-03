#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <device> <output_file_path>"
    exit 1
fi

# Assign arguments to variables
DEVICE=$1
OUTPUT_FILE=$2

# Get device information with fdisk
INFO=$(sudo fdisk -l $DEVICE)

# Extract block size (bytes per sector)
BLOCK_SIZE=$(echo "$INFO" | grep 'Sector size' | awk -F ' ' '{print $4}')

# Extract total number of sectors
NUM_SECTORS=$(echo "$INFO" | grep "$DEVICE" | grep -oP 'sectors, \K[0-9]+')

# Calculate the expected image size in MB
IMAGE_SIZE_MB=$((NUM_SECTORS * BLOCK_SIZE / 1024 / 1024))

# Print the values to be used
echo "Block size: $BLOCK_SIZE bytes"
echo "Number of blocks: $NUM_SECTORS"
echo "Expected image size: $IMAGE_SIZE_MB MB"
echo "Saving image from $DEVICE to $OUTPUT_FILE. Continue? (y/n)"

# Ask for confirmation before proceeding
read -r CONFIRMATION
if [[ ! "$CONFIRMATION" =~ ^[Yy]$ ]]; then
    echo "Operation aborted."
    exit 1
fi

# Execute the dd command with the calculated values and progress status
sudo dd if=$DEVICE of=$OUTPUT_FILE bs=$BLOCK_SIZE count=$NUM_SECTORS status=progress

echo "Image successfully created at $OUTPUT_FILE"
