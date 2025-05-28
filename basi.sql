DROP TABLE IF EXISTS media CASCADE;
CREATE TABLE media (
    id_media VARCHAR(25) PRIMARY KEY,
    titolo VARCHAR(127) NOT NULL,
    genere VARCHAR(63) NOT NULL,
    durata_minuti INT NOT NULL,
    trama TEXT,
    data_rilascio DATE NOT NULL,
    rating_imdb FLOAT,
    CHECK (durata_minuti > 0),
    CHECK (rating_imdb >= 0 AND rating_imdb <= 10)
);

DROP TABLE IF EXISTS saga CASCADE;
CREATE TABLE saga (
    nome VARCHAR(63) PRIMARY KEY,
    descrizione TEXT,
    stato_completamento VARCHAR(31) NOT NULL
);

DROP TABLE IF EXISTS serie_tv CASCADE;
CREATE TABLE serie_tv (
    nome VARCHAR(63) PRIMARY KEY,
    descrizione TEXT,
    numero_stagioni INT NOT NULL,
    stato_completamento VARCHAR(31) NOT NULL,
    incassi INT,
    premi_emmy INT
);

DROP TABLE IF EXISTS film CASCADE;
CREATE TABLE film (
    id_film VARCHAR(25) PRIMARY KEY,
    data_uscita_streaming DATE NOT NULL,
    incassi INT,
    premi_oscar INT,
    nome_saga VARCHAR(63),
    FOREIGN KEY (id_film)   REFERENCES media(id_media),
    FOREIGN KEY (nome_saga) REFERENCES saga(nome)
);

DROP TABLE IF EXISTS episodio CASCADE;
CREATE TABLE episodio (
    id_episodio VARCHAR(25) PRIMARY KEY,
    stagione INT NOT NULL,
    numero INT NOT NULL,
    nome_serie_tv VARCHAR(63),
    FOREIGN KEY (id_episodio)   REFERENCES media(id_media),
    FOREIGN KEY (nome_serie_tv) REFERENCES serie_tv(nome)
);

DROP TABLE IF EXISTS membro CASCADE;
CREATE TABLE membro (
    codice_fiscale CHAR(16) PRIMARY KEY,
    nome VARCHAR(127) NOT NULL,
    cognome VARCHAR(127) NOT NULL,
    nazionalita VARCHAR(127) NOT NULL,
    data_nascita DATE NOT NULL,
    CHECK (codice_fiscale ~ '^[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]$')
);

DROP TABLE IF EXISTS utente CASCADE;
CREATE TABLE utente (
    nome_utente VARCHAR(63) PRIMARY KEY,
    password_utente VARCHAR(127) NOT NULL,
    email VARCHAR(255) NOT NULL,
    data_registrazione DATE NOT NULL,
    CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

DROP TABLE IF EXISTS licenza CASCADE;
CREATE TABLE licenza (
    id_licensed_media VARCHAR(25) PRIMARY KEY,
    tipo VARCHAR(63) NOT NULL,
    data_inizio DATE NOT NULL,
    data_fine DATE,
    CHECK (
        tipo IN (
            'Ad-Supported',
            'Subscription',
            'Transactional (TVOD)',
            'Sublicense',
            'Free',
            'Educational'
        )
    ),
    CHECK (data_fine IS NULL OR data_fine > data_inizio),
    FOREIGN KEY (id_licensed_media) REFERENCES media(id_media)
);

DROP TABLE IF EXISTS casting_media_membro CASCADE;
CREATE TABLE casting_media_membro (
    id_media_casting VARCHAR(25),
    codice_fiscale_membro CHAR(16),
    ruolo VARCHAR(63) NOT NULL,
    CHECK (ruolo IN ('Regista', 'Attore', 'Sceneggiatore', 'Produttore')),
    PRIMARY KEY (codice_fiscale_membro, id_media_casting),
    FOREIGN KEY (id_media_casting) REFERENCES media(id_media),
    FOREIGN KEY (codice_fiscale_membro) REFERENCES membro(codice_fiscale)
);

DROP TABLE IF EXISTS media_visti_utente CASCADE;
CREATE TABLE media_visti_utente (
    id_media_visto VARCHAR(25),
    nome_utente VARCHAR(63),
    data_visione DATE NOT NULL,
    rating_utente FLOAT,
    CHECK (rating_utente >= 0 AND rating_utente <= 10),
    PRIMARY KEY (id_media_visto, nome_utente),
    FOREIGN KEY (id_media_visto) REFERENCES media(id_media),
    FOREIGN KEY (nome_utente) REFERENCES utente(nome_utente)
);

-- Indici

CREATE INDEX idx_episodio_nome_serie_tv ON episodio(nome_serie_tv);

CREATE INDEX idx_film_nome_saga ON film(nome_saga);

-- Insert

INSERT INTO saga (nome, descrizione, stato_completamento) VALUES
('Hunger Games', 'Una saga distopica basata sulla serie di romanzi di Suzanne Collins.', 'Completata'),
('Il Signore degli Anelli', 'Un epico fantasy basato sul romanzo di J.R.R. Tolkien.', 'Completata');

INSERT INTO serie_tv (nome, descrizione, numero_stagioni, stato_completamento, incassi, premi_emmy) VALUES
('Chronos', 'Un thriller psicologico ambientato nel tempo.', 2, 'In corso', 1000000, 0),
('Suits', 'Harvey Specter è uno dei più importanti avvocati di New York, cinico e spietato, con una passione per' || --la trama era stra lunga quindi l'ho spezzata cosi
'gli abiti sartoriali e la vita mondana. È appena diventato socio Senior dello studio legale presso cui lavora,'||
'Pearson Hardman, ruolo che lo obbliga, suo malgrado, ad assumere un giovane associato: Harvey odia dover lavorare in coppia, '||
'e odia ancor di più i neolaureati appena usciti da Harvard (la Pearson Hardman accetta esclusivamente coloro che si sono laureati ad Harvard).'||
'Mike Ross è invece un giovane ragazzo estremamente intelligente, dotato di una prodigiosa memoria eidetica, che non si è mai laureato in legge, '||
'anche se ha sfruttato le sue capacità per sostenere esami al posto di altri studenti illegalmente. Un incontro fortuito tra i due, con Mike che ha '||
'modo di mostrare tutta la sua competenza e inventiva in materia di legge, convince Harvey ad assumerlo nel suo studio, nascondendo a tutti il fatto che '||
'il giovane, in realtà, pur avendo superato l esame di ammissione all Albo (negli USA non esiste il valore legale del titolo di studio) non era in '||
'possesso dei requisiti minimi previsti dallo stato di New York per essere ammesso all esame (28 crediti presso una Law School e 4 anni di '||
'lavoro presso uno studio legale); da parte sua, Mike coglie al volo questa seconda occasione capitatagli inaspettatamente tra le mani, '||
'incominciando a districarsi in un ambiente altamente competitivo e cercando di dimostrare di essere all altezza, per questo posto di lavoro. ', 9, 'Terminata', 50000000, 0);

INSERT INTO media (id_media, titolo, genere, durata_minuti, trama, data_rilascio, rating_imdb) VALUES
('FAN-20100716-INCEPTI12345','Inception','Fantascienza',148,'Un ladro entra nei sogni per rubare segreti.','2010-07-16',8.8),
('COM-20140328-THEGRAN67890','The Grand Budapest Hotel','Commedia',99,'Le avventure di un concierge in un hotel di lusso.','2014-03-28',8.1),
('AZI-20120323-HUNGERG24680','Hunger Games','Azione',142,'Katniss Everdeen combatte per sopravvivere ai giochi mortali.','2012-03-23',7.2),
('AZI-20131122-CATCHIN13579','Catching Fire','Azione',146,'I vincitori affrontano una nuova edizione dei giochi.','2013-11-22',7.5),
('FAN-20011219-ILSIGNO11223','Il Signore degli Anelli: La Compagnia dell Anello','Fantasy',178,'Frodo inizia il suo viaggio per distruggere l Anello.','2001-12-19',8.8),
('FAN-20021218-LEDUETT33445','Il Signore degli Anelli: Le Due Torri','Fantasy',179,'La compagnia si divide ma continua la missione.','2002-12-18',8.7),
('FAN-20031217-ILRITON55667','Il Signore degli Anelli: Il Ritorno del Re','Fantasy',201,'La battaglia finale per la Terra di Mezzo.','2003-12-17',8.9),
('THR-20220101-OROLOGI77889','Orologio Inverso','Thriller',45,'Un misterioso orologio altera il tempo.','2022-01-01',7.4),
('THR-20220108-FRATTUR99001','Frattura Temporale','Thriller',47,'Un salto nel passato cambia tutto.','2022-01-08',7.6),
('THR-20220115-ANELLOC22334','Anello Chiuso','Thriller',44,'I protagonisti si trovano intrappolati.','2022-01-15',7.5),
('THR-20230101-LABUSSO44556','La Bussola del Tempo','Thriller',46,'Una nuova minaccia temporale emerge.','2023-01-01',7.8),
('THR-20230108-PARADOS66778','Paradosso','Thriller',48,'I ricordi iniziano a scomparire.','2023-01-08',7.9),
('GIU-20120310-SUITS5566778','Avvocato per caso','Giudiziario',44,'Avvocato per caso','2012-03-10',6.7),
('GIU-20120317-SUITS5566778','Errori ed omissioni','Giudiziario',45,'Errori ed omissioni','2012-03-17',7.1),
('GIU-20120324-SUITS5566778','Corsia interna','Giudiziario',44,'Corsia interna','2012-03-24',7.7),
('GIU-20120331-SUITS5566778','Loschi piccoli segreti','Giudiziario',44,'Loschi piccoli segreti','2012-03-31',7.7),
('GIU-20120407-SUITS5566778','Libertà su cauzione','Giudiziario',49,'Libertà su cauzione','2012-04-07',7.0),
('GIU-20120414-SUITS5566778','I trucchi del mestiere','Giudiziario',51,'I trucchi del mestiere','2012-04-14',8.1),
('GIU-20120421-SUITS5566778','Concentrati sull uomo','Giudiziario',46,'Concentrati sull uomo','2012-04-21',8.3),
('GIU-20120428-SUITS5566778','Crisi d identità','Giudiziario',44,'Crisi d identità','2012-04-28',7.5),
('GIU-20120505-SUITS5566778','Imbattuto','Giudiziario',44,'Imbattuto','2012-05-05',8.0),
('GIU-20120512-SUITS5566778','Una vita in scatola','Giudiziario',48,'Una vita in scatola','2012-05-12',7.7),
('GIU-20120519-SUITS5566778','Le regole del gioco','Giudiziario',46,'Le regole del gioco','2012-05-19',7.1),
('GIU-20120526-SUITS5566778','Il duello','Giudiziario',54,'Il duello','2012-05-26',7.2),
('THR-20230115-FINEINI88990','Fine Inizio','Thriller',50,'Il cerchio si chiude... o si apre?','2023-01-15',8.0);

INSERT INTO film(id_film,data_uscita_streaming,incassi,premi_oscar,nome_saga) VALUES
('FAN-20100716-INCEPTI12345','2010-12-01',825000000,4,NULL),
('COM-20140328-THEGRAN67890','2014-08-01',175000000,5,NULL),
('AZI-20120323-HUNGERG24680','2012-10-01',694000000,1,'Hunger Games'),
('AZI-20131122-CATCHIN13579','2013-12-01',865000000,1,'Hunger Games'),
('FAN-20011219-ILSIGNO11223','2002-05-01',870000000,4,'Il Signore degli Anelli'),
('FAN-20021218-LEDUETT33445','2003-06-01',926000000,2,'Il Signore degli Anelli'),
('FAN-20031217-ILRITON55667','2004-11-01',1146000000,11,'Il Signore degli Anelli');

INSERT INTO episodio(id_episodio,stagione,numero,nome_serie_tv) VALUES
('THR-20220101-OROLOGI77889',1,1,'Chronos'),
('THR-20220108-FRATTUR99001',1,2,'Chronos'),
('THR-20220115-ANELLOC22334',1,3,'Chronos'),
('THR-20230101-LABUSSO44556',2,1,'Chronos'),
('THR-20230108-PARADOS66778',2,2,'Chronos'),
('THR-20230115-FINEINI88990',2,3,'Chronos'),
('GIU-20120310-SUITS5566778',1,1,'Suits'),
('GIU-20120317-SUITS5566778',1,2,'Suits'),
('GIU-20120324-SUITS5566778',1,3,'Suits'),
('GIU-20120331-SUITS5566778',1,4,'Suits'),
('GIU-20120407-SUITS5566778',1,5,'Suits'),
('GIU-20120414-SUITS5566778',1,6,'Suits'),
('GIU-20120421-SUITS5566778',1,7,'Suits'),
('GIU-20120428-SUITS5566778',1,8,'Suits'),
('GIU-20120505-SUITS5566778',1,9,'Suits'),
('GIU-20120512-SUITS5566778',1,10,'Suits'),
('GIU-20120519-SUITS5566778',1,11,'Suits'),
('GIU-20120526-SUITS5566778',1,12,'Suits');


INSERT INTO membro (codice_fiscale, nome, cognome, nazionalita, data_nascita) VALUES
('RSSMRA85M12H501Z', 'Maria', 'Rossi', 'Italiana', '1985-05-12'),
('VRDPLC80C22F205Z', 'Paolo', 'Verdi', 'Italiana', '1980-03-22'),
('BNCGNN90A01H501T', 'Gianna', 'Bianchi', 'Italiana', '1990-01-01'),
('NRCFNC70B12F839S', 'Franco', 'Neri', 'Italiana', '1970-02-12'),
('SFRLRA75M10C351K', 'Laura', 'Safari', 'Italiana', '1975-08-10'),
('CLLLGU88S11H501U', 'Luigi', 'Colli', 'Italiana', '1988-11-11'),
('MRNGPP92L05Z404L', 'Giuseppe', 'Marini', 'Italiana', '1992-07-05'),
('VLNTDR81D22F205Y', 'Dario', 'Valenti', 'Italiana', '1981-04-22'),
('BLNLCU89A41Z133X', 'Lucia', 'Bellini', 'Italiana', '1989-01-01'),
('GRNPLA73C19F205S', 'Alessandro', 'Grandi', 'Italiana', '1973-03-19'),
('MRTFBA82A01C351T', 'Fabio', 'Martini', 'Italiana', '1982-01-01'),
('RBRMRC77H30F205T', 'Marco', 'Ribera', 'Italiana', '1977-06-30'),
('FRCLNZ95C11Z133H', 'Lorenzo', 'Franchi', 'Italiana', '1995-03-11'),
('SNTGNN86D22H501W', 'Gianni', 'Santi', 'Italiana', '1986-04-22'),
('CRLPLA85M09F205A', 'Paola', 'Carli', 'Italiana', '1985-08-09'),
('FRNZNN74C13H501E', 'Nino', 'Forenzi', 'Italiana', '1974-03-13'),
('CTLCNL93L04F205J', 'Nicole', 'Cataldi', 'Italiana', '1993-07-04'),
('MRZCRS72M16Z133U', 'Carlo', 'Marzini', 'Italiana', '1972-08-16'),
('MNNLSA91H11C351F', 'Lisa', 'Mannari', 'Italiana', '1991-06-11'),
('PNLRNC90S12Z404E', 'Renato', 'Panelli', 'Italiana', '1990-11-12'),
('GRGLLA87D18F205N', 'Luca', 'Gregori', 'Italiana', '1987-04-18'),
('BRNZRN79A22C351Q', 'Rino', 'Bronzi', 'Italiana', '1979-01-22'),
('FNTMLS96C29F205D', 'Melissa', 'Fonti', 'Italiana', '1996-03-29'),
('BLCCHR88B41H501H', 'Chiara', 'Bellucci', 'Italiana', '1988-02-10'),
('DLMVTR92H05C351Y', 'Vittorio', 'Delmi', 'Italiana', '1992-06-05'),
('RVLCST70M01F205Z', 'Cristina', 'Ravelli', 'Italiana', '1970-08-01'),
('NLLFNC91D18Z133K', 'Francesca', 'Nalli', 'Italiana', '1991-04-18'),
('MTRNCL80M10C351L', 'Nicola', 'Maturi', 'Italiana', '1980-08-10'),
('FRRRGL85C22F205T', 'Ruggero', 'Ferrari', 'Italiana', '1985-03-22'),
('MLRNCL90S10F205G', 'Nicole', 'Molari', 'Italiana', '1990-11-10'),
('GZZMRA89H19H501V', 'Maria', 'Guzzo', 'Italiana', '1989-06-19');

INSERT INTO casting_media_membro(id_media_casting,codice_fiscale_membro,ruolo) VALUES
('AZI-20131122-CATCHIN13579','VLNTDR81D22F205Y', 'Regista'),
('THR-20230108-PARADOS66778','VLNTDR81D22F205Y', 'Attore'),
('FAN-20100716-INCEPTI12345','RSSMRA85M12H501Z','Regista'),
('FAN-20100716-INCEPTI12345','VRDPLC80C22F205Z','Attore'),
('FAN-20100716-INCEPTI12345','BNCGNN90A01H501T','Attore'),
('FAN-20100716-INCEPTI12345','NRCFNC70B12F839S','Attore'),
('COM-20140328-THEGRAN67890','SFRLRA75M10C351K','Regista'),
('COM-20140328-THEGRAN67890','CLLLGU88S11H501U','Attore'),
('COM-20140328-THEGRAN67890','MRNGPP92L05Z404L','Attore'),
('COM-20140328-THEGRAN67890','VLNTDR81D22F205Y','Attore'),
('AZI-20120323-HUNGERG24680','BLNLCU89A41Z133X','Regista'),
('AZI-20120323-HUNGERG24680','GRNPLA73C19F205S','Attore'),
('AZI-20120323-HUNGERG24680','MRTFBA82A01C351T','Attore'),
('AZI-20120323-HUNGERG24680','RBRMRC77H30F205T','Attore'),
('AZI-20131122-CATCHIN13579','FRCLNZ95C11Z133H','Regista'),
('AZI-20131122-CATCHIN13579','SNTGNN86D22H501W','Attore'),
('AZI-20131122-CATCHIN13579','CRLPLA85M09F205A','Attore'),
('AZI-20131122-CATCHIN13579','FRNZNN74C13H501E','Attore'),
('FAN-20011219-ILSIGNO11223','CTLCNL93L04F205J','Regista');

INSERT INTO utente (nome_utente, password_utente, email, data_registrazione) VALUES
('giulia_rossi', 'Passw0rd!', 'giuliarossi@email.com', '2022-05-10'),
('alessandro.v', 'AleVerdi123', 'alessandro.verdi@email.it', '2022-06-15'),
('chiara.bell', 'ChiaBell!88', 'chiara.bell@email.it', '2022-07-20'),
('marco.n91', 'MarcoN91$', 'marco.neri@email.it', '2022-08-01'),
('francesca.c88', 'FranCo88*', 'francesca.colombo@email.it', '2022-09-05'),
('dario.lux', 'DarioLux#1', 'dario.lux@email.it', '2022-10-10'),
('elena_r87', 'ElenaR87%', 'elena.rizzi@email.it', '2022-11-12'),
('federico.p77', 'FedP77@', 'federico.pini@email.it', '2022-12-15'),
('laura.gal', 'LauraGal2022', 'laura.galli@email.it', '2023-01-20'),
('simone_drm', 'SimoneDRM5', 'simone.drm@email.it', '2023-02-25');

INSERT INTO media_visti_utente(id_media_visto,nome_utente,data_visione,rating_utente) VALUES
('FAN-20100716-INCEPTI12345','giulia_rossi','2023-04-01',9.5),
('FAN-20100716-INCEPTI12345','alessandro.v','2023-07-01',4.5),
('COM-20140328-THEGRAN67890','alessandro.v','2023-05-15',7.0),
('AZI-20120323-HUNGERG24680','chiara.bell','2023-06-10',5.5),
('AZI-20131122-CATCHIN13579','marco.n91','2023-06-12',6.5),
('FAN-20011219-ILSIGNO11223','francesca.c88','2023-07-20',10.0),
('FAN-20021218-LEDUETT33445','dario.lux','2023-08-01',4.0),
('FAN-20031217-ILRITON55667','elena_r87','2023-09-10',8.5),
('THR-20220101-OROLOGI77889','federico.p77','2023-10-05',7.0),
('THR-20220108-FRATTUR99001','laura.gal','2023-11-01',6.0),
('THR-20220115-ANELLOC22334','simone_drm','2023-11-20',5.0),
('THR-20230101-LABUSSO44556','giulia_rossi','2024-01-01',8.0),
('FAN-20021218-LEDUETT33445','chiara.bell','2023-09-01',6.5),
('THR-20230108-PARADOS66778','alessandro.v','2024-01-15',9.5),
('FAN-20031217-ILRITON55667','chiara.bell','2024-02-01',9.5),
('THR-20230115-FINEINI88990','chiara.bell','2024-02-01',10.0);

INSERT INTO licenza(id_licensed_media,tipo,data_inizio,data_fine) VALUES
('FAN-20100716-INCEPTI12345','Subscription','2023-01-01','2026-01-01'),
('COM-20140328-THEGRAN67890','Ad-Supported','2022-06-01',NULL),
('AZI-20120323-HUNGERG24680','Free','2023-12-01','2025-12-01'),
('AZI-20131122-CATCHIN13579','Educational','2024-01-01',NULL),
('FAN-20011219-ILSIGNO11223','Transactional (TVOD)','2023-11-15','2026-11-15'),
('FAN-20021218-LEDUETT33445','Subscription','2024-01-01',NULL),
('FAN-20031217-ILRITON55667','Subscription','2024-01-01',NULL),
('THR-20220101-OROLOGI77889','Subscription','2024-01-01',NULL),
('THR-20220108-FRATTUR99001','Ad-Supported','2024-02-01','2025-02-01'),
('THR-20220115-ANELLOC22334','Free','2024-03-01','2026-03-01'),
('THR-20230101-LABUSSO44556','Educational','2024-04-01',NULL),
('THR-20230108-PARADOS66778','Subscription','2024-05-01','2027-05-01'),
('THR-20230115-FINEINI88990','Sublicense','2024-06-01','2025-06-01');

-- Query

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
