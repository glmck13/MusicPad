#!/bin/bash

while true
do
	sleep 30
	ssh -t -o ServerAliveInterval=60 -o ServerAliveCountMax=3 -R localhost:8122:localhost:22 pi@mckspot.net sleep 3600
done
