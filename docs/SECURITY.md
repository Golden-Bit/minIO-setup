# Security notes

## 1) Root credentials

Le variabili `MINIO_ROOT_USER` e `MINIO_ROOT_PASSWORD` danno accesso totale.

Best practice:

- generare credenziali lunghe e casuali
- non inserirle nel repository
- non usarle nelle applicazioni
- conservarle in un secret manager quando possibile

## 2) Esposizione pubblica

Pattern raccomandato:

- MinIO in bind locale (`127.0.0.1`)
- Nginx su 80/443
- TLS con Let's Encrypt
- firewall / security group restrittivo

Evita, se possibile:

- esposizione diretta di 9000/9001 su internet
- credenziali root condivise tra persone o servizi

## 3) Utenti applicativi

Crea utenti separati per le applicazioni, con policy minimali.

Per esempio:

- un servizio upload -> `readwrite`
- un processo sola lettura -> `readonly`

## 4) Bucket versioning

Per bucket critici è fortemente consigliato attivare il versioning.

Benefici:

- recupero più semplice da overwrite accidentali
- minore rischio operativo su oggetti importanti

## 5) Backup

Il backup dei dati MinIO deve essere:

- regolare
- verificato
- accompagnato da test di restore

Un backup non testato non è un vero backup.

## 6) Sistema host

Hardening minimo host:

- SSH limitato / preferenza per SSM o VPN
- pacchetti aggiornati
- accesso sudo controllato
- fail2ban / WAF / IP allowlist se esponi in pubblico

## 7) TLS

Se il servizio è pubblico, usa sempre HTTPS.

Per semplicità e manutenibilità, questo repository propone TLS terminato su Nginx.
