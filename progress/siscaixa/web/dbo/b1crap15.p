/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap15.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 05/10/2015
     

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Tratar Estorno de Faturas com codigo de barras

   Alteracoes: 02/05/2005 - Alteracao do historico da SAMAE Blumenau 
                            306 -> 644 (Julio)   

               17/06/2005 - Tratamento convenio Aguas de Itapema -> 456 (Julio)
               
               20/09/2005 - Tratamento para segmento do convenio (Julio)
               
               28/10/2005 - Alteracao do tratamento do sequencial para
                            CELESC -> 625 (Julio)
                            
               08/11/2005 - Alterar tratamento de sequencial para SAMAE
                            POMERODE -> 618 (Julio)
                            
               12/01/2006 - Tratamento para P.M.Itajai -> 659 (Julio)
               
               03/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               11/08/2006 - Tratamento para P.M.Pomerode -> 663 (Julio)
               
               11/10/2006 - Tratamento para CELESC Distribuição -> 666 (Julio)
               
               31/01/2007 - Tratamento para DAE Navegantes --> 671 (Elton).

               23/11/2007 - Tratamento para SEMASA Itajai --> 675 (Elton).
               
               10/01/2008 - Tratamento para novo convênio da P.M.Blumenau
                            337 (Julio)              

               07/05/2008 - Alterado para usar a data com crapdat.dtmvtocd
                            (David).
               
               20/04/2010 - Tratamento para numero sequencial do convênio
                            Aguas de Presidente Getulio --> 464 (Elton).
                            
               01/10/2010 - Tratamento para Samae Rio Negrinho --> 899 (Elton).
               
               05/04/2011 - Tratamento para CERSAD -> 929; 
                          - Tratamento para Foz do Brasil -> 963;
                          - Tratamento para Aguas de Massaranduba -> 964 (Elton).
                          
               20/01/2012 - Tratamento para receber faturas com digito calculado
                            pelo modulo 11;
                          - Não permite estornar guias de DARE -> 1063 e 
                            GNRE -> 1065 (Elton).  
               
               17/08/2012 - Alterado para nao precisar fazer tratamento de 
                            cada novo convenio que iniciar (Elton).
                            
               08/02/2013 - Incluso chamada para a procedure busca_sequencial_fatura
                            (Daniel).  
                            
               18/04/2013 - Validação relativa ao horário de estorno para 
                            pagtos SICREDI (Lucas).
                            
               24/05/2013 - Validação para não estornar DARFs (Lucas).
               
               09/01/2014 - Nao permite estornar guias quando o campo flgenvpa
                            for TRUE. (Reinert)
                            
               18/03/2014 - If para cdhistor 1154 Sicredi. (Jorge)     
               
               25/11/2014 - Ajuste rotina para separar registros de Debaut e
                           registros de pagamento regular de convênios (Lunelli)      
                           
               23/01/2015 - Alterada para Oracle a consulta da craplft na procedure 
                           'retorna-valores-fatura' pois DataServer não suporta as mais
                            de 34 posições do campo cdseqfat (Lunelli - SD. 225876)
                            
               02/03/2015 - Correção no formato de data ORACLE (Lunelli - SD. 260512)
               
               05/03/2015 - Correção na divisão por 100 anteriormente utilizada (Lunelli - SD. 261848)
               
               05/10/2015 - Adicionado condicao (crapscn.dtencemp  = ?) na leitura
                            da crapscn pois estava permitindo estornar alguns
                            tipos de DARF (Tiago/Elton #337771).
                            
               12/12/2017 - Alterar campo flgcnvsi por tparrecd. PRJ406-FGTS (Odirlei-AMcom)                    
.............................................................................*/
   
/*------------------------------------------------------------*/
/*  b1crap15.p - Estorno  Arrecadacoes Faturas (Antigo LANFAT) */
/*------------------------------------------------------------*/

{dbo/bo-erro1.i}


DEF VAR i-cod-erro      AS INTEGER.
DEF VAR c-desc-erro     AS CHAR.


DEF VAR de-valor-calc   AS DEC  NO-UNDO.
DEF VAR p-nro-digito    AS INTE NO-UNDO.
DEF VAR p-retorno       AS LOG  NO-UNDO.
DEF VAR i-nro-lote      LIKE craplft.nrdolote NO-UNDO.
DEF VAR iHandle         AS INTEGER NO-UNDO.

DEF VAR h-b1crap14      AS HANDLE  NO-UNDO.

PROCEDURE valida-codigo-barras.
    DEF INPUT         PARAM p-cooper         AS CHAR.
    DEF INPUT         PARAM p-cod-operador   AS char.
    DEF INPUT         PARAM p-cod-agencia    AS INTE.
    DEF INPUT         PARAM p-nro-caixa      AS INTE.
    DEF INPUT         param p-codigo-barras  AS CHAR.
                 
    FIND crapcop WHERE
         crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF  p-codigo-barras <>  " "  THEN do:
        IF   LENGTH(p-codigo-barras) <> 44 THEN DO:
             ASSIGN p-codigo-barras = " ".
             ASSIGN i-cod-erro  = 666  /* Erro de Leitura. Passe Novamente */
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
    RETURN "OK".

END PROCEDURE.


PROCEDURE retorna-valores-fatura.   
    /*  Listar   Valor/Sequencia/Digito/Codigo de Barras  */
    
    DEF INPUT         PARAM p-cooper        AS CHAR.
    DEF INPUT         PARAM p-cod-operador  AS char.
    DEF INPUT         PARAM p-cod-agencia   AS INTE.
    DEF INPUT         PARAM p-nro-caixa     AS INTE.
    DEF INPUT         param p-fatura1       AS dec.
    DEF INPUT         PARAM p-fatura2       AS DEC. 
    DEF INPUT         param p-fatura3       AS DEC.
    DEF INPUT         PARAM p-fatura4       AS DEC.
    DEF INPUT-OUTPUT  PARAM p-codigo-barras AS CHAR.
    DEF OUTPUT        PARAM p-cdseqfat      AS DEC.
    DEF OUTPUT        PARAM p-vlpago        AS DEC.
    DEF OUTPUT        PARAM p-vlfatura      AS DEC.
    DEF OUTPUT        PARAM p-nrdigfat      AS inte.
    DEF OUTPUT        PARAM p-iptu          AS LOG.    

    { sistema/generico/includes/var_oracle.i }

    DEF VAR aux_dsconsul  AS CHAR NO-UNDO.
    DEF VAR aux_dsmvtocd  AS CHAR NO-UNDO.
    DEF VAR aux_vllanmto  AS DECI NO-UNDO.
    DEF VAR aux_flgfatex  AS LOGI NO-UNDO.
                
    FIND crapcop WHERE
         crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
        
    ASSIGN p-iptu       = NO
           p-cdseqfat   = 0
           p-vlfatura   = 0
           p-nrdigfat   = 0
           aux_flgfatex = NO.
    
    IF  p-fatura1 <> 0 OR
        p-fatura2 <> 0 OR
        p-fatura3 <> 0 OR
        p-fatura4 <> 0 THEN  
        DO:
            ASSIGN de-valor-calc  =
                           DEC(SUBSTR(STRING(p-fatura1,"999999999999"),1,11) + 
                               SUBSTR(STRING(p-fatura2,"999999999999"),1,11) + 
                               SUBSTR(STRING(p-fatura3,"999999999999"),1,11) + 
                               SUBSTR(STRING(p-fatura4,"999999999999"),1,11)).
                                                    
            ASSIGN p-codigo-barras = string(de-valor-calc).
        END.
    
    ASSIGN de-valor-calc = DEC(p-codigo-barras).
    
    /* Calculo Digito Verificador */
    RUN dbo/pcrap04.p (INPUT-OUTPUT de-valor-calc,
                       OUTPUT p-nro-digito,
                       OUTPUT p-retorno).
    IF  p-retorno = NO  THEN 
        DO:
            /*** Verificacao do digito pelo modulo 11 ***/
            ASSIGN de-valor-calc = DEC(p-codigo-barras).
            
            RUN dbo/pcrap14.p (INPUT-OUTPUT de-valor-calc,
                               OUTPUT p-nro-digito,
                               OUTPUT p-retorno).
            
            IF  p-retorno = NO  THEN 
                DO:
                    ASSIGN i-cod-erro  = 8           
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
    
    FIND crapcon WHERE
         crapcon.cdcooper = crapcop.cdcooper                   AND
         crapcon.cdempcon = inte(SUBSTR(p-codigo-barras,16,4)) AND
         crapcon.cdsegmto = inte(SUBSTR(p-codigo-barras,2,1))  NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapcon THEN  
        DO: 
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = "Empresa Conveniada nao Cadastrada".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    /* Se for conv. SICREDI */
    IF  crapcon.tparrecd = 1 THEN
        DO:
            FIND FIRST crapscn WHERE crapscn.cdempcon  = crapcon.cdempcon         AND
                                     crapscn.cdsegmto  = STRING(crapcon.cdsegmto) AND
                                     crapscn.dsoparre <> "E"                      AND /* Debaut */
                                     crapscn.dtencemp  = ?
                                                     NO-LOCK NO-ERROR NO-WAIT.

            FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                     crapstn.tpmeiarr = "C" NO-LOCK NO-ERROR.

            /* Não permite o estorno de DARFs */
            IF  AVAIL crapstn THEN 
                IF (crapstn.dstipdrf <> ""    OR
                    crapscn.cdempres = "K0" ) THEN
                    DO:
                        ASSIGN i-cod-erro  = 0 
                               c-desc-erro = "Esta guia nao pode ser estornada.".
                 
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.

            /* Validação relativa ao horario de canc. de pgto de Convenios SICREDI  */
            FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                               craptab.nmsistem = "CRED"            AND
                               craptab.tptabela = "GENERI"          AND
                               craptab.cdempres = 00                AND
                               craptab.cdacesso = "HRPGSICRED"      AND
                               craptab.tpregist = p-cod-agencia 
                               NO-LOCK NO-ERROR.
    
            IF  NOT AVAIL craptab  THEN
                DO:
                    ASSIGN i-cod-erro  = 0 
                           c-desc-erro = "Parametros nao cadastrados.".
             
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
    
            /* Verifica se a hora atual é maior do que a do cancelamento */
            IF  TIME > INT(ENTRY(3,craptab.dstextab," ")) THEN
                DO:
                    ASSIGN i-cod-erro  = 0 
                           c-desc-erro = "Nao permitido estornar faturas do Sicredi apos as " +
                                          STRING(INT(ENTRY(3,craptab.dstextab," ")),"HH:MM") + " hrs.".
             
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
    
                END.
        END.
    
    IF crapcon.cdhistor <> 1154 THEN
    DO:

        FIND FIRST gnconve WHERE gnconve.cdhiscxa = crapcon.cdhistor
                           NO-LOCK NO-ERROR.
      
        IF gnconve.flgenvpa THEN
            DO:
                ASSIGN i-cod-erro  = 0           
                       c-desc-erro = "Este tipo de fatura nao pode ser estornado.".
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.
    END.

    RUN dbo/b1crap14.p PERSISTENT SET h-b1crap14.
    RUN busca_sequencial_fatura IN h-b1crap14
                                         (INPUT crapcon.cdhistor,
                                          INPUT p-codigo-barras,
                                          OUTPUT p-cdseqfat).

    DELETE PROCEDURE h-b1crap14.
    
    ASSIGN p-vlfatura = DECIMAL(SUBSTR(p-codigo-barras,5,11)) / 100.
                                        
    IF  crapcon.cdhistor  = 644  OR
        crapcon.cdhistor  = 307  OR
        crapcon.cdhistor  = 348  THEN
        ASSIGN p-nrdigfat = INTEGER(SUBSTR(p-codigo-barras,43,02)).
    ELSE
        ASSIGN p-nrdigfat = 0.                   
    
    /* Lote - 15000 --- Tipo 13 --- FATURAS ---*/
    ASSIGN i-nro-lote = 15000 + p-nro-caixa.    

    ASSIGN aux_dsmvtocd = STRING(DAY(crapdat.dtmvtocd),"99")    +
                          STRING(MONTH(crapdat.dtmvtocd),"99")  +
                          STRING(YEAR(crapdat.dtmvtocd),"9999").
    
    ASSIGN aux_dsconsul = "SELECT craplft.vllanmto FROM craplft WHERE craplft.cdcooper = "  + STRING(crapcop.cdcooper) + " AND " +
                                                                     "craplft.dtmvtolt = to_date('" + STRING(aux_dsmvtocd)     + "', 'dd/mm/yyyy') AND " +
                                                                     "craplft.cdagenci = "  + STRING(p-cod-agencia)    + " AND " +
                                                                     "craplft.cdbccxlt = 11                                AND " +
                                                                     "craplft.nrdolote = "  + STRING(i-nro-lote)       + " AND " +
                                                                     "craplft.cdseqfat = "  + STRING(p-cdseqfat).

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement iHandle = PROC-HANDLE NO-ERROR(aux_dsconsul).

    FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = iHandle:

        /* Registro existe */
        ASSIGN aux_flgfatex = TRUE.
        ASSIGN aux_vllanmto = DECI(proc-text).

    END.
    
    CLOSE STORED-PROC send-sql-statement WHERE PROC-HANDLE = iHandle.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

/* Removido para consulta Oracle, pois DataServer não suporta as mais de 34 posições do campo cdseqfat - Lunelli
    FIND craplft WHERE craplft.cdcooper = crapcop.cdcooper  AND
                       craplft.dtmvtolt = crapdat.dtmvtocd  AND
                       craplft.cdagenci = p-cod-agencia     AND
                       craplft.cdbccxlt = 11                AND
                       craplft.nrdolote = i-nro-lote        AND
                       craplft.cdseqfat = p-cdseqfat 
                       USE-INDEX craplft1 NO-LOCK NO-ERROR. */
    
    IF  NOT aux_flgfatex THEN
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
    
    FIND craplot WHERE
         craplot.cdcooper = crapcop.cdcooper   AND
         craplot.dtmvtolt = crapdat.dtmvtocd   AND
         craplot.cdagenci = p-cod-agencia      AND
         craplot.cdbccxlt = 11                 AND    /* Fixo */
         craplot.nrdolote = i-nro-lote         NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplot THEN 
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
    
    /*-- Alterado para retornar valor fatura quando c¢digo de barras = 0 --*/
    IF  p-vlfatura = 0  THEN
        ASSIGN p-vlfatura = (aux_vllanmto).
    /*-------------------------------------*/

/* Robinson Rafael Koprowski */
/* retorno do valor pago     */
    ASSIGN p-vlpago = (aux_vllanmto).
    
    RETURN "OK".
END PROCEDURE.

PROCEDURE estorna-faturas.
    
    DEF INPUT  PARAM p-cooper            AS CHAR.
    DEF INPUT  PARAM p-cod-operador      AS char.
    DEF INPUT  PARAM p-cod-agencia       AS INTE.
    DEF INPUT  PARAM p-nro-caixa         AS INTE.
    DEF INPUT  PARAM p-codigo-barras     AS CHAR.
    DEF INPUT  PARAM p-cdseqfat          AS DEC.
   
    DEF OUTPUT PARAM p-histor            AS INTE.
    DEF OUTPUT PARAM p-pg                AS LOG.
    DEF OUTPUT PARAM p-docto             AS DEC.

    { sistema/generico/includes/var_oracle.i }

    DEF VAR aux_dsconsul  AS CHAR NO-UNDO.
    DEF VAR aux_dsmvtocd  AS CHAR NO-UNDO.
    DEF VAR aux_vllanmto  AS DECI NO-UNDO.
    DEF VAR aux_cdhistor  AS INTE NO-UNDO.
    DEF VAR aux_nrseqdig  AS INTE NO-UNDO.
    DEF VAR aux_insitfat  AS INTE NO-UNDO.
    DEF VAR aux_flgfatex  AS LOGI NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    /* Lote - 15000 --- Tipo 13 --- FATURAS ---*/
    ASSIGN i-nro-lote = 15000 + p-nro-caixa. 
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    DO  WHILE TRUE:
       
        FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapdat.dtmvtocd  AND
                           craplot.cdagenci = p-cod-agencia     AND
                           craplot.cdbccxlt = 11                AND  /* Fixo */
                           craplot.nrdolote = i-nro-lote       
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        IF   NOT AVAILABLE craplot   THEN  
          DO:
             IF   LOCKED craplot     THEN 
               DO:
                  PAUSE 1 NO-MESSAGE.
                  NEXT.
               END.
             ELSE 
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
          END.
        LEAVE.
    END.  /*  DO WHILE */

    ASSIGN aux_dsmvtocd = STRING(DAY(crapdat.dtmvtocd),"99")    +
                          STRING(MONTH(crapdat.dtmvtocd),"99")  +
                          STRING(YEAR(crapdat.dtmvtocd),"9999").

    ASSIGN aux_dsconsul = "SELECT craplft.vllanmto, '|', 
                                  craplft.insitfat, '|', 
                                  craplft.nrseqdig, '|', 
                                  craplft.cdhistor FROM craplft WHERE craplft.cdcooper = "  + STRING(crapcop.cdcooper)  + " AND " +
                                                                     "craplft.dtmvtolt = to_date('" + STRING(aux_dsmvtocd)     + "', 'dd/mm/yyyy') AND " +
                                                                     "craplft.cdagenci = "  + STRING(craplot.cdagenci)  + " AND " +
                                                                     "craplft.cdbccxlt = "  + STRING(craplot.cdbccxlt)  + " AND " +
                                                                     "craplft.nrdolote = "  + STRING(craplot.nrdolote)  + " AND " +
                                                                     "craplft.cdseqfat = "  + STRING(p-cdseqfat).

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement iHandle = PROC-HANDLE NO-ERROR(aux_dsconsul).

    FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = iHandle:

        IF  aux_vllanmto > 0 THEN
            NEXT.

        /* Registro existe */
        ASSIGN aux_flgfatex = TRUE
               aux_vllanmto = DECI(ENTRY(1, proc-text, "|"))
               aux_insitfat = INTE(ENTRY(2, proc-text, "|"))
               aux_nrseqdig = INTE(ENTRY(3, proc-text, "|"))
               aux_cdhistor = INTE(ENTRY(4, proc-text, "|")).
    END.
    
    CLOSE STORED-PROC send-sql-statement WHERE PROC-HANDLE = iHandle.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  NOT aux_flgfatex THEN
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

    /* Removido para consulta Oracle, pois DataServer não suporta as mais de 34 posições do campo cdseqfat - Lunelli
    DO WHILE TRUE:

        FIND   craplft WHERE 
               craplft.cdcooper = crapcop.cdcooper  AND
               craplft.dtmvtolt = crapdat.dtmvtocd  AND
               craplft.cdagenci = craplot.cdagenci  AND
               craplft.cdbccxlt = craplot.cdbccxlt  AND
               craplft.nrdolote = craplot.nrdolote  AND
               craplft.cdseqfat = p-cdseqfat  
               USE-INDEX craplft1  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
        IF    NOT AVAILABLE craplft THEN 
           DO:
              IF   LOCKED craplft   THEN 
                DO:
                   PAUSE 1 NO-MESSAGE.
                   NEXT.
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
      
       IF   craplft.insitfat <> 1 THEN 
          DO:
            ASSIGN i-cod-erro  = 103
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
          END.

       LEAVE.
    END.  /*  DO WHILE */ */
                
    ASSIGN craplot.vlcompcr = craplot.vlcompcr - (aux_vllanmto)
           craplot.qtcompln = craplot.qtcompln - 1

           craplot.vlinfocr = craplot.vlinfocr - (aux_vllanmto)
           craplot.qtinfoln = craplot.qtinfoln - 1.

    ASSIGN p-pg     = NO
           p-docto  = aux_nrseqdig
           p-histor = aux_cdhistor.
   
    /* Não existe mais cursor Progress da craplft - Lunelli 
    DELETE craplft. */

    ASSIGN aux_dsconsul = "DELETE FROM craplft WHERE craplft.cdcooper = "  + STRING(crapcop.cdcooper)  + " AND " +                                                    
                                                    "craplft.dtmvtolt = to_date('" + STRING(aux_dsmvtocd)     + "', 'dd/mm/yyyy') AND " +
                                                    "craplft.cdagenci = "  + STRING(craplot.cdagenci)  + " AND " +
                                                    "craplft.cdbccxlt = "  + STRING(craplot.cdbccxlt)  + " AND " +
                                                    "craplft.nrdolote = "  + STRING(craplot.nrdolote)  + " AND " +
                                                    "craplft.cdseqfat = "  + STRING(p-cdseqfat).

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement iHandle = PROC-HANDLE NO-ERROR(aux_dsconsul).

    FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = iHandle:
    END.
    
    CLOSE STORED-PROC send-sql-statement WHERE PROC-HANDLE = iHandle.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  craplot.vlcompdb = 0 and
        craplot.vlinfodb = 0 and
        craplot.vlcompcr = 0 and
        craplot.vlinfocr = 0 THEN
        DELETE craplot.
    ELSE
       RELEASE craplot.
    
    
    RETURN "OK".

END PROCEDURE.

/* b1crap15.p */

