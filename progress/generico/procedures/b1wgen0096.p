/* .............................................................................

   Programa: b1wgen0096.p
   Autor   : GATI - Diego
   Data    : Abril/2011                  Ultima alteracao: 28/08/2013

   Dados referentes ao programa:

   Objetivo  : Consultar saldo atual dos caixas em tela.
   
   Alteracoes: 22/01/2013 - Alterada procedure SaldoCaixas para aceitar 
                            pac 0 (Daniele).

               28/08/2013 - Alterada procedure SaldoCaixas para filtrar
                            por dtrefere (Carlos)
                            
............................................................................. */

{ sistema/generico/includes/b1wgen0096tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.

PROCEDURE SaldoCaixas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_saldotot AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt_crapbcx.

    DEF VAR h-b2crap13   AS HANDLE                                  NO-UNDO.
    DEF VAR aux_vlcredit AS DECIMAL                                 NO-UNDO.
    DEF VAR aux_vldebito AS DECIMAL                                 NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    RUN dbo/b2crap13.p PERSISTENT SET h-b2crap13.

    EMPTY TEMP-TABLE tt_crapbcx.

    FOR EACH crapbcx NO-LOCK WHERE
             crapbcx.cdcooper = par_cdcooper     AND
             crapbcx.dtmvtolt = par_dtrefere     AND
             IF (par_cdagenci > 0)               THEN
                 crapbcx.cdagenci = par_cdagenci
             ELSE 
                 crapbcx.cdagenci > 0 
             BREAK BY crapbcx.cdagenci 
                   BY crapbcx.nrdcaixa:
                  
        CREATE tt_crapbcx.
        ASSIGN tt_crapbcx.cdagenci = crapbcx.cdagenci
               tt_crapbcx.nrdcaixa = crapbcx.nrdcaixa.
    
        IF  crapbcx.cdsitbcx = 1   THEN 
            DO:
                /* Aberto Hoje */
                tt_crapbcx.csituaca = "ABERTO".

                RUN disponibiliza-dados-boletim-caixa IN h-b2crap13 (
                    INPUT  crapcop.nmrescop,
                    INPUT  par_cdoperad,
                    INPUT  par_cdagenci,
                    INPUT  par_nrdcaixa,
                    INPUT  ROWID(crapbcx),
                    INPUT  " ",
                    INPUT  NO, 
                    INPUT  par_cdprogra,
                    OUTPUT aux_vlcredit,
                    OUTPUT aux_vldebito).
                
                tt_crapbcx.vldsdtot = crapbcx.vldsdini + aux_vlcredit - 
                                  aux_vldebito.
            END.
        ELSE 
        IF  crapbcx.cdsitbcx = 2   THEN
            DO:
               ASSIGN tt_crapbcx.csituaca = "FECHADO"
                      tt_crapbcx.vldsdtot = crapbcx.vldsdfin.
            END.

    
        /*  Exibir apenas com saldo diferente de Zero    */
        IF   tt_crapbcx.vldsdtot = 0   THEN
             DO:
                 DELETE tt_crapbcx.
                 NEXT.
             END.
    
        FIND FIRST crapope WHERE 
                   crapope.cdcooper = par_cdcooper       AND
                   crapope.cdoperad = crapbcx.cdopecxa   NO-LOCK.
    
        IF   AVAIL crapope   THEN
             ASSIGN tt_crapbcx.nmoperad = crapope.nmoperad.
    
        ASSIGN par_saldotot = par_saldotot + tt_crapbcx.vldsdtot.
    
    END.

    IF   VALID-HANDLE(h-b2crap13)   THEN
         DELETE OBJECT h-b2crap13.

    IF   NOT CAN-FIND( FIRST tt_crapbcx)   THEN 
         DO:                                                            
            ASSIGN aux_dscritic = "Nao ha caixas com saldo para o PAC " +
                                  "informado.".
        
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.
