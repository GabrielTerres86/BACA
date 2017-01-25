/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0130.p
    Autor   : Lucas
    Data    : Novembro/2011               Ultima Atualizacao:
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela TAB002
                 
    Alteracoes: 06/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)

.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

/*****************************************************************************
  Carregar os dados gravados na TAB002 
******************************************************************************/
PROCEDURE busca_tab002:
            
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtfolind AS INT                            NO-UNDO.
    DEF OUTPUT PARAM par_qtfolcjt AS INT                            NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "USUARI"       AND
                       craptab.cdempres = 00             AND
                       craptab.cdacesso = "ACOMPTALAO"   AND
                       craptab.tpregist = 001
                       NO-LOCK NO-ERROR NO-WAIT.
    
    IF  AVAILABLE craptab   THEN
        DO:
            ASSIGN par_qtfolind = INTEGER(SUBSTRING(craptab.dstextab,1,3))
                   par_qtfolcjt = INTEGER(SUBSTRING(craptab.dstextab,5,3)).
                                    
            RETURN "OK".                          
        END.
    ELSE
        DO:
            ASSIGN aux_cdcritic = 55.
             
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".                      
        END.
    
END PROCEDURE.

/*****************************************************************************
  Alterar os dados gravados na TAB002 
******************************************************************************/
PROCEDURE altera_tab002:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtfolind AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_qtfolcjt AS INT                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgtrans          AS LOGI                          NO-UNDO.
    DEF  VAR log_dstextab          AS DEC EXTENT 2                  NO-UNDO.
    DEF  VAR aux_msgdolog          AS CHAR                          NO-UNDO.
    DEF  VAR aux_valanter          AS CHAR                          NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    FIND crapope WHERE crapope.cdcooper = par_cdcooper   AND
                       crapope.cdoperad = par_cdoperad    
                       NO-LOCK NO-ERROR.

    TRANS_TAB:
    DO TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                   ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB:

        DO  aux_contador = 1 TO 10:
            
            ASSIGN aux_cdcritic = 0.

            FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 00             AND
                               craptab.cdacesso = "ACOMPTALAO"   AND
                               craptab.tpregist = 001
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craptab   THEN
                IF  LOCKED craptab   THEN
                    DO:
                        ASSIGN aux_contador = aux_contador + 1
                               aux_cdcritic = 77.
                        LEAVE.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 55.
                        LEAVE.
                    END.
        END.

        IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN
            UNDO TRANS_TAB, LEAVE TRANS_TAB.

        /* Armazena Valores anteriores para o LOG */ 
        ASSIGN aux_valanter    = craptab.dstextab
               log_dstextab[1] = DEC(SUBSTRING(aux_valanter,1,3))
               log_dstextab[2] = DEC(SUBSTRING(aux_valanter,5,3)).
  
        IF  AVAIL craptab THEN
            DO:
                
                ASSIGN  SUBSTRING(craptab.dstextab,1,3) = STRING(par_qtfolind,"999")
                        SUBSTRING(craptab.dstextab,5,3) = STRING(par_qtfolcjt,"999").
            END.    
    
        RELEASE craptab.
        ASSIGN aux_flgtrans = TRUE.

    END. /* Fim da transacao */

    IF  NOT aux_flgtrans THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel atualizar os valores.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                DO:
                    UNIX SILENT VALUE ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")     +
                                       " - "        +   STRING(TIME,"HH:MM:SS")               +
                                       " Operador:" + " " + par_cdoperad                      +
                                       " --- " + aux_dscritic            +
                                       " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
                                       "/log/tab002.log").
                END.                                                            

            RETURN "NOK".
        END.

    IF par_qtfolind <> log_dstextab[1] THEN
        ASSIGN aux_msgdolog = "Alterou a Qtd. de Folhas para Contas Individuais de " + STRING(log_dstextab[1],"zz9") + " para " + STRING(par_qtfolind,"zz9") + ".".

    IF par_qtfolcjt <> log_dstextab[2] THEN
        ASSIGN aux_msgdolog = aux_msgdolog + " Alterou Qtd. de Folhas para Contas Conjutas de " + STRING(log_dstextab[2],"zz9") + " para " + STRING(par_qtfolcjt,"zz9") + ".".

    IF  par_flgerlog  THEN 
        DO:
            IF par_qtfolind <> log_dstextab[1] OR 
               par_qtfolcjt <> log_dstextab[2] THEN
                DO:   
                    UNIX SILENT VALUE ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")     +
                                       " - "        +   STRING(TIME,"HH:MM:SS")               +
                                       " Operador: "  + par_cdoperad + " --- "                +
                                              aux_msgdolog                                    +
                                       " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
                                       "/log/tab002.log").
                END.
        END.
    
    RETURN "OK".

END PROCEDURE. 

/*****************************************************************************
   Deletar registro da Cooperativa na TAB002  
******************************************************************************/
PROCEDURE deleta_tab002:
                
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VARIABLE aux_flgtrans     AS LOGI                           NO-UNDO.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    FIND crapope WHERE crapope.cdcooper = par_cdcooper   AND
                       crapope.cdoperad = par_cdoperad    
                       NO-LOCK NO-ERROR.

    EMPTY TEMP-TABLE tt-erro.

    TRANS_TAB:
    DO TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                   ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB:
            
        DO  aux_contador = 1 TO 10:
            
            ASSIGN aux_cdcritic = 0.

            FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                               craptab.nmsistem = "CRED"        AND
                               craptab.tptabela = "USUARI"      AND
                               craptab.cdempres = 00            AND
                               craptab.cdacesso = "ACOMPTALAO"  AND
                               craptab.tpregist = 001         
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craptab   THEN
                IF  LOCKED craptab   THEN
                    DO:
                        ASSIGN aux_contador = aux_contador + 1
                               aux_cdcritic = 77.
                        NEXT.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 55.
                        LEAVE.
                    END.
        END.

        IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN
            UNDO TRANS_TAB, LEAVE TRANS_TAB.

        DELETE craptab.

        RELEASE craptab.

        ASSIGN aux_flgtrans = TRUE.

    END. /* Fim da transacao */
    
    IF  NOT aux_flgtrans THEN
        DO:
            
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel deletar a tabela.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                DO:
                    UNIX SILENT VALUE ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")    +
                                       " - "        +   STRING(TIME,"HH:MM:SS")              +
                                       " Operador:"  + " " + par_cdoperad                    +
                                       " --- " + aux_dscritic                +
                                       " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                                       "/log/tab002.log").
                END.                                                            

            RETURN "NOK".

        END.
                        
    IF  par_flgerlog  THEN 
        DO:
            UNIX SILENT VALUE ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")    +
                               " - "        +   STRING(TIME,"HH:MM:SS")              +
                               " Operador: "  + par_cdoperad                         + 
                               " --- Deletou a TAB002 com sucesso."                  +
                               " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                               "/log/tab002.log").
        END.
    
    RETURN "OK".

END PROCEDURE. 

/****************************************************************************
   Criar registro relativo a Cooperativa na TAB002  
******************************************************************************/
PROCEDURE cria_tab002:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtfolind AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_qtfolcjt AS INT                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dstextab         AS CHAR                           NO-UNDO.
    DEF  VAR aux_flgtrans         AS LOGI                           NO-UNDO.
    DEF  VAR aux_msgdolog         AS CHAR                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    FIND crapope WHERE crapope.cdcooper = par_cdcooper   AND
                       crapope.cdoperad = par_cdoperad    
                       NO-LOCK NO-ERROR.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "USUARI"       AND
                       craptab.cdempres = 00             AND
                       craptab.cdacesso = "ACOMPTALAO"   AND
                       craptab.tpregist = 001
                       NO-LOCK NO-ERROR NO-WAIT.

    IF  AVAILABLE craptab   THEN
        DO:
            ASSIGN aux_cdcritic = 56.
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                              
            RETURN "NOK".

        END.

    ASSIGN aux_dstextab = STRING(par_qtfolind,"999") + " " + STRING(par_qtfolcjt,"999").

    TRANS_TAB:
    DO TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                   ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB:
            
        CREATE craptab.

        ASSIGN craptab.nmsistem = "CRED"
               craptab.tptabela = "USUARI"
               craptab.cdempres = 00
               craptab.cdacesso = "ACOMPTALAO"
               craptab.tpregist = 001
               craptab.cdcooper = par_cdcooper
               craptab.dstextab = aux_dstextab.

        RELEASE craptab.

        ASSIGN aux_flgtrans = TRUE.

    END. /* Fim da transacao */

    ASSIGN aux_msgdolog = "Criou a TAB002 com sucesso, com Qtd. de Folhas para Contas Individuais = " + STRING(par_qtfolind) +
                           " e Qtd. de Folhas para Contas Conjutas = " + STRING(par_qtfolcjt) + ".".

    IF  NOT aux_flgtrans THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel criar a tabela.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            IF  par_flgerlog THEN
                DO:
                    UNIX SILENT VALUE ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")     +
                                       " - "        +   STRING(TIME,"HH:MM:SS")               +
                                       " Operador:"  + " " + par_cdoperad                     +
                                       " --- " + aux_dscritic                  +
                                       " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
                                       "/log/tab002.log").
                END.                                                                        

            RETURN "NOK".
       END.

    IF  par_flgerlog  THEN 
        DO:
            UNIX SILENT VALUE ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")     +
                               " - "        +   STRING(TIME,"HH:MM:SS")               +
                               " Operador: "  + par_cdoperad + " --- "                +
                                     aux_msgdolog                                     +
                               " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
                               "/log/tab002.log").
        END.

    RETURN "OK".

END PROCEDURE. 

/*****************************************************************************
  Fim da b1wgen0130.p 
******************************************************************************/
