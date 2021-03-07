#!/bin/bash

function checkstatus {
	# check if apache 2 is installed or not 
	if $(dpkg --get-selections | grep -q 'apache'); then
		# Check apache2 status
		if [ $(sudo systemctl status apache2 | grep -wc 'active (running)') -ne 0 ]; then
			echo 'apache2 is running.'
		else
			# Start apache2
			echo 'Starting apache2.....' 
			sudo systemctl start apache2
			echo 'apache2 is running.'
		fi

		# Check if apache2 is enabled
		if [ $(sudo systemctl is-enabled apache2) != 'enabled' ]; then
			# Enable apache2
			echo 'Enabling apache2.....'
			sudo systemctl enable apache2
			echo 'apache2 is enabled.'
		else
			echo 'apache2 is enabled.'
		fi
	else
		# Install apache2
		echo y | sudo apt-get install apache2
	fi
}

function createinventory {
	filepath='/var/www/html/'
	htmlfilename='inventory.html'
	fullpath="$filepath$htmlfilename"
	filesize=$(ls -lh /tmp/$2 | cut -d ' ' -f5)
	record="<div><span>httpd-logs</span>\t<span>$1</span>\t<span>tar</span>\t<span>$filesize</span></div>"
	if $(ls -l $filepath | grep -q $htmlfilename); then
		echo "$htmlfilename exists"
		printf $record >> $fullpath
	else
		echo "Creating $htmlfilename....."
		printf '<style>body {display: flex; flex-direction: column; align-items: center;}</style><div><b>Log Type</b>\t<b>Time Created</b>\t<b>Type</b>\t<b>Size</b></div>' >> $fullpath
		printf $record >> $fullpath
	fi
}

function createcron {
	filepath='/etc/cron.d/'
	filename='automation'
	fullpath="$filepath$filename"
	if ! (( $(ls -l $filepath | grep -q $filename) )); then
		echo 'Automation'
		echo '* * * * * root /root/Automation_Project/automation.sh' > $fullpath
	fi
}


function createlogs {
	timestamp=$(date '+%d%m%Y-%H%M%S')
	name='apoorva'
	s3bucket='upgrad-apoorva'
	filename="$name-httpd-logs-$timestamp.tar"

	# create tar of log files and store in /temp
	sudo tar -cvf /tmp/$filename /var/log/apache2/*.log

	# copy the tar log file from /tmp and store in s3
	aws s3 cp /tmp/$filename s3://$s3bucket/

	# create inventory file and append the result
	createinventory $timestamp $filename
}

function serveronload {
	# Update the packages
	sudo apt update -y
	# check status
	checkstatus
	# Create logs with timestamp
	createlogs
	# Create cron job
	createcron 	
}

serveronload



