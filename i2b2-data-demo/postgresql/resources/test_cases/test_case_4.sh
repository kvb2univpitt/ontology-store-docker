#!/usr/bin/env sh

set -e

################################################################################
# Test Case 4:
# Two sets of datasources: One for the Demo project and one for the ACT project.
# The CRC data is imported in the main (Demo) project schema for both projects.
# The metadata is imported in separate project schema.
################################################################################

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "i2b2" <<-EOSQL
    -- create database users for datasources
    -- Demo project
    CREATE USER i2b2ontstoredata WITH PASSWORD 'demouser';
    CREATE USER i2b2ontstoremetadata WITH PASSWORD 'demouser';
    -- ACT project
    CREATE USER i2b2ontstoreactdata WITH PASSWORD 'demouser';
    CREATE USER i2b2ontstoreactmetadata WITH PASSWORD 'demouser';

    -- permit usage and creation inside the schema
    -- Demo project
    GRANT ALL PRIVILEGES ON SCHEMA public TO i2b2ontstoredata;
    GRANT ALL PRIVILEGES ON SCHEMA public TO i2b2ontstoremetadata;
    -- ACT project
    GRANT ALL PRIVILEGES ON SCHEMA public TO i2b2ontstoreactdata;
    GRANT ALL PRIVILEGES ON SCHEMA i2b2actdata TO i2b2ontstoreactmetadata;

    -- grant full permissions on selected schema tables
    -- Demo project
    GRANT ALL ON TABLE public.qt_breakdown_path TO i2b2ontstoredata;
    GRANT ALL ON TABLE public.table_access TO i2b2ontstoremetadata;
    GRANT ALL ON TABLE public.schemes TO i2b2ontstoremetadata;
    -- ACT project
    GRANT ALL ON TABLE public.qt_breakdown_path TO i2b2ontstoreactdata;
    GRANT ALL ON TABLE i2b2actdata.table_access TO i2b2ontstoreactmetadata;
    GRANT ALL ON TABLE i2b2actdata.schemes TO i2b2ontstoreactmetadata;

    -- share all access rights
    -- Demo project
    ALTER DEFAULT PRIVILEGES FOR ROLE i2b2ontstoredata IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO i2b2demodata;
    ALTER DEFAULT PRIVILEGES FOR ROLE i2b2ontstoremetadata IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO i2b2metadata;
    -- ACT project
    ALTER DEFAULT PRIVILEGES FOR ROLE i2b2ontstoreactdata IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO i2b2demodata;
    ALTER DEFAULT PRIVILEGES FOR ROLE i2b2ontstoreactmetadata IN SCHEMA i2b2actdata GRANT ALL PRIVILEGES ON TABLES TO i2b2actata;
EOSQL

psql -v ON_ERROR_STOP=1 --username "i2b2hive" --dbname "i2b2" <<-EOSQL
    -- OntologyStore DB lookup tables
    -- Demo project
    INSERT INTO crc_db_lookup (c_domain_id,c_project_path,c_owner_id,c_db_fullschema,c_db_datasource,c_db_servertype,c_db_nicename,c_entry_date) VALUES ('i2b2demo','/Demo/','ontstore','public','java:/OntologyStoreDataDS','POSTGRESQL','Demo',current_timestamp);
    INSERT INTO ont_db_lookup (c_domain_id,c_project_path,c_owner_id,c_db_fullschema,c_db_datasource,c_db_servertype,c_db_nicename,c_entry_date) VALUES ('i2b2demo','Demo/','ontstore','public','java:/OntologyStoreMetadataDS','POSTGRESQL','Metadata',current_timestamp);
    -- ACT project
    INSERT INTO crc_db_lookup (c_domain_id,c_project_path,c_owner_id,c_db_fullschema,c_db_datasource,c_db_servertype,c_db_nicename,c_entry_date) VALUES ('i2b2demo','/ACT/','ontstore','public','java:/OntologyStoreACTDataDS','POSTGRESQL','Demo',current_timestamp);
    INSERT INTO ont_db_lookup (c_domain_id,c_project_path,c_owner_id,c_db_fullschema,c_db_datasource,c_db_servertype,c_db_nicename,c_entry_date) VALUES ('i2b2demo','ACT/','ontstore','i2b2actdata','java:/OntologyStoreACTMetadataDS','POSTGRESQL','Metadata',current_timestamp);
EOSQL

exit 0
