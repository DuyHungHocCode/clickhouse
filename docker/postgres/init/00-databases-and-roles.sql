\set ON_ERROR_STOP on
\getenv hms_owner_password HMS_POSTGRES_PASSWORD
\getenv peerdb_source_password PEERDB_SOURCE_PASSWORD

CREATE ROLE hms_owner LOGIN PASSWORD :'hms_owner_password';
CREATE ROLE peerdb_user LOGIN REPLICATION BYPASSRLS PASSWORD :'peerdb_source_password';
CREATE DATABASE hms OWNER hms_owner;
GRANT CONNECT ON DATABASE hms TO peerdb_user;
