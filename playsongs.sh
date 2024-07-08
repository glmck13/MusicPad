#!/bin/ksh

#set -x

CDN=$HOME/venv/cdn
QUEUE=$HOME/venv/queue

cd $QUEUE; rm -f *

while true
do
	if [ -f exit ]; then
		rm -f exit
		break
	fi

	song=$(ls -1rt | head -n 1)

	if [ ! "$song" ]; then
		sleep 3
		continue
	fi

	rm -f "$song"

	song=${song#*:} song=${song//://}
	mpg123 $CDN/$song 2>/dev/null
done
