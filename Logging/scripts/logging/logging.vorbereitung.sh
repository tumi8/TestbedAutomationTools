#!/bin/bash

#Logging preparation

#Parameter: interface to be captured from

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
rm -f interface
echo $1 >> interface

#####################Iptablles-Rules#################################

#########################Check-For-Iptables-Version-#################
version=`cat /etc/lsb-release | grep DISTRIB_RELEASE | tr -d "DISTRIB_RELEASE=,\n" | cut -d '.' -f 1`

if [ $version -lt 16 ]; then
	##<16##
	IPT=/mnt/scratch/iptables/sbin/iptables
else
	##>16##
    	IPT=$(which iptables)
fi

#root group
$IPT -A OUTPUT -o $1 -m cgroup --cgroup 0 -j CONNMARK --set-mark 0
$IPT -A INPUT  -i $1 -m connmark --mark 0 -j NFLOG --nflog-group 0
$IPT -A OUTPUT -o $1 -m connmark --mark 0 -j NFLOG --nflog-group 0

#User default group, deprecated
#$IPT -A OUTPUT -o $1 -m cgroup --cgroup 1 -j CONNMARK --set-mark 1
#$IPT -A INPUT  -i $1 -m connmark --mark 1 -j NFLOG --nflog-group 1
#$IPT -A OUTPUT -o $1 -m connmark --mark 1 -j NFLOG --nflog-group 1

#2nd default group, deprecated
#$IPT -A OUTPUT -o $1 -m cgroup --cgroup 2 -j CONNMARK --set-mark 2
#$IPT -A INPUT  -i $1 -m connmark --mark 2 -j NFLOG --nflog-group 2
#$IPT -A OUTPUT -o $1 -m connmark --mark 2 -j NFLOG --nflog-group 2

#########################EOF#########################################
