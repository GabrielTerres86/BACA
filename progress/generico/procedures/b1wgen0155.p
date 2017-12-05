/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+----------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL              |
  +------------------------------------------+----------------------------------+
  | sistema/generico/procedures/b1wgen0155.p |                                  |
  |    retorna-valor-blqjud                  |GENE0005.pc_retorna_valor_blqjud  |
  |    busca-contas-cooperado                |BLQJ0001.pc_busca_contas_cooperado|
  |    inclui-bloqueio-jud                   |BLQJ0001.pc_inclui_bloqueio_jud   |
  |    efetua-desbloqueio-jud                |BLQJ0001.pc_efetua_desbloqueio_jud|
  +------------------------------------------+----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/











/*..............................................................................
    
   Programa: b1wgen0155.p                  
   Autora  : Guilherme / SUPERO
   Data    : 23/04/2013                        Ultima atualizacao: 05/12/2014

   Dados referentes ao programa:

   Objetivo  : BO DE PROCEDURES PARA BLOQUEIO JUDICIAL

   Alteracoes: 06/09/2013 - Incluir Ajustes na pocedure consulta-bloqueio-jud,
                            para retornar todos bloqueios para conta.
                          - Ajustado consulta-bloqueio-jud para retornar dados
                            somente para cada opcao (Lucas R.).
                            
               11/10/2013 - Ajuste na consulta dos registros na tela BLQJUD
                            (Andre/Supero).
               
               13/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               19/11/2013 - Retirar a critica de Resp.Legal/Procurador (Ze). 
               
               04/12/2013 - Ajustes na procedure busca-contas-cooperado,
                            retirado delete procedure da b1wgen0001 do for each
                            e movido para fora do for each tt-cooperado
                            (Lucas R.)
                            
               11/12/2013 - Alterado tt-imprime-total.dsmodali de Poup. 
                            Programada para Poupanca Programada (Lucas R.)
                            
               12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
               
               17/09/2014 - Ajustes e adequacao para melhorar codificacao do 
                            fonte. Retirado param de saida tt-grid da 
                            proc. consulta-bloqueio-jud. Introduzido SQL 
                            dinamico em consulta da mesma proc.
                            (Jorge/Gielow - SD 175038)
                            
               25/09/2014 - Incluido novos parametros na procedure 
                            carrega_dados_atenda na b1wgen0001, alterando
                            a RUN da proc carrega_dados_atenda para receber
                            esses novos parametros de saida.
                            (Andre Santos - SUPERO)

               29/09/2014 - Substituicao da chamada da procedure consulta-aplicacoes 
                            da BO b1wgen0004 pela procedure pc_lista_aplicacoes_car 
                            da package APLI0005.
                            (Carlos Rafael Tanholi - Projeto CAPTACAO)
                            
               27/11/2014 - (Chamado 190747) - Melhoria na tela BLQJUD,
                            deduzir do capital, o saldo devedor dos 
                            empréstimos/financiamentos realizados pelo cooperado 
                            (Tiago Castro - RKAM).	

			   05/12/2014 - Incluido novos parametros na procedure 
                            carrega_dados_atenda na b1wgen0001, alterando
                            a RUN da proc carrega_dados_atenda para receber
                            esses novos parametros de entrada. (Daniel)
                            
               27/08/2015 - Retirar a verificao de bloqueio somente no dia atual
                            ou maior para ler todos os bloqueios.
                            (Jorge/Gielow) - SD 310965                
                            
..............................................................................*/
 
{ sistema/generico/includes/b1wgen0155tt.i }

{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0031tt.i }
{ sistema/generico/includes/b1wgen0085tt.i }
{ sistema/generico/includes/b1wgen0192tt.i }


{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }         
{ sistema/generico/includes/b1cabrelvar.i }

{ sistema/generico/includes/var_oracle.i }


DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_flresplg AS LOGICAL                                        NO-UNDO.

DEF VAR h-b1wgen0001 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0004 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0006 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.

DEF STREAM str_1.


/*............................................................................*/

PROCEDURE busca-nrcpfcgc-cooperado:
    
    DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cooperad AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    
    /*** FAZ A BUSCA POR CPF/CNPJ ***/    
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper       AND
                             crapass.nrcpfcgc = DECI(par_cooperad)
                             NO-LOCK NO-ERROR.
    
    /*** SE NAO ACHOU FAZ A BUSCA POR CONTA ***/
    IF  NOT AVAILABLE crapass  THEN
        DO: 
            FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                     crapass.nrdconta = INT(par_cooperad)
                                     NO-LOCK NO-ERROR.
     
            IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN par_nmprimtl = "COOEPRADO NAO ENCONTRADO".
                    RETURN "NOK".
                END.
            ELSE
                ASSIGN par_nrcpfcgc = crapass.nrcpfcgc
                       par_nmprimtl = crapass.nmprimtl.
        END.
    ELSE
        ASSIGN par_nrcpfcgc = crapass.nrcpfcgc
               par_nmprimtl = crapass.nmprimtl.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE busca-contas-cooperado:

    DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.  
    DEF INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtoan AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cooperad AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM ret_nmprimtl AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-cooperado.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crabblj FOR crapblj.
    
    DEF VAR aux_vlsldapl AS DECIMAL DECIMALS 8                      NO-UNDO.
    DEF VAR aux_vlsldpou AS DECIMAL DECIMALS 8                      NO-UNDO.
    DEF VAR aux_vlsldrpp AS DECIMAL DECIMALS 8                      NO-UNDO.

    DEF VAR aux_flconven AS INTE                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlsdeved AS DECIMAL DECIMALS 8                      NO-UNDO.

    EMPTY TEMP-TABLE tt-cooperado.
    EMPTY TEMP-TABLE tt-erro.
    
    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
    DEF VAR h-b1wgen0002  AS HANDLE   NO-UNDO.
    DEF VAR aux_vltotemp  AS DECIMAL  NO-UNDO.
    DEF VAR aux_vltotpre  AS DECIMAL  NO-UNDO.
    DEF VAR aux_qtprecal  AS DECIMAL  NO-UNDO.
    

    ASSIGN aux_dsorigem = "AYLLOS"
           aux_dstransa = "Consultar dados para Bloqueio Judicial.".
    
    RUN busca-nrcpfcgc-cooperado(INPUT par_cdcooper,
                                 INPUT par_cooperad,
                                OUTPUT aux_nrcpfcgc,
                                OUTPUT ret_nmprimtl).
        
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            ASSIGN aux_cdcritic = 009
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    /* Instancia a BO */
    RUN sistema/generico/procedures/b1wgen0001.p 
        PERSISTENT SET h-b1wgen0001.

    IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
        DO:
           ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0001.".
           LEAVE.
        END.

    FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrcpfcgc = aux_nrcpfcgc
                           NO-LOCK:
        
        CREATE tt-cooperado.
        ASSIGN tt-cooperado.cdcooper = crapass.cdcooper
               tt-cooperado.nrdconta = crapass.nrdconta
               tt-cooperado.nrcpfcgc = crapass.nrcpfcgc.
              
    END.
        
    FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                           crapttl.nrcpfcgc = aux_nrcpfcgc
                           NO-LOCK:
        
        FIND FIRST tt-cooperado WHERE tt-cooperado.cdcooper = crapttl.cdcooper
                                  AND tt-cooperado.nrdconta = crapttl.nrdconta
                                  NO-LOCK NO-ERROR.

        IF  NOT AVAIL tt-cooperado THEN
            DO:
                CREATE tt-cooperado.
                ASSIGN tt-cooperado.cdcooper = crapttl.cdcooper
                       tt-cooperado.nrdconta = crapttl.nrdconta
                       tt-cooperado.nrcpfcgc = crapttl.nrcpfcgc.
            END.
    END. 
    
    FOR EACH tt-cooperado:
        
        ASSIGN aux_vlsldapl = 0
               aux_vlsldpou = 0.
        
        FIND crapass WHERE crapass.cdcooper = tt-cooperado.cdcooper AND
                           crapass.nrdconta = tt-cooperado.nrdconta
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT 9,
                               INPUT-OUTPUT aux_dscritic).

                ret_nmprimtl = aux_dscritic.
        
                RETURN "NOK".
            END.
        
        
        IF  crapass.inpessoa = 1 THEN
            DO:
                FIND LAST crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                        crapttl.nrdconta = crapass.nrdconta AND
                                        crapttl.idseqttl = par_idseqttl   
                                        NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapttl THEN
                    DO:
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,
                                       INPUT 821,
                                       INPUT-OUTPUT aux_dscritic).

                        ret_nmprimtl = aux_dscritic.
        
                        RETURN "NOK".
                    END.
            END.

        EMPTY TEMP-TABLE tt-valores_conta.
        
        IF  VALID-HANDLE(h-b1wgen0001) THEN
            DO:
                RUN carrega_dados_atenda IN h-b1wgen0001
                                        (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,   
                                         INPUT par_dtmvtolt,
                                         INPUT par_dtmvtopr,
                                         INPUT par_dtmvtoan,
                                         INPUT par_dtiniper,
                                         INPUT par_dtfimper,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT crapass.nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT crapass.nrdctitg,
                                         INPUT par_inproces,
                                         INPUT FALSE,
                                        OUTPUT aux_flconven,
                                        OUTPUT aux_cdcritic,
                                        OUTPUT aux_dscritic, 
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-cabec,
                                        OUTPUT TABLE tt-comp_cabec,
                                        OUTPUT TABLE tt-valores_conta,
                                        OUTPUT TABLE tt-crapobs,
                                        OUTPUT TABLE tt-mensagens-atenda,
                                        OUTPUT TABLE tt-arquivos).
            END.



        /* Inicializando objetos para leitura do XML */ 
        CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
        CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
        CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
        CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
        CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
        
        /* Efetuar a chamada a rotina Oracle */ 
        RUN STORED-PROCEDURE pc_lista_aplicacoes_car
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                 INPUT par_cdoperad, /* Código do Operador */
                                                 INPUT par_nmdatela, /* Nome da Tela */
                                                 INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                 INPUT 1,            /* Numero do Caixa */
                                                 INPUT crapass.nrdconta, /* Número da Conta */
                                                 INPUT 1,            /* Titular da Conta */
                                                 INPUT 1,            /* Codigo da Agencia */
                                                 INPUT par_nmdatela,  /* Codigo do Programa */
                                                 INPUT 0,            /* Número da Aplicaçao - Parâmetro Opcional */
                                                 INPUT 0,            /* Código do Produto – Parâmetro Opcional */ 
                                                 INPUT par_dtmvtolt, /* Data de Movimento */
                                                 INPUT 6,            /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                                 INPUT 1,            /* Identificador de Log (0 – Nao / 1 – Sim) */ 																 
                                                OUTPUT ?,            /* XML com informaçoes de LOG */
                                                OUTPUT 0,            /* Código da crítica */
                                                OUTPUT "").          /* Descriçao da crítica */
        
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_lista_aplicacoes_car
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        
        /* Busca possíveis erros */ 
        ASSIGN aux_cdcritic = 0
               aux_dscritic = ""
               aux_cdcritic = pc_lista_aplicacoes_car.pr_cdcritic 
                              WHEN pc_lista_aplicacoes_car.pr_cdcritic <> ?
               aux_dscritic = pc_lista_aplicacoes_car.pr_dscritic 
                              WHEN pc_lista_aplicacoes_car.pr_dscritic <> ?.
        
        IF aux_cdcritic <> 0 OR
           aux_dscritic <> "" THEN
         DO:
             CREATE tt-erro.
             ASSIGN tt-erro.cdcritic = aux_cdcritic
                    tt-erro.dscritic = aux_dscritic.
        
             BELL.
             MESSAGE tt-erro.dscritic.
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 PAUSE 3 NO-MESSAGE.
                 LEAVE.
             END.
             HIDE MESSAGE NO-PAUSE.
        
             RETURN "NOK".
        
          END.
        
        EMPTY TEMP-TABLE tt-saldo-rdca.
        
        /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
         para visualizacao dos registros na tela */
        
        /* Buscar o XML na tabela de retorno da procedure Progress */ 
         ASSIGN xml_req = pc_lista_aplicacoes_car.pr_clobxmlc. 
        
         /* Efetuar a leitura do XML*/ 
         SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
         PUT-STRING(ponteiro_xml,1) = xml_req. 
        
         IF ponteiro_xml <> ? THEN
             DO:
                 xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                 xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
                 DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
                     xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
                     IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                      NEXT. 
        
                     IF xRoot2:NUM-CHILDREN > 0 THEN
                       CREATE tt-saldo-rdca.
        
                     DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
        
                         xRoot2:GET-CHILD(xField,aux_cont).
        
                         IF xField:SUBTYPE <> "ELEMENT" THEN 
                             NEXT. 
        
                         xField:GET-CHILD(xText,1).
                         
                         ASSIGN tt-saldo-rdca.sldresga = DEC (xText:NODE-VALUE) WHEN xField:NAME = "sldresga".
                         ASSIGN tt-saldo-rdca.dssitapl =      xText:NODE-VALUE  WHEN xField:NAME = "dssitapl".
        
                     END. 
        
                 END.
        
                 SET-SIZE(ponteiro_xml) = 0. 
             END.
        
         DELETE OBJECT xDoc. 
         DELETE OBJECT xRoot. 
         DELETE OBJECT xRoot2. 
         DELETE OBJECT xField. 
         DELETE OBJECT xText.
    
        FOR EACH tt-saldo-rdca WHERE 
                 tt-saldo-rdca.dssitapl <> "BLOQUEADA" NO-LOCK:
    
                 ASSIGN aux_vlsldapl = aux_vlsldapl +
                                       tt-saldo-rdca.sldresga.
        END.
    
        EMPTY TEMP-TABLE tt-saldo-rdca.
        
        EMPTY TEMP-TABLE tt-dados-rpp.
        
        /** Saldo das aplicacoes **/
        RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT
            SET h-b1wgen0006.

        IF  VALID-HANDLE(h-b1wgen0006)  THEN
            DO:
                RUN consulta-poupanca IN h-b1wgen0006 
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_cdoperad,
                                       INPUT par_nmdatela,
                                       INPUT 1,
                                       INPUT crapass.nrdconta,
                                       INPUT par_idseqttl,
                                       INPUT 0,
                                       INPUT par_dtmvtolt,
                                       INPUT par_dtmvtopr,
                                       INPUT 1,
                                       INPUT par_nmdatela,
                                       INPUT FALSE,  /** Nao Gerar Log **/
                                       OUTPUT aux_vlsldrpp,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-dados-rpp).
        
                DELETE PROCEDURE h-b1wgen0006.
            
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                        IF  AVAILABLE tt-erro  THEN
                            DO:
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,
                                               INPUT tt-erro.cdcritic,
                                               INPUT-OUTPUT tt-erro.dscritic).

                                ret_nmprimtl = tt-erro.dscritic.
        
                                RETURN "NOK".
                            END.
                    END.
            END.
        
        FOR EACH tt-dados-rpp WHERE 
                 tt-dados-rpp.dsblqrpp <> "Sim" NO-LOCK: /* Bloq. Garantia */
            ASSIGN aux_vlsldpou = aux_vlsldpou + tt-dados-rpp.vlrgtrpp.
        END.
        
        FOR EACH crabblj WHERE crabblj.cdcooper = par_cdcooper AND
                               crabblj.nrdconta = crapass.nrdconta
                               NO-LOCK:

            IF   crabblj.cdtipmov <> 2            AND
                 crabblj.dtblqfim = ?             THEN
                 DO:
                     IF   crabblj.cdmodali = 2 THEN  /* APLICACAO */
                          ASSIGN aux_vlsldapl = aux_vlsldapl - crabblj.vlbloque.

                     IF   crabblj.cdmodali = 3 THEN  /* POUP. PROGRAMADA */
                          ASSIGN aux_vlsldpou = aux_vlsldpou - crabblj.vlbloque.

                     IF   crabblj.cdmodali = 4 THEN  /* CAPITAL */
                          ASSIGN tt-valores_conta.vlsldcap =
                                 tt-valores_conta.vlsldcap - crabblj.vlbloque.
                 END.             
        END.
        
        /* Buscar valor do saldo devedor dos empréstimos ativos, contratados a partir de Outubro/2014 e
           modalidades de linha de credito (emprestimo/financiamento) */
           
        FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper      AND
                               crapepr.inliquid = 0                 AND
                               crapepr.vlsdeved > 0                 AND
                               crapepr.nrdconta = crapass.nrdconta  AND
                               crapepr.dtmvtolt >= 10/01/2014   NO-LOCK
           ,EACH craplcr WHERE craplcr.cdlcremp = crapepr.cdlcremp  AND
                               craplcr.cdcoope  = crapepr.cdcoope   AND
                               CAN-DO("EMPRESTIMO,FINANCIAMENTO", craplcr.dsoperac)  NO-LOCK:            
            
            ASSIGN aux_vltotemp = 0.
            
            RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.
            
            
            RUN saldo-devedor-epr IN h-b1wgen0002
                                   (INPUT par_cdcooper,
                                    INPUT 0,             /* p-cod-agencia */
                                    INPUT 0,             /* p-nro-caixa   */
                                    INPUT par_cdoperad,
                                    INPUT "B1WGEN0155",
                                    INPUT 1,             /* Ayllos        */
                                    INPUT crapass.nrdconta,
                                    INPUT 1,             /* par_idseqttl  */
                                    INPUT par_dtmvtolt,
                                    INPUT par_dtmvtopr,
                                    INPUT crapepr.nrctremp,             /* Contrato      */
                                    INPUT "B1WGEN0155",
                                    INPUT par_inproces,
                                    INPUT FALSE,         /* Nao Logar     */
                                   OUTPUT aux_vltotemp,  /* Tot Empestimo */
                                   OUTPUT aux_vltotpre,  /* Val Prestacao */
                                   OUTPUT aux_qtprecal,
                                   OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE = "NOK"  THEN
            DO:
              FIND FIRST tt-erro NO-LOCK NO-ERROR.   
              IF  AVAILABLE tt-erro  THEN
              DO:
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,
                                 INPUT tt-erro.cdcritic,
                                 INPUT-OUTPUT tt-erro.dscritic).

                  ret_nmprimtl = tt-erro.dscritic.

                  RETURN "NOK".
              END.
            END.
            
            /* acumula saldo de todos emprestimos ativos */
            ASSIGN aux_vlsdeved = aux_vlsdeved + aux_vltotemp.
            
        END.        
        
        FIND FIRST tt-valores_conta NO-LOCK NO-ERROR.
        
        IF  AVAIL tt-valores_conta THEN 
            DO:
                /* subtrai o total de saldo devedor dos emprestimos */
                ASSIGN tt-valores_conta.vlsldcap = tt-valores_conta.vlsldcap - aux_vlsdeved.                
                
                ASSIGN tt-cooperado.vlsldcap = 
                               IF  tt-valores_conta.vlsldcap < 0 THEN 0
                               ELSE tt-valores_conta.vlsldcap
                       tt-cooperado.vlsldapl = 
                               IF  aux_vlsldapl < 0 THEN 0
                               ELSE aux_vlsldapl
                       tt-cooperado.vlstotal = 
                               IF  tt-valores_conta.vlstotal < 0 THEN 0
                               ELSE tt-valores_conta.vlstotal
                       tt-cooperado.vlsldppr = 
                               IF  aux_vlsldpou < 0 THEN 0
                               ELSE aux_vlsldpou.
            END.
        
    END.

    IF  VALID-HANDLE(h-b1wgen0004) THEN
        DELETE PROCEDURE h-b1wgen0004. 

    IF  VALID-HANDLE(h-b1wgen0001) THEN
        DELETE PROCEDURE h-b1wgen0001. 

    RETURN "OK".

END PROCEDURE.


PROCEDURE inclui-bloqueio-jud:

    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS CHAR  /*LISTAS*/                  NO-UNDO.
    DEF INPUT  PARAM par_cdtipmov AS CHAR  /*LISTAS*/                  NO-UNDO.
    DEF INPUT  PARAM par_cdmodali AS CHAR  /*LISTAS*/                  NO-UNDO.
    DEF INPUT  PARAM par_vlbloque AS CHAR  /*LISTAS*/                  NO-UNDO.
    DEF INPUT  PARAM par_vlresblq AS CHAR  /*LISTAS*/                  NO-UNDO.
    DEF INPUT  PARAM par_nroficio AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrproces AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dsjuizem AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dsresord AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_flblcrft AS LOGI                              NO-UNDO.
    DEF INPUT  PARAM par_dtenvres AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_vlrsaldo AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dsinfadc AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-dados-blq.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR          aux_nrdselec AS INT                               NO-UNDO.
    DEF VAR          aux_contador AS INT                               NO-UNDO.
    DEF VAR          aux_nmprimtl AS CHAR                              NO-UNDO.
    DEF VAR          aux_sequenci AS INT                               NO-UNDO.
    DEF VAR          aux_nrdocmto AS INT                               NO-UNDO.
    DEF VAR          aux_flgtrans AS LOG                               NO-UNDO.
    DEF VAR          aux_fldepvis AS LOG                               NO-UNDO.
    DEF VAR          aux_flgbloqu AS LOG                               NO-UNDO.
    DEF VAR          aux_flgdupli AS LOG                               NO-UNDO.

    EMPTY TEMP-TABLE tt-dados-blq. 
    EMPTY TEMP-TABLE tt-erro.      

    ASSIGN aux_nrdselec = NUM-ENTRIES(par_nrdconta,";")
           aux_fldepvis = FALSE
           aux_flgdupli = FALSE.

    IF   INT(ENTRY(1,par_cdtipmov,";")) = 2 THEN
         aux_flgbloqu = FALSE.
    ELSE 
         aux_flgbloqu = TRUE.

    
    DO  aux_contador = 1 TO aux_nrdselec:

        FIND FIRST crapblj WHERE crapblj.cdcooper = par_cdcooper            AND 
                                 crapblj.nrdconta = INT(ENTRY(aux_contador,
                                                    par_nrdconta,";"))      AND
                                 crapblj.nroficio = par_nroficio
                                 NO-LOCK NO-ERROR.
        
        IF   AVAILABLE crapblj THEN
             aux_flgdupli = TRUE.
    END.    
        
    IF   aux_flgdupli THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = 
                          "Ja existe este Nr. Oficio para esta Conta.".
        
             RUN gera_erro (INPUT par_cdcooper,        
                            INPUT 0,
                            INPUT 1, /* nrdcaixa  */
                            INPUT 1, /* sequencia */
                            INPUT aux_cdcritic,        
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
     
    
    DO TRANSACTION:
    
    DO  aux_contador = 1 TO aux_nrdselec:
        
        FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND 
                                 crapass.nrdconta = INT(ENTRY(aux_contador,
                                                    par_nrdconta,";"))
                                 NO-LOCK NO-ERROR.
        
        CREATE crapblj.
        ASSIGN crapblj.cdcooper = par_cdcooper
               crapblj.nrdconta = crapass.nrdconta
               crapblj.nrcpfcgc = crapass.nrcpfcgc
               crapblj.cdmodali = INT(ENTRY(aux_contador,par_cdmodali,";"))
               crapblj.cdtipmov = INT(ENTRY(aux_contador,par_cdtipmov,";"))
               crapblj.flblcrft = par_flblcrft
               crapblj.dtblqini = par_dtmvtolt
               crapblj.dtblqfim = IF   aux_flgbloqu THEN
                                       ?
                                  ELSE par_dtmvtolt
               crapblj.vlbloque = DECI(ENTRY(aux_contador,par_vlbloque,";"))
               crapblj.cdopdblq = par_cdoperad  /* Operador Bloqueio    */
               crapblj.cdopddes = ""            /* Operador Desbloqueio */
               crapblj.dsjuizem = par_dsjuizem
               crapblj.dsresord = par_dsresord
               crapblj.dtenvres = par_dtenvres
               crapblj.nroficio = par_nroficio
               crapblj.nrproces = par_nrproces
               crapblj.dsinfadc = par_dsinfadc.    
               
        IF   INT(ENTRY(aux_contador,par_cdmodali,";")) = 1 THEN
             ASSIGN crapblj.vlresblq = par_vlrsaldo
                    aux_fldepvis     = TRUE.
        ELSE
             ASSIGN crapblj.vlresblq = 0.
             
        VALIDATE crapblj.

        ASSIGN aux_flgtrans = TRUE.

        /*  Cria craplcm */
        IF   INT(ENTRY(aux_contador,par_cdmodali,";")) = 1 AND
             DEC(ENTRY(aux_contador,par_vlbloque,";")) > 0 THEN
             DO:
                 DO WHILE TRUE:

                    FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                       craplot.dtmvtolt = par_dtmvtolt   AND  
                                       craplot.cdagenci = 1              AND
                                       craplot.cdbccxlt = 100            AND
                                       craplot.nrdolote = 6880
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE craplot   THEN
                         IF   LOCKED craplot   THEN
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                         ELSE
                              DO:
                                  CREATE craplot.
                                  ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                         craplot.cdagenci = 1           
                                         craplot.cdbccxlt = 100          
                                         craplot.nrdolote = 6880
                                         craplot.tplotmov = 1
                                         craplot.cdcooper = par_cdcooper.
                              END.
                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */

                 aux_nrdocmto = (craplot.nrseqdig + 1).
                        
                 DO WHILE TRUE:

                    FIND craplcm WHERE craplcm.cdcooper = par_cdcooper     AND
                                       craplcm.dtmvtolt = par_dtmvtolt     AND
                                       craplcm.cdagenci = 1                AND
                                       craplcm.cdbccxlt = 100              AND
                                       craplcm.nrdolote = 6880             AND
                                       craplcm.nrdctabb = crapass.nrdconta AND
                                       craplcm.nrdocmto = aux_nrdocmto
                                       USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                    IF   AVAILABLE craplcm THEN
                         aux_nrdocmto = aux_nrdocmto + 100000.
                    ELSE
                         LEAVE.
          
                 END.  /*  Fim do DO WHILE TRUE  */

                 CREATE craplcm.
                 ASSIGN craplcm.cdcooper = par_cdcooper
                        craplcm.dtmvtolt = par_dtmvtolt
                        craplcm.dtrefere = par_dtmvtolt
                        craplcm.cdagenci = craplot.cdagenci
                        craplcm.cdbccxlt = craplot.cdbccxlt
                        craplcm.nrdolote = craplot.nrdolote
                        craplcm.nrdconta = crapass.nrdconta
                        craplcm.nrdctabb = crapass.nrdconta
                        craplcm.nrdctitg = crapass.nrdctitg
                        craplcm.nrdocmto = aux_nrdocmto
                        craplcm.cdhistor = IF   crapass.inpessoa = 1 THEN 
                                                1402 /* PF */
                                           ELSE 1403 /* PJ */ 
                        craplcm.vllanmto = 
                                  DEC(ENTRY(aux_contador,par_vlbloque,";"))
                        craplcm.nrseqdig = craplot.nrseqdig + 1
                        craplcm.cdpesqbb = "BLOQJUD"
                        craplot.qtcompln = craplot.qtcompln + 1
                        craplot.qtinfoln = craplot.qtinfoln + 1
                        craplot.nrseqdig = craplot.nrseqdig + 1   
                        craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
                        craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
                        
                 VALIDATE craplot.
                 VALIDATE craplcm.

                 DO WHILE TRUE:

                    FIND crapsld WHERE crapsld.cdcooper = par_cdcooper     AND
                                       crapsld.nrdconta = crapass.nrdconta
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                    
                    IF   NOT AVAILABLE crapsld THEN
                         DO:
                             IF   LOCKED crapsld   THEN
                                  DO:
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             ELSE
                                  DO:
                                      ASSIGN aux_cdcritic = 10
                                             aux_dscritic = "".
        
                                      RUN gera_erro (INPUT par_cdcooper,        
                                                     INPUT 0,
                                                     INPUT 1, /* nrdcaixa  */
                                                     INPUT 1, /* sequencia */
                                                     INPUT aux_cdcritic,        
                                                     INPUT-OUTPUT aux_dscritic).
                                      UNDO, RETURN "NOK".
                                  END.
                         END.
                    ELSE
                         ASSIGN crapsld.vlblqjud = crapsld.vlblqjud +
                                                   craplcm.vllanmto.
                    LEAVE.                               
                                                   
                 END.
             END.
        
        /*  Tratamento para o ultimo registro  */
        IF   aux_contador = aux_nrdselec                    AND 
             aux_fldepvis = FALSE                           AND
             par_vlrsaldo > 0                               AND
             par_flblcrft = TRUE                            AND
             aux_flgbloqu = TRUE                            THEN
             DO:
                 CREATE crapblj.
                 ASSIGN crapblj.cdcooper = par_cdcooper
                        crapblj.nrdconta = crapass.nrdconta
                        crapblj.nrcpfcgc = crapass.nrcpfcgc
                        crapblj.cdmodali = 1  /* Dep. a Vista */
                        crapblj.cdtipmov =
                                INT(ENTRY(aux_contador,par_cdtipmov,";"))
                        crapblj.flblcrft = par_flblcrft
                        crapblj.dtblqini = par_dtmvtolt
                        crapblj.dtblqfim = ?
                        crapblj.vlbloque = 0
                        crapblj.cdopdblq = par_cdoperad
                        crapblj.cdopddes = ""
                        crapblj.dsjuizem = par_dsjuizem
                        crapblj.dsresord = par_dsresord
                        crapblj.dtenvres = par_dtenvres
                        crapblj.nroficio = par_nroficio
                        crapblj.nrproces = par_nrproces
                        crapblj.dsinfadc = par_dsinfadc
                        crapblj.vlresblq = par_vlrsaldo.
                 VALIDATE crapblj.
             END.
    END.

    IF  par_flblcrft           AND
        aux_nrdselec > 0       AND
        par_vlrsaldo > 0       AND
        aux_flgbloqu           THEN
        DO: 
            /*** BUSCA CPF/CNPJ DO COOPERADO ***/
            RUN busca-nrcpfcgc-cooperado(INPUT par_cdcooper,
                                         INPUT INT(ENTRY(1,par_nrdconta,";")),
                                        OUTPUT aux_nrcpfcgc,
                                        OUTPUT aux_nmprimtl).

            FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrcpfcgc = aux_nrcpfcgc
                                   NO-LOCK:
                DO WHILE TRUE:

                    FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                       craplot.dtmvtolt = par_dtmvtolt   AND  
                                       craplot.cdagenci = 1              AND
                                       craplot.cdbccxlt = 100            AND
                                       craplot.nrdolote = 6870
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE craplot   THEN
                         IF   LOCKED craplot   THEN
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                         ELSE
                              DO:
                                  CREATE craplot.
                                  ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                         craplot.cdagenci = 1           
                                         craplot.cdbccxlt = 100          
                                         craplot.nrdolote = 6870
                                         craplot.tplotmov = 1
                                         craplot.cdcooper = par_cdcooper.
                              END.
                    LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                aux_nrdocmto = (craplot.nrseqdig + 1).
                        
                DO WHILE TRUE:

                   FIND craplau WHERE craplau.cdcooper = par_cdcooper     AND
                                      craplau.dtmvtolt = par_dtmvtolt     AND
                                      craplau.cdagenci = 1                AND
                                      craplau.cdbccxlt = 100              AND
                                      craplau.nrdolote = 6870             AND
                                      craplau.nrdctabb = crapass.nrdconta AND
                                      craplau.nrdocmto = aux_nrdocmto
                                      USE-INDEX craplau1 NO-LOCK NO-ERROR.

                   IF   AVAILABLE craplau THEN
                        aux_nrdocmto = aux_nrdocmto + 100000.
                   ELSE
                        LEAVE.
          
                END.  /*  Fim do DO WHILE TRUE  */

                CREATE craplau.
                ASSIGN craplau.dtmvtolt = par_dtmvtolt
                       craplau.dtmvtopg = par_dtmvtolt
                       craplau.cdagenci = craplot.cdagenci
                       craplau.cdbccxlt = craplot.cdbccxlt
                       craplau.nrdolote = craplot.nrdolote
                       craplau.nrdconta = crapass.nrdconta
                       craplau.nrdctabb = crapass.nrdconta
                       craplau.nrdctitg = crapass.nrdctitg
                       craplau.nrdocmto = aux_nrdocmto
                       craplau.cdhistor = IF   crapass.inpessoa = 1 THEN 
                                               1402 /* PF */
                                          ELSE 1403 /* PJ */ 
                       craplau.vllanaut = par_vlrsaldo
                       craplau.nrseqdig = craplot.nrseqdig + 1
                       craplau.insitlau = 1
                       craplau.dtdebito = ?
                       craplau.dsorigem = "BLOQJUD"
                       craplau.cdcooper = par_cdcooper
                       craplau.cdseqtel = par_nroficio
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.nrseqdig = craplot.nrseqdig + 1   
                       craplot.vlinfodb = craplot.vlinfodb + par_vlrsaldo
                       craplot.vlcompdb = craplot.vlcompdb + par_vlrsaldo.
                
                VALIDATE craplot.
                VALIDATE craplau.

                ASSIGN aux_flgtrans = TRUE.
            END.
        END.

    IF  NOT aux_flgtrans THEN
        DO: 
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Erro na gravacao da LAUTOM!".
        
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 0,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            UNDO, RETURN "NOK".
        END.

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE consulta-bloqueio-jud-oficio:
	
	DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_contacpf AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nroficio AS CHAR                              NO-UNDO.
	DEF OUTPUT PARAM TABLE FOR tt-dados-blq-oficio.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
	
	DEF VAR aux_contacpf AS CHAR                                       NO-UNDO.
	DEF VAR aux_nmprimtl AS CHAR                                       NO-UNDO.
	
	EMPTY TEMP-TABLE tt-dados-blq-oficio.
    EMPTY TEMP-TABLE tt-erro.
	
	IF  par_nroficio <> "" THEN
		DO:
			FIND FIRST crapblj WHERE crapblj.cdcooper = par_cdcooper AND 
									 crapblj.nroficio = par_nroficio NO-LOCK NO-ERROR.

			IF  NOT AVAILABLE crapblj  THEN
				DO:
						ASSIGN aux_cdcritic = 0
							   aux_dscritic = "Numero Oficio nao encontrado.".

						RUN gera_erro (INPUT par_cdcooper,
									   INPUT 1,
									   INPUT 1,
									   INPUT 1,            /** Sequencia **/
									   INPUT aux_cdcritic,
									   INPUT-OUTPUT aux_dscritic).
						RETURN "NOK".
				END.
			ELSE
				DO:
					FOR EACH crapblj WHERE crapblj.cdcooper = par_cdcooper AND 
									       crapblj.nroficio = par_nroficio
										   NO-LOCK:
						
						FIND FIRST tt-dados-blq-oficio WHERE tt-dados-blq-oficio.nroficio = crapblj.nroficio AND
													         tt-dados-blq-oficio.nrdconta = crapblj.nrdconta
															 NO-LOCK NO-ERROR.
						IF NOT AVAILABLE tt-dados-blq-oficio THEN 
							DO:
								CREATE tt-dados-blq-oficio.
								ASSIGN tt-dados-blq-oficio.nrdconta = crapblj.nrdconta
									   tt-dados-blq-oficio.vlbloque = IF crapblj.dtblqfim = ? THEN crapblj.vlbloque ELSE 0
									   tt-dados-blq-oficio.nroficio = crapblj.nroficio.
							END.
						ELSE
							DO:
								IF crapblj.dtblqfim = ? THEN
									tt-dados-blq-oficio.vlbloque = tt-dados-blq-oficio.vlbloque + crapblj.vlbloque.
							END.
					END.
				END.
		END.
	ELSE
		DO:
			IF par_contacpf <> "" THEN
			DO:
				ASSIGN aux_contacpf = REPLACE(STRING(par_contacpf,"99999999999999"),"-","").

				RUN busca-nrcpfcgc-cooperado(INPUT par_cdcooper,
											 INPUT aux_contacpf,
											 OUTPUT aux_nrcpfcgc,
											 OUTPUT aux_nmprimtl).
											 
				FOR EACH crapblj WHERE crapblj.cdcooper = par_cdcooper AND 
                                       crapblj.nrcpfcgc = aux_nrcpfcgc
									   NO-LOCK:
						
						FIND FIRST tt-dados-blq-oficio WHERE tt-dados-blq-oficio.nroficio = crapblj.nroficio AND
															 tt-dados-blq-oficio.nrdconta = crapblj.nrdconta
															 NO-LOCK NO-ERROR.
						IF NOT AVAILABLE tt-dados-blq-oficio THEN 
						DO:
							CREATE tt-dados-blq-oficio.
							ASSIGN tt-dados-blq-oficio.nrdconta = crapblj.nrdconta
								   tt-dados-blq-oficio.vlbloque = IF crapblj.dtblqfim = ? THEN crapblj.vlbloque ELSE 0
								   tt-dados-blq-oficio.nroficio = crapblj.nroficio.
						END.
						ELSE
							DO:
								IF crapblj.dtblqfim = ? THEN
									tt-dados-blq-oficio.vlbloque = tt-dados-blq-oficio.vlbloque + crapblj.vlbloque.
							END.
				END.
			END.
		END.
		
	RETURN "OK".

END PROCEDURE.


PROCEDURE consulta-bloqueio-jud:

    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_operacao AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cddopcao AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_contacpf AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nroficio AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-dados-blq.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crabass FOR crapass.
    
    DEF VAR aux_vltotblq AS DECI                                       NO-UNDO.
    DEF VAR aux_contacpf AS CHAR                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-dados-blq.
    EMPTY TEMP-TABLE tt-erro.          

    DEF VAR aux_nmprimtl AS CHAR                                       NO-UNDO.
    
    DEF QUERY q_crapblj FOR crapblj.
    DEF VAR aux_query AS CHAR                                          NO-UNDO. 


    ASSIGN aux_contacpf = REPLACE(STRING(par_contacpf,"99999999999999"),"-","").

    RUN busca-nrcpfcgc-cooperado(INPUT par_cdcooper,
                                 INPUT aux_contacpf,
                                OUTPUT aux_nrcpfcgc,
                                OUTPUT aux_nmprimtl).

    
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            ASSIGN aux_cdcritic = 009
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    IF  par_nroficio <> "" THEN
        DO:
           FIND FIRST crapblj WHERE crapblj.cdcooper = par_cdcooper AND 
                                    crapblj.nrcpfcgc = aux_nrcpfcgc AND   
                                    crapblj.nroficio = par_nroficio
                                    NO-LOCK NO-ERROR.
           
           IF  NOT AVAILABLE crapblj  THEN
           DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Numero Oficio nao encontrado.".
    
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT 1,
                              INPUT 1,
                              INPUT 1,            /** Sequencia **/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
               RETURN "NOK".
           END.               
        END.

    /* Operacao Desbloqueio */
    /* P341-Automatizaçao BACENJUD - Renato Darosci
    IF  par_operacao = "D" THEN
        DO:   
            FIND FIRST crapblj WHERE crapblj.cdcooper = par_cdcooper AND
                                     crapblj.nroficio = par_nroficio AND
                                     crapblj.nrcpfcgc = aux_nrcpfcgc AND
                                     crapblj.cdtipmov <> 2           AND
                                     crapblj.dtblqfim <> ?          
                                     NO-LOCK NO-ERROR.
    
            IF  AVAILABLE crapblj THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Cooperado ja esta desbloqueado.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 1,
                                   INPUT 1,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).     
                    
                    RETURN "NOK".
                END.
        END.*/
    
    ASSIGN aux_query = "FOR EACH crapblj NO-LOCK WHERE " +
                       "crapblj.cdcooper = " + STRING(par_cdcooper) + " AND " +
                       "crapblj.nrcpfcgc = " + STRING(aux_nrcpfcgc).

    IF  par_nroficio <> "" THEN
        aux_query = aux_query + " AND crapblj.nroficio = '" + STRING(par_nroficio) + "'".
    
    IF  par_cddopcao = "C" THEN /* Bloqueio do Capital */
        aux_query = aux_query + " AND crapblj.cdtipmov = 3".
    ELSE IF par_cddopcao = "B" THEN /* Bloqueio Judicial */
        aux_query = aux_query + " AND crapblj.cdtipmov = 1".
    ELSE /* transferencia judicial */
        aux_query = aux_query + " AND crapblj.cdtipmov = 2".
    
    IF  par_operacao = "D" THEN
        aux_query = aux_query + " AND crapblj.dtblqfim = ?".

    aux_query = aux_query + " BY crapblj.nrdconta:".
    
    QUERY q_crapblj:QUERY-CLOSE().
    QUERY q_crapblj:QUERY-PREPARE(aux_query).
    QUERY q_crapblj:QUERY-OPEN().
    
    GET FIRST q_crapblj.
    DO WHILE AVAILABLE(crapblj):
       IF crapblj.dtblqfim = ? THEN
          aux_vltotblq = aux_vltotblq + (crapblj.vlbloque + crapblj.vlresblq).
       GET NEXT q_crapblj.
    END.

    /* Leitura p/ criar tt-dados-blq que ira ser usado no AyllosWEB */
    GET FIRST q_crapblj.
    DO WHILE AVAILABLE(crapblj):
       
       CREATE tt-dados-blq.
       BUFFER-COPY crapblj TO tt-dados-blq.
       
        ASSIGN tt-dados-blq.vltotblq = aux_vltotblq
			   tt-dados-blq.nmrofici = crapblj.nroficio.

       FIND FIRST crabass WHERE crabass.cdcooper = crapblj.cdcooper AND
                                crabass.nrdconta = crapblj.nrdconta
                                NO-LOCK NO-ERROR NO-WAIT.
       IF  AVAIL crabass THEN
       DO:
           ASSIGN tt-dados-blq.dscpfcgc = IF crabass.inpessoa = 1 THEN 
                                          STRING(STRING(crapblj.nrcpfcgc,
                                          "99999999999"),"xxx.xxx.xxx-xx")
                                          ELSE
                                          STRING(STRING(crapblj.nrcpfcgc,
                                          "99999999999999"),"xx.xxx.xxx/xxxx-xx").
       END.

       /*** Modalidade do bloqueio ***/
       CASE crapblj.cdmodali:
            WHEN 1 THEN 
               ASSIGN tt-dados-blq.dsmodali = 
                      "Conta Corrente".
            WHEN 2 THEN
               ASSIGN tt-dados-blq.dsmodali = 
                      "Aplicacao".
            WHEN 3 THEN
               ASSIGN tt-dados-blq.dsmodali = 
                      "Poup. Programada".
            WHEN 4 THEN
               ASSIGN tt-dados-blq.dsmodali = 
                     "Capital".
       END CASE.

	   ASSIGN tt-dados-blq.idmodali = crapblj.cdmodali
			  tt-dados-blq.dsblqini = IF crapblj.hrblqini = 0 THEN "" ELSE STRING(crapblj.hrblqini,"HH:MM")
			  tt-dados-blq.dsblqfim = IF crapblj.hrblqfim = 0 THEN "" ELSE STRING(crapblj.hrblqfim,"HH:MM").

       GET NEXT q_crapblj.
    END. 
    QUERY q_crapblj:QUERY-CLOSE().
    
    IF  NOT TEMP-TABLE tt-dados-blq:HAS-RECORDS  THEN DO:
        
        IF  par_cddopcao = "C" THEN 
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registros de bloqueio capital nao encontrado!".
        ELSE
        IF  par_cddopcao = "B" THEN
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registros de bloqueio judicial nao encontrado!".
        ELSE
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registros de transferencia judicial nao encontrado!".
    
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 1,
                       INPUT 1,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE altera-bloqueio-jud:

    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdmodali AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nroficio AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrproces AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dsjuizem AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dsresord AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_flblcrft AS LOGI                              NO-UNDO.
    DEF INPUT  PARAM par_dtenvres AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_nroficon AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrctacon AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dsinfadc AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrofides AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dtenvdes AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_dsinfdes AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_fldestrf AS LOG                               NO-UNDO.
    

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrcpfcgc AS DECI                                       NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                       NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    RUN busca-nrcpfcgc-cooperado(INPUT par_cdcooper,
                                 INPUT par_nrctacon,
                                OUTPUT aux_nrcpfcgc,
                                OUTPUT aux_nmprimtl).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            ASSIGN aux_cdcritic = 009
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.


    DO TRANSACTION:
    
        FOR EACH crapblj WHERE crapblj.cdcooper = par_cdcooper AND 
                               crapblj.nroficio = par_nroficon AND  
                               crapblj.nrcpfcgc = aux_nrcpfcgc
                               EXCLUSIVE-LOCK:
    
            ASSIGN crapblj.nroficio = par_nroficio
                   crapblj.nrproces = par_nrproces
                   crapblj.dsjuizem = par_dsjuizem
                   crapblj.dsresord = par_dsresord
                   crapblj.flblcrft = par_flblcrft
                   crapblj.dtenvres = par_dtenvres
                   crapblj.dsinfadc = par_dsinfadc
                   crapblj.nrofides = par_nrofides
                   crapblj.dtenvdes = par_dtenvdes
                   crapblj.dsinfdes = par_dsinfdes
                   crapblj.fldestrf = par_fldestrf.
        END.
    END.

    RETURN "OK".

END PROCEDURE.



PROCEDURE efetua-desbloqueio-jud:

    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdtipmov AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdmodali AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_vlbloque AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_vlresblq AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nroficio AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrproces AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dsjuizem AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dsresord AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_flblcrft AS LOG                               NO-UNDO.
    DEF INPUT  PARAM par_dtenvres AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_nroficon AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrctacon AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dsinfadc AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrofides AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dtenvdes AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_dsinfdes AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_fldestrf AS LOG                               NO-UNDO.


    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrcpfcgc AS DECI                                       NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrdocmto AS INT                                        NO-UNDO.

    
    EMPTY TEMP-TABLE tt-erro.

    RUN busca-nrcpfcgc-cooperado(INPUT par_cdcooper,
                                 INPUT par_nrctacon,
                                OUTPUT aux_nrcpfcgc,
                                OUTPUT aux_nmprimtl).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            ASSIGN aux_cdcritic = 009
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    DO TRANSACTION:

    FOR EACH crapblj WHERE crapblj.cdcooper = par_cdcooper  AND 
                           crapblj.nroficio = par_nroficio  AND  
                           crapblj.nrcpfcgc = aux_nrcpfcgc
                           EXCLUSIVE-LOCK BREAK BY crapblj.cdmodali:

        FIND crapass WHERE crapass.cdcooper = crapblj.cdcooper AND
                           crapass.nrdconta = crapblj.nrdconta
                           NO-LOCK NO-ERROR.
        
        ASSIGN crapblj.cdopddes = par_cdoperad  /* operador desbloqueio    */
               crapblj.dtblqfim = par_dtmvtolt  /* data desbloqueio        */
               crapblj.nrofides = par_nrofides  /* nro oficio desbloqueio  */
               crapblj.dtenvdes = par_dtenvdes  /*dt envio resp desbloqueio*/
               crapblj.dsinfdes = par_dsinfdes  /*inf adicional desbloqueio*/
               crapblj.fldestrf = par_fldestrf. /*desbloqueio para transf. */



        /*  Cria craplcm */
        IF   crapblj.cdmodali = 1 AND
             crapblj.vlbloque > 0 THEN
             DO:
                 DO WHILE TRUE:

                    FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                       craplot.dtmvtolt = par_dtmvtolt   AND  
                                       craplot.cdagenci = 1              AND
                                       craplot.cdbccxlt = 100            AND
                                       craplot.nrdolote = 6880
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE craplot   THEN
                         IF   LOCKED craplot   THEN
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                         ELSE
                              DO:
                                  CREATE craplot.
                                  ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                         craplot.cdagenci = 1           
                                         craplot.cdbccxlt = 100          
                                         craplot.nrdolote = 6880
                                         craplot.tplotmov = 1
                                         craplot.cdcooper = par_cdcooper.
                              END.
                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */

                 aux_nrdocmto = (craplot.nrseqdig + 1).
                        
                 DO WHILE TRUE:

                    FIND craplcm WHERE craplcm.cdcooper = par_cdcooper     AND
                                       craplcm.dtmvtolt = par_dtmvtolt     AND
                                       craplcm.cdagenci = 1                AND
                                       craplcm.cdbccxlt = 100              AND
                                       craplcm.nrdolote = 6880             AND
                                       craplcm.nrdctabb = crapass.nrdconta AND
                                       craplcm.nrdocmto = aux_nrdocmto
                                       USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                    IF   AVAILABLE craplcm THEN
                         aux_nrdocmto = aux_nrdocmto + 100000.
                    ELSE
                         LEAVE.
          
                 END.  /*  Fim do DO WHILE TRUE  */


                 CREATE craplcm.
                 ASSIGN craplcm.cdcooper = par_cdcooper
                        craplcm.dtmvtolt = par_dtmvtolt
                        craplcm.dtrefere = par_dtmvtolt
                        craplcm.cdagenci = craplot.cdagenci
                        craplcm.cdbccxlt = craplot.cdbccxlt
                        craplcm.nrdolote = craplot.nrdolote
                        craplcm.nrdconta = crapass.nrdconta
                        craplcm.nrdctabb = crapass.nrdconta
                        craplcm.nrdctitg = crapass.nrdctitg
                        craplcm.nrdocmto = aux_nrdocmto
                        craplcm.cdhistor = IF   crapass.inpessoa = 1 THEN 
                                                1404 /* PF */
                                           ELSE 1405 /* PJ */ 
                        craplcm.vllanmto = crapblj.vlbloque
                        craplcm.nrseqdig = craplot.nrseqdig + 1
                        craplcm.cdpesqbb = "BLOQJUD"
                        craplot.qtcompln = craplot.qtcompln + 1
                        craplot.qtinfoln = craplot.qtinfoln + 1
                        craplot.nrseqdig = craplot.nrseqdig + 1   
                        craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
                        craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
                        
                 VALIDATE craplot.
                 VALIDATE craplcm.

                 DO WHILE TRUE:

                    FIND crapsld WHERE crapsld.cdcooper = par_cdcooper     AND
                                       crapsld.nrdconta = crapass.nrdconta
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                    
                    IF   NOT AVAILABLE crapsld THEN
                         DO:
                             IF   LOCKED crapsld   THEN
                                  DO:
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             ELSE
                                  DO:
                                      ASSIGN aux_cdcritic = 10
                                             aux_dscritic = "".
        
                                      RUN gera_erro (INPUT par_cdcooper,        
                                                     INPUT 0,
                                                     INPUT 1, /* nrdcaixa  */
                                                     INPUT 1, /* sequencia */
                                                     INPUT aux_cdcritic,        
                                                     INPUT-OUTPUT aux_dscritic).
                                      UNDO, RETURN "NOK".
                                  END.
                         END.
                    ELSE
                         ASSIGN crapsld.vlblqjud = crapsld.vlblqjud -
                                                   craplcm.vllanmto.
                    LEAVE.                               
                                                   
                 END.
             END.

        /*  Verifica os Lancamentos Futuros  */
        IF   LAST-OF(crapblj.cdmodali) THEN     
             DO:
                 IF   crapblj.flblcrft THEN
                      DO:
                          FOR EACH craplau WHERE 
                                   craplau.cdcooper = par_cdcooper     AND
                                   craplau.dtmvtolt = crapblj.dtblqini AND
                                   craplau.cdagenci = 1                AND
                                   craplau.cdbccxlt = 100              AND
                                   craplau.nrdolote = 6870             
                                   EXCLUSIVE-LOCK:

                              IF   craplau.dsorigem = "BLOQJUD"         AND
                                   craplau.cdseqtel = crapblj.nroficio  THEN
                                   ASSIGN craplau.insitlau = 3
                                          craplau.dtdebito = par_dtmvtolt.
                          END.
                      END.
             END.
    END.
    END.
     
    RETURN "OK".

END PROCEDURE.

PROCEDURE retorna-sld-conta-invt:
	DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
	DEF OUTPUT PARAM ret_vlresblq AS DECI                              NO-UNDO.
	
	DEF VAR aux_dtcalcul AS DATE   NO-UNDO.

	/* Calcular o ultimo dia do mes */
	ASSIGN aux_dtcalcul = ((DATE(MONTH(par_dtmvtolt),28,YEAR(par_dtmvtolt)) + 4) -
							DAY(DATE(MONTH(par_dtmvtolt),28,YEAR(par_dtmvtolt)) + 4)).

	ASSIGN ret_vlresblq = 0.

	FIND FIRST crapsli WHERE crapsli.cdcooper = par_cdcooper AND 
							 crapsli.nrdconta = par_nrdconta AND 
							 crapsli.dtrefere = aux_dtcalcul
							 NO-LOCK NO-ERROR.
                                      
	IF AVAILABLE crapsli THEN
		DO:
			ASSIGN ret_vlresblq = crapsli.vlsddisp.
		END.
	
END PROCEDURE.

PROCEDURE retorna-valor-blqjud:

    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_cdtipmov AS INT                               NO-UNDO.
            /* 0-Todos / 1-Bloq Normal  /  2-Transf. /  3-Blq Capital */
    DEF INPUT  PARAM par_cdmodali AS INT                               NO-UNDO.
            /* 0-Todos / 1-DEP VISTA / 2-APLICACAO / 3-POUP PRG. / 4-CAPITAL */
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.

    DEF OUTPUT PARAM ret_vlbloque AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM ret_vlresblq AS DECI                              NO-UNDO.

    ASSIGN ret_vlbloque = 0
           ret_vlresblq = 0.
    
    
    IF   par_cdtipmov = 0 AND
         par_cdmodali = 0 THEN 
         DO:
             /* Exibe a mensagem se possui Bloqueios Judiciais na ATENDA */
             FIND FIRST crapblj WHERE crapblj.cdcooper =  par_cdcooper AND
                                      crapblj.nrdconta =  par_nrdconta AND
                                      crapblj.dtblqini <= par_dtmvtolt AND
                                      crapblj.dtblqfim =  ?
                                      NO-LOCK NO-ERROR.
                                      
             IF   AVAILABLE crapblj THEN
                  DO:
                      IF   crapblj.vlbloque > 0 THEN
                           ASSIGN ret_vlbloque = crapblj.vlbloque
                                  ret_vlresblq = crapblj.vlresblq.
                      ELSE 
                           ASSIGN ret_vlbloque = crapblj.vlresblq
                                  ret_vlresblq = crapblj.vlresblq.
                  END.
         END.
    ELSE
    IF   par_cdtipmov = 0 THEN 
         DO:
            /* Busca independente do tipo de movimento */
            FOR EACH crapblj WHERE crapblj.cdcooper  = par_cdcooper AND
                                   crapblj.nrdconta  = par_nrdconta AND
                                   crapblj.cdmodali  = par_cdmodali AND
                                   crapblj.dtblqini <= par_dtmvtolt AND
                                   crapblj.dtblqfim  = ? /* SE ? ESTA ATIVO */
                                   NO-LOCK:
                
                ASSIGN ret_vlbloque = ret_vlbloque + crapblj.vlbloque
                       ret_vlresblq = ret_vlresblq + crapblj.vlresblq.
            END.                         
         END.
    ELSE 
         DO:
            FOR EACH crapblj WHERE crapblj.cdcooper  = par_cdcooper AND
                                   crapblj.nrdconta  = par_nrdconta AND
                                   crapblj.cdtipmov  = par_cdtipmov AND
                                   crapblj.cdmodali  = par_cdmodali AND
                                   crapblj.dtblqini <= par_dtmvtolt AND
                                   crapblj.dtblqfim  = ? /* SE ? ESTA ATIVO */
                                   NO-LOCK:
                                   
                ASSIGN ret_vlbloque = ret_vlbloque + crapblj.vlbloque
                       ret_vlresblq = ret_vlresblq + crapblj.vlresblq.
            END.                       
         END.

    RETURN "OK".
    
END PROCEDURE. 


/***  Impressao da operacao C ***/
PROCEDURE imprime_bloqueio_jud:

    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_nroficio AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrctacpf AS CHAR                              NO-UNDO.
    
    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
    DEF VAR aux_vldobloq AS DEC                                        NO-UNDO.
    DEF VAR aux_vlabloqu AS DEC                                        NO-UNDO.
    DEF VAR aux_vltotblq AS DEC                                        NO-UNDO.
    DEF VAR aux_dsdsitua AS CHAR FORMAT "x(15)"                        NO-UNDO.
    

    EMPTY TEMP-TABLE tt-erro.

    FORM SKIP(3)
         "-------------------- DADOS DO OFICIO --------------------" AT 15
         SKIP(1)
         tt-dados-blq.nroficio LABEL "Numero do Oficio"              AT 01
         SKIP(1)
         tt-dados-blq.nrproces LABEL "Numero Processo"               AT 02
         SKIP(1)
         tt-dados-blq.dtenvres LABEL "Data Envio Resp."              AT 01
         SKIP(1)
         tt-dados-blq.dsjuizem LABEL "Juiz Emissor" FORMAT "x(61)"   AT 05
         SKIP(1)
         tt-dados-blq.dsresord LABEL "Resumo da Origem" FORMAT "x(61)" AT 01
         SKIP(1)
         tt-dados-blq.dsinfadc LABEL "Inf. Adicional" FORMAT "x(61)" AT 03
         SKIP(1)
         tt-dados-blq.nrofides LABEL "Numero do oficio Desbloqueado" AT 01
         SKIP(1)
         tt-dados-blq.dtenvdes LABEL "Data Envio Resp. Desbloqueado" AT 01
         SKIP(1)
         tt-dados-blq.dsinfdes LABEL "Inf. Adicional Desbloqueado"   AT 03
         SKIP(1)
         tt-dados-blq.fldestrf LABEL "Desbloq. para Transferencia"   AT 03
         SKIP(3)
         "-------------------- SITUACAO DO OFICIO --------------------" AT 12
         SKIP(1)
         aux_dsdsitua          LABEL "Situacao"                      AT 12
         SKIP(1)
         tt-dados-blq.dtblqini LABEL "Data de Bloqueio"              AT 04
         tt-dados-blq.cdopdblq LABEL "Cod. Operador Bloqueio" FORMAT "x(18)"
                                                                     AT 39
         SKIP(1)
         tt-dados-blq.dtblqfim LABEL "Data de Desbloqueio"           AT 01
         tt-dados-blq.cdopddes LABEL "Cod. Operador Desbloqueio" FORMAT "x(18)"
                                                                     AT 36
         SKIP(3)
         "-------------------- VALORES --------------------"         AT 17
         SKIP(1)
         aux_vltotblq          LABEL "Valor Total do Bloqueio"       AT 15
         SKIP(1)         
         aux_vldobloq          LABEL "Valor Bloqueado"               AT 23
         SKIP(1)
         aux_vlabloqu          LABEL "Valor a Bloquear"              AT 22 
         SKIP(1)
         tt-dados-blq.flblcrft LABEL "Bloqueia Creditos Futuros"     AT 13
         SKIP(3)
         "-------------------- CONTAS E SALDOS BLOQUEADOS --------------------"
                                                                     AT 08
         SKIP(2)
         WITH NO-BOX NO-ATTR-SPACE COLUMN 1 NO-LABELS SIDE-LABELS WIDTH 132 DOWN
              FRAME f_bloqueio_1.

    FORM tt-dados-blq.nrdconta AT 03 LABEL "Conta/dv"
         tt-dados-blq.dscpfcgc AT 15 LABEL "CPF/CNPJ"    FORMAT "x(20)"
         tt-dados-blq.dsmodali AT 37 LABEL "Modalidade"  FORMAT "x(20)"
         tt-dados-blq.vlbloque AT 59 LABEL "Valor"
         WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_bloqueio_2.



    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                          crapcop.dsdircop + "_" + par_nrctacpf.
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2>/dev/null").
    
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    PUT STREAM str_1 crapcop.nmrescop           AT   1 FORMAT "x(11)"
                     "-"                        AT  13
                      "BLQ. JUDICIAL"           AT  15 FORMAT "x(16)"
                     "REF."                     AT  32
                     par_dtmvtolt               AT  36 FORMAT "99/99/9999"
                     "-"                        AT  55
                     TODAY                      AT  57  FORMAT "99/99/9999"
                     STRING(TIME,"HH:MM")       AT  68 FORMAT "x(5)"
                     "PG"                       AT 74
                     PAGE-NUMBER(str_1)         AT 76 FORMAT "zzzz9"
                     SKIP(1).

    RUN consulta-bloqueio-jud (INPUT par_cdcooper,
                               INPUT "C",
                               INPUT par_nrctacpf, /*nroconta/nrcpfcgc*/
                               INPUT par_nroficio,
                               OUTPUT TABLE tt-dados-blq,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    ASSIGN aux_vldobloq = 0
           aux_vlabloqu = 0.

    /*** faz a soma dos valores bloqueados ***/
    FOR EACH tt-dados-blq NO-LOCK:

        ASSIGN aux_vldobloq = aux_vldobloq + tt-dados-blq.vlbloque
               aux_vlabloqu = aux_vlabloqu + tt-dados-blq.vlresblq.
    END.

    FIND FIRST tt-dados-blq NO-LOCK NO-ERROR NO-WAIT.

    IF   AVAILABLE tt-dados-blq THEN
         DO:
             IF  tt-dados-blq.dtblqini <> ? THEN
                 ASSIGN aux_dsdsitua = "Bloqueado".
                
             IF  tt-dados-blq.dtblqfim <> ? THEN
                 ASSIGN aux_dsdsitua = "Desbloqueado".
                    
             IF  tt-dados-blq.cdtipmov = 2 THEN
                 ASSIGN aux_dsdsitua = "Transferencia".

             ASSIGN aux_vltotblq = tt-dados-blq.vltotblq.

             DISPLAY STREAM str_1 tt-dados-blq.nroficio 
                                  tt-dados-blq.nrproces
                                  tt-dados-blq.dtenvres
                                  tt-dados-blq.dsjuizem
                                  tt-dados-blq.dsresord    
                                  tt-dados-blq.dsinfadc
                                  tt-dados-blq.nrofides                  
                                  tt-dados-blq.dtenvdes
                                  tt-dados-blq.dsinfdes
                                  tt-dados-blq.fldestrf
                                  aux_dsdsitua             
                                  tt-dados-blq.dtblqini
                                  tt-dados-blq.cdopdblq    
                                  tt-dados-blq.dtblqfim
                                  tt-dados-blq.cdopddes    
                                  aux_vltotblq
                                  aux_vldobloq         
                                  aux_vlabloqu             
                                  tt-dados-blq.flblcrft
                                  WITH FRAME f_bloqueio_1.
         END.
        
    FOR EACH tt-dados-blq NO-LOCK BREAK BY tt-dados-blq.nrdconta
                                        BY tt-dados-blq.nrcpfcgc:

        DISP STREAM str_1 tt-dados-blq.nrdconta    
                          tt-dados-blq.dscpfcgc 
                          tt-dados-blq.dsmodali 
                          tt-dados-blq.vlbloque 
                          WITH FRAME f_bloqueio_2.

        DOWN STREAM str_1 WITH FRAME f_bloqueio_2.
    END.

    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.
    
    RUN envia-arquivo-web IN h-b1wgen0024 (INPUT par_cdcooper,
                                           INPUT 1, /* cdagenci */
                                           INPUT 0, /* nrdcaixa */
                                           INPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).     
        
    DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

   RETURN "OK".

END PROCEDURE.


/** Impressao da OPCAO R **/
PROCEDURE Gera_Impressao:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_dtiniper AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_dtfimper AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_agenctel AS INTE                               NO-UNDO.

    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsmodali AS CHAR                                       NO-UNDO.
    DEF VAR aux_vldobloq AS DEC                                        NO-UNDO.
    DEF VAR aux_vlabloqu AS DEC                                        NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsagenci AS CHAR                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM tt-imprime-bloqueio.cdagenci AT  1 LABEL "PA" FORMAT "zz9"
         tt-imprime-bloqueio.nrdconta AT  5 LABEL "Conta/dv" FORMAT "zzzz,zzz,9"
         tt-imprime-bloqueio.nroficio AT 16 LABEL "Nr Oficio" FORMAT "x(25)"
         tt-imprime-bloqueio.dtblqini AT 42 LABEL "Dt. Inicio" 
                                      FORMAT "99/99/9999"
         tt-imprime-bloqueio.dtblqfim AT 53 LABEL "Dt Fim"     
                                      FORMAT "99/99/9999"
         tt-imprime-bloqueio.dsmodali AT 64 LABEL "Modalidade" FORMAT "x(16)"
         tt-imprime-bloqueio.vlbloque AT 81 LABEL "Valor Bloqueado"  
                                      FORMAT "zzz,zzz,zzz,zz9.99"
         tt-imprime-bloqueio.vlabloqu AT 100 LABEL "Valor a Bloquear"
                                      FORMAT "zzz,zzz,zzz,zz9.99"
         tt-imprime-bloqueio.dsdsitua AT 119 LABEL "Situacao" FORMAT "x(13)"
         WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_bloqueio_1.

    FORM tt-imprime-bloqueio-transf.cdagenci AT  1 LABEL "PA" FORMAT "zz9"
         tt-imprime-bloqueio-transf.nrdconta AT  5 LABEL "Conta/dv" 
                                             FORMAT "zzzz,zzz,9"
         tt-imprime-bloqueio-transf.nmprimtl AT 16 LABEL "Nome" FORMAT "x(40)"
         tt-imprime-bloqueio-transf.nroficio AT 57 LABEL "Nr Oficio" 
                                             FORMAT "x(25)"
         tt-imprime-bloqueio-transf.dtblqini AT 83 LABEL "Data"      
                                             FORMAT "99/99/9999"
         tt-imprime-bloqueio-transf.vlbloque AT 94 LABEL "Valor Transferido" 
                                             FORMAT "zzz,zzz,zzz,zz9.99"
         WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_bloqueio_2.

    FORM tt-imprime-total.dsmodali           AT 20  FORMAT "x(20)"
         tt-imprime-total.qtdbloqu           AT 48  FORMAT "zzz,zz9"
         tt-imprime-total.vldbloqu           AT 63  FORMAT "zzz,zzz,zz9.99"
         tt-imprime-total.qtddesbl           AT 86  FORMAT "zzz,zz9"
         tt-imprime-total.vlddesbl           AT 101 FORMAT "zzz,zzz,zz9.99"
         WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_bloqueio_total_bloq.
         
    FORM tt-imprime-total.dsmodali           AT 37  FORMAT "x(20)"
         tt-imprime-total.qtdbloqu           AT 65  FORMAT "zzz,zz9"
         tt-imprime-total.vldbloqu           AT 80  FORMAT "zzz,zzz,zz9.99"
         WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_bloqueio_total_transf.
     

    
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper 
                             NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                      crapcop.dsdircop + "_" + STRING(par_agenctel).
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
    
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    PUT STREAM str_1 crapcop.nmrescop           AT  1  FORMAT "x(15)"
                     "-"                        AT 16
                     "BLOQUEIO JUDICIAL"        AT 18  FORMAT "x(20)"
                     "REF."                     AT 55
                     par_dtmvtolt               AT 60  FORMAT "99/99/9999"
                     "BLQJUD/BLQJUD"            AT 74  FORMAT "x(13)"
                     "-"                        AT 89
                     TODAY                      AT 92  FORMAT "99/99/9999"
                     STRING(TIME,"HH:MM")       AT 104 FORMAT "x(5)"
                     "PAG"                      AT 123 
                     PAGE-NUMBER(str_1)         AT 127 FORMAT "zz9"
                     SKIP(2).
    
    IF   par_agenctel = 0 THEN
         aux_dsagenci = "PA:  TODOS".
    ELSE
         aux_dsagenci = "PA:  " + STRING(par_agenctel,"zz9").
    
    PUT STREAM str_1 "PERIODO DE REFERENCIA:"   AT 01  FORMAT "x(22)"
                     par_dtiniper               AT 25  FORMAT "99/99/9999"
                     "A"                        AT 36
                     par_dtfimper               AT 38  FORMAT "99/99/9999"
                     "-"                        AT 53
                     aux_dsagenci               AT 60  FORMAT "x(11)"
                     SKIP(3).
                     
    /* Armazena os totais */
    CREATE tt-imprime-total.
    ASSIGN tt-imprime-total.cdtipmov = 1
           tt-imprime-total.dsmodali = "Aplicacao".
    CREATE tt-imprime-total.
    ASSIGN tt-imprime-total.cdtipmov = 1
           tt-imprime-total.dsmodali = "Conta Corrente".
    CREATE tt-imprime-total.
    ASSIGN tt-imprime-total.cdtipmov = 1
           tt-imprime-total.dsmodali = "Poup. Programada".
    CREATE tt-imprime-total.
    ASSIGN tt-imprime-total.cdtipmov = 2
           tt-imprime-total.dsmodali = "Transferencia".
    CREATE tt-imprime-total.
    ASSIGN tt-imprime-total.cdtipmov = 3
           tt-imprime-total.dsmodali = "Capital".
       
    
    
    FOR EACH crapblj WHERE crapblj.cdcooper =  par_cdcooper AND
                           crapblj.dtblqini >= par_dtiniper AND
                           crapblj.dtblqini <= par_dtfimper
                           NO-LOCK:
            
        FIND crapass WHERE crapass.cdcooper = crapblj.cdcooper AND
                           crapass.nrdconta = crapblj.nrdconta
                           NO-LOCK NO-ERROR.
        
        IF   par_agenctel <> 0 THEN
             IF   crapass.cdagenci <> par_agenctel THEN
                  NEXT.
        
        /*** Modalidade do bloqueio ***/
        CASE crapblj.cdmodali:
             WHEN 1 THEN ASSIGN aux_dsmodali = "Conta Corrente".
             WHEN 2 THEN ASSIGN aux_dsmodali = "Aplicacao".
             WHEN 3 THEN ASSIGN aux_dsmodali = "Poup. Programada".
             WHEN 4 THEN ASSIGN aux_dsmodali = "Capital".
        END CASE.
           
        /*** TRANSFERENCIA ***/
        IF  crapblj.cdtipmov = 2 THEN
            DO:
                CREATE tt-imprime-bloqueio-transf.
                ASSIGN tt-imprime-bloqueio-transf.cdagenci = crapass.cdagenci
                       tt-imprime-bloqueio-transf.nrdconta = crapblj.nrdconta
                       tt-imprime-bloqueio-transf.nmprimtl = crapass.nmprimtl
                       tt-imprime-bloqueio-transf.nroficio = crapblj.nroficio
                       tt-imprime-bloqueio-transf.dtblqini = crapblj.dtblqini
                       tt-imprime-bloqueio-transf.vlbloque = crapblj.vlbloque.
            END.
        ELSE
            DO:
                CREATE tt-imprime-bloqueio.
                ASSIGN tt-imprime-bloqueio.cdagenci = crapass.cdagenci
                       tt-imprime-bloqueio.nrdconta = crapblj.nrdconta
                       tt-imprime-bloqueio.nroficio = crapblj.nroficio
                       tt-imprime-bloqueio.dtblqini = crapblj.dtblqini
                       tt-imprime-bloqueio.dtblqfim = crapblj.dtblqfim
                       tt-imprime-bloqueio.dsmodali = aux_dsmodali
                       tt-imprime-bloqueio.vlbloque = crapblj.vlbloque
                       tt-imprime-bloqueio.vlabloqu = crapblj.vlresblq
                       tt-imprime-bloqueio.dsdsitua = 
                                       IF   crapblj.dtblqfim <> ? THEN
                                            "Desbloqueado"
                                       ELSE
                                            "Bloqueado".
            END.
            
        FIND tt-imprime-total WHERE 
             tt-imprime-total.cdtipmov = crapblj.cdtipmov AND
             tt-imprime-total.dsmodali = aux_dsmodali
             NO-ERROR.
                                      
        IF   AVAIL tt-imprime-total THEN
             DO:
                 IF   crapblj.dtblqfim <> ? THEN
                      ASSIGN tt-imprime-total.qtddesbl = 
                                tt-imprime-total.qtddesbl + 1
                             tt-imprime-total.vlddesbl = 
                                tt-imprime-total.vlddesbl + crapblj.vlbloque.
                 ELSE 
                      ASSIGN tt-imprime-total.qtdbloqu = 
                                tt-imprime-total.qtdbloqu + 1
                             tt-imprime-total.vldbloqu = 
                                tt-imprime-total.vldbloqu + crapblj.vlbloque.
             END.
    END.
    
    PUT STREAM str_1 SKIP(2) "BLOQUEADOS/DESBLOQUEADOS:" SKIP(2).
           
    FOR EACH tt-imprime-bloqueio NO-LOCK BY tt-imprime-bloqueio.nrdconta:
           
        DISPLAY STREAM str_1 tt-imprime-bloqueio.cdagenci 
                             tt-imprime-bloqueio.nrdconta 
                             tt-imprime-bloqueio.nroficio 
                             tt-imprime-bloqueio.dtblqini 
                             tt-imprime-bloqueio.dtblqfim 
                             tt-imprime-bloqueio.dsmodali 
                             tt-imprime-bloqueio.vlbloque 
                             tt-imprime-bloqueio.vlabloqu 
                             tt-imprime-bloqueio.dsdsitua
                             WITH FRAME f_bloqueio_1.
           
        DOWN STREAM str_1 WITH FRAME f_bloqueio_1.
           
    END.
           

    PUT STREAM str_1 SKIP(1)
                     "MODALIDADE"                        AT 20
                     "BLOQUEADOS"                        AT 55
                     "DESBLOQUEADOS"                     AT 91
                     "--------------------"              AT 20
                     "---------------------------------" AT 44
                     "---------------------------------" AT 82
                     SKIP.

    FOR EACH tt-imprime-total WHERE tt-imprime-total.cdtipmov <> 2
                                    NO-LOCK:

        DISPLAY STREAM str_1 tt-imprime-total.dsmodali
                             tt-imprime-total.qtdbloqu
                             tt-imprime-total.vldbloqu
                             tt-imprime-total.qtddesbl
                             tt-imprime-total.vlddesbl
                             WITH FRAME f_bloqueio_total_bloq.
    
        DOWN STREAM str_1 WITH FRAME f_bloqueio_total_bloq.
    END.
    
    
    FIND FIRST tt-imprime-bloqueio-transf NO-LOCK NO-ERROR.
           
    PUT STREAM str_1 SKIP(2) "TRANSFERENCIA:" SKIP(2).
           
    FOR EACH tt-imprime-bloqueio-transf 
             NO-LOCK BREAK BY tt-imprime-bloqueio-transf.cdagenci:
           
        DISPLAY STREAM str_1 tt-imprime-bloqueio-transf.cdagenci
                             tt-imprime-bloqueio-transf.nrdconta
                             tt-imprime-bloqueio-transf.nmprimtl
                             tt-imprime-bloqueio-transf.nroficio
                             tt-imprime-bloqueio-transf.dtblqini
                             tt-imprime-bloqueio-transf.vlbloque
                             WITH FRAME f_bloqueio_2.
           
        DOWN STREAM str_1 WITH FRAME f_bloqueio_2.
    END.       
       
    PUT STREAM str_1 SKIP(1)
                     "MODALIDADE"                        AT 37
                     "TOTAIS"                            AT 74
                     "--------------------"              AT 37
                     "---------------------------------" AT 61
                     SKIP.
    
    FOR EACH tt-imprime-total WHERE tt-imprime-total.cdtipmov = 2
                                    NO-LOCK:
  
        DISPLAY STREAM str_1  tt-imprime-total.dsmodali   
                              tt-imprime-total.qtdbloqu
                              tt-imprime-total.vldbloqu
                              WITH FRAME f_bloqueio_total_transf.
    
        DOWN STREAM str_1 WITH FRAME f_bloqueio_total_transf.
    END.
    
    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.
    
    RUN envia-arquivo-web IN h-b1wgen0024 (INPUT par_cdcooper,
                                           INPUT 1, /* cdagenci */
                                           INPUT 0, /* nrdcaixa */
                                           INPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).     
        
    DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */








