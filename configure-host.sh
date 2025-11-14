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
${basename $0} [-h] [-name hostname] [-ip ip_address] [-hostentry hostentry]
	-h		display help and exit
	-name		configure hostname
	-ip		configure system IP address
	-hostentry	update system host entry
EOF
}

function hostscheck {
	if [ ! -f /etc/hosts ]; then
		echo "/etc/hosts file does not exist! Please ask for system administrator assistance."
		exit 1
	else
		# Add $ if not including mgmt entries
		host_check=$(grep -E "server[0-9]+" /etc/hosts)
	fi
}

function netplancheck {
	echo "netplan check"
}

function hostnamecheck {
	# Must return a variable
}

while [ $# -gt 0 ]; do
	case "$1" in
		-h )
			display_help
			exit
			;;
		-name )
			hostscheck
			if [ $host_check != $2 ]; then
				sed -i.bak -e 's/server[0-9]\+/hostname/' /etc/hosts
			else
				echo "Host entry is already set as $2"
			fi
			
			hostnamecheck
			if [ $hostname_check != $2 ]; then
				hostnamectl hostname $2
			else
				echo "Hostname is already set as $2"
			fi
			exit
			;;
		-ip )
			netplancheck
			hostscheck
			exit
			;;
		-hostentry )
			hostscheck
			exit
			;;
		* )
			echo "Invalid argument: '$1'"
			exit 1
			;;
	esac
	# Maybe shift twice because of arguments???
	shift 2
done


