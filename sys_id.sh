#!/bin/bash

# The first command fetches the vm's hostname before sending it to the file
# descriptor 1 or the STDOUT which is the computer's monitor using the echo
# command.

echo -e "  Hostname:\t$(hostname)\n"

# This section enumerates the IP addresses available in the system and stores 
# them in a variable before processing the variable using a for-loop to print
# each IP address in a line.

echo "IP Addresses: "

ip_addr=$(ip a | grep "inet " | awk '{print $2}')

for addr in $ip_addr; do
  echo "	$addr"
done

# The last section retrieves the vm's default gateway using the ip route
# command and using multiple pipes to send its output as the input for the
# grep command which only retrieves an entire line where a keyword passed off
# as the argument matches before passing its output again as input for the 
# awk command for display formatting

default_gw=$(ip route | grep "default" | awk '{print $3}')

echo -e "\n  IP Gateway:\t$default_gw"
