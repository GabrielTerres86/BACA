/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap10.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 07/05/2013.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Estorno Boletim Caixa

   Alteracoes: 01/09/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               23/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               18/12/2008 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
                            
               07/05/2013 - Tratamento para atualizacao do saldo do cofre
                            (crapslc), na procedure estorna-boletim, para os
                            historicos 1152 e 1153. (Fabricio)
                            
............................................................................ */

/*------------------------------------------------------------*/
/*  b1crap10.p -  Estorno Boletim Caixa                       */
/*------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.

DEF VAR in99        AS INTE      NO-UNDO.

DEF VAR h-b1crap00 AS  HANDLE    NO-UNDO.

PROCEDURE valida-estorno-boletim:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-histor    AS INTE.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper     AND 
                            crapbcx.dtmvtolt = crapdat.dtmvtolt     AND
                            crapbcx.cdagenci = p-cod-agencia        AND
                            crapbcx.nrdcaixa = p-nro-caixa          AND
                            crapbcx.cdopecxa = p-cod-operador       AND
                            crapbcx.cdsitbcx = 1              
                            NO-LOCK NO-ERROR.
                            
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
        END.
                 
    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = p-cod-histor
                       NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL craphis  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Codigo de Historico nao Cadastrado".
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

    IF  craphis.tplotmov <> 22 THEN 
        DO:
            ASSIGN i-cod-erro  = 100
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
        
    IF  craphis.indoipmf > 0 THEN 
        DO:
            ASSIGN i-cod-erro  = 94
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
        
    IF  craphis.indebcre = "D"  AND
        craphis.inhistor = 12   THEN 
        DO:
            ASSIGN i-cod-erro  = 94
                   c-desc-erro = " ".
                   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
        
    IF  craphis.indebcre = "C"  AND
        craphis.inhistor =  2   THEN 
        DO:
            ASSIGN i-cod-erro  = 94
                   c-desc-erro = " ".
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
                     
    RETURN "OK".
                                             
END PROCEDURE.

PROCEDURE retorna-valor-historico:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-cod-histor    AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF OUTPUT PARAM p-nrctacrd      AS INTE.
    DEF OUTPUT PARAM p-nrctadeb      AS INTE.
    DEF OUTPUT PARAM p-cdhstctb      AS INTE.
    DEF OUTPUT PARAM p-ds-histor     AS CHAR.
               
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper  AND
                       crapage.cdagenci = p-cod-agencia     NO-LOCK NO-ERROR.
    
    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = p-cod-histor
                       NO-LOCK NO-ERROR.
     
    IF  craphis.tpctbcxa = 2    THEN
        ASSIGN p-nrctadeb = crapage.cdcxaage
               p-nrctacrd = craphis.nrctacrd.
    ELSE
        IF  craphis.tpctbcxa = 3   THEN
            ASSIGN p-nrctacrd = crapage.cdcxaage
                   p-nrctadeb = craphis.nrctadeb.
        ELSE
            ASSIGN p-nrctacrd = craphis.nrctacrd
                   p-nrctadeb = craphis.nrctadeb.
    
    ASSIGN p-cdhstctb  = craphis.cdhstctb
           p-ds-histor = craphis.dshistor.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE valida-existencia-boletim:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-cod-histor    AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-nro-docto     AS INTE.
    DEF OUTPUT PARAM p-valor         AS DEC. 
    DEF OUTPUT PARAM p-complement1   AS CHAR.
    DEF OUTPUT PARAM p-complement2   AS CHAR.
    DEF OUTPUT PARAM p-complement3   AS CHAR.
    DEF OUTPUT PARAM p-complement4   AS CHAR.
    DEF OUTPUT PARAM p-complement5   AS CHAR.
               
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = p-cod-histor
                       NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL craphis  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Codigo de Historico nao Cadastrado".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.         

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND FIRST craplcx WHERE craplcx.cdcooper = crapcop.cdcooper    AND
                             craplcx.dtmvtolt = crapdat.dtmvtolt    AND
                             craplcx.cdagenci = p-cod-agencia       AND
                             craplcx.nrdcaixa = p-nro-caixa         AND
                             craplcx.cdhistor = p-cod-histor        AND
                             craplcx.cdopecxa = p-cod-operador      AND
                             craplcx.nrdocmto = p-nro-docto      
                             NO-LOCK NO-ERROR.
       
    IF  NOT AVAIL craplcx THEN 
        DO: 
            ASSIGN i-cod-erro  = 90
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    ASSIGN p-valor       = craplcx.vldocmto
           p-complement1 = SUBSTR(craplcx.dsdcompl,1,48)   
           p-complement2 = SUBSTR(craplcx.dsdcompl,49,48)  
           p-complement3 = SUBSTR(craplcx.dsdcompl,97,48)  
           p-complement4 = SUBSTR(craplcx.dsdcompl,145,48)  
           p-complement5 = SUBSTR(craplcx.dsdcompl,193,48).

    RETURN "OK".

END PROCEDURE.

PROCEDURE estorna-boletim:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-histor    AS INTE.    
    DEF INPUT  PARAM p-nro-docto     AS INTE.
    DEF INPUT  PARAM p-codigo        AS CHAR.
    DEF INPUT  PARAM p-senha         AS CHAR.
    DEF OUTPUT PARAM p-pg            AS LOG.

    DEF VAR v-saldo-caixa AS DECI NO-UNDO.
               
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    RUN valida-permissao-estorno-historico IN THIS-PROCEDURE (p-cooper,
                                                              p-cod-agencia,
                                                              p-nro-caixa,
                                                              p-cod-operador,
                                                              p-codigo,
                                                              p-senha,
                                                              p-cod-histor).
    IF  RETURN-VALUE = 'NOK' THEN
        RETURN 'NOK'.

    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = p-cod-histor
                       NO-LOCK NO-ERROR.
    
    IF  craphis.indebcre = "C" THEN
        ASSIGN p-pg = no.   /* Credito = Recebimento */
    ELSE
        ASSIGN p-pg = YES.  /* Debito = Pagamento */
    
    ASSIGN in99  = 0.
    
    DO WHILE TRUE:
       
        ASSIGN in99 = in99 + 1.
        FIND FIRST craplcx WHERE craplcx.cdcooper = crapcop.cdcooper    AND
                                 craplcx.dtmvtolt = crapdat.dtmvtolt    AND
                                 craplcx.cdagenci = p-cod-agencia       AND
                                 craplcx.nrdcaixa = p-nro-caixa         AND
                                 craplcx.cdopecxa = p-cod-operador      AND
                                 craplcx.cdhistor = p-cod-histor        AND
                                 craplcx.nrdocmto = p-nro-docto     
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
        IF  NOT AVAILABLE craplcx   THEN  
            DO:
                IF  LOCKED craplcx  THEN 
                    DO:
                        IF  in99 <  100 THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = 
                                                "Tabela CRAPLCX em uso ".
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                            END.
                    END.
                ELSE 
                    DO:
                        ASSIGN i-cod-erro  = 90
                               c-desc-erro = " ".           
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
            END.
        LEAVE.
    END.  /*  DO WHILE */

    /*--- Utilizado como sequencia de Lancamentos --
    ASSIGN crapbcx.qtcompln = crapbcx.qtcompln - 1.
    ------------------------------------------------*/

    IF p-cod-histor = 1152 OR p-cod-histor = 1153 THEN
    DO:
        ASSIGN in99 = 0.

        DO WHILE TRUE:

            FIND crapslc WHERE crapslc.cdcooper = crapcop.cdcooper AND
                           crapslc.cdagenci = p-cod-agencia        AND
                           crapslc.nrdcofre = 1
                           EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

            ASSIGN in99 = in99 + 1.

            IF NOT AVAIL crapslc THEN
            DO:
                IF LOCKED crapslc THEN
                DO:
                    IF in99 < 100 THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                    ELSE
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Tabela CRAPSLC em uso.".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).

                        RELEASE craplcx.

                        RETURN "NOK".
                    END.
                END.
                ELSE
                DO:
                    ASSIGN i-cod-erro = 0
                           c-desc-erro = "Nao foi possivel consultar o " +
                                         "saldo do cofre.".

                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RELEASE craplcx.

                    RETURN "NOK".
                END.
            END.
            ELSE
            IF p-cod-histor = 1153 THEN /* estorno de suprimento do caixa */
            DO:
                RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

                RUN verifica-saldo-caixa IN h-b1crap00 
                                            (INPUT crapcop.cdcooper,
                                             INPUT crapcop.nmrescop,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT p-cod-operador,
                                            OUTPUT v-saldo-caixa).

                IF VALID-HANDLE(h-b1crap00) THEN
                    DELETE OBJECT h-b1crap00.

                IF RETURN-VALUE = "NOK" THEN
                DO:
                    RELEASE craplcx.
                    RETURN "NOK".
                END.

                IF craplcx.vldocmto > v-saldo-caixa THEN
                DO:
                    ASSIGN i-cod-erro = 0
                          c-desc-erro = "Saldo insuficiente no caixa "
                                      + "para realizar essa operacao.".

                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RELEASE craplcx.

                    RETURN "NOK".
                END.

                ASSIGN crapslc.vlrsaldo = crapslc.vlrsaldo + craplcx.vldocmto.
            END.
            ELSE
            IF p-cod-histor = 1152 THEN
            DO:
                IF craplcx.vldocmto > crapslc.vlrsaldo THEN
                DO:
                    ASSIGN i-cod-erro = 0
                           c-desc-erro = "Saldo insuficiente no cofre "
                                       + "para realizar o estorno.".

                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RELEASE craplcx.

                    RETURN "NOK".
                END.

                ASSIGN crapslc.vlrsaldo = crapslc.vlrsaldo - craplcx.vldocmto.

            END.

            LEAVE.
        END.
    END.

    DELETE craplcx.
    
    RETURN "OK".
END.

PROCEDURE valida-permissao-estorno-historico:

    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF INPUT  PARAM p-codigo           AS char.
    DEF INPUT  PARAM p-senha            AS CHAR.
    DEF INPUT  PARAM p-cod-histor       AS INTEGER NO-UNDO.
           
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
                                                            
    IF  p-cod-histor <> 701     AND 
        p-cod-histor <> 702     THEN
        RETURN 'OK'.

    IF  p-codigo = "" THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Informe Codigo/Senha ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    FIND FIRST crapope WHERE crapope.cdcooper = crapcop.cdcooper    AND
                             crapope.cdoperad = p-codigo 
                             NO-LOCK NO-ERROR.
                             
    IF  NOT AVAIL crapope THEN 
        DO:
            ASSIGN i-cod-erro  = 67
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  p-senha <> crapope.cddsenha  THEN 
        DO:
            ASSIGN i-cod-erro  = 3
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /* 1 - Operador, 2-Supervisor , 3-Gerente  */
    IF  crapope.nvoperad <> 2   AND 
        crapope.nvoperad <> 3   THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = 
                          "Somente um Coordenador pode liberar o lancamento.".
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

/* b1crap10.p */  

/* ..........................................................................*/

