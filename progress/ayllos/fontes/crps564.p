/*..............................................................................

   Programa: fontes/crps564.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Abril/2010                         Ultima atualizacao: 22/09/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Fonte baseado no crps472
               Tratar arquivo CAF501 - CADASTRO DE MUNICIPIOS E FERIADOS.
               Atualizar tabelas crapcaf e crapfsf.

   Alteracoes: 07/07/2010 - Acerto para ler arquivo com referencia na CECRED
                            (Guilherme).
               
               13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)  
                            
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)            

..............................................................................*/

{ includes/var_online.i }
                          
DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.

DEF VAR aux_cdcidade AS INT      FORMAT "999999"                       NO-UNDO.
DEF VAR aux_nmcidade AS CHAR     FORMAT "x(38)"                        NO-UNDO.
DEF VAR aux_cdufresd AS CHAR     FORMAT "!(2)"                         NO-UNDO.
DEF VAR aux_incapint AS INT      FORMAT "9"                            NO-UNDO.
DEF VAR aux_fcacesso AS CHAR     FORMAT "!"                            NO-UNDO.
DEF VAR aux_fctpcomp AS INT      FORMAT "9"                            NO-UNDO.
DEF VAR aux_cdcompen AS INT      FORMAT "999"                          NO-UNDO.
DEF VAR aux_nmcompen AS CHAR     FORMAT "x(30)"                        NO-UNDO.
DEF VAR aux_dscooper AS CHAR                                           NO-UNDO.

DEF  VAR aux_ano       AS INT                                          NO-UNDO.
DEF  VAR aux_mes       AS INT                                          NO-UNDO.
DEF  VAR aux_dia       AS INT                                          NO-UNDO.
DEF  VAR aux_posicao   AS INT                                          NO-UNDO.
DEF  VAR aux_postpfer  AS INT                                          NO-UNDO.
DEF  VAR aux_dtferiad  AS DATE                                         NO-UNDO.
DEF  VAR aux_tpferiad  AS INT    FORMAT "z9"                           NO-UNDO.

DEF  VAR aux_dadosusr AS CHAR                                          NO-UNDO.
DEF  VAR par_loginusr AS CHAR                                          NO-UNDO.
DEF  VAR par_nmusuari AS CHAR                                          NO-UNDO.
DEF  VAR par_dsdevice AS CHAR                                          NO-UNDO.
DEF  VAR par_dtconnec AS CHAR                                          NO-UNDO.
DEF  VAR par_numipusr AS CHAR                                          NO-UNDO.
DEF  VAR h-b1wgen9999 AS HANDLE                                        NO-UNDO.

    
ASSIGN glb_cdprogra = "crps564"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.

/*............................................................................*/
FOR EACH crapcop
   WHERE crapcop.cdcooper = 3 NO-LOCK:

    ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

    ASSIGN aux_nmarqlog = "log/prcctl_" +
                          STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99") + ".log".

    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                          "/abbc/*CAF501*".
     
    INPUT STREAM str_1 
         THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

        ASSIGN aux_nmarqdat = aux_dscooper + "integra/CAF501" +
                              STRING(DAY(glb_dtmvtolt),"99") +
                              STRING(MONTH(glb_dtmvtolt),"99") +
                              STRING(YEAR(glb_dtmvtolt),"9999").

        UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                          aux_nmarqdat + " 2> /dev/null").

        UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

        INPUT STREAM str_2 FROM VALUE(aux_nmarqdat) NO-ECHO.
        
        /* Pula Header */ 
        IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

        IF SUBSTR(aux_setlinha,7,6) <> "CAF501" THEN DO:
           ASSIGN glb_cdcritic = 173.
           RUN fontes/critic.p.

            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - Coop:" + STRING(crapcop.cdcooper,"99") +
                              " - Processar: CAF501" +
                              " - " + glb_cdprogra + "' --> '"  +
                              glb_dscritic + " >> " + aux_nmarqlog).

           RUN fontes/fimprg.p.
           RETURN.       
        END.

        DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

            IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

            /*  Verifica se eh final do Arquivo  */
            IF   INT(SUBSTR(aux_setlinha,1,1)) = 9  THEN
                 LEAVE.

            ASSIGN aux_cdcidade = INT(SUBSTR(aux_setlinha,1,6))
                   aux_nmcidade = SUBSTRING(aux_setlinha,7,38)
                   aux_cdufresd = SUBSTRING(aux_setlinha,45,2)
                   aux_incapint = INT(SUBSTRING(aux_setlinha,47,1))
                   aux_fcacesso = SUBSTRING(aux_setlinha,48,1)
                   aux_fctpcomp = INT(SUBSTRING(aux_setlinha,49,1))
                   aux_cdcompen = INT(SUBSTRING(aux_setlinha,50,3))
                   aux_nmcompen = SUBSTRING(aux_setlinha,53,30).

            IF   aux_cdcidade = 0   THEN DO:
                 ASSIGN glb_dscritic = "Arquivo importado - " + 
                                       aux_nmarqdat + " - esta corrompido.".

                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - Coop:" + STRING(crapcop.cdcooper,"99") +
                                   " - Processar: CAF501" +
                                   " - " + glb_cdprogra + "' --> '"  +
                                   glb_dscritic + " >> " + aux_nmarqlog).

                 RUN fontes/fimprg.p.
                 RETURN.                
            END.

            DO  WHILE TRUE:    

                FIND crapcaf WHERE crapcaf.cdcidade = aux_cdcidade 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crapcaf  THEN DO:
                    IF  LOCKED crapcaf THEN DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapcaf),
                        					 INPUT "banco",
                        					 INPUT "crapcaf",
                        					 OUTPUT par_loginusr,
                        					 OUTPUT par_nmusuari,
                        					 OUTPUT par_dsdevice,
                        					 OUTPUT par_dtconnec,
                        					 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                        			  " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        NEXT.

                    END.

                    CREATE crapcaf.
                    ASSIGN crapcaf.cdcidade = aux_cdcidade.
                END.

                ASSIGN  crapcaf.nmcidade = aux_nmcidade
                        crapcaf.cdufresd = aux_cdufresd
                        crapcaf.incapint = aux_incapint
                        crapcaf.fcacesso = aux_fcacesso
                        crapcaf.fctpcomp = aux_fctpcomp
                        crapcaf.cdcompen = aux_cdcompen
                        crapcaf.nmcompen = aux_nmcompen
                        crapcaf.dtmvtolt = glb_dtmvtolt.
                VALIDATE crapcaf.
                LEAVE.

            END.    /** Fim do WHILE TRUE **/
            
            /** Posicao dos campos no arquivo **/
            ASSIGN  aux_posicao  = 151
                    aux_dia      = 157
                    aux_mes      = 155
                    aux_ano      = 151
                    aux_postpfer = 159.

            DO  WHILE TRUE:
                IF  SUBSTRING(aux_setlinha,aux_posicao,1) <> "" THEN DO:

                    ASSIGN aux_dtferiad = DATE(SUBSTR(aux_setlinha,aux_dia,2) + 
                                          "/" +  
                                          SUBSTR(aux_setlinha,aux_mes,2)      +
                                          "/" +  
                                          SUBSTR(aux_setlinha,aux_ano,4))
                           aux_tpferiad = 
                                      INT(SUBSTR(aux_setlinha,aux_postpfer,1)).

                    FIND crapfsf WHERE  crapfsf.cdcidade = aux_cdcidade AND
                                        crapfsf.dtferiad = aux_dtferiad
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAIL crapfsf THEN DO:
                        IF  LOCKED crapcaf THEN DO:
                            RUN sistema/generico/procedures/b1wgen9999.p
                            PERSISTENT SET h-b1wgen9999.
                            
                            RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapcaf),
                            					 INPUT "banco",
                            					 INPUT "crapcaf",
                            					 OUTPUT par_loginusr,
                            					 OUTPUT par_nmusuari,
                            					 OUTPUT par_dsdevice,
                            					 OUTPUT par_dtconnec,
                            					 OUTPUT par_numipusr).
                            
                            DELETE PROCEDURE h-b1wgen9999.
                            
                            ASSIGN aux_dadosusr = 
                            "077 - Tabela sendo alterada p/ outro terminal.".
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            MESSAGE aux_dadosusr.
                            PAUSE 3 NO-MESSAGE.
                            LEAVE.
                            END.
                            
                            ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                            			  " - " + par_nmusuari + ".".
                            
                            HIDE MESSAGE NO-PAUSE.
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            MESSAGE aux_dadosusr.
                            PAUSE 5 NO-MESSAGE.
                            LEAVE.
                            END.
                            
							NEXT.

                        END.
                        RUN cria_crapfsf. 
                    END.
                    ELSE
                        ASSIGN crapfsf.dtmvtolt = glb_dtmvtolt
                               crapfsf.dtdbaixa = ?.

                    ASSIGN aux_posicao = aux_posicao + 9
                           aux_dia = aux_dia + 9
                           aux_mes = aux_mes + 9
                           aux_ano = aux_ano + 9
                           aux_postpfer = aux_postpfer + 9.
                END.
                ELSE
                    LEAVE.
            END.


        END. /*** Fim do DO WHILE TRUE ***/

        FOR EACH crapfsf WHERE crapfsf.dtmvtolt <> glb_dtmvtolt  
                               EXCLUSIVE-LOCK :

            ASSIGN crapfsf.dtdbaixa = glb_dtmvtolt.

        END.


        UNIX SILENT VALUE("mv " + aux_nmarqdat + " " + aux_dscooper + "salvar").

        UNIX SILENT VALUE("rm " + aux_nmarqdat + " 2> /dev/null").

        INPUT STREAM str_2 CLOSE.

    END. /*** Fim do DO WHILE TRUE ***/
    
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - Processar: CAF501" +
                      " - " + glb_cdprogra + "' --> '"  +
                      " Arquivo integrado com sucesso! >> " + aux_nmarqlog).    

END. /** END do FOR EACH da CRAPCOP **/

INPUT STREAM str_1 CLOSE.


RUN fontes/fimprg.p.                   


PROCEDURE cria_crapfsf:

    CREATE crapfsf.
    
    ASSIGN  crapfsf.cdcidade = aux_cdcidade
            crapfsf.dtferiad = aux_dtferiad   
            crapfsf.tpferiad = aux_tpferiad
            crapfsf.dtmvtolt = glb_dtmvtolt.
    VALIDATE crapfsf.

END PROCEDURE.


/*............................................................................*/
