#!/bin/bash
set -e

PGDATA=${PGDATA:-/home/jovyan/srv/postgresql}
DB_NAME=JOVYAN_DB
PG_PATH=$(echo /usr/lib/postgresql/*/bin/)


rm -rf $PGDATA/$DB_NAME
$PG_PATH/initdb -D $PGDATA/$DB_NAME --auth-host=trust --encoding=UTF8
$PG_PATH/pg_ctl -D $PGDATA/$DB_NAME -l $PGDATA/../$DB_NAME.log start
createdb --owner=jovyan jovyandb

