cd /cartodb
source /usr/local/rvm/scripts/rvm

echo "insert into feature_flags (id,name, restricted) VALUES (1, 'heatmaps', false);" | psql -U postgres carto_db_development
echo "insert into feature_flags (id,name, restricted) VALUES (2, 'georef_disabled', false);" | psql -U postgres carto_db_development

ORGANIZATION_NAME="example"
USERNAME="admin4example"
EMAIL="admin@example.com"
PASSWORD="pass1234"

rake cartodb:db:create_user EMAIL="${EMAIL}" PASSWORD="${PASSWORD}" SUBDOMAIN="${USERNAME}"
rake cartodb:db:set_unlimited_table_quota["${USERNAME}"]
rake cartodb:db:create_new_organization_with_owner ORGANIZATION_NAME="${ORGANIZATION_NAME}" USERNAME="${USERNAME}" ORGANIZATION_SEATS=100 ORGANIZATION_QUOTA=102400 ORGANIZATION_DISPLAY_NAME="${ORGANIZATION_NAME}"
rake cartodb:db:set_organization_quota[$ORGANIZATION_NAME,100]
