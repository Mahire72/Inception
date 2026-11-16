#!/bin/bash
set -e

: "${POSTGRES_DB:?POSTGRES_DB is required}"
: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}"

PG_VERSION=$(pg_lsclusters --no-header | awk 'NR==1 {print $1}')
PG_BIN="/usr/lib/postgresql/$PG_VERSION/bin"
PGDATA="/var/lib/postgresql/data"

# Initialise the persistent database directory if empty
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Initialising PostgreSQL data directory..."

    mkdir -p "$PGDATA"
    chown postgres:postgres "$PGDATA"
    chmod 700 "$PGDATA"

    runuser -u postgres -- "$PG_BIN/initdb" \
        -D "$PGDATA" \
        --auth-host=scram-sha-256 \
        --auth-local=peer
fi

# Configure PostgreSQL network access
sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" \
    "$PGDATA/postgresql.conf"

# Start PostgreSQL temporarily
runuser -u postgres -- "$PG_BIN/pg_ctl" \
    -D "$PGDATA" -o "-c listen_addresses=''" -w start

# Create or update the learning user
runuser -u postgres -- "$PG_BIN/psql" \
    -v username="$POSTGRES_USER" \
    -v password="$POSTGRES_PASSWORD" <<'SQL'
SELECT format(
    'CREATE ROLE %I LOGIN CREATEDB PASSWORD %L',
    :'username', :'password'
)
WHERE NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = :'username'
)
\gexec

ALTER ROLE :"username" PASSWORD :'password';
SQL

# Create the learning database if necessary
runuser -u postgres -- "$PG_BIN/psql" \
    -v dbname="$POSTGRES_DB" \
    -v username="$POSTGRES_USER" <<'SQL'
SELECT format(
    'CREATE DATABASE %I OWNER %I',
    :'dbname', :'username'
)
WHERE NOT EXISTS (
    SELECT 1 FROM pg_database WHERE datname = :'dbname'
)
\gexec
SQL

# Allow password-authenticated connections from Docker networks
grep -qxF "host all all 0.0.0.0/0 scram-sha-256" \
    "$PGDATA/pg_hba.conf" || \
echo "host all all 0.0.0.0/0 scram-sha-256" \
    >> "$PGDATA/pg_hba.conf"

# Stop temporary PostgreSQL process
runuser -u postgres -- "$PG_BIN/pg_ctl" -D "$PGDATA" -m fast -w stop

# Start PostgreSQL in the foreground
exec runuser -u postgres -- "$PG_BIN/postgres" -D "$PGDATA"
