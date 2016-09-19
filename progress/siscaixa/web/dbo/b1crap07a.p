/* ---------------------------------------------------------------------------

    b1crap07a.p - Traz Saldo Inicial - Boletim  Caixa         
                                                            
    Alteracoes:
                23/02/2006 - Unificacao dos bancos - SQLWorks - Eder

----------------------------------------------------------------------------- */
{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.

PROCEDURE saldo-inicial-boletim:
    DEF INPUT  PARAM p-cooper              AS CHAR.
    DEF INPUT  PARAM p-cod-operador        AS char.
    DEF INPUT  PARAM p-cod-agencia         AS INTE.
    DEF INPUT  PARAM p-nro-caixa           AS INTE.
    DEF OUTPUt PARAM p-valor-saldo-inicial AS DEC.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND first crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper    AND
                             crapbcx.dtmvtolt = crapdat.dtmvtolt    AND
                             crapbcx.cdopecxa = p-cod-operador      AND
                             crapbcx.cdsitbcx = 1 
                             USE-INDEX crapbcx3 NO-LOCK NO-ERROR.
                             
    IF  AVAIL crapbcx  THEN 
        DO:
            ASSIGN p-valor-saldo-inicial = crapbcx.vldsdini. 
        END.
    ELSE 
        DO:
            ASSIGN i-cod-erro  = 701
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.    
    
    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */

