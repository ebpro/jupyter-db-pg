#!/bin/bash
set -e

# set up a default postgresql user grap and database
PGDATA=${PGDATA:-/home/jovyan/work/.config/postgresql}
DB_NAME=JOVYAN_DB
PG_PATH=$(echo /usr/lib/postgresql/*/bin/)

rm -rf $PGDATA/$DB_NAME
$PG_PATH/initdb -D $PGDATA/$DB_NAME --auth-host=trust --encoding=UTF8

mkdir -p /home/jovyan/var/run/postgresql
$PG_PATH/pg_ctl -o "-k '/home/jovyan/var/run/postgresql'" -D $PGDATA/$DB_NAME -l $PGDATA/../$DB_NAME.log start
createdb --owner=jovyan jovyandb

PGADMIN_SETUP_EMAIL=jovyan@nowhere.org
PGADMIN_SETUP_PASSWORD=secret

rm -rf /home/jovyan/work/.config/pgadmin-v4
mkdir -p /home/jovyan/work/.config/pgadmin-v4
python /opt/conda/lib/python3.10/site-packages/pgadmin4/setup.py

# import the localhost pg server config
python /opt/conda/lib/python3.10/site-packages/pgadmin4/setup.py --load-servers /pgadmin4-localhostpg.json --user jovyan@nowhere.org
