ORGANIZATION_NAME="example"
USERNAME="admin4example"
EMAIL="admin@example.com"
PASSWORD="pass1234"

rake cartodb:db:create_user EMAIL="${EMAIL}" PASSWORD="${PASSWORD}" SUBDOMAIN="${USERNAME}"
rake cartodb:db:set_unlimited_table_quota["${USERNAME}"]
rake cartodb:db:create_new_organization_with_owner ORGANIZATION_NAME="${ORGANIZATION_NAME}" USERNAME="${USERNAME}" ORGANIZATION_SEATS=100 ORGANIZATION_QUOTA=102400 ORGANIZATION_DISPLAY_NAME="${ORGANIZATION_NAME}"
rake cartodb:db:set_organization_quota[$ORGANIZATION_NAME,5000]
rake cartodb:db:configure_geocoder_extension_for_organizations[$ORGANIZATION_NAME]

# Enable sync tables
echo "UPDATE users SET sync_tables_enabled=true WHERE username='${USERNAME}'" | psql -U postgres -t carto_db_development
