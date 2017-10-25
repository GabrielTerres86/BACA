/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0106.p
    Autor   : Henrique
    Data    : Agosto/2011               Ultima Atualizacao: 08/09/2017
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela TAB042
                 
    Alteracoes: 07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)

				08/09/2017 - Removi validacao de departamento na procedure altera_tab042
							 Carlos Rafael Tanholi (SD 750528).
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
  Carregar os dados gravados na TAB 
******************************************************************************/
PROCEDURE busca_tab042:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_dstextab AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapope THEN
        DO:
            ASSIGN aux_cdcritic = 67.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /* Sequencia */  
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
                                                  
            RETURN "NOK".                             
        END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "LIBPRAZEMP"  AND
                       craptab.tpregist = 001           NO-LOCK NO-ERROR.


    IF  AVAIL craptab THEN
        DO:
            ASSIGN par_dstextab = craptab.dstextab.

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

END PROCEDURE. /* FIM busca_tab042 */

/*****************************************************************************
  Alterar os dados gravados na TAB 
******************************************************************************/
PROCEDURE altera_tab042:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dstextab AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.
    DEF VAR log_dstextab          AS CHAR                           NO-UNDO.
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper   AND
                       crapope.cdoperad = par_cdoperad    
                       NO-LOCK NO-ERROR.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Atualizar contas para validacao de prazo".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    EMPTY TEMP-TABLE tt-erro.

    TRANS_TAB:
    
    DO TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                   ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB:
        
        DO aux_contador = 1 TO 10:
            
            ASSIGN aux_cdcritic = 0.

            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "USUARI"     AND
                               craptab.cdempres = 11           AND
                               craptab.cdacesso = "LIBPRAZEMP" AND
                               craptab.tpregist = 001          
                               EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

            IF  NOT AVAILABLE craptab  THEN
                IF  LOCKED craptab  THEN
                    DO:
                        ASSIGN aux_contador = aux_contador + 1
                               aux_cdcritic = 77.
                        NEXT.
                    END. 
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 55.
                    END.
           
            LEAVE.
        END. /* FIM do DO ... TO */

        IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN
            UNDO TRANS_TAB, LEAVE TRANS_TAB.

        ASSIGN log_dstextab     = craptab.dstextab
               craptab.dstextab = par_dstextab.
        
        FIND CURRENT craptab NO-LOCK NO-ERROR.

        RELEASE craptab.

        ASSIGN aux_flgtrans = TRUE.

    END. /* FIM do TRANSACTION */

    IF  NOT aux_flgtrans THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel atualizar as contas.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            IF  par_flgerlog THEN
                DO:
                    UNIX SILENT VALUE 
                        ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")     +
                         " - "        +   STRING(TIME,"HH:MM:SS")               +
                         "Operador:"  + par_cdoperad                            +
                         "Nao conseguiu gravar as alteracoes"                   +
                         " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
                         "/log/tab042.log").
                END.                                                            
            
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN 
        DO:
            UNIX SILENT VALUE 
                ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")     +
                 " - "        +   STRING(TIME,"HH:MM:SS")               +
                 " Operador: "  + par_cdoperad + " --- "                +
                 " Alterou as contas de "                               +
                 log_dstextab + " para " + par_dstextab                 +
                 " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
                 "/log/tab042.log").
        END.

    RETURN "OK".

END PROCEDURE. /* altera_tab042 */
