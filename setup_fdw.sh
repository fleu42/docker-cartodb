# Create foreign data wrapper to another postgresql database
#
ORGANIZATION_DB=`echo "SELECT database_name FROM users WHERE username='admin4example'" | psql -U postgres -t carto_db_development`

echo "CREATE EXTENSION postgres_fdw;" | psql -U postgres $ORGANIZATION_DB
echo "CREATE SCHEMA gps;" | psql -U postgres $ORGANIZATION_DB
echo "CREATE SERVER remotedb FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '10.0.0.1', port '5432', dbname 'somedb');" | psql -U postgres $ORGANIZATION_DB
echo "CREATE FOREIGN TABLE gps.places (id integer NOT NULL, location geometry) SERVER remotedb OPTIONS (schema_name 'gps', table_name 'places');"

for user in `echo "SELECT 'development_cartodb_user_' || id FROM users WHERE organization_id = (SELECT id FROM organizations WHERE name='example')" | psql -U postgres -t carto_db_development`
do
  echo "GRANT USAGE ON SCHEMA gps TO ${user};" | psql -U postgres $ORGANIZATION_DB
  echo "GRANT SELECT ON gps.places TO ${user};" | psql -U postgres $ORGANIZATION_DB
  echo "GRANT USAGE ON FOREIGN SERVER remotedb TO ${user}" | psql -U postgres $ORGANIZATION_DB
done

# User should be able to creat his/her own mapping with
# CREATE USER MAPPING FOR bob SERVER remotedb (user 'bob', password 'secret');
# Then in create empty table in CartoDB and run something like
# SELECT row_number() OVER(ORDER BY id), location the_geom, ST_Transform(location, 3857) AS the_geom_webmercator FROM gps.places;
