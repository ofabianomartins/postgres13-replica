#!/bin/bash
echo "host replication all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
echo "host replication all 172.25.0.13/0 md5" >> "$PGDATA/pg_hba.conf"

# echo 'host replication repuser 172.25.0.13/32 trust' >> $PGDATA/pg_hba.conf

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE USER $PG_REP_USER REPLICATION LOGIN CONNECTION LIMIT 100 ENCRYPTED PASSWORD '$PG_REP_PASSWORD';

  SELECT * FROM pg_create_physical_replication_slot('slot_name');
EOSQL

cat >> ${PGDATA}/postgresql.conf <<EOF
listen_addresses = '*'
synchronous_standby_names = '*'

max_wal_senders = 8
max_replication_slots = 8
wal_keep_size = 8
max_slot_wal_keep_size = 8
wal_sender_timeout = 1000 
wal_receiver_timeout = 1000 
wal_receiver_status_interval = 10s 
track_commit_timestamp = on
EOF
