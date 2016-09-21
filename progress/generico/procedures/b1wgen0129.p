/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+-----------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL               |
  +------------------------------------------+-----------------------------------+
  | sistema/generico/procedures/b1wgen0129.p | TABE0001                          |
  |      busca_tab030                        |    .pc_busca_tab030               |
  +------------------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/


/*.............................................................................

Programa: sistema/generico/procedures/b1wgen0129.p
Autor   : Lucas
Data    : Novembro/2011               Ultima Atualizacao: 22/04/2013
 
Dados referentes ao programa:

Objetivo  : BO referente a tela TAB030
             
Alteracoes: 25/05/2012 - Incluido campo diasatrs(dias atraso para relatorio)
                         (Tiago).
                         
            15/06/2012 - Alterado para gravar diasatrs apenas para respectiva
                         cooperativa.            
                         
            22/04/2013 - Ajuste para a inclusao do parametro "Dias atraso
                         para inadimplencia" ( Adriano ).             
                          
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
  Carregar os dados gravados na TAB030 
******************************************************************************/

PROCEDURE busca_tab030:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/
   DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.

   DEF OUTPUT PARAM par_vllimite AS DEC                               NO-UNDO.
   DEF OUTPUT PARAM par_vlsalmin AS DEC                               NO-UNDO.
   DEF OUTPUT PARAM par_diasatrs AS INT                               NO-UNDO.
   DEF OUTPUT PARAM par_atrsinad AS INT                               NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF  VAR aux_dstextab         AS CHAR                              NO-UNDO.
      
   FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "USUARI"       AND
                      craptab.cdempres = 11             AND
                      craptab.cdacesso = "RISCOBACEN"   AND
                      craptab.tpregist = 000           
                      NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab   THEN
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
    ELSE 
        DO:
           ASSIGN aux_dstextab = craptab.dstextab
                  par_vllimite = DECIMAL(SUBSTRING(aux_dstextab,3,9))
                  par_vlsalmin = DECIMAL(SUBSTRING(aux_dstextab,13,11))
                  par_diasatrs = INTEGER(SUBSTRING(aux_dstextab,25,3))
                  par_atrsinad = INTEGER(SUBSTRING(aux_dstextab,29,4)).
                       
           RETURN "OK".

        END.

   RELEASE craptab.

END PROCEDURE.

/* Fim da Procedure */

/*****************************************************************************
  Alterar os dados gravados na TAB030 
******************************************************************************/

PROCEDURE altera_tab030:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dstextab AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdepart AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vllimite AS DEC                            NO-UNDO.
    DEF  INPUT PARAM par_vlsalmin AS DEC                            NO-UNDO.
    DEF  INPUT PARAM par_diasatrs AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_atrsinad AS INT                            NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dstextab          AS CHAR                          NO-UNDO.
    DEF  VAR aux_flgtrans          AS LOGI                          NO-UNDO.
    DEF  VAR log_dstextab          AS DEC EXTENT 4                  NO-UNDO.
    DEF  VAR aux_msgdolog          AS CHAR                          NO-UNDO.


    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad    
                       NO-LOCK NO-ERROR.

    IF  NOT CAN-DO("TI,PRODUTOS",par_dsdepart)  THEN
        DO:
            ASSIGN aux_cdcritic = 36.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    ASSIGN aux_dscritic = ""
           aux_flgtrans = FALSE.
    
    
    EMPTY TEMP-TABLE tt-erro.

    /* Adquire valor anterior para o LOG */

    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "USUARI"       AND
                       craptab.cdempres = 11             AND
                       craptab.cdacesso = "RISCOBACEN"   AND
                       craptab.tpregist = 000            
                       NO-LOCK NO-ERROR.

    ASSIGN aux_dstextab    = craptab.dstextab
           log_dstextab[1] = DEC(SUBSTRING(aux_dstextab,3,9))
           log_dstextab[2] = DEC(SUBSTRING(aux_dstextab,13,11))
           log_dstextab[3] = DEC(SUBSTRING(aux_dstextab,25,3))
           log_dstextab[4] = DEC(SUBSTRING(aux_dstextab,29,4)).

    RELEASE craptab.
            
    TRANS_TAB:
    DO  TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                    ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB:
               
        DO  aux_contador = 1 TO 10:
            
            ASSIGN aux_cdcritic = 0.
            
            FOR EACH crapcop NO-LOCK:
                
                DO  WHILE TRUE:
                       
                    FIND craptab WHERE 
                         craptab.cdcooper = crapcop.cdcooper   AND
                         craptab.nmsistem = "CRED"             AND
                         craptab.tptabela = "USUARI"           AND
                         craptab.cdempres = 11                 AND
                         craptab.cdacesso = "RISCOBACEN"       AND
                         craptab.tpregist = 0
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
              

                    IF  NOT AVAILABLE craptab   THEN
                        DO:
                            
                            IF  LOCKED craptab   THEN
                                DO:
                                    /*PAUSE 2 NO-MESSAGE.*/
                                    ASSIGN aux_contador = aux_contador + 1
                                           aux_cdcritic = 77.
                                    NEXT.
                                END.

                            ELSE
                                DO:
                                    ASSIGN aux_cdcritic = 55.
                                END.

                        END.
                    
                    LEAVE.
                  
                END.  /*  Fim do DO WHILE TRUE  */
                  
                IF  aux_cdcritic > 0 OR 
                    aux_dscritic <> ""  THEN
                    UNDO TRANS_TAB, LEAVE TRANS_TAB.
                              

                ASSIGN SUBSTR(craptab.dstextab,3,9)   = STRING(par_vllimite,"999999.99")             
                       SUBSTR(craptab.dstextab,13,11) = STRING(par_vlsalmin,"zzzz,zz9.99").

                IF  par_cdcooper = crapcop.cdcooper THEN
                    ASSIGN SUBSTR(craptab.dstextab,25,3)  = STRING(par_diasatrs,"zz9")
                           SUBSTR(craptab.dstextab,29,4)  = STRING(par_atrsinad,"zzz9").

            END.
        END.  
            
        IF  aux_cdcritic > 0   THEN
            UNDO, NEXT.

        FIND CURRENT craptab NO-LOCK NO-ERROR.
        RELEASE craptab.
        ASSIGN  aux_flgtrans = TRUE.

    END.  /*  Fim do DO TRANSACTION  */

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK.
    
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
                    UNIX SILENT VALUE 
                        ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")  +
                         " - "        +   STRING(TIME,"HH:MM:SS")            +
                         " Operador:"  + " " + par_cdoperad                  +
                         " --- Nao conseguiu gravar as alteracoes."          +
                         " >> /usr/coop/" + TRIM(crapcop.dsdircop)           +
                         "/log/tab030.log").   
                END.                                                            
            
            RETURN "NOK".
        END.

    IF  par_vllimite <> log_dstextab[1] THEN
        ASSIGN aux_msgdolog = "Alterou o Valor a ser Desconsiderado [Arrasto]"+
                              "de " + STRING(log_dstextab[1],"zz,zzz,zz9.99") + 
                              " para " + STRING(par_vllimite,"zz,zzz,zz9.99") + 
                              ".".

    IF  par_vlsalmin <> log_dstextab[2] THEN
        ASSIGN aux_msgdolog = aux_msgdolog + " Alterou o Valor do "           + 
                              "Salario Minimo de " + STRING(log_dstextab[2])  + 
                              " para " + STRING(par_vlsalmin,"zz,zzz,zz9.99") + 
                              ".".

    IF  par_diasatrs <> log_dstextab[3] THEN
        ASSIGN  aux_msgdolog = aux_msgdolog + " Alterou o Valor do "           + 
                              "Dias atraso para relatorio de "                 + 
                              STRING(log_dstextab[3])                          + 
                              " para " + STRING(par_diasatrs,"zz9")            + 
                              ".".

    IF  par_atrsinad <> log_dstextab[4] THEN
        ASSIGN  aux_msgdolog = aux_msgdolog + " Alterou o Valor do "           + 
                              "Dias atraso para inadimplencia "                + 
                              STRING(log_dstextab[4])                          + 
                              " para " + STRING(par_atrsinad,"zzz9")           + 
                              ".".


     /* Grava LOG (Sucesso) */ 
    IF  par_flgerlog THEN 
        DO:
           IF  par_vllimite <> log_dstextab[1] OR 
               par_vlsalmin <> log_dstextab[2] OR 
               par_diasatrs <> log_dstextab[3] OR 
               par_atrsinad <> log_dstextab[4] THEN
               DO:           
                   UNIX SILENT VALUE 
                   ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")   +
                   " - "         +   STRING(TIME,"HH:MM:SS")             +
                   " Operador: "  + par_cdoperad + " --- "               +
                   aux_msgdolog                                          +
                   " >> /usr/coop/" + TRIM(crapcop.dsdircop)             +
                   "/log/tab030.log").

               END.

        END.

    RETURN "OK".

END PROCEDURE. 

/* Fim da Procedure */

/*****************************************************************************
  Fim da b1wgen0129.p 
******************************************************************************/
