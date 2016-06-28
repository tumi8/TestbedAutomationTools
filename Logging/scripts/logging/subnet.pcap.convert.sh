#!/bin/bash

#Conversion from pcapng to pcap using editcap
net=$1

editcap -F pcap local-network$net.pcapng local-network$net.pcap