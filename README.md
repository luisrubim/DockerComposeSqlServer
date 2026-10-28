# SQL Server local (Docker Compose)

SQL Server 2022 para desenvolvimento local, com restore automático de um backup (`.bak`) na primeira subida.

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) rodando (no Windows, com backend WSL2)
- Pelo menos 2 GB de RAM disponíveis para o Docker
- Git Bash (Windows) apenas se for usar `scripts/export.sh`

> A imagem do SQL Server é só `amd64`. Em Mac com Apple Silicon, ative *"Use Rosetta for x86/amd64 emulation"* no Docker Desktop.

## Início rápido

```bash
cp .env.example .env               # depois edite MSSQL_SA_PASSWORD e DB_NAME
# copie o arquivo <DB_NAME>.bak para ./backup/ (peça ao time por canal seguro)
docker compose up -d
docker compose logs -f restore     # aguarde "Restore concluído." (Ctrl+C para sair)
```

Pontos de atenção:

- **Nome do backup:** o arquivo deve se chamar exatamente `<DB_NAME>.bak` (diferencia maiúsculas/minúsculas). Ex.: `DB_NAME=MeuBanco` → `./backup/MeuBanco.bak`.
- **Senha:** mínimo 8 caracteres e 3 destes 4 grupos: maiúsculas, minúsculas, números e símbolos. Senha fraca impede o SQL Server de subir.
- **Sem `.bak`:** o ambiente sobe normalmente, com um servidor vazio.
- O `.env` não é versionado: cada um mantém sua senha localmente.

## Conectando

| Campo    | Valor                                   |
|----------|-----------------------------------------|
| Servidor | `localhost,1433`                        |
| Usuário  | `sa`                                    |
| Senha    | `MSSQL_SA_PASSWORD` do seu `.env`       |
| Opção    | Marcar *Trust server certificate*       |

Funciona com SSMS, Azure Data Studio, DBeaver etc.

Connection string (.NET):

```
Server=localhost,1433;Database=MeuBanco;User Id=sa;Password=<sua senha>;TrustServerCertificate=True;
```

Teste rápido pelo terminal (pede a senha):

```bash
docker exec -it sqldev /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C
```

## Comandos do dia a dia

| Ação                                   | Comando                                              |
|----------------------------------------|------------------------------------------------------|
| Ver status                             | `docker compose ps`                                  |
| Parar (mantém os dados)                | `docker compose stop`                                |
| Subir de novo                          | `docker compose up -d`                               |
| Resetar e restaurar o `.bak` de novo ⚠️ | `docker compose down -v && docker compose up -d`     |

⚠️ `down -v` apaga o volume: todos os dados locais são perdidos e o restore é refeito a partir do `.bak` atual.

## Gerando um backup do banco local

Na raiz do repositório (Git Bash no Windows), com o ambiente rodando:

```bash
./scripts/export.sh
```

Gera e verifica `./backup/<DB_NAME>.bak`, sobrescrevendo o arquivo existente.

## Acesso de outras máquinas e porta

Por padrão o SQL Server só aceita conexões da própria máquina (`localhost,1433`).

Variáveis opcionais no `.env`:

| Variável   | Padrão      | Uso                                                                 |
|------------|-------------|---------------------------------------------------------------------|
| `SQL_BIND` | `127.0.0.1` | Use `0.0.0.0` para liberar acesso de outras máquinas da rede        |
| `SQL_PORT` | `1433`      | Porta no host (ex.: `1434` se já houver um SQL Server instalado)     |

> Ao liberar acesso externo (`SQL_BIND=0.0.0.0`), use uma senha forte no `.env`.
> Mudanças só de `SQL_BIND`/`SQL_PORT` são aplicadas com `docker compose up -d`.

## Problemas comuns

| Sintoma                                                        | Causa                                                    | Solução                                                         |
|----------------------------------------------------------------|----------------------------------------------------------|-----------------------------------------------------------------|
| `sqldev` fica `unhealthy` ou reiniciando                       | Senha não atende aos requisitos                          | Ajuste `MSSQL_SA_PASSWORD` e rode `docker compose down -v && docker compose up -d` |
| `port is already allocated`                                    | Já existe um SQL Server usando a porta 1433              | Defina `SQL_PORT=1434` no `.env` e conecte em `localhost,1434`  |
| Log do restore: `Sem .bak, nada a restaurar.`                  | Arquivo não está em `./backup/` ou nome ≠ `DB_NAME`      | Renomeie para `<DB_NAME>.bak` e rode `docker compose up -d`     |
| Log do restore: `Banco já existe, pulando restore.`            | O restore só acontece quando o banco ainda não existe    | Para restaurar de novo: `docker compose down -v && docker compose up -d` |
| Login falha após trocar a senha no `.env`                      | A senha fica gravada no volume na primeira subida        | `docker compose down -v && docker compose up -d`                |
