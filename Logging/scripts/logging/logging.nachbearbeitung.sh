#!/bin/bash

#Postpreocessing, undo all modifications on host

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
rm -f interface

#Delete user cgroups

for i in {1..9}
	do
		if [ "$(lscgroup net_cls:/group$i)" = "net_cls:/group$i/" ]; then
			cgdelete net_cls:group$i
			echo User group$i deleted
		fi
	done

#Clear IPT-iptables

#########################Check-For-Iptables-Version-#####################
version=`cat /etc/lsb-release | grep DISTRIB_RELEASE | tr -d "DISTRIB_RELEASE=,\n" | cut -d '.' -f 1`

if [ $version -lt 16 ]; then
	##<16##
	IPT=/mnt/scratch/iptables/sbin/iptables
else
	##>16##
    	IPT=$(which iptables)
fi

$IPT -F

#########################EOF#############################################
