/*------------------------------------------------------------------

    b2crap01.p - Verificaca Pendencias Compensacao
    
    Ultima Atualizacao: 02/03/2006
    
    Alteracoes:
                02/03/2006 - Unificacao dos bancos - SQLWorks - Eder
                
------------------------------------------------------------------*/
{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.
DEF VAR i-sequen    AS INTE                             NO-UNDO.
DEF VAR in01        AS INTE                             NO-UNDO.
DEF VAR c-arquivo   AS CHAR FORMAT "x(30)"              NO-UNDO.
DEF VAR c-diretorio AS CHAR                             NO-UNDO.
DEF VAR c-dia       AS CHAR FORMAT "X(03)" EXTENT 7     NO-UNDO.

ASSIGN c-dia[1] = "DOM"
       c-dia[2] = "SEG"
       c-dia[3] = "TER"
       c-dia[4] = "QUA"
       c-dia[5] = "QUI"
       c-dia[6] = "SEX"
       c-dia[7] = "SAB".                                         

PROCEDURE verifica-importacao:
    DEF INPUT  PARAM p-cooper       AS CHAR.
    DEF INPUT  PARAM p-cod-agencia  AS INTE.
    DEF INPUT  PARAM p-nro-caixa    AS INTE.
    DEF INPUT  PARAM p-autentica    AS INTE.
  
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    ASSIGN c-diretorio = crapcop.nmdireto.
   
    /* Compara Sequencia COOKIE com Tabela CRAPAUT */
    ASSIGN i-sequen = 0.
    FIND LAST crapaut WHERE crapaut.cdcooper = crapcop.cdcooper     AND
                            crapaut.cdagenci = p-cod-agencia        AND
                            crapaut.nrdcaixa = p-nro-caixa          AND
                            crapaut.dtmvtolt = crapdat.dtmvtolt 
                            NO-LOCK NO-ERROR.
              
    IF  AVAIL crapaut  THEN
        ASSIGN i-sequen = crapaut.nrsequen.

    /*----
    IF  i-sequen <> p-autentica  THEN  
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = 
                       "ALERTA - Efetue Importacao - Ult.Autenticacao =  " +
                       STRING(p-autentica).
        
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
    ---*/ 

    /* Verifica se existem arquivos a serem Importados */
    in01 = 1.  
    DO  WHILE in01 LE 7:

        ASSIGN c-arquivo = c-diretorio + "/off-line/" + 
                           STRING(p-cod-agencia) + STRING(p-nro-caixa) + 
                           c-dia[in01] + ".txt".  /* Nome Fixo  */
       
        IF  SEARCH (c-arquivo) <> ?  THEN 
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = 
                            "ALERTA - Efetue Importacao - Arquivos Pendentes".
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                LEAVE.
            END.
        ASSIGN in01 = in01 + 1.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica-importacao-fechamento:
    DEF INPUT  PARAM p-cooper       AS CHAR.
    DEF INPUT  PARAM p-cod-agencia  AS INTE.
    DEF INPUT  PARAM p-nro-caixa    AS INTE.
    DEF INPUT  PARAM p-autentica    AS INTE.
  
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper, 
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    ASSIGN c-diretorio = crapcop.nmdireto.
   
    /* Compara Sequencia COOKIE com Tabela CRAPAUT */
    ASSIGN i-sequen = 0.
    FIND LAST crapaut WHERE crapaut.cdcooper = crapcop.cdcooper     AND
                            crapaut.cdagenci = p-cod-agencia        AND
                            crapaut.nrdcaixa = p-nro-caixa          AND
                            crapaut.dtmvtolt = crapdat.dtmvtolt 
                            NO-LOCK NO-ERROR.
              
    IF  AVAIL crapaut  THEN
        ASSIGN i-sequen = crapaut.nrsequen.

    /*---
    IF  i-sequen <> p-autentica  THEN  
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Efetue Importacao - Ult.Autenticacao =  " + 
                                 STRING(p-autentica).
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
    ---*/

    /* Verifica se existem arquivos a serem Importados */
    in01 = 1.  
    DO  WHILE in01 LE 7:

        ASSIGN c-arquivo = c-diretorio + "/off-line/" +  
                           STRING(p-cod-agencia) + STRING(p-nro-caixa) +
                           c-dia[in01] + ".txt".  /* Nome Fixo  */
       
        IF  SEARCH (c-arquivo) <> ?  THEN 
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Efetue Importacao - Arquivos Pendentes".
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                LEAVE.
            END.
        ASSIGN in01 = in01 + 1.
    END.

    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
   
    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica-compensacao:
    DEF INPUT  PARAM p-cooper       AS CHAR.
    DEF INPUT  PARAM p-cod-agencia  AS INTE.
    DEF INPUT  PARAM p-nro-caixa    AS INTE.
      
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    /*--- Nao eliminar - Pendencias de Importacao
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    -----------------------------------------*/
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "CONFIG"          AND
                       craptab.cdempres = crapcop.cdcooper  AND
                       craptab.cdacesso = "CONVTALOES"      AND
                       craptab.tpregist = 001               NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL craptab THEN 
        DO:
            ASSIGN i-cod-erro  = 652
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
                                
    IF  INT(craptab.dstextab) > 0  THEN 
        DO:
    
            FIND crapban WHERE crapban.cdbccxlt = INT(craptab.dstextab)
                               NO-LOCK NO-ERROR.
         
            IF  NOT AVAIL crapban THEN 
                DO: 
                    ASSIGN i-cod-erro  = 57
                        c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                    RETURN "NOK".
                END.

            FIND FIRST craplot WHERE craplot.cdcooper = crapcop.cdcooper    AND
                                     craplot.dtmvtolt = crapdat.dtmvtoan    AND
                                     craplot.cdagenci = 1                   AND
                                     craplot.cdbccxlt = crapban.cdbccxlt    AND
                                    (craplot.nrdolote > 7000                AND
                                     craplot.nrdolote < 7020)               AND
                                     craplot.tplotmov = 1 
                                     NO-LOCK NO-ERROR.
                   
            IF  NOT AVAIL craplot THEN 
                DO:
                    FIND FIRST craplot WHERE 
                               craplot.cdcooper = crapcop.cdcooper  AND
                               craplot.dtmvtolt = crapdat.dtmvtolt  AND
                               craplot.cdagenci = 1                 AND
                               craplot.cdbccxlt = crapban.cdbccxlt  AND
                              (craplot.nrdolote > 7000              AND
                               craplot.nrdolote < 7020)             AND
                               craplot.tplotmov = 1 
                               NO-LOCK NO-ERROR.
                       
                    IF  AVAIL craplot   THEN 
                        DO:
                            ASSIGN c-desc-erro = 
                                        " COMPENSACAO "                       +
                                        crapban.nmresbcc + " REF. "           +
                                        STRING(crapdat.dtmvtoan,"99/99/9999") +
                                        " OK! LISTE NEGATIVOS (IMPREL)".
                        END.
                    ELSE 
                        DO:
                            ASSIGN c-desc-erro = 
                                        "---> COMPENSACAO "                   +
                                        crapban.nmresbcc + " REF. "           +
                                        STRING(crapdat.dtmvtoan,"99/99/9999") +
                                        " NAO ESTA INTEGRADA  <---".
                        END.
                    ASSIGN i-cod-erro  = 0.
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT NO).
                    RETURN "OK".
                END.
        END.
   
    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */

