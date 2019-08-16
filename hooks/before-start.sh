#!/bin/sh

#  ETHER-1 Service Node docker template
#  Copyright © 2019 cryon.io
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published
#  by the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#  Contact: cryi@tutanota.com

BASEDIR=$(dirname "$0")
BOOTSTRAP_URL=""

if [ ! -d "$BASEDIR/../data/xero/geth/chaindata" ]; then 
    
    if [ -z "$BOOTSTRAP_URL" ]; then
        exit 0
    fi

    FILE=snapshot

    printf "loading chain snapshot"
    mkdir -p "$BASEDIR/../data/xero/geth/"
    case "$URL" in
    *.tar.gz) 
        (cd "$BASEDIR/../data/xero/geth/" && \
        curl -L "$URL" -o "./$FILE.tar.gz" && \
        tar -xzvf "./$FILE.tar.gz" && \
        rm -f "./$FILE.tar.gz")
    ;;
    *.zip)
        (cd "$BASEDIR/../data/xero/geth/" && \
        curl -L "$URL" -o "./$FILE.zip" && \
        unzip "./$FILE.zip" && \
        rm -f "./$FILE.zip")
    ;;
    *.tar.bz2)
        (cd "$BASEDIR/../data/xero/geth/" && \
        curl -L "$URL" -o "./$FILE.tar.bz2" && \
        tar xjf "./$FILE.tar.bz2" && \
        rm -f "./$FILE.tar.bz2")
    ;;
    esac
    sh "$BASEDIR/fs-permissions.sh"
fi
exit 0