#!/bin/bash

# Copyright (C) 2017-2018 Stefan Koch <stefan.koch10@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 2.1 of the GNU Lesser General
# Public License as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.

type="$1"
pkg=yast2-usbauth

if [ -z "$type" ]; then
	echo "Usage:"
	echo "build.sh obs [home:repo]"
	echo "NOTICE: argument [home:repo] is only needed to create a new package within home:repo"
	echo "        since home:repo is specified in Rakefile, too."
	exit
fi

if [ $type = obs ]; then
	if [ -n "$2" ]; then
		pushd /tmp
		osc checkout "$2"
		osc meta pkg -e "$2" $pkg
		osc up "$2"
		popd
	fi

	rm -f package/${pkg}*.tar.bz2
	rake osc:build
	rm -f package/${pkg}*.tar.bz2
	rake osc:commit
	rm -f package/${pkg}*.tar.bz2
fi

