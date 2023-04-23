import os
DATA_DIR = os.path.realpath(os.path.expanduser('/home/jovyan/work/.config/pgadmin-v4/'))
LOG_FILE = os.path.join(DATA_DIR, 'pgadmin4.log')
SQLITE_PATH = os.path.join(DATA_DIR, 'pgadmin4.db')
SESSION_DB_PATH = os.path.join(DATA_DIR, 'sessions')
# SESSION_DB_PATH = '/run/shm/pgAdmin4_session'
STORAGE_DIR = os.path.join(DATA_DIR, 'storage')
AZURE_CREDENTIAL_CACHE_DIR = os.path.join(DATA_DIR, 'azurecredentialcache')

UPGRADE_CHECK_ENABLED = False
SHOW_GRAVATAR_IMAGE = False
MFA_ENABLED = False

ENABLE_PSQL = True
ENABLE_BINARY_PATH_BROWSING = True

SERVER_MODE = True

# Minimum password length
PASSWORD_LENGTH_MIN = 6

LOGIN_BANNER = "<ul><li> login with jovyan@nowhere.org/secret \
                <li><If needed to reset run <code>/reset_pgadmin4.sh</code></ul>"
