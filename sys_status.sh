#!/bin/bash

# First section of the script is to assign a variable with the idle level of the cpu as well as assigning a static
# 100% to another variable to subtract and use the difference as the cpu activity level and pushing that to an
# echo command to send it as STDOUT values

cpu_idle=$(mpstat | grep "all" | awk '{print $13}')

cpu_full=100.00

cpu_lvl=$(echo "$cpu_full - $cpu_idle" | bc)

echo "Current CPU Level: $cpu_lvl%"

echo ""

# For aesthetic purposes the current time is retrieved and assigned to a variable to let the user know the
# current time that the script ran

time_date=$(timedatectl | grep "Local time" | awk '{print $4, $5}')

echo "As of $time_date: "

# Using the free command, the vm's free allocated memory is displayed in GiB (as in 1024 GB) and formatted using
# the grep and awk functions. The same thing is done with the vm's unused storage displayed in GB (1000 GB) and
# formatted using grep and awk as well.

free_mem=$(free -h | grep "Mem" | awk '{print $4}')

echo "Free Memory: $free_mem "

free_strg=$(df -h / | grep "40G" | awk '{print $4}')

echo "Free Disk Space: $free_strg"
