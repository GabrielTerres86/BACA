/*-----------------------------------------------------------------------------

    b1crap13.p - Consulta       Boletim Caixa
    
    Alteracoes:
                23/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                
                20/10/2010 - Incluido caminho completo nas referencias do 
                             diretorio spool (Elton).
                             
                23/05/2011 - Alterada a leitura da tabela craptab para a 
                             tabela crapope (Isara - RKAM).
               
                30/09/2011 - Alterar diretorio spool para
                             /usr/coop/sistema/siscaixa/web/spool (Fernando).
                             
                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
-----------------------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF VAR i-cod-erro          AS INT                  NO-UNDO.
DEF VAR i-cont1             AS INT                  NO-UNDO.
DEF VAR i-cont2             AS INT                  NO-UNDO.
DEF VAR v_totpag            LIKE crapaut.vldocmto   NO-UNDO.
DEF VAR v_totrec            LIKE crapaut.vldocmto   NO-UNDO.
DEF VAR aux_vldsdfin        LIKE crapbcx.vldsdini   NO-UNDO.
DEF VAR c-desc-erro         AS CHAR                 NO-UNDO.
DEF VAR c-nome-agencia      AS CHAR                 NO-UNDO.
DEF VAR c-nome-caixa        AS CHAR                 NO-UNDO.
DEF VAR aux_nmdafila        AS CHAR                 NO-UNDO.
DEF VAR aux_nmarqimp        AS CHAR                 NO-UNDO.
DEF VAR p-literal           AS CHAR                 NO-UNDO.
DEF VAR r-registro          AS ROWID                NO-UNDO.
DEF VAR r-crapbcx           AS ROWID                NO-UNDO.


DEF VAR i-nro-vias          AS INTE                 NO-UNDO.
DEF VAR aux_dscomand        AS CHAR                 NO-UNDO.

DEF STREAM str_1.

DEF VAR p-valor-credito     AS DEC                  NO-UNDO.
DEF VAR p-valor-debito      AS DEC                  NO-UNDO.

DEF VAR h-b1crap00          AS HANDLE               NO-UNDO.
DEF VAR h-b2crap13          AS HANDLE               NO-UNDO.

DEF TEMP-TABLE tt-consulta
    FIELD r-registro        AS ROWID
    FIELD hora-abertura   LIKE crapbcx.hrabtbcx         
    FIELD hora-fechamento LIKE crapbcx.hrfecbcx   
    FIELD saldo-inicial   LIKE crapbcx.vldsdini  
    FIELD saldo-final     LIKE crapbcx.vldsdfin   
    FIELD nro-lacre       LIKE crapbcx.nrdlacre.

PROCEDURE consulta-boletim:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF OUTPUT PARAM TABLE FOR  tt-consulta.
                                           
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    FOR EACH tt-consulta:
        DELETE tt-consulta.
    END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND  LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper    AND
                             crapbcx.dtmvtolt = crapdat.dtmvtolt    AND
                             crapbcx.cdagenci = p-cod-agencia       AND
                             crapbcx.nrdcaixa = p-nro-caixa         AND
                             crapbcx.cdopecxa = p-cod-operador 
                             USE-INDEX crapbcx2 NO-LOCK NO-ERROR.
              
    IF  AVAIL crapbcx THEN 
        DO:
            CREATE tt-consulta.
            ASSIGN tt-consulta.r-registro      = ROWID(crapbcx)
                   tt-consulta.hora-abertura   = crapbcx.hrabtbcx         
                   tt-consulta.hora-fechamento = crapbcx.hrfecbcx   
                   tt-consulta.saldo-inicial   = crapbcx.vldsdini  
                   tt-consulta.saldo-final     = crapbcx.vldsdfin    
                   tt-consulta.nro-lacre       = crapbcx.nrdlacre.
        END.

    RETURN "OK".
END.

PROCEDURE impressao-fita-caixa:

    DEF INPUT PARAM p-cooper         AS CHAR.
    DEF INPUT PARAM p-cod-agencia    AS INT.
    DEF INPUT PARAM p-nro-caixa      AS INT.    
    DEF INPUT PARAM p-cod-operador   AS CHAR.  
    DEF INPUT PARAM p-data           AS DATE.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
  
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND FIRST crapope NO-LOCK
         WHERE crapope.cdcooper = crapcop.cdcooper
           AND crapope.cdoperad = p-cod-operador NO-ERROR.
    IF NOT AVAIL crapope THEN
        DO:
            ASSIGN i-cod-erro  = 67
                   c-desc-erro = "". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".  
        END. 
    ELSE
    DO:
        IF crapope.dsimpres = "" THEN
        DO:                          
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = 
                        "Registro de impressora nao encontrado para o Operador".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    END.
    
    ASSIGN aux_nmdafila =  LC(crapope.dsimpres).
    
    ASSIGN aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" + 
                          crapcop.dsdircop +
                          STRING(p-cod-agencia) + 
                          string(p-nro-caixa) + "b1013.txt".  /* Nome Fixo  */

    /* ASSIGN aux_nmarqimp = "Printer".  /* Retirar Printer */ */

    FORM HEADER
         "------- IMPRESSAO  DA  FITA  DE  CAIXA ---------" SKIP
         crapcop.nmrescop FORMAT "x(11)" " - " 
         crapcop.nmextcop FORMAT "x(32)" SKIP(1)
         "MOVIMENTO :" p-data FORMAT 99/99/9999 SKIP
         "PA........:" p-cod-agencia  FORMAT 999 " - " c-nome-agencia SKIP
         "CAIXA.....:" p-nro-caixa    FORMAT 999 " - " c-nome-caixa
         "================================================"
         SKIP(1)
         WITH NO-BOX NO-LABELS PAGE-TOP WIDTH 48 FRAME f_cabec_impres STREAM-IO.

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabec_impres.

    FORM p-literal FORMAT "x(48)" 
        WITH NO-BOX NO-LABELS PAGE-TOP WIDTH 48 FRAME f_literal STREAM-IO.

    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    ASSIGN i-cont1  = 0
           i-cont2  = 0
           v_totpag = 0
           v_totrec = 0.

    FOR EACH crapaut WHERE crapaut.cdcooper = crapcop.cdcooper  AND
                           crapaut.cdagenci    = p-cod-agencia  AND
                           crapaut.nrdcaixa    = p-nro-caixa    AND
                           crapaut.dtmvtolt    = p-data         NO-LOCK:
                           
        ASSIGN i-cont1 = i-cont1 + 1.

        IF  crapaut.cdstatus = "2" THEN      /* OFF-LINE */
            DO:
                ASSIGN i-cont2 = i-cont2 + 1.

                IF  crapaut.tpoperac = yes THEN  /* PG */
                    DO:
                        IF  crapaut.estorno = NO THEN
                            ASSIGN v_totpag = v_totpag + crapaut.vldocmto.
                        ELSE 
                            ASSIGN v_totpag = v_totpag - crapaut.vldocmto.
                    END.
                ELSE 
                    DO:
                        IF  crapaut.estorno = NO THEN
                            ASSIGN v_totrec = v_totrec + crapaut.vldocmto.
                        ELSE 
                            ASSIGN v_totrec = v_totrec - crapaut.vldocmto.
                    END.
            END.

        ASSIGN r-registro = ROWID(crapaut).
        RUN obtem-literal-autenticacao IN h-b1crap00 (INPUT p-cooper,
                                                      INPUT r-registro,
                                                      OUTPUT p-literal).
        DISP STREAM str_1 
             p-literal
             WITH  FRAME f_literal.
        DOWN STREAM str_1 WITH  FRAME f_literal.
    END.
    DELETE PROCEDURE h-b1crap00.

    FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper     AND
                            crapbcx.dtmvtolt = p-data               AND
                            crapbcx.cdagenci = p-cod-agencia        AND
                            crapbcx.nrdcaixa = p-nro-caixa          AND
                            crapbcx.cdopecxa = p-cod-operador       NO-ERROR. 
              
    IF  NOT AVAIL crapbcx THEN
        DO:
            ASSIGN i-cod-erro  = 698
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    ELSE 
        DO:
            ASSIGN r-crapbcx = ROWID(crapbcx).
        END.

    FORM SKIP(1)
         "------      FECHAMENTO    ------" SKIP(1)
         "SALDO INICIAL DO CAIXA.........:" 
                crapbcx.vldsdini FORMAT "ZZZ,ZZZ,ZZ9.99"    SKIP
         "TOTAL DE RECEBIMENTOS .........:" 
                p-valor-credito  FORMAT "ZZZ,ZZZ,ZZ9.99"    SKIP
         "TOTAL DE PAGAMENTOS . .........:" 
                p-valor-debito   FORMAT "ZZZ,ZZZ,ZZ9.99"    SKIP
         "SALDO FINAL DO CAIXA. .........:" 
                aux_vldsdfin     FORMAT "ZZZ,ZZZ,ZZ9.99"    SKIP
         "QUANTIDADE DE AUTENTICACOES....:" 
                i-cont1          FORMAT "ZZZZZZZZ9" AT 39   SKIP(1)
         "------ OPERACAO OFF-LINE  ------"                 SKIP(1)
          
         "TOTAL DE RECEBIMENTOS . .......:" 
                v_totrec         FORMAT "ZZZ,ZZZ,ZZ9.99"    SKIP
         "TOTAL DE PAGAMENTOS. ..........:" 
                v_totpag         FORMAT "ZZZ,ZZZ,ZZ9.99" 
         "QUANTIDADE DE AUTENTICACOES....:" 
                i-cont2          FORMAT "ZZZZZZZZ9" AT 39   SKIP(1)
         WITH NO-BOX NO-LABELS  WIDTH 48 FRAME f_outros STREAM-IO.

    RUN dbo/b2crap13.p PERSISTENT SET h-b2crap13.
    RUN disponibiliza-dados-boletim-caixa IN h-b2crap13 
                   (INPUT  p-cooper,
                    INPUT  p-cod-operador,
                    INPUT  p-cod-agencia,
                    INPUT  p-nro-caixa,
                    INPUT  r-crapbcx,
                    INPUT  " ", 
                    INPUT  NO, /* Impressao */
                    INPUT  "CRAP12",
                    OUTPUT p-valor-credito,
                    OUTPUT p-valor-debito).
                    
    DELETE PROCEDURE h-b2crap13.
    
    IF  RETURN-VALUE = "NOK" THEN  
        RETURN "NOK".
   
    ASSIGN aux_vldsdfin = crapbcx.vldsdini + p-valor-credito - p-valor-debito.

    DISP STREAM str_1 
         crapbcx.vldsdini
         p-valor-credito 
         p-valor-debito  
         aux_vldsdfin    
         i-cont1         
         v_totrec        
         v_totpag        
         i-cont2       
         WITH  FRAME f_outros.
    DOWN STREAM str_1 WITH  FRAME f_outros.
    DISP STREAM str_1
         "------------ FIM IMPRESSAO ------------"
         WITH NO-BOX NO-LABELS  WIDTH 48 FRAME f_fim STREAM-IO.
   
    OUTPUT STREAM str_1 CLOSE.
     
    assign i-nro-vias = 1.
    aux_dscomand = "lp -d" + aux_nmdafila +
                   " -n" + STRING(i-nro-vias) +   
                   " -oMTl88 " + aux_nmarqimp +     
                   " > /dev/null".

    UNIX SILENT VALUE(aux_dscomand).
         
    RETURN "OK".

END PROCEDURE.

/* b1crap13.p */

/* .......................................................................... */

