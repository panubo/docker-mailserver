#!/usr/bin/env bash

set -e

# exit cleanly
trap "{ /usr/bin/killall clamd.amavisd; }" EXIT

# start service
/usr/sbin/clamd.amavisd -c /etc/clamd.d/amavisd.conf --pid /var/run/amavisd/clamd.pid

# don't exit
sleep infinity