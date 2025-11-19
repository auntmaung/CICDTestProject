#!/bin/bash
set -e

echo "Configuring primary for replication..."

# Append replication settings to postgresql.conf
cat >> "$PGDATA/postgresql.conf" <<EOF
max_wal_senders = 10
max_replication_slots = 10
EOF

# Allow replication connections from anywhere (demo-friendly; you can restrict to db-replica's IP)
cat >> "$PGDATA/pg_hba.conf" <<EOF
host    replication     repuser     0.0.0.0/0       md5
EOF

# Create replication user
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM pg_roles WHERE rolname = 'repuser'
        ) THEN
            CREATE ROLE repuser WITH REPLICATION LOGIN PASSWORD 'rep_pass';
        END IF;
    END
    \$\$;
EOSQL
