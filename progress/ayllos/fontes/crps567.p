/*..............................................................................

   Programa: fontes/crps567.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Abril/2010                         Ultima atualizacao: 22/09/2016

   Dados referentes ao programa:

   Frequencia: Diario. (Batch)
   Objetivo  : Fonte baseado no crps487
               Tratar arquivo CAF502 - CADASTRO DE BANCOS E AGENCIAS.
               Atualizar tabela crapagb e crapban.

   Alteracoes:  14/03/2013 - verificar a situação da Agência na importação 
                             do CAF502 (Daniele).
                
                13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
                09/04/2014 - Ajuste no tratamento da importacao CAF (Ze). 
                
                18/01/2016 - Quando encontrar agencia de codigo "9999" desativar
                             todas as agencias do banco correspondente
                             (Douglas - Chamado 361760)
                             
                22/09/2016 - Ajuste para não desativar o banco 7 - BNDS, conforme
                             solicitado no chamado 507147. (Kelvin)
..............................................................................*/

{ includes/var_batch.i {1} }
                         
DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.

DEF VAR aux_cdbccxlt AS INT  FORMAT "999"                              NO-UNDO.
DEF VAR aux_nmdbanco AS CHAR FORMAT "x(50)"                            NO-UNDO.
DEF VAR aux_cdageban AS INT  FORMAT "zzz9"                             NO-UNDO.
DEF VAR aux_nmageban AS CHAR FORMAT "x(30)"                            NO-UNDO.
DEF VAR aux_cdcidade AS INT  FORMAT "999999"                           NO-UNDO.
DEF VAR aux_cdsitagb AS CHAR FORMAT "x(1)"                             NO-UNDO.
DEF VAR aux_nrcnpjag AS DEC  FORMAT "99999999999999"                   NO-UNDO.

ASSIGN glb_cdprogra = "crps567".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop  THEN DO:
     ASSIGN glb_cdcritic = 651.
     RUN fontes/critic.p.

     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                       " - " + glb_cdprogra + "' --> '"  +
                       glb_dscritic + " >> log/proc_batch.log").
    
     RUN fontes/fimprg.p.
     RETURN.
END.

ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                      "/abbc/*CAF502*".

INPUT STREAM str_1 
             THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

    ASSIGN aux_nmarqdat = "integra/CAF502" +
                          STRING(DAY(glb_dtmvtolt),"99") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(YEAR(glb_dtmvtolt),"9999").

    UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                      aux_nmarqdat + " 2> /dev/null").

    UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

    INPUT STREAM str_2 FROM VALUE(aux_nmarqdat) NO-ECHO.

    /* Pula Header */ 
    IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

    IF SUBSTR(aux_setlinha,8,6) <> "CAF502" THEN DO: 
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

        ASSIGN aux_cdbccxlt = INTE(SUBSTR(aux_setlinha,1,3)) 
               aux_nmdbanco = SUBSTR(aux_setlinha,8,50) 
               aux_cdageban = INTE(SUBSTR(aux_setlinha,4,4)) 
               aux_nmageban = SUBSTR(aux_setlinha,58,30)
               aux_cdcidade = INTE(SUBSTR(aux_setlinha,102,6))
               aux_cdsitagb = SUBSTR(aux_setlinha,148,1)
               aux_nrcnpjag = DECI(SUBSTR(aux_setlinha,88,14)).

        IF   aux_cdbccxlt = 0   THEN DO: 
             ASSIGN glb_dscritic = "Arquivo importado - " + 
                                   aux_nmarqdat + " - esta corrompido.".

             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '"  +
                               glb_dscritic + " >> log/proc_batch.log").

             RUN fontes/fimprg.p.
             RETURN.                
         END.

         DO WHILE TRUE:    

            FIND crapban WHERE crapban.cdbccxlt = aux_cdbccxlt 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL crapban  THEN DO:
                IF  LOCKED crapban THEN DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                      
               
                  END.
           
     
                CREATE crapban.
                ASSIGN crapban.cdbccxlt = aux_cdbccxlt.
             END.
 
            ASSIGN crapban.nmresbcc = aux_nmdbanco
                   crapban.nmextbcc = aux_nmdbanco
                   crapban.dtmvtolt = glb_dtmvtolt
                   crapban.cdoperad = glb_cdoperad.
            VALIDATE crapban.
            LEAVE.
 
         END.    /** Fim do WHILE TRUE **/               
        
         DO WHILE TRUE:      
 
            FIND crapagb WHERE crapagb.cdageban = aux_cdageban AND
                               crapagb.cddbanco = aux_cdbccxlt
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
 
            IF  NOT AVAIL crapagb THEN DO:
                IF  LOCKED crapagb THEN DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                END.
                           
                CREATE crapagb.
                ASSIGN crapagb.cdageban = aux_cdageban
                       crapagb.cddbanco = aux_cdbccxlt
                       crapagb.nmageban = aux_nmageban 
                       crapagb.cdcidade = aux_cdcidade                
                       crapagb.nrcnpjag = aux_nrcnpjag
                       crapagb.cdsitagb = aux_cdsitagb 
                       crapagb.dtmvtolt = glb_dtmvtolt 
                       crapagb.cdoperad = glb_cdoperad.
                VALIDATE crapagb.
            END.        
            ELSE DO:
                IF   crapagb.cdsitagb <> aux_cdsitagb AND
                     crapagb.cddbanco <> 7 THEN /*Nao faz para o banco 7 - BNDS*/
                     ASSIGN crapagb.cdsitagb = aux_cdsitagb
                            crapagb.dtmvtolt = glb_dtmvtolt 
                            crapagb.cdoperad = glb_cdoperad.

                IF   crapagb.nrcnpjag <> aux_nrcnpjag   THEN
                     ASSIGN crapagb.nrcnpjag = aux_nrcnpjag
                            crapagb.dtmvtolt = glb_dtmvtolt 
                            crapagb.cdoperad = glb_cdoperad.

                IF   crapagb.cdcidade <> aux_cdcidade   THEN 
                     ASSIGN crapagb.cdcidade = aux_cdcidade
                            crapagb.dtmvtolt = glb_dtmvtolt 
                            crapagb.cdoperad = glb_cdoperad.

                IF   crapagb.nmageban <> aux_nmageban   THEN   
                     ASSIGN crapagb.nmageban = aux_nmageban
                            crapagb.dtmvtolt = glb_dtmvtolt 
                            crapagb.cdoperad = glb_cdoperad.
            END.    

            LEAVE.

         END. /*** Fim do DO WHILE TRUE ***/
         
         /*Nao faz para o banco 7*/
         IF aux_cdbccxlt <> 7 THEN
            DO:
         /* Se a agencia em questao eh "9999" */
         IF aux_cdageban = 9999 THEN
         DO:
             FOR EACH crapagb WHERE crapagb.cddbanco = aux_cdbccxlt
                              EXCLUSIVE-LOCK:
                 /* desativar todas as agencias do banco */
                 ASSIGN crapagb.cdsitagb = "N".
             END.
         END.
    END.                 
    END.                 

    UNIX SILENT VALUE("mv " + aux_nmarqdat + " salvar").

    INPUT STREAM str_2 CLOSE.

END. /*** Fim do DO WHILE TRUE ***/

INPUT STREAM str_1 CLOSE.

RUN fontes/fimprg.p.                   

/*............................................................................*/

