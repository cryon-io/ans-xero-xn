#!/bin/sh

#  XERO Xero Node ANS template
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

ver=$(./get-version.sh)
type="XERO_XN"
STAKE_ADDR=$(cat /home/xero/.xerom/stake_addr)

block_number=$(curl -sX POST --url http://localhost:8545 \
    --header 'Cache-Control: no-cache' \
    --header 'Content-Type: application/json' \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":["latest", false],"id":1}' |
    jq .result -r)
block_count=$(printf "%d\n" "$block_number")

RESULT=$(curl -sX POST --url http://localhost:8545 --header 'Cache-Control: no-cache' --header 'Content-Type: application/json' --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')
syncing=$(printf "%s" "$RESULT" | jq .result -r)
sync_status=false
if [ "$syncing" = "false" ]; then
    sync_status=true
else
    block_count=$(printf "%d" "$(printf "%s" "$RESULT" | jq .result.currentBlock -r)")
    sync_status=false
fi

RESULT=$(curl -sX POST --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", false],"id":1}' --header 'Cache-Control: no-cache' --header 'Content-Type: application/json' --url http://localhost:8545)
block_hash=$(printf "%s" "$RESULT" | jq .result.hash -r)

dashboard_info=$(printf "\n4\n2\n%s\n" "$STAKE_ADDR" | /home/xero/dashboard)
dashboard_enodeid=$(printf "%s" "$dashboard_info" | grep "Node Id:" | sed 's/Node Id: //g')
dashboard_ip=$(printf "%s" "$dashboard_info" | grep "Node Ip:" | sed 's/Node Ip: //g')

ENODEID=$(/usr/sbin/geth-xero --exec "admin.nodeInfo.enode" attach ipc://./home/xero/.xerom/geth.ipc)

if ! printf "%s\n" "$ENODEID" | grep -i "$dashboard_enodeid" ||
    ! printf "%s\n" "$ENODEID" | grep -i "@$dashboard_ip"; then
    mn_status_level="error"
    mn_status="Not Found"
fi

if [ -z "$mn_status_level" ]; then
    if [ "$sync_status" = "false" ]; then
        mn_status_level="warning"
        mn_status="Not Synchronized"
    else
        mn_status_level="ok"
        mn_status="Active"
    fi
fi

printf "\
TYPE: %s
VERSION: %s
BLOCKS: %s
BLOCK_HASH: %s
MN STATUS: %s
MN STATUS LEVEL: %s
SYNCED: %s
" "$type" "$ver" "$block_count" "$block_hash" "$mn_status" "$mn_status_level" "$sync_status" >/home/xero/.xerom/node.info

printf "\
TYPE: %s
VERSION: %s
BLOCKS: %s
BLOCK_HASH: %s
MN STATUS: %s
MN STATUS LEVEL: %s
SYNCED: %s
" "$type" "$ver" "$block_count" "$block_hash" "$mn_status" "$mn_status_level" "$sync_status"
