#!/bin/bash
set -e

PGUSER=jovyan
PGPASSWORD=secret
PGDATABASE=jovyandb

# credit: https://github.com/docker-library/postgres/blob/master/15/bullseye/docker-entrypoint.sh
# usage: docker_process_init_files [file [file [...]]]
#    ie: docker_process_init_files /always-initdb.d/*
# process initializer files, based on file extensions and permissions
process_init_files() {
	printf '\n'
	local f
	for f; do
		case "$f" in
			*.sh)
				# https://github.com/docker-library/postgres/issues/450#issuecomment-393167936
				# https://github.com/docker-library/postgres/pull/452
				if [ -x "$f" ]; then
					printf '%s: running %s\n' "$0" "$f"
					"$f"
				else
					printf '%s: sourcing %s\n' "$0" "$f"
					. "$f"
				fi
				;;
			*.sql)     printf '%s: running %s\n' "$0" "$f"; docker_process_sql -f "$f"; printf '\n' ;;
			*.sql.gz)  printf '%s: running %s\n' "$0" "$f"; gunzip -c "$f" | docker_process_sql; printf '\n' ;;
			*.sql.xz)  printf '%s: running %s\n' "$0" "$f"; xzcat "$f" | docker_process_sql; printf '\n' ;;
			*.sql.zst) printf '%s: running %s\n' "$0" "$f"; zstd -dc "$f" | docker_process_sql; printf '\n' ;;
            *.tar)     printf '%s: restoring %s\n' "$0" "$f"; fn=${f##*/} ;psql jovyandb -c "CREATE DATABASE ${fn%.tar}";pg_restore --no-owner --role=jovyan -d "${fn%.tar}" "$f"; printf '\n' ;;
			*)         printf '%s: ignoring %s\n' "$0" "$f" ;;
		esac
		printf '\n'
	done
}

# sets up a default postgresql user grap and database
PGDATA=${PGDATA:-/home/jovyan/work/.config/postgresql}
DB_NAME=JOVYAN_DB
PG_PATH=$(echo /usr/lib/postgresql/*/bin/)
# ??IN PROD. SHOULD TEST IF IT ALREADY EXITS
rm -rf $PGDATA/$DB_NAME
$PG_PATH/initdb -D $PGDATA/$DB_NAME --auth-host=trust --encoding=UTF8
mkdir -p /home/jovyan/var/run/postgresql
$PG_PATH/pg_ctl -o "-k '/home/jovyan/var/run/postgresql'" -D $PGDATA/$DB_NAME -l $PGDATA/../$DB_NAME.log start

# creates a default database and execute sql init script in /initdb.d
createdb --owner=jovyan jovyandb

process_init_files /initdb.d/*