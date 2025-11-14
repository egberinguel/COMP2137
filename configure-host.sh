#!/bin/bash

"""
Create a script named configure-host.sh to configure some basic host settings. The settings to configure will be given on the command line. If the settings are already in place, the script will do nothing and make no output unless running in verbose mode. Any settings not already in place will be configured and applied, producing no output unless errors are encountered, or running in verbose mode. The script must ignore TERM, HUP and INT signals.

Command line arguments to be accepted:
-verbose
•	this option will enable verbose output while the script runs

-name desiredName
•	 this option will confirm the host has the desired name, updating it if necessary in both the /etc/hosts file and the /etc/hostname file
•	 it will also apply the desired name to the running machine if it is being changed from an existing setting
•	 if running in verbose mode, the script will tell the user about any changes made, or if no changes were necessary
•	 if not running in verbose mode, the script will only produce output if errors are encountered
•	 if changes are made, an entry is sent to the system log using the logger program describing the changes

-ip desiredIPAddress
•	 this option will confirm the host's laninterface has the desired IP address, updating it if necessary in both the /etc/hosts file and the netplan file
•	 it will also apply the desired IP address to the running machine if it is being changed from an existing setting
•	 if running in verbose mode, the script will tell the user about any changes made, or if no changes were necessary
•	 if not running in verbose mode, the script will only produce output if errors are encountered
•	 if changes are made, an entry is sent to the system log using the logger program describing the changes

-hostentry desiredName desiredIPAddress
•	 this option will confirm the host name and IP address are in the /etc/hosts file, updating it if necessary
•	 if running in verbose mode, the script will tell the user about any changes made, or if no changes were necessary
•	 if not running in verbose mode, the script will only produce output if errors are encountered
•	 if changes are made, an entry is sent to the system log using the logger program describing the changes
"""

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

function hosts_check {

}

function netplan_check {

}

function hostname_check {

}

while [ $# -gt 0 ]; do
	case "$1" in
		-h )
			display_help
			exit
			;;
		-name )
			hosts_check
			hostname_check
			exit
			;;
		-ip )
			netplan_check
			hosts_check
			exit
			;;
		-hostentry )
			hosts_check
			exit
			;;
		* )
			echo "Invalid argument: '$1'"
			exit 1
			;;
	esac
	# Maybe shift twice because of arguments???
	shift
done
	
