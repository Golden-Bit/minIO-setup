# Bucket virtual-host style

## Cosa significa

Di default i client possono usare path-style:

```text
https://minio.example.com/my-bucket/my-object.txt
```

Con `MINIO_DOMAIN`, puoi usare virtual-host style:

```text
https://my-bucket.s3.example.com/my-object.txt
```

## Quando serve

Serve soprattutto quando:

- un client S3 si aspetta bucket come subdominio
- vuoi un routing più simile ad S3 AWS
- vuoi una separazione DNS più elegante

## Requisiti

Per usare questa modalità servono in modo coerente:

1. `MINIO_DOMAIN=s3.example.com`
2. DNS wildcard o record bucket-specific coerenti
3. TLS coerente con i nomi host serviti
4. reverse proxy capace di inoltrare correttamente l'host

## Esempio

Nel file `.env`:

```env
MINIO_DOMAIN=s3.example.com
MINIO_SERVER_URL=https://s3.example.com
MINIO_BROWSER_REDIRECT_URL=https://console.minio.example.com
```

## Attenzione

Questa modalità è più avanzata del normale setup con due hostnames fissi.

Se non ti serve esplicitamente, resta su:

- `minio.example.com` per API
- `console.minio.example.com` per Console
