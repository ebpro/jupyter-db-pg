ARG BASE_CONTAINER=brunoe/jupyterutln-default:develop
FROM $BASE_CONTAINER

LABEL maintainer="Emmanuel Bruno <emmanuel.bruno@univ-tln.fr>"

USER root

# Install minimal dependencies 
RUN apt-get update && apt-get install -y --no-install-recommends\
	coreutils \
	dnsutils \
	gnupg \
	graphviz ttf-bitstream-vera gsfonts \
	inkscape \
	iputils-ping \
	net-tools \
	pandoc \
	procps \
	tree \
	zsh \
	plantuml && \
  apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /var/cache/apt

# Postgresql python library
# SQL support for ipython and PlantUML
RUN conda install --quiet --yes psycopg2=2.9.1 && \
	conda install -y -c conda-forge postgresql=13.3 pgspecial=1.13.0 && \
    	conda clean -tipsy && \
	pip install ipython-sql==0.4.0 iplantuml==0.1.1 mocodo_magic==1.0.3 && \
	fix-permissions "${CONDA_DIR}" && \
	fix-permissions "/home/${NB_USER}"

RUN curl https://kumisystems.dl.sourceforge.net/project/plantuml/plantuml.jar -o /usr/local/bin/plantuml.jar

ENV PGDATA=/home/jovyan/work/pgdata

COPY initDB.sh /usr/local/bin/before-notebook.d/ 

RUN ipython profile create && \
	sed -i -e '/c.InteractiveShellApp.extensions = / s/= [^\]]*/= ["mocodo_magic","sql"]/' -e 's/# \(c.InteractiveShellApp.extensions\)/\1/' ~/.ipython/profile_default/ipython_config.py

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
RUN mkdir -p /home/jovyan/.ssh && ssh-keyscan -t rsa github.com > /home/jovyan/.ssh/known_hosts
WORKDIR /home/jovyan
