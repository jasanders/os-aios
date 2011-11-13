#!/bin/sh

# PROVIDES: nzbget

. /usr/local/etc/newsbin/ffp.subr

name="nzbget"

command="/usr/local/etc/newsbin/bin/nzbget"

nzbget_flags="-D -c /usr/local/etc/newsbin/conf/nzbget.conf"

start_cmd="nzbget_start"
stop_cmd="nzbget_stop"
status_cmd="nzbget_status"

nzbget_start()
{
proc_start $command
}

nzbget_stop()
{
proc_stop nzbget
}

nzbget_status()
{
proc_status nzbget
}

run_rc_command "$1"
