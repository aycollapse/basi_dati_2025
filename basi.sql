CREATE TABLE IF NOT EXISTS media (
    id_media SERIAL PRIMARY KEY,
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
/* POPOLAMENTO TABELLE */
INSERT INTO saga (nome, descrizione, stato_completamento) VALUES
('Mind Heist Saga', 'Una saga sci-fi che esplora i sogni e il subconscio.', 'Completata');

INSERT INTO serie_tv (nome, descrizione, numero_stagioni, stato_completamento, incassi, premi_oscar) VALUES
('Chronos', 'Un thriller psicologico ambientato nel tempo.', 2, 'In corso', 1000000, 0);


/* MEDIA */
-- Film
INSERT INTO media (id_media, titolo, genere, durata_minuti, trama, data_rilascio, rating_imdb) VALUES
(1, 'Inception', 'Fantascienza', 148, 'Un ladro entra nei sogni per rubare segreti.', '2010-07-16', 8.8),
(2, 'The Grand Budapest Hotel', 'Commedia', 99, 'Le avventure di un concierge in un hotel di lusso.', '2014-03-28', 8.1);

-- Episodi della serie TV "Chronos"
INSERT INTO media (id_media, titolo, genere, durata_minuti, trama, data_rilascio, rating_imdb) VALUES
(3, 'Orologio Inverso', 'Thriller', 45, 'Un misterioso orologio altera il tempo.', '2022-01-01', 7.4),
(4, 'Frattura Temporale', 'Thriller', 47, 'Un salto nel passato cambia tutto.', '2022-01-08', 7.6),
(5, 'Anello Chiuso', 'Thriller', 44, 'I protagonisti si trovano intrappolati.', '2022-01-15', 7.5),
(6, 'La Bussola del Tempo', 'Thriller', 46, 'Una nuova minaccia temporale emerge.', '2023-01-01', 7.8),
(7, 'Paradosso', 'Thriller', 48, 'I ricordi iniziano a scomparire.', '2023-01-08', 7.9),
(8, 'Fine Inizio', 'Thriller', 50, 'Il cerchio si chiude... o si apre?', '2023-01-15', 8.0);

/* FILM */
INSERT INTO film (id_film, data_uscita_streaming, incassi, premi_oscar, nome_saga) VALUES
(1, '2010-12-01', 825000000, 4, 'Mind Heist Saga'),
(2, '2014-08-01', 175000000, 5, NULL);

/* EPISODI di Chronos */
INSERT INTO episodio (id_episodio, stagione, numero, nome_serie_tv) VALUES
(3, 1, 1, 'Chronos'),
(4, 1, 2, 'Chronos'),
(5, 1, 3, 'Chronos'),
(6, 2, 1, 'Chronos'),
(7, 2, 2, 'Chronos'),
(8, 2, 3, 'Chronos');

/* CASTING */
INSERT INTO membro (codice_fiscale, nome, cognome, nazionalita, data_nascita) VALUES
('RSSMRA85T10A562S', 'Mario', 'Rossi', 'Italiana', '1985-03-10'),
('VRDLGI90A01H501T', 'Giulia', 'Verdi', 'Italiana', '1990-01-01'),
('BNCLNZ70M20Z404Y', 'Lorenzo', 'Bianchi', 'Italiana', '1970-12-20'),
('KPLFRN65C30Z404U', 'Francesca', 'Kaplan', 'Statunitense', '1965-03-30');

-- Inception
INSERT INTO casting_media_membro (id_media, codice_fiscale_membro, ruolo) VALUES
(1, 'RSSMRA85T10A562S', 'Regista'),
(1, 'VRDLGI90A01H501T', 'Attore'),
(1, 'BNCLNZ70M20Z404Y', 'Sceneggiatore');

-- The Grand Budapest Hotel
INSERT INTO casting_media_membro (id_media, codice_fiscale_membro, ruolo) VALUES
(2, 'KPLFRN65C30Z404U', 'Regista'),
(2, 'VRDLGI90A01H501T', 'Attore');

-- Episodi della serie "Chronos"
-- Stagione 1
INSERT INTO casting_media_membro (id_media, codice_fiscale_membro, ruolo) VALUES
(3, 'RSSMRA85T10A562S', 'Regista'),
(3, 'BNCLNZ70M20Z404Y', 'Attore'),
(4, 'RSSMRA85T10A562S', 'Regista'),
(4, 'VRDLGI90A01H501T', 'Attore'),
(5, 'RSSMRA85T10A562S', 'Regista'),
(5, 'BNCLNZ70M20Z404Y', 'Sceneggiatore');

-- Stagione 2
INSERT INTO casting_media_membro (id_media, codice_fiscale_membro, ruolo) VALUES
(6, 'KPLFRN65C30Z404U', 'Regista'),
(6, 'VRDLGI90A01H501T', 'Attore'),
(7, 'KPLFRN65C30Z404U', 'Regista'),
(7, 'BNCLNZ70M20Z404Y', 'Attore'),
(8, 'KPLFRN65C30Z404U', 'Regista'),
(8, 'RSSMRA85T10A562S', 'Sceneggiatore');

INSERT INTO utente (nome_utente, password_utente, email, data_registrazione) VALUES
('alice01', 'pwAlice!', 'alice@example.com', '2023-01-10'),
('bob92', 'pwBob!', 'bob@example.com', '2022-12-15'),
('chiara33', 'pwChiara!', 'chiara@example.com', '2024-01-05'),
('davideX', 'pwDavide!', 'davide@example.com', '2024-03-22');

INSERT INTO media_visti_utente (id_media, nome_utente, data_visione, rating_utente) VALUES
(1, 'alice01', '2024-01-12', 9.0),
(2, 'bob92', '2024-02-05', 8.5),
(3, 'alice01', '2024-01-15', 7.5),
(4, 'bob92', '2024-01-16', 7.0),
(6, 'chiara33', '2024-02-10', 8.0),
(7, 'davideX', '2024-02-12', 7.8),
(8, 'alice01', '2024-02-13', 8.3),
(5, 'davideX', '2024-02-15', 7.4),
(2, 'chiara33', '2024-03-01', 8.2);

INSERT INTO licenza (id_licensed_media, tipo, data_inizio, data_fine) VALUES
(1, 'Subscription', '2023-01-01', '2026-01-01'),
(2, 'Ad-Supported', '2022-06-01', NULL),
(3, 'Free', '2023-12-01', '2025-12-01'),
(4, 'Educational', '2024-01-01', NULL),
(5, 'Transactional (TVOD)', '2023-11-15', '2026-11-15'),
(6, 'Subscription', '2024-01-01', NULL),
(7, 'Subscription', '2024-01-01', NULL),
(8, 'Subscription', '2024-01-01', NULL);
