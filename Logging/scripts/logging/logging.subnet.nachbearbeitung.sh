#!/bin/bash

#Postpreocessing, undo all modifications on host, subnet

###################kill processes stored in pid.txt######################

if [ -f pid.tmp ]
	then

	while read line
		do
			sudo kill $line
		done < pid.tmp

	echo "Processes stopped"
fi

####################restore host#########################################

#reset buffer
if [ -f sysctl.conf.tmp ]
	then

	sudo cp sysctl.conf.tmp /etc/sysctl.conf
	sudo sysctl -p

	#remove the afore appended last line of /etc/sysctl.conf 
	sed -i '$d'  /etc/sysctl.conf
fi

#remove all temporary files
rm -f pid.tmp
rm -f default.tmp
rm -f sysctl.conf.tmp

#########################EOF#############################################