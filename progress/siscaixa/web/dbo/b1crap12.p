/*-----------------------------------------------------------------------------

    b1crap12.p - Consistencias/ Atualizacao Fechamento Boletim Caixa
    
    Alteracoes:
                23/02/2006 - Unificacao dos bancos - SQLWorks - Eder    
                
                16/04/2010 - Criticar caso a crapcme nao foi criada na rotina
                             20 (TED/DOC) quando em especie nao-cooperado
                             e especie cooperado com valor > 10000 (Fernando).
                             
                19/05/2011 - Antes de verificar se o PAC fez as previas, 
                             verificar se o mesmo apresenta indisponibilidade
                             (Guilherme).
                           - Nao permite fechar caixa se haver cheques 
                              banco/caixa 500 nao digitalizados (Elton).
                             
                22/09/2011 - Incluir leitura do lote 30000 ref. Rotina 66
                             (Guilherme).
                             
                03/10/2011 - Remove arquivo contendo nome e usuario do 
                             computador no diretorio /usr/coop/ctr_ayllos 
                             quando fecha o caixa (Elton).
                            
                07/12/2011 - Tratamento para fechamento de caixa se houver 
                            deposito entre cooperativas (Elton). 
                            
                29/12/2011 - Tratar historico 1030 (Gabriel).             
                
                27/02/2012 - Alteracao para que todas as coops possam 
                             digitalizar cheques da propria cooperativa (ZE).
			    
				23/08/2016 - Agrupamento das informacoes (M36 - Kelvin).
				
				14/02/2017 - Ajustes para imprimir boletim de fechamento de
				             caixa corretamente pois imprimia como aberto
							 (Tiago/Elton SD584098)
               
        08/12/2017 - Melhoria 458, auste fechamento-boletim-caixa.
                    Antonio R. Jr (mouts)
------------------------------------------------------------------------------*/
{dbo/bo-erro1.i}

DEF VAR i-cod-erro      AS INTEGER.
DEF VAR c-desc-erro     AS CHAR.


DEF VAR aux_saldo_final AS DEC      FORMAT "zzz,zzz,zz9.99-"    NO-UNDO. 
DEF VAR r-crapbcx       AS ROWID                                NO-UNDO.

DEF VAR p-valor-credito AS DEC                                  NO-UNDO.
DEF VAR p-valor-debito  AS DEC                                  NO-UNDO.
DEF VAR de-diferenca    AS DEC                                  NO-UNDO.

DEF VAR  h-b2crap13     AS HANDLE                               NO-UNDO.
DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.

PROCEDURE retorna-dados-fechamento:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF OUTPUT PARAM p-autenticacoes AS INTE.
    DEF OUTPUT PARAM p-saldo-inicial AS DEC.
                                  
    DEF VAR i-autenticacoes AS INTE NO-UNDO.

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
                            USE-INDEX crapbcx1 NO-LOCK NO-ERROR. 
                            
    IF  NOT AVAIL crapbcx  THEN 
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
   
    ASSIGN i-autenticacoes = 0.
    
    FOR EACH crapaut WHERE crapaut.cdcooper = crapcop.cdcooper  AND
                           crapaut.cdagenci = p-cod-agencia     AND
                           crapaut.nrdcaixa = p-nro-caixa       AND 
                           crapaut.cdopecxa = p-cod-operador    AND
                           crapaut.dtmvtolt = crapdat.dtmvtolt  NO-LOCK:
                           
        ASSIGN i-autenticacoes = i-autenticacoes + 1.
    END.

    ASSIGN p-autenticacoes = i-autenticacoes
           p-saldo-inicial = crapbcx.vldsdini.

    RETURN "OK".

END PROCEDURE.

PROCEDURE fechamento-boletim-caixa:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-saldo-final   AS DEC.
    DEF INPUT  PARAM p-lacre         AS INTE.                             

    DEF VAR aux_vlctrmve        AS DECIMAL            NO-UNDO.
    DEF VAR i-nrseqdig          AS INTE               NO-UNDO.

    DEF VAR h-b1wgen0120        AS HANDLE             NO-UNDO.
    DEF VAR aux_flgsemhi        AS LOGI               NO-UNDO.
    DEF VAR aux_vlrttcrd        AS DECI               NO-UNDO.
    DEF VAR aux_vlrttdeb        AS DECI               NO-UNDO.
    DEF VAR aux_sdfinbol        LIKE crapbcx.vldsdfin NO-UNDO.
    DEF VAR aux_nmarqimp        AS CHAR               NO-UNDO.
    DEF VAR aux_nmarqpdf        AS CHAR               NO-UNDO.
    DEF VAR aux_vllimite        AS DECIMAL            NO-UNDO.
         
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
	
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
                                        
    FIND  LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper    AND
                             crapbcx.dtmvtolt = crapdat.dtmvtolt    AND
                             crapbcx.cdagenci = p-cod-agencia       AND
                             crapbcx.nrdcaixa = p-nro-caixa         AND
                             crapbcx.cdopecxa = p-cod-operador      AND
                             crapbcx.cdsitbcx = 1 
                             USE-INDEX crapbcx1  NO-LOCK NO-ERROR. 
                             
    IF  NOT AVAILABLE crapbcx   THEN 
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
    
    /* Calcula valores - Entrada - Saida -*/
    ASSIGN r-crapbcx = ROWID(crapbcx).
    RUN dbo/b2crap13.p PERSISTENT SET h-b2crap13. 

    FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapdat.dtmvtolt  AND
                           craplot.cdagenci = p-cod-agencia     AND
                          (craplot.cdbccxlt = 11                OR
                           craplot.cdbccxlt = 30                OR
                           craplot.cdbccxlt = 31                OR
                           craplot.cdbccxlt = 500)              AND
                           craplot.nrdcaixa = p-nro-caixa       AND
                           craplot.cdopecxa = p-cod-operador    NO-LOCK:
                           
        IF  craplot.qtcompln <> craplot.qtinfoln    OR
            craplot.vlcompcr <> craplot.vlinfocr    OR   
            craplot.vlcompdb <> craplot.vlinfodb    THEN 
            DO:
                ASSIGN i-cod-erro  = 139
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
    

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "GENERI"          AND
                       craptab.cdempres = 0                 AND
                       craptab.cdacesso = "VLCTRMVESP"      AND
                       craptab.tpregist = 0                 NO-LOCK NO-ERROR.
                       
    IF  AVAILABLE craptab   THEN
        ASSIGN aux_vlctrmve = DEC(craptab.dstextab).

    FOR EACH craplcm WHERE craplcm.cdcooper  = crapcop.cdcooper     AND
                           craplcm.dtmvtolt  = crapdat.dtmvtolt     AND
                           craplcm.cdagenci  = p-cod-agencia        AND
                           craplcm.cdbccxlt  = 11                   AND
                           craplcm.nrdolote  = 11000 + p-nro-caixa  AND
                          (craplcm.cdhistor  = 1                    OR
                           craplcm.cdhistor  = 21                   OR
                           craplcm.cdhistor  = 22                   OR
                           craplcm.cdhistor  = 1030)                AND
                           craplcm.vllanmto >= aux_vlctrmve         
                           USE-INDEX craplcm3 NO-LOCK:
        
        IF  craplcm.cdhistor = 21               AND
            craplcm.cdpesqbb begins "CRAP51"    THEN
            NEXT.

        FIND crapcme WHERE crapcme.cdcooper = crapcop.cdcooper      AND
                           crapcme.dtmvtolt = craplcm.dtmvtolt      AND
                           crapcme.cdagenci = craplcm.cdagenci      AND
                           crapcme.cdbccxlt = craplcm.cdbccxlt      AND
                           crapcme.nrdolote = craplcm.nrdolote      AND
                           crapcme.nrdctabb = craplcm.nrdctabb      AND
                           crapcme.nrdocmto = craplcm.nrdocmto       
                           NO-LOCK NO-ERROR.
         
        IF  NOT AVAILABLE crapcme   THEN
            DO:  
                ASSIGN i-cod-erro  = 768
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
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_consultar_parmon_pld_car
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapcop.cdcooper,
                                               OUTPUT 0,
                                               OUTPUT 0,
                                               OUTPUT 0,
                                               OUTPUT 0,
                                               OUTPUT 0,
                                               OUTPUT "").

    CLOSE STORED-PROC pc_consultar_parmon_pld_car
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_vllimite = pc_consultar_parmon_pld_car.pr_vlmonitoracao_pagamento.
    
    For each craplft where craplft.cdcooper = crapcop.cdcooper AND
                           Craplft.dtmvtolt = crapdat.dtmvtolt and
                           Craplft.cdagenci = p-cod-agencia and
                           Craplft.nrdolote = 15000 + p-nro-caixa and
                           Craplft.tppagmto = 1 and
                           Craplft.vllanmto >= aux_vllimite no-lock:
                           
           FIND crapcme WHERE crapcme.cdcooper = crapcop.cdcooper AND
                              crapcme.dtmvtolt = craplft.dtmvtolt AND
                              crapcme.cdagenci = craplft.cdagenci AND
                              crapcme.cdbccxlt = craplft.cdbccxlt AND
                              crapcme.nrdolote = craplft.nrdolote AND
                              crapcme.nrdctabb = craplft.nrdconta AND
                              crapcme.nrdocmto = craplft.nrseqdig
                              NO-LOCK NO-ERROR.
                              
          IF NOT AVAILABLE crapcme THEN
           DO:
              ASSIGN i-cod-erro = 768
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
    
    For each craptit where craptit.cdcooper = crapcop.cdcooper AND
                           Craptit.dtmvtolt = crapdat.dtmvtolt and
                           Craptit.cdagenci = p-cod-agencia and
                           Craptit.nrdolote = 16000 + p-nro-caixa and
                           Craptit.tppagmto = 1 and
                           Craptit.vldpagto >= aux_vllimite no-lock:
                           
         FIND crapcme WHERE crapcme.cdcooper = crapcop.cdcooper AND
                            crapcme.dtmvtolt = craptit.dtmvtolt AND
                            crapcme.cdagenci = craptit.cdagenci AND
                            crapcme.cdbccxlt = craptit.cdbccxlt AND
                            crapcme.nrdolote = craptit.nrdolote AND
                            crapcme.nrdctabb = craptit.nrdconta AND
                            crapcme.nrdocmto = craptit.nrseqdig
                            NO-LOCK NO-ERROR.
                            
        IF NOT AVAILABLE crapcme THEN
          DO:
            ASSIGN i-cod-erro = 768
                   c-desc-erro = "".
                   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
                           
                RETURN "NOK".
            END.
    END.

    /***********  Deposito entre cooperativas  ******************/
    FOR EACH craplcx WHERE  craplcx.cdcooper = crapcop.cdcooper AND
                            craplcx.dtmvtolt = crapdat.dtmvtolt AND
                            craplcx.cdagenci = p-cod-agencia    AND
                            craplcx.nrdcaixa = p-nro-caixa      AND
                            craplcx.cdopecxa = p-cod-operador   AND
                            craplcx.cdhistor = 1003             AND
                            craplcx.vldocmto >= aux_vlctrmve         
                            NO-LOCK:

        FIND LAST crapcme WHERE crapcme.cdcooper = crapcop.cdcooper      AND
                                crapcme.dtmvtolt = craplcx.dtmvtolt      AND
                                crapcme.cdagenci = craplcx.cdagenci      AND
                                crapcme.cdbccxlt = 11                    AND
                                crapcme.nrdolote = 11000 + p-nro-caixa   AND
                                crapcme.nrdocmto = craplcx.nrdocmto       
                                NO-LOCK NO-ERROR.
        IF  NOT AVAILABLE crapcme   THEN
            DO:                     
                ASSIGN i-cod-erro  = 768
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

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                       craptab.nmsistem = "CRED"           AND
                       craptab.tptabela = "GENERI"         AND
                       craptab.cdempres = 0                AND
                       craptab.cdacesso = "EXETRUNCAGEM"   AND
                       craptab.tpregist = p-cod-agencia
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE craptab THEN
         DO:      
             /* Se o PAC nao possuir registro de indisponibilidade ativa */
             IF NOT CAN-FIND(FIRST crapikx 
                             WHERE crapikx.cdcooper = crapcop.cdcooper AND
                                   crapikx.cdagenci = p-cod-agencia    AND
                                   crapikx.dtindisp = crapdat.dtmvtolt AND
                                   crapikx.flindisp = TRUE
                                   NO-LOCK) THEN
             DO:
                 /* verifica a situacao das previas */
                 IF  craptab.dstextab = "SIM"  THEN
                 DO:
                     FIND FIRST crapchd WHERE     
                                crapchd.cdcooper  = crapcop.cdcooper      AND
                                crapchd.dtmvtolt  = crapdat.dtmvtolt      AND
                                crapchd.cdagenci  = p-cod-agencia         AND
                              ((crapchd.cdbccxlt  = 11                    AND
                                crapchd.nrdolote  = 11000 + p-nro-caixa)   OR
                               (crapchd.cdbccxlt  = 11                    AND
                                crapchd.nrdolote  = 30000 + p-nro-caixa)   OR
                               (crapchd.cdbccxlt  = 500                   AND
                                crapchd.nrdolote  = 28000 + p-nro-caixa)) AND
                                crapchd.insitprv <= 1
                                USE-INDEX crapchd3 NO-LOCK NO-ERROR.

                     IF   AVAILABLE crapchd THEN
                          DO:
                              ASSIGN i-cod-erro  = 0
                                    c-desc-erro = "Ha cheques pendentes para" + 
                                                  " a realizacao da previa.".
                              RUN cria-erro (INPUT p-cooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT i-cod-erro,
                                             INPUT c-desc-erro,
                                             INPUT YES).
                              RETURN "NOK".
                          END.
                 END.
             END.
         END.
    ELSE
         DO:
             ASSIGN i-cod-erro  = 55
                    c-desc-erro = "".

             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
    FOR EACH craptvl WHERE (craptvl.cdcooper = crapcop.cdcooper     AND
                            craptvl.dtmvtolt = crapdat.dtmvtolt     AND
                            craptvl.cdagenci = p-cod-agencia        AND
                            craptvl.cdbccxlt = 11                   AND
          /* TED - SPB */   craptvl.nrdolote = 23000 + p-nro-caixa  AND
                            craptvl.flgespec = TRUE                    ) OR
                           (craptvl.cdcooper = crapcop.cdcooper     AND
                            craptvl.dtmvtolt = crapdat.dtmvtolt     AND
                            craptvl.cdagenci = p-cod-agencia        AND
                            craptvl.cdbccxlt = 11                   AND
           /* TED - BB */   craptvl.nrdolote = 21000 + p-nro-caixa  AND
                            craptvl.flgespec = TRUE                    ) OR
                           (craptvl.cdcooper = crapcop.cdcooper     AND
                            craptvl.dtmvtolt = crapdat.dtmvtolt     AND
                            craptvl.cdagenci = p-cod-agencia        AND
                            craptvl.cdbccxlt = 11                   AND
                /* DOC */   craptvl.nrdolote = 20000 + p-nro-caixa  AND
                            craptvl.flgespec = TRUE                    )
                            NO-LOCK:

        IF   craptvl.nrdconta <> 0   THEN
             DO:
                 FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                                    craptab.nmsistem = "CRED"           AND
                                    craptab.tptabela = "GENERI"         AND
                                    craptab.cdempres = 0                AND
                                    craptab.cdacesso = "VLCTRMVESP"     AND
                                    craptab.tpregist = 0   NO-LOCK NO-ERROR.

                 IF   AVAILABLE craptab AND 
                      craptvl.vldocrcb < DEC(craptab.dstextab)   THEN
                      NEXT.
             END.

        FIND crapcme WHERE crapcme.cdcooper = crapcop.cdcooper      AND
                           crapcme.dtmvtolt = craptvl.dtmvtolt      AND
                           crapcme.cdagenci = craptvl.cdagenci      AND
                           crapcme.cdbccxlt = craptvl.cdbccxlt      AND
                           crapcme.nrdolote = 11000 + p-nro-caixa   AND
                           crapcme.nrdctabb = craptvl.nrdconta      AND
                           crapcme.nrdocmto = craptvl.nrdocmto       
                           NO-LOCK NO-ERROR.
                                     
        IF  NOT AVAILABLE crapcme   THEN
            DO:
                ASSIGN i-cod-erro  = 768
                       c-desc-erro = " ".
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.

    END. /* Fim do FOR EACH - craptvl */
    
    RUN sistema/generico/procedures/b1wgen0120.p PERSISTENT 
             SET h-b1wgen0120.
    
    RUN Gera_Boletim IN h-b1wgen0120 (INPUT crapcop.cdcooper,       
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT 2,
                                      INPUT "CRAP012",
                                      INPUT crapdat.dtmvtolt,       
                                      INPUT STRING(RANDOM(1,10000)),
                                      INPUT YES, /* tipconsu */
                                      INPUT RECID(crapbcx),
                                     OUTPUT aux_flgsemhi,
                                     OUTPUT aux_sdfinbol,
                                     OUTPUT aux_vlrttcrd,
                                     OUTPUT aux_vlrttdeb,
                                     OUTPUT aux_nmarqimp,
                                     OUTPUT aux_nmarqpdf,
                                     OUTPUT TABLE tt-erro).
                                          
    DELETE PROCEDURE h-b1wgen0120.
    
    IF TEMP-TABLE tt-erro:HAS-RECORDS THEN 
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.  
       
          IF AVAIL tt-erro THEN
             DO:
                ASSIGN i-cod-erro  = tt-erro.cdcritic
                       c-desc-erro = tt-erro.dscritic.
                
                RUN cria-erro (INPUT crapcop.cdcooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
             END.
       END.
	
    ASSIGN p-valor-credito = aux_vlrttcrd
           p-valor-debito  = aux_vlrttdeb
           aux_saldo_final = crapbcx.vldsdini + p-valor-credito - p-valor-debito.
    
    IF  aux_saldo_final <> p-saldo-final  THEN 
        DO:
            ASSIGN de-diferenca = aux_saldo_final - p-saldo-final.
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Saldo Final nao Confere.."  +  
                                 TRIM(STRING(aux_saldo_final,
                                                    "zzz,zzz,zzz,zz9.99-"))+
                                 " Diferenca.." + 
                                 TRIM(STRING(de-diferenca,
                                                    "zzz,zzz,zzz,zz9.99-")).
                                              
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    IF  p-saldo-final <> 0  AND
        p-lacre        = 0  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Lacre deve ser Informado".           
        
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

PROCEDURE atualiza-fechamento:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-saldo-final   AS DEC.
    DEF INPUT  PARAM p-nro-lacre     AS INTE.
    DEF INPUT  PARAM p-autenticacoes AS INTE.
    
    DEF VAR h-b1wgen0120        AS HANDLE             NO-UNDO.
    DEF VAR aux_flgsemhi        AS LOGI               NO-UNDO.
    DEF VAR aux_vlrttcrd        AS DECI               NO-UNDO.
    DEF VAR aux_vlrttdeb        AS DECI               NO-UNDO.
    DEF VAR aux_sdfinbol        LIKE crapbcx.vldsdfin NO-UNDO.
    DEF VAR aux_nmarqimp        AS CHAR               NO-UNDO.
    DEF VAR aux_nmarqpdf        AS CHAR               NO-UNDO.
    DEF VAR aux_bcxrecid        AS RECID              NO-UNDO.
    
/*  Esta Sendo alterado pelo ELTON
    DEF INPUT  PARAM p-username      AS CHAR.
    DEF INPUT  PARAM p-compname      AS CHAR. */
  
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND  LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper    AND
                             crapbcx.dtmvtolt = crapdat.dtmvtolt    AND
                             crapbcx.cdagenci = p-cod-agencia       AND
                             crapbcx.nrdcaixa = p-nro-caixa         AND
                             crapbcx.cdopecxa = p-cod-operador      AND
                             crapbcx.cdsitbcx = 1                   NO-ERROR. 
              
    IF  NOT AVAIL crapbcx  THEN 
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
                        
    ASSIGN crapbcx.cdsitbcx  = 2
           crapbcx.hrfecbcx  = TIME
           crapbcx.nrdlacre  = p-nro-lacre
           crapbcx.qtautent  = p-autenticacoes
           crapbcx.vldsdfin  = p-saldo-final.
    
    /* - Impressao Boletim Caixa --*/
    ASSIGN r-crapbcx    = ROWID(crapbcx)
           aux_bcxrecid = RECID(crapbcx).
           
    RELEASE crapbcx.
    
    RUN sistema/generico/procedures/b1wgen0120.p PERSISTENT 
             SET h-b1wgen0120.
    
    RUN Gera_Boletim IN h-b1wgen0120 (INPUT crapcop.cdcooper,       
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT 2,
                                      INPUT "CRAP012",
                                      INPUT crapdat.dtmvtolt,       
                                      INPUT STRING(RANDOM(1,10000)),
                                      INPUT NO, /* tipconsu */
                                      INPUT aux_bcxrecid,
                                     OUTPUT aux_flgsemhi,
                                     OUTPUT aux_sdfinbol,
                                     OUTPUT aux_vlrttcrd,
                                     OUTPUT aux_vlrttdeb,
                                     OUTPUT aux_nmarqimp,
                                     OUTPUT aux_nmarqpdf,
                                     OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0120.
    
    IF TEMP-TABLE tt-erro:HAS-RECORDS THEN 
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.  

          IF AVAIL tt-erro THEN

             DO:
                ASSIGN i-cod-erro  = tt-erro.cdcritic
                       c-desc-erro = tt-erro.dscritic.
                
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
             END.
       END.
    
    ASSIGN p-valor-credito = aux_vlrttcrd
           p-valor-debito  = aux_vlrttdeb.
    
/*  Esta sendo alterado pelo ELTON
    UNIX SILENT VALUE ("rm /usr/coop/ctr_ayllos/" + p-username + "." + 
                       p-compname). */

    RETURN "OK".       

END PROCEDURE.

/* .......................................................................... */
