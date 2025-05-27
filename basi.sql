-- CREAZIONE TABELLE

CREATE TABLE IF NOT EXISTS media (
    id_media INT PRIMARY KEY,
    titolo VARCHAR(127) NOT NULL,
    genere VARCHAR(63) NOT NULL,
    durata_minuti INT NOT NULL,
    trama TEXT,
    data_rilascio DATE NOT NULL,
    rating_imdb FLOAT,
    CHECK (durata_minuti > 0),
    CHECK (rating_imdb >= 0 AND rating_imdb <= 10)
);

CREATE TABLE IF NOT EXISTS saga (
    nome VARCHAR(63) PRIMARY KEY,
    descrizione TEXT,
    stato_completamento VARCHAR(31) NOT NULL
);

CREATE TABLE IF NOT EXISTS serie_tv (
    nome VARCHAR(63) PRIMARY KEY,
    descrizione TEXT,
    numero_stagioni INT NOT NULL,
    stato_completamento VARCHAR(31) NOT NULL,
    incassi INT,
    premi_oscar INT
);

CREATE TABLE IF NOT EXISTS film (
    id_film INT PRIMARY KEY,
    data_uscita_streaming DATE NOT NULL,
    incassi INT,
    premi_oscar INT,
    nome_saga VARCHAR(63),
    FOREIGN KEY (id_film) REFERENCES media(id_media),
    FOREIGN KEY (nome_saga) REFERENCES saga(nome)
);

CREATE TABLE IF NOT EXISTS episodio (
    id_episodio INT PRIMARY KEY,
    stagione INT NOT NULL,
    numero INT NOT NULL,
    nome_serie_tv VARCHAR(63),
    FOREIGN KEY (id_episodio) REFERENCES media(id_media),
    FOREIGN KEY (nome_serie_tv) REFERENCES serie_tv(nome)
);

CREATE TABLE IF NOT EXISTS membro (
	codice_fiscale CHAR(16) PRIMARY KEY,
	nome VARCHAR(127) NOT NULL,
	cognome VARCHAR(127) NOT NULL,
	nazionalita VARCHAR(127) NOT NULL,
	data_nascita DATE NOT NULL,
	/* Controlla che il codice fiscale abbia il formato giusto */
	CHECK (codice_fiscale ~ '^[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]$')
);

CREATE TABLE IF NOT EXISTS utente (
	nome_utente VARCHAR(63) PRIMARY KEY,
	password_utente VARCHAR(127) NOT NULL,
	email VARCHAR(255) NOT NULL,
	data_registrazione DATE NOT NULL,
	/* Controlla che l'email abbia il formato giusto */
	CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);


CREATE TABLE IF NOT EXISTS licenza (
    id_licensed_media INT PRIMARY KEY,
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

CREATE TABLE IF NOT EXISTS casting_media_membro (
    id_media INT,
    codice_fiscale_membro CHAR(16),
    ruolo VARCHAR(63) NOT NULL,
    CHECK (ruolo IN ('Regista', 'Attore', 'Sceneggiatore', 'Produttore')),
    PRIMARY KEY (codice_fiscale_membro, id_media),
    FOREIGN KEY (id_media) REFERENCES media(id_media),
    FOREIGN KEY (codice_fiscale_membro) REFERENCES membro(codice_fiscale)
);

CREATE TABLE IF NOT EXISTS media_visti_utente (
    id_media INT,
    nome_utente VARCHAR(63),
    data_visione DATE NOT NULL,
    rating_utente FLOAT,
    CHECK (rating_utente >= 0 AND rating_utente <= 10),
    PRIMARY KEY (id_media, nome_utente),
    FOREIGN KEY (id_media) REFERENCES media(id_media),
    FOREIGN KEY (nome_utente) REFERENCES utente(nome_utente)
);

-- SAGHE

INSERT INTO saga (nome, descrizione, stato_completamento) VALUES
('Hunger Games', 'Una saga distopica basata sulla serie di romanzi di Suzanne Collins.', 'Completata'),
('Il Signore degli Anelli', 'Un epico fantasy basato sul romanzo di J.R.R. Tolkien.', 'Completata');

-- SERIE TV

INSERT INTO serie_tv (nome, descrizione, numero_stagioni, stato_completamento, incassi, premi_oscar) VALUES
('Chronos', 'Un thriller psicologico ambientato nel tempo.', 2, 'In corso', 1000000, 0);

-- MEDIA (Film + Episodi)

INSERT INTO media (id_media, titolo, genere, durata_minuti, trama, data_rilascio, rating_imdb) VALUES
(1, 'Inception', 'Fantascienza', 148, 'Un ladro entra nei sogni per rubare segreti.', '2010-07-16', 8.8),
(2, 'The Grand Budapest Hotel', 'Commedia', 99, 'Le avventure di un concierge in un hotel di lusso.', '2014-03-28', 8.1),
(3, 'Hunger Games', 'Azione', 142, 'Katniss Everdeen combatte per sopravvivere ai giochi mortali.', '2012-03-23', 7.2),
(4, 'Catching Fire', 'Azione', 146, 'I vincitori affrontano una nuova edizione dei giochi.', '2013-11-22', 7.5),
(5, 'Il Signore degli Anelli: La Compagnia dell Anello', 'Fantasy', 178, 'Frodo inizia il suo viaggio per distruggere l Anello.', '2001-12-19', 8.8),
(6, 'Il Signore degli Anelli: Le Due Torri', 'Fantasy', 179, 'La compagnia si divide ma continua la missione.', '2002-12-18', 8.7),
(7, 'Il Signore degli Anelli: Il Ritorno del Re', 'Fantasy', 201, 'La battaglia finale per la Terra di Mezzo.', '2003-12-17', 8.9),
(8, 'Orologio Inverso', 'Thriller', 45, 'Un misterioso orologio altera il tempo.', '2022-01-01', 7.4),
(9, 'Frattura Temporale', 'Thriller', 47, 'Un salto nel passato cambia tutto.', '2022-01-08', 7.6),
(10, 'Anello Chiuso', 'Thriller', 44, 'I protagonisti si trovano intrappolati.', '2022-01-15', 7.5),
(11, 'La Bussola del Tempo', 'Thriller', 46, 'Una nuova minaccia temporale emerge.', '2023-01-01', 7.8),
(12, 'Paradosso', 'Thriller', 48, 'I ricordi iniziano a scomparire.', '2023-01-08', 7.9),
(13, 'Fine Inizio', 'Thriller', 50, 'Il cerchio si chiude... o si apre?', '2023-01-15', 8.0);

-- FILM

INSERT INTO film (id_film, data_uscita_streaming, incassi, premi_oscar, nome_saga) VALUES
(1, '2010-12-01', 825000000, 4, NULL),
(2, '2014-08-01', 175000000, 5, NULL),
(3, '2012-10-01', 694000000, 1, 'Hunger Games'),
(4, '2013-12-01', 865000000, 1, 'Hunger Games'),
(5, '2002-05-01', 870000000, 4, 'Il Signore degli Anelli'),
(6, '2003-06-01', 926000000, 2, 'Il Signore degli Anelli'),
(7, '2004-11-01', 1146000000, 11, 'Il Signore degli Anelli');

-- EPISODI di Chronos

INSERT INTO episodio (id_episodio, stagione, numero, nome_serie_tv) VALUES
(8, 1, 1, 'Chronos'),
(9, 1, 2, 'Chronos'),
(10, 1, 3, 'Chronos'),
(11, 2, 1, 'Chronos'),
(12, 2, 2, 'Chronos'),
(13, 2, 3, 'Chronos');

-- MEMBRI CAST

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

-- CASTING

INSERT INTO casting_media_membro (id_media, codice_fiscale_membro, ruolo) VALUES
(1, 'RSSMRA85M12H501Z', 'Regista'),
(1, 'VRDPLC80C22F205Z', 'Attore'),
(1, 'BNCGNN90A01H501T', 'Attore'),
(1, 'NRCFNC70B12F839S', 'Attore'),
(2, 'SFRLRA75M10C351K', 'Regista'),
(2, 'CLLLGU88S11H501U', 'Attore'),
(2, 'MRNGPP92L05Z404L', 'Attore'),
(2, 'VLNTDR81D22F205Y', 'Attore'),
(3, 'BLNLCU89A41Z133X', 'Regista'),
(3, 'GRNPLA73C19F205S', 'Attore'),
(3, 'MRTFBA82A01C351T', 'Attore'),
(3, 'RBRMRC77H30F205T', 'Attore'),
(4, 'FRCLNZ95C11Z133H', 'Regista'),
(4, 'SNTGNN86D22H501W', 'Attore'),
(4, 'CRLPLA85M09F205A', 'Attore'),
(4, 'FRNZNN74C13H501E', 'Attore'),
(5, 'CTLCNL93L04F205J', 'Regista');

-- UTENTI

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

-- MEDIA VISTI DAI UTENTI

INSERT INTO media_visti_utente (id_media, nome_utente, data_visione, rating_utente) VALUES
(1, 'giulia_rossi', '2023-04-01', 9),
(1, 'alessandro.v', '2023-07-01', 4),
(2, 'alessandro.v', '2023-05-15', 7),
(3, 'chiara.bell', '2023-06-10', 5),
(4, 'marco.n91', '2023-06-12', 6),
(5, 'francesca.c88', '2023-07-20', 10),
(6, 'dario.lux', '2023-08-01', 4),
(7, 'elena_r87', '2023-09-10', 8),
(8, 'federico.p77', '2023-10-05', 7),
(9, 'laura.gal', '2023-11-01', 6),
(10, 'simone_drm', '2023-11-20', 5),
(11, 'giulia_rossi', '2024-01-01', 8),
(6, 'chiara.bell', '2023-09-01', 6),
(12, 'alessandro.v', '2024-01-15', 9),
(13, 'chiara.bell', '2024-02-01', 10);

-- LICENZE

INSERT INTO licenza (id_licensed_media, tipo, data_inizio, data_fine) VALUES
(1, 'Subscription', '2023-01-01', '2026-01-01'),
(2, 'Ad-Supported', '2022-06-01', NULL),
(3, 'Free', '2023-12-01', '2025-12-01'),
(4, 'Educational', '2024-01-01', NULL),
(5, 'Transactional (TVOD)', '2023-11-15', '2026-11-15'),
(6, 'Subscription', '2024-01-01', NULL),
(7, 'Subscription', '2024-01-01', NULL),
(8, 'Subscription', '2024-01-01', NULL),
(9, 'Ad-Supported', '2024-02-01', '2025-02-01'),
(10, 'Free', '2024-03-01', '2026-03-01'),
(11, 'Educational', '2024-04-01', NULL),
(12, 'Subscription', '2024-05-01', '2027-05-01'),
(13, 'Sublicense', '2024-06-01', '2025-06-01');
