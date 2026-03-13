# TLS e reverse proxy

## Perché usare Nginx davanti a MinIO

Vantaggi principali:

- terminazione TLS centralizzata
- domini separati per API e Console
- nessuna esposizione diretta di 9000/9001
- integrazione facile con Certbot

## Schema consigliato

- `minio.example.com` -> `127.0.0.1:9000`
- `console.minio.example.com` -> `127.0.0.1:9001`

## Impostazioni fondamentali in Nginx

Per l'API S3 sono fondamentali:

```nginx
client_max_body_size 0;
proxy_buffering off;
proxy_request_buffering off;
```

Questo evita problemi con upload e download di oggetti grandi.

## Variabili MinIO da ricordare

Nel file `.env`:

```env
MINIO_SERVER_URL=https://minio.example.com
MINIO_BROWSER_REDIRECT_URL=https://console.minio.example.com
```

Se pubblichi la Console dietro reverse proxy e dimentichi `MINIO_BROWSER_REDIRECT_URL`, i redirect della Console possono comportarsi in modo errato.

## Certbot

Esempio tipico:

```bash
sudo certbot --nginx -d minio.example.com -d console.minio.example.com
```

## Porte da esporre pubblicamente

In un setup con Nginx:

- apri `80/tcp` e `443/tcp`
- non aprire `9000/tcp` e `9001/tcp`
