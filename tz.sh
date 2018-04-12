#!/usr/bin/env bash
# License: GPL
# Author: Chmouel Boudjnah <chmouel@chmouel.com>
set -eo pipefail
declare -A tzone

function help() {
    cat <<EOF
tz allow to calculate different timezone, it allows you to do somethinge like this :
% tz
% tz 10h30
% tz 10h30 next week
% tz 11:00 next thursday

It will show all different timezone for the timeformat

You can as well add multiple timezones directly on the command line like this :

% tz +America/Chicago +UTC 10h00 tomorrow

By default this script will try to detect your current timezone, if you want
to say something like this, show me the different times tomorrow at 10h00 UTC
you can do :

% tz +UTC -t UTC 10h00 tomorrow

The order here is important first have the + to add the UTC timezone and set
the base timezone to UTC to calculate the others.

and so on,

This needs gnu date, on MacOSX just install gnuutils from brew
This needs bash v4 too, you need to install it from brew as well
on MacOSX

EOF
}

if [[ $1 == "-h" || $1 == "--help" ]];then
    help
    exit 0
fi

## Change this
tzone=(
    ["Bangalore"]="Asia/Calcutta"
    ["Brisbane"]="Australia/Brisbane"
    ["Paris"]="Europe/Paris"
)

# If that fails (old distros used to do a hardlink for /etc/localtime)
# you may want to specify your tz directly in currentz like
# currentz="America/Chicago"
currenttz=$(/bin/ls -l /etc/localtime|awk -F/ '{print $(NF-1)"/"$NF}')
date=date
type -p gdate >/dev/null 2>/dev/null && date=gdate

athour=

while [[ $1 == +* ]];do
    tzone[${1#+}]=${1#+}
    shift
done

if [[ $1 == "-t" ]];then
    currenttz=$2
    shift
    shift
fi

args=($@)
if [[ -n ${1} ]];then
    [[ $1 != [0-9]*(:|h)[0-9]* ]] && {
        echo "Invalid date format: $1 you need to specify a time first like tz 10h00 tomorrow!"
        exit 1
    }
    athour="${1/h/:} ${args[@]:1}"
fi


for i in ${!tzone[@]};do
    echo -n "$i: "
    # bug in gnu date? 'now' doesn't take in consideration TZ :(
    [[ -n ${athour} ]] && TZ="${tzone[$i]}" ${date} --date="TZ=\"$currenttz\" ${athour}" || \
            TZ=${tzone[$i]} ${date}
done
