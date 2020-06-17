#!/bin/bash

# See https://github.com/CartoDB/data-services/issues/228#issuecomment-280037353
# Not run during Docker build phase as it would make the image too big
cd /data-services/geocoder
./geocoder_download_dumps
GEOCODER_DB=`echo "SELECT database_name FROM users WHERE username='geocoder'" | psql -U postgres -t carto_db_development`
./geocoder_restore_dump postgres $GEOCODER_DB db_dumps/*.sql
rm -r db_dumps
chmod +x geocoder_download_patches.sh geocoder_apply_patches.sh
./geocoder_download_patches.sh
./geocoder_apply_patches.sh postgres $GEOCODER_DB data_patches/*.sql
rm -r data_patches
