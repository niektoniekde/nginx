#! /bin/bash
set -eE

LETCD="/usr/local/etc/nginx"
CONFD="${LETCD}/conf.d"
DATAD="/srv/data/nginx"

if ! [[ -n $(ls -1A ${CONFD}) ]]; then
    echo "ERROR: there are no configuration files to be included in directory: '${CONFD}' " >&2
    exit 100
fi

if ! [[ -d ${DATAD} ]]; then mkdir -p "${DATAD}"; fi
chmod ug=rwX,o-rX -R "${DATAD}"

if ! [[ -d "${DATAD}/log" ]]; then mkdir -p "${DATAD}/log"; fi
chmod ug=rwX,o-rX -R "${DATAD}/log"

exec /usr/sbin/nginx -c "${LETCD}/nginx.conf" -g 'daemon off;'
