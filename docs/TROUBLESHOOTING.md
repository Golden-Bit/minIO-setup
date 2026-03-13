# Troubleshooting

## 1) `curl: (7) Failed to connect` durante healthcheck

Cause comuni:

- MinIO non è partito
- porta diversa da quella configurata
- `.env` incoerente

Verifiche:

```bash
docker compose ps
docker compose logs minio
cat .env
```

## 2) La Console non si apre correttamente dietro proxy

Cause comuni:

- `MINIO_BROWSER_REDIRECT_URL` non impostata
- dominio Nginx errato
- certificato non valido

Verifica:

```bash
grep MINIO_BROWSER_REDIRECT_URL .env
sudo nginx -t
```

## 3) I client S3 falliscono con redirect / signature mismatch

Cause comuni:

- `Host` header non inoltrato dal proxy
- uso di un dominio diverso da quello atteso
- configurazione virtual-host style parziale

Verifica Nginx:

```nginx
proxy_set_header Host $http_host;
```

## 4) Il bootstrap non crea bucket o utenti

Cause comuni:

- credenziali root errate
- MinIO non ancora pronto
- variabili bootstrap vuote

Verifica:

```bash
./scripts/bootstrap.sh
docker compose run --rm --no-deps mc sh
```

## 5) Restore fallito o dati inconsistenti

Cause comuni:

- restore eseguito con servizio attivo
- archivio errato / corrotto

Raccomandazione:

- eseguire sempre restore a servizio fermo
- verificare l'archivio con `tar -tzf`

## 6) Nginx non parte

Verifica:

```bash
sudo nginx -t
sudo systemctl status nginx --no-pager
```

## 7) Certbot fallisce

Controlla:

- DNS corretto
- porte 80/443 aperte
- vhost Nginx raggiungibile dall'esterno
