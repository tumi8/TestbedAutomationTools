#!/bin/bash

#Logging preparation, subnet

############Raise Network Input-buffer to max########################
#net.core.rmem_max = 2147483647#Max value
#Store current value for postprocessing

sudo cp /etc/sysctl.conf sysctl.conf.tmp
sudo cp /proc/sys/net/core/rmem_max default.tmp
sudo chmod 666 sysctl.conf.tmp
while IFS=' ' read -r f1
	do
		echo "net.core.rmem_max = $f1" >> sysctl.conf.tmp
	done < default.tmp
sudo chmod 644 sysctl.conf.tmp

sudo chmod 666 /etc/sysctl.conf
echo "net.core.rmem_max = 2147483647" >> /etc/sysctl.conf
sudo chmod 644 /etc/sysctl.conf

sudo sysctl -p

#####################Prepare files###################################

#Delete old, if present
rm -f pid.tmp
touch pid.tmp

#########################EOF#########################################