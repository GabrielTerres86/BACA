/*.............................................................................

    Programa: b1wgen0018.p
    Autor   : GATI - Peixoto/Eder
    Data    : Setembro/2009                   Ultima Atualizacao: 19/04/2017
    
    Dados referentes ao programa:

    Objetivo  : Rotinas para obtencao de dados para consultas diversas
                relacionadas a conta

    Alteracoes: 23/11/2009 - Inclusao de procedures para estruturacao da tela
                             DESCTO: 
                             * consulta_cheques_descontados, 
                             * consulta_quem_descontou, 
                             * pesquisa_cheque_descontado,
                             * busca_fechamento_descto,
                             * busca_maiores_cheques_craptab,
                             * busca_lotes_descto,
                             * busca_saldo_descto,
                             * busca_todos_lancamentos,
                             * busca_cheques_descontados_conta,
                             * busca_cheques_descontados_geral,
                             * pi_calcula_datas_liberacao, 
                             * pi_grava_tt-fechamento_descto 
                             CUSTOD:
                             * busca_informacoes_relatorio_custodia
                             
                             (GATI - Eder)

                 08/03/2010 - Correcao data de liberacao(Mirtes)
                            - PA do lote estava ficando zerado na procedure
                              desconta_cheques_em_custodia (David).
                              
                 17/08/2010 - Alteracao do campo tt-crapcst.tpdevolu de "" para
                              "Cust" (Vitor).
                              
                 18/08/2010 - Alteracao na procedure consulta_cheques_custodia
                              p/ filtrar o tipo de listagem de cheques (Vitor).                           
                 
                 30/08/2010 - Incluido caminho completo na gravacao dos arquivos
                              de log (Elton). 
                 
                 28/10/2010 - Alterado procedure valida_operador_desconto
                              para validar senha atraves da BO b1wgen0000.p 
                              (Adriano).
                 
                 05/11/2010 - Criado as procedures alterar_cheques_descontados,
                              busca_alterar_cheques_descontados para a tela
                              DESCTO (Adriano).
                              
                 20/12/2010 - Alteracao nas procedures alterar_cheques_descontados,
                              busca_alterar_cheques_descontados. As mesmas nao
                              estavam sendo processadas de forma correta quando 
                              ha mais de um emitente cadastrado com cdbanchq,
                              cdagechq iguais (Adriano).
                              
                 21/12/2010 - Inclusao dos campos Data inicial e final na
                              consulta (GATI - Sandro).
                              
                 03/06/2011 - Atualiza cheques de desconto a partir dos cheques
                              de custodia - Truncagem (Ze).
                              
                 08/07/2011 - Realizado alteracao na passagem de parametros das
                              procedures:
                              * busca_maiores_cheques_craptab
                              * busca_lotes_descto
                              * busca_cheques_descontados_geral
                              * busca_informacoes_relatorio_custodia
                              * alterar_cheques_descontados 
                              Alterado glb_cdcooper para par_cdcooper no 
                              for each crapcst da procedure busca_lotes_custodia
                              (Adriano).
                            - Criada gera-impressao-transf-pac (Guilherme).
                            
                 27/07/2011 - Corrigido INPUT-OUTPUT aux_nrdconta na dig_fun
                              na procedure busca_informacoes_associado
                              (Guilherme).
                                                
                 03/04/2012 - Alterar as mensagens paramentrização desconto cheque
                             (Oscar).
                                                          
                 04/07/2012 - Tratamento do cdoperad "operador" de INTE para CHAR.
                              (Lucas R.) 
                             
                 12/11/2012 - Retirar matches dos find/for each (Gabriel).
                 
                 03/10/2013 - Alteração para banco ORACLE. Alterado campo da crapcst
                              de crapcst.dtliber para crapcst.dtlibera 
                              (Douglas Pagel).          
                              
                 24/12/2013 - Alterado para consultar troca de PA da conta por
                              PAC ou PA. (Reinert)                              
                                                
                 21/01/2014 - Incluida validacao na procedure consulta_transf_pacs
                              para os campos PA origem e PA destino da tela conalt.
                              (Reinert)
                              
                 05/03/2014 - Incluso VALIDATE (Daniel).
                 
                 24/03/2014 - Retirar tratamento de sequencia na crapbdc (Gabriel)
                              
                 10/04/2014 - #134444 Melhoria da validacao de PA origem e 
                              destino da tela CONALT. Agora valida a existencia 
                              dos PAs apenas quando for maior que zero (Carlos)
                             
                 28/05/2014 - Ajuste em proc. consulta_transf_pacs para verificar
                              campo de PA.
                              (Jorge/Gielow) - SD 152290
                 
                 05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
                            
                 11/12/2014 - Conversão da fn_sequence para procedure para não
                              gerar cursores abertos no Oracle. (Dionathan)
                              
                 16/02/2015 - Melhorias Nova Operacao 129,130,131 e 132- Desconto
                              de Cheque/Titulos (Andre Santos - SUPERO)
                 
                 10/07/2015 - Removido a quebra por data pois estava acarretando
                              na juncao dos borderos da mesma data conforme
                              solicitado no chamado 303654. (Kelvin)
                              
                 17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)
                 
                 23/09/2016 - Alterado valida_limites_desconto e valida_dados_desconto
                              para leitura da nova TAB de desconto segmentada por tipo de pessoa.
                              PRJ-300 - Desconto de cheque(Odirlei-AMcom)
                              
                 19/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                  crapass, crapttl, crapjur 
							 (Adriano - P339).
                              
                 12/03/2018 - Alterado para buscar descricao do tipo de conta do oracle. 
                              PRJ366 (Lombardi).
.............................................................................*/

/*................................ DEFINICOES ...............................*/
{ sistema/generico/includes/b1wgen0018tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/var_oracle.i }
{ includes/var_batch.i }

DEF        VAR aux_cdcritic AS INTE                                   NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                   NO-UNDO.
DEF        VAR aux_pacorig  AS CHAR                                   NO-UNDO.
DEF        VAR aux_nrsequen AS INTE                                   NO-UNDO.
DEF        VAR aux_dssitchq AS CHAR                                   NO-UNDO.
DEF        VAR aux_dtliber1 AS DATE FORMAT "99/99/9999"               NO-UNDO.
DEF        VAR aux_dtliber2 AS DATE FORMAT "99/99/9999"               NO-UNDO.
DEF        VAR aux_vlchqmai AS DECI FORMAT "zzz,zzz,zz9.99"           NO-UNDO.

DEF        VAR ind_dtmvtolt AS DATE FORMAT "99/99/9999"               NO-UNDO.
DEF        VAR ind_cdagenci AS INTE FORMAT "999"                      NO-UNDO.
DEF        VAR ind_cdbccxlt AS INTE FORMAT "999"                      NO-UNDO.
DEF        VAR ind_nrdolote AS INTE FORMAT "999999"                   NO-UNDO.
DEF        VAR ind_cdcmpchq AS INTE FORMAT "999"                      NO-UNDO.
DEF        VAR ind_cdbanchq AS INTE FORMAT "999"                      NO-UNDO.
DEF        VAR ind_cdagechq AS INTE FORMAT "9999"                     NO-UNDO.
DEF        VAR ind_nrctachq AS DECI FORMAT "99999999999999"           NO-UNDO.
DEF        VAR ind_nrcheque AS INTE FORMAT "999999"                   NO-UNDO.
DEF        VAR tab_vlchqmai AS DECI FORMAT "zzz,zzz,zz9.99"           NO-UNDO.
DEF        VAR aux_contador AS INTE                                   NO-UNDO.
DEF        VAR aux_nrdconta AS INTE                                   NO-UNDO.

DEF        VAR lot_vlchqcop AS DECI FORMAT "zzzz,zzz,zz9.99"          NO-UNDO.
DEF        VAR lot_vlchqmen AS DECI FORMAT "zzzz,zzz,zz9.99"          NO-UNDO.
DEF        VAR lot_vlchqmai AS DECI FORMAT "zzzz,zzz,zz9.99"          NO-UNDO.
DEF        VAR lot_qtchqcop AS INTE FORMAT "zzz9"                     NO-UNDO.
DEF        VAR lot_qtchqmen AS INTE FORMAT "zzz9"                     NO-UNDO.
DEF        VAR lot_qtchqmai AS INTE FORMAT "zzz9"                     NO-UNDO.
DEF        VAR lot_nmoperad AS CHAR FORMAT "x(10)"                    NO-UNDO.

DEF        VAR tab_qtrenova AS INTE                                   NO-UNDO.
DEF        VAR tab_qtprzmin AS INTE                                   NO-UNDO.
DEF        VAR tab_qtprzmax AS INTE                                   NO-UNDO.
DEF        VAR aux_dtminima AS DATE                                   NO-UNDO.
DEF        VAR aux_dtmaxima AS DATE                                   NO-UNDO.
DEF        VAR aux_dtlimite AS DATE                                   NO-UNDO.
DEF        VAR aux_dtmvtoan AS DATE                                   NO-UNDO.
DEF        VAR aux_nvoperad AS CHAR     EXTENT 3 INITIAL
                                                ["   Operador",
                                                 "Coordenador",
                                                 "    Gerente"]      NO-UNDO.
DEF        VAR aux_novolote AS INTE                                  NO-UNDO.
DEF        VAR aux_nrborder AS INTE                                  NO-UNDO.
DEF        VAR aux_contalan AS INTE                                  NO-UNDO.
DEF        VAR aux_somalanc AS DECI                                  NO-UNDO.  

DEF        VAR aux_dstipcta AS CHAR                                  NO-UNDO.
DEF        VAR aux_des_erro AS CHAR                                  NO-UNDO.

DEFINE STREAM str_1. /* Relatorio  */   

/*............................ PROCEDURES EXTERNAS ..........................*/

/*****************************************************************************
 Gerar Impressao do relatorio de transferencias de PA
*****************************************************************************/
PROCEDURE gera-impressao-transf-pac:

     DEF  INPUT PARAM par_cdcooper AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                          NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                          NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_nrpacori AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_nrpacdes AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_dtperini AS DATE                          NO-UNDO.
     DEF  INPUT PARAM par_dtperfim AS DATE                          NO-UNDO.
     DEF  INPUT PARAM par_nmendter AS CHAR                          NO-UNDO.
     
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     DEF OUTPUT PARAM par_nmarqimp AS CHAR                          NO-UNDO.
     DEF OUTPUT PARAM par_nmarqpdf AS CHAR                          NO-UNDO.

     DEFINE VARIABLE aux_cabectra AS CHARACTER   NO-UNDO.
     DEFINE VARIABLE h-b1wgen0024 AS HANDLE      NO-UNDO.

     FORM SKIP
          tt-transfer.nrdconta       FORMAT "zzzz,zzz,9"
                                     COLUMN-LABEL "Conta/DV"
          tt-transfer.nmprimtl       FORMAT "x(50)"      
                                     COLUMN-LABEL "Associado"
          tt-transfer.cdageatu       FORMAT "99"
                                     COLUMN-LABEL "PA Atual"
          tt-transfer.dtaltera       FORMAT "99/99/9999" 
                                     COLUMN-LABEL "Data Alt."
          tt-transfer.cdageori       FORMAT "99"
                                     COLUMN-LABEL "PA Origem"
          tt-transfer.cdagedes       FORMAT "99"
                                     COLUMN-LABEL "PA Destino"
          WITH DOWN NO-BOX NO-ATTR-SPACE WIDTH 133 FRAME f_rel STREAM-IO.

     ASSIGN aux_cdcritic = 0
            aux_dscritic = "".

     EMPTY TEMP-TABLE tt-erro.

     FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapcop   THEN
         DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_idorigem,           
                           INPUT 651,
                           INPUT-OUTPUT aux_dscritic).                 
            RETURN "NOK".
         END.

     RUN consulta_transf_pacs    (INPUT par_cdcooper,
                                  INPUT par_nrpacori,
                                  INPUT par_nrpacdes,
                                  INPUT par_dtperini,
                                  INPUT par_dtperfim,
                                  INPUT 0,
                                  INPUT 0,
                                  OUTPUT aux_cabectra,
                                  OUTPUT TABLE tt-transfer,
                                  OUTPUT TABLE tt-erro).
     
     IF  RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".




     ASSIGN par_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                           par_nmendter + "deconv.ex".
     
     UNIX SILENT VALUE("rm /usr/coop/" + crapcop.dsdircop + "/rl/" + 
                       par_nmendter + "deconv* 2> /dev/null").



     OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.     
     
     PUT STREAM str_1 UNFORMATTED
                aux_cabectra 
                SKIP
                "Periodo: " par_dtperini
                " ate " par_dtperfim 
                SKIP(2).

     FOR EACH tt-transfer BY tt-transfer.dtaltera:

         DISPLAY STREAM str_1
                        tt-transfer.nrdconta
                        tt-transfer.nmprimtl
                        tt-transfer.cdageatu
                        tt-transfer.dtaltera
                        tt-transfer.cdageori 
                        tt-transfer.cdagedes 
                        WITH FRAME f_rel.
         DOWN STREAM str_1 WITH FRAME f_rel.  
     END.

     OUTPUT STREAM str_1 CLOSE.
     
     IF  par_idorigem = 5  THEN /* Copiar PDF para o Ayllos Web */
     DO:
         RUN sistema/generico/procedures/b1wgen0024.p
             PERSISTENT SET h-b1wgen0024.

         RUN envia-arquivo-web IN h-b1wgen0024
                                  (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_nmarqimp,
                                  OUTPUT par_nmarqpdf,
                                  OUTPUT TABLE tt-erro).     

         DELETE PROCEDURE h-b1wgen0024.

         IF   RETURN-VALUE <> "OK"   THEN
              RETURN "NOK".
     END.

     RETURN "OK".

 END PROCEDURE.

/*****************************************************************************/
/**           Procedure para obter alteracoes de tipo de conta              **/
/*****************************************************************************/
PROCEDURE consulta_alteracoes_tp_conta:

    DEFINE INPUT  PARAM  par_cdcooper   AS INTE   NO-UNDO.
    DEFINE INPUT  PARAM  par_nrdconta   AS INTE   NO-UNDO.
    DEFINE INPUT  PARAM  par_cdagenci   AS INTE   NO-UNDO.
    DEFINE INPUT  PARAM  par_nrdcaixa   AS INTE   NO-UNDO.
    DEFINE OUTPUT PARAM  TABLE FOR tt-detalhe-conta.
    DEFINE OUTPUT PARAM  TABLE FOR tt-alt-tip-conta.
    DEFINE OUTPUT PARAM  TABLE FOR tt-erro.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper 
                   AND crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass   THEN
         DO:
             ASSIGN aux_cdcritic = 67
                    aux_dscritic = "".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK". 
         END.

    FIND crapage WHERE crapage.cdcooper = par_cdcooper     
                   AND crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.

    CREATE tt-detalhe-conta.
    ASSIGN tt-detalhe-conta.nrmatric = crapass.nrmatric
           tt-detalhe-conta.dtabtcct = crapass.dtabtcct
           tt-detalhe-conta.nrdctitg = crapass.nrdctitg
           tt-detalhe-conta.dtatipct = crapass.dtatipct
           tt-detalhe-conta.nmprimtl = crapass.nmprimtl.
    
	IF crapass.inpessoa = 1 THEN
	   DO:
	      FOR FIRST crapttl FIELDS(nmextttl)
		                    WHERE crapttl.cdcooper = crapass.cdcooper AND
						          crapttl.nrdconta = crapass.nrdconta AND
							      crapttl.idseqttl = 2
							      NO-LOCK:

		    ASSIGN tt-detalhe-conta.nmsegntl = crapttl.nmextttl.

		  END.

	   END.
    
    IF   NOT AVAILABLE crapage   THEN
         tt-detalhe-conta.dsagenci = STRING(crapass.cdagenci,"zz9") +
                                     " - " + FILL("*",15).
    ELSE
         tt-detalhe-conta.dsagenci = STRING(crapass.cdagenci,"zz9") + " - " +
                                     crapage.nmresage.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_descricao_tipo_conta
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa,    /* tipo de pessoa */
                                         INPUT crapass.cdtipcta,    /* tipo de conta */
                                        OUTPUT "",   /* Descricao do tipo de conta */
                                        OUTPUT "",   /* Flag Erro */
                                        OUTPUT "").  /* Descrição da crítica */
    
    CLOSE STORED-PROC pc_descricao_tipo_conta
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dstipcta = ""
           aux_des_erro = ""
           aux_dscritic = ""
           aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                          WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
           aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                          WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
           aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                          WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
    
    IF aux_des_erro = "NOK"  THEN
         tt-detalhe-conta.dstipcta = STRING(crapass.cdtipcta,"99") + 
                                     " - " + FILL("*",15).
    ELSE
         tt-detalhe-conta.dstipcta = STRING(crapass.cdtipcta,"99") + 
                                     " - " + aux_dstipcta.

    IF   crapass.flgctitg = 2   THEN
         tt-detalhe-conta.dssititg = "Ativa".
    ELSE
    IF   crapass.flgctitg = 3   THEN
         tt-detalhe-conta.dssititg = "Inativa".
    ELSE
    IF   crapass.nrdctitg <> ""   THEN
         tt-detalhe-conta.dssititg = "Em Proc".
    ELSE
         tt-detalhe-conta.dssititg = "".

   
    FOR EACH crapact WHERE crapact.cdcooper = par_cdcooper 
                       AND crapact.nrdconta = par_nrdconta NO-LOCK:

        CREATE tt-alt-tip-conta.
        ASSIGN tt-alt-tip-conta.dtalttct = crapact.dtalttct.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapass   THEN
            DO:
            END.
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_descricao_tipo_conta
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa,    /* tipo de pessoa */
                                             INPUT crapact.cdtctant,    /* tipo de conta */
                                            OUTPUT "",   /* Descricao do tipo de conta */
                                            OUTPUT "",   /* Flag Erro */
                                            OUTPUT "").  /* Descrição da crítica */
        
        CLOSE STORED-PROC pc_descricao_tipo_conta
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_dstipcta = ""
               aux_des_erro = ""
               aux_dscritic = ""
               aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                              WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
               aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                              WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
               aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                              WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
        
        IF aux_des_erro = "NOK"  THEN
             tt-alt-tip-conta.dstctant = STRING(crapact.cdtctant,"99") + 
                                         " - " + FILL("*",15).
        ELSE
             tt-alt-tip-conta.dstctant = STRING(crapact.cdtctant,"99") + 
                                         " - " + aux_dstipcta.
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_descricao_tipo_conta
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa,    /* tipo de pessoa */
                                             INPUT crapact.cdtctatu,    /* tipo de conta */
                                            OUTPUT "",   /* Descricao do tipo de conta */
                                            OUTPUT "",   /* Flag Erro */
                                            OUTPUT "").  /* Descrição da crítica */
        
        CLOSE STORED-PROC pc_descricao_tipo_conta
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_dstipcta = ""
               aux_des_erro = ""
               aux_dscritic = ""
               aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                              WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
               aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                              WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
               aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                              WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
        
        IF aux_des_erro = "NOK"  THEN
             tt-alt-tip-conta.dstctatu = STRING(crapact.cdtctatu,"99") + 
                                         " - " + FILL("*",15).
        ELSE
             tt-alt-tip-conta.dstctatu = STRING(crapact.cdtctatu,"99") + 
                                         " - " + aux_dstipcta.

    END.  /*  Fim do FOR EACH  --  Leitura do crapact  */

    RETURN "OK".                                                   
    
END PROCEDURE. /* consulta_alteracoes_tp_conta */

/*****************************************************************************/
/**         Procedure para obter transferencias de pacs                     **/
/*****************************************************************************/
PROCEDURE consulta_transf_pacs:

    DEFINE INPUT  PARAM  par_cdcooper   AS INTE   NO-UNDO.
    DEFINE INPUT  PARAM  par_nrpacori   AS INTE   NO-UNDO.
    DEFINE INPUT  PARAM  par_nrpacdes   AS INTE   NO-UNDO.
    DEFINE INPUT  PARAM  par_dtperini   AS DATE   NO-UNDO.
    DEFINE INPUT  PARAM  par_dtperfim   AS DATE   NO-UNDO.
    DEFINE INPUT  PARAM  par_cdagenci   AS INTE   NO-UNDO.
    DEFINE INPUT  PARAM  par_nrdcaixa   AS INTE   NO-UNDO.
    DEFINE OUTPUT PARAM  par_cabectra   AS CHAR   NO-UNDO.
    DEFINE OUTPUT PARAM  TABLE FOR tt-transfer.
    DEFINE OUTPUT PARAM  TABLE FOR tt-erro.

    DEFINE VARIABLE aux_dsaltera AS CHAR EXTENT 2 NO-UNDO.
    DEFINE VARIABLE aux_ndsalter AS CHAR EXTENT 2 NO-UNDO.
    DEFINE VARIABLE aux_pacatual AS CHAR          NO-UNDO.

    IF  par_nrpacori > 0 AND 
        NOT CAN-FIND(crapage WHERE crapage.cdcooper = par_cdcooper
                              AND crapage.cdagenci = par_nrpacori) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "PA Origem nao cadastrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    IF  par_nrpacdes > 0 AND
        NOT CAN-FIND(crapage WHERE crapage.cdcooper = par_cdcooper
                              AND crapage.cdagenci = par_nrpacdes) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "PA Destino nao cadastrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    IF  par_nrpacori = par_nrpacdes  THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "PA Origem e Destino devem ser diferentes.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1, /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF   par_dtperini = ?   THEN 
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Periodo inicial nao informado.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1, /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF   par_dtperfim = ?   THEN 
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Periodo final nao informado.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1, /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF   par_dtperfim < par_dtperini   THEN 
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Periodo final deve ser maior que o inicial.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1, /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.
    
    IF   par_nrpacori = 0   THEN
         ASSIGN par_cabectra = "Transferencias de outros PAs para PA " +
                               STRING(par_nrpacdes) 
                aux_dsaltera[1] = "*-" + STRING(par_nrpacdes) + ",*"
                aux_dsaltera[2] = "*-" + STRING(par_nrpacdes) + ",*".
    ELSE 
    IF   par_nrpacdes = 0   THEN
         ASSIGN par_cabectra = "Transferencias do PA " + 
                               STRING(par_nrpacori) + 
                               " para outros PAs."
                aux_dsaltera[1] = "*PAC " + STRING(par_nrpacori) + "-*"
                aux_dsaltera[2] = "*PA " + STRING(par_nrpacori) + "-*". 
    ELSE 
         ASSIGN par_cabectra = "Transferencias do PA " +
                               STRING(par_nrpacori) + " para o PA " +
                               STRING(par_nrpacdes)
                aux_dsaltera[1] = "*PAC " + STRING(par_nrpacori) +
                               "-" + STRING(par_nrpacdes)  + ",*"
                aux_dsaltera[2] = "*PA " + STRING(par_nrpacori) +
                               "-" + STRING(par_nrpacdes)  + ",*".
    
    FOR EACH crapass WHERE crapass.cdcooper  = par_cdcooper
                       AND crapass.dtdemiss  = ?             NO-LOCK,
        EACH crapalt WHERE crapalt.cdcooper  = crapass.cdcooper 
                       AND crapalt.dtaltera >= par_dtperini      
                       AND crapalt.dtaltera <= par_dtperfim     
                       AND crapalt.nrdconta  = crapass.nrdconta NO-LOCK:
         
         IF   NOT ((crapalt.dsaltera MATCHES aux_dsaltera[1]  AND
                    crapalt.dsaltera MATCHES "*PA *")        OR
                   (crapalt.dsaltera MATCHES aux_dsaltera[2]  AND
                    crapalt.dsaltera MATCHES "*PA *"))        THEN
              NEXT.
         
         IF   crapass.cdagenci <> par_nrpacori   THEN
              DO:                 
                 ASSIGN aux_ndsalter[1] = crapalt.dsaltera                        
                        aux_ndsalter[2] = crapalt.dsaltera
                        aux_ndsalter[1] = SUBSTRING(aux_ndsalter[1],
                                                 R-INDEX(aux_ndsalter[1],"PA"),
                                                 10)
                        aux_ndsalter[2] = SUBSTRING(aux_ndsalter[2],
                                                 R-INDEX(aux_ndsalter[2],"PA"),
                                                 10)
                        aux_ndsalter[1] = ENTRY(1,aux_ndsalter[1],",") + ","
                        aux_ndsalter[2] = ENTRY(1,aux_ndsalter[2],",") + "," NO-ERROR.
                 
                 IF   aux_ndsalter[1] MATCHES aux_dsaltera[1] THEN 
                      DO:
                          /* se for o primeiro parametro do campo */
                          IF R-INDEX(crapalt.dsaltera,"PA ") = 1 THEN
                          DO:
                             ASSIGN aux_pacatual = SUBSTRING(crapalt.dsaltera,
                                                   R-INDEX(crapalt.dsaltera,
                                                   "PA ") + 4, 10)
                                    aux_pacatual = SUBSTRING(aux_pacatual,
                                                   INDEX(aux_pacatual,
                                                   "-") + 1, 2)
                                    aux_pacatual = REPLACE(aux_pacatual, ",", "")
                                    aux_pacorig  = SUBSTRING(crapalt.dsaltera,
                                                   R-INDEX(crapalt.dsaltera,
                                                   "PA  ") + 4, 10)
                                    aux_pacorig  = SUBSTRING(aux_pacorig,
                                                   1, INDEX(aux_pacorig,
                                                   "-") - 1).
                          END.
                          ELSE
                          DO:
                             /* se nao for o primeiro item verifica 
                                se encontra ,PAC */
                             IF R-INDEX(crapalt.dsaltera, ",PA ") > 0 THEN
                                DO:
                                    aux_pacatual = SUBSTRING(crapalt.dsaltera,
                                                   R-INDEX(crapalt.dsaltera,
                                                   ",PA ") + 5, 10).
                                    aux_pacatual = SUBSTRING(aux_pacatual,
                                                   INDEX(aux_pacatual,
                                                   "-") + 1, 2).
                                    aux_pacatual = REPLACE(aux_pacatual, ",", "").
                                    aux_pacorig  = SUBSTRING(crapalt.dsaltera,
                                                   R-INDEX(crapalt.dsaltera,
                                                   ",PA ") + 5, 10).
                                    aux_pacorig  = SUBSTRING(aux_pacorig,
                                                   1, INDEX(aux_pacorig,
                                                   "-") - 1).
                                END.
                             ELSE
                                NEXT. /* senao nao existe alteracao de PA */
                          END.

                          CREATE tt-transfer.
                          ASSIGN tt-transfer.nrdconta = crapass.nrdconta
                                 tt-transfer.nmprimtl = crapass.nmprimtl 
                                 tt-transfer.cdageatu = crapass.cdagenci
                                 tt-transfer.dtaltera = crapalt.dtaltera 
                                 tt-transfer.cdagedes = INT(aux_pacatual)
                                 tt-transfer.cdageori = INT(aux_pacorig).
                           
                      END.  /* IF   aux_ndsalter[1] MATCHES aux_dsaltera[1] */
                 ELSE
                      IF aux_ndsalter[2] MATCHES aux_dsaltera[2]   THEN
                         DO:
                            /* se for o primeiro parametro do campo */
                            IF R-INDEX(crapalt.dsaltera,"PA ") = 1 THEN
                            DO:
                                aux_pacatual = SUBSTRING(crapalt.dsaltera,
                                               R-INDEX(crapalt.dsaltera,
                                               "PA ") + 3, 10).
                                aux_pacatual = SUBSTRING(aux_pacatual,
                                               INDEX(aux_pacatual, "-") + 1, 2).
                                aux_pacatual = REPLACE(aux_pacatual, ",", "").
                                aux_pacorig  = SUBSTRING(crapalt.dsaltera,
                                               R-INDEX(crapalt.dsaltera,
                                               "PA ") + 3, 10).
                                aux_pacorig  = SUBSTRING(aux_pacorig, 1, 
                                               INDEX(aux_pacorig,"-") - 1).
                            END.
                            ELSE
                            DO: /* se nao for o primeiro item verifica 
                                   se existe alteracao de ,PA */
                                IF R-INDEX(crapalt.dsaltera, ",PA ") > 0 THEN
                                DO:
                                    aux_pacatual = SUBSTRING(crapalt.dsaltera,
                                                   R-INDEX(crapalt.dsaltera,
                                                   ",PA ") + 4, 10).
                                    aux_pacatual = SUBSTRING(aux_pacatual,
                                                   INDEX(aux_pacatual, "-") 
                                                   + 1,2).
                                    aux_pacatual = REPLACE(aux_pacatual, ",", "").
                                    aux_pacorig = SUBSTRING(crapalt.dsaltera,
                                                  R-INDEX(crapalt.dsaltera,
                                                  ",PA ") + 4, 10).
                                    aux_pacorig = SUBSTRING(aux_pacorig, 1, 
                                                  INDEX(aux_pacorig,"-") - 1).
                                END.
                                ELSE
                                    NEXT. /* senao nao existe alteracao de PA */
                            END.

                            CREATE tt-transfer.
                            ASSIGN tt-transfer.nrdconta = crapass.nrdconta
                                   tt-transfer.nmprimtl = crapass.nmprimtl 
                                   tt-transfer.cdageatu = crapass.cdagenci
                                   tt-transfer.dtaltera = crapalt.dtaltera 
                                   tt-transfer.cdagedes = INT(aux_pacatual)
                                   tt-transfer.cdageori = INT(aux_pacorig).

                         END.  /* IF   aux_ndsalter[2] MATCHES aux_dsaltera[2] */
              END. /* IF   crapass.cdagenci <> par_nrpacori */
    END. /* FOR EACH crapass */
    
    RETURN "OK".

END PROCEDURE. /* consulta_transf_pacs */

/*********************************** DESCTO *********************************/
PROCEDURE conferencia_cheques_descontados:
    /************************************************************************
        Objetivo: Buscar informacoes dos cheques descontados pelo bordero
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtiniper AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtfimper AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_containi AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_contafim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcdb.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcdb.

    FOR EACH crapcdb USE-INDEX crapcdb3 WHERE 
             crapcdb.cdcooper  = par_cdcooper   AND
             crapcdb.dtlibera >= par_dtiniper   AND 
             crapcdb.dtlibera <= par_dtfimper   AND 
             crapcdb.dtdevolu = ?               AND 
            (crapcdb.nrdconta >= par_containi   AND
             crapcdb.nrdconta <= par_contafim)  AND
             crapcdb.dtlibbdc <> ?              NO-LOCK:
        
        /* Quando informado PAC, filtra */
        IF par_cdagenci <> 0 AND crapcdb.cdagenci <> par_cdagenci THEN NEXT.
        
        CREATE tt-crapcdb.
        BUFFER-COPY crapcdb TO tt-crapcdb.

        FIND crapass WHERE 
             crapass.cdcooper = crapcdb.cdcooper  AND
             crapass.nrdconta = crapcdb.nrdconta  NO-LOCK NO-ERROR.
        IF   AVAIL crapass   THEN
             ASSIGN tt-crapcdb.nmprimtl = crapass.nmprimtl.
    END.
    
END PROCEDURE. /* conferencia_cheques_descontados */
    
PROCEDURE busca_informacoes_associado:
    /*************************************************************************
        Objetivo: Buscar as informacoes do associado conforme Conta ou
                  CPF informados
    *************************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapass.

    DEF VAR h_b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_nrdconta LIKE par_nrdconta                          NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapass.

    IF   par_nrdconta <> 0   THEN /* Busca associado pela conta */
         DO:
             ASSIGN aux_nrdconta = par_nrdconta.

             RUN sistema/generico/procedures/b1wgen9999.p 
                             PERSISTENT SET h_b1wgen9999.

             RUN dig_fun IN h_b1wgen9999 (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT-OUTPUT aux_nrdconta,
                                          OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h_b1wgen9999.
                  
             IF   RETURN-VALUE = "NOK"   THEN
                  RETURN "NOK".

            
             FIND crapass WHERE
                  crapass.cdcooper = par_cdcooper  AND
                  crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.
             IF   NOT AVAIL crapass   THEN
                  DO:
                      ASSIGN aux_cdcritic = 9
                             aux_dscritic = ""
                             aux_nrsequen = aux_nrsequen + 1.
            
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT aux_nrsequen, /** Sequencia **/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
            
                      RETURN "NOK".
                  END.
         END. /* IF   par_nrdconta <> 0 */
    ELSE IF   par_nrcpfcgc <> 0   THEN /* Busca associado pelo CPF/CNPJ */
         DO:
             FIND crapass WHERE
                  crapass.cdcooper = par_cdcooper AND
                  crapass.nrcpfcgc = par_nrcpfcgc NO-LOCK NO-ERROR.
                    
             IF   NOT AVAIL crapass   THEN
                  DO:
                      CREATE tt-crapass.
                      ASSIGN tt-crapass.nmprimtl = "***** SEM CADASTRO *****".
                      RELEASE tt-crapass.
                      RETURN "OK".
                  END.  
         END. /* IF   par_nrcpfcgc <> 0   THEN */
    ELSE
         DO:
             CREATE tt-crapass.
             ASSIGN tt-crapass.nmprimtl = "***** SEM CADASTRO *****".
             RELEASE tt-crapass.
             RETURN "OK".
         END.

    CREATE tt-crapass.
    BUFFER-COPY crapass TO tt-crapass.

    RETURN "OK".

END PROCEDURE. /* fim busca_informacoes_associado */

PROCEDURE consulta_cheques_descontados:
    /************************************************************************
        Objetivo: Consultar cheques descontados por conta (Opcao "C" da tela
                  DESCTO)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcpfcgc AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtoan AS DATE        NO-UNDO.    
    DEFINE INPUT  PARAMETER par_dtlibini AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibfim AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcdb.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcdb.

    IF  (par_dtlibini <> ?  AND par_dtlibfim  = ?) OR 
        (par_dtlibini  = ?  AND par_dtlibfim <> ?) THEN
        DO:

             ASSIGN aux_cdcritic = 0
                    aux_dscritic = IF par_dtlibini = ? THEN
                                      "Informe a data inicial."
                                   ELSE
                                      "Informe a data final."
                    aux_nrsequen = aux_nrsequen + 1.
           
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

        END.

    IF   par_nrdconta <> 0  THEN /* Busca pelo numero da conta */
         DO:
             IF  par_dtlibini = ? THEN
                 DO:
                      FOR EACH crapcdb USE-INDEX crapcdb2 WHERE
                               crapcdb.cdcooper =  par_cdcooper   AND
                               crapcdb.nrdconta =  par_nrdconta   AND
                               crapcdb.dtlibera >  par_dtmvtoan   AND
                               crapcdb.dtlibbdc <> ?              NO-LOCK:
                          CREATE tt-crapcdb.
                          BUFFER-COPY crapcdb TO tt-crapcdb.
                      END.
                 END.
             ELSE
                 DO:
                     FOR EACH crapcdb USE-INDEX crapcdb2 WHERE
                              crapcdb.cdcooper =  par_cdcooper   AND
                              crapcdb.nrdconta =  par_nrdconta   AND
                              crapcdb.dtlibera >= par_dtlibini   AND
                              crapcdb.dtlibera <= par_dtlibfim   AND
                              crapcdb.dtlibbdc <> ?              NO-LOCK:
                         CREATE tt-crapcdb.
                         BUFFER-COPY crapcdb TO tt-crapcdb.
                     END.
                 END.

         END.
    ELSE 
         DO: /* Busca pelo numero do CPF/CNPJ ou 0 - Sem cadastro */

             IF  par_dtlibini = ? THEN
                 DO:
                     FOR EACH crapcdb USE-INDEX crapcdb8 WHERE
                              crapcdb.cdcooper =  par_cdcooper   AND
                              crapcdb.nrcpfcgc =  par_nrcpfcgc   AND
                              crapcdb.dtlibera >  par_dtmvtoan   AND
                              crapcdb.dtlibbdc <> ?              NO-LOCK:
                         CREATE tt-crapcdb.
                         BUFFER-COPY crapcdb TO tt-crapcdb.
                     END.
                 END.
             ELSE
                 DO:
                     FOR EACH crapcdb USE-INDEX crapcdb8 WHERE
                              crapcdb.cdcooper =  par_cdcooper   AND
                              crapcdb.nrcpfcgc =  par_nrcpfcgc   AND
                              crapcdb.dtlibera >= par_dtlibini   AND
                              crapcdb.dtlibera <= par_dtlibfim   AND
                              crapcdb.dtlibbdc <> ?              NO-LOCK:
                         CREATE tt-crapcdb.
                         BUFFER-COPY crapcdb TO tt-crapcdb.
                     END.
                 END.

         END.

    IF   NOT CAN-FIND(FIRST tt-crapcdb)   THEN
         DO:
             ASSIGN aux_cdcritic = 81
                    aux_dscritic = ""
                    aux_nrsequen = aux_nrsequen + 1.
           
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
            
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE. /* consulta_cheques_descontados */


PROCEDURE consulta_quem_descontou:
    /************************************************************************
        Objetivo: Consultar quem descontou os cheques de determinada conta
                  (Opcao "Q" da tela DESCTO)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcdb.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcdb.

    FOR EACH craplau WHERE 
             craplau.cdcooper = par_cdcooper   AND
             craplau.nrdconta = par_nrdconta   AND
             craplau.cdbccxlt = 700            AND
             craplau.dtmvtopg > par_dtmvtolt   NO-LOCK BY craplau.dtmvtopg
                                                       BY craplau.nrdocmto:

        IF   INT(SUBSTRING(craplau.cdseqtel,16,03)) = 600   THEN   
             ASSIGN ind_dtmvtolt = craplau.dtmvtolt 
                    ind_cdagenci = craplau.cdagenci
                    ind_cdbccxlt = craplau.cdbccxlt
                    ind_nrdolote = craplau.nrdolote.
        ELSE 
             ASSIGN ind_dtmvtolt = DATE(INT(SUBSTRING(craplau.cdseqtel,
                                                      04,02)),
                                        INT(SUBSTRING(craplau.cdseqtel,
                                                      01,02)),
                                        INT(SUBSTRING(craplau.cdseqtel,
                                                      07,04)))
                       
                    ind_cdagenci = INT(SUBSTRING(craplau.cdseqtel,
                                                 12,03))
                    ind_cdbccxlt = INT(SUBSTRING(craplau.cdseqtel,
                                                 16,03))
                    ind_nrdolote = INT(SUBSTRING(craplau.cdseqtel,
                                                 20,06)).
           
        ASSIGN ind_cdcmpchq = INT(SUBSTRING(craplau.cdseqtel,27,03))
               ind_cdbanchq = INT(SUBSTRING(craplau.cdseqtel,31,03))
               ind_cdagechq = INT(SUBSTRING(craplau.cdseqtel,35,04))
               ind_nrctachq = INT(SUBSTRING(craplau.cdseqtel,40,08))
               ind_nrcheque = INT(SUBSTRING(craplau.cdseqtel,49,06)).
           
        FIND crapcdb WHERE crapcdb.cdcooper = par_cdcooper   AND
                           crapcdb.dtmvtolt = ind_dtmvtolt   AND
                           crapcdb.cdagenci = ind_cdagenci   AND
                           crapcdb.cdbccxlt = ind_cdbccxlt   AND
                           crapcdb.nrdolote = ind_nrdolote   AND
                           crapcdb.cdcmpchq = ind_cdcmpchq   AND
                           crapcdb.cdbanchq = ind_cdbanchq   AND
                           crapcdb.cdagechq = ind_cdagechq   AND
                           crapcdb.nrctachq = ind_nrctachq   AND
                           crapcdb.nrcheque = ind_nrcheque
                           NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapcdb   THEN
             NEXT.
                
        FIND crapass WHERE crapass.cdcooper = crapcdb.cdcooper     AND
                           crapass.nrdconta = crapcdb.nrdconta
                           NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE crapass   THEN
             NEXT.

        CREATE tt-crapcdb.
        BUFFER-COPY crapcdb TO tt-crapcdb
            ASSIGN tt-crapcdb.nmprimtl = crapass.nmprimtl
                   tt-crapcdb.dtmvtopg = craplau.dtmvtopg
                   tt-crapcdb.nrdocmto = craplau.nrdocmto.
        
    END. /*  Fim do FOR EACH -- craplau  */

    IF   NOT CAN-FIND(FIRST tt-crapcdb)   THEN
          DO:
              ASSIGN aux_cdcritic = 81
                     aux_dscritic = ""
                     aux_nrsequen = aux_nrsequen + 1.
            
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT aux_nrsequen, /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
            
              RETURN "NOK".
          END.

    RETURN "OK".

END PROCEDURE. /* consulta_quem_descontou */

PROCEDURE pesquisa_cheque_descontado:
    /************************************************************************
        Objetivo: Consultar informacoes de um cheque descontado (Opcao "P" 
                  da tela DESCTO)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbanchq AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagechq AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctachq AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcheque AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcdb.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcdb.

    ASSIGN aux_dssitchq = "NAO PROCESSADO,RESGATADO,PROCESSADO,COM PROBLEMAS".

    FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper   AND
                           crapcdb.nrdconta = par_nrdconta   AND
                           crapcdb.cdbanchq = par_cdbanchq   AND
                           crapcdb.cdagechq = par_cdagechq   AND
                           crapcdb.nrctachq = par_nrctachq   AND
                           crapcdb.nrcheque = par_nrcheque   NO-LOCK:

        CREATE tt-crapcdb.
        BUFFER-COPY crapcdb TO tt-crapcdb.

        ASSIGN tt-crapcdb.dspesqui = STRING(crapcdb.dtmvtolt,"99/99/9999")
                                     + "-" +
                                     STRING(crapcdb.cdagenci,"999") + "-" +
                                     STRING(crapcdb.cdbccxlt,"999") + "-" +
                                     STRING(crapcdb.nrdolote,"999999") + 
                                     "-" +
                                     STRING(crapcdb.nrseqdig,"99999")

               tt-crapcdb.dssitchq = ENTRY(crapcdb.insitchq + 1,aux_dssitchq)

               tt-crapcdb.dsobserv = IF crapcdb.insitchq = 1 THEN 
                                        "DEVOLVIDO EM " + 
                                        STRING(crapcdb.dtdevolu,"99/99/9999") +
                                        " - OPERADOR " + crapcdb.cdopedev
                                     ELSE "".

        IF   crapcdb.insitchq = 1   THEN
             DO:
                 ASSIGN tt-crapcdb.dsobserv = "RESGATADO EM " + 
                                              STRING(crapcdb.dtdevolu,
                                                     "99/99/9999").
                 FIND crapope WHERE 
                      crapope.cdcooper = crapcdb.cdcooper   AND
                      crapope.cdoperad = crapcdb.cdopedev   NO-LOCK NO-ERROR.
                      
                 IF   NOT AVAILABLE crapope   THEN
                      ASSIGN tt-crapcdb.nmopedev = "POR " + crapcdb.cdopedev +
                                                   " - NAO CADASTRADO".
                 ELSE
                      ASSIGN tt-crapcdb.nmopedev = "POR " + crapope.nmoperad.
              END.
        ELSE                             
              ASSIGN tt-crapcdb.dsobserv = ""
                     tt-crapcdb.nmopedev = "".

    END. /* FOR EACH crapcdb */

    IF   NOT CAN-FIND(FIRST tt-crapcdb)   THEN
          DO:
              ASSIGN aux_cdcritic = 244
                     aux_dscritic = ""
                     aux_nrsequen = aux_nrsequen + 1.
            
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT aux_nrsequen, /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
            
              RETURN "NOK".
          END.

    RETURN "OK".

END PROCEDURE. /* pesquisa_cheque_descontado */

PROCEDURE busca_fechamento_descto:
    /************************************************************************
        Objetivo: Buscar informacoes do fechamento de cheques descontados da
                  conta (Opcao "F" da tela DESCTO)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibera AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-fechamento.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-fechamento.

    CREATE tt-fechamento.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         DO:
             ASSIGN aux_cdcritic = 651
                    aux_dscritic = ""
                    aux_nrsequen = aux_nrsequen + 1.
            
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
            
             RETURN "NOK".
         END.
    
    ASSIGN tt-fechamento.dschqcop = "Cheques " + 
                                    STRING(crapcop.nmrescop,"x(11)") + ":".

    RUN pi_calcula_datas_liberacao (INPUT  par_cdcooper,
                                    INPUT  par_dtlibera,
                                    OUTPUT aux_dtliber1,
                                    OUTPUT aux_dtliber2).

    IF   par_nrdconta > 0   THEN
         DO:
             IF   par_dtlibera <> ?   THEN
                  DO:
                      FOR EACH crapcdb WHERE 
                               crapcdb.cdcooper = par_cdcooper   AND
                               crapcdb.nrdconta = par_nrdconta   AND
                               crapcdb.dtlibbdc <> ?             AND
                               crapcdb.dtlibera > aux_dtliber1   AND
                               crapcdb.dtlibera < aux_dtliber2
                               NO-LOCK USE-INDEX crapcdb2:

                          RUN pi_grava_tt-fechamento_descto.

                      END. /*  For each ctapcdb */
                  END.  /* par_dtlibera <> ? */
             ELSE
                  DO:
                      FOR EACH crapcdb WHERE 
                               crapcdb.cdcooper = par_cdcooper   AND
                               crapcdb.nrdconta = par_nrdconta   AND
                               crapcdb.dtlibbdc <> ?             AND
                               crapcdb.dtlibera > par_dtmvtolt   
                               NO-LOCK USE-INDEX crapcdb2:

                          RUN pi_grava_tt-fechamento_descto.

                      END.  /* FOR EACH crapcdb */
                  END.
         END. /* IF   par_nrdconta > 0 */
    ELSE
         DO:
             IF   par_dtlibera <> ?   THEN
                  FOR EACH crapcdb WHERE crapcdb.cdcooper =  par_cdcooper  AND
                                         crapcdb.dtlibbdc <> ?             AND
                                         crapcdb.dtlibera > aux_dtliber1   AND
                                         crapcdb.dtlibera < aux_dtliber2
                                         NO-LOCK USE-INDEX crapcdb3:
                                  
                      RUN pi_grava_tt-fechamento_descto.

                  END.  /*  Fim do FOR EACH -- Leitura do cheque descontados */
             ELSE
                  FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper   AND
                                         crapcdb.dtlibera > par_dtmvtolt   AND
                                         crapcdb.dtlibbdc <> ?  
                                         NO-LOCK USE-INDEX crapcdb3:

                      RUN pi_grava_tt-fechamento_descto.

                  END.  /*  Fim do FOR EACH -- Leitura do cheque  */
         END.

    ASSIGN tt-fechamento.qtcheque = tt-fechamento.qtchqcop + 
                                    tt-fechamento.qtchqban + 
                                    tt-fechamento.qtchqdev
           tt-fechamento.vlcheque = tt-fechamento.vlchqcop + 
                                    tt-fechamento.vlchqban +
                                    tt-fechamento.vlchqdev
           tt-fechamento.qtcredit = tt-fechamento.qtcheque - 
                                    tt-fechamento.qtchqdev
           tt-fechamento.vlcredit = tt-fechamento.vlcheque - 
                                    tt-fechamento.vlchqdev.
    
    RETURN "OK".

END PROCEDURE. /* busca_fechamento_descto */

PROCEDURE busca_maiores_cheques_craptab:
    /************************************************************************
        Objetivo: Buscar informacoes dos maiores cheques na tabela craptab
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER par_vlchmatb AS DECIMAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER par_criticas AS INT         NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MAIORESCHQ"  AND
                       craptab.tpregist = 1             NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE craptab   THEN
         DO:
             par_criticas = 55.

             RETURN "NOK".

         END.

    ASSIGN par_vlchmatb = DECI(SUBSTR(craptab.dstextab,1,15)).

    RETURN "OK".

END PROCEDURE. /* busca_maiores_cheques_craptab */

PROCEDURE busca_lotes_descto:
    /************************************************************************
        Objetivo: Buscar informacoes para montagem do relatorio de lotes
                  (Opcao "R" da tela DESCTO)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_cdcritic AS INT         NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-relat-lotes.
    DEFINE OUTPUT PARAMETER TABLE FOR crawlot.
    
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-relat-lotes.
    EMPTY TEMP-TABLE crawlot.
    
    /* Busca valor dos cheques maiores */
    RUN busca_maiores_cheques_craptab (INPUT  par_cdcooper,
                                       INPUT  par_cdprogra,
                                       OUTPUT tab_vlchqmai,
                                       OUTPUT par_cdcritic,
                                       OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".
    /***********************************/

    CREATE tt-relat-lotes.
    ASSIGN tt-relat-lotes.dsdsaldo = IF par_cdagenci > 0 THEN 
                         "    ** DO PA " + STRING(par_cdagenci,"zz9") + " **"
                                   ELSE "      ** GERAL **"
           tt-relat-lotes.vlchmatb = tab_vlchqmai.                        

    FOR EACH crapbdc WHERE 
             crapbdc.cdcooper = par_cdcooper       AND
             crapbdc.dtlibbdc = par_dtmvtolt       NO-LOCK,
        EACH crapcdb WHERE 
             crapcdb.cdcooper = crapbdc.cdcooper   AND
             crapcdb.nrdconta = crapbdc.nrdconta   AND
             crapcdb.nrborder = crapbdc.nrborder   NO-LOCK 
        BREAK BY crapcdb.dtmvtolt
              BY crapcdb.cdagenci
              BY crapcdb.cdbccxlt
              BY crapcdb.nrdolote:

        IF   par_cdagenci      > 0              AND
             crapcdb.cdagenci <> par_cdagenci   THEN
             NEXT.

        FIND crawlot WHERE 
             crawlot.dtmvtolt = crapcdb.dtmvtolt   AND
             crawlot.cdagenci = crapcdb.cdagenci   AND
             crawlot.nrdolote = crapcdb.nrdolote   NO-ERROR.

        IF   NOT AVAILABLE crawlot   THEN
             DO:
                 CREATE crawlot.
                 ASSIGN crawlot.dtmvtolt = crapcdb.dtmvtolt
                        crawlot.cdagenci = crapcdb.cdagenci
                        crawlot.nrdconta = crapcdb.nrdconta
                        crawlot.nrdolote = crapcdb.nrdolote
                        crawlot.nrborder = crapcdb.nrborder.

                 FIND crapope WHERE 
                      crapope.cdcooper = crapcdb.cdcooper  AND
                      crapope.cdoperad = crapcdb.cdoperad  NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapope   THEN
                      ASSIGN crawlot.nmoperad = crapcdb.cdoperad.
                 ELSE
                      ASSIGN crawlot.nmoperad = ENTRY(1,crapope.nmoperad," ").
             END.

        ASSIGN crawlot.qtchqtot = crawlot.qtchqtot + 1
               crawlot.vlchqtot = crawlot.vlchqtot + crapcdb.vlcheque.

        IF   crapcdb.inchqcop = 1   THEN
             ASSIGN crawlot.vlchqcop = crawlot.vlchqcop + crapcdb.vlcheque
                    crawlot.qtchqcop = crawlot.qtchqcop + 1.
        ELSE
             DO:
                 IF   crapcdb.vlcheque >= tab_vlchqmai THEN
                      ASSIGN crawlot.vlchqmai = crawlot.vlchqmai + 
                                                        crapcdb.vlcheque
                             crawlot.qtchqmai = crawlot.qtchqmai + 1.
                 ELSE
                      ASSIGN crawlot.vlchqmen = crawlot.vlchqmen +
                                                        crapcdb.vlcheque
                             crawlot.qtchqmen = crawlot.qtchqmen + 1.
             END.
 
    END. /* Fim do FOR EACH  crapbdc --  Leitura dos lotes do dia  */

    /* Gravacao dos totais do relatorio */
    FOR EACH crawlot:
        ASSIGN 
          tt-relat-lotes.qtdlotes = tt-relat-lotes.qtdlotes + 1
          tt-relat-lotes.qtchqcop = tt-relat-lotes.qtchqcop + crawlot.qtchqcop
          tt-relat-lotes.qtchqmen = tt-relat-lotes.qtchqmen + crawlot.qtchqmen 
          tt-relat-lotes.qtchqmai = tt-relat-lotes.qtchqmai + crawlot.qtchqmai
          tt-relat-lotes.qtchqtot = tt-relat-lotes.qtchqtot + crawlot.qtchqtot
           
          tt-relat-lotes.vlchqcop = tt-relat-lotes.vlchqcop + crawlot.vlchqcop 
          tt-relat-lotes.vlchqmen = tt-relat-lotes.vlchqmen + crawlot.vlchqmen 
          tt-relat-lotes.vlchqmai = tt-relat-lotes.vlchqmai + crawlot.vlchqmai
          tt-relat-lotes.vlchqtot = tt-relat-lotes.vlchqtot + crawlot.vlchqtot.
    END.

    RETURN "OK".

END PROCEDURE. /* busca_lotes_descto */

PROCEDURE busca_saldo_descto:
    /************************************************************************
        Objetivo: Buscar saldo em desconto (Opcao "S" da tela DESCTO)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibera AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-saldo.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-saldo.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         DO:
             ASSIGN aux_cdcritic = 651
                    aux_dscritic = ""
                    aux_nrsequen = aux_nrsequen + 1.
            
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
            
             RETURN "NOK".
         END.

    RUN pi_calcula_datas_liberacao (INPUT  par_cdcooper,
                                    INPUT  par_dtlibera,
                                    OUTPUT aux_dtliber1,
                                    OUTPUT aux_dtliber2).

    CREATE tt-saldo.
    ASSIGN tt-saldo.dschqcop = "Cheques " + 
                               STRING(crapcop.nmrescop,"x(11)") + ":".
                               
    FOR EACH crapcdb WHERE crapcdb.cdcooper  = par_cdcooper  AND
                           crapcdb.dtlibbdc <> ?             AND
                           crapcdb.dtlibera  > aux_dtliber1  NO-LOCK:

        IF   crapcdb.dtdevolu <  par_dtlibera   OR
             crapcdb.dtlibbdc >  par_dtlibera   THEN
             NEXT.

        IF   crapcdb.dtlibera > par_dtlibera   AND
             crapcdb.dtdevolu = ?              THEN
             DO:
                 IF   crapcdb.inchqcop = 1   THEN
                      ASSIGN tt-saldo.qtchqcop = tt-saldo.qtchqcop + 1
                             tt-saldo.vlchqcop = tt-saldo.vlchqcop + 
                                                 crapcdb.vlcheque.
                 ELSE
                      ASSIGN tt-saldo.qtchqban = tt-saldo.qtchqban + 1
                             tt-saldo.vlchqban = tt-saldo.vlchqban + 
                                                 crapcdb.vlcheque.
             END.
     
        IF   crapcdb.dtdevolu <> ?   THEN 
             DO:
                 IF   crapcdb.dtdevolu = par_dtlibera   THEN
                      ASSIGN tt-saldo.qtchqdev = tt-saldo.qtchqdev - 1
                             tt-saldo.vlchqdev = tt-saldo.vlchqdev - 
                                                 crapcdb.vlcheque.
             END.
     
        IF   crapcdb.dtlibbdc = par_dtlibera   THEN
             DO:
                 ASSIGN tt-saldo.qtcheque = tt-saldo.qtcheque + 1
                        tt-saldo.vlcheque = tt-saldo.vlcheque + 
                                            crapcdb.vlcheque.
             
                 NEXT.
             END.
     
        ASSIGN tt-saldo.qtsldant = tt-saldo.qtsldant + 1
               tt-saldo.vlsldant = tt-saldo.vlsldant + crapcdb.vlcheque.
     
        IF  (crapcdb.dtlibera >= aux_dtliber1   AND
             crapcdb.dtlibera <= par_dtlibera)  AND
             crapcdb.dtdevolu = ?              THEN
             DO:
                 ASSIGN tt-saldo.qtlibera = tt-saldo.qtlibera - 1
                        tt-saldo.vllibera = tt-saldo.vllibera - 
                                            crapcdb.vlcheque.
             END.
     
     END.  /*  Fim do FOR EACH  */

     ASSIGN tt-saldo.qtcredit = tt-saldo.qtsldant + 
                                tt-saldo.qtlibera +
                                tt-saldo.qtcheque + 
                                tt-saldo.qtchqdev
     
            tt-saldo.vlcredit = tt-saldo.vlsldant + 
                                tt-saldo.vllibera +
                                tt-saldo.vlcheque + 
                                tt-saldo.vlchqdev.

     RETURN "OK".

END PROCEDURE. /* busca_saldo_descto */

PROCEDURE busca_todos_lancamentos_descto:
    /************************************************************************
        Objetivo: Buscar todos os lancaments (Opcao "T" da tela DESCTO)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbanchq AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcheque AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlcheque AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtoan AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-lancamentos.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-lancamentos.

    IF   par_cdbanchq = 0 AND par_nrcheque = 0 AND par_vlcheque = 0   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Pelo menos uma selecao deve ser informada".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    FOR EACH crapcdb WHERE crapcdb.cdcooper =  par_cdcooper   AND
                           crapcdb.nrdconta =  par_nrdconta   AND
                           crapcdb.dtlibbdc <> ?              NO-LOCK:
        
        IF   (par_cdbanchq <> 0 AND par_cdbanchq <> crapcdb.cdbanchq)   OR
             (par_nrcheque <> 0 AND par_nrcheque <> crapcdb.nrcheque)   OR
             (par_vlcheque <> 0 AND par_vlcheque <> crapcdb.vlcheque)   THEN
             NEXT.

        IF   crapcdb.dtlibera <= par_dtmvtoan  THEN
             NEXT.

        CREATE tt-lancamentos.
        ASSIGN tt-lancamentos.pesquisa = 
                              STRING(crapcdb.dtmvtolt,"99/99/9999") + "-" +
                              STRING(crapcdb.cdagenci,"999")        + "-" +
                              STRING(crapcdb.cdbccxlt,"999")        + "-" +
                              STRING(crapcdb.nrdolote,"999999")
                tt-lancamentos.dtlibera = crapcdb.dtlibera 
                tt-lancamentos.cdbanchq = crapcdb.cdbanchq
                tt-lancamentos.cdagechq = crapcdb.cdagechq 
                tt-lancamentos.nrctachq = crapcdb.nrctachq 
                tt-lancamentos.nrcheque = crapcdb.nrcheque 
                tt-lancamentos.vlcheque = crapcdb.vlcheque.
    END. /*  Fim do FOR EACH  */

    IF   NOT CAN-FIND(FIRST tt-lancamentos)   THEN
         DO:
             ASSIGN aux_cdcritic = 81
                    aux_dscritic = "".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE. /* busca_todos_lancamentos_descto */

PROCEDURE busca_cheques_descontados_conta:
    /************************************************************************
        Objetivo: Buscar cheques descontados por conta (Opcao "M" da tela 
                  DESCTO)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_inresgat AS LOGICAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcdb.

    EMPTY TEMP-TABLE tt-crapcdb.

    FOR EACH crapcdb WHERE crapcdb.cdcooper =  par_cdcooper   AND
                           crapcdb.nrdconta =  par_nrdconta   AND
                           crapcdb.dtlibera >  par_dtmvtolt   AND
                           crapcdb.dtlibbdc <> ?              NO-LOCK:
        
        IF   NOT par_inresgat        AND
             crapcdb.dtdevolu <> ?   THEN
             NEXT.

        CREATE tt-crapcdb.
        BUFFER-COPY crapcdb TO tt-crapcdb.
    
        ASSIGN tt-crapcdb.nrcherel = INT(STRING(crapcdb.nrcheque,"999999") +
                                         STRING(crapcdb.nrddigc3,"9")).
        
    END.  /*  Fim do FOR EACH  */

    RETURN "OK".

END PROCEDURE. /* busca_cheques_descontados_conta */

PROCEDURE busca_cheques_descontados_geral:
    /************************************************************************
        Objetivo: Buscar cheques descontados - geral (Opcao "M" da tela 
                  DESCTO)
      Parametros: par_cdctalis: Contas
                    - 1: Cooper; 2: Demais Associados; 3: Total Geral
                  par_vlsupinf: 
                    - 1: Qualquer Valor; 2: Inferiores; 3: Superiores
                  par_inchqcop:
                    - 1: Qualquer Cheque; 2: Outros Bancos; 3: Cooperativa
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtiniper AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtfimper AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdctalis AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlsupinf AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_inchqcop AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcdb.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER par_dsrefere AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER par_cdcritic AS INT         NO-UNDO.

    EMPTY TEMP-TABLE tt-crapcdb.

    RUN busca_maiores_cheques_craptab (INPUT  par_cdcooper,
                                       INPUT  par_cdprogra,
                                       OUTPUT aux_vlchqmai,
                                       OUTPUT par_cdcritic,
                                       OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".

    IF   par_cdctalis < 1   OR   par_cdctalis > 3   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Valor invalido para Tipo de Contas".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    IF   par_vlsupinf < 1   OR   par_vlsupinf > 3   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Valor invalido para Valor de Cheque".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    IF   par_inchqcop < 1   OR   par_inchqcop > 3   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Valor invalido para Tipo de Cheque".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    CASE par_cdctalis:
        WHEN 1 THEN ASSIGN par_dsrefere = "SOMENTE COOPER, ".
        WHEN 2 THEN ASSIGN par_dsrefere = "SOMENTE ASSOCIADOS, ".
        WHEN 3 THEN ASSIGN par_dsrefere = "TODAS AS CONTAS, ".
    END CASE.

    CASE par_vlsupinf:
        WHEN 1 THEN ASSIGN par_dsrefere = par_dsrefere + "TODOS OS CHEQUES".
        WHEN 2 THEN ASSIGN par_dsrefere = par_dsrefere + "CHEQUES INFERIORES".
        WHEN 3 THEN ASSIGN par_dsrefere = par_dsrefere + "CHEQUES SUPERIORES".
    END CASE.

    CASE par_inchqcop:
        WHEN 1 THEN ASSIGN par_dsrefere = par_dsrefere + ".".
        WHEN 2 THEN ASSIGN par_dsrefere = par_dsrefere + " DE OUTROS BANCOS.".
        WHEN 3 THEN ASSIGN par_dsrefere = par_dsrefere + " DA COOPERATIVA.".
    END CASE.

    
    FOR EACH crapcdb USE-INDEX crapcdb6
             WHERE  crapcdb.cdcooper =  par_cdcooper   AND
                           (crapcdb.dtlibera >= par_dtiniper   AND 
                            crapcdb.dtlibera <= par_dtfimper)  AND 
                            crapcdb.dtlibbdc <> ?              AND   
                            crapcdb.dtdevolu = ?               NO-LOCK:
        
        IF   par_cdctalis = 1 AND crapcdb.nrdconta <> 85448        THEN NEXT.
        IF   par_cdctalis = 2 AND crapcdb.nrdconta  = 85448        THEN NEXT.
        
        IF   par_vlsupinf = 2 AND crapcdb.vlcheque >= aux_vlchqmai THEN NEXT.
        IF   par_vlsupinf = 3 AND crapcdb.vlcheque  < aux_vlchqmai THEN NEXT.
    
        IF   par_inchqcop = 2 AND crapcdb.inchqcop <> 0            THEN NEXT.
        IF   par_inchqcop = 3 AND crapcdb.inchqcop  = 0            THEN NEXT.

        
        CREATE tt-crapcdb.
        BUFFER-COPY crapcdb TO tt-crapcdb.
        
    END.  /*  Fim do FOR EACH -- crapcdb  */                       
    
    RETURN "OK".

END PROCEDURE. /* busca_cheques_descontados_geral */

/********************************* CUSTOD **********************************/
PROCEDURE consulta_cheques_custodia:
    /************************************************************************
        Objetivo: Consultar cheques em custodia por conta (Opcao "C" da tela
                  CUSTOD)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtoan AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtcusini AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtcusfim AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpcheque AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdolote AS INTEGER     NO-UNDO.    
    DEFINE INPUT  PARAMETER par_dtlibini AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibfim AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdocmc7 AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nriniseq AS INTE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrregist AS INTE        NO-UNDO.

    DEFINE OUTPUT PARAMETER par_qtregist AS INTE        NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcst.

    DEF VAR aux_query AS CHAR                           NO-UNDO.
    DEF VAR aux_nrregist AS INTEGER                     NO-UNDO.
    DEF QUERY q_crapcst FOR crapcst.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcst.

    IF  (par_dtlibini <> ?  AND par_dtlibfim  = ?) OR 
        (par_dtlibini  = ?  AND par_dtlibfim <> ?) THEN
        DO:

             ASSIGN aux_cdcritic = 0
                    aux_dscritic = IF par_dtlibini = ? THEN
                                      "Informe a data inicial."
                                   ELSE
                                      "Informe a data final."
                    aux_nrsequen = aux_nrsequen + 1.
           
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
            
             RETURN "NOK".

        END.

    ASSIGN aux_query = "FOR EACH crapcst WHERE crapcst.cdcooper = " + STRING(par_cdcooper).
    

    IF par_nrdconta > 0 THEN
      ASSIGN aux_query = aux_query + " AND " +
                         "crapcst.nrdconta = " + STRING(par_nrdconta).                         
                       
    IF par_dtlibini = ? THEN
      ASSIGN aux_query = aux_query + " AND " +
                         "crapcst.dtlibera > " + STRING(par_dtmvtoan).
    ELSE
      ASSIGN aux_query = aux_query + " AND " +
                         "crapcst.dtlibera >= " + STRING(par_dtlibini) + " AND " + 
                         "crapcst.dtlibera <= " + STRING(par_dtlibfim).
                         
    IF par_cdagenci <> ? AND par_cdagenci <> 0 THEN
      ASSIGN aux_query = aux_query + " AND " +
                       "crapcst.cdagenci = " + STRING(par_cdagenci).
                       
    IF par_nrdolote <> ? AND par_nrdolote <> 0 THEN
      ASSIGN aux_query = aux_query + " AND " +
                       "crapcst.nrdolote = " + STRING(par_nrdolote).                           
                       
    IF par_dtcusini <> ? THEN
      ASSIGN aux_query = aux_query + " AND " +
                       "crapcst.dtmvtolt >= " + STRING(par_dtcusini).

    IF par_dtcusfim <> ? THEN
      ASSIGN aux_query = aux_query + " AND " +
                       "crapcst.dtmvtolt <= " + STRING(par_dtcusfim).

    IF par_dsdocmc7 <> ? AND par_dsdocmc7 <> "" THEN
      ASSIGN aux_query = aux_query + " AND " +
                       "crapcst.dsdocmc7 = """ + 
                       STRING(par_dsdocmc7, "<99999999<9999999999>999999999999:") + """".
                           
    QUERY q_crapcst:QUERY-PREPARE(aux_query).
    QUERY q_crapcst:QUERY-OPEN().

    GET FIRST q_crapcst NO-LOCK.
    
    REPEAT:
    
      IF QUERY q_crapcst:QUERY-OFF-END THEN LEAVE.

        IF   par_tpcheque = 1 THEN
             DO:
                 IF   crapcst.dtdevolu <> ?  AND
                      crapcst.insitchq  = 1  THEN
                      DO:
                          CREATE tt-crapcst.
                          BUFFER-COPY crapcst TO tt-crapcst.
                          ASSIGN tt-crapcst.tpdevolu = "Resgat".
                      END.
                 ELSE
              DO:                          
                QUERY q_crapcst:GET-NEXT().
                      NEXT.
             END.
         END.
      ELSE IF par_tpcheque = 2 THEN
                   DO:
           IF crapcst.dtdevolu  = ? AND
              crapcst.insitchq <> 1 AND 
              crapcst.nrborder  > 0 THEN
                           DO:
                               CREATE tt-crapcst.
                               BUFFER-COPY crapcst TO tt-crapcst.
                               ASSIGN tt-crapcst.tpdevolu = "Descon".
                           END.
                       ELSE
              DO:                          
                QUERY q_crapcst:GET-NEXT().
                           NEXT.
                   END.
         END.
      ELSE IF par_tpcheque = 3 THEN
                   DO:
                       IF crapcst.dtdevolu = ? THEN
                           DO:
                               CREATE tt-crapcst.
                               BUFFER-COPY crapcst TO tt-crapcst.
                               ASSIGN tt-crapcst.tpdevolu = "Custod".
                           END.
                       ELSE
              DO:                          
                QUERY q_crapcst:GET-NEXT().
                           NEXT.
                   END.
         END.
      ELSE IF par_tpcheque = 4 THEN
                   DO:
                      CREATE tt-crapcst.
                      BUFFER-COPY crapcst TO tt-crapcst.
                  
                      IF   crapcst.dtdevolu <> ?   THEN                   
                           DO:                                            
                               IF crapcst.insitchq = 1 THEN                   
                                    ASSIGN tt-crapcst.tpdevolu = "Resgat".
                               ELSE                                       
                                    ASSIGN tt-crapcst.tpdevolu = "Descon".
                           END.                                           
                      ELSE                                                
                           ASSIGN tt-crapcst.tpdevolu = "Custod".
                   END.

      QUERY q_crapcst:GET-NEXT().

    END.  /*  Fim da query crapcst */
    
    QUERY q_crapcst:QUERY-CLOSE().

    ASSIGN aux_nrregist = par_nrregist.
    
    FOR EACH tt-crapcst:
    
      ASSIGN par_qtregist = par_qtregist + 1.

      IF  par_qtregist < par_nriniseq                    OR
          par_qtregist > (par_nriniseq + par_nrregist)  THEN
          DO:
            DELETE tt-crapcst.
            NEXT.
          END.
          
      IF aux_nrregist <= 0 THEN
         DO:
           DELETE tt-crapcst.
           NEXT.        
         END.
        
      ASSIGN aux_nrregist = aux_nrregist - 1.                   
      
    END.

    IF   NOT CAN-FIND(FIRST tt-crapcst)   THEN
         DO:
             ASSIGN aux_cdcritic = 81
                    aux_dscritic = ""
                    aux_nrsequen = aux_nrsequen + 1.
           
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
            
             RETURN "NOK".
         END.
    
    RETURN "OK".

END PROCEDURE. /* consulta_cheques_custodia */

PROCEDURE pesquisa_cheque_custodia:
    /************************************************************************
        Objetivo: Consultar informacoes de um cheque que esteja em custodia
                  (Opcao "P" da tela CUSTOD)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbanchq AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagechq AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctachq AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcheque AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcst.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcst.

    ASSIGN aux_dssitchq = "NAO PROCESSADO,RESGATADO,PROCESSADO," +
                          "COM PROBLEMAS,PROCESSADO,DESCONTADO".

    FOR EACH crapcst WHERE 
             crapcst.cdcooper = par_cdcooper  AND
             crapcst.nrdconta = par_nrdconta  AND
             crapcst.cdbanchq = par_cdbanchq  AND
             crapcst.cdagechq = par_cdagechq  AND
             crapcst.nrctachq = par_nrctachq  AND
             crapcst.nrcheque = par_nrcheque  NO-LOCK:

        CREATE tt-crapcst.
        BUFFER-COPY crapcst TO tt-crapcst.

        ASSIGN tt-crapcst.dspesqui = STRING(crapcst.dtmvtolt,"99/99/9999")
                                     + "-" +
                                     STRING(crapcst.cdagenci,"999") + "-" +
                                     STRING(crapcst.cdbccxlt,"999") + "-" +
                                     STRING(crapcst.nrdolote,"999999") + 
                                     "-" +
                                     STRING(crapcst.nrseqdig,"99999")
               tt-crapcst.dssitchq = ENTRY(crapcst.insitchq + 1,
                                     aux_dssitchq).
       
        IF   crapcst.insitchq = 1   OR
             crapcst.insitchq = 5   THEN
             DO:
                 IF   crapcst.insitchq = 1   THEN
                      tt-crapcst.dsobserv = "RESGATADO EM " +
                                            STRING(crapcst.dtdevolu,
                                                   "99/99/9999").
                 ELSE
                      tt-crapcst.dsobserv = "DESCONTADO EM " +
                                            STRING(crapcst.dtdevolu,
                                                   "99/99/9999").
                     
                 FIND crapope WHERE
                      crapope.cdcooper = crapcst.cdcooper     AND
                      crapope.cdoperad = crapcst.cdopedev
                      NO-LOCK NO-ERROR.
                     
                 IF   NOT AVAILABLE crapope   THEN
                      ASSIGN tt-crapcst.nmopedev = "POR " + crapcst.cdopedev +
                                                   " - NAO CADASTRADO".
                 ELSE
                      ASSIGN tt-crapcst.nmopedev = "POR " + crapope.nmoperad.
             END.
        ELSE                            
             ASSIGN tt-crapcst.dsobserv = ""
                    tt-crapcst.nmopedev = "".
        
    END.  /*  Fim do FOR EACH  */
               
    IF   NOT CAN-FIND(FIRST tt-crapcst)   THEN
          DO:
              ASSIGN aux_cdcritic = 244
                     aux_dscritic = ""
                     aux_nrsequen = aux_nrsequen + 1.
            
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT aux_nrsequen, /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
            
              RETURN "NOK".
          END.

    RETURN "OK".

END PROCEDURE. /* pesquisa_cheque_custodia */

PROCEDURE busca_fechamento_custodia:
    /************************************************************************
        Objetivo: Buscar informacoes do fechamento de cheques em custodia da
                  conta (Opcao "F" da tela CUSTOD)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibera AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-fechamento.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-fechamento.

    CREATE tt-fechamento.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         DO:
             ASSIGN aux_cdcritic = 651
                    aux_dscritic = ""
                    aux_nrsequen = aux_nrsequen + 1.
            
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
            
             RETURN "NOK".
         END.
    
    ASSIGN tt-fechamento.dschqcop = "Cheques " + 
                                    STRING(crapcop.nmrescop,"x(11)") + ":".

    RUN pi_calcula_datas_liberacao (INPUT  par_cdcooper,
                                    INPUT  par_dtlibera,
                                    OUTPUT aux_dtliber1,
                                    OUTPUT aux_dtliber2).

    IF   par_nrdconta > 0   THEN
         DO:
             IF   par_dtlibera <> ?   THEN
                  DO:
                      FOR EACH crapcst WHERE 
                               crapcst.cdcooper = par_cdcooper   AND
                               crapcst.nrdconta = par_nrdconta   AND
                               crapcst.dtlibera > aux_dtliber1   AND
                               crapcst.dtlibera < aux_dtliber2
                               NO-LOCK USE-INDEX crapcst2:

                          RUN pi_grava_tt-fechamento_custodia.
                          
                      END.  /*  Fim do FOR EACH crapcst -- Cheque custodia  */
                  END. /* IF   par_dtlibera <> ? */
             ELSE
                  DO:
                      FOR EACH crapcst WHERE 
                               crapcst.cdcooper = par_cdcooper   AND
                               crapcst.nrdconta = par_nrdconta   AND
                               crapcst.dtlibera > par_dtmvtolt
                               NO-LOCK USE-INDEX crapcst2:
                      
                          RUN pi_grava_tt-fechamento_custodia.

                      END.  /*  Fim do FOR EACH crapcst -- Cheque custodia  */
                  END. /* ELSE DO: */
         END. /* IF   par_nrdconta > 0 */
    ELSE
         DO:
             IF   par_dtlibera <> ?   THEN
                  DO:
                  
                      FOR EACH crapcst WHERE 
                               crapcst.cdcooper  = par_cdcooper  AND
                               crapcst.nrdconta <> 85448         AND
                               crapcst.dtlibera > aux_dtliber1   AND
                               crapcst.dtlibera < aux_dtliber2
                               NO-LOCK USE-INDEX crapcst3:
                                      
                          RUN pi_grava_tt-fechamento_custodia.
                      
                      END.  /*  Fim do FOR EACH crapcst -- cheque custodia  */
                  END. /* IF   tel_dtlibera <> ? */
             ELSE
                  DO:
                      FOR EACH crapcst WHERE 
                               crapcst.cdcooper = par_cdcooper AND
                               crapcst.nrdconta <> 85448       AND
                               crapcst.dtlibera > par_dtmvtolt
                               NO-LOCK USE-INDEX crapcst3:
                          
                          RUN pi_grava_tt-fechamento_custodia.

                      END.  /*  Fim do FOR EACH crapcst -- Cheque custodia  */
                  END. /* ELSE DO: (IF   tel_dtlibera <> ? ) */
         END. /* ELSE DO: (IF   par_nrdconta > 0 */

    ASSIGN tt-fechamento.qtcheque = tt-fechamento.qtchqcop + 
                                    tt-fechamento.qtchqban + 
                                    tt-fechamento.qtchqdev +
                                    tt-fechamento.qtchqdsc
           tt-fechamento.vlcheque = tt-fechamento.vlchqcop + 
                                    tt-fechamento.vlchqban +
                                    tt-fechamento.vlchqdev +
                                    tt-fechamento.vlchqdsc
           tt-fechamento.qtcredit = tt-fechamento.qtcheque - 
                                    tt-fechamento.qtchqdev
           tt-fechamento.vlcredit = tt-fechamento.vlcheque - 
                                    tt-fechamento.vlchqdev.
    
    RETURN "OK".

END PROCEDURE. /* busca_fechamento_custodia */

PROCEDURE busca_lotes_custodia:
    /************************************************************************
        Objetivo  : Buscar informacoes para montagem do relatorio de lotes de
                    custodia (Opcao "F" da tela CUSTOD - Conta 85448)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibera AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-relat-lotes.
    DEFINE OUTPUT PARAMETER TABLE FOR crawlot.

    EMPTY TEMP-TABLE tt-relat-lotes.
    EMPTY TEMP-TABLE crawlot.

    RUN pi_calcula_datas_liberacao (INPUT  par_cdcooper,
                                    INPUT  par_dtlibera,
                                    OUTPUT aux_dtliber1,
                                    OUTPUT aux_dtliber2).

    CREATE tt-relat-lotes.

    FOR EACH craplot WHERE 
             craplot.cdcooper = par_cdcooper         AND
             craplot.dtmvtopg > (aux_dtliber1)       AND
             craplot.dtmvtopg < (par_dtlibera + 1)   AND
             craplot.tplotmov = 19                   NO-LOCK
             BREAK BY craplot.dtmvtolt
                      BY craplot.cdagenci
                         BY craplot.nrdolote:

        FIND FIRST crapcst WHERE crapcst.cdcooper = craplot.cdcooper   AND
                                 crapcst.dtmvtolt = craplot.dtmvtolt   AND
                                 crapcst.cdagenci = craplot.cdagenci   AND
                                 crapcst.cdbccxlt = craplot.cdbccxlt   AND
                                 crapcst.nrdolote = craplot.nrdolote   
                                 USE-INDEX crapcst1 NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE crapcst      THEN NEXT.
        IF   crapcst.nrdconta <> 85448  THEN NEXT.
        IF   crapcst.insitchq  = 5      THEN NEXT.

        CREATE crawlot.
        ASSIGN crawlot.dtmvtolt = craplot.dtmvtolt
               crawlot.cdagenci = craplot.cdagenci
               crawlot.cdbccxlt = craplot.cdbccxlt
               crawlot.nrdolote = craplot.nrdolote.
         
        FIND crapope WHERE 
             crapope.cdcooper = craplot.cdcooper   AND
             crapope.cdoperad = craplot.cdoperad   NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE crapope   THEN
             ASSIGN crawlot.nmoperad = craplot.cdoperad.
        ELSE
             ASSIGN crawlot.nmoperad = ENTRY(1,crapope.nmoperad," ").
    
        FOR EACH crapcst WHERE crapcst.cdcooper = par_cdcooper       AND
                               crapcst.dtmvtolt = craplot.dtmvtolt   AND
                               crapcst.cdagenci = craplot.cdagenci   AND
                               crapcst.cdbccxlt = craplot.cdbccxlt   AND
                               crapcst.nrdolote = craplot.nrdolote   AND
                               crapcst.dtdevolu = ?
                               USE-INDEX crapcst1 NO-LOCK:
         
            ASSIGN crawlot.qtcompln = crawlot.qtcompln + 1
                   crawlot.vlcompdb = crawlot.vlcompdb + crapcst.vlcheque.
        
        END.  /*  Fim do FOR EACH -- crapcst  */
        
        ASSIGN tt-relat-lotes.qtdlotes = tt-relat-lotes.qtdlotes  + 1
               tt-relat-lotes.qtchqtot = tt-relat-lotes.qtchqtot + 
                                         crawlot.qtcompln
               tt-relat-lotes.vlchqtot = tt-relat-lotes.vlchqtot + 
                                         crawlot.vlcompdb.

    END.  /*  Fim do FOR EACH  --  Leitura dos lotes do dia  */    
    
    RETURN "OK".

END PROCEDURE. /* busca_lotes_custodia */

PROCEDURE busca_informacoes_relatorio_custodia:
    /************************************************************************
        Objetivo  : Buscar informacoes para montagem do relatorio de cheques em
                    custodia (Opcao "R" da tela CUSTOD)
        Observacao: Indicador de Relatorio (Campo indrelat):
                    1) Informacoes da Cooper
                    2) Informacoes dos demais associados
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtini AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtfim AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_cdcritic AS INT         NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-relat-custod.
    DEFINE OUTPUT PARAMETER TABLE FOR crawlot.
    DEFINE OUTPUT PARAMETER TABLE FOR crabcst.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-relat-custod.
    EMPTY TEMP-TABLE crawlot.
    EMPTY TEMP-TABLE crabcst.
    
    /* Busca valor dos cheques maiores */
    RUN busca_maiores_cheques_craptab (INPUT  par_cdcooper,
                                       INPUT  par_cdprogra,
                                       OUTPUT tab_vlchqmai,
                                       OUTPUT par_cdcritic,
                                       OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".
    /***********************************/     

    DO aux_contador = 1 TO 2:

        CREATE tt-relat-custod.
        ASSIGN tt-relat-custod.indrelat = aux_contador
               tt-relat-custod.dsdsaldo = IF aux_contador = 1 THEN 
                                             "     ** COOPER **"
                                          ELSE
                                             "** DEMAIS ASSOCIADOS ** ".
                                             
        FOR EACH craplot WHERE 
                 craplot.cdcooper  = par_cdcooper   AND
                 craplot.dtmvtolt >= par_dtmvtini   AND
                 craplot.dtmvtolt <= par_dtmvtfim   AND
                 craplot.tplotmov = 19              NO-LOCK
                 BY craplot.cdagenci
                 BY craplot.cdbccxlt
                 BY craplot.nrdolote:
                 
           ASSIGN lot_qtchqcop = 0                
                  lot_vlchqcop = 0 
                  lot_qtchqmen = 0 
                  lot_vlchqmen = 0 
                  lot_qtchqmai = 0
                  lot_vlchqmai = 0
                  aux_nrdconta = 0.

           FOR EACH crapcst WHERE 
                    crapcst.cdcooper = craplot.cdcooper   AND
                    crapcst.dtmvtolt = craplot.dtmvtolt   AND
                    crapcst.cdagenci = craplot.cdagenci   AND
                    crapcst.cdbccxlt = craplot.cdbccxlt   AND
                    crapcst.nrdolote = craplot.nrdolote   NO-LOCK:

               IF   par_cdagenci > 0   THEN
                    IF   crapcst.cdagenci <> par_cdagenci   THEN
                         NEXT.

               IF   aux_contador = 1   THEN     /*  Saldo COOPER  */
                    DO:
                        IF   crapcst.nrdconta <> 85448   THEN
                             NEXT.
                    END.
               ELSE
               IF   aux_contador = 2   THEN     /*  Saldo DEMAIS ASSOC.  */
                    DO:
                        IF   crapcst.nrdconta = 85448   THEN
                             NEXT.
                    END.

               ASSIGN aux_nrdconta = crapcst.nrdconta.

               IF   crapcst.inchqcop = 1 THEN
                    ASSIGN lot_vlchqcop = lot_vlchqcop + crapcst.vlcheque
                           lot_qtchqcop = lot_qtchqcop + 1.
               ELSE 
                    DO:
                        IF   crapcst.vlcheque >= tab_vlchqmai THEN
                             ASSIGN lot_vlchqmai = lot_vlchqmai + 
                                                   crapcst.vlcheque
                                    lot_qtchqmai = lot_qtchqmai + 1.
                        ELSE
                             ASSIGN lot_vlchqmen = lot_vlchqmen + 
                                                   crapcst.vlcheque
                                    lot_qtchqmen = lot_qtchqmen + 1.
                    END.
                
               CREATE crabcst.
               ASSIGN crabcst.indrelat = aux_contador
                      crabcst.cdagenci = crapcst.cdagenci 
                      crabcst.nrdconta = crapcst.nrdconta
                      crabcst.nrdolote = crapcst.nrdolote
                      crabcst.cdbccxlt = crapcst.cdbccxlt
                      crabcst.dtlibera = crapcst.dtlibera
                      crabcst.cdcmpchq = crapcst.cdcmpchq
                      crabcst.cdbanchq = crapcst.cdbanchq
                      crabcst.cdagechq = crapcst.cdagechq
                      crabcst.nrctachq = crapcst.nrctachq
                      crabcst.nrcheque = crapcst.nrcheque 
                      crabcst.vlcheque = crapcst.vlcheque
                      crabcst.dsdocmc7 = crapcst.dsdocmc7.
               VALIDATE crabcst.

           END.  /*  Fim do FOR EACH -- Leitura da custodia  */
           
           IF   lot_qtchqcop = 0   AND 
                lot_qtchqmen = 0   AND
                lot_qtchqmai = 0   THEN
                NEXT.
                
           FIND crapope WHERE 
                crapope.cdcooper = par_cdcooper       AND
                crapope.cdoperad = craplot.cdoperad   NO-LOCK NO-ERROR.
           IF   NOT AVAILABLE crapope   THEN
                lot_nmoperad = craplot.cdoperad.
           ELSE
                lot_nmoperad = ENTRY(1,crapope.nmoperad," ").
                
           CREATE crawlot.
           ASSIGN crawlot.indrelat = aux_contador
                  crawlot.cdagenci = craplot.cdagenci
                  crawlot.nrdconta = aux_nrdconta
                  crawlot.nrdolote = craplot.nrdolote
                  crawlot.qtchqcop = lot_qtchqcop
                  crawlot.qtchqmen = lot_qtchqmen
                  crawlot.qtchqmai = lot_qtchqmai
                  crawlot.qtchqtot = craplot.qtcompln
                  crawlot.vlchqcop = lot_vlchqcop
                  crawlot.vlchqmen = lot_vlchqmen
                  crawlot.vlchqmai = lot_vlchqmai
                  crawlot.vlchqtot = craplot.vlcompdb
                  crawlot.dtlibera = craplot.dtmvtopg
                  crawlot.nmoperad = lot_nmoperad.

           ASSIGN tt-relat-custod.qtdlotes = tt-relat-custod.qtdlotes + 1
                  tt-relat-custod.qtchqcop = tt-relat-custod.qtchqcop + 
                                             crawlot.qtchqcop
                  tt-relat-custod.qtchqmen = tt-relat-custod.qtchqmen + 
                                             crawlot.qtchqmen
                  tt-relat-custod.qtchqmai = tt-relat-custod.qtchqmai + 
                                             crawlot.qtchqmai
                  tt-relat-custod.qtchqtot = tt-relat-custod.qtchqtot + 
                                             crawlot.qtchqtot
                  tt-relat-custod.vlchqcop = tt-relat-custod.vlchqcop + 
                                             crawlot.vlchqcop 
                  tt-relat-custod.vlchqmen = tt-relat-custod.vlchqmen + 
                                             crawlot.vlchqmen 
                  tt-relat-custod.vlchqmai = tt-relat-custod.vlchqmai + 
                                             crawlot.vlchqmai
                  tt-relat-custod.vlchqtot = tt-relat-custod.vlchqtot + 
                                             crawlot.vlchqtot.
   
        END.  /*  Fim do FOR EACH  --  Leitura dos lotes do dia  */    

    END.  /*  Fim do DO .. TO  */

    RETURN "OK".

END PROCEDURE. /* busca_informacoes_relatorio_custodia */

PROCEDURE busca_saldo_custodia:
    /************************************************************************
        Objetivo: Buscar saldo em custodia (Opcao "S" da tela CUSTOD)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdsaldo AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibera AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-saldo.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-saldo.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         DO:
             ASSIGN aux_cdcritic = 651
                    aux_dscritic = ""
                    aux_nrsequen = aux_nrsequen + 1.
            
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
            
             RETURN "NOK".
         END.
    
    RUN pi_calcula_datas_liberacao (INPUT  par_cdcooper,
                                    INPUT  par_dtlibera,
                                    OUTPUT aux_dtliber1,
                                    OUTPUT aux_dtliber2).

    CREATE tt-saldo.
    ASSIGN tt-saldo.dschqcop = "Cheques " + 
                               STRING(crapcop.nmrescop,"x(11)") + ":".

    IF   par_tpdsaldo = 3  /* Conta/dv */   THEN
         DO:
             FOR EACH crapcst WHERE 
                      crapcst.cdcooper  = par_cdcooper  AND
                      crapcst.nrdconta  = par_nrdconta  AND
                      crapcst.dtlibera >= par_dtlibera  NO-LOCK
                      USE-INDEX crapcst2:

                  RUN pi_grava_tt-saldo_custodia (INPUT par_tpdsaldo,
                                                  INPUT par_nrdconta,
                                                  INPUT par_dtlibera).
            
             END.
         END. /* IF   aux_tpdsaldo = 3 */
    ELSE
         DO:
             FOR EACH crapcst WHERE 
                      crapcst.cdcooper  = par_cdcooper  AND
                      crapcst.dtlibera >= par_dtlibera  NO-LOCK
                      USE-INDEX crapcst3:

                  RUN pi_grava_tt-saldo_custodia (INPUT par_tpdsaldo,
                                                  INPUT par_nrdconta,
                                                  INPUT par_dtlibera).
            
             END.
         END.

    ASSIGN tt-saldo.qtcredit = tt-saldo.qtsldant + 
                               tt-saldo.qtlibera +
                               tt-saldo.qtcheque + 
                               tt-saldo.qtchqdev +
                               tt-saldo.qtchqdsc
    
           tt-saldo.vlcredit = tt-saldo.vlsldant + 
                               tt-saldo.vllibera +
                               tt-saldo.vlcheque + 
                               tt-saldo.vlchqdev +
                               tt-saldo.vlchqdsc.

    RETURN "OK".

END PROCEDURE. /* busca_saldo_custodia */

PROCEDURE busca_todos_lancamentos_custodia:
    /************************************************************************
        Objetivo: Buscar todos os lancaments (Opcao "T" da tela CUSTOD)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbanchq AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcheque AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlcheque AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtoan AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-lancamentos.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-lancamentos.

    IF   par_cdbanchq = 0 AND par_nrcheque = 0 AND par_vlcheque = 0   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Pelo menos uma selecao deve ser informada".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    FOR EACH crapcst WHERE crapcst.cdcooper = par_cdcooper  AND
                           crapcst.nrdconta = par_nrdconta  NO-LOCK:

        IF   (par_cdbanchq <> 0  AND par_cdbanchq <> crapcst.cdbanchq)   OR   
             (par_nrcheque <> 0  AND par_nrcheque <> crapcst.nrcheque)   OR
             (par_vlcheque <> 0  AND par_vlcheque <> crapcst.vlcheque)   THEN
              NEXT. 
        
        IF   crapcst.dtlibera <= par_dtmvtoan  THEN
             NEXT.

        CREATE tt-lancamentos.
        ASSIGN tt-lancamentos.pesquisa = 
                              STRING(crapcst.dtmvtolt,"99/99/9999") + "-" +
                              STRING(crapcst.cdagenci,"999")        + "-" +
                              STRING(crapcst.cdbccxlt,"999")        + "-" +
                              STRING(crapcst.nrdolote,"999999")
               tt-lancamentos.dtlibera = crapcst.dtlibera 
               tt-lancamentos.cdbanchq = crapcst.cdbanchq
               tt-lancamentos.cdagechq = crapcst.cdagechq 
               tt-lancamentos.nrctachq = crapcst.nrctachq 
               tt-lancamentos.nrcheque = crapcst.nrcheque 
               tt-lancamentos.vlcheque = crapcst.vlcheque.
    END.  /*  Fim do FOR EACH crapcst */

    IF   NOT CAN-FIND(FIRST tt-lancamentos)   THEN
         DO:
             ASSIGN aux_cdcritic = 81
                    aux_dscritic = "".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE. /* busca_todos_lancamentos_custodia */

PROCEDURE busca_cheques_em_custodia:
    /************************************************************************
        Objetivo: Buscar cheques em custodia (Opcao "M" da tela CUSTOD)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_inresgat AS LOGICAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibini AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibfim AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcst.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
        
    EMPTY TEMP-TABLE tt-crapcst.

    IF  (par_dtlibini <> ?  AND par_dtlibfim  = ?) OR 
        (par_dtlibini  = ?  AND par_dtlibfim <> ?) THEN
        DO:

             ASSIGN aux_cdcritic = 0
                    aux_dscritic = IF par_dtlibini = ? THEN
                                      "Informe a data inicial."
                                   ELSE
                                      "Informe a data final."
                    aux_nrsequen = aux_nrsequen + 1.
           
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT 0,
                            INPUT 0,
                            INPUT aux_nrsequen, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
            
             RETURN "NOK".

        END.

    IF  par_dtlibini = ? THEN
        DO:

            FOR EACH crapcst WHERE crapcst.cdcooper =  par_cdcooper   AND
                                   crapcst.nrdconta =  par_nrdconta   AND
                                   crapcst.dtlibera >  par_dtmvtolt   AND
                                   crapcst.insitchq <> 2              NO-LOCK:
        
                IF   NOT par_inresgat   AND crapcst.dtdevolu <> ?   THEN NEXT.
        
                CREATE tt-crapcst.
                BUFFER-COPY crapcst TO tt-crapcst.
            
                ASSIGN tt-crapcst.nrcherel = 
                                  INTEGER(STRING(crapcst.nrcheque,"999999") + 
                                          STRING(crapcst.nrddigc3,"9")).
                     
            END.  /*  Fim do FOR EACH  */

        END.
    ELSE
        DO:

            FOR EACH crapcst WHERE crapcst.cdcooper =  par_cdcooper   AND
                                   crapcst.nrdconta =  par_nrdconta   AND
                                   crapcst.dtlibera >= par_dtlibini   AND
                                   crapcst.dtlibera <= par_dtlibfim   AND
                                   crapcst.insitchq <> 2              NO-LOCK:
    
                IF   NOT par_inresgat   AND crapcst.dtdevolu <> ?   THEN NEXT.
    
                CREATE tt-crapcst.
                BUFFER-COPY crapcst TO tt-crapcst.
    
                ASSIGN tt-crapcst.nrcherel = 
                                  INTEGER(STRING(crapcst.nrcheque,"999999") + 
                                          STRING(crapcst.nrddigc3,"9")).
    
            END.  /*  Fim do FOR EACH  */

        END.

    RETURN "OK".

END PROCEDURE. /* busca_cheques_em_custodia */

PROCEDURE conferencia_cheques_em_custodia:
    /************************************************************************
        Objetivo: Buscar informacoes dos cheques em custodia
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtiniper AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtfimper AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_containi AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_contafim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcst.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcst.

    FOR EACH crapcst WHERE crapcst.cdcooper =  par_cdcooper   AND
                           crapcst.dtlibera >= par_dtiniper   AND 
                           crapcst.dtlibera <= par_dtfimper   AND 
                           crapcst.dtdevolu  = ?              AND 
                           crapcst.nrdconta <> 85448          AND
                          (crapcst.nrdconta >= par_containi   AND
                           crapcst.nrdconta <= par_contafim)  NO-LOCK
                           USE-INDEX crapcst3:

        /* Quando informado PAC, filtra */
        IF par_cdagenci <> 0 AND crapcst.cdagenci <> par_cdagenci THEN NEXT.
    
        CREATE tt-crapcst.
        BUFFER-COPY crapcst TO tt-crapcst.

        FIND crapass WHERE 
             crapass.cdcooper = crapcst.cdcooper  AND
             crapass.nrdconta = crapcst.nrdconta  NO-LOCK NO-ERROR.
        IF   AVAIL crapass   THEN
             ASSIGN tt-crapcst.nmprimtl = crapass.nmprimtl.

    END. /* FOR EACH crapcst */

    RETURN "OK".
    
END PROCEDURE. /* conferencia_cheques_em_custodia */

PROCEDURE valida_limites_desconto:
    /************************************************************************
        Objetivo: Validar e buscar limites parametrizados para desconto de 
                  cheques em custodia - Opcao "D" da tela CUSTOD
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_dtlibera AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    
    DEFINE VAR aux_cdacesso AS CHAR                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST crapass 
         WHERE crapass.cdcooper = par_cdcooper
           AND crapass.nrdconta = par_nrdconta
           NO-LOCK NO-ERROR.
    IF NOT AVAILABLE crapass THEN
    DO:
             ASSIGN aux_cdcritic = 9.
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    FIND FIRST craplim WHERE 
               craplim.cdcooper = par_cdcooper   AND
               craplim.nrdconta = par_nrdconta   AND
               craplim.tpctrlim = 2              AND
               craplim.insitlim = 2              NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE craplim   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = 
                        "Nao ha limite de desconto de cheques ATIVO.".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
         
    FIND crapldc WHERE 
         crapldc.cdcooper = par_cdcooper       AND
         crapldc.cddlinha = craplim.cddlinha   AND
         crapldc.tpdescto = 2                  NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE crapldc   THEN
         DO:
             ASSIGN aux_cdcritic = 363
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.                
    
    IF crapass.inpessoa = 1 THEN
      DO:
         ASSIGN aux_cdacesso = "LIMDESCONTPF".
      END.
    ELSE
      DO: 
         ASSIGN aux_cdacesso = "LIMDESCONTPJ".
      END.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = aux_cdacesso AND
                       craptab.tpregist = 0            NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE craptab   THEN
         DO:
             ASSIGN aux_cdcritic = 55
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,      /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    /*Antigo DECIMAL(SUBSTRING(craptab.dstextab,22,03))*/
    ASSIGN tab_qtprzmin = DECIMAL(ENTRY(4,craptab.dstextab," "))
           par_dtlibera = par_dtmvtolt + tab_qtprzmin + 1.

    RETURN "OK".

END PROCEDURE. /* valida_limites_desconto */

PROCEDURE valida_dados_desconto:
    /************************************************************************
        Objetivo: Validar dados informados para desconto de cheques em 
                  custodia - Opcao "D" da tela CUSTOD
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibera AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    
    DEFINE VAR aux_cdacesso AS CHAR                     NO-UNDO.
    
    FIND FIRST crapass 
         WHERE crapass.cdcooper = par_cdcooper
           AND crapass.nrdconta = par_nrdconta
           NO-LOCK NO-ERROR.
    IF NOT AVAILABLE crapass THEN
    DO:
         ASSIGN aux_cdcritic = 9.
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
         RETURN "NOK".
    END.
    
    
    FIND FIRST craplim WHERE 
               craplim.cdcooper = par_cdcooper   AND
               craplim.nrdconta = par_nrdconta   AND
               craplim.tpctrlim = 2              AND
               craplim.insitlim = 2              NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE craplim   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = 
                        "Nao ha limite de desconto de cheques ATIVO.".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
         
    IF crapass.inpessoa = 1 THEN
      DO:
         ASSIGN aux_cdacesso = "LIMDESCONTPF".
      END.
    ELSE
      DO: 
         ASSIGN aux_cdacesso = "LIMDESCONTPJ".
      END.
         
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = aux_cdacesso AND
                       craptab.tpregist = 0            NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE craptab   THEN
         DO:
             ASSIGN aux_cdcritic = 55
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,      /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
         
    /** Buscar regra para renovaçao **/
    FIND FIRST craprli 
         WHERE craprli.cdcooper = par_cdcooper
           AND craprli.tplimite = 2
           AND craprli.inpessoa = crapass.inpessoa
           NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE craprli  THEN
    DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Tabela Regra de limite nao cadastrada.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,      /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
         
         
    ASSIGN tab_qtrenova = craprli.qtmaxren
           tab_qtprzmin = DECIMAL(ENTRY(4,craptab.dstextab," "))
           tab_qtprzmax = DECIMAL(ENTRY(5,craptab.dstextab," "))
           aux_dtminima = par_dtmvtolt + tab_qtprzmin
           aux_dtmaxima = par_dtmvtolt + tab_qtprzmax.

    IF craplim.dtfimvig <> ? THEN
	  ASSIGN aux_dtlimite = craplim.dtfimvig.
    ELSE
	  ASSIGN aux_dtlimite = craplim.dtinivig + craplim.qtdiavig.
                          
    IF   par_dtlibera >= aux_dtlimite   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Data de liberacao superior ao vencimento do limite contratado. " +
                                   "Vencimento do limite:" + STRING(aux_dtlimite,"99/99/9999") + ". Limite deve ser renovado.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
 
         END.

    IF   par_dtlibera <= aux_dtminima    THEN
             DO:
                   ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Data de liberacao inferior ao prazo minimo. " +
                                   "Data minima:" + STRING(aux_dtminima,"99/99/9999") + ".".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
                 
                 END.
        
    IF   par_dtlibera >= aux_dtmaxima    THEN

         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Data de liberacao superior ao prazo maximo. " +
                                   "Data maxima:" + STRING(aux_dtmaxima,"99/99/9999") + ".".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                          INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
                         
         END.
         
    RETURN "OK".

END PROCEDURE. /* valida_dados_desconto */

PROCEDURE valida_lote_desconto:
    /************************************************************************
        Objetivo: Validar lote de cheques em custodia a ser descontado - 
                  Opcao "D" da tela CUSTOD
    ************************************************************************/
    DEFINE INPUT        PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdagelot AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrdolote AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_dtlibera AS DATE        NO-UNDO.
    DEFINE INPUT-OUTPUT PARAMETER TABLE FOR crawlot.
    DEFINE OUTPUT       PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT       PARAMETER par_menslote AS CHARACTER   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    FIND craplot WHERE 
         craplot.cdcooper = par_cdcooper   AND
         craplot.dtmvtolt = par_dtmvtolt   AND
         craplot.cdagenci = par_cdagelot   AND
         craplot.cdbccxlt = 600            AND
         craplot.nrdolote = par_nrdolote   NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE craplot   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Lote nao encontrado.".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
       
    FIND FIRST crapcst WHERE 
               crapcst.cdcooper = craplot.cdcooper   AND
               crapcst.dtmvtolt = craplot.dtmvtolt   AND
               crapcst.cdagenci = craplot.cdagenci   AND
               crapcst.cdbccxlt = craplot.cdbccxlt   AND
               crapcst.nrdolote = craplot.nrdolote   AND
               crapcst.dtdevolu = ?                  NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE crapcst   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = 
                        "Nenhum cheque foi encontrado para este lote.".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
    
    IF   crapcst.nrdconta <> par_nrdconta   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Conta do favorecido nao confere.".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    ASSIGN  aux_dtmvtoan = par_dtlibera - 1.

    IF   crapcst.dtlibera <> par_dtlibera   THEN
         DO:
             /*  Testa se data liberacao e sabado,domingo ou  feriado  */
             aux_dtmvtoan = crapcst.dtlibera.
    
             DO WHILE TRUE:
    
                IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtoan)))   OR
                     CAN-FIND(crapfer WHERE 
                              crapfer.cdcooper = par_cdcooper AND
                              crapfer.dtferiad = aux_dtmvtoan)   THEN
                     DO:
                         aux_dtmvtoan = aux_dtmvtoan - 1.
                         NEXT.
                     END.
         
                LEAVE.
             END.  /*  Fim do DO WHILE TRUE  */

             IF   crapcst.dtlibera > aux_dtmvtoan      AND
                  crapcst.dtlibera < par_dtlibera      THEN.
             ELSE     
                  DO:
                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = "Data de liberacao nao confere.".
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1,            /** Sequencia **/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
                      RETURN "NOK".
                  END.  
         END.
    
    IF   crapcst.insitchq = 5   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Lote ja descontado.".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    IF CAN-FIND(crawlot WHERE
                crawlot.dtmvtolt = par_dtmvtolt    AND
                crawlot.cdagenci = par_cdagelot    AND
                crawlot.cdbccxlt = 600             AND
                crawlot.nrdolote = par_nrdolote)   THEN 
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Lote ja selecionado.".
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
       END.
    
    FOR EACH crapcst WHERE crapcst.cdcooper = par_cdcooper   AND
                           crapcst.dtmvtolt = par_dtmvtolt   AND
                           crapcst.cdagenci = par_cdagelot   AND
                           crapcst.cdbccxlt = 600            AND
                           crapcst.nrdolote = par_nrdolote   AND
                           crapcst.dtdevolu = ?              NO-LOCK:

        ACCUM crapcst.nrcheque (COUNT).
        ACCUM crapcst.vlcheque (TOTAL).

    END.

    CREATE crawlot.
    ASSIGN crawlot.dtmvtolt = craplot.dtmvtolt
           crawlot.cdagenci = craplot.cdagenci
           crawlot.cdbccxlt = 600
           crawlot.nrdolote = craplot.nrdolote
           crawlot.qtchqtot = (ACCUM COUNT crapcst.nrcheque)
           crawlot.vlchqtot = (ACCUM TOTAL crapcst.vlcheque).

    RELEASE crawlot.

    FOR EACH crawlot:
        ACCUM crawlot.qtchqtot (TOTAL).
        ACCUM crawlot.vlchqtot (TOTAL).
    END.

    ASSIGN par_menslote = 
               "Ja foram selecionados " +
               TRIM(STRING((ACCUM TOTAL crawlot.qtchqtot),"zzz,zz9")) +
               " cheques, no total de R$ " +
               TRIM(STRING((ACCUM TOTAL crawlot.vlchqtot),"zzz,zzz,zz9.99")).

    RETURN "OK".

END PROCEDURE. /* valida_lote_desconto */

PROCEDURE valida_operador_desconto:
    /************************************************************************
        Objetivo: Validar operador do desconto de cheques em custodia - 
                  Opcao "D" da tela CUSTOD
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdsenha AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nvoperad AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER TABLE FOR crawlot.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEFINE VAR h_b1wgen0000 AS HANDLE                   NO-UNDO.
        
    
    EMPTY TEMP-TABLE tt-erro.
    
    RUN sistema/generico/procedures/b1wgen0000.p 
                 PERSISTENT SET h_b1wgen0000.
                
                 RUN valida-senha-coordenador IN h_b1wgen0000
                                                   (INPUT  par_cdcooper,
                                                    INPUT  0,            
                                                    INPUT  0,            
                                                    INPUT  "", 
                                                    INPUT  "", 
                                                    INPUT  1,   
                                                    INPUT  0, 
                                                    INPUT  0, 
                                                    INPUT  par_nvoperad, 
                                                    INPUT  par_cdoperad, 
                                                    INPUT  par_nrdsenha, 
                                                    INPUT  FALSE,        
                                                    OUTPUT TABLE tt-erro).
                  
                  
                  DELETE PROCEDURE h_b1wgen0000.
                  
                  IF   RETURN-VALUE = "NOK"   THEN
                       RETURN "NOK".
                  
    FOR EACH crawlot:
        ACCUM crawlot.qtchqtot (TOTAL).
        ACCUM crawlot.vlchqtot (TOTAL).
    END.
    
    UNIX SILENT VALUE
       ("echo "                                            + 
        STRING(par_dtmvtolt,"99/99/9999")                  +
        " - "                                              +
        STRING(TIME,"HH:MM:SS")                            +
        " - AUTORIZACAO DE DESCONTO"                       + 
        "' --> '"                                          +
        " Operador: "                                      + 
        STRING(par_cdoperad,"x(10)")                       +
        " Conta: "                                         + 
        STRING(par_nrdconta,"zzzz,zzz,9")                  +
        " Qtd. Cheques: "                                  +
        STRING((ACCUM TOTAL crawlot.qtchqtot),"zz,zz9")    +
        " Valor: "                                         +
        STRING((ACCUM TOTAL crawlot.vlchqtot),
               "zzz,zzz,zzz,zz9.99")                       +
        " >> /usr/coop/" + TRIM(crapcop.dsdircop) + "/log/custod.log"). 

    RETURN "OK".

END PROCEDURE. /* valida_operador_desconto */

PROCEDURE desconta_cheques_em_custodia:
    /************************************************************************
        Objetivo: Efetuar desconto de cheques em custodia - 
                  Opcao "D" da tela CUSTOD
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibera AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER TABLE FOR crawlot.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapbdc.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEFINE BUFFER crabass FOR crapass.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN aux_novolote = 10000
           aux_contalan = 0
           aux_somalanc = 0
           aux_nrborder = 1
           aux_dtmvtoan = par_dtlibera - 1.

    /*  Testa se data liberacao e sabado,domingo ou  feriado  */
    DO WHILE TRUE:
    
       IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtoan)))   OR
            CAN-FIND(crapfer WHERE 
                     crapfer.cdcooper = par_cdcooper AND
                     crapfer.dtferiad = aux_dtmvtoan)   THEN
            DO:
                aux_dtmvtoan = aux_dtmvtoan - 1.
                NEXT.
            END.
    
       LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */
    
    DO  WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE:
 
        FIND LAST craplot WHERE 
                  craplot.cdcooper  = par_cdcooper      AND
                  craplot.dtmvtolt  = par_dtmvtolt      AND
                  craplot.cdagenci  = crapass.cdagenci  AND
                  craplot.cdbccxlt  = 700               AND
                  craplot.nrdolote >= aux_novolote
                  NO-LOCK NO-ERROR.
 
        IF   AVAIL craplot   THEN
             ASSIGN aux_novolote = craplot.nrdolote + 1.
        ELSE
             ASSIGN aux_novolote = aux_novolote + 1.
 
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPBDC"
                                            ,INPUT "NRBORDER"
                                            ,INPUT STRING(par_cdcooper)
                                            ,INPUT "N"
                                            ,"").
        
        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        		  
        ASSIGN aux_nrborder = INTE(pc_sequence_progress.pr_sequence)
        					  WHEN pc_sequence_progress.pr_sequence <> ?.
 
        FOR EACH crawlot WHILE aux_contalan < 400:

            FOR EACH crapcst WHERE 
                     crapcst.cdcooper  = par_cdcooper       AND
                     crapcst.nrdconta  = par_nrdconta       AND
                     crapcst.dtlibera   > aux_dtmvtoan      AND
                     crapcst.dtlibera  <= par_dtlibera      AND
                     crapcst.dtmvtolt  = crawlot.dtmvtolt   AND
                     crapcst.cdagenci  = crawlot.cdagenci   AND
                     crapcst.cdbccxlt  = crawlot.cdbccxlt   AND
                     crapcst.nrdolote  = crawlot.nrdolote   AND
                     crapcst.dtdevolu  = ?                  EXCLUSIVE-LOCK
                     WHILE aux_contalan < 400:

                IF   aux_contalan = 0   THEN
                     DO:
                         FIND FIRST craplim WHERE 
                                    craplim.cdcooper = par_cdcooper   AND
                                    craplim.nrdconta = par_nrdconta   AND
                                    craplim.tpctrlim = 2              AND
                                    craplim.insitlim = 2
                                    NO-LOCK NO-ERROR.

                         FIND crapldc WHERE 
                              crapldc.cdcooper = par_cdcooper       AND
                              crapldc.cddlinha = craplim.cddlinha   AND
                              crapldc.tpdescto = 2
                              NO-LOCK NO-ERROR.

                         CREATE craplot.
                         ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                craplot.cdagenci = crapass.cdagenci
                                craplot.cdbccxlt = 700                  
                                craplot.nrdolote = aux_novolote
                                craplot.tplotmov = 26
                                craplot.cdoperad = par_cdoperad
                                craplot.cdhistor = aux_nrborder
                                craplot.nrseqdig = 0
                                craplot.cdcooper = par_cdcooper.
                         VALIDATE craplot.
                     
                        /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) *
                        IF par_cdagenci = 0 THEN
                          ASSIGN par_cdagenci = glb_cdagenci.
                        * Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

                         CREATE crapbdc.
                         ASSIGN crapbdc.nrborder = aux_nrborder
                                crapbdc.dtmvtolt = craplot.dtmvtolt
                                crapbdc.cdagenci = craplot.cdagenci
                                crapbdc.cdbccxlt = craplot.cdbccxlt
                                crapbdc.nrdolote = craplot.nrdolote
                                crapbdc.dtlibbdc = ?
                                crapbdc.cdoperad = par_cdoperad
                                crapbdc.nrctrlim = craplim.nrctrlim
                                crapbdc.nrdconta = par_nrdconta
                                crapbdc.cddlinha = craplim.cddlinha
                                crapbdc.txmensal = crapldc.txmensal
                                crapbdc.txdiaria = crapldc.txdiaria
                                crapbdc.txjurmor = crapldc.txjurmor
                                crapbdc.insitbdc = 1
                                crapbdc.inoribdc = 2
                                crapbdc.hrtransa = TIME
                                /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                                crapbdc.cdopeori = par_cdoperad
                                crapbdc.cdageori = par_cdagenci
                                crapbdc.dtinsori = TODAY
                                /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                                crapbdc.cdcooper = par_cdcooper.
                         VALIDATE crapbdc.

                         CREATE tt-crapbdc.
                         BUFFER-COPY crapbdc TO tt-crapbdc.

                     END.  /* fim IF aux_contalan = 0 */

                ASSIGN aux_contalan = aux_contalan + 1
                       aux_somalanc = aux_somalanc + crapcst.vlcheque.
                
                FIND crapcdb WHERE 
                     crapcdb.cdcooper = crapcst.cdcooper   AND
                     crapcdb.cdcmpchq = crapcst.cdcmpchq   AND
                     crapcdb.cdbanchq = crapcst.cdbanchq   AND
                     crapcdb.cdagechq = crapcst.cdagechq   AND
                     crapcdb.nrctachq = crapcst.nrctachq   AND
                     crapcdb.nrcheque = crapcst.nrcheque   AND
                     crapcdb.dtdevolu = ?                  
                     EXCLUSIVE-LOCK NO-ERROR.
                
                IF   AVAILABLE crapcdb   THEN
                     NEXT.

                aux_dtliber2 = crapcst.dtlibera.
               
                DO WHILE TRUE:
                                
                   IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtliber2)))   OR
                        CAN-FIND(crapfer WHERE
                                 crapfer.cdcooper = par_cdcooper AND
                                 crapfer.dtferiad = aux_dtliber2)   THEN
                        DO:
                            aux_dtliber2 = aux_dtliber2 + 1.
                            NEXT.
                        END.
                  
                   LEAVE.
                                                                                               END.  /*  Fim do DO WHILE TRUE  */
                
                CREATE crapcdb.
                ASSIGN crapcdb.cdagechq = crapcst.cdagechq
                       crapcdb.cdagenci = craplot.cdagenci
                       crapcdb.cdbanchq = crapcst.cdbanchq
                       crapcdb.cdbccxlt = 700
                       crapcdb.cdcmpchq = crapcst.cdcmpchq
                       crapcdb.cdoperad = par_cdoperad
                       crapcdb.dsdocmc7 = crapcst.dsdocmc7
                
                       crapcdb.dtlibera = aux_dtliber2
                                             
                       crapcdb.dtmvtolt = craplot.dtmvtolt
                       crapcdb.insitchq = 0
                       crapcdb.nrctrlim = craplim.nrctrlim
                       crapcdb.nrborder = aux_nrborder
                       crapcdb.nrctachq = crapcst.nrctachq
                       crapcdb.nrdconta = par_nrdconta
                       crapcdb.nrddigc1 = crapcst.nrddigc1
                       crapcdb.nrddigc2 = crapcst.nrddigc2
                       crapcdb.nrddigc3 = crapcst.nrddigc3
                       crapcdb.nrcheque = crapcst.nrcheque
                       crapcdb.nrdolote = craplot.nrdolote
                       crapcdb.nrseqdig = craplot.nrseqdig + 1
                       crapcdb.vlcheque = crapcst.vlcheque
                       crapcdb.inchqcop = crapcst.inchqcop
                       crapcdb.cdcooper = par_cdcooper
                       crapcdb.insitprv = crapcst.insitprv
                       crapcdb.dtprevia = crapcst.dtprevia
                                
                       crapcst.dtdevolu = par_dtmvtolt
                       crapcst.insitchq = 5
                       crapcst.nrborder = crapcdb.nrborder
                       crapcst.cdopedev = par_cdoperad
                              
                       craplot.nrseqdig = craplot.nrseqdig + 1.
                VALIDATE crapcdb.
                               
                IF   crapcst.inchqcop = 1   THEN
                     DO WHILE TRUE:
                     
                         FIND craplau WHERE
                              craplau.cdcooper = par_cdcooper     AND
                              craplau.dtmvtolt = crapcst.dtmvtolt AND
                              craplau.cdagenci = crapcst.cdagenci AND
                              craplau.cdbccxlt = crapcst.cdbccxlt AND
                              craplau.nrdolote = crapcst.nrdolote AND
                              craplau.nrdctabb = INT(crapcst.nrctachq) AND
                              craplau.nrdocmto = INT(STRING(crapcst.nrcheque) +
                                                     STRING(crapcst.nrddigc3))
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                         
                         IF   NOT AVAILABLE craplau   THEN
                              IF   LOCKED craplau   THEN
                                   DO:
                                       PAUSE 2 NO-MESSAGE.
                                       NEXT.
                                   END.
                              ELSE
                                   DO:
                                        /*  DEFINIR  */
                                   END.
                         ELSE     
                              DO:
                                  ASSIGN craplau.dtmvtolt = craplot.dtmvtolt
                                         craplau.cdagenci = craplot.cdagenci
                                         craplau.cdbccxlt = craplot.cdbccxlt
                                         craplau.nrdolote = craplot.nrdolote
                                         craplau.nrseqdig = craplot.nrseqdig
                                         craplau.cdhistor = 
                                            IF craplau.cdhistor = 21 THEN 
                                               521
                                            ELSE IF craplau.cdhistor = 26 THEN 
                                                    526
                                                 ELSE craplau.cdhistor.
                              END.
                         
                         FIND crabass WHERE 
                              crabass.cdcooper = par_cdcooper      AND
                              crabass.nrdconta = craplau.nrdconta  
                              NO-LOCK NO-ERROR.
                         IF   NOT AVAILABLE crabass   THEN
                              LEAVE.
                         
                         ASSIGN crapcdb.nrcpfcgc = crabass.nrcpfcgc.
                         
                         /*  Verifica o cadastro de emitentes de cheques  */
                         FIND crapcec WHERE 
                              crapcec.cdcooper = par_cdcooper       AND
                              crapcec.cdcmpchq = crapcdb.cdcmpchq   AND
                              crapcec.cdbanchq = crapcdb.cdbanchq   AND
                              crapcec.cdagechq = crapcdb.cdagechq   AND
                              crapcec.nrctachq = crapcdb.nrctachq   AND
                              crapcec.nrdconta = craplau.nrdconta
                              NO-LOCK NO-ERROR.
                
                         IF   NOT AVAILABLE crapcec   THEN
                              DO:
                                  CREATE crapcec.
                                  ASSIGN crapcec.cdagechq = crapcdb.cdagechq
                                         crapcec.cdbanchq = crapcdb.cdbanchq
                                         crapcec.cdcmpchq = crapcdb.cdcmpchq
                                         crapcec.nmcheque = crabass.nmprimtl
                                         crapcec.nrcpfcgc = crabass.nrcpfcgc
                                         crapcec.nrctachq = crapcdb.nrctachq
                                         crapcec.nrdconta = craplau.nrdconta
                                         crapcec.cdcooper = par_cdcooper.
                                  VALIDATE crapcec.
                              END.
                         
                         LEAVE.
                
                     END.  /*  DO WHILE TRUE (IF crapcst.inchqcop = 1)  */
                                                 
            END.  /* fim do FOR EACH crapcst... */
 
            IF   aux_contalan < 400   THEN
                 DELETE crawlot.
                
       END.  /* fim do FOR EACH crawcst... */
 
       ASSIGN craplot.qtcompln = aux_contalan
              craplot.vlcompdb = aux_somalanc
              craplot.vlcompcr = aux_somalanc
              craplot.qtinfoln = aux_contalan
              craplot.vlinfodb = aux_somalanc
              craplot.vlinfocr = aux_somalanc.
 
       IF   aux_contalan = 400   THEN
            DO:
                ASSIGN aux_contalan = 0
                       aux_somalanc = 0.
            END.
       ELSE
            LEAVE.
 
    END. /* fim WHILE TRANSACTION... */

    RELEASE craplot.
    RELEASE crapbdc.

    RETURN "OK".

END PROCEDURE. /* desconta_cheques_em_custodia */

PROCEDURE busca_relatorio_desconto_custodia:
    /************************************************************************
        Objetivo: Buscar informacoes para apresentacao de relatorio de 
                  desconto de cheques em custodia - Opcao "D" da tela CUSTOD
     Observacoes: Temp-table tt-crapbdc precisa estar carregada com as 
                  chaves dos borderos a serem impressos
    ************************************************************************/
    DEFINE INPUT         PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT         PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT         PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT-OUTPUT  PARAMETER TABLE FOR tt-crapbdc.
    DEFINE OUTPUT        PARAMETER TABLE FOR tt-crapcst.
    DEFINE OUTPUT        PARAMETER TABLE FOR tt-erro.

    FOR EACH tt-crapbdc:

        FIND crapbdc WHERE 
             crapbdc.cdcooper = tt-crapbdc.cdcooper   AND
             crapbdc.nrborder = tt-crapbdc.nrborder   NO-LOCK NO-ERROR.
        IF   AVAIL crapbdc   THEN
             DO:
                 FIND crapass WHERE 
                      crapass.cdcooper = tt-crapbdc.cdcooper   AND
                      crapass.nrdconta = tt-crapbdc.nrdconta   
                      NO-LOCK NO-ERROR.
                 IF   NOT AVAIL crapass   THEN
                      DO:
                          ASSIGN aux_cdcritic = 9
                                 aux_dscritic = "".
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,            /** Sequencia **/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                          RETURN "NOK".
                      END.

                 FIND FIRST crapcdb WHERE 
                            crapcdb.cdcooper = crapbdc.cdcooper   AND
                            crapcdb.nrdconta = crapbdc.nrdconta   AND
                            crapcdb.dtmvtolt = crapbdc.dtmvtolt   AND
                            crapcdb.nrborder = crapbdc.nrborder   
                            NO-LOCK NO-ERROR.
                 IF   NOT AVAILABLE crapcdb   THEN
                      DO:
                          ASSIGN aux_cdcritic = 0
                                 aux_dscritic = "Bordero nao possui " + 
                                                "cheques descontados".
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,            /** Sequencia **/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                          RETURN "NOK".
                      END.

                 BUFFER-COPY crapbdc TO tt-crapbdc.
                 ASSIGN tt-crapbdc.nmprimtl = crapass.nmprimtl
                        tt-crapbdc.dtlibera = crapcdb.dtlibera.

                 FOR EACH crapcst WHERE 
                          crapcst.cdcooper = crapbdc.cdcooper   AND
                          crapcst.dtdevolu = crapbdc.dtmvtolt   AND
                          crapcst.nrborder = crapbdc.nrborder   AND
                          crapcst.insitchq = 5                  NO-LOCK:

                     CREATE tt-crapcst.
                     BUFFER-COPY crapcst TO tt-crapcst.

                 END. /* FOR EACH crapcst */
             END. /* IF   AVAIL crapbdc */
    END. /* FOR EACH tt-crapbdc */

    RETURN "OK".

END PROCEDURE. /* busca_relatorio_desconto_custodia */

PROCEDURE pi_calcula_datas_liberacao:
    /************************************************************************
        Objetivo: Calcular datas de liberacao anterior e posterior 
                  considerando somente dias uteis
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibera AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_dtliber1 AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_dtliber2 AS DATE        NO-UNDO.

    ASSIGN par_dtliber1 = par_dtlibera.
    
    DO WHILE TRUE:
               
       ASSIGN par_dtliber1 = par_dtliber1 - 1.
       
       IF   CAN-DO("1,7",STRING(WEEKDAY(par_dtliber1)))   OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                   crapfer.dtferiad = par_dtliber1)   THEN
            NEXT.

       LEAVE.
               
    END.  /*  Fim do DO WHILE TRUE  */
               
    ASSIGN par_dtliber2 = par_dtlibera.
    
    DO WHILE TRUE:

       IF   CAN-DO("1,7",STRING(WEEKDAY(par_dtliber2)))   OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                   crapfer.dtferiad = par_dtliber2)   THEN
            DO:
                ASSIGN par_dtliber2 = par_dtliber2 + 1.
                NEXT.
            END.

       ASSIGN par_dtliber2 = par_dtliber2 + 1.
       
       LEAVE.
               
    END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE. /* pi_calcula_datas_liberacao */
 

PROCEDURE pi_grava_tt-fechamento_descto:
    /************************************************************************
        Objetivo: Criar tt-fechamento para desconto
    ************************************************************************/

    /* Nao considera cheques redescontados */
    IF   crapcdb.dtdevolu <> ?   AND
         crapcdb.insitchq <> 2   THEN
         DO:
             ASSIGN tt-fechamento.qtchqdev = tt-fechamento.qtchqdev + 1
                    tt-fechamento.vlchqdev = tt-fechamento.vlchqdev + 
                                             crapcdb.vlcheque.
       
             NEXT.
         END.
    
    IF   crapcdb.inchqcop = 1   THEN
         ASSIGN tt-fechamento.qtchqcop = tt-fechamento.qtchqcop + 1
                tt-fechamento.vlchqcop = tt-fechamento.vlchqcop +
                                         crapcdb.vlcheque.
    ELSE
         DO:
             ASSIGN tt-fechamento.qtchqban = tt-fechamento.qtchqban + 1
                    tt-fechamento.vlchqban = tt-fechamento.vlchqban + 
                                             crapcdb.vlcheque.
             IF  crapcdb.vlcheque < 300 THEN
                 ASSIGN tt-fechamento.vlrmenor = tt-fechamento.vlrmenor + 
                                                 crapcdb.vlcheque
                        tt-fechamento.qtdmenor = tt-fechamento.qtdmenor + 1.
             ELSE
                 ASSIGN tt-fechamento.vlrmaior = tt-fechamento.vlrmaior + 
                                                 crapcdb.vlcheque
                        tt-fechamento.qtdmaior = tt-fechamento.qtdmaior + 1.
         END.

END PROCEDURE. /* pi_grava_tt-fechamento_descto */

PROCEDURE pi_grava_tt-fechamento_custodia:
    /************************************************************************
        Objetivo: Criar tt-fechamento para custodia
    ************************************************************************/

    IF   crapcst.dtdevolu <> ?   THEN
         DO:
             IF   crapcst.insitchq = 5   THEN
                  ASSIGN tt-fechamento.qtchqdsc = tt-fechamento.qtchqdsc + 1
                         tt-fechamento.vlchqdsc = tt-fechamento.vlchqdsc + 
                                                  crapcst.vlcheque.
             ELSE
                  ASSIGN tt-fechamento.qtchqdev = tt-fechamento.qtchqdev + 1
                         tt-fechamento.vlchqdev = tt-fechamento.vlchqdev +
                                                  crapcst.vlcheque.
       
             NEXT.
         END.
    
    IF   crapcst.inchqcop = 1   THEN
         ASSIGN tt-fechamento.qtchqcop = tt-fechamento.qtchqcop + 1
                tt-fechamento.vlchqcop = tt-fechamento.vlchqcop +
                                         crapcst.vlcheque.
    ELSE
         DO:
             ASSIGN tt-fechamento.qtchqban = tt-fechamento.qtchqban + 1
                    tt-fechamento.vlchqban = tt-fechamento.vlchqban + 
                                             crapcst.vlcheque.
             
             IF  crapcst.vlcheque < 300 THEN
                 ASSIGN tt-fechamento.vlrmenor = tt-fechamento.vlrmenor + 
                                                 crapcst.vlcheque
                        tt-fechamento.qtdmenor = tt-fechamento.qtdmenor + 1.   
             ELSE
                 ASSIGN tt-fechamento.vlrmaior = tt-fechamento.vlrmaior + 
                                                 crapcst.vlcheque
                        tt-fechamento.qtdmaior = tt-fechamento.qtdmaior + 1.
         END.

END PROCEDURE. /* pi_grava_tt-fechamento_custodia */

PROCEDURE pi_grava_tt-saldo_custodia:
    /*************************************************************************
        Objetivo: Gravar temp-table tt-saldo para custodia
    *************************************************************************/
    DEFINE INPUT  PARAMETER par_tpdsaldo AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtlibera AS DATE        NO-UNDO.

    IF   par_tpdsaldo = 1   AND   crapcst.nrdconta <> 85448   THEN RETURN.
    IF   par_tpdsaldo = 2   AND   crapcst.nrdconta = 85448    THEN RETURN.
    IF   crapcst.dtlibera < aux_dtliber1                      THEN RETURN.
    IF   crapcst.dtdevolu < par_dtlibera                      THEN RETURN.

    IF   crapcst.dtmvtolt < par_dtlibera   THEN
         ASSIGN tt-saldo.qtsldant = tt-saldo.qtsldant + 1
                tt-saldo.vlsldant = tt-saldo.vlsldant + crapcst.vlcheque.

    IF   (crapcst.dtdevolu = par_dtlibera) AND
         (crapcst.insitchq = 5)    THEN
         DO:
             ASSIGN tt-saldo.qtchqdsc = tt-saldo.qtchqdsc - 1
                    tt-saldo.vlchqdsc = tt-saldo.vlchqdsc - crapcst.vlcheque.
             RETURN.
         END.
                
    IF   crapcst.dtdevolu <> ?   THEN
         IF   crapcst.dtdevolu = par_dtlibera   THEN
              DO:
                  ASSIGN tt-saldo.qtchqdev = tt-saldo.qtchqdev - 1
                         tt-saldo.vlchqdev = tt-saldo.vlchqdev - 
                                             crapcst.vlcheque.
           
                  IF   crapcst.dtmvtolt <> crapcst.dtdevolu   THEN
                       RETURN.
              END.

    IF  (crapcst.dtlibera >= aux_dtliber1  AND
         crapcst.dtlibera <= par_dtlibera) AND
         crapcst.dtdevolu = ?              THEN
         DO:
             ASSIGN tt-saldo.qtlibera = tt-saldo.qtlibera - 1
                    tt-saldo.vllibera = tt-saldo.vllibera - crapcst.vlcheque.
             
             IF   crapcst.inchqcop = 1   THEN
                  ASSIGN tt-saldo.qtchqcop = tt-saldo.qtchqcop - 1
                         tt-saldo.vlchqcop = tt-saldo.vlchqcop - 
                                             crapcst.vlcheque.
             ELSE
                  ASSIGN tt-saldo.qtchqban = tt-saldo.qtchqban - 1
                         tt-saldo.vlchqban = tt-saldo.vlchqban -
                                             crapcst.vlcheque. 
         END.
        
    IF   crapcst.dtmvtolt <= par_dtlibera   THEN
         IF   crapcst.inchqcop = 1   THEN
              ASSIGN tt-saldo.qtchqcop = tt-saldo.qtchqcop + 1
                     tt-saldo.vlchqcop = tt-saldo.vlchqcop + 
                                         crapcst.vlcheque.
         ELSE
              ASSIGN tt-saldo.qtchqban = tt-saldo.qtchqban + 1
                     tt-saldo.vlchqban = tt-saldo.vlchqban + 
                                         crapcst.vlcheque.

    IF   crapcst.dtmvtolt <> par_dtlibera   THEN
         NEXT.

    ASSIGN tt-saldo.qtcheque = tt-saldo.qtcheque + 1
           tt-saldo.vlcheque = tt-saldo.vlcheque + crapcst.vlcheque.
    
END PROCEDURE. /* pi_grava_tt-saldo_custodia */

/*...........................................................................*/


PROCEDURE busca_alterar_cheques_descontados:
    /************************************************************************
        Objetivo: Consultar cheques descontados que serao alterados (Opcao 
                  "A" da tela DESCTO)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrborder AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdcmpchq AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbanchq AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagechq AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctachq AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcheque AS INT         NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-alterar.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0 
           aux_dscritic = ""
           aux_nrsequen = 0.
    
    FIND crapcdb WHERE crapcdb.cdcooper = par_cdcooper AND
                       crapcdb.nrborder = par_nrborder AND
                       crapcdb.nrdconta = par_nrdconta AND
                       crapcdb.cdcmpchq = par_cdcmpchq AND
                       crapcdb.cdbanchq = par_cdbanchq AND
                       crapcdb.cdagechq = par_cdagechq AND
                       crapcdb.nrctachq = par_nrctachq AND
                       crapcdb.nrcheque = par_nrcheque USE-INDEX crapcdb7
                       NO-LOCK NO-ERROR.
        
    IF AVAIL crapcdb THEN
       DO:
          FIND crapcec WHERE crapcec.cdcooper = crapcdb.cdcooper AND
                             crapcec.cdcmpchq = crapcdb.cdcmpchq AND
                             crapcec.cdbanchq = crapcdb.cdbanchq AND
                             crapcec.cdagechq = crapcdb.cdagechq AND
                             crapcec.nrctachq = crapcdb.nrctachq AND
                             crapcec.nrcpfcgc = crapcdb.nrcpfcgc 
                             USE-INDEX crapcec2
                             NO-LOCK NO-ERROR.
       
          IF AVAIL crapcec THEN
             DO:
                CREATE tt-alterar.
                ASSIGN tt-alterar.nrcpfcgc = crapcdb.nrcpfcgc
                       tt-alterar.nmcheque = crapcec.nmcheque.
                
             END.
          ELSE     
             DO:
               IF NOT AVAILABLE crapcec THEN
                  IF LOCKED crapcec THEN
                     DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Registro em uso. Tente novamente."
                               aux_nrsequen = aux_nrsequen + 1.
                        NEXT.
               
                     END.
                  ELSE
                     DO:
                        ASSIGN aux_cdcritic = 009
                               aux_dscritic = "".
               
                     END.
                  
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT 0,
                                 INPUT aux_nrsequen, /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
              
                  RETURN "NOK".
                  
             END.

       END. 
    ELSE
    DO:
       ASSIGN aux_cdcritic = 244
              aux_dscritic = ""
              aux_nrsequen = aux_nrsequen + 1.
            
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT 0,
                      INPUT aux_nrsequen, /** Sequencia **/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
            
       RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE. /* Busca_alterar_cheques_descontados */

/************************************************************/

PROCEDURE alterar_cheques_descontados:
    /************************************************************************
        Objetivo: Alterar CPF/CGC e nome do emitente dos cheques descontados
                  (Opcao "A" da tela DESCTO)
    ************************************************************************/
    DEFINE INPUT  PARAMETER par_cdcooper AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrborder AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdcmpchq AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbanchq AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagechq AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctachq AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcheque AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmcheque AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcpfcgc AS DEC         NO-UNDO.
    DEFINE INPUT  PARAMETER par_auxnmchq AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_auxnrcpf AS DEC         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHAR         NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    
    DEF VAR aux_contador AS INT                         NO-UNDO.
   
    EMPTY TEMP-TABLE tt-erro.
    

    ASSIGN aux_cdcritic = 0 
           aux_dscritic = ""
           aux_nrsequen = 0.

    DO aux_contador = 1 TO 10:
       
       FIND crapcdb WHERE crapcdb.cdcooper = par_cdcooper AND
                          crapcdb.nrborder = par_nrborder AND
                          crapcdb.nrdconta = par_nrdconta AND
                          crapcdb.cdcmpchq = par_cdcmpchq AND
                          crapcdb.cdbanchq = par_cdbanchq AND
                          crapcdb.cdagechq = par_cdagechq AND
                          crapcdb.nrctachq = par_nrctachq AND
                          crapcdb.nrcheque = par_nrcheque USE-INDEX crapcdb7
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
           
       IF NOT AVAILABLE crapcdb THEN
          IF LOCKED crapcdb THEN
             DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro em uso. Tente novamente."
                       aux_nrsequen = aux_nrsequen + 1.
                NEXT.

             END.
          ELSE
             DO:
                 ASSIGN aux_cdcritic = 244.
                        
                 LEAVE.

             END. 
    END.          
    
    DO aux_contador = 1 TO 10:

       FIND crapcec WHERE crapcec.cdcooper = crapcdb.cdcooper AND
                          crapcec.cdcmpchq = crapcdb.cdcmpchq AND
                          crapcec.cdbanchq = crapcdb.cdbanchq AND
                          crapcec.cdagechq = crapcdb.cdagechq AND
                          crapcec.nrctachq = crapcdb.nrctachq AND
                          crapcec.nrcpfcgc = par_nrcpfcgc                    
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                      
       IF NOT AVAILABLE crapcec THEN
          IF LOCKED crapcec THEN
             DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro em uso. Tente novamente." 
                       aux_nrsequen = aux_nrsequen + 1.
                NEXT.
       
             END.
          ELSE
             DO:
                ASSIGN aux_cdcritic = 009
                       aux_dscritic = "".

                LEAVE.
       
            END.
       
       ASSIGN crapcec.nmcheque = par_auxnmchq
              crapcec.nrcpfcgc = par_auxnrcpf
              crapcdb.nrcpfcgc = par_auxnrcpf
              aux_dscritic = "".
               
       LEAVE.
              
    END.
    
    
    IF (aux_dscritic <> "" AND aux_cdcritic <> 0) THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT aux_nrsequen, 
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + 
                              " - " + STRING(TIME,"HH:MM:SS") + " '-->' " +
                              STRING(aux_dscritic) + " >> log/descto.log").

            
            RETURN "NOK".

        END.
        
    UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - "
                     + STRING(TIME,"HH:MM:SS") + " '-->' Operador "  +
                     STRING(par_cdoperad) + " " + "alterou"          + 
                     " o CPF/CNPJ de numero " + STRING(par_nrcpfcgc) +
                     " para  " + STRING(par_auxnrcpf)                + 
                     ", nome do emitente do cheque de " + STRING(par_nmcheque) 
                     + " para " + STRING(par_auxnmchq) + ", do cheque de numero "
                     + STRING(par_nrcheque)+ ", banco " + STRING(par_cdbanchq)
                     + ", agencia " + STRING(par_cdagechq) + ", conta " 
                     + STRING(par_nrctachq) + "." + " >> log/descto.log").
        

    RETURN "OK".

END PROCEDURE. /* Alterar_cheques_descontados */

/************************************************************************/

PROCEDURE busca_descontos:
    /************************************************************************
    Objetivo: Busca de desctos de cheque e titulos para exibr no InternetBank
    ************************************************************************/

    DEF INPUT   PARAMETER par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT   PARAMETER par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT   PARAMETER par_nrdconta AS INTE                        NO-UNDO.
    DEF OUTPUT  PARAMETER par_vltotdsc AS DECI                        NO-UNDO.
    DEF OUTPUT  PARAMETER par_qttotdsc AS DECI                        NO-UNDO.
    DEF OUTPUT  PARAMETER par_vldsctit AS DECI                        NO-UNDO.
    DEF OUTPUT  PARAMETER par_qtdsctit AS DECI                        NO-UNDO.
    DEF OUTPUT  PARAMETER par_vldscchq AS DECI                        NO-UNDO.
    DEF OUTPUT  PARAMETER par_qtdscchq AS DECI                        NO-UNDO.

    DEF VAR h-b1wgen0030 AS HANDLE                                    NO-UNDO.

    /*  Totaliza o montante de descontos em cheque e titulos e no geral  */
    ASSIGN par_vltotdsc = 0
           par_qttotdsc = 0
           par_vldsctit = 0
           par_qtdsctit = 0
           par_vldscchq = 0
           par_qtdscchq = 0.

    IF  NOT VALID-HANDLE(h-b1wgen0030) THEN
        RUN sistema/generico/procedures/b1wgen0030.p
        PERSISTENT SET h-b1wgen0030.
    
    /* Valor total de Descontos */
    RUN busca_total_descontos IN h-b1wgen0030 (INPUT par_cdcooper,
                                               INPUT 0,     /** agencia  **/
                                               INPUT 0,     /** caixa    **/
                                               INPUT "996",   /** Operador **/
                                               INPUT par_dtmvtolt,
                                               INPUT par_nrdconta,
                                               INPUT 1,     /** idseqttl **/
                                               INPUT 1,     /** origem   **/
                                               INPUT "INTERNETBANK",
                                               INPUT FALSE, /** log      **/
                                              OUTPUT TABLE tt-tot_descontos).

    IF  VALID-HANDLE(h-b1wgen0030) THEN
        DELETE PROCEDURE h-b1wgen0030.

    FIND FIRST tt-tot_descontos NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-tot_descontos  THEN
        ASSIGN par_vltotdsc = tt-tot_descontos.vltotdsc
               par_qttotdsc = tt-tot_descontos.qttotdsc
               par_vldsctit = tt-tot_descontos.vldsctit
               par_qtdsctit = tt-tot_descontos.qtdsctit
               par_vldscchq = tt-tot_descontos.vldscchq
               par_qtdscchq = tt-tot_descontos.qtdscchq.

    RETURN "OK".

END PROCEDURE.

/************************************************************************/

PROCEDURE busca_limite_chq_bordero:
    /************************************************************************
    Objetivo: Consulta Limite Valor de Cheques do Cooperado - InternetBank
    Operacao 129
    ************************************************************************/
    DEF INPUT  PARAMETER par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT  PARAMETER par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_nrdcaixa AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_cdoperad AS CHAR                        NO-UNDO.
    DEF INPUT  PARAMETER par_nmdatela AS CHAR                        NO-UNDO.
    DEF INPUT  PARAMETER par_idorigem AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_nrdconta AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_idseqttl AS INTE                        NO-UNDO.
    
    DEF OUTPUT PARAMETER par_vllimite AS DECI                        NO-UNDO.
    DEF OUTPUT PARAMETER par_vlutiliz AS DECI                        NO-UNDO.

    DEF VAR aux_vltotdsc AS DECI                                     NO-UNDO.
    DEF VAR aux_qttotdsc AS DECI                                     NO-UNDO.
    DEF VAR aux_vldsctit AS DECI                                     NO-UNDO.
    DEF VAR aux_qtdsctit AS DECI                                     NO-UNDO.
    DEF VAR aux_vldscchq AS DECI                                     NO-UNDO.
    DEF VAR aux_qtdscchq AS DECI                                     NO-UNDO.

    /* Inicializa Variavel */
    ASSIGN par_vllimite = 0
           par_vlutiliz = 0.

    /* Busca o limite de credito */
    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper
                         AND craplim.nrdconta = par_nrdconta
                         AND craplim.tpctrlim = 2
                         AND craplim.insitlim = 2  /* ATIVO */
                         NO-LOCK NO-ERROR.

    IF  AVAILABLE craplim   THEN
        ASSIGN par_vllimite = craplim.vllimite.


    /* Valor total de Descontos */
    RUN busca_descontos (INPUT par_cdcooper,
                         INPUT par_dtmvtolt,
                         INPUT par_nrdconta,
                         OUTPUT aux_vltotdsc,
                         OUTPUT aux_qttotdsc,
                         OUTPUT aux_vldsctit,
                         OUTPUT aux_qtdsctit,
                         OUTPUT aux_vldscchq,
                         OUTPUT aux_qtdscchq).     
    
    ASSIGN par_vlutiliz = aux_vldscchq.

    RETURN "OK".

END PROCEDURE.

/************************************************************************/

PROCEDURE busca_limite_tit_bordero:
    /************************************************************************
    Objetivo: Consulta Limite Valor de Titulos do Cooperado - InternetBank
    ************************************************************************/
    DEF INPUT  PARAMETER par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT  PARAMETER par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_nrdcaixa AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_cdoperad AS CHAR                        NO-UNDO.
    DEF INPUT  PARAMETER par_nmdatela AS CHAR                        NO-UNDO.
    DEF INPUT  PARAMETER par_idorigem AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_nrdconta AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_idseqttl AS INTE                        NO-UNDO.
    
    DEF OUTPUT PARAMETER par_vllimite AS DECI                        NO-UNDO.
    DEF OUTPUT PARAMETER par_vldsctit AS DECI                        NO-UNDO.

    DEF VAR aux_vltotdsc AS DECI                                     NO-UNDO.
    DEF VAR aux_qttotdsc AS DECI                                     NO-UNDO.
    DEF VAR aux_vldsctit AS DECI                                     NO-UNDO.
    DEF VAR aux_qtdsctit AS DECI                                     NO-UNDO.
    DEF VAR aux_vldscchq AS DECI                                     NO-UNDO.
    DEF VAR aux_qtdscchq AS DECI                                     NO-UNDO.

    DEF VAR h-b1wgen0030 AS HANDLE                                   NO-UNDO.

    /* Inicializa Variavel */
    ASSIGN par_vllimite = 0
           par_vldsctit = 0.

    IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
        RUN sistema/generico/procedures/b1wgen0030.p
        PERSISTENT SET h-b1wgen0030.
    
    RUN busca_dados_dsctit IN h-b1wgen0030
                          (INPUT par_cdcooper,
                           INPUT 0, /*agenci*/
                           INPUT 0, /*nrdcaixa*/
                           INPUT "996", /*cdoperad*/
                           INPUT par_dtmvtolt,
                           INPUT 3, /*origem*/
                           INPUT par_nrdconta,
                           INPUT 1, /*seqttl */
                           INPUT par_nmdatela,
                           INPUT TRUE, /* LOG */
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-desconto_titulos).

    IF  VALID-HANDLE(h-b1wgen0030)  THEN
        DELETE PROCEDURE h-b1wgen0030.
    
    FIND FIRST tt-desconto_titulos NO-LOCK NO-ERROR.

    IF  AVAIL tt-desconto_titulos  THEN
        ASSIGN par_vllimite = tt-desconto_titulos.vllimite.

    /* Valor total de Descontos */
    RUN busca_descontos (INPUT par_cdcooper,
                         INPUT par_dtmvtolt,
                         INPUT par_nrdconta,
                         OUTPUT aux_vltotdsc,
                         OUTPUT aux_qttotdsc,
                         OUTPUT aux_vldsctit,
                         OUTPUT aux_qtdsctit,
                         OUTPUT aux_vldscchq,
                         OUTPUT aux_qtdscchq).
    
    ASSIGN par_vldsctit = aux_vldsctit.

    RETURN "OK".

END PROCEDURE.

/************************************************************************/

PROCEDURE consulta_desconto_cheques:
    /************************************************************************
    Objetivo: Consulta dos Bordero de Cheques do Cooperado - InternetBank
    Operacao 129
    ************************************************************************/
    DEF INPUT  PARAMETER par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT  PARAMETER par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_nrdcaixa AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_cdoperad AS CHAR                        NO-UNDO.
    DEF INPUT  PARAMETER par_nmdatela AS CHAR                        NO-UNDO.
    DEF INPUT  PARAMETER par_idorigem AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_nrdconta AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_idseqttl AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_dtiniper AS DATE                        NO-UNDO.
    DEF INPUT  PARAMETER par_dtfimper AS DATE                        NO-UNDO.
    DEF INPUT  PARAMETER par_flgregis AS LOGICAL                     NO-UNDO.

    DEF OUTPUT PARAMETER TABLE FOR tt-resumo-bordero.
    
    DEF VAR aux_contador AS INTE                                     NO-UNDO.
    DEF VAR aux_flglibch AS LOGICAL                                  NO-UNDO.
    DEF VAR aux_qtcompln AS INTE                                     NO-UNDO.
    DEF VAR aux_vlcompcr AS DECI                                     NO-UNDO.
   
    EMPTY TEMP-TABLE tt-resumo-bordero.

    ASSIGN aux_contador = 0.

    /* Busca os Cheques de Bordero Descontados */
    FOR EACH crapbdc NO-LOCK
       WHERE crapbdc.cdcooper = par_cdcooper
         AND crapbdc.nrdconta = par_nrdconta
         AND ((par_flgregis = FALSE
         AND  crapbdc.dtmvtolt >= par_dtiniper
         AND  crapbdc.dtmvtolt <= par_dtfimper)
          OR  par_flgregis = TRUE)
         BY crapbdc.dtmvtolt DESC:

        IF  crapbdc.dtlibbdc <> ? THEN
            IF  (crapbdc.dtlibbdc < par_dtmvtolt - 90) THEN DO:
                ASSIGN aux_flglibch = NO.

                IF  crapbdc.nrdconta <> 85448   THEN DO:
                    FIND FIRST crapcdb NO-LOCK
                         WHERE crapcdb.cdcooper = par_cdcooper
                           AND crapcdb.nrdconta = crapbdc.nrdconta
                           AND crapcdb.nrborder = crapbdc.nrborder
                           AND crapcdb.dtlibera > par_dtmvtolt
                           USE-INDEX crapcdb7 NO-ERROR.

                    IF  AVAIL crapcdb THEN
                        ASSIGN aux_flglibch = YES.

                END.

                IF   NOT aux_flglibch   THEN  
                     NEXT. 

            END.

        FIND craplot WHERE craplot.cdcooper = par_cdcooper 
                       AND craplot.dtmvtolt = crapbdc.dtmvtolt
                       AND craplot.cdagenci = crapbdc.cdagenci
                       AND craplot.cdbccxlt = crapbdc.cdbccxlt
                       AND craplot.nrdolote = crapbdc.nrdolote
                       NO-LOCK NO-ERROR.
                       
        IF  NOT AVAILABLE craplot   THEN
            ASSIGN aux_qtcompln = 0
                   aux_vlcompcr = 0.
        ELSE
            ASSIGN aux_qtcompln = craplot.qtcompln
                   aux_vlcompcr = craplot.vlcompcr.
    
        CREATE tt-resumo-bordero.
        ASSIGN tt-resumo-bordero.dtmvtolt = crapbdc.dtmvtolt
               tt-resumo-bordero.nrborder = crapbdc.nrborder
               tt-resumo-bordero.vlcheque = aux_vlcompcr
               tt-resumo-bordero.qtcheque = aux_qtcompln.

    END. /* Fim do FOR EACH */

    RETURN "OK".

END PROCEDURE. /* consulta_desconto_cheques */

/************************************************************************/


/************************************************************************/

PROCEDURE detalhe_desconto_cheques:
    /************************************************************************
    Objetivo: Consulta Detalhes do Bordero de Cheques do Cooperado -
    InternetBank - Operacao 131. Detalhes da Operacao 129
    ************************************************************************/

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrborder AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagin AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_qtcheque AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-detalhes-bordero.

    EMPTY TEMP-TABLE tt-resumo-bordero.

    FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper
                       AND crapcdb.nrborder = par_nrborder
                       NO-LOCK:

        ASSIGN par_qtcheque = par_qtcheque + 1.

        IF  par_qtcheque < par_nriniseq                    OR
            par_qtcheque >= (par_nriniseq + par_nrregist)  THEN
            NEXT.

        CREATE tt-detalhes-bordero.
        ASSIGN tt-detalhes-bordero.dtlibera = crapcdb.dtlibera
               tt-detalhes-bordero.cdbanchq = crapcdb.cdbanchq
               tt-detalhes-bordero.cdagechq = crapcdb.cdagechq
               tt-detalhes-bordero.nrctachq = crapcdb.nrctachq
               tt-detalhes-bordero.nrcheque = crapcdb.nrcheque
               tt-detalhes-bordero.vlcheque = crapcdb.vlcheque
               tt-detalhes-bordero.dtdevolu = crapcdb.dtdevolu.
    
    END. /* Fim do FOR EACH */

END PROCEDURE. /* detalhe_desconto_cheques */

/************************************************************************/

PROCEDURE consulta_desconto_titulos:
    /************************************************************************
    Objetivo: Consulta dos Bordero de Titulos do Cooperado - InternetBank
    Operacao 130
    ************************************************************************/
    DEF INPUT  PARAMETER par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT  PARAMETER par_cdagenci AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_nrdcaixa AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_cdoperad AS CHAR                        NO-UNDO.
    DEF INPUT  PARAMETER par_nmdatela AS CHAR                        NO-UNDO.
    DEF INPUT  PARAMETER par_idorigem AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_nrdconta AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_idseqttl AS INTE                        NO-UNDO.
    DEF INPUT  PARAMETER par_dtiniper AS DATE                        NO-UNDO.
    DEF INPUT  PARAMETER par_dtfimper AS DATE                        NO-UNDO.
    DEF INPUT  PARAMETER par_flgregis AS LOGICAL                     NO-UNDO.

    DEF OUTPUT PARAMETER TABLE FOR tt-titulo-bordero.
    
    DEF VAR aux_contador AS INT                         NO-UNDO.
   
    EMPTY TEMP-TABLE tt-titulo-bordero.

    ASSIGN aux_contador = 0.

    /* Busca os Titulos de Bordero Descontados */
    FOR EACH crapbdt WHERE crapbdt.cdcooper = par_cdcooper
                       AND crapbdt.nrdconta = par_nrdconta
                       AND ((par_flgregis = FALSE
                       AND  crapbdt.dtmvtolt >= par_dtiniper
                       AND  crapbdt.dtmvtolt <= par_dtfimper)
                        OR  par_flgregis = TRUE) NO-LOCK
       ,EACH craptdb WHERE craptdb.cdcooper = crapbdt.cdcooper
                       AND craptdb.nrdconta = crapbdt.nrdconta
                       AND craptdb.nrborder = crapbdt.nrborder NO-LOCK
                       BREAK BY crapbdt.dtmvtolt
                             BY crapbdt.nrborder:

        /* 
            Borderos liberados ate 90 dias 
            Borderos liberados a mais de 90 dias com titulos pendentes 
            Todos os borderos nao liberados
        */    
        IF  crapbdt.dtlibbdt <> ?  THEN
            IF (crapbdt.dtlibbdt < par_dtmvtolt - 90) AND
                crapbdt.insitbdt = 4                  THEN  
                NEXT.

        /*IF  FIRST-OF(crapbdt.dtmvtolt) THEN DO: /* Separar por dtmvtolt */*/
            IF  FIRST-OF(crapbdt.nrborder) THEN DO: /* Separar por bordero */

                CREATE tt-titulo-bordero.
                ASSIGN tt-titulo-bordero.dtmvtolt = crapbdt.dtmvtolt
                       tt-titulo-bordero.nrborder = crapbdt.nrborder.
            END.
        /*END.*/

        /* Soma os valores de cheque */
        ASSIGN aux_contador = aux_contador + 1
               tt-titulo-bordero.vltitulo = tt-titulo-bordero.vltitulo +
                                            craptdb.vltitulo
               tt-titulo-bordero.vlliquid = tt-titulo-bordero.vlliquid +
                                            craptdb.vlliquid.

        IF  LAST-OF(crapbdt.nrborder) THEN DO:  /* Quantidade de cheques */
            ASSIGN tt-titulo-bordero.qttitulo = aux_contador
                   aux_contador = 0.
        END.

    END. /* Fim do FOR EACH */

    RETURN "OK".

END PROCEDURE. /* consulta_desconto_titulos */

/************************************************************************/

PROCEDURE detalhe_desconto_titulos:
    /************************************************************************
    Objetivo: Consulta Detalhes do Bordero de Titulos do Cooperado -
    InternetBank - Operacao 132. Detalhes da Operacao 130
    ************************************************************************/

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrborder AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagin AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_qtcheque AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-detalhes-titulo.

    EMPTY TEMP-TABLE tt-resumo-bordero.

    FOR EACH craptdb WHERE  craptdb.cdcooper = par_cdcooper
                       AND  craptdb.nrdconta = par_nrdconta
                       AND  craptdb.nrborder = par_nrborder NO-LOCK
       ,EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper
                       AND crapcob.cdbandoc = craptdb.cdbandoc
                       AND crapcob.nrdctabb = craptdb.nrdctabb
                       AND crapcob.nrdconta = craptdb.nrdconta
                       AND crapcob.nrcnvcob = craptdb.nrcnvcob
                       AND crapcob.nrdocmto = craptdb.nrdocmto
                       AND crapcob.flgregis = TRUE
                       NO-LOCK BY craptdb.dtlibbdt
                               BY craptdb.nrborder:

        ASSIGN par_qtcheque = par_qtcheque + 1.

        IF  par_qtcheque < par_nriniseq                    OR
            par_qtcheque >= (par_nriniseq + par_nrregist)  THEN
            NEXT.

        CREATE tt-detalhes-titulo.
        ASSIGN tt-detalhes-titulo.dtlibbdt = craptdb.dtlibbdt
               tt-detalhes-titulo.cdbandoc = craptdb.cdbandoc
               tt-detalhes-titulo.nrcnvcob = craptdb.nrcnvcob
               tt-detalhes-titulo.nrdocmto = craptdb.nrdocmto
               tt-detalhes-titulo.vltitulo = craptdb.vltitulo
               tt-detalhes-titulo.vlliquid = craptdb.vlliquid
               tt-detalhes-titulo.dtvencto = craptdb.dtvencto
               tt-detalhes-titulo.dtresgat = craptdb.dtresgat
               tt-detalhes-titulo.vlliqres = craptdb.vlliqres
               tt-detalhes-titulo.tpcobran = IF  crapcob.flgregis = TRUE AND
                                                 crapcob.cdbandoc = 085  THEN
                                                 "Coop. Emite"
                                             ELSE 
                                             IF  crapcob.flgregis = TRUE  AND
                                                 crapcob.cdbandoc <> 085 THEN 
                                                "Banco Emite"
                                             ELSE
                                             IF  crapcob.flgregis = FALSE THEN 
                                                 "S/registro"
                                             ELSE
                                                 " ".
    
    END. /* Fim do FOR EACH */

END PROCEDURE. /* detalhe_desconto_titulos */

PROCEDURE pc_situacao_canal_recarga:
    /************************************************************************
    Objetivo: Consulta a situação da recarga de celular em cada canal
    ************************************************************************/

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM par_flgsitrc AS LOGI                          NO-UNDO.
    
    RUN STORED-PROCEDURE pc_situacao_canal_recarga
	  aux_handproc = PROC-HANDLE NO-ERROR
						 (INPUT par_cdcooper, /* Cooperativa*/
						  INPUT par_idorigem, /* Id origem*/
						  OUTPUT 0,           /* Flag situacao recarga (0-INATIVO/1-ATIVO) */
						  OUTPUT 0,           /* Código da crítica.*/
						  OUTPUT "").         /* Desc. da crítica */
	
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_situacao_canal_recarga
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    /* Busca parametros retornados */ 
    ASSIGN par_flgsitrc = FALSE
           aux_dscritic = ""
           par_flgsitrc = TRUE
                          WHEN pc_situacao_canal_recarga.pr_flgsitrc = 1
           aux_dscritic = pc_situacao_canal_recarga.pr_dscritic
                          WHEN pc_situacao_canal_recarga.pr_dscritic <> ?.
    
    IF aux_dscritic <> "" THEN
      RETURN "NOK".
    

END PROCEDURE. 

/************************************************************************/

