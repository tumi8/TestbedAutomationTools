#!/bin/bash

#Portscan using Netcat

#Parameter
dstip=$1       #victim IP-address
range=$2       #portrange to be scanned
waiting=$3     #optional delay time

echo "Netcat initiated, starting in $waiting seconds"

sleep $waiting

echo "starting portscan"
nc -zv $dstip $range;