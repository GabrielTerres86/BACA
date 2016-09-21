/* ..........................................................................

   Programa: fontes/libera_nsu_cashes.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2007                          Ultima atualizacao:   /  /    
                                                                        
   Dados referentes ao programa:

   Frequencia: CRON
   Objetivo  : Liberar registro NSU.

   Alteracoes: 

............................................................................. */

DEF VAR aux_nmusuari AS CHAR NO-UNDO.
DEF VAR aux_nmusuant AS CHAR NO-UNDO.

DEF VAR aux_nrdrecid AS INT  NO-UNDO.
DEF VAR aux_nrusuari AS INT  NO-UNDO.
DEF VAR aux_nrusuant AS INT  NO-UNDO.
DEF VAR aux_contador AS INT  NO-UNDO.
DEF VAR aux_cdcooper AS INT  NO-UNDO.

ASSIGN aux_contador = 0
       aux_nrusuant = 0.

/*  Captura codigo da cooperativa da variavel de ambiente CDCOOPER .......... */

aux_cdcooper = INT(OS-GETENV("CDCOOPER")).

IF   aux_cdcooper = ?   THEN
     QUIT.

DO WHILE TRUE:

   FIND FIRST crapnsu WHERE crapnsu.cdcooper = aux_cdcooper
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE crapnsu   THEN
        IF   LOCKED crapnsu   THEN
             DO:
                 FIND FIRST crapnsu WHERE crapnsu.cdcooper = aux_cdcooper
                                          NO-LOCK NO-ERROR.
                 
                 aux_nrdrecid = RECID(crapnsu).

                 RUN acha_lock (INPUT  aux_nrdrecid, INPUT  "crapnsu",
                                OUTPUT aux_nrusuari, OUTPUT aux_nmusuari).

                 IF   aux_nmusuant = ""   THEN
                      DO:
                          ASSIGN aux_nmusuant = aux_nmusuari
                                 aux_nrusuant = aux_nrusuari
                                 aux_contador = 1.
                          
                          PAUSE 2 NO-MESSAGE.
                          NEXT.
                      END.      
                      
                 IF   aux_nmusuant <> aux_nmusuari   THEN
                      DO:
                          ASSIGN aux_nmusuant = aux_nmusuari
                                 aux_nrusuant = aux_nrusuari
                                 aux_contador = 1.
                                 
                          PAUSE 2 NO-MESSAGE.
                          NEXT.
                      END.
                 
                 aux_contador = aux_contador + 1.
                 
                 IF   aux_contador = 25   THEN
                      RUN mata_lock.
                      
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END.
   
   FIND CURRENT crapnsu NO-LOCK.

   LEAVE.
   
END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

PROCEDURE acha_lock:

    DEF INPUT  PARAM par_recid    AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nmtabela AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nrusuari AS INT                               NO-UNDO.
    DEF OUTPUT PARAM par_nmusuari AS CHAR                              NO-UNDO.

    FIND FIRST _file WHERE _file-name = par_nmtabela NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE _file   THEN
         RETURN.
     
    FIND FIRST _lock WHERE _lock-table = _file._file-number   AND
                           _lock-recid = par_recid NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE _lock   THEN
         RETURN.

    FIND _connect WHERE _connect._connect-usr = _lock-usr NO-LOCK NO-ERROR.
     
    IF   NOT AVAILABLE _connect   THEN
         RETURN.

    ASSIGN par_nmusuari = _connect-device
           par_nrusuari = _connect-usr.

    LEAVE.
    
END PROCEDURE.

PROCEDURE mata_lock:

    DEF VAR aux_dscomand AS CHAR NO-UNDO.
    
    UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                      STRING(TIME,"HH:MM:SS") + "' --> '"  + 
                      "Liberando NSU alocada pelo cash " +
                      STRING(aux_nmusuari) + " - " +
                      STRING(aux_nrusuari) + " >> /usr/coop/cecred/log/" +
                      "cashes_desconectados.log").
    
    ASSIGN aux_contador = 0
           aux_dscomand = "sudo proshut " + STRING(DBNAME) + 
                          " -C disconnect " + 
                          STRING(aux_nrusuari) + " > /dev/null".
    
    UNIX SILENT VALUE(aux_dscomand).

END PROCEDURE.

/* .......................................................................... */

