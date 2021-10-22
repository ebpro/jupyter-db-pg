DB_NAME=DEMO_DB
rm -rf $PGDATA/$DB_NAME
initdb -D $PGDATA/$DB_NAME
pg_ctl -D $PGDATA/$DB_NAME -l $PGDATA/../$DB_NAME.log start
createdb --owner=jovyan jovyandb