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

function createlogs {
	timestamp=$(date '+%d%m%Y-%H%M%S')
	name='apoorva'
	s3bucket='upgrad-apoorva'

	# create tar of log files and store in /temp
	sudo tar -cvf /tmp/$name-httpd-logs-$timestamp.tar /var/log/apache2/*.log

	# copy the tar log file from /tmp and store in s3
	aws s3 cp /tmp/$name-httpd-logs-$timestamp.tar s3://$s3bucket/
}

function serveronload {
	# Update the packages
	sudo apt update -y
	# check status
	checkstatus
	# Create logs with timestamp
	createlogs 
}

serveronload

