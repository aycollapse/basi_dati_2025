#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>

//prova ad includere l'header con i nostri dati privati
//se non presente definire i valori manualmente sotto
#ifdef __has_include
#  if __has_include("credentials.h")
#    include "credentials.h"
#  endif
#endif

//sostituire coi valori giusti
#ifndef DB_NAME
    #define DB_NAME "db_name" 
#endif

#ifndef USER
    #define USER "user_name" 
#endif

#ifndef PASSWORD
    #define PASSWORD "user_password" 
#endif

#define TAB 40  // questo valore indica la larghezza di ogni colonna quando si vanno a stampare le tabelle risultanti delle query

void exit_db(PGconn *conn);
void print_menu();
void clear_screen();
void print_cell(const char *str);
void checkerr_prepare(PGresult *res, PGconn *conn);
void checkerr_result(PGresult *res, PGconn *conn);

int main()
{
    char connectdbstr[256];
    snprintf(connectdbstr, sizeof(connectdbstr),
             "dbname=%s user=%s password=%s host=localhost port=5432",
             DB_NAME, USER, PASSWORD);

    PGconn *conn = PQconnectdb(connectdbstr);
    PGresult *res;

    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connessione al DB fallita: %s", PQerrorMessage(conn));
        exit_db(conn);
    }

    // Query
    const char *query_1 = "SELECT nome_utente, numero FROM ("
                          "SELECT nome_utente, COUNT(*) AS numero "
                          "FROM media_visti_utente GROUP BY nome_utente) AS sub "
                          "WHERE numero = ("
                          "SELECT MAX(numero)"
                          "FROM ("
                          "SELECT COUNT(*) AS numero "
                          "FROM media_visti_utente GROUP BY nome_utente) AS counts);";
    checkerr_prepare(PQprepare(conn, "utenti_piu_attivi", query_1, 0, NULL), conn);

    const char *query_2 = "SELECT * FROM (SELECT nome_serie_tv AS serie_tv, AVG(rating_imdb) AS media_rating_episodi from episodio "
                          "inner join serie_tv on episodio.nome_serie_tv = serie_tv.nome "
                          "inner join media on media.id_media = episodio.id_episodio GROUP BY nome_serie_tv) AS tabella where media_rating_episodi >= $1::float";
    checkerr_prepare(PQprepare(conn, "serie_dato_rating", query_2, 1, NULL), conn);

    const char *query_3 = "SELECT titolo, incassi from media inner join film on media.id_media = film.id_film Where incassi >= $1::int";
    checkerr_prepare(PQprepare(conn, "film_dato_incassi", query_3, 1, NULL), conn);

    const char *query_4 = "SELECT nome_serie_tv, count(id_episodio) AS numero_episodi from episodio inner join serie_tv on episodio.nome_serie_tv = serie_tv.nome "
                          "INNER join media on media.id_media = episodio.id_episodio GROUP by nome_serie_tv "
                          "HAVING count(id_episodio)>= $1::int";
    checkerr_prepare(PQprepare(conn, "serie_con_almeno_tot_episodi", query_4, 1, NULL), conn);

    const char *query_5 = "SELECT media.titolo, casting_media_membro.ruolo, serie_tv.nome AS nome_serie_tv FROM membro "
                          "INNER JOIN casting_media_membro ON membro.codice_fiscale = casting_media_membro.codice_fiscale_membro "
                          "INNER JOIN media ON media.id_media = casting_media_membro.id_media_casting "
                          "LEFT JOIN episodio ON media.id_media = episodio.id_episodio "
                          "LEFT JOIN serie_tv ON episodio.nome_serie_tv = serie_tv.nome "
                          "WHERE membro.codice_fiscale = $1";
    checkerr_prepare(PQprepare(conn, "opere_vittorio_delmi", query_5, 1, NULL), conn);

    const char *query_6 = "SELECT m.titolo AS titolo_media,s.nome AS titolo_serie_tv,AVG(mvu.rating_utente) AS media_voti_utenti, m.rating_imdb "
                          "FROM media m "
                          "JOIN media_visti_utente mvu ON m.id_media = mvu.id_media_visto "
                          "LEFT JOIN episodio e ON m.id_media = e.id_episodio "
                          "LEFT JOIN serie_tv s ON e.nome_serie_tv = s.nome "
                          "GROUP BY m.id_media, m.titolo, s.nome, m.rating_imdb "
                          "HAVING AVG(mvu.rating_utente) > m.rating_imdb";
    checkerr_prepare(PQprepare(conn, "confronto_rating", query_6, 1, NULL), conn);

    int scelta_query;
    int num_tuple;
    int num_attr;

    // loop esecuzione
    while (1) {
        clear_screen();
        print_menu();
        printf("\nSeleziona query da eseguire: ");
        scanf("%d", &scelta_query);
        while (getchar() != '\n');

        switch (scelta_query) {
            case 0:
                printf("Esci\n");
                exit_db(conn);
                break;
            case 1:
                res = PQexecPrepared(conn, "utenti_piu_attivi", 0, NULL, NULL, NULL, 0);
                break;
            case 2: {
                char rating_str[32];
                float rating;
                printf("Inserire rating minimo: ");
                scanf("%f", &rating);
                snprintf(rating_str, sizeof(rating_str), "%f", rating);
                const char *params[] = { rating_str };
                res = PQexecPrepared(conn, "serie_dato_rating", 1, params, NULL, NULL, 0);
                break;
            }
            case 3: {
                char incassi_str[32];
                int incassi;
                printf("Inserire incassi: ");
                scanf("%d", &incassi);
                snprintf(incassi_str, sizeof(incassi_str), "%d", incassi);
                const char *params[] = { incassi_str };
                res = PQexecPrepared(conn, "film_dato_incassi", 1, params, NULL, NULL, 0);
                break;
            }
            case 4: {
                char episodi_str[32];
                int num_episodi;
                printf("Inserire numero di episodi: ");
                scanf("%d", &num_episodi);
                snprintf(episodi_str, sizeof(episodi_str), "%d", num_episodi);
                const char *params[] = { episodi_str };
                res = PQexecPrepared(conn, "serie_con_almeno_tot_episodi", 1, params, NULL, NULL, 0);
                break;
            }
            case 5: {
                const char *params[] = { "VLNTDR81D22F205Y" };
                res = PQexecPrepared(conn, "opere_vittorio_delmi", 1, params, NULL, NULL, 0);
                break;
            }
            case 6: {
                res = PQexecPrepared(conn, "confronto_rating", 0, NULL, NULL, NULL, 0);
                break;
            }
            default:
                printf("Scegliere un numero valido\n");
                continue;
        }

        checkerr_result(res, conn);
        num_tuple = PQntuples(res);
        num_attr = PQnfields(res);

        // Stampa colonne tabella
        for (int i = 0; i < num_attr; i++) {
            printf("| %-*s", TAB - 2, PQfname(res, i));
        }
        printf("|\n");

        for (int i = 0; i < num_attr; i++) {
            for (int j = 0; j < TAB; j++) printf("-");
        }
        printf("\n");

        // Stampa le righe della tabella
        for (int i = 0; i < num_tuple; i++) {
            for (int j = 0; j < num_attr; j++) {
                printf("| ");
                print_cell(PQgetvalue(res, i, j));
            } 
        printf("|\n");
        }

        PQclear(res);

        char risposta;
        do {
            printf("\nContinuare? [y/n] ");
            scanf(" %c", &risposta); 
        } while (risposta != 'y' && risposta != 'Y' && risposta != 'n' && risposta != 'N');

        if (risposta == 'n' || risposta == 'N') {
            exit_db(conn);
        }

    }

    exit_db(conn);
}

void exit_db(PGconn *conn)
{
    PQfinish(conn);
    exit(1);
}

//pulisce il terminale
void clear_screen() { 
    printf("\033[2J\033[H");
    fflush(stdout);
}

void print_menu()
{
    printf("*************\n");
    printf("** Opzioni **\n");
    printf("*************\n");
    printf("0) Esci\n");
    printf("1) Trova l'utente/gli utenti che ha/hanno visto più film\n");
    printf("2) Dato il rating restituisce le serie tv con valutazione maggiore o uguale (parametrica)\n");
    printf("3) Dato un numero di incassi restituisce i film con introiti maggiori o uguali (parametrica)\n");
    printf("4) Dato un numero di episodi restituisce le serie tv almeno quel numero episodi (parametrica)\n");
    printf("5) Trova tutti gli episodi di serie tv e film dove ha partecipato Dario Valenti\n");
    printf("6) Mostra tutti i media che hanno un rating medio sulla piattaforma più alta del raing su imdb\n");
}

//questa funzione serve a troncare i valori che eccedono lo spazio definito in TAB per una singola cella
//succedeva per esempio che stampando il titolo di un film del signore degli anelli la tabella venisse stampata male
void print_cell(const char *str) {
    int len = strlen(str);
    if (len > TAB - 3) {
        for (int i = 0; i < TAB - 6; i++) {
            putchar(str[i]);
        }
        printf("... "); 
    } else {
        printf("%-*s", TAB - 2, str);
    }
}

void checkerr_prepare(PGresult *res, PGconn *conn)
{
    if (PQresultStatus(res) != PGRES_COMMAND_OK) {
        fprintf(stderr, "Preparazione fallita: %s", PQerrorMessage(conn));
        PQclear(res);
        exit_db(conn);
    }
    PQclear(res);
}

void checkerr_result(PGresult *res, PGconn *conn)
{
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Operazione fallita: %s", PQerrorMessage(conn));
        PQclear(res);
        exit_db(conn);
    }
}
