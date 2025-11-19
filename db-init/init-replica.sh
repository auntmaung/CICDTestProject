#!/bin/bash
set -e

echo "Starting replica init script..."

# PGDATA is /var/lib/postgresql/data (from env)
if [ -z "$(ls -A "$PGDATA" 2>/dev/null)" ]; then
  echo "PGDATA is empty, running pg_basebackup from primary..."
  # Wait for primary to be reachable
  until pg_isready -h db -p 5432 -U repuser; do
    echo "Waiting for primary (db:5432)..."
    sleep 2
  done

  pg_basebackup \
    -h db \
    -p 5432 \
    -D "$PGDATA" \
    -U repuser \
    -Fp -Xs -P -R

  chown -R postgres:postgres "$PGDATA"
  echo "Base backup complete. Replica configured."
else
  echo "PGDATA is not empty, skipping basebackup."
fi

echo "Starting postgres in standby mode..."
exec docker-entrypoint.sh postgres
