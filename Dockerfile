#
# Cartodb container
#
FROM ubuntu:14.04
MAINTAINER Adrien Fleury <fleu42@gmail.com>

# Configuring locales
RUN dpkg-reconfigure locales && \
      locale-gen en_US.UTF-8 && \
      update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# Preparing apt
RUN apt-get update && \
      useradd -m -d /home/cartodb -s /bin/bash cartodb && \
      apt-get install -y -q software-properties-common && \
      add-apt-repository -y ppa:chris-lea/node.js && \
      apt-get update 

# Installing stuff 
RUN apt-get install -y -q build-essential checkinstall unp zip libgeos-c1 \
      libgeos-dev libjson0 python-simplejson libjson0-dev proj-bin \
      proj-data libproj-dev postgresql-9.3 postgresql-client-9.3 \
      postgresql-contrib-9.3 postgresql-server-dev-9.3 \
      postgresql-plpython-9.3 gdal-bin libgdal1-dev nodejs \
      redis-server python2.7-dev build-essential python-setuptools \
      varnish imagemagick git postgresql-9.3-postgis-2.1 libmapnik-dev \
      python-mapnik mapnik-utils postgresql-9.3-postgis-2.1-scripts postgis \
      python-argparse python-gdal python-chardet openssl libreadline6 curl \
      git-core zlib1g zlib1g-dev libssl-dev libyaml-dev \
      libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf \
      libc6-dev ncurses-dev automake libtool bison subversion \
      pkg-config libpq5 libpq-dev libcurl4-gnutls-dev libffi-dev \
      libgdbm-dev gnupg libreadline6-dev 

# Setting PostgreSQL
RUN sed -i 's/\(peer\|md5\)/trust/' /etc/postgresql/9.3/main/pg_hba.conf

# Install schema_triggers
RUN git clone https://github.com/CartoDB/pg_schema_triggers.git && \
      cd pg_schema_triggers && \
      make all install && \
      sed -i \
      "/#shared_preload/a shared_preload_libraries = 'schema_triggers.so'" \
      /etc/postgresql/9.3/main/postgresql.conf 
ADD ./template_postgis.sh /tmp/template_postgis.sh
RUN service postgresql start && /bin/su postgres -c \
      /tmp/template_postgis.sh && service postgresql stop

# Install cartodb extension
RUN git clone --branch 0.5.1 https://github.com/CartoDB/cartodb-postgresql && \
      cd cartodb-postgresql && \
      PGUSER=postgres make install
ADD ./cartodb_pgsql.sh /tmp/cartodb_pgsql.sh
RUN service postgresql start && /bin/su postgres -c \
      /tmp/cartodb_pgsql.sh && service postgresql stop

# Install CartoDB API
RUN git clone git://github.com/CartoDB/CartoDB-SQL-API.git && \
      cd CartoDB-SQL-API && ./configure && npm install
ADD ./config/CartoDB-dev.js \
      /CartoDB-SQL-API/config/environments/development.js

# Install Windshaft
RUN git clone git://github.com/CartoDB/Windshaft-cartodb.git && \
      cd Windshaft-cartodb && ./configure && npm install && mkdir logs
ADD ./config/WS-dev.js \
      /Windshaft-cartodb/config/environments/development.js

# Install rvm
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN curl -L https://get.rvm.io | bash -s stable --ruby
RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc
RUN /bin/bash -l -c rvm requirements
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN /bin/bash -l -c 'rvm install 1.9.3-p547 --patch railsexpress'
RUN /bin/bash -l -c 'rvm use 1.9.3-p547 --default'
RUN /bin/bash -l -c 'gem install bundle archive-tar-minitar'

# Install bundler
RUN /bin/bash -l -c 'gem install bundler --no-doc --no-ri'

# Install CartoDB (with the bug correction on bundle install)
RUN git clone git://github.com/CartoDB/cartodb.git && \
      cd cartodb && /bin/bash -l -c 'bundle install' || \
      /bin/bash -l -c "cd $(/bin/bash -l -c 'gem contents \
            debugger-ruby_core_source' | grep CHANGELOG | sed -e \
            's,CHANGELOG.md,,') && /bin/bash -l -c 'rake add_source \
            VERSION=$(/bin/bash -l -c 'ruby --version' | awk \
            '{print $2}' | sed -e 's,p55,-p55,' )' && cd /cartodb && \
            /bin/bash -l -c 'bundle install'"

# Copy confs
ADD ./config/app_config.yml /cartodb/config/app_config.yml
ADD ./config/database.yml /cartodb/config/database.yml
ADD ./create_dev_user /cartodb/script/create_dev_user
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN service postgresql start && service redis-server start && \
	bash -l -c "cd /cartodb && bash script/create_dev_user" && \
	service postgresql stop && service redis-server stop

EXPOSE 3000

ADD ./startup.sh /opt/startup.sh

CMD ["/bin/bash", "/opt/startup.sh"]

