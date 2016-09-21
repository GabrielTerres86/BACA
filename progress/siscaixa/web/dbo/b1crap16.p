/*-------------------------------------------------------------------------
  b1crap16.p - Associacao Lote                                  
  Ultima Alteracao: 23/02/2006  
 
  Alteracao: 
            16/02/2005 - Nao permitir associacao para tipo lote <> 1(Mirtes) 
            
            23/02/2006 - Unificacao dos bancos - SQLWorks - Eder
--------------------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF VAR i-cod-erro      AS INTEGER.
DEF VAR c-desc-erro     AS CHAR.

DEF VAR h-b1crap00      AS HANDLE       NO-UNDO.

DEF VAR p-literal       AS CHAR         NO-UNDO.
DEF VAR p-ult-sequencia AS INTE         NO-UNDO.
DEF var p-registro      AS RECID        NO-UNDO.

PROCEDURE associacao-lote:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-nro-lote      AS INTE.
    DEF OUTPUT PARAM p-docto         AS INTE.
    DEF OUTPUT PARAM p-valor         AS DEC.
    DEF OUTPUT param p-histor        AS INTE.

    DEF  OUTPUT PARAM p-literal-r        AS CHAR.
    DEF  OUTPUT PARAM p-ult-sequencia-r  AS INTE.
                                               
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
 
    IF  craplot.nrdcaixa > 0    OR
        craplot.cdopecxa > ""   THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Lote ja Associado ".           
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
        
    IF  crapbcx.cdsitbcx <> 1 THEN 
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
    
    IF  NOT AVAILABLE craplot   THEN /* Locked */ 
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
   
    ASSIGN craplot.nrdcaixa = p-nro-caixa
           craplot.cdopecxa = p-cod-operador.

    ASSIGN p-valor  = craplot.vlcompdb
           p-docto  = craplot.nrdolote 
           p-histor = craplot.cdhistor.
   
    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN grava-autenticacao IN h-b1crap00 (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT p-cod-operador,
                                          INPUT p-valor,
                                          INPUT dec(p-docto),
                                          INPUT yes, /* YES (PG), NO (REC) */
                                          INPUT "1", /* On-line            */
                                            
                                          INPUT NO,  /* Nao estorno        */
                                          INPUT p-histor, 
                                          INPUT ?, /* Data off-line */
                                          INPUT 0, /* Sequencia off-line */
                                          INPUT 0, /* Hora off-line */
                                          INPUT 0, /* Seq.orig.Off-line */

                                          OUTPUT p-literal,
                                          OUTPUT p-ult-sequencia,
                                          OUTPUT p-registro).
    DELETE PROCEDURE h-b1crap00.

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

     /* Atualiza sequencia Autenticacao */
    ASSIGN  craplot.nrautdoc = p-ult-sequencia.

    ASSIGN p-ult-sequencia-r = p-ult-sequencia
           p-literal-r       = p-literal.
    
    RELEASE craplot.
          
    RETURN "OK".
END.

PROCEDURE retorna-valor-lote:
    DEF INPUT  param p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-nro-lote      AS INTE.
    DEF OUTPUT PARAM p-valor         AS DEC.
      
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

    ASSIGN p-valor  = craplot.vlcompdb.
          
    RETURN "OK".
END.

/* b1crap16.p */
  
/* .......................................................................... */

