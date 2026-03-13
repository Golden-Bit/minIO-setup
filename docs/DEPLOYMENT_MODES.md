# Deployment modes

Questo repository supporta tre modalità operative.

## 1) Local-only (default)

Configurazione:

- `MINIO_API_BIND_IP=127.0.0.1`
- `MINIO_CONSOLE_BIND_IP=127.0.0.1`

Pro:

- superficie d'attacco minima
- ideale per sviluppo, test, accesso da tunnel SSH/SSM/VPN
- semplice da manutenere

Contro:

- non accessibile direttamente dall'esterno

## 2) Public via Nginx + TLS (raccomandata)

Configurazione:

- MinIO resta bindato su loopback
- Nginx pubblica 80/443
- Certbot installa i certificati
- `MINIO_SERVER_URL` e `MINIO_BROWSER_REDIRECT_URL` valorizzati

Pro:

- approccio più pulito per domini pubblici
- TLS centralizzato
- nessuna esposizione diretta di 9000/9001
- facile da integrare con WAF / allowlist / proxy aggiuntivi

Contro:

- richiede DNS e configurazione reverse proxy

## 3) Direct public bind (sconsigliata)

Configurazione:

- `MINIO_API_BIND_IP=0.0.0.0`
- `MINIO_CONSOLE_BIND_IP=0.0.0.0`

Pro:

- molto semplice

Contro:

- non consigliabile in produzione pubblica
- maggiore esposizione del servizio
- gestione TLS più scomoda
- più difficile aggiungere hardening edge-level

## Raccomandazione pratica

- locale/dev/interno -> modalità 1
- pubblico/produzione -> modalità 2
- test veloci su rete privata -> modalità 3 solo se sai esattamente cosa stai facendo
