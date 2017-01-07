#!/bin/bash

#Move pre-started system processes into cgroups grouped by process owner
#remark: also one cgroup per pid possible

	#########################Check-For-System-Version-######################################
	version=`cat /etc/lsb-release | grep DISTRIB_RELEASE | tr -d "DISTRIB_RELEASE=,\n" | cut -d '.' -f 1`
	version2=`cat /etc/lsb-release | grep DISTRIB_RELEASE | tr -d "DISTRIB_RELEASE=,\n" | cut -d '.' -f 2`
	if [ $version -le 15 ] && [ $version2 -lt 10 ]; then
		##< Linux 16##
		IPT=/mnt/scratch/iptables/sbin/iptables

while IFS=' ' read -r f1
  do
    echo $f1

    ############obtain UID to PID######################################

    uid=$(awk '/^Uid:/{print $2}' /proc/$f1/status) 
    usrname=$(getent passwd "$uid" | awk -F: '{print $1}')
    echo $usrname

    ############check for existence of cgroup##########################

    echo Using group: process-$usrname
    if [ "$(lscgroup net_cls:/process-$usrname)" = "net_cls:/process-$usrname/" ]; then
	echo pid $f1 to existing group process-$usrname moved 
	cgclassify -g net_cls:process-$usrname $f1

    else
	#################Creating new cgroup###############################

	ClsID=`tail -n 1 cgroup.id.log | awk  {'print $0'} | tr -d '\n'` #get current ID from id file
	ClsIDnx=`tail -n 1 cgroup.id.log | awk  {'print $0+1'} | tr -d '\n'`

	cgcreate -a root -t root -g net_cls:process-$usrname
	echo $ClsID > /sys/fs/cgroup/net_cls/process-$usrname/net_cls.classid

	#########################Iptablles-Rules###########################

	interface=`head -n 1 interface`
	
	$IPT -A OUTPUT -o $interface -m cgroup --cgroup $ClsID -j CONNMARK --set-mark $ClsID
	$IPT -A INPUT  -i $interface -m connmark --mark $ClsID -j NFLOG --nflog-group $ClsID
	$IPT -A OUTPUT -o $interface -m connmark --mark $ClsID -j NFLOG --nflog-group $ClsID

	#########################Move and Write-Log########################

	cgclassify -g net_cls:process-$usrname $f1
	echo ";process-$usrname;"root\;root";$f1;"`date --iso-8601=seconds` >> cgroup.id.log #remark: pid to taskname conversion possible
	echo -n $ClsIDnx >> cgroup.id.log
	echo pid $f1 to new group process-$usrname moved  

	###################################################################

	fi

  done < /sys/fs/cgroup/net_cls/tasks
	else
		##> Linux 16, moving sys processes not working##
    		IPT=$(which iptables)
	fi
  #########################EOF#########################################
