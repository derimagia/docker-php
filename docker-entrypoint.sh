#!/bin/sh

set -e

if [ -n "$PHP_SENDMAIL_PATH" ]; then
	sed -i -- "s|sendmail_path = .*|sendmail_path = '${PHP_SENDMAIL_PATH}'|" /usr/local/etc/php/php.ini
fi

exec php-fpm