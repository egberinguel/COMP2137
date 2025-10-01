#!/bin/bash

# This script is for identifying system hardware components and displaying useful information about them

# First information is for identifying the network interface names using nmcli device show

echo "Interface Names:"

if_name=$(nmcli device show | grep GENERAL.DEVICE | awk '{print $2}') 

for intf in $if_name; do
  echo "		$intf"
done


# Second information is for identifying the processor model name with the number of cores and speed

cpu_model=$(lscpu | grep 'Model name' | awk -F':' '{print $2}' | xargs)

echo "Processor Model: "
echo "		$cpu_model"

sockets_num=$(lscpu | grep 'Socket(s)' | awk -F':' '{print $2}' | xargs)
cores_num=$(lscpu | grep 'Core(s) per socket' | awk -F':' '{print $2}' | xargs)
cores_total=$(($sockets_num*$cores_num))

echo "Number of cores: "
echo "		$cores_total"
echo "Speed: "
echo "		$(echo $cpu_model | awk -F'@ ' '{print $2}')"


# Third information is for memory size

echo "Total memory: "
echo "		$(lsmem | grep 'Total online memory' | awk -F':       ' '{print $2}') or $(free -h | grep 'Mem:' | awk -F'       ' '{print $2}' | xargs)"

# Fourth information is to display disk drive device names and model names

echo -e "\nDisk Information: \n"
echo "		Name   Type   Size Model"
echo -e "		$(lsblk -do NAME,TYPE,SIZE,MODEL | awk '$2 == "disk"')\n"

# Fifth information is for displaying the video card model name

echo "Video Cards: "
echo "		$(lspci | grep 'VGA\|Display' | awk -F':' '{print $3}' | xargs)"


