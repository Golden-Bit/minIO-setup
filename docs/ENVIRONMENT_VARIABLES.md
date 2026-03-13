# Variabili ambiente

Questo documento spiega le variabili principali presenti in `.env.example`.

## Immagini

### `MINIO_IMAGE`
Tag immagine del server MinIO.

### `MC_IMAGE`
Tag immagine del client `mc` usato per bootstrap e operazioni amministrative.

## Credenziali root

### `MINIO_ROOT_USER`
Access key amministrativa primaria.

### `MINIO_ROOT_PASSWORD`
Secret key amministrativa primaria.

> Non usare queste credenziali dentro applicazioni business. Crea un utente dedicato.

## Persistenza e contesto

### `MINIO_DATA_DIR`
Path dati interna al container. In questo repository vale `/data`.

### `DATA_DIR`
Directory dati sul filesystem host. Di default `./data`.

### `BACKUP_DIR`
Directory backup sul filesystem host. Di default `./backups`.

### `MINIO_REGION_NAME`
Regione logica S3 usata dal server.

### `TZ`
Timezone del container.

## Porte e binding

### `MINIO_API_BIND_IP`
IP di bind host della porta API S3.

- `127.0.0.1` = solo locale
- `0.0.0.0` = esposto su tutte le interfacce

### `MINIO_API_HOST_PORT`
Porta host per l'API S3.

### `MINIO_CONSOLE_BIND_IP`
IP di bind host della Console.

### `MINIO_CONSOLE_HOST_PORT`
Porta host della Console.

## Healthcheck

### `MINIO_HEALTHCHECK_HOST`
Host usato dagli script locali per pingare `/minio/health/live` e `/minio/health/ready`.

### `MINIO_HEALTHCHECK_SCHEME`
Protocollo usato dagli script locali (`http` o `https`).

## URL pubblici / reverse proxy

### `MINIO_SERVER_URL`
URL pubblico dell'API S3. Serve quando pubblichi MinIO dietro reverse proxy / load balancer.

Esempio:

```env
MINIO_SERVER_URL=https://minio.example.com
```

### `MINIO_BROWSER_REDIRECT_URL`
URL pubblico della Console. Importantissimo quando la Console viene pubblicata dietro reverse proxy.

Esempio:

```env
MINIO_BROWSER_REDIRECT_URL=https://console.minio.example.com
```

### `MINIO_BROWSER_REDIRECT`
Se `true`, le richieste browser vengono redirette verso la Console.

### `MINIO_BROWSER`
Abilita/disabilita la Console embedded (`on` / `off`).

### `MINIO_BROWSER_LOGIN_ANIMATION`
Abilita/disabilita l'animazione di login (`on` / `off`).

### `MINIO_BROWSER_SESSION_DURATION`
Durata sessione browser. Esempi: `12h`, `24h`, `7d`.

## Metrics

### `MINIO_PROMETHEUS_AUTH_TYPE`
Controlla come vengono esposte le metriche Prometheus.

Valori comuni:

- `public`
- `jwt`

## Bucket virtual-host style

### `MINIO_DOMAIN`
Dominio base per bucket virtual-host style.

Esempio:

```env
MINIO_DOMAIN=s3.example.com
```

In questo caso un bucket può diventare:

```text
my-bucket.s3.example.com
```

Questa funzione richiede DNS/TLS coerenti, spesso con wildcard.

## Bootstrap

### `MINIO_DEFAULT_BUCKETS`
Lista bucket iniziali separati da virgola.

### `MINIO_ENABLE_VERSIONING`
Se `true`, abilita il versioning sui bucket creati in bootstrap.

### `MINIO_DEFAULT_USER`
Utente applicativo opzionale.

### `MINIO_DEFAULT_USER_PASSWORD`
Password dell'utente applicativo.

### `MINIO_DEFAULT_USER_POLICY`
Policy built-in assegnata all'utente applicativo.

Valori tipici:

- `readwrite`
- `readonly`
- `consoleAdmin`
- `diagnostics`
