# See https://github.com/CartoDB/data-services/issues/228#issuecomment-280037353
# Not run during Docker build phase as it's 5Gb of downloads
cd /data-services/geocoder && \
./geocoder_download_dumps && \
./geocoder_restore_dump geocoder geocoder db_dumps/*.sql
rm -r db_dumps
chmod +x geocoder_download_patches.sh geocoder_apply_patches.sh
./geocoder_download_patches.sh
./geocoder_apply_patches.sh geocoder geocoder data_patches/*.sql
rm -r data_patches
