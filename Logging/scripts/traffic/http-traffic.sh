#!/bin/bash

#Creating http-traffic using wget, no parameter required, urls stored in urls.txt

wget -r  -l3 -nd --delete-after -U "firefox" -i urls.txt