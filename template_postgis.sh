#!/bin/bash
#
# Init script for template postgis
#

POSTGIS_SQL_PATH=`pg_config --sharedir`/contrib/postgis-2.1.2;
createdb -E UTF8 template_postgis;
createlang -d template_postgis plpgsql;
psql -d postgres -c "UPDATE pg_database SET datistemplate='true' \
  WHERE datname='template_postgis'"
psql -d template_postgis -c "CREATE EXTENSION postgis;"
psql -d template_postgis -c "CREATE EXTENSION postgis_topology;"
psql -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
psql -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"
psql -c "CREATE EXTENSION plpythonu;"
psql -c "CREATE EXTENSION schema_triggers;"
