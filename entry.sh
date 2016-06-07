#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

# Allow bypass initialisation
if [ "$1" != "/usr/local/bin/voltgrid.py" ]; then
   exec "$@"
fi

# Copy default spool from cache
if [ ! "$(ls -A /var/spool/postfix)" ]; then
   cp -a /var/spool/postfix.cache/* /var/spool/postfix/
fi

# TODO: update postmaster in /etc/aliases
export ADMIN_EMAIL=${ADMIN_EMAIL-postmaster}

# SQLGrey DB
export DB_SQLGREY_NAME=${DB_SQLGREY_NAME-sqlgrey}
export DB_SQLGREY_HOST=${DB_SQLGREY_HOST-$MARIADB_PORT_3306_TCP_ADDR}
export DB_SQLGREY_USER=${DB_SQLGREY_USER-sqlgrey}
export DB_SQLGREY_PASS=${DB_SQLGREY_PASS}

# Main User DB, Used by Postfix and Dovecot
export DB_MAIL_NAME=${DB_MAIL_NAME-mail}
export DB_MAIL_HOST=${DB_MAIL_HOST-$MARIADB_PORT_3306_TCP_ADDR}
export DB_MAIL_USER=${DB_MAIL_USER-mail}
export DB_MAIL_PASS=${DB_MAIL_PASS}

# TLS For Postfix and Dovecot
export TLS_KEY=${TLS_KEY-/etc/pki/tls/private/${MAILNAME}.key}
export TLS_CRT=${TLS_CRT-/etc/pki/tls/certs/${MAILNAME}.crt}
export TLS_CA=${TLS_CA-/etc/pki/tls/certs/ca.crt}

# Configuration Sanity testing

if [ -z "$DB_SQLGREY_HOST" ]; then
    echo "Error: DB_SQLGREY_HOST not specified, or MARIADB link not defined"
    exit 128
fi

if [ -z "$DB_MAIL_HOST" ]; then
    echo "Error: DB_MAIL_HOST not specified, or MARIADB link not defined"
    exit 128
fi

if [ "$MARIADB_PORT_3306_TCP_PORT}" == "3306" ]; then
    echo "Error: MYSQL on port other than 3306 not suported"
    exit 128
fi

if [ -z "$MYDOMAIN" ]; then
    echo "Error: MYDOMAIN not specified"
    exit 128
fi

if [ -z "$MAILNAME" ]; then
    echo "Error: MAILNAME not specified"
    exit 128
fi

if [ -z "$MYNETWORKS" ]; then
    export MYNETWORKS='127.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16'
    echo "Warning: MYNETWORKS not specified, allowing all private IPs"
fi

if [ -z "$SIZELIMIT" ]; then
    export SIZELIMIT=15728640  # 10Meg with headroom
fi

# Generate SSL Key.
if [ "$GENERATE_TLS" == "true" ]; then
    echo "Generating TLS Key / Cert"
    openssl req -x509 -newkey rsa:2048 -keyout $TLS_KEY -out $TLS_CRT -subj "/CN=$MAILNAME/O=ACME Widgets Inc./C=US" -nodes -days 1024
    chmod 600 $TLS_KEY && touch $TLS_CA
fi

for K in TLS_KEY TLS_CRT TLS_CA; do
    [ ! -f "$(eval echo \$$K)" ] && echo "$K not found at $(eval echo \$$K)" && exit 128
done

echo "Exec'ing $@"
exec "$@"
