\set ON_ERROR_STOP on
\connect hms

CREATE SCHEMA hms AUTHORIZATION hms_owner;
SET ROLE hms_owner;
CREATE TABLE hms.cdc_heartbeat (
  singleton boolean PRIMARY KEY DEFAULT true CHECK (singleton),
  source_time timestamptz NOT NULL DEFAULT now()
);
INSERT INTO hms.cdc_heartbeat (singleton) VALUES (true);
RESET ROLE;

GRANT USAGE ON SCHEMA hms TO peerdb_user;
GRANT SELECT ON hms.cdc_heartbeat TO peerdb_user;
ALTER DEFAULT PRIVILEGES FOR ROLE hms_owner IN SCHEMA hms GRANT SELECT ON TABLES TO peerdb_user;
