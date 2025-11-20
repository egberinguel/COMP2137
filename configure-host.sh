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

function display_help {
	cat <<EOF
$(basename $0) [-h | --help]  [-name hostname]  [-ip ip address]  [-hostentry hostname]
	-h | --help	Display help and exit
	-name		Configure hostname
	-ip		Configure system IP address
	-hostentry	Update system host entry
	
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
	if [ ! -f /etc/netplan/*.yaml ]; then
		echo "There are no files existing in /etc/netplan/ ! Please ask for system administrator assistance."
		exit 1
	else
		if [ $(ls -l /etc/netplan | wc -l) -gt 2 ]; then
			echo "This script assumes there is only 1 file in /etc/netplan"
			echo "Exiting..."
			wait 2
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

if [ $# -eq 0 ]; then
	display_help
	exit
fi

while [ $# -gt 0 ]; do
	case "$1" in
		-h )
			display_help
			exit
			;;
		-name )
			hostscheck
			
			if [ "$unique_system_name" != "$2" ]; then
				echo "Changing hostname entry in /etc/hosts"
				sed -i "s/$unique_system_name/$2/" /etc/hosts
			else
				echo "Host entry is already set as $2"
			fi
			
			hostnamecheck
			if [ "$hostname_check" != "$2" ]; then
				hostnamectl hostname $2
			else
				echo "Hostname is already set as $2"
			fi
			
			shift
			;;
		-ip )
			ip_setting
			if [ "$current_address" != "$2" ]; then
				echo "Adjusting netplan configuration"
				sed -i "s/$current_address/$2/" /etc/netplan/$netplan_file
				netplan apply 2> /etc/null
				if [ $? -ne 0 ]; then
					echo "netplan failed to apply settings!"
					mv /etc/netplan/$netplan_file".bak" /etc/netplan/$netplan_file
					exit 1
				fi
			else
				echo "System netplan address is already set as $2"
			fi
			
			if [ "$ip_entry" != "$2" ]; then
				echo "Changing address entry in /etc/hosts"
				sed -i.bak "s/$ip_entry/$2/" /etc/hosts
			else
				echo "Host entry is already set as $2"
			fi
			
			shift
			;;
		-hostentry )
			hostscheck
			address_check=$(grep mgmt /etc/hosts -B 1 | awk '{ print $1 }'| head -n 1)
			if [[ ! $2 =~ ^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$ ]]; then
				if [ "$unique_system_name" != "$2" ]; then
					echo "Changing hostname entry in /etc/hosts to $unique_system_name"
					sed -i "s/$unique_system_name/$2/" /etc/hosts
				else
					echo "Host entry is already set as $2"
				fi
				
				if [ "$address_check" != "$3" ]; then
					echo "Changing address entry in /etc/hosts to $address_check"
					sed -i.bak "s/$address_check/$3/" /etc/hosts
				else
					echo "Address entry is already set as $3"
				fi
				
			else
				if [ "$unique_system_name" != "$3" ]; then
					echo "Changing hostname entry in /etc/hosts to $unique_system_name"
					sed -i "s/$unique_system_name/$3/" /etc/hosts
				else
					echo "Host entry is already set as $3"
				fi
				
				if [ "$address_check" != "$2" ]; then
					echo "Changing address entry in /etc/hosts to $address_check"
					sed -i.bak "s/$address_check/$2/" /etc/hosts
				else
					echo "Address entry is already set as $2"
				fi
			fi
			shift 2
			;;
		-verbose )
			echo "Verbose"
			exit
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
