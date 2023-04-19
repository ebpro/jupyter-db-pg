FROM brunoe/jupyter-base:develop

USER root

COPY Artefacts/apt_packages /tmp/apt_packages

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
 	apt-get update && \
	apt-get install -qq --yes --no-install-recommends \
		$(cat /tmp/apt_packages) && \
	chown jovyan /var/run/postgresql/ && \
	rm -rf /var/lib/apt/lists/*	

# Postgresql python library
# SQL support for ipython and PlantUML
RUN conda install --quiet --yes psycopg2 && \
   	conda clean -tipy && \
	pip install pgspecial ipython-sql mocodo && \
	fix-permissions "${CONDA_DIR}" && \
	fix-permissions "/home/${NB_USER}"

COPY initdb.sh /usr/local/bin/before-notebook.d/

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
