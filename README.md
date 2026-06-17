# FantaSanremo - Progetto Basi di Dati 2024-25

Un sistema relazionale completo per la gestione del FantaSanremo, progettato e implementato come progetto d'esame (12 CFU) per il corso di Basi di Dati. Il database modella e gestisce la logica di gioco del festival, inclusi utenti, squadre, leghe (pubbliche, private, segrete), artisti, brani, votazioni delle giurie (tecnica, demoscopica, pubblico) e l'assegnazione dinamica di bonus e malus.

## Funzionalità Principali

Il progetto copre l'intero ciclo di vita di un database relazionale, partendo dall'analisi dei requisiti fino all'ottimizzazione delle performance:

*   **Progettazione Concettuale e Logica**: Modellazione tramite Diagramma Entity-Relationship (ER) e ristrutturazione in uno schema logico relazionale rigorosamente normalizzato fino alla Terza Forma Normale di Boyce-Codd (BCNF).
*   **Implementazione SQL (DDL e DML)**: Creazione delle tabelle con vincoli di integrità (CHECK, chiavi primarie ed esterne con regole di cancellazione a cascata) e popolamento massivo dei dati.
*   **Interrogazioni e Viste**: Realizzazione di viste riassuntive (es. statistiche base/malus delle squadre) e query avanzate che includono operazioni insiemistiche, divisione relazionale e sottointerrogazioni correlate.
*   **Logica Applicativa Server-Side (PL/pgSQL)**:
    *   *Funzioni*: Procedure per l'inserimento controllato in formazione (con validazione del budget Baudi, dei limiti massimi di 5 titolari/2 riserve e controllo duplicati) e calcolo delle medie di lega.
    *   *Trigger*: Meccanismi automatici per la validazione del ruolo (es. il capitano deve essere titolare) e per il calcolo e l'aggiornamento automatico in tempo reale dei punteggi delle squadre.
*   **Progettazione Fisica e Ottimizzazione**: Analisi comparativa dei piani di esecuzione (EXPLAIN) e creazione mirata di indici B-tree (inclusi indici funzionali sulle date) per abbattere i tempi di risposta (Cost e Execution Time) delle query di sistema.
*   **Sicurezza e Controllo Accessi**: Implementazione di una rigida gerarchia di privilegi tramite i ruoli di PostgreSQL (`proprietario`, `amministratore`, `utente_premium`, `utente_semplice`), con assegnazione granulare dei permessi (GRANT/REVOKE).
*   **Data Populating in the Large**: Scripting per l'inserimento massivo di centinaia di record per stress-testare lo schema fisico e le performance del database.

## Tecnologie Utilizzate
*   **Database Management System**: PostgreSQL tramite interfaccia pgAdmin
*   **Linguaggi**: SQL, PL/pgSQL
*   **Modellazione Dati**: Progettazione Concettuale (Diagrammi ER)

## Autori (Gruppo 63)
*   **Andrea Peri** (Matricola: 541544)
*   **Jeffrey Germano** (Matricola: 5669424)
*   **Alessio Giorno** (Matricola: 5590816)
