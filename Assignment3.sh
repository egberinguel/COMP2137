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

