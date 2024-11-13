#!/bin/bash

TMPDIR=${DOCUMENT_ROOT}/tmp
SPOOLDIR=/var/spool/asterisk/outgoing/
MP3CONF=${DOCUMENT_ROOT}/cdn/mp3.conf
CALLFILE=${TMPDIR}/callfile$$.txt
LOCKFILE=${TMPDIR}/flic.lock
DESTINATION=6300

exec 3<> $LOCKFILE
flock -x 3

typeset -A CLICKMAP
CLICKMAP["BH39-E44843|click"]="830"
CLICKMAP["BH39-E44843|double_click"]="835"
CLICKMAP["BH39-E44843|hold"]="SoundOfMusic"
CLICKMAP["BH39-E43956|click"]="840"
CLICKMAP["BH39-E43956|double_click"]="844"
CLICKMAP["BH39-E43956|hold"]="MaryPoppins"
CLICKMAP["BH39-E46990|click"]="805"
CLICKMAP["BH39-E46990|double_click"]="807"
CLICKMAP["BH39-E46990|hold"]="MsRachel"

echo -e "Content-Type: text/plain\n"

event=$(cat -)
button=${event%,*} button=${button#*:} button=${button#*\"} button=${button%\"*}
click=${event#*,} click=${click#*:} click=${click#*\"} click=${click%\"*}

extension="${CLICKMAP[$button|$click]}"
extension=$(grep ${extension:-.} $MP3CONF | shuf -n1) extension=${extension%%\|*}
echo $event $button $click $extension >&2

in_progress=$(ls ${SPOOLDIR})

if [ ! "$in_progress" ]; then
cat - >${CALLFILE} <<-EOF
Channel: PJSIP/${DESTINATION}
Context: from-internal-custom
Extension: ${extension}
Priority: 1
Callerid: flic
WaitTime: 12
EOF
mv ${CALLFILE} ${SPOOLDIR}
echo "Queued: $(ls ${SPOOLDIR})" >&2
else
echo "Pending: $in_progress" >&2
fi

echo "OK"
