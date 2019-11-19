#!/bin/bash

set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_ADDR}}
: ${PORT:=${DB_PORT}}
: ${USER:=${DB_USER:=${POSTGRES_USER}}}
: ${PASSWORD:=${DB_PASSWORD:=${POSTGRES_PASSWORD}}}

function check_config() {
    param="$1"
    value="$2"
    if ! [ -z $value ]; then
	cp $ODOO_CFG /tmp/temp_odoo_cfg
	sed -i 's/'${param}'\s*=.*/'${param}'='${value}'/g' /tmp/temp_odoo_cfg
	cp /tmp/temp_odoo_cfg $ODOO_CFG
    fi;
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

case "$1" in
    --)
        shift
        exec openerp-server -c $ODOO_CFG "$@"
        ;;
    -*)
        exec openerp-server -c $ODOO_CFG "$@"
        ;;
    *)
        exec openerp-server -c $ODOO_CFG
esac

exit 1
