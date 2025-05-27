Progetto di Basi di Dati 2025

Per compilare su macOs
```bash
clang -I$(pg_config --includedir) -L$(pg_config --libdir) -lpq -o script script.c
```
Dovrebbe essere analogo in gcc

Se si vuole, definire le credenziali in un file credentials.h con la seguente struttura:
```
#ifndef CREDENTIALS_H
#define CREDENTIALS_H

#define DB_NAME "db"
#define USER "user"
#define PASSWORD "passw"

#endif
```