-- QUESTE SONO DA METTERE INSIEME ALL'ALTRO FILE, LE HO MESSE QUI SOLO PER QUESTIONE DI ORGANIZZAZIONE MOMENTANEA

-- Trova l'utente/gli utenti che ha/hanno visto più film
SELECT nome_utente, numero
FROM (
    SELECT nome_utente, COUNT(*) AS numero
    FROM media_visti_utente
    GROUP BY nome_utente
) AS sub
WHERE numero = (
    SELECT MAX(numero)
    FROM (
        SELECT COUNT(*) AS numero
        FROM media_visti_utente
        GROUP BY nome_utente
    ) AS counts
);

-- Dato il rating restituisce le serie tv con valutazione maggiore o uguale (parametrica)
SELECT *
FROM (
    SELECT nome_serie_tv AS serie_tv, AVG(rating_imdb) AS media_rating_episodi
    FROM episodio
    INNER JOIN serie_tv ON episodio.nome_serie_tv = serie_tv.nome
    INNER JOIN media ON media.id_media = episodio.id_episodio
    GROUP BY nome_serie_tv
) AS tabella
WHERE media_rating_episodi >= 7.5;

-- Dato un numero di incassi restituisce i film con introiti maggiori o uguali (parametrica)
SELECT titolo, incassi
FROM media
INNER JOIN film ON media.id_media = film.id_film
WHERE incassi >= 500000000;

-- Dato un numero di episodi restituisce le serie tv almeno quel numero episodi (parametrica)
SELECT nome_serie_tv, COUNT(id_episodio) AS numero_episodi
FROM episodio
INNER JOIN serie_tv ON episodio.nome_serie_tv = serie_tv.nome
INNER JOIN media ON media.id_media = episodio.id_episodio
GROUP BY nome_serie_tv
HAVING COUNT(id_episodio) >= 3;

-- Trova tutti gli episodi di serie tv e film dove ha partecipato Dario Valenti
SELECT media.titolo, casting_media_membro.ruolo, serie_tv.nome AS nome_serie_tv
FROM membro
INNER JOIN casting_media_membro ON membro.codice_fiscale = casting_media_membro.codice_fiscale_membro
INNER JOIN media ON media.id_media = casting_media_membro.id_media_casting
LEFT JOIN episodio ON media.id_media = episodio.id_episodio
LEFT JOIN serie_tv ON episodio.nome_serie_tv = serie_tv.nome
WHERE membro.codice_fiscale = 'VLNTDR81D22F205Y';

-- Mostra tutti i media che hanno un rating medio sulla piattaforma più alta del raing su imdb
SELECT m.titolo AS titolo_media,s.nome AS titolo_serie_tv,
    AVG(mvu.rating_utente) AS media_voti_utenti, m.rating_imdb
FROM media m
JOIN media_visti_utente mvu ON m.id_media = mvu.id_media_visto
LEFT JOIN episodio e ON m.id_media = e.id_episodio
LEFT JOIN serie_tv s ON e.nome_serie_tv = s.nome
GROUP BY m.id_media, m.titolo, s.nome, m.rating_imdb
HAVING AVG(mvu.rating_utente) > m.rating_imdb;