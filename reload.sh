#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

echo "Reloading services"

service postfix reload
service dovecot reload
