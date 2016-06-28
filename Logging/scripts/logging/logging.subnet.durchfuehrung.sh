#!/bin/bash

#Start dumpcap for packet capturing

net=$1     #local network number
iface=$2   #monitor interface

#-P: output as pcap not pcapng, does not work on multiple interfaces
dumpcap -n -q -B 1000 -i $iface -w local-network$net.pcapng  &>> dumpcap.log &
echo $! >> pid.tmp