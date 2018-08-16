# Mailserver Image

All in one mailserver image designed to work with [Mailmanager](https://github.com/voltgrid/mailmanager) for user account creation and management.

[Roundcube](https://github.com/macropin/docker-roundcube) is a great webmail
that works well with this image.

Features:

- Postfix
- Dovecot (IMAP / POP3)
- ClamAV / Amavisd
- Spamassasin (with self-update)
- MySQL backend for authentication (use official `docker.io/mariadb` container)
- SSL / TLS for all services

## Environment

See `entry.sh` for the environment variables used to configure the container.

## Status

Stable. Used in production on a small scale for many years now
without any known issues.

# TODO

Documentation is lacking.
