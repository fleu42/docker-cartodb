#!/bin/bash

while :
do
sleep $SYNC_TABLES_INTERVAL
cd /cartodb
bundle exec rake cartodb:sync_tables[true]
done
