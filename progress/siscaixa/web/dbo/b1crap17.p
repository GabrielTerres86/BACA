/*-------------------------------------------------------------------------
  b1crap17.p - Estorno Associacao Lote                                  
  Ultima Alteracao: 23/02/2006  
 
  Alteracao: 
            16/02/2005 - Nao permitir estorno para tipo de lote <> 1(Mirtes) 
            
            23/02/2006 - Unificacao dos bancos - SQLWorks - Eder
--------------------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.

PROCEDURE estorno-associacao:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-nro-lote      AS INTE.
    DEF OUTPUT param p-docto         AS INTE.        
    DEF OUTPUT param p-valor         AS DEC.   
    DEF OUTPUT PARAM p-histor        AS INTE.
        
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
                                        
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF  p-nro-lote = 0  THEN  
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Lote deve ser Informado".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtolt  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND
                       craplot.nrdolote = p-nro-lote        NO-LOCK NO-ERROR.
 
    IF  NOT AVAILABLE craplot THEN  
        DO:
            ASSIGN i-cod-erro  = 60
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  craplot.nrdcaixa = 0    OR
        craplot.cdopecxa = ""   THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Lote nao Associado".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  craplot.tplotmov <> 1 THEN 
        DO:
            ASSIGN i-cod-erro  = 62
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
    FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper     AND
                            crapbcx.dtmvtolt = crapdat.dtmvtolt     AND
                            crapbcx.cdagenci = p-cod-agencia        AND
                            crapbcx.nrdcaixa = p-nro-caixa          AND
                            crapbcx.cdopecxa = p-cod-operador  
                            NO-LOCK NO-ERROR.
              
    IF  NOT AVAIL crapbcx THEN 
        DO: 
            ASSIGN i-cod-erro  = 701
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                          INPUT YES).
            RETURN "NOK".
        END.
        
    IF  crapbcx.cdsitbcx <> 1   THEN 
        DO:
            ASSIGN i-cod-erro  = 699
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.  
 
    /* Atualizacao */
     
    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtolt  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND
                       craplot.nrdolote = p-nro-lote 
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAILABLE craplot /* Locked */  THEN  
        DO:
            ASSIGN i-cod-erro  = 84
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
    ASSIGN p-valor  = craplot.vlcompdb
           p-docto  = craplot.nrdolote
           p-histor = craplot.cdhistor.

    ASSIGN craplot.nrdcaixa = 0
           craplot.cdopecxa = " ".
    RELEASE craplot.
          
    RETURN "OK".

END PROCEDURE.

/* b1crap17.p */
  
/* .......................................................................... */

