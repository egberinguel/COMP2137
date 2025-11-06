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
# Call system checks first to evaluate needed changes
# Create a function for each check

step_one=$(grep -we server1$ /etc/hosts | awk '{ print $1 }')

# First check return FALSE if server1 is not set to 192.168.16.21
function check_one {
	if [ $step_one != "192.168.16.21" ]; then
		check_one_value=0
	else
		check_one_value=1
	fi
	
	if [ $check_one_value -ne 1 ]; then
		echo "First check failed:	Need to adjust /etc/hosts file for server1 as 192.168.16.241"
	else
		echo "First check success!"
	fi
}

# Second check return FALSE if address is not found in command "ip a"
function check_two {
	declare -a ip_addresses
	evaluate_addr+=$(ip a | grep -w inet | awk '{ print $2 }')

	for addr in ${evaluate_addr[@]}; do
		ip_addresses+=("$addr")
	done

	for ip_tbe in ${ip_addresses[@]}; do
		address_exist=0
		if [ $ip_tbe == "192.168.16.21/24" ]; then
			check_two_value=1
			$address_exist=1
			echo "Second check success!"
			break
		fi
	done
	
	if [ $address_exist -eq 0 ]; then
		check_two_value=0
		echo "Second check failed:	IP Address is not set to 192.168.16.21/24"
	fi
}

function check_three {
	dpkg -l | grep -E '^ii' | grep "apache2 "
	if [ $? -ne 0 ]; then
		check_three_apache_value=0
		echo "Apache check failed:	Apache not installed properly"
	else
		check_three_apache_value=1
		echo "Apache is installed already"
	fi
	
	dpkg -l | grep -E '^ii' | grep "apache2 "
	if [ $? -ne 0 ]; then
		check_three_squid_value=0
		echo "Squid check failed:	Squid not installed properly"
	else
		check_three_squid_value=1
		echo "Apache is installed already"
	fi
}

# ONLY FOR CHECKING USER ACCOUNT EXISTS
# DOES NOT CHECK IF USER HAS HOME DIR OR BASH AS DEFAULT SHELL

users_in_passwd=$(cat /etc/passwd | awk -F : '{ print $1 }')
users_to_create=(dennis aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda)

# Declare an array containing user accounts
declare -a users_existing
for names in ${users_in_passwd[@]}; do
	users_existing+=("$names")
done


function check_four {
	# Compare each user account in the array to each account in the /etc/passwd file
	for users_tbc in ${users_to_create[@]}; do
		# All users by default are missing
		is_created=0
		for users in ${users_existing[@]}; do
			# If user is found in /etc/passwd, then user is tagged as created
			if [ $users_tbc == $users ]; then
				echo "$users_tbc is created"
				is_created=1
			fi
		done
		# Space for clarification
		# After the for loop, if tag is still 0 then account is missing
		if [ $is_created -ne 1 ]; then
			echo "$users_tbc is missing"
		fi
	done
}

function check_five {
	for users_accounts in ${users_to_create[@]}; do
		if [ -f /home/$users_accounts/.ssh/key_rsa ] && [ -f /home/$users_accounts/.ssh/key_rsa.pub ]; then
			echo "RSA Keys created properly for $users_accounts"
			check_five_rsa_value=1
		else
			echo "RSA Keys missing for $users_accounts"
			check_five_rsa_value=0
		fi
			
		if [ -f /home/$users_accounts/.ssh/key_ed25519 ] && [ -f /home/$users_accounts/.ssh/key_ed25519.pub ]; then
			echo "ED25519 Keys created properly for $userusers_accounts_acc"
			check_five_ed25519_value=1
		else
			echo "ED25519 Keys missing for $users_accounts"
			check_five_ed25519_value=0
		fi
		
		echo ""
	done
}

check_one()



"""
check_one_value=FALSE
check_two_value=FALSE
check_three_apache_value=FALSE
check_three_squid_value=FALSE
check_four_value=FALSE
check_five_value=FALSE
"""



# Might(?) need to use for loop here or combine with previous step
# File manipulation
"""
if [ $step_one != "192.168.16.21" ]; then
	sed -i -E '/server1$/s/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/192\.168\.16\.241/' file1	
	check_one=TRUE
else
	check_one=TRUE	
fi


 FOR STEP FOUR
for user_acc in $users; do
	useradd $user_acc -m -s /bin/bash

	# Create RSA Keys and add to authorized_keys file
	ssh-keygen -t rsa -C "$user_acc@$HOSTNAME" -f /home/$user_acc/.ssh/key_rsa
	echo /home/$user_acc/.ssh/key_rsa.pub >> /home/$user_acc/.ssh/authorized_keys

	# Create ED25519 Keys and add to authorized_keys file
	ssh-keygen -t ed25519 -C "$user_acc@$HOSTNAME" -f /home/$user_acc/.ssh/key_ed25519
	echo /home/$user_acc/.ssh/key_ed25519.pub >> /home/$user_acc/.ssh/authorized_keys
done
"""
