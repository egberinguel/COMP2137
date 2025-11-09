#!/bin/bash

# Assignment 2 Script
# Elijah Beringuel, 200626887

# Goal 1: List all changes needed to be made.
# Goal 2: Keep the user notified of changes
# Goal 3: Errors should be produced in human-friendly information
# Goal 4: Must be able to run on the same machine without negatively affecting outcome

# Step 1: Change /etc/hosts file on server1 to have 192.168.16.21
# Step 2: Change the ip address to 192.168.16.21/24 on server1
# Step 3: Install softwares on server1 (apache2 & squid w/ default running config)
# Step 4: Create user accounts with a home directory in /home and bash as default shell
# Step 5: Created users must have ssh key pairs for RSA & ED25519 and must be added to their own ~/.ssh/authorized_keys file

#-------------------------------------------------------------------------------------------------------------
# Create a function for each system check

# First check return FALSE if server1 is not set to 192.168.16.21
function check_one {
	if [ -f /etc/hosts ]; then
		grep -we server1$ /etc/hosts
		hosts_file=$?
		
		if [ $hosts_file -ne 0 ]; then
			echo "server1 does not exist in /etc/hosts"
			exit 1
		fi
		
		ip_hosts=$(grep -we server1$ /etc/hosts | awk '{ print $1 }')
		if [ "$ip_hosts" != "192.168.16.21" ]; then
			echo "1. Need to adjust /etc/hosts file for server1 as 192.168.16.241"
			echo ""
			return 1
		else
			echo "1. First check success!"
			return 0
		fi
	else
		echo "Critical Error: /etc/hosts cannot be found"
		exit 1
	fi
}

# Second check return FALSE if address is not found in command "ip a"
function check_two {
	declare -a ip_addresses
	evaluate_addr+=$(ip a | grep -w inet | awk '{ print $2 }')

	for addr in "${evaluate_addr[@]}"; do
		ip_addresses+=("$addr")
	done

	for ip_tbe in "${ip_addresses[@]}"; do
		address_exist=0
		if [ "$ip_tbe" == "192.168.16.21/24" ]; then
			address_exist=1
			echo "2. Second check success!"
			return 0
		fi
	done
	
	if [ "$address_exist" -eq 0 ]; then
		echo "2. IP Address is not set to 192.168.16.21/24"
		return 1
	fi
}

function check_three {
	dpkg -l | grep -E '^ii' | grep "apache2 "
	if [ $? -ne 0 ]; then
		check_three_apache_value=0
		echo "3a. Apache not installed properly"
	else
		check_three_apache_value=1
		echo "3a. Apache is installed already"
	fi
	
	dpkg -l | grep -E '^ii' | grep "squid "
	if [ $? -ne 0 ]; then
		check_three_squid_value=0
		echo "3b. Squid not installed properly"
	else
		check_three_squid_value=1
		echo "3b. Squid is installed already"
	fi
}

# ONLY FOR CHECKING USER ACCOUNT EXISTS
# DOES NOT CHECK IF USER HAS HOME DIR OR BASH AS DEFAULT SHELL

users_in_passwd=$(awk -F : '{ print $1 }' /etc/passwd)
users_to_create=(dennis aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda)

# Declare an array containing user accounts
declare -a users_existing
for names in "${users_in_passwd[@]}"; do
	users_existing+=("$names")
done


function check_four {
	# Compare each user account in the array to each account in the /etc/passwd file
	for users_tbc in "${users_to_create[@]}"; do
		# All users by default are not created
		is_created=0
		for users in "${users_existing[@]}"; do
			# If user is found in /etc/passwd, then user is tagged as created
			if [ "$users_tbc" == "$users" ]; then
				echo "$users_tbc is created"
				is_created+=1
			fi
		done
		# Space for clarification
	done
	
	# After the for loop, if tag is still 0 then account is missing
	if [ "$is_created" -eq 0 ]; then
		echo "4. No user accounts have been created yet"
		return 1
	elif [ "$is_created" -lt 11 ]; then
		echo "4. $(( 11 - is_created )) users are missing"
		return 2
	else
		echo "4. All user accounts are present"
		return 0
	fi
}

function check_five {
	total_keys=0
	total_rsa=0
	total_ed25519=0
	for users_account in "${users_to_create[@]}"; do
		if [ -f /home/"$users_account"/.ssh/key_rsa ] && [ -f /home/"$users_account"/.ssh/key_rsa.pub ]; then
			total_keys+=1
			total_rsa+=1
		fi
		if [ -f /home/"$users_account"/.ssh/key_ed25519 ] && [ -f /home/"$users_account"/.ssh/key_ed25519.pub ]; then
			total_keys+=1
			total_ed25519+=1
		fi
	done
	
	echo -e "5. RSA keys present, $total_rsa.\n   ED25519 keys present, $total_ed25519.\n   Overall keys created, $total_keys."
	
	if [ $total_keys -eq 22 ]; then
		return 0
	elif [ $total_keys -eq 0 ]; then
		return 1
	else
		return 2
	fi
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# MAIN

check_one
if [ $? -ne 0 ]; then
	echo "Adjusting /etc/hosts file for server1"
	sed -i -E '/server1$/s/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/192\.168\.16\.241/' /etc/hosts
else
	break
fi

check_two
if [ $? -ne 0 ]; then
	if [ -f /etc/netplan/10-lxc.yaml ]; then
		echo "Changing IP Address to 192.168.16.21"
		sed -i -E '0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/{s/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/192\.168\.16\.21/}' /etc/netplan/10-lxc.yaml
		netplan apply
		
		if [ $? -ne 0 ]; then
			echo "netplan failed to apply changes"
			exit 1
		fi
	else
		echo "YAML file does not exit in netplan"
		exit 1
else
	echo "IP Address is properly set"
fi

# Figure out how to verify check_three
check_three
if [ $check_three_apache_value = 0 ]; then
	sudo apt install apache2 -y
else
	continue

if [ $check_three_squid_value = 0 ]; then
	sudo apt install squid -y
else
	continue
	

check_four
check_four_rv=$?

if [ $check_four_rv -eq 1 ]; then
	echo "Users are all created"
elif [ $check_four_rv -eq 0 ]; then
	echo "Creating all users..."
	for each_user in "${#users_to_create[@]}"; do
		# Edit to add ssh public keys as well for this specific user
		useradd $each_user -m -s /bin/bash
		
		# Check if user is 'dennis'
		if [ $each_user == "dennis" ]; then
			usermod -aG $each_user sudo
			echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" >> /home/$each_user/.ssh/authorized_keys
		fi
	done
elif [ $check_four_rv -eq 2 ]; then
	echo "Some users are missing"
fi

check_five
check_five_rv=$?

if [ $check_five_rv -eq 0 ]; then
	echo "Keys are all created"
elif [ $check_five_rv -eq 1 ]; then
	echo "Creating all keys..."
	for each_user in "${#users_to_create[@]}"; do
		# Check user's RSA keys exist
		if [ -f /home/$each_user/.ssh/key_rsa ]; then
			continue
		else
			# Create RSA Keys and add to authorized_keys file
			ssh-keygen -t rsa -C "$each_user@$HOSTNAME" -f /home/$each_user/.ssh/key_rsa
			echo /home/$each_user/.ssh/key_rsa.pub >> /home/$each_user/.ssh/authorized_keys
		fi

		# Check user's ED25519 keys exist
		if [ -f /home/$each_user/.ssh/key_ed25519 ]; then
			continue
		else
			# Create ED25519 Keys and add to authorized_keys file
			ssh-keygen -t ed25519 -C "$each_user@$HOSTNAME" -f /home/$each_user/.ssh/key_ed25519
			echo /home/$each_user/.ssh/key_ed25519.pub >> /home/$each_user/.ssh/authorized_keys
		fi
		
		echo "SSH keys for user $each_user created and added to authorized_keys file"
	done
elif [ $check_five_rv -eq 2 ]; then
	echo "Some keys are missing"
	for keys_tbc in "${users_to_create[@]}"; do
		# All users by default are not created
		keys_created=0
		for keys_existing in "${users_existing[@]}"; do
			if [ "$keys_tbc" == "$keys_existing" ]; then
				continue
			else
				# Check user's RSA keys exist
				if [ -f /home/$each_user/.ssh/key_rsa ]; then
					continue
				else
					# Create RSA Keys and add to authorized_keys file
					ssh-keygen -t rsa -C "$each_user@$HOSTNAME" -f /home/$each_user/.ssh/key_rsa
					echo /home/$each_user/.ssh/key_rsa.pub >> /home/$each_user/.ssh/authorized_keys
				fi

				# Check user's ED25519 keys exist
				if [ -f /home/$each_user/.ssh/key_ed25519 ]; then
					continue
				else
					# Create ED25519 Keys and add to authorized_keys file
					ssh-keygen -t ed25519 -C "$each_user@$HOSTNAME" -f /home/$each_user/.ssh/key_ed25519
					echo /home/$each_user/.ssh/key_ed25519.pub >> /home/$each_user/.ssh/authorized_keys
				fi
			keys_created=1
		done
	done
fi
