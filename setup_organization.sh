cd /cartodb
source /usr/local/rvm/scripts/rvm

ORGANIZATION_NAME="example"
USERNAME="admin4example"
EMAIL="admin@example.com"
PASSWORD="pass1234"

rake cartodb:db:create_user EMAIL="${EMAIL}" PASSWORD="${PASSWORD}" SUBDOMAIN="${USERNAME}"
rake cartodb:db:set_unlimited_table_quota["${USERNAME}"]
rake cartodb:db:create_new_organization_with_owner ORGANIZATION_NAME="${ORGANIZATION_NAME}" USERNAME="${USERNAME}" ORGANIZATION_SEATS=100 ORGANIZATION_QUOTA=102400 ORGANIZATION_DISPLAY_NAME="${ORGANIZATION_NAME}"
rake cartodb:db:set_organization_quota[$ORGANIZATION_NAME,5000]
rake cartodb:db:configure_geocoder_extension_for_organizations[$ORGANIZATION_NAME]

# Set dataservices server
ORGANIZATION_DB=`echo "SELECT database_name FROM users WHERE username='admin4example'" | psql -A -U postgres -t carto_db_development`
psql -U postgres $ORGANIZATION_DB < /cartodb/script/geocoder_client.sql
echo "CREATE EXTENSION cdb_dataservices_client;" | psql -U postgres $ORGANIZATION_DB
echo "SELECT CDB_Conf_SetConf('user_config', '{"'"is_organization"'": true, "'"entity_name"'": "'"example"'"}');" | psql -U postgres $ORGANIZATION_DB
GEOCODER_DB=`echo "SELECT database_name FROM users WHERE username='geocoder'" | psql -A -U postgres -t carto_db_development`
echo -e "SELECT CDB_Conf_SetConf('geocoder_server_config', '{ \"connection_str\": \"host=localhost port=5432 dbname=${GEOCODER_DB} user=postgres\"}');" | psql -U postgres $ORGANIZATION_DB

