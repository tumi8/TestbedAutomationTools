#!/bin/bash

#Central script for enabeling logging of commands and scrips
#For help run ./cgroup.create -h
#########################Check-For-Iptables-Version-######################################
version=`cat /etc/lsb-release | grep DISTRIB_RELEASE | tr -d "DISTRIB_RELEASE=,\n" | cut -d '.' -f 1`

#Check for Linux Version, 16 uses iptables > v1.6.0
if [ $version -lt 16 ]; then
	##<Linux 16##
	IPT=/mnt/scratch/iptables/sbin/iptables
else
	##>Linux 16##
   	 IPT=$(which iptables)
fi

#########################Check-For-Usage-Cases-############################################

case $1 in

#########################User-Group-Case###################################################
  -u| -U ) #user group usage indicated with -u, first group ID then process

shift

if [[ $1 != [0-9]* ]]; then #check if given ID is int
	
	echo "user group must be int"

else

	if [ $1 -lt 10 ] && [ $1 -gt 0 ]; then #check whether $1 is a valid user group
		param=$1
		shift
		echo Using group$param

		if [ "$(lscgroup net_cls:/group$param)" = "net_cls:/group$param/" ]; then #check if cgroup already exists

			echo command in existing group$param executed 
			cgexec -g net_cls:group$param $*
			sed -i "2i $param;group$param;root\;root;$*;`date --iso-8601=seconds`" cgroup.id.log

		else #if cgroup does not exist, create it

			cgcreate -a root -t root -g net_cls:group$param
			echo $param > /sys/fs/cgroup/net_cls/group$param/net_cls.classid

			#########################Iptablles-Rules###########################

			interface=`head -n 1 interface` #get logging interface
			
			$IPT -A OUTPUT -o $interface -m cgroup --cgroup $param -j CONNMARK --set-mark $param
			$IPT -A INPUT  -i $interface -m connmark --mark $param -j NFLOG --nflog-group $param
			$IPT -A OUTPUT -o $interface -m connmark --mark $param -j NFLOG --nflog-group $param

			#########################Write logfile#############################

			sed -i "2i $param;group$param;root\;root;$*;`date --iso-8601=seconds`" cgroup.id.log 

			#########################Execute command############################

			cgexec -g net_cls:group$param $*
			echo command in new group$param executed
		fi
	else

		echo Only 1-9 allowed as user groups. First parameter must be either a user Group ID or an aplphanumeric scripname!

	fi
fi;;

#########################Move-Case#########################################################
  -m| --move ) #move existing processes to user-group, usage indicated with -m, first group then task/s(pid), separated by space

shift

if [[ $1 != [0-9]* ]]; then
	echo "user group task is moved to must be int"

else


	if [ $1 -lt 10 ] && [ $1 -gt 0 ]; then #check whether $1 is a valid user group
		param=$1
		shift
		echo Using group$param
		if [ "$(lscgroup net_cls:/group$param)" = "net_cls:/group$param/" ]; then
			echo task to existing group$param moved 
			cgclassify -g net_cls:group$param $*
		else
			cgcreate -a root -t root -g net_cls:group$param
			echo $param > /sys/fs/cgroup/net_cls/group$param/net_cls.classid

			#########################Iptablles-Rules###########################

			interface=`head -n 1 interface` #get logging interface
			
			$IPT -A OUTPUT -o $interface -m cgroup --cgroup $param -j CONNMARK --set-mark $param
			$IPT -A INPUT  -i $interface -m connmark --mark $param -j NFLOG --nflog-group $param
			$IPT -A OUTPUT -o $interface -m connmark --mark $param -j NFLOG --nflog-group $param

			#########################Write logfile#############################

			#echo "$param;group$param;"root\;root";$*;"`date --iso-8601=seconds` >> cgroup.id.log ###############################################################################

			#########################Execute command############################

			cgclassify -g net_cls:group$param $*
			echo task to new group$param moved
		fi
	else

		echo Only 1-9 allowed as user groups. First parameter must be either a user Group or an aplphanumeric scripname!

	fi
fi;;

#########################Lookup-Case######################################################
  -l| --lookup ) #show cgroup to pid
  
  shift

  cat /proc/$1/cgroup
  
  ;;

#########################Help-Case########################################################
  -h| --help )

  echo "Usage:  cgroup.create <scriptname | command> to execute in a new cgroup or"
  echo "	cgroup.create -u <user-group> <scriptname | command> to execute in a new or existing user-cgroup (user-group: 1-9) or"
  echo "	cgroup.create -m <user-group> <pids> to move existing processes to user-cgroup, pids separated by spaces (user-group: 1-9) or"
  echo "	cgroup.create -l <pid> to show corresponding cgroup to pid"
  
  ;;

#########################Empty-Case########################################################
  "" )
 
  echo No parameter specified, call a script or command or either -h or --help for help;;

#########################Script-Case#######################################################  
 
  * )
  
	######################Read-ID-File+Params##################################

ClsID=`tail -n 1 cgroup.id.log | awk  {'print $0'} | tr -d '\n'` #get current ID from id file
ClsIDnx=`tail -n 1 cgroup.id.log | awk  {'print $0+1'} | tr -d '\n'`
COMD=$1 #Shifted input param: Script or Command

GrpName=`echo $COMD"-"$ClsID | tr -d "\./"` #create new grooupname from command and ID

echo $GrpName

	#########################Create-Cgroup+Set-ID##############################

cgcreate -a root -t root -g net_cls:$GrpName 
#(https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Resource_Management_Guide/sec-Creating_Cgroups.html)

#-t <tuid>:<tgid>
#    defines the name of the user and the group, which owns tasks file of the defined control group. I.e. this user and members of this group have write access to the file. The default value is the same as has the parent cgroup. 
#-a <agid>:<auid>
#    defines the name of the user and the group, which owns the rest of the defined control group's files. These users are allowed to set subsystem parameters and create subgroups. The default value is the same as has the parent cgroup. 

echo $ClsID > /sys/fs/cgroup/net_cls/$GrpName/net_cls.classid

	#########################Iptablles-Rules###################################

interface=`head -n 1 interface` #get logging interface

$IPT -A OUTPUT -o $interface -m cgroup --cgroup $ClsID -j CONNMARK --set-mark $ClsID
$IPT -A INPUT  -i $interface -m connmark --mark $ClsID -j NFLOG --nflog-group $ClsID
$IPT -A OUTPUT -o $interface -m connmark --mark $ClsID -j NFLOG --nflog-group $ClsID

	#########################Write-Log#########################################

echo ";$GrpName;"root\;root";$COMD;"`date --iso-8601=seconds` >> cgroup.id.log
echo -n $ClsIDnx >> cgroup.id.log

	#########################Command-Execution#################################

cgexec -g net_cls:$GrpName $*

	#########################Cleanup###########################################

cgdelete net_cls:$GrpName #delete cgroup and rules after execution

$IPT -D OUTPUT -o $interface -m cgroup --cgroup $ClsID -j CONNMARK --set-mark $ClsID
$IPT -D INPUT  -i $interface -m connmark --mark $ClsID -j NFLOG --nflog-group $ClsID
$IPT -D OUTPUT -o $interface -m connmark --mark $ClsID -j NFLOG --nflog-group $ClsID

;;

esac

#########################EOF################################################################
