FROM brunoe/jupyter-base:develop

USER root

COPY Artefacts/apt_packages /tmp/apt_packages

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
 	apt-get update && \
	apt-get install -qq --yes --no-install-recommends \
		$(cat /tmp/apt_packages) && \
	rm -rf /var/lib/apt/lists/*	

# Postgresql python library
# SQL support for ipython and PlantUML
# pgadmin4 and gunicorn
RUN conda install --quiet --yes psycopg2 && \
   	conda clean -tipy && \
	pip install pgspecial ipython-sql mocodo gunicorn https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v7.0/pip/pgadmin4-7.0-py3-none-any.whl && \
	fix-permissions "${CONDA_DIR}" && \
	fix-permissions "/home/${NB_USER}"

# Configure phppgadmin and its proxy
COPY phppgadmin.conf /etc/apache2/sites-enabled/phppgadmin.conf
COPY phppgadmin/jupyter_phppgadmin_config.py /tmp
RUN touch jupyter_config.py && \
	cat /tmp/jupyter_phppgadmin_config.py >> /home/jovyan/.jupyter/jupyter_config.py
COPY phppgadmin/icons $HOME/.jupyter/icons
# RUN rm /etc/apache2/sites-available/000-default.conf
RUN sed -i -e '/export APACHE_RUN_USER=/s/=.*/=jovyan/' \
		-e '/export APACHE_RUN_DIR=/s/=.*/=\/home\/jovyan\/var\/run\/apache2/' \
		-e '/export APACHE_LOCK_DIR =/s/=.*/=\/home\/jovyan\/var\/lock\/apache2/' \
		-e '/export APACHE_LOG_DIR=/s/=.*/=\/home\/jovyan\/var\/log\/apache2/' \
		-e '/export APACHE_PID_FILE=/s/=.*/=\/home\/jovyan\/var\/run\/apache2\/apache2.pid/' \
		/etc/apache2/envvars && \
		mkdir -p /home/jovyan/var/run/apache2/ \
			/home/jovyan/var/lock/apache2/ \
			/home/jovyan/var/log/apache2/ && \
		chown -R $NB_USER /home/jovyan/var && \
	sed -i -e 's/80/9090/g' /etc/apache2/sites-available/000-default.conf

# Configuration of pgadmin4
COPY pgadmin4/config_local.py  /opt/conda/lib/python3.10/site-packages/pgadmin4/config_local.py

ENV PGADMIN_SETUP_EMAIL=jovyan@nowhere.org
ENV PGADMIN_SETUP_PASSWORD=secret

RUN sed -i -e "/unix_socket_directories = /s/= .*/ = '\/home\/jovyan\/var\/run\/postgresql'/" \
	$(echo /etc/postgresql/*/main/postgresql.conf)

# Adds pgadmin4 jupyterproxy
COPY pgadmin4/jupyter_pgadmin4_config.py /tmp
RUN touch jupyter_config.py && \
	cat /tmp/jupyter_pgadmin4_config.py >> /home/jovyan/.jupyter/jupyter_config.py

# preconfigure localhost postgresql server for pgadmin4
COPY pgadmin4/pgadmin4-localhostpg.json /

# Initialisation of the default database in the userspace (~/work)
COPY before-notebook/* /usr/local/bin/before-notebook.d/

RUN mkdir /initdb.d

RUN wget https://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip -O /tmp/dvdrental.zip && \
	(cd /initdb.d && unzip /tmp/dvdrental.zip) && \
	rm /tmp/dvdrental.zip

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
