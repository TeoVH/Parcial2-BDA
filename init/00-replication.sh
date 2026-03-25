#!/bin/bash
set -e

echo "host replication admin_monitoreo all md5" >> "$PGDATA/pg_hba.conf"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'SQL'
ALTER ROLE admin_monitoreo WITH REPLICATION;
SQL
