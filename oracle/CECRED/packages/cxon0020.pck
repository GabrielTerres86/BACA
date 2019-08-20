CREATE OR REPLACE PACKAGE CECRED.cxon0020 AS

/*..............................................................................

   Programa: cxon0020                        Antigo: dbo/b1crap20.p
   Sistema : Caixa On-line
   Sigla   : CRED
   Autor   : Elton
   Data    : Outubro/2011                      Ultima atualizacao: 20/07/2018

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Transferencia e deposito entre cooperativas.

   Alteracoes: 23/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                17/04/2007 - Critica quando nao encontra cidade para
                             determinada agencia bancaria (Elton).

                23/04/2007 - Alterado para nao deixar fixo as informacoes do
                             Banco e Agencia do remetente (Elton).

                10/05/2007 - Criticar situacao da agencia destino  (Mirtes)

                29/01/2008 - Mostra o PAC do cooperado na autenticacao (Elton).

                19/02/2008 - Retirada critica que nao permite utilizacao de
                             TED's (Elton/Evandro).

                17/04/2008 - Tratamento horario TED (Diego)
                             Validacao de operador para TED (Evandro).

                22/12/2008 - Ajustes para unificacao dos bancos de dados
                             (Evandro).

                25/03/2009 - Retirado comentario dos campos craptvl.cdoperad e
                             craptvl.cdopeaut;
                           - Incluida critica no campo CPF/CNPJ do destinatario
                             do TED (Elton).

                25/05/2009 - Alteracao CDOPERAD (Kbase).

                26/08/2009 - Substituicao do campo banco/agencia da COMPE,
                             para o banco/agencia COMPE de DOC (cdagedoc e
                             cdbandoc) - (Sidnei - Precise).

                23/10/2009 - Alterada a procedure atualiza-doc-ted para enviar
                             TED¿s por mensageria - SPB (Fernando).

                04/05/2010 - Criar lote 11000 + caixa sempre que uma transa¿¿o
                             for efetuada (Fernando).

                31/05/2010 - Criada procedure valida-saldo para alertar quando
                             o saldo + limite de credito do remetente for menor
                             que o valor a ser enviado no DOC/TED (Fernando).

                24/06/2010 - Criticar o envio de TEDs entre cooperativas do
                             Sistema CECRED (Fernando).

                26/06/2010 - Ajustar chamada da b1wgen0046 para os TEDs via
                             SPB.
                             Criticar envio de TED C debito em conta com mesma
                             titularidade. Solicitar envio do TED D (Fernando).

                11/08/2010 - Retirar criticas da procedure atualiza-doc-ted
                             e colocar na procedure valida-valores (Fernando).

                24/09/2010 - Incluido parametro p-cod-id-transf (Guilherme).

                29/03/2011 - Incluido validacao de valores na verifica-operador
                             (Guilherme).

                17/05/2011 - Ajuste no comprovante de TED/DOC (Gabriel).

                25/08/2011 - Inclusao do parametro 'cod.rotina' na procedure
                             valida-saldo-conta (Diego).

                14/12/2011 - Incluido os parametro p-cod-rotina e p-coopdest na
                             procedure valida-saldo e na chamada da procedure
                             valida-saldo-conta (Elton).

                12/04/2012 - Inclusao do parametro "origem", na chamada da
                             procedure proc_envia_tec_ted. (Fabricio)

                11/05/2012 - Projeto TED Internet (David).

                22/11/2012 - Ajuste para utilizar campo crapdat.dtmvtocd no
                             lugar do crapdat.dtmvtolt. (Jorge)

                04/12/2012 - Incluir origem da mensagem no numero de controle
                            (Diego).

                15/03/2013 - Novo tratamento para Bancos que nao possuem
                             agencia (David Kruger).

                16/05/2013 - Incluso nova estrutura para buscar valor tarifa
                             utilizando b1wgen0153 (Daniel).

                20/05/2013 - Novo param. procedure 'grava-autenticacao-internet'
                            (Lucas).

                04/06/2013 - Incluso bloco de repeticao nas procedures enviar-ted
                             e atualiza-doc-tec ao efetuar lancamento na craplcm
                             (Daniel).

                23/07/2013 - Alterado lancamento tarifa nas procedures enviar-ted
                             e atualiza-doc-ted para utilizar procedure
                             lan-tarifa-online da b1wgen0153.p (Daniel).

               26/08/2013 - Convers¿o Progress para Oracle (Alisson - AMcom)

			   25/04/2016 - Remocao de caracteres invalidos no nome da agencia
							conforme solicitado no chamado 429584 (Kelvin)

               21/11/2016 - Alterado idorigem Mobile de 9 para 10.
                            PRJ335 - Analise de fraudes (Odirlei-AMcom)

               21/11/2016 - Rotina pc_executa_envio_ted - Inclusao de parametros.
                                   pc_envio_ted - Tratamento para gerar registro de analise de fraude
                            PRJ335 - Analise de fraudes (Odirlei-AMcom)

               12/12/2016 - Nao cobrar tarifa de TED quando a origem for do
                            BacenJud (Andrino - Mouts). Projeto 341-Bacenjud

               15/05/2018 - Bacenjud SM 1 - Heitor (Mouts)

			   25/06/2018 - Adicionado CPF/CNPJ e nome do favorecido no e-mail enviado em casos de fraude.
							(SCTASK0015124 - Kelvin).
               20/07/2018 - Alterações referentes ao projeto 475 - MELHORIAS SPB CONTINGÊNCIA
                            Everton Souza - Mouts
               01/09/2018 - Alterações referentes ao projeto 475 - MELHORIAS SPB CONTINGÊNCIA - SPRINT B
                            Marcelo Telles Coelho - Mouts

			   16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)

..............................................................................*/
  --  antigo tt-protocolo-ted
  TYPE typ_reg_protocolo_ted
        IS RECORD ( cdtippro crappro.cdtippro%TYPE
                   ,dtmvtolt crappro.dtmvtolt%TYPE
                   ,dttransa crappro.dttransa%TYPE
                   ,hrautent crappro.hrautent%TYPE
                   ,vldocmto crappro.vldocmto%TYPE
                   ,nrdocmto crappro.nrdocmto%TYPE
                   ,nrseqaut crappro.nrseqaut%TYPE
                   ,dsinform##1 crappro.dsinform##1%TYPE
                   ,dsinform##2 crappro.dsinform##2%TYPE
                   ,dsinform##3 crappro.dsinform##3%TYPE
                   ,dsprotoc crappro.dsprotoc%TYPE
                   ,nmprepos crappro.nmprepos%TYPE
                   ,nrcpfpre crappro.nrcpfpre%TYPE
                   ,nmoperad crapopi.nmoperad%TYPE
                   ,nrcpfope crappro.nrcpfope%TYPE
                   ,cdbcoctl crapcop.cdbcoctl%TYPE
                   ,cdagectl crapcop.cdagectl%TYPE);
  TYPE typ_tab_protocolo_ted IS TABLE OF typ_reg_protocolo_ted
       INDEX BY PLS_INTEGER;


  /* Procedure para buscar tarifa ted */
  PROCEDURE pc_busca_tarifa_ted (pr_cdcooper IN INTEGER --Codigo Cooperativa
                                ,pr_cdagenci IN INTEGER --Codigo Agencia
                                ,pr_nrdconta IN INTEGER --Numero da Conta
                                ,pr_vllanmto IN OUT NUMBER  --Valor Lancamento
                                ,pr_vltarifa OUT NUMBER --Valor Tarifa
                                ,pr_cdhistor OUT INTEGER --Historico da tarifa
                                ,pr_cdhisest OUT INTEGER --Historico estorno
                                ,pr_cdfvlcop OUT INTEGER --Codigo faixa valor cooperativa
                                ,pr_cdcritic OUT INTEGER       --C¿digo do erro
                                ,pr_dscritic OUT VARCHAR2);     --Descricao do erro

  -- Procedure para verificar os dados da TED
  PROCEDURE pc_verifica_dados_ted (pr_cdcooper IN INTEGER                --> Codigo Cooperativa
                                  ,pr_cdagenci IN INTEGER                --> Codigo Agencia
                                  ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                  ,pr_idorigem IN INTEGER                --> Identificador de origem
                                  ,pr_nrdconta IN INTEGER                --> Numero da Conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                  ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Codigo do banco
                                  ,pr_cdageban IN crapcti.cdageban%TYPE  --> Codigo da agencia bancaria
                                  ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> numero da conta transferencia destino
                                  ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> Nome do titular
                                  ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> Numero do cpf/cnpj do titular destino
                                  ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Identificador de tipo de pessoa
                                  ,pr_intipcta IN crapcti.intipcta%TYPE  --> identificador de tipo de conta
                                  ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lançamento
                                  ,pr_cdfinali IN INTEGER                --> Codigo de finalidade
                                  ,pr_dshistor IN VARCHAR2               --> Descriçao de historico
                                  ,pr_cdispbif IN crapcti.nrispbif%TYPE  --> Oito primeiras posicoes do cnpj.
                                  ,pr_idagenda IN INTEGER                --> Indicador de agendamento
                                  /* parametros de saida */
                                  ,pr_dstransa OUT VARCHAR2              --> Descrição de transação
                                  ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                                  ,pr_dscritic OUT VARCHAR2);            --> Descricao do erro


  --> Procedure para executar o envio da TED
  PROCEDURE pc_executa_envio_ted
                          (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Agencia
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Caixa Operador
                          ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador Autorizacao
                          ,pr_idorigem IN INTEGER                --> Origem
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                          ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta Remetente
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --> CPF operador juridico
                          ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Banco destino
                          ,pr_cdageban IN crapcti.cdageban%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Conta transferencia
                          ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> nome do titular destino
                          ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> CPF do titular destino
                          ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Tipo de pessoa
                          ,pr_intipcta IN crapcti.intipcta%TYPE  --> Tipo de conta
                          ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lançamento
                          ,pr_dstransf IN VARCHAR2               --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          ,pr_dshistor IN VARCHAR2               --> Descriçao do Histórico
                          ,pr_cdispbif IN INTEGER                --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0      --> Indicador se origem é do Mobile
                          ,pr_idagenda IN INTEGER                --> Tipo de agendamento
                          ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                          ,pr_dstransa IN VARCHAR2 DEFAULT NULL  --> Descrição da transacao no IBank/mobile
                          ,pr_iddispos IN VARCHAR2 DEFAULT NULL  --> Identif. do dispositivo mobile
                          ,pr_idportab IN NUMBER   DEFAULT 0     --> Indica uma transferencia de portabilidade (TEC de salário)
                          ,pr_nrridlfp IN NUMBER   DEFAULT 0     --> Indica o registro de lançamento da folha de pagamento, caso necessite devolução
                          -- saida
                          ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Retorna protocolo
                          ,pr_tab_protocolo_ted OUT cxon0020.typ_tab_protocolo_ted --> dados do protocolo
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2);            --> Descricao do erro

  --> Procedure para executar o envio da TED chamada pelo Progress
  PROCEDURE pc_executa_envio_ted_prog
                          (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Agencia
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Caixa Operador
                          ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador Autorizacao
                          ,pr_idorigem IN INTEGER                --> Origem
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                          ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta Remetente
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --> CPF operador juridico
                          ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Banco destino
                          ,pr_cdageban IN crapcti.cdageban%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Conta transferencia
                          ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> nome do titular destino
                          ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> CPF do titular destino
                          ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Tipo de pessoa
                          ,pr_intipcta IN crapcti.intipcta%TYPE  --> Tipo de conta
                          ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lançamento
                          ,pr_dstransf IN VARCHAR2               --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          ,pr_dshistor IN VARCHAR2               --> Descriçao do Histórico
                          ,pr_cdispbif IN INTEGER                --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0      --> Indicador se origem é do Mobile
                          ,pr_idagenda IN INTEGER                --> Tipo de agendamento
                          ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                          ,pr_dstransa IN VARCHAR2 DEFAULT NULL  --> Descrição da transacao no IBank/mobile
                          ,pr_iddispos IN VARCHAR2 DEFAULT NULL  --> Identif. do dispositivo mobile
                          -- saida
                          ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Retorna protocolo
                          ,pr_tab_protocolo_ted OUT CLOB --> dados do protocolo
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_enviar_ted (pr_cdcooper IN INTEGER  --> Cooperativa
                          ,pr_idorigem IN INTEGER  --> Origem
                          ,pr_cdageope IN INTEGER  --> PAC Operador
                          ,pr_nrcxaope IN INTEGER  --> Caixa Operador
                          ,pr_cdoperad IN VARCHAR2 --> Operador Autorizacao
                          ,pr_cdopeaut IN VARCHAR2 --> Operador Autorizacao
                          ,pr_vldocmto IN NUMBER   --> Valor TED
                          ,pr_nrdconta IN INTEGER  --> Conta Remetente
                          ,pr_idseqttl IN INTEGER  --> Titular
                          ,pr_nmprimtl IN VARCHAR2 --> Nome Remetente
                          ,pr_nrcpfcgc IN NUMBER   --> CPF/CNPJ Remetente
                          ,pr_inpessoa IN INTEGER  --> Tipo Pessoa Remetente
                          ,pr_cdbanfav IN INTEGER  --> Banco Favorecido
                          ,pr_cdagefav IN INTEGER  --> Agencia Favorecido
                          ,pr_nrctafav IN NUMBER   --> Conta Favorecido
                          ,pr_nmfavore IN VARCHAR2 --> Nome Favorecido
                          ,pr_nrcpffav IN NUMBER   --> CPF/CNPJ Favorecido
                          ,pr_inpesfav IN INTEGER  --> Tipo Pessoa Favorecido
                          ,pr_tpctafav IN INTEGER  --> Tipo Conta Favorecido
                          ,pr_dshistor IN VARCHAR2 --> Descriçao do Histórico
                          ,pr_dstransf IN VARCHAR2 --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER  --> Finalidade TED
                          ,pr_cdispbif IN INTEGER  --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0 --> Indicador se origem é do Mobile
                          ,pr_idagenda IN INTEGER  --> Tipo de agendamento
                          ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                          ,pr_dstransa IN VARCHAR2 DEFAULT NULL  --> Descrição da transacao no IBank/mobile
                          ,pr_iddispos IN VARCHAR2 DEFAULT NULL  --> Identif. do dispositivo mobile
                          ,pr_idportab IN NUMBER   DEFAULT 0     --> Indica uma transferencia de portabilidade (TEC de salário)
                          ,pr_nrridlfp IN NUMBER   DEFAULT 0     --> Indica o registro de lançamento da folha de pagamento, caso necessite devolução
                          -- saida
                          ,pr_nrdocmto OUT INTEGER --> Documento TED
                          ,pr_nrrectvl OUT ROWID   --> Autenticacao TVL
                          ,pr_nrreclcm OUT ROWID   --> Autenticacao LCM
                          ,pr_cdcritic OUT INTEGER  --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2 --> Descrição da critica
                          ,pr_des_erro OUT VARCHAR2 );

  /******************************************************************************/
  /**                  Procedure para validar TED                              **/
  /******************************************************************************/
  PROCEDURE pc_validar_ted ( pr_cdcooper IN INTEGER  --> Cooperativa
                            ,pr_idorigem IN INTEGER  --> Origem
                            ,pr_cdageope IN INTEGER  --> PAC Operador
                            ,pr_nrcxaope IN INTEGER  --> Caixa Operador
                            ,pr_vldocmto IN NUMBER   --> Valor TED
                            ,pr_nrdconta IN INTEGER  --> Conta Remetente
                            ,pr_idseqttl IN INTEGER  --> Titular
                            ,pr_nmprimtl IN VARCHAR2 --> Nome Remetente
                            ,pr_nrcpfcgc IN NUMBER   --> CPF/CNPJ Remetente
                            ,pr_inpessoa IN INTEGER  --> Tipo Pessoa Remetente
                            ,pr_cdbanfav IN INTEGER  --> Banco Favorecido
                            ,pr_cdagefav IN INTEGER  --> Agencia Favorecido
                            ,pr_nrctafav IN NUMBER   --> Conta Favorecido
                            ,pr_nmfavore IN VARCHAR2 --> Nome Favorecido
                            ,pr_nrcpffav IN NUMBER   --> CPF/CNPJ Favorecido
                            ,pr_inpesfav IN INTEGER  --> Tipo Pessoa Favorecido
                            ,pr_tpctafav IN INTEGER  --> Tipo Conta Favorecido
                            ,pr_cdfinali IN INTEGER  --> Finalidade TED
                            ,pr_dshistor IN VARCHAR2 --> Descriçao do Histórico
                            ,pr_cdispbif IN INTEGER  --> ISPB Banco Favorecido
                            ,pr_idagenda IN INTEGER  --> Indicador de agendamento
                            ,pr_des_erro OUT VARCHAR2);

  FUNCTION fn_verifica_lote_uso(pr_rowid rowid) RETURN NUMBER;

  --Bacenjud - SM 1
  PROCEDURE pc_executa_reenvio_ted
                          (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Agencia
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Caixa Operador
                          ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador Autorizacao
                          ,pr_idorigem IN INTEGER                --> Origem
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                          ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta Remetente
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --> CPF operador juridico
                          ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Banco destino
                          ,pr_cdageban IN crapcti.cdageban%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Conta transferencia
                          ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> nome do titular destino
                          ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> CPF do titular destino
                          ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Tipo de pessoa
                          ,pr_intipcta IN crapcti.intipcta%TYPE  --> Tipo de conta
                          ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lançamento
                          ,pr_dstransf IN VARCHAR2               --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          ,pr_dshistor IN VARCHAR2               --> Descriçao do Histórico
                          ,pr_cdispbif IN INTEGER                --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0      --> Indicador se origem é do Mobile
                          ,pr_idagenda IN INTEGER                --> Tipo de agendamento
                          ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                          ,pr_dstransa IN VARCHAR2 DEFAULT NULL  --> Descrição da transacao no IBank/mobile
                          -- saida
                          ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Retorna protocolo
                          ,pr_tab_protocolo_ted OUT cxon0020.typ_tab_protocolo_ted --> dados do protocolo
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2);            --> Descricao do erro
  --Fim Bacenjud - SM 1
END CXON0020;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cxon0020 AS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : CXON0020
    Sistema  : Procedimentos e funcoes das transacoes do caixa online
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Junho/2013.                   Ultima atualizacao: 01/03/2019

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo  : Procedimentos e funcoes das transacoes do caixa online

    Alteração : 14/03/2016 - Removido save point da procedure e alterado por rollback em
                             toda a transação caso ocorra problemas. SD 417330 (Kelvin).

                27/04/2016 - Adicionado tratamento para verificar isencao ou nao
                             de tarifa no envio de TED Eletrônica. PRJ 218/2 (Reinert).

                14/06/2016 - Ajuste para incluir o UPPER em campos de indice ao ler a tabela craptvl
                             (Adriano - SD 469449).

                22/07/2016 - Correção de xml sendo limpo após execução da rotina pc_executa_envio_ted_prog (Carlos)

                25/07/2016 - Ajuste para retornar corretamente o xml pois estava gerando problemas para
                             o progress receber os valores de data e nome de tags com o caracter "#"
                             (Adriano).

                29/08/2016 - #456682 Inclusão de verificação de fraude na rotina pc_validar_ted (Carlos)

                05/10/2016 - Implementei correcoes e alteracoes na pc_enviar_ted SD 535051. (Carlos Rafael Tanholi).

                21/11/2016 - Rotina pc_executa_envio_ted - Inclusao de parametros.
                                   pc_envio_ted - Tratamento para gerar registro de analise de fraude
                            PRJ335 - Analise de fraudes (Odirlei-AMcom)

                20/03/2017 - Ajuste para validar o cpf/cnpj de acordo com o inpessoa informado
                            (Adriano - SD 620221).

                25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur
							 (Adriano - P339).

                12/05/2017 - Segunda fase da melhoria 342 (Kelvin).

                08/06/2017 - Ajustes referentes ao novo catalogo do SPB (Lucas Ranghetti #668207)

				13/08/2017 - Ajustes realizados:
						     > Pegar o erro corretamente;
							 > Devolver critica através de parâmetros
							  (Jonata - RKAM / P364).

                12/12/2017 - Passar como texto o campo nrcartao na chamada da procedure
                             pc_gera_log_ope_cartao (Lucas Ranghetti #810576)
                             
                23/01/2019 - Tratar a geração do numero de documento para evitar duplicidade 
                             (Jose Dill Mouts INC0030535)             
                             
                01/03/2019 - Se o banco ainda não estiver operante no SPB (Data de inicio da operação), 
                             deve bloquear o envio da TED.
                             (Jonata - Mouts INC0031899).
                             
                19/06/2019 - Alteração na "pc_enviar_ted": Inclusão de tratamento para transferir da conta Transitória 
                             para a Conta Corrente quando o histórico for o 1406 - TRANSFERENCIA BLOQUEIO JUDICIAL.
                             P450.2 - BUG 22067 - Marcelo Elias Gonçalves/AMcom. 
                             
                16/07/2019 - Alteração na "pc_enviar_ted": Inclusão de tratamento para transferir da conta Transitória 
                             para a Conta Corrente quando o histórico for o 1406 - TRANSFERENCIA BLOQUEIO JUDICIAL.
                             (Validação feita somente para Contas em Prejuizo).
                             P450.2 - BUG 22067 - Marcelo Elias Gonçalves/AMcom.                                                          
			    
                25/06/2019 - Tratamento para não estourar o limite de crédito quando houver mais de um TED de uma mesma
                             conta encaminhada no mesmo momento.
                             (Jose Dill - Mout PRB0041934)
         
  ---------------------------------------------------------------------------------------------------------------*/

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.nmextcop
          ,crapcop.nrtelura
          ,crapcop.dsdircop
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.flgoppag
          ,crapcop.flgopstr
          ,crapcop.inioppag
          ,crapcop.fimoppag
          ,crapcop.iniopstr
          ,crapcop.fimopstr
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Buscar dados das agencias */
  CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%type
                    ,pr_cdagenci IN crapage.cdagenci%type) IS
    SELECT crapage.nmresage
          ,crapage.qtddaglf
    FROM crapage
    WHERE crapage.cdcooper = pr_cdcooper
    AND   crapage.cdagenci = pr_cdagenci;
  rw_crapage cr_crapage%ROWTYPE;

  /* Busca dos dados do associado */
  CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.inpessoa
          ,crapass.cdagenci
          ,crapass.vllimcre
          ,crapass.nrcpfcgc
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
     AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  --Selecionar informacoes dos terminais
  CURSOR cr_craptfn (pr_cdcoptfn IN craptfn.cdcooper%type
                    ,pr_nrterfin IN craptfn.nrterfin%type) IS
    SELECT craptfn.nrultaut
          ,craptfn.cdcooper
          ,craptfn.cdagenci
          ,craptfn.nrterfin
          ,craptfn.cdoperad
          ,craptfn.ROWID
    FROM craptfn
    WHERE craptfn.cdcooper = pr_cdcoptfn
    AND   craptfn.nrterfin = pr_nrterfin;
  rw_craptfn cr_craptfn%ROWTYPE;

  --Selecionar informacoes dos lotes
  CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                    ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                    ,pr_cdagenci IN craplot.cdagenci%TYPE
                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                    ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT craplot.dtmvtolt
          ,craplot.cdagenci
          ,craplot.cdbccxlt
          ,craplot.nrdolote
          ,craplot.nrseqdig
          ,craplot.rowid
    FROM   craplot craplot
    WHERE  craplot.cdcooper = pr_cdcooper
    AND    craplot.dtmvtolt = pr_dtmvtolt
    AND    craplot.cdagenci = pr_cdagenci
    AND    craplot.cdbccxlt = pr_cdbccxlt
    AND    craplot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;

  --Bacenjud - SM 1
  vr_reenvio NUMBER(1) := 0;

  /* Procedure para buscar tarifa ted */
  PROCEDURE pc_busca_tarifa_ted (pr_cdcooper IN INTEGER --Codigo Cooperativa
                                ,pr_cdagenci IN INTEGER --Codigo Agencia
                                ,pr_nrdconta IN INTEGER --Numero da Conta
                                ,pr_vllanmto IN OUT NUMBER  --Valor Lancamento
                                ,pr_vltarifa OUT NUMBER --Valor Tarifa
                                ,pr_cdhistor OUT INTEGER --Historico da tarifa
                                ,pr_cdhisest OUT INTEGER --Historico estorno
                                ,pr_cdfvlcop OUT INTEGER --Codigo faixa valor cooperativa
                                ,pr_cdcritic OUT INTEGER       --C¿digo do erro
                                ,pr_dscritic OUT VARCHAR2) IS   --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_tarifa_ted             Antigo: dbo/b1crap20.p/busca-tarifa-ted
  --  Sistema  : Procedure para buscar tarifa ted
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar tarifa ted
  --
  -- Alteracoes: 01/10/2015 - Retirado soma do parametro pr_vllanmto conforme era no progress (Odirlei-Amcom)
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_dssigtar VARCHAR2(20);
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;

      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_tab_erro GENE0001.typ_tab_erro;

      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      --Tipo de Dados para cursor cooperativa
      rw_crabcop  cr_crapcop%ROWTYPE;
      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Inicializar variaveis retorno
      pr_vltarifa:= 0;
      pr_cdhistor:= 0;
      pr_cdfvlcop:= 0;
      pr_cdhisest:= 0;

      --Selecionar associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      --Posicionar no proximo registro
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        vr_dscritic:= 'Associado nao cadastrado.';
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;

      /** Conta administrativa nao sofre tarifacao **/
      IF rw_crapass.inpessoa = 3 THEN
        RETURN;
      END IF;

      --Se for TAA
      IF pr_cdagenci = 91 THEN
        RETURN;
      ELSIF pr_cdagenci = 90 THEN  /** Internet **/
        --Pessoa Fisica
        IF rw_crapass.inpessoa = 1 THEN
          --Sigla tarifa
          vr_dssigtar:= 'TEDELETRPF';
        ELSE
          --Sigla tarifa
          vr_dssigtar:= 'TEDELETRPJ';
        END IF;
      ELSE  /** Caixa On-Line **/
        --Pessoa Fisica
        IF rw_crapass.inpessoa = 1 THEN
          --Sigla tarifa
          vr_dssigtar:= 'TEDCAIXAPF';
        ELSE
          --Sigla tarifa
          vr_dssigtar:= 'TEDCAIXAPJ';
        END IF;
      END IF;

      /*  Busca valor da tarifa sem registro*/
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                            ,pr_cdbattar  => vr_dssigtar  --Codigo Tarifa
                                            ,pr_vllanmto  => pr_vllanmto  --Valor Lancamento
                                            ,pr_cdprogra  => NULL         --Codigo Programa
                                            ,pr_cdhistor  => pr_cdhistor  --Codigo Historico
                                            ,pr_cdhisest  => pr_cdhisest  --Historico Estorno
                                            ,pr_vltarifa  => pr_vltarifa  --Valor tarifa
                                            ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                            ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                            ,pr_cdfvlcop  => pr_cdfvlcop  --Codigo faixa valor cooperativa
                                            ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                            ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                            ,pr_tab_erro  => vr_tab_erro); --Tabela erros
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          vr_cdcritic:= vr_tab_erro(1).cdcritic;
          vr_dscritic:= vr_tab_erro(1).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
        END IF;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0020.pc_busca_tarifa_ted. '||SQLERRM;
    END;
  END pc_busca_tarifa_ted;

  /******************************************************************************/
  /**                  Procedure para validar TED                              **/
  /******************************************************************************/
  PROCEDURE pc_validar_ted ( pr_cdcooper IN INTEGER  --> Cooperativa
                            ,pr_idorigem IN INTEGER  --> Origem
                            ,pr_cdageope IN INTEGER  --> PAC Operador
                            ,pr_nrcxaope IN INTEGER  --> Caixa Operador
                            ,pr_vldocmto IN NUMBER   --> Valor TED
                            ,pr_nrdconta IN INTEGER  --> Conta Remetente
                            ,pr_idseqttl IN INTEGER  --> Titular
                            ,pr_nmprimtl IN VARCHAR2 --> Nome Remetente
                            ,pr_nrcpfcgc IN NUMBER   --> CPF/CNPJ Remetente
                            ,pr_inpessoa IN INTEGER  --> Tipo Pessoa Remetente
                            ,pr_cdbanfav IN INTEGER  --> Banco Favorecido
                            ,pr_cdagefav IN INTEGER  --> Agencia Favorecido
                            ,pr_nrctafav IN NUMBER   --> Conta Favorecido
                            ,pr_nmfavore IN VARCHAR2 --> Nome Favorecido
                            ,pr_nrcpffav IN NUMBER   --> CPF/CNPJ Favorecido
                            ,pr_inpesfav IN INTEGER  --> Tipo Pessoa Favorecido
                            ,pr_tpctafav IN INTEGER  --> Tipo Conta Favorecido
                            ,pr_cdfinali IN INTEGER  --> Finalidade TED
                            ,pr_dshistor IN VARCHAR2 --> Descriçao do Histórico
                            ,pr_cdispbif IN INTEGER  --> ISPB Banco Favorecido
                            ,pr_idagenda IN INTEGER  --> Indicador de agendamento
                            ,pr_des_erro OUT VARCHAR2)IS --> Indicador se retornou com erro (OK ou NOK)

  /*---------------------------------------------------------------------------------------------------------------

      Programa : pc_validar_ted             Antigo: b1crap20/validar-ted
      Sistema  : Rotinas acessadas pelas telas de cadastros Web
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Junho/2015.                   Ultima atualizacao: 01/03/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para validar TED

      Alteração : 08/06/2015 - Conversão Progress -> Oracle (Odirlei-Amcom)

                  20/03/2017 - Ajuste para validar o cpf/cnpj de acordo com o inpessoa informado
                              (Adriano - SD 620221).

                  01/03/2019 - Se o banco ainda não estiver operante no SPB (Data de inicio da operação), 
                               deve bloquear o envio da TED.
                               (Jonata - Mouts INC0031899).

  ---------------------------------------------------------------------------------------------------------------*/
    ---------------> CURSORES <-----------------
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.inpessoa,
             crapass.nrcpfcgc
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Validar banco
    CURSOR cr_crapban (pr_cdispbif crapban.nrispbif%TYPE,
                       pr_cdbccxlt crapban.cdbccxlt%TYPE) IS
      SELECT flgdispb
            ,dtinispb
        FROM crapban
       WHERE (crapban.nrispbif = pr_cdispbif AND pr_cdbccxlt = 0)
         OR  (crapban.cdbccxlt = pr_cdbccxlt AND pr_cdbccxlt > 0);
    rw_crapban cr_crapban%ROWTYPE;

    -- Verificacao de cpf/cnpj fraudulento
    CURSOR cr_crapcbf(pr_tpfraude crapcbf.tpfraude%TYPE,
                      pr_dsfraude crapcbf.dsfraude%TYPE) IS
      SELECT 1
        FROM crapcbf
       WHERE tpfraude = pr_tpfraude
         AND UPPER(dsfraude) = UPPER(pr_dsfraude);
    rw_crapcbf cr_crapcbf%ROWTYPE;

    --Selecionar informacoes log transacoes no sistema
    CURSOR cr_craplgm(pr_cdcooper IN craplgm.cdcooper%type,
                      pr_nrdconta IN craplgm.nrdconta%type,
                      pr_idseqttl IN craplgm.idseqttl%type,
                      pr_dttransa IN craplgm.dttransa%type,
                      pr_dsorigem IN craplgm.dsorigem%type,
                      pr_cdoperad IN craplgm.cdoperad%type,
                      pr_flgtrans IN craplgm.flgtrans%type,
                      pr_dstransa IN craplgm.dstransa%TYPE) IS
      SELECT m.hrtransa
            ,i.dsdadatu
        FROM craplgm m
            ,craplgi i
       WHERE m.cdcooper = pr_cdcooper
         AND m.nrdconta = pr_nrdconta
         AND m.idseqttl = pr_idseqttl
         AND m.dsorigem = 'INTERNET'
         AND m.cdoperad = '996'
         AND m.dttransa = pr_dttransa
         AND i.nmdcampo = 'IP'
         AND m.cdcooper = i.cdcooper
         AND m.nrdconta = i.nrdconta
         AND m.idseqttl = i.idseqttl
         AND m.dttransa = i.dttransa
         AND m.hrtransa = i.hrtransa
         AND m.nrsequen = i.nrsequen
         AND m.dstransa = pr_dstransa
       ORDER BY m.progress_recid DESC;


    ------------> ESTRUTURAS DE REGISTRO <-----------

    --Tabela de memória de limites de horario
    vr_tab_limite INET0001.typ_tab_limite;
    vr_index      PLS_INTEGER;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    vr_tpfraude crapcbf.tpfraude%TYPE;
    vr_nrdipatu  VARCHAR2(1000);
    vr_des_corpo VARCHAR2(1000);
    vr_cpfcnpj   VARCHAR2(40);

    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

    vr_nrcxaope NUMBER;
    vr_flgretor BOOLEAN;
    vr_tppessoa INTEGER;
    vr_dstextab craptab.dstextab%TYPE;

  BEGIN

    IF pr_idorigem IN (3,4) THEN  /** 3-Internet  4-CASH/TAA **/
      vr_nrcxaope := pr_nrdconta || pr_idseqttl;
    ELSE
      vr_nrcxaope := pr_nrcxaope;
    END IF;

    --Eliminar erro
    CXON0000.pc_elimina_erro(pr_cooper      => pr_cdcooper
                            ,pr_cod_agencia => pr_cdageope
                            ,pr_nro_caixa   => vr_nrcxaope
                            ,pr_cdcritic    => vr_cdcritic
                            ,pr_dscritic    => vr_dscritic);

    vr_cdcritic := 0;
    vr_dscritic := NULL;

    --> Buscar dados cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    --> verificar se encontra registro
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    /*SD 244456 - VANESSA*/
    IF pr_cdfinali IN (99,99999,999) AND TRIM(pr_dshistor) IS NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Informe a descriçao do histórico';
      RAISE vr_exc_erro;
    END IF;
    /* FIM SD 244456*/

    --Buscar Horario Operacao
    INET0001.pc_horario_operacao (pr_cdcooper   => pr_cdcooper  -- Código Cooperativa
                                 ,pr_cdagenci   => pr_cdageope  -- Agencia do Associado
                                 ,pr_tpoperac   => 4 /* TED */  -- Tipo de Operacao (0=todos)
                                 ,pr_inpessoa   => pr_inpessoa  -- Tipo de Pessoa
                                 ,pr_idagenda   => 0             --Tipo de agendamento
                                 ,pr_cdtiptra   => 0             --Tipo de transferencia
                                 ,pr_tab_limite => vr_tab_limite --Tabelas de retorno de horarios limite
                                 ,pr_cdcritic   => vr_cdcritic    --Código do erro
                                 ,pr_dscritic   => vr_dscritic);  --Descricao do erro
    --Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    vr_index := vr_tab_limite.first;
    /* Agendamento de TED deve ser possível realizar em qualquer horário e dia,
       mesmo não sendo útil */
    IF vr_tab_limite.exists(vr_index) = FALSE  OR   -- Não encontrou
       ((vr_tab_limite(vr_index).idesthor = 1  OR   -- Estourou o horario
       vr_tab_limite(vr_index).iddiauti = 2)   AND
       NOT pr_idagenda IN(2,3))                THEN -- Não é dia util

      vr_cdcritic := 676; --> 676 - Horario esgotado para digitacao.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;

    -- Validar data cooper
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
       CLOSE btch0001.cr_crapdat;

       vr_cdcritic := 0;
       vr_dscritic := 'Sistema sem data de movimento.';
       RAISE vr_exc_erro;
    ELSE
       CLOSE btch0001.cr_crapdat;
    END IF;

    -- Validar cooperado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- verificar se localizou
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      vr_dscritic := NULL;
      RAISE vr_exc_erro;

    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Verificar nome
    IF TRIM(pr_nmprimtl) IS NULL  THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Nome do remetente incorreto';
      RAISE vr_exc_erro;
    END IF;

    -- Validar cpf ou cnpj
    GENE0005.pc_valida_cpf_cnpj (pr_nrcalcul => pr_nrcpfcgc --> Numero a ser verificado
                                ,pr_stsnrcal => vr_flgretor  --> Situacao
                                ,pr_inpessoa => vr_tppessoa);--> Tipo Inscricao Cedente

    IF vr_flgretor = FALSE THEN
      vr_cdcritic := 27; --> 027 - CPF/CNPJ com erro.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;

    -- Validar tipo de pessoa
    IF pr_inpessoa <> vr_tppessoa THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Tipo de pessoa do remetente incorreto.';
      RAISE vr_exc_erro;
    END IF;

    -- Validar codigo do banco favorecido
    IF pr_cdbanfav = rw_crapcop.cdbcoctl THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Nao e posssivel efetuar transferencia entre IFs do Sistema AILOS.';
      RAISE vr_exc_erro;
    END IF;

    -- Validar banco
    OPEN cr_crapban (pr_cdispbif => pr_cdispbif,
                     pr_cdbccxlt => pr_cdbanfav);
    FETCH cr_crapban INTO rw_crapban;

    IF cr_crapban%NOTFOUND THEN
      vr_cdcritic := 57; --> BANCO NAO CADASTRADO.
      vr_dscritic := NULL;
      CLOSE cr_crapban;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapban;

    -- Verificar se banco esta em operação no SPB
    IF rw_crapban.flgdispb = 0 /*FALSE*/ THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Banco do favorecido não opera no SPB.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verificar se banco já está em operação no SPB
    IF rw_crapban.flgdispb = 1 /*true*/      AND 
       trunc(SYSDATE) < rw_crapban.dtinispb  THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Banco nao iniciou as atividades no SPB. Data de inicio ' || to_char(rw_crapban.dtinispb,'DD/MM/RRRR') || '.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Validar agencia
    IF TRIM(pr_cdagefav) IS NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Agencia invalida.';
      RAISE vr_exc_erro;
    END IF;

    -- Verificar conta favorecida
    IF nvl(pr_nrctafav,0) = 0 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Conta do favorecido deve ser informada.';
      RAISE vr_exc_erro;
    END IF;
    IF TRIM(pr_nmfavore) IS NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Nome favorecido deve ser informado.';
      RAISE vr_exc_erro;
    END IF;

    IF pr_inpesfav = 1 THEN

      -- Valida CPF enviado
      GENE0005.pc_valida_cpf(pr_nrcalcul => pr_nrcpffav   --Numero a ser verificado
                            ,pr_stsnrcal => vr_flgretor);   --Situacao

    IF vr_flgretor = FALSE THEN
      vr_cdcritic := 27; --> 027 - CPF/CNPJ com erro.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;

    ELSE

      -- Valida CPF/CNPJ enviado
      GENE0005.pc_valida_cnpj(pr_nrcalcul => pr_nrcpffav   --Numero a ser verificado
                             ,pr_stsnrcal => vr_flgretor);   --Situacao

      IF vr_flgretor = FALSE THEN
        vr_cdcritic := 27; --> 027 - CPF/CNPJ com erro.
        vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;

    END IF;

    IF pr_inpesfav = 1 THEN
      vr_tpfraude := 2;
    ELSE
      vr_tpfraude := 3;
    END IF;

    vr_cpfcnpj := gene0002.fn_mask_cpf_cnpj(pr_nrcpffav, pr_inpesfav);

    -- Verifica se o cpf/cnpj eh fraudulento
    OPEN cr_crapcbf(vr_tpfraude, vr_cpfcnpj);
    FETCH cr_crapcbf INTO rw_crapcbf;

    IF cr_crapcbf%FOUND THEN

      CLOSE cr_crapcbf;

      -- Pegar ultimo ip de acesso
      FOR rw_craplgm IN cr_craplgm(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_dttransa => trunc(SYSDATE)
                                  ,pr_dsorigem => 'INTERNET'
                                  ,pr_cdoperad => '996'
                                  ,pr_flgtrans => 1
                                  ,pr_dstransa => 'Efetuado login de acesso a conta on-line.') LOOP
        vr_nrdipatu := rw_craplgm.dsdadatu;
        exit;
      END LOOP;

      -- monta o corpo do email
      vr_des_corpo := '<b>Atencao! Houve tentativa de TED fraudulento</b>.<br>' ||
                      '<b>IP:</b> ' || vr_nrdipatu || '<br>' ||
                      '<b>Cooperativa: </b>' || rw_crapcop.cdcooper || ' - ' || rw_crapcop.nmrescop || '<br>' ||
                      '<b>Conta: </b>'||gene0002.fn_mask_conta(pr_nrdconta) || '<br>' ||
                      '<b>CPF/CNPJ destino: </b>' || vr_cpfcnpj || '<br>' ||
                      '<b>Nome Favorecido: </b>' || pr_nmfavore;


      -- Envio de e-mail informando que houve a tentativa
      gene0003.pc_solicita_email(pr_cdcooper => pr_cdcooper,
                                 pr_cdprogra => 'CXON0020',
                                 pr_des_destino => 'monitoracaodefraudes@ailos.coop.br',
                                 pr_des_assunto => 'Atencao - Tentativa de TED para CPF/CNPJ em restritivo',
                                 pr_des_corpo => vr_des_corpo,
                                 pr_des_anexo => NULL,
                                 pr_flg_enviar => 'S',
                                 pr_des_erro => vr_dscritic);

      --Se ocorreu erro
      IF nvl(vr_cdcritic,0)<> 0 OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        vr_dscritic := 'Dados inconsistentes. Impossibilidade de realizar a transação.';
        RAISE vr_exc_erro;
    END IF;

    END IF;
    CLOSE cr_crapcbf;


    -- Ler tabela generica -  Tipo de conta
    vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => rw_crapcop.cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 00
                                              ,pr_cdacesso => 'TPCTACRTED'
                                              ,pr_tpregist => pr_tpctafav   );

    IF vr_dstextab IS NULL THEN
      vr_cdcritic := 17; --> Tipo de conta errado
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;

    -- Ler tabela generica
    vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => rw_crapcop.cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 00
                                              ,pr_cdacesso => 'FINTRFTEDS'
                                              ,pr_tpregist => pr_cdfinali   );

    IF vr_dstextab IS NULL THEN
      vr_cdcritic := 362; --> Finalidade nao cadastrada.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;

    -- Validar valor
    IF pr_vldocmto = 0 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Valor da TED deve ser informado.';
      RAISE vr_exc_erro;
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      --Criar Erro
      CXON0000.pc_cria_erro( pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdageope
                            ,pr_nrdcaixa => vr_nrcxaope
                            ,pr_cod_erro => vr_cdcritic
                            ,pr_dsc_erro => vr_dscritic
                            ,pr_flg_erro => TRUE
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      vr_dscritic := 'Nao foi possivel validar TED:'||SQLERRM;
      CXON0000.pc_cria_erro( pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdageope
                            ,pr_nrdcaixa => vr_nrcxaope
                            ,pr_cod_erro => 0
                            ,pr_dsc_erro => vr_dscritic
                            ,pr_flg_erro => TRUE
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      pr_des_erro := 'NOK';
  END pc_validar_ted;

  /******************************************************************************/
  /**                  Procedure para verificar os dados da TED                **/
  /******************************************************************************/
  PROCEDURE pc_verifica_dados_ted (pr_cdcooper IN INTEGER                --> Codigo Cooperativa
                                  ,pr_cdagenci IN INTEGER                --> Codigo Agencia
                                  ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Numero do caixa
                                  ,pr_idorigem IN INTEGER                --> Identificador de origem
                                  ,pr_nrdconta IN INTEGER                --> Numero da Conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                  ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Codigo do banco
                                  ,pr_cdageban IN crapcti.cdageban%TYPE  --> Codigo da agencia bancaria
                                  ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> numero da conta transferencia destino
                                  ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> Nome do titular
                                  ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> Numero do cpf/cnpj do titular destino
                                  ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Identificador de tipo de pessoa
                                  ,pr_intipcta IN crapcti.intipcta%TYPE  --> identificador de tipo de conta
                                  ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lançamento
                                  ,pr_cdfinali IN INTEGER                --> Codigo de finalidade
                                  ,pr_dshistor IN VARCHAR2               --> Descriçao de historico
                                  ,pr_cdispbif IN crapcti.nrispbif%TYPE  --> Oito primeiras posicoes do cnpj.
                                  ,pr_idagenda IN INTEGER                --> Indicador de agendamento
                                  /* parametros de saida */
                                  ,pr_dstransa OUT VARCHAR2              --> Descrição de transação
                                  ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do erro
  /*---------------------------------------------------------------------------------------------------------------

      Programa : pc_verifica_dados_ted             Antigo: b1wgen0015/verifica-dados-ted
      Sistema  : Rotinas acessadas pelas telas de cadastros Web
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Junho/2015.                   Ultima atualizacao: 08/06/2015

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para verificar os dados da TED

      Alteração : 08/06/2015 - Conversão Progress -> Oracle (Odirlei-Amcom)

  ---------------------------------------------------------------------------------------------------------------*/
    ---------------> CURSORES <-----------------
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.inpessoa,
             crapass.nrcpfcgc
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Buscar titulares
    CURSOR cr_crapttl ( pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE,
                        pr_idseqttl crapttl.idseqttl%TYPE)  IS
      SELECT ttl.nmextttl
            ,ttl.inpessoa
            ,ttl.idseqttl
            ,ttl.nrcpfcgc
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl ;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- buscar erro
    CURSOR cr_craperr(pr_cdcooper craperr.cdcooper%TYPE,
                      pr_cdagenci craperr.cdagenci%TYPE,
                      pr_nrdcaixa craperr.nrdcaixa%TYPE) IS
      SELECT craperr.dscritic
        FROM craperr
       WHERE craperr.cdcooper = pr_cdcooper
         AND craperr.cdagenci = pr_cdagenci
         AND craperr.nrdcaixa = pr_nrdcaixa;


    ------------> ESTRUTURAS DE REGISTRO <-----------

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

    vr_nmextttl crapttl.nmextttl%TYPE;
    vr_nrcpfcgc crapttl.nrcpfcgc%TYPE;
    vr_des_erro  VARCHAR2(200);


  BEGIN
    pr_dstransa := 'Transferencia de TED';

    --> Buscar dados cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    --> verificar se encontra registro
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'Registro de cooperativa nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- verificar se localizou
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado.';
      RAISE vr_exc_erro;

    ELSE
      CLOSE cr_crapass;
    END IF;

    -- se for pessoa fisica
    IF rw_crapass.inpessoa = 1 THEN
      -- buscar dados titular
      OPEN cr_crapttl (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_idseqttl => pr_idseqttl);
      FETCH cr_crapttl INTO rw_crapttl;

      IF cr_crapttl%NOTFOUND THEN
        CLOSE cr_crapttl;
        vr_dscritic := 'Titular nao cadastrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapttl;

      vr_nmextttl := rw_crapttl.nmextttl;
      vr_nrcpfcgc := rw_crapttl.nrcpfcgc;

    ELSE
      -- se for pessoa juridica, usar informações da crapass
      vr_nmextttl := rw_crapass.nmprimtl;
      vr_nrcpfcgc := rw_crapass.nrcpfcgc;
    END IF;

    cxon0020.pc_validar_ted( pr_cdcooper => pr_cdcooper    --> Cooperativa
                            ,pr_idorigem => pr_idorigem   --> Origem
                            ,pr_cdageope => pr_cdagenci   --> PAC Operador
                            ,pr_nrcxaope => pr_nrdcaixa   --> Caixa Operador
                            ,pr_vldocmto => pr_vllanmto   --> Valor TED
                            ,pr_nrdconta => pr_nrdconta   --> Conta Remetente
                            ,pr_idseqttl => pr_idseqttl   --> Titular
                            ,pr_nmprimtl => vr_nmextttl   --> Nome Remetente
                            ,pr_nrcpfcgc => vr_nrcpfcgc   --> CPF/CNPJ Remetente
                            ,pr_inpessoa => (CASE rw_crapass.inpessoa    --> Tipo Pessoa Remetente
                                               WHEN 1 THEN rw_crapass.inpessoa
                                               ELSE 2
                                             END)
                            ,pr_cdbanfav => pr_cddbanco   --> Banco Favorecido
                            ,pr_cdagefav => pr_cdageban   --> Agencia Favorecido
                            ,pr_nrctafav => pr_nrctatrf   --> Conta Favorecido
                            ,pr_nmfavore => pr_nmtitula   --> Nome Favorecido
                            ,pr_nrcpffav => pr_nrcpfcgc   --> CPF/CNPJ Favorecido
                            ,pr_inpesfav => pr_inpessoa   --> Tipo Pessoa Favorecido
                            ,pr_tpctafav => pr_intipcta   --> Tipo Conta Favorecido
                            ,pr_cdfinali => pr_cdfinali   --> Finalidade TED
                            ,pr_dshistor => pr_dshistor   --> Descriçao do Histórico
                            ,pr_cdispbif => pr_cdispbif   --> ISPB Banco Favorecido
                            ,pr_idagenda => pr_idagenda   --> Indicador de agendamento
                            ,pr_des_erro => vr_des_erro); --> Indicador se retornou com erro (OK ou NOK)

    IF vr_des_erro <> 'OK' THEN
      -- buscar erro
      vr_dscritic := NULL;
      OPEN cr_craperr(pr_cdcooper => pr_cdcooper,
                      pr_cdagenci => pr_cdagenci,
                      pr_nrdcaixa => pr_nrdconta||pr_idseqttl);
      FETCH cr_craperr INTO vr_dscritic;
      CLOSE cr_craperr;

      -- se nao encontrou a critica ou esta em branco, define mensagem
      vr_dscritic := nvl(vr_dscritic,'TED invalida.');
      RAISE vr_exc_erro;

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic = 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := 'Não foi possivel verificar dados TED';
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel verificar dados TED: '||SQLERRM;
  END pc_verifica_dados_ted;

  /******************************************************************************/
  /**                  Procedure para envio do TED                             **/
  /******************************************************************************/
  PROCEDURE pc_enviar_ted (pr_cdcooper IN INTEGER  --> Cooperativa
                          ,pr_idorigem IN INTEGER  --> Origem
                          ,pr_cdageope IN INTEGER  --> PAC Operador
                          ,pr_nrcxaope IN INTEGER  --> Caixa Operador
                          ,pr_cdoperad IN VARCHAR2 --> Operador Autorizacao
                          ,pr_cdopeaut IN VARCHAR2 --> Operador Autorizacao
                          ,pr_vldocmto IN NUMBER   --> Valor TED
                          ,pr_nrdconta IN INTEGER  --> Conta Remetente
                          ,pr_idseqttl IN INTEGER  --> Titular
                          ,pr_nmprimtl IN VARCHAR2 --> Nome Remetente
                          ,pr_nrcpfcgc IN NUMBER   --> CPF/CNPJ Remetente
                          ,pr_inpessoa IN INTEGER  --> Tipo Pessoa Remetente
                          ,pr_cdbanfav IN INTEGER  --> Banco Favorecido
                          ,pr_cdagefav IN INTEGER  --> Agencia Favorecido
                          ,pr_nrctafav IN NUMBER   --> Conta Favorecido
                          ,pr_nmfavore IN VARCHAR2 --> Nome Favorecido
                          ,pr_nrcpffav IN NUMBER   --> CPF/CNPJ Favorecido
                          ,pr_inpesfav IN INTEGER  --> Tipo Pessoa Favorecido
                          ,pr_tpctafav IN INTEGER  --> Tipo Conta Favorecido
                          ,pr_dshistor IN VARCHAR2 --> Descriçao do Histórico
                          ,pr_dstransf IN VARCHAR2 --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER  --> Finalidade TED
                          ,pr_cdispbif IN INTEGER  --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0 --> Indicador se origem é do Mobile
                          ,pr_idagenda IN INTEGER  --> Tipo de agendamento
                          ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                          ,pr_dstransa IN VARCHAR2 DEFAULT NULL  --> Descrição da transacao no IBank/mobile
                          ,pr_iddispos IN VARCHAR2 DEFAULT NULL  --> Identif. do dispositivo mobile
                          ,pr_idportab IN NUMBER   DEFAULT 0     --> Indica uma transferencia de portabilidade (TEC de salário)
                          ,pr_nrridlfp IN NUMBER   DEFAULT 0     --> Indica o registro de lançamento da folha de pagamento, caso necessite devolução
                          -- saida
                          ,pr_nrdocmto OUT INTEGER --> Documento TED
                          ,pr_nrrectvl OUT ROWID   --> Autenticacao TVL
                          ,pr_nrreclcm OUT ROWID   --> Autenticacao LCM
                          ,pr_cdcritic OUT INTEGER  --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2 --> Descrição da critica
                          ,pr_des_erro OUT VARCHAR2 )IS  --> Indicador se retornou com erro (OK ou NOK)

  /*---------------------------------------------------------------------------------------------------------------

      Programa : pc_enviar_ted             Antigo: b1crap20/enviar-ted
      Sistema  : Rotinas acessadas pelas telas de cadastros Web
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Junho/2015.                   Ultima atualizacao: 10/07/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para envio do TED

      Alteração : 08/06/2015 - Conversão Progress -> Oracle (Odirlei-Amcom)

                  04/02/2016 - Aumento no tempo de verificacao de TED duplicada. De 30 seg. para
                               10 min. (Jorge/David) - SD 397867

                  26/02/2016 - Inclusão de log de lote em uso - TARI0001.pc_gera_log_lote_uso (Odirlei-AMcom)

                  01/03/2016 - Removido tratamento de TED duplicada contendo select na craptvl sem nrdconta
                               e ajustado a critica (Odirlei-AMcom)

				08/03/2016 - Adicionados parâmetros para geraçao de LOG
                               (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)

                  14/03/2016 - Removido save point da procedure e alterado por rollback em
                               toda a transação caso ocorra problemas. SD 417330 (Kelvin).

                  14/06/2016 - Ajuste para incluir o UPPER em campos de indice ao ler a tabela craptvl
                              (Adriano - SD 469449).

                  05/10/2016 - Removi as chamadas para gera_log_lote_uso, ajustei os campos do insert na craptvl
                               movi a chamada da procedure gera_log_ope_cartao para antes do UPDATE na craplot.
                               SD 535051. (Carlos Rafael Tanholi).

				 14/11/2016 - Alterado cdorigem 9 para 10, novo cdorigem especifico para mobile
	                          PRJ335 - Analise de Fraude(Odirlei-AMcom)

                  21/11/2016 - Tratamento para gerar analise de fraude das TEDs.
                               PRJ335 - Analise de Fraude(Odirlei-AMcom)

                  26/04/2017 - Ajustado para nao realizar analise de fraude para efetivações
                               de agendamento. PRJ335 - Analise de Fraude(Odirlei-AMcom)

				  15/08/2017 - Ajuste para devolver critica através de parâmetros (Jonata - RKAM / P364).

                  12/12/2017 - Passar como texto o campo nrcartao na chamada da procedure
                               pc_gera_log_ope_cartao (Lucas Ranghetti #810576)
                               
                  24/08/2018 - Caso for TEDs de mesm titularidade passar pela monitoração (Problema com FRAUDE - TIAGO)                 
                  
                  28/08/2018 - Tratamento de exceção pra chamada AFRA0004.pc_monitora_operacao (Tiago - RITM0025395)

                  08/02/2019 - Realizado a inclusão de parametro para indicar que está sendo realizada uma 
                               transferencia de salário via portabilidade, de forma que o programa possa tratar
                               a requisição como TEC de salário. Foram realizados os ajustes também para que 
                               seja utilizado o histórico correto (Renato - Supero - Projeto 485)
                               
                  03/05/2019 - Alterado para que não seja gerada tarifa para transferencias de portabilidade de 
                               salário. (Renato Darosci - Supero - Projeto 485)

                  05/06/2019 - Tratar INC0011406 relacionado ao horario de aprovacao da TED (Diego).

                  19/06/2019 - Alteração na "pc_enviar_ted": Inclusão de tratamento para transferir da conta Transitória 
                               para a Conta Corrente quando o histórico for o 1406 - TRANSFERENCIA BLOQUEIO JUDICIAL.
                               P450.2 - BUG 22067 - Marcelo Elias Gonçalves/AMcom.
                  
                  21/06/2019 - Tratar INC0015554 - solucao de contorno (Diego).

                  10/07/2019 - Tratar INC0019779 relacionado a duplicidade do número de controle IF (Diego).

                  16/07/2019 - Alteração na "pc_enviar_ted": Inclusão de tratamento para transferir da conta Transitória 
                               para a Conta Corrente quando o histórico for o 1406 - TRANSFERENCIA BLOQUEIO JUDICIAL.
                               (Validação feita somente para Contas em Prejuizo).
                               P450.2 - BUG 22067 - Marcelo Elias Gonçalves/AMcom.             
                  
                  16/07/2019 - Tratar para que deposito bacenjud não execute rotina de saldo.
                               Jose Dill (Mouts). INC0020549 
  ---------------------------------------------------------------------------------------------------------------*/
    ---------------> CURSORES <-----------------
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.inpessoa,
             crapass.nrcpfcgc,
             crapass.nrdctitg,
             crapass.cdagenci,
             crapass.vllimcre
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Validar banco
    CURSOR cr_crapban (pr_cdispbif crapban.nrispbif%TYPE) IS
      SELECT flgdispb
        FROM crapban
       WHERE crapban.nrispbif = pr_cdispbif;
    rw_crapban cr_crapban%ROWTYPE;

    -- Verificar tranferencia de valores (DOC C, DOC D E TEDS)
    CURSOR cr_craptvl (pr_cdcooper craptvl.cdcooper%TYPE,
                       pr_nrctrlif craptvl.idopetrf%TYPE)IS
      SELECT flgtitul,
             tpdctadb
        FROM craptvl
       WHERE craptvl.cdcooper = pr_cdcooper
         AND craptvl.tpdoctrf = 3 /* TED SPB */
       AND UPPER(craptvl.idopetrf) = UPPER(pr_nrctrlif);
    rw_craptvl cr_craptvl%ROWTYPE;

    /* Validar transferencia duplicadas */
    CURSOR cr_craptvl_max( pr_cdcooper craptvl.cdcooper%TYPE,
                           pr_dtmvtocd craptvl.dtmvtolt%TYPE,
                           pr_cdageope craptvl.cdagenci%TYPE,
                           pr_nrdolote craptvl.nrdolote%TYPE,
                           pr_nrdconta craptvl.nrdconta%TYPE,
                           pr_cdbanfav craptvl.cdbccrcb%TYPE,
                           pr_cdagefav craptvl.cdagercb%TYPE,
                           pr_nrctafav craptvl.nrcctrcb%TYPE,
                           pr_vldocmto craptvl.vldocrcb%TYPE) IS
      SELECT MAX(hrtransa) hrtransa
        FROM craptvl
       WHERE craptvl.cdcooper = pr_cdcooper
         AND craptvl.dtmvtolt = pr_dtmvtocd
         AND craptvl.cdagenci = pr_cdageope
         AND craptvl.cdbccxlt = 11
         AND craptvl.nrdolote = pr_nrdolote
         AND craptvl.tpdoctrf = 3
         AND craptvl.nrdconta = pr_nrdconta
         AND craptvl.cdbccrcb = pr_cdbanfav
         AND craptvl.cdagercb = pr_cdagefav
         AND craptvl.nrcctrcb = pr_nrctafav
         AND craptvl.vldocrcb = pr_vldocmto;
    rw_craptvl_max cr_craptvl_max%ROWTYPE;


    -- Buscar dados historico
    CURSOR cr_craphis (pr_cdcooper craphis.cdcooper%TYPE,
                       pr_cdhistor craphis.cdhistor%TYPE)IS
      SELECT craphis.cdhistor
        FROM craphis
       WHERE craphis.cdcooper = pr_cdcooper
         AND craphis.cdhistor = pr_cdhistor;
    rw_craphis cr_craphis%ROWTYPE;

    -- Verificar se ja existe lcm
    CURSOR cr_craplcm (pr_cdcooper craplcm.cdcooper%TYPE,
                       pr_nrdconta craplcm.nrdctabb%TYPE,
                       pr_dtmvtolt craplcm.dtmvtolt%TYPE,
                       pr_cdagenci craplcm.cdagenci%TYPE,
                       pr_nrdolote craplcm.nrdolote%TYPE,
                       pr_nrdocmto craplcm.nrdocmto%TYPE)IS
      SELECT craplcm.hrtransa
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdbccxlt = 11
         AND craplcm.nrdolote = pr_nrdolote
         AND craplcm.nrdctabb = pr_nrdconta
         AND craplcm.nrdocmto = pr_nrdocmto;
    rw_craplcm cr_craplcm%ROWTYPE;

    -- Verificar lote
    CURSOR cr_craplot (pr_cdcooper  craplot.cdcooper%TYPE,
                       pr_dtmvtolt  craplot.dtmvtolt%TYPE,
                       pr_cdageope  craplot.cdagenci%TYPE,
                       pr_cdbccxlt  craplot.cdbccxlt%TYPE,
                       pr_nrdolote  craplot.nrdolote%TYPE)IS
      SELECT craplot.rowid,
             craplot.dtmvtolt,
             craplot.cdagenci,
             craplot.cdbccxlt,
             craplot.nrdolote,
             craplot.nrseqdig,
             craplot.cdhistor
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = pr_cdageope
         AND craplot.cdbccxlt = pr_cdbccxlt
         AND craplot.nrdolote = pr_nrdolote;

    rw_craplot_tvl cr_craplot%ROWTYPE;
    rw_craplot_lcm cr_craplot%ROWTYPE;
    vr_nrseqdig    craplot.nrseqdig%type;

    --> Buscar dados da tarifa
    CURSOR cr_craplat (pr_rowid ROWID) IS
      SELECT lat.cdlantar
        FROM craplat lat
       WHERE lat.rowid = pr_rowid;
    rw_craplat cr_craplat%ROWTYPE;

    ------------> ESTRUTURAS DE REGISTRO <-----------

    --Tabela de memória de limites de horario
    vr_tab_limite INET0001.typ_tab_limite;
    vr_index      PLS_INTEGER;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(4000);
    vr_tab_erro GENE0001.typ_tab_erro;
    vr_tab_saldo EXTR0001.typ_tab_saldos;

    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;

    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_exc_log  EXCEPTION;

    vr_nrcxaope NUMBER;
    vr_flgretor BOOLEAN;
    vr_tppessoa INTEGER;
		vr_idorigem INTEGER;
    vr_dstextab craptab.dstextab%TYPE;
    vr_nrdolote craplot.nrdolote%TYPE;
    vr_tpdolote craplot.tplotmov%TYPE;
    vr_cdhistor craplot.cdhistor%TYPE;
    vr_nrlotlcm craplot.nrdolote%TYPE;
    vr_tplotlcm craplot.tplotmov%TYPE;
    vr_nrseqted NUMBER;
    vr_nrctrlif VARCHAR2(200);
    vr_dslitera crapaut.dslitera%TYPE;
    vr_nrultseq crapaut.nrsequen%TYPE;
    vr_ultsqlcm crapaut.nrsequen%TYPE;
    vr_vllantar NUMBER;
    vr_vllanto_aux NUMBER;
    vr_cdhistar craphis.cdhistor%TYPE;
    vr_cdhisest craphis.cdhistor%TYPE;
    vr_cdhisted craphis.cdhistor%TYPE;
    vr_cdfvlcop INTEGER;
    vr_cdlantar craplat.cdlantar%TYPE;
    vr_hrtransa craplcm.hrtransa%TYPE;
    vr_email_dest VARCHAR2(500);
    vr_conteudo   VARCHAR2(4000);
    vr_nmarqlog   VARCHAR2(500);
    vr_flgerlog   VARCHAR2(50);
    vr_vlsldisp   NUMBER;
    vr_vltarifa   NUMBER;
    vr_debtarifa  BOOLEAN := FALSE;
    -- Everton - Mouts - Projeto 475
    vr_trace_nmmensagem tbspb_msg_enviada.nmmensagem%TYPE;
    vr_nrseq_mensagem10 tbspb_msg_enviada_fase.nrseq_mensagem%type;
    vr_nrseq_mensagem20 tbspb_msg_enviada_fase.nrseq_mensagem%type;
    vr_nrseq_mensagem_fase tbspb_msg_enviada_fase.nrseq_mensagem_fase%type := null;
    vr_flvldhor            NUMBER;
    vr_aux_exisdoc NUMBER;
    -- Renato Supero - P485 - Indica se é uma TED ou TEC de salário
    vr_flgctsal   BOOLEAN := FALSE; 
    vr_idtected   NUMBER;  -- Indicador para formar o número de controle da IF

    --Rowid lancamento tarifa
    vr_rowid_craplat ROWID;

	vr_qtacobra   INTEGER;
	vr_fliseope   INTEGER;

    vr_idanalise_fraude tbgen_analise_fraude.idanalise_fraude%TYPE;

    vr_incrineg INTEGER;
    vr_tab_retorno LANC0001.typ_reg_retorno;
    
    vr_inprejuz BOOLEAN; -- Indica se a conta corrente está em prejuízo

    ---------------- SUB-ROTINAS ------------------
    -- Procedimento para inserir o lote e não deixar tabela lockada
    PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                              pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                              pr_cdagenci IN craplot.cdagenci%TYPE,
                              pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                              pr_nrdolote IN craplot.nrdolote%TYPE,
                              pr_tplotmov IN craplot.tplotmov%TYPE,
                              pr_cdhistor IN craplot.cdhistor%TYPE DEFAULT 0,
                              pr_cdoperad IN craplot.cdoperad%TYPE,
                              pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                              pr_cdopecxa IN craplot.cdopecxa%TYPE,
                              pr_craplot  OUT cr_craplot%ROWTYPE,
                              pr_dscritic OUT VARCHAR2)IS

      -- Pragma - abre nova sessao para tratar a atualizacao
      PRAGMA AUTONOMOUS_TRANSACTION;

      rw_craplot cr_craplot%ROWTYPE;
      vr_nrdolote craplot.nrdolote%TYPE;

    BEGIN
      vr_nrdolote := pr_nrdolote;

          -- verificar lote
          OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                           pr_dtmvtolt  => pr_dtmvtolt,
                           pr_cdageope  => pr_cdageope,
                           pr_cdbccxlt  => pr_cdbccxlt,
                           pr_nrdolote  => vr_nrdolote);
          FETCH cr_craplot INTO rw_craplot;

      IF cr_craplot%NOTFOUND THEN
        -- criar registros de lote na tabela
        INSERT INTO craplot
            (dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             tplotmov,
             cdcooper,
             cdoperad,
             nrdcaixa,
             cdopecxa,
             nrseqdig,
             cdhistor)
          VALUES
            (pr_dtmvtolt,
             pr_cdagenci,
             pr_cdbccxlt,
             vr_nrdolote,
             pr_tplotmov,  -- tplotmov
             pr_cdcooper,
             pr_cdoperad,
             pr_nrdcaixa,
             pr_cdopecxa,
             1,            -- nrseqdig
             pr_cdhistor)
           RETURNING ROWID,
                     craplot.dtmvtolt,
                     craplot.cdagenci,
                     craplot.cdbccxlt,
                     craplot.nrdolote,
                     craplot.nrseqdig
                INTO rw_craplot.rowid,
                     rw_craplot.dtmvtolt,
                     rw_craplot.cdagenci,
                     rw_craplot.cdbccxlt,
                     rw_craplot.nrdolote,
                     rw_craplot.nrseqdig;
        COMMIT;
      END IF;

      CLOSE cr_craplot;
      pr_craplot := rw_craplot;

    EXCEPTION
      WHEN OTHERS THEN
        IF cr_craplot%ISOPEN THEN
          CLOSE cr_craplot;
        END IF;

        ROLLBACK;
        -- se ocorreu algum erro durante a criac?o
        pr_dscritic := 'Erro ao inserir/atualizar lote '||rw_craplot.nrdolote||': '||SQLERRM;
    END pc_insere_lote;

    -------------------- Programa Principal -----------------
  BEGIN
    IF pr_idorigem IN (3,4) THEN  /** 3-Internet  4-CASH/TAA **/
      vr_nrcxaope := pr_nrdconta || pr_idseqttl;
    ELSE
      vr_nrcxaope := pr_nrcxaope;
    END IF;

    --Eliminar erro
    CXON0000.pc_elimina_erro(pr_cooper      => pr_cdcooper
                            ,pr_cod_agencia => pr_cdageope
                            ,pr_nro_caixa   => vr_nrcxaope
                            ,pr_cdcritic    => vr_cdcritic
                            ,pr_dscritic    => vr_dscritic);

    vr_cdcritic := 0;
    vr_dscritic := NULL;

    --> Buscar dados cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    --> verificar se encontra registro
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Validar data cooper
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
       CLOSE btch0001.cr_crapdat;

      vr_cdcritic := 0;
      vr_dscritic := 'Sistema sem data de movimento.';
      RAISE vr_exc_erro;
    ELSE
       CLOSE btch0001.cr_crapdat;
    END IF;

    IF rw_crapcop.flgoppag = 0 /*FALSE*/ AND  -- Não operando com o pag. (camara de compensacao)
       rw_crapcop.flgopstr = 0 /*FALSE*/ THEN -- Não opera com o str.
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperativa nao esta operando no SPB.';
      RAISE vr_exc_erro;
    END IF;

    -- verificar caixa
    IF nvl(pr_cdageope,0) = 0   OR
       nvl(pr_nrcxaope,0) = 0   OR
       pr_cdoperad IS NULL  THEN
      vr_cdcritic := 0;
      vr_dscritic := 'ERRO!!! PA ZERADO. FECHE O CAIXA E AVISE O CPD.';
      RAISE vr_exc_erro;
    END IF;

    -- Validar cooperado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- verificar se localizou
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      vr_dscritic := NULL;
      RAISE vr_exc_erro;

    ELSE
      CLOSE cr_crapass;
    END IF;

    vr_nrdolote := 23000 + pr_nrcxaope;
    vr_tpdolote := 25;
    vr_cdhistor := 523;
    /* Lote para debito em CC*/
    vr_nrlotlcm := 11000 + pr_nrcxaope;
    vr_tplotlcm := 1;
    rw_craplot_tvl := NULL;

    -- Procedimento para inserir o lote e não deixar tabela lockada
	--Bacenjud - SM 1
    IF vr_reenvio = 0 THEN
    pc_insere_lote (pr_cdcooper => rw_crapcop.cdcooper,
                    pr_dtmvtolt => rw_crapdat.dtmvtocd,
                    pr_cdagenci => pr_cdageope,
                    pr_cdbccxlt => 11,
                    pr_nrdolote => vr_nrdolote,
                    pr_tplotmov => vr_tpdolote,
                    pr_cdhistor => vr_cdhistor,
                    pr_cdoperad => pr_cdoperad,
                    pr_nrdcaixa => pr_nrcxaope,
                    pr_cdopecxa => pr_cdoperad,
                    pr_dscritic => vr_dscritic,
                    pr_craplot  => rw_craplot_tvl);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    END IF;
	--Fim Bacenjud - SM 1

    -- Marcelo Telles Coelho - Projeto 475 - SPRINT B
    -- Passou a utiliza a SSPB0001.fn_nrdocmto_nrctrlif
    -- /* Busca a proxima sequencia do campo CRAPMAT.NRSEQTED */
    -- vr_nrseqted := fn_sequence( 'CRAPMAT'
    --                            ,'NRSEQTED'
    --                            ,rw_crapcop.cdcooper
    --                            ,'N');
    -- -- retornar numero do documento
    pr_nrdocmto := SSPB0001.fn_nrdocmto_nrctrlif;
    --
    -- INC0030535 - Validar se ja existe número de documento (Jose Dill - Mouts)
    vr_aux_exisdoc := 0;
    Select count(*) into vr_aux_exisdoc 
    From Craptvl tvl
    Where tvl.cdcooper = rw_crapcop.cdcooper
    and   tvl.tpdoctrf = 3
    and   tvl.nrdocmto = pr_nrdocmto;
    --
    IF  vr_aux_exisdoc > 0 THEN
        For vr_cont IN 1..5 Loop
          
        
          pr_nrdocmto := SSPB0001.fn_nrdocmto_nrctrlif;
          
          -- Validar se existe
          vr_aux_exisdoc := 0;
          Select count(*) into vr_aux_exisdoc 
          From Craptvl tvl
          Where tvl.cdcooper = rw_crapcop.cdcooper
          and   tvl.tpdoctrf = 3
          and   tvl.nrdocmto = pr_nrdocmto;
          --
          IF vr_aux_exisdoc = 0 THEN
             Exit;
          END IF;   
          --
        End Loop;
    END IF;  

    IF vr_aux_exisdoc > 0  THEN
      IF pr_idagenda <> 2 THEN --TED Online
        vr_cdcritic := 0;
        vr_dscritic := 'Não foi possível efetuar a operação. Tente novamente.'; 
        RAISE vr_exc_erro;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Não foi possível efetuar a operação.'||'CRAPTVL: Coop - '
                                                             ||rw_crapcop.cdcooper||
                                                             ' Tipo: 3'||
                                                             ' Documento: '||pr_nrdocmto; 
        RAISE vr_exc_erro;        
      END IF;
    END IF;    
    -- Fim INC0030535

    -- Se for uma transação de portabilidade de salário (P485 - Renato Darosci - Supero)
    IF NVL(pr_idportab,0) = 1 THEN
      -- Indica como 2 por configurar uma TEC
      vr_idtected := 2;
    ELSE
      -- Indicar como 1 por configurar como uma TED
      vr_idtected := 1;
    END IF;
      
    /* Se alterar numero de controle, ajustar procedure atualiza-doc-ted */
    vr_nrctrlif := vr_idtected||to_char(rw_crapdat.dtmvtocd,'RRMMDD')
                      ||to_char(rw_crapcop.cdagectl,'fm0000')
                       -- Marcelo Telles Coelho - Projeto 475 - SPRINT B
                       -- Buscar o NRDOCMTO para evitar duplicidadr de NumCtrlIF
                       -- || to_char(SYSDATE,'sssss')
                       --   /* para evitar duplicidade devido paralelismo */
                      ||to_char(pr_nrdocmto,'fm00000000');
    -- Fim Projeto 475

    IF pr_flmobile = 1 THEN /* Canal Mobile */
      vr_nrctrlif := vr_nrctrlif ||'M';
    ELSIF pr_idorigem = 1 THEN /* Origem BacenJud - Ayllos */
      vr_nrctrlif := vr_nrctrlif ||'A';
    ELSE /* Canal InternetBank */
      vr_nrctrlif := vr_nrctrlif ||'I';
    END IF;

    -- Verificar tranferencia de valores (DOC C, DOC D E TEDS)
    OPEN cr_craptvl (pr_cdcooper => rw_crapcop.cdcooper,
                     pr_nrctrlif => vr_nrctrlif);
    FETCH cr_craptvl INTO rw_craptvl;
    -- se localizou
    IF cr_craptvl%FOUND THEN
      CLOSE cr_craptvl;
      vr_cdcritic := 0;
      vr_dscritic := 'ERRO!!! NR. DOCUMENTO DUPLICADO, TENTE NOVAMENTE.';
      RAISE vr_exc_erro;
    END IF;

    IF pr_idagenda = 1 THEN

	  /* Garantir o horario de funcionamento do SPB */
	  IF sspb0003.fn_valida_horario_ted(pr_cdcooper => pr_cdcooper) then
         vr_cdcritic := 0;
         vr_dscritic := 'Operação deve ser realizada dentro do horário estabelecido para transferências na data atual.';
         RAISE vr_exc_erro; 
      END IF; 

      /* Controle para envio de 2 TEDs iguais pelo ambiente Mobile */
      OPEN cr_craptvl_max( pr_cdcooper => rw_crapcop.cdcooper,
                           pr_dtmvtocd => rw_crapdat.dtmvtocd,
                           pr_cdageope => pr_cdageope,
                           pr_nrdolote => vr_nrdolote,
                           pr_nrdconta => pr_nrdconta,
                           pr_cdbanfav => pr_cdbanfav,
                           pr_cdagefav => pr_cdagefav,
                           pr_nrctafav => pr_nrctafav,
                           pr_vldocmto => pr_vldocmto);
      FETCH cr_craptvl_max INTO rw_craptvl_max;

      -- se ja existe um lançamento com os mesmos dados em menos de 10 minutos (600 seg) apresentar alerta
      IF cr_craptvl_max%FOUND AND
        (to_char(SYSDATE,'SSSSS') - nvl(rw_craptvl_max.hrtransa,0)) <= 600 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Ja existe TED de mesmo valor e favorecido. ' ||
                       'Consulte extrato ou tente novamente em 10 min.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_craptvl_max;

    END IF;

	--Bacenjud - SM 1
    IF vr_reenvio = 0 THEN
    /* Grava uma autenticacao */
    CXON0000.pc_grava_autenticacao_internet
                          (pr_cooper       => pr_cdcooper     --> Codigo Cooperativa
                          ,pr_nrdconta     => pr_nrdconta     --> Numero da Conta
                          ,pr_idseqttl     => pr_idseqttl     --> Sequencial do titular
                          ,pr_cod_agencia  => pr_cdageope     --> Codigo Agencia
                          ,pr_nro_caixa    => pr_nrcxaope     --> Numero do caixa
                          ,pr_cod_operador => pr_cdoperad     --> Codigo Operador
                          ,pr_valor        => pr_vldocmto     --> Valor da transacao
                          ,pr_docto        => pr_nrdocmto     --> Numero documento
                          ,pr_operacao     => FALSE           --> Indicador Operacao Debito
                          ,pr_status       => '1'             --> Status da Operacao - Online
                          ,pr_estorno      => FALSE           --> Indicador Estorno
                          ,pr_histor       => vr_cdhistor     --> Historico Debito
                          ,pr_data_off     => NULL            --> Data Transacao
                          ,pr_sequen_off   => 0               --> Sequencia
                          ,pr_hora_off     => 0               --> Hora transacao
                          ,pr_seq_aut_off  => 0               --> Sequencia automatica
                          ,pr_cdempres     => NULL            --> Descricao Observacao
                          ,pr_literal      => vr_dslitera     --> Descricao literal lcm
                          ,pr_sequencia    => vr_nrultseq     --> Sequencia Autenticacao
                          ,pr_registro     => pr_nrrectvl     --> ROWID do registro debito
                          ,pr_cdcritic     => vr_cdcritic     --> Codigo do erro
                          ,pr_dscritic     => vr_dscritic);   --> Descricao do erro

    --Se ocorreu erro
    IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Everton - Mouts - Projeto 475
    -- Fase 10 - controle mensagem SPB
    sspb0003.pc_grava_trace_spb(pr_cdfase                 => 10
                               ,pr_idorigem               => 'E'
                               ,pr_nmmensagem             => 'MSG_TEMPORARIA'
                               ,pr_nrcontrole             => vr_nrctrlif
                               ,pr_nrcontrole_str_pag     => NULL
                               ,pr_nrcontrole_dev_or      => NULL
                               ,pr_dhmensagem             => sysdate
                               ,pr_insituacao             => 'OK'
                               ,pr_dsxml_mensagem         => null
                               ,pr_dsxml_completo         => null
                               ,pr_nrseq_mensagem_xml     => null
                               ,pr_nrdconta               => pr_nrdconta
                               ,pr_cdcooper               => pr_cdcooper
                               ,pr_cdproduto              => 30 -- TED
                               ,pr_nrseq_mensagem         => vr_nrseq_mensagem10
                               ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                               ,pr_dscritic               => vr_dscritic
                               ,pr_des_erro               => vr_des_erro);
    -- Se ocorreu erro
    IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levantar Excecao
      vr_cdcritic := 0;
      RAISE vr_exc_erro;
    END IF;
    --> Para as origens InternetBank e Mobile,
    --> Deve ser gerado o registro de analise de fraude antes de
    --> realizar a operação
    IF pr_idorigem IN (3) AND
       pr_idagenda <> 2   THEN --> Nao gerar analise para agendamentos

      IF pr_flmobile = 1 THEN
			  vr_idorigem := 10; --> MOBILE
      ELSE
        vr_idorigem := pr_idorigem;
      END IF;

      vr_idanalise_fraude := NULL;
      --> Rotina para Inclusao do registro de analise de fraude
      AFRA0001.pc_Criar_Analise_Antifraude( pr_cdcooper    => pr_cdcooper
                                          ,pr_cdagenci    => pr_cdageope
                                          ,pr_nrdconta    => pr_nrdconta
                                          ,pr_cdcanal     => vr_idorigem
                                          ,pr_iptransacao => pr_iptransa
                                          ,pr_dtmvtolt    => rw_crapdat.dtmvtocd
                                          ,pr_cdproduto   => 30 --> TED
										                      ,pr_cdoperacao  => 12 --> TED Eletronica
                                          ,pr_dstransacao => pr_dstransa
                                          ,pr_tptransacao => 1 --> Online
                                          ,pr_iddispositivo => pr_iddispos
                                          ,pr_idanalise_fraude => vr_idanalise_fraude
                                          ,pr_dscritic   => vr_dscritic);
      vr_dscritic := NULL;
    ELSE
      -- Everton - Mouts - Projeto 475
      -- Se não entrou na rotina para Inclusao do registro de analise de fraude
      -- mesmo assim gerar mensagem para controle
      -- Fase 20 - controle mensagem SPB
      IF pr_idagenda = 2 THEN
        vr_trace_nmmensagem := 'Agend.Aprov.OFSAA';
      ELSE
        vr_trace_nmmensagem := 'Não utiliza OFSAA';
      END IF;
      --
      sspb0003.pc_grava_trace_spb(pr_cdfase                 => 20
                                 ,pr_nmmensagem             => vr_trace_nmmensagem
                                 ,pr_nrcontrole             => vr_nrctrlif
                                 ,pr_nrcontrole_str_pag     => NULL
                                 ,pr_nrcontrole_dev_or      => NULL
                                 ,pr_dhmensagem             => sysdate
                                 ,pr_insituacao             => 'OK'
                                 ,pr_dsxml_mensagem         => null
                                 ,pr_dsxml_completo         => null
                                 ,pr_nrseq_mensagem_xml     => null
                                 ,pr_nrdconta               => pr_nrdconta
                                 ,pr_cdcooper               => pr_cdcooper
                                 ,pr_cdproduto              => 30 -- TED
                                 ,pr_nrseq_mensagem         => vr_nrseq_mensagem20
                                 ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                 ,pr_dscritic               => vr_dscritic
                                 ,pr_des_erro               => vr_des_erro);
      -- Se ocorreu erro
      IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levantar Excecao
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
    END IF;
    --
    END IF;
    ELSE
      -- Everton - Mouts - Projeto 475
      -- Fase 10 - controle mensagem SPB
      sspb0003.pc_grava_trace_spb(pr_cdfase                 => 10
                                 ,pr_idorigem               => 'E'
                                 ,pr_nmmensagem             => 'MSG_TEMPORARIA'
                                 ,pr_nrcontrole             => vr_nrctrlif
                                 ,pr_nrcontrole_str_pag     => NULL
                                 ,pr_nrcontrole_dev_or      => NULL
                                 ,pr_dhmensagem             => sysdate
                                 ,pr_insituacao             => 'OK'
                                 ,pr_dsxml_mensagem         => null
                                 ,pr_dsxml_completo         => null
                                 ,pr_nrseq_mensagem_xml     => null
                                 ,pr_nrdconta               => pr_nrdconta
                                 ,pr_cdcooper               => pr_cdcooper
                                 ,pr_cdproduto              => 30 -- TED
                                 ,pr_nrseq_mensagem         => vr_nrseq_mensagem10
                                 ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                 ,pr_dscritic               => vr_dscritic
                                 ,pr_des_erro               => vr_des_erro);
      -- Se ocorreu erro
      IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levantar Excecao
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;
      -- Fase 20 - controle mensagem SPB
      sspb0003.pc_grava_trace_spb(pr_cdfase                 => 20
                                 ,pr_nmmensagem             => 'Não utiliza OFSAA'
                                 ,pr_nrcontrole             => vr_nrctrlif
                                 ,pr_nrcontrole_str_pag     => NULL
                                 ,pr_nrcontrole_dev_or      => NULL
                                 ,pr_dhmensagem             => sysdate
                                 ,pr_insituacao             => 'OK'
                                 ,pr_dsxml_mensagem         => null
                                 ,pr_dsxml_completo         => null
                                 ,pr_nrseq_mensagem_xml     => null
                                 ,pr_nrdconta               => pr_nrdconta
                                 ,pr_cdcooper               => pr_cdcooper
                                 ,pr_cdproduto              => 30 -- TED
                                 ,pr_nrseq_mensagem         => vr_nrseq_mensagem20
                                 ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                 ,pr_dscritic               => vr_dscritic
                                 ,pr_des_erro               => vr_des_erro);
      -- Se ocorreu erro
      IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levantar Excecao
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;
    --
    END IF;
	--Fim Bacenjud - SM 1

    
      vr_nrseqdig := fn_sequence('CRAPLOT'
						                    ,'NRSEQDIG'
						                    ,''||rw_crapcop.cdcooper||';'
							                     ||to_char(rw_craplot_tvl.dtmvtolt,'DD/MM/RRRR')||';'
							                     ||rw_craplot_tvl.cdagenci||';'
							                     ||rw_craplot_tvl.cdbccxlt||';'
							                     ||rw_craplot_tvl.nrdolote);

    FOR vr_contador IN 1..10 LOOP
       BEGIN
  
      INSERT INTO craptvl
                (craptvl.cdcooper
                ,craptvl.tpdoctrf
                ,craptvl.idopetrf
                ,craptvl.nrdconta
                ,craptvl.idseqttl
                ,craptvl.cpfcgemi
                ,craptvl.nmpesemi
                ,craptvl.nrdctitg
                ,craptvl.cdbccrcb
                ,craptvl.cdagercb
                ,craptvl.cpfcgrcb
                ,craptvl.nmpesrcb
                ,craptvl.cdbcoenv
                ,craptvl.vldocrcb
                ,craptvl.dtmvtolt
                ,craptvl.hrtransa
                ,craptvl.nrdolote
                ,craptvl.cdagenci
                ,craptvl.cdbccxlt
                ,craptvl.nrdocmto
                ,craptvl.nrseqdig
                ,craptvl.nrcctrcb
                ,craptvl.cdfinrcb
                ,craptvl.tpdctacr
                ,craptvl.tpdctadb
                ,craptvl.dshistor
                ,craptvl.cdoperad
                ,craptvl.cdopeaut
                ,craptvl.flgespec
                ,craptvl.flgtitul
                ,craptvl.flgenvio
                ,craptvl.nrispbif
                ,craptvl.nrautdoc
                ,craptvl.flgpesdb
                ,craptvl.flgpescr
                ,craptvl.idanafrd
                ,craptvl.idmsgenv
                ,craptvl.nrridlfp -- Id lançamento folha
               )
         VALUES (rw_crapcop.cdcooper     --> craptvl.cdcooper
                ,3                       --> craptvl.tpdoctrf
                ,vr_nrctrlif             --> craptvl.idopetrf
                ,pr_nrdconta             --> craptvl.nrdconta
                ,pr_idseqttl             --> craptvl.idseqttl
                ,pr_nrcpfcgc             --> craptvl.cpfcgemi
                ,upper(pr_nmprimtl)      --> craptvl.nmpesemi
                ,rw_crapass.nrdctitg     --> craptvl.nrdctitg
                ,pr_cdbanfav             --> craptvl.cdbccrcb
                ,pr_cdagefav             --> craptvl.cdagercb
                ,pr_nrcpffav             --> craptvl.cpfcgrcb
                ,upper(pr_nmfavore)      --> craptvl.nmpesrcb
                ,rw_crapcop.cdbcoctl     --> craptvl.cdbcoenv
                ,pr_vldocmto             --> craptvl.vldocrcb
                ,rw_crapdat.dtmvtocd     --> craptvl.dtmvtolt
                ,gene0002.fn_busca_time  --> craptvl.hrtransa
                ,vr_nrdolote             --> craptvl.nrdolote
                ,pr_cdageope             --> craptvl.cdagenci
                ,11                      --> craptvl.cdbccxlt
                ,pr_nrdocmto             --> craptvl.nrdocmto
                ,vr_nrseqdig             --> craptvl.nrseqdig 
                ,pr_nrctafav             --> craptvl.nrcctrcb
                ,pr_cdfinali             --> craptvl.cdfinrcb
                ,pr_tpctafav             --> craptvl.tpdctacr
                ,1  /** Conta Corrente craptvl.tpdctadb**/
                ,pr_dshistor             --> craptvl.dshistor
                ,pr_cdoperad             --> craptvl.cdoperad
                ,pr_cdopeaut             --> craptvl.cdopeaut
                ,0 /*FALSE*/             --> craptvl.flgespec
                ,0 /*FALSE*/             --> craptvl.flgtitul
                ,1 /*true*/              --> craptvl.flgenvio
                ,pr_cdispbif             --> craptvl.nrispbif
                ,vr_nrultseq             --> craptvl.nrautdoc
                ,(CASE pr_inpessoa       --> craptvl.flgpesdb
                    WHEN 1 THEN 1 /*TRUE*/
                    ELSE 0        /*FALSE*/
                  END)
                ,(CASE pr_inpesfav       --> craptvl.flgpescr
                    WHEN 1 THEN 1 /*TRUE*/
                    ELSE 0        /*FALSE*/
                  END)
                ,vr_idanalise_fraude     --> craptvl.idanafrd
                ,vr_nrseq_mensagem10 --> craptvl.idmsgenv
                ,pr_nrridlfp
                )
        RETURNING craptvl.tpdctadb, craptvl.flgtitul
             INTO rw_craptvl.tpdctadb, rw_craptvl.flgtitul;
                
           EXIT; -- sair do loop, inseriu com sucesso     
                
    EXCEPTION
               
         WHEN dup_val_on_index THEN 
           
           -- se for o ultima tentativa, aborta a transacao
           IF vr_contador = 10 THEN
              IF  pr_idagenda <> 2 THEN --TED Online
                  vr_dscritic := 'Não foi possível efetuar a operação. Tente novamente.'; 
                  RAISE vr_exc_erro;
              ELSE  
                  vr_dscritic := 'Não foi possivel inserir transferencia: '||SQLERRM;
                  RAISE vr_exc_erro;
              END IF;    
           ELSE 
              -- Busca novo numero de documento
               pr_nrdocmto := SSPB0001.fn_nrdocmto_nrctrlif;
          
              CONTINUE; -- Tenta inserir novamente
           END IF;
         
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possivel inserir transferencia: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
       
    END LOOP;

    -- Indicar que a transação não é uma transferencia de salário(TEC)   (Renato - Supero - P485)
    vr_flgctsal := FALSE;
    
	--Bacenjud - SM 1
    IF vr_reenvio = 0 THEN
    ----------- LANÇAMENTO -----------
    rw_craplot_lcm := NULL;
    -- Criação do lote para lançamento
    pc_insere_lote (pr_cdcooper => rw_crapcop.cdcooper,
                    pr_dtmvtolt => rw_crapdat.dtmvtocd,
                    pr_cdagenci => pr_cdageope,
                    pr_cdbccxlt => 11,
                    pr_nrdolote => vr_nrlotlcm,
                    pr_tplotmov => vr_tplotlcm,
                    pr_cdoperad => pr_cdoperad,
                    pr_nrdcaixa => pr_nrcxaope,
                    pr_cdopecxa => pr_cdoperad,
                    pr_craplot  => rw_craplot_lcm,
                    pr_dscritic => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- inicializar valor
    vr_vllanto_aux := 1;

    -- Se não for transferencia de portabilidade de salário (Renato - Supero - P485)
    IF NVL(pr_idportab,0) = 0 THEN
      
    -- Rotina para buscar valor tarifa TED/DOC
    CXON0020.pc_busca_tarifa_ted (pr_cdcooper => rw_crapcop.cdcooper --> Codigo Cooperativa
                                 ,pr_cdagenci => pr_cdageope         --> Codigo Agencia
                                 ,pr_nrdconta => pr_nrdconta         --> Numero da Conta
                                 ,pr_vllanmto => vr_vllanto_aux      --> Valor Lancamento
                                 ,pr_vltarifa => vr_vllantar         --> Valor Tarifa
                                 ,pr_cdhistor => vr_cdhistar         --> Historico da tarifa
                                 ,pr_cdhisest => vr_cdhisest         --> Historico estorno
                                 ,pr_cdfvlcop => vr_cdfvlcop         --> Codigo Filial Cooperativa
                                 ,pr_cdcritic => vr_cdcritic         --> Codigo do erro
                                 ,pr_dscritic => vr_dscritic);       --> Descricao do erro
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    -- Se for bloqueio judicial (bacenjud), utiliza o historico 1406-TR.BLOQ.JUD
    IF pr_tpctafav = 9 THEN
      vr_cdhisted := 1406;
    ELSE
    -- definir historico de ted
    vr_cdhisted := 555;
    END IF;

    ELSE
      -- Portabilidade não deve cobrar tarifa
      vr_vllantar := 0;    
    
      -- Histórico da TED/TEC de transferencia de salário de portabilidade
      vr_cdhisted := 2944; -- NOSSA REMESSA TEC COMPE CECRED - CONTA SALARIO
      
      -- Indicar que está realizando uma TEC de Salário
      vr_flgctsal := TRUE;
    END IF;

    /* Grava uma autenticacao */
    CXON0000.pc_grava_autenticacao_internet
                          (pr_cooper       => pr_cdcooper     --> Codigo Cooperativa
                          ,pr_nrdconta     => pr_nrdconta     --> Numero da Conta
                          ,pr_idseqttl     => pr_idseqttl     --> Sequencial do titular
                          ,pr_cod_agencia  => pr_cdageope     --> Codigo Agencia
                          ,pr_nro_caixa    => pr_nrcxaope     --> Numero do caixa
                          ,pr_cod_operador => pr_cdoperad     --> Codigo Operador
                          ,pr_valor        => pr_vldocmto     --> Valor da transacao
                          ,pr_docto        => pr_nrdocmto     --> Numero documento
                          ,pr_operacao     => TRUE            --> Indicador Operacao Debito
                          ,pr_status       => '1'             --> Status da Operacao - Online
                          ,pr_estorno      => FALSE           --> Indicador Estorno
                          ,pr_histor       => vr_cdhisted     --> Historico Debito
                          ,pr_data_off     => NULL            --> Data Transacao
                          ,pr_sequen_off   => 0               --> Sequencia
                          ,pr_hora_off     => 0               --> Hora transacao
                          ,pr_seq_aut_off  => 0               --> Sequencia automatica
                          ,pr_cdempres     => NULL            --> Descricao Observacao
                          ,pr_literal      => vr_dslitera     --> Descricao literal lcm
                          ,pr_sequencia    => vr_ultsqlcm     --> Sequencia Autenticacao
                          ,pr_registro     => pr_nrreclcm     --> ROWID do registro debito
                          ,pr_cdcritic     => vr_cdcritic     --> Codigo do erro
                          ,pr_dscritic     => vr_dscritic);   --> Descricao do erro
    --Se ocorreu erro
    IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    -- Buscar dados historico
    OPEN cr_craphis (pr_cdcooper => rw_crapcop.cdcooper,
                     pr_cdhistor => vr_cdhisted);
    FETCH cr_craphis INTO rw_craphis;
    -- se não encontrar dados do historico
    IF cr_craphis%NOTFOUND THEN
      vr_cdcritic := 526; -- 526 - Historico nao encontrado.
      vr_dscritic := NULL;
      CLOSE cr_craphis;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craphis;

    -- Verifico se ja existe registro com mesmo nrdocmto, se existir
    -- buscar ultimo sequencial de TED na crapmat
    OPEN cr_craplcm ( pr_cdcooper => rw_crapcop.cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_dtmvtolt => rw_crapdat.dtmvtocd,
                      pr_cdagenci => pr_cdageope,
                      pr_nrdolote => vr_nrlotlcm,
                      pr_nrdocmto => pr_nrdocmto);

    FETCH cr_craplcm INTO rw_craplcm;
    -- se localizar
    IF cr_craplcm%FOUND THEN
      /* Busca a proxima sequencia do campo CRAPMAT.NRSEQTED */
      vr_nrseqted := fn_sequence( 'CRAPMAT'
                                 ,'NRSEQTED'
                                 ,rw_crapcop.cdcooper
                                 ,'N');
      -- retornar numero do documento
      pr_nrdocmto := vr_nrseqted;

    END IF;
    CLOSE cr_craplcm;

    -- Se for BacenJud nao deve validar saldo INC0020549  
    IF NVL(pr_tpctafav,0) <> 9 THEN 
    /*PRB0041934 - Incluída a chamada da rotina que verifica saldo antes da inclusao do lançamento, devido
      ao problema do sistema permitir a inclusão de dois TEDs de uma mesma conta ao mesmo tempo, sendo que a 
      soma dos valores de TEDs deveria estourar o saldo, o que nao estava ocorrendo em algumas situações.  */
    --Limpar tabela saldo e erro
    vr_tab_saldo.DELETE;
    vr_tab_erro.DELETE;
    /** Verifica se possui saldo para fazer a operacao **/
    EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => rw_crapcop.cdcooper
                                ,pr_rw_crapdat => rw_crapdat
                                ,pr_cdagenci   => pr_cdageope
                                ,pr_nrdcaixa   => pr_nrcxaope
                                ,pr_cdoperad   => pr_cdoperad
                                ,pr_nrdconta   => pr_nrdconta
                                ,pr_vllimcre   => rw_crapass.vllimcre
                                ,pr_tipo_busca => 'A' --> tipo de busca(A-dtmvtoan)
                                ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                ,pr_flgcrass   => FALSE
                                ,pr_des_reto   => vr_dscritic
                                ,pr_tab_sald   => vr_tab_saldo
                                ,pr_tab_erro   => vr_tab_erro);

    --Se ocorreu erro
    IF vr_dscritic = 'NOK' THEN
      -- Tenta buscar o erro no vetor de erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informacao na pr_tab_erro, Conta: '||pr_nrdconta;
      END IF;

      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    --Verificar o saldo retornado
    IF vr_tab_saldo.Count = 0 THEN
      --Montar mensagem erro
      vr_cdcritic:= 0;
      vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      --Total disponivel recebe valor disponivel + limite credito
      vr_vlsldisp:= nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) + nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
      -- log item
      /*Neste momento considera o valor do TED mais o valor da Tarifa em relação ao saldo
        disponível (antecipa uma validação), pois o lançamento ainda nao foi realizado na craplcm */      
      IF (pr_vldocmto + nvl(vr_vllantar,0)) > vr_vlsldisp THEN
        --Montar mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao ha saldo suficiente para a operacao.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;         
    /*FIM PRB0041934*/
    END IF;   
    
    

    vr_hrtransa := gene0002.fn_busca_time;

      vr_nrseqdig := fn_sequence('CRAPLOT'
						                    ,'NRSEQDIG'
						                    ,''||rw_crapcop.cdcooper||';'
							                     ||to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR')||';'
							                     ||rw_craplot_lcm.cdagenci||';'
							                     ||rw_craplot_lcm.cdbccxlt||';'
							                     ||rw_craplot_lcm.nrdolote);
    
    LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => rw_crapcop.cdcooper                  
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtocd               
                                      ,pr_hrtransa => vr_hrtransa                       
                                      ,pr_cdagenci => pr_cdageope                       
                                      ,pr_cdbccxlt => 11                                
                                      ,pr_nrdolote => rw_craplot_lcm.nrdolote           
                                      ,pr_nrdconta => pr_nrdconta                       
                                      ,pr_nrdctabb => pr_nrdconta                       
                                      ,pr_nrdctitg => to_char(pr_nrdconta,'fm00000000') 
                                      ,pr_nrdocmto => pr_nrdocmto                       
                                      ,pr_cdhistor => rw_craphis.cdhistor               
                                      ,pr_nrseqdig => vr_nrseqdig                       
                                      ,pr_vllanmto => pr_vldocmto                       
                                      ,pr_vldoipmf => 0                                 
                                      ,pr_nrautdoc => vr_ultsqlcm                       
                                      ,pr_cdpesqbb => 'CRAP020'
                                      ,pr_incrineg => vr_incrineg
                                      ,pr_tab_retorno => vr_tab_retorno
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
                                      
    IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
      
      IF vr_cdcritic = 92 THEN -- Lançamento duplicado
        vr_dscritic := 'Não foi possivel enviar TED, tente novamente ou comunique seu PA.';
        RAISE vr_exc_erro;
      ELSE 
        vr_dscritic := 'Não foi possivel gerar lcm:'||SQLERRM;
        RAISE vr_exc_erro;
      END IF;
    END IF;
    
    -- Verifica se a conta está em prejuízo
    vr_inprejuz := PREJ0003.fn_verifica_preju_conta(pr_cdcooper => rw_crapcop.cdcooper
                                                  , pr_nrdconta => pr_nrdconta);    
    -- Apenas para conta prejuizo
    IF vr_inprejuz THEN    
      --TRANSFERENCIA BLOQUEIO JUDICIAL
      IF rw_craphis.cdhistor = 1406 THEN
        -- Se não há saldo suficiente na conta transitória
        IF PREJ0003.fn_sld_cta_prj(pr_cdcooper => rw_crapcop.cdcooper, pr_nrdconta => pr_nrdconta) < pr_vldocmto THEN 
           vr_dscritic:= 'Não foi possível gerar lcm: conta corrente em prejuízo sem saldo suficiente no Bloqueados Prejuízo.';
           RAISE vr_exc_erro;
        -- Se há saldo suficiente na conta transitória   
        ELSE
          vr_dscritic:= NULL;
          vr_cdcritic:= NULL;
          --
          --Efetua a Transferência da Transitória para a Conta Corrente    
          PREJ0003.pc_gera_transf_cta_prj(pr_cdcooper => rw_crapcop.cdcooper   
                                        , pr_nrdconta => pr_nrdconta                                    
                                        , pr_vllanmto => pr_vldocmto
                                        , pr_dtmvtolt => rw_crapdat.dtmvtocd                                                                                                          
                                        , pr_cdcritic => vr_cdcritic
                                        , pr_dscritic => vr_dscritic);                                                       
          --
          IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
             vr_dscritic:= 'Não foi possível gerar lcm: erro ao transferir o valor do Bloqueados Prejuízo para a Conta Corrente.';
             RAISE vr_exc_erro;
          END IF;
        END IF;   
      END IF; 
    END IF;

    IF vr_vllantar <> 0 THEN
		  /* Verificar isenção ou não de tarifa */
		  TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => rw_crapcop.cdcooper -- Cooperativa
																					,pr_cdoperad => '888'               -- Operador
																					,pr_cdagenci => 1                   -- PA
																					,pr_cdbccxlt => 100                 -- Banco
																					,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data de movimento
																					,pr_cdprogra => 'CXON0020'          -- Cód. do programa
																					,pr_idorigem => 2                   -- Id. de origem
																					,pr_nrdconta => pr_nrdconta         -- Número da conta
																					,pr_tipotari => 12                  -- Tipo de tarifa 12 - TED Eletrônico
																					,pr_tipostaa => 0                   -- Tipo TAA
																					,pr_qtoperac => 1                   -- Quantidade de operações
																					,pr_qtacobra => vr_qtacobra         -- Quantidade de operações a serem tarifadas
																					,pr_fliseope => vr_fliseope         -- Identificador de isenção de tarifa (0 - nao isenta/1 - isenta)
																					,pr_cdcritic => vr_cdcritic         -- Cód. da crítica
																					,pr_dscritic => vr_dscritic);       -- Desc. da crítica

      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Exececao
        RAISE vr_exc_erro;
      END IF;

      -- Buscar dados historico
      OPEN cr_craphis (pr_cdcooper => rw_crapcop.cdcooper,
                       pr_cdhistor => vr_cdhistar);
      FETCH cr_craphis INTO rw_craphis;
      -- se não encontrar dados do historico
      IF cr_craphis%NOTFOUND THEN
        vr_cdcritic := 526; -- 526 - Historico nao encontrado.
        vr_dscritic := NULL;
        CLOSE cr_craphis;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_craphis;

      --Limpar tabela saldo e erro
      vr_tab_saldo.DELETE;
      vr_tab_erro.DELETE;

      /** Verifica se possui saldo para fazer a operacao **/

      EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => rw_crapcop.cdcooper
                                  ,pr_rw_crapdat => rw_crapdat
                                  ,pr_cdagenci   => pr_cdageope
                                  ,pr_nrdcaixa   => pr_nrcxaope
                                  ,pr_cdoperad   => pr_cdoperad
                                  ,pr_nrdconta   => pr_nrdconta
                                  ,pr_vllimcre   => rw_crapass.vllimcre
                                  ,pr_tipo_busca => 'A' --> tipo de busca(A-dtmvtoan)
                                  ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                  ,pr_flgcrass   => FALSE
                                  ,pr_des_reto   => vr_dscritic
                                  ,pr_tab_sald   => vr_tab_saldo
                                  ,pr_tab_erro   => vr_tab_erro);

      --Se ocorreu erro
      IF vr_dscritic = 'NOK' THEN
        -- Tenta buscar o erro no vetor de erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informacao na pr_tab_erro, Conta: '||pr_nrdconta;
        END IF;

        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Verificar o saldo retornado
      IF vr_tab_saldo.Count = 0 THEN

        --Montar mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';

        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Total disponivel recebe valor disponivel + limite credito
        vr_vlsldisp:= nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) + nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);

        --Se o saldo nao for suficiente
        IF vr_vlsldisp >= vr_vllantar THEN
          vr_debtarifa := TRUE;
        END IF;
      END IF;

      IF pr_tpctafav = 9 THEN -- Se for BacenJud nao deve cobrar tarifa
        NULL;
	    -- Se não isenta cobrança da tarifa
      ELSIF vr_fliseope <> 1 THEN

        IF pr_idagenda = 1 OR
           vr_debtarifa    THEN
          --Realizar lancamento tarifa
          TARI0001.pc_lan_tarifa_online (pr_cdcooper => rw_crapcop.cdcooper  --Codigo Cooperativa
                                        ,pr_cdagenci => 1                    --Codigo Agencia destino
                                        ,pr_nrdconta => pr_nrdconta          --Numero da Conta Destino
                                        ,pr_cdbccxlt => 100                  --Codigo banco/caixa
                                        ,pr_nrdolote => 7999                 --Numero do Lote
                                        ,pr_tplotmov => 1                    --Tipo Lote
                                        ,pr_cdoperad => 888                  --Codigo Operador
                                        ,pr_dtmvtlat => rw_crapdat.dtmvtolt  --Data Tarifa
                                        ,pr_dtmvtlcm => rw_crapdat.dtmvtocd  --Data lancamento
                                        ,pr_nrdctabb => pr_nrdconta         --Numero Conta BB
                                        ,pr_nrdctitg => to_char(pr_nrdconta,'fm00000000')         --Conta Integracao
                                        ,pr_cdhistor => vr_cdhistar          --Codigo Historico
                                        ,pr_cdpesqbb => 'CRAP020'            --Codigo pesquisa
                                        ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                        ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                        ,pr_nrctachq => 0                    --Numero Conta Cheque
                                        ,pr_flgaviso => FALSE                --Flag Aviso
                                        ,pr_tpdaviso => 0                    --Tipo Aviso
                                        ,pr_vltarifa => vr_vllantar          --Valor tarifa
                                        ,pr_nrdocmto => pr_nrdocmto          --Numero Documento
                                        ,pr_cdcoptfn => rw_crapcop.cdcooper  --Codigo Cooperativa Terminal
                                        ,pr_cdagetfn => rw_crapass.cdagenci  --Codigo Agencia Terminal
                                        ,pr_nrterfin => 0                    --Numero Terminal Financeiro
                                        ,pr_nrsequni => 0                    --Numero Sequencial Unico
                                        ,pr_nrautdoc => vr_nrseqdig + 1      --Numero Autenticacao Documento
                                        ,pr_dsidenti => NULL                 --Descricao Identificacao
                                        ,pr_cdfvlcop => vr_cdfvlcop          --Codigo Faixa Valor Cooperativa
                                        ,pr_inproces => rw_crapdat.inproces  --Indicador Processo
                                        ,pr_cdlantar => vr_cdlantar          --Codigo Lancamento tarifa
                                        ,pr_tab_erro => vr_tab_erro          --Tabela de erro
                                        ,pr_cdcritic => vr_cdcritic          --Codigo do erro
                                        ,pr_dscritic => vr_dscritic);        --Descricao do erro

          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Se tem informacoes no vetor erro
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= 0;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel lancar a tarifa.';
            END IF;
            --Levantar Exececao
            RAISE vr_exc_erro;
          END IF;
        ELSE

          --Inicializar variavel retorno erro
          TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                           ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --Data Lancamento
                                           ,pr_cdhistor => vr_cdhistar   --Codigo Historico
                                           ,pr_vllanaut => vr_vllantar   --Valor lancamento automatico
                                           ,pr_cdoperad => 888   --Codigo Operador
                                           ,pr_cdagenci => 1   --Codigo Agencia
                                           ,pr_cdbccxlt => 100   --Codigo banco caixa
                                           ,pr_nrdolote => 7999   --Numero do lote
                                           ,pr_tpdolote => 1   --Tipo do lote
                                           ,pr_nrdocmto => pr_nrdocmto   --Numero do documento
                                           ,pr_nrdctabb => pr_nrdconta   --Numero da conta
                                           ,pr_nrdctitg => to_char(pr_nrdconta,'fm00000000')   --Numero da conta integracao
                                           ,pr_cdpesqbb => 'CRAP020'   --Codigo pesquisa
                                           ,pr_cdbanchq => 0   --Codigo Banco Cheque
                                           ,pr_cdagechq => 0   --Codigo Agencia Cheque
                                           ,pr_nrctachq => 0   --Numero Conta Cheque
                                           ,pr_flgaviso => FALSE   --Flag aviso
                                           ,pr_tpdaviso => 0   --Tipo aviso
                                           ,pr_cdfvlcop => vr_cdfvlcop   --Codigo cooperativa
                                           ,pr_inproces => rw_crapdat.inproces   --Indicador processo
                                           ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                           ,pr_tab_erro => vr_tab_erro   --Tabela retorno erro
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica

          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Se tem informacoes no vetor erro
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= 0;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel lancar a tarifa.';
            END IF;
              --Levantar Exececao
            RAISE vr_exc_erro;
          END IF;
        END IF;

        --> Caso possua analise de fraude  e gerou tarifa
        --> atualizar a analise com o numero da tarifa, para
        --> caso necessario conseguir estorna-la
        IF nvl(vr_idanalise_fraude,0) > 0 AND
           (vr_rowid_craplat IS NOT NULL OR vr_cdlantar IS NOT NULL) THEN

          IF vr_cdlantar IS NULL THEN
            --> Buscar dados da tarifa
            OPEN cr_craplat (pr_rowid => vr_rowid_craplat);
            FETCH cr_craplat INTO rw_craplat;
            CLOSE cr_craplat;
            vr_cdlantar := rw_craplat.cdlantar;
      END IF;

          IF vr_cdlantar IS NOT NULL THEN
            BEGIN
              UPDATE tbgen_analise_fraude
                 SET tbgen_analise_fraude.cdlantar = vr_cdlantar
               WHERE tbgen_analise_fraude.idanalise_fraude = vr_idanalise_fraude;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar analise de fraude: '||SQLERRM;
                RAISE vr_exc_erro;
            END;
    END IF;

        END IF;  -- Fim IF analise
      END IF;
    END IF;
    END IF;
	--Fim Bacenjud - SM 1

	  --Bacenjud - SM 1
    --Como nao passa pelas rotinas de autenticacao e insercao de transferencia de valores,
    --setamos abaixo com os mesmos valores que seriam setados acima
    IF vr_reenvio = 1 THEN
      vr_hrtransa         := gene0002.fn_busca_time;
      rw_craptvl.flgtitul := 0;
      rw_craptvl.tpdctadb := 1;
    END IF;
    --Fim Bacenjud - SM 1

    --Caso for TEDs de mesm titularidade passar pela monitoração (Problema com FRAUDE)
    IF pr_nrcpfcgc = pr_nrcpffav THEN
      BEGIN
      AFRA0004.pc_monitora_operacao (pr_cdcooper   => rw_crapcop.cdcooper
                                    ,pr_nrdconta   => pr_nrdconta
                                    ,pr_idseqttl   => pr_idseqttl
                                    ,pr_vlrtotal   => pr_vldocmto
                                    ,pr_flgagend   => CASE pr_idagenda WHEN 1 THEN 0 ELSE 1 END
                                    ,pr_idorigem   => pr_idorigem
                                    ,pr_cdoperacao => 12 --TED
                                    ,pr_idanalis   => vr_idanalise_fraude
                                    ,pr_cdcritic   => vr_cdcritic
                                    ,pr_dscritic   => vr_dscritic);

        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      EXCEPTION
        WHEN vr_exc_erro THEN
            vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                       pr_ind_tipo_log => 2, --> erro tratado
                                       pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - CXON0020.pc_enviar_ted --> ' ||
                                                          vr_cdcritic||' -> '||vr_dscritic,
                                       pr_nmarqlog     => vr_nmarqlog);

            vr_cdcritic := NULL;
            vr_dscritic := NULL;
        WHEN OTHERS THEN
              vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
              btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - CXON0020.pc_enviar_ted --> ' || sqlerrm,
                                         pr_nmarqlog     => vr_nmarqlog);

              vr_cdcritic := NULL;
              vr_dscritic := NULL;
      END;


    END IF;

    --> Caso possua processo de analise de fraude, não deve enviar a TED para a cabine
    --> Processo ocorrerá apos o retorno da analise
    IF nvl(vr_idanalise_fraude,0) = 0 THEN
      -- Marcelo Telles Coelho - Projeto 475 - Sprint B
      -- Se for efetivação de agendamento não deve verificar o horário de abertura da cabine
      IF pr_idagenda = 2 THEN
        vr_flvldhor := 0;
      ELSE
        vr_flvldhor := 1;
      END IF;
      -- Fim Projeto 475
    -- Procedimento para envio do TED para o SPB
    SSPB0001.pc_proc_envia_tec_ted
                          (pr_cdcooper =>  rw_crapcop.cdcooper  --> Cooperativa
                          ,pr_cdagenci =>  pr_cdageope          --> Cod. Agencia
                          ,pr_nrdcaixa =>  pr_nrcxaope          --> Numero  Caixa
                          ,pr_cdoperad =>  pr_cdoperad          --> Operador
                          ,pr_titulari =>  (rw_craptvl.flgtitul = 1) --> Mesmo Titular.
                          ,pr_vldocmto =>  pr_vldocmto          --> Vlr. DOCMTO
                          ,pr_nrctrlif =>  vr_nrctrlif          --> NumCtrlIF
                          ,pr_nrdconta =>  pr_nrdconta          --> Nro Conta
                          ,pr_cdbccxlt =>  pr_cdbanfav          --> Codigo Banco
                          ,pr_cdagenbc =>  pr_cdagefav          --> Cod Agencia
                          ,pr_nrcctrcb =>  pr_nrctafav          --> Nr.Ct.destino
                          ,pr_cdfinrcb =>  pr_cdfinali          --> Finalidade
                          ,pr_tpdctadb =>  rw_craptvl.tpdctadb  --> Tp. conta deb
                          ,pr_tpdctacr =>  pr_tpctafav          --> Tp conta cred
                          ,pr_nmpesemi =>  pr_nmprimtl          --> Nome Do titular
                          ,pr_nmpesde1 =>  NULL                 --> Nome De 2TTT
                          ,pr_cpfcgemi =>  pr_nrcpfcgc          --> CPF/CNPJ Do titular
                          ,pr_cpfcgdel =>  0                    --> CPF sec TTL
                          ,pr_nmpesrcb =>  pr_nmfavore          --> Nome Para
                          ,pr_nmstlrcb =>  NULL                 --> Nome Para 2TTL
                          ,pr_cpfcgrcb =>  pr_nrcpffav          --> CPF/CNPJ Para
                          ,pr_cpstlrcb =>  0                    --> CPF Para 2TTL
                          ,pr_tppesemi =>  pr_inpessoa          --> Tp. pessoa De
                          ,pr_tppesrec =>  pr_inpesfav          --> Tp. pessoa Para
                          ,pr_flgctsal =>  vr_flgctsal          --> CC Sal 
                          ,pr_cdidtran =>  pr_dstransf          --> tipo de transferencia
                          ,pr_cdorigem =>  pr_idorigem          --> Cod. Origem
                          ,pr_dtagendt =>  NULL                 --> data egendamento
                          ,pr_nrseqarq =>  0                    --> nr. seq arq.
                          ,pr_cdconven =>  0                    --> Cod. Convenio
                          ,pr_dshistor =>  pr_dshistor          --> Dsc do Hist.
                          ,pr_hrtransa =>  vr_hrtransa          --> Hora transacao
                          ,pr_cdispbif =>  pr_cdispbif          --> ISPB Banco
                          ,pr_flvldhor =>  vr_flvldhor          --> --> Flag para verificar se deve validar o horario permitido para TED(1-valida,0-nao valida) -- Marcelo Telles Coelho - Projeto 475 - Sprint B
                          --------- SAIDA  --------
                          ,pr_cdcritic =>  vr_cdcritic          --> Codigo do erro
                          ,pr_dscritic =>  vr_dscritic );	    --> Descricao do erro

    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    END IF;

    --Bacenjud - SM 1
    IF vr_reenvio = 0 THEN
		IF pr_flmobile = 1 THEN
			vr_idorigem := 10; --> MOBILE
		ELSE
			IF pr_idorigem = 0 THEN
				vr_idorigem := 7;
			ELSE
				vr_idorigem := pr_idorigem;
			END IF;
    END IF;

   /* GRAVA LOG OPERADOR CARTAO */
    CADA0004.pc_gera_log_ope_cartao
                          (pr_cdcooper        => pr_cdcooper     --> Codigo Cooperativa
                          ,pr_nrdconta        => pr_nrdconta     --> Numero da Conta
                          ,pr_indoperacao     => 3               --> TED
                          ,pr_cdorigem        => vr_idorigem
                          ,pr_indtipo_cartao  => 0
                          ,pr_nrdocmto        => pr_nrdocmto
                          ,pr_cdhistor        => vr_cdhisted
                          ,pr_nrcartao        => '0'
                          ,pr_vllanmto        => pr_vldocmto
                          ,pr_cdoperad        => pr_cdoperad
                          ,pr_cdbccrcb        => pr_cdbanfav
                          ,pr_cdfinrcb        => pr_cdfinali
													,pr_cdpatrab        => pr_cdageope
													,pr_nrseqems        => 0
													,pr_nmreceptor      => ''
													,pr_nrcpf_receptor  => 0
                          ,pr_dscritic        => vr_dscritic);   --> Descricao do erro

    --Se ocorreu erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    END IF;
	--Fim Bacenjud - SM 1

    COMMIT;
    pr_des_erro := 'OK';

  EXCEPTION
    --> exception para apenas gerar log e não abortar envio de TED, pois
     -- script já foi executado
    WHEN vr_exc_log THEN
      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      vr_nmarqlog := 'proc_message.log';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' - '||
                                                    'CXON0020 - enviar-ted'               ||
                                                    ' - ERRO APOS ENVIAR TED  --> '              ||
                                                    'Cooperativa: '     || to_char(pr_cdcooper, '990')           ||
                                                    ', Conta: '         || gene0002.fn_mask_conta(pr_nrdconta)   ||
                                                    ', Documento: '     || to_char(pr_nrdocmto,'999G999G999G990')||
                                                    ', Valor: '         || to_char(pr_vldocmto,'999G999G999G990D00') ||
                                                    ', Banco Fav.: '    || pr_cdbanfav ||
                                                    ', Agencia Fav.: '  || pr_cdagefav ||
                                                    ', Conta Fav.: '    || pr_nrctafav ||
                                                    ', Critica: '       || vr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog);

      -- buscar destinatarios do email
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_ENVIO_TED');

      -- Gravar conteudo do email, controle com substr para não estourar campo texto
      vr_conteudo := substr('ERRO APOS ENVIAR TED '||
                     '<br>Cooperativa: '    || to_char(pr_cdcooper, '990')           ||
                      '<br>Conta: '         || gene0002.fn_mask_conta(pr_nrdconta)   ||
                      '<br>Documento: '     || to_char(pr_nrdocmto,'999G999G999G990')||
                      '<br>Valor: '         || to_char(pr_vldocmto,'999G999G999G990D00') ||
                      '<br>Banco Fav.: '    || pr_cdbanfav ||
                      '<br>Agencia Fav.: '  || pr_cdagefav ||
                      '<br>Conta Fav.: '    || pr_nrctafav ||
                      '<br>Critica: '       || vr_dscritic,1,4000);

      vr_dscritic := NULL;
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'CXON0020'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'Erro apos envio TED - CXON0020'
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      vr_dscritic := NULL;
      COMMIT;
      pr_des_erro := 'OK';

    WHEN vr_exc_erro THEN

      IF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := 'Erro ao efetuar o envio da TED. Tente Novamente.';
      END IF;

      -- rollback do ted
      ROLLBACK;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      pr_des_erro := 'NOK';
    WHEN OTHERS THEN

      -- rollback do ted
      ROLLBACK;

      pr_cdcritic := 'Erro ao efetuar o envio da TED. Tente Novamente.:'||SQLERRM;
      pr_dscritic := vr_dscritic;

      pr_des_erro := 'NOK';

  END pc_enviar_ted;


  /******************************************************************************/
  /**             Procedure para executar o envio da TED                       **/
  /******************************************************************************/
  PROCEDURE pc_executa_envio_ted
                          (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Agencia
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Caixa Operador
                          ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador Autorizacao
                          ,pr_idorigem IN INTEGER                --> Origem
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                          ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta Remetente
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --> CPF operador juridico
                          ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Banco destino
                          ,pr_cdageban IN crapcti.cdageban%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Conta transferencia
                          ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> nome do titular destino
                          ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> CPF do titular destino
                          ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Tipo de pessoa
                          ,pr_intipcta IN crapcti.intipcta%TYPE  --> Tipo de conta
                          ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lançamento
                          ,pr_dstransf IN VARCHAR2               --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          ,pr_dshistor IN VARCHAR2               --> Descriçao do Histórico
                          ,pr_cdispbif IN INTEGER                --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0      --> Indicador se origem é do Mobile
                          ,pr_idagenda IN INTEGER                --> Tipo de agendamento
                          ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                          ,pr_dstransa IN VARCHAR2 DEFAULT NULL  --> Descrição da transacao no IBank/mobile
                          ,pr_iddispos IN VARCHAR2 DEFAULT NULL  --> Identif. do dispositivo mobile
                          ,pr_idportab IN NUMBER   DEFAULT 0     --> Indica uma transferencia de portabilidade (TEC de salário)
                          ,pr_nrridlfp IN NUMBER   DEFAULT 0     --> Indica o registro de lançamento da folha de pagamento, caso necessite devolução
                          -- saida
                          ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Retorna protocolo
                          ,pr_tab_protocolo_ted OUT cxon0020.typ_tab_protocolo_ted --> dados do protocolo
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do erro

  /*---------------------------------------------------------------------------------------------------------------

      Programa : pc_executa_envio_ted             Antigo: b1wgen0015/executa-envio-ted
      Sistema  : Rotinas acessadas pelas telas de cadastros Web
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Junho/2015.                   Ultima atualizacao: 13/06/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para executar o envio da TED

      Alteração : 09/06/2015 - Conversão Progress -> Oracle (Odirlei-Amcom)

                  08/10/2015 - Ajustado para gerar o numero da conta no protocolo com "."
                               conforme progress SD341797 (Odirlei-Amcom)

                  08/06/2017 - Ajustes referentes ao novo catalogo do SPB (Lucas Ranghetti #668207)

				  13/08/2017 - Ajuste para pegar o erro corretamente (Jonata - RKAM / P364).

				  13/06/2018 - Ajuste para limpar caracteres especiais (Andrey Formigari - MOUTS).

  ---------------------------------------------------------------------------------------------------------------*/
    ---------------> CURSORES <-----------------
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.nmprimtl,
             crapass.inpessoa,
             crapass.nrcpfcgc,
             crapass.nrdctitg,
             crapass.cdagenci,
             crapass.idastcjt
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    rw_crabass cr_crapass%ROWTYPE;

    -- Verificar cadasto de senhas
    CURSOR cr_crapsnh (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_idseqttl crapttl.idseqttl%TYPE,
                       pr_nrcpfcgc crapttl.nrcpfcgc%TYPE) IS
      SELECT crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.nrcpfcgc
            ,crapsnh.vllimweb
            ,crapsnh.vllimtrf
            ,crapsnh.vllimted
            ,crapsnh.idseqttl
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND (crapsnh.idseqttl = pr_idseqttl OR pr_idseqttl = 0)
         AND crapsnh.tpdsenha = 1
         AND (crapsnh.nrcpfcgc = pr_nrcpfcgc OR pr_nrcpfcgc = 0);
    rw_crapsnh cr_crapsnh%ROWTYPE;

    -- Verificar cadasto de senhas
    CURSOR cr_crapavt (pr_cdcooper crapavt.cdcooper%TYPE,
                       pr_nrdconta crapavt.nrdconta%TYPE,
                       pr_nrcpfcgc crapavt.nrcpfcgc%TYPE) IS
      SELECT crapavt.cdcooper
            ,crapavt.nrdconta
            ,crapavt.nrdctato
            ,crapavt.nmdavali
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.tpctrato = 6
         AND crapavt.nrcpfcgc = pr_nrcpfcgc;
    rw_crapavt cr_crapavt%ROWTYPE;

    -- Buscar titulares
    CURSOR cr_crapttl ( pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE,
                        pr_idseqttl crapttl.idseqttl%TYPE)  IS
      SELECT ttl.nmextttl
            ,ttl.inpessoa
            ,ttl.idseqttl
            ,ttl.nrcpfcgc
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl ;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- buscar erro
    CURSOR cr_craperr(pr_cdcooper craperr.cdcooper%TYPE,
                      pr_cdagenci craperr.cdagenci%TYPE,
                      pr_nrdcaixa craperr.nrdcaixa%TYPE) IS
      SELECT craperr.dscritic
        FROM craperr
       WHERE craperr.cdcooper = pr_cdcooper
         AND craperr.cdagenci = pr_cdagenci
         AND craperr.nrdcaixa = pr_nrdcaixa;

    -- localizar crapaut
    CURSOR cr_crapaut (pr_rowid ROWID) IS
      SELECT crapaut.dtmvtolt,
             crapaut.hrautent,
             crapaut.nrsequen,
             crapaut.nrdcaixa
        FROM crapaut
       WHERE crapaut.rowid = pr_rowid
       FOR UPDATE NOWAIT;
    rw_crapaut cr_crapaut%ROWTYPE;

    -- Validar banco
    CURSOR cr_crapban (pr_cdispbif crapban.nrispbif%TYPE) IS
      SELECT flgdispb,
             nmextbcc
        FROM crapban
       WHERE crapban.nrispbif = pr_cdispbif;

    CURSOR cr_crapban2 (pr_cdbccxlt crapban.cdbccxlt%TYPE) IS
      SELECT flgdispb,
             nmextbcc
        FROM crapban
       WHERE crapban.cdbccxlt = pr_cdbccxlt;

    rw_crapban cr_crapban%ROWTYPE;

    CURSOR cr_crappod(pr_cdcooper crappod.cdcooper%TYPE
                     ,pr_nrdconta crappod.nrdconta%TYPE) IS
      SELECT pod.cdcooper,
             pod.nrdconta,
             pod.nrcpfpro
        FROM crappod pod
       WHERE pod.cdcooper = pr_cdcooper
         AND pod.nrdconta = pr_nrdconta
         AND pod.cddpoder = 10
         AND pod.flgconju = 1;

    rw_crappod cr_crappod%ROWTYPE;

    -- Buscar dados agencia favorecido
    CURSOR cr_crapagb (pr_cddbanco crapagb.cddbanco%TYPE,
                       pr_cdageban crapagb.cdageban%TYPE) IS
      SELECT gene0007.fn_caract_acento(crapagb.nmageban,1) nmageban
        FROM crapagb
       WHERE crapagb.cddbanco = pr_cddbanco
         AND crapagb.cdageban = pr_cdageban;
    rw_crapagb cr_crapagb%ROWTYPE;

    -- Buscar dados protocolo
    CURSOR cr_crappro (pr_cdcooper crappro.cdcooper%TYPE,
                       pr_dsprotoc crappro.dsprotoc%TYPE) IS
      SELECT crappro.cdtippro,
             crappro.dtmvtolt,
             crappro.dttransa,
             crappro.hrautent,
             crappro.vldocmto,
             crappro.nrdocmto,
             crappro.nrseqaut,
             crappro.dsinform##1,
             crappro.dsinform##2,
             crappro.dsinform##3,
             crappro.dsprotoc,
             crappro.nmprepos,
             crappro.nrcpfpre,
             crappro.nrcpfope
        FROM crappro
       WHERE crappro.cdcooper = pr_cdcooper
         AND upper(crappro.dsprotoc) = upper(pr_dsprotoc);
    rw_crappro cr_crappro%ROWTYPE;

    -- Buscar dados operador juridico
    CURSOR cr_crapopi (pr_cdcooper crapopi.cdcooper%TYPE,
                       pr_nrdconta crapopi.nrdconta%TYPE,
                       pr_nrcpfope crapopi.nrcpfope%TYPE) IS
      SELECT crapopi.nmoperad
        FROM crapopi
       WHERE crapopi.cdcooper = pr_cdcooper
         AND crapopi.nrdconta = pr_nrdconta
         AND crapopi.nrcpfope = pr_nrcpfope;
    rw_crapopi cr_crapopi%rowtype;

    ------------> ESTRUTURAS DE REGISTRO <-----------

    --Tabela de memória de limites de horario
    vr_tab_limite INET0001.typ_tab_limite;
    vr_index      PLS_INTEGER;

    ---------------> VARIAVEIS <-----------------
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_tab_erro GENE0001.typ_tab_erro;
    vr_des_erro VARCHAR2(50);

    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;

    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
    vr_exc_log  EXCEPTION;

    vr_nmextttl crapttl.nmextttl%TYPE;
    vr_nmprepos crapass.nmprimtl%TYPE;
    vr_nrcpfcgc crapttl.nrcpfcgc%TYPE;
    vr_nrdocmto craplcm.nrdocmto%TYPE;
    vr_nrrectvl ROWID;
    vr_nrreclcm ROWID;
    vr_dstextab craptab.dstextab%TYPE;
    vr_dsinfor1 crappro.dsinform##1%TYPE;
    vr_dsinfor2 crappro.dsinform##1%TYPE;
    vr_dsinfor3 crappro.dsinform##3%TYPE;
    vr_dscpfcgc VARCHAR2(100);
    vr_idxpro   PLS_INTEGER;
    vr_cddbanco VARCHAR2(100);
    vr_nmarqlog VARCHAR2(100);
    vr_email_dest VARCHAR2(500);
    vr_conteudo   VARCHAR2(4000);

  BEGIN

    --> Buscar dados cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    --> verificar se encontra registro
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'Registro de cooperativa nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Buscar dados associados
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

    -- Verifica senha, apenas se não for TEC de salário (Renato - Supero - P485)
    IF NVL(pr_idportab,1) = 0 THEN
    -- Verificar cadastro de senha
    OPEN cr_crapsnh (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_idseqttl => pr_idseqttl,
                     pr_nrcpfcgc => 0);
    IF cr_crapsnh%NOTFOUND THEN
      CLOSE cr_crapsnh;
      vr_dscritic := 'Senha para conta on-line nao cadastrada';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapsnh;
    END if;

    -- se for pessoa juridica
    IF rw_crapass.inpessoa = 1 THEN
      -- buscar dados titular
      OPEN cr_crapttl (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_idseqttl => pr_idseqttl);
      FETCH cr_crapttl INTO rw_crapttl;

      IF cr_crapttl%NOTFOUND THEN
        CLOSE cr_crapttl;
        vr_dscritic := 'Titular nao cadastrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapttl;

      vr_nmextttl := rw_crapttl.nmextttl;
      vr_nrcpfcgc := rw_crapttl.nrcpfcgc;

    ELSE

      vr_nmextttl := rw_crapass.nmprimtl;
      vr_nrcpfcgc := rw_crapass.nrcpfcgc;

      -- Buscar dados do preposto apenas quando nao possuir
      -- assinatura multipla
      IF rw_crapass.idastcjt = 0 THEN

        -- Buscar dados de avalista
        OPEN cr_crapavt (pr_cdcooper => rw_crapsnh.cdcooper,
                         pr_nrdconta => rw_crapsnh.nrdconta,
                         pr_nrcpfcgc => rw_crapsnh.nrcpfcgc);
        FETCH cr_crapavt INTO rw_crapavt;
        IF cr_crapavt%FOUND THEN
          CLOSE cr_crapavt;

          -- Buscar dados associados preposto
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => rw_crapavt.nrdctato);
          FETCH cr_crapass INTO rw_crabass;
          IF cr_crapass%FOUND THEN
            vr_nmprepos := rw_crabass.nmprimtl;
          ELSE
            vr_nmprepos := rw_crapavt.nmdavali;
          END IF;
          CLOSE cr_crapass;

        END IF;
        CLOSE cr_crapavt;

      END IF;

    END IF;

	--Bacenjud - SM 1
    IF vr_reenvio = 0 THEN
    --Atualizar registro movimento da internet
    IF rw_crapass.idastcjt = 0 THEN
      BEGIN
        UPDATE crapmvi
           SET crapmvi.vlmovted = crapmvi.vlmovted + pr_vllanmto
        WHERE crapmvi.cdcooper = pr_cdcooper
             AND crapmvi.nrdconta = pr_nrdconta
             AND crapmvi.idseqttl = pr_idseqttl
             AND crapmvi.dtmvtolt = pr_dtmvtolt;

        --Nao atualizou nenhum registro
        IF SQL%ROWCOUNT = 0 THEN
          -- Cria o registro do movimento da internet
          BEGIN
            INSERT INTO crapmvi
                   (crapmvi.cdcooper
                   ,crapmvi.cdoperad
                   ,crapmvi.dtmvtolt
                   ,crapmvi.dttransa
                   ,crapmvi.hrtransa
                   ,crapmvi.idseqttl
                   ,crapmvi.nrdconta
                   ,crapmvi.vlmovted)
            VALUES (pr_cdcooper
                   ,pr_cdoperad
                   ,pr_dtmvtolt
                   ,trunc(SYSDATE)
                   ,GENE0002.fn_busca_time
                   ,pr_idseqttl
                   ,pr_nrdconta
                   ,pr_vllanmto);
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao inserir movimento na internet. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar movimento na internet. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
    ELSE
      FOR rw_crappod IN cr_crappod(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta) LOOP
        OPEN cr_crapsnh(pr_cdcooper => rw_crappod.cdcooper
                       ,pr_nrdconta => rw_crappod.nrdconta
                       ,pr_idseqttl => 0
                       ,pr_nrcpfcgc => rw_crappod.nrcpfpro);

        FETCH cr_crapsnh INTO rw_crapsnh;

        IF cr_crapsnh%NOTFOUND THEN
          CLOSE cr_crapsnh;
          CONTINUE;
        ELSE
          CLOSE cr_crapsnh;

          BEGIN
            UPDATE crapmvi
               SET crapmvi.vlmovted = crapmvi.vlmovted + pr_vllanmto
            WHERE crapmvi.cdcooper = pr_cdcooper
                 AND crapmvi.nrdconta = pr_nrdconta
                 AND crapmvi.idseqttl = rw_crapsnh.idseqttl
                 AND crapmvi.dtmvtolt = pr_dtmvtolt;

            --Nao atualizou nenhum registro
            IF SQL%ROWCOUNT = 0 THEN
              -- Cria o registro do movimento da internet
              BEGIN
                INSERT INTO crapmvi
                       (crapmvi.cdcooper
                       ,crapmvi.cdoperad
                       ,crapmvi.dtmvtolt
                       ,crapmvi.dttransa
                       ,crapmvi.hrtransa
                       ,crapmvi.idseqttl
                       ,crapmvi.nrdconta
                       ,crapmvi.vlmovted)
                VALUES (pr_cdcooper
                       ,pr_cdoperad
                       ,pr_dtmvtolt
                       ,trunc(SYSDATE)
                       ,GENE0002.fn_busca_time
                       ,rw_crapsnh.idseqttl
                       ,pr_nrdconta
                       ,pr_vllanmto);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao inserir movimento na internet. '||sqlerrm;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              END;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar movimento na internet. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
      END LOOP;
    END IF;
	END IF;
	--Fim Bacenjud - SM 1

    -- Enviar TED
    pc_enviar_ted (pr_cdcooper => pr_cdcooper --> Cooperativa
                  ,pr_idorigem => pr_idorigem --> Origem
                  ,pr_cdageope => pr_cdagenci --> PAC Operador
                  ,pr_nrcxaope => pr_nrdcaixa --> Caixa Operador
                  ,pr_cdoperad => pr_cdoperad --> Operador Autorizacao
                  ,pr_cdopeaut => pr_cdoperad --> Operador Autorizacao
                  ,pr_vldocmto => pr_vllanmto --> Valor TED
                  ,pr_nrdconta => pr_nrdconta --> Conta Remetente
                  ,pr_idseqttl => pr_idseqttl --> Titular
                  ,pr_nmprimtl => vr_nmextttl --> Nome Remetente
                  ,pr_nrcpfcgc => vr_nrcpfcgc --> CPF/CNPJ Remetente
                  ,pr_inpessoa => rw_crapass.inpessoa --> Tipo Pessoa Remetente
                  ,pr_cdbanfav => pr_cddbanco --> Banco Favorecido
                  ,pr_cdagefav => pr_cdageban --> Agencia Favorecido
                  ,pr_nrctafav => pr_nrctatrf --> Conta Favorecido
                  ,pr_nmfavore => gene0007.fn_caract_acento(pr_nmtitula, 1) --> Nome Favorecido
                  ,pr_nrcpffav => pr_nrcpfcgc --> CPF/CNPJ Favorecido
                  ,pr_inpesfav => pr_inpessoa --> Tipo Pessoa Favorecido
                  ,pr_tpctafav => pr_intipcta --> Tipo Conta Favorecido
                  ,pr_dshistor => pr_dshistor --> Descriçao do Histórico
                  ,pr_dstransf => gene0007.fn_caract_acento(pr_dstransf, 1) --> Identificacao Transf.
                  ,pr_cdfinali => pr_cdfinali --> Finalidade TED
                  ,pr_cdispbif => pr_cdispbif --> ISPB Banco Favorecido
                  ,pr_flmobile => pr_flmobile --> Indicador se origem é do Mobile
                  ,pr_idagenda => pr_idagenda --> Tipo de agendamento
                  ,pr_iptransa => pr_iptransa --> IP da transacao no IBank/mobile
                  ,pr_dstransa => pr_dstransa --> Descrição da transacao no IBank/mobile
                  ,pr_iddispos => pr_iddispos --> ID Dispositivo mobile
                  ,pr_idportab => pr_idportab --> Indicar transferencia de valor de portabilidade de salário
                  ,pr_nrridlfp => pr_nrridlfp --> Indicador do registro do lançamento de folha de pagamento
                  -- saida
                  ,pr_nrdocmto => vr_nrdocmto --> Documento TED
                  ,pr_nrrectvl => vr_nrrectvl --> Autenticacao TVL
                  ,pr_nrreclcm => vr_nrreclcm --> Autenticacao LCM
                  ,pr_cdcritic => vr_cdcritic --> Código da critica
                  ,pr_dscritic => vr_dscritic --> Descrição da critica
                  ,pr_des_erro => vr_des_erro);

    IF vr_des_erro <> 'OK' THEN

      IF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := 'TED invalida.';
      END IF;

      RAISE vr_exc_erro;
    END IF;

    /** PROTOCOLO PARA REGISTRO NA TABELA CRAPTVL **/

    -- localizar autenticação
    --Bacenjud - SM 1
    --Nao deve gerar protocolo de autenticacao se for reenvio de TED Bacenjud
	IF vr_reenvio = 0 THEN
    FOR vr_contador IN 1..10 LOOP
      BEGIN
        OPEN cr_crapaut (pr_rowid => vr_nrrectvl);
        FETCH cr_crapaut INTO rw_crapaut;
        -- verificar se encontrou
        IF cr_crapaut%NOTFOUND THEN
          vr_dscritic := 'Registro de autenticacao nao encontrado.';
          CLOSE cr_crapaut;
          RAISE vr_exc_log;
        END IF;

        CLOSE cr_crapaut;
        EXIT; -- sair do loop
      EXCEPTION
        WHEN OTHERS THEN
          -- se cursor estiver aberto, deve fechar
          IF cr_crapaut%ISOPEN THEN
            CLOSE cr_crapaut;
          END IF;
          -- se for o ultima tentativa, abortar o programa
          IF vr_contador = 10 THEN
            vr_dscritic := 'Registro de autenticacao esta sendo alterado.';
            RAISE vr_exc_log;
          END IF;
          continue;
      END;
    END LOOP;

    IF pr_cddbanco = 0 THEN
      vr_cddbanco := '   ';
    ELSE
      vr_cddbanco := to_char(pr_cddbanco,'fm000');
    END IF;

    vr_dsinfor1 := 'TED';
    vr_dsinfor2 := vr_nmextttl||'#'||to_char(vr_cddbanco,'fm000');

    -- Obtem dados do banco do favorecido para Protocolo
    IF pr_cdispbif = 0 THEN
      OPEN cr_crapban2 (pr_cdbccxlt => pr_cddbanco);
      FETCH cr_crapban2 INTO rw_crapban;

      IF cr_crapban2%FOUND THEN
        vr_dsinfor2 := vr_dsinfor2 ||' - '||REPLACE(upper(TRIM(rw_crapban.nmextbcc)),'&','e');
      END IF;
      CLOSE cr_crapban2;
    ELSE

      OPEN cr_crapban (pr_cdispbif => pr_cdispbif);
      FETCH cr_crapban INTO rw_crapban;

      IF cr_crapban%FOUND THEN
        vr_dsinfor2 := vr_dsinfor2 ||' - '||REPLACE(upper(TRIM(rw_crapban.nmextbcc)),'&','e');
      END IF;
      CLOSE cr_crapban;
    END IF;

    vr_dsinfor2 := vr_dsinfor2 ||'#'||to_char(pr_cdageban,'fm0000');

    --> Obtem dados da agencia do favorecido para Protocolo
    OPEN cr_crapagb (pr_cddbanco => pr_cddbanco,
                     pr_cdageban => pr_cdageban);
    FETCH cr_crapagb INTO rw_crapagb;

    IF cr_crapagb%FOUND THEN
      vr_dsinfor2 := vr_dsinfor2 ||' - '||TRIM(rw_crapagb.nmageban);
    END IF;
    CLOSE cr_crapagb;

    vr_dsinfor2 := vr_dsinfor2 ||'#';

    --> Formata dados do favorecido para Protocolo
    vr_dsinfor2 := vr_dsinfor2||
                  TRIM(gene0002.fn_mask(to_char(pr_nrctatrf),'zzzzzzzzzzzzzzzzzzz.9'))||
                  '#'||gene0002.fn_mask(pr_cdispbif,'zzzzzzzzz9');
    vr_dscpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc,pr_inpessoa);
    vr_dsinfor3 := TRIM(pr_nmtitula) ||'#'|| vr_dscpfcgc ||'#';

    --> Formata dados da TED para Protocolo

    -- Ler tabela generica
    vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => rw_crapcop.cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 00
                                              ,pr_cdacesso => 'FINTRFTEDS'
                                              ,pr_tpregist => pr_cdfinali   );

    vr_dsinfor3 := vr_dsinfor3 || TRIM(upper(vr_dstextab)) ||'#'|| pr_dstransf;

    --Gerar protocolo
    GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper             --> Código da cooperativa
                              ,pr_dtmvtolt => rw_crapaut.dtmvtolt     --> Data movimento
                              ,pr_hrtransa => rw_crapaut.hrautent     --> Hora da transação NOK
                              ,pr_nrdconta => pr_nrdconta             --> Número da conta
                              ,pr_nrdocmto => vr_nrdocmto             --> Número do documento
                              ,pr_nrseqaut => rw_crapaut.nrsequen     --> Número da sequencia
                              ,pr_vllanmto => pr_vllanmto             --> Valor lançamento
                              ,pr_nrdcaixa => rw_crapaut.nrdcaixa     --> Número do caixa NOK
                              ,pr_gravapro => TRUE                    --> Controle de gravação
                              ,pr_cdtippro => 9                       --> Código de operação
                              ,pr_dsinfor1 => vr_dsinfor1             --> Descrição 1
                              ,pr_dsinfor2 => vr_dsinfor2             --> Descrição 2
                              ,pr_dsinfor3 => vr_dsinfor3             --> Descrição 3
                              ,pr_dscedent => NULL                    --> Descritivo
                              ,pr_flgagend => FALSE                   --> Controle de agenda
                              ,pr_nrcpfope => pr_nrcpfope             --> Número de operação
                              ,pr_nrcpfpre => rw_crapsnh.nrcpfcgc     --> Número pré operação
                              ,pr_nmprepos => vr_nmprepos             --> Nome
                              ,pr_dsprotoc => pr_dsprotoc             --> Descrição do protocolo
                              ,pr_dscritic => vr_dscritic             --> Descrição crítica
                              ,pr_des_erro => vr_des_erro);           --> Descrição dos erros de processo

    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      RAISE vr_exc_log;
    ELSE
    /* Se não aconteceu erro o processo gera as informações do protocolo */
      -- Buscar dados protocolo
      OPEN cr_crappro (pr_cdcooper => pr_cdcooper,
                       pr_dsprotoc => pr_dsprotoc);
      FETCH cr_crappro INTO rw_crappro;
      IF cr_crappro%FOUND THEN
        CLOSE cr_crappro;

        rw_crapopi := NULL;
        -- Buscar dados operador juridico
        OPEN cr_crapopi (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrcpfope => rw_crappro.nrcpfope);
        FETCH cr_crapopi INTO rw_crapopi;
        CLOSE cr_crapopi;

        /** Se incluir novo campo para o protocolo, verificar a
            procedure lista_protocolos da BO bo_algoritmo_seguranca,
            onde ocorre consulta de protocolos para o InternetBank **/
        vr_idxpro := pr_tab_protocolo_ted.count;

        pr_tab_protocolo_ted(vr_idxpro).cdtippro    := rw_crappro.cdtippro;
        pr_tab_protocolo_ted(vr_idxpro).dtmvtolt    := rw_crappro.dtmvtolt;
        pr_tab_protocolo_ted(vr_idxpro).dttransa    := rw_crappro.dttransa;
        pr_tab_protocolo_ted(vr_idxpro).hrautent    := rw_crappro.hrautent;
        pr_tab_protocolo_ted(vr_idxpro).vldocmto    := rw_crappro.vldocmto;
        pr_tab_protocolo_ted(vr_idxpro).nrdocmto    := rw_crappro.nrdocmto;
        pr_tab_protocolo_ted(vr_idxpro).nrseqaut    := rw_crappro.nrseqaut;
        pr_tab_protocolo_ted(vr_idxpro).dsinform##1 := rw_crappro.dsinform##1;
        pr_tab_protocolo_ted(vr_idxpro).dsinform##2 := rw_crappro.dsinform##2;
        pr_tab_protocolo_ted(vr_idxpro).dsinform##3 := rw_crappro.dsinform##3;
        pr_tab_protocolo_ted(vr_idxpro).dsprotoc    := rw_crappro.dsprotoc;
        pr_tab_protocolo_ted(vr_idxpro).nmprepos    := rw_crappro.nmprepos;
        pr_tab_protocolo_ted(vr_idxpro).nrcpfpre    := rw_crappro.nrcpfpre;
        pr_tab_protocolo_ted(vr_idxpro).nmoperad    := rw_crapopi.nmoperad;
        pr_tab_protocolo_ted(vr_idxpro).nrcpfope    := rw_crappro.nrcpfope;
        pr_tab_protocolo_ted(vr_idxpro).cdbcoctl    := rw_crapcop.cdbcoctl;
        pr_tab_protocolo_ted(vr_idxpro).cdagectl    := rw_crapcop.cdagectl;

      END IF;

      /** Armazena protocolo na autenticacao da craptvl **/
      BEGIN
        UPDATE crapaut
           SET crapaut.dsprotoc = pr_dsprotoc
         WHERE crapaut.rowid = vr_nrrectvl;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 'Não foi possivel atualizar protocolo na autenticação: '||SQLERRM;
          RAISE vr_exc_log;
      END;

      /** PROTOCOLO PARA REGISTRO NA TABELA CRAPLCM **/
      -- localizar autenticação
      FOR vr_contador IN 1..10 LOOP
        BEGIN
          OPEN cr_crapaut (pr_rowid => vr_nrreclcm);
          FETCH cr_crapaut INTO rw_crapaut;
          -- verificar se encontrou
          IF cr_crapaut%NOTFOUND THEN
            vr_dscritic := 'Registro de autenticacao nao encontrado.';
            CLOSE cr_crapaut;
            RAISE vr_exc_log;
          ELSE
            /** Armazena protocolo na autenticacao da craplcm **/
            BEGIN
              UPDATE crapaut
                 SET crapaut.dsprotoc = pr_dsprotoc
               WHERE crapaut.rowid = vr_nrreclcm;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 'Não foi possivel atualizar protocolo na autenticação: '||SQLERRM;
                RAISE vr_exc_log;
            END;
          END IF;

          CLOSE cr_crapaut;
          EXIT; -- sair do loop
        EXCEPTION
          WHEN OTHERS THEN
            -- se cursor estiver aberto, deve fechar
            IF cr_crapaut%ISOPEN THEN
              CLOSE cr_crapaut;
            END IF;
            -- se for o ultima tentativa, abortar o programa
            IF vr_contador = 10 THEN
              vr_dscritic := 'Registro de autenticacao esta sendo alterado.';
              RAISE vr_exc_log;
            END IF;
            continue;
        END;
      END LOOP;
    END IF;
	END IF;
	--Fim Bacenjud - SM 1

  EXCEPTION
    --> exception para apenas gerar log e não abortar envio de TED, pois
     -- script já foi executado
    WHEN vr_exc_log  THEN
      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      vr_nmarqlog := 'proc_message.log';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' - '||
                                                    'b1wgen0015 - executa-envio-ted'               ||
                                                    ' - ERRO GERACAO PROTOCOLO  --> '              ||
                                                    'Cooperativa: '     || to_char(pr_cdcooper, '990')           ||
                                                    ', Conta: '         || gene0002.fn_mask_conta(pr_nrdconta)   ||
                                                    ', Documento: '     || to_char(vr_nrdocmto,'999G999G999G990')||
                                                    ', Valor: '         || to_char(pr_vllanmto,'999G999G999G990D00') ||
                                                    ', Informacao 1: '  || vr_dsinfor1 ||
                                                    ', Informacao 2: '  || vr_dsinfor2 ||
                                                    ', Informacao 3: '  || vr_dsinfor3 ||
                                                    ', CPF Operador: '  || to_char(pr_nrcpfope,'99999999999990')         ||
                                                    ', CPF crapsnh: '   || to_char(rw_crapsnh.nrcpfcgc,'99999999999990') ||
                                                    ', Nome Preposto: ' || vr_nmprepos ||
                                                    '. Data Autenticacao: '     || to_char(rw_crapaut.dtmvtolt, 'DD/MM/RRRR')||
                                                    ', Hora Autenticacao: '     || to_char(to_date(rw_crapaut.hrautent,'SSSSS'),'HH24:MM:SS')||
                                                    ', Sequencia Autenticacao: '|| to_char(rw_crapaut.nrsequen,'99G990')||
                                                    ', Caixa Autenticacao: '    || to_char(rw_crapaut.nrdcaixa,'990')||
                                                    ', Critica: '||vr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog);

      -- buscar destinatarios do email
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_ENVIO_TED');

      -- Gravar conteudo do email, controle com substr para não estourar campo texto
      vr_conteudo := substr('ERRO GERACAO PROTOCOLO - PROCEDURE executa-envio-ted'||
                     '<br>Cooperativa: '     || to_char(pr_cdcooper, '990')           ||
                      '<br>Conta: '         || gene0002.fn_mask_conta(pr_nrdconta)   ||
                      '<br>Documento: '     || to_char(vr_nrdocmto,'999G999G999G990')||
                      '<br>Valor: '         || to_char(pr_vllanmto,'999G999G999G990D00') ||
                      '<br>Informacao 1: '  || vr_dsinfor1 ||
                      '<br>Informacao 2: '  || vr_dsinfor2 ||
                      '<br>Informacao 3: '  || vr_dsinfor3 ||
                      '<br>CPF Operador: '  || to_char(pr_nrcpfope,'99999999999990')         ||
                      '<br>CPF crapsnh: '   || to_char(rw_crapsnh.nrcpfcgc,'99999999999990') ||
                      '<br>Nome Preposto: ' || vr_nmprepos ||
                      '<br>Data Autenticacao: '     || to_char(rw_crapaut.dtmvtolt, 'DD/MM/RRRR')||
                      '<br>Hora Autenticacao: '     || to_char(to_date(rw_crapaut.hrautent,'SSSSS'),'HH24:MM:SS')||
                      '<br>Sequencia Autenticacao: '|| to_char(rw_crapaut.nrsequen,'99G990')||
                      '<br>Caixa Autenticacao: '    || to_char(rw_crapaut.nrdcaixa,'990')||
                      '<br>Critica: '               || vr_dscritic,1,4000);

      vr_dscritic := NULL;
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'B1WGEN0015'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'Erro geracao protocolo TED - b1wgen0015'
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);

    WHEN vr_exc_erro THEN

      IF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := 'Não foi possivel executar o envio da TED. Tente Novamente.';
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- rollback do ted
      ROLLBACK;
    WHEN OTHERS THEN
      -- rollback do ted
      ROLLBACK;
      pr_dscritic := 'Não foi possivel executar o envio da TED. Tente Novamente.:'||SQLERRM;

  END pc_executa_envio_ted;


  /******************************************************************************/
  /**             Procedure para executar o envio da TED                       **/
  /******************************************************************************/
  PROCEDURE pc_executa_envio_ted_prog
                          (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Agencia
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Caixa Operador
                          ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador Autorizacao
                          ,pr_idorigem IN INTEGER                --> Origem
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                          ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta Remetente
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --> CPF operador juridico
                          ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Banco destino
                          ,pr_cdageban IN crapcti.cdageban%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Conta transferencia
                          ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> nome do titular destino
                          ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> CPF do titular destino
                          ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Tipo de pessoa
                          ,pr_intipcta IN crapcti.intipcta%TYPE  --> Tipo de conta
                          ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lançamento
                          ,pr_dstransf IN VARCHAR2               --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          ,pr_dshistor IN VARCHAR2               --> Descriçao do Histórico
                          ,pr_cdispbif IN INTEGER                --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0      --> Indicador se origem é do Mobile
                          ,pr_idagenda IN INTEGER                --> Tipo de agendamento
                          ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                          ,pr_dstransa IN VARCHAR2 DEFAULT NULL  --> Descrição da transacao no IBank/mobile
                          ,pr_iddispos IN VARCHAR2 DEFAULT NULL  --> Identif. do dispositivo mobile
                          -- saida
                          ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Retorna protocolo
                          ,pr_tab_protocolo_ted OUT CLOB --> dados do protocolo
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do erro
  /*---------------------------------------------------------------------------------------------------------------

      Programa : pc_executa_envio_ted_prog
      Sistema  : Rotinas acessadas pelo Progress
      Sigla    : CRED
      Autor    : Carlos Henrique W.
      Data     : Abril/2016.                   Ultima atualizacao: 25/07/2016

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para envio do TED

      Alteração : 25/07/2016 - Ajuste para retornar corretamente o xml pois estava gerando problemas para
                               o progress receber os valores de data e nome de tags com o caracter "#"
                               (Adriano).


  ---------------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767);

    vr_tab_protocolo_ted CXON0020.typ_tab_protocolo_ted;

    vr_dscritic VARCHAR2(4000);
    BEGIN
      pc_executa_envio_ted(
                pr_cdcooper => pr_cdcooper,
                pr_cdagenci => pr_cdagenci,
                pr_nrdcaixa => pr_nrdcaixa,
                pr_cdoperad => pr_cdoperad,
                pr_idorigem => pr_idorigem,
                pr_dtmvtolt => pr_dtmvtolt,
                pr_nrdconta => pr_nrdconta,
                pr_idseqttl => pr_idseqttl,
                pr_nrcpfope => pr_nrcpfope,
                pr_cddbanco => pr_cddbanco,
                pr_cdageban => pr_cdageban,
                pr_nrctatrf => pr_nrctatrf,
                pr_nmtitula => pr_nmtitula,
                pr_nrcpfcgc => pr_nrcpfcgc,
                pr_inpessoa => pr_inpessoa,
                pr_intipcta => pr_intipcta,
                pr_vllanmto => pr_vllanmto,
                pr_dstransf => pr_dstransf,
                pr_cdfinali => pr_cdfinali,
                pr_dshistor => pr_dshistor,
                pr_cdispbif => pr_cdispbif,
                pr_flmobile => pr_flmobile,
                pr_idagenda => pr_idagenda,
                pr_iptransa => pr_iptransa,
                pr_dstransa => pr_dstransa,
                pr_iddispos => pr_iddispos,
                pr_dsprotoc => pr_dsprotoc,
                pr_tab_protocolo_ted => vr_tab_protocolo_ted,
                pr_cdcritic => pr_cdcritic,
                pr_dscritic => pr_dscritic);

    -- se possui codigo, porém não possui descrição
    IF nvl(pr_cdcritic,0) > 0 AND
       TRIM(pr_dscritic) IS NULL THEN
      -- buscar descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    END IF;

    --> DESCARREGAR TEMPTABLE DE LIMITES PARA O CLOB <---
    -- Criar documento XML
    dbms_lob.createtemporary(pr_tab_protocolo_ted, TRUE);
    dbms_lob.open(pr_tab_protocolo_ted, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_tab_protocolo_ted
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

    FOR vr_contador IN nvl(vr_tab_protocolo_ted.FIRST,0)..nvl(vr_tab_protocolo_ted.LAST,-1) LOOP

      -- Montar XML com registros de carencia
      gene0002.pc_escreve_xml(pr_xml            => pr_tab_protocolo_ted
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<protocolo>'
                                                ||   '<cdtippro>'||vr_tab_protocolo_ted(vr_contador).cdtippro    ||'</cdtippro>'
                                                ||   '<dtmvtolt>'||NVL(TO_CHAR(vr_tab_protocolo_ted(vr_contador).dtmvtolt,'DD/MM/RRRR'),' ') ||'</dtmvtolt>'
                                                ||   '<dttransa>'||NVL(TO_CHAR(vr_tab_protocolo_ted(vr_contador).dttransa,'DD/MM/RRRR'),' ') ||'</dttransa>'
                                                ||   '<hrautent>'||vr_tab_protocolo_ted(vr_contador).hrautent    ||'</hrautent>'
                                                ||   '<vldocmto>'||vr_tab_protocolo_ted(vr_contador).vldocmto    ||'</vldocmto>'
                                                ||   '<nrdocmto>'||vr_tab_protocolo_ted(vr_contador).nrdocmto    ||'</nrdocmto>'
                                                ||   '<nrseqaut>'||vr_tab_protocolo_ted(vr_contador).nrseqaut    ||'</nrseqaut>'
                                                ||   '<dsinform1>'||vr_tab_protocolo_ted(vr_contador).dsinform##1 ||'</dsinform1>'
                                                ||   '<dsinform2>'||vr_tab_protocolo_ted(vr_contador).dsinform##2 ||'</dsinform2>'
                                                ||   '<dsinform3>'||vr_tab_protocolo_ted(vr_contador).dsinform##3 ||'</dsinform3>'
                                                ||   '<dsprotoc>'||vr_tab_protocolo_ted(vr_contador).dsprotoc ||'</dsprotoc>'
                                                ||   '<nmprepos>'||vr_tab_protocolo_ted(vr_contador).nmprepos ||'</nmprepos>'
                                                ||   '<nrcpfpre>'||vr_tab_protocolo_ted(vr_contador).nrcpfpre ||'</nrcpfpre>'
                                                ||   '<nmoperad>'||vr_tab_protocolo_ted(vr_contador).nmoperad ||'</nmoperad>'
                                                ||   '<nrcpfope>'||vr_tab_protocolo_ted(vr_contador).nrcpfope ||'</nrcpfope>'
                                                ||   '<cdbcoctl>'||vr_tab_protocolo_ted(vr_contador).cdbcoctl ||'</cdbcoctl>'
                                                ||   '<cdagectl>'||vr_tab_protocolo_ted(vr_contador).cdagectl ||'</cdagectl>'
                                                || '</protocolo>');
    END LOOP;

    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_tab_protocolo_ted
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</raiz>'
                           ,pr_fecha_xml      => TRUE);

    vr_xml_temp := NULL;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Não foi possivel verificar operacao:'|| SQLERRM;
    END;
  END pc_executa_envio_ted_prog;

  FUNCTION fn_verifica_lote_uso(pr_rowid rowid) RETURN NUMBER IS
    -- Verificar lote
    CURSOR cr_craplot IS
      SELECT craplot.rowid
        FROM craplot
       WHERE craplot.rowid = pr_rowid
       FOR UPDATE NOWAIT;
    rw_craplot cr_craplot%ROWTYPE;
  BEGIN
    /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
    FOR i IN 1..100 LOOP
      BEGIN
        -- Leitura do lote
        OPEN cr_craplot;
        FETCH cr_craplot INTO rw_craplot;
        CLOSE cr_craplot;

        EXIT;
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;

          -- setar critica caso for o ultimo
          IF i = 100 THEN
            RETURN 1; --> em uso
          END IF;
          -- aguardar 0,5 seg. antes de tentar novamente
          sys.dbms_lock.sleep(0.1);
      END;
    END LOOP;

    RETURN 0; --> liberado
  END;

  PROCEDURE pc_executa_reenvio_ted
                          (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Agencia
                          ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --> Caixa Operador
                          ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador Autorizacao
                          ,pr_idorigem IN INTEGER                --> Origem
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                          ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta Remetente
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --> CPF operador juridico
                          ,pr_cddbanco IN crapcti.cddbanco%TYPE  --> Banco destino
                          ,pr_cdageban IN crapcti.cdageban%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --> Conta transferencia
                          ,pr_nmtitula IN crapcti.nmtitula%TYPE  --> nome do titular destino
                          ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE  --> CPF do titular destino
                          ,pr_inpessoa IN crapcti.inpessoa%TYPE  --> Tipo de pessoa
                          ,pr_intipcta IN crapcti.intipcta%TYPE  --> Tipo de conta
                          ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor do lançamento
                          ,pr_dstransf IN VARCHAR2               --> Identificacao Transf.
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          ,pr_dshistor IN VARCHAR2               --> Descriçao do Histórico
                          ,pr_cdispbif IN INTEGER                --> ISPB Banco Favorecido
                          ,pr_flmobile IN INTEGER DEFAULT 0      --> Indicador se origem é do Mobile
                          ,pr_idagenda IN INTEGER                --> Tipo de agendamento
                          ,pr_iptransa IN VARCHAR2 DEFAULT NULL  --> IP da transacao no IBank/mobile
                          ,pr_dstransa IN VARCHAR2 DEFAULT NULL  --> Descrição da transacao no IBank/mobile
                          -- saida
                          ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Retorna protocolo
                          ,pr_tab_protocolo_ted OUT cxon0020.typ_tab_protocolo_ted --> dados do protocolo
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do erro
  BEGIN
    --Seta variavel de reenvio para poder desviar o fluxo no envio de TED, quando necessario
    vr_reenvio := 1;

    pc_executa_envio_ted(pr_cdcooper          => pr_cdcooper,
                         pr_cdagenci          => pr_cdagenci,
                         pr_nrdcaixa          => pr_nrdcaixa,
                         pr_cdoperad          => pr_cdoperad,
                         pr_idorigem          => pr_idorigem,
                         pr_dtmvtolt          => pr_dtmvtolt,
                         pr_nrdconta          => pr_nrdconta,
                         pr_idseqttl          => pr_idseqttl,
                         pr_nrcpfope          => pr_nrcpfope,
                         pr_cddbanco          => pr_cddbanco,
                         pr_cdageban          => pr_cdageban,
                         pr_nrctatrf          => pr_nrctatrf,
                         pr_nmtitula          => pr_nmtitula,
                         pr_nrcpfcgc          => pr_nrcpfcgc,
                         pr_inpessoa          => pr_inpessoa,
                         pr_intipcta          => pr_intipcta,
                         pr_vllanmto          => pr_vllanmto,
                         pr_dstransf          => pr_dstransf,
                         pr_cdfinali          => pr_cdfinali,
                         pr_dshistor          => pr_dshistor,
                         pr_cdispbif          => pr_cdispbif,
                         pr_flmobile          => pr_flmobile,
                         pr_idagenda          => pr_idagenda,
                         pr_iptransa          => pr_iptransa,
                         pr_dstransa          => pr_dstransa,
                         pr_dsprotoc          => pr_dsprotoc,
                         pr_tab_protocolo_ted => pr_tab_protocolo_ted,
                         pr_cdcritic          => pr_cdcritic,
                         pr_dscritic          => pr_dscritic);

    --Limpa a variavel de reenvio
    vr_reenvio := 0;
  END pc_executa_reenvio_ted;
END CXON0020;
/
