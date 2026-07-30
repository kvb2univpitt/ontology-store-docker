#!/usr/bin/env sh

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE i2b2;

    CREATE USER i2b2demodata WITH PASSWORD 'demouser';
    CREATE USER i2b2hive WITH PASSWORD 'demouser';
    CREATE USER i2b2imdata WITH PASSWORD 'demouser';
    CREATE USER i2b2metadata WITH PASSWORD 'demouser';
    CREATE USER i2b2pm WITH PASSWORD 'demouser';
    CREATE USER i2b2workdata WITH PASSWORD 'demouser';

    GRANT ALL PRIVILEGES ON DATABASE i2b2 TO i2b2demodata;
    GRANT ALL PRIVILEGES ON DATABASE i2b2 TO i2b2hive;
    GRANT ALL PRIVILEGES ON DATABASE i2b2 TO i2b2imdata;
    GRANT ALL PRIVILEGES ON DATABASE i2b2 TO i2b2metadata;
    GRANT ALL PRIVILEGES ON DATABASE i2b2 TO i2b2pm;
    GRANT ALL PRIVILEGES ON DATABASE i2b2 TO i2b2workdata;
EOSQL

pg_restore --verbose --username="$POSTGRES_USER" --dbname=i2b2 --format=c /var/lib/postgresql/i2b2-data-demo_1.8.3.dump

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "i2b2" <<-EOSQL
    CREATE USER i2b2actata WITH PASSWORD 'demouser';

    CREATE SCHEMA i2b2actdata;

    GRANT ALL ON SCHEMA i2b2actdata TO i2b2actata;
EOSQL

psql -v ON_ERROR_STOP=1 --username "i2b2actata" --dbname "i2b2" <<-EOSQL
    CREATE TABLE i2b2actdata.schemes (
        c_key varchar(50) NOT NULL,
        c_name varchar(50) NOT NULL,
        c_description varchar(100) NULL,
        CONSTRAINT act_schemes_pk PRIMARY KEY (c_key)
    );

    CREATE TABLE i2b2actdata.table_access (
        c_table_cd varchar(50) NOT NULL,
        c_table_name varchar(50) NOT NULL,
        c_protected_access bpchar(1) NULL,
        c_ontology_protection text NULL,
        c_hlevel int4 NOT NULL,
        c_fullname varchar(700) NOT NULL,
        c_name varchar(2000) NOT NULL,
        c_synonym_cd bpchar(1) NOT NULL,
        c_visualattributes bpchar(3) NOT NULL,
        c_totalnum int4 NULL,
        c_basecode varchar(50) NULL,
        c_metadataxml text NULL,
        c_facttablecolumn varchar(50) NOT NULL,
        c_dimtablename varchar(50) NOT NULL,
        c_columnname varchar(50) NOT NULL,
        c_columndatatype varchar(50) NOT NULL,
        c_operator varchar(10) NOT NULL,
        c_dimcode varchar(700) NOT NULL,
        c_comment text NULL,
        c_tooltip varchar(900) NULL,
        c_entry_date timestamp NULL,
        c_change_date timestamp NULL,
        c_status_cd bpchar(1) NULL,
        valuetype_cd varchar(50) NULL
    );
EOSQL

psql -v ON_ERROR_STOP=1 --username "i2b2pm" --dbname "i2b2" <<-EOSQL
    INSERT INTO pm_project_data (project_id,project_name,project_wiki,project_path,status_cd) VALUES ('ACT','i2b2 ACT','http://www.i2b2.org','/ACT','A');

    -- add user to the ACT project
    INSERT INTO pm_project_user_roles (project_id,user_id,user_role_cd,status_cd) VALUES ('ACT','demo','USER','A');
    INSERT INTO pm_project_user_roles (project_id,user_id,user_role_cd,status_cd) VALUES ('ACT','demo','DATA_DEID','A');
    INSERT INTO pm_project_user_roles (project_id,user_id,user_role_cd,status_cd) VALUES ('ACT','demo','DATA_OBFSC','A');
    INSERT INTO pm_project_user_roles (project_id,user_id,user_role_cd,status_cd) VALUES ('ACT','demo','DATA_AGG','A');
    INSERT INTO pm_project_user_roles (project_id,user_id,user_role_cd,status_cd) VALUES ('ACT','demo','DATA_LDS','A');
    INSERT INTO pm_project_user_roles (project_id,user_id,user_role_cd,status_cd) VALUES ('ACT','demo','EDITOR','A');
    INSERT INTO pm_project_user_roles (project_id,user_id,user_role_cd,status_cd) VALUES ('ACT','demo','DATA_PROT','A');

    -- add ontologystore service URL
    INSERT INTO pm_cell_data (cell_id,project_path,"name",method_cd,url,can_override,status_cd) VALUES ('ONTSTORE','/','OntologyStore Cell','REST','http://localhost:9090/i2b2/services/OntologyStoreService/',1,'A');

    -- add ontologystore-admin role to i2b2 admin
    INSERT INTO pm_project_user_roles (project_id,user_id,user_role_cd,status_cd) VALUES ('Demo','i2b2','ONTSTORE_ADMIN','A');
EOSQL

psql -v ON_ERROR_STOP=1 --username "i2b2hive" --dbname "i2b2" <<-EOSQL
    -- update ACT ontology datasource path
    UPDATE ont_db_lookup SET c_db_datasource = 'java:/ACTOntologyDemoDS' WHERE c_project_path = 'ACT/' AND c_owner_id = '@';

    -- ontologystore configurations
    INSERT INTO hive_cell_params (id,datatype_cd,cell_id,param_name_cd,value,status_cd) VALUES ((SELECT max(id)+1  FROM hive_cell_params),'T','ONTSTORE','ontstore.product.list.url','https://ontology-store-v2.s3.us-east-1.amazonaws.com/product-list-aws-all.json','A');
    INSERT INTO hive_cell_params (id,datatype_cd,cell_id,param_name_cd,value,status_cd) VALUES ((SELECT max(id)+1  FROM hive_cell_params),'T','ONTSTORE','ontstore.dir.download','/opt/jboss/wildfly','A');
EOSQL

# test case to run
/var/lib/postgresql/test_case_${TEST_CASE_NUMBER}.sh

# /var/lib/postgresql/test_case_1.sh
# /var/lib/postgresql/test_case_2.sh
# /var/lib/postgresql/test_case_3.sh
# /var/lib/postgresql/test_case_4.sh

# clean up files
rm -f /var/lib/postgresql/test_case_*.sh
rm -f /var/lib/postgresql/i2b2-data-demo_1.8.3.dump

exit 0
