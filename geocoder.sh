
rake cartodb:db:create_user --trace SUBDOMAIN="geocoder" \
	PASSWORD="pass1234" ADMIN_PASSWORD="pass1234" \
	EMAIL="geocoder@example.com"

# # Update your quota to 100GB
echo "--- Updating quota to 100GB"
rake cartodb:db:set_user_quota[geocoder,102400]

# # Allow unlimited tables to be created
echo "--- Allowing unlimited tables creation"
rake cartodb:db:set_unlimited_table_quota[geocoder]


GEOCODER_DB=`echo "SELECT database_name FROM users WHERE username='geocoder'" | psql -U postgres -t carto_db_development`    
psql -U postgres $GEOCODER_DB < /cartodb/script/geocoder_server.sql
