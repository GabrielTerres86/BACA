CREATE OR REPLACE PACKAGE CECRED.FOLH0002 AS

/*..............................................................................

   Programa: FOLH0002                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Maio/2015                      Ultima atualizacao: 05/07/2018

   Dados referentes ao programa:

   Frequencia: -------------------
   Objetivo  : Centralizar os procedimentos e funcoes de tela referente a
               folha de pagamento.

   Alteracoes: 18/12/2015 - Criado proc. pc_hrlimite, para listar horario limite de
                            Folha Pagamento. (Jorge/David) Proj. 131 Asinatura Multipla.

               05/07/2018 - Inclusao das tags de cdtarifa e cdfaixav no XML de saída
                            das procedures: pc_valida_pagto_ib, pc_busca_opcao_deb_ib
                            e pc_lista_pgto_pend_ib, Prj.363 (Jean Michel).

..............................................................................*/


   /* Pl-Table que ira armazenar os dados de folha de pagamento */
   TYPE typ_reg_pagamento IS
      RECORD(tpregist   NUMBER(1)
            ,indrowid   VARCHAR2(32767)
            ,dtmvtolt   DATE
            ,dssitpgt   VARCHAR(20)
            ,qtlctpag   NUMBER(10,2)
            ,vllctpag   NUMBER(18,2)
            ,vltarifa   NUMBER(10,2)
            ,dtdebito   DATE
            ,imgdebto   VARCHAR2(32767)
            ,hintdebt   VARCHAR2(32767)
            ,dtcredit   DATE
            ,imgcredt   VARCHAR2(32767)
            ,hintcred   VARCHAR2(32767)
            ,imgcompr   VARCHAR2(32767)
            ,hintcomp   VARCHAR2(32767)
            ,dthorage   VARCHAR2(32767)
            ,dsdetapr   VARCHAR2(32767)
            ,dsdetest   VARCHAR2(32767)
            ,dthordeb   VARCHAR2(32767)
            ,dthorcre   VARCHAR2(32767)
            ,dthortar   VARCHAR2(32767)
            ,exibestr   VARCHAR2(32767)
            ,dscomprv   VARCHAR2(32767)
            ,cdempres   crapemp.cdempres%TYPE
            ,idtppagt   VARCHAR2(32767)
            ,idsitapr   crappfp.idsitapr%TYPE
            ,envcompr   NUMBER(3)
            ,nrseqpag   crappfp.nrseqpag%TYPE
            ,dthrdebi   VARCHAR2(32767)
            ,dthrcred   VARCHAR2(32767)
            ,dthrtari   VARCHAR2(32767)            
            ,idsitdeb   NUMBER(1)
            ,idsitcre   NUMBER(1)
            ,idsitpgt   NUMBER(1)
            ,dstpapgt   VARCHAR2(32767));

   /* Pl-Table que ira armazenar os dados de pagamento enviados p/ aprovacao */
   TYPE typ_reg_pgto IS
      RECORD(nrdconta   crapemp.nrdconta%TYPE
            ,cdorigem   crapofp.cdorigem%TYPE
            ,vllctpag   crappfp.vllctpag%TYPE
            ,nrcpfemp   crapefp.nrcpfemp%TYPE
            ,cdempres   crapemp.cdempres%TYPE
            ,idtpcont   craplfp.idtpcont%TYPE
            ,rowidlfp   VARCHAR2(100));

   /* Pl-Table que ira armazenar as contas e origens duplicadas para informar ao usuario */
   TYPE typ_reg_origem IS
      RECORD(nrdconta   crapemp.nrdconta%TYPE
            ,dsorigem   VARCHAR2(100));

   /* Pl-Table que ira chave e valor de registros inseridos */
   TYPE typ_reg_log IS
      RECORD(valor_old crapprm.dsvlrprm%TYPE
            ,valor_new crapprm.dsvlrprm%TYPE);

   /* Pl-Table que ira chave e valor dos registros da CRAPPRM */
   TYPE typ_reg_consulta_prm IS
      RECORD(dsvlrprm crapprm.dsvlrprm%TYPE);

   TYPE typ_tab_pagamento IS TABLE OF typ_reg_pagamento    INDEX BY BINARY_INTEGER;
   TYPE typ_tab_pgto      IS TABLE OF typ_reg_pgto         INDEX BY BINARY_INTEGER;
   TYPE typ_tab_origem    IS TABLE OF typ_reg_origem       INDEX BY VARCHAR2(20);
   TYPE typ_log           IS TABLE OF typ_reg_log          INDEX BY BINARY_INTEGER;
   TYPE typ_verifica_log  IS TABLE OF typ_log              INDEX BY BINARY_INTEGER;
   TYPE typ_consulta_prm  IS TABLE OF typ_reg_consulta_prm INDEX BY BINARY_INTEGER;

   -- Procedimento de gravacao de tarifas de convenios
   PROCEDURE pc_grava_crapcfp(pr_cdcontar IN VARCHAR2
                             ,pr_dscontar IN VARCHAR2
                             ,pr_rowid    IN VARCHAR2
                             ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

   -- Procedimento para excluir tarifas de convenios desnecessarias
   PROCEDURE pc_excluir_crapcfp(pr_rowid    IN VARCHAR2
                               ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

   -- Busca dados para exibir na tela CRAPCFP
   PROCEDURE pc_lista_dados_crapcfp(pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

   -- Procedimento de gravacao de origens de folha de pagamento
   PROCEDURE pc_grava_crapofp(pr_cdoriflh IN VARCHAR2
                             ,pr_dsoriflh IN VARCHAR2
                             ,pr_idvarmes IN VARCHAR2
                             ,pr_cdhisdeb IN VARCHAR2
                             ,pr_cdhsdbcp IN VARCHAR2
                             ,pr_cdhiscre IN VARCHAR2
                             ,pr_cdhscrcp IN VARCHAR2
                             ,pr_fldebfol IN VARCHAR2
                             ,pr_rowid    IN VARCHAR2
                             ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

   -- Busca dados para exibir na tela CRAPOFP
   PROCEDURE pc_lista_dados_crapofp(pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

   -- Procedimento para excluir origens de pagamentos desnecessarias
   PROCEDURE pc_excluir_crapofp(pr_rowid    IN VARCHAR2
                               ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

   -- Realiza a gravação dos parametros da Folha IB informados na tela PARFOL
   PROCEDURE pc_grava_prm_folhaib(pr_dsvlrprm1   IN VARCHAR2  -- Qtde meses cancelamento automático
                                 ,pr_dsvlrprm2   IN VARCHAR2  -- Qtde dias para envio comprovantes
                                 ,pr_dsvlrprm3   IN VARCHAR2  -- Nro meses para emissão dos Comprovantes
                                 ,pr_dsvlrprm4   IN VARCHAR2  -- Histórico Débito Tarifa
                                 ,pr_dsvlrprm5   IN VARCHAR2  -- Histórico Estorno Outras Empresas
                                 ,pr_dsvlrprm6   IN VARCHAR2  -- Histórico Estorno para Cooperativas
                                 ,pr_dsvlrprm7   IN VARCHAR2  -- E-mails para alerta na Central
                                 ,pr_dsvlrprm8   IN VARCHAR2  -- Agendamento
                                 ,pr_dsvlrprm9   IN VARCHAR2  -- Portabilidade (Pgto no dia)
                                 ,pr_dsvlrprm10  IN VARCHAR2  -- Solicitação Estouro Conta
                                 ,pr_dsvlrprm11  IN VARCHAR2  -- Liberação Estouro Conta
                                 ,pr_dsvlrprm12  IN VARCHAR2  -- Lote
                                 ,pr_dsvlrprm13  IN VARCHAR2  -- Histórico Crédito TEC
                                 ,pr_dsvlrprm14  IN VARCHAR2  -- Histórico Débito TEC
                                 ,pr_dsvlrprm15  IN VARCHAR2  -- Histórico Recusa TEC
                                 ,pr_dsvlrprm16  IN VARCHAR2  -- Histórico Devolução TEC
                                 ,pr_dsvlrprm17  IN VARCHAR2  -- Histórico Devolução Empresa
                                 ,pr_dsvlrprm18  IN VARCHAR2  -- Lote TRF
                                 ,pr_dsvlrprm19  IN VARCHAR2  -- Histórico Débito TRF
                                 ,pr_dsvlrprm20  IN VARCHAR2  -- Histórico Crédito TRF
                                 ,pr_dsvlrprm21  IN VARCHAR2  -- E-mails para alerta ao Financeiro
                                 ,pr_dsvlrprm22  IN VARCHAR2  -- Pagto no dia (contas cooperativa)
                                 ,pr_dsvlrprm23  IN VARCHAR2  -- Habilita Transferência
                                 ,pr_dsvlrprm24  IN VARCHAR2  
                                 ,pr_dsvlrprm25  IN VARCHAR2
                                 ,pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);           --> Erros do processo

   -- Realiza a gravação dos parametros da Folha IB informados na tela PRMSFP
   PROCEDURE pc_consulta_prm_folhaib(pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2);           --> Erros do processo

   -- Busca dados para exibir na tela ESTPFP
   PROCEDURE pc_lista_dados_estpfp(pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

   -- Rotina de aprovacao/reprovacao de folha de pagamento
   PROCEDURE pc_aprova_reprova_pagto(pr_dsjustif IN VARCHAR2
                                    ,pr_dsmsgeml IN VARCHAR2
                                    ,pr_cdeftpag IN VARCHAR2
                                    ,pr_cdempres IN VARCHAR2
                                    ,pr_dtsolest IN VARCHAR2
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

   -- Procedimento para validar horario limite para aprovar e reprovar estouro de folha de pagamento
   PROCEDURE pc_hrlimite_estouro(pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo


  /* Realiza listagem das cooperativas que serão listadas nos parametros de pesquisa da tela RLPGFP */
  PROCEDURE pc_lista_coop_pesquisa(pr_xmllog     IN VARCHAR2             --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);           --> Erros do processo

  -- Rotina para montar a listagem das folhas de pagamento
  PROCEDURE pc_consulta_folhas_pagto(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                    ,pr_cdempres IN NUMBER                --> Código da empresa informado na tela
                                    ,pr_dtmvtolt IN VARCHAR2              --> Data do Movimento
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina para montar a listagem de detalhes das folhas de pagamento
  PROCEDURE pc_consulta_detalhes_pagto(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                      ,pr_cdempres IN NUMBER                --> Código da empresa selecionada na tela
                                    	,pr_nrseqpag IN NUMBER                --> Codigo da pagamentos selecionado na tela
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Buscar a flag que indica que o cooperado possui o acesso ao Folha de Pagamento
  PROCEDURE pc_busca_flgpgtib(pr_cdcooper    IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                             ,pr_nrdconta    IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                             ,pr_flgpgtib   OUT crapemp.flgpgtib%TYPE  -- Flag do folha de pagamento
                             ,pr_cdcritic   OUT INTEGER                -- Código do erro
                             ,pr_dscritic   OUT VARCHAR2);             -- Descricao do erro

  -- Realizar o envio dos e-mails de interesse do Folha de Pagamento
  PROCEDURE pc_envia_email_interesse(pr_cdcooper    IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                    ,pr_nrdconta    IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                    ,pr_cdcritic   OUT INTEGER                -- Código do erro
                                    ,pr_dscritic   OUT VARCHAR2);             -- Descricao do erro

  -- Procedure para termo de adesao e/ou cancelamento
  PROCEDURE pc_termo_adesao_cancel(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE
                                  ,pr_idorigem IN PLS_INTEGER
                                  ,pr_cdempres IN crapemp.cdempres%TYPE
                                  ,pr_imptermo IN PLS_INTEGER
                                  ,pr_lisconta IN VARCHAR2
                                  ,pr_nmarquiv OUT VARCHAR2
                                  ,pr_cdcritic OUT NUMBER
                                  ,pr_dscritic OUT VARCHAR2);

  -- Procedure encarregada de buscar os dados de folha de pagamento
  PROCEDURE pc_busca_dados_pagto_ib(pr_cdcooper   IN PLS_INTEGER
                                   ,pr_nrdconta   IN NUMBER
                                   ,pr_dtiniper   IN DATE
                                   ,pr_dtfimper   IN DATE
                                   ,pr_nrregist   IN NUMBER
                                   ,pr_nriniseq   IN NUMBER
                                   ,pr_cdcritic   OUT PLS_INTEGER
                                   ,pr_dscritic   OUT VARCHAR2
                                   ,pr_pagto_xml  OUT CLOB);

  -- Procedure encarregada de efetuar o cancelamento dos registros
  PROCEDURE pc_cancela_pagto_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                               ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                               ,pr_indrowid   IN VARCHAR2
                               ,pr_nrdconta   IN NUMBER
                               ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE
                               ,pr_cdcritic   OUT PLS_INTEGER
                               ,pr_dscritic   OUT VARCHAR2);

  -- Procedure encarregada de validar os registros selecionados
  PROCEDURE pc_valida_pagto_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                              ,pr_indrowid  IN VARCHAR2
														  ,pr_flvalsld  IN NUMBER																														
                              ,pr_nrcpfope  IN NUMBER																										
                              ,pr_des_reto  OUT VARCHAR2
                              ,pr_dscritic  OUT VARCHAR2
                              ,pr_retxml    OUT CLOB);

  -- Procedure de aprovacao dos pagamentos
  PROCEDURE pc_aprovar_pagto_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE
                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                               ,pr_nrcpfapr  IN crappfp.nrcpfapr%TYPE
                               ,pr_flsolest  IN NUMBER
                               ,pr_indrowid  IN VARCHAR2
                               ,pr_des_reto OUT VARCHAR2
                               ,pr_dsalerta OUT VARCHAR2
                               ,pr_dscritic OUT VARCHAR2);

   --  Procedure encarregada de validar a data de credito e retorna-la
   PROCEDURE pc_valid_dat_cred_ib(pr_cdcooper  IN PLS_INTEGER
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                 ,pr_nrdconta  IN NUMBER
                                 ,pr_cdcritic  OUT PLS_INTEGER
                                 ,pr_dscritic  OUT VARCHAR2
                                 ,pr_data_xml  OUT CLOB);

   -- Procedure encarregada de validar e retornar a data de debito para selecao
   PROCEDURE pc_busca_opcao_deb_ib(pr_cdcooper   IN PLS_INTEGER
                                  ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                  ,pr_nrdconta   IN NUMBER
                                  ,pr_cdcritic   OUT PLS_INTEGER
                                  ,pr_dscritic   OUT VARCHAR2
                                  ,pr_data_xml   OUT CLOB);

   -- Procedure encarregada de listar os pagamentos para aprovacao
   PROCEDURE pc_lista_pgto_pend_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                  ,pr_nrdconta   IN NUMBER
                                  ,pr_dsrowpfp   IN VARCHAR2
                                  ,pr_xmlpagto   OUT CLOB
                                  ,pr_cdcritic   OUT PLS_INTEGER
                                  ,pr_dscritic   OUT VARCHAR2);

   /* Eliminar um pagamento convencional no IB */
   PROCEDURE pc_exclui_lancto_pfp_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                    ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                    ,pr_nrdconta   IN NUMBER
                                    ,pr_rowidlfp   IN VARCHAR2
                                    ,pr_cdcritic   OUT PLS_INTEGER
                                    ,pr_dscritic   OUT VARCHAR2);

   -- Procedure encarregada de exibir lista de origens de pagamento
   PROCEDURE pc_lista_origem_pagto_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                     ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                     ,pr_nrdconta   IN NUMBER
                                     ,pr_data_xml   OUT CLOB
                                     ,pr_cdcritic   OUT PLS_INTEGER
                                     ,pr_dscritic   OUT VARCHAR2);
  
   /* Procedure encarregada de enviar os pagamentos para aprovacao */
   PROCEDURE pc_envia_pagto_apr_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                  ,pr_nrdconta   IN NUMBER
                                  ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE
                                  ,pr_dsrowpfp   IN VARCHAR2
                                  ,pr_idopdebi   IN NUMBER
                                  ,pr_dtcredit   IN DATE
                                  ,pr_dtdebito   IN DATE
                                  ,pr_vltarapr   IN NUMBER
                                  ,pr_gravarpg   IN NUMBER
                                  ,pr_dsdirarq   IN VARCHAR2
                                  ,pr_dsarquiv   IN VARCHAR2
                                  ,pr_dsdspscp   IN NUMBER
                                  ,pr_cdcritic   OUT PLS_INTEGER
                                  ,pr_dscritic   OUT VARCHAR2);

   -- Procedure encarregada de exibir lista de funcionarios cadastrados para empresa
   PROCEDURE pc_lista_empregados_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                   ,pr_nrdconta   IN NUMBER
                                   ,pr_data_xml   OUT CLOB
                                   ,pr_cdcritic   OUT PLS_INTEGER
                                   ,pr_dscritic   OUT VARCHAR2);

   -- Procedure para Trazer as informações iniciais da tela de comprovantes do IB
  PROCEDURE pc_valida_comprovante(pr_rowidpfp  IN VARCHAR2                --> Rowid da crappfp
                                 ,pr_pagto_xml OUT CLOB                   --> Info dos comprovantes carregados                                   ,pr_cdcritic OUT INTEGER                -- Código do erro
                                 ,pr_cdcritic  OUT PLS_INTEGER
                                 ,pr_dscritic  OUT VARCHAR2);           --> Erros do processo

  /* Procedure encarregada de cadastrar/atualizar funcionario para empresa */
  PROCEDURE pc_cadastra_empregado_ib(pr_nrdctemp IN crapass.nrdconta%TYPE
                                     ,pr_nrcpfemp IN NUMBER
                                     ,pr_nmprimtl IN VARCHAR2
                                     ,pr_dsdcargo IN VARCHAR2
                                     ,pr_dtadmiss IN VARCHAR2
                                     ,pr_dstelefo IN VARCHAR2
                                     ,pr_dsdemail IN VARCHAR2
                                     ,pr_nrregger IN VARCHAR2
                                     ,pr_nrodopis IN VARCHAR2
                                     ,pr_nrdactps IN VARCHAR2
                                     ,pr_altera   IN VARCHAR2
                                     ,pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                                     ,pr_nrcpfope IN crapopi.nrcpfope%TYPE
                                     ,pr_cdcritic   OUT PLS_INTEGER
                                     ,pr_dscritic   OUT VARCHAR2);

  /* Procedure encarregada de excluir um funcionario da empresa */
  PROCEDURE pc_exclui_empregado_ib(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE
                                  ,pr_nrcpfope IN crapopi.nrcpfope%TYPE
                                  ,pr_nrdctemp IN crapass.nrdconta%TYPE
                                  ,pr_nrcpfemp IN craplfp.nrcpfemp%TYPE
                                  ,pr_cdempres IN crapemp.cdempres%TYPE
                                  ,pr_idtpcont IN craplfp.idtpcont%TYPE
                                  ,pr_cdcritic OUT PLS_INTEGER
                                  ,pr_dscritic OUT VARCHAR2);

  /* Procedure para geracao do relatorio dos pagamentos de folha da empresa */
  PROCEDURE pc_gera_relatorio_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                 ,pr_nrctaemp  IN crapass.nrdconta%TYPE -- Conta empresa
                                 ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE -- Operador conectado
                                 ,pr_nrctalfp  IN crapass.nrdconta%TYPE -- Conta empregado
                                 ,pr_dtinisel  IN DATE
                                 ,pr_dtfimsel  IN DATE
                                 ,pr_insituac  IN INTEGER
                                 ,pr_tpemissa  IN VARCHAR2
                                 ,pr_iddspscp  IN NUMBER
                                 ,pr_nmarquiv OUT VARCHAR2
                                 ,pr_dssrvarq OUT VARCHAR2
                                 ,pr_dsdirarq OUT VARCHAR2
                                 ,pr_dscritic OUT VARCHAR2);

  --Procedure para impimir os comprovantes  HOLERITE
  PROCEDURE pc_impressao_comprovante(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta IN NUMBER
                                    ,pr_idtipfol IN NUMBER
                                    ,pr_rowidpfp IN VARCHAR2
                                    ,pr_iddspscp IN NUMBER
                                    ,pr_retxml   OUT VARCHAR2
                                    ,pr_cdcritic OUT PLS_INTEGER
                                    ,pr_dscritic OUT VARCHAR2);

  /* Procedure para trazer os holerites (comprovantes salariais) */
  PROCEDURE pc_lista_holerites_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta  IN craplfp.nrdconta%TYPE
                                  ,pr_idseqttl  IN craphdp.idseqttl%TYPE
                                  ,pr_clobxml  OUT CLOB
                                  ,pr_cdcritic OUT PLS_INTEGER
                                  ,pr_dscritic OUT VARCHAR2 );

  /* Rotina para buscar a quantidade de pagamentos pendentes */
  PROCEDURE pc_busca_pgto_pendente_ib(pr_cdcooper    IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                     ,pr_cdempres    IN crapemp.cdempres%TYPE  -- Código da empresa
                                     ,pr_inpagpen   OUT INTEGER                -- Flag do folha de pagamento
                                     ,pr_cdcritic   OUT INTEGER                -- Código do erro
                                     ,pr_dscritic   OUT VARCHAR2);             -- Descricao do erro

  -- Procedimento para validar horario limite folha de pagamento
  PROCEDURE pc_hrlimite( pr_cdcooper IN INTEGER      --> Codigo da Cooperativa
                        ,pr_hrlimage OUT VARCHAR2    --> Horario limite agenda
                        ,pr_hrlimptb OUT VARCHAR2    --> Horario limite portabilidade
                        ,pr_hrlimsol OUT VARCHAR2    --> Horario limite solicitacao Estorno
                        ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                        ,pr_dscritic OUT VARCHAR2);  --> Descricao da critica

  PROCEDURE pc_gera_retorno_cooperado(pr_cdcooper IN INTEGER       --> Codigo da Cooperativa
                                     ,pr_rowidpfp IN VARCHAR2      --> Rowid da crappfp                                                                    
                                     ,pr_clob_ret OUT CLOB         --> Arquivo de retorno          
                                     ,pr_cdcritic OUT PLS_INTEGER  --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2);   --> Descricao da critica
END FOLH0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.FOLH0002 AS

/*..............................................................................

   Programa: FOLH0002                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Maio/2015                      Ultima atualizacao: 15/02/2019

   Dados referentes ao programa:

   Frequencia: -------------------
   Objetivo  : Centralizar os procedimentos e funcoes de tela referente a
               folha de pagamento.

   Alteracoes: 23/11/2015 - Desconsiderando a posicao 4 do array de acessos
               (Andre Santos - SUPERO)

               18/12/2015 - Criado proc. pc_hrlimite, para listar horario limite de
                            Folha Pagamento. (Jorge/David) Proj. 131 Asinatura Multipla.

               19/01/2017 - Adicionado novo limite de horario para pagamento no dia
                            para contas da cooperativa. (M342 - Kelvin)  
               
               30/03/2017 - Ajuste referente a segunda fase da melhoria 342. (Kelvin)
               
               12/05/2017 - Segunda fase da melhoria 342 (Kelvin).
               
               21/06/2017 - Incluido razao social da empresa nos relatórios (Kelvin #682260)

               05/07/2018 - Inclusao das tags de cdtarifa e cdfaixav no XML de saída
                            das procedures: pc_valida_pagto_ib, pc_busca_opcao_deb_ib
                            e pc_lista_pgto_pend_ib, Prj.363 (Jean Michel).

               15/02/2019 - Na procedure pc_envia_pagto_apr_ib após o 
                            processamento do arquivo incluir o rm (Lucas Ranghetti #PRB0040468)
..............................................................................*/
   -- Arrays
   -- Campos da tela
   TYPE typ_dstabela   IS VARRAY(25) OF VARCHAR2(60);
   vr_tab_dscmptel     typ_dstabela := typ_dstabela('Qtde meses cancelamento automático'
                                                   ,'Qtde dias para envio comprovantes'
                                                   ,'Nro meses para emissão dos Comprovantes'
                                                   ,NULL --> Antigo: Histórico Débito Tarifa
                                                   ,'Histórico Estorno Outras Empresas'
                                                   ,'Histórico Estorno para Cooperativas'
                                                   ,'E-mails para alerta na Central'
                                                   ,'Agendamento'
                                                   ,'Portabilidade (Pgto no dia)'
                                                   ,'Solicitação Estouro Conta'
                                                   ,'Liberação Estouro Conta'
                                                   ,'Lote'
                                                   ,'Histórico Crédito TEC'
                                                   ,'Histórico Débito TEC'
                                                   ,'Histórico Recusa TEC'
                                                   ,'Histórico Devolução TEC'
                                                   ,'Histórico Devolução Empresa'
                                                   ,'Lote TRF'
                                                   ,'Histórico Débito TRF'
                                                   ,'Histórico Crédito TRF'
                                                   ,'E-mails para alerta ao Financeiro'
                                                   ,'Pagto no dia (contas cooperativa)'
                                                   ,'Habilita transferência tipo Crédito Salário (0=Não/1=Sim)'
                                                   ,'Transf no dia (tipo Crédito Salário)'
                                                   ,'Tarifa transferência tipo Crédito Salário (0=Isento/1=Sim)');

   vr_tab_cdacesso     typ_dstabela := typ_dstabela('FOLHAIB_QTD_MES_CANCELA'
                                                   ,'FOLHAIB_QTD_DIA_ENV_COMP'
                                                   ,'FOLHAIB_QTD_MES_EMI_COMP'
                                                   ,NULL --> Antigo: FOLHAIB_CDHISTOR_TARIFA
                                                   ,'FOLHAIB_HIS_ESTOR_EMPR'
                                                   ,'FOLHAIB_HIS_ESTOR_COOP'
                                                   ,'FOLHAIB_EMAIL_ALERT_PROC'
                                                   ,'FOLHAIB_HOR_LIM_AGENDA'
                                                   ,'FOLHAIB_HOR_LIM_PORTAB'
                                                   ,'FOLHAIB_HOR_LIM_SOL_EST'
                                                   ,'FOLHAIB_HOR_LIM_ANA_EST'
                                                   ,'FOLHAIB_NRLOTE_CTASAL'
                                                   ,'FOLHAIB_HIS_CRE_TECSAL'
                                                   ,'FOLHAIB_HIS_DEB_TECSAL'
                                                   ,'FOLHAIB_HIST_REC_TECSAL'
                                                   ,'FOLHAIB_HIST_DEV_TECSAL'
                                                   ,'FOLHAIB_HIST_EST_TECSAL'
                                                   ,'FOLHAIB_NRLOT_CTASAL_B85'
                                                   ,'FOLHAIB_HIST_DEB_TEC_B85'
                                                   ,'FOLHAIB_HIST_CRE_TEC_B85'
                                                   ,'FOLHAIB_EMAIL_ALERT_FIN'
                                                   ,'FOLHAIB_HOR_LIM_PAG_COOP'
                                                   ,'FOLHAIB_HABILITA_TRANSF'
                                                   ,'FOLHAIB_HR_LIM_TRF_TPSAL'
                                                   ,'FOLHAIB_TARI_TRF_TPSAL');
   /* Procedimento de gravacao de tarifas de convenios */
   PROCEDURE pc_grava_crapcfp(pr_cdcontar IN VARCHAR2
                             ,pr_dscontar IN VARCHAR2
                             ,pr_rowid    IN VARCHAR2
                             ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_grava_crapcfp
   --  Sistema  : AyllosWeb
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Maio/2015.                   Ultima atualizacao: 19/11/2015
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedimento de gravacao de tarifas de convenios
   --
   -- Alteracoes: 19/11/2015 - Gerando Log de Inclusao/Atualizacao da tela ORIFOL - Melhoria
   --                        -- Removendo a gravacao dos valores D0,D-1 e D-2
   --                          (Andre Santos - SUPERO)
   --
   ---------------------------------------------------------------------------------------------------------------

      -- Cursor
      -- Buscar as informacoes da cooperativa
      CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
         SELECT crapcop.cdbcoctl
               ,crapcop.cdagectl
               ,crapcop.nmrescop
           FROM crapcop
          WHERE crapcop.cdcooper = p_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca ultimo codigo de convenio tarifario +1
      CURSOR cr_chave_crapcfp(p_cdcooper crapcop.cdcooper%TYPE) IS
         SELECT NVL(MAX(cfp.cdcontar),0)+1
           FROM crapcfp cfp
          WHERE cfp.cdcooper = p_cdcooper;
      vr_deschave crapcfp.cdcontar%TYPE;

      -- Verifica se a descricao ja foi inserida
      CURSOR cr_crapcfp(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_dscontar crapcfp.dscontar%TYPE
                       ,p_rowid   VARCHAR2) IS
         SELECT cfp.dscontar
           FROM crapcfp cfp
          WHERE cfp.cdcooper = p_cdcooper
            AND ((p_rowid IS NULL
            AND LOWER(cfp.dscontar) LIKE LOWER(p_dscontar))
             OR (p_rowid IS NOT NULL
            AND LOWER(cfp.dscontar) LIKE LOWER(p_dscontar)
            AND cfp.rowid <> p_rowid));
      vr_dscontar crapcfp.dscontar%TYPE;

      -- Buscando os dados para gerar log
      CURSOR cr_dados_cfp(p_rowid VARCHAR2) IS
        SELECT cfp.cdcooper
              ,cfp.cdcontar
              ,cfp.dscontar
          FROM crapcfp cfp
         WHERE cfp.ROWID = p_rowid;
      rw_dados_cfp cr_dados_cfp%ROWTYPE;

      -- Variaveis
      vr_excerror EXCEPTION;

      vr_cdcooper    NUMBER;
      vr_nmdatela    VARCHAR2(25);
      vr_nmeacao     VARCHAR2(25);
      vr_cdagenci    VARCHAR2(25);
      vr_nrdcaixa    VARCHAR2(25);
      vr_idorigem    VARCHAR2(25);
      vr_cdoperad    VARCHAR2(25);

      rw_crapcfp_old crapcfp%ROWTYPE;
      rw_crapcfp_new crapcfp%ROWTYPE;

      vr_nrdrowid    ROWID;
      vr_dsorigem    VARCHAR2(100);
      vr_dstransa    VARCHAR2(100);

   BEGIN
      -- Inicializa Variavel
      pr_cdcritic := 0;
      pr_dscritic := NULL;
      pr_des_erro := NULL;

      -- Extrair informacoes padrao do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      -- Buscando descricao da origem do ambiente
      vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

      -- Buscar dados da cooperativa
      OPEN  cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
         -- Se nao encontrar dados
         IF cr_crapcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcop;
            pr_cdcritic := 9999;
            pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapcop;

      -- Validacao dos campos obrigatorios
      OPEN cr_crapcfp(vr_cdcooper
                     ,pr_dscontar
                     ,pr_rowid);
      FETCH cr_crapcfp INTO vr_dscontar;
         -- Gera Critica
         IF cr_crapcfp%FOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcfp;
            pr_cdcritic := 1;
            pr_des_erro := 'Favor informar outra descricao, pois a mesma ja esta em uso!';
            pr_nmdcampo := 'dscontar';
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapcfp;

      -- Se for atualizar, devemos buscar os dados
      -- para comparar com os dados novos
      IF pr_rowid IS NOT NULL THEN
         OPEN cr_dados_cfp(pr_rowid);
         FETCH cr_dados_cfp INTO rw_dados_cfp;
         -- Se nao encontra
         IF cr_dados_cfp%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_dados_cfp;
            pr_cdcritic := 9999;
            pr_des_erro := 'Registro nao localizado!';
            pr_nmdcampo := 'dscontar';
            RAISE vr_excerror;
         END IF;
         CLOSE cr_dados_cfp;
      END IF;

      -- Validacao dos campos obrigatorios
      IF pr_dscontar IS NULL THEN
         pr_cdcritic := 2;
         pr_des_erro := 'Descricao do convenio obrigatorio!';
         pr_nmdcampo := 'dscontar';
         RAISE vr_excerror;
      END IF;

      IF NVL(pr_rowid,' ') = ' ' OR pr_rowid IS NULL THEN -- Inserir

         OPEN cr_chave_crapcfp(vr_cdcooper);
         FETCH cr_chave_crapcfp INTO vr_deschave;
         CLOSE cr_chave_crapcfp;

         -- Insere o registro na CRAPCFP
         BEGIN
            INSERT INTO crapcfp(cdcooper
                               ,cdcontar
                               ,dscontar)
            VALUES(vr_cdcooper
                  ,vr_deschave
                  ,pr_dscontar);
         EXCEPTION
            WHEN OTHERS THEN
               pr_cdcritic := 9999;
               pr_des_erro := 'Erro ao inserir o registro na CRAPCFP: '||SQLERRM;
               pr_nmdcampo := 'dscontar';
               RAISE vr_excerror;
         END;

         vr_dstransa    := 'Registro inserido com sucesso - CONFOL.';
         -- Registro OLD
         rw_crapcfp_old.cdcontar := NULL;
         rw_crapcfp_old.dscontar := NULL;
         -- Registro NEW
         rw_crapcfp_new.cdcontar := vr_deschave;
         rw_crapcfp_new.dscontar := pr_dscontar;

      ELSE  -- Atualizacao
         -- Atualiza o registro na CRAPCFP
         BEGIN
            UPDATE crapcfp cfp
               SET cfp.cdcooper = vr_cdcooper
                  ,cfp.cdcontar = pr_cdcontar
                  ,cfp.dscontar = pr_dscontar
             WHERE cfp.rowid = pr_rowid;
         EXCEPTION
            WHEN OTHERS THEN
               pr_cdcritic := 9999;
               pr_des_erro := 'Erro ao atualizar o registro na CRAPCFP: '||SQLERRM;
               pr_nmdcampo := 'dscontar';
               RAISE vr_excerror;
         END;

         vr_dstransa    := 'Registro alterado com sucesso - CONFOL.';
         -- Registro OLD
         rw_crapcfp_old.cdcontar := rw_dados_cfp.cdcontar;
         rw_crapcfp_old.dscontar := rw_dados_cfp.dscontar;
         -- Registro NEW
         rw_crapcfp_new.cdcontar := rw_dados_cfp.cdcontar;
         rw_crapcfp_new.dscontar := pr_dscontar;
      END IF;

      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Log Item => Codigo Convenio
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Codigo Convenio'
                           , pr_dsdadant => rw_crapcfp_old.cdcontar
                           , pr_dsdadatu => rw_crapcfp_new.cdcontar);
      -- Log Item => Descricao Convenio
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Descricao Convenio'
                           , pr_dsdadant => rw_crapcfp_old.dscontar
                           , pr_dsdadatu => rw_crapcfp_new.dscontar);
      -- Efetua Commit
      COMMIT;

   EXCEPTION
     WHEN vr_excerror THEN
        -- Desfazer Operacao
        ROLLBACK;
        pr_dscritic := pr_des_erro;
        -- Retorno não OK
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => NVL(pr_dscritic,' ')
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Convenio Tarifario de Folha de Pagamento - CONFOL'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> ERRO/FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Commit do LOG
        COMMIT;
        -- Carregar XML padrao para variavel de retorno nao utilizada.
        -- Existe para satisfazer exigencia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 9999;
        pr_des_erro := 'Erro geral na rotina pc_grava_crapcfp: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_grava_crapcfp: '||SQLERRM;
        -- Retorno não OK
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => NVL(pr_dscritic,' ')
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Convenio Tarifario de Folha de Pagamento - CONFOL'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> ERRO/FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Commit do LOG
        COMMIT;
        -- Carregar XML padrao para variavel de retorno nao utilizada.
        -- Existe para satisfazer exigencia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');

   END pc_grava_crapcfp;

   /* Procedimento para excluir tarifas de convenios desnecessarias */
   PROCEDURE pc_excluir_crapcfp(pr_rowid    IN VARCHAR2
                               ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_excluir_crapcfp
   --  Sistema  : AyllosWeb
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Maio/2015.                   Ultima atualizacao: 19/11/2015
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedimento para excluir tarifas de convenios desnecessarias
   --
   -- Alteracoes: 19/11/2015 - Gerando Log de Exclusao da tela CONFOL - Melhoria (Andre Santos - SUPERO)
   --
   ---------------------------------------------------------------------------------------------------------------

      -- Cursor
      -- Buscar as informacoes da cooperativa
      CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
         SELECT crapcop.cdbcoctl
               ,crapcop.cdagectl
               ,crapcop.nmrescop
           FROM crapcop
          WHERE crapcop.cdcooper = p_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;


      -- Busca o convenio selecionado
      CURSOR cr_crapcfp(p_rowid VARCHAR2) IS
         SELECT cfp.cdcooper
               ,cfp.cdcontar
               ,cfp.dscontar
           FROM crapcfp cfp
          WHERE cfp.rowid = p_rowid;
      rw_crapcfp cr_crapcfp%ROWTYPE;


      -- Verifica se existe empresa relacionada ao convenio
      CURSOR cr_crapemp(p_cdcooper crapemp.cdcooper%TYPE
                       ,p_cdcontar crapcfp.cdcontar%TYPE) IS
         SELECT COUNT(1)
           FROM crapemp emp
          WHERE emp.cdcooper = p_cdcooper
            AND emp.cdcontar = p_cdcontar;
      vr_existe NUMBER(5);


      -- Verifica vinculo do convenio com a CADTAR
      CURSOR cr_craptar(p_cdcooper IN crapcop.cdcooper%TYPE
                       ,p_cdcontar IN crapcfp.cdcontar%TYPE) IS
         SELECT 1
           FROM craptar tar
               ,crapfvl fvl
               ,crapfco fco
          WHERE tar.cdinctar = 4          --> Folha
            AND tar.cdtarifa = fvl.cdtarifa
            AND fvl.cdfaixav = fco.cdfaixav
            AND fco.cdcooper = p_cdcooper --> Mesma Cooperativa do convenio
            AND fco.nrconven = p_cdcontar --> Convenio passível de exclusao
            AND fco.flgvigen = 1;         --> Somente ativos
      vr_existe_tar NUMBER(5);


      -- Variaveis
      vr_excerror EXCEPTION;

      vr_cdcooper    NUMBER;
      vr_nmdatela    VARCHAR2(25);
      vr_nmeacao     VARCHAR2(25);
      vr_cdagenci    VARCHAR2(25);
      vr_nrdcaixa    VARCHAR2(25);
      vr_idorigem    VARCHAR2(25);
      vr_cdoperad    VARCHAR2(25);

      vr_nrdrowid    ROWID;
      vr_dsorigem    VARCHAR2(100);
      vr_dstransa    VARCHAR2(100);

   BEGIN
      -- Inicializa Variavel
      pr_cdcritic := 0;
      pr_dscritic := NULL;
      pr_des_erro := NULL;

      -- Extrair informacoes padrao do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);


      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      -- Buscando descricao da origem do ambiente
      vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

      -- Buscar dados da cooperativa
      OPEN  cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
         -- Se nao encontrar dados
         IF cr_crapcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcop;
            pr_cdcritic := 9999;
            pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapcop;

      -- Busca o convenio selecionado
      OPEN cr_crapcfp(pr_rowid);
      FETCH cr_crapcfp INTO rw_crapcfp;
         IF cr_crapcfp%NOTFOUND THEN
            -- Fecha cursor
           CLOSE cr_crapcfp;
           pr_cdcritic := 1;
           pr_des_erro := 'Registro de convenio nao localizado!';
           RAISE vr_excerror;
         END IF;
      CLOSE cr_crapcfp;

      OPEN cr_craptar(rw_crapcfp.cdcooper
                     ,rw_crapcfp.cdcontar);
      FETCH cr_craptar INTO vr_existe_tar;
         IF cr_craptar%FOUND THEN
            -- Fecha cursor
           CLOSE cr_craptar;
           pr_cdcritic := 3;
           pr_des_erro := 'Convenio Tarifario nao pode ser excluido! Motivo: Existem tarifas vigentes '||
                          'vinculadas ao mesmo!';
           RAISE vr_excerror;
         END IF;
      CLOSE cr_craptar;

      -- Verifica se existe alguma empresa vinculada ao convenio
      OPEN cr_crapemp(rw_crapcfp.cdcooper
                     ,rw_crapcfp.cdcontar);
      FETCH cr_crapemp INTO vr_existe;
         IF vr_existe>0 THEN
            -- Fecha cursor
           CLOSE cr_crapemp;
           pr_cdcritic := 2;
           pr_des_erro := 'Existe pelo menos uma empresa vinculada ao convenio, impossivel exclui-lo!!';
           RAISE vr_excerror;
         END IF;
      CLOSE cr_crapemp;

      -- Se nao houve divergencias, preparar para eliminar o registro
      BEGIN
         DELETE crapcfp cfp
          WHERE cfp.rowid = pr_rowid;
      EXCEPTION
         WHEN OTHERS THEN
            pr_cdcritic := 9999;
            pr_des_erro := 'Erro ao deletar o registro na CRAPCFP: '||SQLERRM;
            RAISE vr_excerror;
      END;

      vr_dstransa := 'Exclusao de registro efetuado com sucesso - CONFOL.';

      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Log Item => Codigo Convenio
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Codigo Convenio'
                           , pr_dsdadant => rw_crapcfp.cdcontar
                           , pr_dsdadatu => NULL);
      -- Log Item => Descricao Convenio
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Descricao Convenio'
                           , pr_dsdadant => rw_crapcfp.dscontar
                           , pr_dsdadatu => NULL);
      -- Efetua Commit
      COMMIT;

   EXCEPTION
     WHEN vr_excerror THEN
        -- Desfazer Operacao
        ROLLBACK;
        pr_dscritic := pr_des_erro;
        -- Retorno não OK
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => NVL(pr_dscritic,' ')
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Convenio Tarifario de Folha de Pagamento - CONFOL.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> ERRO/FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Commit do LOG
        COMMIT;
        -- Carregar XML padrao para variavel de retorno nao utilizada.
        -- Existe para satisfazer exigencia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 9999;
        pr_des_erro := 'Erro geral na rotina pc_excluir_crapcfp: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_excluir_crapcfp: '||SQLERRM;
        -- Retorno não OK
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => NVL(pr_dscritic,' ')
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Convenio Tarifario de Folha de Pagamento - CONFOL.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> ERRO/FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Commit do LOG
        COMMIT;
        -- Carregar XML padrao para variavel de retorno nao utilizada.
        -- Existe para satisfazer exigencia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');

   END pc_excluir_crapcfp;

   /* Busca dados para exibir na tela CADCFP */
   PROCEDURE pc_lista_dados_crapcfp(pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_lista_dados_crapcfp
   --  Sistema  : AyllosWeb
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Maio/2015.                   Ultima atualizacao: 16/02/2016
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Busca dados para exibir na tela CADCFP
   --
   -- Alteracoes:  13/11/2015 - Inclusão de NVL para não mais enviar data de admissão vazia,
   --                           pois gera erro na leitura (Marcos-Supero)
   --
   -- Alteracoes: 19/11/2015 - Gerando Log de Comsulta da tela CONFOL - Melhoria
   --                          (Andre Santos - SUPERO)
   --
   --              16/02/2016 - Inclusao do parametro conta na chamada da
   --                           FOLH0001.fn_valor_tarifa_folha. (Jaison/Marcos)
   --
   ---------------------------------------------------------------------------------------------------------------

      -- Cursores

      -- Buscar as informacoes da cooperativa
      CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdbcoctl
             , crapcop.cdagectl
             , crapcop.nmrescop
          FROM crapcop
         WHERE crapcop.cdcooper = p_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca os dados de convenios
      CURSOR cr_crapcfp(p_cdcooper crapcop.cdcooper%TYPE) IS
         SELECT cfp.cdcooper
               ,cfp.cdcontar
               ,cfp.dscontar
               ,decode(folh0001.fn_valor_tarifa_folha(cfp.cdcooper,0,cfp.cdcontar,0,0),-1,'ERRO'
                      ,TO_CHAR(folh0001.fn_valor_tarifa_folha(cfp.cdcooper,0,cfp.cdcontar,0,0), 'FM990D00', 'NLS_NUMERIC_CHARACTERS=,.')) vltarid0
               ,decode(folh0001.fn_valor_tarifa_folha(cfp.cdcooper,0,cfp.cdcontar,1,0),-1,'ERRO'
                      ,TO_CHAR(folh0001.fn_valor_tarifa_folha(cfp.cdcooper,0,cfp.cdcontar,1,0), 'FM990D00', 'NLS_NUMERIC_CHARACTERS=,.')) vltarid1
               ,decode(folh0001.fn_valor_tarifa_folha(cfp.cdcooper,0,cfp.cdcontar,2,0),-1,'ERRO'
                      ,TO_CHAR(folh0001.fn_valor_tarifa_folha(cfp.cdcooper,0,cfp.cdcontar,2,0), 'FM990D00', 'NLS_NUMERIC_CHARACTERS=,.')) vltarid2
               ,cfp.rowid
           FROM crapcfp cfp
          WHERE cfp.cdcooper = p_cdcooper
          ORDER BY cfp.cdcontar;

      -- Variaveis
      vr_excerror EXCEPTION;

      vr_cdcooper    NUMBER;
      vr_nmdatela    VARCHAR2(25);
      vr_nmeacao     VARCHAR2(25);
      vr_cdagenci    VARCHAR2(25);
      vr_nrdcaixa    VARCHAR2(25);
      vr_idorigem    VARCHAR2(25);
      vr_cdoperad    VARCHAR2(25);

      vr_index PLS_INTEGER;

      -- Variavel Tabela Temporaria
      vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
      vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG's do XML

      vr_nrdrowid    ROWID;
      vr_dsorigem    VARCHAR2(100);
      vr_dstransa    VARCHAR2(100);
      vr_qtdregis    VARCHAR2(100);

      vr_flgerror    BOOLEAN := FALSE;

   BEGIN

      -- Extrair informacoes padrao do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      -- Buscando descricao da origem do ambiente
      vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

      -- Buscar dados da cooperativa
      OPEN  cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
         -- Se nao encontrar dados
         IF cr_crapcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcop;
            pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapcop;

      -- Inicializa
      vr_flgerror := FALSE;

      FOR rw_crapcfp IN cr_crapcfp(vr_cdcooper) LOOP
         -- Captura ultimo indice da PL Table
         vr_index := nvl(vr_tab_dados.count, 0) + 1;
         -- Gravando registros
         vr_tab_dados(vr_index)('indrowid') := rw_crapcfp.rowid;
         vr_tab_dados(vr_index)('cdcontar') := rw_crapcfp.cdcontar;
         vr_tab_dados(vr_index)('dscontar') := rw_crapcfp.dscontar;
         vr_tab_dados(vr_index)('vltarid0') := rw_crapcfp.vltarid0;
         vr_tab_dados(vr_index)('vltarid1') := rw_crapcfp.vltarid1;
         vr_tab_dados(vr_index)('vltarid2') := rw_crapcfp.vltarid2;

         IF rw_crapcfp.vltarid0 = 'ERRO' OR
            rw_crapcfp.vltarid1 = 'ERRO' OR
            rw_crapcfp.vltarid2 = 'ERRO' THEN
            vr_flgerror := TRUE;
         END IF;
      END LOOP;

      -- Guarda a quantidade de registros
      vr_qtdregis := vr_index;

      -- Geracao de TAG's
      gene0007.pc_gera_tag('indrowid',vr_tab_tags);
      gene0007.pc_gera_tag('cdcontar',vr_tab_tags);
      gene0007.pc_gera_tag('dscontar',vr_tab_tags);
      gene0007.pc_gera_tag('vltarid0',vr_tab_tags);
      gene0007.pc_gera_tag('vltarid1',vr_tab_tags);
      gene0007.pc_gera_tag('vltarid2',vr_tab_tags);

      IF vr_flgerror THEN /* Se houve algum erro */
         -- Criar nodo filho
         pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root'
                                            ,XMLTYPE('<descricao>9998</descricao>')); -- Exibir o erro
      ELSE
         -- Criar nodo filho
         pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root'
                                            ,XMLTYPE('<descricao>OK</descricao>'));
      END IF;

      -- Forma XML de retorno para casos de sucesso (listar dados)
      gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                          ,pr_tab_tag   => vr_tab_tags
                          ,pr_XMLType   => pr_retxml
                          ,pr_path_tag  => '/Root'
                          ,pr_tag_no    => 'retorno'
                          ,pr_des_erro  => pr_des_erro);

      vr_dstransa := 'Buscando Conv.Tar. Folha Pagto: CONFOL - Retornou: '||TRIM(gene0002.fn_mask(NVL(vr_qtdregis,0),'zzzzz9'))||' regitro(s).';
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
   EXCEPTION
      WHEN vr_excerror THEN
         -- Desfaz as alteracoes
         ROLLBACK;
         pr_dscritic := pr_des_erro;
         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => NVL(pr_dscritic,' ')
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => 'Convenio Tarifario de Folha de Pagamento - CONFOL.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nrdconta => 0
                             ,pr_nrdrowid => vr_nrdrowid);
         -- Commit do LOG
         COMMIT;
         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');
      WHEN OTHERS THEN
         -- Desfaz as alteracoes
         ROLLBACK;
         pr_des_erro := 'Erro geral na rotina pc_lista_dados_crapcfp: '||SQLERRM;
         pr_dscritic := 'Erro geral na rotina pc_lista_dados_crapcfp: '||SQLERRM;
         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => NVL(pr_dscritic,' ')
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => 'Convenio Tarifario de Folha de Pagamento - CONFOL.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nrdconta => 0
                             ,pr_nrdrowid => vr_nrdrowid);
         -- Commit do LOG
         COMMIT;
         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');
   END pc_lista_dados_crapcfp;

   /* Procedimento de origens de folha de pagamento */
   PROCEDURE pc_grava_crapofp(pr_cdoriflh IN VARCHAR2
                             ,pr_dsoriflh IN VARCHAR2
                             ,pr_idvarmes IN VARCHAR2
                             ,pr_cdhisdeb IN VARCHAR2
                             ,pr_cdhsdbcp IN VARCHAR2
                             ,pr_cdhiscre IN VARCHAR2
                             ,pr_cdhscrcp IN VARCHAR2
                             ,pr_fldebfol IN VARCHAR2
                             ,pr_rowid    IN VARCHAR2
                             ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_grava_crapofp
   --  Sistema  : AyllosWeb
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Maio/2015.                   Ultima atualizacao: 17/11/2015
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedimento de origens de folha de pagamento
   --
   -- Alteracoes: 17/11/2015 - Gerando Log de Inclusao/Atualizacao da tela ORIFOL - Melhoria
   --                         (Andre Santos - SUPERO)
   --
   ---------------------------------------------------------------------------------------------------------------

      -- Cursor
      -- Buscar as informacoes da cooperativa
      CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
         SELECT crapcop.cdbcoctl
               ,crapcop.cdagectl
               ,crapcop.nmrescop
           FROM crapcop
          WHERE crapcop.cdcooper = p_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Verifica se a descricao ja foi inserida
      CURSOR cr_crapofp_ori(p_cdcooper crapcop.cdcooper%TYPE
                           ,p_cdoriflh crapcfp.dscontar%TYPE
                           ,p_rowid   VARCHAR2) IS
         SELECT ofp.cdorigem
           FROM crapofp ofp
          WHERE ofp.cdcooper = p_cdcooper
            AND ((p_rowid IS NULL
            AND LOWER(ofp.cdorigem) LIKE LOWER(p_cdoriflh))
             OR (p_rowid IS NOT NULL
            AND LOWER(ofp.cdorigem) LIKE LOWER(p_cdoriflh)
            AND ofp.rowid <> p_rowid));
      vr_cdoriflh crapofp.cdorigem%TYPE;

      -- Verifica se a descricao ja foi inserida
      CURSOR cr_crapofp(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_dsoriflh crapcfp.dscontar%TYPE
                       ,p_rowid   VARCHAR2) IS
         SELECT ofp.dsorigem
           FROM crapofp ofp
          WHERE ofp.cdcooper = p_cdcooper
            AND ((p_rowid IS NULL
            AND LOWER(ofp.dsorigem) LIKE LOWER(p_dsoriflh))
             OR (p_rowid IS NOT NULL
            AND LOWER(ofp.dsorigem) LIKE LOWER(p_dsoriflh)
            AND ofp.rowid <> p_rowid));
      vr_dsoriflh crapofp.dsorigem%TYPE;

      -- Verifica se a descricao ja foi inserida
      CURSOR cr_dados(p_rowid VARCHAR2) IS
         SELECT ofp.cdcooper
               ,ofp.cdorigem
               ,ofp.dsorigem
               ,ofp.cdhisdeb
               ,ofp.cdhiscre
               ,ofp.cdhsdbcp
               ,ofp.cdhscrcp
               ,ofp.idvarmes
               ,ofp.fldebfol
           FROM crapofp ofp
          WHERE ofp.rowid = p_rowid;
      rw_dados cr_dados%ROWTYPE;

      -- Verifica se existe historico de DED/CRE
      CURSOR cr_craphis(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_cdhistor craphis.cdhistor%TYPE) IS
         SELECT his.indebcre
           FROM craphis his
          WHERE his.cdcooper = p_cdcooper
            AND his.cdhistor = p_cdhistor;
      rw_craphis cr_craphis%ROWTYPE;

      -- Variaveis
      vr_excerror EXCEPTION;

      vr_cdcooper    NUMBER;
      vr_nmdatela    VARCHAR2(25);
      vr_nmeacao     VARCHAR2(25);
      vr_cdagenci    VARCHAR2(25);
      vr_nrdcaixa    VARCHAR2(25);
      vr_idorigem    VARCHAR2(25);
      vr_cdoperad    VARCHAR2(25);

      vr_nrdrowid    ROWID;
      vr_dsorigem    VARCHAR2(100);
      vr_dstransa    VARCHAR2(100);

      rw_crapofp_old crapofp%ROWTYPE;
      rw_crapofp_new crapofp%ROWTYPE;
      vr_idvarmes_old    VARCHAR2(50);
      vr_fldebfol_old    VARCHAR2(50);
      vr_idvarmes_new    VARCHAR2(50);
      vr_fldebfol_new    VARCHAR2(50);

   BEGIN
      -- Inicializa Variavel
      pr_cdcritic := 0;
      pr_dscritic := NULL;
      pr_des_erro := NULL;

      -- Extrair informacoes padrao do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      -- Buscando descricao da origem do ambiente
      vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

      -- Buscar dados da cooperativa
      OPEN  cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
         -- Se nao encontrar dados
         IF cr_crapcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcop;
            pr_cdcritic := 9999;
            pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapcop;

      IF pr_rowid IS NOT NULL THEN
         -- Validacao dos campos obrigatorios
         OPEN cr_dados(pr_rowid);
         FETCH cr_dados INTO rw_dados;
            IF cr_dados%NOTFOUND THEN
               -- Fecha cursor
               CLOSE cr_dados;
               pr_cdcritic := 9999;
               pr_des_erro := 'Registro nao localizado!';
               pr_nmdcampo := 'cdoriflh';
               RAISE vr_excerror;
            END IF;
         CLOSE cr_dados;
      END IF;

      -- Validacao dos campos obrigatorios
      OPEN cr_crapofp_ori(vr_cdcooper
                         ,pr_cdoriflh
                         ,pr_rowid);
      FETCH cr_crapofp_ori INTO vr_cdoriflh;
         IF cr_crapofp_ori%FOUND THEN
            -- Fecha cursor
            CLOSE cr_crapofp_ori;
            pr_cdcritic := 0;
            pr_des_erro := 'Ja existe origem com este codigo, favor ajustar!';
            pr_nmdcampo := 'cdoriflh';
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapofp_ori;

      -- Validacao dos campos obrigatorios
      OPEN cr_crapofp(vr_cdcooper
                     ,pr_dsoriflh
                     ,pr_rowid);
      FETCH cr_crapofp INTO vr_dsoriflh;
         IF cr_crapofp%FOUND THEN
            -- Fecha cursor
            CLOSE cr_crapofp;
            pr_cdcritic := 1;
            pr_des_erro := 'Ja existe parametrizacao para a mesma combinacao, favor alterar o cadastro!';
            pr_nmdcampo := 'dsoriflh';
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapofp;

      -- Validacao dos campos obrigatorios
      IF NVL(pr_cdoriflh,' ') = ' 'THEN
         pr_cdcritic := 2;
         pr_des_erro := 'O codigo para Origem e obrigatoria!';
         pr_nmdcampo := 'cdoriflh';
         RAISE vr_excerror;
      END IF;

      -- Validacao dos campos obrigatorios
      IF NVL(pr_dsoriflh,' ') = ' 'THEN
         pr_cdcritic := 3;
         pr_des_erro := 'A descricao para Origem e obrigatoria!';
         pr_nmdcampo := 'dsoriflh';
         RAISE vr_excerror;
      END IF;

      -- Validando o campo de Historico de credito p/Cooperativa
      IF pr_cdhsdbcp IS NULL AND
         pr_cdhiscre IS NULL AND
         pr_cdhisdeb IS NULL AND
         pr_cdhscrcp IS NULL THEN
         pr_cdcritic := 13;
         pr_des_erro := 'Historico p/Empresa e/ou p/Cooperativa devem ser informados!';
         pr_nmdcampo := '';
         RAISE vr_excerror;
      END IF;

      /* Validacao para gravar historicos p/Empresa ou p/Cooperativa */

      -- Se os historicos de cooperativa nao foram preenchidos
      IF pr_cdhsdbcp IS NULL AND pr_cdhscrcp IS NULL THEN
         -- Valida Historico de debito p/Empresa
         IF pr_cdhisdeb IS NULL THEN
            pr_cdcritic := 4;
            pr_des_erro := 'Historico de debito p/Empresa deve ser informado!';
            pr_nmdcampo := 'cdhisdeb';
            RAISE vr_excerror;
            END IF;
      END IF;

      -- Se os historicos de cooperativa nao foram preenchidos
      IF pr_cdhsdbcp IS NULL AND pr_cdhscrcp IS NULL THEN
         -- Valida Historico de credito p/Empresa
         IF pr_cdhiscre IS NULL THEN
            pr_cdcritic := 5;
            pr_des_erro := 'Historico de credito p/Empresa deve ser informado!';
            pr_nmdcampo := 'cdhiscre';
            RAISE vr_excerror;
         END IF;
      END IF;

      -- Validando Historico de debito p/Cooperativa
      IF pr_cdhsdbcp IS NULL AND (pr_cdhisdeb IS NULL OR pr_cdhiscre IS NULL) THEN
         pr_cdcritic := 6;
         pr_des_erro := 'Historico de debito p/Cooperativa deve ser informado!';
         pr_nmdcampo := 'cdhsdbcp';
         RAISE vr_excerror;
      END IF;

      -- Validando Historico de credito p/Cooperativa
      IF pr_cdhscrcp IS NULL AND (pr_cdhisdeb IS NULL OR pr_cdhiscre IS NULL) THEN
         pr_cdcritic := 7;
         pr_des_erro := 'Historico de credito p/Cooperativa deve ser informado!';
         pr_nmdcampo := 'cdhscrcp';
         RAISE vr_excerror;
      END IF;

      /* Se for preencher todos os campos, validar se todos os campos estao preenchidos */

      -- Validando o campo de Historico de debito p/Empresa
      IF pr_cdhsdbcp IS NOT NULL AND
         pr_cdhscrcp IS NOT NULL AND
         pr_cdhiscre IS NOT NULL AND
         pr_cdhisdeb IS NULL THEN
         pr_cdcritic := 4;
         pr_des_erro := 'Historico de debito p/Empresa deve ser informado!';
         pr_nmdcampo := 'cdhisdeb';
         RAISE vr_excerror;
      END IF;

      -- Validando o campo de Historico de credito p/Empresa
      IF pr_cdhsdbcp IS NOT NULL AND
         pr_cdhscrcp IS NOT NULL AND
         pr_cdhisdeb IS NOT NULL AND
         pr_cdhiscre IS NULL THEN
         pr_cdcritic := 5;
         pr_des_erro := 'Historico de credito p/Empresa deve ser informado!';
         pr_nmdcampo := 'cdhiscre';
         RAISE vr_excerror;
      END IF;

      -- Validando o campo de Historico de debito p/Cooperativa
      IF pr_cdhisdeb IS NOT NULL AND
         pr_cdhscrcp IS NOT NULL AND
         pr_cdhiscre IS NOT NULL AND
         pr_cdhsdbcp IS NULL THEN
         pr_cdcritic := 6;
         pr_des_erro := 'Historico de debito p/Cooperativa deve ser informado!';
         pr_nmdcampo := 'cdhsdbcp';
         RAISE vr_excerror;
      END IF;

      -- Validando o campo de Historico de credito p/Cooperativa
      IF pr_cdhsdbcp IS NOT NULL AND
         pr_cdhiscre IS NOT NULL AND
         pr_cdhisdeb IS NOT NULL AND
         pr_cdhscrcp IS NULL THEN
         pr_cdcritic := 7;
         pr_des_erro := 'Historico de credito p/Cooperativa deve ser informado!';
         pr_nmdcampo := 'cdhscrcp';
         RAISE vr_excerror;
      END IF;

      /* Verifica se os historicos informados sao validos para cada campo */

      IF pr_cdhisdeb IS NOT NULL THEN
         -- Verifica o historico informado
         OPEN cr_craphis(vr_cdcooper
                        ,pr_cdhisdeb);
         FETCH cr_craphis INTO rw_craphis;
            IF cr_craphis%NOTFOUND THEN
               CLOSE cr_craphis;
               -- Gera Critica
               pr_cdcritic := 8;
               pr_des_erro := 'Historico Inexistente!';
               RAISE vr_excerror;
            END IF;

            -- Se for credito, gera critica e retorna ao campo informado
            IF rw_craphis.indebcre = 'C' THEN
               CLOSE cr_craphis;
               -- Gera Critica
               pr_cdcritic := 9;
               pr_des_erro := 'Favor informar um historico do tipo Debito p/ Empresa!';
               pr_nmdcampo := 'cdhisdeb';
               RAISE vr_excerror;
            END IF;
         CLOSE cr_craphis;
      END IF;

      IF pr_cdhiscre IS NOT NULL THEN
         -- Verifica o historico informado
         OPEN cr_craphis(vr_cdcooper
                        ,pr_cdhiscre);
         FETCH cr_craphis INTO rw_craphis;
            IF cr_craphis%NOTFOUND THEN
               CLOSE cr_craphis;
               -- Gera Critica
               pr_cdcritic := 8;
               pr_des_erro := 'Historico Inexistente!';
               RAISE vr_excerror;
            END IF;

            -- Se for debito, gera critica e retorna ao campo informado
            IF rw_craphis.indebcre = 'D' THEN
               CLOSE cr_craphis;
               -- Gera Critica
               pr_cdcritic := 10;
               pr_des_erro := 'Favor informar um historico do tipo Credito p/ Empresa!';
               pr_nmdcampo := 'cdhiscre';
               RAISE vr_excerror;
            END IF;
         CLOSE cr_craphis;
      END IF;

      IF pr_cdhsdbcp IS NOT NULL THEN
         -- Verifica o historico informado
         OPEN cr_craphis(vr_cdcooper
                        ,pr_cdhsdbcp);
         FETCH cr_craphis INTO rw_craphis;
            IF cr_craphis%NOTFOUND THEN
               CLOSE cr_craphis;
               -- Gera Critica
               pr_cdcritic := 8;
               pr_des_erro := 'Historico Inexistente!';
               RAISE vr_excerror;
            END IF;

            -- Se for debito, gera critica e retorna ao campo informado
            IF rw_craphis.indebcre = 'C' THEN
               CLOSE cr_craphis;
               -- Gera Critica
               pr_cdcritic := 11;
               pr_des_erro := 'Favor informar um historico do tipo Debito p/Cooperativa!';
               pr_nmdcampo := 'cdhsdbcp';
               RAISE vr_excerror;
            END IF;
         CLOSE cr_craphis;
      END IF;

      IF pr_cdhscrcp IS NOT NULL THEN
         -- Verifica o historico informado
         OPEN cr_craphis(vr_cdcooper
                        ,pr_cdhscrcp);
         FETCH cr_craphis INTO rw_craphis;
            IF cr_craphis%NOTFOUND THEN
               CLOSE cr_craphis;
               -- Gera Critica
               pr_cdcritic := 8;
               pr_des_erro := 'Historico Inexistente!';
               RAISE vr_excerror;
            END IF;

            -- Se for debito, gera critica e retorna ao campo informado
            IF rw_craphis.indebcre = 'D' THEN
               CLOSE cr_craphis;
               -- Gera Critica
               pr_cdcritic := 12;
               pr_des_erro := 'Favor informar um historico do tipo Credito p/Cooperativa!';
               pr_nmdcampo := 'cdhscrcp';
               RAISE vr_excerror;
            END IF;
         CLOSE cr_craphis;
      END IF;

      IF NVL(pr_rowid,' ') = ' ' OR pr_rowid IS NULL THEN -- Inserir

         -- Insere o registro na CRAPCFP
         BEGIN
            INSERT INTO crapofp(cdcooper
                               ,cdorigem
                               ,dsorigem
                               ,cdhisdeb
                               ,cdhiscre
                               ,cdhsdbcp
                               ,cdhscrcp
                               ,idvarmes
                               ,fldebfol)
            VALUES(vr_cdcooper
                  ,pr_cdoriflh
                  ,pr_dsoriflh
                  ,NVL(pr_cdhisdeb,0)
                  ,NVL(pr_cdhiscre,0)
                  ,NVL(pr_cdhsdbcp,0)
                  ,NVL(pr_cdhscrcp,0)
                  ,pr_idvarmes
                  ,DECODE(pr_fldebfol,'S',1,0));
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               pr_cdcritic := 1;
               pr_des_erro := 'Ja existe parametrizacao para a mesma combinacao, favor alterar o cadastro!';
               pr_nmdcampo := 'cdoriflh';
               RAISE vr_excerror;
            WHEN OTHERS THEN
               pr_cdcritic := 9999;
               pr_des_erro := 'Erro ao inserir o registro na CRAPOFP: '||SQLERRM;
               pr_nmdcampo := 'dsoriflh';
               RAISE vr_excerror;
         END;

         vr_dstransa    := 'Registro inserido com sucesso - ORIFOL.';
         -- Registros OLD
         rw_crapofp_old.cdorigem := NULL;
         rw_crapofp_old.dsorigem := NULL;
         vr_idvarmes_old         := NULL;
         vr_fldebfol_old         := NULL;
         rw_crapofp_old.cdhisdeb := NULL;
         rw_crapofp_old.cdhiscre := NULL;
         rw_crapofp_old.cdhsdbcp := NULL;
         rw_crapofp_old.cdhscrcp := NULL;
         -- Registros NEW
         rw_crapofp_new.cdorigem := pr_cdoriflh;
         rw_crapofp_new.dsorigem := pr_dsoriflh;
         --
         IF pr_idvarmes = 'S' THEN
            vr_idvarmes_new := 'Sim';
         ELSIF pr_idvarmes = 'A' THEN
            vr_idvarmes_new := 'Sim, mas com Alerta';
         END IF;
         --
         IF pr_fldebfol = 'S' THEN
            vr_fldebfol_new := 'Sim';
         ELSE
            vr_fldebfol_new := 'Nao';
         END IF;
         --
         rw_crapofp_new.cdhisdeb := NVL(pr_cdhisdeb,0);
         rw_crapofp_new.cdhiscre := NVL(pr_cdhiscre,0);
         rw_crapofp_new.cdhsdbcp := NVL(pr_cdhsdbcp,0);
         rw_crapofp_new.cdhscrcp := NVL(pr_cdhscrcp,0);

      ELSE  -- Atualizacao
         -- Atualiza o registro na CRAPCFP
         BEGIN
            UPDATE crapofp ofp
               SET ofp.cdcooper = vr_cdcooper
                  ,ofp.cdorigem = pr_cdoriflh
                  ,ofp.dsorigem = pr_dsoriflh
                  ,ofp.cdhisdeb = NVL(pr_cdhisdeb,0)
                  ,ofp.cdhiscre = NVL(pr_cdhiscre,0)
                  ,ofp.cdhsdbcp = NVL(pr_cdhsdbcp,0)
                  ,ofp.cdhscrcp = NVL(pr_cdhscrcp,0)
                  ,ofp.idvarmes = pr_idvarmes
                  ,ofp.fldebfol = DECODE(pr_fldebfol,'S',1,0)
             WHERE ofp.rowid = pr_rowid;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               pr_cdcritic := 1;
               pr_des_erro := 'Ja existe parametrizacao para a mesma combinacao, favor alterar o cadastro!';
               pr_nmdcampo := 'cdoriflh';
               RAISE vr_excerror;
            WHEN OTHERS THEN
               pr_cdcritic := 9999;
               pr_des_erro := 'Erro ao atualizar o registro na CRAPOFP: '||SQLERRM;
               pr_nmdcampo := 'dsoriflh';
               RAISE vr_excerror;
         END;

         vr_dstransa := 'Registro alterado com sucesso - ORIFOL.';
         -- Registros OLD
         rw_crapofp_old.cdorigem := rw_dados.cdorigem;
         rw_crapofp_old.dsorigem := rw_dados.dsorigem;
         --
         IF rw_dados.idvarmes = 'S' THEN
            vr_idvarmes_old := 'SIM';
         ELSE
            vr_idvarmes_old := 'SIM, MAS COM ALERTA';
         END IF;
         --
         IF rw_dados.fldebfol = 1 THEN
            vr_fldebfol_old := 'SIM';
         ELSE
            vr_fldebfol_old := 'NAO';
         END IF;
         --
         rw_crapofp_old.cdhisdeb := rw_dados.cdhisdeb;
         rw_crapofp_old.cdhiscre := rw_dados.cdhiscre;
         rw_crapofp_old.cdhsdbcp := rw_dados.cdhsdbcp;
         rw_crapofp_old.cdhscrcp := rw_dados.cdhscrcp;
         -- Registros NEW
         rw_crapofp_new.cdorigem := pr_cdoriflh;
         rw_crapofp_new.dsorigem := pr_dsoriflh;
         --
         IF pr_idvarmes = 'S' THEN
            vr_idvarmes_new := 'SIM';
         ELSE
            vr_idvarmes_new := 'SIM, MAS COM ALERTA';
         END IF;
         --
         IF pr_fldebfol = 'S' THEN
            vr_fldebfol_new := 'SIM';
         ELSE
            vr_fldebfol_new := 'NAO';
         END IF;
         --
         rw_crapofp_new.cdhisdeb := NVL(pr_cdhisdeb,0);
         rw_crapofp_new.cdhiscre := NVL(pr_cdhiscre,0);
         rw_crapofp_new.cdhsdbcp := NVL(pr_cdhsdbcp,0);
         rw_crapofp_new.cdhscrcp := NVL(pr_cdhscrcp,0);
      END IF;

      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Log Item => Origem
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Origem'
                           , pr_dsdadant => rw_crapofp_old.cdorigem
                           , pr_dsdadatu => rw_crapofp_new.cdorigem);
      -- Log Item => Descricao da Origem
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Descricao'
                           , pr_dsdadant => rw_crapofp_old.dsorigem
                           , pr_dsdadatu => rw_crapofp_new.dsorigem);
      -- Log Item => Permitir Varias Gravacoes no Mes
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Permite varios no mes'
                           , pr_dsdadant => vr_idvarmes_old
                           , pr_dsdadatu => vr_idvarmes_new);
      -- Log Item => Verif. deb vinc. folha
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Verif. deb vinc. folha'
                           , pr_dsdadant => vr_fldebfol_old
                           , pr_dsdadatu => vr_fldebfol_new);
      -- Log Item => Hist.Deb p/ Empresa
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Hist.Deb p/ Empresa'
                           , pr_dsdadant => rw_crapofp_old.cdhisdeb
                           , pr_dsdadatu => rw_crapofp_new.cdhisdeb);
      -- Log Item => Hist.Cred p/ Empresa
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Hist.Cred p/ Empresa'
                           , pr_dsdadant => rw_crapofp_old.cdhiscre
                           , pr_dsdadatu => rw_crapofp_new.cdhiscre);
      -- Log Item => Hist.Deb p/ Coop
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Hist.Deb p/ Coop'
                           , pr_dsdadant => rw_crapofp_old.cdhsdbcp
                           , pr_dsdadatu => rw_crapofp_new.cdhsdbcp);
      -- Log Item => Hist.Deb p/ Coop
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Hist.Deb p/ Coop'
                           , pr_dsdadant => rw_crapofp_old.cdhscrcp
                           , pr_dsdadatu => rw_crapofp_new.cdhscrcp);
      -- Efetua Commit
      COMMIT;

   EXCEPTION
      WHEN vr_excerror THEN
         -- Desfazer Operacao
         ROLLBACK;
         pr_dscritic := gene0007.fn_convert_db_web(pr_des_erro);
         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => NVL(pr_dscritic,' ')
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => 'Origens para Folha de Pagamento - ORIFOL.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nrdconta => 0
                             ,pr_nrdrowid => vr_nrdrowid);
         -- Commit do LOG
         COMMIT;
         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');
      WHEN OTHERS THEN
         ROLLBACK;
         pr_cdcritic := 9999;
         pr_des_erro := 'Erro geral na rotina pc_grava_crapofp: '||SQLERRM;
         pr_dscritic := 'Erro geral na rotina pc_grava_crapofp: '||SQLERRM;
         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => NVL(pr_dscritic,' ')
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => 'Origens para Folha de Pagamento - ORIFOL.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nrdconta => 0
                             ,pr_nrdrowid => vr_nrdrowid);
         -- Commit do LOG
         COMMIT;
         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');

   END pc_grava_crapofp;

   /* Busca dados para exibir na tela CRAPOFP */
   PROCEDURE pc_lista_dados_crapofp(pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_lista_dados_crapofp
   --  Sistema  : AyllosWeb
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Maio/2015.                   Ultima atualizacao: 17/11/2015
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Busca dados para exibir na tela CRAPOFP
   --
   -- Alteracoes: 17/11/2015 - Gerando Log de Consulta da tela ORIFOL - Melhoria (Andre Santos - SUPERO)
   --
   ---------------------------------------------------------------------------------------------------------------

      -- Cursores

      -- Buscar as informacoes da cooperativa
      CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdbcoctl
             , crapcop.cdagectl
             , crapcop.nmrescop
          FROM crapcop
         WHERE crapcop.cdcooper = p_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca os dados de convenios
      CURSOR cr_crapofp(p_cdcooper crapcop.cdcooper%TYPE) IS
         SELECT ofp.cdorigem
               ,ofp.dsorigem
               ,ofp.cdhiscre
               ,ofp.cdhisdeb
               ,ofp.cdhscrcp
               ,ofp.cdhsdbcp
               ,DECODE(ofp.fldebfol,1,'S','N') fldebfol
               ,ofp.idvarmes
               ,ofp.rowid
           FROM crapofp ofp
          WHERE ofp.cdcooper = p_cdcooper;
      rw_crapofp cr_crapofp%ROWTYPE;

      -- Variaveis
      vr_excerror EXCEPTION;

      vr_cdcooper    NUMBER;
      vr_nmdatela    VARCHAR2(25);
      vr_nmeacao     VARCHAR2(25);
      vr_cdagenci    VARCHAR2(25);
      vr_nrdcaixa    VARCHAR2(25);
      vr_idorigem    VARCHAR2(25);
      vr_cdoperad    VARCHAR2(25);

      vr_index PLS_INTEGER;

      -- Variavel Tabela Temporaria
      vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
      vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG's do XML

      vr_nrdrowid    ROWID;
      vr_dsorigem    VARCHAR2(100);
      vr_dstransa    VARCHAR2(100);
      vr_qtdregis    VARCHAR2(100);

   BEGIN

      -- Extrair informacoes padrao do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      -- Buscando descricao da origem do ambiente
      vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

      -- Buscar dados da cooperativa
      OPEN  cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
         -- Se nao encontrar dados
         IF cr_crapcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcop;
            pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapcop;

      vr_qtdregis := 0;

      OPEN cr_crapofp(vr_cdcooper);
      FETCH cr_crapofp INTO rw_crapofp;
         LOOP
            EXIT WHEN cr_crapofp%NOTFOUND;

            -- Captura ultimo indice da PL Table
            vr_index := nvl(vr_tab_dados.count, 0) + 1;
            -- Gravando registros
            vr_tab_dados(vr_index)('indrowid') := rw_crapofp.rowid;
            vr_tab_dados(vr_index)('cdorigem') := rw_crapofp.cdorigem;
            vr_tab_dados(vr_index)('dsorigem') := rw_crapofp.dsorigem;
            vr_tab_dados(vr_index)('idvarmes') := rw_crapofp.idvarmes;
            vr_tab_dados(vr_index)('cdhisdeb') := rw_crapofp.cdhisdeb;
            vr_tab_dados(vr_index)('cdhiscre') := rw_crapofp.cdhiscre;
            vr_tab_dados(vr_index)('cdhsdbcp') := rw_crapofp.cdhsdbcp;
            vr_tab_dados(vr_index)('cdhscrcp') := rw_crapofp.cdhscrcp;
            vr_tab_dados(vr_index)('fldebfol') := rw_crapofp.fldebfol;
            -- Acumula a quantidade de registros
            vr_qtdregis := vr_qtdregis + 1;
            FETCH cr_crapofp INTO rw_crapofp;
         END LOOP;
      CLOSE cr_crapofp;

      -- Geracao de TAG's
      gene0007.pc_gera_tag('indrowid',vr_tab_tags);
      gene0007.pc_gera_tag('cdorigem',vr_tab_tags);
      gene0007.pc_gera_tag('dsorigem',vr_tab_tags);
      gene0007.pc_gera_tag('idvarmes',vr_tab_tags);
      gene0007.pc_gera_tag('cdhisdeb',vr_tab_tags);
      gene0007.pc_gera_tag('cdhiscre',vr_tab_tags);
      gene0007.pc_gera_tag('cdhsdbcp',vr_tab_tags);
      gene0007.pc_gera_tag('cdhscrcp',vr_tab_tags);
      gene0007.pc_gera_tag('fldebfol',vr_tab_tags);

      -- Forma XML de retorno para casos de sucesso (listar dados)
      gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                          ,pr_tab_tag   => vr_tab_tags
                          ,pr_XMLType   => pr_retxml
                          ,pr_path_tag  => '/Root'
                          ,pr_tag_no    => 'retorno'
                          ,pr_des_erro  => pr_des_erro);

      vr_dstransa := 'Buscando Origens Folha Pagto - ORIFOL. Retornou: '||TRIM(gene0002.fn_mask(NVL(vr_qtdregis,0),'zzzzz9'))||' regitro(s).';
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
   EXCEPTION
      WHEN vr_excerror THEN
         -- Desfaz as alteracoes
         ROLLBACK;
         pr_dscritic := pr_des_erro;
         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => NVL(pr_dscritic,' ')
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => 'Origens para Folha de Pagamento - ORIFOL.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nrdconta => 0
                             ,pr_nrdrowid => vr_nrdrowid);
         -- Commit do LOG
         COMMIT;
         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');
      WHEN OTHERS THEN
         -- Desfaz as alteracoes
         ROLLBACK;
         pr_des_erro := 'Erro geral na rotina pc_lista_dados_crapofp: '||SQLERRM;
         pr_dscritic := 'Erro geral na rotina pc_lista_dados_crapofp: '||SQLERRM;
         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => NVL(pr_dscritic,' ')
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => 'Origens para Folha de Pagamento - ORIFOL.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nrdconta => 0
                             ,pr_nrdrowid => vr_nrdrowid);
         -- Commit do LOG
         COMMIT;
         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');
   END pc_lista_dados_crapofp;

   /* Procedimento para excluir origens de pagamentos desnecessarias */
   PROCEDURE pc_excluir_crapofp(pr_rowid    IN VARCHAR2
                               ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_excluir_crapofp
   --  Sistema  : AyllosWeb
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Maio/2015.                   Ultima atualizacao: 17/11/2015
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedimento para excluir origens de pagamentos desnecessarias
   -- Alteracoes:
   --
   -- Alteracoes: 17/11/2015 - Gerando Log de Exclusao da tela ORIFOL - Melhoria (Andre Santos - SUPERO)
   --
   ---------------------------------------------------------------------------------------------------------------

      -- Cursor
      -- Buscar as informacoes da cooperativa
      CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
         SELECT crapcop.cdbcoctl
               ,crapcop.cdagectl
               ,crapcop.nmrescop
           FROM crapcop
          WHERE crapcop.cdcooper = p_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca o convenio selecionado
      CURSOR cr_crapofp(p_rowid VARCHAR2) IS
         SELECT ofp.cdcooper
               ,ofp.cdorigem
               ,ofp.dsorigem
               ,ofp.cdhisdeb
               ,ofp.cdhiscre
               ,ofp.cdhsdbcp
               ,ofp.cdhscrcp
               ,ofp.idvarmes
               ,ofp.fldebfol
           FROM crapofp ofp
          WHERE ofp.rowid = p_rowid;
      rw_crapofp cr_crapofp%ROWTYPE;

      -- Verifica se existe empresa relacionada ao convenio
      CURSOR cr_craplfp(p_cdcooper crapemp.cdcooper%TYPE
                       ,p_dsorigem craplfp.cdorigem%TYPE) IS
         SELECT COUNT(1)
           FROM craplfp lfp
          WHERE lfp.cdcooper = p_cdcooper
            AND lfp.cdorigem = p_dsorigem;
      vr_existe NUMBER(5);


      -- Variaveis
      vr_excerror EXCEPTION;

      vr_cdcooper    NUMBER;
      vr_nmdatela    VARCHAR2(25);
      vr_nmeacao     VARCHAR2(25);
      vr_cdagenci    VARCHAR2(25);
      vr_nrdcaixa    VARCHAR2(25);
      vr_idorigem    VARCHAR2(25);
      vr_cdoperad    VARCHAR2(25);

      vr_nrdrowid    ROWID;
      vr_dsorigem    VARCHAR2(100);
      vr_dstransa    VARCHAR2(100);

      vr_idvarmes    VARCHAR2(100);
      vr_fldebfol    VARCHAR2(100);

   BEGIN

      -- Extrair informacoes padrao do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);


      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      -- Buscando descricao da origem do ambiente
      vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

      -- Buscar dados da cooperativa
      OPEN  cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
         -- Se nao encontrar dados
         IF cr_crapcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcop;
            pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapcop;


      OPEN cr_crapofp(pr_rowid);
      FETCH cr_crapofp INTO rw_crapofp;
         IF cr_crapofp%NOTFOUND THEN
            -- Fecha cursor
           CLOSE cr_crapofp;

           pr_des_erro := 'Registro de convenio nao localizado!';
           RAISE vr_excerror;
         END IF;
      CLOSE cr_crapofp;


      OPEN cr_craplfp(rw_crapofp.cdcooper
                     ,rw_crapofp.cdorigem);
      FETCH cr_craplfp INTO vr_existe;
         IF vr_existe>0 THEN
            -- Fecha cursor
            CLOSE cr_craplfp;

            pr_des_erro := 'Origem nao pode ser excluida enquanto houverem pagamentos vinculados a ela!!';
            RAISE vr_excerror;
         END IF;
      CLOSE cr_craplfp;

      -- Se nao houve divergencias, preparar para eliminar o registro
      BEGIN
         DELETE crapofp ofp
          WHERE ofp.rowid = pr_rowid;
      EXCEPTION
         WHEN OTHERS THEN
            pr_cdcritic := 9999;
            pr_des_erro := 'Erro ao deletar o registro na CRAPLFP: '||SQLERRM;
            RAISE vr_excerror;
      END;

      vr_dstransa := 'Exclusao de registro efetuado com sucesso - ORIFOL.';

      IF rw_crapofp.idvarmes = 'S' THEN
         vr_idvarmes := 'SIM';
      ELSE
         vr_idvarmes := 'SIM, MAS COM ALERTA';
      END IF;

      IF rw_crapofp.fldebfol = 1 THEN
         vr_fldebfol := 'SIM';
      ELSE
         vr_fldebfol := 'NAO';
      END IF;

      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Log Item => Origem
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Origem'
                           , pr_dsdadant => rw_crapofp.cdorigem
                           , pr_dsdadatu => NULL);
      -- Log Item => Descricao da Origem
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Descricao'
                           , pr_dsdadant => rw_crapofp.dsorigem
                           , pr_dsdadatu => NULL);
      -- Log Item => Permitir Varias Gravacoes no Mes
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Permite varios no mes'
                           , pr_dsdadant => vr_idvarmes
                           , pr_dsdadatu => NULL);
      -- Log Item => Verif. deb vinc. folha
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Verif. deb vinc. folha'
                           , pr_dsdadant => vr_fldebfol
                           , pr_dsdadatu => NULL);
      -- Log Item => Hist.Deb p/ Empresa
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Hist.Deb p/ Empresa'
                           , pr_dsdadant => rw_crapofp.cdhisdeb
                           , pr_dsdadatu => NULL);
      -- Log Item => Hist.Cred p/ Empresa
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Hist.Cred p/ Empresa'
                           , pr_dsdadant => rw_crapofp.cdhiscre
                           , pr_dsdadatu => NULL);
      -- Log Item => Hist.Deb p/ Coop
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Hist.Deb p/ Coop'
                           , pr_dsdadant => rw_crapofp.cdhsdbcp
                           , pr_dsdadatu => NULL);
      -- Log Item => Hist.Deb p/ Coop
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           , pr_nmdcampo => 'Hist.Deb p/ Coop'
                           , pr_dsdadant => rw_crapofp.cdhscrcp
                           , pr_dsdadatu => NULL);

      -- Efetua Commit
      COMMIT;

   EXCEPTION
     WHEN vr_excerror THEN
        -- Desfazer Operacao
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := pr_des_erro;
        -- Retorno não OK
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => NVL(pr_dscritic,' ')
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Origens para Folha de Pagamento - ORIFOL.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> ERRO/FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Commit do LOG
        COMMIT;
        -- Carregar XML padrao para variavel de retorno nao utilizada.
        -- Existe para satisfazer exigencia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- Desfaz as alteracoes
        ROLLBACK;
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral na rotina pc_excluir_crapofp: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_excluir_crapofp: '||SQLERRM;
        -- Retorno não OK
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => NVL(pr_dscritic,' ')
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Origens para Folha de Pagamento - ORIFOL.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> ERRO/FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Commit do LOG
        COMMIT;
        -- Carregar XML padrao para variavel de retorno nao utilizada.
        -- Existe para satisfazer exigencia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
   END pc_excluir_crapofp;

   -- Realiza a gravacao dos parametros da Folha IB informados na tela PARFOL
   PROCEDURE pc_grava_prm_folhaib(pr_dsvlrprm1   IN VARCHAR2  -- Qtde meses cancelamento automatico
                                 ,pr_dsvlrprm2   IN VARCHAR2  -- Qtde dias para envio comprovantes
                                 ,pr_dsvlrprm3   IN VARCHAR2  -- Nro meses para emissao dos Comprovantes
                                 ,pr_dsvlrprm4   IN VARCHAR2  -- Antigo: Historico Débito Tarifa
                                 ,pr_dsvlrprm5   IN VARCHAR2  -- Historico Estorno Outras Empresas
                                 ,pr_dsvlrprm6   IN VARCHAR2  -- Historico Estorno para Cooperativas
                                 ,pr_dsvlrprm7   IN VARCHAR2  -- E-mails para alerta na Central
                                 ,pr_dsvlrprm8   IN VARCHAR2  -- Agendamento
                                 ,pr_dsvlrprm9   IN VARCHAR2  -- Portabilidade (Pgto no dia)
                                 ,pr_dsvlrprm10  IN VARCHAR2  -- Solicitação Estouro Conta
                                 ,pr_dsvlrprm11  IN VARCHAR2  -- Liberação Estouro Conta
                                 ,pr_dsvlrprm12  IN VARCHAR2  -- Lote
                                 ,pr_dsvlrprm13  IN VARCHAR2  -- Historico Credito TEC
                                 ,pr_dsvlrprm14  IN VARCHAR2  -- Historico Debito TEC
                                 ,pr_dsvlrprm15  IN VARCHAR2  -- Historico Recusa TEC
                                 ,pr_dsvlrprm16  IN VARCHAR2  -- Historico Devolucao TEC
                                 ,pr_dsvlrprm17  IN VARCHAR2  -- Historico Devolucao Empresa
                                 ,pr_dsvlrprm18  IN VARCHAR2  -- Lote TRF
                                 ,pr_dsvlrprm19  IN VARCHAR2  -- Historico Debito TRF
                                 ,pr_dsvlrprm20  IN VARCHAR2  -- Histórico Credito TRF
                                 ,pr_dsvlrprm21  IN VARCHAR2  -- E-mails para alerta ao Financeiro
                                 ,pr_dsvlrprm22  IN VARCHAR2  -- Pagto no dia (contas cooperativa)
                                 ,pr_dsvlrprm23  IN VARCHAR2  -- Habilita Transferência
                                 ,pr_dsvlrprm24  IN VARCHAR2  
                                 ,pr_dsvlrprm25  IN VARCHAR2  
                                 ,pr_xmllog      IN VARCHAR2            --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER          --> Código da critica
                                 ,pr_dscritic  OUT VARCHAR2             --> Descrição da critica
                                 ,pr_retxml     IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

   /* .............................................................................

   Programa: pc_grava_prm_folhaib
   Sistema : AyllosWeb
   Sigla   : FOLH
   Autor   : Renato Darosci - Supero
   Data    : Maio/2015.                  Ultima atualizacao: 18/01/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Efetua a gravação dos parametros de Folha IB
   Observacao: OS CÓDIGOS DE CRÍTICAS DESTE PROGRAMA SÃO PRÓPRIAS DO MESMO E SÃO
               TRATADAS DIRETAMENTE NO PROGRAMA PHP.

   Alteracoes: 18/11/2015 - Gerando Log de Alteracao/Inclusao da tela PARFOL - Melhoria
                          -- Desconsiderando a posicao 4 do array de acessos
                            (Andre Santos - SUPERO)

               18/01/2017 - Validacao de horario de operacao do spb. (M342 - Kelvin)
               
               19/01/2017 - Adicionado novo limite de horario para pagamento no dia
                            para contas da cooperativa. (M342 - Kelvin)            
   ..............................................................................*/
    -- Cursores

    CURSOR cr_dados_prm(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_cdacesso crapprm.cdacesso%TYPE) IS
       SELECT prm.dsvlrprm
         FROM crapprm prm
        WHERE prm.cdcooper = p_cdcooper
          AND prm.nmsistem = 'CRED'
          AND prm.cdacesso = p_cdacesso;
    rw_dados_prm cr_dados_prm%ROWTYPE;

    -- Variáveis
    vr_cdcooper         NUMBER;
    vr_nmdatela         VARCHAR2(25);
    vr_nmeacao          VARCHAR2(25);
    vr_cdagenci         VARCHAR2(25);
    vr_nrdcaixa         VARCHAR2(25);
    vr_idorigem         VARCHAR2(25);
    vr_cdoperad         VARCHAR2(25);

    -- campos
    vr_hragenda         crapprm.dsvlrprm%TYPE; -- Agendamento
    vr_hrportab         crapprm.dsvlrprm%TYPE; -- Portabilidade (Pgto no dia)
    vr_hrestcta         crapprm.dsvlrprm%TYPE; -- Solicitação Estouro Conta
    vr_hranaest         crapprm.dsvlrprm%TYPE; -- Análise Estouro Conta
    vr_hrlimcop         crapprm.dsvlrprm%TYPE; -- Pagto no dia (contas cooperativa)          
    vr_hrlimtrf         crapprm.dsvlrprm%TYPE; -- Pagto no dia transferencia (contas cooperativa)          
    vr_dsvlrprm4        NUMBER;
    vr_dsvlrprm5        NUMBER;
    vr_dsvlrprm6        NUMBER;
    vr_dsvlrprm13       NUMBER;
    vr_dsvlrprm14       NUMBER;
    vr_dsvlrprm15       NUMBER;
    vr_dsvlrprm16       NUMBER;
    vr_dsvlrprm17       NUMBER;
    vr_dsvlrprm19       NUMBER;
    vr_dsvlrprm20       NUMBER;

    vr_nrdrowid    ROWID;
    vr_dsorigem    VARCHAR2(100);

    vr_typ_log          typ_verifica_log;
    vr_typ_consulta_prm typ_consulta_prm;

    -- Excessões
    vr_exc_erro         EXCEPTION;

    -- Inicializa pl-table para gravar os parametros
    PROCEDURE pc_grava_parametros IS
    BEGIN
        vr_typ_consulta_prm(1).dsvlrprm  := pr_dsvlrprm1;
        vr_typ_consulta_prm(2).dsvlrprm  := pr_dsvlrprm2;
        vr_typ_consulta_prm(3).dsvlrprm  := pr_dsvlrprm3;
        vr_typ_consulta_prm(4).dsvlrprm  := NULL; -- pr_dsvlrprm4
        vr_typ_consulta_prm(5).dsvlrprm  := pr_dsvlrprm5;
        vr_typ_consulta_prm(6).dsvlrprm  := pr_dsvlrprm6;
        vr_typ_consulta_prm(7).dsvlrprm  := pr_dsvlrprm7;
        vr_typ_consulta_prm(8).dsvlrprm  := pr_dsvlrprm8;
        vr_typ_consulta_prm(9).dsvlrprm  := pr_dsvlrprm9;
        vr_typ_consulta_prm(10).dsvlrprm := pr_dsvlrprm10;
        vr_typ_consulta_prm(11).dsvlrprm := pr_dsvlrprm11;
        vr_typ_consulta_prm(12).dsvlrprm := pr_dsvlrprm12;
        vr_typ_consulta_prm(13).dsvlrprm := pr_dsvlrprm13;
        vr_typ_consulta_prm(14).dsvlrprm := pr_dsvlrprm14;
        vr_typ_consulta_prm(15).dsvlrprm := pr_dsvlrprm15;
        vr_typ_consulta_prm(16).dsvlrprm := pr_dsvlrprm16;
        vr_typ_consulta_prm(17).dsvlrprm := pr_dsvlrprm17;
        vr_typ_consulta_prm(18).dsvlrprm := pr_dsvlrprm18;
        vr_typ_consulta_prm(19).dsvlrprm := pr_dsvlrprm19;
        vr_typ_consulta_prm(20).dsvlrprm := pr_dsvlrprm20;
        vr_typ_consulta_prm(21).dsvlrprm := pr_dsvlrprm21;
        vr_typ_consulta_prm(22).dsvlrprm := pr_dsvlrprm22;
        vr_typ_consulta_prm(23).dsvlrprm := pr_dsvlrprm23;
        vr_typ_consulta_prm(24).dsvlrprm := pr_dsvlrprm24;
        vr_typ_consulta_prm(25).dsvlrprm := pr_dsvlrprm25;
    END;

    -- Rotina de validação de hora
    PROCEDURE pc_valida_hora(pr_dshorinf  IN OUT VARCHAR2
                            ,pr_dscritic  IN OUT VARCHAR2) IS

      --  variáveis
      vr_dtformat    DATE;

    BEGIN

      -- Faz o to_date para validar e formatar a hora informada
      vr_dtformat := to_date(pr_dshorinf,'HH24:MI');

      -- Retorna o campo com o valor corretamente formatado
      pr_dshorinf := to_char(vr_dtformat,'HH24:MI');

    EXCEPTION
      WHEN OTHERS THEN
        -- Se houver algum erro é porque a data é inválida
        pr_dscritic := 'Hora informada e invalida!';
    END;

    -- Função para validar os históricos
    PROCEDURE pr_valida_historico(pr_cdcooper IN     craphis.cdcooper%TYPE
                                 ,pr_cdhistor IN     craphis.cdhistor%TYPE
                                 ,pr_indebcre IN     craphis.indebcre%TYPE
                                 ,pr_cdcritic IN OUT NUMBER
                                 ,pr_dscritic    OUT VARCHAR2) IS

      -- Histórico
      CURSOR cr_craphis IS
        SELECT his.indebcre
          FROM craphis his
         WHERE his.cdcooper = pr_cdcooper
           AND his.cdhistor = pr_cdhistor;

      -- Variáveis
      vr_indebcre         craphis.indebcre%TYPE;

    BEGIN

      -- Validar se o histórico informado é valido
      OPEN  cr_craphis;
      FETCH cr_craphis INTO vr_indebcre;
      -- Se não encontrou registro
      IF cr_craphis%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craphis;

        -- Retorna erro de histórico não encontrado
        pr_dscritic := 'Historico nao encontrado!';
        -- Nesta situação o cdcritic ira retornar o indice do campo da tela que caiu na validação
        pr_cdcritic := pr_cdcritic + 10; -- Erro de historico não encontrado

        RETURN;
      ELSE
        -- Fechar o cursor
        CLOSE cr_craphis;

        -- Se for histórico de crédito e o histórico não for de débito
        IF pr_indebcre = 'C' AND  vr_indebcre <> 'C' THEN

          -- Retorna erro de histórico não encontrado
          pr_dscritic := 'Historico para tarifa deve ser um historico de credito!';
          RETURN;

        -- Verifica se é um histórico de débito
        ELSIF pr_indebcre = 'D' AND  vr_indebcre <> 'D' THEN

          -- Retorna erro de histórico não encontrado
          pr_dscritic := 'Historico para tarifa deve ser um historico de debito!';
          RETURN;

        END IF;
      END IF;

      -- Limpar os parametros de crítica
      pr_cdcritic := NULL;
      pr_dscritic := NULL;

    END pr_valida_historico;

   BEGIN

    -- Tratar os valores vindos da Web
    vr_dsvlrprm4  := NULL; -- to_number(pr_dsvlrprm4 );
    vr_dsvlrprm5  := to_number(pr_dsvlrprm5 );
    vr_dsvlrprm6  := to_number(pr_dsvlrprm6 );
    vr_dsvlrprm13 := to_number(pr_dsvlrprm13);
    vr_dsvlrprm14 := to_number(pr_dsvlrprm14);
    vr_dsvlrprm15 := to_number(pr_dsvlrprm15);
    vr_dsvlrprm16 := to_number(pr_dsvlrprm16);
    vr_dsvlrprm17 := to_number(pr_dsvlrprm17);
    vr_dsvlrprm19 := to_number(pr_dsvlrprm19);
    vr_dsvlrprm20 := to_number(pr_dsvlrprm20);

    -- Vamos de hora
    vr_hragenda := pr_dsvlrprm8;
    vr_hrportab := pr_dsvlrprm9;
    vr_hrestcta := pr_dsvlrprm10;
    vr_hranaest := pr_dsvlrprm11;
    vr_hrlimcop := pr_dsvlrprm22;
    vr_hrlimtrf := pr_dsvlrprm24;

    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    -- Criar cabecalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscando descricao da origem do ambiente
     vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

     -- Validar Histórico Estorno Outras Empresas
     pr_cdcritic := 51; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm5
                        ,pr_indebcre => 'C' -- Validar como histórico de crédito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Histórico Estorno para Outras Cooperativas
     pr_cdcritic := 52; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm6
                        ,pr_indebcre => 'C' -- Validar como histórico de crédito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Histórico Crédito TEC
     pr_cdcritic := 53; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm13
                        ,pr_indebcre => 'C' -- Validar como histórico de crédito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Histórico Débito TEC
     pr_cdcritic := 54; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm14
                        ,pr_indebcre => 'D' -- Validar como histórico de débito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Histórico Recusa TEC
     pr_cdcritic := 55; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm15
                        ,pr_indebcre => 'C' -- Validar como histórico de crédito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Histórico Devolução TEC
     pr_cdcritic := 56; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm16
                        ,pr_indebcre => 'D' -- Validar como histórico de débito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Histórico Devolução Empresa
     pr_cdcritic := 57; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm17
                        ,pr_indebcre => 'C' -- Validar como histórico de crédito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Histórico Débito TRF
     pr_cdcritic := 58; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm19
                        ,pr_indebcre => 'D' -- Validar como histórico de débito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Histórico Crédito TRF
     pr_cdcritic := 59; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm20
                        ,pr_indebcre => 'C' -- Validar como histórico de crédito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar os campos de hora
     -- Pagto no dia (contas cooperativa)     
     pc_valida_hora(pr_dshorinf => vr_hrlimcop
                   ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       -- Nesta situação o cdcritic ira retornar o indice do campo da tela que caiu na validação
       pr_cdcritic := 22;
       RAISE vr_exc_erro;
     END IF;

     -- Verifica se a hora informada está dentro do Range permitido
     -- Pagto no dia (contas cooperativa)  
     IF NOT FOLH0001.fn_valida_hrtransfer(vr_cdcooper, to_date(vr_hrlimcop,'hh24:mi')) THEN
       -- Retornar o cdcritic para tratamento no PHP
       pr_cdcritic := 115;
       pr_des_erro := 'Mostrar erro '||pr_cdcritic;
       RAISE vr_exc_erro;
     END IF;
     
     -- Validar os campos de hora
     -- Pagto no dia (contas cooperativa)     
     pc_valida_hora(pr_dshorinf => vr_hrlimtrf
                   ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       -- Nesta situação o cdcritic ira retornar o indice do campo da tela que caiu na validação
       pr_cdcritic := 24;
       RAISE vr_exc_erro;
     END IF;
     
     -- Verifica se a hora informada está dentro do Range permitido
     -- Pagto no dia (contas cooperativa)  
     IF NOT FOLH0001.fn_valida_hrtransfer(vr_cdcooper, to_date(vr_hrlimtrf,'hh24:mi')) THEN
       -- Retornar o cdcritic para tratamento no PHP
       pr_cdcritic := 116;
       pr_des_erro := 'Mostrar erro '||pr_cdcritic;
       RAISE vr_exc_erro;
     END IF;
     
     -- Validar os campos de hora
     -- Agendamento
     pc_valida_hora(pr_dshorinf => vr_hragenda
                   ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       -- Nesta situação o cdcritic ira retornar o indice do campo da tela que caiu na validação
       pr_cdcritic := 8;
       RAISE vr_exc_erro;
     END IF;

     -- Verifica se a hora informada está dentro do Range permitido
     IF NOT FOLH0001.fn_valida_hrtransfer(vr_cdcooper, to_date(vr_hragenda,'hh24:mi')) THEN
       -- Retornar o cdcritic para tratamento no PHP
       pr_cdcritic := 83;
       pr_des_erro := 'Mostrar erro '||pr_cdcritic;
       RAISE vr_exc_erro;
     END IF;

     -- Portabilidade (Pgto no dia)
     pc_valida_hora(pr_dshorinf => vr_hrportab
                   ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       -- Nesta situação o cdcritic ira retornar o indice do campo da tela que caiu na validação
       pr_cdcritic := 9;
       RAISE vr_exc_erro;
     END IF;

     --Verifica se o horario informado está dentro do horario de operacao do spb
     IF NOT FOLH0001.fn_valida_hrportabil(vr_cdcooper, to_date(vr_hrportab,'hh24:mi')) THEN
       -- Retornar o cdcritic para tratamento no PHP
       pr_cdcritic := 114;
       pr_des_erro := 'Mostrar erro '||pr_cdcritic;
       RAISE vr_exc_erro;
     END IF;

     -- Solicitação Estouro Conta
     pc_valida_hora(pr_dshorinf => vr_hrestcta
                   ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       -- Nesta situação o cdcritic ira retornar o indice do campo da tela que caiu na validação
       pr_cdcritic := 10;
       RAISE vr_exc_erro;
     END IF;

     -- Verifica se a hora informada está dentro do Range permitido
     IF NOT FOLH0001.fn_valida_hrtransfer(vr_cdcooper, to_date(vr_hrestcta,'hh24:mi')) THEN
       -- Retornar o cdcritic para tratamento no PHP
       pr_cdcritic := 103;
       pr_des_erro := 'Mostrar erro '||pr_cdcritic;
       RAISE vr_exc_erro;
     END IF;

     -- Análise Estouro Conta
     pc_valida_hora(pr_dshorinf => vr_hranaest
                   ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       -- Nesta situação o cdcritic ira retornar o indice do campo da tela que caiu na validação
       pr_cdcritic := 11;
       RAISE vr_exc_erro;
     END IF;

     -- Verifica se a hora informada está dentro do Range permitido
     IF NOT FOLH0001.fn_valida_hrtransfer(vr_cdcooper, to_date(vr_hranaest,'hh24:mi')) THEN
       -- Retornar o cdcritic para tratamento no PHP
       pr_cdcritic := 113;
       pr_des_erro := 'Mostrar erro '||pr_cdcritic;
       RAISE vr_exc_erro;
     END IF;

     -- Verifica se a hora de Analise é maior que a hora de solicitação de estouro
     IF to_date(vr_hranaest,'HH24:MI') < to_date(vr_hrestcta,'HH24:MI') THEN
       -- Nesta situação o cdcritic ira retornar o indice do campo da tela que caiu na validação
       pr_cdcritic := 101;
       pr_des_erro := 'O Horario Limite de Analise do Estouro deve ser superior ao Horario Limite de Solicitação de Estouro.';
       RAISE vr_exc_erro;
     END IF;

     -- Inicializa pl-table para gravar os parametros
     pc_grava_parametros;

     -- Percorrer o registro de campos e inserir cada um deles
     FOR ind IN vr_tab_cdacesso.FIRST..vr_tab_cdacesso.LAST LOOP

       IF vr_tab_cdacesso(ind) IS NULL THEN
          -- Desconsidera a posicao
          CONTINUE;
       END IF;

       OPEN  cr_dados_prm(vr_cdcooper
                         ,vr_tab_cdacesso(ind));
       FETCH cr_dados_prm INTO rw_dados_prm;
       -- Se nao encontrou
       IF cr_dados_prm%NOTFOUND THEN
          -- INSERT do registro
          vr_typ_log(1)(ind).valor_old := NULL;
          vr_typ_log(1)(ind).valor_new := vr_typ_consulta_prm(ind).dsvlrprm;
       ELSE
          -- Ocorreu um UPDATE
          vr_typ_log(2)(ind).valor_old := rw_dados_prm.dsvlrprm;
          vr_typ_log(2)(ind).valor_new := vr_typ_consulta_prm(ind).dsvlrprm;
       END IF;
       -- Fecha o cursor
       CLOSE cr_dados_prm;

       BEGIN
         -- Realizar o update das informações
         UPDATE crapprm prm
            SET prm.dsvlrprm = decode(ind, 1, pr_dsvlrprm1
                                         , 2, pr_dsvlrprm2
                                         , 3, pr_dsvlrprm3
                                         , 4, vr_dsvlrprm4
                                         , 5, vr_dsvlrprm5
                                         , 6, vr_dsvlrprm6
                                         , 7, pr_dsvlrprm7
                                         , 8, vr_hragenda
                                         , 9, vr_hrportab
                                         ,10, vr_hrestcta
                                         ,11, vr_hranaest
                                         ,12, pr_dsvlrprm12
                                         ,13, vr_dsvlrprm13
                                         ,14, vr_dsvlrprm14
                                         ,15, vr_dsvlrprm15
                                         ,16, vr_dsvlrprm16
                                         ,17, vr_dsvlrprm17
                                         ,18, pr_dsvlrprm18
                                         ,19, vr_dsvlrprm19
                                         ,20, vr_dsvlrprm20
                                         ,21, pr_dsvlrprm21
                                         ,22, pr_dsvlrprm22
                                         ,23, pr_dsvlrprm23
                                         ,24, pr_dsvlrprm24
                                         ,25, pr_dsvlrprm25)
          WHERE prm.cdcooper = vr_cdcooper
            AND prm.nmsistem = 'CRED'
            AND prm.cdacesso = vr_tab_cdacesso(ind);

         -- Se nenhum registro foi atualizado
         IF SQL%ROWCOUNT = 0 THEN
           -- Faz a inserção do parametro
           INSERT INTO crapprm(nmsistem
                              ,cdcooper
                              ,cdacesso
                              ,dstexprm
                              ,dsvlrprm)
                        VALUES('CRED'
                              ,vr_cdcooper
                              ,vr_tab_cdacesso(ind)
                              ,vr_tab_dscmptel(ind)
                              ,decode(ind, 1, pr_dsvlrprm1
                                         , 2, pr_dsvlrprm2
                                         , 3, pr_dsvlrprm3
                                         , 4, vr_dsvlrprm4
                                         , 5, vr_dsvlrprm5
                                         , 6, vr_dsvlrprm6
                                         , 7, pr_dsvlrprm7
                                         , 8, vr_hragenda
                                         , 9, vr_hrportab
                                         ,10, vr_hrestcta
                                         ,11, vr_hranaest
                                         ,12, pr_dsvlrprm12
                                         ,13, vr_dsvlrprm13
                                         ,14, vr_dsvlrprm14
                                         ,15, vr_dsvlrprm15
                                         ,16, vr_dsvlrprm16
                                         ,17, vr_dsvlrprm17
                                         ,18, pr_dsvlrprm18
                                         ,19, vr_dsvlrprm19
                                         ,20, vr_dsvlrprm20
                                         ,21, pr_dsvlrprm21
                                         ,22, pr_dsvlrprm22
                                         ,23, pr_dsvlrprm23
                                         ,24, pr_dsvlrprm24
                                         ,25, pr_dsvlrprm25));
         END IF;

       EXCEPTION
         WHEN OTHERS THEN
           pr_des_erro := 'Erro ao atualizar parametros: '||SQLERRM;
       END;

     END LOOP;

     IF vr_typ_log.EXISTS(1) THEN -- Se foi inserido algum registro
        -- Gerando Log de Consulta
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => 'OK'
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Inserido param servico folha IB c/ sucesso - PARFOL.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> SUCESSO/TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Lendo os registros
        FOR ind IN vr_tab_cdacesso.FIRST..vr_tab_cdacesso.LAST LOOP
           -- Gravando log dos parametros de sistemas
           IF vr_typ_log(1).EXISTS(ind) THEN
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       , pr_nmdcampo => vr_tab_dscmptel(ind)
                                       , pr_dsdadant => vr_typ_log(1)(ind).valor_old
                                       , pr_dsdadatu => vr_typ_log(1)(ind).valor_new);
           END IF;
        END LOOP;
     END IF;

     IF vr_typ_log.EXISTS(2) THEN -- Se foi alterado algum registro
        -- Gerando Log de Consulta
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => 'OK'
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Atualizacao param servico folha IB c/ sucesso - PARFOL.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> SUCESSO/TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Lendo os registros
        FOR ind IN vr_tab_cdacesso.FIRST..vr_tab_cdacesso.LAST LOOP
           -- Gravando log dos parametros de sistemas
           IF vr_typ_log(2).EXISTS(ind) THEN
             GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     , pr_nmdcampo => vr_tab_dscmptel(ind)
                                     , pr_dsdadant => vr_typ_log(2)(ind).valor_old
                                     , pr_dsdadatu => vr_typ_log(2)(ind).valor_new);
           END IF;
        END LOOP;
     END IF;

     -- Efetivar as informações
     COMMIT;

   EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_dscritic := pr_des_erro;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Parametrizacao Servico Folha IB  - PARFOL.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;
      pr_des_erro := 'Erro geral na rotina pc_grava_prm_folhaib: '||SQLERRM;
      pr_dscritic := pr_des_erro;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Parametrizacao Servico Folha IB - PARFOL.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
   END pc_grava_prm_folhaib;


   -- Realiza a gravação dos parametros da Folha IB informados na tela PARFOL
   PROCEDURE pc_consulta_prm_folhaib(pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

     /* .............................................................................

      Programa: pc_consulta_prm_folhaib
      Sistema : AyllosWeb
      Sigla   : FOLH
      Autor   : Renato Darosci - Supero
      Data    : Maio/2015.                  Ultima atualizacao: 18/11/2015

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua a consulta dos parametros de Folha IB
      Observacao: -----

      Alteracoes: 18/11/2015 - Gerando Log de Comsulta da tela PARFOL - Melhoria
                             -- Desconsiderando a posicao 4 do array de acessos
                              (Andre Santos - SUPERO)

     ..............................................................................*/
     -- Cursores
     CURSOR cr_crapprm(pr_cdcooper crapprm.cdcooper%TYPE
                      ,pr_cdacesso crapprm.cdacesso%TYPE) IS
       SELECT prm.dsvlrprm
         FROM crapprm prm
        WHERE prm.cdcooper = pr_cdcooper
          AND prm.nmsistem = 'CRED'
          AND prm.cdacesso = pr_cdacesso;

     -- Variáveis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_nmeacao          VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);
     vr_dsvlrprm         crapprm.dsvlrprm%TYPE;

     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(100);

     -- Excessões
     vr_exc_erro         EXCEPTION;

   BEGIN

     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      -- Buscando descricao da origem do ambiente
      vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

      -- Para cada campo da tela... buscar o parametro
      FOR ind IN vr_tab_cdacesso.FIRST..vr_tab_cdacesso.LAST LOOP
        -- Buscar o valor do parametro
        OPEN  cr_crapprm(vr_cdcooper, vr_tab_cdacesso(ind));
        FETCH cr_crapprm INTO vr_dsvlrprm;

        -- Se não encontrar o valor é null
        IF cr_crapprm%NOTFOUND THEN
           vr_dsvlrprm := NULL;
        END IF;
        -- Fechar o cursor
        CLOSE cr_crapprm;

        -- Criar nodo filho
       pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                          ,'/Root'
                                          ,XMLTYPE('<dsvlrprm'||ind||'>'||vr_dsvlrprm||'</dsvlrprm'||ind||'>'));

      END LOOP;

      vr_dstransa := 'Buscando Parametros de Servico Folha IB - PARFOL.';
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
   EXCEPTION
     WHEN vr_exc_erro THEN
       -- Desfazer alterações
       ROLLBACK;
       pr_dscritic := pr_des_erro;
       -- Retorno não OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'Parametrizacao Servico Folha IB - PARFOL.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => 0
                           ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
       -- Desfazer alterações
       ROLLBACK;
       pr_des_erro := 'Erro geral na rotina pc_consulta_prm_folhaib: '||SQLERRM;
       pr_dscritic := pr_des_erro;
       -- Retorno não OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'Parametrizacao Servico Folha IB - PARFOL.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => 0
                           ,pr_nrdrowid => vr_nrdrowid);
       -- Commit do LOG
       COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Dados>Rotina com erros</Dados></Root>');
   END pc_consulta_prm_folhaib;

   /* Busca dados para exibir na tela ESTPFP */
   PROCEDURE pc_lista_dados_estpfp(pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_lista_dados_estpfp
   --  Sistema  : AyllosWeb
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Maio/2015.                   Ultima atualizacao: 30/10/2017
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Busca dados para exibir na tela ESTPFP
   -- Alteracoes:
   --
   -- Alteracoes: 20/11/2015 - Gerando Log de Comsulta da tela ESTFOL - Melhoria
   --                          (Andre Santos - SUPERO)
   --
   --             07/07/2016 - Mudança nos parâmetros da chamada de saldo para melhora
   --                          de performance - Marcos(Supero)
   -- 
   --             30/10/2017 - Somando os pagamentos aprovados e nao debitados na verificação
   --                          de estouro, conforme solicitado no chamado 707298 (Kelvin).
   --
   ---------------------------------------------------------------------------------------------------------------

      -- Cursores

      -- Buscar as informacoes da cooperativa
      CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdbcoctl
             , crapcop.cdagectl
             , crapcop.nmrescop
          FROM crapcop
         WHERE crapcop.cdcooper = p_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca os dados de convenios
      CURSOR cr_crappfp(p_cdcooper crapcop.cdcooper%TYPE) IS
         SELECT ass.cdcooper
               ,ass.cdagenci
               ,emp.cdempres
               ,emp.nmresemp
               ,ass.nrdconta
               ,MIN(TO_CHAR(pfp.dtsolest,'hh24:mi')) dtsolest
               ,SUM(pfp.qtlctpag) qtlctpag
               ,SUM(pfp.vllctpag) vllctpag
               ,SUM(pfp.qtlctpag*pfp.vltarapr) vltarire
               ,to_number(ass.vllimcre) vllimcre
           FROM crapass ass
               ,crapemp emp
               ,crappfp pfp
          WHERE pfp.cdcooper = p_cdcooper --> Cooperativa conectada
            AND pfp.idsitapr = 2          --> Em estouro
            AND pfp.cdcooper = emp.cdcooper
            AND pfp.cdempres = emp.cdempres
            AND emp.cdcooper = ass.cdcooper
            AND emp.nrdconta = ass.nrdconta
          GROUP BY ass.cdcooper
                  ,ass.cdagenci
                  ,emp.cdempres
                  ,emp.nmresemp
                  ,ass.nrdconta
                  ,ass.vllimcre;
      rw_crappfp cr_crappfp%ROWTYPE;
      
      -- Busca os dados de convenios
      CURSOR cr_crappfp_aprovados(p_cdcooper crapcop.cdcooper%TYPE
                                 ,p_cdempres crapemp.cdempres%TYPE) IS
        SELECT ass.cdcooper
              ,ass.cdagenci
              ,emp.cdempres
              ,emp.nmresemp
              ,ass.nrdconta
              ,MIN(TO_CHAR(pfp.dtsolest,'hh24:mi')) dtsolest
              ,SUM(pfp.qtlctpag) qtlctpag
              ,SUM(pfp.vllctpag) vllctpag
              ,SUM(pfp.qtlctpag*pfp.vltarapr) vltarire
              ,to_number(ass.vllimcre) vllimcre
          FROM crapass ass
              ,crapemp emp
              ,crappfp pfp
         WHERE pfp.cdcooper = p_cdcooper --> Cooperativa conectada
           AND pfp.idsitapr = 5 --> pendentes
           AND pfp.flsitdeb = 0
           AND pfp.cdcooper = emp.cdcooper
           AND pfp.cdempres = emp.cdempres
           AND emp.cdcooper = ass.cdcooper
           AND emp.nrdconta = ass.nrdconta
           AND emp.cdempres = p_cdempres
         GROUP BY ass.cdcooper
                 ,ass.cdagenci
                 ,emp.cdempres
                 ,emp.nmresemp
                 ,ass.nrdconta
                 ,ass.vllimcre;                  
      rw_crappfp_aprovados cr_crappfp_aprovados%ROWTYPE;
      
      -- Variaveis
      vr_excerror EXCEPTION;

      vr_cdcooper    NUMBER;
      vr_nmdatela    VARCHAR2(25);
      vr_nmeacao     VARCHAR2(25);
      vr_cdagenci    VARCHAR2(25);
      vr_nrdcaixa    VARCHAR2(25);
      vr_idorigem    VARCHAR2(25);
      vr_cdoperad    VARCHAR2(25);
      vr_dsretorn    VARCHAR2(32767);
      vr_ind_sald    PLS_INTEGER;
      vr_vlsddisp    crapsda.vlsddisp%TYPE;
      vr_vllancto    NUMBER;

      -- Cursor generico de calendario
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Temp-Table com o saldo do dia
      vr_tab_sald EXTR0001.typ_tab_saldos;

      -- Temp-table para armazenar o erro
      vr_tab_erro GENE0001.typ_tab_erro;

      vr_index PLS_INTEGER;

      -- Variavel Tabela Temporaria
      vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
      vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG's do XML

      vr_nrdrowid    ROWID;
      vr_dsorigem    VARCHAR2(100);
      vr_dstransa    VARCHAR2(100);
      vr_qtdregis    VARCHAR2(100);

   BEGIN

      -- Extrair informacoes padrao do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      -- Buscando descricao da origem do ambiente
      vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

      -- Buscar dados da cooperativa
      OPEN  cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
         -- Se nao encontrar dados
         IF cr_crapcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcop;
            pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapcop;

      vr_qtdregis := 0;

      OPEN cr_crappfp(vr_cdcooper);
         LOOP
            FETCH cr_crappfp INTO rw_crappfp;
            EXIT WHEN cr_crappfp%NOTFOUND;

            -- Verificacao do calendario
            OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crappfp.cdcooper);
            FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
            CLOSE BTCH0001.cr_crapdat;

            extr0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crappfp.cdcooper
                                       ,pr_rw_crapdat => rw_crapdat
                                       ,pr_cdagenci   => rw_crappfp.cdagenci
                                       ,pr_nrdcaixa   => 0
                                       ,pr_cdoperad   => '1'
                                       ,pr_nrdconta   => rw_crappfp.nrdconta
                                       ,pr_vllimcre   => rw_crappfp.vllimcre
                                       ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                       ,pr_flgcrass   => FALSE --> Não carregar a crapass inteira
                                       ,pr_tipo_busca => 'A' --> Busca da SDA do dia anterior
                                       ,pr_des_reto   => vr_dsretorn
                                       ,pr_tab_sald   => vr_tab_sald
                                       ,pr_tab_erro   => vr_tab_erro);

            -- Se encontrar erro
            IF vr_dsretorn <> 'OK' THEN
               -- Fecha cursor
               CLOSE cr_crappfp;

               -- Presente na tabela de erros
               IF vr_tab_erro.count > 0 THEN
                  -- Adquire descrição
                  pr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
               END IF;

               -- Gera exceção
               RAISE vr_excerror;
            END IF;

            -- Alimenta indice da temp-table
            vr_ind_sald := vr_tab_sald.last;

            -- Adquire saldo disponível total da conta
            vr_vlsddisp := vr_tab_sald(vr_ind_sald).vlsddisp;
            
            OPEN cr_crappfp_aprovados(p_cdcooper => vr_cdcooper
                                     ,p_cdempres => rw_crappfp.cdempres);
              FETCH cr_crappfp_aprovados
                INTO rw_crappfp_aprovados;
            CLOSE cr_crappfp_aprovados;
            
            vr_vllancto := NVL(rw_crappfp_aprovados.vllctpag,0) + NVL(rw_crappfp.vllctpag,0);
            
            -- Se houver saldo suficiente
            IF (vr_vlsddisp + NVL(rw_crappfp.vllimcre,0)) - vr_vllancto >= 0 THEN
               CONTINUE; -- Proximo registro
            END IF;

            -- Captura ultimo indice da PL Table
            vr_index := nvl(vr_tab_dados.count, 0) + 1;
            -- Gravando registros
            vr_tab_dados(vr_index)('cdagenci') := rw_crappfp.cdagenci;
            vr_tab_dados(vr_index)('cdempres') := rw_crappfp.cdempres;
            vr_tab_dados(vr_index)('nmresemp') := rw_crappfp.nmresemp;
            vr_tab_dados(vr_index)('nrdconta') := gene0002.fn_mask_conta(rw_crappfp.nrdconta);
            vr_tab_dados(vr_index)('dtsolest') := rw_crappfp.dtsolest;
            vr_tab_dados(vr_index)('qtlctpag') := rw_crappfp.qtlctpag;
            vr_tab_dados(vr_index)('vllctpag') := TO_CHAR(rw_crappfp.vllctpag, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.');
            vr_tab_dados(vr_index)('vltarire') := TO_CHAR(rw_crappfp.vltarire, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.');
            vr_tab_dados(vr_index)('vltotdeb') := TO_CHAR((NVL(rw_crappfp.vllctpag,0) +  NVL(rw_crappfp.vltarire,0)), 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.');
            vr_tab_dados(vr_index)('vlestour') := TO_CHAR(ABS(vr_vlsddisp + NVL(rw_crappfp.vllimcre,0) - vr_vllancto), 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.');
         END LOOP;
      CLOSE cr_crappfp;

      vr_qtdregis := vr_index;

      -- Geracao de TAG's
      gene0007.pc_gera_tag('indrowid',vr_tab_tags);
      gene0007.pc_gera_tag('cdagenci',vr_tab_tags);
      gene0007.pc_gera_tag('cdempres',vr_tab_tags);
      gene0007.pc_gera_tag('nmresemp',vr_tab_tags);
      gene0007.pc_gera_tag('nrdconta',vr_tab_tags);
      gene0007.pc_gera_tag('dtsolest',vr_tab_tags);
      gene0007.pc_gera_tag('qtlctpag',vr_tab_tags);
      gene0007.pc_gera_tag('vllctpag',vr_tab_tags);
      gene0007.pc_gera_tag('vltarire',vr_tab_tags);
      gene0007.pc_gera_tag('vltotdeb',vr_tab_tags);
      gene0007.pc_gera_tag('vlestour',vr_tab_tags);

      -- Forma XML de retorno para casos de sucesso (listar dados)
      gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                          ,pr_tab_tag   => vr_tab_tags
                          ,pr_XMLType   => pr_retxml
                          ,pr_path_tag  => '/Root'
                          ,pr_tag_no    => 'retorno'
                          ,pr_des_erro  => pr_des_erro);

      vr_dstransa := 'Busca Analise Estouro Folha Pagto - ESTFOL. Retornou: '||TRIM(gene0002.fn_mask(NVL(vr_qtdregis,0),'zzzzz9'))||' regitro(s).';
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);

      -- Efetua Commit
      COMMIT;

   EXCEPTION
      WHEN vr_excerror THEN
         -- Desfaz as alteracoes
         ROLLBACK;
         pr_dscritic := pr_des_erro;
         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => NVL(pr_dscritic,' ')
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => 'Analise de Estouro de Folha de Pagamento - ESTFOL.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nrdconta => 0
                             ,pr_nrdrowid => vr_nrdrowid);
         -- Commit do LOG
         COMMIT;
         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');
      WHEN OTHERS THEN
         -- Desfaz as alteracoes
         ROLLBACK;
         pr_des_erro := 'Erro geral na rotina pc_lista_dados_estpfp: '||SQLERRM;
         pr_dscritic := 'Erro geral na rotina pc_lista_dados_estpfp: '||SQLERRM;
         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => NVL(pr_dscritic,' ')
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => 'Analise de Estouro de Folha de Pagamento - ESTFOL.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nrdconta => 0
                             ,pr_nrdrowid => vr_nrdrowid);
         -- Commit do LOG
         COMMIT;
         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');
   END pc_lista_dados_estpfp;

   -- Rotina de aprovacao/reprovacao de folha de pagamento
   PROCEDURE pc_aprova_reprova_pagto(pr_dsjustif IN VARCHAR2
                                    ,pr_dsmsgeml IN VARCHAR2
                                    ,pr_cdeftpag IN VARCHAR2
                                    ,pr_cdempres IN VARCHAR2
                                    ,pr_dtsolest IN VARCHAR2
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_aprova_pagto
   --  Sistema  : AyllosWeb
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Maio/2015.                   Ultima atualizacao: 07/07/2016
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedimento validar e efetuar a aprovacao de pagamento de conta
   --
   -- Alteracoes: 20/11/2015 - Gerando log de aprovacao de pagamentos
   --                         (Andre Santos - SUPERO)
   --
   --             25/01/2016 - Adicionado nrdconta na geracao do log, passado até entao com 0.
   --                          (Jorge/Marcos Supero).
   --
   --             27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
   --
   --             07/07/2016 - Mudança nos parâmetros da chamada de saldo para melhora
   --                          de performance - Marcos(Supero)   
   ---------------------------------------------------------------------------------------------------------------
      -- Cursores

      -- Buscar as informacoes da cooperativa
      CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdbcoctl
             , crapcop.cdagectl
             , crapcop.nmrescop
             , crapcop.cdcooper
          FROM crapcop
         WHERE crapcop.cdcooper = p_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca pagamentos de folha de pagamanto
      CURSOR cr_crappfp(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_cdempres IN crappfp.cdempres%TYPE) IS
         SELECT ass.cdcooper
               ,ass.cdagenci
               ,emp.cdempres
               ,emp.nmresemp
               ,ass.nrdconta
               ,pfp.idsitapr
               ,DECODE(pfp.idsitapr,2,'2 - Em estouro'
                                   ,3,'3 - Reprovado'
                                   ,4,'4 - Aprv.Estouro'
                                   ,5,'5 - Aprovado') dssitapr
               ,MIN(TO_CHAR(pfp.dtsolest,'hh24:mi')) dtsolest
               ,SUM(pfp.qtlctpag) qtlctpag
               ,SUM(pfp.vllctpag) vllctpag
               ,to_number(ass.vllimcre) vllimcre
           FROM crapass ass
               ,crapemp emp
               ,crappfp pfp
          WHERE pfp.cdcooper = p_cdcooper --> Cooperativa conectada
            AND pfp.idsitapr = 2 --> Em estouro
            AND pfp.cdempres = p_cdempres
            AND pfp.cdcooper = emp.cdcooper
            AND pfp.cdempres = emp.cdempres
            AND emp.cdcooper = ass.cdcooper
            AND emp.nrdconta = ass.nrdconta
          GROUP BY ass.cdcooper
                  ,ass.cdagenci
                  ,emp.cdempres
                  ,emp.nmresemp
                  ,ass.nrdconta
                  ,DECODE(pfp.idsitapr,2,'2 - Em estouro'
                                      ,3,'3 - Reprovado'
                                      ,4,'4 - Aprv.Estouro'
                                      ,5,'5 - Aprovado')
                  ,pfp.idsitapr
                  ,ass.vllimcre;
      rw_crappfp cr_crappfp%ROWTYPE;

      -- Busca e-mail da empresa
      CURSOR cr_crapemp(p_cdcooper IN crapcop.cdcooper%type
                       ,p_cdempres crapemp.cdempres%TYPE) IS
         SELECT emp.nrdconta
               ,emp.dsdemail
               ,emp.nmextemp
           FROM crapemp emp
          WHERE emp.cdcooper = p_cdcooper
            AND emp.cdempres = p_cdempres
            AND trim(emp.dsdemail) IS NOT NULL;
      rw_crapemp cr_crapemp%ROWTYPE;

      -- Variaveis
      vr_excerror    EXCEPTION;

      rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;
      vr_dsretorn    VARCHAR2(2);
      vr_ind_sald    PLS_INTEGER;
      vr_vlsddisp    crapsda.vlsddisp%TYPE;

      -- Temp-Table com o saldo do dia
      vr_tab_sald EXTR0001.typ_tab_saldos;

      -- Temp-table para armazenar o erro
      vr_tab_erro GENE0001.typ_tab_erro;

      vr_cdcooper    NUMBER;
      vr_nmdatela    VARCHAR2(25);
      vr_nmeacao     VARCHAR2(25);
      vr_cdagenci    VARCHAR2(25);
      vr_nrdcaixa    VARCHAR2(25);
      vr_idorigem    VARCHAR2(25);
      vr_cdoperad    VARCHAR2(25);

      vr_assunto     VARCHAR2(32767);
      vr_desmsgem    VARCHAR2(32767);

      vr_hrlimest    VARCHAR2(10);

      vr_nrdrowid    ROWID;
      vr_dsorigem    VARCHAR2(100);
      vr_dstransa    VARCHAR2(100);
      vr_tpoperac    VARCHAR2(100);
      vr_nrctaemp    NUMBER := 0;

   BEGIN
      -- Inicializa Variavel
      pr_cdcritic := 0;
      pr_dscritic := NULL;
      pr_des_erro := NULL;

      -- Extrair informacoes padrao do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      -- Buscando descricao da origem do ambiente
      vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

      -- Buscar dados da cooperativa
      OPEN  cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
         -- Se nao encontrar dados
         IF cr_crapcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcop;
            pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapcop;

      vr_hrlimest := GENE0001.FN_PARAM_SISTEMA('CRED',vr_cdcooper,'FOLHAIB_HOR_LIM_ANA_EST');
      -- Se horario atual for superior ao parametro de sistema
      IF TO_CHAR(SYSDATE,'hh24:mi') > vr_hrlimest THEN
         pr_cdcritic := 1;
         pr_des_erro := vr_hrlimest;
         pr_nmdcampo := 'dsjustif';
         RAISE vr_excerror;
      END IF;

      -- Justificativa deve possuir no minimo 40 caracteres
      IF LENGTH(NVL(pr_dsjustif,0)) < 40 THEN
         pr_cdcritic := 2;
         pr_des_erro := 'Justificativa deve possuir no minimo 40 caracteres!';
         pr_nmdcampo := 'dsjustif';
         RAISE vr_excerror;
      END IF;

      -- Justificativa deve possuir no minimo 40 caracteres
      IF LENGTH(NVL(pr_dsmsgeml,0)) < 40 THEN
         pr_cdcritic := 5;
         pr_des_erro := 'Corpo do e-mail deve possuir no minimo 40 caracteres!';
         pr_nmdcampo := 'dsmsgeml';
         RAISE vr_excerror;
      END IF;

      OPEN cr_crappfp(rw_crapcop.cdcooper
                     ,pr_cdempres);
      FETCH cr_crappfp INTO rw_crappfp;
         -- Nao localizou o registro
         IF cr_crappfp%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crappfp;
            -- Gera critica
            pr_cdcritic := 3;
            pr_des_erro := 'Registro nao localizado!';
            pr_nmdcampo := 'dsjustif';
            RAISE vr_excerror;
         END IF;

         IF rw_crappfp.idsitapr <> '2' THEN
            -- Fecha cursor
            CLOSE cr_crappfp;
            -- Gera critica
            pr_cdcritic := 4;
            pr_des_erro := rw_crappfp.dssitapr;
            pr_nmdcampo := 'dsjustif';
            RAISE vr_excerror;
         END IF;

         -- Verificacao do calendario
         OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crappfp.cdcooper);
         FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
         CLOSE BTCH0001.cr_crapdat;

         extr0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crappfp.cdcooper
                                    ,pr_rw_crapdat => rw_crapdat
                                    ,pr_cdagenci   => rw_crappfp.cdagenci
                                    ,pr_nrdcaixa   => 0
                                    ,pr_cdoperad   => '1'
                                    ,pr_nrdconta   => rw_crappfp.nrdconta
                                    ,pr_vllimcre   => rw_crappfp.vllimcre
                                    ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                    ,pr_flgcrass   => FALSE --> Não carregar a crapass inteira
                                    ,pr_tipo_busca => 'A' --> Busca da SDA do dia anterior
                                    ,pr_des_reto   => vr_dsretorn
                                    ,pr_tab_sald   => vr_tab_sald
                                    ,pr_tab_erro   => vr_tab_erro);

         -- Se encontrar erro
         IF vr_dsretorn <> 'OK' THEN
            -- Fecha cursor
            CLOSE cr_crappfp;

            -- Presente na tabela de erros
            IF vr_tab_erro.count > 0 THEN
               -- Adquire descrição
               pr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            END IF;

            -- Gera exceção
            RAISE vr_excerror;
         END IF;

         -- Alimenta indice da temp-table
         vr_ind_sald := vr_tab_sald.last;

         -- Adquire saldo disponível total da conta
         vr_vlsddisp := vr_tab_sald(vr_ind_sald).vlsddisp;

         -- Se houver saldo suficiente
         IF (vr_vlsddisp + NVL(rw_crappfp.vllimcre,0) - NVL(rw_crappfp.vllctpag,0))>0 THEN
            pr_cdcritic := 6;
            pr_des_erro := 'Este pagamento sera debitado em breve, pois houve regularizacao de saldo e o Estouro em Conta nao e mais necessario!';
            pr_nmdcampo := 'dsjustif';
            RAISE vr_excerror;
         END IF;

      CLOSE cr_crappfp;

      -- Atualiza o registro na CRAPCFP
      BEGIN
         UPDATE crappfp pfp
            SET pfp.idsitapr = pr_cdeftpag --> (3-Estouro/4-Aprovado com estouro)
               ,pfp.cdopeest = vr_cdoperad
               ,pfp.dsjusest = gene0007.fn_convert_web_db(pr_dsjustif)
          WHERE pfp.cdcooper = rw_crappfp.cdcooper
            AND pfp.cdempres = TO_NUMBER(pr_cdempres)
            AND pfp.idsitapr = 2;
      EXCEPTION
         WHEN OTHERS THEN
            pr_cdcritic := 9999;
            pr_des_erro := 'Erro ao atualizar o registro na CRAPPFP: '||SQLERRM;
            pr_nmdcampo := 'dsjustif';
            RAISE vr_excerror;
      END;

      -- Busca e-mail da empresa
      OPEN cr_crapemp(rw_crappfp.cdcooper,TO_NUMBER(pr_cdempres));
      FETCH cr_crapemp INTO rw_crapemp;
         -- Se nao encontrar registro
         IF cr_crapemp%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapemp;
            -- Gera critica
            pr_cdcritic := 9999;
            pr_des_erro := 'E-mail da empresa nao localizado!';
            pr_nmdcampo := 'dsjustif';
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapemp;

      vr_nrctaemp := rw_crapemp.nrdconta;
      vr_desmsgem := gene0007.fn_convert_web_db(pr_dsmsgeml);

      -- Substitue as quebras de linha pela tag BR
      vr_desmsgem := REPLACE(vr_desmsgem,CHR(10),'<br />');

      IF pr_cdeftpag = 4 THEN -- Aprovado
         vr_assunto := 'Folha de Pagamento - Estouro aprovado';
      ELSIF pr_cdeftpag = 3 THEN -- Reprovado
         vr_assunto := 'Folha de Pagamento - Estouro reprovado';
      END IF;

      -- Enviar Email comunicando a aprovacao do estouro de pagamento
      gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                                ,pr_cdprogra        => 'FOLH0002'
                                ,pr_des_destino     => TRIM(rw_crapemp.dsdemail)
                                ,pr_des_assunto     => vr_assunto
                                ,pr_des_corpo       => vr_desmsgem
                                ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => pr_des_erro);

      -- Se houver erros
      IF pr_des_erro IS NOT NULL THEN
         -- Gera critica
         pr_cdcritic := 9999;
         RAISE vr_excerror;
      END IF;

      IF pr_cdeftpag = 4 THEN -- Aprovado
         vr_dstransa := 'Folha de Pagamento - Estouro aprovado - ESTFOL.';
         vr_tpoperac := 'Permitido';
      ELSIF pr_cdeftpag = 3 THEN -- Reprovado
         vr_dstransa := 'Folha de Pagamento - Estouro reprovado - ESTFOL.';
         vr_tpoperac := 'Reprovado';
      END IF;

      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => vr_nrctaemp
                          ,pr_nrdrowid => vr_nrdrowid);

      -- Log Item => Valor Permitido
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Empresa'
                            , pr_dsdadant => NULL
                            , pr_dsdadatu => rw_crapemp.nmextemp);
      -- Log Item => Valor Permitido
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Valor '||vr_tpoperac
                            , pr_dsdadant => NULL
                            , pr_dsdadatu => TRIM(TO_CHAR(rw_crappfp.vllctpag, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')));
      -- Log Item => Justificativa
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Justificativa'
                            , pr_dsdadant => NULL
                            , pr_dsdadatu => pr_dsjustif);

      -- Efetuar commit
      COMMIT;

   EXCEPTION
      WHEN vr_excerror THEN
         -- Desfaz as alteracoes
         ROLLBACK;
         pr_dscritic := pr_des_erro;
         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => NVL(pr_dscritic,' ')
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => 'Analise de Estouro de Folha de Pagamento - ESTFOL.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nrdconta => vr_nrctaemp
                             ,pr_nrdrowid => vr_nrdrowid);
         -- Commit do LOG
         COMMIT;
         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');
      WHEN OTHERS THEN
         -- Desfaz as alteracoes
         ROLLBACK;
         pr_des_erro := 'Erro geral na rotina pc_aprova_reprova_pagto: '||SQLERRM;
         pr_dscritic := 'Erro geral na rotina pc_aprova_reprova_pagto: '||SQLERRM;
         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => NVL(pr_dscritic,' ')
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => 'Analise de Estouro de Folha de Pagamento - ESTFOL.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nrdconta => vr_nrctaemp
                             ,pr_nrdrowid => vr_nrdrowid);
         -- Commit do LOG
         COMMIT;
         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');
   END pc_aprova_reprova_pagto;

   /* Procedimento para validar horario limite para aprovar e reprovar estouro de folha de pagamento */
   PROCEDURE pc_hrlimite_estouro(pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_hrlimite_estouro
   --  Sistema  : Genérico
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Maio/2015.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedimento para validar horario limite para aprovar e reprovar estouro de folha de pagamento
   -- Alteracoes:
   ---------------------------------------------------------------------------------------------------------------
      -- Cursores

      -- Buscar as informacoes da cooperativa
      CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdbcoctl
             , crapcop.cdagectl
             , crapcop.nmrescop
          FROM crapcop
         WHERE crapcop.cdcooper = p_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Variaveis
      vr_excerror EXCEPTION;

      vr_cdcooper    NUMBER;
      vr_nmdatela    VARCHAR2(25);
      vr_nmeacao     VARCHAR2(25);
      vr_cdagenci    VARCHAR2(25);
      vr_nrdcaixa    VARCHAR2(25);
      vr_idorigem    VARCHAR2(25);
      vr_cdoperad    VARCHAR2(25);

      vr_hrlimest    VARCHAR2(10);

   BEGIN
      -- Inicializa Variavel
      pr_cdcritic := 0;
      pr_dscritic := NULL;
      pr_des_erro := NULL;

      -- Extrair informacoes padrao do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      -- Buscar dados da cooperativa
      OPEN  cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
         -- Se nao encontrar dados
         IF cr_crapcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcop;
            pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
            RAISE vr_excerror;
         END IF;
      CLOSE cr_crapcop;

      vr_hrlimest := GENE0001.FN_PARAM_SISTEMA('CRED',vr_cdcooper,'FOLHAIB_HOR_LIM_ANA_EST');
      -- Se horario atual for superior ao parametro de sistema
      IF TO_CHAR(SYSDATE,'hh24:mi') > vr_hrlimest THEN
         pr_cdcritic := 1;
         pr_des_erro := vr_hrlimest;
         pr_nmdcampo := '';
         RAISE vr_excerror;
      END IF;

   EXCEPTION
      WHEN vr_excerror THEN
         pr_dscritic := pr_des_erro;

         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');
      WHEN OTHERS THEN
         pr_des_erro := 'Erro geral na rotina pc_hrlimite_estouro: '||SQLERRM;
         pr_dscritic := 'Erro geral na rotina pc_hrlimite_estouro: '||SQLERRM;

         -- Carregar XML padrao para variavel de retorno nao utilizada.
         -- Existe para satisfazer exigencia da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Dados>Rotina com erros</Dados></Root>');
   END pc_hrlimite_estouro;

  -- Realiza listagem das cooperativas que serão listadas nos parametros de pesquisa da tela RLPGFP
  PROCEDURE pc_lista_coop_pesquisa(pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo

    /* .............................................................................

      Programa: pc_lista_coop_pesquisa
      Sistema : ayllosWeb
      Sigla   : FOLH
      Autor   : Renato Darosci - Supero
      Data    : Junho/2015.                  Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Realiza listagem das cooperativas que serão listadas nos
                  parametros de pesquisa da tela RLPGFP
      Observacao: -----

      Alteracoes:

    ..............................................................................*/
    -- Cursores
    CURSOR cr_crapcop(pr_cdcooper crapprm.cdcooper%TYPE) IS
      SELECT t.cdcooper
           , t.nmrescop
        FROM crapcop  t
       WHERE t.flgativo = 1
         AND (t.cdcooper = pr_cdcooper
            OR pr_cdcooper = 3)
       ORDER BY t.nmrescop;

    -- Variáveis
    vr_cdcooper         NUMBER;
    vr_nmdatela         VARCHAR2(25);
    vr_nmeacao          VARCHAR2(25);
    vr_cdagenci         VARCHAR2(25);
    vr_nrdcaixa         VARCHAR2(25);
    vr_idorigem         VARCHAR2(25);
    vr_cdoperad         VARCHAR2(25);

    -- Excessões
    vr_exc_erro         EXCEPTION;

  BEGIN

    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    -- Criar cabecalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Para cada cooperativa encontrada
     FOR rw_crapcop IN cr_crapcop(vr_cdcooper) LOOP

       -- Criar nodo filho
       pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                          ,'/Root'
                                          ,XMLTYPE('<coop>'||
                                                   '<cdcooper>'||rw_crapcop.cdcooper||'</cdcooper>'||
                                                   '<nmrescop>'||rw_crapcop.nmrescop||'</nmrescop>'||
                                                   '</coop>'));

     END LOOP;


  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_dscritic := pr_des_erro;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_des_erro := 'Erro geral na rotina pc_lista_coop_pesquisa: '||SQLERRM;
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_lista_coop_pesquisa;

  -- Rotina para montar a listagem das folhas de pagamento
  PROCEDURE pc_consulta_folhas_pagto(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                    ,pr_cdempres IN NUMBER                --> Código da empresa informado na tela
                                    ,pr_dtmvtolt IN VARCHAR2              --> Data do Movimento
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
     ---------------------------------------------------------------------------------------------------------------
     --  Programa : pc_consulta_folhas_pagto
     --  Sistema  : AyllosWeb
     --  Sigla    : CRED
     --  Autor    : Renato Darosci - SUPERO
     --  Data     : Junho/2015.                   Ultima atualizacao: 17/08/2016
     --
     -- Dados referentes ao programa:
     --
     -- Frequencia: -----
     -- Objetivo  : Busca dados para exibir na tela PAGFOL
     --
     -- Alteracoes: 12/11/2015 - Migracao da tarifação do sistema da CONFOL para CADTAR (Marcos-Supero)
     --
     --             20/11/2015 - Gerando Log de Comsulta da tela PAGFOL - Melhoria
     --                          (Andre Santos - SUPERO)
     --
     --             16/02/2016 - Inclusao do parametro conta na chamada da
     --                          FOLH0001.fn_valor_tarifa_folha. (Jaison/Marcos)
     --
     --             17/08/2016 - Ajuste feito para não permitir continuar a operação
     --                          na tela pagfol caso a empresa não tenha convenio de
     --                          folha ativo, conforme solicitado no chamado 485808. 
     --                          (Kelvin).
     --
     ---------------------------------------------------------------------------------------------------------------

     -- CURSORES

     -- Buscar as informacoes da cooperativa
     CURSOR cr_dados(pr_cdcooper crapcop.cdcooper%TYPE
                    ,pr_cdempres crapemp.cdempres%TYPE
                    ,pr_dtmvtolt crappfp.dtmvtolt%TYPE) IS
       SELECT pfp.cdcooper
            , pfp.cdempres
            , pfp.nrseqpag     -- Sequencial dos pagamentos
            , to_char(pfp.dtmvtolt,'dd/mm/yyyy') dtmvtolt -- Data Agendamento - Data do Ultimo movimento antes da aprovação
            , DECODE(pfp.flsitcre,1, to_char(pfp.dthorcre,'dd/mm/yyyy - HH24:MI')
                                   , to_char(pfp.dtcredit,'dd/mm/yyyy')) dtcredit -- Data do Agendamento do Crédito
            , DECODE(pfp.flsitcre,1, 'OK',2,'Parcial', DECODE(pfp.idsitapr,4,'Age',5,'Age','Pen')) flsitcre      -- Situação do Crédito / true false
            , DECODE(pfp.flsitdeb,1, to_char(pfp.dthordeb,'dd/mm/yyyy - HH24:MI')
                                   , to_char(pfp.dtdebito,'dd/mm/yyyy')) dtdebito -- Data do Agendamento do Débito
            , DECODE(pfp.flsitdeb,1, 'OK', DECODE(pfp.idsitapr,4,'Age',5,'Age','Pen')) flsitdeb      -- Situação do Debito  / true false
            , pfp.qtlctpag                                          -- Quantidade total do arquivo de pagamento
            , pfp.vllctpag                                          -- Valor Total do arquivo de Pagamento
            , pfp.idsitapr
            , (folh0001.fn_valor_tarifa_folha(pr_cdcooper,emp.nrdconta,emp.cdcontar,pfp.idopdebi,pfp.vllctpag) * pfp.qtlctpag) vltarcfp
            , (pfp.qtlctpag * pfp.vltarapr) vltarpfp
         FROM crapemp emp
            , crappfp pfp
            , crapage age
            , crapreg reg
            , crapass ass
            , crapcop cop
            , crapdat dat
        WHERE emp.cdcooper = pfp.cdcooper
          AND emp.cdempres = pfp.cdempres
          AND cop.cdcooper = emp.cdcooper
          AND pfp.cdcooper = pr_cdcooper
          AND pfp.cdempres = pr_cdempres
          AND (TRUNC(pfp.dtmvtolt) = pr_dtmvtolt OR
               TRUNC(pfp.dtcredit) = pr_dtmvtolt OR
               TRUNC(pfp.dtdebito) = pr_dtmvtolt OR
               TRUNC(pfp.dthorcre) = pr_dtmvtolt OR
               TRUNC(pfp.dthordeb) = pr_dtmvtolt)
          -- Regional
          AND ass.cdcooper = emp.cdcooper
          AND ass.nrdconta = emp.nrdconta
          AND age.cdcooper = emp.cdcooper
          AND age.cdagenci = ass.cdagenci
          AND reg.cdcooper(+) = age.cdcooper
          AND reg.cddregio(+) = age.cddregio
          AND dat.cdcooper = cop.cdcooper
        ORDER BY pfp.dtmvtolt, pfp.nrseqpag;

     -- Buscar dados da empresa e da cooperativa
     CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_cdempres crapemp.cdempres%TYPE) IS
       SELECT cop.nmrescop||' - '||cop.nmextcop    nmcooper           -- Nome da cooperativa
            , emp.cdempres                         cdempres           -- Cod Empresa
            , emp.nmresemp                         dsempres           -- Nome da empresa
            , emp.nmextemp                         nmextemp           -- Nome Extenso da Empresa
            , reg.dsdregio                         dsdregio           -- Descrição da região
            , 'NOME CONSULTOR'                     nmconspj           -- Nome do consultor PJ
            , GENE0002.fn_mask_conta(emp.nrdconta) nrdconta           -- Conta da empresa
            , emp.nrdconta                         nrdconta_emp       -- Conta da empresa
            , to_char(age.cdagenci,'FM000')||' - '||age.nmextage  nmagenci
            , to_char(emp.dtultufp,'dd/mm/yyyy') dtultufp -- Data e hora da ultimo uso do novo produto folha
         FROM crapemp emp
            , crapage age
            , crapreg reg
            , crapass ass
            , crapcop cop
        WHERE ass.cdcooper = emp.cdcooper
          AND ass.nrdconta = emp.nrdconta
          AND age.cdcooper = emp.cdcooper
          AND age.cdagenci = ass.cdagenci
          AND reg.cdcooper(+) = age.cdcooper
          AND reg.cddregio(+) = age.cddregio
          AND cop.cdcooper = emp.cdcooper
          AND emp.cdempres = pr_cdempres
          AND cop.cdcooper = pr_cdcooper;
     rw_crapcop     cr_crapcop%ROWTYPE;

     -- Buscar quantidade CTASAL
     CURSOR cr_qtctasal(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_cdempres crapemp.cdempres%TYPE
                       ,pr_nrseqpag craplfp.nrseqpag%TYPE) IS
       SELECT COUNT(ccs.nrdconta) qtd_ctasal
         FROM crapccs ccs
            , crappfp pfp
            , craplfp lfp
        WHERE ccs.cdcooper = pfp.cdcooper
          AND ccs.nrdconta = lfp.nrdconta
          AND ccs.nrcpfcgc = lfp.nrcpfemp
          AND pfp.cdcooper = lfp.cdcooper
          AND pfp.cdempres = lfp.cdempres
          AND pfp.nrseqpag = lfp.nrseqpag
          AND lfp.cdcooper = pr_cdcooper
          AND lfp.cdempres = pr_cdempres
          AND lfp.nrseqpag = pr_nrseqpag;

     -- Variaveis
     vr_excerror EXCEPTION;

     vr_cdcooper    NUMBER;
     vr_nmdatela    VARCHAR2(25);
     vr_nmeacao     VARCHAR2(25);
     vr_cdagenci    VARCHAR2(25);
     vr_nrdcaixa    VARCHAR2(25);
     vr_idorigem    VARCHAR2(25);
     vr_cdoperad    VARCHAR2(25);
     vr_qtctasal    NUMBER;
     vr_dtmvtolt    DATE;

     vr_index PLS_INTEGER;

     -- Variavel Tabela Temporaria
     vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
     vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG's do XML

     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(100);
     vr_qtdregis    VARCHAR2(100);

   BEGIN

     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Buscando descricao da origem do ambiente
     vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

     -- Buscar os dados da cooperativa e da empresa
     OPEN  cr_crapcop(pr_cdcooper, pr_cdempres);
     FETCH cr_crapcop INTO rw_crapcop;
     CLOSE cr_crapcop;

     IF rw_crapcop.nrdconta = '0' OR 
        TRIM(rw_crapcop.nrdconta) IS NULL THEN
     
        pr_des_erro := 'Empresa ' || pr_cdempres  || ' nao possui convenio de folha ativo!';
        RAISE vr_excerror;
     END IF;
     
     -- Converte a STRING data para DATE
     vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/RRRR');

     -- Criar cabecalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root nmcooper="'||rw_crapcop.nmcooper||
                                                                                    '" dsempres="'||rw_crapcop.dsempres||
                                                                                    '" dsdregio="'||rw_crapcop.dsdregio||
                                                                                    '" nmconspj="'||rw_crapcop.nmconspj||
                                                                                    '" nmagenci="'||rw_crapcop.nmagenci||
                                                                                    '" nrdconta="'||rw_crapcop.nrdconta||
                                                                                    '" dtultufp="'||rw_crapcop.dtultufp||'" />');

     -- Percorre todas as informações retornadas no cursor
     FOR rw_dados IN cr_dados(pr_cdcooper => pr_cdcooper,
                              pr_cdempres => pr_cdempres,
                              pr_dtmvtolt => vr_dtmvtolt) LOOP

       -- Zerar a variável a cada iteração
       vr_qtctasal := 0;
       vr_qtdregis := 0;

       -- Buscar a qtd CTASAL
       OPEN  cr_qtctasal(pr_cdcooper
                        ,pr_cdempres
                        ,rw_dados.nrseqpag);
       FETCH cr_qtctasal INTO vr_qtctasal;
       CLOSE cr_qtctasal;

       -- Captura ultimo indice da PL Table
       vr_index := nvl(vr_tab_dados.count, 0) + 1;
       -- Gravando registros
       vr_tab_dados(vr_index)('cdcooper') := rw_dados.cdcooper;
       vr_tab_dados(vr_index)('cdempres') := rw_dados.cdempres;
       vr_tab_dados(vr_index)('nrseqpag') := rw_dados.nrseqpag;
       vr_tab_dados(vr_index)('dtmvtolt') := rw_dados.dtmvtolt;
       vr_tab_dados(vr_index)('dtcredit') := rw_dados.dtcredit;
       vr_tab_dados(vr_index)('flsitcre') := rw_dados.flsitcre;
       vr_tab_dados(vr_index)('dtdebito') := rw_dados.dtdebito;
       vr_tab_dados(vr_index)('flsitdeb') := rw_dados.flsitdeb;
       vr_tab_dados(vr_index)('qtlctpag') := TO_CHAR(rw_dados.qtlctpag, 'fm999g999g999g999g999g990', 'NLS_NUMERIC_CHARACTERS=,.');
       vr_tab_dados(vr_index)('qtctasal') := TO_CHAR(NVL(vr_qtctasal,0),'fm999g999g999g999g999g990', 'NLS_NUMERIC_CHARACTERS=,.');
       vr_tab_dados(vr_index)('vllctpag') := TO_CHAR(rw_dados.vllctpag, 'fm999g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.');

       IF rw_dados.idsitapr > 1 THEN
         vr_tab_dados(vr_index)('vltarifa') := TO_CHAR(rw_dados.vltarpfp, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.');
       ELSE
         vr_tab_dados(vr_index)('vltarifa') := TO_CHAR(rw_dados.vltarcfp, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.');
       END IF;

     END LOOP;

     vr_qtdregis := vr_index;

     -- Geracao de TAG's
     gene0007.pc_gera_tag('cdcooper',vr_tab_tags);
     gene0007.pc_gera_tag('cdempres',vr_tab_tags);
     gene0007.pc_gera_tag('nrseqpag',vr_tab_tags);
     gene0007.pc_gera_tag('dtmvtolt',vr_tab_tags);
     gene0007.pc_gera_tag('dtcredit',vr_tab_tags);
     gene0007.pc_gera_tag('flsitcre',vr_tab_tags);
     gene0007.pc_gera_tag('dtdebito',vr_tab_tags);
     gene0007.pc_gera_tag('flsitdeb',vr_tab_tags);
     gene0007.pc_gera_tag('qtlctpag',vr_tab_tags);
     gene0007.pc_gera_tag('qtctasal',vr_tab_tags);
     gene0007.pc_gera_tag('vllctpag',vr_tab_tags);
     gene0007.pc_gera_tag('vltarifa',vr_tab_tags);
     gene0007.pc_gera_tag('nmcooper',vr_tab_tags);
     gene0007.pc_gera_tag('dsempres',vr_tab_tags);
     gene0007.pc_gera_tag('dsdregio',vr_tab_tags);
     gene0007.pc_gera_tag('nmconspj',vr_tab_tags);

     -- Forma XML de retorno para casos de sucesso (listar dados)
     gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                         ,pr_tab_tag   => vr_tab_tags
                         ,pr_XMLType   => pr_retxml
                         ,pr_path_tag  => '/Root'
                         ,pr_tag_no    => 'retorno'
                         ,pr_des_erro  => pr_des_erro);

     vr_dstransa := 'Buscando Relac. de Pagtos Folha - PAGFOL. Retornou: '||TRIM(gene0002.fn_mask(NVL(vr_qtdregis,0),'zzzzz9'))||' regitro(s).';
     -- Gerando Log de Consulta
     GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                         ,pr_cdoperad => vr_cdoperad
                         ,pr_dscritic => 'OK'
                         ,pr_dsorigem => vr_dsorigem
                         ,pr_dstransa => vr_dstransa
                         ,pr_dttransa => TRUNC(SYSDATE)
                         ,pr_flgtrans => 1 --> SUCESSO/TRUE
                         ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                         ,pr_idseqttl => 1
                         ,pr_nmdatela => vr_nmdatela
                         ,pr_nrdconta => rw_crapcop.nrdconta_emp
                         ,pr_nrdrowid => vr_nrdrowid);
     -- Log Item => Cooperativa Pesquisada
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                              , pr_nmdcampo => 'Cooperativa'
                              , pr_dsdadant => NULL
                              , pr_dsdadatu => rw_crapcop.nmcooper);
     -- Log Item => Data Informada
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                              , pr_nmdcampo => 'Data'
                              , pr_dsdadant => NULL
                              , pr_dsdadatu => TO_CHAR(vr_dtmvtolt,'DD/MM/YYYY'));
     -- Log Item => Empresa
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                              , pr_nmdcampo => 'Empresa'
                              , pr_dsdadant => NULL
                              , pr_dsdadatu => TRIM(GENE0002.fn_mask(rw_crapcop.cdempres,'999'))||': '||rw_crapcop.dsempres ||' - '||rw_crapcop.nmextemp);
     -- Commit do LOG
     COMMIT;

  EXCEPTION
    WHEN vr_excerror THEN
      -- Desfaz as alteracoes
      ROLLBACK;
      pr_dscritic := pr_des_erro;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Relacao de Pagamentos de Folha - PAGFOL.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
    WHEN OTHERS THEN
      -- Desfaz as alteracoes
      ROLLBACK;
      pr_des_erro := 'Erro geral na rotina pc_consulta_folhas_pagto: '||SQLERRM;
      pr_dscritic := 'Erro geral na rotina pc_consulta_folhas_pagto: '||SQLERRM;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Relacao de Pagamentos de Folha - PAGFOL.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_consulta_folhas_pagto;

-- Rotina para montar a listagem de detalhes das folhas de pagamento
  PROCEDURE pc_consulta_detalhes_pagto(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                      ,pr_cdempres IN NUMBER                --> Código da empresa selecionada na tela
                                      ,pr_nrseqpag IN NUMBER                --> Codigo da pagamentos selecionado na tela
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
     ---------------------------------------------------------------------------------------------------------------
     --  Programa : pc_consulta_detalhes_pagto
     --  Sistema  : AyllosWeb
     --  Sigla    : CRED
     --  Autor    : Renato Darosci - SUPERO
     --  Data     : Junho/2015.                   Ultima atualizacao: 20/11/2015
     --
     -- Dados referentes ao programa:
     --
     -- Frequencia: -----
     -- Objetivo  : Busca dados para exibir na tela PAGFOL
     --
     -- Alteracoes: 20/11/2015 - Gerando Log de Comsulta da tela PAGFOL - Melhoria
     --                         (Andre Santos - SUPERO)
     --
     --             15/07/2019 - Apresentar contas da modalidade salário com indicação "SALARIO"
     --                          na tela PAGFOL. (Renato Darosci - Supero)
     ---------------------------------------------------------------------------------------------------------------

     -- CURSORES

     -- Buscar as informacoes da cooperativa
     CURSOR cr_detalhes(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_cdempres crapemp.cdempres%TYPE
                       ,pr_nrseqpag crappfp.nrseqpag%TYPE) IS
       -- DETALHES DO PAGAMENTO - LANÇAMENTOS DE PAGAMENTO
       SELECT ass.nrcpfcgc      -- CPF
            , SUBSTR(ass.nmprimtl,0,40)  nmprimtl    -- Nome
            , ass.nrdconta      -- Conta
            , decode(tip.cdmodalidade_tipo, 2, 'SALARIO'
                                             , 'CONTA') dsmodali  -- Modalidade -> Se é um associado (ou se é nova conta salário) ou é uma conta salario / CONTA/CTASAL
            , lfp.nrseqlfp      -- Nr Sequencia Pagamento
            , lfp.vllancto      -- Valor do Lançamento / Valor pago
            , lfp.idsitlct      -- Situação Lançamento (‘L’-Lançado / ‘C’-Creditado / ‘T’-Transmitido / 'D'-Devolvido / ‘E’-Erro)
            , DECODE(lfp.idsitlct,'L','Lançado'
                                 ,'C','Creditado'
                                 ,'T','Transmitido'
                                 ,'D','Devolvido'
                                 ,'E','Erro') dssitlct
            , lfp.dsobslct      -- Observação do Lançamento -> Se há alguma mensagem sobre o lançamento
         FROM tbcc_tipo_conta tip
            , crapass         ass
            , crappfp         pfp
            , craplfp         lfp
        WHERE tip.inpessoa     = ass.inpessoa
          AND tip.cdtipo_conta = ass.cdtipcta
          AND pfp.cdcooper = lfp.cdcooper
          AND pfp.cdempres = lfp.cdempres
          AND pfp.nrseqpag = lfp.nrseqpag
          AND ass.cdcooper = pfp.cdcooper
          AND ass.nrdconta = lfp.nrdconta
          AND ass.nrcpfcgc = lfp.nrcpfemp
          AND pfp.cdcooper = pr_cdcooper
          AND pfp.cdempres = pr_cdempres
          AND pfp.nrseqpag = pr_nrseqpag
        UNION
       SELECT ccs.nrcpfcgc
            , SUBSTR(ccs.nmfuncio,0,40) nmprimtl
            , ccs.nrdconta
            , 'CTASAL' dsmodali
            , lfp.nrseqlfp      -- Nr Sequencia Pagamento
            , lfp.vllancto      -- Valor do Lançamento / Valor pago
            , lfp.idsitlct      -- Situação Lançamento (‘L’-Lançado / ‘C’-Creditado / ‘T’-Transmitido / 'D'-Devolvido / ‘E’-Erro)
            , DECODE(lfp.idsitlct,'L','Lançado'
                                 ,'C','Creditado'
                                 ,'T','Transmitido'
                                 ,'D','Devolvido'
                                 ,'E','Erro') dssitlct
            , lfp.dsobslct      -- Observação do Lançamento -> Se há alguma mensagem sobre o lançamento
         FROM crapccs ccs
            , crappfp pfp
            , craplfp lfp
        WHERE pfp.cdcooper = lfp.cdcooper
          AND pfp.cdempres = lfp.cdempres
          AND pfp.nrseqpag = lfp.nrseqpag
          AND ccs.cdcooper = pfp.cdcooper
          AND ccs.nrdconta = lfp.nrdconta
          AND ccs.nrcpfcgc = lfp.nrcpfemp
          AND pfp.cdcooper = pr_cdcooper
          AND pfp.cdempres = pr_cdempres
          AND pfp.nrseqpag = pr_nrseqpag
      ORDER BY nrseqlfp;

     -- Buscar as informacoes da cooperativa
      CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT crapcop.nmrescop ||' - '||crapcop.nmextcop nmcooper
          FROM crapcop
         WHERE crapcop.cdcooper = p_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

     --
     CURSOR cr_crapemp(p_cdcooper crapcop.cdcooper%TYPE
                      ,p_cdempres crapemp.cdempres%TYPE) IS
        SELECT TRIM(gene0002.fn_mask(crapemp.cdempres,999)) ||': ' ||
                                           crapemp.nmresemp ||' - '||
                                           crapemp.nmextemp nmempresa
              ,crapemp.nrdconta
          FROM crapemp
         WHERE crapemp.cdcooper = p_cdcooper
           AND crapemp.cdempres = p_cdempres;
      rw_crapemp cr_crapemp%ROWTYPE;

     -- Variaveis
     vr_excerror EXCEPTION;

     vr_cdcooper    NUMBER;
     vr_nmdatela    VARCHAR2(25);
     vr_nmeacao     VARCHAR2(25);
     vr_cdagenci    VARCHAR2(25);
     vr_nrdcaixa    VARCHAR2(25);
     vr_idorigem    VARCHAR2(25);
     vr_cdoperad    VARCHAR2(25);

     vr_index PLS_INTEGER;

     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(100);
     vr_qtdregis    VARCHAR2(100);

     -- Variavel Tabela Temporaria
     vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
     vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG's do XML

   BEGIN

     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Buscando descricao da origem do ambiente
     vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

     -- Busca os dados da cooperativa
     OPEN cr_crapcop(pr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
     CLOSE cr_crapcop;

     -- Busca os dados da Empresa
     OPEN cr_crapemp(pr_cdcooper
                    ,pr_cdempres);
     FETCH cr_crapemp INTO rw_crapemp;
     CLOSE cr_crapemp;

      -- Criar cabecalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Percorre todas as informações retornadas no cursor
     FOR rw_detalhes IN cr_detalhes(pr_cdcooper, pr_cdempres, pr_nrseqpag) LOOP

       -- Captura ultimo indice da PL Table
       vr_index := nvl(vr_tab_dados.count, 0) + 1;
       -- Gravando registros
       vr_tab_dados(vr_index)('nrcpfcgc') := GENE0002.fn_mask_cpf_cnpj(rw_detalhes.nrcpfcgc,1);
       vr_tab_dados(vr_index)('nrdconta') := GENE0002.fn_mask_conta(rw_detalhes.nrdconta);
       vr_tab_dados(vr_index)('nmprimtl') := rw_detalhes.nmprimtl;
       vr_tab_dados(vr_index)('dsmodali') := rw_detalhes.dsmodali;
       vr_tab_dados(vr_index)('vllancto') := TO_CHAR(rw_detalhes.vllancto, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.');
       vr_tab_dados(vr_index)('idsitlct') := rw_detalhes.idsitlct||' - '||rw_detalhes.dssitlct;
       vr_tab_dados(vr_index)('dsobslct') := rw_detalhes.dsobslct;

     END LOOP;

     vr_qtdregis := vr_index;

     -- Geracao de TAG's
     gene0007.pc_gera_tag('nrcpfcgc',vr_tab_tags);
     gene0007.pc_gera_tag('nrdconta',vr_tab_tags);
     gene0007.pc_gera_tag('nmprimtl',vr_tab_tags);
     gene0007.pc_gera_tag('dsmodali',vr_tab_tags);
     gene0007.pc_gera_tag('vllancto',vr_tab_tags);
     gene0007.pc_gera_tag('idsitlct',vr_tab_tags);
     gene0007.pc_gera_tag('dsobslct',vr_tab_tags);

     -- Forma XML de retorno para casos de sucesso (listar dados)
     gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                         ,pr_tab_tag   => vr_tab_tags
                         ,pr_XMLType   => pr_retxml
                         ,pr_path_tag  => '/Root'
                         ,pr_tag_no    => 'retorno'
                         ,pr_des_erro  => pr_des_erro);

     vr_dstransa := 'Detalhando Relac. Pagtos Folha - PAGFOL. Retornou: '||TRIM(gene0002.fn_mask(NVL(vr_qtdregis,0),'zzzzz9'))||' regitro(s).';
     -- Gerando Log de Consulta
     GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                         ,pr_cdoperad => vr_cdoperad
                         ,pr_dscritic => 'OK'
                         ,pr_dsorigem => vr_dsorigem
                         ,pr_dstransa => vr_dstransa
                         ,pr_dttransa => TRUNC(SYSDATE)
                         ,pr_flgtrans => 1 --> SUCESSO/TRUE
                         ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                         ,pr_idseqttl => 1
                         ,pr_nmdatela => vr_nmdatela
                         ,pr_nrdconta => rw_crapemp.nrdconta
                         ,pr_nrdrowid => vr_nrdrowid);
     -- Log Item => Cooperativa Pesquisada
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                              , pr_nmdcampo => 'Cooperativa'
                              , pr_dsdadant => NULL
                              , pr_dsdadatu => rw_crapcop.nmcooper);
     -- Log Item => Empresa
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                              , pr_nmdcampo => 'Empresa'
                              , pr_dsdadant => NULL
                              , pr_dsdadatu => rw_crapemp.nmempresa);
     -- Log Item => Empresa
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                              , pr_nmdcampo => 'Sequencia Pagamento'
                              , pr_dsdadant => NULL
                              , pr_dsdadatu => pr_nrseqpag);
     -- Commit do LOG
     COMMIT;

  EXCEPTION
    WHEN vr_excerror THEN
      -- Desfaz as alteracoes
      ROLLBACK;
      pr_dscritic := pr_des_erro;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Relacao de Pagamentos de Folha - PAGFOL.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
    WHEN OTHERS THEN
      -- Desfaz as alteracoes
      ROLLBACK;
      pr_des_erro := 'Erro geral na rotina pc_consulta_folhas_pagto: '||SQLERRM;
      pr_dscritic := 'Erro geral na rotina pc_consulta_folhas_pagto: '||SQLERRM;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Relacao de Pagamentos de Folha - PAGFOL.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_consulta_detalhes_pagto;

  -- Buscar a flag que indica que o cooperado possui o acesso ao Folha de Pagamento
  PROCEDURE pc_busca_flgpgtib(pr_cdcooper    IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                             ,pr_nrdconta    IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                             ,pr_flgpgtib   OUT crapemp.flgpgtib%TYPE  -- Flag do folha de pagamento
                             ,pr_cdcritic   OUT INTEGER                -- Código do erro
                             ,pr_dscritic   OUT VARCHAR2) IS           -- Descricao do erro
    /* .............................................................................
    Programa : FOLH0002
    Sistema  : Internet Banking
    Sigla    : FOLH
    Autor    : Renato Darosci - SUPERO
    Data     : Junho/2015.                      Ultima atualizacao:  /  /

    Dados referentes ao programa:

    Frequencia: Sempre que Chamado
    Objetivo  : Rotina para buscar o flag que indica se o cooperado(PJ) possui acesso ao Folha

    Alteracoes:
    ............................................................................. */
    -- CURSORES
    -- Buscar o flag na CRAPEMP
    CURSOR cr_crapemp IS
      SELECT emp.flgpgtib
        FROM crapemp   emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.nrdconta = pr_nrdconta;

  BEGIN

    -- Buscar a flag que indica aquisição do produto
    OPEN  cr_crapemp;
    FETCH cr_crapemp INTO pr_flgpgtib;
    -- Se não encontrar o registro
    IF cr_crapemp%NOTFOUND THEN
      pr_flgpgtib := 0;
    END IF;

    CLOSE cr_crapemp;

    --pr_flgpgtib := 0; -- ver renato
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro pc_busca_flgpgtib: '||SQLERRM;
  END pc_busca_flgpgtib;

  -- Realizar o envio dos e-mails de interesse do Folha de Pagamento
  PROCEDURE pc_envia_email_interesse(pr_cdcooper    IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                    ,pr_nrdconta    IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                    ,pr_cdcritic   OUT INTEGER                -- Código do erro
                                    ,pr_dscritic   OUT VARCHAR2) IS           -- Descricao do erro
    /* .............................................................................
    Programa : FOLH0002
    Sistema  : Internet Banking
    Sigla    : FOLH
    Autor    : Renato Darosci - SUPERO
    Data     : Junho/2015.                      Ultima atualizacao:  /  /

    Dados referentes ao programa:

    Frequencia: Sempre que Chamado
    Objetivo  : Rotina para realizar o envio dos e-mails de interesse do Folha de Pagamento

    Alteracoes:
    ............................................................................. */
    -- CURSORES
    -- Busca informações do cooperado e da agencia do mesmo
    CURSOR cr_crapass_age IS
      SELECT ass.nmprimtl
           , age.dsdemail
        FROM crapage age
           , crapass ass
       WHERE age.cdcooper = ass.cdcooper
         AND age.cdagenci = ass.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    -- Busca telefones do Cooperado
    CURSOR cr_craptfc IS
      SELECT DECODE(tfc.tptelefo, 1, 'Residencial'
                                , 2, 'Celular'
                                , 3, 'Comercial'
                                , 4, 'Contato'
                                ,'Indefinido') dstelefo
           , tfc.nrdddtfc
           , tfc.nrtelefo
           , tfc.nmpescto
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
       ORDER BY tfc.tptelefo;

    -- Buscar o e-mail do cooperado
    CURSOR cr_crapcem IS
      SELECT cem.dsdemail
           , rownum       nrregist
        FROM crapcem  cem
       WHERE cem.cdcooper = pr_cdcooper
         AND cem.nrdconta = pr_nrdconta
       ORDER BY cem.idseqttl;

    -- VARIÁVEIS
    vr_nmprimtl     crapass.nmprimtl%TYPE;
    vr_dsdemail     crapage.dsdemail%TYPE;
    vr_dsassunt     VARCHAR2(1000);
    vr_dsmensag     VARCHAR2(1000);

    vr_excerror     EXCEPTION;

  BEGIN

    -- Buscar dados do cooperado e da agencia do mesmo
    OPEN  cr_crapass_age;
    FETCH cr_crapass_age INTO vr_nmprimtl
                            , vr_dsdemail;
    CLOSE cr_crapass_age;

    -- Se encontrar e-mail
    IF TRIM(vr_dsdemail) IS NOT NULL THEN

      vr_dsassunt := 'Folha de Pagamento - Conta '||TRIM(GENE0002.fn_mask_conta(pr_nrdconta => pr_nrdconta))||
                     ' demonstrou interesse no Serviço';
      vr_dsmensag := 'Prezado Colaborador, o cooperado '||TRIM(GENE0002.fn_mask_conta(pr_nrdconta => pr_nrdconta))||
                     ' - '||vr_nmprimtl||' gostaria de conhecer o serviço Folha de Pagamento.  Entre em contato ou agende uma visita. '||
                     '<br><br>Abaixo seguem os contatos do mesmo:<br>Telefones:<br>';

      -- Percorre todos os registros de contato do associado
      FOR rw_craptfc IN cr_craptfc LOOP

        vr_dsmensag := vr_dsmensag || rw_craptfc.dstelefo || ': ' || rw_craptfc.nrtelefo;

        -- Se há nome de contato
        IF TRIM(rw_craptfc.nmpescto) IS NOT NULL THEN
          vr_dsmensag := vr_dsmensag || ' (' || rw_craptfc.nmpescto || ') ';
        END IF;

        -- Quebra de linha
        vr_dsmensag := vr_dsmensag || '<br>';

      END LOOP;

      -- Percorre os e-mails do cooperado
      FOR rw_crapcem IN cr_crapcem LOOP

        -- Se for o primeiro registro de e-mail
        IF rw_crapcem.nrregist = 1 THEN
          vr_dsmensag := vr_dsmensag || '<br>' || 'E-mail do cooperado: <br>';
        END IF;

        -- Concatenar os e-mail na mensagem
        vr_dsmensag := vr_dsmensag || rw_crapcem.dsdemail;

      END LOOP;

      -- Enviar Email comunicando o interesse
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'FOLH0002'
                                ,pr_des_destino     => TRIM(vr_dsdemail)
                                ,pr_des_assunto     => vr_dsassunt
                                ,pr_des_corpo       => vr_dsmensag
                                ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => pr_dscritic);

      -- Se houver erros
      IF pr_dscritic IS NOT NULL THEN
         -- Gera critica
         pr_cdcritic := 9999;
         RAISE vr_excerror;
      END IF;

    END IF;

    -- Commita os e-mails solicitados
    COMMIT;

  EXCEPTION
    WHEN vr_excerror THEN
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro pc_envia_email_interesse: '||SQLERRM;
      ROLLBACK;
  END pc_envia_email_interesse;

  -- Procedure para termo de adesao e/ou cancelamento
  PROCEDURE pc_termo_adesao_cancel(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE
                                  ,pr_idorigem IN PLS_INTEGER
                                  ,pr_cdempres IN crapemp.cdempres%TYPE
                                  ,pr_imptermo IN PLS_INTEGER
                                  ,pr_lisconta IN VARCHAR2
                                  ,pr_nmarquiv OUT VARCHAR2
                                  ,pr_cdcritic OUT NUMBER
                                  ,pr_dscritic OUT VARCHAR2) IS
  /* .............................................................................
    Programa : FOLH0002
    Sistema  : Ayllos Web
    Sigla    : FOLH
    Autor    : Andre Santos - SUPERO
    Data     : Julho/2015.                      Ultima atualizacao: 22/02/2017

    Dados referentes ao programa:

    Frequencia: Sempre que Chamado
    Objetivo  : Impressao de Termo de Adesao ou Cancelamento

    Alteracoes: 05/11/2015 - Correção na busca dos valores de d-0 e d-2, que estava
                            invertido - Marcos(Supero)

                12/11/2015 - Migracao da tarifação do sistema da CONFOL para CADTAR (Marcos-Supero)
                
                16/02/2016 - Inclusao do parametro conta na chamada da
                             FOLH0001.fn_valor_tarifa_folha. (Jaison/Marcos)

                01/03/2016 - Correção do nome da cidade no termo (Marcos-Supero)
                
			    31/05/2016 - Alteracao para pegar o nome da crapass para colocar
                             na Razao Social do termo. (Jaison/Marcos-Supero)
                
                22/02/2016 - Realizado ajuste para para trazer a razao social ao inves
                             do nome resumido, conforme solicitado no chamado 590014. (Kelvin)
                
                20/02/2018 - Alterado cursor cr_crapass, substituindo o acesso à tabela CRAPTIP
                             pela tabela TBCC_TIPO_CONTA. PRJ366 (Lombardi).
                             
                             
    ............................................................................. */

     -- Seleciona os dados da Cooperativa
     CURSOR cr_crapcop (p_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT crapcop.nrdconta
           ,gene0002.fn_mask(crapcop.cdagectl,'9999') cdagectl
           ,gene0002.fn_mask(crapcop.cdbcoctl,'9999') cdbcoctl
           ,gene0002.fn_mask_cpf_cnpj(crapcop.nrdocnpj,2) nrdocnpj
           ,UPPER(crapcop.nmrescop)     nmrescop
           ,INITCAP(crapcop.nmextcop)   nmextcop
           ,UPPER(crapcop.nmcidade)     nmcidade
           ,UPPER(crapcop.cdufdcop)     cdufdcop
           ,INITCAP(crapcop.dsendcop)||', '||crapcop.nrendcop||DECODE(crapcop.nrcxapst,0,'',', Cx Postal: '||crapcop.nrcxapst) dsendcop
           ,INITCAP(crapcop.nmbairro)||', '||INITCAP(crapcop.nmcidade)||'/'||crapcop.cdufdcop||' - CEP '||gene0002.fn_mask(crapcop.nrcepend,'99999-999') dscompl
     FROM crapcop crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     -- Selecionar os dados da tabela de Associados
     CURSOR cr_crapass (p_cdcooper IN crapass.cdcooper%TYPE
                       ,p_nrdconta IN crapass.nrdconta%TYPE) IS
       SELECT crapass.cdcooper
             ,TRIM(gene0002.fn_mask(crapass.nrdconta,'Z.ZZZ.ZZ9-9')) nrdconta
             ,crapass.cdagenci
             ,gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc,crapass.inpessoa) nrcpfcgc
             ,crapass.nmprimtl
             ,crapass.inpessoa
             ,tpcta.dstipo_conta dstipcta
             ,INITCAP(crapenc.dsendere)||', '||crapenc.nrendere||DECODE(crapenc.complend,' ','',', '||crapenc.complend) dsendere
             ,crapenc.nmcidade
             ,crapenc.nmbairro
             ,crapenc.cdufende
             ,gene0002.fn_mask(crapenc.nrcepend,'99999-999') nrcepend
             ,gene0002.fn_mask(crapass.cdbcochq,'9999') cdbcoctl
             ,gene0002.fn_mask(crapass.cdagenci,'9999') cdagectl
         FROM crapass crapass
             ,tbcc_tipo_conta tpcta
             ,crapenc crapenc
        WHERE crapass.inpessoa = tpcta.inpessoa
          AND crapass.cdtipcta = tpcta.cdtipo_conta
          AND crapass.cdcooper = crapenc.cdcooper
          AND crapass.nrdconta = crapenc.nrdconta
          AND crapass.cdcooper = p_cdcooper
          AND crapass.nrdconta = p_nrdconta
          AND crapenc.cdseqinc = 1
          AND crapenc.idseqttl = 1;
     rw_crapass cr_crapass%ROWTYPE;

     -- Conta Debito / Convenio Tarifário / Limite Diário:
     CURSOR cr_crapemp(p_cdcooper  IN crapcop.cdcooper%TYPE
                      ,p_cdempres  IN crapemp.cdempres%TYPE) IS
        SELECT emp.nmresemp
              ,ass.nmprimtl
              ,emp.nmextemp
              ,gene0002.fn_mask_cpf_cnpj(emp.nrdocnpj,2) nrdocnpj
              ,emp.dsendemp
              ,emp.nmcidade
              ,emp.cdufdemp
              ,ass.cdagenci
              ,gene0002.fn_mask(ass.cdagenci,'99999-999') cdctaage
              ,emp.nrdconta
              ,emp.vllimfol
              ,gene0002.fn_mask(emp.nrcepend,'99999-999') nrcepend
              ,emp.cdcontar||' - '||cfp.dscontar dscontar
              ,folh0001.fn_valor_tarifa_folha(p_cdcooper,0,emp.cdcontar,0,emp.vllimfol) vltarid0
              ,folh0001.fn_valor_tarifa_folha(p_cdcooper,0,emp.cdcontar,1,emp.vllimfol) vltarid1
              ,folh0001.fn_valor_tarifa_folha(p_cdcooper,0,emp.cdcontar,2,emp.vllimfol) vltarid2
        FROM  crapcfp cfp
             ,crapemp emp
             ,crapass ass
        WHERE emp.cdcooper = p_cdcooper
          AND emp.cdempres = p_cdempres
          AND ass.cdcooper = emp.cdcooper
          AND ass.nrdconta = emp.nrdconta
          AND emp.cdcooper = cfp.cdcooper
          AND emp.cdcontar = cfp.cdcontar;
     rw_crapemp cr_crapemp%ROWTYPE;

     -- Conta Debito / Convenio Tarifário / Limite Diário:
     CURSOR cr_procurador(p_cdcooper  IN crapcop.cdcooper%TYPE
                         ,p_cdempres  IN crapemp.cdempres%TYPE) IS
        SELECT emp.nmresemp
              ,avt.nrdctato
              ,avt.nrcpfcgc
              ,ass.nmprimtl
              ,avt.dsproftl  /* Cargo */
         FROM  crapavt avt
              ,crapass ass
              ,crapemp emp
        WHERE emp.cdcooper = p_cdcooper  /* Cooperativa Sistema */
          AND emp.cdempres = p_cdempres  /* Empresa Selecionada na tela */
          AND avt.cdcooper = emp.cdcooper
          AND avt.nrdconta = emp.nrdconta
          AND avt.tpctrato = 6 /* Procuradores */
          AND (pr_lisconta) LIKE '%,'||avt.nrdctato||',%'   /* Selecionados na tela */
          AND ass.cdcooper = avt.cdcooper
          AND ass.nrdconta = avt.nrdctato;
     rw_procurador cr_procurador%ROWTYPE;


     -- Verifica o tipo de que sera impresso termo 0 - Adesao / 1 - Cancelamento
     CURSOR cr_tipo_termo(p_cdcooper  IN crapcop.cdcooper%TYPE
                         ,p_cdempres  IN crapemp.cdempres%TYPE) IS
        SELECT emp.flgpgtib
              ,emp.dtultufp
          FROM crapemp emp
         WHERE emp.cdcooper = p_cdcooper
           AND emp.cdempres = p_cdempres;
     rw_indtermo cr_tipo_termo%ROWTYPE;

     -- Valida se as informacoes estao preenchidas para Impressao
     CURSOR cr_valid_cadastro(p_cdcooper  IN crapcop.cdcooper%TYPE
                             ,p_cdempres  IN crapemp.cdempres%TYPE) IS
        SELECT 1
          FROM crapemp emp
         WHERE emp.cdcooper = p_cdcooper
           AND emp.cdempres = p_cdempres
           AND emp.nrdocnpj <> 0
           AND emp.vllimfol <> 0
           AND emp.nrdconta <> 0
           AND emp.cdcontar <> 0;
     vr_existe NUMBER(10);

     -- Dados do Registro do Contrato
     -- Busca TAB com Conteudo do Termo
     CURSOR cr_craptab (p_cdcooper IN crapcop.cdcooper%TYPE
                       ,p_cdacesso IN craptab.cdacesso%TYPE) IS
        SELECT NVL(TRIM(craptab.dstextab),'0') dstextab
          FROM craptab craptab
         WHERE craptab.cdcooper        = p_cdcooper
           AND UPPER(craptab.nmsistem) = 'CRED'
           AND UPPER(craptab.tptabela) = 'GENERI'
           AND craptab.cdempres        = 0
           AND UPPER(craptab.cdacesso) = p_cdacesso
           AND craptab.tpregist        = 90;
       rw_craptab cr_craptab%ROWTYPE;

      -- Data do dia do termo
      CURSOR cr_crapdat(p_cdcooper crapcop.cdcooper%TYPE) IS
         SELECT TO_CHAR(a.dtmvtolt, 'DD "de" fmMonth "de" YYYY','NLS_DATE_LANGUAGE=PORTUGUESE') dtmvtolt
           FROM crapdat a
          WHERE a.cdcooper = p_cdcooper;
      rw_crapdat cr_crapdat%ROWTYPE;


      -- Variaveis
      vr_cdcritic NUMBER(10);
      --Variavel para arquivo de dados e XML
      vr_nom_direto  VARCHAR2(400);
      vr_nom_arquivo VARCHAR2(100);
      vr_dsjasper    VARCHAR2(100);
      vr_sqcabrel    PLS_INTEGER := 0;
      vr_cdrelato    PLS_INTEGER := 0;
      vr_typ_said VARCHAR2(3);
      -- Variável para armazenar as informações em XML
      vr_des_xml     CLOB;
      -- Quebrando a string
      vr_lisconta VARCHAR2(4000);
      vr_nrdctass crapass.nrdconta%TYPE;
      vr_qtdconta gene0002.typ_split;
      vr_numentry PLS_INTEGER := 0;
      -- Variaveis para Tratamento erro
      vr_exc_saida EXCEPTION;
      vr_des_erro  VARCHAR2(4000);
      vr_tab_erro  gene0001.typ_tab_erro;


      --Escrever no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo XML
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

   BEGIN

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_crapcop;
         vr_des_erro := 'Cooperativa nao cadastrada.';
         RAISE vr_exc_saida;
      ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
      END IF;


      -- Verificando o tipo de termo
      OPEN cr_tipo_termo(pr_cdcooper
                        ,pr_cdempres);
      FETCH cr_tipo_termo INTO rw_indtermo;
      -- Se nao encontrar
      IF cr_tipo_termo%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_tipo_termo;
         vr_des_erro := 'Registro de empresa nao localizado. Empresa: '||pr_cdempres;
         RAISE vr_exc_saida;
      ELSE
         -- Valida se o termo de cancelamento pode ser gerado
         IF pr_imptermo = 1 AND (rw_indtermo.flgpgtib = 0 AND rw_indtermo.dtultufp IS NULL) THEN
            -- Fechar o cursor pois havera raise
            CLOSE cr_tipo_termo;
            vr_des_erro := 'Nao e possivel gerar o termo de cancelamento.';
            RAISE vr_exc_saida;
         END IF;

         -- Apenas fechar o cursor
         CLOSE cr_tipo_termo;
      END IF;


      IF pr_imptermo = 0 THEN -- Adesao
         -- Validando se as informacoes estao preenchidas corretamente
         OPEN cr_valid_cadastro(pr_cdcooper
                               ,pr_cdempres);
         FETCH cr_valid_cadastro INTO vr_existe;
         -- Se nao encontrar
         IF cr_valid_cadastro%NOTFOUND THEN
            -- Fechar o cursor pois havera raise
            CLOSE cr_valid_cadastro;
            vr_des_erro := 'Campos obrigatorios incompletos ou faltante no cadastro da empresa.';
            RAISE vr_exc_saida;
         ELSE
            -- Apenas fechar o cursor
            CLOSE cr_valid_cadastro;
         END IF;
      ELSE -- Cancelamento
         -- Nao permite imprimir um Termo de uma empresa com convenio ativo
         IF rw_indtermo.flgpgtib = 1 THEN
            vr_des_erro := 'Convenio ativo para a empresa, nao ha Termo de Cancelamento a imprimir.';
            RAISE vr_exc_saida;
         END IF;
      END IF;


      -- Busca o cadastro da empresa
      OPEN cr_crapemp(pr_cdcooper
                     ,pr_cdempres);
      FETCH cr_crapemp INTO rw_crapemp;
      -- Se nao encontrar
      IF cr_crapemp%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_crapemp;
         vr_des_erro := 'Empresa nao cadastrada.';
         RAISE vr_exc_saida;
      ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapemp;
      END IF;

      -- Busca TAB com Conteudo do Termo
      OPEN cr_craptab(pr_cdcooper
                     ,'FLPGTINR');
      FETCH cr_craptab INTO rw_craptab;
      -- Apenas fechar o cursor
      CLOSE cr_craptab;


      -- Data do dia do termo
      OPEN cr_crapdat(pr_cdcooper);
      FETCH cr_crapdat INTO rw_crapdat;
      CLOSE cr_crapdat;


      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><termo>');
      -- Informacoes dos procuradores
      pc_escreve_xml('<dados>
                      <nmextcop>'||rw_crapcop.nmextcop||'</nmextcop>
                      <nrcnpjcp>'||rw_crapcop.nrdocnpj||'</nrcnpjcp>
                      <dsendcop>'||rw_crapcop.dsendcop||'</dsendcop>');
      -- Dados da Empresa
      pc_escreve_xml('<nmprimtl>'||rw_crapemp.nmprimtl||'</nmprimtl>
                      <nrdocnpj>'||rw_crapemp.nrdocnpj||'</nrdocnpj>
                      <dsendemp>'||rw_crapemp.dsendemp||'</dsendemp>
                      <nmcidade>'||rw_crapemp.nmcidade||'</nmcidade>
                      <nrcepend>'||rw_crapemp.nrcepend||'</nrcepend>
                      <cdufdemp>'||rw_crapemp.cdufdemp||'</cdufdemp>');
      -- Informacoes da empresa
      pc_escreve_xml('<cdctaban>0085</cdctaban>
                      <cdctaage>'||rw_crapemp.cdctaage||'</cdctaage>
                      <nrdctadb>'||TRIM(gene0002.fn_mask_conta(rw_crapemp.nrdconta))||'</nrdctadb>
                      <dscontar>'||rw_crapemp.dscontar||'</dscontar>
                      <vltarid0>'||To_Char(rw_crapemp.vltarid0,'fm990d00')||'</vltarid0>
                      <vltarid1>'||To_Char(rw_crapemp.vltarid1,'fm990d00')||'</vltarid1>
                      <vltarid2>'||To_Char(rw_crapemp.vltarid2,'fm990d00')||'</vltarid2>
                      <vllimfol>'||To_Char(rw_crapemp.vllimfol,'fm9g999g999g999g999g990d00')||'</vllimfol>
                      <flpgtinr>'||NVL(rw_craptab.dstextab,0)||'</flpgtinr>
                      <dtmvtolt>'||rw_crapcop.nmcidade||'/'||rw_crapcop.cdufdcop||','||rw_crapdat.dtmvtolt||'</dtmvtolt>');
      pc_escreve_xml('</dados>');

      IF pr_imptermo = 0 THEN -- Adesao

         -- Verifica a lista de procuradores selecionados
         pc_escreve_xml('<procuradores>');
         FOR rw_procurador IN cr_procurador(pr_cdcooper
                                           ,pr_cdempres) LOOP
            pc_escreve_xml('<procurador>
                               <represen>'||rw_procurador.nmprimtl||'</represen>
                               <descargo>'||rw_procurador.dsproftl||'</descargo>
                            </procurador>');
         END LOOP;
         pc_escreve_xml('</procuradores>');
         -- Verifica a lista de associados para assinatura
         pc_escreve_xml('<assinaturas>');
         -- Remove as virgulas do inicio e fim da lista
         vr_lisconta := SUBSTR(pr_lisconta,2,LENGTH(pr_lisconta)-2);
         -- Verifica a quantidade de contas
         vr_qtdconta := gene0002.fn_quebra_string(pr_string  => vr_lisconta,pr_delimit => ',');
         -- Verifica o numero de entradas
         FOR vr_numentry IN 1..vr_qtdconta.COUNT() LOOP
             -- Busca a conta dentro da lista de contas
             vr_nrdctass := TO_NUMBER(gene0002.fn_busca_entrada(vr_numentry,vr_lisconta,','));
             -- Verifica os dados do associado
             OPEN cr_crapass(pr_cdcooper
                            ,vr_nrdctass);
             FETCH cr_crapass INTO rw_crapass;
             -- Se nao encontrar
             IF cr_crapass%NOTFOUND THEN
                -- Fechar o cursor pois havera raise
                CLOSE cr_crapass;
                vr_des_erro := 'Cooperado nao localizado!';
                RAISE vr_exc_saida;
             END IF;
             pc_escreve_xml('<assinatura>
                               <nmextemp>'||rw_crapemp.nmprimtl||'</nmextemp>
                               <nmprimtl>'||rw_crapass.nmprimtl||'</nmprimtl>
                             </assinatura>');
             -- fechar o cursor
             CLOSE cr_crapass;
         END LOOP;
         pc_escreve_xml('</assinaturas>');

      ELSE -- Cancelamento

         -- Verifica a lista de associados para assinatura
         pc_escreve_xml('<assinaturas>');
         pc_escreve_xml('<assinatura>
                           <nmextemp>'||rw_crapemp.nmprimtl||'</nmextemp>
                         </assinatura>');
         pc_escreve_xml('</assinaturas>');

      END IF;
      -- Finaliza a tag de termo
      pc_escreve_xml('</termo>');

      -- Busca o diretorio padrao do sistema
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rlnsv'); --> Utilizaremos o não salvo

      IF pr_imptermo = 0 THEN -- Adesao
         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl704_'||pr_cdempres;
         vr_dsjasper    := 'crrl704.jasper';
         vr_sqcabrel    := 1;
         vr_cdrelato    := 704;
      ELSE
         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl705_'||pr_cdempres;
         vr_dsjasper    := 'crrl705.jasper';
         vr_sqcabrel    := 2;
         vr_cdrelato    := 705;
      END IF;

      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => 'CADEMP'            --> Programa chamador
                                 ,pr_dtmvtolt  => pr_dtmvtolt         --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/termo'            --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => vr_dsjasper         --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.pdf' --> Arquivo final
                                 ,pr_qtcoluna  => 80                  --> 80 colunas
                                 ,pr_sqcabrel  => vr_sqcabrel         --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ' '                 --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'S'                 --> gerar PDF
                                 ,pr_cdrelato  => vr_cdrelato         --> Codigo do Relatorio
                                 ,pr_des_erro  => vr_des_erro);       --> Saída com erro  */

      -- Testar se houve erro
      IF vr_des_erro IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      -- Chamar a rotina que irá copiar o arquivo para o servidor do AyllosWeb
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper                                 --> Coop
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_nrdcaixa => 0
                                  ,pr_nmarqpdf => vr_nom_direto||'/'||vr_nom_arquivo||'.pdf' --> Caminho completo
                                  ,pr_des_reto => vr_des_erro                                --> OK/NOK
                                  ,pr_tab_erro => vr_tab_erro);                              --> tabela de erros

      -- Caso apresente erro na operação
      IF nvl(vr_des_erro, 'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Retorna o caminho do arquivo pdf gerado
      pr_nmarquiv := vr_nom_arquivo||'.pdf';

      -- Removemos o arquivo gerado na NSV
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm "'||vr_nom_direto||'/'||vr_nom_arquivo||'.pdf"'
                                    ,pr_typ_saida   => vr_typ_said
                                    ,pr_des_saida   => pr_dscritic);
      -- Testar retorno de erro
      IF vr_typ_said = 'ERR' THEN
         -- Incrementar o erro
         vr_des_erro := 'Erro ao apagar o arquivo auxiliar do sistema. '||vr_nom_direto||'/'||vr_nom_arquivo||'.pdf';
         RAISE vr_exc_saida;
      END IF;

      -- Gravamos a transação pendente
      COMMIT;

   EXCEPTION
     WHEN vr_exc_saida THEN
       -- Desfazer as alteracoes
       ROLLBACK;
       -- Efetuar retorno do erro
       pr_cdcritic := NVL(vr_cdcritic,0);
       pr_dscritic := vr_des_erro;
     WHEN OTHERS THEN
       -- Desfazer as alteracoes
       ROLLBACK;
       -- Apenas retornar a variável de saida
       pr_cdcritic := 0;
       pr_dscritic := 'Erro FOLH0002.pc_termo_adesao_cancel: ' || SQLERRM;
   END pc_termo_adesao_cancel;

   /* Procedure encarregada de buscar os dados de folha de pagamento */
   PROCEDURE pc_busca_dados_pagto_ib(pr_cdcooper   IN PLS_INTEGER
                                    ,pr_nrdconta   IN NUMBER
                                    ,pr_dtiniper   IN DATE
                                    ,pr_dtfimper   IN DATE
                                    ,pr_nrregist   IN NUMBER
                                    ,pr_nriniseq   IN NUMBER
                                    ,pr_cdcritic   OUT PLS_INTEGER
                                    ,pr_dscritic   OUT VARCHAR2
                                    ,pr_pagto_xml  OUT CLOB) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_busca_dados_pagto_ib
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2015.                   Ultima atualizacao: 21/03/2017
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure encarregada de buscar os dados de folha de pagamento
   --
   -- Alteracoes: 12/11/2015 - Migracao da tarifação do sistema da CONFOL para CADTAR (Marcos-Supero)
   --
   --             27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
   --
   --             16/02/2016 - Inclusao do parametro conta na chamada da
   --                          FOLH0001.fn_valor_tarifa_folha. (Jaison/Marcos)
   --
   --             21/03/2017 - Adicionando paginacao na tela de folha, conforme 
	 --		        	             solicitado no chamado 626091 (Kelvin).
   --             04/09/2017 - Alteração Projeto Assinatura conjunta (Proj 397), 
   --                          Não visualizar na tela quando o pagamento por folha
   --                          estiver em transações pendentes, nova situação tipo 6
   --
   ---------------------------------------------------------------------------------------------------------------
      -- Cursor para buscar os registros Pendentes e Aprovados                         
      CURSOR cr_registros (p_cdcooper crapcop.cdcooper%TYPE
                             ,p_nrdconta crapemp.nrdconta%TYPE
                             ,p_dtiniper DATE
                          ,p_dtfimper DATE
                          ,p_nrregist NUMBER
                          ,p_nriniseq NUMBER) IS
      
        SELECT dados3.*
          FROM (SELECT dados2.*
                      ,COUNT(1) OVER (PARTITION BY 1) qtregist  --Quantidade de registros 
                      ,COUNT(1) OVER (PARTITION BY 1 ORDER BY dados2.idsitapr, dados2.dtmvtolt DESC ) linha --Utilizado para que o partition by não se perca (Dúvidas Renato) e sequencial do registro
                  FROM (SELECT dados.*
                          FROM (SELECT pfp.cdempres
               ,pfp.idtppagt
               ,pfp.dtmvtolt
               ,DECODE(pfp.idsitapr,'1','Pendente'
                                   ,'2','Sol. Estouro'
                                   ,'3','Estouro Reprov.'
                                   ,'Pendente') dssitpgt
               ,pfp.qtregpag qtlctpag
               ,pfp.vllctpag
               ,(pfp.qtlctpag * folh0001.fn_valor_tarifa_folha(p_cdcooper,emp.nrdconta,emp.cdcontar,pfp.idopdebi,pfp.vllctpag)) vltarifa
               ,pfp.dtdebito
               ,pfp.dtcredit
               ,pfp.idsitapr
                                      ,pfp.rowid dsrowid
               /* Detalhes - onClick */
               ,to_char(pfp.dtmvtolt,'dd/mm/rr hh24:mi') dthoragen
               ,DECODE(pfp.idsitapr,'1','Aprovação pendente'
                                      ,'Pagamento aprovado por '|| DECODE(pfp.nrcpfapr,0,(SELECT emp.nmresemp
                                                                   FROM crapemp emp
                                                                  WHERE emp.cdcooper = pfp.cdcooper
                                                                    AND emp.cdempres = pfp.cdempres)
                                          ,(SELECT opi.nmoperad
                                             FROM crapopi opi
                                            WHERE opi.cdcooper = pfp.cdcooper
                                              AND opi.nrcpfope = pfp.nrcpfapr
                                              AND ROWNUM = 1))) dsdetapr
               ,DECODE(pfp.idsitapr,'1','-'
                                   ,'2','Estouro aguardando análise'
                                      ,'3','Estouro reprovado por '|| (SELECT ope.nmoperad
                                             FROM crapope ope
                                            WHERE ope.cdcooper = pfp.cdcooper
                                              AND ope.cdoperad = pfp.cdopeest
                                              AND ROWNUM = 1)||'. Motivo: '||pfp.dsjusest) dsdetest
                                         
                                      ,null dsobsdeb
                                      ,null dsobstar
                                      ,null cdcooper
                                      ,pfp.nrseqpag
                                      ,null flsitdeb
                                      ,null flsitcre
                                      ,null dsobscre     
                                      ,null dthordeb
                                      ,null dsobservdeb
                                      ,null dthorcre
                                      ,null dsobservcre
                                      ,null dthortar
                                      ,null dsobservtar
                                      ,null qtsubtra  
                                                                        
           FROM crapemp emp
               ,crappfp pfp
          WHERE pfp.cdcooper = p_cdcooper --> Cooperativa conectada
            AND emp.nrdconta = p_nrdconta --> Conta da empresa conectada
            AND pfp.cdcooper = emp.cdcooper
            AND pfp.cdempres = emp.cdempres
            AND pfp.idsitapr < 4 --> Nao aprovados ainda
            AND pfp.idsitapr <> 6  -- Transacao pendente
            AND (TRUNC(pfp.dtmvtolt) BETWEEN p_dtiniper AND p_dtfimper
                                    OR TRUNC(pfp.dtdebito) BETWEEN p_dtiniper AND p_dtfimper
                                    OR TRUNC(pfp.dtcredit) BETWEEN p_dtiniper AND p_dtfimper)
                                 UNION ALL          
                                SELECT pfp.cdempres
                                      ,pfp.idtppagt
               ,pfp.dtmvtolt
                                      ,DECODE(pfp.flsitcre,1,'Creditado',2,'Cred. Parcial',DECODE(pfp.flsitdeb,1,'Debitado','Agendado')) dssitpgt
               ,pfp.qtregpag qtlctpag
               ,pfp.vllctpag
               ,pfp.qtlctpag * pfp.vltarapr vltarifa
               ,pfp.dtdebito
               ,pfp.dtcredit
               ,pfp.idsitapr
                                      ,pfp.rowid dsrowid
                                      ,to_char(pfp.dtmvtolt,'dd/mm/rr hh24:mi') dthoragen
                                      /* Detalhes (On-click) */
               ,'Pagamento aprovado por '||
                       DECODE(pfp.nrcpfapr,0,(SELECT emp.nmresemp
                                                FROM crapemp emp
                                               WHERE emp.cdcooper = pfp.cdcooper
                                                 AND emp.cdempres = pfp.cdempres)
                                          ,(SELECT opi.nmoperad
                                             FROM crapopi opi
                                            WHERE opi.cdcooper = pfp.cdcooper
                                              AND opi.nrcpfope = pfp.nrcpfapr
                                              AND ROWNUM = 1)) dsdetapr
                                      ,DECODE(pfp.idsitapr,'4','Estouro aprovado por '|| (SELECT ope.nmoperad
                                            FROM crapope ope
                                           WHERE ope.cdcooper = pfp.cdcooper
                                             AND ope.cdoperad = pfp.cdopeest
                                             AND ROWNUM = 1)||'. Motivo: '||pfp.dsjusest) dsdetest
                                      ,pfp.dsobsdeb
                                      ,pfp.dsobstar
                                      ,pfp.cdcooper
                                      ,pfp.nrseqpag
                                      ,pfp.flsitdeb
                                      ,pfp.flsitcre
                                      ,pfp.dsobscre     
               ,NVL(to_char(pfp.dthordeb,'dd/mm/rr hh24:mi'),to_char(pfp.dtdebito,'dd/mm/rr')) dthordeb
               ,DECODE(pfp.flsitdeb,0,NVL(TRIM(pfp.dsobsdeb),'Pagamento aguardando data do débito.'),'Débito efetuado com sucesso') dsobservdeb
               ,NVL(to_char(pfp.dthorcre,'dd/mm/rr hh24:mi'),to_char(pfp.dtcredit,'dd/mm/rr')) dthorcre
                                      ,DECODE(pfp.flsitcre,0,nvl(TRIM(pfp.dsobscre),'Pagamento aguardando data do crédito.'),DECODE((SELECT COUNT(1)
                                                                       FROM craplfp lfp
                                                                      WHERE lfp.cdcooper = pfp.cdcooper
                                                                        AND lfp.cdempres = pfp.cdempres
                                                                                                                                        AND lfp.nrseqpag = pfp.nrseqpag                                                                                                                                        AND lfp.idsitlct IN('L','D','E'))
                                                            ,0,'Crédito efetuado com sucesso'
                                                            ,'Crédito efetuado com alertas.')) dsobservcre
               ,to_char(pfp.dthortar,'dd/mm/rr hh24:mi') dthortar
               ,DECODE(pfp.flsittar,0,NVL(TRIM(pfp.dsobstar),'Tarifa pendente de débito.'),'Tarifa debitada com sucesso') dsobservtar
               ,dat.dtmvtolt - TRUNC(pfp.dthorcre) qtsubtra
            FROM crapemp emp
                ,crappfp pfp
                ,crapdat dat
           WHERE pfp.cdcooper = p_cdcooper -- Cooperativa conectada
             AND emp.nrdconta = p_nrdconta -- Conta da empresa conectada
             AND pfp.cdcooper = emp.cdcooper
             AND pfp.cdempres = emp.cdempres
             AND dat.cdcooper = pfp.cdcooper
             AND pfp.idsitapr > 3 --> Somente aprovados
             AND pfp.idsitapr <> 6  -- Transacao pendente
             AND (TRUNC(pfp.dtmvtolt) BETWEEN p_dtiniper AND p_dtfimper
                                    OR TRUNC(pfp.dtdebito) BETWEEN p_dtiniper AND p_dtfimper
                                    OR TRUNC(pfp.dtcredit) BETWEEN p_dtiniper AND p_dtfimper
                                    OR TRUNC(pfp.dthorcre) BETWEEN p_dtiniper AND p_dtfimper
                                    OR TRUNC(pfp.dthordeb) BETWEEN p_dtiniper AND p_dtfimper)) dados
                         ORDER BY dados.idsitapr, dados.dtmvtolt DESC) dados2) dados3	
         WHERE dados3.linha >= p_nriniseq
           AND dados3.linha <  p_nrregist;

      -- Verifica registros com problema no debito ou credito
      CURSOR cr_valida_apr(p_cdcooper crapcop.cdcooper%TYPE
                          ,p_cdempres crapemp.cdempres%TYPE
                          ,p_nrseqpag craplfp.nrseqpag%TYPE) IS
         SELECT 1
           FROM craplfp
          WHERE cdcooper = p_cdcooper
            AND cdempres = p_cdempres
            AND nrseqpag = p_nrseqpag
            AND idsitlct IN('E','D');
      rw_valida_apr cr_valida_apr%ROWTYPE;

      -- Verifica registros com problema no debito ou credito
      CURSOR cr_val_comprov(p_cdcooper crapcop.cdcooper%TYPE
                           ,p_cdempres crapemp.cdempres%TYPE
                           ,p_nrseqpag craplfp.nrseqpag%TYPE) IS
         SELECT 1
           FROM craplfp
          WHERE cdcooper = p_cdcooper
            AND cdempres = p_cdempres
            AND nrseqpag = p_nrseqpag
            AND dtrefenv IS NOT NULL;
      rw_val_comprov cr_val_comprov%ROWTYPE;

      -- Variavel
      vr_tab_pagamento folh0002.typ_tab_pagamento;
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      vr_idx_pagto     PLS_INTEGER;
      vr_qtdiaenv      NUMBER(3);
      vr_nrregist      NUMBER;
      vr_nriniseq      NUMBER;      
      vr_qtregist      NUMBER;
      vr_flgprime      NUMBER;
      vr_flgpende      NUMBER;

      -- Variavel de Exception
      vr_exc_erro EXCEPTION;

   BEGIN
      -- Inicia variaveis
      pr_cdcritic  := NULL;
      pr_dscritic  := NULL;
      vr_idx_pagto := 0;
      vr_nrregist  := NULL;
      vr_nriniseq  := NULL;
      vr_qtregist  := 0;      
      vr_flgprime  := 0;
      vr_flgpende  := 0;
     
      vr_nriniseq := pr_nriniseq;
      vr_nrregist := pr_nrregist + pr_nriniseq;

      -- Verificamos se os parametros de data estao corretos
      -- Primeiramente verificamos se os campos estao null
      IF pr_dtiniper IS NULL THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Data inicial deve ser informada!';
         RAISE vr_exc_erro;
      END IF;
      IF pr_dtfimper IS NULL THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Data final deve ser informada!';
         RAISE vr_exc_erro;
      END IF;

      -- Nao podemos permitir data DE superior a ATE
      IF pr_dtiniper > pr_dtfimper THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Data inicial não pode ser superior a data final!';
         RAISE vr_exc_erro;
      END IF;

      -- Nao podemos permitir consultas superiores a 6 meses
      IF MONTHS_BETWEEN(pr_dtfimper,pr_dtiniper)>6 THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Período de datas não podem ser superior a 6 meses!';
         RAISE vr_exc_erro;
      END IF;

      -- Limpando tabela de memória
      vr_tab_pagamento.DELETE;

      -- Inicia a chave de tabela
      vr_idx_pagto := NVL(vr_tab_pagamento.COUNT(),0)+1;

      -- Busca a Qtde dias para envio comprovantes
      vr_qtdiaenv := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'FOLHAIB_QTD_DIA_ENV_COMP');
      
      FOR rw_registros IN cr_registros(pr_cdcooper
                                         ,pr_nrdconta
                                         ,pr_dtiniper
                                      ,pr_dtfimper
                                      ,vr_nrregist
                                      ,vr_nriniseq) LOOP

        --Pendentes
        IF rw_registros.idsitapr < 4 THEN
          IF  rw_registros.idsitapr = 1 THEN
              vr_tab_pagamento(vr_idx_pagto).exibestr := 1;
          ELSE
              vr_tab_pagamento(vr_idx_pagto).exibestr := 0;
          END IF;

          -- Popula a tabela
          vr_tab_pagamento(vr_idx_pagto).tpregist := 0;
          vr_tab_pagamento(vr_idx_pagto).envcompr := vr_qtdiaenv;
          vr_tab_pagamento(vr_idx_pagto).indrowid := rw_registros.dsrowid;
          vr_tab_pagamento(vr_idx_pagto).dtmvtolt := rw_registros.dtmvtolt;
          vr_tab_pagamento(vr_idx_pagto).dssitpgt := rw_registros.dssitpgt;
          vr_tab_pagamento(vr_idx_pagto).idsitpgt := rw_registros.idsitapr;
          vr_tab_pagamento(vr_idx_pagto).qtlctpag := rw_registros.qtlctpag;
          vr_tab_pagamento(vr_idx_pagto).vllctpag := rw_registros.vllctpag;
          vr_tab_pagamento(vr_idx_pagto).vltarifa := rw_registros.vltarifa;
          vr_tab_pagamento(vr_idx_pagto).dtdebito := rw_registros.dtdebito;
          vr_tab_pagamento(vr_idx_pagto).imgdebto := '';
          vr_tab_pagamento(vr_idx_pagto).hintdebt := '';
          vr_tab_pagamento(vr_idx_pagto).idsitdeb := 1;
          vr_tab_pagamento(vr_idx_pagto).dtcredit := rw_registros.dtcredit;
          vr_tab_pagamento(vr_idx_pagto).imgcredt := '';
          vr_tab_pagamento(vr_idx_pagto).hintcred := '';
          vr_tab_pagamento(vr_idx_pagto).idsitcre := 1;
          -- Linha Oculta
          vr_tab_pagamento(vr_idx_pagto).dthorage := rw_registros.dthoragen;
          vr_tab_pagamento(vr_idx_pagto).dsdetapr := rw_registros.dsdetapr;
          vr_tab_pagamento(vr_idx_pagto).dsdetest := rw_registros.dsdetest;
          vr_tab_pagamento(vr_idx_pagto).dthordeb := '';
          vr_tab_pagamento(vr_idx_pagto).dthorcre := '';
          vr_tab_pagamento(vr_idx_pagto).dthortar := '';
          vr_tab_pagamento(vr_idx_pagto).dthrtari := '';          
          vr_tab_pagamento(vr_idx_pagto).dscomprv := '';
          vr_tab_pagamento(vr_idx_pagto).cdempres := rw_registros.cdempres;
          vr_tab_pagamento(vr_idx_pagto).idtppagt := rw_registros.idtppagt;
          vr_tab_pagamento(vr_idx_pagto).dstpapgt := CASE WHEN rw_registros.idtppagt = 'A' THEN 'Arquivo' ELSE 'Convencional' END;
          vr_tab_pagamento(vr_idx_pagto).idsitapr := rw_registros.idsitapr;
          vr_tab_pagamento(vr_idx_pagto).nrseqpag := rw_registros.nrseqpag;          
          vr_tab_pagamento(vr_idx_pagto).dthrdebi := TO_CHAR(rw_registros.dtdebito,'DD/MM/RRRR') || ' 00:00';
          vr_tab_pagamento(vr_idx_pagto).dthrcred := TO_CHAR(rw_registros.dtcredit,'DD/MM/RRRR') || ' 00:00';          
          
          vr_idx_pagto := vr_idx_pagto + 1;
          vr_flgpende := 1;
        --Aprovados
        ELSE
          --Adicionado linha em branco para gerar separação na grid
          /*IF vr_tab_pagamento.COUNT()> 0 AND vr_flgprime = 0 AND vr_flgpende = 1 THEN
            -- Popula a tabela
            vr_tab_pagamento(vr_idx_pagto).indrowid := NULL;
            vr_tab_pagamento(vr_idx_pagto).dtmvtolt := NULL;
            vr_tab_pagamento(vr_idx_pagto).dssitpgt := NULL;
            vr_tab_pagamento(vr_idx_pagto).idsitpgt := NULL;
            vr_tab_pagamento(vr_idx_pagto).qtlctpag := NULL;
            vr_tab_pagamento(vr_idx_pagto).vllctpag := NULL;
            vr_tab_pagamento(vr_idx_pagto).vltarifa := NULL;
            vr_tab_pagamento(vr_idx_pagto).dtdebito := NULL;
            vr_tab_pagamento(vr_idx_pagto).imgdebto := NULL;
            vr_tab_pagamento(vr_idx_pagto).hintdebt := NULL;
            vr_tab_pagamento(vr_idx_pagto).idsitdeb := NULL;
            vr_tab_pagamento(vr_idx_pagto).dtcredit := NULL;
            vr_tab_pagamento(vr_idx_pagto).imgcredt := NULL;
            vr_tab_pagamento(vr_idx_pagto).hintcred := NULL;
            vr_tab_pagamento(vr_idx_pagto).idsitcre := NULL;
            vr_tab_pagamento(vr_idx_pagto).dscomprv := NULL;
            vr_tab_pagamento(vr_idx_pagto).idtppagt := NULL;
            vr_tab_pagamento(vr_idx_pagto).dstpapgt := NULL;
            vr_idx_pagto := vr_idx_pagto + 1;
            vr_flgprime := 1;
          END IF; */

          IF  rw_registros.idsitapr = 5 THEN
              vr_tab_pagamento(vr_idx_pagto).exibestr := 1;
          ELSE
              vr_tab_pagamento(vr_idx_pagto).exibestr := 0;
          END IF;

          -- Se encontrar, o registro possui iregularidade
          IF rw_registros.dssitpgt = 'Debitado' AND rw_registros.dsobsdeb IS NOT NULL THEN
             vr_tab_pagamento(vr_idx_pagto).dssitpgt := '***'||rw_registros.dssitpgt;

          ELSIF rw_registros.dssitpgt = 'Creditado' AND rw_registros.dsobstar IS NOT NULL THEN
             vr_tab_pagamento(vr_idx_pagto).dssitpgt := '***'||rw_registros.dssitpgt;

          ELSE
             -- Verifica registros com problema no debito ou credito
             OPEN cr_valida_apr(rw_registros.cdcooper
                               ,rw_registros.cdempres
                               ,rw_registros.nrseqpag);
             FETCH cr_valida_apr INTO rw_valida_apr;
                -- Se encontrar, o registro possui inregularidade
                IF cr_valida_apr%FOUND THEN
                   vr_tab_pagamento(vr_idx_pagto).dssitpgt := '***'||rw_registros.dssitpgt;
                ELSE
                   vr_tab_pagamento(vr_idx_pagto).dssitpgt := rw_registros.dssitpgt;
                END IF;
             CLOSE cr_valida_apr;
          END IF;

          -- Validacao de campo de debito
          IF rw_registros.flsitdeb = 0 AND rw_registros.dsobsdeb IS NULL THEN
             vr_tab_pagamento(vr_idx_pagto).imgdebto := 'agendamento.png';
             vr_tab_pagamento(vr_idx_pagto).hintdebt := 'Aguardando data de débito...';
             vr_tab_pagamento(vr_idx_pagto).idsitdeb := 2;
          ELSIF rw_registros.flsitdeb = 0 AND rw_registros.dsobsdeb IS NOT NULL THEN
             vr_tab_pagamento(vr_idx_pagto).imgdebto := 'sit_er.png';
             vr_tab_pagamento(vr_idx_pagto).hintdebt := 'Houve erro no processo de débito!';
             vr_tab_pagamento(vr_idx_pagto).idsitdeb := 3;
          ELSIF rw_registros.flsitdeb = 1 THEN
             vr_tab_pagamento(vr_idx_pagto).imgdebto := 'sit_ok.png';
             vr_tab_pagamento(vr_idx_pagto).hintdebt := 'Débito efetuado com sucesso';
             vr_tab_pagamento(vr_idx_pagto).idsitdeb := 4;
          END IF;

          -- Validacao de campo de debito
          IF rw_registros.flsitcre = 0 AND rw_registros.dsobscre IS NULL THEN
             vr_tab_pagamento(vr_idx_pagto).imgcredt := 'agendamento.png';
             vr_tab_pagamento(vr_idx_pagto).hintcred := 'Aguardando data de crédito...';
             vr_tab_pagamento(vr_idx_pagto).idsitcre := 2;
          ELSIF rw_registros.flsitcre = 1 AND rw_registros.dsobscre IS NOT NULL THEN
             vr_tab_pagamento(vr_idx_pagto).imgcredt := 'sit_er.png';
             vr_tab_pagamento(vr_idx_pagto).hintcred := 'Houve erro no processo de crédito!';
             vr_tab_pagamento(vr_idx_pagto).idsitcre := 3;
          ELSE
             -- Verifica registros com problema no debito ou credito
             OPEN cr_valida_apr(rw_registros.cdcooper
                               ,rw_registros.cdempres
                               ,rw_registros.nrseqpag);
             FETCH cr_valida_apr INTO rw_valida_apr;
                -- Se encontrar, o registro possui inregularidade
                IF cr_valida_apr%FOUND THEN
                   vr_tab_pagamento(vr_idx_pagto).imgcredt := 'sit_al.png';
                   vr_tab_pagamento(vr_idx_pagto).hintcred := 'Crédito efetuado com alertas!';
                   vr_tab_pagamento(vr_idx_pagto).idsitcre := 5;
                ELSE
                   vr_tab_pagamento(vr_idx_pagto).imgcredt := 'sit_ok.png';
                   vr_tab_pagamento(vr_idx_pagto).hintcred := 'Crédito efetuado com sucesso!';
                   vr_tab_pagamento(vr_idx_pagto).idsitcre := 4;
                END IF;
             CLOSE cr_valida_apr;
          END IF;

          -- Comprovante
          OPEN cr_val_comprov(rw_registros.cdcooper
                             ,rw_registros.cdempres
                             ,rw_registros.nrseqpag);
          FETCH cr_val_comprov INTO rw_val_comprov;
             -- Se o pagamento tiver recebido a carga de algum comprovante.
             IF cr_val_comprov%FOUND THEN
                vr_tab_pagamento(vr_idx_pagto).imgcompr := 'comprov_salario.png';
                vr_tab_pagamento(vr_idx_pagto).hintcomp := 'Comprovante salarial enviado!';
                vr_tab_pagamento(vr_idx_pagto).dscomprv := 'Comprovante salarial enviado.';
             ELSE
                vr_tab_pagamento(vr_idx_pagto).imgcompr := '';
                vr_tab_pagamento(vr_idx_pagto).hintcomp := '';
                vr_tab_pagamento(vr_idx_pagto).dscomprv := 'Comprovante salarial não enviado.';
             END IF;
          CLOSE cr_val_comprov;

          -- Popula a tabela
          vr_tab_pagamento(vr_idx_pagto).tpregist := 1;
          vr_tab_pagamento(vr_idx_pagto).envcompr := vr_qtdiaenv;
          vr_tab_pagamento(vr_idx_pagto).indrowid := rw_registros.dsrowid;
          vr_tab_pagamento(vr_idx_pagto).dtmvtolt := rw_registros.dtmvtolt;
          vr_tab_pagamento(vr_idx_pagto).qtlctpag := rw_registros.qtlctpag;
          vr_tab_pagamento(vr_idx_pagto).vllctpag := rw_registros.vllctpag;
          vr_tab_pagamento(vr_idx_pagto).vltarifa := rw_registros.vltarifa;
          vr_tab_pagamento(vr_idx_pagto).dtdebito := rw_registros.dtdebito;
          vr_tab_pagamento(vr_idx_pagto).dtcredit := rw_registros.dtcredit;
          CASE
            WHEN rw_registros.dssitpgt = 'Creditado'     THEN vr_tab_pagamento(vr_idx_pagto).idsitpgt := 4;            
            WHEN rw_registros.dssitpgt = 'Cred. Parcial' THEN vr_tab_pagamento(vr_idx_pagto).idsitpgt := 5;            
            WHEN rw_registros.dssitpgt = 'Debitado'      THEN vr_tab_pagamento(vr_idx_pagto).idsitpgt := 6;
            ELSE vr_tab_pagamento(vr_idx_pagto).idsitpgt := 7;            
          END CASE;
          -- Linha Oculta
          vr_tab_pagamento(vr_idx_pagto).dthorage := rw_registros.dthoragen;
          vr_tab_pagamento(vr_idx_pagto).dsdetapr := rw_registros.dsdetapr;
          vr_tab_pagamento(vr_idx_pagto).dsdetest := rw_registros.dsdetest;
          vr_tab_pagamento(vr_idx_pagto).dthordeb := rw_registros.dthordeb ||'  '||rw_registros.dsobservdeb;
          vr_tab_pagamento(vr_idx_pagto).dthorcre := rw_registros.dthorcre ||'  '||rw_registros.dsobservcre;
          vr_tab_pagamento(vr_idx_pagto).dthortar := rw_registros.dthortar ||'  '||rw_registros.dsobservtar;
          vr_tab_pagamento(vr_idx_pagto).cdempres := rw_registros.cdempres;
          vr_tab_pagamento(vr_idx_pagto).idtppagt := rw_registros.idtppagt;
          vr_tab_pagamento(vr_idx_pagto).dstpapgt := CASE WHEN rw_registros.idtppagt = 'A' THEN 'Arquivo' ELSE 'Convencional' END;
          vr_tab_pagamento(vr_idx_pagto).nrseqpag := rw_registros.nrseqpag;
          vr_tab_pagamento(vr_idx_pagto).dthrtari := rw_registros.dthortar;
          
          CASE 
            WHEN NVL(rw_registros.dthordeb,' ') = ' ' THEN vr_tab_pagamento(vr_idx_pagto).dthrdebi := ' '; 
            WHEN LENGTH(rw_registros.dthordeb) = 14 THEN vr_tab_pagamento(vr_idx_pagto).dthrdebi := rw_registros.dthordeb;
            ELSE vr_tab_pagamento(vr_idx_pagto).dthrdebi := rw_registros.dthordeb || ' 00:00';
          END CASE;
          
          CASE 
            WHEN NVL(rw_registros.dthorcre,' ') = ' ' THEN vr_tab_pagamento(vr_idx_pagto).dthrcred := ' ';
            WHEN LENGTH(rw_registros.dthorcre) = 14 THEN vr_tab_pagamento(vr_idx_pagto).dthrcred := rw_registros.dthorcre;
            ELSE vr_tab_pagamento(vr_idx_pagto).dthrcred := rw_registros.dthorcre || ' 00:00';
          END CASE;                    

          -- Proximo registro
          vr_idx_pagto := vr_idx_pagto + 1;
         
        END IF;          
                               
         vr_qtregist := rw_registros.qtregist;
         
      END LOOP;

      -- Monta documento XML
      dbms_lob.createtemporary(pr_pagto_xml, TRUE);
      dbms_lob.open(pr_pagto_xml, dbms_lob.lob_readwrite);
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_pagto_xml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<raiz>');
      -- Inicializa a leitura da tabela
      vr_idx_pagto := vr_tab_pagamento.first();
      WHILE vr_idx_pagto IS NOT NULL LOOP
         -- Grava o Corpo do XML
         gene0002.pc_escreve_xml(pr_xml            => pr_pagto_xml
                                ,pr_texto_completo => vr_xml_pgto_temp
                                ,pr_texto_novo     => '<pagamentos>'
                                                   || '<indrowid>'||vr_tab_pagamento(vr_idx_pagto).indrowid||'</indrowid>'
                                                   || '<dtmvtolt>'||TO_CHAR(vr_tab_pagamento(vr_idx_pagto).dtmvtolt,'DD/MM/YY') ||'</dtmvtolt>'
                                                   || '<dssitpgt>'||vr_tab_pagamento(vr_idx_pagto).dssitpgt ||'</dssitpgt>'
                                                   || '<qtlctpag>'||vr_tab_pagamento(vr_idx_pagto).qtlctpag ||'</qtlctpag>'
                                                   || '<vllctpag>'||TO_CHAR(vr_tab_pagamento(vr_idx_pagto).vllctpag, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||'</vllctpag>'
                                                   || '<vltarifa>'||TO_CHAR(vr_tab_pagamento(vr_idx_pagto).vltarifa, 'FM999g990D00', 'NLS_NUMERIC_CHARACTERS=,.') ||'</vltarifa>'
                                                   || '<dtdebito>'||TO_CHAR(vr_tab_pagamento(vr_idx_pagto).dtdebito,'DD/MM/YY') ||'</dtdebito>'
                                                   || '<imgdebto>'||vr_tab_pagamento(vr_idx_pagto).imgdebto ||'</imgdebto>'
                                                   || '<hintdebt>'||vr_tab_pagamento(vr_idx_pagto).hintdebt ||'</hintdebt>'
                                                   || '<dtcredit>'||TO_CHAR(vr_tab_pagamento(vr_idx_pagto).dtcredit,'DD/MM/YY') ||'</dtcredit>'
                                                   || '<imgcredt>'||vr_tab_pagamento(vr_idx_pagto).imgcredt ||'</imgcredt>'
                                                   || '<hintcred>'||vr_tab_pagamento(vr_idx_pagto).hintcred||'</hintcred>'
                                                   || '<imgcompr>'||vr_tab_pagamento(vr_idx_pagto).imgcompr ||'</imgcompr>'
                                                   || '<hintcomp>'||vr_tab_pagamento(vr_idx_pagto).hintcomp ||'</hintcomp>'
                                                   || '<tpregist>'||vr_tab_pagamento(vr_idx_pagto).tpregist ||'</tpregist>'
                                                   || '<dthorage>'||vr_tab_pagamento(vr_idx_pagto).dthorage ||'</dthorage>'
                                                   || '<dsdetapr>'||vr_tab_pagamento(vr_idx_pagto).dsdetapr ||'</dsdetapr>'
                                                   || '<dsdetest>'||vr_tab_pagamento(vr_idx_pagto).dsdetest ||'</dsdetest>'
                                                   || '<dthordeb>'||vr_tab_pagamento(vr_idx_pagto).dthordeb ||'</dthordeb>'
                                                   || '<dthorcre>'||vr_tab_pagamento(vr_idx_pagto).dthorcre ||'</dthorcre>'
                                                   || '<dthortar>'||vr_tab_pagamento(vr_idx_pagto).dthortar ||'</dthortar>'
                                                   || '<exibestr>'||vr_tab_pagamento(vr_idx_pagto).exibestr ||'</exibestr>'
                                                   || '<dscomprv>'||vr_tab_pagamento(vr_idx_pagto).dscomprv ||'</dscomprv>'
                                                   || '<hvllctpag>'||TO_CHAR(vr_tab_pagamento(vr_idx_pagto).vllctpag, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=.,')||'</hvllctpag>'
                                                   || '<hvltarifa>'||TO_CHAR(vr_tab_pagamento(vr_idx_pagto).vltarifa, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=.,')||'</hvltarifa>'
                                                   || '<cdempres>' ||vr_tab_pagamento(vr_idx_pagto).cdempres||'</cdempres>'
                                                   || '<idtpapgt>' ||vr_tab_pagamento(vr_idx_pagto).idtppagt||'</idtpapgt>'
                                                   || '<idsitapr>' ||vr_tab_pagamento(vr_idx_pagto).idsitapr||'</idsitapr>'
                                                   || '<envcompr>' ||vr_tab_pagamento(vr_idx_pagto).envcompr||'</envcompr>'
                                                   || '<qtregist>' || vr_qtregist || '</qtregist>' 
                                                   || '<dtcrefmt>'||TO_CHAR(vr_tab_pagamento(vr_idx_pagto).dtcredit,'DD/MM/YYYY') ||'</dtcrefmt>'
                                                   || '<nrseqpag>'||vr_tab_pagamento(vr_idx_pagto).nrseqpag ||'</nrseqpag>'
                                                   
                                                   || '<dthrdebi>'||vr_tab_pagamento(vr_idx_pagto).dthrdebi ||'</dthrdebi>'
                                                   || '<dthrcred>'||vr_tab_pagamento(vr_idx_pagto).dthrcred ||'</dthrcred>'
                                                   || '<dthrtari>'||vr_tab_pagamento(vr_idx_pagto).dthrtari ||'</dthrtari>'
                                                   || '<idsitdeb>'||vr_tab_pagamento(vr_idx_pagto).idsitdeb ||'</idsitdeb>'
                                                   || '<idsitcre>'||vr_tab_pagamento(vr_idx_pagto).idsitcre ||'</idsitcre>'
                                                   || '<idsitpgt>'||vr_tab_pagamento(vr_idx_pagto).idsitpgt ||'</idsitpgt>'
                                                   || '<dstpapgt>'||vr_tab_pagamento(vr_idx_pagto).dstpapgt ||'</dstpapgt>'
                                                   || '</pagamentos>');
         vr_idx_pagto := vr_tab_pagamento.NEXT(vr_idx_pagto); -- Proximo registro
      END LOOP;
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_pagto_xml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

      -- Limpando tabela de memória
      vr_tab_pagamento.DELETE;

   EXCEPTION
      WHEN vr_exc_erro THEN
         -- Apenas retornamos o erro
         NULL;
      WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro ao montar XML. Rotina FOLH.pc_busca_dados_pagto_ib: '||SQLERRM;
   END pc_busca_dados_pagto_ib;

   -- Procedure encarregada de efetuar o cancelamento dos registros
   PROCEDURE pc_cancela_pagto_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                ,pr_indrowid   IN VARCHAR2
                                ,pr_nrdconta   IN NUMBER
                                ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE
                                ,pr_cdcritic   OUT PLS_INTEGER
                                ,pr_dscritic   OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_cancela_pagto_ib
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2015.                   Ultima atualizacao: 26/01/2016
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure encarregada de efetuar o cancelamento dos registros
   --
   -- Alteracoes: 26/01/2016 - Inclusão de LOG sob as operações efetuadas (Marcos-Supero)
   /*
                  04/09/2017 - Alteração Projeto Assinatura conjunta (Proj 397), 
                  Validar o limite do operador para realizar o cancelamento de uma
                  folha de pagamento
   */
   ---------------------------------------------------------------------------------------------------------------

      -- Busca todos os dados do registro selecionado
      CURSOR cr_valida_reg(p_rowid IN VARCHAR2) IS
         SELECT pfp.cdcooper
               ,pfp.flsitcre
               ,pfp.idsitapr
               ,pfp.flsitdeb
               ,pfp.cdempres
               ,pfp.nrseqpag
               ,pfp.vllctpag
               ,pfp.idtppagt
               ,pfp.idopdebi
               ,pfp.dtdebito
               ,pfp.dtcredit
               ,pfp.qtlctpag
           FROM crappfp pfp
          WHERE pfp.rowid = p_rowid;
      rw_valida_reg cr_valida_reg%ROWTYPE;

      -- Busca todos os dados do registro selecionado
      CURSOR cr_crapemp(p_cdcooper IN crapcop.cdcooper%TYPE
                       ,p_cdempres IN crapemp.cdempres%TYPE) IS
         SELECT emp.nrdconta
               ,ass.nrdctitg
               ,emp.idtpempr
           FROM crapemp emp
               ,crapass ass
          WHERE emp.cdcooper = p_cdcooper
            AND emp.cdempres = p_cdempres
            AND emp.cdcooper = ass.cdcooper
            AND emp.nrdconta = ass.nrdconta;
      rw_crapemp cr_crapemp%ROWTYPE;

      -- Busca dados da tabela
      CURSOR cr_craptab(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_tpregist NUMBER) IS
         SELECT to_number(dstextab) nrdolote
           FROM craptab
          WHERE craptab.cdcooper = p_cdcooper -- Cooperativa
            AND upper(craptab.nmsistem) = 'CRED'
            AND upper(craptab.tptabela) = 'GENERI'
            AND craptab.cdempres = 0
            AND upper(craptab.cdacesso) = 'NUMLOTEFOL'
            AND craptab.tpregist = p_tpregist; -- Codigo da empresa
      rw_craptab cr_craptab%ROWTYPE;

      -- Busca o lote para atualizar
      CURSOR cr_craplot(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_dtmvtolt DATE
                       ,p_nrdolote NUMBER) IS
         SELECT nrseqdig
               ,nrdolote
               ,ROWID idrowid
          FROM craplot
         WHERE craplot.cdcooper = p_cdcooper
           AND craplot.dtmvtolt = p_dtmvtolt
           AND craplot.cdagenci = 1
           AND craplot.cdbccxlt = 100
           AND craplot.nrdolote = p_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      CURSOR cr_crappfp (prc_indrowid IN VARCHAR2)IS
        SELECT pfp.dtdebito,
               pfp.vllctpag
          FROM crappfp pfp
         WHERE pfp.rowid like prc_indrowid;
      --
       CURSOR cr_crapopi (prc_cdcooper       IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                         ,prc_nrdconta       IN crapass.nrdconta%TYPE --Conta do Associado
                         ,prc_nrcpfope       IN crapass.nrcpfcgc%TYPE) IS
         SELECT 1
            FROM crapopi opi
           WHERE opi.cdcooper = prc_cdcooper
             AND opi.nrdconta = prc_nrdconta
             AND opi.nrcpfope = prc_nrcpfope
             AND rownum       = 1;      
      -- Variaveis de exception
      vr_erro      EXCEPTION;

      -- Variaveis
      vr_nrseqdig  craplot.nrseqdig%TYPE := 0;
      vr_cdhisest  NUMBER(10);
      vr_nrdrowid  ROWID;
      va_existe_operador NUMBER;
      vr_vllanmto  crappfp.vllctpag%type;
      va_data_ant  crappfp.dtdebito%type;
      pr_tab_internet INET0001.typ_tab_internet;
      vr_vldspptl     crapsnh.vllimflp%TYPE ;

   BEGIN
      -- Inicializa variavel
      pr_cdcritic := NULL;
      pr_dscritic := NULL;

      -- Buscando todos os dados do registro selecionado
      -- para aplicar as validacoes necessarias
      OPEN  cr_valida_reg(pr_indrowid);
      FETCH cr_valida_reg INTO rw_valida_reg;
      CLOSE cr_valida_reg;

      -- Se o registro ja foi creditado
      IF rw_valida_reg.flsitcre IN (1, 2) THEN
         -- Gera critica
         pr_cdcritic := 0;
         pr_dscritic := 'Pagamentos já creditados aos empregados não podem ser cancelados!';
         RAISE vr_erro;
      END IF;

      -- Apos a validacao do registro, busca os dados do associado
      OPEN  cr_crapemp(pr_cdcooper
                      ,rw_valida_reg.cdempres);
      FETCH cr_crapemp INTO rw_crapemp;
      CLOSE cr_crapemp;
      -- Inicializa
      va_existe_operador := 0;
      -- Verifica se é operador
      BEGIN
        FOR rw_crapopi IN cr_crapopi(pr_cdcooper,
                                     pr_nrdconta,
                                     pr_nrcpfope) LOOP
          va_existe_operador := 1;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic:= 0;
          pr_dscritic:= 'FOLH0002.Erro ao buscar operador: '||sqlerrm||  ' rowid: '||pr_indrowid;
          --Levantar Excecao
          RAISE vr_erro;
      END;       
      -- Se Operador e nao pendente
      IF va_existe_operador = 1 AND rw_valida_reg.idsitapr <> 1 THEN
          pr_cdcritic:= 0;
          pr_dscritic:= 'Operador só pode cancelar folha de pagamento com status pendente';
          --Levantar Excecao
          RAISE vr_erro;        
      END IF;
      -- Se operador 
      IF va_existe_operador = 1 THEN
        vr_vllanmto := 0;
        va_data_ant := null;
        vr_vldspptl := 0;
        FOR rw_crappfp IN cr_crappfp(pr_indrowid) LOOP
          va_data_ant := rw_crappfp.dtdebito;
          vr_vllanmto := rw_crappfp.vllctpag;
        END LOOP;
        BEGIN
        
          INET0001.pc_busca_limites_opera_trans(pr_cdcooper    => pr_cdcooper  --Codigo Cooperativa
                                              ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                              ,pr_idseqttl     => 1            --Identificador Sequencial titulo
                                              ,pr_nrcpfope     => pr_nrcpfope  --Numero do CPF
                                              ,pr_dtmvtopg     => nvl(va_data_ant,sysdate)  --Data do debito da folha de pagamento
                                              ,pr_dsorigem     => 'INTERNET'  --Descricao Origem
                                              ,pr_tab_internet => pr_tab_internet --Tabelas de retorno de horarios limite
                                              ,pr_cdcritic     => pr_cdcritic   --Codigo do erro
                                              ,pr_dscritic     => pr_dscritic); --Descricao do erro;
                             
          --Se ocorreu erro
          IF pr_cdcritic IS NOT NULL OR pr_dscritic IS NOT NULL THEN
            --Levantar Excecao
             RAISE vr_erro;
          END IF; 
          
          IF NOT pr_tab_internet.EXISTS(1) THEN
            pr_cdcritic:= 0;
            pr_dscritic:= 'Registro de limite para validar cancelamento folha de pagamento nao encontrado.';
            --Levantar Excecao
            RAISE vr_erro;
          END IF; 
          
           vr_vldspptl := pr_tab_internet(1).vldspflp;            
          /** Verifica se pode movimentar em relacao ao que ja foi usado **/
          IF vr_vllanmto > vr_vldspptl  THEN
            pr_cdcritic:= 0;
            pr_dscritic:= 'Operador não possui limite disponível para cancelar a folha de pagamento';
            --Levantar Excecao
            RAISE vr_erro;            
          END IF;              
        END;
      END IF;
      --

      IF rw_valida_reg.idsitapr <> 1 THEN

         -- Para os registros debitados, será necessário processar
         -- o estorno do débito em conta.
         IF rw_valida_reg.flsitdeb = 1 THEN

            --  Primeiramente iremos buscar o número do Lote desta empresa
            OPEN  cr_craptab(pr_cdcooper
                            ,rw_valida_reg.cdempres);
            FETCH cr_craptab INTO rw_craptab;
            CLOSE cr_craptab;

            -- Com o número do lote, verificamos se o mesmo já não foi criado
            OPEN cr_craplot(pr_cdcooper
                           ,pr_dtmvtolt
                           ,rw_craptab.nrdolote);
            FETCH cr_craplot INTO rw_craplot;
            -- Se nao encontrar
            IF cr_craplot%NOTFOUND THEN
               -- Fecha cursor
               CLOSE cr_craplot;
               -- Se nao existir cria a capa de lote
               BEGIN
                  INSERT INTO craplot(cdcooper
                                     ,dtmvtolt
                                     ,cdagenci
                                     ,cdbccxlt
                                     ,nrdolote
                                     ,tplotmov)
                  VALUES(pr_cdcooper
                        ,pr_dtmvtolt
                        ,1   --> cdagenci
                        ,100 --> cdbccxlt
                        ,rw_craptab.nrdolote
                        ,1)
                  RETURNING nrseqdig
                           ,nrdolote
                           ,ROWID INTO rw_craplot.nrseqdig
                                      ,rw_craplot.nrdolote
                                      ,rw_craplot.idrowid;
               EXCEPTION
                  WHEN OTHERS THEN
                     pr_cdcritic := 0;
                     pr_dscritic := 'Erro ao inserir CRAPLOT : '||SQLERRM;
                     RAISE vr_erro;
               END;
            ELSE
               -- Apenas fecha cursor
               CLOSE cr_craplot;
            END IF;

            -- Guarda o valor da sequencia
            vr_nrseqdig := rw_craplot.nrseqdig + 1;

            -- Para cooperativas
            IF rw_crapemp.idtpempr = 'C' THEN
               vr_cdhisest := TO_NUMBER(gene0001.fn_param_sistema('CRED'
                                                                 ,pr_cdcooper
                                                                 ,'FOLHAIB_HIS_ESTOR_COOP'));
            ELSE
               -- Para outras empresas
               vr_cdhisest := TO_NUMBER(gene0001.fn_param_sistema('CRED'
                                                                 ,pr_cdcooper
                                                                 ,'FOLHAIB_HIS_ESTOR_EMPR'));
            END IF;

            -- Inserir lançamento
            INSERT INTO craplcm(dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,nrdconta
                               ,nrdctabb
                               ,nrdctitg
                               ,nrdocmto
                               ,cdhistor
                               ,vllanmto
                               ,nrseqdig
                               ,cdcooper)
            VALUES(pr_dtmvtolt
                  ,1
                  ,100
                  ,rw_craplot.nrdolote
                  ,rw_crapemp.nrdconta --> Conta da empresa
                  ,rw_crapemp.nrdconta --> Conta da empresa
                  ,GENE0002.fn_mask(rw_crapemp.nrdctitg,'99999999') -- nrdctitg
                  ,vr_nrseqdig
                  ,vr_cdhisest
                  ,rw_valida_reg.vllctpag
                  ,vr_nrseqdig
                  ,pr_cdcooper);

            -- Atualiza o lote
            UPDATE craplot lot
               SET lot.nrseqdig = lot.nrseqdig + 1
                  ,lot.qtcompln = lot.qtcompln + 1
                  ,lot.qtinfoln = lot.qtinfoln + 1
                  ,lot.vlcompcr = lot.vlcompcr + rw_valida_reg.vllctpag
                  ,lot.vlinfocr = lot.vlinfocr + rw_valida_reg.vllctpag
             WHERE lot.rowid = rw_craplot.idrowid;

         END IF;

         -- Por fim, cancelamos o registro
         UPDATE crappfp pfp
            SET pfp.idsitapr = 1
               ,pfp.nrcpfapr = 0
               ,pfp.dtsolest = NULL
               ,pfp.cdopeest = NULL
               ,pfp.dsjusest = NULL
               ,pfp.flsitdeb = 0
               ,pfp.dthordeb = NULL
               ,pfp.dsobsdeb = NULL
               ,pfp.vltarapr = NULL
          WHERE pfp.rowid = pr_indrowid;

      ELSE -- Para pagamentos pendentes

         -- Eliminamos os lancamentos
         BEGIN
           DELETE craplfp lfp
            WHERE lfp.cdcooper = rw_valida_reg.cdcooper
              AND lfp.cdempres = rw_valida_reg.cdempres
              AND lfp.nrseqpag = rw_valida_reg.nrseqpag;
         EXCEPTION
            WHEN OTHERS THEN
               pr_cdcritic := 0;
               pr_dscritic := 'Erro ao deletar a CRAPLFP: ' || SQLERRM;
               RAISE vr_erro;
         END;

         -- Eliminamos o pagamento
         BEGIN
           DELETE crappfp pfp
            WHERE pfp.rowid = pr_indrowid;
         EXCEPTION
            WHEN OTHERS THEN
               pr_cdcritic := 0;
               pr_dscritic := 'Erro ao deletar a CRAPPFP: ' || SQLERRM;
               RAISE vr_erro;
         END;

      END IF;

      -- Geração do LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 996
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(3)
                          ,pr_dstransa => 'Pagto Folha #'||rw_valida_reg.nrseqpag||' cancelado por '||folh0001.fn_nmoperad_log(pr_cdcooper,pr_nrdconta,pr_nrcpfope)
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO
                          ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      -- Adição de detalhes a nivel de item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Empresa'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => rw_valida_reg.cdempres);
      IF rw_valida_reg.idtppagt = 'A' THEN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Tipo'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'Arquivo');
      ELSE
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Tipo'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'Convencional');
      END IF;
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Opção Débito'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => folh0001.fn_nmopdebi_log(rw_valida_reg.idopdebi));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data Débito'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(rw_valida_reg.dtdebito,'dd/mm/rrrr'));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data Crédito'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(rw_valida_reg.dtcredit,'dd/mm/rrrr'));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Quantidade de pagamentos'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => rw_valida_reg.qtlctpag);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Valor dos pagamentos'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(rw_valida_reg.vllctpag,'fm999g999g999g990d00'));
      IF rw_valida_reg.flsitdeb = 0 THEN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Débito Estornado?'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'Não necessário');
      ELSE
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Débito Estornado?'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'Sim');
      END IF;
      IF rw_valida_reg.idsitapr <> 1 THEN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Pagamento eliminado?'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'Não');
      ELSE
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Pagamento eliminado?'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'Sim');
      END IF;

      -- Efetua Commit
      COMMIT;

   EXCEPTION
      WHEN vr_erro THEN
         -- Desfaz qualquer operacao
         ROLLBACK;
      WHEN OTHERS THEN
         -- Desfaz qualquer operacao
         ROLLBACK;
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina FOLH0002.pc_cancela_pagto_ib: '||SQLERRM;
   END pc_cancela_pagto_ib;

   /* Procedure para realizar validacao da aprovacao dos pagamentos */
   PROCEDURE pc_valida_pagto_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE
                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                               ,pr_indrowid  IN VARCHAR2
                               ,pr_flvalsld  IN NUMBER
                               ,pr_nrcpfope  IN NUMBER
                               ,pr_des_reto  OUT VARCHAR2
                               ,pr_dscritic  OUT VARCHAR2
                               ,pr_retxml    OUT CLOB) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_validar_pagto              Antigo:
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Jaison
   --  Data     : Julho/2015.                   Ultima atualizacao: 05/07/2018
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure para realizar validacao da aprovacao dos pagamentos
   --
   -- Alterações: 12/11/2015 - Migracao da tarifação do sistema da CONFOL para CADTAR (Marcos-Supero)
   --
   --             21/12/2015 - Adicionado param de entrada pr_flvalsld, projeto 131. (Reinert/David)

   --             16/02/2016 - Inclusao do parametro conta na chamada da
   --                          FOLH0001.fn_valor_tarifa_folha. (Jaison/Marcos)
   --
   --             07/07/2016 - Mudança nos parâmetros da chamada de saldo para melhora
   --                          de performance - Marcos(Supero)
   --                          
   --             08/12/2016 - Ajuste realizado para solucionar o problema que estava 
   --                          impedindo que continuasse a operação pois o cooperado
   --                          havia feito uma solicitacao de estouro, conforme relatado
   --                          no chamado 499370. (Kelvin)
   --                     
   --             16/01/2017 - Adicionado validacao de horario para agendamentos d-2. (M342 - Kelvin)
   --                     
   --             05/07/2018 - Inclusao das tags de cdtarifa e cdfaixav no XML de saída, Prj.363 (Jean Michel)
   --
   ---------------------------------------------------------------------------------------------------------------

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

     -- Busca os dados do pagamento
     CURSOR cr_crappfp(pr_rowid IN VARCHAR2) IS
        SELECT pfp.idsitapr
              ,pfp.vllctpag
              ,pfp.dtdebito
              ,pfp.dtcredit
              ,pfp.idopdebi
              ,pfp.nrseqpag
              ,pfp.cdempres
          FROM crappfp pfp
         WHERE pfp.rowid = pr_rowid;
     rw_crappfp cr_crappfp%ROWTYPE;

     -- Busca o limite de folha da empresa
     CURSOR cr_crapemp(pr_cdcooper IN crapemp.cdcooper%TYPE
                      ,pr_nrdconta IN crapemp.nrdconta%TYPE) IS
        SELECT emp.cdempres
              ,emp.vllimfol
              ,ass.vllimcre
          FROM crapemp emp
              ,crapass ass
         WHERE emp.cdcooper = pr_cdcooper
           AND emp.nrdconta = pr_nrdconta
           AND ass.cdcooper = emp.cdcooper
           AND ass.nrdconta = emp.nrdconta;
     rw_crapemp cr_crapemp%ROWTYPE;

     -- Busca o valor total de registros aprovados
     CURSOR cr_totaprv(pr_cdcooper crappfp.cdcooper%TYPE
                      ,pr_cdempres crappfp.cdempres%TYPE
                      ,pr_dtdebito crappfp.dtdebito%TYPE
                      ,pr_nrseqpag VARCHAR2) IS
        SELECT nvl(SUM(pfp.vllctpag*decode(flsitdeb,1,0,1)),0)  -- Desconsiderando os debitados
              ,nvl(SUM(pfp.vllctpag),0)                         -- Todos os aprovados do dia
          FROM crappfp pfp
         WHERE pfp.cdcooper = pr_cdcooper
           AND pfp.cdempres = pr_cdempres
           AND pfp.dtdebito = pr_dtdebito
           AND pfp.idsitapr IN (2,4,5) -- 2-Em estouro / 4-Aprv.Estouro / 5-Aprovado
           AND gene0002.fn_existe_valor(pr_nrseqpag,pfp.nrseqpag,',') = 'N';

     -- Busca os lancamentos da folha
     CURSOR cr_craplfp(pr_cdcooper craplfp.cdcooper%TYPE
                      ,pr_cdempres craplfp.cdempres%TYPE
                      ,pr_nrseqpag craplfp.nrseqpag%TYPE) IS
        SELECT lfp.idtpcont
              ,lfp.nrdconta
              ,lfp.nrcpfemp
          FROM craplfp lfp
         WHERE lfp.cdcooper = pr_cdcooper
           AND lfp.cdempres = pr_cdempres
           AND lfp.nrseqpag = pr_nrseqpag
      GROUP BY lfp.idtpcont
              ,lfp.nrdconta
              ,lfp.nrcpfemp;

     -- Busca o valor da tarifa
     CURSOR cr_vltarif(pr_cdcooper crappfp.cdcooper%TYPE
                      ,pr_nrdconta crapemp.nrdconta%TYPE
                      ,pr_nrseqpag crappfp.nrseqpag%TYPE) IS
        SELECT (folh0001.fn_valor_tarifa_folha(pr_cdcooper,emp.nrdconta,emp.cdcontar,pfp.idopdebi,pfp.vllctpag) * pfp.qtlctpag) vltarida
          FROM crapemp emp
              ,crappfp pfp
         WHERE pfp.cdcooper = pr_cdcooper
           AND emp.nrdconta = pr_nrdconta
           AND pfp.cdcooper = emp.cdcooper
           AND pfp.cdempres = emp.cdempres
           AND pfp.nrseqpag = pr_nrseqpag;

     -- Busca a data limite de agendamento
     CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE) IS
        SELECT TRUNC(SYSDATE) + qtddaglf
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = 90;

     -- Buscar Limite do Operador
     CURSOR cr_crapopi(prc_cdcooper crapopi.cdcooper%type,
                       prc_nrdconta crapopi.nrdconta%type,
                       prc_nrcpfope crapopi.nrcpfope%type) IS
       SELECT c.vllimflp
         FROM crapopi c
        WHERE c.cdcooper = prc_cdcooper
          AND c.nrdconta = prc_nrdconta
          AND c.nrcpfope = prc_nrcpfope;
     --
     CURSOR cr_crappfp_2 (pr_cdcooper IN crappfp.cdcooper%type
                         ,pr_nrdconta IN crapemp.nrdconta%type
                         ,pr_dtdebito IN crappfp.dtdebito%type) IS
      SELECT nvl(sum(pfp.VLLCTPAG),0) vllctpag
         FROM crapemp emp
            , crappfp pfp
            , crapass ass
        WHERE emp.cdcooper  = pfp.cdcooper
          AND emp.cdempres  = pfp.cdempres
          AND pfp.cdcooper = pr_cdcooper
          AND emp.nrdconta = pr_nrdconta
          AND TRUNC(pfp.dtdebito) = TRUNC(pr_dtdebito)
          AND ass.cdcooper = emp.cdcooper
          AND ass.nrdconta = emp.nrdconta
          AND pfp.idsitapr = 5 -- Aprovada
          ;         

     -- Tabelas
     TYPE typ_reg_craplfp IS
       RECORD (nrdconta craplfp.nrdconta%TYPE
              ,nrcpfemp craplfp.nrcpfemp%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,dscritic VARCHAR2(4000));

     TYPE typ_tab_craplfp IS
       TABLE OF typ_reg_craplfp
       INDEX BY PLS_INTEGER;

     -- Variaveis da PLTABLE
     vr_tab_craplfp typ_tab_craplfp;
     vr_tab_saldo   EXTR0001.typ_tab_saldos;

     -- Variaveis
     vr_indrowid GENE0002.typ_split;
     vr_rowid    VARCHAR2(50);
     vr_xml_temp VARCHAR2(32726) := '';
     vr_dtlimite DATE;
     vr_dtdebpfp crappfp.dtdebito%TYPE;
     vr_vltotapr crappfp.vllctpag%TYPE;
     vr_vltotpen crappfp.vllctpag%TYPE;
     vr_vltotsel crappfp.vllctpag%TYPE;
     vr_vltotpag crappfp.vllctpag%TYPE;
     vr_vlrtotal crappfp.vllctpag%TYPE;
     vr_vltarifa crappfp.vllctpag%TYPE;
     vr_vltottar crappfp.vllctpag%TYPE;
     vr_hrlimite crapprm.dsvlrprm%TYPE;
     vr_hrlimcop crapprm.dsvlrprm%TYPE;
     vr_nmprimtl crapass.nmprimtl%TYPE;
     vr_vlsddisp crapsda.vlsddisp%TYPE;
     vr_nrseqpag VARCHAR2(1500);
     vr_dsmsgret VARCHAR2(1000);
     vr_totporta NUMBER;
     vr_totcoope NUMBER;
     vr_totporar NUMBER;
     vr_totaprov NUMBER;
     vr_dtdebito crappfp.dtdebito%type;

     -- Variaveis de Erro
     vr_dscritic VARCHAR2(4000);
     vr_dsalerta VARCHAR2(4000);
     vr_des_reto VARCHAR2(3);
     vr_tab_erro GENE0001.typ_tab_erro;

     --
     vr_nrdrowid ROWID;
     
     -- Variaveis Excecao
     vr_exc_erro EXCEPTION;

     vr_cdtarifa VARCHAR2(10);
     vr_cdfaixav VARCHAR2(10);
     vr_dstarfai VARCHAR2(20);

    BEGIN
       -- Inicializa as variaveis
       pr_des_reto := 'OK';
       pr_dscritic := NULL;
       vr_dtdebpfp := NULL;
       vr_vltotapr := 0;
       vr_vltotsel := 0;
       vr_vltottar := 0;
       vr_vlsddisp := 0;
       vr_vlrtotal := 0;
       vr_dsmsgret := NULL;
       vr_totporta := 0;
       vr_totcoope := 0;
       vr_totporar := 0;
       vr_tab_craplfp.DELETE;
       vr_nrseqpag := NULL;

       -- Quebra a string contendo o rowid separado por virgula
       vr_indrowid := gene0002.fn_quebra_string(pr_string => pr_indrowid, pr_delimit => ',');

       vr_dtdebito := null;
       vr_totaprov := 0;
       
       -- Para cada registro selecionado, faremos as validacoes necessarias
       FOR vr_index IN 1..vr_indrowid.COUNT() LOOP
         --Reinicilizando variaveis
         vr_totporta := 0;
         vr_totcoope := 0;
         
         -- ROWID do pagamento
         vr_rowid := vr_indrowid(vr_index);

         -- Buscando todos os dados do registro selecionado
         OPEN  cr_crappfp(pr_rowid => vr_rowid);
         FETCH cr_crappfp INTO rw_crappfp;
         CLOSE cr_crappfp;

         IF vr_nrseqpag IS NULL THEN
           vr_nrseqpag := rw_crappfp.nrseqpag;
         ELSE
           vr_nrseqpag := vr_nrseqpag || ',' || rw_crappfp.nrseqpag;  
         END IF;
          
         -- Novas TAGS
         vr_dstarfai := FOLH0001.fn_cdtarifa_cdfaixav(pr_cdocorre => rw_crappfp.idopdebi);
         vr_cdtarifa := gene0002.fn_busca_entrada(1,vr_dstarfai,',');
         vr_cdfaixav := gene0002.fn_busca_entrada(2,vr_dstarfai,',');

         
         -- Caso NAO esteja como Pendente(1), Reprovado(3)
         -- Se for Solicitacao De Estouro(2), devemos deixar processeguir
         -- pois usuario pode ter ajustado o saldo da conta e desaja tentar
         -- novamente a operacao
         IF rw_crappfp.idsitapr NOT IN(1,2,3,6) THEN
           -- Gera critica
           pr_dscritic := 'Somente pagamentos pendentes podem ser Aprovados!';
           RAISE vr_exc_erro;
         END IF;

         -- Caso seja a primeira vez guarda a data de debito
         IF vr_dtdebpfp IS NULL THEN
           vr_dtdebpfp := rw_crappfp.dtdebito;
         END IF;

         -- Caso a data de debito guardada seja diferente da data do registro atual
         IF vr_dtdebpfp <> rw_crappfp.dtdebito THEN
           -- Gera critica
           pr_dscritic := 'Selecione apenas pagamentos com a mesma data de débito da sua conta!';
           RAISE vr_exc_erro;
         END IF;

         -- Caso a data de Debito esteja vencida ou NAO seja um dia util
         IF rw_crappfp.dtdebito < pr_dtmvtolt OR
            rw_crappfp.dtdebito <> GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                              ,pr_dtmvtolt => rw_crappfp.dtdebito) THEN
           -- Gera critica
           pr_dscritic := 'Data de débito inválida!';
           RAISE vr_exc_erro;
         END IF;

         -- Caso a data de Credito esteja vencida ou NAO seja um dia util
         IF rw_crappfp.dtcredit < pr_dtmvtolt OR
            rw_crappfp.dtcredit <> GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                              ,pr_dtmvtolt => rw_crappfp.dtcredit) THEN
           -- Gera critica
           pr_dscritic := 'Data de crédito inválida!';
           RAISE vr_exc_erro;
         END IF;

         -- Caso o debito seja no dia
         /*IF rw_crappfp.dtdebito = pr_dtmvtolt THEN

           -- Credito agendado (D-1)
           IF rw_crappfp.idopdebi = 1 THEN
             -- Busca o horario limite
             vr_hrlimite := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                     ,pr_cdcooper => pr_cdcooper
                                                     ,pr_cdacesso => 'FOLHAIB_HOR_LIM_AGENDA');
             -- Se atingiu o horario, gera critica
             IF TO_CHAR(SYSDATE,'hh24:mi') > vr_hrlimite THEN
               -- Gera critica
               pr_dscritic := 'Horário inválido! Para agendar os pagamentos, você deveria aprová-los até as ' || vr_hrlimite;
               RAISE vr_exc_erro;
             END IF;
           -- Credito no dia
           ELSE
             -- Busca o horario limite
             vr_hrlimite := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                     ,pr_cdcooper => pr_cdcooper
                                                     ,pr_cdacesso => 'FOLHAIB_HOR_LIM_PORTAB');
             -- Se atingiu o horario permitido
             IF TO_CHAR(SYSDATE,'hh24:mi') > vr_hrlimite THEN
               -- Gera critica
               pr_dscritic := 'Horário inválido! Para pagamento do dia, você deve aprovar os pagamentos até as ' || vr_hrlimite;
               RAISE vr_exc_erro;
             END IF;
           END IF;

         END IF;

         END IF;*/

         -- Listagem dos lancamentos dos pagamentos
         FOR rw_craplfp IN cr_craplfp(pr_cdcooper => pr_cdcooper,
                                      pr_cdempres => rw_crappfp.cdempres,
                                      pr_nrseqpag => rw_crappfp.nrseqpag) LOOP
           
           --Portabilidade
           IF rw_craplfp.idtpcont = 'T' THEN
              vr_totporta := vr_totporta + 1;
              vr_totporar := vr_totporar + 1;
           --Conta da cooperativa
           ELSIF rw_craplfp.idtpcont = 'C' THEN
              vr_totcoope := vr_totcoope + 1;   
           END IF;  
                                                                          
           -- Verificar a situacao de cada conta, pois algum empregado pode ter encerrado sua conta
           -- ou efetuado alguma alteracao em seu cadastro que impeca o credito
           FOLH0001.pc_valida_lancto_folha(pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => rw_craplfp.nrdconta,
                                           pr_nrcpfcgc => rw_craplfp.nrcpfemp,
                                           pr_idtpcont => rw_craplfp.idtpcont,
                                           pr_nmprimtl => vr_nmprimtl,
                                           pr_dsalerta => vr_dsalerta,
                                           pr_dscritic => vr_dscritic);
           -- Caso tenha retornado alguma critica
           IF vr_dsalerta IS NOT NULL OR
              vr_dscritic IS NOT NULL THEN
             -- Criar um registro no vetor
             vr_tab_craplfp(vr_tab_craplfp.COUNT() + 1).nrdconta := rw_craplfp.nrdconta;
             vr_tab_craplfp(vr_tab_craplfp.COUNT()).nrcpfemp := rw_craplfp.nrcpfemp;
             vr_tab_craplfp(vr_tab_craplfp.COUNT()).nmprimtl := vr_nmprimtl;
             vr_tab_craplfp(vr_tab_craplfp.COUNT()).dscritic := NVL(vr_dsalerta,vr_dscritic);
           END IF;
           
         END LOOP; -- cr_craplfp

         IF rw_crappfp.dtdebito = pr_dtmvtolt THEN
           
           -- Credito agendado (D-1 ou D-2)
           IF rw_crappfp.idopdebi IN (1,2) THEN
             -- Busca o horario limite
             vr_hrlimite := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                     ,pr_cdcooper => pr_cdcooper
                                                     ,pr_cdacesso => 'FOLHAIB_HOR_LIM_AGENDA');
             -- Se atingiu o horario, gera critica
             IF TO_CHAR(SYSDATE,'hh24:mi') > vr_hrlimite THEN
               -- Gera critica
               pr_dscritic := 'Horário inválido! Para agendar os pagamentos, você deveria aprová-los até as ' || vr_hrlimite;
               RAISE vr_exc_erro;
             END IF;
                                                     
           ELSE
         
             --Tem apenas contas de portabilidade
             IF vr_totporta > 0 AND vr_totcoope = 0 THEN           
               -- Busca o horario limite
               vr_hrlimite := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                       ,pr_cdcooper => pr_cdcooper
                                                       ,pr_cdacesso => 'FOLHAIB_HOR_LIM_PORTAB');
               -- Se atingiu o horario permitido
               IF TO_CHAR(SYSDATE,'hh24:mi') > vr_hrlimite THEN
                 -- Gera critica
                 pr_dscritic := 'Horário inválido! Para pagamento do dia, você deve aprovar os pagamentos até as ' || vr_hrlimite;
                 RAISE vr_exc_erro;
               END IF;            
             --Pode ou nao ter os dois tipos*/
             ELSE
               vr_hrlimcop := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                       ,pr_cdcooper => pr_cdcooper
                                                       ,pr_cdacesso => 'FOLHAIB_HOR_LIM_PAG_COOP');
               
               -- Se atingiu o horario permitido
               IF TO_CHAR(SYSDATE,'hh24:mi') > vr_hrlimcop THEN
                 -- Gera critica
                 pr_dscritic := 'Horário inválido! Para pagamento do dia, você deve aprovar os pagamentos até as ' || vr_hrlimcop;
                 RAISE vr_exc_erro;
               END IF;  
               
               IF vr_totporta > 0 THEN
                 
                 vr_hrlimite := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                         ,pr_cdcooper => pr_cdcooper
                                                         ,pr_cdacesso => 'FOLHAIB_HOR_LIM_PORTAB');  
               
               
                 -- Se atingiu o horario permitido
                 IF TO_CHAR(SYSDATE,'hh24:mi') > vr_hrlimite THEN
                   vr_dsmsgret := 'Cooperado, neste pagamento há ' || vr_totporar || ' conta(s) de portabilidade que devem receber o salário até
                                   às ' || vr_hrlimite ||', conforme determinação do Banco Central. Para essas contas o pagamento será
                                   realizado somente no próximo dia útil. Deseja continuar?';                                                   
                 END IF;
               END IF;
             END IF;
           END IF;
         END IF;
         
         -- Busca o valor da tarifa
         OPEN  cr_vltarif(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrseqpag => rw_crappfp.nrseqpag);
         FETCH cr_vltarif INTO vr_vltarifa;
         CLOSE cr_vltarif;

         -- Acumula os lancamentos selecionados e as tarifas
         vr_vltotsel := vr_vltotsel + rw_crappfp.vllctpag;
         vr_vltottar := vr_vltottar + NVL(vr_vltarifa,0);

         -- Somar as folhas de pagamento aprovadas, para subtrair do limite do operador
         -- ou preposto
         -- 397
         /*FOR rw_crappfp_2 IN cr_crappfp_2(pr_cdcooper,
                                          pr_nrdconta,
                                          rw_crappfp.dtdebito) LOOP

           IF rw_crappfp_2.vllctpag <> 0 AND 
              (vr_dtdebito IS NULL OR vr_dtdebito <> rw_crappfp.dtdebito) THEN
             vr_dtdebito := rw_crappfp.dtdebito;
             vr_totaprov := vr_totaprov + rw_crappfp_2.vllctpag;
           END IF;
         END LOOP;*/

       END LOOP; -- vr_indrowid

       -- Busca a data limite de agendamento
       OPEN  cr_crapage(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapage INTO vr_dtlimite;
       CLOSE cr_crapage;

       -- Caso a data de debito guardada seja maior que a data limite
       IF vr_dtdebpfp > vr_dtlimite THEN
         -- Gera critica
         pr_dscritic := 'Os pagamentos não podem ser agendados para este prazo, favor rever a data do débito para uma data mais próxima!';
         RAISE vr_exc_erro;
       END IF;

       -- Carrega o valor limite de folha da empresa
       OPEN  cr_crapemp(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
       FETCH cr_crapemp INTO rw_crapemp;
       CLOSE cr_crapemp;

       -- Busca o valor total pendente de debito e o total aprovado da empresa para o dia
       OPEN  cr_totaprv(pr_cdcooper => pr_cdcooper
                       ,pr_cdempres => rw_crapemp.cdempres
                       ,pr_dtdebito => vr_dtdebpfp
                       ,pr_nrseqpag => vr_nrseqpag);
       FETCH cr_totaprv INTO vr_vltotpen,vr_vltotapr;
       CLOSE cr_totaprv;

       -- Soma o total dos aprovados com os selecionados
       vr_vltotpag := NVL(vr_vltotapr,0) + NVL(vr_vltotsel,0);
       -- Soma o total dos pendentes com os selecionados
       vr_vlrtotal := NVL(vr_vltotpen,0) + NVL(vr_vltotsel,0);

       -- Se o valor limite de folha for menor que a soma dos pagamentos aprovados e selecionados
       IF NVL(rw_crapemp.vllimfol,0) < vr_vltotpag THEN
         -- Gera critica
         pr_dscritic := 'Valor limite diário de folha de pagamento atingido! ' ||
                        'Favor alterar a data de débito se deseja continuar ou solicite ao Posto de Atendimento o aumento deste valor';
         RAISE vr_exc_erro;
       END IF;
       -- Caso tenha algum lancamento com problema
       IF vr_tab_craplfp.COUNT() > 0 THEN
         -- Escrevemos a variavel de erro
         pr_dscritic := 'Os pagamentos selecionados apresentaram críticas! É necessário rever os lançamentos abaixo:';

         -- Monta documento XML
         dbms_lob.createtemporary(pr_retxml, TRUE);
         dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

         -- Insere o cabeçalho do XML
         GENE0002.pc_escreve_xml(pr_xml            => pr_retxml
                                ,pr_texto_completo => vr_xml_temp
                                ,pr_texto_novo     => '<dados dscritic="'||pr_dscritic||'" >');

         -- Criar do XML de retorno
         FOR vr_index IN 1..vr_tab_craplfp.COUNT() LOOP
           -- Grava o Corpo do XML
           GENE0002.pc_escreve_xml(pr_xml            => pr_retxml
                                  ,pr_texto_completo => vr_xml_temp
                                  ,pr_texto_novo     => '<pagto>'
                                                     || '<nrdconta>'|| ltrim(gene0002.fn_mask_conta(vr_tab_craplfp(vr_index).nrdconta)) ||'</nrdconta>'
                                                     || '<nrcpfemp>'|| gene0002.fn_mask_cpf_cnpj(vr_tab_craplfp(vr_index).nrcpfemp,1) ||'</nrcpfemp>'
                                                     || '<nmprimtl>'|| vr_tab_craplfp(vr_index).nmprimtl ||'</nmprimtl>'
                                                     || '<dscritic>'|| vr_tab_craplfp(vr_index).dscritic ||'</dscritic>'
                                                     || '</pagto>');
         END LOOP; -- vr_tab_craplfp

         -- Encerrar a tag
         GENE0002.pc_escreve_xml(pr_xml            => pr_retxml
                                ,pr_texto_completo => vr_xml_temp
                                ,pr_texto_novo     => '</dados>'
                                ,pr_fecha_xml      => TRUE);
         -- Gera critica
         RAISE vr_exc_erro;
       END IF; -- vr_tab_craplfp.COUNT() > 0

       -- Caso a  data de debito seja igual a data atual
       IF vr_dtdebpfp = pr_dtmvtolt AND pr_flvalsld = 1 THEN

         -- Leitura do calendario da cooperativa
         OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
         FETCH btch0001.cr_crapdat INTO rw_crapdat;
         CLOSE btch0001.cr_crapdat;

         -- Obtencao do saldo da conta sem o dia fechado
         EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                     pr_rw_crapdat => rw_crapdat, -- Rowtype
                                     pr_cdagenci   => 0,
                                     pr_nrdcaixa   => 0,
                                     pr_cdoperad   => 1,
                                     pr_nrdconta   => pr_nrdconta,
                                     pr_vllimcre   => rw_crapemp.vllimcre, -- ass.vllimcre
                                     pr_flgcrass   => FALSE, --> Não carregar a crapass inteira
                                     pr_tipo_busca => 'A', --> Busca da SDA do dia anterior
                                     pr_dtrefere   => rw_crapdat.dtmvtolt,
                                     pr_des_reto   => vr_des_reto,
                                     pr_tab_sald   => vr_tab_saldo,
                                     pr_tab_erro   => vr_tab_erro);
         IF vr_des_reto = 'OK' THEN
           vr_vlsddisp := vr_tab_saldo(vr_tab_saldo.LAST).vlsddisp + vr_tab_saldo(vr_tab_saldo.LAST).vllimcre;
         END IF;

         -- Se NAO houver saldo
         IF vr_vlsddisp < vr_vlrtotal THEN

           IF rw_crappfp.idsitapr = 2 THEN
              -- Gera critica
              pr_dscritic := 'Não há saldo suficiente para a operação!';
              RAISE vr_exc_erro;
           END IF;

           -- Busca o horario limite
           vr_hrlimite := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdcooper => pr_cdcooper
                                                   ,pr_cdacesso => 'FOLHAIB_HOR_LIM_SOL_EST');
           -- Se atingiu o horario permitido
           IF TO_CHAR(SYSDATE,'hh24:mi') > vr_hrlimite THEN
             -- Gera critica
             pr_dscritic := 'Não há saldo suficiente para débito de sua conta! Como o horário limite para solicitação do estouro ao Posto de Atendimento foi atingido, este pagamento deve ser agendado para outra data!';
             RAISE vr_exc_erro;
           ELSE
             -- Gera critica, porem retorna como 'OK'
             pr_dscritic := 'Não há saldo suficiente para a operação! Deseja solicitar o estouro de conta ao seu Posto de Atendimento?';
           END IF;

         END IF;

       END IF; --  vr_dtdebpfp = pr_dtmvtolt

       -- Caso tenha passado por todas as validacoes
       IF pr_des_reto = 'OK' THEN
         -- Monta documento XML
         dbms_lob.createtemporary(pr_retxml, TRUE);
         dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

         -- Insere o cabeçalho do XML
         GENE0002.pc_escreve_xml(pr_xml            => pr_retxml
                                ,pr_texto_completo => vr_xml_temp
                                ,pr_texto_novo     => '<dados>');

         -- Grava o Corpo do XML
         GENE0002.pc_escreve_xml(pr_xml            => pr_retxml
                                ,pr_texto_completo => vr_xml_temp
                                ,pr_texto_novo     => '<dtdebpag>'|| TO_CHAR(vr_dtdebpfp,'DD/MM/RRRR') ||'</dtdebpag>'
                                                   || '<vltotpag>'|| TO_CHAR(vr_vltotsel,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||'</vltotpag>'
                                                   || '<vltottar>'|| TO_CHAR(vr_vltottar,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||'</vltottar>'
                                                   || '<vlsomado>'|| TO_CHAR((vr_vltotsel + vr_vltottar),'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||'</vlsomado>'
                                                   || '<cdtarifa>'|| TO_CHAR(vr_cdtarifa) ||'</cdtarifa>'
                                                   || '<cdfaixav>'|| TO_CHAR(vr_cdfaixav) ||'</cdfaixav>');
       
         --Caso tenha mensagem retorna
         IF vr_dsmsgret IS NOT NULL AND pr_dscritic IS NULL THEN
           GENE0002.pc_escreve_xml(pr_xml            => pr_retxml
                                  ,pr_texto_completo => vr_xml_temp
                                  ,pr_texto_novo     => '<mensagem><dsmsgret> ' || vr_dsmsgret || ' </dsmsgret></mensagem>');
             
         END IF;  
       
         -- Encerrar a tag
         GENE0002.pc_escreve_xml(pr_xml            => pr_retxml
                                ,pr_texto_completo => vr_xml_temp
                                ,pr_texto_novo     => '</dados>'
                                ,pr_fecha_xml      => TRUE);
       END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_reto := 'NOK';
        -- Desfaz operacao
        ROLLBACK;
      WHEN OTHERS THEN
        -- Desfaz operacao
        ROLLBACK;
        pr_des_reto := 'NOK';
        pr_dscritic := 'Erro na rotina FOLH0002.pc_valida_pagto_ib: ' || SQLERRM;
   END pc_valida_pagto_ib;

   /* Procedure para realizar a aprovacao dos pagamentos */
   PROCEDURE pc_aprovar_pagto_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                ,pr_nrcpfapr  IN crappfp.nrcpfapr%TYPE
                                ,pr_flsolest  IN NUMBER
                                ,pr_indrowid  IN VARCHAR2
                                ,pr_des_reto OUT VARCHAR2
                                ,pr_dsalerta OUT VARCHAR2
                                ,pr_dscritic OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_aprovar_pagto_ib              Antigo:
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Jaison
   --  Data     : Julho/2015.                   Ultima atualizacao: 16/02/2016
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure para realizar a aprovacao dos pagamentos
   --
   -- Alterações: 12/11/2015 - Migracao da tarifação do sistema da CONFOL para CADTAR (Marcos-Supero)
   --
   --             26/01/2016 - Inclusão de LOG sob as operações efetuadas (marcos-Supero)
   --             16/02/2016 - Inclusao do parametro conta na chamada da
   --                          FOLH0001.fn_valor_tarifa_folha. (Jaison/Marcos)
   --
   ---------------------------------------------------------------------------------------------------------------

      -- Busca o valor da tarifa
      CURSOR cr_pfp_cfp(pr_rowid VARCHAR2) IS
         SELECT pfp.cdempres
               ,pfp.nrseqpag
               ,pfp.dtdebito
               ,pfp.qtlctpag
               ,pfp.vllctpag
               ,folh0001.fn_valor_tarifa_folha(pr_cdcooper,emp.nrdconta,emp.cdcontar,pfp.idopdebi,pfp.vllctpag) vltarifa
           FROM crapemp emp
               ,crappfp pfp
          WHERE pfp.rowid    = pr_rowid
            AND pfp.cdcooper = emp.cdcooper
            AND pfp.cdempres = emp.cdempres;
      rw_pfp_cfp cr_pfp_cfp%ROWTYPE;

      -- Busca o email da PA
      CURSOR cr_ass_age(pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE) IS
         SELECT crapass.nmprimtl
               ,crapage.dsdemail
           FROM crapage
               ,crapass
          WHERE crapass.cdcooper = pr_cdcooper
            AND crapass.nrdconta = pr_nrdconta
            AND crapage.cdcooper = crapass.cdcooper
            AND crapage.cdagenci = crapass.cdagenci;
      rw_ass_age cr_ass_age%ROWTYPE;

      -- Variaveis
      vr_indrowid GENE0002.typ_split;
      vr_rowid    VARCHAR2(50);
      vr_emaildst VARCHAR2(1000);
      vr_dtsolest crappfp.dtsolest%TYPE := SYSDATE;
      vr_idsitapr crappfp.idsitapr%TYPE;
      vr_dtdebpfp crappfp.dtdebito%TYPE;
      vr_cdempres crappfp.cdempres%TYPE;
      vr_vltarifa NUMBER := 0;
      vr_qllctpag crappfp.qtlctpag%TYPE := 0;
      vr_vllctpag crappfp.vllctpag%TYPE := 0;
      vr_hrlimite crapprm.dsvlrprm%TYPE;
      vr_dslista_pagtos VARCHAR2(4000);
      vr_nrdrowid ROWID;

      -- Variaveis Excecao
      vr_exc_erro EXCEPTION;

      -- Variaveis de Erro
      vr_dscritic   VARCHAR2(4000);

   BEGIN
      -- Inicializa as variaveis
      pr_des_reto := 'OK';
      pr_dscritic := NULL;
      pr_dsalerta := NULL;
      vr_dtdebpfp := NULL;

      -- Quebra a string contendo o rowid separado por virgula
      vr_indrowid := gene0002.fn_quebra_string(pr_string => pr_indrowid, pr_delimit => ',');

      -- Caso seja uma solicitacao de estouro
      IF pr_flsolest = 1 THEN
        vr_idsitapr := 2; -- Estouro
        vr_dtsolest := SYSDATE;
      ELSE
        vr_idsitapr := 5; -- Aprovado
        vr_dtsolest := NULL;
      END IF;

      -- Para cada registro selecionado, faremos as validacoes necessarias
      FOR vr_index IN 1..vr_indrowid.COUNT() LOOP
        -- ROWID do pagamento
        vr_rowid := vr_indrowid(vr_index);

        -- Busca o valor da tarifa e a data de debito
        OPEN  cr_pfp_cfp(pr_rowid => vr_rowid);
        FETCH cr_pfp_cfp INTO rw_pfp_cfp;
        CLOSE cr_pfp_cfp;

        -- Caso seja a primeira vez guarda a data de debito
        IF vr_dtdebpfp IS NULL THEN
          vr_dtdebpfp := rw_pfp_cfp.dtdebito;
        END IF;

        BEGIN
          -- Atualiza o pagamento
          UPDATE crappfp
             SET crappfp.idsitapr = vr_idsitapr
                ,crappfp.nrcpfapr = pr_nrcpfapr
                ,crappfp.dtsolest = vr_dtsolest
                ,crappfp.vltarapr = rw_pfp_cfp.vltarifa
           WHERE crappfp.rowid = vr_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na atualizacao da CRAPPFP: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;

        -- Acumular valores para log
        vr_cdempres := rw_pfp_cfp.cdempres;
        vr_qllctpag := vr_qllctpag + rw_pfp_cfp.qtlctpag;
        vr_vllctpag := vr_vllctpag + rw_pfp_cfp.vllctpag;
        vr_vltarifa := vr_vltarifa + rw_pfp_cfp.vltarifa * rw_pfp_cfp.qtlctpag;
        vr_dslista_pagtos := vr_dslista_pagtos || '#' || rw_pfp_cfp.nrseqpag || ',';

      END LOOP; -- vr_indrowid

      -- Caso seja uma solicitacao de estouro
      IF pr_flsolest = 1 THEN

        -- Busca o horario limite
        vr_hrlimite := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_cdacesso => 'FOLHAIB_HOR_LIM_SOL_EST');

        -- Busca o email do PA
        OPEN  cr_ass_age(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);
        FETCH cr_ass_age INTO rw_ass_age;
        CLOSE cr_ass_age;

        -- Carrega o email do PA
        vr_emaildst := rw_ass_age.dsdemail;

        -- Caso o email do PA seja nulo ou vazio
        IF vr_emaildst IS NULL OR vr_emaildst = ' ' THEN
          -- Destinatarios responsaveis pelos avisos
          vr_emaildst :=  GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdcooper => pr_cdcooper
                                                   ,pr_cdacesso => 'FOLHAIB_EMAIL_ALERT_PROC');
        END IF;

        -- Solicita envio do email
        GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => 'FOLH0001'
                                  ,pr_des_destino     => TRIM(vr_emaildst)
                                  ,pr_des_assunto     => 'Folha de Pagamento - Conta '|| pr_nrdconta ||' solicitou estouro de conta'
                                  ,pr_des_corpo       => 'Olá, o cooperado '|| pr_nrdconta ||' - '|| rw_ass_age.nmprimtl ||' solicitou estouro de sua conta para efetuar o débito da folha de pagamento de seus funcionários. ' ||
                                                         'Para efetuar a aprovação ou reprovação do mesmo, favor conectar-se a tela ESTFOL até o horário limite ' || vr_hrlimite
                                  ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);

        -- Gera o alerta de retorno
        pr_dsalerta := 'Pendência de estouro solicitada com sucesso! Lembramos que o seu Posto de Atendimento pode reprovar o estouro, sendo o ideal você entrar em contato com o mesmo até as ' || vr_hrlimite;

      ELSE

        -- Caso a  data de debito seja igual a data atual
        IF vr_dtdebpfp = pr_dtmvtolt THEN
          -- Gera alerta para pagamento na data atual
          pr_dsalerta := 'Pagamento aprovado com sucesso! Em instantes os valores serão processados!';
        ELSE
          -- Gera alerta para pagamento com data no futuro
          pr_dsalerta := 'Pagamento agendado com sucesso! Os valores serão processados conforme a programação escolhida! Lembre-se que é necessário saldo em conta no dia do débito selecionado!';
        END IF;

      END IF; -- pr_flsolest

      -- Geração do LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 996
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(3)
                          ,pr_dstransa => 'Pagto Folha efetuado por '||folh0001.fn_nmoperad_log(pr_cdcooper,pr_nrdconta,pr_nrcpfapr)
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO
                          ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      -- Adição de detalhes a nivel de item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Empresa'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => rw_pfp_cfp.cdempres);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Pagtos selecionados'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => rtrim(vr_dslista_pagtos,',')); --> Removendo a ultima virgula
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data Débito'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(vr_dtdebpfp,'dd/mm/rrrr'));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Quantidade de pagamentos selecionados'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => vr_qllctpag);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Valor dos pagamentos selecionados'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(vr_vllctpag,'fm999g999g999g990d00'));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Total da tarifa'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(vr_vltarifa,'fm999g999g999g990d00'));
      IF pr_flsolest = 1 THEN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Estouro?'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'Solicitado');
      ELSE
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Estouro?'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'Não necessário');
      END IF;

      -- Efetua Commit
      COMMIT;

   EXCEPTION
     WHEN vr_exc_erro THEN
       pr_des_reto := 'NOK';
       pr_dscritic := vr_dscritic;
       -- Desfaz operacao
       ROLLBACK;
     WHEN OTHERS THEN
       -- Desfaz operacao
       ROLLBACK;
       pr_des_reto := 'NOK';
       pr_dscritic := 'Erro na rotina FOLH0002.pc_aprovar_pagto_ib: ' || SQLERRM;
   END pc_aprovar_pagto_ib;

   /* Procedure encarregada de validar a data de credito e retorna-la */
   PROCEDURE pc_valid_dat_cred_ib(pr_cdcooper  IN PLS_INTEGER
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                 ,pr_nrdconta  IN NUMBER
                                 ,pr_cdcritic  OUT PLS_INTEGER
                                 ,pr_dscritic  OUT VARCHAR2
                                 ,pr_data_xml  OUT CLOB) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_valid_dat_cred_ib
   --  Sistema  : Genérico
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2015.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure encarregada de validar a data de credito e retorna-la
   --
   -- Alteracoes:
   ---------------------------------------------------------------------------------------------------------------
      vr_dtmvtolt0 crapdat.dtmvtolt%TYPE;
      vr_xml_data_temp VARCHAR2(32726) := '';

   BEGIN
      -- Inicializa Variaveis
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      -- Por padrao, busca o dia util
      vr_dtmvtolt0 := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper  -- Cooperativa
                                                 ,pr_dtmvtolt => pr_dtmvtolt  -- Data atual
                                                 ,pr_tipo => 'P');            -- Proximo dia
      -- Monta documento XML
      dbms_lob.createtemporary(pr_data_xml, TRUE);
      dbms_lob.open(pr_data_xml, dbms_lob.lob_readwrite);
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_data_temp
                             ,pr_texto_novo     => '<raiz>');
      gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                                ,pr_texto_completo => vr_xml_data_temp
                                ,pr_texto_novo     => '<opcao>'
                                                   || '<dtcredit>'||TO_CHAR(vr_dtmvtolt0,'DD/MM/YYYY') ||'</dtcredit>'
                                                   || '</opcao>');
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_data_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);
   EXCEPTION
      WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina FOLH0002.pc_valid_dat_cred_ib: '||SQLERRM;
   END pc_valid_dat_cred_ib;

   /* Procedure encarregada de validar e retornar a data de debito para selecao */
   PROCEDURE pc_busca_opcao_deb_ib(pr_cdcooper   IN PLS_INTEGER
                                  ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                  ,pr_nrdconta   IN NUMBER
                                  ,pr_cdcritic   OUT PLS_INTEGER
                                  ,pr_dscritic   OUT VARCHAR2
                                  ,pr_data_xml   OUT CLOB) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_busca_opcao_deb_ib
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2015.                   Ultima atualizacao: 05/07/2018
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure encarregada de validar e retornar a data de debito para selecao
   --
   -- Alteracoes: 12/11/2015 - Migracao da tarifação do sistema da CONFOL para CADTAR (Marcos-Supero)
   --
   --             16/02/2016 - Inclusao do parametro conta na chamada da
   --                          FOLH0001.fn_valor_tarifa_folha. (Jaison/Marcos)
   -- 
   --             05/07/2018 - Inclusao das tags de cdtarifa e cdfaixav no XML de saída, Prj.363 (Jean Michel)
   ---------------------------------------------------------------------------------------------------------------

      -- Verificamos se a data de credito esta correta
      CURSOR cr_valida_fer(p_cdcooper crapcop.cdcooper%TYPE
                          ,p_dtmvtolt DATE) IS
         SELECT 1
           FROM crapfer fer
          WHERE fer.cdcooper = p_cdcooper
            AND fer.dtferiad = p_dtmvtolt;
      rw_valida_fer cr_valida_fer%ROWTYPE;

      -- Busca o convenio tarifario da empresa vinculada a conta
      CURSOR cr_convenio(p_cdcooper crapcop.cdcooper%TYPE
                        ,p_nrdconta crapass.nrdconta%TYPE) IS
         SELECT emp.cdcontar||' - '||cfp.dscontar dscontar
               ,folh0001.fn_valor_tarifa_folha(p_cdcooper,emp.nrdconta,emp.cdcontar,0,emp.vllimfol) vltarid0
               ,folh0001.fn_valor_tarifa_folha(p_cdcooper,emp.nrdconta,emp.cdcontar,1,emp.vllimfol) vltarid1
               ,folh0001.fn_valor_tarifa_folha(p_cdcooper,emp.nrdconta,emp.cdcontar,2,emp.vllimfol) vltarid2
           FROM crapemp emp
               ,crapcfp cfp
          WHERE emp.cdcooper = p_cdcooper
            AND emp.nrdconta = p_nrdconta
            AND emp.cdcooper = cfp.cdcooper
            AND emp.cdcontar = cfp.cdcontar;
      rw_convenio cr_convenio%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat     btch0001.cr_crapdat%ROWTYPE;

      vr_dtmvtolt0 crapdat.dtmvtolt%TYPE;
      vr_dtmvtolt1 crapdat.dtmvtolt%TYPE;
      vr_dtmvtolt2 crapdat.dtmvtolt%TYPE;

      -- Variaveis
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      vr_fldatad1 VARCHAR(1);
      vr_fldatad2 VARCHAR(1);

      -- variaveis de excessao
      vr_erro EXCEPTION;

   BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_dscritic := 'Problemas ao recuperar a data do sistema. Favor, entre em contato com seu PA!';
        RAISE vr_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Inicializa Variaveis
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      vr_fldatad1 := 'T';
      vr_fldatad2 := 'T';

      -- Busca o convenio relacionando a
      -- empresa atraves da conta
      OPEN  cr_convenio(pr_cdcooper
                       ,pr_nrdconta);
      FETCH cr_convenio INTO rw_convenio;
      CLOSE cr_convenio;

      -- Nao podemos presseguir com a data
      -- de credito null
      IF pr_dtmvtolt IS NULL THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Data de crédito deve ser informada!';
         RAISE vr_erro;
      END IF;

      -- Nao podemos permitir data inferior
      -- ao dia atual
      IF pr_dtmvtolt < TRUNC(rw_crapdat.dtmvtolt) THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Data de crédito não pode ser anterior à data atual';
         RAISE vr_erro;
      END IF;

      -- Precisamos validar se a data de credito
      -- informada e um fim de semana
      IF TO_CHAR(pr_dtmvtolt,'D') IN (1,7) THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Data para crédito da folha deve ser dia util';
         RAISE vr_erro;
      END IF;

      -- Precisamos validar se a data de credito
      -- informada e um feriado
      OPEN cr_valida_fer(pr_cdcooper
                        ,pr_dtmvtolt);
      FETCH cr_valida_fer INTO rw_valida_fer;
      IF cr_valida_fer%FOUND THEN
         -- fecha cursor
         CLOSE cr_valida_fer;
         -- Gera critica
         pr_cdcritic := 0;
         pr_dscritic := 'Data para crédito da folha deve ser dia util';
         RAISE vr_erro;
      END IF;
      -- Apenas fecha cursor
      CLOSE cr_valida_fer;

      -- Por padrao, busca o dia util
      vr_dtmvtolt0 := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper  -- Cooperativa
                                                 ,pr_dtmvtolt => pr_dtmvtolt  -- Data atual
                                                 ,pr_tipo => 'P');            -- Proximo dia

      IF TO_CHAR(vr_dtmvtolt0,'d') = 2 THEN -- Segunda-Feira
         -- Grava a data informada desconsiderando o fim de semana
         -- Nesse caso precisamos voltar 3 dias a partir da data informada
         vr_dtmvtolt1 := vr_dtmvtolt0-3;
      ELSIF TO_CHAR(vr_dtmvtolt0,'d') NOT IN (1,2,7) THEN
         -- Grava a data informada desconsiderando o
         -- fim de semana, segunda ou terca pois ja
         -- foram tratados acima
         -- Nesse caso precisamos voltar 1 dia apenas
         vr_dtmvtolt1 := vr_dtmvtolt0-1;
      END IF;

      -- Valida a data D-1 para verificar se nao eh fim de semana ou feriado
      vr_dtmvtolt1 := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper  -- Cooperativa
                                                 ,pr_dtmvtolt => vr_dtmvtolt1 -- Data atual
                                                 ,pr_tipo => 'A');            -- Proximo dia

      -- Com a data D-1 correta, buscamos a data D-2
      vr_dtmvtolt2 := vr_dtmvtolt1-1;
      vr_dtmvtolt2 := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper  -- Cooperativa
                                                 ,pr_dtmvtolt => vr_dtmvtolt2 -- Data atual
                                                 ,pr_tipo => 'A');            -- Proximo dia

      IF vr_dtmvtolt1 < TRUNC(rw_crapdat.dtmvtolt) THEN
         vr_fldatad1 := 'F';
      END IF;

      IF vr_dtmvtolt2 < TRUNC(rw_crapdat.dtmvtolt) THEN
         vr_fldatad2 := 'F';
      END IF;

      -- Monta documento XML
      dbms_lob.createtemporary(pr_data_xml, TRUE);
      dbms_lob.open(pr_data_xml, dbms_lob.lob_readwrite);
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<raiz>');
      gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                                ,pr_texto_completo => vr_xml_pgto_temp
                                ,pr_texto_novo     => '<opcao>'
                                                   || '<dscontar>'||rw_convenio.dscontar||'</dscontar>'
                                                   || '<vltarid0>'||TO_CHAR(rw_convenio.vltarid0, 'FM999G990D00', 'NLS_NUMERIC_CHARACTERS=,.') ||'</vltarid0>'
                                                   || '<vltarid1>'||TO_CHAR(rw_convenio.vltarid1, 'FM999G990D00', 'NLS_NUMERIC_CHARACTERS=,.') ||'</vltarid1>'
                                                   || '<vltarid2>'||TO_CHAR(rw_convenio.vltarid2, 'FM999G990D00', 'NLS_NUMERIC_CHARACTERS=,.') ||'</vltarid2>'
                                                   || '<dtmvtolt0>'||TO_CHAR(vr_dtmvtolt0,'DD/MM/YYYY') ||'</dtmvtolt0>'
                                                   || '<dtmvtolt1>'||TO_CHAR(vr_dtmvtolt1,'DD/MM/YYYY') ||'</dtmvtolt1>'
                                                   || '<dtmvtolt2>'||TO_CHAR(vr_dtmvtolt2,'DD/MM/YYYY') ||'</dtmvtolt2>'
                                                   || '<fldatad1>'||vr_fldatad1||'</fldatad1>'
                                                   || '<fldatad2>'||vr_fldatad2||'</fldatad2>'
                                                   || '<cdtarifa0>' || gene0002.fn_busca_entrada(1,FOLH0001.fn_cdtarifa_cdfaixav(pr_cdocorre => 0),',') || '</cdtarifa0>'
                                                   || '<cdfaixav0>' || gene0002.fn_busca_entrada(2,FOLH0001.fn_cdtarifa_cdfaixav(pr_cdocorre => 0),',') || '</cdfaixav0>'
                                                   || '<cdtarifa1>' || gene0002.fn_busca_entrada(1,FOLH0001.fn_cdtarifa_cdfaixav(pr_cdocorre => 1),',') || '</cdtarifa1>'
                                                   || '<cdfaixav1>' || gene0002.fn_busca_entrada(2,FOLH0001.fn_cdtarifa_cdfaixav(pr_cdocorre => 1),',') || '</cdfaixav1>'
                                                   || '<cdtarifa2>' || gene0002.fn_busca_entrada(1,FOLH0001.fn_cdtarifa_cdfaixav(pr_cdocorre => 2),',') || '</cdtarifa2>'
                                                   || '<cdfaixav2>' || gene0002.fn_busca_entrada(2,FOLH0001.fn_cdtarifa_cdfaixav(pr_cdocorre => 2),',') || '</cdfaixav2>'
                                                   || '</opcao>');
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

   EXCEPTION
      WHEN vr_erro THEN
         -- Retorno do erro
         NULL;
      WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina FOLH0002.pc_busca_opcao_deb_ib: '||SQLERRM;
   END pc_busca_opcao_deb_ib;

   /* Procedure encarregada de listar os pagamentos para aprovacao selecionado  */
   PROCEDURE pc_lista_pgto_pend_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                  ,pr_nrdconta   IN NUMBER
                                  ,pr_dsrowpfp   IN VARCHAR2
                                  ,pr_xmlpagto   OUT CLOB
                                  ,pr_cdcritic   OUT PLS_INTEGER
                                  ,pr_dscritic   OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_lista_pgto_pend_ib
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2015.                   Ultima atualizacao: 05/07/2018
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure encarregada de listar os pagamentos para aprovacao selecionado
   --
   -- Alteracoes: 27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
   --
   --             11/08/2016 - Retirada a chamada da rotina pc_valida_lancto_folha, devido a mesma
   --                          não estar sendo necessária e ajuste no controle de erro de forma que 
   --                          as datas sejam retornadas mesmo no caso de erros
   --
   --             05/07/2018 - Inclusao das tags de cdtarifa e cdfaixav no XML de saída, Prj.363 (Jean Michel)
   --
   ---------------------------------------------------------------------------------------------------------------
      -- Busca todos os dados ja cadastrados
      CURSOR cr_crappfp(p_dsrowpfp IN VARCHAR2) IS
         SELECT pfp.cdcooper
               ,pfp.cdempres
               ,pfp.nrseqpag
               ,pfp.dtcredit
               ,pfp.dtdebito
               ,pfp.idopdebi
               ,pfp.qtregpag
               ,pfp.vllctpag
               ,pfp.flgrvsal
               ,lfp.nrseqlfp
               ,lfp.cdorigem
               ,lfp.nrdconta
               ,lfp.nrcpfemp
               ,lfp.idtpcont
               ,pfp.vltarapr
           FROM crappfp pfp
               ,craplfp lfp
          WHERE pfp.rowid    = p_dsrowpfp
            AND pfp.cdcooper = lfp.cdcooper
            AND pfp.cdempres = lfp.cdempres
            AND pfp.nrseqpag = lfp.nrseqpag;
      rw_crappfp cr_crappfp%ROWTYPE;

      -- Busca todos os lancamentos ja cadastrados
      CURSOR cr_craplfp(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_cdempres crapemp.cdempres%TYPE
                       ,p_nrseqpag craplfp.nrseqpag%TYPE) IS
         SELECT lfp.cdcooper
               ,lfp.cdempres
               ,lfp.nrdconta
               ,lfp.nrcpfemp
               ,lfp.cdorigem
               ,lfp.vllancto
               ,lfp.idtpcont
               ,DECODE(efp.idtpcont,'C',(SELECT ass.nmprimtl
                                           FROM crapass ass
                                          WHERE ass.cdcooper = efp.cdcooper
                                            AND ass.nrdconta = efp.nrdconta)
                                   ,'T',(SELECT ccs.nmfuncio
                                           FROM crapccs ccs
                                          WHERE ccs.cdcooper = efp.cdcooper
                                            AND ccs.nrdconta = efp.nrdconta)) nmprimtl
               ,lfp.rowid
               ,lfp.nrseqpag
           FROM craplfp lfp
               ,crapefp efp
          WHERE lfp.cdcooper = p_cdcooper
            AND lfp.cdempres = p_cdempres
            AND lfp.nrseqpag = p_nrseqpag
            AND lfp.cdcooper = efp.cdcooper(+)
            AND lfp.cdempres = efp.cdempres(+)
            AND lfp.nrdconta = efp.nrdconta(+)
            AND lfp.nrcpfemp = efp.nrcpfemp(+)
          ORDER BY nmprimtl;

      -- Buscar informações do associado
    CURSOR cr_crapass(pr_cdcooper  crapass.cdcooper%TYPE
                     ,pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT t.nmprimtl
        FROM crapass t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;

    -- Buscar contas de funcionarios optaram pela transferencia do salario para outra instituicao financeira
    CURSOR cr_crapccs(pr_cdcooper  crapass.cdcooper%TYPE
                     ,pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT ccs.nmfuncio
        FROM crapccs ccs
       WHERE ccs.cdcooper = pr_cdcooper
         AND ccs.nrdconta = pr_nrdconta;

      vr_nmprimtl VARCHAR2(1000);
      vr_dsalert  VARCHAR2(1000);

      vr_xml_orig_temp VARCHAR2(32767);
      --vr_erro EXCEPTION;

      vr_cdtarifa VARCHAR2(10);     
      vr_cdfaixav VARCHAR2(10);
      vr_dstarfai VARCHAR2(20);
   BEGIN
      -- Inicializa variavel
      pr_cdcritic := NULL;
      pr_dscritic := NULL;

      -- Busca as informacoes de pagamentos
      OPEN cr_crappfp(pr_dsrowpfp);
      FETCH cr_crappfp INTO rw_crappfp;
      CLOSE cr_crappfp;

      vr_dstarfai := FOLH0001.fn_cdtarifa_cdfaixav(pr_cdocorre => rw_crappfp.idopdebi);
      vr_cdtarifa := gene0002.fn_busca_entrada(1,vr_dstarfai,',');
      vr_cdfaixav := gene0002.fn_busca_entrada(2,vr_dstarfai,',');

      -- Monta documento XML
      dbms_lob.createtemporary(pr_xmlpagto, TRUE);
      dbms_lob.open(pr_xmlpagto, dbms_lob.lob_readwrite);
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_xmlpagto
                             ,pr_texto_completo => vr_xml_orig_temp
                             ,pr_texto_novo     => '<dados dtcredit="'||TO_CHAR(rw_crappfp.dtcredit,'DD/MM/RRRR')||'" dtdebito="'||TO_CHAR(rw_crappfp.dtdebito,'DD/MM/RRRR')||'" idopdebi="'||rw_crappfp.idopdebi||'" qtregpag="'||rw_crappfp.qtregpag||'" vllctpag="'||TO_CHAR(rw_crappfp.vllctpag,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')||'" flgrvsal="'||rw_crappfp.flgrvsal||'" vltarapr="'||rw_crappfp.vltarapr||'" cdtarifa="'||TO_CHAR(vr_cdtarifa)||'" cdfaixav="'||TO_CHAR(vr_cdfaixav)||'" >');

      FOR rw_craplfp IN cr_craplfp(rw_crappfp.cdcooper
                                    ,rw_crappfp.cdempres
                                    ,rw_crappfp.nrseqpag) LOOP

         -- Limpar variável
         vr_nmprimtl := NULL;
         
         -- Buscar o nome conforme o tipo da conta, antes era retornado pela pc_valida_lancto_folha
         -- Conforme o tipo de conta 
         IF rw_craplfp.idtpcont = 'C' THEN -- Para associados

           -- Buscar dados da CRAPASS
           OPEN  cr_crapass(rw_craplfp.cdcooper, rw_craplfp.nrdconta);
           FETCH cr_crapass INTO vr_nmprimtl;
           CLOSE cr_crapass;
         
         ELSIF rw_craplfp.idtpcont = 'T' THEN -- Para CTASAL

           -- Buscar as informações de CTASAL
           OPEN  cr_crapccs(rw_craplfp.cdcooper, rw_craplfp.nrdconta);
           FETCH cr_crapccs INTO vr_nmprimtl;
           CLOSE cr_crapccs;
           
         END IF;

         /**************************************
         ** Renato Darosci - Supero
         ** 11/08/2015
         **
         ** Retirado a chamada da validação pois a variável de retorno de críticas
         ** não está sendo testada, dessa forma a chamada da validação não se faz
         ** necessária. Outro motivo é que esta validação é feita no momento da 
         ** validação do pagamento.         
         **
         -- Efetua a validação do lançamento
         FOLH0001.pc_valida_lancto_folha(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_craplfp.nrdconta
                                        ,pr_nrcpfcgc => rw_craplfp.nrcpfemp
                                        ,pr_idtpcont => rw_craplfp.idtpcont
                                        ,pr_nmprimtl => vr_nmprimtl
                                        ,pr_dsalerta => vr_dsalert
                                        ,pr_dscritic => pr_dscritic);

         -- Se ocorrer erro de processamento
         IF pr_dscritic IS NOT NULL THEN
            pr_cdcritic := 0;
            RAISE vr_erro; -- Finaliza o programa
         END IF;
         **************************************/

         -- Grava o Corpo do XML
         gene0002.pc_escreve_xml(pr_xml            => pr_xmlpagto
                                ,pr_texto_completo => vr_xml_orig_temp
                                ,pr_texto_novo     => '<lanctos>'
                                                   || '<cdcooper>'||rw_craplfp.cdcooper||'</cdcooper>'
                                                   || '<cdempres>'||rw_craplfp.cdempres||'</cdempres>'
                                                   || '<nrdconta>'||TRIM(gene0002.fn_mask_conta(rw_craplfp.nrdconta))||'</nrdconta>'
                                                   || '<nrcpfemp>'||rw_craplfp.nrcpfemp||'</nrcpfemp>'
                                                   || '<cdorigem>'||rw_craplfp.cdorigem||'</cdorigem>'
                                                   || '<vllancto>'||TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')||'</vllancto>'
                                                   || '<dsrowlfp>'||rw_craplfp.rowid||'</dsrowlfp>'
                                                   || '<nmprimtl>'||vr_nmprimtl||'</nmprimtl>'
                                                   || '<idtpcont>'||rw_craplfp.idtpcont||'</idtpcont>'
                                                   || '</lanctos>');
      END LOOP;

      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_xmlpagto
                             ,pr_texto_completo => vr_xml_orig_temp
                             ,pr_texto_novo     => '</dados>'
                             ,pr_fecha_xml      => TRUE);

   EXCEPTION
      /*WHEN vr_erro THEN    -- TRATAMENTO NÃO SERÁ MAIS UTILIZADO
         -- Apenas retorna o erro
         NULL;*/
      WHEN OTHERS THEN
        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => pr_xmlpagto
                               ,pr_texto_completo => vr_xml_orig_temp
                               ,pr_texto_novo     => '</dados>'
                               ,pr_fecha_xml      => TRUE);  
      
      
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina FOLH0002.pc_lista_pgto_pend_ib: '||SQLERRM;
   END pc_lista_pgto_pend_ib;


   /* Eliminar um pagamento convencional no IB */
   PROCEDURE pc_exclui_lancto_pfp_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                    ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                    ,pr_nrdconta   IN NUMBER
                                    ,pr_rowidlfp   IN VARCHAR2
                                    ,pr_cdcritic   OUT PLS_INTEGER
                                    ,pr_dscritic   OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_exclui_lancto_pfp_ib
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2015.                   Ultima atualizacao: 27/01/2016
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Eliminar um pagamento convencional no IB
   --
   -- Alteracoes: 27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
   ---------------------------------------------------------------------------------------------------------------

      -- Buscar a craplfp da empresa
      CURSOR cr_craplfp(p_dsrowlfp IN VARCHAR2) IS
        SELECT lfp.cdcooper
              ,lfp.cdempres
              ,lfp.nrdconta
              ,lfp.nrseqpag
              ,lfp.nrseqlfp
              ,lfp.vllancto
          FROM craplfp lfp
         WHERE lfp.rowid = p_dsrowlfp;
      rw_craplfp cr_craplfp%ROWTYPE;

      vr_erro EXCEPTION;

   BEGIN
      -- Inicializa Variavel
      pr_cdcritic := NULL;
      pr_dscritic := NULL;

      -- Buscar sequencial dos lancamentos
      OPEN  cr_craplfp(pr_rowidlfp);
      FETCH cr_craplfp INTO rw_craplfp;
      CLOSE cr_craplfp;

      BEGIN
        -- Inserir a informação da CRAPPFP
        UPDATE crappfp pfp
           SET pfp.dtmvtolt = pr_dtmvtolt                        -- dtmvtolt
              ,pfp.qtlctpag = pfp.qtlctpag - 1                   -- qtlctpag
              ,pfp.qtregpag = pfp.qtregpag - 1                   -- qtregpag
              ,pfp.vllctpag = pfp.vllctpag - rw_craplfp.vllancto -- vllctpag
        WHERE pfp.cdcooper = rw_craplfp.cdcooper
          AND pfp.cdempres = rw_craplfp.cdempres
          AND pfp.nrseqpag = rw_craplfp.nrseqpag;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar CRAPPFP: '||SQLERRM;
          RAISE vr_erro;
      END;

      BEGIN
        -- Inserir a informação da CRAPPFP
        DELETE craplfp lfp
        WHERE lfp.rowid = pr_rowidlfp;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar CRAPPFP: '||SQLERRM;
          RAISE vr_erro;
      END;

      -- Efetua Commit
      COMMIT;

   EXCEPTION
      WHEN vr_erro THEN
          ROLLBACK; -- Retorna a critica ja informada
      WHEN OTHERS THEN
         ROLLBACK;
         pr_cdcritic := 0;
         pr_dscritic := 'Erro ao montar XML. Rotina FOLH.pc_exclui_lancto_pfp_ib: '||SQLERRM;
   END pc_exclui_lancto_pfp_ib;

   /* Listar as origens para pagamento convencional */
   PROCEDURE pc_lista_origem_pagto_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                     ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                     ,pr_nrdconta   IN NUMBER
                                     ,pr_data_xml   OUT CLOB
                                     ,pr_cdcritic   OUT PLS_INTEGER
                                     ,pr_dscritic   OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_lista_origem_pagto_ib
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2015.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Listar as origens para pagamento convencional
   --
   -- Alteracoes:
   ---------------------------------------------------------------------------------------------------------------

      -- Buscamos os dados da empresa
      CURSOR cr_crapemp(p_cdcooper crapemp.cdcooper%TYPE
                       ,p_nrdconta crapemp.nrdconta%TYPE) IS
        SELECT UPPER(emp.idtpempr) idtpempr
          FROM crapemp emp
         WHERE emp.cdcooper = p_cdcooper
           AND emp.nrdconta = p_nrdconta;
      rw_crapemp cr_crapemp%ROWTYPE;

      -- Buscamos as origens de pagamentos referente a cooperativa
      CURSOR cr_crapofp_cop (p_cdcooper crapemp.cdcooper%TYPE) IS
         SELECT ofp.cdorigem
               ,ofp.dsorigem
               ,ofp.idvarmes
           FROM crapofp ofp
          WHERE ofp.cdcooper = p_cdcooper
            AND ofp.cdhscrcp > 0;

      -- Buscamos as origens de pagamentos referente a outras empresas
      CURSOR cr_crapofp_emp (p_cdcooper crapemp.cdcooper%TYPE) IS
         SELECT ofp.cdorigem
               ,ofp.dsorigem
               ,ofp.idvarmes
           FROM crapofp ofp
          WHERE ofp.cdcooper = p_cdcooper
            AND ofp.cdhiscre > 0;

      vr_xml_orig_temp VARCHAR2(32767);

   BEGIN
      -- Inicia variaveis
      pr_cdcritic  := NULL;
      pr_dscritic  := NULL;

      -- Verificamos se a conta e referente a
      -- empresa ou cooperativa
      OPEN cr_crapemp(pr_cdcooper
                     ,pr_nrdconta);
      FETCH cr_crapemp INTO rw_crapemp;
      CLOSE cr_crapemp;

      -- Monta documento XML
      dbms_lob.createtemporary(pr_data_xml, TRUE);
      dbms_lob.open(pr_data_xml, dbms_lob.lob_readwrite);
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_orig_temp
                             ,pr_texto_novo     => '<raiz>');
      -- Se for cooperativa
      IF rw_crapemp.idtpempr = 'C' THEN
         FOR rw_crapofp IN cr_crapofp_cop(pr_cdcooper) LOOP
            -- Grava o Corpo do XML
            gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                                   ,pr_texto_completo => vr_xml_orig_temp
                                   ,pr_texto_novo     => '<origens>'
                                                      || '<dsorigem>'||rw_crapofp.dsorigem||'</dsorigem>'
                                                      || '<cdorigem>'||rw_crapofp.cdorigem||'</cdorigem>'
                                                      || '<idvarmes>'||rw_crapofp.idvarmes||'</idvarmes>'
                                                      || '</origens>');
         END LOOP;
      ELSE -- Outras empresas
         FOR rw_crapofp IN cr_crapofp_emp(pr_cdcooper) LOOP
            -- Grava o Corpo do XML
            gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                                   ,pr_texto_completo => vr_xml_orig_temp
                                   ,pr_texto_novo     => '<origens>'
                                                      || '<dsorigem>'||rw_crapofp.dsorigem||'</dsorigem>'
                                                      || '<cdorigem>'||rw_crapofp.cdorigem||'</cdorigem>'
                                                      || '<idvarmes>'||rw_crapofp.idvarmes||'</idvarmes>'
                                                      || '</origens>');
         END LOOP;
      END IF;

      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_orig_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

   EXCEPTION
      WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina FOLH0002.pc_lista_origem_pagto_ib: '||SQLERRM;
   END;

   /* Procedure encarregada de enviar os pagamentos para aprovacao */
   PROCEDURE pc_envia_pagto_apr_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE
                                  ,pr_nrdconta   IN NUMBER
                                  ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE
                                  ,pr_dsrowpfp   IN VARCHAR2
                                  ,pr_idopdebi   IN NUMBER
                                  ,pr_dtcredit   IN DATE
                                  ,pr_dtdebito   IN DATE
                                  ,pr_vltarapr   IN NUMBER
                                  ,pr_gravarpg   IN NUMBER
                                  ,pr_dsdirarq   IN VARCHAR2
                                  ,pr_dsarquiv   IN VARCHAR2
                                  ,pr_dsdspscp   IN NUMBER
                                  ,pr_cdcritic   OUT PLS_INTEGER
                                  ,pr_dscritic   OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_envia_pagto_apr_ib
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2015.                   Ultima atualizacao: 15/02/2019
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure encarregada de enviar os pagamentos para aprovacao
   --
   -- Alteracoes: 27/10/2015 - Remoção de campos não utilizados (Marcos-Supero)
   --
   --             26/01/2016 - Inclusão de log sob as operacções efetuadas (Marcos-Supero)
   --
   --             27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
   --
   --             15/02/2019 - Incluir rm após o processamento do arquivo (Lucas Ranghetti #PRB0040468)
   ---------------------------------------------------------------------------------------------------------------

      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;  
    
      -- Busca empresa cadastrada pelo usuario conectado
      CURSOR cr_crapemp(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_nrdconta crapemp.nrdconta%TYPE) IS
         SELECT emp.cdempres
               ,emp.idtpempr
           FROM crapemp emp
          WHERE emp.cdcooper = p_cdcooper
            AND emp.nrdconta = p_nrdconta;
      rw_crapemp cr_crapemp%ROWTYPE;

      -- Busca as origens de pagamentos
      CURSOR cr_crapofp(p_cdcooper NUMBER
                       ,p_cdorigem crapofp.cdorigem%TYPE) IS
         SELECT ofp.cdorigem
               ,ofp.dsorigem
               ,ofp.idvarmes
           FROM crapofp ofp
          WHERE ofp.cdcooper = p_cdcooper
            AND ofp.cdorigem = p_cdorigem;
      rw_crapofp cr_crapofp%ROWTYPE;

      -- Valida se o funcionarios esta previamente cadastrado a empresa
      CURSOR cr_crapefp(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_cdempres crapemp.cdempres%TYPE
                       ,p_nrdconta crapefp.nrdconta%TYPE
                       ,p_nrcpfemp crapefp.nrcpfemp%TYPE) IS
         SELECT efp.nrdconta
           FROM crapefp efp
          WHERE efp.cdcooper = p_cdcooper
            AND efp.cdempres = p_cdempres
            AND efp.nrdconta = p_nrdconta
            AND efp.nrcpfemp = p_nrcpfemp;
      rw_crapefp cr_crapefp%ROWTYPE;

      -- Buscar o código do próximo crappfp para a empresa
      CURSOR cr_nrseqpag(pr_cdcooper  CRAPPFP.cdcooper%TYPE
                        ,pr_cdempres  CRAPPFP.CDEMPRES%TYPE) IS
        SELECT NVL(MAX(pfp.nrseqpag),0) + 1 nrseqpag
          FROM crappfp pfp
         WHERE pfp.cdcooper = pr_cdcooper
           AND pfp.cdempres = pr_cdempres;

      -- Buscar o código do próximo crappfp para a empresa
      CURSOR cr_nrseqpfp(p_dsrowpfp IN VARCHAR2) IS
        SELECT NVL(pfp.nrseqpag,0) nrseqpag
              ,idopdebi
              ,dtdebito
              ,dtcredit
              ,qtlctpag
              ,qtregpag
              ,vllctpag
          FROM crappfp pfp
         WHERE pfp.rowid = p_dsrowpfp;

      -- Buscar o código do próximo craplfp
      CURSOR cr_nrseqlfp(p_cdcooper  crappfp.cdcooper%TYPE
                        ,p_cdempres  crappfp.cdempres%TYPE
                        ,p_nrseqpag  craplfp.nrseqpag%TYPE) IS
        SELECT NVL(MAX(lfp.nrseqlfp),0) + 1 nrseqlfp
          FROM craplfp lfp
         WHERE lfp.cdcooper = p_cdcooper
           AND lfp.cdempres = p_cdempres
           AND lfp.nrseqpag = p_nrseqpag;

      -- Buscar valor anterior de origem e valor
      CURSOR cr_craplfp_old(pr_rowid IN ROWID) IS
        SELECT nrseqlfp
              ,cdorigem
              ,vllancto
          FROM craplfp
         WHERE ROWID = pr_rowid;
      vr_cdorigem_old craplfp.cdorigem%TYPE;
      vr_vllancto_old craplfp.vllancto%TYPE;

      -- Validacao de Origens duplicadas
      CURSOR cr_valida_ori(p_cdcooper crapcop.cdcooper%TYPE
                          ,p_cdempres crapemp.cdempres%TYPE
                          ,p_dtcredit crapdat.dtmvtolt%TYPE
                          ,p_nrdconta NUMBER
                          ,p_cdorigem VARCHAR2
                          ,p_rowid    VARCHAR2) IS
         SELECT lfp.nrdconta
               ,lfp.cdorigem
           FROM crappfp pfp
               ,craplfp lfp
          WHERE pfp.cdcooper = lfp.cdcooper
            AND pfp.cdempres = lfp.cdempres
            AND pfp.nrseqpag = lfp.nrseqpag
            AND lfp.cdcooper = p_cdcooper
            AND lfp.cdempres = p_cdempres
            AND lfp.nrdconta = p_nrdconta
            AND lfp.cdorigem = p_cdorigem
            AND TRUNC(pfp.dtcredit,'MM') = TRUNC(p_dtcredit,'MM')
            AND (pfp.rowid <> p_rowid OR
                p_rowid IS NULL);
      rw_valida_ori cr_valida_ori%ROWTYPE;

    -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
    -- Buscar Banco da transferência da conta
    CURSOR cr_craplcs(pr_cdcooper craplcs.cdcooper%TYPE
                     ,pr_nrdconta craplcs.nrdconta%TYPE
                     ,pr_cdempres crapccs.cdempres%TYPE) IS
      SELECT b.cdbantrf
        FROM craplcs a
            ,crapccs b
       WHERE b.cdcooper  = a.cdcooper
         AND b.nrdconta  = a.nrdconta
         AND b.cdempres  = pr_cdempres
         AND a.cdcooper  = pr_cdcooper
         AND a.nrdconta  = pr_nrdconta
         AND a.dtmvtolt  = TRUNC(SYSDATE)
         AND a.cdhistor IN(560,561,gene0001.fn_param_sistema('CRED',pr_cdcooper,'FOLHAIB_HIS_CRE_TECSAL'))
         AND a.flgenvio  = 0;
    rw_craplcs cr_craplcs%ROWTYPE;
  
      -- Variaveis
      vr_tab_origem typ_tab_origem;
      vr_idx        VARCHAR2(20);
      vr_idx_pgto   PLS_INTEGER;
      vr_tab_pgto   FOLH0002.typ_tab_pgto;
      vr_nrseqpag   crappfp.nrseqpag%TYPE;
      vr_nrseqlfp   craplfp.nrseqlfp%TYPE;
      vr_qtlctpag   crappfp.qtlctpag%TYPE;
      vr_qtregpag   crappfp.qtregpag%TYPE;
      vr_vllctpag   crappfp.vllctpag%TYPE;
      vr_nmprimtl   crapass.nmprimtl%TYPE;
      vr_dsdireto   VARCHAR(32767);
      vr_idtpcont   VARCHAR2(1);
      vr_indvalid   VARCHAR2(1);
    vr_inestcri   NUMBER;         -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
    vr_idsitlct   VARCHAR2(1);    -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
    vr_dsobslct   VARCHAR2(1000); -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
    vr_clobxmlc   CLOB;           -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019

      -- Variáveis para tratamento do XML
      vr_lenght      NUMBER;
      vr_qtfilhos    NUMBER;
      vr_node_name   VARCHAR2(100);
      vr_xmltype     sys.xmltype;
      vr_xmlpagto    CLOB;
      vr_element     XMLDOM.DOMElement;
      vr_nodenames   XMLDOM.DOMNamedNodeMap;
      vr_node_list   xmldom.DOMNodeList;
      vr_parser      xmlparser.Parser;
      vr_doc         xmldom.DOMDocument;
      vr_item_node   xmldom.DOMNode;
      vr_typ_said    VARCHAR2(50); -- Critica

      -- Cursor com os dados para insert
      rw_craplfp     craplfp%ROWTYPE;

      -- Variaveis para LOG
      vr_nrdrowid     ROWID;
      vr_neseqlfp_old craplfp.nrseqlfp%TYPE;
      vr_idopdebi_old crappfp.idopdebi%TYPE;
      vr_dtdebito_old crappfp.dtdebito%TYPE;
      vr_dtcredit_old crappfp.dtcredit%TYPE;
      vr_qtlctpag_old crappfp.qtlctpag%TYPE;
      vr_qtregpag_old crappfp.qtregpag%TYPE;
      vr_vllctpag_old crappfp.vllctpag%TYPE;

      -- Variavel de excecao
      vr_erro EXCEPTION;
      vr_dsalert     VARCHAR2(500); -- Critica
      vr_des_erro     VARCHAR2(500); -- Critica
      vr_des_reto VARCHAR2(3);

   BEGIN
      -- Inicializa Variaveis
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      vr_idx_pgto := 0;
      vr_qtlctpag := 0;
      vr_qtregpag := 0;
      vr_vllctpag := 0;
      vr_indvalid := 'N';
      vr_tab_pgto.DELETE;
      vr_tab_origem.DELETE;

      --> Verificar cooperativa
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);    
      FETCH cr_crapcop INTO rw_crapcop;
        
      --> verificar se encontra registro
      IF cr_crapcop%NOTFOUND THEN      
        CLOSE cr_crapcop;    
          
        pr_dscritic := 'Cooperativa de destino nao cadastrada.';      
        RAISE vr_erro;      
      ELSE
        CLOSE cr_crapcop;
      END IF;       

      IF pr_dsdspscp = 0 THEN -- Diretorio de upload do gnusites
      -- Busca o diretório do upload do arquivo
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'upload');

      -- Realizar a cópia do arquivo
      GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||pr_dsdirarq||pr_dsarquiv||' S'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_des_erro);
      -- Testar erro
      IF vr_typ_said = 'ERR' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        pr_dscritic := 'Erro no arquivo: ' || vr_des_erro;
        RAISE vr_erro;
      END IF;
      ELSE
        vr_dsdireto := gene0001.fn_diretorio('C',0)                                ||
                       gene0001.fn_param_sistema('CRED',0,'PATH_DOWNLOAD_ARQUIVO') ||
                       '/'                                                         ||
                       rw_crapcop.dsdircop                                         ||
                       '/upload';
      END IF;        

      -- Se não existir o arquivo
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||pr_dsarquiv) THEN
        -- Retorna erro pois em situação de insert deve vir dados
         pr_dscritic := 'Problema com o envio das informacoes (Arquivo nao recebido). Favor, entre em contato com seu PA!';
         RAISE vr_erro;
      END IF;

      -- Ler o arquivo e gravar o mesmo no CLOB
      BEGIN
        vr_xmlpagto := GENE0002.fn_arq_para_clob(pr_caminho => vr_dsdireto, pr_arquivo => pr_dsarquiv);
      EXCEPTION
        WHEN OTHERS THEN
          -- Retorna erro pois em situação de insert deve vir dados
          pr_dscritic := 'Problema com o envio das informacoes (XML invalido). Favor, entre em contato com seu PA!';
          RAISE vr_erro;
      END;

      -- Excluir o arquivo, pois desse ponto em diante irá trabalhar com o registro
      -- de memória. Em caso de erros o programa abortará e o usuário irá realizar
      -- novamente o envio do arquivo
      GENE0001.pc_OScommand_Shell('rm ' || vr_dsdireto || '/' || pr_dsarquiv);

      -- Se não vieram dados no XML
      IF LENGTH(vr_xmlpagto) <= 0 THEN
         -- Retorna erro pois em situação de insert deve vir dados
         pr_dscritic := 'Problema com o envio das informacoes (Arquivo vazio). Favor, entre em contato com seu PA!';
         RAISE vr_erro;
      END IF;

      -- Busca as informacoes da empresa atraves da conta
      OPEN cr_crapemp(pr_cdcooper
                     ,pr_nrdconta);
      FETCH cr_crapemp INTO rw_crapemp;
      -- Se nao encontrar
      IF cr_crapemp%NOTFOUND THEN
         -- Gera critica
         CLOSE cr_crapemp;
         pr_cdcritic := 0;
         pr_dscritic := 'Não foi localizado a empresa com a conta: '||pr_nrdconta;
         RAISE vr_erro;
      END IF;
      -- Apenas fecha cursor
      CLOSE cr_crapemp;

      -- Leitura de pagamentos recebidos via XML
      vr_xmltype := XMLType.createxml(vr_xmlpagto);
      -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
      vr_parser := xmlparser.newParser;
      xmlparser.parseClob(vr_parser,vr_xmltype.getClobVal());
      vr_doc    := xmlparser.getDocument(vr_parser);
      xmlparser.freeParser(vr_parser);
      -- Faz o get de toda a lista de elementos
      vr_node_list := xmldom.getElementsByTagName(vr_doc, '*');
      vr_lenght := xmldom.getLength(vr_node_list);

      BEGIN
         -- Percorrer os elementos
         FOR i IN 0..vr_lenght-1 LOOP
            -- Pega o item
            vr_item_node := xmldom.item(vr_node_list, i);
            -- Captura o nome do nodo
            vr_node_name := xmldom.getNodeName(vr_item_node);
            -- Verifica qual nodo esta sendo lido
            IF vr_node_name IN ('pagamentos') THEN
               -- Limpar variáveis
               vr_indvalid := 'N';
               -- Captura o elemento do nodo
               vr_element := xmldom.makeElement(vr_item_node);
               -- Todos os atributos do nodo
               vr_nodenames := xmldom.getAttributes(vr_item_node);

               -- Se encontrar atributos
               IF (NOT xmldom.isNull(vr_nodenames)) THEN
                  -- Ler a quantidade de atributos
                  vr_qtfilhos := xmldom.getLength(vr_nodenames);

                  -- Percorrer os atributos
                  FOR i IN 0..vr_qtfilhos-1 loop
                     vr_item_node := xmldom.item(vr_nodenames, i);

                     -- Verifica o atributo conforme o nome
                     IF LOWER(xmldom.getNodeName(vr_item_node)) = 'indvalid' THEN
                        vr_indvalid := xmldom.getNodeValue(vr_item_node);
                     END IF;

                  END LOOP;

               END IF;
               CONTINUE; -- Descer para o próximo filho
            ELSIF vr_node_name IN ('pagamento') THEN
               CONTINUE;
            ELSIF vr_node_name = 'nrdconta' THEN
               -- Inicia o INDEX pelo nome da TELA
               vr_idx_pgto := vr_idx_pgto + 1;
               vr_tab_pgto(vr_idx_pgto).nrdconta := TO_NUMBER(REPLACE(TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))),'.',''));
               vr_tab_pgto(vr_idx_pgto).cdempres := rw_crapemp.cdempres;
               CONTINUE;
            ELSIF vr_node_name = 'cdorigem' THEN
               vr_tab_pgto(vr_idx_pgto).cdorigem := TRIM(LPAD(TO_NUMBER(TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)))),2,'0'));
               CONTINUE;
            ELSIF vr_node_name = 'vllctpag' THEN
               vr_tab_pgto(vr_idx_pgto).vllctpag := TO_NUMBER(TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))))/100;
               CONTINUE;
            ELSIF vr_node_name = 'nrcpfemp' THEN
               vr_tab_pgto(vr_idx_pgto).nrcpfemp := TO_NUMBER(REPLACE(REPLACE(TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))),'.',''),'-',''));
               CONTINUE;
            ELSIF vr_node_name = 'nrcpfemp' THEN
               vr_tab_pgto(vr_idx_pgto).nrcpfemp := TO_NUMBER(REPLACE(REPLACE(TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))),'.',''),'-',''));
               CONTINUE;
            ELSIF vr_node_name = 'idtpcont' THEN
               vr_tab_pgto(vr_idx_pgto).idtpcont := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
               CONTINUE;
            ELSIF vr_node_name = 'rowidlfp' THEN
               vr_tab_pgto(vr_idx_pgto).rowidlfp := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
               CONTINUE;
            ELSE
               CONTINUE; -- Descer para o próximo filho
            END IF;
         END LOOP;

      EXCEPTION
         WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := ' Erro na leitura do XML. Rotina pc_envia_pagto_apr_ib: '||SQLERRM;
            RAISE vr_erro;
      END;

      -- Apos validarmos as datas de credito e debito,
      -- Precisamos validar todos os registros envidados
      -- para aprovacao
      FOR vr_idx_pgto IN vr_tab_pgto.first..vr_tab_pgto.last LOOP

         -- Validamos se a origem de pagamento esta cadastrada
         OPEN cr_crapofp(pr_cdcooper
                        ,vr_tab_pgto(vr_idx_pgto).cdorigem);
         FETCH cr_crapofp INTO rw_crapofp;
         -- Se nao encontrar
         IF cr_crapofp%NOTFOUND THEN
            -- Gera critica
            CLOSE cr_crapofp;
            pr_cdcritic := 0;
            pr_dscritic := 'Favor escolher a origem para todos os lançamentos!';
            RAISE vr_erro;
         END IF;
         -- Apenas fecha o cursor
         CLOSE cr_crapofp;

         -- Valida origem duplicadas
         IF vr_indvalid = 'N' AND rw_crapofp.idvarmes = 'A' THEN

            -- Validacao de Origens duplicadas
            OPEN cr_valida_ori(pr_cdcooper
                              ,rw_crapemp.cdempres
                              ,pr_dtcredit
                              ,vr_tab_pgto(vr_idx_pgto).nrdconta
                              ,vr_tab_pgto(vr_idx_pgto).cdorigem
                              ,TRIM(pr_dsrowpfp));
            FETCH cr_valida_ori INTO rw_valida_ori;
            -- Se nao encontrar na base
            IF cr_valida_ori%FOUND THEN

               -- Devemos verificar se a origem ja foi encontrada e gravada para exibir
               IF NOT vr_tab_origem.EXISTS(TO_CHAR(TRIM(LPAD(rw_valida_ori.nrdconta,10,0))||
                                                   TRIM(LPAD(rw_valida_ori.cdorigem,10,0)))) AND
                  vr_tab_origem.COUNT() < 3 THEN -- Gravar somente 3 registros
                  vr_tab_origem(TO_CHAR(TRIM(LPAD(rw_valida_ori.nrdconta,10,0))||
                                                   TRIM(LPAD(rw_valida_ori.cdorigem,10,0)))).nrdconta := rw_valida_ori.nrdconta;
                  vr_tab_origem(TO_CHAR(TRIM(LPAD(rw_valida_ori.nrdconta,10,0))||
                                                   TRIM(LPAD(rw_valida_ori.cdorigem,10,0)))).dsorigem := rw_crapofp.dsorigem;
               END IF;

            END IF;
            -- Apenas fecha o cursor
            CLOSE cr_valida_ori;

         END IF;

         -- Nao podemos permitir que o valor
         -- do pagamento seja negativo
         --IF NVL(vr_tab_pgto(vr_idx_pgto).vllctpag,0) <= 0 THEN
         --   pr_cdcritic := 0;
         --   pr_dscritic := 'O valor mínimo de pagamento é R$0,01.';
         --   RAISE vr_erro;
         --END IF;

         -- Validando se o funcionario esta devidamente cadastrado para empresa
         OPEN cr_crapefp(pr_cdcooper
                        ,NVL(vr_tab_pgto(vr_idx_pgto).cdempres,0)
                        ,NVL(vr_tab_pgto(vr_idx_pgto).nrdconta,0)
                        ,NVL(vr_tab_pgto(vr_idx_pgto).nrcpfemp,0));
         FETCH cr_crapefp INTO rw_crapefp;
         -- Se nao encontrar
         IF cr_crapefp%NOTFOUND THEN
            -- Gera critica
            CLOSE cr_crapefp;
            pr_cdcritic := 0;
            pr_dscritic := 'Existem lançamentos para funcionários não cadastrados previamente por você! Favor rever o cadastro!';
            RAISE vr_erro;
         END IF;
         -- Apenas fecha o cursor
         CLOSE cr_crapefp;

         -- Efetua a validação do lançamento
         FOLH0001.pc_valida_lancto_folha(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => vr_tab_pgto(vr_idx_pgto).nrdconta
                                        ,pr_nrcpfcgc => vr_tab_pgto(vr_idx_pgto).nrcpfemp
                                        ,pr_idtpcont => vr_idtpcont
                                        ,pr_nmprimtl => vr_nmprimtl
                                        ,pr_dsalerta => vr_dsalert
                                        ,pr_dscritic => pr_dscritic);

         -- Se ocorrer erro de processamento
         IF pr_dscritic IS NOT NULL THEN
            pr_cdcritic := 0;
            RAISE vr_erro; -- Finaliza o programa
         END IF;

         vr_qtregpag := vr_qtregpag + 1;
         IF vr_tab_pgto(vr_idx_pgto).vllctpag > 0 THEN
           vr_qtlctpag := vr_qtlctpag + 1;
         END IF;
         vr_vllctpag := vr_vllctpag + vr_tab_pgto(vr_idx_pgto).vllctpag;

      END LOOP;

      -- Se houver registros para exibir
      IF vr_tab_origem.COUNT()>0 THEN
         -- monta a variavel para exibir os dados
         vr_idx := vr_tab_origem.first;

         LOOP
             pr_dscritic := '<pagto>'
                         || '<nrdconta>'||TRIM(gene0002.fn_mask_conta(vr_tab_origem(vr_idx).nrdconta))||'</nrdconta>'
                         || '<dsorigem>'||vr_tab_origem(vr_idx).dsorigem||'</dsorigem>'
                         || '</pagto>'
                         ||pr_dscritic;
             EXIT WHEN vr_idx = vr_tab_origem.LAST;
             vr_idx := vr_tab_origem.NEXT(vr_idx);
         END LOOP;

         pr_cdcritic := 999;
         RAISE vr_erro;
      END IF;

      -- Todas as validações obtiverem sucesso, prosseguiremos com a gravação.

      -- Se o pagamento for uma inclusao
      IF TRIM(pr_dsrowpfp) IS NULL THEN

         -- Buscar o próximo sequencial para a empresa
         OPEN  cr_nrseqpag(pr_cdcooper,rw_crapemp.cdempres);
         FETCH cr_nrseqpag INTO vr_nrseqpag;
         CLOSE cr_nrseqpag;

         BEGIN
           -- Inserir a informação da CRAPPFP
           INSERT INTO crappfp(cdcooper
                              ,cdempres
                              ,nrseqpag
                              ,dtmvtolt
                              ,idtppagt
                              ,idopdebi
                              ,dtcredit
                              ,dtdebito
                              ,qtlctpag
                              ,qtregpag
                              ,vllctpag
                              ,flgrvsal
                              ,idsitapr
                              ,vltarapr
                              ,flsitdeb
                              ,flsitcre
                              ,flsittar)
                       VALUES (pr_cdcooper         -- cdcooper
                              ,rw_crapemp.cdempres -- cdempres
                              ,vr_nrseqpag         -- nrseqpag
                              ,SYSDATE             -- dtmvtolt
                              ,'C'                 -- idtppagt
                              ,pr_idopdebi         -- idopdebi
                              ,pr_dtcredit         -- dtcredit
                              ,pr_dtdebito         -- dtdebito
                              ,vr_qtlctpag         -- qtlctpag
                              ,vr_qtregpag         -- qtregpag
                              ,vr_vllctpag         -- vllctpag
                              ,pr_gravarpg         -- flgrvsal
                              ,1   -- Pendente     -- idsitapr
                              ,pr_vltarapr         -- vltarapr
                              ,0   -- false        -- flsitdeb
                              ,0   -- false        -- flsitcre
                              ,0); -- false        -- flsittar

         EXCEPTION
           WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := 'Erro ao inserir CRAPPFP: '||SQLERRM;
             RAISE vr_erro;
         END;

         -- Geração do LOG
         gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => 996
                             ,pr_dscritic => 'OK'
                             ,pr_dsorigem => gene0001.vr_vet_des_origens(3)
                             ,pr_dstransa => 'Pagto Folha #'||vr_nrseqpag||' carregado por '||folh0001.fn_nmoperad_log(pr_cdcooper,pr_nrdconta,pr_nrcpfope)
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 1 --> SUCESSO
                             ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => 'INTERNETBANK'
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);

      ELSE -- Alteracao

         -- Buscar sequencial dos lancamentos
         OPEN  cr_nrseqpfp(pr_dsrowpfp);
         FETCH cr_nrseqpfp INTO vr_nrseqpag
                               ,vr_idopdebi_old
                               ,vr_dtdebito_old
                               ,vr_dtcredit_old
                               ,vr_qtlctpag_old
                               ,vr_qtregpag_old
                               ,vr_vllctpag_old;
         CLOSE cr_nrseqpfp;

         BEGIN
           -- Inserir a informação da CRAPPFP
           UPDATE crappfp pfp
              SET pfp.dtmvtolt = SYSDATE     -- dtmvtolt
                 ,pfp.idopdebi = pr_idopdebi -- idopdebi
                 ,pfp.dtcredit = pr_dtcredit -- dtcredit
                 ,pfp.dtdebito = pr_dtdebito -- dtdebito
                 ,pfp.qtlctpag = vr_qtlctpag -- qtlctpag
                 ,pfp.qtregpag = vr_qtregpag -- qtregpag
                 ,pfp.vllctpag = vr_vllctpag -- vllctpag
                 ,pfp.flgrvsal = pr_gravarpg
                 ,pfp.idsitapr = 1   -- Pendente
                 ,pfp.vltarapr = pr_vltarapr
                 ,pfp.flsitdeb = 0
                 ,pfp.flsitcre = 0
                 ,pfp.flsittar = 0
           WHERE pfp.rowid = pr_dsrowpfp;
         EXCEPTION
           WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := 'Erro ao atualizar CRAPPFP: '||SQLERRM;
             RAISE vr_erro;
         END;

         -- Geração do LOG
         gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => 996
                             ,pr_dscritic => 'OK'
                             ,pr_dsorigem => gene0001.vr_vet_des_origens(3)
                             ,pr_dstransa => 'Pagto Folha #'||vr_nrseqpag||' alterado por '||folh0001.fn_nmoperad_log(pr_cdcooper,pr_nrdconta,pr_nrcpfope)
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 1 --> SUCESSO
                             ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => 'INTERNETBANK'
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);

      END IF;
      -- Adição de detalhes a nivel de item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Empresa'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => rw_crapemp.cdempres);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => 'Convencional');
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Opção Débito'
                               ,pr_dsdadant => folh0001.fn_nmopdebi_log(vr_idopdebi_old)
                               ,pr_dsdadatu => folh0001.fn_nmopdebi_log(pr_idopdebi));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data Débito'
                               ,pr_dsdadant => to_char(vr_dtdebito_old,'dd/mm/rrrr')
                               ,pr_dsdadatu => to_char(pr_dtdebito,'dd/mm/rrrr'));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data Crédito'
                               ,pr_dsdadant => to_char(vr_dtcredit_old,'dd/mm/rrrr')
                               ,pr_dsdadatu => to_char(pr_dtcredit,'dd/mm/rrrr'));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Quantidade de Pagamentos positivos'
                               ,pr_dsdadant => vr_qtlctpag_old
                               ,pr_dsdadatu => vr_qtlctpag);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Valor total dos pagamentos'
                               ,pr_dsdadant => to_char(vr_vllctpag_old,'fm999g999g999g990d00')
                               ,pr_dsdadatu => to_char(vr_vllctpag,'fm999g999g999g990d00'));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Quantidade de Pagamentos total'
                               ,pr_dsdadant => vr_qtregpag_old
                               ,pr_dsdadatu => vr_qtregpag);

      -- Buscar o próximo sequencial para os lancamentos
      OPEN  cr_nrseqlfp(pr_cdcooper,rw_crapemp.cdempres,vr_nrseqpag);
      FETCH cr_nrseqlfp INTO vr_nrseqlfp;
      CLOSE cr_nrseqlfp;
    --
    -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
    -- Busca o indicador estado de crise
    sspb0001.pc_estado_crise (pr_inestcri => vr_inestcri
                             ,pr_clobxmlc => vr_clobxmlc);
    -- Fim Pj 475
      FOR vr_idx_pgto IN vr_tab_pgto.first..vr_tab_pgto.last LOOP

         IF vr_tab_pgto(vr_idx_pgto).rowidlfp IS NULL THEN
        -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
        -- Definir a situação como Erro quando for Intercompany e estado de crise ligado
        vr_idsitlct := 'L';
        vr_dsobslct := NULL;
        --
        IF vr_inestcri > 0 THEN
          OPEN cr_craplcs(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => vr_tab_pgto(vr_idx_pgto).nrdconta
                         ,pr_cdempres => rw_crapemp.cdempres);
          FETCH cr_craplcs INTO rw_craplcs.cdbantrf;
          IF cr_craplcs%NOTFOUND THEN
            rw_craplcs.cdbantrf := 85;
          END IF;
          IF rw_craplcs.cdbantrf <> 85 THEN
            vr_idsitlct := 'E';
            vr_dsobslct := 'Erro encontrado - Estado de Crise Ativo';
          END IF;
          CLOSE cr_craplcs;
        END IF;
        -- Fim Pj 475

            -- Ira um insert para cada conjunto de informações, dessa forma
            -- deve ser realizada a limpeza do registro e a carga para garantir
            -- dados corretos
            rw_craplfp := NULL;
            rw_craplfp.cdcooper := pr_cdcooper;
            rw_craplfp.cdempres := rw_crapemp.cdempres;
            rw_craplfp.nrseqpag := vr_nrseqpag;
        rw_craplfp.idsitlct := vr_idsitlct; -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
        rw_craplfp.dsobslct := vr_dsobslct; -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
            rw_craplfp.nrseqlfp := vr_nrseqlfp;
            rw_craplfp.nrdconta := vr_tab_pgto(vr_idx_pgto).nrdconta;
            rw_craplfp.idtpcont := vr_tab_pgto(vr_idx_pgto).idtpcont;
            rw_craplfp.nrcpfemp := vr_tab_pgto(vr_idx_pgto).nrcpfemp;
            rw_craplfp.vllancto := vr_tab_pgto(vr_idx_pgto).vllctpag;
            rw_craplfp.cdorigem := vr_tab_pgto(vr_idx_pgto).cdorigem;

            -- Realiza o insert dos dados do registro na CRAPLFP
            BEGIN
               INSERT INTO craplfp VALUES rw_craplfp;
            EXCEPTION
               WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao inserir CRAPLFP: '||SQLERRM;
                  RAISE vr_erro;
            END;

            -- Adição de detalhes a nivel de item
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Conta['||rw_craplfp.nrseqlfp||']'
                                     ,pr_dsdadant => NULL
                                     ,pr_dsdadatu => gene0002.fn_mask_conta(rw_craplfp.nrdconta));
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'CPF['||rw_craplfp.nrseqlfp||']'
                                     ,pr_dsdadant => NULL
                                     ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(rw_craplfp.nrcpfemp,1));
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Tipo['||rw_craplfp.nrseqlfp||']'
                                     ,pr_dsdadant => NULL
                                     ,pr_dsdadatu => folh0001.fn_tpconta_log(rw_craplfp.idtpcont));
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Origem['||rw_craplfp.nrseqlfp||']'
                                     ,pr_dsdadant => NULL
                                     ,pr_dsdadatu => folh0001.fn_dsorigem_log(pr_cdcooper,rw_craplfp.cdorigem));
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Valor['||rw_craplfp.nrseqlfp||']'
                                     ,pr_dsdadant => NULL
                                     ,pr_dsdadatu => to_char(rw_craplfp.vllancto,'fm999g999g999g990d00'));

            vr_nrseqlfp := vr_nrseqlfp+1;

         ELSE

            -- Buscar valor anterior de origem e valor
            OPEN cr_craplfp_old(vr_tab_pgto(vr_idx_pgto).rowidlfp);
            FETCH cr_craplfp_old
             INTO vr_neseqlfp_old
                 ,vr_cdorigem_old
                 ,vr_vllancto_old;
            CLOSE cr_craplfp_old;

            BEGIN
              -- Inserir a informação da CRAPPFP
              UPDATE craplfp lfp
                 SET lfp.nrdconta = vr_tab_pgto(vr_idx_pgto).nrdconta
                    ,lfp.idtpcont = vr_tab_pgto(vr_idx_pgto).idtpcont
                    ,lfp.nrcpfemp = vr_tab_pgto(vr_idx_pgto).nrcpfemp
                    ,lfp.vllancto = vr_tab_pgto(vr_idx_pgto).vllctpag
                    ,lfp.cdorigem = vr_tab_pgto(vr_idx_pgto).cdorigem
              WHERE lfp.rowid = vr_tab_pgto(vr_idx_pgto).rowidlfp;
            EXCEPTION
              WHEN OTHERS THEN
                pr_cdcritic := 0;
                pr_dscritic := 'Erro ao atualizar CRAPLFP: '||SQLERRM;
                RAISE vr_erro;
            END;

            -- Adição de detalhes a nivel de item
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Conta['||vr_neseqlfp_old||']'
                                     ,pr_dsdadant => NULL
                                     ,pr_dsdadatu => gene0002.fn_mask_conta(vr_tab_pgto(vr_idx_pgto).nrdconta));
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'CPF['||vr_neseqlfp_old||']'
                                     ,pr_dsdadant => NULL
                                     ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(vr_tab_pgto(vr_idx_pgto).nrcpfemp,1));
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Tipo['||vr_neseqlfp_old||']'
                                     ,pr_dsdadant => NULL
                                     ,pr_dsdadatu => folh0001.fn_tpconta_log(vr_tab_pgto(vr_idx_pgto).idtpcont));
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Origem['||vr_neseqlfp_old||']'
                                     ,pr_dsdadant => vr_cdorigem_old
                                     ,pr_dsdadatu => folh0001.fn_dsorigem_log(pr_cdcooper,vr_tab_pgto(vr_idx_pgto).cdorigem));
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Valor['||vr_neseqlfp_old||']'
                                     ,pr_dsdadant => vr_vllancto_old
                                     ,pr_dsdadatu => to_char(vr_tab_pgto(vr_idx_pgto).vllctpag,'fm999g999g999g990d00'));

         END IF;

      END LOOP;

      -- Limpa tabela de memoria
      vr_tab_pgto.DELETE;
      vr_tab_origem.DELETE;
      
      -- Efetua commit
      COMMIT;

   EXCEPTION
      WHEN vr_erro THEN
         -- Dezfaz alteracoes
         ROLLBACK;
         NULL; -- Retorna a critica ja informada
      WHEN OTHERS THEN
         -- Dezfaz alteracoes
         ROLLBACK;
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina FOLH0002.pc_envia_pagto_apr_ib: '||SQLERRM;
   END pc_envia_pagto_apr_ib;

   /* Procedure encarregada de exibir lista de funcionarios cadastrados para empresa */
   PROCEDURE pc_lista_empregados_ib(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                   ,pr_nrdconta   IN NUMBER
                                   ,pr_data_xml   OUT CLOB
                                   ,pr_cdcritic   OUT PLS_INTEGER
                                   ,pr_dscritic   OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_envia_pagto_apr_ib
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2015.                   Ultima atualizacao: 13/11/2015
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure encarregada de exibir lista de funcionarios cadastrados para empresa
   --
   -- Alteracoes:  13/11/2015 - Inclusão de NVL para não mais enviar data de admissão vazia,
   --                           pois gera erro na leitura (Marcos-Supero)
   --
   ---------------------------------------------------------------------------------------------------------------

      -- Busca lista de empregados relacionados a empresa
      CURSOR cr_crapefp(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_cdempres crapemp.cdempres%TYPE) IS
         SELECT -- Campos da tela
                efp.nrdconta
               ,efp.nrcpfemp
               ,DECODE(efp.idtpcont,'C',(SELECT ass.nmprimtl
                                           FROM crapass ass
                                          WHERE ass.cdcooper = efp.cdcooper
                                            AND ass.nrdconta = efp.nrdconta)
                                   ,'T',(SELECT ccs.nmfuncio
                                           FROM crapccs ccs
                                          WHERE ccs.cdcooper = efp.cdcooper
                                            AND ccs.nrdconta = efp.nrdconta)) nmprimtl
               ,efp.dsdcargo
               ,efp.dtadmiss
               ,NVL(TRIM(REGEXP_REPLACE(efp.dstelefo,'[^0-9]')),' ') dstelefo
               ,efp.dsdemail
               ,efp.nrregger
               ,efp.nrodopis
               ,efp.nrdactps
               ,efp.cdempres
               ,efp.idtpcont
               ,NVL(efp.vlultsal,0) vlultsal
           FROM crapefp efp
          WHERE efp.cdcooper = p_cdcooper
            AND efp.cdempres = p_cdempres
          ORDER BY DECODE(efp.idtpcont,'C',(SELECT ass.nmprimtl
                                           FROM crapass ass
                                          WHERE ass.cdcooper = efp.cdcooper
                                            AND ass.nrdconta = efp.nrdconta)
                                   ,'T',(SELECT ccs.nmfuncio
                                           FROM crapccs ccs
                                          WHERE ccs.cdcooper = efp.cdcooper
                                            AND ccs.nrdconta = efp.nrdconta));

      -- Busca empresa cadastrada pelo usuario
      CURSOR cr_crapemp(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_nrdconta crapemp.nrdconta%TYPE) IS
         SELECT emp.cdempres
           FROM crapemp emp
          WHERE emp.cdcooper = p_cdcooper
            AND emp.nrdconta = p_nrdconta;
      rw_crapemp cr_crapemp%ROWTYPE;

      -- Variaveis
      vr_erro EXCEPTION;
      vr_xml_pgto_temp VARCHAR2(32726) := '';

   BEGIN
      -- Busca as informacoes das empresas
      OPEN cr_crapemp(pr_cdcooper
                     ,pr_nrdconta);
      FETCH cr_crapemp INTO rw_crapemp;
      -- Se nao encontrar
      IF cr_crapemp%NOTFOUND THEN
         -- Gera critica
         CLOSE cr_crapemp;
         pr_cdcritic := 0;
         pr_dscritic := 'Não foi localizado a empresa com a conta: '||pr_nrdconta;
         RAISE vr_erro;
      END IF;
      -- Apenas fecha cursor
      CLOSE cr_crapemp;
      -- Monta documento XML
      dbms_lob.createtemporary(pr_data_xml, TRUE);
      dbms_lob.open(pr_data_xml, dbms_lob.lob_readwrite);
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<raiz>');
      -- Busca todos os empregados relacionados
      FOR rw_crapefp IN cr_crapefp(pr_cdcooper
                                  ,rw_crapemp.cdempres) LOOP
          gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                                 ,pr_texto_completo => vr_xml_pgto_temp
                                 ,pr_texto_novo     => '<funcionarios>'
                                                    || '<nrdconta>'||GENE0002.fn_mask_conta(rw_crapefp.nrdconta)||'</nrdconta>'
                                                    || '<nrcpfemp>'||GENE0002.fn_mask_cpf_cnpj(rw_crapefp.nrcpfemp,1)||'</nrcpfemp>'
                                                    || '<nmprimtl>'||rw_crapefp.nmprimtl||'</nmprimtl>'
                                                    || '<dsdcargo>'||rw_crapefp.dsdcargo||'</dsdcargo>'
                                                    || '<dtadmiss>'||nvl(TO_CHAR(rw_crapefp.dtadmiss,'DD/MM/YYYY'),' ')||'</dtadmiss>'
                                                    || '<dstelefo>'||rw_crapefp.dstelefo||'</dstelefo>'
                                                    || '<dsdemail>'||rw_crapefp.dsdemail||'</dsdemail>'
                                                    || '<nrregger>'||rw_crapefp.nrregger||'</nrregger>'
                                                    || '<nrodopis>'||rw_crapefp.nrodopis||'</nrodopis>'
                                                    || '<nrdactps>'||rw_crapefp.nrdactps||'</nrdactps>'
                                                    || '<cdempres>'||rw_crapefp.cdempres||'</cdempres>'
                                                    || '<idtpcont>'||rw_crapefp.idtpcont||'</idtpcont>'
                                                    || '<vlultsal>'||TO_CHAR(rw_crapefp.vlultsal,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')||'</vlultsal>'
                                                    || '</funcionarios>');
      END LOOP;
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_data_xml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);
   EXCEPTION
      WHEN vr_erro THEN
          NULL; -- Retorna a critica ja informada
      WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina FOLH0002.pc_lista_empregados_ib: '||SQLERRM;
   END pc_lista_empregados_ib;


   -- Procedure para Trazer as informações iniciais da tela de comprovantes do IB
  PROCEDURE pc_valida_comprovante(pr_rowidpfp  IN VARCHAR2
                                  ,pr_pagto_xml OUT CLOB               --> Info dos comprovantes carregados                                   ,pr_cdcritic OUT INTEGER                -- Código do erro
                                  ,pr_cdcritic  OUT PLS_INTEGER
                                  ,pr_dscritic  OUT VARCHAR2) IS       --> Erros do processo

   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_valida_comprovante
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Vanessa
   --  Data     : Agosto/2015.                   Ultima atualizacao: 27/01/2016
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure Trazer as informações iniciais da tela de comprovantes
   --
   -- Alteracoes: 27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
   ---------------------------------------------------------------------------------------------------------------

     CURSOR cr_craplfp(pr_cdcooper crapemp.cdcooper%TYPE
                      ,pr_cdempres craplfp.cdempres%TYPE
                      ,pr_nrseqpag craplfp.nrseqpag%TYPE) IS
         SELECT COUNT(1)
           FROM craplfp lfp
          WHERE lfp.cdcooper = pr_cdcooper     -- Cooperativa logada
            AND lfp.cdempres = pr_cdempres     -- Codigo da Empresa associada
            AND lfp.nrseqpag = pr_nrseqpag     -- Pagamento selecionado na tela
            AND lfp.dtrefenv IS NOT NULL ;     --Onde houve carga de comprovantes

     CURSOR cr_crappfp(pr_rowidpfp VARCHAR2) IS
         SELECT pfp.cdcooper,
                pfp.cdempres,
                pfp.nrseqpag,
                pfp.idtppagt,
                pfp.dtcredit,
                pfp.dtdebito,
                pfp.qtregpag,
                pfp.vllctpag,
                pfp.flsitcre,
                dat.dtmvtolt - TRUNC(pfp.dthorcre) qtsubtra
           FROM crappfp pfp,
                crapdat dat
          WHERE pfp.rowid = pr_rowidpfp 
            AND dat.cdcooper = pfp.cdcooper;
      rw_crappfp cr_crappfp%ROWTYPE;


      -- Variaveis
      vr_existe NUMBER(5);
      vr_erro EXCEPTION;
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      vr_msgtela VARCHAR2(32726) := '';
      vr_cdcritic INTEGER := 0;
      vr_dscritic VARCHAR2(4000) := '';
      vr_qtdiaenv NUMBER(3);
   BEGIN

      -- Busca as informacoes da empresa atraves da conta
      OPEN cr_crappfp(pr_rowidpfp);
      FETCH cr_crappfp INTO rw_crappfp;
      CLOSE cr_crappfp;

      OPEN cr_craplfp(rw_crappfp.cdcooper
                     ,rw_crappfp.cdempres
                     ,rw_crappfp.nrseqpag);
      FETCH cr_craplfp INTO vr_existe;
      CLOSE cr_craplfp;

      IF vr_existe > 0 THEN
         IF   vr_existe = rw_crappfp.qtregpag THEN
              vr_msgtela := 'Todos os comprovantes desse pagamento já foram carregados. Ao carregar novos, dados serão atualizados!';
         ELSIF vr_existe < rw_crappfp.qtregpag THEN
              vr_msgtela := 'Pagamento com (' || vr_existe || ') comprovante(s) carregado(s). Carregue novos ou atualize.';
         END IF;
      END IF;

      -- Busca a Qtde dias para envio comprovantes
      vr_qtdiaenv := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => rw_crappfp.cdcooper
                                              ,pr_cdacesso => 'FOLHAIB_QTD_DIA_ENV_COMP');
                                              
      IF rw_crappfp.qtsubtra > vr_qtdiaenv THEN        
        vr_dscritic := 'O envio dos comprovantes deve ser efetuado no máximo ' || TO_CHAR(vr_qtdiaenv) || ' dia(s) após o pagamento.';
        RAISE vr_erro;
      END IF;     
      
      IF rw_crappfp.flsitcre NOT IN (1,2) THEN
        vr_dscritic := 'Apenas registros creditados podem ser enviados.';
        RAISE vr_erro;        
      END IF;

       -- Monta documento XML
      dbms_lob.createtemporary(pr_pagto_xml, TRUE);
      dbms_lob.open(pr_pagto_xml, dbms_lob.lob_readwrite);
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_pagto_xml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<raiz>');


       -- Insere o cabeçalho do XML
       gene0002.pc_escreve_xml(pr_xml       => pr_pagto_xml
                         ,pr_texto_completo => vr_xml_pgto_temp
                         ,pr_texto_novo     => '<comprovantes>'
                                            || '<cdcooper>'||rw_crappfp.cdcooper||'</cdcooper>'
                                            || '<cdempres>'||rw_crappfp.cdempres||'</cdempres>'
                                            || '<nrseqpag>'||rw_crappfp.nrseqpag||'</nrseqpag>'
                                            || '<idtppagt>'||rw_crappfp.idtppagt||'</idtppagt>'
                                            || '<dtcredit>'||TO_CHAR(rw_crappfp.dtcredit,'DD/MM/YYYY')||'</dtcredit>'
                                            || '<dtdebito>'||TO_CHAR(rw_crappfp.dtdebito,'DD/MM/YYYY')||'</dtdebito>'
                                            || '<qtlctpag>'||rw_crappfp.qtregpag||'</qtlctpag>'
                                            || '<vllctpag>'||TO_CHAR(rw_crappfp.vllctpag, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||'</vllctpag>'
                                            || '<dsmsgtela>'||vr_msgtela||'</dsmsgtela>'
                                            || '</comprovantes>');


      gene0002.pc_escreve_xml(pr_xml            => pr_pagto_xml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '</raiz>'
                              ,pr_fecha_xml      =>  TRUE);

   EXCEPTION
      WHEN vr_erro THEN
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro ao montar XML. Rotina FOLH.pc_valida_comprovantes: '||SQLERRM;
   END pc_valida_comprovante;

   /* Procedure encarregada de cadastrar/atualizar funcionario para empresa */
   PROCEDURE pc_cadastra_empregado_ib(pr_nrdctemp IN crapass.nrdconta%TYPE
                                     ,pr_nrcpfemp IN NUMBER
                                     ,pr_nmprimtl IN VARCHAR2
                                     ,pr_dsdcargo IN VARCHAR2
                                     ,pr_dtadmiss IN VARCHAR2
                                     ,pr_dstelefo IN VARCHAR2
                                     ,pr_dsdemail IN VARCHAR2
                                     ,pr_nrregger IN VARCHAR2
                                     ,pr_nrodopis IN VARCHAR2
                                     ,pr_nrdactps IN VARCHAR2
                                     ,pr_altera   IN VARCHAR2
                                     ,pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                                     ,pr_nrcpfope IN crapopi.nrcpfope%TYPE
                                     ,pr_cdcritic   OUT PLS_INTEGER
                                     ,pr_dscritic   OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_inclui_empregado
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Lombardi
   --  Data     : Agosto/2015.                   Ultima atualizacao: 27/01/2016
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure encarregada de cadastrar/atualizar funcionario para empresa
   --
   -- Alteracoes: 20/11/2015 - Ajuste de mensagem de erro (Andre Santos - SUPERO)
   --
   --             27/01/2016 - Inclusão do processo de log nas operações (Marcos-Supero)
   --
   ---------------------------------------------------------------------------------------------------------------
      --Cursores

      -- Procura associado ou cadastro de conta salário
      CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_nrcpfemp IN crapass.nrcpfcgc%TYPE) IS
         SELECT 'C' idtpcont
           FROM crapass ass
          WHERE ass.cdcooper = pr_cdcooper
            AND ass.nrdconta = pr_nrdconta
            AND ass.nrcpfcgc = pr_nrcpfemp
          UNION
         SELECT 'T' idtpcont
           FROM crapccs ccs
          WHERE ccs.cdcooper = pr_cdcooper
            AND ccs.nrdconta = pr_nrdconta
            AND ccs.nrcpfcgc = pr_nrcpfemp;

      rw_crapass cr_crapass%ROWTYPE;

      -- Dados da empresa
      CURSOR cr_crapemp (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT cdempres
          FROM crapemp
         WHERE nrdconta = pr_nrdconta
           AND cdcooper = pr_cdcooper;

      rw_crapemp cr_crapemp%ROWTYPE;

      -- Dados antes do upd para log
      CURSOR cr_crapefp(pr_cdempres IN crapemp.cdempres%TYPE
                       ,pr_idtpcont IN crapefp.idtpcont%TYPE) IS
        SELECT efp.dsdcargo
              ,efp.dtadmiss
              ,efp.dstelefo
              ,efp.dsdemail
              ,efp.nrregger
              ,efp.nrodopis
              ,efp.nrdactps
          FROM crapefp efp
         WHERE efp.cdcooper = pr_cdcooper
           AND efp.cdempres = pr_cdempres
           AND efp.nrdconta = pr_nrdctemp
           AND efp.nrcpfemp = pr_nrcpfemp
           AND efp.idtpcont = pr_idtpcont;
      rw_crapefp cr_crapefp%ROWTYPE;

      -- Variaveis
      vr_dtadmiss VARCHAR2(10);
      vr_hasfound BOOLEAN;
      vr_erro     EXCEPTION;
      vr_nrdrowid ROWID;
      vr_dsoperac VARCHAR2(15);
      vr_dsopelog VARCHAR2(15);

   BEGIN

      -- Busca as informacoes das empresas
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdctemp
                      ,pr_nrcpfemp => pr_nrcpfemp);
      FETCH cr_crapass INTO rw_crapass;
      vr_hasfound := cr_crapass%FOUND;
      CLOSE cr_crapass;
      -- Se nao encontrar
      IF NOT vr_hasfound THEN
         -- Gera critica
         pr_cdcritic := 0;
         pr_dscritic := 'Conta e CPF divergentes!';
         RAISE vr_erro;
      END IF;

      -- Busca as informacoes das empresas
      OPEN cr_crapemp (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapemp INTO rw_crapemp;
      vr_hasfound := cr_crapemp%FOUND;
      CLOSE cr_crapemp;
      -- Se nao encontrar
      IF NOT vr_hasfound THEN
         -- Gera critica
         pr_cdcritic := 0;
         pr_dscritic := 'Empresa não encontrada.';
         RAISE vr_erro;
      END IF;

      IF pr_dtadmiss = ' ' THEN
        vr_dtadmiss := '';
      ELSE
        vr_dtadmiss := pr_dtadmiss;
      END IF;

      IF upper(pr_altera) <> 'S' THEN
        -- Insere registro
        vr_dsoperac := 'Inserção';
        vr_dsopelog := 'cadastrado';
        BEGIN
          INSERT INTO crapefp (cdcooper
                              ,nrdconta
                              ,cdempres
                              ,nrcpfemp
                              ,idtpcont
                              ,dsdcargo
                              ,dtadmiss
                              ,dstelefo
                              ,dsdemail
                              ,nrregger
                              ,nrodopis
                              ,nrdactps)
                       VALUES (pr_cdcooper
                              ,pr_nrdctemp
                              ,rw_crapemp.cdempres
                              ,pr_nrcpfemp
                              ,rw_crapass.idtpcont
                              ,pr_dsdcargo
                              ,to_date(vr_dtadmiss,'DD/MM/RRRR')
                              ,pr_dstelefo
                              ,pr_dsdemail
                              ,pr_nrregger
                              ,pr_nrodopis
                              ,pr_nrdactps);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Empregado já cadastrado, favor informar outra Conta e CPF!';
            RAISE vr_erro;
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := SQLERRM;
            RAISE vr_erro;
        END;
      ELSE
        -- Busca dados antes do upd
        OPEN cr_crapefp(pr_cdempres => rw_crapemp.cdempres
                       ,pr_idtpcont => rw_crapass.idtpcont);
        FETCH cr_crapefp
         INTO rw_crapefp;
        CLOSE cr_crapefp;

        -- Atualiza registro
        vr_dsoperac := 'Atualização';
        vr_dsopelog := 'atualizado';
        BEGIN
          UPDATE crapefp
             SET dsdcargo = pr_dsdcargo
                ,dtadmiss = to_date(vr_dtadmiss,'DD/MM/RRRR')
                ,dstelefo = pr_dstelefo
                ,dsdemail = pr_dsdemail
                ,nrregger = pr_nrregger
                ,nrodopis = pr_nrodopis
                ,nrdactps = pr_nrdactps
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdctemp
             AND cdempres = rw_crapemp.cdempres
             AND nrcpfemp = pr_nrcpfemp;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := SQLERRM;
            RAISE vr_erro;
        END;
      END IF;

      -- Geração do LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 996
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(3)
                          ,pr_dstransa => 'Empregado Folha '||vr_dsopelog||' por '||folh0001.fn_nmoperad_log(pr_cdcooper,pr_nrdconta,pr_nrcpfope)
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO
                          ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Adição de detalhes a nivel de item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Empresa'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => rw_crapemp.cdempres);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Operação'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => vr_dsoperac);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => gene0002.fn_mask_conta(pr_nrdctemp));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'CPF'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(pr_nrcpfemp,1));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => folh0001.fn_tpconta_log(rw_crapass.idtpcont) );
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Cargo'
                               ,pr_dsdadant => rw_crapefp.dsdcargo
                               ,pr_dsdadatu => pr_dsdcargo);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Data Admissão'
                               ,pr_dsdadant => to_char(rw_crapefp.dtadmiss,'dd/mm/rrrr')
                               ,pr_dsdadatu => vr_dtadmiss);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Telefone'
                               ,pr_dsdadant => rw_crapefp.dstelefo
                               ,pr_dsdadatu => pr_dstelefo);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Email'
                               ,pr_dsdadant => rw_crapefp.dsdemail
                               ,pr_dsdadatu => pr_dsdemail);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'RG'
                               ,pr_dsdadant => rw_crapefp.nrregger
                               ,pr_dsdadatu => pr_nrregger);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'PIS'
                               ,pr_dsdadant => rw_crapefp.nrodopis
                               ,pr_dsdadatu => pr_nrodopis);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'CTPS'
                               ,pr_dsdadant => rw_crapefp.nrdactps
                               ,pr_dsdadatu => pr_nrdactps);

      COMMIT;

   EXCEPTION
      WHEN vr_erro THEN
          ROLLBACK; -- Retorna a critica ja informada
      WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina FOLH0002.pc_lista_empregados_ib: '||SQLERRM;
         ROLLBACK;
   END pc_cadastra_empregado_ib;

   /* Procedure encarregada de excluir um funcionario da empresa */
   PROCEDURE pc_exclui_empregado_ib(pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_nrcpfope IN crapopi.nrcpfope%TYPE
                                   ,pr_nrdctemp IN crapass.nrdconta%TYPE
                                   ,pr_nrcpfemp IN craplfp.nrcpfemp%TYPE
                                   ,pr_cdempres IN crapemp.cdempres%TYPE
                                   ,pr_idtpcont IN craplfp.idtpcont%TYPE
                                   ,pr_cdcritic OUT PLS_INTEGER
                                   ,pr_dscritic OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_exclui_empregado_ib
   --  Sistema  : internet Banking
   --  Sigla    : CRED
   --  Autor    : Lombardi
   --  Data     : Agosto/2015.                   Ultima atualizacao: 26/01/2016
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure encarregada de excluir um funcionario da empresa
   --
   -- Alteracoes: 09/09/2015 - Ajuste no cursor cr_craplfp para trazer as dando
   --                          FETCH para encontrar os valores (Vanessa).
   --
   --             26/01/2016 - Inclusão de log nas operações da rotina (Marcos-Supero)
   --               
   --             15/05/2018 - Ajuste realizado para validar a situacao da transacao pedente
   --                          na exclusao de funcionario (PRB0040042 - Kelvin).
   --                          
   ---------------------------------------------------------------------------------------------------------------
      --Cursores
      CURSOR cr_craplfp(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE
                       ,pr_nrdctemp crapass.nrdconta%TYPE
                       ,pr_nrcpfemp craplfp.nrcpfemp%TYPE
                       ,pr_idtpcont craplfp.idtpcont%TYPE) IS
        SELECT pfp.idsitapr
              ,pfp.cdcooper
              ,pfp.cdempres
              ,pfp.nrseqpag
          FROM craplfp lfp
              ,crappfp pfp
              ,crapemp emp
        WHERE emp.cdcooper = pr_cdcooper
          AND emp.nrdconta = pr_nrdconta
          AND pfp.cdcooper = emp.cdcooper
          AND pfp.cdempres = emp.cdempres
          AND pfp.flsitcre = 0 --> Não creditado ainda
          AND pfp.idtppagt = 'C'
          AND lfp.cdcooper = pfp.cdcooper
          AND lfp.cdempres = pfp.cdempres
          AND lfp.nrseqpag = pfp.nrseqpag
          AND lfp.nrdconta = pr_nrdctemp
          AND lfp.nrcpfemp = pr_nrcpfemp
          AND lfp.idtpcont = pr_idtpcont
          AND lfp.idsitlct = 'L';
      rw_craplfp cr_craplfp%ROWTYPE;
      
      CURSOR cr_valida_trans_pend(pr_cdcooper crapcop.cdcooper%TYPE
                                 ,pr_cdempres crappfp.cdempres%TYPE
                                 ,pr_nrseqpag crappfp.nrseqpag%TYPE) IS
        SELECT tpd.idsituacao_transacao
          FROM tbfolha_trans_pend tfl
          JOIN tbgen_trans_pend tpd
            ON tpd.cdtransacao_pendente = tfl.cdtransacao_pendente
         WHERE tfl.cdcooper = pr_cdcooper
           AND tfl.cdempres = pr_cdempres
           AND tfl.nrsequencia_folha = pr_nrseqpag
           AND tpd.idsituacao_transacao NOT IN (1,2,5);
      rw_valida_trans_pend cr_valida_trans_pend%ROWTYPE;    
      
      -- Variaveis
      vr_hasfound BOOLEAN;
      vr_erro EXCEPTION;
      vr_nrdrowid ROWID;

   BEGIN
     -- Verifica se existe algum pagamento pendente.
     FOR rw_craplfp IN cr_craplfp(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrdctemp => pr_nrdctemp
                                 ,pr_nrcpfemp => pr_nrcpfemp
                                 ,pr_idtpcont => pr_idtpcont) LOOP
       
       --Se for transação pendente  
       IF rw_craplfp.idsitapr = 6 THEN
         OPEN cr_valida_trans_pend(rw_craplfp.cdcooper
                                  ,rw_craplfp.cdempres
                                  ,rw_craplfp.nrseqpag);
           FETCH cr_valida_trans_pend
             INTO rw_valida_trans_pend;
             
           IF cr_valida_trans_pend%NOTFOUND THEN
             CLOSE cr_valida_trans_pend;
             -- Gera critica
             pr_cdcritic := 0;
             pr_dscritic := 'Empregado não pode ser excluído enquanto houver agendamentos cadastrados! (1)';
             RAISE vr_erro;
           END IF;
              
         CLOSE cr_valida_trans_pend;
       
       ELSE
         -- Gera critica
         pr_cdcritic := 0;
         pr_dscritic := 'Empregado não pode ser excluído enquanto houver agendamentos cadastrados! (2)';
         RAISE vr_erro;         
       END IF;
                   
     END LOOP;
     
     BEGIN

       DELETE FROM crapefp
             WHERE cdcooper = pr_cdcooper
               AND cdempres = pr_cdempres
               AND nrdconta = pr_nrdctemp
               AND nrcpfemp = pr_nrcpfemp;

     EXCEPTION
       WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := SQLERRM;
         RAISE vr_erro;
     END;

     -- Geração do LOG
     gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                         ,pr_cdoperad => 996
                         ,pr_dscritic => 'OK'
                         ,pr_dsorigem => gene0001.vr_vet_des_origens(3)
                         ,pr_dstransa => 'Empregado Folha excluido por '||folh0001.fn_nmoperad_log(pr_cdcooper,pr_nrdconta,pr_nrcpfope)
                         ,pr_dttransa => TRUNC(SYSDATE)
                         ,pr_flgtrans => 1 --> SUCESSO
                         ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                         ,pr_idseqttl => 1
                         ,pr_nmdatela => 'INTERNETBANK'
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrdrowid => vr_nrdrowid);

     -- Adição de detalhes a nivel de item
     gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                              ,pr_nmdcampo => 'Empresa'
                              ,pr_dsdadant => NULL
                              ,pr_dsdadatu => pr_cdempres);
     gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                              ,pr_nmdcampo => 'Conta'
                              ,pr_dsdadant => NULL
                              ,pr_dsdadatu => gene0002.fn_mask_conta(pr_nrdctemp));
     gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                              ,pr_nmdcampo => 'CPF'
                              ,pr_dsdadant => NULL
                              ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(pr_nrcpfemp,1));
     gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                              ,pr_nmdcampo => 'Tipo'
                              ,pr_dsdadant => NULL
                              ,pr_dsdadatu => folh0001.fn_tpconta_log(pr_idtpcont));

     COMMIT;

   EXCEPTION
      WHEN vr_erro THEN
          NULL; -- Retorna a critica ja informada
      WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina FOLH0002.pc_lista_empregados_ib: '||SQLERRM;
   END pc_exclui_empregado_ib;



   /* Procedure para geracao do relatorio dos pagamentos de folha da empresa */
   PROCEDURE pc_gera_relatorio_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                 ,pr_nrctaemp  IN crapass.nrdconta%TYPE -- Conta empresa
                                 ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE -- Operador conectado
                                 ,pr_nrctalfp  IN crapass.nrdconta%TYPE -- Conta empregado
                                 ,pr_dtinisel  IN DATE
                                 ,pr_dtfimsel  IN DATE
                                 ,pr_insituac  IN INTEGER
                                 ,pr_tpemissa  IN VARCHAR2
                                 ,pr_iddspscp  IN NUMBER
                                 ,pr_nmarquiv OUT VARCHAR2
                                 ,pr_dssrvarq OUT VARCHAR2
                                 ,pr_dsdirarq OUT VARCHAR2
                                 ,pr_dscritic OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_gera_relatorio_ib              Antigo:
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Jaison
   --  Data     : Julho/2015.                   Ultima atualizacao: 21/06/2017
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure para geracao do relatorio dos pagamentos de folha da empresa
   --
   -- Alterações: 12/11/2015 - Migracao da tarifação do sistema da CONFOL para CADTAR (Marcos-Supero)
   --
   --             26/01/2016 - INclusão de log sob as operações (Marcos-Supero)
   --
   --             27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
   --             16/02/2016 - Inclusao do parametro conta na chamada da
   --                          FOLH0001.fn_valor_tarifa_folha. (Jaison/Marcos)
   --
   --             31/03/2016 - Incluido novo Tipo Emissao - Individual (tpemissa) (Guilherme/Supero)
   --
   --             21/06/2017 - Incluido razao social da empresa nos relatórios (Kelvin #682260)
   --
   --             31/07/2019 - Ajuste para aparecer o valor do credito para cada conta. RITM0011931 (Lombardi)
   ---------------------------------------------------------------------------------------------------------------

      -- Busca dados para o cabecalho
      CURSOR cr_headtag(pr_cdcooper crapemp.cdcooper%TYPE,
                        pr_nrdconta crapemp.nrdconta%TYPE) IS
         SELECT emp.cdempres
               ,emp.nmresemp
               ,emp.nmextemp
               ,ass.nrdconta
               ,ass.cdagenci || '-' || age.nmextage nomdopac
               ,ass.nrcpfcgc
               ,cop.nmextcop
           FROM crapemp emp
               ,crapass ass
               ,crapage age
               ,crapcop cop
          WHERE emp.cdcooper = pr_cdcooper
            AND emp.nrdconta = pr_nrdconta
            AND emp.cdcooper = ass.cdcooper
            AND emp.nrdconta = ass.nrdconta
            AND ass.cdcooper = age.cdcooper
            AND ass.cdagenci = age.cdagenci
            AND ass.cdcooper = cop.cdcooper;
      rw_headtag cr_headtag%ROWTYPE;

      -- Busca a relacao dos pagamentos
      CURSOR cr_relpgto(pr_cdcooper crappfp.cdcooper%TYPE,
                        pr_cdempres crappfp.cdempres%TYPE,
                        pr_nrdconta craplfp.nrdconta%TYPE,
                        pr_dtinisel DATE,
                        pr_dtfimsel DATE,
                        pr_insituac INTEGER) IS
         SELECT pfp.nrseqpag
               ,pfp.idsitapr
               ,TO_CHAR(pfp.dtmvtolt,'dd/mm/yy hh24:mi') dtmvtolt
               ,DECODE(pfp.idtppagt,'A','Arquivo','C','Convencional',' ') tppagt
               ,pfp.nrcpfapr
               ,TO_CHAR(pfp.dtsolest,'hh24:mi') dtsolest
               ,pfp.cdopeest
               ,TO_CHAR(pfp.qtregpag,'fm999g999g999g999g999g990') qtlctpag
               ,TO_CHAR(pfp.vllctpag,'fm9g999g999g999g999g990d00') vllctpag
               ,TO_CHAR(NVL(pfp.dthordeb,pfp.dtdebito),'dd/mm/rr hh24:mi') dtdebito
               ,DECODE(pfp.flsitdeb,0,'Pendente '||dsobsdeb,1,'Debitado com sucesso',' ') dssitdeb
               ,pfp.flsitcre
               ,TO_CHAR(NVL(pfp.dthorcre,pfp.dtcredit),'dd/mm/rr hh24:mi') dtcredit
               ,DECODE(pfp.flsitcre,0,'Pendente '||dsobscre,1,'Creditado',' ') dssitcre
               ,TO_CHAR(DECODE(pfp.idsitapr,1,folh0001.fn_valor_tarifa_folha(pr_cdcooper,emp.nrdconta,emp.cdcontar,pfp.idopdebi,pfp.vllctpag)
               ,pfp.vltarapr),'fm999990d00') vltarifa
               ,DECODE(pfp.flsittar,0,'Pendente',1,'Debitada',' ') dssittar
               ,TO_CHAR(pfp.dtcredit,'DD/MM/RR') dtcredit_regs
           FROM crapemp emp
               ,crappfp pfp
          WHERE pfp.cdcooper = pr_cdcooper
            AND pfp.cdempres = pr_cdempres
            AND pfp.cdcooper = emp.cdcooper
            AND pfp.cdempres = emp.cdempres
            AND (NVL(TRUNC(pfp.dthorcre),pfp.dtcredit) BETWEEN pr_dtinisel AND pr_dtfimsel
              OR NVL(TRUNC(pfp.dthordeb),pfp.dtdebito) BETWEEN pr_dtinisel AND pr_dtfimsel)

            AND ((pr_insituac = 1)
              OR (pr_insituac = 2 AND pfp.idsitapr IN (1 /*Pendente*/, 2 /*Em estouro*/, 3 /*Reprovado*/))
              OR (pr_insituac = 3 AND pfp.idsitapr IN (4 /*Aprovado com Estouro*/, 5 /*Aprovado*/))
              OR (pr_insituac = 4 AND pfp.flsitdeb = 1 /*Debitado*/)
              OR (pr_insituac = 5 AND pfp.flsitcre = 1 /*Creditado*/))

            AND EXISTS(SELECT 1
                         FROM craplfp lfp
                        WHERE pfp.cdcooper = lfp.cdcooper
                          AND pfp.cdempres = lfp.cdempres
                          AND pfp.nrseqpag = lfp.nrseqpag
                          AND (lfp.nrdconta = NVL(pr_nrdconta,0) OR 0 = NVL(pr_nrdconta,0)));

      -- Busca operador de internet
      CURSOR cr_crapopi(pr_cdcooper crapopi.cdcooper%TYPE,
                        pr_nrdconta crapopi.nrdconta%TYPE,
                        pr_nrcpfope crapopi.nrcpfope%TYPE) IS
         SELECT crapopi.nmoperad
           FROM crapopi
          WHERE crapopi.cdcooper = pr_cdcooper
            AND crapopi.nrdconta = pr_nrdconta
            AND crapopi.nrcpfope = pr_nrcpfope;

      -- Busca operador
      CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE,
                        pr_cdoperad crapope.cdoperad%TYPE) IS
         SELECT crapope.nmoperad
           FROM crapope
          WHERE crapope.cdcooper = pr_cdcooper
            AND crapope.cdoperad = pr_cdoperad;

      -- Verifica se possui alerta
      CURSOR cr_ale_lfp(pr_cdcooper craplfp.cdcooper%TYPE,
                        pr_cdempres craplfp.cdempres%TYPE,
                        pr_nrseqpag craplfp.nrseqpag%TYPE) IS
         SELECT 1
           FROM craplfp
          WHERE craplfp.cdcooper = pr_cdcooper
            AND craplfp.cdempres = pr_cdempres
            AND craplfp.nrseqpag = pr_nrseqpag
            AND craplfp.idsitlct IN ('L','E','D'); -- Lancado, Erro, Devolvido)
      rw_ale_lfp cr_ale_lfp%ROWTYPE;

      -- Busca os lancamentos
      CURSOR cr_craplfp(pr_cdcooper craplfp.cdcooper%TYPE,
                        pr_cdempres craplfp.cdempres%TYPE,
                        pr_nrseqpag craplfp.nrseqpag%TYPE,
                        pr_nrdconta craplfp.nrdconta%TYPE) IS
         SELECT lfp.idtpcont
               ,DECODE(lfp.idsitlct,'L','Lançado'
                                   ,'C','Creditado'
                                   ,'T','Transmitido'
                                   ,'D','Devolvido'
                                   ,'E','Erro','') dssitlct
               ,lfp.idsitlct
               ,GENE0002.fn_mask_conta(lfp.nrdconta) nrdconta
               ,GENE0002.fn_mask_cpf_cnpj(lfp.nrcpfemp,1) nrcpfcgc
               ,ofp.dsorigem
               ,TO_CHAR(lfp.vllancto,'fm9g999g999g999g999g990d00') vllancto
               ,lfp.dsobslct
               ,CASE lfp.idtpcont
                  WHEN 'C' THEN ass.nmprimtl
                  ELSE ccs.nmfuncio
                END nmprimtl
               ,lfp.nrseqlfp
           FROM craplfp lfp
               ,crapofp ofp
               ,crapass ass
               ,crapccs ccs

          WHERE lfp.cdcooper = pr_cdcooper
            AND lfp.cdempres = pr_cdempres
            AND lfp.nrseqpag = pr_nrseqpag
            AND lfp.cdcooper = ofp.cdcooper
            AND lfp.cdorigem = ofp.cdorigem
            AND (lfp.nrdconta = NVL(pr_nrdconta,0) OR 0 = NVL(pr_nrdconta,0))

            AND ass.cdcooper(+) = lfp.cdcooper
            AND ass.nrdconta(+) = lfp.nrdconta
            AND ass.nrcpfcgc(+) = lfp.nrcpfemp

            AND ccs.cdcooper(+) = lfp.cdcooper
            AND ccs.nrdconta(+) = lfp.nrdconta
            AND ccs.nrcpfcgc(+) = lfp.nrcpfemp;

      CURSOR cr_datadecredito(pr_cdcooper crapass.cdcooper%TYPE
                             ,pr_nrseqpag craplfp.nrseqpag%TYPE
                             ,pr_nrdconta crapass.nrdconta%TYPE
                             ,pr_cdempres craplfp.cdempres%TYPE)IS
        SELECT to_char(lcs.dttransf,'dd/mm/rr') dtcredit
          FROM crappfp pfp -->Pagamentos de folha de pagamanto
              ,craplfp lfp -->Lancamentos do pagamento de folha
              ,craplcs lcs -->Contem os lancamentos dos funcionarios das empresas que optaram por transferir o salario para outra instituicao financeira.
         WHERE pfp.cdcooper = pr_cdcooper /*parametro*/
           AND pfp.cdempres = pr_cdempres /*parametro*/
           AND pfp.nrseqpag = pr_nrseqpag /*parametro*/
           AND lfp.cdcooper = pfp.cdcooper
           AND lfp.cdempres = pfp.cdempres
           AND lfp.nrseqpag = pfp.nrseqpag /*parametro*/
           AND lfp.nrdconta = pr_nrdconta /*parametro*/
           AND lcs.cdcooper = lfp.cdcooper
           AND lcs.cdhistor(+) in (560,561)
           AND lcs.nrridlfp(+)= lfp.progress_recid;
      rw_datacredito cr_datadecredito%ROWTYPE;
  
      -- Variaveis
      vr_des_xml  CLOB;
      vr_blnfound BOOLEAN;
      vr_blnachou BOOLEAN := FALSE;
      vr_dsaprova VARCHAR2(100);
      vr_dsestour VARCHAR2(100);
      vr_dssitcre VARCHAR2(100);
      vr_nmoperad crapope.nmoperad%TYPE;
      vr_nmdireto VARCHAR2(400);
      vr_nmarquiv VARCHAR2(100);
      vr_tpemissa VARCHAR2(10);
      vr_dssituac VARCHAR2(10);
      vr_nrdrowid ROWID;
      vr_nmdirlgc VARCHAR(400);
      vr_data_credito varchar2(22);
      -- Variaveis Excecao
      vr_exc_erro EXCEPTION;

      -- Variaveis de Erro
      vr_dscritic VARCHAR2(100) := 'Erro na geração do relatório. Entre em contato com seu PA.';
      vr_des_erro VARCHAR2(4000);
      vr_des_reto VARCHAR2(3);

      -- Escrever no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo XML
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

   BEGIN
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicilizar as informações do XML
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><rlpgtib>');

      -- Buscar dados para o cabecalho
      OPEN  cr_headtag(pr_cdcooper, pr_nrctaemp);
      FETCH cr_headtag INTO rw_headtag;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_headtag%FOUND;
      -- Fecha cursor
      CLOSE cr_headtag;

      -- Se NAO encontrar dados
      IF NOT vr_blnfound THEN
         RAISE vr_exc_erro;
      END IF;


      -- Tipo de emissao
      IF pr_tpemissa = 'A' THEN
        vr_tpemissa := 'ANALÍTICA';
      ELSIF pr_tpemissa = 'I' THEN
        vr_tpemissa := 'INDIVIDUAL';      
      ELSE
        vr_tpemissa := 'SINTÉTICA';
      END IF;

      -- Situação
      IF pr_insituac = 1 THEN
        vr_dssituac := 'Todos';
      ELSIF pr_insituac = 2 THEN
        vr_dssituac := 'Pendente';
      ELSIF pr_insituac = 3 THEN
        vr_dssituac := 'Aprovado';
      ELSIF pr_insituac = 4 THEN
        vr_dssituac := 'Creditado';
      ELSE
        vr_dssituac := 'Debitado';
      END IF;

      -- Cria o cabecalho
      pc_escreve_xml('<head tpemissa="' || vr_tpemissa || '"
                            nmextcop="' || rw_headtag.nmextcop || '"
                            nomdopac="' || rw_headtag.nomdopac || '"
                            cdempres="' || rw_headtag.cdempres || '"
                            nmempres="' || rw_headtag.nmresemp || '"
                            nmextemp="' || rw_headtag.nmextemp || '"
                            nrcpfcgc="' || GENE0002.fn_mask_cpf_cnpj(rw_headtag.nrcpfcgc,2) || '"
                            nrdconta="' || GENE0002.fn_mask_conta(rw_headtag.nrdconta) || '"
                            dsperiod="DE ' || TO_CHAR(pr_dtinisel,'dd/mm/yyyy') || ' A ' || TO_CHAR(pr_dtfimsel,'dd/mm/yyyy') || '"/><body>');

      -- Percorre a relacao de pagamentos
      FOR rw_relpgto IN cr_relpgto(pr_cdcooper => pr_cdcooper,
                                   pr_cdempres => rw_headtag.cdempres,
                                   pr_nrdconta => pr_nrctalfp,
                                   pr_dtinisel => pr_dtinisel,
                                   pr_dtfimsel => pr_dtfimsel,
                                   pr_insituac => pr_insituac) LOOP
         -- Seta como possui registro
         vr_blnachou := TRUE;

         -- Caso esteja como pendente
         IF rw_relpgto.idsitapr = 1 THEN
           vr_dsaprova := '';
         -- Caso nao possua operador vinculado
         ELSIF rw_relpgto.nrcpfapr = 0 THEN
           vr_dsaprova := rw_headtag.nmresemp;
         ELSE
           -- Busca operador de internet
           OPEN  cr_crapopi(pr_cdcooper, pr_nrctaemp, rw_relpgto.nrcpfapr);
           FETCH cr_crapopi INTO vr_dsaprova;
           -- Fecha cursor
           CLOSE cr_crapopi;
         END IF;

         -- Situacao do pagamento
         CASE
           WHEN rw_relpgto.idsitapr = 2 THEN
             vr_dsestour := 'Em análise (Solicitado em ' || rw_relpgto.dtsolest || ')';

           WHEN rw_relpgto.idsitapr IN (3,4) THEN
             -- Busca operador
             OPEN  cr_crapope(pr_cdcooper, rw_relpgto.cdopeest);
             FETCH cr_crapope INTO vr_nmoperad;
             -- Fecha cursor
             CLOSE cr_crapope;
             -- Guarda operador com a situacao do pagto
             IF rw_relpgto.idsitapr = 3 THEN
                vr_dsestour := 'Reprovado por ' || vr_nmoperad || ' (' || rw_relpgto.cdopeest || ')';
             ELSE
                vr_dsestour := 'Aprovado por ' || vr_nmoperad || ' (' || rw_relpgto.cdopeest || ')';
             END IF;

           ELSE -- 1 ou 5
             vr_dsestour := '';
         END CASE;

         -- Seta a situacao do credito
         vr_dssitcre := rw_relpgto.dssitcre;

         -- Caso tenha sido creditado
         IF rw_relpgto.flsitcre = 1 THEN
            -- Buscar alerta do lancamento
            OPEN  cr_ale_lfp(pr_cdcooper, rw_headtag.cdempres, rw_relpgto.nrseqpag);
            FETCH cr_ale_lfp INTO rw_ale_lfp;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_ale_lfp%FOUND;
            -- Fecha cursor
            CLOSE cr_ale_lfp;
            -- Se encontrar dados
            IF vr_blnfound THEN
               vr_dssitcre := vr_dssitcre || ' com alertas (Ver detalhes)';
            ELSE
               vr_dssitcre := vr_dssitcre || ' com sucesso';
            END IF;
         END IF;

         -- Cria tag pagto
         pc_escreve_xml('<pagto nrdocmto="' || rw_relpgto.nrseqpag || '"
                                dtmvtolt="' || rw_relpgto.dtmvtolt || '"
                                tppagto="' || rw_relpgto.tppagt || '"
                                qtlctpag="' || rw_relpgto.qtlctpag || '"
                                vllctpag="' || rw_relpgto.vllctpag || '"
                                dsaprova="' || vr_dsaprova || '"
                                dsestour="' || vr_dsestour || '"
                                dtdebito="' || rw_relpgto.dtdebito || '"
                                dssitdeb="' || rw_relpgto.dssitdeb || '"
                                dtcredit="' || rw_relpgto.dtcredit || '"
                                dssitcre="' || vr_dssitcre || '"
                                vttarifa="' || rw_relpgto.vltarifa || '"
                                dssittar="' || rw_relpgto.dssittar || '">');

         -- Listagem dos lancamentos
         FOR rw_craplfp IN cr_craplfp(pr_cdcooper => pr_cdcooper,
                                      pr_cdempres => rw_headtag.cdempres,
                                      pr_nrseqpag => rw_relpgto.nrseqpag,
                                      pr_nrdconta => pr_nrctalfp) LOOP
                                   
           IF rw_craplfp.idtpcont = 'T' THEN
             
             OPEN cr_datadecredito(pr_cdcooper => pr_cdcooper
                                  ,pr_nrseqpag => rw_relpgto.nrseqpag
                                  ,pr_nrdconta => REPLACE(rw_craplfp.nrdconta,'.')
                                  ,pr_cdempres => rw_headtag.cdempres);
             FETCH cr_datadecredito INTO rw_datacredito; --> verificar a necessidade deste cursor Brruno
             CLOSE cr_datadecredito;
             
             vr_data_credito := rw_datacredito.dtcredit;
           ELSE
             vr_data_credito := rw_relpgto.dtcredit_regs;
           END IF;
    
            -- Cria tag lancto
            pc_escreve_xml('<lancto>
                                <idsitlct>' || rw_craplfp.idsitlct || '</idsitlct>
                                <dssitlct>' || rw_craplfp.dssitlct || '</dssitlct>
                                <nrdconta>' || rw_craplfp.nrdconta || '</nrdconta>
                                <nrcpfcgc>' || rw_craplfp.nrcpfcgc || '</nrcpfcgc>
                                <nmprimtl><![CDATA[' || NVL(rw_craplfp.nmprimtl,' ') || ']]></nmprimtl>
                                <dsorigem><![CDATA[' || rw_craplfp.dsorigem || ']]></dsorigem>
								<dtcredito>'|| vr_data_credito ||'</dtcredito>
                                <vllancto>' || rw_craplfp.vllancto || '</vllancto>
                                <dsobslct><![CDATA[' || NVL(rw_craplfp.dsobslct,' ') || ']]></dsobslct>
                                <dsprotoc>'|| GENE0002.fn_mask(rw_relpgto.nrseqpag,'9999999999')|| GENE0002.fn_mask(rw_craplfp.nrseqlfp,'9999999999') ||'</dsprotoc>
                            </lancto>');
         END LOOP; -- cr_relpgto

         -- Finaliza tag pagto
         pc_escreve_xml('</pagto>');
      END LOOP; -- cr_relpgto

      -- Geração do LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 996
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(3)
                          ,pr_dstransa => 'Relação dos Pagto Folha solicitada por '||folh0001.fn_nmoperad_log(pr_cdcooper,pr_nrctaemp,pr_nrcpfope)
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO
                          ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrctaemp
                          ,pr_nrdrowid => vr_nrdrowid);

      -- Adição de detalhes a nivel de item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Empresa'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => rw_headtag.cdempres);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Período de'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(pr_dtinisel,'dd/mm/rrrr'));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Período até'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(pr_dtfimsel,'dd/mm/rrrr'));
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Situação'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => vr_dssituac);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Opção'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => vr_tpemissa);
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => gene0002.fn_mask_conta(pr_nrctalfp));
      IF vr_blnachou THEN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Resultado'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'Relatório gerado com sucesso');
      ELSE
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Resultado'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'Nenhum pagamento selecionado com as restrições!');
        vr_dscritic := 'Nenhum pagamento selecionado com estas restrições!';
        COMMIT;
        -- Gerar excecao
        RAISE vr_exc_erro;
      END IF;

      -- Finaliza tag body/rlpgtib
      pc_escreve_xml('</body></rlpgtib>');

      -- Busca o diretorio padrao do sistema
      vr_nmdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      -- Monta o nome do arquivo
      vr_nmarquiv := 'REL' || pr_nrctaemp || '.' || TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||
                     '.' || TO_CHAR(SYSTIMESTAMP,'SSSSSFF5') || '.pdf';

      -- Busca diretório do logo da cooperativa
      vr_nmdirlgc := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'IMG_LOGO_COOP');
      
      -- Efetuar solicitacao de geracao de relatorio
      GENE0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,
                                  pr_cdprogra  => 'ATENDA',
                                  pr_dtmvtolt  => pr_dtmvtolt,
                                  pr_dsxml     => vr_des_xml,
                                  pr_dsxmlnode => '/rlpgtib/body/pagto/lancto',
                                  pr_dsjasper  => 'folha_relato_pagtos.jasper',
                                  pr_dsparams  => 'PR_IMGDLOGO##' || vr_nmdirlgc,
                                  pr_dsarqsaid => vr_nmdireto || '/' || vr_nmarquiv,
                                  pr_flg_gerar => 'S',
                                  pr_qtcoluna  => 80,
                                  pr_cdrelato  => 1,
                                  pr_des_erro  => vr_des_erro);
                 
      -- Testar se houve erro
      IF vr_des_erro IS NOT NULL THEN
        -- Gerar excecao
        RAISE vr_exc_erro;
      END IF;

      -- Liberando a memoria alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      IF pr_iddspscp = 0 THEN
      -- Copia o PDF para o IB
      GENE0002.pc_efetua_copia_arq_ib(pr_cdcooper => pr_cdcooper,
                                      pr_nmarqpdf => vr_nmdireto || '/' || vr_nmarquiv,
                                      pr_des_erro => vr_des_erro);
      -- Testar se houve erro
      IF vr_des_erro IS NOT NULL THEN
        -- Gerar excecao
        RAISE vr_exc_erro;
      END IF;

      -- Remove o arquivo XML fisico de envio
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_nmdireto || '/' || vr_nmarquiv||' 2> /dev/null'
                            ,pr_typ_saida   => vr_des_reto
                            ,pr_des_saida   => vr_des_erro);
      -- Se ocorreu erro dar RAISE
      IF vr_des_reto = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;
      ELSE
        gene0002.pc_copia_arq_para_download(pr_cdcooper => pr_cdcooper
                                           ,pr_dsdirecp => vr_nmdireto||'/'
                                           ,pr_nmarqucp => vr_nmarquiv
                                           ,pr_flgcopia => 0
                                           ,pr_dssrvarq => pr_dssrvarq
                                           ,pr_dsdirarq => pr_dsdirarq
                                           ,pr_des_erro => vr_dscritic);

        IF vr_dscritic IS NOT NULL AND TRIM(vr_dscritic) <> ' ' THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Seta o retorno
      pr_dscritic := NULL;
      pr_nmarquiv := vr_nmarquiv;

      -- Efetua Commit
      COMMIT;

   EXCEPTION
     WHEN vr_exc_erro THEN
       -- Desfaz operacao
       ROLLBACK;
       pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
       -- Desfaz operacao
       ROLLBACK;
       pr_dscritic := vr_dscritic;
   END pc_gera_relatorio_ib;

   --Procedure para impimir os comprovantes  HOLERITE
   PROCEDURE pc_impressao_comprovante(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                      ,pr_nrdconta IN NUMBER
                                      ,pr_idtipfol IN NUMBER
                                      ,pr_rowidpfp IN VARCHAR2
                                      ,pr_iddspscp IN NUMBER
                                      ,pr_retxml   OUT VARCHAR2
                                      ,pr_cdcritic OUT PLS_INTEGER
                                      ,pr_dscritic OUT VARCHAR2) IS

   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_impressao_comprovante
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Vanessa
   --  Data     : Agosto/2015.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure para gerar os comprovantes de pagamento em pdf
   --
   -- Alteracoes:
   ---------------------------------------------------------------------------------------------------------------

       --Busca dados da Nova Folha IB
        CURSOR cr_craplfp(pr_rowidpfp VARCHAR2) IS
            SELECT lfp.cdcooper
                  ,lfp.dtrefenv  -- dtrefere
                  ,lfp.dsxmlenv  -- dsdpagto
                  ,lfp.rowid     -- nrdrowid
              FROM craplfp lfp
             WHERE lfp.rowid = pr_rowidpfp;
      rw_craplfp cr_craplfp%ROWTYPE;

      --Busca dados da Antiga Folha
      CURSOR cr_craphdp(pr_rowidhdp VARCHAR2) IS
        SELECT hdp.*
          FROM craphdp hdp
         WHERE hdp.progress_recid = pr_rowidhdp;
      rw_craphdp cr_craphdp%ROWTYPE;

      CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT ass.cdagenci
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta =pr_nrdconta ;
      rw_crapass cr_crapass%ROWTYPE;

      CURSOR cr_crapemp(pr_cdcooper crapemp.cdcooper%TYPE
                       ,pr_nrcgcemp craphdp.nrcgcemp%TYPE) IS
        SELECT emp.nmextemp
          FROM crapemp emp
         WHERE emp.cdcooper = pr_cdcooper
           AND emp.nrdocnpj = pr_nrcgcemp;
      rw_crapemp cr_crapemp%ROWTYPE;


      CURSOR cr_crapddp(pr_cdcooper craphdp.cdcooper%TYPE
                       ,pr_nrdconta craphdp.nrdconta%TYPE
                       ,pr_idseqttl craphdp.idseqttl%TYPE
                       ,pr_dtrefere craphdp.dtrefere%TYPE
                       ,pr_cddpagto craphdp.cddpagto%TYPE
                       ,pr_dtmvtolt craphdp.dtmvtolt%TYPE) IS
        SELECT ddp.dscodlan
              ,ddp.dslancto
              ,ddp.vllancto
          FROM  crapddp ddp
         WHERE ddp.cdcooper = pr_cdcooper
           AND ddp.nrdconta = pr_nrdconta
           AND ddp.idseqttl = pr_idseqttl
           AND ddp.dtrefere = pr_dtrefere
           AND ddp.cddpagto = pr_cddpagto
           AND ddp.dtmvtolt = pr_dtmvtolt
           AND ddp.tpregist = 2
        ORDER BY ddp.nrsequen ASC;
      rw_crapddp cr_crapddp%ROWTYPE;

       CURSOR cr_crapmdp(pr_cdcooper craphdp.cdcooper%TYPE
                       ,pr_nrdconta craphdp.nrdconta%TYPE
                       ,pr_idseqttl craphdp.idseqttl%TYPE
                       ,pr_dtrefere craphdp.dtrefere%TYPE
                       ,pr_cddpagto craphdp.cddpagto%TYPE
                       ,pr_dtmvtolt craphdp.dtmvtolt%TYPE) IS
        SELECT mdp.dscomprv
          FROM crapmdp mdp
         WHERE mdp.cdcooper = pr_cdcooper
           AND mdp.nrdconta = pr_nrdconta
           AND mdp.idseqttl = pr_idseqttl
           AND mdp.dtrefere = pr_dtrefere
           AND mdp.cddpagto = pr_cddpagto
           AND mdp.dtmvtolt =pr_dtmvtolt
           AND mdp.tpregist = 3
        ORDER BY mdp.nrsequen;
      rw_crapmdp cr_crapmdp%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat     btch0001.cr_crapdat%ROWTYPE;

      --Variaveis
      vr_nmdireto VARCHAR2(400);
      vr_nmarquiv VARCHAR2(100);
      vr_des_erro VARCHAR2(4000);
      vr_des_reto VARCHAR2(3);
      vr_nmextemp VARCHAR2(100);
      vr_dsdpagto VARCHAR2(4000);
      vr_dssrvarq VARCHAR2(500);
      vr_dsdirarq VARCHAR2(500);

      vr_dsxmlrel    CLOB;
      vr_dsdtexto    VARCHAR2(32000);
      -- Subrotina para escrever texto na variável CLOB do XML

      PROCEDURE pc_escreve_xml_folha(pr_dsddados  IN VARCHAR2,
                                     pr_nrdlinha  IN NUMBER  DEFAULT NULL,
                                     pr_idfechar  IN BOOLEAN DEFAULT FALSE) IS

        -- Variáveis
        vr_dstagini      VARCHAR2(20);
        vr_dstagfim      VARCHAR2(20);

      BEGIN
        -- Se não for informada a linha
        IF pr_nrdlinha IS NULL THEN
          -- Escreve os dados no XML
          gene0002.pc_escreve_xml(vr_dsxmlrel, vr_dsdtexto, pr_dsddados, pr_idfechar);
        ELSE
          -- Se linha foi informada, deve imprimir no XML com a tag de linha
          vr_dstagini := '<linha'||to_char(pr_nrdlinha,'FM00')||'>';
          vr_dstagfim := '</linha'||to_char(pr_nrdlinha,'FM00')||'>'||chr(10);

          gene0002.pc_escreve_xml(vr_dsxmlrel, vr_dsdtexto, vr_dstagini||pr_dsddados||vr_dstagfim, pr_idfechar);
        END IF;
      END pc_escreve_xml_folha;

     BEGIN

      -- Busca o diretorio padrao do sistema
      vr_nmdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      -- Monta o nome do arquivo
      vr_nmarquiv := pr_cdcooper || pr_nrdconta || '.' || TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||
                     '.' || TO_CHAR(SYSTIMESTAMP,'SSSSSFF5') || '.pdf';
      IF pr_idtipfol = 1 THEN
           -- Leitura dos dados da Nova Folha
          OPEN cr_craplfp(pr_rowidpfp => pr_rowidpfp);
          FETCH cr_craplfp INTO rw_craplfp;

          -- Se não encontrar
          IF cr_craplfp%NOTFOUND THEN
            -- Fechar o cursor pois efetuaremos raise
            CLOSE cr_craplfp;
            -- Montar mensagem de critica
            pr_cdcritic := 1;
            pr_dscritic := 'Comprovante não encontrado';
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_craplfp;
          END IF;


          cecred.gene0002.pc_solicita_relato(pr_cdcooper => pr_cdcooper,
                                             pr_cdprogra => 'ATENDA',
                                             pr_dtmvtolt => SYSDATE,
                                             pr_dsxml => rw_craplfp.dsxmlenv,
                                             pr_dsxmlnode => '/xml',
                                             pr_dsjasper => 'folha_comprv_salarial.jasper',
                                             pr_dsparams => '',
                                             pr_dsarqsaid => vr_nmdireto || '/' || vr_nmarquiv,
                                             pr_flg_gerar => 'S', -- Geração na hora
                                             pr_qtcoluna => 80,
                                             pr_cdrelato  => 1,
                                             pr_des_erro => pr_dscritic);

          ELSE
                -- Leitura dos dados da Nova Folha
              OPEN cr_craphdp(pr_rowidhdp => pr_rowidpfp);
              FETCH cr_craphdp INTO rw_craphdp;

              -- Se não encontrar
              IF cr_craphdp%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE cr_craphdp;
                -- Montar mensagem de critica
                pr_cdcritic := 1;
                pr_dscritic := 'Comprovante não encontrado';
              ELSE
                -- Apenas fechar o cursor
                CLOSE cr_craphdp;
              END IF;

              OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
              FETCH btch0001.cr_crapdat INTO rw_crapdat;
              -- Se não encontrar
              IF btch0001.cr_crapdat%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE btch0001.cr_crapdat;
                -- Montar mensagem de critica
                 pr_dscritic := 'Registo de data nao encontrado';
              ELSE
                 -- Apenas fechar o cursor
                 CLOSE btch0001.cr_crapdat;
              END IF;

              OPEN  cr_crapass(pr_cdcooper => rw_craphdp.cdcooper
                              ,pr_nrdconta => rw_craphdp.nrdconta);
              FETCH cr_crapass INTO rw_crapass;

              -- Se não encontrar
              IF cr_crapass%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE cr_crapass;
                -- Montar mensagem de critica
                pr_cdcritic := 1;
                pr_dscritic := 'Associado nao cadastrado';
              ELSE
                -- Apenas fechar o cursor
                CLOSE cr_crapass;
              END IF;


              OPEN  cr_crapemp(pr_cdcooper => rw_craphdp.cdcooper
                              ,pr_nrcgcemp => rw_craphdp.nrcgcemp);
              FETCH cr_crapemp INTO rw_crapemp;

              -- Se não encontrar
              IF cr_crapemp%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE cr_crapemp;
                vr_nmextemp := '';
              ELSE
                -- Apenas fechar o cursor
                CLOSE cr_crapemp;

                vr_nmextemp := rw_crapemp.nmextemp;

              END IF;

              IF rw_craphdp.cddpagto = 1   THEN
                 vr_dsdpagto := 'PAGAMENTO MENSAL';
              ELSIF rw_craphdp.cddpagto = 2   THEN
                    vr_dsdpagto := 'pAGAMENTO 1a QUINZENA';
              ELSIF rw_craphdp.cddpagto = 3   THEN
                    vr_dsdpagto :='ADIANTAMENTO';
              ELSIF rw_craphdp.cddpagto = 4   THEN
                    vr_dsdpagto :='FERIAS';
              ELSIF rw_craphdp.cddpagto = 5   THEN
                    vr_dsdpagto :='13o SALARIO';
              ELSE  vr_dsdpagto := ' ';

              END IF;

              -- Inicializar o CLOB do XML
              vr_dsxmlrel := null;
              dbms_lob.createtemporary(vr_dsxmlrel, true);
              dbms_lob.open(vr_dsxmlrel, dbms_lob.lob_readwrite);

              -- Inicilizar as informações do XML
              vr_dsdtexto := null;
              pc_escreve_xml_folha('<?xml version="1.0" encoding="utf-8"?><root>');
              pc_escreve_xml_folha(vr_dsdpagto, 1);
              pc_escreve_xml_folha(TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/YYYY') ||
                             '                         '                     ||
                             TO_CHAR(SYSDATE,'HH:MM') ,2);
              pc_escreve_xml_folha('PA: '                                 ||
                                   TO_CHAR(rw_crapass.cdagenci,'9999')    ||
                                   '              '                       ||
                                   'CONTA: '                              ||
                                   gene0002.fn_mask_conta(rw_craphdp.nrdconta),3);
              pc_escreve_xml_folha('            DADOS DA EMPRESA:           ' ,4);
              pc_escreve_xml_folha(vr_nmextemp    ,5);
              pc_escreve_xml_folha('        CNPJ: '                                   ||
                            GENE0002.fn_mask_cpf_cnpj(rw_craphdp.nrcgcemp,2)          ||
                             '        '                                      ,6);
              pc_escreve_xml_folha('========================================',7);
              pc_escreve_xml_folha('         DADOS DO FUNCIONARIO:          ',8);
              pc_escreve_xml_folha(RPAD(rw_craphdp.nmfuncio,40,' ')    ,9);
              pc_escreve_xml_folha('CARGO: ' || RPAD(rw_craphdp.dsfuncao,40, ' ') ,10);

              pc_escreve_xml_folha('MATRICULA: '    || GENE0002.fn_mask_matric(rw_craphdp.dsnromat) ||
                                   '   ADMISSAO:  ' || TO_CHAR(rw_craphdp.dtadmiss,'DD/MM/YY'),11);

              pc_escreve_xml_folha( 'CPF: ' || GENE0002.fn_mask_cpf_cnpj(rw_craphdp.nrcpfcgc,1)||
                                    '   RG:  ' || rw_craphdp.nrdocfco ,12);
              pc_escreve_xml_folha('PIS/PASEP: ' || rw_craphdp.nrpisfco                             ||
                                   ' CTPS:' || rw_craphdp.nrctpfco     ,13);
              pc_escreve_xml_folha( '========================================',14);
              pc_escreve_xml_folha('         DADOS DO COMPROVANTE:          ' ,15);
              pc_escreve_xml_folha('PERIODO: '                         ||
                                   TO_CHAR(rw_craphdp.dtrefere,'DD/MM/YYYY') ||
                                   '       NRO. LOTE: ' || LPAD(rw_craphdp.nrdolote,3,0) ,16);
              pc_escreve_xml_folha( 'COD. DESCRICAO                     VALOR'    ,17);

              -- IMPRIMIR O CONTEÚDO
              -- Contador de linha - Iniciando na 18 linha do XML


              FOR rw_crapddp IN cr_crapddp(pr_cdcooper => rw_craphdp.cdcooper
                                         ,pr_nrdconta => rw_craphdp.nrdconta
                                         ,pr_idseqttl => rw_craphdp.idseqttl
                                         ,pr_dtrefere => rw_craphdp.dtrefere
                                         ,pr_cddpagto => rw_craphdp.cddpagto
                                         ,pr_dtmvtolt => rw_craphdp.dtmvtolt) LOOP
                 pc_escreve_xml_folha('<dados>');
                 pc_escreve_xml_folha(LPAD(rw_crapddp.dscodlan,4,0)    || ' '  ||
                                      RPAD(rw_crapddp.dslancto,20,' ') ||
                                      LPAD(TRIM(TO_CHAR(rw_crapddp.vllancto,'FM999G999G990D00')),15,' '),1);

                 pc_escreve_xml_folha('</dados>');
             END LOOP;

             pc_escreve_xml_folha('========================================',19 ) ;



          FOR rw_crapmdp IN cr_crapmdp(pr_cdcooper => rw_craphdp.cdcooper
                                     ,pr_nrdconta => rw_craphdp.nrdconta
                                     ,pr_idseqttl => rw_craphdp.idseqttl
                                     ,pr_dtrefere => rw_craphdp.dtrefere
                                     ,pr_cddpagto => rw_craphdp.cddpagto
                                     ,pr_dtmvtolt => rw_craphdp.dtmvtolt) LOOP

             pc_escreve_xml_folha(LPAD(rw_crapmdp.dscomprv,40,' '),20 );



          END LOOP;
          pc_escreve_xml_folha('========================================' ||
                               'AS   INFORMACOES    DISPONIVEIS    NESTE' ||
                               ' COMPROVANTE  SAO   DE   RESPONSABILIDADE' ||
                               ' EXCLUSIVA  DA  EMPRESA  FONTE  PAGADORA.' ||
                               ' QUALQUER   OCORRENCIA    MOTIVADA    POR' ||
                               ' DIVERGENCIA    ENTRE    OS     REGISTROS' ||
                               ' CONSTANTES  NESTE   COMPROVANTE   DEVERA' ||
                               ' SER   ESCLARECIDO   JUNTO   A   EMPRESA.',21 );

           pc_escreve_xml_folha('</root>',NULL,TRUE);

           cecred.gene0002.pc_solicita_relato(pr_cdcooper => pr_cdcooper,
                                             pr_cdprogra => 'ATENDA',
                                             pr_dtmvtolt => SYSDATE,
                                             pr_dsxml => vr_dsxmlrel,
                                             pr_dsxmlnode => '/root',                              --> Nó base do XML para leitura dos dados
                                             pr_dsjasper  => 'folha_pagamento_antiga.jasper',
                                             pr_dsparams => '@@PR_NRDCONTA##'||GENE0002.fn_mask_conta(rw_craphdp.nrdconta)||'@@PR_NMTITULAR##'||UPPER(rw_craphdp.nmfuncio),
                                             pr_dsarqsaid => vr_nmdireto || '/' || vr_nmarquiv,
                                             pr_flg_gerar => 'S', -- Geração na hora
                                             pr_qtcoluna => 80,
                                             pr_cdrelato  => 1,
                                             pr_des_erro => pr_dscritic);
          END IF;



          IF pr_dscritic IS NULL THEN

              IF pr_iddspscp = 0 THEN
              -- Copia o PDF para o IB
              GENE0002.pc_efetua_copia_arq_ib(pr_cdcooper => pr_cdcooper,
                                              pr_nmarqpdf => vr_nmdireto || '/' || vr_nmarquiv,
                                              pr_des_erro => vr_des_erro);

             -- Testar se houve erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar excecao
                 pr_dscritic := vr_des_erro;
              END IF;

              -- Remove o arquivo XML fisico de envio
              GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                    ,pr_des_comando => 'rm '||vr_nmdireto || '/' || vr_nmarquiv||' 2> /dev/null'
                                    ,pr_typ_saida   => vr_des_reto
                                    ,pr_des_saida   => vr_des_erro);
              -- Se ocorreu erro dar RAISE
              IF vr_des_reto = 'ERR' THEN
                pr_dscritic := vr_des_erro;
              END IF;
                
                pr_retxml := '<nmarquiv>' || vr_nmarquiv || '</nmarquiv>';
              ELSE
                gene0002.pc_copia_arq_para_download(pr_cdcooper => pr_cdcooper
                                                   ,pr_dsdirecp => vr_nmdireto||'/'
                                                   ,pr_nmarqucp => vr_nmarquiv
                                                   ,pr_flgcopia => 0
                                                   ,pr_dssrvarq => vr_dssrvarq
                                                   ,pr_dsdirarq => vr_dsdirarq
                                                   ,pr_des_erro => pr_dscritic);  
                                                   
                pr_retxml := '<nmarquiv>' || vr_nmarquiv          || '</nmarquiv>' ||
                             '<dssrvarq>' || NVL(vr_dssrvarq,' ') || '</dssrvarq>' ||
                             '<dsdirarq>' || NVL(vr_dsdirarq,' ') || '</dsdirarq>';              
              END IF;
              
              COMMIT;
              -- Seta o retorno
              pr_dscritic := NULL;
          END IF;
   EXCEPTION
     WHEN OTHERS THEN
       pr_cdcritic := 0;
       pr_dscritic := 'Erro pc_impressao_comprovante: '||SQLERRM;
   END pc_impressao_comprovante;

   /* Procedure para trazer os holerites (comprovantes salariais) */
   PROCEDURE pc_lista_holerites_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta  IN craplfp.nrdconta%TYPE
                                  ,pr_idseqttl  IN craphdp.idseqttl%TYPE
                                  ,pr_clobxml  OUT CLOB
                                  ,pr_cdcritic OUT PLS_INTEGER
                                  ,pr_dscritic OUT VARCHAR2 ) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_lista_holerites_ib
   --  Sistema  : INternet Banking
   --  Sigla    : CRED
   --  Autor    : Vanessa
   --  Data     : Agosto/2015.                   Ultima atualizacao: 27/01/2016
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure para trazer os holerites (comprovantes salariais)
   --
   -- Alteracoes
   --             04/11/2015 - Ajustar data referência do comprovante simples
   --                          para utilizar a data do crédito e não mais o mês
   --                          anterior (Marcos-Supero)
   --
   --             07/12/2015 - Filtrando os ultimos N meses parametrizados para buscar
   --                          os comprovantes novos e antigos. (Andre Santos - SUPERO)
   --
   --             27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
   --
   ---------------------------------------------------------------------------------------------------------------
   --Curosres
   --Busca dados da Nova Folha IB
        CURSOR cr_craplfp(pr_cdcooper crapemp.cdcooper%TYPE
                         ,pr_nrdconta craplfp.nrdconta%TYPE
                         ,pr_dtmvtolt  crapdat.dtmvtolt%TYPE ) IS

            SELECT lfp.cdcooper
                  ,NVL(TO_CHAR(lfp.dtrefenv,'DD/MM/RRRR'),TO_CHAR(pfp.dthorcre,'DD/MM/RRRR'))  dtrefenv  -- dtrefere
                  ,lfp.dsxmlenv  -- dsdpagto
                  ,ofp.dsorigem
                  ,lfp.rowid     -- nrdrowid
                  ,'1' idtipfol  -- (0-folha antiga / 1-folha nova)
              FROM craplfp lfp
                  ,crapofp ofp
                  ,crappfp pfp
             WHERE lfp.cdcooper = pr_cdcooper
               AND lfp.nrdconta = pr_nrdconta
               AND lfp.cdcooper = ofp.cdcooper
               AND lfp.cdorigem = ofp.cdorigem
               AND lfp.idtpcont = 'C'       -- conta – não CTASAL (c-conta t-ctasal)
               AND pfp.cdcooper = lfp.cdcooper
               AND pfp.cdempres = lfp.cdempres
               AND pfp.nrseqpag = lfp.nrseqpag
               AND pfp.flsitcre = 1
               AND lfp.idsitlct IN('C')
               AND (lfp.vllancto > 0 OR lfp.dtrefenv IS NOT null) --> Somente completo quando pagamento zerado
               AND NVL(lfp.dtrefenv,pfp.dthorcre) >=
                   ADD_MONTHS(pr_dtmvtolt,(gene0001.fn_param_sistema('CRED',pr_cdcooper, 'FOLHAIB_QTD_MES_EMI_COMP')*-1))
             ORDER BY nvl(lfp.dtrefenv,pfp.dthorcre) DESC;    --Onde houve carga de comprovantes
      rw_craplfp cr_craplfp%ROWTYPE;

      --Busca dados da folha antiga
      CURSOR cr_craphdp(pr_cdcooper  craphdp.cdcooper%TYPE
                       ,pr_nrdconta  craphdp.nrdconta%TYPE
                       ,pr_idseqttl craphdp.idseqttl%TYPE
                       ,pr_dtmvtolt  crapdat.dtmvtolt%TYPE) IS

            SELECT hdp.cdcooper
                  ,hdp.dtrefere  -- dtrefere
                  ,hdp.dsfuncao dsdpagto
                  ,hdp.cddpagto  -- dsorigem
                  ,hdp.progress_recid-- nrdrowid
                  ,'0' idtipfol  -- (0-folha antiga / 1-folha nova)
              FROM craphdp hdp
             WHERE hdp.cdcooper = pr_cdcooper
               AND hdp.nrdconta = pr_nrdconta
               AND hdp.idseqttl = pr_idseqttl
               AND hdp.dtrefere >=
                   ADD_MONTHS(pr_dtmvtolt,(gene0001.fn_param_sistema('CRED',pr_cdcooper, 'FOLHAIB_QTD_MES_EMI_COMP')*-1))
             ORDER BY hdp.dtrefere DESC;
      rw_craphdp cr_craphdp%ROWTYPE;

      -- Variaveis
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      vr_erro EXCEPTION;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_dsdpagto VARCHAR2(100) := '';
    BEGIN

      -- Verificacao do calendario
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

       -- Monta documento XML
      dbms_lob.createtemporary(pr_clobxml, TRUE);
      dbms_lob.open(pr_clobxml, dbms_lob.lob_readwrite);
      
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<raiz>');

      -- Percorre aos comprovantes novos
      FOR rw_craplfp IN cr_craplfp(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

        BEGIN
           -- Insere o conteudo do XML
           gene0002.pc_escreve_xml(pr_xml            => pr_clobxml
                                  ,pr_texto_completo => vr_xml_temp
                                  ,pr_texto_novo     => '<comprovantes>'
                                                     || '<cdcooper>'||rw_craplfp.cdcooper||'</cdcooper>'
                                                     || '<dtrefere>'||rw_craplfp.dtrefenv||'</dtrefere>'
                                                     || '<dsdpagto>'||UPPER(rw_craplfp.dsorigem)||'</dsdpagto>'
                                                     || '<idtipfol>'||rw_craplfp.idtipfol||'</idtipfol>'
                                                     || '<nrdrowid>'||rw_craplfp.rowid||'</nrdrowid>'
                                                     || '</comprovantes>');

        END;
      END LOOP;

      -- Percorre aos comprovantes Antigos
      FOR rw_craphdp IN cr_craphdp(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
        BEGIN
          IF rw_craphdp.cddpagto = 1 THEN
            vr_dsdpagto := 'PAGAMENTO MENSAL';
          ELSIF rw_craphdp.cddpagto = 2 THEN
            vr_dsdpagto := 'PAGAMENTO 1a QUINZENA';
          ELSIF rw_craphdp.cddpagto = 3 THEN
            vr_dsdpagto := 'ADIANTAMENTO';
          ELSIF rw_craphdp.cddpagto = 4 THEN
            vr_dsdpagto := 'FERIAS';
          ELSIF rw_craphdp.cddpagto = 1 THEN
            vr_dsdpagto := '13o SALARIO';
          ELSE
            vr_dsdpagto := '';
          END IF;
          -- Insere o conteudo do XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxml
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<comprovantes>'
                                                    || '<cdcooper>'||rw_craphdp.cdcooper||'</cdcooper>'
                                                    || '<dtrefere>'||TO_CHAR(rw_craphdp.dtrefere,'DD/MM/YYYY')||'</dtrefere>'
                                                    || '<dsdpagto>'||vr_dsdpagto ||'</dsdpagto>'
                                                    || '<idtipfol>'||rw_craphdp.idtipfol||'</idtipfol>'
                                                    || '<nrdrowid>'||rw_craphdp.progress_recid||'</nrdrowid>'
                                                    || '</comprovantes>');

        END;
      END LOOP;
      -- Fecha o XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      =>  TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_lista_holerites_ib: '||SQLERRM;
    END pc_lista_holerites_ib;


  /* Rotina para buscar a quantidade de pagamentos pendentes */
  PROCEDURE pc_busca_pgto_pendente_ib(pr_cdcooper    IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                     ,pr_cdempres    IN crapemp.cdempres%TYPE  -- Código da empresa
                                     ,pr_inpagpen   OUT INTEGER                -- Flag do folha de pagamento
                                     ,pr_cdcritic   OUT INTEGER                -- Código do erro
                                     ,pr_dscritic   OUT VARCHAR2) IS           -- Descricao do erro
    /* .............................................................................
    Programa : FOLH0002
    Sistema  : Internet Banking
    Sigla    : FOLH
    Autor    : Jaison
    Data     : Junho/2015.                      Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que Chamado
    Objetivo  : Rotina para buscar a quantidade de pagamentos pendentes

    Alteracoes: 18/11/2016 - SD542975 - Ajuste no teste para considerar 
	                                    pendente ou não - Marcos-Supero
    ............................................................................. */

     -- Busca a quantidade de pagamentos pendentes
     CURSOR cr_crappfp(pr_cdcooper crappfp.cdcooper%TYPE
                      ,pr_cdempres crappfp.cdempres%TYPE) IS
        SELECT COUNT(pfp.cdempres)
          FROM crappfp pfp
         WHERE pfp.cdcooper = pr_cdcooper
           AND pfp.cdempres = pr_cdempres
           AND pfp.idsitapr IN (2,4,5) -- 2-Em estouro / 4-Aprv.Estouro / 5-Aprovado
		   AND pfp.flsitcre = 0;

  BEGIN

    -- Buscar a quantidade
    OPEN cr_crappfp(pr_cdcooper => pr_cdcooper
                   ,pr_cdempres => pr_cdempres);
    FETCH cr_crappfp INTO pr_inpagpen;
    -- Se não encontrar o registro
    IF cr_crappfp%NOTFOUND THEN
      pr_inpagpen := 0;
    END IF;

    CLOSE cr_crappfp;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro pc_busca_pgto_pendente_ib: '||SQLERRM;
  END pc_busca_pgto_pendente_ib;

  /* Procedimento para validar horario limite para folha de pagamento */
  PROCEDURE pc_hrlimite( pr_cdcooper IN INTEGER               --> Codigo da Cooperativa
                        ,pr_hrlimage OUT VARCHAR2             --> Horario limite agenda
                        ,pr_hrlimptb OUT VARCHAR2             --> Horario limite portabilidade
                        ,pr_hrlimsol OUT VARCHAR2             --> Horario limite solicitacao Estorno
                        ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                        ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                        ) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_hrlimite
   --  Sistema  : Procedimento para validar horario limite folha de pagamento
   --  Sigla    : CRED
   --  Autor    : Jorge Hamaguchi
   --  Data     : Dezembro/2015.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedimento para validar horario limite para folha de pagamento
   -- Alteracoes:
   ---------------------------------------------------------------------------------------------------------------
      -- Cursores

      -- Variaveis


   BEGIN
      -- Inicializa Variavel
      pr_cdcritic := 0;
      pr_dscritic := NULL;

      pr_hrlimage := GENE0001.FN_PARAM_SISTEMA('CRED',pr_cdcooper,'FOLHAIB_HOR_LIM_AGENDA');
      pr_hrlimptb := GENE0001.FN_PARAM_SISTEMA('CRED',pr_cdcooper,'FOLHAIB_HOR_LIM_PORTAB');
      pr_hrlimsol := GENE0001.FN_PARAM_SISTEMA('CRED',pr_cdcooper,'FOLHAIB_HOR_LIM_SOL_EST');


   EXCEPTION
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina FOLH0002.pc_hrlimite. '||SQLERRM;
   END pc_hrlimite;

  PROCEDURE pc_gera_retorno_cooperado(pr_cdcooper IN INTEGER       --> Codigo da Cooperativa
                                     ,pr_rowidpfp IN VARCHAR2      --> Rowid da crappfp                                                                    
                                     ,pr_clob_ret OUT CLOB         --> Arquivo de retorno          
                                     ,pr_cdcritic OUT PLS_INTEGER  --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica
 
    CURSOR cr_crappfp (pr_rowidpfp ROWID
                      ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT pfp.cdcooper 
            ,pfp.cdempres
            ,pfp.nrseqpag
            ,pfp.dtcredit
            ,lfp.cdorigem
            ,lfp.nrdconta
            ,lfp.vllancto
            ,DECODE(lfp.idtpcont,'C',ass.nmprimtl,ccs.nmfuncio) nmfuncio
            ,DECODE(lfp.idtpcont,'C',ass.nrcpfcgc,ccs.nrcpfcgc) nrcpfcgc
            ,CASE 
               WHEN (pfp.dtcredit <= pr_dtmvtolt
                AND lfp.idtpcont = 'T' 
                AND lfp.idsitlct = 'T' 
                AND lfp.dsobslct IS NULL) 
                 OR (pfp.dtcredit <= pr_dtmvtolt
                AND lfp.idtpcont = 'C'
                AND lfp.idsitlct = 'C') THEN to_char(pfp.dtcredit,'DDMMYYYY')
               ELSE RPAD('0',8,'0') 
              END dtctreal
            ,CASE 
               WHEN (pfp.dtcredit <= pr_dtmvtolt
                AND lfp.idtpcont = 'T' 
                AND lfp.idsitlct = 'T' 
                AND lfp.dsobslct IS NULL) 
                 OR (pfp.dtcredit <= pr_dtmvtolt
                AND lfp.idtpcont = 'C'
                AND lfp.idsitlct = 'C') THEN to_char(lfp.vllancto)
               ELSE RPAD('0',15,'0') 
              END vllnreal
            ,CASE 
               WHEN pfp.dtcredit > pr_dtmvtolt
                AND pfp.flsitcre = 0 THEN '04'
               WHEN pfp.dtcredit < pr_dtmvtolt
                AND lfp.idsitlct = 'C' THEN '00'
               WHEN lfp.idsitlct = 'L'
                 OR lfp.idsitlct = 'T' THEN '05'
               WHEN (pfp.dtcredit < pr_dtmvtolt
                AND (lfp.idsitlct = 'D'
                 OR lfp.idsitlct = 'E')) THEN '06'
               ELSE '06'
              END cdocorre
            ,CASE 
               WHEN pfp.dtcredit < pr_dtmvtolt
                AND (lfp.idsitlct = 'C'
                 OR (lfp.idsitlct = 'T'
                AND lfp.dsobslct IS NULL)) THEN 1
               ELSE 0
              END flgsegmt
            ,LPAD(gene0002.fn_mask(lfp.nrseqpag,'999999999') || gene0002.fn_mask(lfp.nrseqlfp,'999999999'),25,' ') dsprotoc
            ,pfp.vllctpag
            ,pfp.idsitapr
        FROM crappfp pfp
        JOIN craplfp lfp 
          ON lfp.cdcooper = pfp.cdcooper
         AND lfp.cdempres = pfp.cdempres
         AND lfp.nrseqpag = pfp.nrseqpag  
        LEFT JOIN crapccs ccs
          ON ccs.cdcooper = lfp.cdcooper
         AND ccs.nrdconta = lfp.nrdconta
        LEFT JOIN crapass ass
          ON ass.cdcooper = lfp.cdcooper
         AND ass.nrdconta = lfp.nrdconta
       WHERE pfp.rowid = pr_rowidpfp;
    
    CURSOR cr_info_pessoa(pr_cdcooper crapcop.cdcooper%TYPE
                         ,pr_cdempres crapemp.cdempres%TYPE) IS
      SELECT ass.inpessoa
            ,ass.nrcpfcgc
            ,emp.cdempres
            ,ass.nrdconta
            ,ass.nmprimtl
            ,cop.cdagectl
            ,cop.nmextcop
            ,cop.cdcooper
        FROM crapemp emp
        JOIN crapass ass
          ON ass.cdcooper = emp.cdcooper
         AND ass.nrdconta = emp.nrdconta
        JOIN crapcop cop
          ON cop.cdcooper = emp.cdcooper
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.cdempres = pr_cdempres;             
    rw_info_pessoa cr_info_pessoa%ROWTYPE;
    
    CURSOR cr_crapenc(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT enc.dsendere
            ,enc.nrendere
            ,enc.nmcidade
            ,enc.nrcepend
            ,enc.cdufende
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta 
         AND enc.tpendass = 9; --Comercial                    
    rw_crapenc cr_crapenc%ROWTYPE;
    
    -- Cursor generico de calendario
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
     
    --Variáveis auxiliares
    vr_flgempre BOOLEAN;
    vr_dstexto  VARCHAR2(32767);
    vr_horagera VARCHAR2(1000);
    vr_setlinha VARCHAR2(1000);
    vr_contador NUMBER;
    vr_conttrai NUMBER;
    vr_vllctpag NUMBER;
      
    --Variáveis de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
  
  --Escrever no arquivo CLOB
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
    vr_des_dados VARCHAR2(32767);
  BEGIN
    -- retirar caracteres acentuados
    vr_des_dados := gene0007.fn_caract_acento(pr_des_dados);
    --Escrever no arquivo XML
    dbms_lob.writeappend(pr_clob_ret,length(vr_des_dados),vr_des_dados);
  END;
  
  BEGIN
    --Inicialização de variáveis
    vr_cdcritic := 0;
    vr_horagera := 0;
    vr_contador := 0;
    vr_conttrai := 0;
    vr_dstexto  := NULL;
    vr_dscritic := NULL;
    vr_setlinha := NULL;
    vr_flgempre := FALSE;
    
    -- Inicializar o CLOB
    dbms_lob.createtemporary(pr_clob_ret, TRUE);
    dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);	
    
    --Hora geracao
    vr_horagera:= to_char(SYSDATE,'HH24MISS');
    
    -- Insere o cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root>');
    
    -- Leitura do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

    -- Adiciona o valor ao registro
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
    -- Identifica se retornou registro
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fecha o cursor
      CLOSE BTCH0001.cr_crapdat;
      
      -- Código da crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Sistema sem data de movimento';
      
      -- Força o erro
      RAISE vr_exc_erro;
      
    ELSE
      -- Fecha o cursor
      CLOSE BTCH0001.cr_crapdat;
      
    END IF;
   
    --Busca o lote do pagamento e seus respectivos filhos
    FOR rw_crappfp IN cr_crappfp(pr_rowidpfp
                                ,rw_crapdat.dtmvtolt) LOOP
    
      /*Se for FALSE é a primeira vez, então temos que acessar a crapemp e crapass
        para montar os headers*/
      IF vr_flgempre = FALSE THEN
        OPEN cr_info_pessoa(rw_crappfp.cdcooper
                           ,rw_crappfp.cdempres);
        FETCH cr_info_pessoa
        INTO rw_info_pessoa;
          
        IF cr_info_pessoa%NOTFOUND THEN
          CLOSE cr_info_pessoa;
          vr_cdcritic := 0;
          vr_dscritic := 'Não foi possível localizar as informações do cooperado';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_info_pessoa;
        END IF;
          
        OPEN cr_crapenc(rw_info_pessoa.cdcooper
                       ,rw_info_pessoa.nrdconta);
        FETCH cr_crapenc
        INTO rw_crapenc;
          
        IF cr_crapenc%NOTFOUND THEN
          CLOSE cr_crapenc;
          vr_cdcritic := 0;
          vr_dscritic := 'Não foi possível localizar o endereço do cooperado';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapenc;
        END IF;
        
        IF TRUNC(rw_crappfp.dtcredit) = TRUNC(rw_crapdat.dtmvtocd) THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Arquivo de retorno dos créditos disponível no próximo dia útil.';
          RAISE vr_exc_erro;          
        END IF;
        
        IF rw_crappfp.idsitapr = 1 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Necessário aprovação do lote para disponibilização de arquivo de retorno.';
          RAISE vr_exc_erro;          
        END IF;        
        
        vr_conttrai := vr_conttrai + 1;
        
        /************ HEADER DO ARQUIVO ************/
        vr_setlinha:= '085'||                                                                                            /* Banco*/
                      '0000' ||                                                                                          /* Lote */
                      '0'||                                                                                            /* Tp Registro */
                      '         '||                                                                                     /* Brancos (9) */
                      rw_info_pessoa.inpessoa||                                                                          /* Tp Inscricao*/	
                      gene0002.fn_mask(rw_info_pessoa.nrcpfcgc,'99999999999999' )||                                      /* CNPJ/CPF */
                      rpad(rw_info_pessoa.cdempres,20, ' ')||                                                            /* Nr Convenio (20) */
                      gene0002.fn_mask(to_number(gene0002.fn_mask(rw_info_pessoa.cdagectl,'9999' )|| '0' ), '999999' )|| /* Age Mantenedora*/
                      gene0002.fn_mask(rw_info_pessoa.nrdconta,'9999999999999')||                                        /* Cta+Dig */
                      ' ' ||                                                                                             /* Dig Verf Age/Cta*/
                      substr(rpad(rw_info_pessoa.nmprimtl,30, ' ' ),1 , 30)||                                            /* Nome Empresa */
                      substr(rpad(rw_info_pessoa.nmextcop,30, ' ' ),1 , 30)||                                            /* Nome Banco */
                      '          '||                                                                                     /* 15.0 */
                      '2' ||                                                                                             /* 16.0 */
                      to_char( SYSDATE, 'DDMMYYYY')||                                                                    /* 17.0 */
                      gene0002.fn_mask(vr_horagera,'999999' )||                                                          /* 18.0 */
                      gene0002.fn_mask(rw_crappfp.nrseqpag,'999999' )||                                                  /* 19.0 */
                      '084'||                                                                                            /* 20.0 */
                      '00000'||                                                                                          /* 21.0 */
                      LPAD(' ' , 20, ' ' )||                                                                             /* 22.0 */
                      LPAD(' ' , 20, ' ' )||                                                                             /* 23.0 */
                      LPAD(' ' , 29, ' ' )||                                                                             /* 24.0 */
                      chr(13) || chr(10);
          
        --Escrever Header do arquivo
        vr_dstexto := '<dados>
                         <cdseqlin>'|| vr_contador ||'</cdseqlin>
                         <dsdlinha>'|| vr_setlinha ||'</dsdlinha>
                       </dados>';
        
        pc_escreve_xml(vr_dstexto);
        
        vr_conttrai := vr_conttrai + 1;
        
        /************ HEADER DO LOTE ************/
        vr_setlinha := '085'||     							                                                                        /* Banco*/
                       '0001'||                                                                                          /* Lote */
                       '1'||                                                                                              /* Tp Registro */
                       'C'||                                                                                             /* Tp Operacao */
                       rw_crappfp.cdorigem||                                                                            /* Tp Servico */
                       '30'||                                                                                             /* FEBRABAN (2)*/
                       '043'||                                                                                            /* Versao Layout */
                       ' '||                                                                                              /* FEBRABAN (1)*/
                       rw_info_pessoa.inpessoa||                                                                          /* Tp Inscricao*/                        
                       gene0002.fn_mask(rw_info_pessoa.nrcpfcgc,'99999999999999')||                                      /* Nr Insc */
                       rpad(rw_info_pessoa.cdempres,20, ' ')||                                                            /* Nr Convenio (20) */
                       gene0002.fn_mask(to_number(gene0002.fn_mask(rw_info_pessoa.cdagectl,'9999' )|| '0' ), '999999' )|| /* Age Mantenedora*/
                       gene0002.fn_mask(rw_info_pessoa.nrdconta,'9999999999999')||                                        /* Cta+Dig */
                       ' '||                                                                                              /* Dig Verf Age/Cta*/
                       substr(rpad(rw_info_pessoa.nmprimtl,30, ' ' ),1 , 30)||                                            /* Nome Empresa */
                       lpad(' ' , 40, ' ' )||                                                                             /* Mensagem 1 */
                       substr(rpad(rw_crapenc.dsendere || ',' || rw_crapenc.nrendere,30, ' ' ),1 , 30)||                  /* endereco */
                       '00000'||                                                                                          /* Nr local */
                       lpad(' ' , 15, ' ' )||
                       substr(rpad(rw_crapenc.nmcidade,20, ' ' ),1 , 20)||                                                /* cidade */
                       gene0002.fn_mask(rw_crapenc.nrcepend,'99999999')||                                                 /* cep */
                       rw_crapenc.cdufende ||                                                                             /* sigla UF */
                       lpad(' ' , 18, ' ' )||
                       chr(13) || chr(10);      
        
        --Escrever Header do lote
        vr_dstexto := '<dados>
                         <cdseqlin>'|| vr_contador ||'</cdseqlin>
                         <dsdlinha>'|| vr_setlinha ||'</dsdlinha>
                       </dados>';
        
        pc_escreve_xml(vr_dstexto);
        
        vr_flgempre := TRUE;
                       
      END IF;
      
      vr_contador := vr_contador + 1; 
       
      vr_conttrai := vr_conttrai + 1;
      
      /************ SEGMENTO A ************/
      vr_setlinha := '085'||     							                                                                        
                     '0001'|| 
                     '3'||
                     gene0002.fn_mask(vr_contador,'99999')||
                     'A'||
                     '0'||
                     '00'||
                     '018'||
                     '085'||
                     gene0002.fn_mask(to_number(gene0002.fn_mask(rw_info_pessoa.cdagectl,'9999' )|| '0' ), '999999' )||
                     gene0002.fn_mask(rw_crappfp.nrdconta,'9999999999999')||
                     LPAD(' ' , 1, ' ' )||
                     substr(rpad(rw_crappfp.nmfuncio,30, ' ' ),1 , 30)||
                     gene0002.fn_mask(rw_crappfp.nrcpfcgc,'99999999999999999999')||
                     to_char(rw_crappfp.dtcredit, 'DDMMYYYY')||
                     'BRL'||
                     LPAD(' ' , 15, ' ' )||
                     gene0002.fn_mask(rw_crappfp.vllancto * 100,'999999999999999')||
                     LPAD(' ' , 20, ' ' )||
                     rw_crappfp.dtctreal|| 
                     gene0002.fn_mask(rw_crappfp.vllnreal * 100,'999999999999999')||
                     LPAD(' ' , 40, ' ' )||
                     LPAD(' ' , 2, ' ' )|| 
                     '00004'||                      
                     LPAD(' ' , 2, ' ' )|| 
                     LPAD(' ' , 3, ' ' )||
                     '0'||
                     gene0002.fn_mask(rw_crappfp.cdocorre,'9999999999')||
                     chr(13) || chr(10);
      
      --Escrever segmento A
      vr_dstexto := '<dados>
                       <cdseqlin>'|| vr_contador ||'</cdseqlin>
                       <dsdlinha>'|| vr_setlinha ||'</dsdlinha>
                     </dados>';
        
      pc_escreve_xml(vr_dstexto);
      
      vr_contador := vr_contador + 1;
       
      vr_conttrai := vr_conttrai + 1; 
      
      /************ SEGMENTO B ************/
      vr_setlinha := '085'||
                     '0001'||
                     '3'||
                     gene0002.fn_mask(vr_contador,'99999')||
                     'B'||
                     LPAD(' ' , 3, ' ' )||
                     '1'||
                     gene0002.fn_mask(rw_crappfp.nrcpfcgc,'99999999999999')||
                     LPAD(' ' , 30, ' ')||
                     LPAD('0' , 5, '0')||
                     LPAD(' ' , 15, ' ')||
                     LPAD(' ' , 15, ' ')||
                     LPAD(' ' , 20, ' ')||
                     LPAD('0' , 5, '0')||
                     LPAD('0' , 3, '0')||
                     LPAD(' ' , 2, ' ')||
                     LPAD('0' , 8, '0')||
                     LPAD('0' , 15, '0')||
                     LPAD('0' , 15, '0')||
                     LPAD('0' , 15, '0')||
                     LPAD('0' , 15, '0')||
                     LPAD('0' , 15, '0')||
                     LPAD(' ' , 15, ' ')||
                     LPAD('0' , 1, '0')||
                     LPAD(' ' , 6, ' ')||      		
                     LPAD(' ' , 8, ' ')||
                     chr(13) || chr(10);
       
      --Escrever segmento B
      vr_dstexto := '<dados>
                       <cdseqlin>'|| vr_contador ||'</cdseqlin>
                       <dsdlinha>'|| vr_setlinha ||'</dsdlinha>
                     </dados>';
        
      pc_escreve_xml(vr_dstexto);
      
      --Se retornou 1 significa que deve gerar o segmento Z
      IF rw_crappfp.flgsegmt = 1 THEN
        
        vr_contador := vr_contador + 1;  
        
        vr_conttrai := vr_conttrai + 1;
        
        /************ SEGMENTO Z ************/
        vr_setlinha := '085'||
                       '0001'||
                       '3'||
                       gene0002.fn_mask(vr_contador,'99999')||
                       'Z'||
                       LPAD(' ' , 64, ' ')||
                       rw_crappfp.dsprotoc||
                       LPAD(' ' , 127, ' ')||
                       gene0002.fn_mask(rw_crappfp.cdocorre,'9999999999')||
                       chr(13) || chr(10);
        
        --Escrever segmento Z
        vr_dstexto := '<dados>
                         <cdseqlin>'|| vr_contador ||'</cdseqlin>
                         <dsdlinha>'|| vr_setlinha ||'</dsdlinha>
                       </dados>';
          
        pc_escreve_xml(vr_dstexto);               
      END IF;
      
      vr_vllctpag := rw_crappfp.vllctpag ;
          
    END LOOP;  
    
    /************ TRAILLER DO LOTE ************/
    vr_setlinha := '085'||
                   '0001'|| 
                   '5'||
                   LPAD(' ' , 9, ' ')||  
                   gene0002.fn_mask(vr_conttrai,'999999')||
                   gene0002.fn_mask(vr_vllctpag * 100,'999999999999999999')|| 
                   LPAD('0' , 18, '0')||                               
                   LPAD('0' , 6, '0')||
                   LPAD(' ' , 165, ' ')||
                   LPAD(' ' , 10, ' ')||
                   chr(13) || chr(10);
    
    vr_contador := vr_contador + 1;      
    
    vr_conttrai := vr_conttrai + 1;   
    
    --Escrever trailler do lote
    vr_dstexto := '<dados>
                     <cdseqlin>'|| vr_contador ||'</cdseqlin>
                     <dsdlinha>'|| vr_setlinha ||'</dsdlinha>
                   </dados>';
          
    pc_escreve_xml(vr_dstexto);
    
    vr_contador := vr_contador + 1;      
    
    vr_conttrai := vr_conttrai + 1;
    
    /************ TRAILLER DO ARQUIVO ************/
    vr_setlinha := '085'||
                   '9999'|| 
                   '9'||
                   LPAD(' ' , 9, ' ')||  
                   '000001'||
                   gene0002.fn_mask(vr_conttrai,'999999')||
                   LPAD('0' , 6, '0')||                               
                   LPAD(' ' , 205, ' ')||                   
                   chr(13) || chr(10);
    
    --Escrever trailler do arquivo
    vr_dstexto := '<dados>
                     <cdseqlin>'|| vr_contador ||'</cdseqlin>
                     <dsdlinha>'|| vr_setlinha ||'</dsdlinha>
                   </dados>';
          
    pc_escreve_xml(vr_dstexto);                      
    
    pc_escreve_xml('</root>');
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina FOLH0002.pc_gera_retorno_cooperado. '||SQLERRM;  
      
  END pc_gera_retorno_cooperado;

END FOLH0002;
/
