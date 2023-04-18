#!/usr/bin/env bash

WORKDIR=$HOME/JUPYTER_WORK
IMAGE_REPO=brunoe

docker run --rm -it \
	--user root \
	--name ${PWD##*/} \
	--volume $WORKDIR:/home/jovyan/work \
    --publish 8888:8888 \
    --env NB_UID=$UID \
    ${IMAGE_REPO}/${PWD##*/}:$(git rev-parse --abbrev-ref HEAD) start-notebook.sh	
	
#        start-notebook.sh --notebook-dir=/home/jovyan/notebooks/	