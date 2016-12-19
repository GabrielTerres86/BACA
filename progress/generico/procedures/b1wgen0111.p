/* ............................................................................

   Programa: sistema/generico/procedures/b1wgen0111.p
   Autor  : Adriano
   Data   : Agosto/2011                      Ultima alteracao: 05/02/2013 

   Dados referentes ao programa:

   Objetivo  : BO referente a tela TAB091.
   
   Alteracoes: 05/02/2013 - Ajustes referente ao projeto Cadastro Restritivo
                            (Adriano).
   
               07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                            departamento passando a considerar o código (Renato Darosci)
   
..............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }


DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.


/*****************************************************************************
  Consulta TAB 
******************************************************************************/
PROCEDURE consulta_tab:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdcopalt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_dstextab AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcopalt 
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
       DO:
          ASSIGN aux_cdcritic = 794.

          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/ 
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
    
       END.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapope THEN
       DO:
           ASSIGN aux_cdcritic = 67.

           RUN gera_erro (INPUT par_cdcooper,        
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, /*sequencia*/  
                          INPUT aux_cdcritic,        
                          INPUT-OUTPUT aux_dscritic).
                                                 
           RETURN "NOK".      

       END.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcopalt         AND
                       craptab.nmsistem = "CRED"               AND
                       craptab.tptabela = "GENERI"             AND
                       craptab.cdempres = 0                    AND
                       craptab.cdacesso = "EMAILCADRESTRITIVO" AND
                       craptab.tpregist = 1            
                       NO-LOCK NO-ERROR.

    IF AVAIL craptab THEN
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
                         INPUT 1, /*sequencia*/ 
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".  

       END.

END PROCEDURE. /* Fim da procedure consulta_tab */


/*****************************************************************************
  Alterar TAB 
******************************************************************************/
PROCEDURE altera_tab:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dstextab AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdcopalt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR log_dstextab AS CHAR                                   NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                  NO-UNDO.
    DEF VAR aux_cdcritic AS INT                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                   NO-UNDO.
    DEF VAR aux_sittrans AS CHAR                                   NO-UNDO.
    DEF VAR aux_contador AS INTE                                   NO-UNDO.
    DEF VAR aux_nmrescop AS CHAR                                   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_contador = 0
           aux_nmrescop = ""
           aux_sittrans = "NOK".
    

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
       DO:
          ASSIGN aux_cdcritic = 794.

          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/ 
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
    
       END.
    ELSE
       ASSIGN aux_nmrescop = TRIM(crapcop.dsdircop).

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad    
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapope THEN
       DO:
           ASSIGN aux_cdcritic = 67.

           RUN gera_erro (INPUT par_cdcooper,        
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, /*sequencia*/  
                          INPUT aux_cdcritic,        
                          INPUT-OUTPUT aux_dscritic).
                                                 
           RETURN "NOK".      

       END.

    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcopalt  
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
       DO:
          ASSIGN aux_cdcritic = 794.

          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/  
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
    
       END.


    IF par_flgerlog  THEN
       ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
              aux_dstransa = "Alteracao de email. " + crapcop.nmrescop.

    
    TRANS_TAB:
    DO TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                   ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB:
       
       ContadorTab: DO aux_contador = 1 TO 10:
           
          FIND craptab WHERE craptab.cdcooper = par_cdcopalt         AND
                             craptab.nmsistem = "CRED"               AND
                             craptab.tptabela = "GENERI"             AND
                             craptab.cdempres = 0                    AND
                             craptab.cdacesso = "EMAILCADRESTRITIVO" AND
                             craptab.tpregist = 1          
                             EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

          IF NOT AVAIL craptab  THEN
             IF LOCKED craptab  THEN
                DO:
                   IF aux_contador = 10 THEN
                      ASSIGN aux_cdcritic = 77.

                   NEXT ContadorTab.

                END. 
             ELSE
                ASSIGN aux_cdcritic = 55.
          
          LEAVE ContadorTab.

       END. /* Fim do ContadorTab */

       IF aux_cdcritic <> 0  OR 
          aux_dscritic <> "" THEN
          UNDO TRANS_TAB, LEAVE TRANS_TAB.

       ASSIGN log_dstextab     = craptab.dstextab
              craptab.dstextab = par_dstextab
              aux_sittrans     = "OK".
       
    END. /* FIM do TRANSACTION */

    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
       DO:
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/  
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 

       END.

    IF aux_sittrans = "OK" THEN
       DO: 
          DO aux_contador = 1 TO NUM-ENTRIES(log_dstextab):

             IF ENTRY(aux_contador,log_dstextab) <> ENTRY(aux_contador,par_dstextab) THEN
                DO:
                    UNIX SILENT
                          VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                          " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          "Operador " + par_cdoperad                        +
                          " alterou o " + STRING(aux_contador) + "º"        + 
                          "e-mail da cooperativa " + STRING(par_cdcopalt)   +
                          " de "                                            + 
                          (IF ENTRY(aux_contador,log_dstextab) = "" THEN
                              "vazio"
                           ELSE
                              ENTRY(aux_contador,log_dstextab))             +
                          " para  "                                         + 
                          (IF ENTRY(aux_contador,par_dstextab) = "" THEN 
                              "vazio"
                           ELSE 
                              ENTRY(aux_contador,par_dstextab))             +
                          ". >> /usr/coop/" + aux_nmrescop                  + 
                          "/log/tab091.log").

                END.

          END.

       END.

    RETURN aux_sittrans.

END PROCEDURE. /* Fim da procedure altera_tab */



/* ------------------------------------------------------------------------- */
/*    RETORNA AS VARIAVEIS PARA PREENCHIMENTO DO COMBO DE COOPERATIVAS       */
/* ------------------------------------------------------------------------- */
PROCEDURE Busca_Cooperativas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmcooper AS CHAR                           NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    ASSIGN aux_contador = 0.

    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 
                           NO-LOCK BY crapcop.dsdircop:

        IF  aux_contador = 0 THEN
            ASSIGN par_nmcooper = "TODAS,0," + CAPS(crapcop.dsdircop) + "," +
                                  STRING(crapcop.cdcooper)
                   aux_contador = 1.
        ELSE
            ASSIGN par_nmcooper = par_nmcooper + "," + CAPS(crapcop.dsdircop)
                                              + "," + STRING(crapcop.cdcooper).

    END. /* FIM FOR EACH crapcop  */

    RETURN "OK".
    
END PROCEDURE. /* Busca_Cooperativas */
