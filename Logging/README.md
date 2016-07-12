# Linux Logging Tool

This tool offers Linux traffic capturing and creation of a keyfile that holds the information to which process/script each packet belongs.

This project can be used in conjunction with [GPLMT](https://github.com/docmalloc/gplmt). The given examples use GPLMT for deployment and execution.

Dependencies:
=============

These are the direct dependencies for running the framework:

- Python >= 3.5.1
- scapy-python3 >= 0.18

- Linux Kernel >= 3.14

- iptables >= 1.6.0

- libnftnl library

- Dumpcap >= 2.0.2

The version numbers represent the versions we used at development.

Content
=============

scripts/
scripts for dataset creation, subdivided into logging attacks and traffic

tasklists/
gplmt tasklists needed to call the scripts

experiments/
gplmt experiment XML files

results/
Output folder for results

targets/
gplmt target definition XML files

docs/
documentation sources (e.g. pictures)

How to install?
===============

Python
--------

Check http://www.python.org/ how to setup Python for your OS

To install the required python3 modules, we recommend to use the pip3 
installer:

http://www.pip-installer.org/en/latest/index.html

scapy-python3 >= 0.18
--------

On GNU/Linux use: `sudo pip3 install scapy-python3`
Or check https://github.com/phaethon/scapy

Dumpcap
--------

On Ubuntu use: `sudo apt-get install wireshark-common`


![Topology](docs/Topology-eng.png)
This woderful readme is to be continued ... :shipit: