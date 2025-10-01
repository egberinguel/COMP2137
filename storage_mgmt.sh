#!/bin/bash

# Storage Management

# List mounted local disk file systems with device name and mount point

echo -e "\t\tLocal Disk File Systems:\n"
echo -e "$(lsblk -o NAME,ID,FSTYPE,TYPE,MOUNTPOINTS)\n"

# List mounted network file systems with network source identification and mount point

echo -e "\t\tNetwork-Mounted Devices:\n"
echo -e "$(findmnt -t smb,nfs,cifs -o SOURCES,TARGET,LABEL,FSTYPE)\n"

# Identify how much free space is left in home directory

echo -e "\t\tHome Directory Free Space:\n"
echo -e "$(df -h /home)\n"

# Identify how much space is used and how many files in a directory

echo -n "Type a full directory path: "
read name_dir 
[ -d "$name_dir" ]

while [ $? != 0 ]
do
	echo -n "Directory does not exist. Try again: "
	read name_dir
	[ -d "$name_dir" ]
done 

echo -e "\n\t\tPrinting "$name_dir" usage and file count\n"
echo -en "$(sudo du -h "$name_dir" | tail -1)  :    " 

line_count=$(sudo ls -l $name_dir | wc -l)
echo "There are $((line_count-1)) files in this directory"

 
