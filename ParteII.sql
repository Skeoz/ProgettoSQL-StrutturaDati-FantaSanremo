--- Progetto BD 24-25 (6CFU)
--- Numero gruppo: 63
--- Nomi e matricole componenti: Andrea Peri (5415544) , Jeffrey Germano (5669424) , Alessio Giorno (5590816)

--- PARTE 2 
/* il file deve essere file SQL ... cioè formato solo testo e apribili ed eseguibili in pgAdmin */

/*************************************************************************************************************************************************************************/
--1a. Schema

/*Abbiamo implementato, tra tutti i vincoli individuati nella prima parte, solo quelli esprimibili tramite vincoli di tipo CHECK, come richiesto dalla consegna (vincoli numero 3,4,5,6,7,19,20). I vincoli CHECK sono stati applicati, ad esempio, per limitare i valori ammessi di alcuni attributi (come i ruoli, i tipi di lega, i valori numerici positivi, ecc.) e per garantire la correttezza di intervalli di date o costanti.                                                                                                                               */

/*Tutti gli altri vincoli di integrità e di business che non possono essere espressi tramite CHECK, come i vincoli di unicità multipla, i conteggi, i vincoli di mutua esclusione, i controlli su insiemi di tuple o su relazioni tra tabelle, andrebbero implementati tramite vincoli UNIQUE, trigger o tramite logica applicativa a livello di software, in modo da garantire il rispetto delle regole di business pi� complesse e la coerenza�dei�dati.*/
/*************************************************************************************************************************************************************************/ 

CREATE TABLE Edizione (
    idEdizione INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    anno INTEGER UNIQUE NOT NULL,
    luogo VARCHAR(100) NOT NULL,
    DataInizio DATE NOT NULL,
    DataFine DATE NOT NULL,
    CHECK (DataFine >= DataInizio)
);

CREATE TABLE Artista (
    idArtista INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(100) NOT NULL,
    biografia TEXT,
    GenereMusicale VARCHAR(50),
    provenienza VARCHAR(50),
    prezzoBaudi INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE Brano (
    idBrano INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    titolo VARCHAR(100) NOT NULL,
    autori VARCHAR(200),
    compositori VARCHAR(200),
    durata INTEGER,
    GenereMusicale VARCHAR(50),
    idArtista INTEGER NOT NULL,
    idEdizione INTEGER NOT NULL,
    FOREIGN KEY (idArtista) REFERENCES Artista(idArtista) ON DELETE CASCADE,
    FOREIGN KEY (idEdizione) REFERENCES Edizione(idEdizione) ON DELETE CASCADE
);

CREATE TABLE Utente (
    idUtente INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    username VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    DataNascita DATE,
    password VARCHAR(100) NOT NULL,
    DataRegistrazione DATE NOT NULL
);

CREATE TABLE Lega (
    idLega INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(50) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    descrizione TEXT,
    idProprietario INTEGER NOT NULL,
    isCampionato BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (idProprietario) REFERENCES Utente(idUtente) ON DELETE CASCADE,
    CHECK (tipo IN ('pubblica', 'privata', 'segreta'))
);

CREATE TABLE Serata (
    idSerata INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    data DATE NOT NULL,
    ordine INTEGER,
    idEdizione INTEGER NOT NULL,
    FOREIGN KEY (idEdizione) REFERENCES Edizione(idEdizione) ON DELETE CASCADE
);

CREATE TABLE Giuria (
    idGiuria INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE Giuria_Tecnica (
    idGiuria INTEGER PRIMARY KEY,
    NumeroEsperti INTEGER,
    organizzazione VARCHAR(100),
    FOREIGN KEY (idGiuria) REFERENCES Giuria(idGiuria) ON DELETE CASCADE
);

CREATE TABLE Giuria_Demoscopica (
    idGiuria INTEGER PRIMARY KEY,
    NumeroCampionamento INTEGER,
    MetodoCampionamento VARCHAR(100),
    FOREIGN KEY (idGiuria) REFERENCES Giuria(idGiuria) ON DELETE CASCADE
);

CREATE TABLE Giuria_Pubblico (
    idGiuria INTEGER PRIMARY KEY,
    TipoVoto VARCHAR(50),
    NumeroVoti INTEGER,
    FOREIGN KEY (idGiuria) REFERENCES Giuria(idGiuria) ON DELETE CASCADE
);

CREATE TABLE Esibizione (
    idEsibizione INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    orario TIME NOT NULL,
    OrdineEsibizione INTEGER NOT NULL,
    DettagliAggiuntivi TEXT,
    idSerata INTEGER NOT NULL,
    idArtista INTEGER NOT NULL,
    idBrano INTEGER NOT NULL,
    FOREIGN KEY (idSerata) REFERENCES Serata(idSerata) ON DELETE CASCADE,
    FOREIGN KEY (idArtista) REFERENCES Artista(idArtista) ON DELETE CASCADE,
    FOREIGN KEY (idBrano) REFERENCES Brano(idBrano) ON DELETE CASCADE
);

CREATE TABLE Voti (
    idVoto INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    valore INTEGER NOT NULL,
    idEsibizione INTEGER NOT NULL,
    idGiuria INTEGER NOT NULL,
    FOREIGN KEY (idEsibizione) REFERENCES Esibizione(idEsibizione) ON DELETE CASCADE,
    FOREIGN KEY (idGiuria) REFERENCES Giuria(idGiuria) ON DELETE CASCADE
);

CREATE TABLE Partecipazione_Artista (
    idArtista INTEGER NOT NULL,
    idEdizione INTEGER NOT NULL,
    PRIMARY KEY (idArtista, idEdizione),
    FOREIGN KEY (idArtista) REFERENCES Artista(idArtista) ON DELETE CASCADE,
    FOREIGN KEY (idEdizione) REFERENCES Edizione(idEdizione) ON DELETE CASCADE
);

CREATE TABLE Squadra (
    idSquadra INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(50) NOT NULL,
    BudgetBaudi INTEGER NOT NULL CHECK (BudgetBaudi <= 100),
    DataCreazione DATE NOT NULL,
    idUtente INTEGER NOT NULL,
    idLega INTEGER NOT NULL,
    idSerata INTEGER,
    idEdizione INTEGER NOT NULL,
    FOREIGN KEY (idUtente) REFERENCES Utente(idUtente) ON DELETE CASCADE,
    FOREIGN KEY (idLega) REFERENCES Lega(idLega) ON DELETE CASCADE,
    FOREIGN KEY (idSerata) REFERENCES Serata(idSerata) ON DELETE CASCADE,
    FOREIGN KEY (idEdizione) REFERENCES Edizione(idEdizione) ON DELETE CASCADE
);

CREATE TABLE Iscrizione_Squadra (
    idIscrizione INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    DataIscrizione DATE NOT NULL,
    idSquadra INTEGER NOT NULL,
    idLega INTEGER NOT NULL,
    FOREIGN KEY (idSquadra) REFERENCES Squadra(idSquadra) ON DELETE CASCADE,
    FOREIGN KEY (idLega) REFERENCES Lega(idLega) ON DELETE CASCADE
);

CREATE TABLE Partecipazione_Lega (
    idLega INTEGER NOT NULL,
    idUtente INTEGER NOT NULL,
    ruolo VARCHAR(20) NOT NULL,
    PRIMARY KEY (idLega, idUtente),
    FOREIGN KEY (idLega) REFERENCES Lega(idLega) ON DELETE CASCADE,
    FOREIGN KEY (idUtente) REFERENCES Utente(idUtente) ON DELETE CASCADE,
    CHECK (ruolo IN ('proprietario', 'amministratore', 'partecipante'))
);

CREATE TABLE Formazione (
    idFormazione INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    ruolo VARCHAR(10) NOT NULL CHECK (ruolo IN ('titolare', 'riserva')),
    isCapitano BOOLEAN NOT NULL CHECK (isCapitano IN (TRUE, FALSE)),
    idSquadra INTEGER NOT NULL,
    idArtista INTEGER NOT NULL,
    idSerata INTEGER NOT NULL,
    idEdizione INTEGER NOT NULL,
    FOREIGN KEY (idSquadra) REFERENCES Squadra(idSquadra) ON DELETE CASCADE,
    FOREIGN KEY (idArtista) REFERENCES Artista(idArtista) ON DELETE CASCADE,
    FOREIGN KEY (idSerata) REFERENCES Serata(idSerata) ON DELETE CASCADE,
    FOREIGN KEY (idEdizione) REFERENCES Edizione(idEdizione) ON DELETE CASCADE
);

CREATE TABLE Bonus (
    idBonus INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    DescrizioneBonus VARCHAR(200) NOT NULL,
    ValoreBonus INTEGER NOT NULL CHECK (ValoreBonus > 0),
    TipoBonus VARCHAR(30) NOT NULL
);

CREATE TABLE Malus (
    idMalus INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    DescrizioneMalus VARCHAR(200) NOT NULL,
    ValoreMalus INTEGER NOT NULL CHECK (ValoreMalus > 0),
    TipoMalus VARCHAR(30) NOT NULL
);

CREATE TABLE Assegnazione_Bonus_Malus (
    idAssegnazione INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    TipoAssegnazione VARCHAR(10) NOT NULL,
    valore INTEGER NOT NULL CHECK (valore > 0),
    motivazione TEXT,
    idBonus INTEGER,
    idMalus INTEGER,
    idArtista INTEGER NOT NULL,
    idSquadra INTEGER NOT NULL,
    idSerata INTEGER NOT NULL,
    FOREIGN KEY (idBonus) REFERENCES Bonus(idBonus) ON DELETE CASCADE,
    FOREIGN KEY (idMalus) REFERENCES Malus(idMalus) ON DELETE CASCADE,
    FOREIGN KEY (idArtista) REFERENCES Artista(idArtista) ON DELETE CASCADE,
    FOREIGN KEY (idSquadra) REFERENCES Squadra(idSquadra) ON DELETE CASCADE,
    FOREIGN KEY (idSerata) REFERENCES Serata(idSerata) ON DELETE CASCADE
);

CREATE TABLE Punteggio_Squadra (
    idPunteggio INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    punteggio INTEGER NOT NULL,
    BonusTotale INTEGER,
    MalusTotale INTEGER,
    idSquadra INTEGER NOT NULL,
    idSerata INTEGER NOT NULL,
    FOREIGN KEY (idSquadra) REFERENCES Squadra(idSquadra) ON DELETE CASCADE,
    FOREIGN KEY (idSerata) REFERENCES Serata(idSerata) ON DELETE CASCADE
);

CREATE TABLE Classifica (
    idClassifica INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    posizione INTEGER NOT NULL,
    punteggio INTEGER NOT NULL,
    idArtista INTEGER NOT NULL,
    idSerata INTEGER NOT NULL,
    idEdizione INTEGER NOT NULL,
    FOREIGN KEY (idArtista) REFERENCES Artista(idArtista) ON DELETE CASCADE,
    FOREIGN KEY (idSerata) REFERENCES Serata(idSerata) ON DELETE CASCADE,
    FOREIGN KEY (idEdizione) REFERENCES Edizione(idEdizione) ON DELETE CASCADE
);

CREATE TABLE Classifica_Squadre (
    idClassificaSquadre INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    posizione INTEGER NOT NULL,
    punteggio INTEGER NOT NULL,
    idSquadra INTEGER NOT NULL,
    idLega INTEGER NOT NULL,
    idSerata INTEGER NOT NULL,
    FOREIGN KEY (idSquadra) REFERENCES Squadra(idSquadra) ON DELETE CASCADE,
    FOREIGN KEY (idLega) REFERENCES Lega(idLega) ON DELETE CASCADE,
    FOREIGN KEY (idSerata) REFERENCES Serata(idSerata) ON DELETE CASCADE
);


/*************************************************************************************************************************************************************************/ 
--1b. Popolamento 
/*************************************************************************************************************************************************************************/ 


-- EDIZIONE
INSERT INTO edizione (anno, luogo, datainizio, datafine) VALUES
(2024, 'Sanremo', '2024-02-05', '2024-02-10'),
(2023, 'Sanremo', '2023-02-06', '2023-02-11');

-- UTENTE
INSERT INTO utente (username, nome, cognome, email, datanascita, password, dataregistrazione) VALUES
('lucar', 'Luca', 'Rossi', 'lucar@email.com', '2000-05-10', 'pw1', '2024-01-01'),
('giuliab', 'Giulia', 'Bianchi', 'giuliab@email.com', '1998-09-17', 'pw2', '2024-01-02'),
('marcov', 'Marco', 'Verdi', 'marcov@email.com', '2002-07-08', 'pw3', '2024-01-03'),
('anna90', 'Anna', 'Neri', 'anna@email.com', '1990-03-22', 'pw4', '2024-01-04');

-- ARTISTA
INSERT INTO artista (nome, biografia, generemusicale, provenienza, prezzoBaudi) VALUES
('Gigi DAlessio', 'Biografia Gigi', 'Pop', 'Napoli', 25),
('Mina', 'Biografia Mina', 'Jazz', 'Cremona', 30),
('Tiziano Ferro', 'Biografia Tiziano', 'Pop', 'Latina', 24),
('Achille Lauro', 'Biografia Achille', 'Rap', 'Roma', 18),
('Elodie', 'Biografia Elodie', 'Pop', 'Roma', 20),
('Emma', 'Biografia Emma', 'Pop', 'Firenze', 17),
('Mahmood', 'Biografia Mahmood', 'Pop', 'Milano', 22);

-- LEGA
INSERT INTO lega (nome, tipo, descrizione, idproprietario, iscampionato) VALUES
('FantaSanremo', 'pubblica', 'Lega pubblica ufficiale', 1, FALSE),
('EliteStars', 'privata', 'Lega riservata', 2, FALSE),
('Campionato Mondiale', 'pubblica', 'Lega mondiale', 1, TRUE),
('SecretSanremo', 'segreta', 'Lega segreta', 3, FALSE);

-- GIURIA
INSERT INTO giuria (nome) VALUES
('Giuria Tecnica'), ('Giuria Demoscopica'), ('Giuria Pubblico');

-- BONUS
INSERT INTO bonus (descrizionebonus, valorebonus, tipobonus) VALUES
('Standing Ovation', 10, 'speciale'),
('Look Perfetto', 5, 'look'),
('Esibizione Creativa', 8, 'performance'),
('Interazione Pubblico', 6, 'social');

-- MALUS
INSERT INTO malus (descrizionemalus, valoremalus, tipomalus) VALUES
('Dimenticanza Testo', 7, 'errore'),
('Look Improbabile', 3, 'look'),
('Arrivo in Ritardo', 5, 'ritardo'),
('Stonatura', 6, 'intonazione');

-- SERATA
INSERT INTO serata (data, ordine, idedizione) VALUES
('2024-02-06', 1, 1), ('2024-02-07', 2, 1), ('2024-02-08', 3, 1), ('2024-02-09', 4, 1), ('2024-02-10', 5, 1),
('2023-02-07', 1, 2), ('2023-02-08', 2, 2), ('2023-02-09', 3, 2), ('2023-02-10', 4, 2), ('2023-02-11', 5, 2);

-- BRANO
INSERT INTO brano (titolo, autori, compositori, durata, generemusicale, idartista, idedizione) VALUES
('Serenata', 'Gigi', 'Gigi', 210, 'Pop', 1, 1),
('Onda', 'Mina', 'Mina', 190, 'Jazz', 2, 1),
('Impossibile', 'Tiziano', 'Tiziano', 200, 'Pop', 3, 1),
('Follia', 'Achille', 'Achille', 205, 'Rap', 4, 1),
('Vertigine', 'Elodie', 'Elodie', 190, 'Pop', 5, 1),
('Fuoco', 'Emma', 'Emma', 185, 'Pop', 6, 1),
('Soldi', 'Mahmood', 'Mahmood', 180, 'Pop', 7, 1);

-- SQUADRA
INSERT INTO squadra (nome, budgetbaudi, datacreazione, idutente, idlega, idserata, idedizione) VALUES
('TeamRossi', 100, '2024-02-01', 1, 1, 1, 1),
('SquadraBianca', 100, '2024-02-01', 2, 1, 1, 1),
('VerdiPower', 100, '2024-02-01', 3, 2, 1, 1),
('NeriSuperstar', 100, '2024-02-01', 4, 2, 1, 1),
('EliteSquad', 100, '2024-02-01', 2, 2, 1, 1);

-- PARTECIPAZIONE_ARTISTA
INSERT INTO partecipazione_artista (idartista, idedizione) VALUES
(1, 1),(2, 1),(3, 1),(4, 1),(5, 1),(6, 1),(7, 1),
(1, 2),(2, 2),(3, 2),(4, 2),(5, 2);

-- ISCRIZIONE_SQUADRA
INSERT INTO iscrizione_squadra (dataiscrizione, idsquadra, idlega) VALUES
('2024-02-01', 1, 1), ('2024-02-01', 2, 1), ('2024-02-01', 3, 2),
('2024-02-01', 4, 2), ('2024-02-01', 5, 2);

-- PARTECIPAZIONE_LEGA
INSERT INTO partecipazione_lega (idlega, idutente, ruolo) VALUES
(1, 1, 'proprietario'), (1, 2, 'partecipante'), (1, 3, 'partecipante'), (1, 4, 'partecipante'),
(2, 2, 'proprietario'), (2, 3, 'amministratore'), (2, 1, 'partecipante'),
(3, 1, 'proprietario'), (3, 2, 'partecipante'), (3, 3, 'partecipante'),
(4, 3, 'proprietario'), (4, 4, 'partecipante');

-- FORMAZIONE
INSERT INTO formazione (ruolo, iscapitano, idsquadra, idartista, idserata, idedizione) VALUES
('titolare', TRUE, 1, 1, 1, 1),
('titolare', FALSE, 1, 2, 2, 1),
('titolare', FALSE, 1, 3, 3, 1),
('titolare', FALSE, 1, 4, 4, 1),
('titolare', FALSE, 1, 5, 5, 1),
('riserva', FALSE, 1, 6, 1, 1),
('titolare', TRUE, 2, 2, 1, 1),
('titolare', FALSE, 2, 3, 2, 1),
('titolare', FALSE, 2, 4, 3, 1),
('titolare', FALSE, 2, 5, 4, 1),
('titolare', FALSE, 2, 6, 5, 1),
('riserva', FALSE, 2, 7, 1, 1);

-- ESIBIZIONE
INSERT INTO esibizione (orario, ordineesibizione, dettagliaggiuntivi, idserata, idartista, idbrano) VALUES
('21:10', 1, 'Apertura spettacolare', 1, 1, 1),
('21:25', 2, '', 1, 2, 2),
('21:40', 3, '', 1, 3, 3),
('21:55', 4, '', 1, 4, 4),
('22:10', 5, '', 1, 5, 5),
('22:25', 6, '', 1, 6, 6),
('22:40', 7, '', 1, 7, 7);

-- GIURIA_TECNICA
INSERT INTO giuria_tecnica (idgiuria, numeroesperti, organizzazione) VALUES
(1, 10, 'RAI');

-- GIURIA_DEMOSCOPICA
INSERT INTO giuria_demoscopica (idgiuria, numerocampionamento, metodocampionamento) VALUES
(2, 400, 'Sorteggio');

-- GIURIA_PUBBLICO
INSERT INTO giuria_pubblico (idgiuria, tipovoto, numerovoti) VALUES
(3, 'televoto', 12000);

-- ASSEGNAZIONE_BONUS_MALUS
INSERT INTO assegnazione_bonus_malus (tipoassegnazione, valore, motivazione, idbonus, idmalus, idartista, idsquadra, idserata) VALUES
('bonus', 10, 'Standing Ovation', 1, NULL, 1, 1, 1),
('malus', 7, 'Dimenticanza Testo', NULL, 1, 2, 1, 1),
('bonus', 8, 'Esibizione Creativa', 3, NULL, 3, 2, 2),
('malus', 3, 'Look Improbabile', NULL, 2, 3, 3, 3),
('bonus', 5, 'Look Perfetto', 2, NULL, 4, 4, 4),
('malus', 5, 'Arrivo in Ritardo', NULL, 3, 5, 5, 5),
('bonus', 6, 'Interazione Pubblico', 4, NULL, 1, 5, 1);

-- PUNTEGGIO_SQUADRA
INSERT INTO punteggio_squadra (punteggio, bonustotale, malustotale, idsquadra, idserata) VALUES
(30, 38, 8, 1, 1), (10, 13, 3, 2, 1), (28, 33, 5, 3, 1), 
(38, 43, 5, 4, 2), (21, 27, 6, 5, 3);

-- VOTI
INSERT INTO voti (valore, idesibizione, idgiuria) VALUES
(8, 1, 1), (9, 1, 2), (7, 1, 3),
(7, 2, 1), (8, 2, 2), (7, 2, 3),
(9, 3, 1), (9, 3, 2), (8, 3, 3),
(10, 4, 1), (9, 4, 2), (8, 4, 3),
(7, 5, 1), (8, 5, 2), (7, 5, 3);

-- CLASSIFICA
INSERT INTO classifica (posizione, punteggio, idartista, idserata, idedizione) VALUES
(1, 110, 1, 1, 1), (2, 105, 2, 1, 1), (3, 100, 3, 1, 1),
(4, 90, 4, 1, 1), (5, 85, 5, 1, 1);

-- CLASSIFICA_SQUADRE
INSERT INTO classifica_squadre (posizione, punteggio, idsquadra, idlega, idserata) VALUES
(1, 40, 1, 1, 1), (2, 38, 4, 2, 2), (3, 36, 2, 1, 1), (4, 21, 5, 2, 3);



/*************************************************************************************************************************************************************************/ 
--2. Vista
/* Si vuole creare una vista che, per ogni squadra, mostri il totale dei bonus assegnati, il totale dei malus assegnati e il punteggio medio ottenuto nelle varie serate, aggregando i dati da almeno tre tabelle: squadra, assegnazione_bonus_malus e punteggio_squadra. */
/*************************************************************************************************************************************************************************/ 

CREATE OR REPLACE VIEW vista_riassunto_squadre AS
SELECT
    s.idsquadra,
    s.nome AS nome_squadra,
    COUNT(CASE WHEN abm.tipoassegnazione = 'bonus' THEN 1 END) AS totale_bonus,
    COUNT(CASE WHEN abm.tipoassegnazione = 'malus' THEN 1 END) AS totale_malus,
    AVG(ps.punteggio) AS punteggio_medio
FROM
    squadra s
LEFT JOIN assegnazione_bonus_malus abm ON abm.idsquadra = s.idsquadra
LEFT JOIN punteggio_squadra ps ON ps.idsquadra = s.idsquadra
GROUP BY s.idsquadra, s.nome;

/*************************************************************************************************************************************************************************/
--Comando per richiamare la vista 

SELECT * FROM vista_riassunto_squadre;

/*************************************************************************************************************************************************************************/

--3. Interrogazioni
/*************************************************************************************************************************************************************************/ 

/*************************************************************************************************************************************************************************/ 
/* 3a (interrogazione con operazione insiemistica)															 */

/* Si vuole ottenere l'elenco di tutti gli artisti che hanno ricevuto almeno un bonus oppure almeno un malus, cioè tutti gli artisti che hanno avuto assegnazioni di     */
/* bonus e/o malus.                                                                                                                                                      */                                                                    
/*************************************************************************************************************************************************************************/ 


SELECT DISTINCT idartista
FROM assegnazione_bonus_malus
WHERE tipoassegnazione = 'bonus'

UNION

SELECT DISTINCT idartista
FROM assegnazione_bonus_malus
WHERE tipoassegnazione = 'malus';



/*************************************************************************************************************************************************************************/ 
/* 3b (interrogazione di divisione) 																	 */

/* Si vogliono individuare le squadre che hanno schierato una formazione in tutte le serate relative a una specifica edizione del festival (ad esempio l�edizione 2024). */
/* L'interrogazione restituisce solo le squadre che non hanno saltato nessuna serata.                                                                                  */
/*************************************************************************************************************************************************************************/ 


SELECT s.idsquadra, s.nome
FROM squadra s
WHERE NOT EXISTS (
    SELECT se.idserata
    FROM serata se
    WHERE se.idedizione = 1 -- es: edizione 2024
    AND NOT EXISTS (
        SELECT 1
        FROM formazione f
        WHERE f.idsquadra = s.idsquadra
          AND f.idserata = se.idserata
    )
); 



/*************************************************************************************************************************************************************************/ 
/* 3c (interrogazione con sottointerrogazione correlata) 														 */

/* Si vuole ottenere la lista delle squadre che hanno almeno un artista in formazione che ha ricevuto almeno un bonus di valore superiore a 8 in una serata. */
/**********************************************************************************************************/

SELECT s.idsquadra, s.nome
FROM squadra s
WHERE EXISTS (
    SELECT 1
    FROM formazione f
    JOIN assegnazione_bonus_malus abm ON abm.idsquadra = f.idsquadra AND abm.idartista = f.idartista
    WHERE f.idsquadra = s.idsquadra
      AND abm.tipoassegnazione = 'bonus'
      AND abm.valore > 8
);


/*************************************************************************************************************************************************************************/ 
--4. Funzioni
/*************************************************************************************************************************************************************************/ 

/*************************************************************************************************************************************************************************/ 
/* 4a: operazione di inserimento non banale, effettuando tutti gli opportuni controlli e calcoli di dati derivati.							 */

/* Si vuole creare una funzione che inserisce un nuovo giocatore in formazione per una squadra in una determinata serata.                                                */
/* La funzione controlla:                                                                                                                                                */
/*	- Che il budget della squadra sia sufficiente per acquistare quell'artista.                                                                                      */
/*	- Che non sia già stato inserito quell'artista per quella serata nella stessa squadra.                                                                           */
/*	- Che il numero massimo di titolari (5) e riserve (2) non venga superato.                                                                                        */
/* Se i controlli sono superati, la funzione inserisce il record in Formazione, aggiorna il budget della squadra e restituisce un messaggio di successo.                 */
/* Altrimenti, restituisce un messaggio di errore descrittivo.														 */
/*************************************************************************************************************************************************************************/ 


CREATE OR REPLACE FUNCTION inserisci_formazione(
    in_idSquadra INT,
    in_idArtista INT,
    in_idSerata INT,
    in_idEdizione INT,
    in_ruolo VARCHAR,
    in_prezzo INT,
    in_isCapitano BOOLEAN
) RETURNS TEXT AS $$
DECLARE
    budget INT;
    num_titolari INT;
    num_riserve INT;
    already_present INT;
BEGIN
    -- Controlla budget
    SELECT budgetbaudi INTO budget FROM squadra WHERE idsquadra = in_idSquadra;
    IF budget < in_prezzo THEN
        RETURN 'Budget insufficiente';
    END IF;

    -- Controlla limite titolari/riserve
    SELECT COUNT(*) INTO num_titolari FROM formazione
        WHERE idsquadra = in_idSquadra AND idserata = in_idSerata AND ruolo = 'titolare';
    SELECT COUNT(*) INTO num_riserve FROM formazione
        WHERE idsquadra = in_idSquadra AND idserata = in_idSerata AND ruolo = 'riserva';

    IF (in_ruolo = 'titolare' AND num_titolari >= 5) OR (in_ruolo = 'riserva' AND num_riserve >= 2) THEN
        RETURN 'Superato limite titolari/riserve';
    END IF;

    -- Controlla duplicato artista
    SELECT COUNT(*) INTO already_present FROM formazione
        WHERE idsquadra = in_idSquadra AND idserata = in_idSerata AND idartista = in_idArtista;
    IF already_present > 0 THEN
        RETURN 'Artista già presente in formazione per questa serata';
    END IF;

    -- Inserisce la formazione
    INSERT INTO formazione (ruolo, iscapitano, idsquadra, idartista, idserata, idedizione)
    VALUES (in_ruolo, in_isCapitano, in_idSquadra, in_idArtista, in_idSerata, in_idEdizione);

    -- Aggiorna il budget della squadra
    UPDATE squadra SET budgetbaudi = budgetbaudi - in_prezzo WHERE idsquadra = in_idSquadra;

    RETURN 'Formazione inserita correttamente';
END;
$$ LANGUAGE plpgsql;

--esempio di chiamata
SELECT inserisci_formazione(
    1,   -- in_idSquadra
    2,   -- in_idArtista
    1,   -- in_idSerata
    1,   -- in_idEdizione
    'titolare',   -- in_ruolo
    25,  -- in_prezzo (esempio)
    FALSE -- in_isCapitano
);

/*************************************************************************************************************************************************************************/ 
/* 4b: calcolo di un informazione derivata rilevante e non banale, che richieda l'accesso a diverse tabelle e un'aggregazione                                            */

/* Si desidera calcolare il punteggio medio totale delle squadre appartenenti a una determinata lega.                                                                    */
/* Per ciascuna squadra della lega selezionata, si sommano i punteggi ottenuti in tutte le serate;                                                                       */
/* si calcola quindi la media di questi punteggi totali tra tutte le squadre della lega, restituendo il valore risultante.                                               */                                                                     */
/*************************************************************************************************************************************************************************/ 


CREATE OR REPLACE FUNCTION media_punteggio_lega(idLegaInput INT)
RETURNS NUMERIC AS $$
DECLARE
    media NUMERIC;
BEGIN
    SELECT AVG(totale) INTO media
    FROM (
        SELECT SUM(ps.punteggio) AS totale
        FROM squadra s
        JOIN punteggio_squadra ps ON ps.idsquadra = s.idsquadra
        WHERE s.idlega = idLegaInput
        GROUP BY s.idsquadra
    ) sub;
    
    RETURN COALESCE(media, 0);
END;
$$ LANGUAGE plpgsql;

--esempio di chiamata
SELECT idlega, media_punteggio_lega(idlega) AS media_punteggio
FROM lega;

/*************************************************************************************************************************************************************************/ 
--5. Trigger
/*************************************************************************************************************************************************************************/ 

/*************************************************************************************************************************************************************************/ 
/* 5a: trigger per la verifica di un vincolo che non sia implementabile come vincolo CHECK                                                                               */                                                                          
/* "In una formazione, se un artista viene indicato come capitano (isCapitano = TRUE), allora il suo ruolo deve essere necessariamente 'titolare'. Non � permesso 
assegnare il ruolo di capitano a una riserva."                                                                                                                           */
/*************************************************************************************************************************************************************************/ 


-- Prima la funzione trigger
CREATE OR REPLACE FUNCTION check_captain_role()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.isCapitano = TRUE AND NEW.ruolo <> 'titolare') THEN
        RAISE EXCEPTION 'Se isCapitano = TRUE, il ruolo deve essere "titolare"';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Poi il trigger vero e proprio
CREATE TRIGGER trg_check_captain_role
BEFORE INSERT OR UPDATE ON Formazione
FOR EACH ROW
EXECUTE FUNCTION check_captain_role();
 

/*************************************************************************************************************************************************************************/ 
/* 5b: trigger per il mantenimento di informazione derivata o per l'implementazione di una regola di dominio                                                              */                                                                          
/* Ogni volta che viene inserito o aggiornato un record nella tabella punteggio_squadra, il valore del campo punteggio viene automaticamente calcolato come la differenza */
/* tra il totale dei bonus e il totale dei malus per quella squadra in quella serata, garantendo sempre la coerenza tra questi valori.                                    */
/*************************************************************************************************************************************************************************/ 

-- Prima la funzione trigger
CREATE OR REPLACE FUNCTION aggiorna_punteggio_squadra()
RETURNS TRIGGER AS $$
BEGIN
    NEW.punteggio := COALESCE(NEW.bonustotale, 0) - COALESCE(NEW.malustotale, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Poi il trigger 
DROP TRIGGER IF EXISTS trg_aggiorna_punteggio_squadra ON punteggio_squadra;

CREATE TRIGGER trg_aggiorna_punteggio_squadra
BEFORE INSERT OR UPDATE ON punteggio_squadra
FOR EACH ROW
EXECUTE FUNCTION aggiorna_punteggio_squadra();


