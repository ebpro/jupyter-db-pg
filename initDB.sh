DB_NAME=DEMO_DB
rm -rf $PGDATA/$DB_NAME
sudo -u jovyan initdb -D $PGDATA/$DB_NAME
sudo -u jovyan pg_ctl -D $PGDATA/$DB_NAME -l $PGDATA/../$DB_NAME.log start
sudo -u jovyan createdb --owner=jovyan jovyandb