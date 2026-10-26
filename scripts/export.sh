#!/bin/bash
set -e
source .env
docker compose exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b \
  -Q "BACKUP DATABASE [$DB_NAME] TO DISK='/var/opt/mssql/backup/$DB_NAME.bak' WITH INIT, COMPRESSION, CHECKSUM, STATS=10;
      RESTORE VERIFYONLY FROM DISK='/var/opt/mssql/backup/$DB_NAME.bak' WITH CHECKSUM;"
echo "Backup gerado e verificado em ./backup/$DB_NAME.bak"