#!/bin/sh
#
#   http://code.google.com/p/1073dd-max/
#   Copyright (C) 2011  Max Yao
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# echo "B847FF00" > /sys/devices/platform/VenusIR/fakekey
arg_opt=`echo "$QUERY_STRING" | awk -F, '{print $2}'`

echo "$arg_opt" > /sys/devices/platform/VenusIR/fakekey
