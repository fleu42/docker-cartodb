#
# Cartodb container
#
FROM ubuntu:16.04
MAINTAINER Stefan Verhoeven <s.verhoeven@esciencecenter.nl>

# Configuring locales
ENV DEBIAN_FRONTEND noninteractive
RUN dpkg-reconfigure locales && \
      locale-gen en_US.UTF-8 && \
      update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN useradd -m -d /home/cartodb -s /bin/bash cartodb && \
  apt-get update && \
  apt-get install -y -q \
    build-essential \
    autoconf \
    automake \
    libtool \
    checkinstall \
    unp \
    zip \
    unzip \
    git-core \
    git \
    subversion \
    curl \
    libgeos-c1v5 \
    libgeos-dev \
    libjson0 \
    python-simplejson \
    libjson0-dev \
    proj-bin \
    proj-data \
    libproj-dev \
    gdal-bin \
    libgdal1-dev \
    postgresql-9.5 \
    postgresql-client-9.5 \
    postgresql-contrib-9.5 \
    postgresql-server-dev-9.5 \
    postgresql-plpython-9.5 \
    postgresql-9.5-plproxy \
    postgresql-9.5-postgis-2.2 \
    postgresql-9.5-postgis-scripts \
    postgis \
    ca-certificates \
    redis-server \
    python2.7-dev \
    python-setuptools \
    varnish \
    imagemagick \
    libmapnik-dev \
    mapnik-utils \
    python-mapnik \
    python-argparse \
    python-gdal \
    python-chardet \
    openssl \
    libreadline6 \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    libyaml-dev \
    libsqlite3-dev \
    sqlite3 \
    libxml2-dev \
    libxslt-dev \
    libc6-dev \
    ncurses-dev \
    bison \
    pkg-config \
    libpq5 \
    libpq-dev \
    libcurl4-gnutls-dev \
    libffi-dev \
    libgdbm-dev \
    gnupg \
    libreadline6-dev \
    libcairo2-dev \
    libjpeg8-dev \
    libpango1.0-dev \
    libgif-dev \
    libgmp-dev \
    libicu-dev \
  --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*

RUN git config --global user.email you@example.com
RUN git config --global user.name "Your Name"

# ogr2ogr2 static build, see https://github.com/CartoDB/cartodb/wiki/How-to-build-gdal-and-ogr2ogr2
# using cartodb instruction got error https://trac.osgeo.org/gdal/ticket/6073
# https://github.com/OSGeo/gdal/compare/trunk...CartoDB:ogr2ogr2 has no code changes, so just use latest gdal tarball
RUN cd /opt && \
curl http://download.osgeo.org/gdal/2.1.1/gdal-2.1.1.tar.gz -o gdal-2.1.1.tar.gz && \
tar -zxf gdal-2.1.1.tar.gz && \
cd gdal-2.1.1 && \
./configure --disable-shared && \
make -j 4 && \
cp apps/ogr2ogr /usr/bin/ogr2ogr2 && \
rm -rf /opt/ogr2ogr2 /root/.gitconfig

# Install NodeJS
RUN curl https://nodejs.org/download/release/v0.10.41/node-v0.10.41-linux-x64.tar.gz| tar -zxf - --strip-components=1 -C /usr

# Install rvm
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN curl -L https://get.rvm.io | bash -s stable --ruby
RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc
RUN /bin/bash -l -c rvm requirements
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN echo rvm_max_time_flag=15 >> ~/.rvmrc
RUN /bin/bash -l -c 'rvm install 2.2.3'
RUN /bin/bash -l -c 'rvm use 2.2.3 --default'
RUN /bin/bash -l -c 'gem install bundle archive-tar-minitar'

# Install bundler
RUN /bin/bash -l -c 'gem install bundler --no-doc --no-ri'

# Setting PostgreSQL
RUN sed -i 's/\(peer\|md5\)/trust/' /etc/postgresql/9.5/main/pg_hba.conf

# Install schema_triggers
RUN git clone https://github.com/CartoDB/pg_schema_triggers.git && \
      cd pg_schema_triggers && \
      make all install && \
      sed -i \
      "/#shared_preload/a shared_preload_libraries = 'schema_triggers.so'" \
      /etc/postgresql/9.5/main/postgresql.conf
ADD ./template_postgis.sh /tmp/template_postgis.sh
RUN service postgresql start && /bin/su postgres -c \
      /tmp/template_postgis.sh && service postgresql stop

# Install cartodb extension
RUN git clone https://github.com/CartoDB/cartodb-postgresql && \
      cd cartodb-postgresql && \
      PGUSER=postgres make install
ADD ./cartodb_pgsql.sh /tmp/cartodb_pgsql.sh
RUN service postgresql start && /bin/su postgres -c \
      /tmp/cartodb_pgsql.sh && service postgresql stop

# Install CartoDB API
RUN git clone git://github.com/CartoDB/CartoDB-SQL-API.git && \
      cd CartoDB-SQL-API && ./configure && npm install

# Install Windshaft
RUN git clone git://github.com/CartoDB/Windshaft-cartodb.git && \
      cd Windshaft-cartodb && ./configure && npm install && mkdir logs

# Install CartoDB (with the bug correction on bundle install)
RUN git clone git://github.com/CartoDB/cartodb.git && \
      cd cartodb && \
      perl -pi -e 's/jwt \(1\.5\.3\)/jwt (1.5.4)/' Gemfile.lock && \
      /bin/bash -l -c 'bundle install' || \
      /bin/bash -l -c "cd $(/bin/bash -l -c 'gem contents \
            debugger-ruby_core_source' | grep CHANGELOG | sed -e \
            's,CHANGELOG.md,,') && /bin/bash -l -c 'rake add_source \
            VERSION=$(/bin/bash -l -c 'ruby --version' | awk \
            '{print $2}' | sed -e 's,p55,-p55,' )' && cd /cartodb && \
            /bin/bash -l -c 'bundle install'"

# Geocoder SQL client + server
RUN git clone https://github.com/CartoDB/data-services && \
  cd /data-services/geocoder/extension && PGUSER=postgres make all install && cd / && \
  git clone https://github.com/CartoDB/dataservices-api.git && \
  ln -s /usr/local/rvm/rubies/ruby-2.2.3/bin/ruby /usr/bin && \
  cd /dataservices-api/server/extension && PGUSER=postgres make install && \
  cd ../lib/python/cartodb_services && python setup.py install && \
  cd ../../../../client && PGUSER=postgres make install && \
  service postgresql start && \
  echo "CREATE ROLE geocoder WITH LOGIN SUPERUSER PASSWORD 'geocoder'" | psql -U postgres postgres && \
  createdb -U postgres -E UTF8 -O geocoder geocoder && \
  echo 'CREATE EXTENSION plpythonu;CREATE EXTENSION postgis;CREATE EXTENSION cartodb;CREATE EXTENSION cdb_geocoder;CREATE EXTENSION plproxy;CREATE EXTENSION cdb_dataservices_server;CREATE EXTENSION cdb_dataservices_client;' | psql -U geocoder geocoder && \
  service postgresql stop

# Copy confs
ADD ./config/CartoDB-dev.js \
      /CartoDB-SQL-API/config/environments/development.js
ADD ./config/WS-dev.js \
      /Windshaft-cartodb/config/environments/development.js
ADD ./config/app_config.yml /cartodb/config/app_config.yml
ADD ./config/database.yml /cartodb/config/database.yml
ADD ./create_dev_user /cartodb/script/create_dev_user
ADD ./setup_organization.sh /cartodb/script/setup_organization.sh
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN mkdir -p /cartodb/log && touch /cartodb/log/users_modifications
RUN service postgresql start && service redis-server start && \
	bash -l -c "cd /cartodb && bash script/create_dev_user || bash script/create_dev_user && bash script/setup_organization.sh" && \
# Enable CARTO Builder
#    bundle exec rake cartodb:features:enable_feature_for_all_users['editor-3'] && \
#    bundle exec rake cartodb:features:enable_feature_for_all_users['explore_site']" && \
	service postgresql stop && service redis-server stop

EXPOSE 3000 8080 8181

ENV GDAL_DATA /usr/share/gdal/1.10

ADD ./startup.sh /opt/startup.sh

CMD ["/bin/bash", "/opt/startup.sh"]
