create extension cdb_geocoder;
create extension plproxy;
create extension observatory;
create extension cdb_dataservices_server;
create extension cdb_dataservices_client;

SELECT CDB_Conf_SetConf(
    'redis_metadata_config',
    '{"redis_host": "localhost", "redis_port": 6379, "sentinel_master_id": "", "timeout": 0.1, "redis_db": 5}'
);
SELECT CDB_Conf_SetConf(
    'redis_metrics_config',
    '{"redis_host": "localhost", "redis_port": 6379, "sentinel_master_id": "", "timeout": 0.1, "redis_db": 5}'
);

SELECT CDB_Conf_SetConf(
    'user_config',
    '{"is_organization": false, "entity_name": "geocoder"}'
);

SELECT CDB_Conf_SetConf(
    'server_conf',
    '{"environment": "development"}'
);