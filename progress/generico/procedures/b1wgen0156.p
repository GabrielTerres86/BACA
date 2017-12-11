
/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0156.p
    Autor   : Jorge I. Hamaguchi
    Data    : Maio/2013                Ultima Atualizacao: 11/12/2017
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela LOTPRC
                 
    Alteracoes: 21/08/2013 - Ajustes em geracao do arquivo, avalistas. (Jorge)
    
                28/10/2013 - Adicionado opcao "R" e ajustes em outras opcoes.
                             (Jorge).
                             
                08/11/2013 - Alterado valor limite da operacao para 30000.
                            (Irlan).
                            
                12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                07/04/2014 - Ajuste para validar cpf de conjugue. (Jorge)
                
                20/06/2014 - Ajuste em relatorio do lote, adicionado disp do 
                             campo dtvencnd. 
                             (Jorge/Rosangela) - SD 136936
               
               26/06/2014 -  Ajuste em relatorio do lote para não verificar mais a data de finalização do lote antes de gerar o arquivo. 
                             (Vanessa Klein) - SD 152369
                             
               24/11/2014 - Alteraçao da rotina gerar_arq_enc_brde para 
                            chamada da rotina convertida para oracle
                            (Odirlei-AMcom)

			   06/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                            departamento passando a considerar o código (Renato Darosci)
                            
               21/09/2017 - Atualizado possibilidades de cod. de porte de beneficiario
                            PF/PJ de acordo com a atualizacao do layout promovida pelo BRDE.
                            (Chamado 732059) - (Fabricio)
                            
              11/12/2017 - Ajustar mensagem do Porte conta fisica e Juridica para exibier o
                           campo da tabela crapprm (Lucas Ranghetti #809661)
.............................................................................*/

{ sistema/generico/includes/b1wgen0156tt.i }
{ sistema/generico/includes/b1wgen0058tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i } 

DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR h-b1wgen0011 AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0058 AS HANDLE                                NO-UNDO.

/*****************************************************************************
  Abrir lote      
******************************************************************************/
PROCEDURE abrir_lote:
    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nrdolote AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrnewlot AS INTE                                     NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    RUN valida_operad_depto(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                           OUTPUT par_nmdcampo,
                           OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

    AbrirLote: DO TRANSACTION
           ON ERROR  UNDO AbrirLote, LEAVE AbrirLote
           ON QUIT   UNDO AbrirLote, LEAVE AbrirLote
           ON STOP   UNDO AbrirLote, LEAVE AbrirLote
           ON ENDKEY UNDO AbrirLote, LEAVE AbrirLote:

        FIND LAST  craplpc NO-LOCK
             WHERE craplpc.cdcooper = par_cdcooper
             NO-ERROR.
        
        IF AVAIL craplpc THEN
           ASSIGN aux_nrnewlot = craplpc.nrdolote.
    
        ASSIGN aux_nrnewlot = aux_nrnewlot + 1.
    
        CREATE craplpc.
        ASSIGN craplpc.cdcooper = par_cdcooper
               craplpc.dtmvtolt = par_dtmvtolt
               craplpc.nrdolote = aux_nrnewlot.
        VALIDATE craplpc.
    
        ASSIGN par_nrdolote = aux_nrnewlot.
    END. /* AbrirLote */

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Incluir conta no lote      
******************************************************************************/
PROCEDURE incluir_conta_lote:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdolote AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprocap AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencnd AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmunben AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdgenben AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdporben AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsetben AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcndfed AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcndfgt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcndest AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_lstavali AS CHAR                           NO-UNDO.
                                                                   
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_contador AS INTE                                     NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI                                     NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /* verificar e validar se existe lote e conta validas */
    RUN verificar_conta_lote (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_dtmvtolt,
                              INPUT par_nrdconta,
                              INPUT par_nrdolote,
                             OUTPUT aux_inpessoa,
                             OUTPUT par_nmdcampo,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-avalistas).
    
    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".
    
    IncluirConta: DO TRANSACTION
                  ON ERROR  UNDO IncluirConta, LEAVE IncluirConta
                  ON QUIT   UNDO IncluirConta, LEAVE IncluirConta
                  ON STOP   UNDO IncluirConta, LEAVE IncluirConta
                  ON ENDKEY UNDO IncluirConta, LEAVE IncluirConta:

        CREATE crapipc.
        ASSIGN crapipc.cdcooper = par_cdcooper
               crapipc.nrdconta = par_nrdconta
               crapipc.nrdolote = par_nrdolote
               crapipc.vlprocap = par_vlprocap
               crapipc.dtvencnd = par_dtvencnd
               crapipc.cdmunben = par_cdmunben
               crapipc.cdgenben = par_cdgenben
               crapipc.cdporben = par_cdporben
               crapipc.cdsetben = par_cdsetben
               crapipc.dtcndfed = par_dtcndfed
               crapipc.dtcndfgt = par_dtcndfgt
               crapipc.dtcndest = par_dtcndest.
        VALIDATE crapipc.
    
        FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                             AND crapass.nrdconta = par_nrdconta
                             NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL crapass THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Conta nao encontrada!".
                       par_nmdcampo = "".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,  /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        IF  crapass.inpessoa <> 1 THEN
            DO:
                /* limpar os avalistas do lote e conta em questao */
                FOR EACH crapapc WHERE crapapc.cdcooper = par_cdcooper
                                   AND crapapc.nrdolote = par_nrdolote
                                   AND crapapc.nrdconta = par_nrdconta
                                   EXCLUSIVE-LOCK:
                    DELETE crapapc.
                END.
            
                IF  LENGTH(TRIM(par_lstavali)) > 0 THEN
                    DO:
                        IF NUM-ENTRIES(par_lstavali,"|") > 5 THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Maximo de 5 avalistas " +
                                                  "excedido.".
                                   par_nmdcampo = "chkavali".
                
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,  /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            RETURN "NOK".
                        END.

                        /* DO de quantidade de avalistas selecionados */
                        DO  aux_contador = 1 TO NUM-ENTRIES(par_lstavali,"|"):
            
                            ASSIGN 
                            aux_nrcpfcgc = DECIMAL(
                                           ENTRY(
                                           aux_contador,par_lstavali,"|")).
                            
                            FIND FIRST crapavt 
                                 WHERE crapavt.cdcooper = par_cdcooper
                                   AND crapavt.tpctrato = 6
                                   AND crapavt.nrdconta = par_nrdconta
                                   AND crapavt.nrcpfcgc = aux_nrcpfcgc
                                   NO-LOCK NO-ERROR.
                                                 
                            IF  NOT AVAIL crapavt THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao foi possivel " +
                                                        "encontrar o avalista.".
                                           par_nmdcampo = "".
                        
                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1,  /** Sequencia **/
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).
                                    RETURN "NOK".
                                END.
            
                            CREATE crapapc.
                            ASSIGN crapapc.cdcooper = par_cdcooper
                                   crapapc.nrdolote = par_nrdolote
                                   crapapc.nrdconta = par_nrdconta
                                   crapapc.nrcpfrep = aux_nrcpfcgc
                                   crapapc.nrctarep = crapavt.nrdctato.
                            VALIDATE crapapc.
                        END.
                    END.
        
            END. /* DO inpessoa <> 1 */
    END. /* IncluirConta */
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Consultar conta do lote      
******************************************************************************/
PROCEDURE consultar_conta_lote:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdolote AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cddopcao AS CHAR                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-contas-lote.
    DEF  OUTPUT PARAM TABLE FOR tt-avalistas.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_nmdavali AS CHAR                                     NO-UNDO.

    DEF BUFFER b-crapass FOR crapass.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-contas-lote.
    EMPTY TEMP-TABLE tt-avalistas.
    
    IF  par_cddopcao = "A" THEN
    DO:
        FIND FIRST craplpc WHERE craplpc.cdcooper = par_cdcooper
                             AND craplpc.nrdolote = par_nrdolote
                             NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL craplpc THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel " +
                                    "encontrar o Lote.".
                       par_nmdcampo = "nrdolote".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,  /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        IF  craplpc.dtfimlot <> ? THEN
            ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                  " ja se encontra finalizado.".
        ELSE IF craplpc.dtfeclot <> ? THEN
            ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                       " ja se encontra fechado.".
        
        IF aux_dscritic <> '' THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   par_nmdcampo = "nrdolote".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    END.

    /* verificar se a conta informada existe no lote */        
    FIND FIRST crapipc WHERE crapipc.cdcooper = par_cdcooper
                         AND crapipc.nrdconta = par_nrdconta
                         AND crapipc.nrdolote = par_nrdolote
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapipc THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta nao cadastrada no lote " + 
                                  STRING(par_nrdolote) + "."
                   par_nmdcampo = "nrdconta".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    CREATE tt-contas-lote.
    BUFFER-COPY crapipc TO tt-contas-lote.
    
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                         AND crapass.nrdconta = par_nrdconta
                         NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapass THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta nao encontrada!".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_inpessoa = crapass.inpessoa.

    IF  crapass.inpessoa <> 1 THEN
        DO:
            FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper
                               AND crapavt.tpctrato = 6
                               AND crapavt.nrdconta = par_nrdconta
                               NO-LOCK:

                IF crapavt.nrdctato <> 0  THEN
                DO:
                    FIND FIRST b-crapass 
                         WHERE b-crapass.cdcooper = crapavt.cdcooper
                           AND b-crapass.nrdconta = crapavt.nrdctato
                           NO-LOCK NO-ERROR.

                    IF NOT AVAIL b-crapass THEN
                        ASSIGN aux_nmdavali = "".
                    ELSE
                        ASSIGN aux_nmdavali = b-crapass.nmprimtl.
                END.
                ELSE
                    ASSIGN aux_nmdavali = crapavt.nmdavali.
                
                CREATE tt-avalistas.
                ASSIGN tt-avalistas.nrcpfcgc = crapavt.nrcpfcgc
                       tt-avalistas.nrdctato = crapavt.nrdctato
                       tt-avalistas.nmdavali = aux_nmdavali.
        
                IF CAN-FIND(FIRST crapapc 
                            WHERE crapapc.cdcooper = crapavt.cdcooper
                              AND crapapc.nrdolote = par_nrdolote
                              AND crapapc.nrdconta = crapavt.nrdconta
                              AND crapapc.nrcpfrep = crapavt.nrcpfcgc
                              NO-LOCK)
                THEN
                    ASSIGN tt-avalistas.flgcheck = TRUE.
                ELSE
                    ASSIGN tt-avalistas.flgcheck = FALSE.
            END.
        END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Alterar conta do lote        
******************************************************************************/
PROCEDURE alterar_conta_lote:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdolote AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprocap AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencnd AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmunben AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdgenben AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdporben AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsetben AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcndfed AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcndfgt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcndest AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_lstavali AS CHAR                           NO-UNDO.
                                                                   
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_contador AS INTE                                     NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI                                     NO-UNDO.

    /* validar se existe lote e conta validas */
    RUN validar_conta_lote (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_nrdconta,
                            INPUT par_nrdolote,
                           OUTPUT par_nmdcampo,
                           OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".
    
    AlterarConta: DO TRANSACTION
                  ON ERROR  UNDO AlterarConta, LEAVE AlterarConta
                  ON QUIT   UNDO AlterarConta, LEAVE AlterarConta
                  ON STOP   UNDO AlterarConta, LEAVE AlterarConta
                  ON ENDKEY UNDO AlterarConta, LEAVE AlterarConta:

        FIND FIRST craplpc WHERE craplpc.cdcooper = par_cdcooper
                             AND craplpc.nrdolote = par_nrdolote
                             NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL craplpc THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel " +
                                    "encontrar o Lote.".
                       par_nmdcampo = "nrdolote".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,  /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        IF  craplpc.dtfimlot <> ? THEN
            ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                  " ja se encontra finalizado.".
        ELSE IF craplpc.dtfeclot <> ? THEN
            ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                       " ja se encontra fechado.".
        
        IF aux_dscritic <> '' THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   par_nmdcampo = "nrdolote".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
        FIND FIRST crapipc WHERE crapipc.cdcooper = par_cdcooper
                             AND crapipc.nrdconta = par_nrdconta
                             AND crapipc.nrdolote = par_nrdolote
                             EXCLUSIVE-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapipc THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Problema ao atualizar conta em Lote."
                       par_nmdcampo = "nrdconta".
        
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
        ELSE 
            DO:
                ASSIGN crapipc.cdcooper = par_cdcooper
                       crapipc.nrdconta = par_nrdconta
                       crapipc.nrdolote = par_nrdolote
                       crapipc.vlprocap = par_vlprocap
                       crapipc.dtvencnd = par_dtvencnd
                       crapipc.cdmunben = par_cdmunben
                       crapipc.cdgenben = par_cdgenben
                       crapipc.cdporben = par_cdporben
                       crapipc.cdsetben = par_cdsetben
                       crapipc.dtcndfed = par_dtcndfed
                       crapipc.dtcndfgt = par_dtcndfgt
                       crapipc.dtcndest = par_dtcndest.
    
                FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                                     AND crapass.nrdconta = par_nrdconta
                                     NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Nao foi possivel " +
                                            "encontrar a conta.".
                               par_nmdcampo = "nrdconta".
            
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,  /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                IF  crapass.inpessoa <> 1 THEN
                    DO:
                        /* limpar os avalistas do lote e conta em questao */
                        FOR EACH crapapc WHERE crapapc.cdcooper = par_cdcooper
                                           AND crapapc.nrdolote = par_nrdolote
                                           AND crapapc.nrdconta = par_nrdconta
                                           EXCLUSIVE-LOCK:
                            DELETE crapapc.
                        END.
                    
                        IF  LENGTH(TRIM(par_lstavali)) > 0 THEN
                        DO:
                            IF NUM-ENTRIES(par_lstavali,"|") > 5 THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Maximo de 5 avalistas " +
                                                      "excedido.".
                                       par_nmdcampo = "chkavali".
                    
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,  /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                RETURN "NOK".
                            END.

                            /* DO de quantidade de avalistas selecionados */
                            DO  aux_contador = 1 TO 
                                NUM-ENTRIES(par_lstavali,"|"):
                
                                ASSIGN aux_nrcpfcgc = 
                                       DECIMAL(
                                       ENTRY(aux_contador,par_lstavali,"|")).
                                
                                FIND FIRST crapavt 
                                     WHERE crapavt.cdcooper = par_cdcooper
                                       AND crapavt.tpctrato = 6
                                       AND crapavt.nrdconta = par_nrdconta
                                       AND crapavt.nrcpfcgc = aux_nrcpfcgc
                                       NO-LOCK NO-ERROR.
                                                     
                                IF  NOT AVAIL crapavt THEN
                                    DO:
                                        ASSIGN 
                                        aux_cdcritic = 0
                                        aux_dscritic = "Nao foi possivel " +
                                                       "encontrar o avalista."
                                        par_nmdcampo = "".
                            
                                        RUN gera_erro (INPUT par_cdcooper,
                                                       INPUT par_cdagenci,
                                                       INPUT par_nrdcaixa,
                                                       INPUT 1,   /** Seq**/
                                                       INPUT aux_cdcritic,
                                                INPUT-OUTPUT aux_dscritic).
                                        RETURN "NOK".
                                    END.
                
                                CREATE crapapc.
                                ASSIGN crapapc.cdcooper = par_cdcooper
                                       crapapc.nrdolote = par_nrdolote
                                       crapapc.nrdconta = par_nrdconta
                                       crapapc.nrcpfrep = aux_nrcpfcgc
                                       crapapc.nrctarep = crapavt.nrdctato.
                                VALIDATE crapapc.
                            END.
                        END.    
                    END.
            END.
    END. /* AlterarConta */

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Excluir conta do lote      
******************************************************************************/
PROCEDURE excluir_conta_lote:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdolote AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /* validar se existe lote e conta validas */
    RUN validar_conta_lote (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_nrdconta,
                            INPUT par_nrdolote,
                           OUTPUT par_nmdcampo,
                           OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".
    
    ExcluirConta: DO TRANSACTION
                  ON ERROR  UNDO ExcluirConta, LEAVE ExcluirConta
                  ON QUIT   UNDO ExcluirConta, LEAVE ExcluirConta
                  ON STOP   UNDO ExcluirConta, LEAVE ExcluirConta
                  ON ENDKEY UNDO ExcluirConta, LEAVE ExcluirConta:

        FIND FIRST craplpc WHERE craplpc.cdcooper = par_cdcooper
                             AND craplpc.nrdolote = par_nrdolote
                             NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL craplpc THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel " +
                                    "encontrar o Lote.".
                       par_nmdcampo = "nrdolote".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,  /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        IF  craplpc.dtfimlot <> ? THEN
            ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                  " ja se encontra finalizado.".
        ELSE IF craplpc.dtfeclot <> ? THEN
            ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                       " ja se encontra fechado.".
        
        IF aux_dscritic <> '' THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   par_nmdcampo = "nrdolote".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

        FIND FIRST crapipc WHERE crapipc.cdcooper = par_cdcooper
                             AND crapipc.nrdconta = par_nrdconta
                             AND crapipc.nrdolote = par_nrdolote
                             EXCLUSIVE-LOCK NO-ERROR.
        
        IF  NOT AVAIL crapipc THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Esta Conta/DV nao consta no Lote."
                       par_nmdcampo = "nrdconta".
        
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
        ELSE
            DO:
                DELETE crapipc.
    
                FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                                     AND crapass.nrdconta = par_nrdconta
                                     NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Nao foi possivel " +
                                            "encontrar a conta.".
                               par_nmdcampo = "nrdconta".
            
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,  /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                IF  crapass.inpessoa <> 1 THEN
                    DO:
                        /* limpar os avalistas do lote e conta em questao */
                        FOR EACH crapapc WHERE crapapc.cdcooper = par_cdcooper
                                           AND crapapc.nrdolote = par_nrdolote
                                           AND crapapc.nrdconta = par_nrdconta
                                           EXCLUSIVE-LOCK:
                            DELETE crapapc.
                        END.
                    END.
            END.
    END. /* ExcluirConta */

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Consultar Lote      
******************************************************************************/
PROCEDURE consultar_lote:
    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdolote AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cddopcao AS CHAR                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-lote.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-lote.
    EMPTY TEMP-TABLE tt-erro.
    
    FIND FIRST  craplpc WHERE craplpc.cdcooper = par_cdcooper 
                          AND craplpc.nrdolote = par_nrdolote
                          NO-LOCK NO-ERROR.
    
    IF NOT AVAIL craplpc THEN
       DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Lote nao encontrado"
                   par_nmdcampo = "nrdolote".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    CREATE tt-lote.
    BUFFER-COPY craplpc TO tt-lote.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
  Fechar lote      
******************************************************************************/
PROCEDURE fechar_lote:
    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdolote AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_numseque AS INTE                                     NO-UNDO.
    DEF VAR aux_dscriti2 AS CHAR                                     NO-UNDO.
    DEF VAR aux_dscriti3 AS CHAR                                     NO-UNDO.
    DEF VAR aux_nmarqind AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-contas-lote.
    EMPTY TEMP-TABLE tt-arq-brde.

    RUN valida_operad_depto(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                           OUTPUT par_nmdcampo,
                           OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper 
         NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
    DO:
        ASSIGN aux_cdcritic = 0.
               aux_dscritic = "Problema ao acessar dados da cooperativa.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 0,  /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    IF  NOT AVAIL crapdat THEN
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Problema ao carregar data de fechamento " +
                                  "do Lote.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.


    ASSIGN aux_numseque = 0
           aux_dscritic = "".
    
    FIND FIRST craplpc WHERE craplpc.cdcooper = par_cdcooper
                         AND craplpc.nrdolote = par_nrdolote
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplpc THEN
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "PLote nao encontrado".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    IF craplpc.dtcontrt = ? THEN
        aux_dscriti2 = aux_dscriti2 +
                       " - Data de contratacao nao cadastrada.\n".
    IF craplpc.dtpricar = ? THEN
        aux_dscriti2 = aux_dscriti2 +
                       " - Data da primeira carencia nao cadastrada.\n".
    IF craplpc.dtfincar = ? THEN
        aux_dscriti2 = aux_dscriti2 +
                       " - Data da ultima carencia nao cadastrada.\n".
    IF craplpc.dtpriamo = ? THEN
        aux_dscriti2 = aux_dscriti2 +
                       " - Data da primeira amortizacao nao cadastrada.\n".
    IF craplpc.dtultamo = ? THEN
        aux_dscriti2 = aux_dscriti2 +
                       " - Data da ultima amortizacao nao cadastrada.\n".
    IF craplpc.dtfincar >= craplpc.dtpriamo THEN
            aux_dscriti2 = aux_dscriti2 +
                           " - Data final da carencia deve ser menor que" +
                           " data da primeira amortizacao.\n".
    IF DAY(craplpc.dtpricar) <> 15 THEN
        aux_dscriti2 = aux_dscriti2 +
                       " - Dia da primeira carencia deve ser 15.\n".
    IF craplpc.cdmunbce = 0 THEN
        aux_dscriti2 = aux_dscriti2 +
                       " - Codigo BACEN do municipio da operacao " +
                       "nao cadastrado.\n".
    IF craplpc.cdsetpro = 0 THEN
        aux_dscriti2 = aux_dscriti2 +
                       " - Codigo do setor de atividade do projeto (CNAE) " +
                       "nao cadastrado.\n".
    
    IF  aux_dscriti2 <> "" THEN
    DO:
        ASSIGN aux_dscritic = aux_dscritic + 
                              'Lote: ' + STRING(craplpc.nrdolote) +
                              '\n' + aux_dscriti2 + '\n' + 
                              FILL('=',80) + '\n\n'. 
    END.

    FOR EACH crapipc NO-LOCK 
       WHERE crapipc.cdcooper = par_cdcooper
         AND crapipc.nrdolote = par_nrdolote,
        EACH crapass NO-LOCK
       WHERE crapass.cdcooper = crapipc.cdcooper
         AND crapass.nrdconta = crapipc.nrdconta:

        ASSIGN aux_dscriti3 = ''.

        IF  crapipc.vlprocap <= 0 OR crapipc.vlprocap > 30000 THEN
            aux_dscriti3 = aux_dscriti3 + 
                           " - Valor do PROCAPCRED invalido.\n".
        IF crapipc.cdmunben = 0 THEN
            aux_dscriti3 = aux_dscriti3 +
                           " - Codigo BNDES do municipio do cooperado " +
                           "nao cadastrado.\n".
        IF crapipc.cdgenben = 0 THEN
            aux_dscriti3 = aux_dscriti3 +
                           " - Genero do cooperado nao cadastrado.\n".
        IF crapipc.cdporben = 0 THEN
            aux_dscriti3 = aux_dscriti3 +
                           " - Porte do cooperado nao cadastrado.\n".
        IF crapipc.cdsetben = 0 THEN
            aux_dscriti3 = aux_dscriti3 +
                           " - Setor de atividade (CNAE) nao cadastrado.\n".
                
        IF crapass.inpessoa = 1 THEN
        DO:
            FOR FIRST crapprm FIELDS(crapprm.dsvlrprm) WHERE crapprm.cdacesso = 'BRDE_PORTE_COOP_PF' NO-LOCK. END.
            
            IF NOT avail crapprm THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                       aux_dscritic = "Problema ao carregar portes do cooperado PF.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 0,  /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".            
            END.
            /* PF pode ter porte 11, 12, 13, 14 ou 17 - atualizacao layout BRDE (Setembro/2017 - Fabricio) */
            IF NOT CAN-DO(crapprm.dsvlrprm, STRING(crapipc.cdporben)) THEN
            aux_dscriti3 = aux_dscriti3 +
                               " - Porte conta fisica deve ser " + crapprm.dsvlrprm + ".\n".
                               
            IF crapipc.cdporben = 17   AND
               crapipc.cdgenben <> 230 THEN
                aux_dscriti3 = aux_dscriti3 +
                               " - Porte 17 PF somente com genero 230.\n".
        END.
        ELSE
        DO:
            FOR FIRST crapprm FIELDS(crapprm.dsvlrprm) WHERE crapprm.cdacesso = 'BRDE_PORTE_COOP_PJ' NO-LOCK. END.
            
            IF NOT avail crapprm THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                       aux_dscritic = "Problema ao carregar portes do cooperado PJ.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 0,  /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".            
            END.
            /* PJ pode ter porte 21, 24, 25, 26 ou 27 - atualizacao layout BRDE (Setembro/2017 - Fabricio) */
            IF NOT CAN-DO(crapprm.dsvlrprm, STRING(crapipc.cdporben)) THEN
            aux_dscriti3 = aux_dscriti3 +
                           " - Porte conta juridica deve ser " + crapprm.dsvlrprm + ".\n".
                           
            IF crapipc.dtvencnd = ? THEN
            aux_dscriti3 = aux_dscriti3 +
                           " - Data vencimento CND nao informado.\n".
                           
            IF NOT CAN-FIND(FIRST crapapc NO-LOCK
                         WHERE crapapc.cdcooper = crapipc.cdcooper
                           AND crapapc.nrdolote = crapipc.nrdolote
                           AND crapapc.nrdconta = crapipc.nrdconta) THEN 
            aux_dscriti3 = aux_dscriti3 +
                           " - Conta PJ deve ter no minimo 1 avalista.\n".

        END.

        IF  aux_dscriti3 <> "" THEN
        DO:
            ASSIGN aux_dscritic = aux_dscritic + 
                                  'Conta/DV: ' + STRING(crapipc.nrdconta) +
                                  '\n' + aux_dscriti3 + '\n\n'. 
        END.
    END.

    ASSIGN aux_nmarqind = "ERR_LOT_" + 
                           STRING(par_cdcooper,"99") +
                           STRING(par_nrdolote,"999999") + ".txt".

    IF aux_dscritic <> "" THEN
    DO:
        OUTPUT STREAM str_2 TO VALUE("/usr/coop/" + crapcop.dsdircop + 
                                     "/arq/" + aux_nmarqind).
        
        PUT STREAM str_2 UNFORMATTED
            "COOP.: " + STRING(par_cdcooper,"z9")     + FILL(" ",20) +
            "LOTE : " + STRING(par_nrdolote,"zzzzz9") + FILL(" ",20) +
            "DATA : " + STRING(TODAY,"99/99/9999")    + "\n\n".

        PUT STREAM str_2 UNFORMATTED aux_dscritic.
    
        OUTPUT STREAM str_2 CLOSE.
    
        RUN sistema/generico/procedures/b1wgen0011.p
            PERSISTENT SET h-b1wgen0011.
    
        RUN converte_arquivo IN h-b1wgen0011
                            (INPUT par_cdcooper,
                             INPUT "/usr/coop/" + crapcop.dsdircop +
                                   "/arq/" + aux_nmarqind,
                             INPUT aux_nmarqind).
         
        DELETE PROCEDURE h-b1wgen0011.          
                   
        ASSIGN par_nmarquiv = "/micros/" + crapcop.dsdircop + 
                              "/procap/" + aux_nmarqind.

        UNIX SILENT VALUE ("mv /usr/coop/" + crapcop.dsdircop +
                           "/converte/" + aux_nmarqind + " " +
                           par_nmarquiv + " 2>/dev/null").
    
        RETURN "NOK".
    END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    IF  NOT AVAIL crapdat THEN
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Problema ao carregar data de fechamento " +
                                  "do Lote.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    FIND FIRST craplpc WHERE craplpc.cdcooper = par_cdcooper
                         AND craplpc.nrdolote = par_nrdolote
                         EXCLUSIVE-LOCK NO-ERROR.
    IF  NOT AVAIL craplpc THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Lote nao encontrado."
                   par_nmdcampo = "nrdolote".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    ELSE
        DO:
            IF  craplpc.dtfimlot <> ? THEN
                ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                      " ja se encontra finalizado.".
            ELSE IF craplpc.dtfeclot <> ? THEN
                ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                      " ja se encontra fechado.".
                
            IF aux_dscritic <> '' THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       par_nmdcampo = "nrdolote".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
            END.
            /* grava a data de fechamento do lote */
            ASSIGN craplpc.dtfeclot = crapdat.dtmvtolt.
        END.
        
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Reabrir lote      
******************************************************************************/
PROCEDURE reabrir_lote:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdolote AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN valida_operad_depto(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                           OUTPUT par_nmdcampo,
                           OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

    FIND FIRST craplpc WHERE craplpc.cdcooper = par_cdcooper
                         AND craplpc.nrdolote = par_nrdolote
                         EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL craplpc THEN
        DO:
            IF  craplpc.dtfimlot <> ? THEN
                ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                      " ja se encontra finalizado.".
            ELSE IF craplpc.dtfeclot = ? THEN
                ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                      " precisa estar fechado para reabri-lo.".
                
            IF aux_dscritic <> '' THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       par_nmdcampo = "nrdolote".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
            END.
            
            /* reabre o lote retirando a data de fechamento */
            ASSIGN craplpc.dtfeclot = ?.

        END.
    ELSE
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Lote nao existe."
                   par_nmdcampo = "nrdolote".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.    

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Finalizar lote      
******************************************************************************/
PROCEDURE finalizar_lote:
    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdolote AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN valida_operad_depto(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                           OUTPUT par_nmdcampo,
                           OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

    FIND FIRST craplpc WHERE craplpc.cdcooper = par_cdcooper
                         AND craplpc.nrdolote = par_nrdolote
                         EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL craplpc THEN
        DO:
            IF  craplpc.dtfimlot <> ? THEN
                ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                      " ja se encontra finalizado.".
            ELSE IF craplpc.dtfeclot = ? THEN
                ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                      " nao esta fechado.".
                
            IF aux_dscritic <> '' THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       par_nmdcampo = "nrdolote".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
            END.
            
            /* se chegar aki, finaliza o lote */
            ASSIGN craplpc.dtfimlot = par_dtmvtolt.

        END.
    ELSE
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Lote nao existe."
                   par_nmdcampo = "nrdolote".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END. 

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Incluir, Alterar informacoes do Lote      
******************************************************************************/
PROCEDURE alterar_lote:
    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdolote AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtcontrt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtpricar AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtfincar AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtpriamo AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_dtultamo AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdmunbce AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdsetpro AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    RUN valida_operad_depto(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                           OUTPUT par_nmdcampo,
                           OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

    FIND FIRST  craplpc WHERE craplpc.cdcooper = par_cdcooper 
                          AND craplpc.nrdolote = par_nrdolote
                          EXCLUSIVE-LOCK NO-ERROR.
    
    IF NOT AVAIL craplpc THEN
       DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Lote nao encontrado"
                   par_nmdcampo = "nrdolote".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    ASSIGN craplpc.dtcontrt = par_dtcontrt
           craplpc.dtpricar = par_dtpricar
           craplpc.dtfincar = par_dtfincar
           craplpc.dtpriamo = par_dtpriamo
           craplpc.dtultamo = par_dtultamo
           craplpc.cdmunbce = par_cdmunbce
           craplpc.cdsetpro = par_cdsetpro.

    RETURN "OK".

END PROCEDURE.



/*****************************************************************************
  Gerar arquivo para encaminhamento ao BRDE      
******************************************************************************/
PROCEDURE gerar_arq_enc_brde:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdolote AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_des_reto AS CHAR                                      NO-UNDO.  
    DEF VAR aux_cdcooper AS INT                                       NO-UNDO.  
    DEF VAR aux_cdagenci AS INT                                       NO-UNDO.  
    DEF VAR aux_nrdcaixa AS INT                                       NO-UNDO.   
    DEF VAR aux_nrsequen AS INT                                       NO-UNDO.  
    DEF VAR aux_cdcritic AS INT                                       NO-UNDO.  
    DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.  
    
    
    
    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INT      NO-UNDO.
    DEF VAR aux_cont      AS INT      NO-UNDO.
    DEF VAR xml_req       AS CHAR     NO-UNDO.  
  
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
    /* limpar temp-table*/
    EMPTY TEMP-TABLE tt-erro.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    /* Excecutar rotina convertida para oracle*/
    RUN STORED-PROCEDURE pc_gerar_arq_enc_brde_web
        aux_handproc = PROC-HANDLE NO-ERROR
          (INPUT  par_cdcooper,
           INPUT  par_cdagenci,
           INPUT  par_nrdcaixa,
           INPUT  par_cdoperad,
           INPUT  par_dtmvtolt,
           INPUT  par_nrdolote,
           OUTPUT "", /* pr_nmarquiv*/
           OUTPUT "", /* pr_nmdcampo*/
           OUTPUT "", /* pr_des_reto */
           OUTPUT "" /* pr_xml_erro */
          ).
    
    /* Fechar o rotina oracle */ 
    CLOSE STORED-PROC pc_gerar_arq_enc_brde_web
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    /* limpar variaveis*/ 
    ASSIGN par_nmarquiv = ""
           par_nmdcampo = ""
           aux_des_reto = "".
    
    /*buscar valores de prm de saidas*/
    ASSIGN par_nmarquiv = pc_gerar_arq_enc_brde_web.pr_nmarquiv 
                          WHEN pc_gerar_arq_enc_brde_web.pr_nmarquiv <> ?       
           par_nmdcampo = pc_gerar_arq_enc_brde_web.pr_nmdcampo 
                          WHEN pc_gerar_arq_enc_brde_web.pr_nmdcampo <> ?
           aux_des_reto = pc_gerar_arq_enc_brde_web.pr_des_reto 
                          WHEN pc_gerar_arq_enc_brde_web.pr_des_reto <> ?.      
    
    /* senao retornou OK buscar critica*/
    IF aux_des_reto <> "OK" THEN
    DO:
    
      /*************************************************************/
      /* Buscar o XML na tabela de retorno da procedure Progress */ 
      ASSIGN xml_req = pc_gerar_arq_enc_brde_web.pr_xml_erro. 

      /* Efetuar a leitura do XML*/ 
      SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
      PUT-STRING(ponteiro_xml,1) = xml_req. 
     
      xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
      xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.

      DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

          xRoot:GET-CHILD(xRoot2,aux_cont_raiz) NO-ERROR. 

          IF   xRoot2:SUBTYPE <> "ELEMENT"   THEN 
               NEXT. 

          /* Limpar variaveis  */ 
          ASSIGN aux_cdcooper = 0
                 aux_cdagenci = 0
                 aux_nrdcaixa = 0
                 aux_nrsequen = 0
                 aux_cdcritic = 0
                 aux_dscritic = "".
          DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 

            xRoot2:GET-CHILD(xField,aux_cont) NO-ERROR. 

            IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 

            xField:GET-CHILD(xText,1) NO-ERROR. 

            /* Se nao vier conteudo na TAG */ 
            IF ERROR-STATUS:ERROR             OR  
               ERROR-STATUS:NUM-MESSAGES > 0  THEN
               NEXT.
                    
            ASSIGN aux_cdcooper = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdcooper"
                   aux_cdagenci = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdagenci"
                   aux_nrdcaixa = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrdcaixa"
                   aux_nrsequen = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrsequen"
                   aux_cdcritic = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdcritic"
                   aux_dscritic = xText:NODE-VALUE       WHEN xField:NAME = "dscritic".
            
            
          END. /* fim loop elemento*/
          
          /*gerar registro de critica, somente se tiver critica*/
          IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
          DO:
            MESSAGE STRING(aux_nrsequen) aux_dscritic VIEW-AS ALERT-BOX.
            RUN gera_erro (INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_nrsequen,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
          END.
          
      END.   /*fim loop raiz*/ 
      
      SET-SIZE(ponteiro_xml) = 0. 
      
      /* se no final a tt-erro ainda esta sem
         registro inserir critica generica */
      FIND FIRST tt-erro NO-ERROR.
      
      IF NOT AVAIL tt-erro THEN
      DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Nao foi possivel gerar arquivo" + 
                              "(pc_gerar_arq_enc_~ brde_web): " + 
                              aux_des_reto.
        
        RUN gera_erro (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_nrsequen,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
      END.
      
      RETURN "NOK".
      
    END. /*Fim IF pr_des_reto <> "OK"*/
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Gerar arquivo final ao BRDE      
******************************************************************************/
PROCEDURE gerar_arq_fin_brde:

    /* opcao ainda  a ser desenvolvida */
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Relatorio de lotes      
******************************************************************************/
PROCEDURE relatorio_lote:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdolote AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_nmtitula AS CHAR                                     NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI                                     NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                     NO-UNDO.
    DEF VAR aux_tpendass AS INTE                                     NO-UNDO.
    DEF VAR aux_qtdtotal AS INTE                                     NO-UNDO.
    DEF VAR aux_vlrtotal AS DECI                                     NO-UNDO.

     /***Cabecalho****/
    DEF VAR rel_nmrescop AS CHAR                                       NO-UNDO.
    DEF VAR rel_nmresemp AS CHAR  FORMAT "x(15)"                       NO-UNDO.
    DEF VAR rel_nmrelato AS CHAR  FORMAT "x(40)"                       NO-UNDO.
    DEF VAR rel_nrmodulo AS INTE  FORMAT     "9"                       NO-UNDO.
    DEF VAR rel_nmempres AS CHAR  FORMAT "x(15)"                       NO-UNDO.
    DEF VAR rel_nmdestin AS CHAR                                       NO-UNDO.
    DEF VAR rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 5              
                                  INIT ["","","","",""]                NO-UNDO.

    FORM SKIP(1)
         par_nrdolote     AT  1  FORMAT "zzz,zz9"         LABEL "NUMERO DO LOTE"
         SKIP(1)
         WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_cab_lote.

    FORM crapass.cdagenci AT   1 FORMAT "zz9"             LABEL "PA"
         crapipc.nrdconta AT   7 FORMAT "zzzz,zzz,9"      LABEL "CONTA/DV"
         aux_nmtitula     AT  20 FORMAT "x(50)"           LABEL "TITULAR"
         aux_nrcpfcgc     AT  74 FORMAT "zzzzzzzzzzzzz9"  LABEL "CPF/CNPJ"
         crapenc.nmcidade AT  91 FORMAT "X(30)"           LABEL "CIDADE"
         crapipc.vlprocap AT 124 FORMAT "zzz,zzz,zz9.99"  LABEL "VALOR"
         crapipc.dtcndfed AT 143 FORMAT "99/99/9999"      LABEL "VENCIMENTO CND FEDERAL"
         crapipc.dtcndfgt AT 168 FORMAT "99/99/9999"      LABEL "VENCIMENTO CND FGTS"
         crapipc.dtcndest AT 190 FORMAT "99/99/9999"      LABEL "VENCIMENTO CND ESTADUAL"
         crapipc.dtvencnd AT 216 FORMAT "99/99/9999"      LABEL "VENCIMENTO CND INSS"
         WITH DOWN NO-BOX NO-LABELS WIDTH 234 FRAME f_contas_lote.
    
    FORM aux_qtdtotal     AT 205 FORMAT "zzz,zzz,zz9"        LABEL "QUANTIDADE"
         aux_vlrtotal     AT 217 FORMAT "zzz,zzz,zzz,zz9.99" LABEL "VALOR TOTAL"
         WITH DOWN NO-BOX NO-LABELS WIDTH 234 FRAME f_rodape_lote.


    FIND FIRST  craplpc WHERE craplpc.cdcooper = par_cdcooper 
                          AND craplpc.nrdolote = par_nrdolote
                          NO-LOCK NO-ERROR.
    
    IF NOT AVAIL craplpc THEN
       DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Lote nao encontrado"
                   par_nmdcampo = "nrdolote".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper 
             NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_dscritic = "Cooperativa nao encontrada".
            LEAVE Imprime.
        END.

        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop +
                              "/rl/lotprc".
        
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               par_nmarqimp = aux_nmendter + ".ex"
               par_nmarqpdf = aux_nmendter + ".pdf".

        OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 82.

        { sistema/generico/includes/b1cabrel234.i "1" "669"}
        
        DISPLAY STREAM str_1 par_nrdolote WITH FRAME f_cab_lote.
        

        ASSIGN aux_qtdtotal = 0
               aux_vlrtotal = 0.

        FOR EACH crapipc WHERE crapipc.cdcooper = par_cdcooper
                           AND crapipc.nrdolote = par_nrdolote
                           NO-LOCK:
            
            ASSIGN aux_nmtitula = ""
                   aux_nrcpfcgc = 0.

            FIND FIRST crapass WHERE crapass.cdcooper = crapipc.cdcooper
                                 AND crapass.nrdconta = crapipc.nrdconta
                                 NO-LOCK NO-ERROR.
            IF NOT AVAIL crapass THEN
            DO:
                ASSIGN aux_dscritic = "Associado nao encontrado " +
                                      "(" + STRING(crapipc.nrdconta) + ")".
                LEAVE Imprime.
            END.

            IF  crapass.inpessoa = 1 THEN
            DO:
               FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper
                                    AND crapttl.nrdconta = crapass.nrdconta
                                    AND crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
               IF NOT AVAIL crapttl THEN
               DO:
                   ASSIGN aux_dscritic = "Titular da conta nao encontrado " +
                                         "(" + STRING(crapipc.nrdconta) + ")".
                   LEAVE Imprime.
               END.
               
               ASSIGN aux_nmtitula = crapttl.nmextttl
                      aux_nrcpfcgc = crapttl.nrcpfcgc
                      aux_tpendass = 10.

            END.
            ELSE /* se nao for pesoa fisica */
            DO:
                ASSIGN aux_nmtitula = crapass.nmprimtl
                       aux_nrcpfcgc = crapass.nrcpfcgc
                       aux_tpendass = 9.
            END.

            FIND FIRST crapenc
                 WHERE crapenc.cdcooper = crapass.cdcooper AND
                       crapenc.nrdconta = crapass.nrdconta AND
                       crapenc.idseqttl = 1                AND
                       crapenc.tpendass = aux_tpendass
                       NO-LOCK NO-ERROR.
            IF NOT AVAIL crapenc THEN
            DO:
                ASSIGN aux_dscritic = "Endereco nao encontrado " +
                                      "(" + STRING(crapipc.nrdconta) + ")".
                LEAVE Imprime.
            END.
            
            DISPLAY STREAM str_1 crapass.cdagenci
                                 crapipc.nrdconta
                                 aux_nmtitula
                                 aux_nrcpfcgc
                                 crapenc.nmcidade
                                 crapipc.vlprocap
                                 crapipc.dtcndfed
                                 crapipc.dtcndfgt
                                 crapipc.dtcndest
                                 crapipc.dtvencnd
                                 WITH FRAME f_contas_lote.

            DOWN WITH FRAME f_contas_lote.

            ASSIGN aux_qtdtotal = aux_qtdtotal + 1
                   aux_vlrtotal = aux_vlrtotal + crapipc.vlprocap.

        END. /* for each crapipc */

        DISP STREAM str_1 SKIP WITH FRAME f_abc.

        DISPLAY STREAM str_1 aux_qtdtotal aux_vlrtotal
                WITH FRAME f_rodape_lote.

        OUTPUT STREAM str_1 CLOSE.
        
        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.
        
        IF NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0024.".
                LEAVE Imprime.
            END.

        RUN envia-arquivo-web IN h-b1wgen0024 
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_nmarqimp,
             OUTPUT par_nmarqpdf,
             OUTPUT TABLE tt-erro ).

        IF  VALID-HANDLE(h-b1wgen0024)  THEN
            DELETE PROCEDURE h-b1wgen0024.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.

    END. /* Imprime */
    
    IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS  AND 
       (aux_dscritic <> "" OR aux_cdcritic <> 0)  THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Verificar Conta e Lote, carregar avalistas      
******************************************************************************/
PROCEDURE verificar_conta_lote:
    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdolote AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    DEF  OUTPUT PARAM TABLE FOR tt-avalistas.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_nmdavali AS CHAR                                     NO-UNDO.

    DEF BUFFER b-crapass FOR crapass.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-avalistas.

    ASSIGN par_nmdcampo = "".
    
    RUN validar_conta_lote (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_nrdconta,
                            INPUT par_nrdolote,
                           OUTPUT par_nmdcampo,
                           OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    
    /* verificar se a conta ja consta no lote */
    IF  CAN-FIND(crapipc WHERE crapipc.cdcooper = par_cdcooper
                           AND crapipc.nrdconta = par_nrdconta
                           AND crapipc.nrdolote = par_nrdolote
                           NO-LOCK) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta ja existente no lote " + 
                                  STRING(par_nrdolote) + "."
                   par_nmdcampo = "nrdconta".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND FIRST craplpc WHERE craplpc.cdcooper = par_cdcooper
                         AND craplpc.nrdolote = par_nrdolote
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplpc THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao foi possivel " +
                                "encontrar o Lote.".
                   par_nmdcampo = "nrdolote".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    IF  craplpc.dtfimlot <> ? THEN
        ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                              " ja se encontra finalizado.".
    ELSE IF craplpc.dtfeclot <> ? THEN
        ASSIGN aux_dscritic = "O Lote " + STRING(par_nrdolote) + 
                                   " ja se encontra fechado.".
    
    IF aux_dscritic <> '' THEN
    DO:
        ASSIGN aux_cdcritic = 0
               par_nmdcampo = "nrdolote".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                         AND crapass.nrdconta = par_nrdconta
                         NO-ERROR.
    
    IF  NOT AVAIL crapass THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta nao encontrada!".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    ASSIGN par_inpessoa = crapass.inpessoa.

    IF  crapass.inpessoa <> 1 THEN
        DO:
            /* carregar avalistas da conta PJ*/
            FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper    
                               AND crapavt.tpctrato = 6
                               AND crapavt.nrdconta = par_nrdconta 
                               NO-LOCK:
                IF  crapavt.nrdctato = 0 THEN
                    ASSIGN aux_nmdavali = crapavt.nmdavali.
                ELSE
                DO:
                    FIND FIRST b-crapass 
                         WHERE b-crapass.cdcooper = crapavt.cdcooper
                           AND b-crapass.nrdconta = crapavt.nrdctato
                           NO-LOCK NO-ERROR.

                    IF  NOT AVAIL b-crapass THEN
                        ASSIGN aux_nmdavali = "".
                    ELSE
                        ASSIGN aux_nmdavali = b-crapass.nmprimtl.

                END.
                
                CREATE tt-avalistas.
                ASSIGN tt-avalistas.nrcpfcgc = crapavt.nrcpfcgc
                       tt-avalistas.nrdctato = crapavt.nrdctato
                       tt-avalistas.nmdavali = aux_nmdavali.
            END.
        END.

    RETURN "OK".
    
END PROCEDURE.


/*****************************************************************************
  Validar Conta e Lote       
******************************************************************************/
PROCEDURE validar_conta_lote:
    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdolote AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    ASSIGN par_nmdcampo = "".

    IF NOT CAN-FIND(FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                                    AND crapass.nrdconta = par_nrdconta
                                    NO-LOCK) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta invalida!"
                   par_nmdcampo = "nrdconta".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    /* validar se lote existe */
    IF NOT CAN-FIND(FIRST craplpc WHERE craplpc.cdcooper = par_cdcooper
                                    AND craplpc.nrdolote = par_nrdolote
                                    NO-LOCK) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Lote nao encontrado!"
                   par_nmdcampo = "nrdolote".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    RETURN "OK".
    
END PROCEDURE.


/*****************************************************************************
  Localizar codigo do municipio conforme BNDES      
******************************************************************************/
PROCEDURE codigo_cidade_bacen_bndes:
    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_cdcidbac AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_cdcidbnd AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    ASSIGN par_nmdcampo = "".

    /* codigos BACEN e BNDES das cidades sedes das cooperativas */

    CASE par_cdcooper:
        WHEN 1 OR 
        WHEN 2 OR 
        WHEN 3 OR 
        WHEN 4 THEN /* cooperativas de Blumenau SC */
           ASSIGN par_cdcidbac = 12311        par_cdcidbnd = 4202404.
        WHEN 5 THEN /* cooperativa de Criciuma SC */
           ASSIGN par_cdcidbac = 9379        par_cdcidbnd = 4204608.
        WHEN 6 OR 
        WHEN 7 OR 
        WHEN 8 OR 
        WHEN 9 THEN /* cooperativas de Florianopolis SC */
           ASSIGN par_cdcidbac = 21216        par_cdcidbnd = 4205407.
        WHEN 10 THEN /* cooperativa de Lages SC */
           ASSIGN par_cdcidbac = 38003        par_cdcidbnd = 4209300.
        WHEN 11 THEN /* cooperativa de Itajai SC */
           ASSIGN par_cdcidbac = 4556        par_cdcidbnd = 4208203.
        WHEN 12 THEN /* cooperativa de Guaramirim SC */
           ASSIGN par_cdcidbac = 23025        par_cdcidbnd = 4206504.
        WHEN 13 THEN /* cooperativa de Sao Bento do Sul SC */
           ASSIGN par_cdcidbac = 14632        par_cdcidbnd = 4215802.
        WHEN 14 THEN /* cooperativa de Francisco Beltrao PR */
           ASSIGN par_cdcidbac = 17938        par_cdcidbnd = 4108403.
        WHEN 15 THEN /* cooperativa de Porto Uniao SC */
           ASSIGN par_cdcidbac = 3595        par_cdcidbnd = 4213609.
        WHEN 16 THEN /* cooperativa de Ibirama SC */
           ASSIGN par_cdcidbac = 15765        par_cdcidbnd = 4206900.
    END CASE.
      
    RETURN "OK".
    
END PROCEDURE.



/*****************************************************************************
  Verificar permissao de acesso conforme departamento
******************************************************************************/
PROCEDURE valida_operad_depto:
    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF  VAR aux_dscritic AS CHAR                                    NO-UNDO.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper  AND
                       crapope.cdoperad = par_cdoperad
                       NO-LOCK NO-ERROR.
        
    IF  NOT AVAIL crapope THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao foi possivel " +
                                "encontrar o operador.".
                   par_nmdcampo = "cdoperad".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

     IF   crapope.cddepart <> 20   AND  /* TI */
          crapope.cddepart <> 14  THEN  /* PRODUTOS */
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Voce nao tem permissao para realizar " 
                                    + "esta acao.".

              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
              RETURN "NOK".
          END.

      RETURN "OK".

END PROCEDURE.
