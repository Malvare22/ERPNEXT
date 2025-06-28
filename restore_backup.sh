#!/bin/bash

set -e

CONTAINER_NAME=erpnext-backend-1
BACKUP_DIR=./backup

echo "Copiando backups al contenedor..."
docker cp $BACKUP_DIR/. $CONTAINER_NAME:/home/frappe/frappe-bench/sites/frontend/private/backups/

echo "Ejecutando restore y comandos dentro del contenedor..."
docker exec -it $CONTAINER_NAME bash -c "
  bench --site frontend --force restore /home/frappe/frappe-bench/sites/frontend/private/backups/database.sql.gz --with-public-files /home/frappe/frappe-bench/sites/frontend/private/backups/files.tar --with-private-files /home/frappe/frappe-bench/sites/frontend/private/backups/private-files.tar &&
  tar -xf /home/frappe/frappe-bench/sites/frontend/private/backups/files.tar -C /home/frappe/frappe-bench/sites/frontend/private/backups/ &&
  tar -xf /home/frappe/frappe-bench/sites/frontend/private/backups/private-files.tar -C /home/frappe/frappe-bench/sites/frontend/private/backups/ &&
  bench --site frontend migrate &&
  bench --site frontend clear-cache &&
  bench --site frontend  set-config server_script_enabled true
"

echo "Reiniciando la stack..."
docker compose down
docker compose -f pwd.yml up -d

echo "¡Restauración y reinicio completados!"

