#!/bin/bash
set -e

PGDATA=${PGDATA:-/home/jovyan/srv/postgresql}
DB_NAME=DEMO_DB
PG_PATH=$(echo /usr/lib/postgresql/*/bin/)


rm -rf $PGDATA/$DB_NAME
sudo -u jovyan $PG_PATH/initdb -D $PGDATA/$DB_NAME --auth-host=trust --encoding=UTF8
chown -R jovyan:users /var/run/postgresql
sudo -u jovyan $PG_PATH/pg_ctl -D $PGDATA/$DB_NAME -l $PGDATA/../$DB_NAME.log start
sudo -u jovyan createdb --owner=jovyan jovyandb

exec "$@"
