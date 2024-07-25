#!/bin/ksh

#set -x
#alias sonos='echo'

export SPKR=Move

typeset -A action
action["MSG_WELCOME"]="init play"
action["KEY_BACKSPACE"]="play"
action["KEY_KPEQUAL"]=""
action["KEY_KPMINUS"]="lower play"
action["KEY_KPPLUS"]="raise play"
action["KEY_KPENTER"]="pause play"
action["KEY_KPSLASH"]="shuffle"
action["KEY_KPASTERISK"]="clear"
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
action["KEY_KP5"]="play"
action["KEY_KP6"]="play"
action["KEY_RIGHT"]="play"
action["KEY_KP7"]="play"
action["KEY_HOME"]="play"
action["KEY_KP8"]="play"
action["KEY_UP"]="play"
action["KEY_KP9"]="play"
action["KEY_PAGEUP"]="play"

action["KEY_EQUAL"]=action["KEY_KPEQUAL"]
action["KEY_MINUS"]=action["KEY_KPMINUS"]
action["KEY_ENTER"]=action["KEY_KPENTER"]
action["KEY_SLASH"]=action["KEY_KPSLASH"]
action["KEY_DOT"]=action["KEY_KPDOT"]

CDN=$HOME/venv/cdn
QUEUE=$HOME/venv/queue

if [ -s songs-sonos.txt ]; then
	mode="sonos"
else
	mode="speaker"
	MAXLIST=$(ls -1 songs-*.txt | wc -l)
	let list=$MAXLIST-1
fi

init="n"

while read line
do
	key=$line key=${key##*\(} key=${key%%\)*}
	for verb in ${action[$key]}
	do

	case "$verb" in

	init)
		if [ "$mode" = "sonos" ]; then
			if [ "$init" != "y" ]; then
				>$QUEUE/exit
				sonos cq
				sonos play_mode NORMAL
				sonos volume 20 
			fi
		fi
		;;
	raise)
		if [ "$mode" = "sonos" ]; then
			sonos relative_volume +3
		else
			let list="($list+$MAXLIST+1)%$MAXLIST"
		fi
		;;
	lower)
		if [ "$mode" = "sonos" ]; then
			sonos relative_volume -3
		else
			let list="($list+$MAXLIST-1)%$MAXLIST"
		fi
		;;
	pause)
		if [ "$mode" = "sonos" ]; then
			sonos pauseplay
		fi
		;;
	shuffle)
		if [ "$mode" = "sonos" ]; then
			sonos play_mode shuffle_norepeat
		fi
		;;
	skip)
		if [ "$mode" = "sonos" ]; then
			sonos next
		else
			pkill -u pi mpg123 >/dev/null 2>&1
		fi
		;;
	clear)
		if [ "$mode" = "sonos" ]; then
			sonos cq
		else
			rm -f $QUEUE/*
		fi
		;;
	play)
		if [ "$mode" = "sonos" ]; then
			song=$(grep "$key," songs-sonos.txt)
			song=${song##*,}
			if [ "$song" ]; then
				if [[ "$song" == *playlist* ]]; then
					sonos play_sharelink $song
				elif [ "$init" != "y" ]; then
					sonos play_file $song
					init="y"
				fi
			fi
		else
			song=$(grep "$key," songs-$list.txt)
			song=${song##*,} song=${song//\//:}
			if [ "$song" ]; then
				>$QUEUE/$(date "+%s%3N"):$song
			fi
		fi
		;;
	*)
		;;
	esac

	done
done

>$QUEUE/exit
if [ "$mode" != "sonos" ]; then
	pkill -u pi mpg123 >/dev/null 2>&1
fi
