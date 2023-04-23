#!/bin/bash
set -e

PGADMIN_SETUP_EMAIL=jovyan@nowhere.org
PGADMIN_SETUP_PASSWORD=secret

rm -rf /home/jovyan/work/.config/pgadmin-v4
mkdir -p /home/jovyan/work/.config/pgadmin-v4
python /opt/conda/lib/python3.10/site-packages/pgadmin4/setup.py

# import the localhost pg server config
python /opt/conda/lib/python3.10/site-packages/pgadmin4/setup.py --load-servers /pgadmin4-localhostpg.json --user jovyan@nowhere.org
