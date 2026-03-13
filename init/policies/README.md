# Policy examples

Questa cartella contiene esempi di policy JSON in stile MinIO / IAM.

Nel bootstrap automatico di questo repository viene usata, per semplicità, una **policy built-in**
configurabile con `MINIO_DEFAULT_USER_POLICY`.

Questi file servono come base per personalizzazioni future, ad esempio se vuoi usare:

```bash
mc admin policy create local app-readonly ./init/policies/app-readonly.json
mc admin policy attach local app-readonly --user myapp
```

oppure:

```bash
mc admin policy create local app-readwrite ./init/policies/app-readwrite.json
mc admin policy attach local app-readwrite --user myapp
```
