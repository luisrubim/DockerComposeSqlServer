## Subindo o ambiente

1. Crie o `.env` a partir do exemplo: `cp .env.example .env`
2. Edite o `.env`: defina a senha do `sa` (`MSSQL_SA_PASSWORD`) e o nome do banco (`DB_NAME`)
3. Coloque o `<DB_NAME>.bak` em `./backup/` (pedir ao time por canal seguro)
4. `docker compose up -d`

O `.env` não é versionado: cada um mantém sua senha localmente.

O restore só acontece na primeira subida. Para restaurar de novo (ex.: um `.bak` mais recente), rode `docker compose down -v && docker compose up -d`.

## Acesso ao banco

Por padrão o SQL Server só aceita conexões da própria máquina (`localhost,1433`).

Variáveis opcionais no `.env`:

| Variável   | Padrão      | Uso                                                                 |
|------------|-------------|---------------------------------------------------------------------|
| `SQL_BIND` | `127.0.0.1` | Use `0.0.0.0` para liberar acesso de outras máquinas da rede        |
| `SQL_PORT` | `1433`      | Porta no host (ex.: `1434` se já houver um SQL Server instalado)     |

> Ao liberar acesso externo (`SQL_BIND=0.0.0.0`), use uma senha forte no `.env`.
> A senha só é aplicada na criação do volume: se o ambiente já existe, rode `docker compose down -v && docker compose up -d` (recria o banco e refaz o restore).
> Mudanças só de `SQL_BIND`/`SQL_PORT` são aplicadas com `docker compose up -d`.
