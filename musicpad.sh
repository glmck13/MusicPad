#!/bin/ksh

source $HOME/venv/bin/activate
PATH=:$PATH
cd $HOME/venv/src

keypress.py | keyexec.sh &
playsongs.sh &
wait
