/*..............................................................................

   Programa: fontes/crps584.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Novembro/2010                      Ultima atualizacao: 05/04/2017.

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Integra Protocolo Eletronico - Atualizacao de Cheques para
               Processados - Tratar arquivo de retorno da Truncagem

   Alteracoes: 23/03/2011 - Incluir as atualizacoes do crapcst e crapcdb (Ze).
             
               13/05/2011 - Acerto no tratamento do Grupo SETEC (Ze).
               
               13/02/2012 - Alteracao para que todas as coops possam 
                            digitalizar cheques da propria cooperativa (ZE).
                            
               15/03/2012 - Acerto no tratamento de cheques do BB na 
                            custodia/desconto (Elton).
                            
               26/03/2012 - Faz primeiro a verificacao dos cheques da crapcdb e 
                            depois a verificacao dos cheques da crapcst (Elton).

			   20/07/2016 - Alteracao do caminho onde serao salvos os arquivos
							de truncagem de cheque. SD 476097. Carlos R.	

               
               05/04/2017 - Incluir dtdevolu na leitura da crapcdb e crapcst (Lucas Ranghetti #621301)

			   26/05/2017 - Alterado ordem de atualizacao tabela cst e cdb (Daniel).
..............................................................................*/

{ includes/var_batch.i "NEW" }

DEF STREAM str_1.
DEF STREAM str_2.

DEF TEMP-TABLE crawarq                                                  NO-UNDO
    FIELD nrsequen AS INTEGER
    FIELD nmarquiv AS CHAR
    INDEX crawarq1 AS PRIMARY
          nmarquiv nrsequen.

DEF VAR aux_mes      AS CHAR                                           NO-UNDO.
DEF VAR aux_dtarquiv AS DATE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_cdbanchq AS INT                                            NO-UNDO.
DEF VAR aux_cdagechq AS INT                                            NO-UNDO.
DEF VAR aux_cdcmpchq AS INT                                            NO-UNDO.
DEF VAR aux_nrcheque AS INT                                            NO-UNDO.
DEF VAR aux_nrctachq AS DECI                                           NO-UNDO.

DEF VAR aux_dscooper AS CHAR                                           NO-UNDO.

ASSIGN glb_cdprogra = "crps584"
       glb_flgbatch = FALSE.

FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:

    /*  Le data do sistema  */

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR NO-WAIT.

    IF   NOT AVAILABLE crapdat THEN
         DO:
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + "Cooperativa: " +
                               STRING(crapcop.nmrescop) + 
                               " - Sem data de sistema (crapdat) " +
                               " >> log/proc_batch.log").
             NEXT.                  
         END.
    ELSE
         ASSIGN glb_cdcritic = 0
                glb_dtmvtolt = crapdat.dtmvtolt.
    
    RUN pi_carrega_arquivos.

    RUN pi_processa_registros.

END.

QUIT.

/*............................................................................*/

PROCEDURE pi_carrega_arquivos:

    EMPTY TEMP-TABLE crawarq.

    IF   MONTH(glb_dtmvtolt) > 9 THEN
         CASE MONTH(glb_dtmvtolt):
              WHEN 10 THEN aux_mes = "O".
              WHEN 11 THEN aux_mes = "N".
              WHEN 12 THEN aux_mes = "D".
         END CASE.
    ELSE
         aux_mes = STRING(MONTH(glb_dtmvtolt),"9").
    
    ASSIGN aux_contador = 0
           aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/"
           aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/integra/R" +
                          STRING(crapcop.cdagectl,"9999") +
                          aux_mes                         + 
                          STRING(DAY(glb_dtmvtolt),"99")  +
                          ".*".

    INPUT STREAM str_1 
          THROUGH VALUE("ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
        SET STREAM str_1 aux_nmarquiv FORMAT "x(70)".

        ASSIGN aux_contador = aux_contador + 1.

        CREATE crawarq.
        ASSIGN crawarq.nrsequen = aux_contador
               crawarq.nmarquiv = aux_nmarquiv.

    END. /*** Fim do DO WHILE TRUE ***/

    INPUT STREAM str_1 CLOSE.


END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_registros:

    FOR EACH crawarq BY crawarq.nrsequen:

        ASSIGN glb_cdcritic = 0.

        /* Verificar se o arquivo esta completo - inicio */
        INPUT STREAM str_1 THROUGH VALUE("tail -1 " + crawarq.nmarquiv)
                           NO-ECHO.

        IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
        
        IF   SUBSTR(aux_setlinha,01,10) <> "9999999999" THEN
             DO:
                 
                 INPUT STREAM str_1 CLOSE.
                 
                 UNIX SILENT VALUE ("strings " + 
                                    crawarq.nmarquiv + " > " +
                                    crawarq.nmarquiv + ".OK").
                                    
                 UNIX SILENT VALUE ("cp " +
                                    crawarq.nmarquiv + " ./tmp").
                                    
                 UNIX SILENT VALUE ("mv " +
                                    crawarq.nmarquiv + ".OK " +
                                    crawarq.nmarquiv).
                   

                 /* Verificar se o arquivo esta completo - inicio */
                 INPUT STREAM str_1 THROUGH VALUE("tail -1 " + crawarq.nmarquiv)
                           NO-ECHO.

                 IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
                
                 IF   SUBSTR(aux_setlinha,01,10) <> "9999999999" THEN
                 DO:
                                    
					 glb_cdcritic = 258.
					 RUN fontes/critic.p.
					 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
									   glb_cdprogra + "' --> '" + glb_dscritic +
									   " - Arquivo: " + crawarq.nmarquiv +
									   " >> log/proc_batch.log").
					 glb_cdcritic = 0.
					 NEXT.
             END.
             END.

        INPUT STREAM str_1 CLOSE.


        /* Verificar se o arquivo inicia correto */
        INPUT STREAM str_2 FROM VALUE(crawarq.nmarquiv) NO-ECHO.

        IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
        
        ASSIGN aux_dtarquiv = DATE(INT(SUBSTR(aux_setlinha,70,2)),
                                   INT(SUBSTR(aux_setlinha,72,2)),
                                   INT(SUBSTR(aux_setlinha,66,4))).

        IF   SUBSTR(aux_setlinha,1,10) <> "0000000000"  THEN
             glb_cdcritic = 468.

        IF   glb_cdcritic <> 0 THEN
             DO:
                 INPUT STREAM str_2 CLOSE.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " - Arquivo: " + crawarq.nmarquiv +
                                   " >> log/proc_batch.log").
                     
                 glb_cdcritic = 0.
                 NEXT.
             END.

        INPUT STREAM str_2 CLOSE.

        glb_cdcritic = 0.

        INPUT STREAM str_2 FROM VALUE(crawarq.nmarquiv) NO-ECHO.
    
        IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

        TRANS_1:
        DO WHILE TRUE TRANSACTION ON ENDKEY UNDO TRANS_1, LEAVE TRANS_1
                                  ON ERROR  UNDO TRANS_1, LEAVE TRANS_1:
                                       
           IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
           
           IF   SUBSTR(aux_setlinha,1,10) = "9999999999" THEN 
                LEAVE.
            
           /* 04 a 06 - Numero do Banco   */
           /* 07 a 10 - Numero da Agencia */
           /* 01 a 03 - Codigo da Compe   */
           /* 25 a 30 - Numero do Cheque  */
    
           ASSIGN aux_cdbanchq = INT(SUBSTR(aux_setlinha,4,3))
                  aux_cdagechq = INT(SUBSTR(aux_setlinha,7,4))
                  aux_cdcmpchq = INT(SUBSTR(aux_setlinha,1,3))
                  aux_nrcheque = INT(SUBSTR(aux_setlinha,25,6))
                  aux_nrctachq = DEC(SUBSTR(aux_setlinha,12,12)).
                  
           FIND LAST crapchd WHERE crapchd.cdcooper = crapcop.cdcooper AND
                                   crapchd.dtmvtolt = aux_dtarquiv     AND
                                   crapchd.cdcmpchq = aux_cdcmpchq     AND
                                   crapchd.cdbanchq = aux_cdbanchq     AND 
                                   crapchd.cdagechq = aux_cdagechq     AND 
                                   crapchd.nrctachq = aux_nrctachq     AND 
                                   crapchd.nrcheque = aux_nrcheque
                                   EXCLUSIVE-LOCK NO-ERROR.
            
           IF   AVAILABLE crapchd THEN
                ASSIGN crapchd.insitprv = 3.
           ELSE
                DO:
                    /* Trata Grupo SETEC */
                    IF   aux_cdbanchq = 1    AND
                         aux_cdagechq = 3420 THEN
                         aux_nrctachq = DEC("0070" +
                                            SUBSTR(aux_setlinha,16,08)).

                    FIND LAST crapchd WHERE 
                              crapchd.cdcooper = crapcop.cdcooper AND
                              crapchd.dtmvtolt = aux_dtarquiv     AND
                              crapchd.cdcmpchq = aux_cdcmpchq     AND
                              crapchd.cdbanchq = aux_cdbanchq     AND 
                              crapchd.cdagechq = aux_cdagechq     AND 
                              crapchd.nrctachq = aux_nrctachq     AND 
                              crapchd.nrcheque = aux_nrcheque
                              EXCLUSIVE-LOCK NO-ERROR.
            
                    IF   AVAILABLE crapchd THEN
                         ASSIGN crapchd.insitprv = 3.
                    ELSE
                         DO:
                              IF  aux_cdbanchq = 1    AND
                                  aux_cdagechq = 3420 THEN
                                  aux_nrctachq = DEC(SUBSTR(aux_setlinha,16,08)).

                              FIND LAST crapchd WHERE 
                                   crapchd.cdcooper = crapcop.cdcooper AND
                                   crapchd.dtmvtolt = aux_dtarquiv     AND
                                   crapchd.cdcmpchq = aux_cdcmpchq     AND
                                   crapchd.cdbanchq = aux_cdbanchq     AND 
                                   crapchd.cdagechq = aux_cdagechq     AND 
                                   crapchd.nrctachq = aux_nrctachq     AND 
                                   crapchd.nrcheque = aux_nrcheque
                                   EXCLUSIVE-LOCK NO-ERROR.
            
                              IF   AVAILABLE crapchd THEN
                                   ASSIGN crapchd.insitprv = 3.
                              ELSE 
                                    DO: /*** Desconto de Cheque ***/
                                        IF    aux_cdbanchq = 1    THEN
                                              aux_nrctachq = DEC(SUBSTR(aux_setlinha,16,08)).

                                        FIND LAST crapcst WHERE 
                                                  crapcst.cdcooper = crapcop.cdcooper AND
                                                  crapcst.cdcmpchq = aux_cdcmpchq     AND
                                                  crapcst.cdbanchq = aux_cdbanchq     AND
                                                  crapcst.cdagechq = aux_cdagechq     AND 
                                                  crapcst.nrctachq = aux_nrctachq     AND
                                                  crapcst.nrcheque = aux_nrcheque     AND
                                                  crapcst.dtdevolu = ?
                                                  EXCLUSIVE-LOCK NO-ERROR.
                                        
                                        IF AVAIL crapcst THEN
                                            crapcst.insitprv = 3.
                                        ELSE
                                            DO:
                                                IF  aux_cdbanchq = 1 THEN
                                                    aux_nrctachq = DEC(SUBSTR(aux_setlinha,13,11)).
                                                ELSE
                                                    aux_nrctachq = DEC(SUBSTR(aux_setlinha,12,12)).

                                                FIND LAST crapcst WHERE 
                                                          crapcst.cdcooper = crapcop.cdcooper AND
                                                          crapcst.cdcmpchq = aux_cdcmpchq     AND
                                                          crapcst.cdbanchq = aux_cdbanchq     AND
                                                          crapcst.cdagechq = aux_cdagechq     AND 
                                                          crapcst.nrctachq = aux_nrctachq     AND
                                                          crapcst.nrcheque = aux_nrcheque     AND
                                                          crapcst.dtdevolu = ?
                                                          EXCLUSIVE-LOCK NO-ERROR.
                                                  
                                                IF   AVAILABLE crapcst THEN
                                                     crapcst.insitprv = 3.
                                                ELSE 
                                                    DO:  
                                                        IF    aux_cdbanchq = 1    THEN
                                                              ASSIGN aux_nrctachq = DEC(SUBSTR(aux_setlinha,16,08)).
                
                                                        FIND  LAST   crapcdb WHERE
                                                                     crapcdb.cdcooper = crapcop.cdcooper AND
                                                                     crapcdb.cdcmpchq = aux_cdcmpchq     AND
                                                                     crapcdb.cdbanchq = aux_cdbanchq     AND
                                                                     crapcdb.cdagechq = aux_cdagechq     AND
                                                                     crapcdb.nrctachq = aux_nrctachq     AND
                                                                     crapcdb.nrcheque = aux_nrcheque     AND
                                                                     crapcdb.dtdevolu = ?
                                                                     EXCLUSIVE-LOCK NO-ERROR.
                                                        
                                                        IF   AVAILABLE crapcdb THEN
                                                             ASSIGN crapcdb.insitprv = 3.
                                                        ELSE
                                                             DO:
                                                                IF   aux_cdbanchq = 1 THEN
                                                                     aux_nrctachq = DEC(SUBSTR(aux_setlinha,13,11)).
                                                                ELSE
                                                                    aux_nrctachq =  DEC(SUBSTR(aux_setlinha,12,12)).
                                            
                                                                FIND LAST crapcdb WHERE
                                                                          crapcdb.cdcooper = crapcop.cdcooper AND
                                                                          crapcdb.cdcmpchq = aux_cdcmpchq     AND
                                                                          crapcdb.cdbanchq = aux_cdbanchq     AND
                                                                          crapcdb.cdagechq = aux_cdagechq     AND
                                                                          crapcdb.nrctachq = aux_nrctachq     AND
                                                                          crapcdb.nrcheque = aux_nrcheque     AND
                                                                          crapcdb.dtdevolu = ?
                                                                          EXCLUSIVE-LOCK NO-ERROR.
                                                                                         
                                                                IF   AVAILABLE crapcdb THEN
                                                                     ASSIGN crapcdb.insitprv = 3.
                                                             END.     
                                                    END.
                                            END.
                                    END.         
                         END.
                END.
        
        END. /* FIM do DO WHILE TRUE TRANSACTION */

        INPUT STREAM str_2 CLOSE.

        UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " +
                           aux_dscooper + "salvar/truncagem").

    END. /* END do FOR EACH crawarq */

END PROCEDURE.

/*............................................................................*/
