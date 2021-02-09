#!/bin/bash

set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_ADDR:='db'}}
: ${PORT:=${DB_PORT:=5432}}
: ${NAME:=${DB_NAME:='odoo'}}
: ${USER:=${DB_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if ! grep  -q -E "^\s*\b${param}\b\s*=" $ODOO_CFG ; then
        echo "ENTRYPOINT: $param not found in config file, add $param=$value"
        DB_ARGS+=("--${param}")
        DB_ARGS+=("${value}")
    else
        echo "ENTRYPOINT: $param defined in config file"
    fi;
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_name" "$NAME"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

case "$1" in
    -- | openerp-server)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            echo "ENTRYPOINT: exec openerp-server -c $ODOO_CFG \"$@\""
            exec openerp-server -c $ODOO_CFG "$@"
        else
            echo "ENTRYPOINT: exec openerp-server -c $ODOO_CFG \"$@\" \"${DB_ARGS[@]}\""
            exec openerp-server -c $ODOO_CFG "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        echo "ENTRYPOINT: exec openerp-server -c $ODOO_CFG \"$@\" \"${DB_ARGS[@]}\""
        exec openerp-server -c $ODOO_CFG "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
