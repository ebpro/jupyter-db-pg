ARG BASE_CONTAINER=brunoe/jupyterutln-default:develop
FROM $BASE_CONTAINER

LABEL maintainer="Emmanuel Bruno <emmanuel.bruno@univ-tln.fr>"

ENV PLANTUML_VERSION 1.2022.1
ENV PLANTUML_SHA1 ac9847dac6687f5079793952cf981f8d75ff4515
USER root



# Install minimal dependencies 
RUN	apt-get update && apt-get install -y --no-install-recommends\
		coreutils \
		curl \
		dnsutils \
		gnupg \
		graphviz \
		inkscape \
		iputils-ping \
		net-tools \
		pandoc \
		postgresql-client \
		procps \
		tree \
		ttf-bitstream-vera \
		zsh && \
  apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /var/cache/apt

# Postgresql python library
# SQL support for ipython and PlantUML
RUN conda install --quiet --yes psycopg2=2.9.1 && \
	conda install -y -c conda-forge postgresql=13.3 pgspecial=1.13.0 && \
    	conda clean -tipsy && \
	pip install ipython-sql==0.4.0 iplantuml==0.1.1 mocodo_magic==1.0.3 && \
	fix-permissions "${CONDA_DIR}" && \
	fix-permissions "/home/${NB_USER}"

RUN mkdir /usr/local/jre && \
	curl -L https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.2%2B8/OpenJDK17U-jre_x64_linux_hotspot_17.0.2_8.tar.gz -o /usr/local/jre/jre.tgz && \
	tar  zxf /usr/local/jre/jre.tgz --strip=1 -C /usr/local/jre && \
	rm /usr/local/jre/jre.tgz
ENV PATH /usr/local/jre/bin:$PATH

RUN curl -L https://sourceforge.net/projects/plantuml/files/plantuml.${PLANTUML_VERSION}.jar/download -o /usr/local/bin/plantuml.jar && \
    echo "$PLANTUML_SHA1 */usr/local/bin/plantuml.jar" | sha1sum -c - 

ENV PGDATA=/home/jovyan/work/pgdata

COPY initDB.sh /usr/local/bin/before-notebook.d/ 

RUN ipython profile create && \
	sed -i -e '/c.InteractiveShellApp.extensions = / s/= [^\]]*/= ["mocodo_magic","sql"]/' -e 's/# \(c.InteractiveShellApp.extensions\)/\1/' ~/.ipython/profile_default/ipython_config.py

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
# RUN mkdir -p /home/jovyan/.ssh && ssh-keyscan -t rsa github.com > /home/jovyan/.ssh/known_hosts
WORKDIR /home/jovyan
