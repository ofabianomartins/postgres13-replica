#!/bin/bash
if [ ! -s "$PGDATA/PG_VERSION" ]; then

echo "*:*:*:$PG_REP_USER:$PG_REP_PASSWORD" > ~/.pgpass

chmod 0600 ~/.pgpass

until ping -c 1 -W 1 master
do
echo "Waiting for master to ping..."
sleep 1s
done

until pg_basebackup -h master --pgdata ${PGDATA} --format=p --write-recovery-conf --checkpoint=fast --label=mffb --progress --username  ${PG_REP_USER} -vP -W -S slot_name
do
echo "Waiting for master to connect..."
sleep 1s
done

echo "host replication all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
echo "host replication all 172.25.0.12/0 md5" >> "$PGDATA/pg_hba.conf"

set -e

cat >> ${PGDATA}/postgres.conf <<EOF
# standby_mode = on
log_replication_commands = true
primary_conninfo = 'host=master port=5432 user=$PG_REP_USER password=$PG_REP_PASSWORD'
primary_slot_name = 'slot_name'
promoter_trigger_file = '/tmp/touch_me_to_promote_to_me_master'
EOF

chown postgres. ${PGDATA} -R

chmod 700 ${PGDATA} -R

fi

sed -i 's/wal_level = hot_standby/wal_level = replica/g' ${PGDATA}/postgresql.conf

exec "$@"
