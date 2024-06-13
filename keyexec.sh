#!/bin/ksh

#set -x

typeset -A action
action["MSG_WELCOME"]="play"
action["KEY_BACKSPACE"]="play"
action["KEY_KPMINUS"]="list- play"
action["KEY_KPPLUS"]="list+ play"
action["KEY_ENTER"]="play"
action["KEY_KPSLASH"]="play"
action["KEY_KPASTERISK"]="play"
action["KEY_DELETE"]="skip"
action["KEY_KPDOT"]="skip"
action["KEY_KP0"]=""
action["KEY_INSERT"]=""
action["KEY_KP1"]="play"
action["KEY_END"]="play"
action["KEY_KP2"]="play"
action["KEY_DOWN"]="play"
action["KEY_KP3"]="play"
action["KEY_PAGEDOWN"]="play"
action["KEY_KP4"]="play"
action["KEY_LEFT"]="play"
action["KEY_KP5"]=""
action["KEY_KP6"]="play"
action["KEY_RIGHT"]="play"
action["KEY_KP7"]="play"
action["KEY_HOME"]="play"
action["KEY_KP8"]="play"
action["KEY_UP"]="play"
action["KEY_KP9"]="play"
action["KEY_PAGEUP"]="play"

CDN=$HOME/venv/cdn
QUEUE=$HOME/venv/queue

MAXLIST=$(ls -1 songs-*.txt | wc -l)
let list=$MAXLIST-1

while read line
do
	key=$line key=${key##*\(} key=${key%%\)*}
	for verb in ${action[$key]}
	do
	case "$verb" in
	list+)
		let list="($list+$MAXLIST+1)%$MAXLIST"
		;;
	list-)
		let list="($list+$MAXLIST-1)%$MAXLIST"
		;;
	skip)
		pkill -u pi mpg123 >/dev/null 2>&1
		;;
	play)
		song=$(grep "$key," songs-$list.txt)
		song=${song##*,} song=${song//\//:}
		if [ "$song" ]; then
			>$QUEUE/$(date "+%s%3N"):$song
		fi
		;;
	*)
		;;
	esac
	done
done

>$QUEUE/exit
pkill -u pi mpg123 >/dev/null 2>&1
