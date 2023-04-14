FROM brunoe/jupyter-base:develop

USER root

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
 	apt-get update && \
	apt-get install -qq --yes --no-install-recommends \
		$(cat /tmp/apt_packages) && \
	rm -rf /var/lib/apt/lists/*

# Postgresql python library
# SQL support for ipython and PlantUML
RUN conda install --quiet --yes psycopg2 && \
	conda install -y -c conda-forge postgresql pgspecial && \
    	conda clean -tipy && \
	pip install ipython-sql iplantuml mocodo && \
	fix-permissions "${CONDA_DIR}" && \
	fix-permissions "/home/${NB_USER}"

ENV PGDATA=/home/jovyan/work/pgdata

COPY initDB.sh /usr/local/bin/before-notebook.d/ 

#RUN ipython profile create && \
#	sed -i -e '/c.InteractiveShellApp.extensions = / s/= [^\]]*/= ["mocodo_magic","sql"]/' -e 's/# \(c.InteractiveShellApp.extensions\)/\1/' ~/.ipython/profile_default/ipython_config.py

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
