/*..............................................................................

   Programa: fontes/crps566.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Abril/2010                         Ultima atualizacao: 13/01/2014

   Dados referentes ao programa:

   Frequencia: Diario. (Batch).
   Objetivo  : Fonte baseado no crps485
               Tratar arquivo CAF501 - CADASTRO DE MUNICIPIOS E FERIADOS.
               Atualizar tabelas crapcaf e crapfsf.

   Alteracoes: 13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 

..............................................................................*/

{ includes/var_batch.i {1} } 
                          
DEF STREAM str_1.
DEF STREAM str_2.

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

DEF  VAR aux_ano       AS INT                                          NO-UNDO.
DEF  VAR aux_mes       AS INT                                          NO-UNDO.
DEF  VAR aux_dia       AS INT                                          NO-UNDO.
DEF  VAR aux_posicao   AS INT                                          NO-UNDO.
DEF  VAR aux_postpfer  AS INT                                          NO-UNDO.
DEF  VAR aux_dtferiad  AS DATE                                         NO-UNDO.
DEF  VAR aux_tpferiad  AS INT    FORMAT "z9"                           NO-UNDO.


ASSIGN glb_cdprogra = "crps566".



RUN fontes/iniprg.p.
                          
IF  glb_cdcritic > 0  THEN
    RETURN.                  

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop  THEN
     DO:
         ASSIGN glb_cdcritic = 651.
         RUN fontes/critic.p.
         
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
        
         RUN fontes/fimprg.p.
         RETURN.
     END.



ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                      "/abbc/CAF501*".  
 
INPUT STREAM str_1 
             THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

    ASSIGN aux_nmarqdat = "integra/CAF501" +
                          STRING(DAY(glb_dtmvtolt),"99") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(YEAR(glb_dtmvtolt),"9999").
   
    
  
    UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                       aux_nmarqdat + " 2> /dev/null"). 

    
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv ).                    

     
    INPUT STREAM str_2 FROM VALUE(aux_nmarqdat) NO-ECHO.

    /* Pula Header */ 
    IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

    IF SUBSTR(aux_setlinha,7,6) <> "CAF501" THEN DO:
       ASSIGN glb_cdcritic = 173.
       RUN fontes/critic.p.

       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         glb_dscritic + " >> log/proc_batch.log").
       
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
                               " - " + glb_cdprogra + "' --> '"  +
                               glb_dscritic + " >> log/proc_batch.log").

             RUN fontes/fimprg.p.
             RETURN.                
         END.

        DO  WHILE TRUE:    

            FIND crapcaf WHERE crapcaf.cdcidade = aux_cdcidade 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crapcaf  THEN DO:
                IF  LOCKED crapcaf THEN DO:
                      PAUSE 2 NO-MESSAGE.
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
                        PAUSE 2 NO-MESSAGE.
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

/*    UNIX SILENT VALUE("mv " + aux_nmarqdat + " salvar").   */
    
    INPUT STREAM str_2 CLOSE.
                                                       
END. /*** Fim do DO WHILE TRUE ***/

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
