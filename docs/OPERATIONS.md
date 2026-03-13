# Operazioni quotidiane

## Avvio

```bash
./scripts/up.sh
```

## Stop

```bash
./scripts/down.sh
```

## Logs

```bash
./scripts/logs.sh
```

## Healthcheck

```bash
./scripts/healthcheck.sh
```

## Stampa endpoint

```bash
./scripts/print-endpoints.sh
```

## Bootstrap bucket e user

```bash
./scripts/bootstrap.sh
```

## Backup

```bash
./scripts/backup_data.sh
```

## Restore

```bash
./scripts/restore_data.sh ./backups/minio_data_xxx.tar.gz
```

## Update

```bash
./scripts/update.sh
```

## Comandi utili manuali

Shell nel container MinIO:

```bash
docker compose exec minio sh
```

Shell nel container `mc`:

```bash
docker compose run --rm --no-deps mc sh
```

Visualizzare stato stack:

```bash
docker compose ps
```
