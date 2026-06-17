--- Progetto BD 24-25 (12 CFU)
--- Numero gruppo: 63
--- Nomi e matricole componenti: Andrea Peri (5415544) , Jeffrey Germano (5669424) , Alessio Giorno (5590816)


--- PARTE III 
/* il file deve essere file SQL ... cioè formato solo testo e apribili ed eseguibili in pgAdmin */


/*************************************************************************************************************************************************************************/ 
--1b. Schema per popolamento in the large
/*************************************************************************************************************************************************************************/ 



CREATE TABLE artista_CL (
    idartista INTEGER,
    nome VARCHAR(100),
    generemusicale VARCHAR(50),
    biografia TEXT,
    provenienza VARCHAR(50),
    prezzobaudi INTEGER,
    dummy CHAR(200)
);

CREATE TABLE serata_CL (
    idserata INTEGER,
    data DATE,
    ordine INTEGER,
    idedizione INTEGER,
    dummy CHAR(200)
);

CREATE TABLE squadra_CL (
    idsquadra INTEGER,
    nome VARCHAR(50),
    budgetbaudi INTEGER,
    datacreazione DATE,
    idutente INTEGER,
    idlega INTEGER,
    idserata INTEGER,
    idedizione INTEGER,
    dummy CHAR(200)
);

CREATE TABLE lega_CL (
    idlega INTEGER,
    nome VARCHAR(50),
    tipo VARCHAR(20),
    descrizione TEXT,
    idproprietario INTEGER,
    iscampionato BOOLEAN,
    dummy CHAR(200)
);

CREATE TABLE utente_CL (
    idutente INTEGER,
    username VARCHAR(50),
    nome VARCHAR(50),
    cognome VARCHAR(50),
    email VARCHAR(100),
    datanascita DATE,
    password VARCHAR(100),
    dataregistrazione DATE,
    dummy CHAR(200)
);



/*************************************************************************************************************************************************************************/
--1c. Carico di lavoro
/*************************************************************************************************************************************************************************/ 

/*************************************************************************************************************************************************************************/ 
/* Q1: Query con singola selezione e nessun join */
/*************************************************************************************************************************************************************************/ 


SELECT * FROM artista_CL
WHERE generemusicale = 'Pop';


/*************************************************************************************************************************************************************************/ 
/* Q2: Query con condizione di selezione complessa e nessun join */
/*************************************************************************************************************************************************************************/ 


SELECT * FROM serata_CL
WHERE EXTRACT(YEAR FROM data) = 2024
  AND ordine > 2;


/*************************************************************************************************************************************************************************/ 
/* Q3: Query con almeno un join e almeno una condizione di selezione */
/*************************************************************************************************************************************************************************/ 


SELECT s.nome AS nome_squadra, u.nome AS nome_utente
FROM squadra_CL s
JOIN utente_CL u ON s.idutente = u.idutente
JOIN lega_CL l ON s.idlega = l.idlega
WHERE l.tipo = 'pubblica';


/*************************************************************************************************************************************************************************/
--1e. Schema fisico
/*************************************************************************************************************************************************************************/ 


-- Elimina indice su artista.generemusicale
DROP INDEX IF EXISTS idx_artista_generemusicale;

-- Elimina indice su serata.data+ordine
DROP INDEX IF EXISTS idx_serata_data_ordine;

-- Elimina indice su squadra.idutente
DROP INDEX IF EXISTS idx_squadra_idutente;
-- Elimina indice su squadra.idlega
DROP INDEX IF EXISTS idx_squadra_idlega;

-- Eventuali altri indici creati su lega_CL o utente_CL:
DROP INDEX IF EXISTS idx_lega_tipo;
DROP INDEX IF EXISTS idx_utente_nome;



-- Crea indice su artista_CL.generemusicale
CREATE INDEX idx_artistaCL_generemusicale ON artista_CL (generemusicale);

-- Crea indice funzionale sulla funzione usata nella WHERE
CREATE INDEX idx_serataCL_year ON serata_CL ((EXTRACT(year FROM data)));

-- Crea indice su squadra_CL.idutente
CREATE INDEX idx_squadraCL_idutente ON squadra_CL (idutente);

-- Crea indice su squadra_CL.idlega
CREATE INDEX idx_squadraCL_idlega ON squadra_CL (idlega);

-- Eventuali altri indici su lega_CL, utente_CL se necessario
CREATE INDEX idx_legaCL_tipo ON lega_CL (tipo);
CREATE INDEX idx_utenteCL_nome ON utente_CL (nome);


/*************************************************************************************************************************************************************************/ 
--2. Controllo dell'accesso 
/*************************************************************************************************************************************************************************/ 

-- CREAZIONE DEI RUOLI
CREATE ROLE proprietario;
CREATE ROLE amministratore;
CREATE ROLE utente_premium;
CREATE ROLE utente_semplice;

-- GERARCHIA DEI RUOLI
GRANT amministratore TO proprietario;
GRANT utente_premium TO amministratore;
GRANT utente_semplice TO utente_premium;

-- CREAZIONE UTENTI
CREATE USER luca_r WITH PASSWORD 'lucapwd';
CREATE USER giulia_b WITH PASSWORD 'giuliapwd';
CREATE USER marco_v WITH PASSWORD 'marcopwd';
CREATE USER anna_n WITH PASSWORD 'annapwd';

-- ASSEGNAZIONE RUOLI AGLI UTENTI
GRANT proprietario TO luca_r;
GRANT amministratore TO giulia_b;
GRANT utente_premium TO marco_v;
GRANT utente_semplice TO anna_n;

-- ASSEGNAZIONE PRIVILEGI SPECIFICI (ESEMPI, personalizza secondo le tue tabelle!)
-- Proprietario Lega (tutti i privilegi)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO proprietario;

-- Amministratore Lega (quasi tutti i privilegi tranne DROP)
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO amministratore;
GRANT DELETE ON squadra, formazione, iscrizione_squadra TO amministratore;

-- Utente Premium (pu� leggere e inserire squadre e formazione)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO utente_premium;
GRANT INSERT ON squadra, formazione TO utente_premium;

-- Utente Semplice (solo lettura)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO utente_semplice;

-- (Facoltativo) Revoca privilegi pubblici per maggiore sicurezza
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;

-- (Facoltativo) Se vuoi essere certo che solo questi ruoli abbiano accesso:
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;

-- [Eventuali privilegi aggiuntivi o personalizzati sulle singole tabelle]
-- Ad esempio, solo proprietario può cancellare utenti:
GRANT DELETE ON utente TO proprietario;
REVOKE DELETE ON utente FROM amministratore, utente_premium, utente_semplice;









