#include <stdio.h>
#include <stdlib.h>
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

void exit_db(PGconn *conn);

void print_menu();

void checkerr(PGresult *res, PGconn *conn);

int main()
{
    char connectdbstr[256];
    snprintf(connectdbstr, sizeof(connectdbstr),
            "dbname=%s user=%s password=%s host=localhost port=5432",
            DB_NAME, USER, PASSWORD);
    PGconn *conn = PQconnectdb(connectdbstr);
    PGresult *res;
    print_menu();
    int scelta_query;
    int num_tuple;
    int num_attr;
    
    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connessione al DB fallita: %s", PQerrorMessage(conn));
        exit_db(conn);
    }

    // LOOP PRINCIPALE
    while(1){
        printf("Seleziona query da eseguire: ");
        scanf("%d", &scelta_query);
        while(getchar() != '\n'); //filtra input

        switch(scelta_query){
            case 0:
                printf("Esci\n");
                exit_db(conn);
                break;
            case 1:
                res = PQexec(conn,  "SELECT nome_utente, numero FROM ("
                                            "SELECT nome_utente, COUNT(*) AS numero "
                                            "FROM media_visti_utente GROUP BY nome_utente) AS sub "
                                        "WHERE numero = ("
                                            "SELECT MAX(numero)"
                                            "FROM ("
                                            "SELECT COUNT(*) AS numero "
                                            "FROM media_visti_utente GROUP BY nome_utente) AS counts);");
                checkerr(res, conn);
                num_tuple = PQntuples(res);
                num_attr = PQnfields(res);

                for(int i = 0; i < num_attr; i++)
                {
                    fprintf(stdout, "%s\t", PQfname(res, i));
                }
                fprintf(stdout, "\n");

                for(int i = 0; i < num_tuple; i++)
                {
                    for (int j = 0; j < num_attr; j++)
                    {
                        fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                    }
                    fprintf(stdout, "\n");
                }
                PQclear(res);
                break;
            case 2:
                char* query = "SELECT * FROM (SELECT nome_serie_tv AS serie_tv, AVG(rating_imdb) AS media_rating_episodi from episodio "
                              "inner join serie_tv on episodio.nome_serie_tv = serie_tv.nome "
                              "inner join media on media.id_media = episodio.id_episodio GROUP BY nome_serie_tv) AS tabella where media_rating_episodi >= $1::float"
                
                PGresult* res = PQprepare ( conn , "serie_dato_rating" , query , 1 , NULL );
                float rating;
                printf ("Inserire rating minimo: ") ;
                scanf ("%f", rating);
                
                res = PQexecPrepared (conn, "serie_dato_rating", 1, &rating, NULL, 0, 0);

                checkerr(res, conn);
                num_tuple = PQntuples(res);
                num_attr = PQnfields(res);


                for(int i = 0; i < num_attr; i++)
                {
                    fprintf(stdout, "%s\t", PQfname(res, i));
                }
                fprintf(stdout, "\n");

                for(int i = 0; i < num_tuple; i++)
                {
                    for (int j = 0; j < num_attr; j++)
                    {
                        fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                    }
                    fprintf(stdout, "\n");
                }

                /*
                // Stampa i headers con larghezza fissa
                fprintf(stdout, "%-20s %-15s\n", 
                    PQfname(res, 0), 
                    PQfname(res, 1));
                fprintf(stdout, "----------------------------------------\n");

                // Stampa i dati con larghezza fissa
                for(int i = 0; i < num_tuple; i++) {
                    fprintf(stdout, "%-20s %-15s\n",
                        PQgetvalue(res, i, 0),
                        PQgetvalue(res, i, 1));
                }*/
                PQclear(res);
                break;

            case 3:
                char* query = "SELECT titolo, incassi from media inner join film on media.id_media = film.id_film Where incassi >= $1::int"
                
                PGresult* res = PQprepare ( conn , "film_dato_incassi" , query , 1 , NULL );
                int incassi;
                printf ("Inserire incassi: ") ;
                scanf ("%d", incassi);
                
                res = PQexecPrepared (conn, "film_dato_incassi", 1, &incassi, NULL, 0, 0);

                checkerr(res, conn);
                num_tuple = PQntuples(res);
                num_attr = PQnfields(res);


                for(int i = 0; i < num_attr; i++)
                {
                    fprintf(stdout, "%s\t", PQfname(res, i));
                }
                fprintf(stdout, "\n");

                for(int i = 0; i < num_tuple; i++)
                {
                    for (int j = 0; j < num_attr; j++)
                    {
                        fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                    }
                    fprintf(stdout, "\n");
                }

                PQclear(res);
                break;
            case 4:
                char* query = "SELECT nome_serie_tv, count(id_episodio) AS numero_episodi from episodio inner join serie_tv on episodio.nome_serie_tv = serie_tv.nome "
                              "INNER join media on media.id_media = episodio.id_episodio GROUP by nome_serie_tv "
                              "HAVING count(id_episodio)>= $1::int"
                
                PGresult* res = PQprepare ( conn , "serie_con_almeno_tot_episodi" , query , 1 , NULL );
                int num_episodi;
                printf ("Inserire numero di episodi: ") ;
                scanf ("%d", num_episodi);
                
                res = PQexecPrepared (conn, "serie_con_almeno_tot_episodi", 1, &num_episodi, NULL, 0, 0);

                checkerr(res, conn);
                num_tuple = PQntuples(res);
                num_attr = PQnfields(res);


                for(int i = 0; i < num_attr; i++)
                {
                    fprintf(stdout, "%s\t", PQfname(res, i));
                }
                fprintf(stdout, "\n");

                for(int i = 0; i < num_tuple; i++)
                {
                    for (int j = 0; j < num_attr; j++)
                    {
                        fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                    }
                    fprintf(stdout, "\n");
                }

                PQclear(res);
                break;
            case 5:
                res = PQexec(conn,  "SELECT media.titolo, casting_media_membro.ruolo, serie_tv.nome AS nome_serie_tv FROM membro "
                                    "INNER JOIN casting_media_membro ON membro.codice_fiscale = casting_media_membro.codice_fiscale_membro "
                                    "INNER JOIN media ON media.id_media = casting_media_membro.id_media_casting "
                                    "left JOIN episodio ON media.id_media = episodio.id_episodio "
                                    "left JOIN serie_tv ON episodio.nome_serie_tv = serie_tv.nome "
                                    "WHERE membro.codice_fiscale = 'VLNTDR81D22F205Y'");
                checkerr(res, conn);
                num_tuple = PQntuples(res);
                num_attr = PQnfields(res);

                for(int i = 0; i < num_attr; i++)
                {
                    fprintf(stdout, "%s\t", PQfname(res, i));
                }
                fprintf(stdout, "\n");

                for(int i = 0; i < num_tuple; i++)
                {
                    for (int j = 0; j < num_attr; j++)
                    {
                        fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                    }
                    fprintf(stdout, "\n");
                }
                PQclear(res);
                break;
            case 6:
                res = PQexec(conn,  "SELECT ruolo, count(*) as numero_volte_svolto FROM membro "
                                    "INNER JOIN casting_media_membro ON membro.codice_fiscale = casting_media_membro.codice_fiscale_membro "
                                    "INNER JOIN media ON media.id_media = casting_media_membro.id_media_casting "
                                    "INNER JOIN film on media.id_media = film.id_film "
                                    "WHERE membro.codice_fiscale = 'VLNTDR81D22F205Y' "
                                    "GROUP BY casting_media_membro.ruolo");
                checkerr(res, conn);
                num_tuple = PQntuples(res);
                num_attr = PQnfields(res);

                for(int i = 0; i < num_attr; i++)
                {
                    fprintf(stdout, "%s\t", PQfname(res, i));
                }
                fprintf(stdout, "\n");

                for(int i = 0; i < num_tuple; i++)
                {
                    for (int j = 0; j < num_attr; j++)
                    {
                        fprintf(stdout, "%s\t\t", PQgetvalue(res, i, j));
                    }
                    fprintf(stdout, "\n");
                }
                PQclear(res);
                break;
            default:
                printf("Scegliere un numero valido\n");
                break;
        }
    }
    exit_db(conn);
}

void exit_db(PGconn *conn)
{
    PQfinish(conn);
    exit(1);
}

void print_menu(){
    printf("Opzioni\n");
    printf("0) Esci\n");
    printf("1) Trova l'utente/gli utenti che ha/hanno visto più film nell'ultimo mese\n");
    printf("2) Dato il rating restituisce le serie tv con valutazione maggiore o uguale (parametrica)\n");
    printf("3) Dato un numero di incassi restituisce i film con introiti maggiori o uguali (parametrica)\n");
    printf("4) Dato un numero di episodi restituisce le serie tv almeno quel numero episodi (parametrica)\n");
    printf("5) Trova tutti gli episodi di serie tv e film dove ha partecipato Vittorio Delmi\n");
    printf("6) Mostra che il numero di volte che ha eseguito un certo ruolo in un film Vittorio Delmi\n");
}

void checkerr(PGresult *res, PGconn *conn){
    if(PQresultStatus(res) != PGRES_TUPLES_OK){
        fprintf(stderr, "Operazione fallita: %s", PQerrorMessage(conn));
        PQclear(res);
        exit_db(conn);
    }
}