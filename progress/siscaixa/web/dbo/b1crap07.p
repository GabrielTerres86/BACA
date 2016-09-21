/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap07.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 16/12/2013.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Consistencias / Atualizacao Abertura Boletim Caixa

   Alteracoes: 01/09/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               22/02/2006 - Unificacao dos bancos - SQLWorks - Eder        
                    
               22/06/2007 - Inclusao do indice crapbcx5 (Julio)     
               
               28/06/2013 - Atualizacao do campo crapbcx.hrultsgr na procedure
                            abertura-boletim-caixa. (Fabricio)
                            
               16/12/2013 - Adicionado validate para tabela crapbcx (Tiago).
............................................................................ */

/*--------------------------------------------------------------------*/
/*  b1crap07.p - Consistencias / Atualizacao Abertura Boletim Caixa   */
/*--------------------------------------------------------------------*/
{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.

PROCEDURE abertura-boletim-caixa:
    DEF INPUT  PARAM p-cooper              AS CHAR.
    DEF INPUT  PARAM p-cod-operador        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia         AS INTE.
    DEF INPUT  PARAM p-nro-caixa           AS INTE.
    DEF INPUT  PARAM p-valor-saldo-inicial AS DEC.

    DEF VAR i-nrseqdig AS INTE NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND FIRST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper    AND
                             crapbcx.dtmvtolt = crapdat.dtmvtolt    AND
                             crapbcx.cdopecxa = p-cod-operador      AND
                             crapbcx.cdsitbcx = 1 
                             USE-INDEX crapbcx3 NO-LOCK NO-ERROR.
                   
    IF  AVAIL crapbcx  THEN 
        DO:
            ASSIGN i-cod-erro  = 703
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
                            crapbcx.nrdcaixa = p-nro-caixa 
                            USE-INDEX crapbcx1 NO-LOCK NO-ERROR.
              
    IF  NOT AVAIL crapbcx THEN 
        DO:
            FIND FIRST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper    AND
                                     crapbcx.cdagenci = p-cod-agencia       AND
                                     crapbcx.nrdcaixa = p-nro-caixa         AND
                                     crapbcx.dtmvtolt < crapdat.dtmvtolt    
                                     USE-INDEX crapbcx5 NO-LOCK NO-ERROR.
        END.
        
    IF  NOT AVAIL crapbcx THEN 
        DO: 
            ASSIGN i-cod-erro  = 701
                   c-desc-erro = " " .       
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.     

    IF  crapbcx.cdsitbcx <> 2  THEN 
        DO:

            ASSIGN i-cod-erro  = 704
                   c-desc-erro = " ".       
            IF  crapbcx.cdopecxa <> p-cod-operador THEN 
                DO: 
                    ASSIGN i-cod-erro = 0
                           c-desc-erro = 
                                "Caixa sendo utilizado por outro Operador".
                END.
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
        
    IF  crapbcx.vldsdfin <> p-valor-saldo-inicial  THEN 
        DO:
            ASSIGN i-cod-erro  = 700
                   c-desc-erro = " " .       
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
        
    IF  crapbcx.cdopecxa = p-cod-operador   AND
        crapbcx.dtmvtolt = crapdat.dtmvtolt THEN
        DO:
            /* Operador nao pode abrir caixa no mesmo dia */
            ASSIGN i-cod-erro  = 703
                   c-desc-erro = " " .       
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.     

    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
   
    IF  crapbcx.dtmvtolt <> crapdat.dtmvtolt THEN
        ASSIGN i-nrseqdig = 1.
    ELSE
        ASSIGN i-nrseqdig = crapbcx.nrseqdig + 1.

    FIND crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper  AND
                       crapbcx.dtmvtolt = crapdat.dtmvtolt  AND
                       crapbcx.cdagenci = p-cod-agencia     AND
                       crapbcx.nrdcaixa = p-nro-caixa       AND
                       crapbcx.nrseqdig = i-nrseqdig 
                       USE-INDEX crapbcx1 NO-LOCK NO-ERROR.
         
    IF  AVAIL crapbcx THEN 
        DO:
            ASSIGN i-cod-erro  = 92
                   c-desc-erro = " " .       
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /* -- Atualizacao ---*/
    CREATE crapbcx.
    ASSIGN crapbcx.cdcooper = crapcop.cdcooper 
           crapbcx.dtmvtolt = crapdat.dtmvtolt
           crapbcx.cdagenci = p-cod-agencia
           crapbcx.nrdcaixa = p-nro-caixa
           crapbcx.nrseqdig = i-nrseqdig
           crapbcx.cdopecxa = p-cod-operador
           crapbcx.cdsitbcx = 1
           crapbcx.nrdlacre = 0
           crapbcx.nrdmaqui = p-nro-caixa
           crapbcx.qtautent = 0
           crapbcx.vldsdini = p-valor-saldo-inicial
           crapbcx.vldsdfin = p-valor-saldo-inicial
           crapbcx.hrabtbcx = TIME
           crapbcx.hrfecbcx = 0
           crapbcx.hrultsgr = TIME.
    VALIDATE crapbcx.

    RETURN "OK".

END PROCEDURE.

PROCEDURE saldo-inicial-boletim:
    DEF INPUT  PARAM p-cooper              AS CHAR.
    DEF INPUT  PARAM p-cod-operador        AS char.
    DEF INPUT  PARAM p-cod-agencia         AS INTE.
    DEF INPUT  PARAM p-nro-caixa           AS INTE.
    DEF OUTPUt PARAM p-valor-saldo-inicial AS DEC.
                                               
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND FIRST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper    AND
                             crapbcx.cdagenci = p-cod-agencia       AND
                             crapbcx.nrdcaixa = p-nro-caixa         AND
                             crapbcx.dtmvtolt = crapdat.dtmvtolt    AND
                             crapbcx.cdsitbcx = 2  
                             USE-INDEX crapbcx5 NO-LOCK NO-ERROR.
               
    IF  NOT AVAIL crapbcx THEN  
        DO:
            FIND FIRST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper    AND
                                     crapbcx.cdagenci = p-cod-agencia       AND
                                     crapbcx.nrdcaixa = p-nro-caixa         AND
                                     crapbcx.dtmvtolt < crapdat.dtmvtolt    AND
                                     crapbcx.cdsitbcx = 2 
                                     USE-INDEX crapbcx5 NO-LOCK NO-ERROR.
        END.

    IF  AVAIL crapbcx  THEN 
        DO:
            ASSIGN p-valor-saldo-inicial = crapbcx.vldsdini. 
        END.
    ELSE 
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
    
    RETURN "OK".

END PROCEDURE.

/* ......................................................................... */


