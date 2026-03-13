# MinIO Setup su Ubuntu/EC2 (Docker Compose + Nginx opzionale + TLS)

Data: 2026-03-13

Questa repository contiene una procedura operativa DevOps per installare **MinIO** come **object storage S3-compatible** su un server Ubuntu (EC2 o simile) usando:

- Docker Compose
- bind locale di default (`127.0.0.1`) per non esporre il servizio direttamente
- pubblicazione opzionale via **Nginx reverse proxy** su **80/443**
- supporto a **dominio dedicato** per API S3 e Console
- supporto opzionale a **bucket virtual-host style** tramite `MINIO_DOMAIN`
- script operativi per avvio, healthcheck, bootstrap bucket/utente, backup/restore, aggiornamento e log
- servizio **systemd** per avvio automatico al reboot
- hardening minimo e documentazione dettagliata

> Nota importante: il setup è pensato per **single-node / single-instance**. È ottimo per sviluppo, ambienti small/medium e use case applicativi dove serve object storage privato S3-compatible. Se ti servono HA reali, tolleranza a fault di nodo o scalabilità multi-node, devi progettare una topologia distribuita dedicata.

---

## 0) Obiettivi del repository

Questo repository nasce per avere un setup **analogo nello stile** ai repository di provisioning già presenti per Keycloak, PostgreSQL e OpenFGA:

- file `docker-compose.yml` leggibile e commentato
- `.env.example` esaustivo, con spiegazione delle variabili
- cartelle `docs/`, `nginx/`, `scripts/`, `systemd/`, `init/`
- approccio operativo e non solo dimostrativo
- versioni **pinnate** e niente secret nel repository

---

## 1) Architettura logica

### Componenti principali

1. **MinIO server**
   - espone l'API S3 sulla porta `9000`
   - espone la Console sulla porta `9001`
   - salva i dati nella directory persistente `./data`

2. **MinIO Client (`mc`)**
   - usato come tool operativo dentro un container effimero
   - serve per bootstrap bucket, utenti, policy e verifiche

3. **Nginx (opzionale, sul sistema host)**
   - pubblica l'API S3 su un dominio, ad esempio `minio.example.com`
   - pubblica la Console su un dominio separato, ad esempio `console.minio.example.com`
   - gestisce TLS tramite Certbot / Let's Encrypt

### Perché due hostnames separati

Per deployment pubblici, il pattern raccomandato è:

- `minio.example.com` -> API S3 (`9000`)
- `console.minio.example.com` -> Console (`9001`)

Questo è il modello più semplice e pulito per reverse proxy, redirect della Console e client S3.

---

## 2) Struttura del repository

```text
minio-setup/
├─ docker-compose.yml
├─ .env.example
├─ .gitignore
├─ LICENSE
├─ README.md
├─ SECURITY.md
├─ data/
│  └─ .gitkeep
├─ backups/
│  └─ .gitkeep
├─ init/
│  └─ policies/
│     ├─ README.md
│     ├─ app-readonly.json
│     └─ app-readwrite.json
├─ nginx/
│  ├─ minio-api.conf
│  └─ minio-console.conf
├─ scripts/
│  ├─ _common.sh
│  ├─ docker-entrypoint.sh
│  ├─ up.sh
│  ├─ down.sh
│  ├─ logs.sh
│  ├─ healthcheck.sh
│  ├─ bootstrap.sh
│  ├─ bootstrap-mc.sh
│  ├─ backup_data.sh
│  ├─ restore_data.sh
│  ├─ update.sh
│  └─ print-endpoints.sh
├─ systemd/
│  └─ minio-compose.service
└─ docs/
   ├─ DEPLOYMENT_MODES.md
   ├─ ENVIRONMENT_VARIABLES.md
   ├─ OPERATIONS.md
   ├─ SECURITY.md
   ├─ TLS_AND_REVERSE_PROXY.md
   ├─ TROUBLESHOOTING.md
   └─ VIRTUAL_HOST_BUCKETS.md
```

---

## 3) Prerequisiti

Sistema target consigliato:

- Ubuntu 22.04 o 24.04
- Docker Engine + Docker Compose plugin
- almeno 2 vCPU / 4 GB RAM per ambienti piccoli
- storage persistente su disco affidabile
- DNS configurabile se vuoi esposizione pubblica

Se Docker non è installato:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

---

## 4) Quick start locale (raccomandato)

### 4.1 Copia il template `.env`

```bash
cp .env.example .env
chmod 600 .env
```

Compila almeno questi campi:

- `MINIO_ROOT_USER`
- `MINIO_ROOT_PASSWORD`
- opzionalmente `MINIO_DEFAULT_BUCKETS`
- opzionalmente `MINIO_DEFAULT_USER` / `MINIO_DEFAULT_USER_PASSWORD`

### 4.2 Avvio

```bash
./scripts/up.sh
```

### 4.3 Verifica salute del servizio

```bash
./scripts/healthcheck.sh
```

### 4.4 Mostra endpoint utili

```bash
./scripts/print-endpoints.sh
```

Con configurazione locale di default, gli endpoint saranno:

- API S3: `http://127.0.0.1:9000`
- Console: `http://127.0.0.1:9001`

### 4.5 Bootstrap bucket e utente applicativo (opzionale)

Se hai valorizzato le variabili relative al bootstrap nel file `.env`, esegui:

```bash
./scripts/bootstrap.sh
```

Questo script può:

- creare uno o più bucket iniziali
- abilitare il versioning sui bucket creati
- creare un utente applicativo separato dal root user
- assegnare una policy built-in (`readwrite`, `readonly`, `consoleAdmin`, `diagnostics`)

---

## 5) Modalità di deploy supportate

### Modalità A - Solo locale / host-local (default)

Valori predefiniti:

- `MINIO_API_BIND_IP=127.0.0.1`
- `MINIO_CONSOLE_BIND_IP=127.0.0.1`

Risultato:

- MinIO non è esposto direttamente su internet
- si accede dal server locale oppure via tunnel/SSM/VPN
- è il modello più sicuro per sviluppo e ambienti interni

### Modalità B - Pubblicazione pubblica tramite Nginx + TLS (**raccomandata**) 

Si mantiene MinIO bindato su loopback, e si pubblicano:

- `minio.example.com` -> API S3
- `console.minio.example.com` -> Console

con:

- Nginx sul nodo host
- Certbot / Let's Encrypt
- TLS terminato sul reverse proxy

### Modalità C - Esposizione diretta delle porte del container (**sconsigliata**) 

Puoi impostare nel file `.env`:

```env
MINIO_API_BIND_IP=0.0.0.0
MINIO_CONSOLE_BIND_IP=0.0.0.0
```

Questo espone direttamente 9000/9001 sul server. È utile solo per test rapidi o reti private controllate. In pubblico è fortemente preferibile il reverse proxy con TLS.

---

## 6) Pubblicazione sotto dominio con certificato TLS

### 6.1 DNS

Configura due record DNS verso il server:

- `minio.example.com`
- `console.minio.example.com`

### 6.2 Aggiorna `.env`

Imposta:

```env
MINIO_BROWSER_REDIRECT_URL=https://console.minio.example.com
MINIO_SERVER_URL=https://minio.example.com
```

Se vuoi anche bucket virtual-host style (opzionale avanzato):

```env
MINIO_DOMAIN=s3.example.com
```

### 6.3 Installa Nginx

```bash
sudo apt update
sudo apt install -y nginx
sudo systemctl enable --now nginx
```

### 6.4 Installa i vhost

```bash
sudo cp nginx/minio-api.conf /etc/nginx/sites-available/minio-api
sudo cp nginx/minio-console.conf /etc/nginx/sites-available/minio-console
sudo ln -sf /etc/nginx/sites-available/minio-api /etc/nginx/sites-enabled/minio-api
sudo ln -sf /etc/nginx/sites-available/minio-console /etc/nginx/sites-enabled/minio-console
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

> Ricordati di sostituire i `server_name` placeholder nei file Nginx.

### 6.5 Certificati Let's Encrypt

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d minio.example.com -d console.minio.example.com
sudo certbot renew --dry-run
```

### 6.6 Security group / firewall

Apri solo:

- `80/tcp`
- `443/tcp`

Non aprire pubblicamente `9000` e `9001` se usi Nginx come reverse proxy.

---

## 7) Uso applicativo

Puoi usare MinIO da:

- SDK MinIO ufficiali
- AWS SDK (compatibilità S3)
- `mc`
- AWS CLI / s3cmd / client compatibili S3

Esempio `mc` da host (se installato localmente):

```bash
mc alias set localminio http://127.0.0.1:9000 <ROOT_USER> <ROOT_PASSWORD>
mc admin info localminio
mc ls localminio
```

Esempio bucket:

```bash
mc mb localminio/my-bucket
mc cp ./file.txt localminio/my-bucket/
```

---

## 8) Persistenza dati

Il volume dati è la directory locale:

```text
./data
```

Questa directory contiene i dati effettivi di MinIO. **Non va persa**.

Raccomandazioni:

- montarla su disco persistente
- includerla in una strategia di backup
- evitare cancellazioni manuali
- fare restore solo a servizio fermo

---

## 9) Backup e restore

### Backup

```bash
./scripts/backup_data.sh
```

Lo script:

- controlla se MinIO è attivo
- se attivo, lo ferma temporaneamente per ottenere un backup coerente
- comprime `./data` in `./backups/`
- riavvia MinIO se prima era in esecuzione

### Restore

```bash
./scripts/restore_data.sh ./backups/minio_data_YYYYmmdd_HHMMSS.tar.gz
```

Lo script:

- ferma MinIO
- fa un backup preventivo della data directory corrente
- ripristina l'archivio indicato
- riavvia il servizio

---

## 10) Aggiornamento

1. modifica i tag delle immagini in `.env`
2. leggi le release notes upstream
3. esegui:

```bash
./scripts/update.sh
```

Lo script effettua:

- pull immagini
- recreate controllata del container
- verifica finale dello stato

---

## 11) Avvio automatico con systemd

Copia il service file:

```bash
sudo mkdir -p /opt/minio-setup
sudo rsync -a ./ /opt/minio-setup/
sudo cp systemd/minio-compose.service /etc/systemd/system/minio-compose.service
sudo systemctl daemon-reload
sudo systemctl enable --now minio-compose
sudo systemctl status minio-compose --no-pager
```

---

## 12) File principali e loro ruolo

### `docker-compose.yml`
Contiene:

- servizio `minio`
- servizio `mc` per operazioni amministrative/di bootstrap
- binding porte parametrico
- persistency dei dati

### `.env.example`
Template completo di configurazione:

- credenziali root
- bind IP/porte
- URL pubblici
- bootstrap bucket/utente
- opzioni Console
- opzioni S3 virtual-host style

### `scripts/`
Operatività quotidiana:

- start/stop/logs
- healthcheck
- bootstrap bucket e user
- backup/restore
- aggiornamento

### `nginx/`
Template Nginx per:

- API S3
- Console

### `systemd/`
Servizio di avvio automatico via systemd.

### `docs/`
Approfondimenti su:

- variabili ambiente
- deployment modes
- sicurezza
- TLS / reverse proxy
- troubleshooting
- virtual-host buckets

---

## 13) Hardening minimo consigliato

- non usare mai `minioadmin:minioadmin`
- non versionare `.env`
- non esporre 9000/9001 direttamente se non necessario
- usa sempre TLS in pubblico
- crea un utente applicativo dedicato, non usare il root user nell'applicazione
- abilita versioning sui bucket critici
- fai backup regolari e test di restore
- limita l'accesso SSH/SSM al server
- proteggi il Security Group / firewall

Dettagli in `docs/SECURITY.md`.

---

## 14) Note sulla scelta immagini

Questo repository usa tag **pinnati**, non `latest`, per evitare aggiornamenti impliciti e comportamenti non deterministici.

Controlla periodicamente la strategia di distribuzione upstream prima di aggiornare i tag immagini o il binario.

---

## 15) Troubleshooting

Vedi `docs/TROUBLESHOOTING.md`.

---

## 16) Licenza

MIT.
