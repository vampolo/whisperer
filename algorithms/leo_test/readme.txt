Ti allego a questa mail due funzioni matlab che sostanzialmente invocano
le operazioni necessarie a creare il modello con uno degli algoritmi
(LSA) e ad usarlo poi per creare il vettore di raccomandazioni. Una
funzione restituisce modello e raccomandazioni per un utente
(identificato dal numero di riga della urm). L'altra prende in input
anche un modello già creato e quindi permette di richiedere direttamente
la raccomandazione.
Puoi eseguirle direttamente da Matlab invocando rispettivamente i comandi:
[model, recList] = full_flowLSA (urmTraining, icm, 5);
recList = flowLSA (model, urmTraining, icm, 184);

Ovviamente il numero è l'utente di cui sei interessato ad ottenere il
vettore di raccomandazioni.
Noterai che ho inserito e commentato alcune righe. Infatti benché non
servano direttamente in questo caso potrebbe essere talvolta necessario
specificare anche parametri di tipo funzione (come ad esempio la prima
riga commentata).

Non c'è necessità in questo caso di ridurre il set di dati i quanto con
questo algoritmo la creazione del modello impiega poco meno di un minuto
e le raccomandazioni sono pressoché istantanee.
