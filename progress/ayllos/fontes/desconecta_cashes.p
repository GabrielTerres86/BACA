/* ..........................................................................

   Programa: fontes/desconecta_cashes.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Fevereiro/2007                      Ultima atualizacao:   /  /    
                                                                        
   Dados referentes ao programa:

   Frequencia: CRON
   Objetivo  : Desconectar instancias duplicadas dos cashes.

   Alteracoes: 

   Observacoes: _connect-type: SELF => Conexoes locais (terminais)
                               REMC => Conexoes remotas (cashes)
                               RPLS => Replicacao (Server)
                               RPLA => Replicacao (Agent)
                               FMA  => DB_Agent Fathom Management 
                                
............................................................................. */

DEF VAR aux_nmdmeses AS CHAR                                         NO-UNDO.

DEF VAR aux_nrdiacon AS INT                                          NO-UNDO.
DEF VAR aux_nrmescon AS INT                                          NO-UNDO.
DEF VAR aux_nranocon AS INT                                          NO-UNDO.
DEF VAR aux_nrhorcon AS INT                                          NO-UNDO.

DEF TEMP-TABLE w_cash                                                NO-UNDO
         FIELD w_userio-usr     AS INT  
         FIELD w_connect-date   AS DATE
         FIELD w_connect-time   AS INT
         FIELD w_connect-device AS CHAR
         FIELD w_userio-name    AS CHAR.

aux_nmdmeses = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec".

FIND _myconnection NO-LOCK.

FOR EACH _connect WHERE _connect-type = "REMC"             AND
                        _connect-disconnect = 0            AND
                        _connect-device MATCHES "*cash*"   AND
                        _connect-usr <> _myconn-userid NO-LOCK,
    EACH _userio WHERE _userio._userio-usr = _connect-usr NO-LOCK:

    IF   NOT AVAILABLE _userio  THEN
         NEXT.

    IF   _userio-name = "root"   THEN
         NEXT.
         
    ASSIGN aux_nrmescon = LOOKUP(SUBSTRING(_connect-time,5,3),aux_nmdmeses)
           aux_nrdiacon = INT(SUBSTRING(_connect-time,09,2))
           aux_nranocon = INT(SUBSTRING(_connect-time,21,4))
           
           aux_nrhorcon = (INT(SUBSTRING(_connect-time,12,2)) * 3600) +
                          (INT(SUBSTRING(_connect-time,15,2)) * 60) +
                          (INT(SUBSTRING(_connect-time,18,2))).
         
    IF   aux_nrmescon = 0   THEN
         NEXT.

    CREATE w_cash.
    ASSIGN w_userio-usr     = _userio-usr
           w_connect-date   = DATE(aux_nrmescon,aux_nrdiacon,aux_nranocon)
           w_connect-time   = aux_nrhorcon
           w_connect-device = _connect-device
           w_userio-name    = _userio-name.
 
END.  /*  Fim do FOR EACH -- _connect  */

FOR EACH w_cash NO-LOCK BREAK BY w_connect-device
                                 BY w_connect-date
                                    BY w_connect-time:
    
    IF   NOT LAST-OF(w_connect-device)   THEN
         DO:
             UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                               STRING(TIME,"HH:MM:SS") + "' --> '"  + 
                               "Desconectando cash " +
                               STRING(w_connect-device) + " - " +
                               STRING(w_userio-usr) + " no " +
                               STRING(ENTRY(NUM-ENTRIES(DBNAME,"/"),
                                            DBNAME,"/")) +
                               " >> /usr/coop/cecred/log/" +
                               "cashes_desconectados.log").

             UNIX SILENT VALUE("proshut " + STRING(DBNAME) +
                               " -C disconnect " + STRING(w_userio-usr) + 
                               " > /dev/null").
         END.

END.  /*  Fim do FOR EACH  */

/* .......................................................................... */

