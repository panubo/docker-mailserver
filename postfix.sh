#!/usr/bin/env bash

set -e

# exit cleanly
trap "{ /sbin/service postfix stop; }" EXIT

# start postfix
/sbin/service postfix start

# don't exit
sleep infinity
