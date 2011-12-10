#!/bin/sh

# PROVIDE: lighttpd
# REQUIRE: LOGIN

. /usr/local/etc/newsbin/ffp.subr

name="lighttpd"
command="/usr/local/sbin/lighttpd"

lighttpd_flags="-f /usr/local/etc/newsbin/conf/lighttpd.conf"
required_files="/usr/local/etc/newsbin/conf/lighttpd.conf"

run_rc_command "$1"
