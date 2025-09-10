#!/bin/bash

# The first command fetches the vm's hostname before sending it to the file
# descriptor 0 or the STDOUT which is the computer's monitor using the echo
# command.

echo -e "  Hostname:\t$(hostname)\n"

# This section creates an array for each line stored in the variable ip_addr
# before proceeding to apply a for loop for each line to print its index
# along with the line itself which contains the ip address of the vm.
# This is a dynamic code that scales with the number of addresses on the vm.

ip_addr=$(ip a | grep "inet " | awk '{print $2}')

readarray -t addr_list <<< $ip_addr

for addr_count in "${!addr_list[@]}"; do
  echo "  IP Address $addr_count: ${addr_list[$addr_count]}"
done

# The last section retrieves the vm's default gateway using the ip route
# command and using multiple pipes to send its output as the input for the
# grep command which only retrieves an entire line where a keyword passed off
# as the argument matches before passing its output again as input for the 
# awk command for display formatting

default_gw=$(ip route | grep "default" | awk '{print $3}')

echo -e "\n  IP Gateway:\t$default_gw"
