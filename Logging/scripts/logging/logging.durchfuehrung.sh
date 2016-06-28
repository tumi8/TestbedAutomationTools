#!/bin/bash

#Start dumpcap for packet capturing

#-P: output as pcap not pcapng, does not work on multiple interfaces
dumpcap -q -n -B 1000 -i nflog:$(echo {0..31} | tr ' ' ',') -w allin1.pcapng &>> dumpcap.log &
echo $! >> pid.tmp

echo "Logging started"