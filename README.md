# Jupyterlab PostgreSQL Image

A jupyterlab image with postgresql installed and started.
A database `demodb` is created for user `jovyan`.

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
