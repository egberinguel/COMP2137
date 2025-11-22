#!/bin/bash
# This script runs the configure-host.sh script from the current directory to modify 2 servers and update the local /etc/hosts file

VERBOSE=false

function display_help {
	cat <<EOF
$(basename $0) [OPTIONAL: -verbose]
	-verbose	Script will print debugging messages about its progress
	
EOF
}

function vmsg {
	$VERBOSE && echo "$@"
}

while [ $# -gt 0 ]; do
	case "$1" in
		-verbose )
			VERBOSE=true
			echo "Verbose mode enabled for lab3.sh script"
		;;
		
		* )
			echo "Invalid option"
			echo ""
			display_help
			exit 1
		;;
	esac
	shift
done

if [ -f ./configure-host.sh ]; then
	machines=(server1 server2)
	
	if [ "$VERBOSE" = true ]; then
		VERBOSE_OPT="-verbose"
	fi

	for container in ${machines[@]}; do
		vmsg ""
		ssh-keyscan $container-mgmt >> ~/.ssh/known_hosts 2> /dev/null
		vmsg "Copying configure-host.sh script over to $container"
		scp configure-host.sh remoteadmin@$container-mgmt:/root > /dev/null
		[ $? -ne 0 ] && bash -c 'echo "scp was unable to send script to remote machines" ; exit 1'

		vmsg "Configuring $container..."
				
		case $container in
			server1 )
				ssh remoteadmin@server1-mgmt -- "/root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4 $VERBOSE_OPT"
				;;
			server2 )
				ssh remoteadmin@server2-mgmt -- "/root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3 $VERBOSE_OPT"
				;;
		esac
	done
	
	vmsg ""
	vmsg "Adding new entries to local /etc/hosts file"
	logger "$(basename $0): Adding new entries to /etc/hosts"
	./configure-host.sh -hostentry loghost 192.168.16.3
	./configure-host.sh -hostentry webhost 192.168.16.4
else
	echo "Script does not exist in this directory!"
	exit 1
fi


