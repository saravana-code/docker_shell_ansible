#!/bin/bash
# system_info.sh - shell script to to get information about your  Linux server / desktop.
# Author: Saravana
# Date: 12/01/2018
#version:1

# Define variables
LSB=/usr/bin/lsb_release

# Purpose: Display pause prompt
# $1-> Message (optional)
function pause(){
	local message="$@"
	[ -z $message ] && message="Press [Enter] key to continue..."
	read -p "$message" readEnterKey
}

# Purpose  - Display a menu on screen
function show_menu(){
    date
    echo "---------------------------"
    echo "   Main Menu"
    echo "---------------------------"
	echo "o. Operating system info"
	echo "c. Number of CPU cores"
	echo "d. Disk info"
	echo "m. memory info without arg"
	echo "k. memory info KB"
	echo "g. memory info GB"
	echo "f. firewall status"
	echo "s. selinux status"
	echo "p. process counts"
	echo "l. process listening"
	echo "e. exit"
}

# Purpose - Display header message
# $1 - message
function write_header(){
	local h="$@"
	echo "---------------------------------------------------------------"
	echo "     ${h}"
	echo "---------------------------------------------------------------"
}

# Purpose - Get info about your operating system
function os_info(){
	write_header " System information "
	echo "Operating system : $(uname)"
	[ -x $LSB ] && $LSB -a || echo "$LSB command is not insalled (set \$LSB variable)"
	#pause "Press [Enter] key to continue..."
	pause
}

# Purpose - Display total CPU cores
function cpu_info(){
	write_header " Total number of CPU cores "; nproc; pause
}

# Purpose - Display used and free memory info
function mem_info(){
	write_header " Free and used memory "
	free -g
	local cmd="$1"
        case "$cmd" in
                k) write_header " Memory info in KB "; free -k ; pause ;;
                m) write_header " Memory info in MB "; free -m ; pause ;;
                g) write_header " Memory info in GB "; free -g ; pause ;;
        esac
    
        pause
}
# Purpose - Display whether firewall is enabled or not
function firewall_info(){
        write_header " Firewall service status "
        systemctl status firewalld.service | grep -i active
	ufw status verbose
	
        pause
}
# Purpose - Display whether selinux is enabled or not
function selinux_info(){
        write_header " selinux running status "
	sestatus
	cat /etc/selinux/config | grep 'SELINUX='
        pause
}

# Purpose - Display disk info:
function disk_info(){
        write_header "Disk information "
	echo "****************************************"
        echo "*** Total available disk on the system  ***"
        echo "****************************************"
        fdisk -l
	echo "***********************"
        echo "*** Mounted partitions ***"
        echo "***********************"
	df -h
	echo "*******************************"
        echo "*** List of all block devices ***"
        echo "*******************************"
	lsblk
        pause
}
function process_info(){
        write_header " Total number of processes "
	ps aux | awk '{print $2}' | sed  "1d" |wc -l
        pause
}

function listening_info(){
        write_header " Processes listen "
	netstat -nap
        pause
}
# Purpose - Get input via the keyboard and make a decision using case..esac 
function read_input(){
	local c
	read -p "Enter your choice on below alphabets " c
	case $c in
		o)	os_info ;;
		s)	selinux_info ;;
		c)	cpu_info ;;
		d)	disk_info ;;
		m)	mem_info ;;
		k)	mem_info "k" ;;
		g)	mem_info "g" ;;
		m)	mem_info "m" ;;
		f)	firewall_info ;;
		p)	process_info ;;
		l)	listening_info ;;
		e)	echo "Bye!"; exit 0 ;;
		*)	
			echo "Please select between 1 to 7 choice only."
			pause
	esac
}

# ignore CTRL+C, CTRL+Z and quit singles using the trap
trap '' SIGINT SIGQUIT SIGTSTP

# main logic
while true
do
	clear
 	show_menu	# display memu
 	read_input  # wait for user input
done
