/* ............................................................................

   Programa: sistema/generico/procedures/b1wgen0197.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Maio/2017.                       Ultima atualizacao:  /  /  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO referente a Desligamento de Cooperados

   Alteracoes:
   
............................................................................ */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0009tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0033tt.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/b1wgen0082tt.i }
{ sistema/generico/includes/b1wgen0197tt.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0009 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0019 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0030 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0033 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0082 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dsdidade AS CHAR                                           NO-UNDO.
DEF VAR aux_vlbloque AS DECIMAL                                        NO-UNDO.
DEF VAR aux_vlresblq AS DECIMAL                                        NO-UNDO.
DEF VAR aux_vlresapl AS DECIMAL INIT 0                                 NO-UNDO.
DEF VAR aux_dsdmesag AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

/******************************************************************************/

PROCEDURE busca_inf_produtos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-inf-produto.

    FOR FIRST crapope FIELDS(flgacres)
                       WHERE crapope.cdcooper = par_cdcooper
                         AND crapope.cdoperad = par_cdoperad
                         NO-LOCK:                     
    END.
    
    IF AVAILABLE crapope THEN
       DO:
          FOR FIRST crapass FIELDS(flgrestr)
                             WHERE crapass.cdcooper = par_cdcooper
                               AND crapass.nrdconta = par_nrdconta
                               NO-LOCK:
          END.
          
          IF NOT AVAILABLE crapass THEN
             DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT 9,
                               INPUT-OUTPUT aux_dscritic).
                               
                ASSIGN par_dscritic = aux_dscritic.
                               
                RETURN "NOK".
             END.
          ELSE
             DO:
                IF crapass.flgrestr = TRUE AND crapope.flgacres = FALSE THEN
                  DO:
                     ASSIGN par_dscritic = "Operacao nao permitida.".
                     
                     RETURN "NOK".
                  END.
             END.
       END.
    ELSE
       DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT 67,
                         INPUT-OUTPUT aux_dscritic).
                         
          ASSIGN par_dscritic = aux_dscritic.
                         
          RETURN "NOK".          
       END.
    
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT "Consulta Impedimentos Desligamento",
                        INPUT TRUE,
                        INPUT par_idseqttl, /** idseqttl **/
                        INPUT par_nmdatela,
                        INPUT par_nrdconta, /* nrdconta */
                       OUTPUT aux_nrdrowid).

    RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

    RUN obtem-propostas-emprestimo IN h-b1wgen0002 (INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT par_cdoperad,
                                                    INPUT par_nmdatela,
                                                    INPUT par_idorigem, /* Ayllos */
                                                    INPUT par_nrdconta,
                                                    INPUT par_idseqttl,
                                                    INPUT par_dtmvtolt,
                                                    INPUT 0,/*Contrato(todos)*/
                                                    INPUT FALSE,
                                                    OUTPUT TABLE tt-erro,
                                                    OUTPUT TABLE tt-proposta-epr,
                                                    OUTPUT TABLE tt-dados-gerais,
                                                    OUTPUT aux_dsdidade).
    DELETE PROCEDURE h-b1wgen0002.

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF   AVAIL tt-erro  THEN
               par_dscritic = tt-erro.dscritic.
          ELSE
               par_dscritic = "Nao foi possivel listar as propostas de emprestimo.".

          LEAVE.
        END.

    CREATE tt-inf-produto.
    ASSIGN tt-inf-produto.vlemprst = 0
           tt-inf-produto.vllimpro = 0
           tt-inf-produto.vllimdsc = 0
           tt-inf-produto.vlcompcr = 0
           tt-inf-produto.vllimcar = 0
           tt-inf-produto.vlresapl = 0
           tt-inf-produto.flcobran = 0
           tt-inf-produto.flseguro = 0
           tt-inf-produto.flconsor = 0
           tt-inf-produto.flgctitg = 0
           tt-inf-produto.flgccbcb = 0
           tt-inf-produto.flgccbdb = 0
           tt-inf-produto.qtfdcuso = 0
           tt-inf-produto.qtchqdev = 0
           tt-inf-produto.qtreqtal = 0
           tt-inf-produto.qtchqcan = 0
           tt-inf-produto.inarqcbr = 0
           tt-inf-produto.flgbinss = 0
           tt-inf-produto.flpdbrde = 0.
    
    FOR EACH tt-proposta-epr NO-LOCK:
      ASSIGN tt-inf-produto.vlemprst = tt-inf-produto.vlemprst + tt-proposta-epr.vlemprst.
    END.
    
    RUN sistema/generico/procedures/b1wgen0019.p PERSISTENT SET h-b1wgen0019.

    RUN obtem-limite IN h-b1wgen0019 (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem, /* Ayllos */
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT FALSE,                                      
                                      INPUT par_dtmvtolt,
                                      INPUT 0,
                                      INPUT FALSE,
                                      OUTPUT TABLE tt-proposta-limcredito,
                                      OUTPUT TABLE tt-erro,                                      
                                      OUTPUT TABLE tt-msg-confirma).
    DELETE PROCEDURE h-b1wgen0019.

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF   AVAIL tt-erro  THEN
               par_dscritic = tt-erro.dscritic.
          ELSE
               par_dscritic = "Nao foi possivel obter o limite de cheque especial.".

          LEAVE.
        END.
    
    FOR FIRST tt-proposta-limcredito NO-LOCK:
      ASSIGN tt-inf-produto.vllimpro = tt-proposta-limcredito.vllimpro.
    END.
    
    RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.    
    
    RUN busca_dados_dscchq IN h-b1wgen0009 (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_dtmvtolt,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_idorigem,
                                            INPUT par_nmdatela,
                                            INPUT FALSE, /* LOG*/
                                           OUTPUT TABLE tt-erro, 
                                           OUTPUT TABLE tt-desconto_cheques).
    
    DELETE PROCEDURE h-b1wgen0009.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF   AVAIL tt-erro  THEN
               par_dscritic = tt-erro.dscritic.
          ELSE
               par_dscritic = "Nao foi possivel obter o limite de desconto de cheque.".

          LEAVE.
        END.
        
    FOR FIRST tt-desconto_cheques NO-LOCK:
      ASSIGN tt-inf-produto.vllimdsc = tt-desconto_cheques.vllimite.
    END.
    
    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
    
    RUN busca_dados_dsctit IN h-b1wgen0030 (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT FALSE, /* LOG */
                                           OUTPUT TABLE tt-erro, 
                                           OUTPUT TABLE tt-desconto_titulos).

    DELETE PROCEDURE h-b1wgen0030.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF   AVAIL tt-erro  THEN
               par_dscritic = tt-erro.dscritic.
          ELSE
               par_dscritic = "Nao foi possivel obter o limite de desconto de titulo.".

          LEAVE.
        END.
        
    FOR FIRST tt-desconto_titulos NO-LOCK:
      ASSIGN tt-inf-produto.vllimdsc = tt-inf-produto.vllimdsc + tt-desconto_titulos.vllimite.
    END.
        
    RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.    
    
    RUN busca_borderos IN h-b1wgen0009 (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_dtmvtolt,
                                        INPUT FALSE,
                                       OUTPUT TABLE tt-bordero_chq).
                              
    DELETE PROCEDURE h-b1wgen0009.
    
    FOR EACH tt-bordero_chq NO-LOCK:
      ASSIGN tt-inf-produto.vlcompcr = tt-inf-produto.vlcompcr + tt-bordero_chq.vlcompcr.
    END.
            
    FOR EACH crawcrd FIELDS(vllimcrd)
                     WHERE crawcrd.cdcooper = par_cdcooper
                       AND crawcrd.nrdconta = par_nrdconta
                       AND (crawcrd.insitcrd = 4 
                        OR  crawcrd.insitcrd = 7)
                        NO-LOCK:
      ASSIGN tt-inf-produto.vllimcar = tt-inf-produto.vllimcar + crawcrd.vllimcrd.
    END.
    
    RUN sistema/generico/procedures/b1wgen0155.p PERSISTENT SET h-b1wgen0155.
        
    RUN retorna-valor-blqjud IN h-b1wgen0155 (INPUT par_cdcooper,
                                              INPUT par_nrdconta,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT par_dtmvtolt,
                                             OUTPUT aux_vlbloque,
                                             OUTPUT aux_vlresblq).
    DELETE PROCEDURE h-b1wgen0155.
    
    /* Percorrer as aplicacoes da conta */
    FOR EACH craprda WHERE craprda.cdcooper = par_cdcooper
                       AND craprda.nrdconta = par_nrdconta
                       AND craprda.insaqtot = 0 NO-LOCK:
                           
      RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

      RUN buscar-dados-aplicacao IN h-b1wgen0081 (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT par_cdoperad,
                                                  INPUT par_nmdatela,
                                                  INPUT par_idorigem,
                                                  INPUT par_nrdconta,
                                                  INPUT par_idseqttl,
                                                  INPUT "E",
                                                  INPUT par_dtmvtolt,
                                                  INPUT craprda.nraplica,
                                                  INPUT FALSE,
                                                 OUTPUT TABLE tt-tipo-aplicacao,
                                                 OUTPUT TABLE tt-dados-aplicacao,
                                                 OUTPUT TABLE tt-erro).

      DELETE PROCEDURE h-b1wgen0081.

      IF  RETURN-VALUE = "NOK"  THEN
          DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAIL tt-erro  THEN
                 par_dscritic = tt-erro.dscritic.
            ELSE
                 par_dscritic = "Nao foi possivel obter os dados das aplicacoes.".

            LEAVE.
          END.

      ASSIGN aux_vlresapl = aux_vlresapl + tt-dados-aplicacao.vllanmto.

    END.
    
    ASSIGN tt-inf-produto.vlresapl = aux_vlresapl + aux_vlresblq.
    
    RUN sistema/generico/procedures/b1wgen0082.p PERSISTENT SET h-b1wgen0082.
    
    RUN carrega-convenios-ceb IN h-b1wgen0082 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT par_dtmvtolt,
                                               INPUT FALSE,
                                              OUTPUT aux_dsdmesag,
                                              OUTPUT TABLE tt-cadastro-bloqueto,
                                              OUTPUT TABLE tt-crapcco,
                                              OUTPUT TABLE tt-titulares,
                                              OUTPUT TABLE tt-emails-titular).

    DELETE PROCEDURE h-b1wgen0082.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF   AVAIL tt-erro  THEN
               par_dscritic = tt-erro.dscritic.
          ELSE
               par_dscritic = "Nao foi possivel obter os dados de cobranca.".

          LEAVE.
        END.

    FOR FIRST tt-cadastro-bloqueto:
        ASSIGN tt-inf-produto.flcobran = 1.
    END.
    
    /* Verificar se conta possui seguro */
    FOR FIRST crapseg WHERE crapseg.cdcooper = par_cdcooper
                        AND crapseg.nrdconta = par_nrdconta
                        AND crapseg.dtinsexc = ? NO-LOCK:
        ASSIGN tt-inf-produto.flseguro = 1.
    END.                            
        
    /* Verificar se conta possui consorcio ativo */
    FOR FIRST crapcns WHERE crapcns.cdcooper = par_cdcooper 
                        AND crapcns.nrdconta = par_nrdconta
                        AND crapcns.flgativo = TRUE NO-LOCK:
        ASSIGN tt-inf-produto.flconsor = 1.
    END.        
    /* Verificar se conta possui conta ITG ativa */
    FOR FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                        AND crapass.nrdconta = par_nrdconta
                        AND crapass.flgctitg = 2 NO-LOCK:
        ASSIGN tt-inf-produto.flgctitg = 1.
    END.

    /* Verificar cartao bancoob */
    FOR FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper
                        AND craplcm.nrdconta = par_nrdconta
                        AND CAN-DO("1956,1957,1958,1959,1960,1961", STRING(craplcm.cdhistor)) NO-LOCK:
        ASSIGN tt-inf-produto.flgccbcb = 1.
    END.
    
    /* Verificar cartao BB */
    FOR FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper
                        AND craplcm.nrdconta = par_nrdconta
                        AND CAN-DO("444,584", STRING(craplcm.cdhistor)) NO-LOCK:
        ASSIGN tt-inf-produto.flgccbdb = 1.
    END.

    /* Buscar quantidade de folhas de cheque em uso */
    FOR EACH crapfdc FIELDS(cdcooper) 
                      WHERE crapfdc.cdcooper = par_cdcooper 
                        AND crapfdc.nrdconta = par_nrdconta
                        AND crapfdc.incheque = 0 
                        AND crapfdc.dtliqchq = ? NO-LOCK:
        ASSIGN tt-inf-produto.qtfdcuso = tt-inf-produto.qtfdcuso + 1.
    END.
    
    /* Buscar quantidade de cheques devolvidos */
    FOR EACH crapcec FIELDS(cdcooper)
                      WHERE crapcec.cdcooper = par_cdcooper 
                        AND crapcec.nrdconta = par_nrdconta NO-LOCK:
        ASSIGN tt-inf-produto.qtchqdev = tt-inf-produto.qtchqdev + 1.
    END.
    
    /* Buscar quantidade de Talonarios em estoque */
    FOR FIRST crapreq FIELDS(qtreqtal)
                       WHERE crapreq.cdcooper = par_cdcooper
                         AND crapreq.nrdconta = par_nrdconta
                         AND crapreq.insitreq = 1
                         AND crapreq.tprequis = 1
                         NO-LOCK:
        ASSIGN tt-inf-produto.qtreqtal = crapreq.qtreqtal.
    END.
    
    /* Buscar quantidade de Cheques cancelados */
    FOR EACH crapfdc FIELDS(cdcooper)
                      WHERE crapfdc.cdcooper = par_cdcooper
                        AND crapfdc.nrdconta = par_nrdconta
                        AND crapfdc.incheque = 8 /*Cancelado*/
                        NO-LOCK:
        ASSIGN tt-inf-produto.qtchqcan = tt-inf-produto.qtchqcan + 1.
    END.
    
    /* Verificar se cooperado recebe beneficio do INSS */
    FOR EACH craplcm FIELDS(cdcooper)
                      WHERE craplcm.cdcooper = par_cdcooper
                        AND craplcm.nrdconta = par_nrdconta
                        AND craplcm.cdhistor = 1399 /* Beneficio INSS */
                         NO-LOCK:
        ASSIGN tt-inf-produto.flgbinss = 1.
    END.
    
    /* Cooperado utiliza pagamento por arquivo */
    FOR FIRST crapass FIELDS(inarqcbr)
                       WHERE crapass.cdcooper = par_cdcooper
                         AND crapass.nrdconta = par_nrdconta
                         AND crapass.flgctitg = 2 /* Ativo */
                         AND crapass.inarqcbr = 1 /* Gera arquivo */
                         NO-LOCK:
        ASSIGN tt-inf-produto.inarqcbr = crapass.inarqcbr.
    END.
    
    /* Produto BRDE */
    FOR FIRST craplcm FIELDS(cdcooper)
                       WHERE craplcm.cdcooper = par_cdcooper
                         AND craplcm.nrdconta = par_nrdconta
                         AND craplcm.cdhistor = 583 /* Financiamento BRDE */
                         NO-LOCK:
        ASSIGN tt-inf-produto.flpdbrde = 1.
    END.
END PROCEDURE.

/******************************************************************************/