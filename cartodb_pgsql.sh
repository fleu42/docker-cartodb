#!/bin/bash
#
# Init script to success tests.
#

psql -c "CREATE EXTENSION postgis;"
psql -c "CREATE EXTENSION cartodb;"
