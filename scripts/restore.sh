#!/bin/bash
set -e
SQLCMD="/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P $MSSQL_SA_PASSWORD -C -b"
BAK="/var/opt/mssql/backup/${DB_NAME}.bak"
DATA="/var/opt/mssql/data"

[ -f "$BAK" ] || { echo "Sem .bak, nada a restaurar."; exit 0; }

EXISTS=$($SQLCMD -h -1 -W -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name='${DB_NAME}'" | tr -d '[:space:]')
[ "$EXISTS" != "0" ] && { echo "Banco já existe, pulando restore."; exit 0; }

MOVES=""; d=0; l=0
while IFS='|' read -r logical physical type _; do
  [ -z "$logical" ] && continue
  case "$type" in
    D) ext=$([ $d -eq 0 ] && echo mdf || echo ndf); MOVES="$MOVES, MOVE '$logical' TO '$DATA/${DB_NAME}_$d.$ext'"; d=$((d+1)) ;;
    L) MOVES="$MOVES, MOVE '$logical' TO '$DATA/${DB_NAME}_log$l.ldf'"; l=$((l+1)) ;;
  esac
done < <($SQLCMD -h -1 -s "|" -W -Q "SET NOCOUNT ON; RESTORE FILELISTONLY FROM DISK='$BAK'")

$SQLCMD -Q "RESTORE DATABASE [$DB_NAME] FROM DISK='$BAK' WITH REPLACE, STATS=10 $MOVES"
echo "Restore concluído."