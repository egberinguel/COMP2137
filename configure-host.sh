#!/bin/bash

# Objectives:

#1. Script should not run without options, display help instead
#2. Options: verbose, name, ip, hostentry
#	name:	should confirm if the indicated name is configured on the hosts and hostname file
#		should update if not
#		accepts at most 1 argument
#		produce errors only when not running verbose
#		create system log entries if changes are made
#		should do major file checks and system checks
#		if an error is encountered that does not allow for file to change, exit script

#	ip:	should confirm the host's ip address on the hosts and netplan file
#		should update if not
#		accepts at most 1 argument
#		produce errors only when not running verbose
#		create system log entries if changes are made
#		if an error is encountered that does not allow for file to change, exit script

#	hostentry:	should confirm both name and ip on the hosts file ONLY
#			should update if not
#			accepts at most 1 argument
#			produce errors only when not running verbose
#			create system log entries if changes are made
#			if an error is encountered that does not allow for file to change, exit script

#	verbose:	will produce output even if no errors are encountered
trap '' TERM HUP INT

VERBOSE=false

function display_help {
	cat <<EOF
$(basename $0) [-h | --help]  [-name hostname]  [-ip ip address]  [-hostentry hostname] [-verbose]
	-h | --help	Display help and exit
	-name		Configure hostname
	-ip		Configure system IP address
	-hostentry	Update system host entry
	-verbose	Script will print debugging messages about its progress
	
EOF
}

declare -a host_check

function hostscheck {
	if [ ! -f /etc/hosts ]; then
		echo "/etc/hosts file does not exist! Please ask for system administrator assistance."
		exit 1
	else
		entry_check=$(grep -B 1 mgmt /etc/hosts | awk '{ print $2 }' | head -n 2)
		unique_system_name=$(grep -B 1 mgmt /etc/hosts | awk '{ print $2 }' | head -n 1)
	fi
}

function ip_setting {
	netplan_files=$(ls /etc/netplan/)
	
	if [ ${#netplan_files[@]} -eq 0 ]; then
		echo "There are no files existing in /etc/netplan/ ! Please ask for system administrator assistance."
		exit 1
	else
		if [ ${#netplan_files[@]} -ne 1 ]; then
			echo "This script assumes there is only 1 file in /etc/netplan"
			echo "Exiting..."
			exit 1
		else
			netplan_file="$(ls /etc/netplan)"
			current_address=$(grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" /etc/netplan/* | head -n 1)
		fi
	fi
	
	if [ ! -f /etc/hosts ]; then
		echo "/etc/hosts does not exist! Please ask for system administrator assistance."
		exit 1
	else
		ip_entry=$(grep -B 1 mgmt /etc/hosts | awk '{ print $1 }' | head -n 1)
	fi
}

function hostnamecheck {
	if [ ! -f /etc/hostname ]; then
		echo "/etc/hostname does not exist! Please ask for system administrator assistance."
		exit 1
	else
		current_hostname=$(cat /etc/hostname)
	fi
}

function vmsg {
	$VERBOSE && echo "$@"
}

if [ $# -eq 0 ]; then
	display_help
	exit
fi

for options in "$@"; do
	if [ "$options" = "-verbose" ]; then
		VERBOSE=true
		vmsg "Verbose mode enabled"
		vmsg ""
		break
	fi
done

while [ $# -gt 0 ]; do
	case "$1" in
		-h )
			display_help
			exit
			;;
		-name )
			hostscheck
			
			if [ "$unique_system_name" != "$2" ]; then
				vmsg "Changing hostname entry in /etc/hosts"
				sed -i "s/$unique_system_name/$2/" /etc/hosts
				logger "$(basename $0): Changing hostname entry in /etc/hosts to $2"				
			else
				vmsg "Host entry is already set as $2"
			fi
			
			hostnamecheck
			if [ "$current_hostname" != "$2" ]; then
				hostnamectl hostname $2
				logger "$(basename $0): Changing hostname to $2"
			else
				vmsg "Hostname is already set as $2"
			fi
			
			shift
			;;
		-ip )
			ip_setting
			if [ "$current_address" != "$2" ]; then
				vmsg "Adjusting netplan configuration"
				sed -i "s/$current_address/$2/" /etc/netplan/$netplan_file
				netplan apply 2> /dev/null
				logger "$(basename $0): Adjusting netplan configuration"
				if [ $? -ne 0 ]; then
					echo "netplan failed to apply settings!"
					mv /etc/netplan/$netplan_file".bak" /etc/netplan/$netplan_file
					exit 1
				fi
				
			else
				vmsg "System netplan address is already set as $2"
			fi
			
			if [ "$ip_entry" != "$2" ]; then
				vmsg "Changing address entry in /etc/hosts"
				sed -i.bak "s/$ip_entry/$2/" /etc/hosts
				logger "$(basename $0): Changing address entry to /etc/hosts"
			else
				vmsg "Host entry is already set as $2"
			fi
			
			shift
			;;
		-hostentry )			
			new_hostname="$2"
			new_addr="$3"
			
			grep -w $new_hostname /etc/hosts > /dev/null
			if [ $? -ne 0 ]; then
				grep -w $new_addr /etc/hosts > /dev/null
				if [ $? -ne 0 ]; then
					vmsg "Adding $3 $2 entry to /etc/hosts"
					echo "$3 $2" | sudo tee -a /etc/hosts > /dev/null
					logger "$(basename $0): Adding new entry to /etc/hosts"
				else
					old_hostname=$(grep -w $new_addr /etc/hosts | awk '{ print $2 }') 
					vmsg "Editing hostname in /etc/hosts"
					sudo sed -i -e "s/^$new_addr[[:space:]]\+$old_hostname/$new_addr $new_hostname/" /etc/hosts
					logger "$(basename $0): Editing hostname entry in /etc/hosts"
				fi
			else
				grep -w $new_hostname /etc/hosts | grep -w $new_addr > /dev/null
				if [ $? -ne 0 ]; then
					old_addr=$(awk -v h="$new_hostname" '$2 == h { print $1 }' /etc/hosts)
					vmsg "Editing address in /etc/hosts"
					sudo sed -i -e "s/^$old_addr[[:space:]]\+$new_hostname/$new_addr $new_hostname/" /etc/hosts
					logger "$(basename $0): Editing address entry in /etc/hosts"
				else
					vmsg "Entry $new_addr $new_hostname already exists in /etc/hosts"
				fi
			fi
			
			shift 2
			;;
		-verbose )
			;;
		* )
			echo "Invalid argument: '$1'"
			display_help
			exit 1
			;;

	esac
	shift
done

exit
