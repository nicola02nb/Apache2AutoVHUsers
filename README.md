# VIRTUAL HOST APACHE CON PERMESSI SEPARATI

Questo script si occupa di installare e gestire un servizio di hosting web tramite un web-server `apache2` con il supporto per `php`.
Lo script e mirato a creare dei **Virtual Host** per ogni singolo utente, i quali tramite la **mod** di **Apache** `libapache2-mpm-itk`, sono eseguiti con permessi utente separati e indipendenti per prevenire problemi di sicurezza:

- **Accesso** a file di altri utenti tramite `php`
- Uso di utenti differenti al posto di uno condiviso come `www-data`

## Installazione

Installato e testato su server **DEBIAN 10 64bit**

Dipendenze necessarie per l'utilizzo `curl`:

`sudo apt install curl`

Per utilizzare lo script basta **scaricatrlo** tramite:

`curl https://git.e-fermi.it/s01723/apache2autovhusers/-/raw/master/Apache2AutoVHUsers.sh --output Apache2AutoVHUsers.sh`

Poi bisogna dargli i permessi di **esecuzione**:

`chmod +x ./Apache2AutoVHUsers.sh`

## Utilizo

Per esegurlo basta esegure il file `.sh`:

`./Apache2AutoVHUsers.sh`
