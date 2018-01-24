/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0135.p
    Autor(a): Fabricio
    Data    : Fevereiro/2012                     Ultima atualizacao: 29/02/2016
  
    Dados referentes ao programa:
  
    Objetivo  : BO com regras de negocio refente a tela TRAESP.
                
  
    Alteracoes: 13/11/2013 - Nova forma de chamar as ag?ncias, de PAC agora 
                             a escrita será PA (Guilherme Gielow) 
                             
                29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
                             solicitado no chamado 402159 (Kelvin).
                             
                02/05/2016 - Ajuste na tela onde estava duplicando registros
                             na opcao "P", conforme solicitado no chamado 434404.
                             (Kelvin)                             
                             
                23/06/2016 - Ajuste na rotina consulta-transacoes-sem-documento
                             para resolver o problema referente o chamado 467402. (Kelvin)
                
                04/12/2017 - Melhoria 458 adicionado informacao do CPF a tela Traesp, Antonio R. Junior (mouts)             
.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgen0135tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR aux_cdcritic AS INTE NO-UNDO.
DEF VAR aux_dscritic AS CHAR NO-UNDO.
DEF VAR aux_nrregist AS INTE NO-UNDO.

DEF QUERY q-crapcme FOR crapcme.

PROCEDURE consulta-transacoes-especie:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE NO-UNDO.

    DEF OUTPUT PARAM par_contador AS INT NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-transacoes-especie.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_query    AS CHAR NO-UNDO.
    DEF VAR aux_tpoperac AS CHAR NO-UNDO.
    
    EMPTY TEMP-TABLE tt-transacoes-especie.

    ASSIGN aux_nrregist = par_nrregist.
    
    FOR EACH crapcme WHERE crapcme.cdcooper = par_cdcooper  AND
                         ((crapcme.nrdconta = par_nrdconta  AND
                           par_nrdconta <> 0)               OR
                           par_nrdconta = 0)                AND
                         ((crapcme.dtmvtolt >= par_dtmvtolt AND
                           par_dtmvtolt <> ?)               OR
                           par_dtmvtolt = ?)
                           NO-LOCK BY crapcme.cdagenci
                                   BY crapcme.nrdconta:
        
        ASSIGN par_contador = par_contador + 1.
        
        /* controles da paginaç?o */
        IF (par_contador < par_nriniseq) OR
           (par_contador > (par_nriniseq + par_nrregist)) THEN
            NEXT.

        IF aux_nrregist > 0 THEN
        DO:
            FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = crapcme.nrdconta
                                                  USE-INDEX crapass1
                                                  NO-LOCK NO-ERROR.
             
            IF crapcme.tpoperac = 1 THEN
                ASSIGN aux_tpoperac = "DEPOSITO".
            ELSE
            IF crapcme.tpoperac = 2 THEN
                ASSIGN aux_tpoperac = "SAQUE".
            ELSE
                ASSIGN aux_tpoperac = "PAGAMENTO".

            CREATE tt-transacoes-especie.
            ASSIGN tt-transacoes-especie.cdagenci = STRING(crapcme.cdagenci, "999")
                   tt-transacoes-especie.nrdolote = crapcme.nrdolote
                   tt-transacoes-especie.nrdconta = 
                    STRING(crapcme.nrdconta, "zzzz,zzz,9")
                   tt-transacoes-especie.vllanmto = 
                    STRING(crapcme.vllanmto, "zzz,zzz,zz9.99")
                   tt-transacoes-especie.nrdocmto = 
                                    STRING(crapcme.nrdocmto, "zz,zzz,zz9")
                   tt-transacoes-especie.dtmvtolt = crapcme.dtmvtolt
                   tt-transacoes-especie.tpoperac = aux_tpoperac
                   tt-transacoes-especie.sisbacen = crapcme.sisbacen.
            
            IF AVAIL crapass THEN
                ASSIGN tt-transacoes-especie.nmprimtl = TRIM(SUBSTR(crapass.nmprimtl,1,10)).
            
        END.

        ASSIGN aux_nrregist = aux_nrregist - 1.

    END.

    IF par_contador = 0 THEN
    DO:
        ASSIGN aux_cdcritic = 011
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,     /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".


END PROCEDURE.

PROCEDURE consulta-transacoes-sem-documento:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE NO-UNDO.

    DEF OUTPUT PARAM par_contador AS INT NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-transacoes-especie.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VARIABLE    aux_vlctrmve AS DECI NO-UNDO.
    DEF VARIABLE    aux_vllimite AS DECI NO-UNDO.
    DEF VARIABLE    aux_tpoperac AS CHAR NO-UNDO.
    DEF VARIABLE    aux_nrdolote AS INTE NO-UNDO.
    DEF VARIABLE    aux_regexist AS LOGI NO-UNDO.

    ASSIGN aux_nrregist = par_nrregist.
    
    EMPTY TEMP-TABLE tt-transacoes-especie.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "VLCTRMVESP" AND
                       craptab.tpregist = 0            NO-LOCK NO-ERROR.

    IF AVAILABLE craptab THEN
        ASSIGN aux_vlctrmve = DEC(craptab.dstextab).                         
    ELSE
        ASSIGN aux_vlctrmve = 0.

    FOR EACH crapbcx WHERE crapbcx.cdcooper = par_cdcooper AND
                           crapbcx.dtmvtolt = par_dtmvtolt AND
                           crapbcx.cdagenci = par_cdagenci NO-LOCK
                           BY crapbcx.dtmvtolt:

        FOR EACH craplcm WHERE 
                 craplcm.cdcooper = par_cdcooper              AND
                 craplcm.dtmvtolt = par_dtmvtolt              AND
                 craplcm.cdagenci = par_cdagenci              AND
                 craplcm.cdbccxlt = 11                        AND
                 craplcm.nrdolote = 11000 + crapbcx.nrdcaixa  AND
                (craplcm.cdhistor = 1                         OR     
                 craplcm.cdhistor = 21                        OR        
                 craplcm.cdhistor = 22                        OR
                 craplcm.cdhistor = 1030)                     AND
                 craplcm.vllanmto >= aux_vlctrmve USE-INDEX craplcm3 NO-LOCK
                 BY craplcm.dtmvtolt:
                       
            IF craplcm.cdhistor = 21 AND craplcm.cdpesqbb BEGINS "CRAP51" THEN
                NEXT.
                    
            FIND crapcme WHERE crapcme.cdcooper = par_cdcooper       AND
                               crapcme.dtmvtolt = craplcm.dtmvtolt   AND
                               crapcme.cdagenci = craplcm.cdagenci   AND
                               crapcme.cdbccxlt = craplcm.cdbccxlt   AND
                               crapcme.nrdolote = craplcm.nrdolote   AND
                               crapcme.nrdctabb = craplcm.nrdctabb   AND
                               crapcme.nrdocmto = craplcm.nrdocmto   
                               NO-LOCK NO-ERROR.

            IF NOT AVAILABLE crapcme THEN  
                DO:
                    ASSIGN par_contador = par_contador + 1.
        
                    /* controles da paginaç?o */
                    IF (par_contador < par_nriniseq) OR
                       (par_contador > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF aux_nrregist > 0 THEN
                    DO:
                        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                           crapass.nrdconta = craplcm.nrdconta
                                           NO-LOCK NO-ERROR.
                                
                        FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                                           craphis.cdhistor = craplcm.cdhistor
                                           NO-LOCK NO-ERROR.
                                
                        ASSIGN aux_tpoperac = "".
    
                        IF craphis.indebcre = "C" THEN
                            aux_tpoperac = "DEPOSITO".
                        ELSE
                        IF craphis.indebcre = "D" THEN
                            aux_tpoperac = "SAQUE".
    
                        CREATE tt-transacoes-especie.
                        ASSIGN tt-transacoes-especie.cdagenci = 
                                                STRING(craplcm.cdagenci, "999")
                               tt-transacoes-especie.nrdolote = craplcm.nrdolote
                               tt-transacoes-especie.nrdconta = 
                                           STRING(craplcm.nrdconta, "zzzz,zzz,9")
                               tt-transacoes-especie.nmprimtl = crapass.nmprimtl
                                                                WHEN AVAIL crapass
                               tt-transacoes-especie.nrdocmto = 
                                            STRING(craplcm.nrdocmto, "zz,zzz,zz9")
                               tt-transacoes-especie.tpoperac = aux_tpoperac
                               tt-transacoes-especie.vllanmto = 
                                         STRING(craplcm.vllanmto, "zzz,zzz,zz9.99")
                               tt-transacoes-especie.dtmvtolt = craplcm.dtmvtolt.
                    END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.
 
                END.
        END.

        FOR EACH craptvl WHERE (craptvl.cdcooper = par_cdcooper             AND
                                craptvl.dtmvtolt = par_dtmvtolt             AND
                                craptvl.cdagenci = par_cdagenci             AND
                                craptvl.cdbccxlt = 11                       AND
              /* TED - SPB */   craptvl.nrdolote = 23000 + crapbcx.nrdcaixa AND
                                craptvl.flgespec = TRUE                    ) OR
                               (craptvl.cdcooper = par_cdcooper             AND
                                craptvl.dtmvtolt = par_dtmvtolt             AND
                                craptvl.cdagenci = par_cdagenci             AND
                                craptvl.cdbccxlt = 11                       AND
               /* TED - BB */   craptvl.nrdolote = 21000 + crapbcx.nrdcaixa AND
                                craptvl.flgespec = TRUE                    ) OR
                               (craptvl.cdcooper = par_cdcooper             AND
                                craptvl.dtmvtolt = par_dtmvtolt             AND
                                craptvl.cdagenci = par_cdagenci             AND
                                craptvl.cdbccxlt = 11                       AND
                    /* DOC */   craptvl.nrdolote = 20000 + crapbcx.nrdcaixa AND
                                craptvl.flgespec = TRUE                    )
                                NO-LOCK BY craptvl.dtmvtolt:

            IF craptvl.nrdconta <> 0 THEN
                DO:
                    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                                       craptab.nmsistem = "CRED"           AND
                                       craptab.tptabela = "GENERI"         AND
                                       craptab.cdempres = 0                AND
                                       craptab.cdacesso = "VLCTRMVESP"     AND
                                       craptab.tpregist = 0   NO-LOCK NO-ERROR.
                    
                    IF AVAILABLE craptab AND 
                                 craptvl.vldocrcb < DEC(craptab.dstextab) THEN
                        NEXT.
                END.

            FIND crapcme WHERE crapcme.cdcooper = par_cdcooper             AND
                               crapcme.dtmvtolt = craptvl.dtmvtolt         AND
                               crapcme.cdagenci = craptvl.cdagenci         AND
                               crapcme.cdbccxlt = craptvl.cdbccxlt         AND
                               crapcme.nrdolote = 11000 + crapbcx.nrdcaixa AND
                               crapcme.nrdctabb = craptvl.nrdconta         AND
                               crapcme.nrdocmto = craptvl.nrdocmto 
                               NO-LOCK NO-ERROR.

            IF NOT AVAILABLE crapcme THEN  
                DO:
                    ASSIGN par_contador = par_contador + 1.
        
                    /* controles da paginaç?o */
                    IF (par_contador < par_nriniseq) OR
                       (par_contador > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF aux_nrregist > 0 THEN
                    DO:
                        FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                           crapass.nrdconta = craptvl.nrdconta 
                                           NO-LOCK NO-ERROR.
                                
                        ASSIGN aux_tpoperac = "SAQUE"
                               aux_nrdolote = 11000 + crapbcx.nrdcaixa.
    
                        CREATE tt-transacoes-especie.
                        ASSIGN tt-transacoes-especie.cdagenci = 
                                            STRING(craptvl.cdagenci, "999")
                               tt-transacoes-especie.nrdolote = aux_nrdolote
                               tt-transacoes-especie.nrdconta = 
                                            STRING(craptvl.nrdconta, "zzzz,zzz,9")
                               tt-transacoes-especie.nmprimtl = crapass.nmprimtl
                                                                WHEN AVAIL crapass
                               tt-transacoes-especie.nrdocmto = 
                                            STRING(craptvl.nrdocmto, "zz,zzz,zz9")
                               tt-transacoes-especie.tpoperac = aux_tpoperac
                               tt-transacoes-especie.vllanmto = 
                                         STRING(craptvl.vldocrcb, "zzz,zzz,zz9.99")
                               tt-transacoes-especie.dtmvtolt = craptvl.dtmvtolt.
                    END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.
 
                END.                                       
        END.
                           
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }          
          /* Efetuar a chamada a rotina Oracle */ 
          RUN STORED-PROCEDURE pc_consultar_parmon_pld_car
           aux_handproc = PROC-HANDLE NO-ERROR 
                       ( INPUT par_cdcooper /* pr_cdcooper --> Codigo da cooperativa */                                             
                        /* --------- OUT --------- */
                        ,OUTPUT 0          /* pr_vllimite --> Retorno da operacao     */
                        ,OUTPUT 0          /* pr_vlcredito_diario_pf --> Retorno da operacao     */
                        ,OUTPUT 0          /* pr_vlcredito_diario_pj --> Retorno da operacao     */
                        ,OUTPUT 0          /* pr_cdcritic --> Codigo da critica  */
                        ,OUTPUT 0
                        ,OUTPUT "" ).      /* pr_dscritic --> Descriçao da critica    */
          
          /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_consultar_parmon_pld_car
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN aux_vllimite = pc_consultar_parmon_pld_car.pr_vllimite
                     WHEN pc_consultar_parmon_pld_car.pr_vllimite <> ?.
          
          FOR EACH craplft WHERE
               craplft.cdcooper = par_cdcooper AND
               craplft.dtmvtolt = par_dtmvtolt AND
               craplft.cdagenci = par_cdagenci AND
               craplft.cdbccxlt = 11 AND
               craplft.nrdolote = 15000 + crapbcx.nrdcaixa AND
               craplft.tppagmto = 1 AND /*** Pagamento em espécie ***/
               craplft.vllanmto >= aux_vllimite NO-LOCK
               BY craplft.dtmvtolt:

               FIND crapcme WHERE crapcme.cdcooper = par_cdcooper AND
                    crapcme.dtmvtolt = craplft.dtmvtolt AND
                    crapcme.cdagenci = craplft.cdagenci AND
                    crapcme.cdbccxlt = craplft.cdbccxlt AND
                    crapcme.nrdolote = craplft.nrdolote AND
                    crapcme.nrdctabb = craplft.nrdconta AND
                    crapcme.nrdocmto = craplft.nrseqdig
                    NO-LOCK NO-ERROR.
               
               IF NOT AVAILABLE crapcme THEN
                 DO:
                  ASSIGN par_contador = par_contador + 1.

                  /* controles da paginaçao */
                  IF (par_contador < par_nriniseq) OR
                     (par_contador > (par_nriniseq + par_nrregist)) THEN
                     NEXT.
                   
                  IF aux_nrregist > 0 THEN
                   DO:
                       FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                          crapass.nrdconta = craplft.nrdconta
                                          NO-LOCK NO-ERROR.

                       ASSIGN aux_tpoperac = "PAGAMENTO".
                    
                       CREATE tt-transacoes-especie.
                       ASSIGN tt-transacoes-especie.cdagenci = STRING(craplft.cdagenci, "999")
                              tt-transacoes-especie.nrdolote = craplft.nrdolote
                              tt-transacoes-especie.nrdconta = STRING(craplft.nrdconta, "zzzz,zzz,9")
                              tt-transacoes-especie.nmprimtl = crapass.nmprimtl WHEN AVAIL crapass
                              tt-transacoes-especie.nrdocmto = STRING(craplft.nrseqdig, "zz,zzz,zz9")
                              tt-transacoes-especie.tpoperac = aux_tpoperac
                              tt-transacoes-especie.vllanmto = STRING(craplft.vllanmto, "zzz,zzz,zz9.99")
                              tt-transacoes-especie.dtmvtolt = craplft.dtmvtolt.
        END.
                    
                   ASSIGN aux_nrregist = aux_nrregist - 1.
                 END.
          END.

          FOR EACH craptit WHERE
                   craptit.cdcooper = par_cdcooper AND
                   craptit.dtmvtolt = par_dtmvtolt AND
                   craptit.cdagenci = par_cdagenci AND
                   craptit.cdbccxlt = 11 AND
                   craptit.nrdolote = 16000 + crapbcx.nrdcaixa AND
                   craptit.tppagmto = 1 AND
                   craptit.vldpagto >= aux_vllimite NO-LOCK
                   BY craptit.dtmvtolt:

               FIND crapcme WHERE crapcme.cdcooper = par_cdcooper AND
                    crapcme.dtmvtolt = craptit.dtmvtolt AND
                    crapcme.cdagenci = craptit.cdagenci AND
                    crapcme.cdbccxlt = craptit.cdbccxlt AND
                    crapcme.nrdolote = craptit.nrdolote AND
                    crapcme.nrdctabb = craptit.nrdconta AND
                    crapcme.nrdocmto = craptit.nrseqdig
                    NO-LOCK NO-ERROR.
               
               IF NOT AVAILABLE crapcme THEN
                DO:
                  ASSIGN par_contador = par_contador + 1.

                  /* controles da paginaçao */
                  IF (par_contador < par_nriniseq) OR
                     (par_contador > (par_nriniseq + par_nrregist)) THEN
                      NEXT.
                  IF aux_nrregist > 0 THEN
                   DO:
                     FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                          crapass.nrdconta = craptit.nrdconta
                          NO-LOCK NO-ERROR.

                     ASSIGN aux_tpoperac = "PAGAMENTO".
                     
                     CREATE tt-transacoes-especie.
                     ASSIGN tt-transacoes-especie.cdagenci = STRING(craptit.cdagenci, "999")
                            tt-transacoes-especie.nrdolote = craptit.nrdolote
                            tt-transacoes-especie.nrdconta = STRING(craptit.nrdconta, "zzzz,zzz,9")
                            tt-transacoes-especie.nmprimtl = crapass.nmprimtl WHEN AVAIL crapass
                            tt-transacoes-especie.nrdocmto = STRING(craptit.nrseqdig, "zz,zzz,zz9")
                            tt-transacoes-especie.tpoperac = aux_tpoperac
                            tt-transacoes-especie.vllanmto = STRING(craptit.vldpagto, "zzz,zzz,zz9.99")
                            tt-transacoes-especie.dtmvtolt = craptit.dtmvtolt.
                   END.
                    
                   ASSIGN aux_nrregist = aux_nrregist - 1.
                  
                END.
          END.
                       
    END.

        /* Transferencia intercooperativa */
        FOR EACH craplcx WHERE craplcx.cdcooper = par_cdcooper  AND
                               craplcx.dtmvtolt = par_dtmvtolt  AND
                               craplcx.cdagenci = par_cdagenci  AND 
                               craplcx.cdhistor = 1003          NO-LOCK
                               BY craplcx.dtmvtolt:

            FIND FIRST crapcme WHERE 
                              crapcme.cdcooper = par_cdcooper             AND
                              crapcme.dtmvtolt = craplcx.dtmvtolt         AND
                              crapcme.cdagenci = craplcx.cdagenci         AND
                              crapcme.cdbccxlt = 11                       AND
                              crapcme.nrdolote = 11000 + craplcx.nrdcaixa AND
                              crapcme.nrdocmto = craplcx.nrdocmto   
                              NO-LOCK NO-ERROR.

            IF AVAIL crapcme THEN
                NEXT.

            ASSIGN par_contador = par_contador + 1.
        
            /* controles da paginaç?o */
            IF (par_contador < par_nriniseq) OR
               (par_contador > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF aux_nrregist > 0 THEN
            DO:
                ASSIGN aux_tpoperac = "SAQUE"
                       aux_nrdolote = 11000 + craplcx.nrdcaixa.
    
                CREATE tt-transacoes-especie.
                ASSIGN tt-transacoes-especie.cdagenci = 
                                         STRING(craplcx.cdagenci, "999")
                       tt-transacoes-especie.nrdolote = aux_nrdolote
                       tt-transacoes-especie.nrdocmto = 
                                         STRING(craplcx.nrdocmto, "zz,zzz,zz9")
                       tt-transacoes-especie.tpoperac = aux_tpoperac
                       tt-transacoes-especie.vllanmto = 
                                         STRING(craplcx.vldocmto, "zzz,zzz,zz9.99")
                       tt-transacoes-especie.dtmvtolt = craplcx.dtmvtolt.
            END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.
                                   
    IF par_contador = 0 THEN
        DO:
            ASSIGN aux_cdcritic = 011
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
                    
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE consulta-controle-movimentacao:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-transacoes-especie.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_tpoperac AS CHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-transacoes-especie.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
    DO:
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,     /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    FIND FIRST crapcme WHERE crapcme.cdcooper = par_cdcooper AND 
                             crapcme.dtmvtolt = par_dtmvtolt AND
                             crapcme.cdagenci = par_cdagenci AND
                             crapcme.cdbccxlt = par_cdbccxlt AND
                             crapcme.nrdolote = par_nrdolote AND
                             crapcme.nrdocmto = par_nrdocmto AND
                           ((crapcme.nrdconta = par_nrdconta AND
                             par_nrdconta <> 0)              OR
                             par_nrdconta = 0)
                             NO-LOCK NO-ERROR.

    IF NOT AVAILABLE crapcme THEN
    DO:
        ASSIGN aux_cdcritic = 11 /* Lancamentos nao encontrados */
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,     /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    
    END.
     
    IF crapcme.nrdconta <> 0 THEN
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = crapcme.nrdconta  
                           NO-LOCK NO-ERROR.

    IF crapcme.tpoperac = 1 THEN
        ASSIGN aux_tpoperac = "DEPOSITO".
    ELSE
    IF crapcme.tpoperac = 2 THEN
        ASSIGN aux_tpoperac = "SAQUE".
    ELSE
        ASSIGN aux_tpoperac = "PAGAMENTO".

    CREATE tt-transacoes-especie.
    ASSIGN tt-transacoes-especie.cdagenci = STRING(crapcme.cdagenci, "999")
           tt-transacoes-especie.nrdolote = crapcme.nrdolote
           tt-transacoes-especie.nrdconta = 
                                        STRING(crapcme.nrdconta, "zzzz,zzz,9")
           tt-transacoes-especie.nmprimtl = crapass.nmprimtl WHEN AVAIL crapass
           tt-transacoes-especie.vllanmto = 
                                     STRING(crapcme.vllanmto, "zzz,zzz,zz9.99")
           tt-transacoes-especie.nrdocmto = 
                                        STRING(crapcme.nrdocmto, "zz,zzz,zz9")
           tt-transacoes-especie.dtmvtolt = crapcme.dtmvtolt
           tt-transacoes-especie.tpoperac = aux_tpoperac
           tt-transacoes-especie.sisbacen = crapcme.sisbacen
           tt-transacoes-especie.nmrescop = crapcop.nmrescop
           tt-transacoes-especie.cdopecxa = crapcme.cdopecxa
           tt-transacoes-especie.nrdcaixa = crapcme.nrdcaixa
           tt-transacoes-especie.nrseqaut = crapcme.nrseqaut
           tt-transacoes-especie.nrdctabb = crapcme.nrdctabb.

    RETURN "OK".

END PROCEDURE.

PROCEDURE reimprime-controle-movimentacao:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmrescop AS CHAR NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdopecxa AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE NO-UNDO.
    DEF INPUT PARAM par_tpdocmto AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrseqaut AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdctabb AS INTE NO-UNDO.
    DEF INPUT PARAM par_tpoperac AS INTE NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_data_inf AS INTE   NO-UNDO.
    DEF VAR h_bo_depos   AS HANDLE NO-UNDO.
    DEF VAR h_bo_saque   AS HANDLE NO-UNDO.
    DEF VAR aux_impresso AS LOGI   NO-UNDO.

    ASSIGN aux_impresso = (par_idorigem = 1).
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
    DO:
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,     /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    ASSIGN aux_data_inf = INTE(STRING(DAY(par_dtmvtolt),"99") +
                      STRING(MONTH(par_dtmvtolt),"99") +
                      STRING(YEAR(par_dtmvtolt),"9999")).
    
    IF par_tpoperac = 1 OR 
       par_tpoperac = 3 THEN
    DO:
        RUN dbo/bo_controla_depositos.p PERSISTENT SET h_bo_depos.

        RUN bo_imp_ctr_depositos IN h_bo_depos(INPUT par_nmrescop,
                                               INPUT par_cdopecxa, 
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_nrdolote,  
                                               INPUT par_nrseqaut,  
                                               INPUT aux_impresso,
                                               INPUT aux_data_inf,
                                              OUTPUT par_nmarqimp).

        DELETE PROCEDURE h_bo_depos.
        
        IF RETURN-VALUE = "NOK" THEN
        DO:
            FIND LAST craperr WHERE craperr.cdcooper = par_cdcooper AND
                                    craperr.cdagenci = par_cdagenci AND
                                    craperr.nrdcaixa = par_nrdcaixa
                                    NO-LOCK NO-ERROR.

            IF AVAIL craperr THEN
            DO:
                ASSIGN aux_cdcritic = craperr.cdcritic
                       aux_dscritic = craperr.dscritic.

                RUN gera_erro (INPUT craperr.cdcooper,
                               INPUT craperr.cdagenci,
                               INPUT craperr.nrdcaixa,
                               INPUT 1,     /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            END.

            RETURN "NOK".
        END.
    END.
    ELSE
    DO:
        FIND craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                           craplcm.dtmvtolt = par_dtmvtolt AND
                           craplcm.cdagenci = par_cdagenci AND
                           craplcm.cdbccxlt = par_cdbccxlt AND
                           craplcm.nrdolote = par_nrdolote AND
                           craplcm.nrdctabb = par_nrdctabb AND
                           craplcm.nrdocmto = par_nrdocmto
                           NO-LOCK NO-ERROR.

        IF AVAILABLE craplcm THEN
        DO:
            RUN dbo/bo_controla_saques.p PERSISTENT SET h_bo_saque.

            RUN bo_imp_ctr_saques IN h_bo_saque(INPUT par_nmrescop,
                                                INPUT par_cdopecxa, 
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_nrdolote,
                                                INPUT par_nrdocmto,
                                                INPUT par_nrseqaut,  
                                                INPUT aux_impresso,
                                                INPUT aux_data_inf,
                                                INPUT FALSE,
                                                INPUT par_cdopecxa,
                                               OUTPUT par_nmarqimp).

            DELETE PROCEDURE h_bo_saque.

            IF RETURN-VALUE = "NOK" THEN
            DO:
                FIND LAST craperr WHERE craperr.cdcooper = par_cdcooper AND
                                        craperr.cdagenci = par_cdagenci AND
                                        craperr.nrdcaixa = par_nrdcaixa
                                        NO-LOCK NO-ERROR.

                IF AVAIL craperr THEN
                DO:
                    ASSIGN aux_cdcritic = craperr.cdcritic
                           aux_dscritic = craperr.dscritic.

                    RUN gera_erro (INPUT craperr.cdcooper,
                                   INPUT craperr.cdagenci,
                                   INPUT craperr.nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                END.

                RETURN "NOK".

            END.
        END.
        ELSE
        DO:
            FIND craptvl WHERE craptvl.cdcooper = par_cdcooper AND
                               craptvl.tpdoctrf = par_tpdocmto AND
                               craptvl.nrdocmto = par_nrdocmto
                               NO-LOCK NO-ERROR.
                  
            IF NOT AVAILABLE craptvl THEN
            DO:
                ASSIGN aux_cdcritic = 90
                       aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,     /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
                        
            END.

            RUN dbo/bo_controla_saques.p PERSISTENT SET h_bo_saque.

            RUN bo_imp_ctr_saques IN h_bo_saque(INPUT par_nmrescop,
                                                INPUT par_cdopecxa, 
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_nrdolote,
                                                INPUT par_nrdocmto,
                                                INPUT par_nrseqaut,  
                                                INPUT aux_impresso,
                                                INPUT aux_data_inf,
                                                INPUT TRUE,
                                                INPUT par_cdopecxa,
                                               OUTPUT par_nmarqimp).
            DELETE PROCEDURE h_bo_saque.
            
            IF RETURN-VALUE = "NOK" THEN
            DO:
                FIND LAST craperr WHERE craperr.cdcooper = par_cdcooper AND
                                        craperr.cdagenci = par_cdagenci AND
                                        craperr.nrdcaixa = par_nrdcaixa
                                        NO-LOCK NO-ERROR.

                IF AVAIL craperr THEN
                DO:
                    ASSIGN aux_cdcritic = craperr.cdcritic
                           aux_dscritic = craperr.dscritic.

                    RUN gera_erro (INPUT craperr.cdcooper,
                                   INPUT craperr.cdagenci,
                                   INPUT craperr.nrdcaixa,
                                   INPUT 1,     /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                END.

                RETURN "NOK".
            END.
        END.
    END.

    IF par_idorigem = 5 THEN /* Ayllos Web */
    DO:
        ASSIGN par_nmarqpdf = "/usr/coop/" + crapcop.dsdircop + 
                                         "/arq/controle_movimentacao.pdf".
    
        RUN gera_impressao (INPUT par_cdcooper,
                            INPUT par_nmarqimp,
                            INPUT-OUTPUT par_nmarqpdf,
                            OUTPUT aux_dscritic).

        IF aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 0,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE imprime-listagem-transacoes:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsagenci AS CHAR    FORMAT "x(20)"                    NO-UNDO.
    DEF VAR aux_cdocpttl AS LOGICAL                                   NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                      NO-UNDO.

    DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                    INIT ["DEP. A VISTA   ","CAPITAL        ",
                                          "EMPRESTIMOS    ","DIGITACAO      ",
                                          "GENERICO       "]          NO-UNDO.

    DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 1           NO-UNDO.
    DEF VAR rel_nmrescop AS CHAR                                      NO-UNDO.
    DEF VAR rel_nmempres AS CHAR                                      NO-UNDO.
    DEF VAR rel_dsagenci AS CHAR    FORMAT "x(21)"                    NO-UNDO.
    DEF VAR rel_nrmodulo AS INT     FORMAT "9"                        NO-UNDO.
    DEF VAR rel_nmdestin AS CHAR                                      NO-UNDO.

    DEF VAR rel_nrcpfcgc AS CHAR                                      NO-UNDO.
    DEF VAR rel_nrcpfstl AS CHAR                                      NO-UNDO.
    DEF VAR rel_cpfcgdst AS CHAR                                      NO-UNDO.
    DEF VAR rel_cpfcgrcb AS CHAR                                      NO-UNDO.

    DEF VAR aux_tpoperac AS CHAR                                      NO-UNDO.
    DEF VAR aux_dtaltera AS DATE                                      NO-UNDO.
    DEF VAR aux_dsocpttl AS CHAR                                      NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                      NO-UNDO.
    DEF VAR aux_inpolexp AS CHAR                                      NO-UNDO.
    
    DEF VAR aux_regexist AS LOGI INIT FALSE                           NO-UNDO.

    FORM "Controle de Movimentacao" 
         SKIP(2)  
         par_dtmvtolt     AT 12 LABEL "Data"             FORMAT "99/99/9999"
         SKIP(1)
         crapcop.nmextcop     AT 05 LABEL "Cooperativa"    FORMAT "x(80)" 
         aux_dsagenci     AT 13 LABEL "PA"                FORMAT "x(80)"
         SKIP(1)
         crapass.nrdconta AT 08 LABEL "Conta/dv"  
         SKIP(1)   
         "Documento:" AT 08
         crapcme.nrdocmto AT 27 NO-LABEL
         crapcme.vllanmto AT 12 LABEL "Valor"
         SKIP(1)
         crapass.dtadmiss AT 06 LABEL "Admis.Coop" 
         aux_dtaltera AT 05 LABEL "Recadastmto" 
         SKIP(2)
         crapcme.recursos AT 06 LABEL "Origem do dinheiro"
         SKIP(1)
         aux_tpoperac     AT 16 LABEL "Operacao"
         SKIP(2)
         WITH DOWN SIDE-LABELS WIDTH 132 FRAME f_coop_dep.

    FORM "Controle de Movimentacao" 
         SKIP(2)  
         par_dtmvtolt     AT 12 LABEL "Data"               FORMAT "99/99/9999"
         SKIP(1)
         crapcop.nmextcop     AT 05 LABEL "Cooperativa"    FORMAT "x(80)" 
         aux_dsagenci     AT 13 LABEL "PA"                FORMAT "x(80)"
         SKIP(1)
         crapass.nrdconta AT 08 LABEL "Conta/dv"  
         SKIP(1)
         "Documento:" AT 08
         crapcme.nrdocmto AT 27 NO-LABEL
         crapcme.vllanmto AT 12 LABEL "Valor"
         SKIP(1)
         crapass.dtadmiss AT 06 LABEL "Admis.Coop" 
         aux_dtaltera AT 05 LABEL "Recadastmto" 
         SKIP(2)
         crapcme.dstrecur AT 05 LABEL "Destino do dinheiro"
         SKIP(1)
         aux_tpoperac     AT 16 LABEL "Operacao"
         SKIP(2)
         WITH DOWN SIDE-LABELS WIDTH 132 FRAME f_coop_saq.

    FORM crapttl.idseqttl COLUMN-LABEL "Tit."
         crapttl.nmextttl COLUMN-LABEL "Nome" FORMAT "x(40)"
         aux_nrcpfcgc     COLUMN-LABEL "CPF"  FORMAT "x(18)"
         aux_inpolexp     COLUMN-LABEL "Politicamente exposta" FORMAT "x(08)"
         aux_cdocpttl     COLUMN-LABEL "Servidor Publico"      FORMAT "Sim/Nao"
         WITH DOWN WIDTH 132 FRAME f_fis.

    FORM crapjur.nmextttl COLUMN-LABEL "Nome"
         aux_nrcpfcgc     COLUMN-LABEL "CNPJ" FORMAT "x(18)"
         WITH DOWN WIDTH 132 FRAME f_jur.

    
    /* Busca dados da cooperativa */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAILABLE crapcop THEN
    DO:
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,     /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
        
    END.
 
    ASSIGN aux_cdcritic    = 0
           par_nmarqimp    = "/usr/coop/" + crapcop.dsdircop + "/rl/O295_" + 
                                STRING(TIME,"99999") + ".lst"
           aux_dsocpttl = "169,319,67,309,308,271,65,306,272,273," +
                          "74,305,69,316,209,311,303,64,310,314,"  +
                          "313,315,307,76,75,77,317,325,312,304".

    OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.

    { sistema/generico/includes/b1cabrel132.i "11" "295" }.
        
    FOR EACH crapcme WHERE crapcme.infrepcf = 1           
                           NO-LOCK BY crapcme.cdcooper
                                    BY crapcme.cdagenci
                                     BY crapcme.dtmvtolt 
                                      BY crapcme.nrdconta:

        ASSIGN aux_dtaltera = ?
               aux_tpoperac = "".
          
        IF crapcme.tpoperac = 1 THEN         
        DO:
            aux_tpoperac = "DEPOSITO".
          
        END.
        ELSE
        IF crapcme.tpoperac = 2 THEN
        DO:
            aux_tpoperac = "SAQUE".
        END.
        ELSE
        IF crapcme.tpoperac = 3 THEN
        DO:
            aux_tpoperac = "PAGAMENTO".
        END.
             
        FIND LAST crapalt WHERE crapalt.cdcooper = crapcme.cdcooper AND
                                crapalt.nrdconta = crapcme.nrdconta AND
                                crapalt.tpaltera = 1 
                                NO-LOCK NO-ERROR.
   
        IF NOT AVAILABLE crapalt THEN
            aux_dtaltera = ?.
        ELSE
            aux_dtaltera = crapalt.dtaltera.
     
        FIND crapcop WHERE crapcop.cdcooper = crapcme.cdcooper 
                           NO-LOCK NO-ERROR.

        ASSIGN aux_dsagenci = "".

        IF AVAIL crapcop THEN
            FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper AND
                               crapage.cdagenci = crapcme.cdagenci 
                               NO-LOCK NO-ERROR.
       
        IF AVAIL crapage THEN
            ASSIGN aux_dsagenci = STRING(crapcme.cdagenci) + " - " +
                                    crapage.nmcidade.
   
        FIND crapass WHERE crapass.cdcooper = crapcme.cdcooper AND
                           crapass.nrdconta = crapcme.nrdconta
                           NO-LOCK NO-ERROR.

        IF crapcme.tpoperac = 1 OR
           crapcme.tpoperac = 3 THEN 
        DO:
            DISPLAY STREAM str_1 crapcop.nmextcop
                                 aux_dsagenci
                                 crapass.nrdconta WHEN AVAIL crapass
                                 crapcme.nrdocmto
                                 crapcme.vllanmto
                                 crapass.dtadmiss WHEN AVAIL crapass    
                                 aux_dtaltera
                                 aux_tpoperac
                                 par_dtmvtolt
                                 crapcme.recursos 
                                 WITH FRAME f_coop_dep.
      
            DOWN WITH FRAME f_coop_dep.

        END.
        ELSE
        DO:
            DISPLAY STREAM str_1 crapcop.nmextcop
                                 aux_dsagenci
                                 crapass.nrdconta WHEN AVAIL crapass
                                 crapcme.nrdocmto
                                 crapcme.vllanmto
                                 crapass.dtadmiss WHEN AVAIL crapass    
                                 aux_dtaltera
                                 aux_tpoperac
                                 par_dtmvtolt
                                 crapcme.dstrecur 
                                 WITH FRAME f_coop_saq.
        
            DOWN WITH FRAME f_coop_saq.
        
        END.

        IF AVAIL crapass THEN
            IF crapass.inpessoa = 1 THEN
            DO:
                PUT STREAM str_1 "Titular(es) da Conta" AT 45 SKIP(1).
         
                FOR EACH crapttl WHERE crapttl.cdcooper = crapcme.cdcooper AND
                                       crapttl.nrdconta = crapcme.nrdconta 
                                       NO-LOCK:
         
                    ASSIGN aux_nrcpfcgc = 
                            STRING(STRING(crapttl.nrcpfcgc,"zzzzzzzzzzz"),
                                                          "xxx.xxx.xxx-xx").
         
                    IF CAN-DO(aux_dsocpttl,STRING(crapttl.cdocpttl)) THEN
                        ASSIGN aux_cdocpttl = TRUE.
                    ELSE
                        ASSIGN aux_cdocpttl = FALSE.
                
                    IF crapttl.inpolexp = 0 THEN  
                      ASSIGN aux_inpolexp = "Nao".
                    ELSE IF crapttl.inpolexp = 1 THEN
                      ASSIGN aux_inpolexp = "Sim".
                    ELSE IF  crapttl.inpolexp = 2 THEN
                      ASSIGN aux_inpolexp = "Pendente".
                    
                    DISPLAY STREAM str_1 crapttl.idseqttl 
                                         crapttl.nmextttl 
                                         aux_nrcpfcgc     
                                         aux_inpolexp 
                                         aux_cdocpttl     
                                         WITH FRAME f_fis.
         
         
                    ASSIGN aux_cdocpttl = FALSE
                           aux_nrcpfcgc = "".
         
                    DOWN STREAM str_1 WITH FRAME f_fis.
                
         
         
                END.
         
                DISP STREAM str_1 SKIP(1).
         
            END.
        ELSE
        DO:
            FOR EACH crapjur WHERE crapjur.cdcooper = crapcme.cdcooper AND
                                   crapjur.nrdconta = crapcme.nrdconta 
                                   NO-LOCK:
         
                ASSIGN aux_nrcpfcgc = 
                            STRING(STRING(crapass.nrcpfcgc,"zzzzzzzzzzzzzz"),
                                                       "xx.xxx.xxx/xxxx-xx").
        
                
                PUT STREAM str_1 "Titular da Conta" AT 25 SKIP(1).
        
                DISPLAY STREAM str_1 crapjur.nmextttl 
                                     aux_nrcpfcgc     
                                     WITH FRAME f_jur.
         
        
                ASSIGN aux_nrcpfcgc = "".
        
                DOWN STREAM str_1 WITH FRAME f_jur.
                
         
            END.
        
            DISP STREAM str_1 SKIP(1).
           
        END.

        ASSIGN aux_regexist = TRUE.
    END.                

    OUTPUT STREAM str_1 CLOSE.

    IF NOT aux_regexist THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Registros nao localizados.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,     /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF par_idorigem = 5 THEN /* Ayllos Web */
    DO:

        /* Busca dados da cooperativa */
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
        IF NOT AVAILABLE crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
            
        END.
    
        ASSIGN par_nmarqpdf = "/usr/coop/" + crapcop.dsdircop + 
                              "/arq/0295_" + STRING(TIME, "99999") + ".pdf".
    
        RUN gera_impressao (INPUT par_cdcooper,
                            INPUT par_nmarqimp,
                            INPUT-OUTPUT par_nmarqpdf,
                            OUTPUT aux_dscritic).
        
        IF aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 0,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
    
        END.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_impressao:

    DEF INPUT  PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nmarqimp AS CHAR NO-UNDO.

    DEF INPUT-OUTPUT  PARAM par_nmarqpdf AS CHAR NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR NO-UNDO.

    DEF VARIABLE h-b1wgen0024     AS HANDLE NO-UNDO.

               
    Imp-Web: DO WHILE TRUE:
        RUN sistema/generico/procedures/b1wgen0024.p 
                                            PERSISTENT SET h-b1wgen0024.
               
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
        DO:
            ASSIGN par_dscritic = "Handle invalido para BO b1wgen0024.".
            LEAVE Imp-Web.
        END.
        
        RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT par_nmarqimp,
                                                INPUT par_nmarqpdf).
        
        IF  SEARCH(par_nmarqpdf) = ?  THEN
        DO:
            ASSIGN par_dscritic = "Nao foi possivel gerar " + 
                                                "a impressao.".
            LEAVE Imp-Web.
        END.
               
        UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                      '"scp ' + par_nmarqpdf + ' scpuser@' + aux_srvintra 
                      + ':/var/www/ayllos/documentos/' + crapcop.dsdircop 
                      + '/temp/" 2>/dev/null').
               
        LEAVE Imp-Web.
    END. /** Fim do DO WHILE TRUE **/
               
    IF  VALID-HANDLE(h-b1wgen0024)  THEN
        DELETE OBJECT h-b1wgen0024.  

    ASSIGN par_nmarqpdf = ENTRY(NUM-ENTRIES(par_nmarqpdf,"/"),par_nmarqpdf,"/").

END PROCEDURE.

PROCEDURE consulta-dados-fechamento:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.

    DEF OUTPUT PARAM par_contador AS INT NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcme.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VARIABLE aux_vllanmto AS DECIMAL.
    DEF VARIABLE aux_vloperac AS DECIMAL.
    
	
    FOR EACH crapcme WHERE crapcme.dtmvtolt = par_dtmvtolt,
        EACH crapass WHERE crapass.cdcooper = crapcme.cdcooper AND
                           crapass.nrdconta = crapcme.nrdconta 
                           BREAK BY crapcme.tpoperac 
                                    BY crapass.nrcpfcgc:
                                    
        ASSIGN aux_vllanmto = aux_vllanmto + crapcme.vllanmto.
        
        IF LAST-OF(nrcpfcgc) THEN
          DO:          
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }          
          /* Efetuar a chamada a rotina Oracle */ 
          RUN STORED-PROCEDURE pc_busca_limite_operacao
           aux_handproc = PROC-HANDLE NO-ERROR 
                       ( INPUT crapcme.cdcooper /* pr_cdcooper --> Codigo da cooperativa */                     
                        ,INPUT crapcme.tpoperac /* pr_tpoperac --> tipo da operacao */
                        /* --------- OUT --------- */
                        ,OUTPUT 0          /* pr_cdcritic --> Codigo da critica  */
                        ,OUTPUT ""          /* pr_dscritic --> Descriçao da critica    */
                        ,OUTPUT 0 ).        /* pr_vloperac --> Retorno da operacao     */
          
          /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_busca_limite_operacao
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN aux_vloperac = pc_busca_limite_operacao.pr_vloperac
                     WHEN pc_busca_limite_operacao.pr_vloperac <> ?.        
             
          IF aux_vllanmto >= aux_vloperac THEN
            DO:
              CREATE tt-crapcme2.
              ASSIGN tt-crapcme2.cdcooper = crapcme.cdcooper
                     tt-crapcme2.tpoperac = STRING(crapcme.tpoperac)
                     tt-crapcme2.nrcpfcgc = STRING(crapass.nrcpfcgc)                    
                     tt-crapcme2.dtmvtolt = crapcme.dtmvtolt.
            END.
          ASSIGN aux_vllanmto = 0.  
        END.
    END.     
    
    FOR EACH tt-crapcme2, 
              EACH crapass WHERE crapass.cdcooper = tt-crapcme2.cdcooper AND
                                 crapass.nrcpfcgc = DECIMAL(tt-crapcme2.nrcpfcgc),                                
                   EACH crapcme WHERE (IF par_cdcooper <> 3 THEN
                              (crapcme.cdcooper = par_cdcooper    AND
                                       crapcme.infrepcf <> 2             )     ELSE
                                       crapcme.infrepcf <> 2             )     AND
                                       crapcme.dtmvtolt = tt-crapcme2.dtmvtolt AND
                                       STRING(crapcme.tpoperac) = tt-crapcme2.tpoperac AND 
                                       crapcme.cdcooper = tt-crapcme2.cdcooper AND                               
                                       crapcme.nrdconta = crapass.nrdconta                                   
                            NO-LOCK:

        ASSIGN par_contador = par_contador + 1.
    
        CREATE tt-crapcme.
        ASSIGN tt-crapcme.cdcooper = crapcme.cdcooper
               tt-crapcme.cdagenci = crapcme.cdagenci   
               tt-crapcme.nrdconta = crapcme.nrdconta
               tt-crapcme.nmprimtl = crapass.nmprimtl WHEN AVAIL crapass
               tt-crapcme.nrdocmto = crapcme.nrdocmto
               tt-crapcme.tpoperac = (IF crapcme.tpoperac = 1 THEN
                                      "DEPOSITO" ELSE
                                        IF crapcme.tpoperac = 2 THEN
                                        "SAQUE" ELSE
                                        "PAGAMENTO")
               tt-crapcme.recursos = crapcme.recursos
               tt-crapcme.dstrecur = crapcme.dstrecur
               tt-crapcme.flinfdst = crapcme.flinfdst
               tt-crapcme.vllanmto = crapcme.vllanmto
               tt-crapcme.dtmvtolt = crapcme.dtmvtolt  
               tt-crapcme.infrepcf = "Informar"
               tt-crapcme.nrdrowid = ROWID(crapcme)
                 tt-crapcme.dsdjusti = crapcme.dsdjusti               
                 tt-crapcme.nrcpfcgc = (IF crapass.inpessoa = 1 THEN 
                                           STRING(STRING(crapass.nrcpfcgc,"99999999999"),"xxx.xxx.xxx-xx")
                                        ELSE 
                                           STRING(STRING(crapass.nrcpfcgc,"99999999999999"),"xx.xxx.xxx/xxxx-xx")).
               
    END.

    IF par_contador = 0 THEN
        DO:
            ASSIGN aux_cdcritic = 011
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
                    
        END.

    RETURN "OK".


END PROCEDURE.

PROCEDURE efetua-confirmacao-sisbacen:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_identifi AS INTE NO-UNDO.
    DEF INPUT PARAM par_infocoaf AS LOGI NO-UNDO.
    DEF INPUT PARAM par_justific AS CHAR NO-UNDO.
    DEF INPUT PARAM TABLE FOR tt-crapcme.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    FOR EACH tt-crapcme NO-LOCK:
        
       /* FIND crapcme WHERE ROWID(crapcme) = tt-crapcme.nrdrowid
                                            EXCLUSIVE-LOCK NO-ERROR.*/
        FIND crapcme WHERE crapcme.cdcooper = tt-crapcme.cdcooper AND
                           crapcme.cdagenci = tt-crapcme.cdagenci AND
                           crapcme.nrdconta = tt-crapcme.nrdconta AND
                           crapcme.dtmvtolt = tt-crapcme.dtmvtolt AND
                           crapcme.nrdocmto = tt-crapcme.nrdocmto
                           EXCLUSIVE-LOCK NO-ERROR.

        IF AVAIL crapcme THEN
        DO:
            IF par_identifi = -1 THEN
                ASSIGN crapcme.infrepcf = 2.
            ELSE
            IF par_infocoaf THEN
                ASSIGN crapcme.dsdjusti = par_justific
                       crapcme.infrepcf = 2
                       crapcme.sisbacen = YES
                       crapcme.opeenvcf = par_cdoperad.
            ELSE
                ASSIGN crapcme.dsdjusti = par_justific
                       crapcme.sisbacen = NO
                       crapcme.infrepcf = 2
                       crapcme.opeenvcf = par_cdoperad.
        END.
        ELSE
        DO:
            ASSIGN aux_cdcritic = 011
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    END.

    RETURN "OK".

END PROCEDURE.
