#!/bin/bash

set -e

: ${DEBUG:=${DEBUG_MODE:='none'}}
: ${PYDEV_DEBUG_SERVER:='host.docker.internal'}

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_HOST:=${DB_ADDR:='db'}}}
: ${PORT:=${DB_PORT:=5432}}
: ${NAME:=${DB_NAME:='odoo'}}
: ${USER:=${DB_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

DB_ARGS=()
function check_config() {
    param_config="$1"
    param_cmdline="$2"
    value="$3"
    if ! grep  -q -E "^\s*\b${param_config}\b\s*=" $ODOO_CFG ; then
        echo "ENTRYPOINT: \"$param_config\" not found in config file, add \"$param_cmdline $value\" in command line"
        DB_ARGS+=("${param_cmdline}")
        DB_ARGS+=("${value}")
    else
        echo "ENTRYPOINT: \"$param_config\" defined in config file"
    fi;
}
check_config "db_host" "--db_host" "$HOST"
check_config "db_port" "--db_port" "$PORT"
check_config "db_name" "--database" "$NAME"
check_config "db_user" "--db_user" "$USER"
check_config "db_password" "--db_password" "$PASSWORD"

DEBUG_ARG=""
DEBUG_CMD=""
case "$DEBUG" in
    debugpy)
        DEBUG_ARG="--debug"
        DEBUG_CMD="python -m debugpy --listen 0.0.0.0:3001"
        ;;
    pydevd)
        DEBUG_ARG="--debug"
        DEBUG_CMD="python -m pydevd --port 3001 --client $PYDEV_DEBUG_SERVER --file"
        ;;
esac

COMMAND=""
case "$1" in
    -- | openerp-server)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            COMMAND="/usr/bin/openerp-server $DEBUG_ARG -c $ODOO_CFG $@"
        else
            COMMAND="/usr/bin/openerp-server $DEBUG_ARG -c $ODOO_CFG $@ ${DB_ARGS[@]}"
        fi
        ;;
    -*)
        COMMAND="/usr/bin/openerp-server $DEBUG_ARG -c $ODOO_CFG $@ ${DB_ARGS[@]}"
        ;;
    *)
        COMMAND="$@"
esac

echo "ENTRYPOINT: exec $DEBUG_CMD $COMMAND"
exec $DEBUG_CMD $COMMAND

exit 0
