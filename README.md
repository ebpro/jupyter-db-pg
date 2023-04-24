# Jupyterlab PostgreSQL Image

A jupyterlab image with PostgreSQL installed and started.
A database `demodb` is created for user `jovyan`.
PhpPgAdmin is embedded.

Try it on [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/ebpro/notebook-qs-databases/develop?labpath=SQL%20sandbox.ipynb)

or with docker :

```bash
WORKDIR=$HOME/JUPYTER_WORK
docker run --rm -it \
        --user root \
        --name ${PWD##*/} \
        --volume $WORKDIR:/home/jovyan/work \
    --publish 8888:8888 \
    --env NB_UID=$UID \
    brunoe/jupyter-db-pg:develop start-notebook.sh
```
