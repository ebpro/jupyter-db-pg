ARG BASE_CONTAINER=brunoe/jupyterutln-default
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
RUN conda install --quiet --yes psycopg2 && \
	conda install -y -c conda-forge postgresql pgspecial && \
    	conda clean -tipsy && \
	fix-permissions "${CONDA_DIR}" && \
	fix-permissions "/home/${NB_USER}"

# SQL support for ipython and PlantUML
RUN pip install ipython-sql iplantuml && \
	fix-permissions "${CONDA_DIR}" && \
	fix-permissions "/home/${NB_USER}"

RUN curl https://kumisystems.dl.sourceforge.net/project/plantuml/plantuml.jar -o /usr/local/bin/plantuml.jar

ENV PGDATA=/home/jovyan/work/pgdata

COPY initDB.sh /usr/local/bin/before-notebook.d/ 

RUN pip install jupyterlab_sql && \
	jupyter serverextension enable jupyterlab_sql --py --sys-prefix && \
	jupyter lab build && \
	fix-permissions "${CONDA_DIR}" && \
        fix-permissions "/home/${NB_USER}"

RUN  pip install mocodo_magic

RUN jupyter lab --generate-config && \
	sed -i -e '/c.InteractiveShellApp.extensions = / s/= [^\]]*/= ["mocodo_magic","sql"]/' -e 's/# \(c.InteractiveShellApp.extensions\)/\1/' ~/.ipython/profile_default/ipython_config.py


# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
RUN mkdir -p /home/jovyan/.ssh && ssh-keyscan -t rsa github.com > /home/jovyan/.ssh/known_hosts
WORKDIR /home/jovyan
