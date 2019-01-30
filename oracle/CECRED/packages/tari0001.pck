CREATE OR REPLACE PACKAGE CECRED.TARI0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: TARI0001                         Antiga: generico/procedures/b1wgen0153.p
  --  Autor   : Tiago Machado/Daniel Zimmermann
  --  Data    : Fevereiro/2013                  Ultima Atualizacao: 23/10/2018
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : BO referente ao projeto tarifas
  --
  --  Alteracoes: 17/07/2013 - Conversao Progress para oracle (Alisson - AMcom)
  --
  --              24/07/2013 - Retirado na leitura crapfco a verificacao da cdcooper
  --                           na procedure rel-receita-tarifas (Daniel).
  --
  --              02/08/2013 - Alteracoes na parte de cobranca nos cadastros e
  --                           buscas da cadtar(web) (Tiago).
  --
  --              21/08/2013 - Incluso novo parametro na procedure 'buscar-cadtar'
  --                          (Daniel).
  --
  --              23/08/2013 - Criada procedure carrega_dados_tarifa_emprestimo
  --                           (Tiago).
  --
  --              26/08/2013 - Criado registro linha padrao na procedure
  --                           lista-linhas-credito (Tiago).
  --
  --              03/10/2013 - Refeito a logica da procedure
  --                           carrega-atribuicao-detalhamento (Rodrigo/ Tiago).
  --
  --              10/10/2013 - Incluido parametro cdprogra nas procedures da
  --                           b1wgen0153 que carregam dados de tarifas (Tiago).
  --
  --              28/10/2013 - Incluso na procedure carrega_dados_tarifa_cobranca
  --                           novo processo de busca tarifa na craptar usando
  --                           fixo cdmotivo = "00" (Daniel).
  --
  --              13/08/2013 - Nova forma de chamar as agencias, alterado para
  --                           "Posto de Atendimento" (PA). (André Santos - SUPERO)
  --
  --              14/11/2013 - Fixado valor do campo crapfco.flgvigen para FALSE na
  --                           inclusao e alteracao de registro (Daniel).
  --
  --              25/11/2013 - Inclusao da procedure pc_carrega_par_tarifa_vigente (Jean Michel - CECRED)
  --
  --              02/12/2013 - Fixado utilixacao filtro crapfvl quando utilizar
  --                           chave cdtarifa (Daniel).
  --
  --              05/02/2014 - Tratamento para não dar erro de tarifa caso a
  --                           coop. não estiver ativa (crapcop.flgativo) (Lucas).
  --
  --              12/02/2014 - Retirado condicao "craplcr.flgstlcr = TRUE" dos FINDs
  --                           da craplcr (Tiago)
  --
  --              16/04/2014 - Incluido a funcao sq_sequencia para buscar o maior valor
  --                           (Andrino/RKAM)
  --
  --              02/09/2015 - Inclusão da procedure pc_verifica_tarifa_operacao Prj. 
  --                           Tarifas - 218 (Jean Michel)             
  --
  --              26/11/2015 - Alterado parametro pr_dtmvtolt da TARI0001.pc_cria_lan_auto_tarifa 
  --                           dentro da procedure pc_verifica_tarifa_operacao  (Jean Michel).             
  --
  --              14/12/2015 - Incluido tratamento para inpessoa = 3 na procedure pc_verifica_tarifa_operacao
  --                           (Jean Michel).
  --              
  --              05/01/2016 - Alteração na chamada da rotina extr0001.pc_obtem_saldo_dia
  --                           para passagem do parâmetro pr_tipo_busca, para melhoria
  --                           de performance.
  --                           Chamado 291693 (Heitor - RKAM)
  --              27/01/2016 - Incluido procedure pc_integra_deb_tarifa para debitar tarifas de conta integração
  --                           rodado por job todo quinto dia útil do mês, conforme solicitado no chamado 381175. 
  --                           (Kelvin)   
  --
  --			  10/02/2016 - Alteracao de parametro Fato Gerador(pc_verifica_tarifa_operacao), de rw_crapdat.dtmvtolt para
  --						   pr_dtmvtolt, SD 397975 (Jean Michel).
  --
  --              07/03/2016 - Alterado na procedure pc_deb_tarifa_online a data passada 
  --                           no update da tabela craplat no campo dtefetiv para dtmvtolt
  --                           conforme solicitado no chamado 413660 (Kelvin).
  --
  --              16/03/2016 - Corrigida variável de retorno na 'pc_cobra_tarifa_imgchq' quando Associado
  --                           não encontrado. De 'pr_dscritic' para 'vr_dscritic' (Guilherme/SUPERO)
  --
  --			  03/05/2016 - Retirado verificacao de 5 dia util na pc_deb_tarifa_online e adicionado na rotina
  --						   pc_controla_deb_tarifas (Lucas Ranghetti #412789)
  --
  --			  04/04/2016 - Alteracao de parametros para Prj. Tarifas - 2 na
  --                           procedure pc_verifica_tarifa_operacao(Jean Michel).
  --
  --              08/06/2016 - Tratada procedure pc_verifica_tarifa_operacao para criar
  --                           lancamento automatico somente quando vr_vltarifa > 0 (Diego)
  --
  --              08/02/2018 - Inclusão da procedure PC_CALCULA_TARIFA
  --                           Marcelo Telles Coelho - Projeto 410 - IOF
  --
  --              23/10/2018 - Padrões: Others, Modulo/Action, PC Internal Exception, PC Log Programa
  --                           Inserts, Updates, Deletes e SELECT's, Parâmetros, troca de mensagens por código
  --                           Parte 1: pc_verifica_pct_tari_web
  --                             (Envolti - Belli - REQ0011726)	 
  --
  --              20/11/2018 - Inclusao da rotina de estorno da tarifa de adiantamento a depositante (APD).
  --                         - PRJ435 - Adriano Nagasava (Supero).
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Tipos de registros para tabelas memoria */
  TYPE typ_reg_tarifas_dsctit
    IS RECORD (vltarctr NUMBER(5,2)
              ,vltarrnv NUMBER(5,2)
              ,vltarbdt NUMBER(5,2)
              ,vlttitcr NUMBER(5,2)
              ,vlttitsr NUMBER(5,2)
              ,vltrescr NUMBER(5,2)
              ,vltressr NUMBER(5,2));

  --Tipo de Registro para as tarifas pendentes
  TYPE typ_reg_tarifas_pend IS
    RECORD (cdtarifa   craptar.cdtarifa%TYPE,
            cdcooper   crapcop.cdcooper%TYPE,
            nmrescop   crapcop.nmrescop%TYPE,
            cdagenci   crapage.cdagenci%TYPE,
            nrdconta   crapass.nrdconta%TYPE,
            nmprimtl   crapass.nmprimtl%TYPE,
            dtmvtolt   crapdat.dtmvtolt%TYPE,
            dstarifa   craptar.dstarifa%TYPE,
            vltarifa   craplat.vltarifa%TYPE,
            cdoperad   craplat.cdoperad%TYPE,
            dsstatus   VARCHAR2(30),
            tarrowid   ROWID);

  --Tipo de Registro para as tarifas pendentes
  TYPE typ_reg_associado IS
    RECORD (nrdconta   crapass.nrdconta%TYPE,
            cdagenci   crapass.cdagenci%TYPE,
            nmprimtl   crapass.nmprimtl%TYPE,
            flgsaldo   BOOLEAN);

  TYPE typ_reg_coop IS
    RECORD (nmrescop   crapcop.nmrescop%TYPE);


  TYPE typ_tab_associado
    IS TABLE OF typ_reg_associado INDEX BY PLS_INTEGER;

  /* Tipos de tabela de memoria */
  TYPE typ_tab_tarifas_pend
    IS TABLE OF typ_reg_tarifas_pend INDEX BY PLS_INTEGER;
    
  TYPE typ_tab_conta_ssaldo
    IS TABLE OF NUMBER INDEX BY PLS_INTEGER;    
            
  TYPE typ_tab_coop
    IS TABLE OF typ_reg_coop INDEX BY PLS_INTEGER;

  /* Tipos de tabela de memoria */
  TYPE typ_tab_tarifas_dsctit
    IS TABLE OF typ_reg_tarifas_dsctit INDEX BY PLS_INTEGER;

  /* Tabela Memoria Vigencias */
  TYPE typ_reg_vigenc IS RECORD
    (cdfvlcop crapfco.cdfvlcop%TYPE
    ,dtvigenc crapfco.dtvigenc%TYPE
    ,nrconven crapfco.nrconven%TYPE
    ,cdlcremp crapfco.cdlcremp%TYPE
    ,cdocorre craptar.cdocorre%TYPE
    ,cdmotivo craptar.cdmotivo%TYPE
    ,cdfaixav crapfvl.cdfaixav%TYPE
    ,qtdiavig INTEGER);

  /* Tipo de tabela de memoria de vigencia */
  TYPE typ_tab_vigenc IS TABLE OF typ_reg_vigenc INDEX BY VARCHAR2(10);

  /* Vetor da tabela de memoria de vigencia */
  vr_tab_vigenc typ_tab_vigenc;

  /* Procedure para buscar dados da tarifa cobranca */
  PROCEDURE pc_carrega_dados_tarifa_cobr (pr_cdcooper  IN  INTEGER               --Codigo Cooperativa
                                         ,pr_nrdconta  IN  crapass.nrdconta%TYPE DEFAULT 0 --Numero da Conta
                                         ,pr_nrconven  IN  crapcco.nrconven%TYPE --Numero Convenio
                                         ,pr_dsincide  IN  VARCHAR2              --Descricao Incidencia
                                         ,pr_cdocorre  IN  craptar.cdocorre%TYPE --Codigo Ocorrencia
                                         ,pr_cdmotivo  IN  craptar.cdmotivo%TYPE --Codigo Motivo
                                         ,pr_inpessoa  IN  craptar.inpessoa%TYPE DEFAULT 0 --Tipo Pessoa
                                         ,pr_vllanmto  IN  NUMBER                --Valor Lancamento
                                         ,pr_cdprogra  IN  crapprg.cdprogra%TYPE --Nome Programa
                                         ,pr_flaputar  IN  NUMBER DEFAULT 0      --Flag (0/1) para indicar que haverá apuraçao desta tarifa
                                         ,pr_cdhistor  OUT INTEGER               --Codigo Historico
                                         ,pr_cdhisest  OUT INTEGER               --Historico Estorno
                                         ,pr_vltarifa  OUT NUMBER                --Valor Tarifa
                                         ,pr_dtdivulg  OUT DATE                  --Data Divulgacao
                                         ,pr_dtvigenc  OUT DATE                  --Data Vigencia
                                         ,pr_cdfvlcop  OUT INTEGER               --Codigo Cooperativa
                                         ,pr_cdcritic  OUT INTEGER  --Codigo Critica
                                         ,pr_dscritic  OUT VARCHAR2); --Descricao Critica

  /* Procedure para criar lancamento automatico tarifa */
  PROCEDURE pc_cria_lan_auto_tarifa (pr_cdcooper IN INTEGER --Codigo Cooperativa
                                    ,pr_nrdconta IN INTEGER --Numero da Conta
                                    ,pr_dtmvtolt IN DATE    --Data Lancamento
                                    ,pr_cdhistor IN INTEGER --Codigo Historico
                                    ,pr_vllanaut IN NUMBER  --Valor lancamento automatico
                                    ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                    ,pr_cdagenci IN INTEGER  --Codigo Agencia
                                    ,pr_cdbccxlt IN INTEGER  --Codigo banco caixa
                                    ,pr_nrdolote IN INTEGER  --Numero do lote
                                    ,pr_tpdolote IN INTEGER  --Tipo do lote
                                    ,pr_nrdocmto IN NUMBER   --Numero do documento
                                    ,pr_nrdctabb IN INTEGER  --Numero da conta
                                    ,pr_nrdctitg IN VARCHAR2 --Numero da conta integracao
                                    ,pr_cdpesqbb IN VARCHAR2 --Codigo pesquisa
                                    ,pr_cdbanchq IN INTEGER  --Codigo Banco Cheque
                                    ,pr_cdagechq IN INTEGER  --Codigo Agencia Cheque
                                    ,pr_nrctachq IN INTEGER  --Numero Conta Cheque
                                    ,pr_flgaviso IN BOOLEAN  --Flag aviso
                                    ,pr_tpdaviso IN INTEGER  --Tipo aviso
                                    ,pr_cdfvlcop IN INTEGER  --Codigo cooperativa
                                    ,pr_inproces IN INTEGER  --Indicador processo
                                    ,pr_rowid_craplat OUT ROWID --Rowid do lancamento tarifa
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela retorno erro
                                    ,pr_cdcritic OUT INTEGER --Codigo Critica
                                    ,pr_dscritic OUT VARCHAR2); --Descricao Critica

  /* Procedure responsavel por carregar dados da tarifa vigente   */
  PROCEDURE pc_carrega_dados_tar_vigente (pr_cdcooper  IN INTEGER  --Codigo Cooperativa
                                         ,pr_cdbattar  IN VARCHAR2 DEFAULT NULL --Codigo da sigla da tarifa (CRAPBAT) - Ao popular este parâmetro o pr_cdtarifa não é necessário
                                         ,pr_cdtarifa  IN NUMBER DEFAULT NULL   --Codigo da Tarifa (CRAPTAR) - Ao popular este parâmetro o pr_cdbattar não é necessário
                                         ,pr_vllanmto  IN NUMBER   --Valor Lancamento
                                         ,pr_cdprogra  IN VARCHAR2 --Codigo Programa
                                         ,pr_cdhistor  OUT INTEGER  --Codigo Historico
                                         ,pr_cdhisest  OUT NUMBER   --Historico Estorno
                                         ,pr_vltarifa  OUT NUMBER   --Valor tarifa
                                         ,pr_dtdivulg  OUT DATE     --Data Divulgacao
                                         ,pr_dtvigenc  OUT DATE     --Data Vigencia
                                         ,pr_cdfvlcop  OUT INTEGER  --Codigo faixa valor cooperativa
                                         ,pr_cdcritic  OUT INTEGER   --Codigo Critica
                                         ,pr_dscritic  OUT VARCHAR2   --Descricao Critica
                                         ,pr_tab_erro  OUT GENE0001.typ_tab_erro); --Tabela erros

  /* Procedure responsavel por carregar dados da tarifa vigente   */
  PROCEDURE pc_carrega_dados_tar_vigen_prg (pr_cdcooper  IN INTEGER     --Codigo Cooperativa
                                           ,pr_cdbattar  IN VARCHAR2    --Codigo da sigla da tarifa (CRAPBAT) - Ao popular este parâmetro o pr_cdtarifa não é necessário
                                           ,pr_cdprogra  IN VARCHAR2    --Codigo Programa
                                           ,pr_cdhistor  OUT INTEGER    --Codigo Historico
                                           ,pr_cdhisest  OUT NUMBER     --Historico Estorno
                                           ,pr_vltarifa  OUT NUMBER     --Valor tarifa
                                           ,pr_cdcritic  OUT INTEGER    --Codigo Critica
                                           ,pr_dscritic  OUT VARCHAR2); --Descricao Critica 

  /* Procedure para buscar tarifa intercooperativa */
  PROCEDURE pc_busca_tar_transf_intercoop (pr_cdcooper IN INTEGER --Codigo Cooperativa
                                          ,pr_cdagenci IN INTEGER --Codigo Agencia
                                          ,pr_nrdconta IN INTEGER --Numero da Conta
                                          ,pr_vllanmto IN OUT NUMBER  --Valor Lancamento
                                          ,pr_vltarifa OUT NUMBER --Valor Tarifa
                                          ,pr_cdhistor OUT INTEGER --Historico da tarifa
                                          ,pr_cdhisest OUT INTEGER --Historico estorno
                                          ,pr_cdfvlcop OUT INTEGER --Codigo faixa valor cooperativa
                                          ,pr_cdcritic OUT INTEGER     --C¿digo do erro
                                          ,pr_dscritic OUT VARCHAR2);   --Descricao do erro

  /* Lancamento de tarifas na Conta Corrente */
  PROCEDURE pc_lan_tarifa_conta_corrente (pr_cdcooper IN INTEGER   --Codigo Cooperativa
                                         ,pr_cdagenci IN INTEGER   --Codigo Agencia
                                         ,pr_nrdconta IN INTEGER   --Numero da Conta
                                         ,pr_cdbccxlt IN INTEGER   --Codigo Banco/Agencia/Caixa
                                         ,pr_nrdolote IN INTEGER   --Numero do Lote
                                         ,pr_tplotmov IN INTEGER   --Tipo Lote
                                         ,pr_cdoperad IN VARCHAR2  --Codigo Operador
                                         ,pr_dtmvtolt IN DATE      --Data Movimento Atual
                                         ,pr_nrdctabb IN INTEGER   --Numero Conta BB
                                         ,pr_nrdctitg IN VARCHAR2  --Numero Conta Integracao
                                         ,pr_cdhistor IN INTEGER   --Codigo Historico
                                         ,pr_cdpesqbb IN VARCHAR2  --Codigo Pesquisa
                                         ,pr_cdbanchq IN NUMBER    --Codigo Banco Cheque
                                         ,pr_cdagechq IN INTEGER   --Codigo Agencia Cheque
                                         ,pr_nrctachq IN INTEGER   --Numero Conta Cheque
                                         ,pr_flgaviso IN BOOLEAN   --Flag Aviso Debito CC
                                         ,pr_cdsecext IN INTEGER   --Codigo Extrato
                                         ,pr_tpdaviso IN INTEGER   --Tipo de Aviso
                                         ,pr_vltarifa IN NUMBER    --Valor da Tarifa
                                         ,pr_nrdocmto IN NUMBER    --Numero do Documento
                                         ,pr_cdageass IN INTEGER   --Codigo Agencia Associado
                                         ,pr_cdcoptfn IN INTEGER   --Codigo Cooperativa do Terminal
                                         ,pr_cdagetfn IN INTEGER   --Codigo Agencia do Terminal
                                         ,pr_nrterfin IN INTEGER   --Numero do Terminal
                                         ,pr_nrsequni IN INTEGER   --Numero Sequencial Unico
                                         ,pr_nrautdoc IN INTEGER   --Numero da Autenticacao do Documento
                                         ,pr_dsidenti IN VARCHAR2  --Descricao da Identificacao
                                         ,pr_inproces IN INTEGER   --Indicador do Processo
                                         ,pr_tab_erro OUT GENE0001.typ_tab_erro      --Tabela de retorno de erro
                                         ,pr_cdcritic OUT INTEGER      --C¿digo do erro
                                         ,pr_dscritic OUT VARCHAR2);

  /* Realizar Lan¿amento Tarifa Online */
  PROCEDURE pc_lan_tarifa_online (pr_cdcooper IN INTEGER  --Codigo Cooperativa
                                 ,pr_cdagenci IN INTEGER  --Codigo Agencia destino
                                 ,pr_nrdconta IN INTEGER  --Numero da Conta Destino
                                 ,pr_cdbccxlt IN INTEGER  --Codigo banco/caixa
                                 ,pr_nrdolote IN INTEGER  --Numero do Lote
                                 ,pr_tplotmov IN INTEGER  --Tipo Lote
                                 ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                 ,pr_dtmvtlat IN DATE     --Data Tarifa
                                 ,pr_dtmvtlcm IN DATE     --Data lancamento
                                 ,pr_nrdctabb IN INTEGER  --Numero Conta BB
                                 ,pr_nrdctitg IN VARCHAR2 --Conta Integracao
                                 ,pr_cdhistor IN INTEGER  --Codigo Historico
                                 ,pr_cdpesqbb IN VARCHAR2 --Codigo pesquisa
                                 ,pr_cdbanchq IN NUMBER   --Codigo Banco Cheque
                                 ,pr_cdagechq IN INTEGER  --Codigo Agencia Cheque
                                 ,pr_nrctachq IN INTEGER  --Numero Conta Cheque
                                 ,pr_flgaviso IN BOOLEAN  --Flag Aviso
                                 ,pr_tpdaviso IN INTEGER  --Tipo Aviso
                                 ,pr_vltarifa IN NUMBER   --Valor tarifa
                                 ,pr_nrdocmto IN NUMBER   --Numero Documento
                                 ,pr_cdcoptfn IN INTEGER  --Codigo Cooperativa Terminal
                                 ,pr_cdagetfn IN INTEGER  --Codigo Agencia Terminal
                                 ,pr_nrterfin IN INTEGER  --Numero Terminal Financeiro
                                 ,pr_nrsequni IN INTEGER  --Numero Sequencial Unico
                                 ,pr_nrautdoc IN INTEGER  --Numero Autenticacao Documento
                                 ,pr_dsidenti IN VARCHAR2 --Descricao Identificacao
                                 ,pr_cdfvlcop IN INTEGER  --Codigo Faixa Valor Cooperativa
                                 ,pr_inproces IN INTEGER  --Indicador Processo
                                 ,pr_cdlantar OUT craplat.cdlantar%type --Codigo Lancamento tarifa
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela de erro
                                 ,pr_cdcritic OUT INTEGER     --C¿digo do erro
                                 ,pr_dscritic OUT VARCHAR2);   --Descricao do erro

  /* Procedure para buscar dados da tarifa */
  PROCEDURE pc_busca_dados_tarifa (pr_cdcooper  IN  INTEGER               --Codigo Cooperativa
                                  ,pr_nrdconta  IN  INTEGER               --Numero da Conta
                                  ,pr_nrconven  IN  crapcco.nrconven%TYPE --Numero Convenio
                                  ,pr_dsincide  IN  VARCHAR2              --Descricao Incidencia
                                  ,pr_cdocorre  IN  craptar.cdocorre%TYPE --Codigo Ocorrencia
                                  ,pr_cdmotivo  IN  craptar.cdmotivo%TYPE --Codigo Motivo
                                  ,pr_idtabcob  IN  ROWID                 --ROWID Cobranca
                                  ,pr_flaputar  IN  NUMBER DEFAULT 0      --Flag (0/1) para indicar que haverá apuração desta tarifa
                                  ,pr_cdhistor  OUT INTEGER               --Codigo Historico
                                  ,pr_cdhisest  OUT INTEGER               --Historico Estorno
                                  ,pr_vltarifa  OUT NUMBER                --Valor Tarifa
                                  ,pr_dtdivulg  OUT DATE                  --Data Divulgacao
                                  ,pr_dtvigenc  OUT DATE                  --Data Vigencia
                                  ,pr_cdfvlcop  OUT INTEGER               --Codigo Cooperativa
                                  ,pr_cdcritic  OUT INTEGER               --Codigo Critica
                                  ,pr_dscritic  OUT VARCHAR2              --Descricao Critica
                                  ,pr_tab_erro  OUT GENE0001.typ_tab_erro); --Tabela erros

  PROCEDURE pc_car_dados_tar_empr_web (pr_cdcooper  IN  INTEGER               --Codigo Cooperativa
                                      ,pr_nrdconta  IN  INTEGER               --Conta do associado
                                      ,pr_cdlcremp  IN  craplcr.cdlcremp%TYPE --Linha Emprestimo
                                      ,pr_cdmotivo  IN  craptar.cdmotivo%TYPE --Codigo Motivo
                                      ,pr_inpessoa  IN  craptar.inpessoa%TYPE --Tipo Pessoa                                      
                                      ,pr_vllanmto  IN  NUMBER                --Valor Lancamento
                                      ,pr_dsbemgar  IN  VARCHAR2              --Relação de categoria de bens em garantia
                                      ,pr_cdprogra  IN VARCHAR2
                                      ,pr_xmllog    IN VARCHAR2               --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);             --> Erros do processo
                                      
  /* Procedure para buscar dados da tarifa emprestimo */
  PROCEDURE pc_carrega_dados_tarifa_empr (pr_cdcooper  IN  INTEGER               --Codigo Cooperativa
                                         ,pr_cdlcremp  IN  craplcr.cdlcremp%TYPE --Linha Emprestimo
                                         ,pr_cdmotivo  IN  craptar.cdmotivo%TYPE --Codigo Motivo
                                         ,pr_inpessoa  IN  craptar.inpessoa%TYPE --Tipo Pessoa
                                         ,pr_vllanmto  IN  NUMBER                --Valor Lancamento
                                         ,pr_cdprogra  IN  VARCHAR2              --Codigo Programa
                                         ,pr_cdhistor  OUT INTEGER               --Codigo Historico
                                         ,pr_cdhisest  OUT INTEGER               --Historico Estorno
                                         ,pr_vltarifa  OUT NUMBER                --Valor Tarifa
                                         ,pr_dtdivulg  OUT DATE                  --Data Divulgacao
                                         ,pr_dtvigenc  OUT DATE                  --Data Vigencia
                                         ,pr_cdfvlcop  OUT INTEGER               --Codigo Cooperativa
                                         ,pr_cdcritic  OUT INTEGER               --Codigo Critica
                                         ,pr_dscritic  OUT VARCHAR2              --Descricao Critica
                                         ,pr_tab_erro  OUT GENE0001.typ_tab_erro); --Tabela erros

  /* Procedure para buscar tarifa vigente */
  PROCEDURE pc_carrega_par_tarifa_vigente (pr_cdcooper  IN  INTEGER                   --Codigo Cooperativa
                                          ,pr_cdbattar  IN VARCHAR2                   --Sigla da Tarifa
                                          ,pr_dsconteu  OUT VARCHAR2                  --Descricao do parametro de tarifa
                                          ,pr_cdcritic  OUT INTEGER                   --Codigo Critica
                                          ,pr_dscritic  OUT VARCHAR2                  --Descricao Critica
                                          ,pr_des_erro  OUT VARCHAR2                  --Indicador de erro OK/NOK
                                          ,pr_tab_erro  OUT GENE0001.typ_tab_erro);   --Tabela erros

  /* Consulta por:                                       
      Saques feitos no meu TAA por outras Coops (pr_cdcoptfn <> 0)     
      Saques feitos por meus Assoc. em outras Coops (pr_cdcooper <> 0)  */
  PROCEDURE  pc_taa_lancamento_tarifas_ext(pr_cdcooper        IN  crapcop.cdcooper%TYPE, 
                                           pr_cdcoptfn        IN  craplcm.cdcoptfn%TYPE, 
                                           pr_tpextrat        IN  crapext.tpextrat%TYPE,
                                           pr_insitext        IN  VARCHAR2,
                                           pr_dtmvtoin        IN  DATE,
                                           pr_dtmvtofi        IN  DATE,
                                           pr_cdtplanc        IN  PLS_INTEGER,
                                           pr_dscritic        OUT VARCHAR2,
                                           pr_tab_lancamentos OUT cada0001.typ_tab_lancamentos);
                                           
  
  PROCEDURE pc_busca_tarifa_pendente(pr_cdcooper        IN  crapcop.cdcooper%TYPE,
                                     pr_cdcopatu        IN  crapcop.cdcooper%TYPE,
                                     pr_cdagenci        IN  crapage.cdagenci%TYPE,
                                     pr_cdoperad        IN  crapope.cdoperad%TYPE,
                                     pr_inpessoa        IN  crapass.inpessoa%TYPE,
                                     pr_nrdconta        IN  crapass.nrdconta%TYPE,
                                     pr_cdhistor        IN  craphis.cdhistor%TYPE,
                                     pr_cddgrupo        IN  crapgru.cddgrupo%TYPE,
                                     pr_cdsubgru        IN  crapsgr.cdsubgru%TYPE,                        
                                     pr_dtinicio        IN  DATE,
                                     pr_dtafinal        IN  DATE,                                     
                                     pr_dscritic        OUT VARCHAR2,
                                     pr_tab_tari_pend   OUT TARI0001.typ_tab_tarifas_pend);
  
  PROCEDURE pc_busca_tarifa_pend_web(pr_cdcooper IN  crapcop.cdcooper%TYPE 
                                    ,pr_cdcopatu IN  crapcop.cdcooper%TYPE 
                                    ,pr_cdagenci IN  crapage.cdagenci%TYPE
                                    ,pr_cdoperad IN  crapope.cdoperad%TYPE
                                    ,pr_inpessoa IN  crapass.inpessoa%TYPE
                                    ,pr_nrdconta IN  crapass.nrdconta%TYPE
                                    ,pr_cdhistor IN  craphis.cdhistor%TYPE
                                    ,pr_cddgrupo IN  crapgru.cddgrupo%TYPE
                                    ,pr_cdsubgru IN  crapsgr.cdsubgru%TYPE                                    
                                    ,pr_dtinicio IN  VARCHAR2
                                    ,pr_dtafinal IN  VARCHAR2                                                                          
                                    ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);                                         

  PROCEDURE pc_debita_tarifa_online(pr_cdcooper        IN  crapcop.cdcooper%TYPE,
                                    pr_cdoperad        IN  crapope.cdoperad%TYPE,
                                    pr_idorigem        IN  PLS_INTEGER,
                                    pr_nmdatela        IN  VARCHAR2,
                                    pr_listalat        IN  CLOB,
                                    pr_flimprim        IN  PLS_INTEGER DEFAULT 0,
                                    pr_nmarqpdf        OUT VARCHAR2,
                                    pr_dscritic        OUT VARCHAR2,
                                    pr_tab_tari_pend   IN OUT TARI0001.typ_tab_tarifas_pend);
                                    
  PROCEDURE pc_deb_tarifa_online_web(pr_listalat IN  CLOB
                                    ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);

  /* Procedimento para buscar todas as tarifas pendentes de debito e tentar debita-las */
  PROCEDURE pc_deb_tarifa_pend ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                ,pr_dtinicio IN DATE                    --> data de inicio para verificação das tarifas               
                                ,pr_dtafinal IN DATE                    --> data final para verificação das tarifas               
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                ,pr_dscritic OUT VARCHAR2);             --> Texto de erro/critica encontrada                                    
             
  /*  Procedimento para verificar se a conta possui lançamento de credito no dia
      e se possui saldo */
  PROCEDURE pc_verifica_credito (pr_cdcooper  IN crapcop.cdcooper%TYPE,      --> Codigo da cooperativa    
                                 pr_nrdconta  IN craplat.nrdconta%TYPE,      --> Numero da conta do cooperaro
                                 pr_vllimcre  IN crapass.vllimcre%TYPE,      --> limite de credito do cooperado
                                 pr_rcrapdat  IN btch0001.cr_crapdat%ROWTYPE,--> data da cooperativa 
                                 pr_flgvflcm  IN BOOLEAN,                    --> flag de controle se deve verificar lançamentos de credito    
                                 pr_flgvfsld  IN BOOLEAN,                    --> flag de controle se deve verificar saldo do cooperado
                                 pr_fposcred OUT BOOLEAN,                    --> Retorna flag se cooperado possui credito
                                 pr_tab_sald OUT EXTR0001.typ_tab_saldos,    --> Retorna saldo do cooperado
                                 pr_dscritic OUT VARCHAR2                    --> Retorna critica
                                 );                                                      
                                 
  /* Efetua cobrança de tarifa */
  PROCEDURE pc_cobra_tarifa_imgchq (pr_cdagechq  IN NUMBER
                            ,pr_nrctachq  IN NUMBER
                            ,pr_xmllog    IN VARCHAR2             --> XML com informac?es de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                            ,pr_retxml    IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  /* Efetua verificacao para cobrancas de tarifas sobre operacoes */
  PROCEDURE pc_verifica_tarifa_operacao(pr_cdcooper IN NUMBER                   --> Codigo da Cooperativa
                                       ,pr_cdoperad IN VARCHAR2                 --> Codigo Operador
                                       ,pr_cdagenci IN INTEGER                  --> Codigo Agencia
                                       ,pr_cdbccxlt IN INTEGER                  --> Codigo banco caixa
                                       ,pr_dtmvtolt IN DATE                     --> Data Lancamento
                                       ,pr_cdprogra IN crapprg.cdprogra%TYPE    --> Nome do Programa que chama a rotina
                                       ,pr_idorigem IN INTEGER                  --> Identificador Origem(1-AYLLOS,2-CAIXA,3-INTERNET,4-TAA,5-AYLLOS WEB,6-URA)
                                       ,pr_nrdconta IN INTEGER                  --> Numero da Conta
                                       ,pr_tipotari IN INTEGER                  --> Tipo de Tarifa(1-Saque,2-Consulta)
                                       ,pr_tipostaa IN INTEGER                    --> Tipo de TAA que foi efetuado a operacao(0-Cooperativas Filiadas,1-BB, 2-Banco 24h, 3-Banco 24h compartilhado, 4-Rede Cirrus)
                                       ,pr_qtoperac IN INTEGER                  --> Quantidade de registros da operação (Custódia, contra-ordem, folhas de cheque)
                                       ,pr_nrdocumento IN NUMBER default null     --> numero do documento (somente para saque)
                                       ,pr_hroperacao  IN NUMBER default null     --> hora de realização da operação de saque
                                       ,pr_qtacobra OUT INTEGER                 --> Quantidade de registros a cobrar tarifa na operação
                                       ,pr_fliseope OUT INTEGER                 --> Flag indica se ira isentar tarifa:0-Não isenta,1-Isenta
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo da critica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao da critica  
  
  /* Verificacao agencia da cooperativa */
  PROCEDURE pc_busca_agencia_cop(pr_cdagectl IN crapcop.cdagectl%TYPE
                                 ,pr_xmllog    IN VARCHAR2             --> XML com informac?es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                 ,pr_retxml    IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                 
  PROCEDURE pc_integra_deb_tarifa (pr_cdcooper IN crapcop.cdcooper%TYPE);   --> Cooperativa solicitada                            
  
  PROCEDURE pc_gera_log_lote_uso(pr_cdcooper IN craplot.cdcooper%TYPE,
                                 pr_nrdconta IN crapass.nrdconta%TYPE,
                                 pr_nrdolote IN craplot.nrdolote%TYPE,
                                 pr_flgerlog IN OUT VARCHAR2,
                                 pr_des_log IN VARCHAR2);                               
     
  -- Rotina para verificar pacote de tarifas
  PROCEDURE pc_verifica_pacote_tarifas(pr_cdcooper  IN craprac.cdcooper%TYPE   --> Código da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE   --> Numero da Conta
                                      ,pr_idorigem  IN NUMBER                  --> Origem
                                      ,pr_tpservic  IN NUMBER                  --> Tipo de Servico
                                      ,pr_flpacote OUT NUMBER                  --> Flag de Pacote
                                      ,pr_flservic OUT NUMBER                  --> Flag de Sevico
                                      ,pr_qtopdisp OUT NUMBER                  --> Quantidade de Operacoes Disponiveis
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Código da crítica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descrição da crítica                                  

  -- Rotina para verificar pacote de tarifas via web
  PROCEDURE pc_verifica_pct_tari_web(pr_cdcooper IN craprac.cdcooper%TYPE  --> Código da Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da Conta
                                    ,pr_tpservic IN NUMBER                 --> Tipo de Servico
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
   
  /*****************************************************************************
  Estorno/Baixa de lancamento de tarifas
  ******************************************************************************/
  PROCEDURE pc_estorno_baixa_tarifa (pr_cdcooper  IN INTEGER  --> Codigo Cooperativa
                                    ,pr_cdagenci  IN INTEGER  --> Codigo Agencia
                                    ,pr_nrdcaixa  IN INTEGER  --> Numero do caixa
                                    ,pr_cdoperad  IN VARCHAR2 --> Codigo Operador
                                    ,pr_dtmvtolt  IN DATE     --> Data Lancamento
                                    ,pr_nmdatela  IN VARCHAR2 --> Nome da tela       
                                    ,pr_idorigem  IN INTEGER  --> Indicador de origem
                                    ,pr_inproces  IN INTEGER  --> Indicador processo
                                    ,pr_nrdconta  IN INTEGER  --> Numero da Conta
                                    ,pr_cddopcap  IN INTEGER  --> Codigo de opcao --> 1 - Estorno de tarifa
                                                                                  --> 2 - Baixa de tarifa
                                    ,pr_lscdlant  IN VARCHAR2 --> Lista de lancamentos de tarifa(delimitador ;)
                                    ,pr_lscdmote  IN VARCHAR2 --> Lista de motivos de estorno (delimitador ;)
                                    ,pr_flgerlog  IN VARCHAR2 --> Indicador se deve gerar log (S-sim N-Nao)
                                    ,pr_cdcritic OUT INTEGER      --> Codigo Critica
                                    ,pr_dscritic OUT VARCHAR2);   --> Descricao Critica
                                    
                                    
  PROCEDURE pc_calcula_tarifa (pr_cdcooper  IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                              ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta do associado
                              ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE --> Codigo da linha de credito do emprestimo.
                              ,pr_vlemprst  IN crapepr.vlemprst%TYPE --> Valor do emprestimo.
                              ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE --> Codigo de uso da linha de credito (0-Normal/1-CDC/2-Boletos)
                              ,pr_tpctrato  IN craplcr.tpctrato%TYPE --> Tipo de contrato utilizado por esta linha de credito.
                              ,pr_dsbemgar  IN VARCHAR2              --> Relação de categoria de bens em garantia
                              ,pr_cdprogra  IN VARCHAR2              --> Nome do programa chamador
                              ,pr_flgemail  IN VARCHAR2              --> Envia e-mail S/N, se N interrompe o processo em caso de erro
                              ,pr_tpemprst  in crapepr.tpemprst%type DEFAULT NULL --> tipo de emprestimo
                              ,pr_idfiniof  IN crapepr.idfiniof%type DEFAULT 0
                              --
                              ,pr_vlrtarif OUT crapfco.vltarifa%TYPE --> Valor da tarifa calculada
                              ,pr_vltrfesp OUT craplcr.vltrfesp%TYPE --> Valor da tarifa especial calculada
                              ,pr_vltrfgar OUT crapfco.vltarifa%TYPE --> Valor da tarifa garantia calculada
                              ,pr_cdhistor OUT craphis.cdhistor%TYPE --> Codigo do historico do lancamento.
                              ,pr_cdfvlcop OUT crapfco.cdfvlcop%TYPE --> Codigo da faixa de valor por cooperativa.
                              ,pr_cdhisgar OUT craphis.cdhistor%TYPE --> Codigo do historico de bens em garantia
                              ,pr_cdfvlgar OUT crapfco.cdfvlcop%TYPE --> Código da faixa de valor dos bens em garantia							  
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                              ,pr_dscritic OUT VARCHAR2              --> Texto de erro/critica encontrada
                              );

  PROCEDURE pc_efetiva_tarifa (pr_rowid_craplat in ROWID      --Rowid da tarifa
                              ,pr_dtmvtolt      DATE          --Data Lancamento
                              ,pr_cdcritic      OUT INTEGER   --Codigo Critica
                              ,pr_dscritic      OUT VARCHAR2);--Descricao Critica                              

  PROCEDURE pc_envia_email_tarifa(pr_rowid  IN rowid,pr_des_erro OUT varchar2);

  /* Verificar se o saque será tarifado e o valor da tarifa */
  PROCEDURE pc_verifica_tarifa_saque(pr_cdcooper IN NUMBER                   --> Codigo da Cooperativa
                                    ,pr_dtmvtolt IN DATE                     --> Data Lancamento
                                    ,pr_idorigem IN INTEGER                  --> Identificador Origem(1-AYLLOS,2-CAIXA,3-INTERNET,4-TAA,5-AYLLOS WEB,6-URA)
                                    ,pr_nrdconta IN INTEGER                  --> Numero da Conta
                                    ,pr_tipostaa IN INTEGER                  --> Tipo de TAA que foi efetuado a operacao(0-Cooperativas Filiadas,1-BB, 2-Banco 24h, 3-Banco 24h compartilhado, 4-Rede Cirrus)
                                    ,pr_fliseope OUT INTEGER                 --> Flag indica se ira isentar tarifa:0-Não isenta,1-Isenta
                                    ,pr_vltarifa OUT NUMBER                  --> Valor da Tarifa
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo da critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao da critica  
  -- Estorno da tarifa de ADP
	PROCEDURE pc_estorno_tarifa_adp(pr_cdcooper IN  craplat.cdcooper%TYPE
																 ,pr_nrdconta IN  craplat.nrdconta%TYPE
																 ,pr_dscritic OUT VARCHAR2
		                             );
                              
  /* Procedure para estorno de tarifa de saque*/
  procedure pc_estorno_tarifa_saque (pr_cdcooper  IN INTEGER  --> Codigo Cooperativa
                                    ,pr_cdagenci  IN INTEGER  --> Codigo Agencia
                                    ,pr_nrdcaixa  IN INTEGER  --> Numero do caixa
                                    ,pr_cdoperad  IN VARCHAR2 --> Codigo Operador
                                    ,pr_dtmvtolt  IN DATE     --> Data Lancamento
                                    ,pr_nmdatela  IN VARCHAR2 --> Nome da tela       
                                    ,pr_idorigem  IN INTEGER  --> Indicador de origem
                                    ,pr_nrdconta  IN INTEGER  --> Numero da Conta
                                    ,pr_nrdocmto  IN INTEGER  --> Numero do documento
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE); 
                                       
  -- Rotina de Log - tabela: tbgen prglog ocorrencia
  PROCEDURE pc_log(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                  ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                  ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                  ,pr_tpexecuc IN NUMBER   DEFAULT 0   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                  ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                  ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                  ,pr_nmrotina IN VARCHAR2 DEFAULT 'TARI0001'
                  ,pr_cdcooper IN VARCHAR2 DEFAULT 0
                  );                              
END TARI0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TARI0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TARI0001
  --  Sistema  : Procedimentos envolvendo tarifas bancarias
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: 23/10/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para agendamentos na Internet

  /* Alteracoes: 27/08/2015 - Inclusão da procedure pc_cobra_tarifa
                              Projeto de TARIFAS - Lombardi
               
                 02/09/2015 - Inclusão da procedure pc_verifica_tarifa_operacao Prj. Tarifas - 218 (Jean Michel)                            

                 26/11/2015 - Alterado parametro pr_dtmvtolt da TARI0001.pc_cria_lan_auto_tarifa 
                              dentro da procedure pc_verifica_tarifa_operacao  (Jean Michel).

                 14/12/2015 - Incluido tratamento para inpessoa = 3 na procedure pc_verifica_tarifa_operacao
                              (Jean Michel). 
                 
                 05/01/2016 - Alteração na chamada da rotina extr0001.pc_obtem_saldo_dia
                              para passagem do parâmetro pr_tipo_busca, para melhoria
                              de performance.
                              Chamado 291693 (Heitor - RKAM)

                 27/01/2016 - Incluido procedure pc_integra_deb_tarifa para debitar tarifas de conta integração
                              rodado por job todo quinto dia útil do mês, conforme solicitado no chamado 381175. 
                              (Kelvin)            
                              
                 12/02/2016 - PRJ 213 - Reciprocidade. (Jaison/Marcos)

                 26/02/2016 - Criado rotina pc_gera_log_lote_uso para monitorar a criação dos lotes no TED.(Odirlei-AMcom)             
					   
                 07/03/2016 - Alterado na procedure pc_deb_tarifa_online a data passada 
                              no update da tabela craplat no campo dtefetiv para dtmvtolt
                              conforme solicitado no chamado 413660 (Kelvin).
 
                 04/04/2016 - Alteracao de parametros para Prj. Tarifas - 2 na 
                              procedure pc_verifica_tarifa_operacao(Jean Michel). 
																
								 28/04/2016 - Adicionado chamada da procedure pc_verifica_tarifa_operacao
								              em pc_integra_deb_tarifa. PRJ 218/2 (Reinert).

                 03/05/2016 - Retirado verificacao de 5 dia util na pc_deb_tarifa_online e adicionado na rotina
  						                pc_controla_deb_tarifas (Lucas Ranghetti #412789)
                              
                 15/09/2016 - #519899 Criação de log de controle de início, erros e fim de execução
                              do job pc_deb_tarifa_pend (Carlos)
                              
                 29/03/2017 - #640389 Alterada a forma como era feito o insert na lcm, na rotina
                              pc_lan_tarifa_conta_corrente, passando a tratar com DUP_VAL_ON_INDEX,
                              dispensando a consulta do mesmo antes da inserção (Carlos)

				 11/07/2017 - Melhoria 150 - Adicionado calculo de tarifa por faixa percentual			    

				 25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                  crapass, crapttl, crapjur 
							  (Adriano - P339).

                08/02/2018 - Inclusão da procedure PC_CALCULA_TARIFA
                             Marcelo Telles Coelho - Projeto 410 - IOF
                             
                29/05/2018 - P450 - Implementacao das chamadas a rotina de lancamento em conta, para controle dos
                             lancamentos de historico.
                            Marcel Kohls (AMcom)                         

                23/10/2018 - Padrões: Others, Modulo/Action, PC Internal Exception, PC Log Programa
                             Inserts, Updates, Deletes e SELECT's, Parâmetros, troca de mensagens por código
                             Parte 1: pc_log
                                      pc_verifica_pct_tari_web
                                      pc_verifica_pacote_tarifas
                                      pc_carrega_dados_tar_vigente
                                      pc_verifica_tarifa_saque
                                      pc_gera_log_lote_uso
                                      pc_carrega_par_tarifa_vigente
                                      pc_estorno_baixa_tarifa
                                      pc_taa_lancamento_tarifas_ext
                                      pc_busca_tar_transf_intercoop
                               (Envolti - Belli - REQ0011726)                             

	               20/11/2018 - Inclusao da rotina de estorno da tarifa de adiantamento a depositante (APD).
	                          - PRJ435 - Adriano Nagasava (Supero).	  
                20/11/2018 - Alteração da pc_tarifa_operação para tarifar saques avulsos e realizar controle de tempo de 30 min para a tarifacao.
                             (Fabio Stein - Supero)
                20/11/2018 - incluido procedure  pc_estorno_tarifa_saque para estorno de tarifa de saque.
                             (Fabio Stein - Supero)
                             

  */
 
  ---------------------------------------------------------------------------------------------------------------

  /* Cursores da Package */

  -- Busca do diretorio conforme a cooperativa conectada
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.dsdircop
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.nmrescop
          ,crapcop.flgativo
    FROM crapcop crapcop
    WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca dos dados do associado
  CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.vllimcre
          ,crapass.nrcpfcgc
          ,crapass.inpessoa
          ,crapass.cdcooper
          ,crapass.cdsecext
          ,crapass.cdagenci
          ,crapass.dtdemiss
    FROM crapass
    WHERE crapass.cdcooper = pr_cdcooper
    AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

    --Buscar informacoes de lote
  CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                    ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                    ,pr_cdagenci IN craplot.cdagenci%TYPE
                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                    ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT  craplot.nrdolote
           ,craplot.nrseqdig
           ,craplot.cdbccxlt
           ,craplot.cdcooper
           ,craplot.dtmvtolt
           ,craplot.cdagenci
           ,craplot.rowid
    FROM craplot craplot
    WHERE craplot.cdcooper = pr_cdcooper
    AND   craplot.dtmvtolt = pr_dtmvtolt
    AND   craplot.cdagenci = pr_cdagenci
    AND   craplot.cdbccxlt = pr_cdbccxlt
    AND   craplot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;

  --Selecionar erros
  CURSOR cr_craperr (pr_cdcooper IN craperr.cdcooper%type
                    ,pr_cdagenci IN craperr.cdagenci%type
                    ,pr_nrdcaixa IN craperr.nrdcaixa%type) IS
    SELECT craperr.dscritic
    FROM craperr craperr
    WHERE craperr.cdcooper = pr_cdcooper
    AND   craperr.cdagenci = pr_cdagenci
    AND   craperr.nrdcaixa = pr_nrdcaixa;
    rw_craperr cr_craperr%ROWTYPE;

  --Selecionar informacoes dos bancos
  CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%type) IS
    SELECT crapban.nmresbcc
          ,crapban.nmextbcc
    FROM crapban
    WHERE crapban.cdbccxlt = pr_cdbccxlt;
  rw_crapban cr_crapban%ROWTYPE;  

  --Selecionar faixa valor tarifa
  CURSOR cr_crapfvl (pr_cdtarifa IN crapfvl.cdtarifa%type
                    ,pr_vllanmto IN crapfvl.vlinifvl%type) IS
    SELECT crapfvl.cdfaixav
          ,crapfvl.cdhistor
          ,crapfvl.cdhisest
          ,crapfvl.cdtarifa
    FROM crapfvl
    WHERE crapfvl.cdtarifa = pr_cdtarifa
    AND nvl(pr_vllanmto,0) BETWEEN crapfvl.vlinifvl AND crapfvl.vlfinfvl
    ORDER BY crapfvl.progress_recid DESC;
  rw_crapfvl cr_crapfvl%ROWTYPE;

  --Selecionar faixa valor cooperativa
  CURSOR cr_crapfco (pr_cdcooper IN crapfco.cdcooper%type
                    ,pr_cdfaixav IN crapfco.cdfaixav%type
                    ,pr_flgvigen IN crapfco.flgvigen%type) IS
    SELECT crapfco.vltarifa
          ,crapfco.dtdivulg
          ,crapfco.dtvigenc
          ,crapfco.cdfvlcop
          ,crapfco.cdfaixav
          ,crapfco.tpcobtar
          ,crapfco.vlpertar
          ,crapfco.vlmintar
          ,crapfco.vlmaxtar
    FROM crapfco
    WHERE crapfco.cdcooper = pr_cdcooper
    AND   crapfco.cdfaixav = pr_cdfaixav
    AND   crapfco.flgvigen = pr_flgvigen;
  rw_crapfco cr_crapfco%ROWTYPE;

  -- Busca dados referente ao batch e tarifas
  CURSOR cr_crapbat(pr_cdbattar IN crapbat.cdbattar%TYPE) IS
    SELECT crapbat.cdcadast -- Codigo do cadastro
    FROM crapbat
    WHERE crapbat.cdbattar = pr_cdbattar; -- Sigla da Tarifa

  rw_crapbat cr_crapbat%ROWTYPE;

  -- Busca dados referente as tarifas de cooperativas
  CURSOR cr_crappco(pr_cdcooper IN crapfco.cdcooper%TYPE
                   ,pr_cdcadast IN crapbat.cdcadast%TYPE) IS
    SELECT crappco.dsconteu
    FROM crappco
    WHERE crappco.cdcooper = pr_cdcooper
    AND   crappco.cdpartar = pr_cdcadast
    ORDER BY crappco.progress_recid ASC;
  rw_crappco cr_crappco%ROWTYPE;

  --Tipo de Dados para cursor data
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_vltarifa crapfco.vltarifa%TYPE;
  -- Variaveis de Log e Modulo - 23/10/2018 - REQ0011726
  vr_cdproexe VARCHAR2  (100) := 'TARI0001';

  /* Procedure para buscar dados da tarifa cobranca */
  PROCEDURE pc_carrega_dados_tarifa_cobr (pr_cdcooper  IN  INTEGER               --Codigo Cooperativa
                                         ,pr_nrdconta  IN  crapass.nrdconta%TYPE DEFAULT 0 --Numero da Conta
                                         ,pr_nrconven  IN  crapcco.nrconven%TYPE --Numero Convenio
                                         ,pr_dsincide  IN  VARCHAR2              --Descricao Incidencia
                                         ,pr_cdocorre  IN  craptar.cdocorre%TYPE --Codigo Ocorrencia
                                         ,pr_cdmotivo  IN  craptar.cdmotivo%TYPE --Codigo Motivo
                                         ,pr_inpessoa  IN  craptar.inpessoa%TYPE DEFAULT 0 --Tipo Pessoa
                                         ,pr_vllanmto  IN  NUMBER                --Valor Lancamento
                                         ,pr_cdprogra  IN  crapprg.cdprogra%TYPE --Nome Programa
                                         ,pr_flaputar  IN  NUMBER DEFAULT 0      --Flag (0/1) para indicar que haverá apuração desta tarifa
                                         ,pr_cdhistor  OUT INTEGER               --Codigo Historico
                                         ,pr_cdhisest  OUT INTEGER               --Historico Estorno
                                         ,pr_vltarifa  OUT NUMBER                --Valor Tarifa
                                         ,pr_dtdivulg  OUT DATE                  --Data Divulgacao
                                         ,pr_dtvigenc  OUT DATE                  --Data Vigencia
                                         ,pr_cdfvlcop  OUT INTEGER               --Codigo Cooperativa
                                         ,pr_cdcritic  OUT INTEGER  --Codigo Critica
                                         ,pr_dscritic  OUT VARCHAR2) IS --Descricao Critica
    -- ........................................................................
    --
    --  Programa : pc_carrega_dados_tarifa_cobr           Antigo: b1wgen0153.p/carrega_dados_tarifa_cobranca
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 12/02/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para buscar dados da tarifa cobranca
    --
    --   Atualizacao: 27/08/2013 - Adequar programa conforme modificacoes progress
    --
    --                12/02/2016 - Alteracao na assinatura e na rotina. (Jaison/Marcos)
    --
  BEGIN
    DECLARE
      --Cursores Locais

      --Selecionar tipo de incidencia da tarifa
      CURSOR cr_crapint (pr_dsinctar IN crapint.dsinctar%type) IS
        SELECT crapint.cdinctar
        FROM  crapint
        WHERE UPPER(crapint.dsinctar) LIKE UPPER(pr_dsinctar||'%')
        ORDER BY crapint.progress_recid ASC;
      rw_crapint cr_crapint%ROWTYPE;
      --Selecionar tarifas
      CURSOR cr_craptar (pr_cdinctar IN craptar.cdinctar%type
                        ,pr_cdocorre IN craptar.cdocorre%type
                        ,pr_cdmotivo IN craptar.cdmotivo%type
                        ,pr_inpessoa IN craptar.inpessoa%type) IS
        SELECT craptar.cdtarifa
              ,craptar.cdocorre
              ,craptar.cdmotivo
        FROM craptar
        WHERE craptar.cdinctar = pr_cdinctar
        AND   craptar.cdocorre = pr_cdocorre
        AND  (trim(pr_cdmotivo) IS NULL OR craptar.cdmotivo = pr_cdmotivo)
        AND   craptar.inpessoa = pr_inpessoa
        ORDER BY craptar.progress_recid ASC;
      rw_craptar cr_craptar%ROWTYPE;
      --Selecionar faixa valor cooperativa
      CURSOR cr_crapfco (pr_cdcooper IN crapfco.cdcooper%type
                        ,pr_nrconven IN crapfco.nrconven%type
                        ,pr_cdfaixav IN crapfco.cdfaixav%type
                        ,pr_flgvigen IN crapfco.flgvigen%type) IS
        SELECT crapfco.vltarifa
              ,crapfco.dtdivulg
              ,crapfco.dtvigenc
              ,crapfco.cdfvlcop
              ,crapfco.nrconven
              ,crapfco.cdfaixav
              ,crapfco.tpcobtar
              ,crapfco.vlpertar
              ,crapfco.vlmintar
              ,crapfco.vlmaxtar
              ,COUNT(*) over (PARTITION BY crapfco.cdfvlcop) qtdreg
        FROM crapfco
        WHERE crapfco.cdcooper = pr_cdcooper
        AND   crapfco.nrconven = pr_nrconven
        AND   crapfco.cdfaixav = pr_cdfaixav
        AND   crapfco.flgvigen = pr_flgvigen;
      rw_crapfco cr_crapfco%ROWTYPE;
      --Selecionar faixa cooperativa
      CURSOR cr_crapfco2 (pr_cdfvlcop IN crapfco.cdfvlcop%type) IS
        SELECT crapfco.vltarifa
              ,crapfco.dtdivulg
              ,crapfco.dtvigenc
              ,crapfco.cdfvlcop
              ,crapfco.nrconven
              ,crapfco.cdfaixav
              ,crapfco.tpcobtar
              ,crapfco.vlpertar
              ,crapfco.vlmintar
              ,crapfco.vlmaxtar
              ,1 qtdreg
        FROM crapfco
        WHERE crapfco.cdfvlcop = pr_cdfvlcop;
      --Selecionar a categoria da tarifa com desconto
      CURSOR cr_tar_ctc (pr_cdcooper IN tbcobran_categ_tarifa_conven.cdcooper%TYPE
                        ,pr_nrdconta IN tbcobran_categ_tarifa_conven.nrdconta%TYPE
                        ,pr_nrconven IN tbcobran_categ_tarifa_conven.nrconven%TYPE
                        ,pr_cdtarifa IN craptar.cdtarifa%TYPE) IS
        SELECT ctc.perdesconto
          FROM craptar tar
              ,tbcobran_categ_tarifa_conven ctc
         WHERE tar.cdtarifa = pr_cdtarifa
           AND tar.cdcatego = ctc.cdcatego
           AND ctc.cdcooper = pr_cdcooper
           AND ctc.nrdconta = pr_nrdconta
           AND ctc.nrconven = pr_nrconven;
      rw_tar_ctc cr_tar_ctc%ROWTYPE;
      --Verifica se o convenio possui reciprocidade ativa
      CURSOR cr_crapceb (pr_cdcooper IN crapceb.cdcooper%TYPE
                        ,pr_nrdconta IN crapceb.nrdconta%TYPE
                        ,pr_nrconven IN crapceb.nrconven%TYPE) IS
        SELECT crapceb.idrecipr
          FROM crapceb
         WHERE crapceb.cdcooper = pr_cdcooper
           AND crapceb.nrdconta = pr_nrdconta
           AND crapceb.nrconven = pr_nrconven;
      --Verifica se o periodo de apuracao ainda nao foi criado
      CURSOR cr_apuracao(pr_cdcooper        IN tbrecip_apuracao.cdcooper%TYPE
                        ,pr_nrdconta        IN tbrecip_apuracao.nrdconta%TYPE
                        ,pr_cdchave_produto IN tbrecip_apuracao.cdchave_produto%TYPE
                        ,pr_idconfig        IN tbrecip_apuracao.idconfig_recipro%TYPE) IS
        SELECT COUNT(1)
          FROM tbrecip_apuracao
         WHERE idconfig_recipro     = pr_idconfig
           AND cdcooper             = pr_cdcooper
           AND nrdconta             = pr_nrdconta
           AND cdproduto            = 6 -- Cobranca
           AND cdchave_produto      = pr_cdchave_produto
           AND indsituacao_apuracao = 'A'; -- Em aberto
      --Buscar a configuracao do calculo para criacao do periodo
      CURSOR cr_confrec (pr_idcalculo_reciproci IN tbrecip_calculo.idcalculo_reciproci%TYPE) IS
        SELECT qtdmes_retorno_reciproci
          FROM tbrecip_calculo
         WHERE idcalculo_reciproci = pr_idcalculo_reciproci;

      --Variaveis Locais
      vr_inpessoa crapass.inpessoa%TYPE;
      vr_dspessoa VARCHAR2(20);
      vr_index_vigenc VARCHAR2(10);
      vr_cdmotivo craptar.cdmotivo%TYPE:= pr_cdmotivo;
      vr_contador INTEGER:= 0;
      vr_cdfvlcop INTEGER:= 0;
      vr_crapfco  BOOLEAN:= FALSE;
      vr_blnfound BOOLEAN;
      vr_vltarids NUMBER;
      vr_idrecipr crapceb.idrecipr%TYPE;
      vr_qtapurac NUMBER;
      vr_qtmesrec tbrecip_calculo.qtdmes_retorno_reciproci%TYPE;
      vr_idapurec tbrecip_apuracao.idapuracao_reciproci%TYPE;
      --Variaveis de erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      -- Caso nao foi informado o tipo de pessoa e conta
      IF pr_inpessoa = 0 AND pr_nrdconta = 0 THEN
        vr_dscritic := 'Conta e Tipo pessoa nao informados – impossivel buscar tarifa!';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Se o tipo de pessoa for zero
      IF pr_inpessoa = 0 THEN
        --Selecionar associado
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
        --Posicionar no proximo registro
        FETCH cr_crapass INTO rw_crapass;
        -- Alimenta a booleana se achou ou nao
        vr_blnfound := cr_crapass%FOUND;
        --Fechar Cursor
        CLOSE cr_crapass;
        --Se nao encontrar
        IF NOT vr_blnfound THEN
          vr_dscritic:= 'Associado nao cadastrado.';
          RAISE vr_exc_erro;
        ELSE
          vr_inpessoa := rw_crapass.inpessoa;
        END IF;
      ELSE
        vr_inpessoa := pr_inpessoa;
      END IF;

      --Selecionar Tipo de Incidencia de tarifa
      OPEN cr_crapint (pr_dsinctar => pr_dsincide);
      --Posicionar no proximo registro
      FETCH cr_crapint INTO rw_crapint;
      --Se nao encontrar
      IF cr_crapint%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapint;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Tipo de incidencia de tarifa nao cadastrada!';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapint;

      /* Tratamento para caso parametro venha zerado */
       IF TRIM(vr_cdmotivo) = '0' THEN
         --Atribuir nulo
         vr_cdmotivo:= NULL;
       END IF;
       --Se o Motivo for nulo
       IF TRIM(vr_cdmotivo) IS NOT NULL THEN
         --Se o motivo possuir apenas 1 digito
         IF nvl(length(vr_cdmotivo),0) < 2 THEN
           --Concatenar Zero
           vr_cdmotivo:= '0'||vr_cdmotivo;
         END IF;
       END IF;

      --Selecionar as tarifas
      OPEN cr_craptar (pr_cdinctar => rw_crapint.cdinctar
                      ,pr_cdocorre => pr_cdocorre
                      ,pr_cdmotivo => vr_cdmotivo
                      ,pr_inpessoa => vr_inpessoa);
      --Posicionar no proximo registro
      FETCH cr_craptar INTO rw_craptar;
      --Se nao encontrar
      IF cr_craptar%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_craptar;
        --Motivo Preenchido
        IF TRIM(vr_cdmotivo) IS NULL THEN
          --Selecionar Tarifa
          OPEN cr_craptar (pr_cdinctar => rw_crapint.cdinctar
                          ,pr_cdocorre => pr_cdocorre
                          ,pr_cdmotivo => '00'
                          ,pr_inpessoa => vr_inpessoa);
          --Posicionar no proximo registro
          FETCH cr_craptar INTO rw_craptar;
          --Se nao encontrou
          IF cr_craptar%NOTFOUND THEN
            --Zerar Critica
            vr_cdcritic:= 0;
            --Determinar se é pessoa fisica ou juridica
            IF vr_inpessoa = 1 THEN
              vr_dspessoa:= 'F';
            ELSE
              vr_dspessoa:= 'J';
            END IF;
            vr_dscritic:= 'Erro Tarifa'|| ' Par: ' || pr_dsincide ||
                          ' - ' || pr_cdocorre ||
                          ' - '     || vr_cdmotivo ||
                          ' Cnv: '   || pr_nrconven ||
                          ' P'|| vr_dspessoa;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          --Fechar Cursor
          IF cr_craptar%ISOPEN THEN
            CLOSE cr_craptar;
          END IF;
        ELSE
          --Zerar Critica
          vr_cdcritic:= 0;
          --Determinar se é pessoa fisica ou juridica
          IF vr_inpessoa = 1 THEN
            vr_dspessoa:= 'F';
          ELSE
            vr_dspessoa:= 'J';
          END IF;
          vr_dscritic:= 'Erro Tarifa'|| ' Par: ' || pr_dsincide ||
                        ' - ' || pr_cdocorre ||
                        ' - '     || vr_cdmotivo ||
                        ' Cnv: '   || pr_nrconven ||
                        ' P'     || vr_dspessoa;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Fechar Cursor
      IF cr_craptar%ISOPEN THEN
        CLOSE cr_craptar;
      END IF;

      --Selecionar faixa valor tarifa
      OPEN cr_crapfvl (pr_cdtarifa  => rw_craptar.cdtarifa
                      ,pr_vllanmto  => pr_vllanmto);
      --Posicionar no proximo registro
      FETCH cr_crapfvl INTO rw_crapfvl;
      --Se nao encontrar
      IF cr_crapfvl%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapfvl;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro Faixa Valor! '||
                      'Tar: '|| rw_craptar.cdtarifa||
                      ' Vlr: '||pr_vllanmto;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapfvl;

      --Zerar contador
      vr_contador:= 0;

      --Selecionar data
      OPEN BTCH0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
      --Posicionar primeiro registro
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      --Se encontrou
      IF BTCH0001.cr_crapdat%FOUND and rw_crapdat.inproces > 1 THEN
        --Limpar tabela memoria
        vr_tab_vigenc.DELETE;
        --Selecionar faixa valor cooperativa
        FOR rw_crapfco IN cr_crapfco (pr_cdcooper => pr_cdcooper
                                     ,pr_nrconven => pr_nrconven
                                     ,pr_cdfaixav => rw_crapfvl.cdfaixav
                                     ,pr_flgvigen => 1) LOOP
          --Inserir Vigencia
          vr_index_vigenc:= lpad(rw_crapdat.dtmvtolt - rw_crapfco.dtvigenc,5,'0')||
                            lpad(vr_contador,5,'0');
          vr_tab_vigenc(vr_index_vigenc).cdfvlcop:= rw_crapfco.cdfvlcop;
          vr_tab_vigenc(vr_index_vigenc).dtvigenc:= rw_crapfco.dtvigenc;
          vr_tab_vigenc(vr_index_vigenc).nrconven:= rw_crapfco.nrconven;
          vr_tab_vigenc(vr_index_vigenc).cdocorre:= rw_craptar.cdocorre;
          vr_tab_vigenc(vr_index_vigenc).cdmotivo:= rw_craptar.cdmotivo;
          vr_tab_vigenc(vr_index_vigenc).cdfaixav:= rw_crapfvl.cdfaixav;
          vr_tab_vigenc(vr_index_vigenc).qtdiavig:= rw_crapdat.dtmvtolt - rw_crapfco.dtvigenc;
          --Incrementar contador
          vr_contador:= nvl(vr_contador,0) + 1;
        END LOOP;
      END IF;
      --Fechar Cursor
      CLOSE BTCH0001.cr_crapdat;
      --Se possuir várias vigencias
      IF vr_contador > 1 THEN
        IF vr_tab_vigenc.COUNT > 0 THEN
          vr_dscritic:= 'ERRO: Multiplos detalhamentos vigentes: Tar '||rw_crapfvl.cdtarifa;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || pr_cdprogra || ' --> '
                                                        || vr_dscritic );
          --Posicionar no primeiro registro da tabela
          vr_index_vigenc:= vr_tab_vigenc.FIRST;
          --Percorrer as vigencias encontradas
          WHILE vr_index_vigenc IS NOT NULL LOOP
            --Se faixa valor cooperativa for igual zero e a quantidade
            --de dias da vigencia >= zero
            IF vr_cdfvlcop = 0 AND vr_tab_vigenc(vr_index_vigenc).qtdiavig >= 0 THEN
              --Selecionar faixa cooperativa
              OPEN cr_crapfco2 (pr_cdfvlcop => vr_tab_vigenc(vr_index_vigenc).cdfvlcop);
              FETCH cr_crapfco2 INTO rw_crapfco;
              --Indicar que encontrou ou nao
              vr_crapfco:= cr_crapfco2%FOUND;
              CLOSE cr_crapfco2;
              --Codigo Faixa Valor
              vr_cdfvlcop:= vr_tab_vigenc(vr_index_vigenc).cdfvlcop;
            END IF;
            --Escrever no log
            vr_dscritic:= 'Flv: '||vr_tab_vigenc(vr_index_vigenc).cdfaixav||
                          ' Fco: '||vr_tab_vigenc(vr_index_vigenc).cdfvlcop||
                          ' Vig: '||to_char(vr_tab_vigenc(vr_index_vigenc).dtvigenc,'DD/MM/YYYY')||
                          ' Cnv: '||vr_tab_vigenc(vr_index_vigenc).nrconven||
                          ' Oco: '||vr_tab_vigenc(vr_index_vigenc).cdocorre||
                          ' Mot: '||vr_tab_vigenc(vr_index_vigenc).cdmotivo;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                          || pr_cdprogra || ' --> '
                                                          || vr_dscritic );
            --Proximo registro
            vr_index_vigenc:= vr_tab_vigenc.NEXT(vr_index_vigenc);
          END LOOP;

          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- Processo Normal
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '|| pr_cdprogra
                                                        || ' --> '|| 'Selecionado detalhamento: '||vr_cdfvlcop );


        END IF;
      ELSE
        --Selecionar faixa valor cooperativa
        OPEN cr_crapfco (pr_cdcooper => pr_cdcooper
                        ,pr_nrconven => pr_nrconven
                        ,pr_cdfaixav => rw_crapfvl.cdfaixav
                        ,pr_flgvigen => 1);
        --Posicionar no proximo registro
        FETCH cr_crapfco INTO rw_crapfco;
        vr_crapfco:= cr_crapfco%FOUND AND rw_crapfco.qtdreg = 1;
        --Fechar Cursor
        CLOSE cr_crapfco;
      END IF;

      --Se nao encontrar
      IF NOT vr_crapfco THEN
        --Busca dados da cooperativa
        OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        CLOSE cr_crapcop;

        --Montar mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro Faixa Valor Coop. '||
                      'Tar: '||rw_craptar.cdtarifa||
                      ' Fvl: '||rw_crapfvl.cdfaixav||
                      ' Cnv: '||pr_nrconven;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Se foi informado conta
      IF pr_nrdconta > 0 THEN

        --Selecionar a categoria da tarifa com desconto
        OPEN cr_tar_ctc (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrconven => pr_nrconven
                        ,pr_cdtarifa => rw_craptar.cdtarifa);
        --Posicionar no proximo registro
        FETCH cr_tar_ctc INTO rw_tar_ctc;
        -- Alimenta a booleana se achou ou nao
        vr_blnfound := cr_tar_ctc%FOUND;
        --Fechar Cursor
        CLOSE cr_tar_ctc;

        --Se encontrar
        IF vr_blnfound THEN
          --Retornar valores
          -- TARIFA POR PERCENTUAL
          IF NVL(rw_crapfco.tpcobtar,0) = 2 THEN
            vr_vltarifa:= pr_vllanmto * (nvl(rw_crapfco.vlpertar,0)/100);
            --
            --VERIFICA LIMITE MÍNIMO
            IF vr_vltarifa < rw_crapfco.vlmintar THEN
              vr_vltarifa := rw_crapfco.vlmintar;
            END IF;
            --VERIFICA LIMITE MÁXIMO
            IF vr_vltarifa > rw_crapfco.vlmaxtar THEN
              vr_vltarifa := rw_crapfco.vlmaxtar;
            END IF;
          -- TARIFA FIXA
          ELSE
            vr_vltarifa:= rw_crapfco.vltarifa;
          END IF;
          --
          vr_vltarids := vr_vltarifa - (vr_vltarifa * (rw_tar_ctc.perdesconto / 100));
          
          --Se foi solicitado para apurar a tarifação
          IF pr_flaputar = 1 THEN 
          
            BEGIN
              INSERT INTO tbrecip_apuracao_tarifa
                         (cdcooper
                         ,nrdconta
                         ,cdproduto
                         ,cdchave_produto 
                         ,dtocorre
                         ,cdtarifa
                         ,vltarifa_original
                         ,vlocorrencia
                         ,perdesconto
                         ,vltarifa_cobrado)
                   VALUES(pr_cdcooper
                         ,pr_nrdconta
                         ,6 -- Cobranca bancaria
                         ,pr_nrconven
                         ,rw_crapdat.dtmvtolt
                         ,rw_craptar.cdtarifa
                         ,rw_crapfco.vltarifa
                         ,pr_vllanmto
                         ,rw_tar_ctc.perdesconto
                         ,vr_vltarids);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro na inclusao da TBRECIP_APURACAO_TARIFA: ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
                  
            --Verifica se o convenio possui reciprocidade ativa
            OPEN cr_crapceb (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrconven => pr_nrconven);
            --Posicionar no proximo registro
            FETCH cr_crapceb INTO vr_idrecipr;
            --Fechar Cursor
            CLOSE cr_crapceb;

            --Se houver Reciprocidade
            IF NVL(vr_idrecipr,0) > 0 THEN

              --Verifica se o periodo de apuracao ainda nao foi criado
              OPEN cr_apuracao(pr_cdcooper        => pr_cdcooper
                              ,pr_nrdconta        => pr_nrdconta
                              ,pr_cdchave_produto => pr_nrconven
                              ,pr_idconfig        => vr_idrecipr);
              --Posicionar no proximo registro
              FETCH cr_apuracao INTO vr_qtapurac;
              --Fechar Cursor
              CLOSE cr_apuracao;

              -- Se nao encontrou nenhum periodo em aberto
              IF vr_qtapurac = 0 THEN

                --Buscar a configuracao do calculo para criacao do periodo
                OPEN cr_confrec (pr_idcalculo_reciproci => vr_idrecipr);
                --Posicionar no proximo registro
                FETCH cr_confrec INTO vr_qtmesrec;
                --Fechar Cursor
                CLOSE cr_confrec;

                -- Inserimos o periodo de apuracao com base no dia atual + periodo configurado
                BEGIN
                  INSERT INTO tbrecip_apuracao
                             (cdcooper
                             ,nrdconta
                             ,cdproduto
                             ,cdchave_produto 
                             ,tpreciproci
                             ,idconfig_recipro
                             ,dtinicio_apuracao
                             ,dttermino_apuracao
                             ,indsituacao_apuracao)
                       VALUES(pr_cdcooper
                             ,pr_nrdconta
                             ,6 -- Cobranca bancaria
                             ,pr_nrconven
                             ,1 -- Por previsao
                             ,vr_idrecipr
                             ,rw_crapdat.dtmvtolt
                             ,ADD_MONTHS(rw_crapdat.dtmvtolt,vr_qtmesrec)-1
                             ,'A')
                    RETURNING idapuracao_reciproci
                         INTO vr_idapurec;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro na inclusao da TBRECIP_APURACAO: ' || SQLERRM;
                    RAISE vr_exc_erro;
                END;

                -- Inserimos os indicadores deste periodo de apuracao copiando os indicadores selecionados no calculo
                BEGIN
                  INSERT INTO tbrecip_apuracao_indica
                             (idapuracao_reciproci
                             ,idindicador)
                       SELECT vr_idapurec
                             ,idindicador
                         FROM tbrecip_indica_calculo
                        WHERE idcalculo_reciproci = vr_idrecipr;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro na inclusao da TBRECIP_APURACAO_INDICA: ' || SQLERRM;
                    RAISE vr_exc_erro;
                END;

              END IF; -- vr_qtapurac

            END IF; -- vr_idrecipr

          END IF; -- Se foi solicitado apuracao
        
        END IF; -- cr_tar_ctc

      END IF; -- pr_nrdconta

      --Retornar Parametros para procedure
      pr_cdhistor:= rw_crapfvl.cdhistor;
      pr_cdhisest:= rw_crapfvl.cdhisest;
      -- Ou vem da Reciprocidade com Desconto OU da faixa original
      pr_vltarifa:= nvl(vr_vltarids,rw_crapfco.vltarifa); 
      pr_dtdivulg:= rw_crapfco.dtdivulg;
      pr_dtvigenc:= rw_crapfco.dtvigenc;
      pr_cdfvlcop:= rw_crapfco.cdfvlcop;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina TARI0001.pc_carrega_dados_tarifa_cobr. '||sqlerrm;
    END;
  END pc_carrega_dados_tarifa_cobr;

---------elt
 /* Procedure para efetivar tarifa na craplat */
  PROCEDURE pc_efetiva_tarifa (pr_rowid_craplat in ROWID         --Rowid da tarifa
                              ,pr_dtmvtolt      DATE             --Data Lancamento
                              ,pr_cdcritic      OUT INTEGER      --Codigo Critica
                              ,pr_dscritic      OUT VARCHAR2) IS --Descricao Critica
   BEGIN

    -- ........................................................................
    --
    --  Programa : pc_efetiva_tarifa          
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Elton Giusti (AMcom)
    --  Data     : 20/06/2018.                      Ultima atualizacao: -
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : efetivar tarifa na craplat
    --
    --.............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

  
     
  BEGIN 
    
       --Atualizar tabela lancamento
      BEGIN
        UPDATE craplat SET craplat.dtefetiv = pr_dtmvtolt
                          ,craplat.insitlat = 2  /** Efetivado **/
        WHERE craplat.ROWID = pr_rowid_craplat;

      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar tabela craplat. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_saida;
      END;
         
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
  
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TARI0001.pc_efetiva_tarifa: ' || SQLERRM;

    END;
  END pc_efetiva_tarifa;
                                         

-----elt


  /* Procedure para buscar dados da tarifa emprestimo */
  PROCEDURE pc_car_dados_tar_empr_web (pr_cdcooper  IN  INTEGER               --Codigo Cooperativa
                                      ,pr_nrdconta  IN  INTEGER               --Conta do associado
                                      ,pr_cdlcremp  IN  craplcr.cdlcremp%TYPE --Linha Emprestimo
                                      ,pr_cdmotivo  IN  craptar.cdmotivo%TYPE --Codigo Motivo
                                      ,pr_inpessoa  IN  craptar.inpessoa%TYPE --Tipo Pessoa                                      
                                      ,pr_vllanmto  IN  NUMBER                --Valor Lancamento
                                      ,pr_dsbemgar  IN  VARCHAR2              --Relação de categoria de bens em garantia
                                      ,pr_cdprogra  IN VARCHAR2
                                      ,pr_xmllog    IN VARCHAR2               --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS           --> Erros do processo
   BEGIN

    -- ........................................................................
    --
    --  Programa : pc_car_dados_tar_empr_web          
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Diogo Carlassara (MoutS)
    --  Data     : 19/01/2015.                      Ultima atualizacao: -
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Carregar dados da tarifa de empréstimo - chamada pela web
    --
    --.............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_cdhistor INTEGER;
      vr_cdhisest INTEGER;
      vr_vltarifa NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_tab_erro GENE0001.typ_tab_erro;
      
      VR_CDBATTAR VARCHAR2(100);
       vr_vlrtarif number;
       vr_vltrfesp number;
       vr_vltrfgar number;
       vr_des_erro VARCHAR2(100);
       vr_des_corpo VARCHAR2(100);
       vr_vltottar  number;

   cursor cr_craplcr is
      select *
        from craplcr
       where cdcooper = pr_cdcooper
         and cdlcremp = pr_cdlcremp;

     rw_craplcr cr_craplcr%rowtype;
     
  BEGIN 
  -- Limpa Variaveis de Tarifa
    vr_vlrtarif:= 0;
    vr_vltrfesp:= 0;
    vr_vltrfgar:= 0;

    open cr_craplcr;
    fetch cr_craplcr into rw_craplcr;
    
    if cr_craplcr%notfound then
       raise vr_exc_saida;
    end if;
    CLOSE cr_craplcr;
    
    TARI0001.pc_calcula_tarifa (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdlcremp => pr_cdlcremp
                               ,pr_vlemprst => pr_vllanmto
                               ,pr_cdusolcr => rw_craplcr.cdusolcr
                               ,pr_tpctrato => rw_craplcr.tpctrato 
                               ,pr_dsbemgar => pr_dsbemgar
                               ,pr_cdprogra => 'Rel CET'
                               ,pr_flgemail => 'N'
                               ,pr_vlrtarif => vr_vlrtarif
                               ,pr_vltrfesp => vr_vltrfesp
                               ,pr_vltrfgar => vr_vltrfgar
                               ,pr_cdhistor => vr_cdhistor
                               ,pr_cdfvlcop => vr_cdfvlcop
                               ,pr_cdhisgar => vr_cdhistor
                               ,pr_cdfvlgar => vr_cdfvlcop
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               );

    -- Total Tarifa a ser Cobrado
    vr_vltottar := NVL(vr_vlrtarif,0) + NVL(vr_vltrfesp,0) + nvl(vr_vltrfgar,0);
      
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        -- Leitura da tabela temporaria para retornar XML para a WEB
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => TO_CHAR(pr_cdcooper), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdmotivo', pr_tag_cont => TO_CHAR(pr_cdmotivo), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'inpessoa', pr_tag_cont => TO_CHAR(pr_inpessoa), pr_des_erro => vr_dscritic);        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllanmto', pr_tag_cont => TO_CHAR(pr_vllanmto,'fm999999999D00'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdprogra', pr_tag_cont => TO_CHAR(pr_cdprogra), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhistor', pr_tag_cont => TO_CHAR(vr_cdhistor), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhisest', pr_tag_cont => TO_CHAR(vr_cdhisest), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vltarifa', pr_tag_cont => TO_CHAR(vr_vltottar,'fm999999999D00'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dtdivulg', pr_tag_cont => TO_CHAR(vr_dtdivulg,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dtvigenc', pr_tag_cont => TO_CHAR(vr_dtvigenc,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdfvlcop', pr_tag_cont => TO_CHAR(vr_cdfvlcop), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdcritic', pr_tag_cont => TO_CHAR(vr_cdcritic), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdusolcr', pr_tag_cont => TO_CHAR(rw_craplcr.cdusolcr), pr_des_erro => vr_dscritic);
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TARI0001.pc_car_dados_tar_empr_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_car_dados_tar_empr_web;
                                         

  /* Procedure para buscar dados da tarifa emprestimo */
  PROCEDURE pc_carrega_dados_tarifa_empr (pr_cdcooper  IN  INTEGER               --Codigo Cooperativa
                                         ,pr_cdlcremp  IN  craplcr.cdlcremp%TYPE --Linha Emprestimo
                                         ,pr_cdmotivo  IN  craptar.cdmotivo%TYPE --Codigo Motivo
                                         ,pr_inpessoa  IN  craptar.inpessoa%TYPE --Tipo Pessoa
                                         ,pr_vllanmto  IN  NUMBER                --Valor Lancamento
                                         ,pr_cdprogra  IN  VARCHAR2              --Codigo Programa
                                         ,pr_cdhistor  OUT INTEGER               --Codigo Historico
                                         ,pr_cdhisest  OUT INTEGER               --Historico Estorno
                                         ,pr_vltarifa  OUT NUMBER                --Valor Tarifa
                                         ,pr_dtdivulg  OUT DATE                  --Data Divulgacao
                                         ,pr_dtvigenc  OUT DATE                  --Data Vigencia
                                         ,pr_cdfvlcop  OUT INTEGER               --Codigo Cooperativa
                                         ,pr_cdcritic  OUT INTEGER               --Codigo Critica
                                         ,pr_dscritic  OUT VARCHAR2              --Descricao Critica
                                         ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS --Tabela erros
    -- ........................................................................
    --
    --  Programa : pc_carrega_dados_tarifa_empr           Antigo: b1wgen0153.p/carrega_dados_tarifa_emprestimo
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Outubro/2013.                   Ultima atualizacao: 29/10/2013
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para buscar dados da tarifa emprestimo
    --
    --   Atualizacao: 27/08/2013 - Adequar programa conforme modificacoes progress
    --
  BEGIN
    DECLARE
      --Cursores Locais

      --Selecionar tarifas
      CURSOR cr_craptar (pr_cdmotivo IN craptar.cdmotivo%type
                        ,pr_inpessoa IN craptar.inpessoa%type) IS
        SELECT craptar.cdtarifa
              ,craptar.cdocorre
              ,craptar.cdmotivo
        FROM craptar
        WHERE craptar.cdmotivo = pr_cdmotivo
        AND   craptar.inpessoa = pr_inpessoa
        ORDER BY craptar.progress_recid ASC;
      rw_craptar cr_craptar%ROWTYPE;
      --Selecionar faixa valor cooperativa
      CURSOR cr_crapfco (pr_cdcooper IN crapfco.cdcooper%type
                        ,pr_cdlcremp IN crapfco.cdlcremp%type
                        ,pr_cdfaixav IN crapfco.cdfaixav%type
                        ,pr_flgvigen IN crapfco.flgvigen%type) IS
        SELECT crapfco.vltarifa
              ,crapfco.dtdivulg
              ,crapfco.dtvigenc
              ,crapfco.cdfvlcop
              ,crapfco.cdfaixav
              ,crapfco.cdlcremp
              ,crapfco.tpcobtar
              ,crapfco.vlpertar
              ,crapfco.vlmintar
              ,crapfco.vlmaxtar
        FROM crapfco
        WHERE crapfco.cdcooper = pr_cdcooper
        AND   crapfco.cdlcremp = pr_cdlcremp
        AND   crapfco.cdfaixav = pr_cdfaixav
        AND   crapfco.flgvigen = pr_flgvigen;
      rw_crapfco cr_crapfco%ROWTYPE;
      --Selecionar Linha Credito
      CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%TYPE
                        ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT craplcr.flgtarif
              ,decode(craplcr.cdhistor,2013,1,2014,1,0) inlcrcdc
        FROM craplcr
        WHERE craplcr.cdcooper = pr_cdcooper
        AND   craplcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      --Selecionar faixa cooperativa
      CURSOR cr_crapfco2 (pr_cdfvlcop IN crapfco.cdfvlcop%type) IS
        SELECT crapfco.vltarifa
              ,crapfco.dtdivulg
              ,crapfco.dtvigenc
              ,crapfco.cdfvlcop
              ,crapfco.cdfaixav
              ,crapfco.cdlcremp
              ,crapfco.tpcobtar
              ,crapfco.vlpertar
              ,crapfco.vlmintar
              ,crapfco.vlmaxtar
        FROM crapfco
        WHERE crapfco.cdfvlcop = pr_cdfvlcop;

      --Variaveis Locais
      vr_contador INTEGER:= 0;
      vr_cdfvlcop INTEGER:= 0;
      vr_dspessoa VARCHAR2(20);
      vr_index_vigenc VARCHAR2(10);
      vr_cdlcremp craplcr.cdlcremp%TYPE;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      vr_sair     EXCEPTION;
    BEGIN

      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Limpar tabela erro
      pr_tab_erro.DELETE;     

      --Selecionar as tarifas
      OPEN cr_craptar (pr_cdmotivo => pr_cdmotivo
                      ,pr_inpessoa => pr_inpessoa);
      --Posicionar no proximo registro
      FETCH cr_craptar INTO rw_craptar;
      --Se nao encontrar
      IF cr_craptar%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_craptar;
        --Zerar Critica
        vr_cdcritic:= 0;
        --Determinar se eh pessoa fisica ou juridica
        IF pr_inpessoa = 1 THEN
          vr_dspessoa:= 'F';
        ELSE
          vr_dspessoa:= 'J';
        END IF;
        vr_dscritic:= 'Erro Tarifa!'||
                      ' Mot: '     || pr_cdmotivo ||
                      ' Lcr: '   || pr_cdlcremp ||
                      ' P'     || vr_dspessoa;
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_craptar;
      
      --Selecionar linha de crédito
      OPEN cr_craplcr (pr_cdcooper  => pr_cdcooper
                      ,pr_cdlcremp  => pr_cdlcremp);
      --Posicionar no proximo registro
      FETCH cr_craplcr INTO rw_craplcr;
      --Se nao encontrar
      IF cr_craplcr%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_craplcr;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro Linha Credito! '||
                      'Linha: '||pr_cdlcremp;
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_craplcr;
      --Se Cobrar tarifa
      IF rw_craplcr.flgtarif = 1 THEN
        vr_cdlcremp := 0;
      ELSE
        pr_vltarifa := 0;
        RAISE vr_sair;
      END IF;      
      
      --Selecionar faixa valor tarifa
      OPEN cr_crapfvl (pr_cdtarifa  => rw_craptar.cdtarifa
                      ,pr_vllanmto  => pr_vllanmto);
      --Posicionar no proximo registro
      FETCH cr_crapfvl INTO rw_crapfvl;
      --Se nao encontrar
      IF cr_crapfvl%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapfvl;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro Faixa Valor!'||
                      ' Tar: '||rw_craptar.cdtarifa||
                      ' Vlr: '||pr_vllanmto;
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapfvl;

      --Zerar contador
      vr_contador := 0;

      --Selecionar data
      OPEN BTCH0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
      --Posicionar primeiro registro
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      --Se encontrou
      IF BTCH0001.cr_crapdat%FOUND and rw_crapdat.inproces > 1 THEN
        --Limpar tabela memoria
        vr_tab_vigenc.DELETE;
        --Selecionar faixa valor cooperativa
        FOR rw_crapfco IN cr_crapfco (pr_cdcooper => pr_cdcooper
                                     ,pr_cdlcremp => pr_cdlcremp
                                     ,pr_cdfaixav => rw_crapfvl.cdfaixav
                                     ,pr_flgvigen => 1) LOOP
          --Incrementar contador
          vr_contador:= vr_contador + 1;

          --Inserir Vigencia
          vr_index_vigenc:= lpad(rw_crapdat.dtmvtolt - rw_crapfco.dtvigenc,5,'0')||
                            lpad(vr_contador,5,'0');
          vr_tab_vigenc(vr_index_vigenc).cdfvlcop:= rw_crapfco.cdfvlcop;
          vr_tab_vigenc(vr_index_vigenc).dtvigenc:= rw_crapfco.dtvigenc;
          vr_tab_vigenc(vr_index_vigenc).cdlcremp:= rw_crapfco.cdlcremp;
          vr_tab_vigenc(vr_index_vigenc).cdocorre:= rw_craptar.cdocorre;
          vr_tab_vigenc(vr_index_vigenc).cdmotivo:= rw_craptar.cdmotivo;
          vr_tab_vigenc(vr_index_vigenc).cdfaixav:= rw_crapfvl.cdfaixav;
          vr_tab_vigenc(vr_index_vigenc).qtdiavig:= rw_crapdat.dtmvtolt - rw_crapfco.dtvigenc;

        END LOOP;
      END IF;
      --Fechar Cursor
      CLOSE BTCH0001.cr_crapdat;

      IF vr_contador > 1 AND vr_tab_vigenc.COUNT > 0 THEN
        vr_dscritic:= 'ERRO: Multiplos detalhamentos vigentes: Tar '||rw_crapfvl.cdtarifa;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || pr_cdprogra || ' --> '
                                                      || vr_dscritic );
        --Percorrer as vigencias encontradas
        vr_index_vigenc:= vr_tab_vigenc.FIRST;
        WHILE vr_index_vigenc IS NOT NULL LOOP
          IF vr_cdfvlcop = 0 AND vr_tab_vigenc(vr_index_vigenc).qtdiavig >= 0 THEN
            --Selecionar faixa cooperativa
            OPEN cr_crapfco2 (pr_cdfvlcop => vr_tab_vigenc(vr_index_vigenc).cdfvlcop);
            FETCH cr_crapfco2 INTO rw_crapfco;
            --Se nao encontrou
            IF cr_crapfco2%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_crapfco2;
              vr_cdcritic:= 0;
              vr_dscritic:= ' - Erro Faixa Valor Coop. '||
                            'Tar: '||rw_craptar.cdtarifa||
                            ' Fvl: '||rw_crapfvl.cdfaixav||
                            ' Lcr: '||pr_cdlcremp;
              --Gerar erro
              GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => 1
                                   ,pr_nrdcaixa => 1
                                   ,pr_nrsequen => 1
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapfco2;
            --Valor faixa cooperativa
            vr_cdfvlcop:= vr_tab_vigenc(vr_index_vigenc).cdfvlcop;
          END IF;
          vr_dscritic:= 'Flv: '||vr_tab_vigenc(vr_index_vigenc).cdfaixav||
                        ' Fco: '||vr_tab_vigenc(vr_index_vigenc).cdfvlcop||
                        ' Vig: '||to_char(vr_tab_vigenc(vr_index_vigenc).dtvigenc,'DD/MM/YYYY')||
                        ' Lcr: '||vr_tab_vigenc(vr_index_vigenc).cdlcremp||
                        ' Mot: '||vr_tab_vigenc(vr_index_vigenc).cdmotivo;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || pr_cdprogra || ' --> '
                                                        || vr_dscritic );
          --Proximo Registro
          vr_index_vigenc:= vr_tab_vigenc.NEXT(vr_index_vigenc);
        END LOOP;

        vr_dscritic:= 'Selecionado detalhamento: '||vr_cdfvlcop;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || pr_cdprogra || ' --> '
                                                      || vr_dscritic );

      ELSE
        --Selecionar faixa valor cooperativa
        OPEN cr_crapfco (pr_cdcooper => pr_cdcooper
                        ,pr_cdlcremp => vr_cdlcremp
                        ,pr_cdfaixav => rw_crapfvl.cdfaixav
                        ,pr_flgvigen => 1);
        --Posicionar no proximo registro
        FETCH cr_crapfco INTO rw_crapfco;
        --Se nao encontrar
        IF cr_crapfco%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapfco;
          vr_cdcritic:= 0;
          vr_dscritic:= ' - Erro Faixa Valor Coop. '||
                        'Tar: '||rw_craptar.cdtarifa||
                        ' Fvl: '||rw_crapfvl.cdfaixav||
                        ' Lcr: '||vr_cdlcremp;
          --Gerar erro
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => 1
                               ,pr_nrdcaixa => 1
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapfco;
      END IF;
      --Retornar valores
      -- TARIFA POR PERCENTUAL
      IF NVL(rw_crapfco.tpcobtar,0) = 2 THEN
        pr_vltarifa:= pr_vllanmto * (nvl(rw_crapfco.vlpertar,0)/100);
        --
        --VERIFICA LIMITE MÍNIMO
        IF pr_vltarifa < rw_crapfco.vlmintar THEN
          pr_vltarifa := rw_crapfco.vlmintar;
        END IF;
        --VERIFICA LIMITE MÁXIMO
        IF pr_vltarifa > rw_crapfco.vlmaxtar THEN
          pr_vltarifa := rw_crapfco.vlmaxtar;
        END IF;
      -- TARIFA FIXA
      ELSE
        pr_vltarifa:= rw_crapfco.vltarifa;
      END IF;
      --
      --Retornar Parametros para procedure
      pr_cdhistor:= rw_crapfvl.cdhistor;
      pr_cdhisest:= rw_crapfvl.cdhisest;
      pr_dtdivulg:= rw_crapfco.dtdivulg;
      pr_dtvigenc:= rw_crapfco.dtvigenc;
      pr_cdfvlcop:= rw_crapfco.cdfvlcop;

    EXCEPTION
      WHEN vr_sair THEN
        pr_vltarifa := 0; 
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina TARI0001.pc_carrega_dados_tarifa_empr. '||sqlerrm;
    END;
  END pc_carrega_dados_tarifa_empr;

  /* Procedure para criar lancamento automatico tarifa */
  PROCEDURE pc_cria_lan_auto_tarifa (pr_cdcooper IN INTEGER --Codigo Cooperativa
                                    ,pr_nrdconta IN INTEGER --Numero da Conta
                                    ,pr_dtmvtolt IN DATE    --Data Lancamento
                                    ,pr_cdhistor IN INTEGER --Codigo Historico
                                    ,pr_vllanaut IN NUMBER  --Valor lancamento automatico
                                    ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                    ,pr_cdagenci IN INTEGER  --Codigo Agencia
                                    ,pr_cdbccxlt IN INTEGER  --Codigo banco caixa
                                    ,pr_nrdolote IN INTEGER  --Numero do lote
                                    ,pr_tpdolote IN INTEGER  --Tipo do lote
                                    ,pr_nrdocmto IN NUMBER   --Numero do documento
                                    ,pr_nrdctabb IN INTEGER  --Numero da conta
                                    ,pr_nrdctitg IN VARCHAR2 --Numero da conta integracao
                                    ,pr_cdpesqbb IN VARCHAR2 --Codigo pesquisa
                                    ,pr_cdbanchq IN INTEGER  --Codigo Banco Cheque
                                    ,pr_cdagechq IN INTEGER  --Codigo Agencia Cheque
                                    ,pr_nrctachq IN INTEGER  --Numero Conta Cheque
                                    ,pr_flgaviso IN BOOLEAN  --Flag aviso
                                    ,pr_tpdaviso IN INTEGER  --Tipo aviso
                                    ,pr_cdfvlcop IN INTEGER  --Codigo cooperativa
                                    ,pr_inproces IN INTEGER  --Indicador processo
                                    ,pr_rowid_craplat OUT ROWID --Rowid do lancamento tarifa
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela retorno erro
                                    ,pr_cdcritic OUT INTEGER --Codigo Critica
                                    ,pr_dscritic OUT VARCHAR2) IS --Descricao Critica
    -- ........................................................................
    --
    --  Programa : pc_cria_lan_auto_tarifa           Antigo: b1wgen0153.p/cria_lan_auto_tarifa
    --  Sistema  : Cred
    --  Sigla    : PAGA0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 26/03/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para criar lancamento automatico tarifa
    --   Alterações
    --   06/03/2014 - Ajuste no tratamento de erro no insert, como a sqlerrm estava
    --                fora da exception, seu valor não era aproveitado, e era gerado
    --                o texto "ORA-0000: normal, successful completion" - Marcos(Supero)
    --
    --   26/03/2014 - Retirar tratamento de sequencia na craplat (Gabriel)
    --
    --   11/07/2018 - Inclusão de pc_internal_exception nas exceptions others INC0018458 (AJFink)
    --
  BEGIN
    DECLARE
      --Cursores Locais
      vr_flgaviso INTEGER;
      vr_datdodia DATE;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    BEGIN
      --Inicializar retorno erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Limpar tabela erro
      pr_tab_erro.DELETE;

      --Se valor for zero
      IF pr_vllanaut = 0 THEN
        --Sair
        RAISE vr_exc_saida;
      END IF;

      --Buscar a data do dia
      vr_datdodia:= TRUNC(SYSDATE);
      --Determinar aviso
      IF pr_flgaviso THEN
        vr_flgaviso:= 1;
      ELSE
        vr_flgaviso:= 0;
      END IF;
      --Inserir lancamento automatico
      BEGIN
        INSERT INTO craplat
          (craplat.cdcooper
          ,craplat.nrdconta
          ,craplat.dtmvtolt
          ,craplat.cdlantar
          ,craplat.dttransa
          ,craplat.hrtransa
          ,craplat.insitlat
          ,craplat.cdhistor
          ,craplat.vltarifa
          ,craplat.cdoperad
          ,craplat.cdagenci
          ,craplat.cdbccxlt
          ,craplat.nrdolote
          ,craplat.tpdolote
          ,craplat.nrdocmto
          ,craplat.nrdctabb
          ,craplat.nrdctitg
          ,craplat.cdpesqbb
          ,craplat.cdbanchq
          ,craplat.cdagechq
          ,craplat.nrctachq
          ,craplat.flgaviso
          ,craplat.tpdaviso
          ,craplat.cdfvlcop
          ,craplat.idseqlat)
        VALUES
          (pr_cdcooper
          ,pr_nrdconta
          ,pr_dtmvtolt
          ,seqlat_cdlantar.NEXTVAL
          ,vr_datdodia
          ,GENE0002.fn_busca_time
          ,1 /** PENDENTE **/
          ,pr_cdhistor
          ,pr_vllanaut
          ,pr_cdoperad
          ,pr_cdagenci
          ,pr_cdbccxlt
          ,pr_nrdolote
          ,pr_tpdolote
          ,pr_nrdocmto
          ,pr_nrdctabb
          ,pr_nrdctitg
          ,pr_cdpesqbb
          ,pr_cdbanchq
          ,pr_cdagechq
          ,pr_nrctachq
          ,vr_flgaviso
          ,pr_tpdaviso
          ,pr_cdfvlcop
          ,fn_sequence('CRAPLAT','IDSEQLAT',pr_cdcooper||';'||pr_nrdconta ||';'||to_char(pr_dtmvtolt,'dd/mm/yyyy')))
          RETURNING rowid INTO pr_rowid_craplat;
      EXCEPTION
        WHEN Others THEN
          cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper); --INC0018458
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro na gravacao da tarifa! '||sqlerrm;
          --Gerar erro
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => 1
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          --Levantar Excecao para retornar NOK
          RAISE vr_exc_erro;
      END;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic:= NULL;
        pr_dscritic:= NULL;
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper); --INC0018458
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina TARI0001.pc_cria_lan_auto_tarifa. '||sqlerrm;
    END;
  END pc_cria_lan_auto_tarifa;

  /* Procedure para Buscar parametros de tarifas de desconto de titulo - TAB053  */
  PROCEDURE pc_busca_tarifas_dsctit (pr_cdcooper  IN INTEGER --Codigo Cooperativa
                                    ,pr_cdagenci  IN INTEGER  --Codigo Agencia
                                    ,pr_nrdcaixa  IN INTEGER  --Numero do caixa
                                    ,pr_cdoperad  IN VARCHAR2 --Codigo Operador
                                    ,pr_dtmvtolt  IN DATE     --Data Movimento
                                    ,pr_idorigem  IN INTEGER  --Identificador Origem
                                    ,pr_cdcritic  OUT INTEGER  --Codigo Critica
                                    ,pr_dscritic  OUT VARCHAR2  --Descricao Critica
                                    ,pr_tab_tarifas_dsctit OUT TARI0001.typ_tab_tarifas_dsctit
                                    ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS --Tabela erros
    -- ........................................................................
    --
    --  Programa : pc_busca_tarifas_dsctit           Antigo: b1wgen0030.p/busca_tarifas_dsctit
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Buscar parametros de tarifas de desconto de titulo - TAB053
  BEGIN
    DECLARE
      --Cursores Locais

      --Variaveis Locais
      vr_index    INTEGER;
      vr_dstextab craptab.dstextab%TYPE;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Limpar tabela tarifas desconto titulos
      pr_tab_tarifas_dsctit.DELETE;

      --Selecionar tarifas
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TARDESCTIT'
                                              ,pr_tpregist => 0);
      --Se encontrou
      IF vr_dstextab IS NOT NULL THEN
        --Retornar tarifas desconto titulos
        vr_index:= pr_tab_tarifas_dsctit.Count + 1;
        pr_tab_tarifas_dsctit(vr_index).vltarctr:= GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(01,vr_dstextab,';'));
        pr_tab_tarifas_dsctit(vr_index).vltarrnv:= GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(02,vr_dstextab,';'));
        pr_tab_tarifas_dsctit(vr_index).vltarbdt:= GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(03,vr_dstextab,';'));
        pr_tab_tarifas_dsctit(vr_index).vlttitcr:= GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(04,vr_dstextab,';'));
        pr_tab_tarifas_dsctit(vr_index).vlttitsr:= GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(05,vr_dstextab,';'));
        pr_tab_tarifas_dsctit(vr_index).vltrescr:= GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(06,vr_dstextab,';'));
        pr_tab_tarifas_dsctit(vr_index).vltressr:= GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(07,vr_dstextab,';'));
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de titulos de desconto de titulos nao encontrado.';
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina TARI0001.pc_busca_tarifas_dsctit. '||sqlerrm;
    END;
  END pc_busca_tarifas_dsctit;

  /* Procedure responsavel por carregar dados da tarifa vigente   */
  PROCEDURE pc_carrega_dados_tar_vigente (pr_cdcooper  IN INTEGER  --Codigo Cooperativa
                                         ,pr_cdbattar  IN VARCHAR2 DEFAULT NULL --Codigo da sigla da tarifa (CRAPBAT) - Ao popular este parâmetro o pr_cdtarifa não é necessário
                                         ,pr_cdtarifa  IN NUMBER DEFAULT NULL   --Codigo da Tarifa (CRAPTAR) - Ao popular este parâmetro o pr_cdbattar não é necessário
                                         ,pr_vllanmto  IN NUMBER   --Valor Lancamento
                                         ,pr_cdprogra  IN VARCHAR2 --Codigo Programa
                                         ,pr_cdhistor  OUT INTEGER  --Codigo Historico
                                         ,pr_cdhisest  OUT NUMBER   --Historico Estorno
                                         ,pr_vltarifa  OUT NUMBER   --Valor tarifa
                                         ,pr_dtdivulg  OUT DATE     --Data Divulgacao
                                         ,pr_dtvigenc  OUT DATE     --Data Vigencia
                                         ,pr_cdfvlcop  OUT INTEGER  --Codigo faixa valor cooperativa
                                         ,pr_cdcritic  OUT INTEGER  --Codigo Critica
                                         ,pr_dscritic  OUT VARCHAR2  --Descricao Critica
                                         ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS --Tabela erros
    -- ........................................................................
    --
    --  Programa : pc_carrega_dados_tarifa_vigente           Antigo: b1wgen0153.p/carrega_dados_tarifa_vigente
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 23/10/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure responsavel por carregar dados da tarifa vigente
    --
    --   Atualização:
    --
    --   23/10/2018 - Padrões: Others, Modulo/Action, PC Internal Exception, PC Log Programa
    --                SELECT's, Parâmetros, troca de mensagens por código                             
    --               (Envolti - Belli - REQ0011726)
    -- 
  BEGIN
    DECLARE

      /* Cursores Locais */
      --Selecionar sigla da tarifa
      CURSOR cr_crapbat (pr_cdbattar IN crapbat.cdbattar%type) IS
        SELECT crapbat.cdcadast
        FROM crapbat
        WHERE crapbat.cdbattar = pr_cdbattar; /* Sigla Tarifa */

      --Selecionar tarifas
      CURSOR cr_craptar (pr_cdtarifa IN craptar.cdtarifa%type) IS
        SELECT craptar.cdtarifa
        FROM craptar
        WHERE craptar.cdtarifa = pr_cdtarifa;
      rw_craptar cr_craptar%ROWTYPE;

      --Selecionar faixa cooperativa
      CURSOR cr_crapfco2 (pr_cdfvlcop IN crapfco.cdfvlcop%type) IS
        SELECT crapfco.vltarifa
              ,crapfco.dtdivulg
              ,crapfco.dtvigenc
              ,crapfco.cdfvlcop
              ,crapfco.cdfaixav
        FROM crapfco
        WHERE crapfco.cdfvlcop = pr_cdfvlcop;
      rw_crapfco2 cr_crapfco2%ROWTYPE;

      --Registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Locais
      vr_cdtarifa     craptar.cdtarifa%TYPE;
      vr_cdfvlcop     INTEGER:= 0;
      vr_index_vigenc VARCHAR2(10);
      vr_contador     INTEGER:= 0;
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
      -- Variaveis de Log e Modulo - 23/10/2018 - REQ0011726
      vr_dsparame VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
      vr_nmrotpro VARCHAR2  (100) := 'pc_carrega_dados_tar_vigente';
      vr_cdproint VARCHAR2  (100);
    BEGIN
      -- Posiciona procedure - 23/10/2018 - REQ0011726
      vr_cdproint := vr_cdproexe||'.'||vr_nmrotpro;
      -- Inclusão do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);    
      vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                     ', pr_cdbattar:' || pr_cdbattar ||
                     ', pr_cdtarifa:' || pr_cdtarifa ||
                     ', pr_vllanmto:' || pr_vllanmto ||
                     ', pr_cdprogra:' || pr_cdprogra;       
      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 794;
        vr_dscritic:= NULL;
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1 /* cdagenci */
                             ,pr_nrdcaixa => 1 /* nrdcaixa */
                             ,pr_nrsequen => 1 /* sequencia */
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      --Se nao estiver ativo retorna OK
      IF rw_crapcop.flgativo = 0 THEN
        --Levantar Excecao - Saida OK
        RAISE vr_exc_saida;
      END IF;

      --Limpar tabela erro
      pr_tab_erro.DELETE;
      
      -- Recebe a tarifa passada por parâmetro
      vr_cdtarifa := pr_cdtarifa;
      
      -- Caso não houver tarifa, busca a partir da sigla (CRAPBAT)
      IF vr_cdtarifa IS NULL OR vr_cdtarifa = 0 THEN
      --Selecionar sigla da tarifa
      OPEN cr_crapbat (pr_cdbattar  => pr_cdbattar);
      --Posicionar no proximo registro
        FETCH cr_crapbat INTO vr_cdtarifa;
      --Se nao encontrar
      IF cr_crapbat%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapbat;             
        vr_cdcritic := 1393; -- Sigla da tarifa nao cadastrada - 23/10/2018 - REQ0011726
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapbat;
      END IF;
      
      --Selecionar as tarifas
      OPEN cr_craptar (pr_cdtarifa => vr_cdtarifa);
      --Posicionar no proximo registro
      FETCH cr_craptar INTO rw_craptar;
      --Se nao encontrar
      IF cr_craptar%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_craptar;
        vr_cdcritic := 1041; -- Tarifa nao cadastrada - 23/10/2018 - REQ0011726
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                       ', vr_cdtarifa:' || vr_cdtarifa;
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_craptar;
      --Selecionar faixa valor tarifa
      OPEN cr_crapfvl (pr_cdtarifa  => rw_craptar.cdtarifa
                      ,pr_vllanmto  => pr_vllanmto);
      --Posicionar no proximo registro
      FETCH cr_crapfvl INTO rw_crapfvl;
      --Se nao encontrar
      IF cr_crapfvl%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapfvl;
        vr_cdcritic := 1392; -- Erro Faixa Valor - 23/10/2018 - REQ0011726
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                       ', vr_cdtarifa:' || vr_cdtarifa;
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapfvl;

      --Zerar contador
      vr_contador:= 0;

      --Selecionar data
      OPEN BTCH0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
      --Posicionar primeiro registro
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      --Se encontrou
      IF BTCH0001.cr_crapdat%FOUND and rw_crapdat.inproces > 1 THEN
        --Limpar tabela memoria
        vr_tab_vigenc.DELETE;
        --Selecionar faixa valor cooperativa
        FOR rw_crapfco IN cr_crapfco (pr_cdcooper => pr_cdcooper
                                     ,pr_cdfaixav => rw_crapfvl.cdfaixav
                                     ,pr_flgvigen => 1) LOOP
          --Incrementar contador
          vr_contador:= vr_contador + 1;

          --Inserir Vigencia
          vr_index_vigenc:= lpad(rw_crapdat.dtmvtolt - rw_crapfco.dtvigenc,5,'0')||
                            lpad(vr_contador,5,'0');
          vr_tab_vigenc(vr_index_vigenc).cdfvlcop:= rw_crapfco.cdfvlcop;
          vr_tab_vigenc(vr_index_vigenc).dtvigenc:= rw_crapfco.dtvigenc;
          vr_tab_vigenc(vr_index_vigenc).cdfaixav:= rw_crapfco.cdfaixav;
          vr_tab_vigenc(vr_index_vigenc).qtdiavig:= rw_crapdat.dtmvtolt - rw_crapfco.dtvigenc;

        END LOOP;
      END IF;
      --Fechar Cursor
      CLOSE BTCH0001.cr_crapdat;

      IF vr_contador > 1 AND vr_tab_vigenc.COUNT > 0 THEN
        vr_cdcritic := 1394; -- Multiplos detalhamentos vigentes - 23/10/2018 - REQ0011726
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||  
                       ' '  || vr_nmrotpro ||  
                       '. ' || vr_dsparame ||
                       ', vr_cdtarifa:'    || vr_cdtarifa ||
                       ', vr_tab_vigenc.COUNT:'    || vr_tab_vigenc.COUNT ||
                       ', vr_tab_vigenc.FIRST:'    || vr_tab_vigenc.FIRST ||
                       ', vr_tab_vigenc.LAST:'    || vr_tab_vigenc.LAST;
        -- Log Erro
        tari0001.pc_log(pr_cdcooper => pr_cdcooper
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
        -- Continuação processo
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
        --Percorrer as vigencias encontradas
        FOR idx01 IN vr_tab_vigenc.FIRST..vr_tab_vigenc.LAST LOOP
        vr_index_vigenc := lpad(idx01,10,'0');
        BEGIN
          IF vr_tab_vigenc(vr_index_vigenc).qtdiavig >= 0 AND vr_cdfvlcop = 0 THEN
            --Selecionar faixa cooperativa
            OPEN cr_crapfco2 (pr_cdfvlcop => vr_tab_vigenc(vr_index_vigenc).cdfvlcop);
            FETCH cr_crapfco2 INTO rw_crapfco2;
            --Se nao encontrou
            IF cr_crapfco2%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_crapfco2;
              vr_cdcritic := 1391; -- Erro Faixa Valor Coop.Fvl - 23/10/2018 - REQ0011726
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                             ' vr_cdtarifa:' || vr_cdtarifa ||
                             ', vr_tab_vigenc idx:'          || vr_index_vigenc ||
                             ', cdfvlcop:'    || vr_tab_vigenc(vr_index_vigenc).cdfvlcop ||
                             ', qtdiavig:'    || vr_tab_vigenc(vr_index_vigenc).qtdiavig ||
                             ', cdfaixav:'    || rw_crapfvl.cdfaixav;
              --Gerar erro
              GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => 1
                                   ,pr_nrdcaixa => 1
                                   ,pr_nrsequen => 1
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapfco2;
            --Faixa de Valor da cooperativa
            vr_cdfvlcop:= vr_tab_vigenc(vr_index_vigenc).cdfvlcop;
          END IF;
          -- Envio centralizado de log de erro                                                    
          vr_cdcritic := 1394; --  - 23/10/2018 - REQ0011726
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' '  || vr_nmrotpro ||  
                         '. ' || vr_dsparame ||
                         ', vr_cdtarifa:'  || vr_cdtarifa ||
                         ', tab idx:'      || vr_index_vigenc ||
                         ', cur cdfaixav:' || rw_crapfvl.cdfaixav;-- ||
                        -- ', tab cdfvlcop:' || vr_tab_vigenc(vr_index_vigenc).cdfvlcop ||
                        -- ', tab qtdiavig:' || vr_tab_vigenc(vr_index_vigenc).qtdiavig ||
                        -- ', tab cdfaixav:' || vr_tab_vigenc(vr_index_vigenc).cdfaixav ||
                        -- ', tab dtvigenc:' || to_char(vr_tab_vigenc(vr_index_vigenc).dtvigenc,'DD/MM/YYYY');
          -- Log Erro
          tari0001.pc_log(pr_cdcooper => pr_cdcooper
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
          -- Continuação processo
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             vr_cdcritic := SQLCODE;
             vr_cdcritic := NULL;
          WHEN OTHERS THEN
             vr_cdcritic := SQLCODE;
             vr_cdcritic := NULL;
        END;
        END LOOP;
        -- Eliminado btch0001.pc_gera_log_batch                                                      
        vr_cdcritic := 1394; -- Multiplos detalh vigentes/Selecionado detalhamento - 23/10/2018 - REQ0011726
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||  
                       ' '  || vr_nmrotpro ||  
                       '. ' || vr_dsparame ||
                       ', vr_cdtarifa:'    || vr_cdtarifa ||
                       ', vr_cdfvlcop:'    || vr_cdfvlcop;
        -- Envio centralizado de log de erro
        tari0001.pc_log(pr_cdcooper => pr_cdcooper
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
        -- Continuação processo
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
      ELSE
        --Selecionar faixa valor cooperativa
        OPEN cr_crapfco (pr_cdcooper => pr_cdcooper
                        ,pr_cdfaixav => rw_crapfvl.cdfaixav
                        ,pr_flgvigen => 1);
        --Posicionar no proximo registro
        FETCH cr_crapfco INTO rw_crapfco;
        --Se nao encontrar
        IF cr_crapfco%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapfco;                        
          vr_cdcritic := 1391; -- Erro Faixa Valor Coop - 23/10/2018 - REQ0011726
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                         ' vr_cdtarifa:' || vr_cdtarifa ||
                         ', cdfaixav:'    || rw_crapfvl.cdfaixav;
          --Gerar erro
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => 1
                               ,pr_nrdcaixa => 1
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapfco;
      END IF;

      --Retornar valores
      -- TARIFA POR PERCENTUAL
      IF NVL(rw_crapfco.tpcobtar,0) = 2 THEN
        pr_vltarifa:= pr_vllanmto * (nvl(rw_crapfco.vlpertar,0)/100);
        --
        --VERIFICA LIMITE MÍNIMO
        IF pr_vltarifa < rw_crapfco.vlmintar THEN
          pr_vltarifa := rw_crapfco.vlmintar;
        END IF;
        --VERIFICA LIMITE MÁXIMO
        IF pr_vltarifa > rw_crapfco.vlmaxtar THEN
          pr_vltarifa := rw_crapfco.vlmaxtar;
        END IF;
      -- TARIFA FIXA
      ELSE
        pr_vltarifa:= rw_crapfco.vltarifa;
      END IF;
      --
      pr_cdhistor:= rw_crapfvl.cdhistor;
      pr_cdhisest:= rw_crapfvl.cdhisest;
      pr_dtdivulg:= rw_crapfco.dtdivulg;
      pr_dtvigenc:= rw_crapfco.dtvigenc;
      pr_cdfvlcop:= rw_crapfco.cdfvlcop;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic:= NULL;
        pr_dscritic:= NULL;
      WHEN vr_exc_erro THEN        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);			
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        IF pr_cdprogra IN ( 'Rel CET', 'IMGCHQ',  'TARIFA' ) 
        THEN
           NULL;
        ELSE
          -- Controlar geração de log de execução dos jobs   
          tari0001.pc_log(pr_cdcooper => pr_cdcooper
                         ,pr_dscritic => pr_dscritic         ||
                                         ' '  || vr_nmrotpro || 
                                         '. ' || vr_dsparame
                         ,pr_cdcritic => pr_cdcritic); 
        END IF;       
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       ' '  || vr_nmrotpro || 
                       ' '  || SQLERRM     ||
                       '. ' || vr_dsparame; 
        -- Controlar geração de log de execução dos jobs   
        tari0001.pc_log(pr_cdcooper => pr_cdcooper
                       ,pr_dscritic => pr_dscritic
                       ,pr_cdcritic => pr_cdcritic); 
        pr_cdcritic := 1224; --Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);                                  
                                 
    END;
  END pc_carrega_dados_tar_vigente;

  PROCEDURE pc_carrega_dados_tar_vigen_prg (pr_cdcooper  IN INTEGER       --Codigo Cooperativa
                                           ,pr_cdbattar  IN VARCHAR2      --Codigo da sigla da tarifa (CRAPBAT) - Ao popular este parâmetro o pr_cdtarifa não é necessário
                                           ,pr_cdprogra  IN VARCHAR2      --Codigo Programa
                                           ,pr_cdhistor  OUT INTEGER      --Codigo Historico
                                           ,pr_cdhisest  OUT NUMBER       --Historico Estorno
                                           ,pr_vltarifa  OUT NUMBER       --Valor tarifa
                                           ,pr_cdcritic  OUT INTEGER      --Codigo Critica
                                           ,pr_dscritic  OUT VARCHAR2) IS --Descricao Critica 

    vr_dtdivulg     DATE;
    vr_dtvigenc     DATE;
    vr_cdfvlcop     INTEGER;          
    vr_tab_erro     GENE0001.typ_tab_erro;
  BEGIN
    /*  Busca valor da tarifa sem registro*/
    TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper    --Codigo Cooperativa
                                          ,pr_cdbattar  => pr_cdbattar    --Codigo Tarifa
                                          ,pr_vllanmto  => 0              --Valor Lancamento
                                          ,pr_cdprogra  => pr_cdprogra    --Codigo Programa
                                          ,pr_cdhistor  => pr_cdhistor    --Codigo Historico
                                          ,pr_cdhisest  => pr_cdhisest    --Historico Estorno
                                          ,pr_vltarifa  => pr_vltarifa    --Valor tarifa
                                          ,pr_dtdivulg  => vr_dtdivulg    --Data Divulgacao
                                          ,pr_dtvigenc  => vr_dtvigenc    --Data Vigencia
                                          ,pr_cdfvlcop  => vr_cdfvlcop    --Codigo faixa valor cooperativa
                                          ,pr_cdcritic  => pr_cdcritic    --Codigo Critica
                                          ,pr_dscritic  => pr_dscritic    --Descricao Critica
                                          ,pr_tab_erro  => vr_tab_erro);  --Tabela erros

  END pc_carrega_dados_tar_vigen_prg;

  /* Procedure para buscar tarifa intercooperativa */
  PROCEDURE pc_busca_tar_transf_intercoop (pr_cdcooper IN INTEGER --Codigo Cooperativa
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
  --  Programa : pc_busca_tar_transf_intercoop        Antigo: dbo/b1crap22.p/tarifa-transf-intercooperativa
  --  Sistema  : Procedure para buscar tarifa transferencia intercooperativa
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 23/10/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar tarifa transferencia intercooperativa
  --                
  --   Atualizacao:    
  --     23/10/2018 - Padrões: Others, Modulo/Action, PC Internal Exception, PC Log Programa
  --                  Inserts, Updates, Deletes e SELECT's, Parâmetros, troca de mensagens por código                             
  --                 (Envolti - Belli - REQ0011726)           
  --                
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
       --Tipos de tabelas de memoria para descricoes
       TYPE typ_tab_dim1 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
       TYPE typ_tab_dim2 IS TABLE OF typ_tab_dim1 INDEX BY BINARY_INTEGER;
       --Tabela de Memoria para descricoes
       vr_tab_dstiptar typ_tab_dim2;
      --Variaveis Locais
      vr_dssigtar VARCHAR2(20);
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdagenci INTEGER;

      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_tab_erro GENE0001.typ_tab_erro;

      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      -- Variaveis de Log e Modulo - 23/10/2018 - REQ0011726
      vr_dsparame VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
      vr_nmrotpro VARCHAR2  (100) := 'pc_busca_tar_transf_intercoop';
      vr_cdproint VARCHAR2  (100);      
      vr_exc_fim  EXCEPTION; --Variaveis Excecao
    BEGIN
      -- Posiciona procedure - 23/10/2018 - REQ0011726
      vr_cdproint := vr_cdproexe||'.'||vr_nmrotpro;
      -- Inclusão do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);    
      vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                     ', pr_cdagenci:' || pr_cdagenci ||
                     ', pr_nrdconta:' || pr_nrdconta ||
                     ', pr_vllanmto:' || pr_vllanmto;
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Inicializar variaveis retorno
      pr_vltarifa:= 0;
      pr_cdhistor:= 0;
      pr_cdfvlcop:= 0;
      pr_cdhisest:= 0;

      --Limpar vetor memoria
      vr_tab_dstiptar.DELETE;

      --Associar no vetor de memorias as descricoes das transacoes
      vr_tab_dstiptar (91)(1):= 'TROUTTAAPF';
      vr_tab_dstiptar (91)(2):= 'TROUTTAAPJ';
      vr_tab_dstiptar (90)(1):= 'TROUTINTPF';
      vr_tab_dstiptar (90)(2):= 'TROUTINTPJ';
      vr_tab_dstiptar (99)(1):= 'TROUTPREPF';
      vr_tab_dstiptar (99)(2):= 'TROUTPREPJ';

      --Atribuir a agencia para a variavel
      vr_cdagenci:= pr_cdagenci;

      --Se a agencia nao for 90 nem 91 atribuir 99
      IF vr_cdagenci NOT IN (90,91) THEN
        vr_cdagenci:= 99;
      END IF;

      --Selecionar associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      --Posicionar no proximo registro
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
         --- vr_dscritic:= 'Associado nao cadastrado.';
        vr_cdcritic := 1; -- Associado nao cadastrado - 23/10/2018 - REQ0011726
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;

      /** Conta administrativa nao sofre tarifacao **/
      IF rw_crapass.inpessoa = 3 THEN
        RAISE vr_exc_fim;
      END IF;

      /* A sigla da tarifa ira receber os valores do vetor de acordo com
         a agencia e o tipo da pessoa (fisica/juridica */

      --Sigla tarifa recebe valor tabela memoria para agencia e inpessoa
      vr_dssigtar:= vr_tab_dstiptar (vr_cdagenci)(rw_crapass.inpessoa);

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
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE 
          -- Trata descrição incompleta - 23/10/2018 - REQ0011726
          vr_cdcritic := NVL(vr_cdcritic,0); -- Grava erro original        
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic,pr_dscritic => vr_dscritic)||
                         '(1)';	
          -- Controlar geração de log de execução dos jobs   
          tari0001.pc_log(pr_cdcooper => pr_cdcooper
                         ,pr_dscritic => vr_dscritic         ||
                                         ' '  || vr_nmrotpro || 
                                         '. ' || vr_dsparame
                         ,pr_cdcritic => vr_cdcritic); 
          vr_cdcritic := 1058; -- Nao foi possivel carregar a tarifa        
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         '(1)';	
        END IF;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Limpar tabela memoria
      vr_tab_dstiptar.DELETE;
      -- Limpa do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);  
    EXCEPTION
      WHEN vr_exc_fim THEN
         --Limpar tabela memoria
         vr_tab_dstiptar.DELETE;
         -- Limpa do módulo e ação logado
         GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL); 
       WHEN vr_exc_erro THEN		      
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic );	
       WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                         ' '  || vr_nmrotpro || 
                         ' '  || SQLERRM     ||
                         '. ' || vr_dsparame; 
          -- Controlar geração de log de execução dos jobs   
          tari0001.pc_log(pr_cdcooper => pr_cdcooper
                         ,pr_dscritic => pr_dscritic
                         ,pr_cdcritic => pr_cdcritic); 
          pr_cdcritic := 1224; --Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);          
    END;
  END pc_busca_tar_transf_intercoop;


  /* Lancamento de tarifas na Conta Corrente */
  PROCEDURE pc_lan_tarifa_conta_corrente (pr_cdcooper IN INTEGER   --Codigo Cooperativa
                                         ,pr_cdagenci IN INTEGER   --Codigo Agencia
                                         ,pr_nrdconta IN INTEGER   --Numero da Conta
                                         ,pr_cdbccxlt IN INTEGER   --Codigo Banco/Agencia/Caixa
                                         ,pr_nrdolote IN INTEGER   --Numero do Lote
                                         ,pr_tplotmov IN INTEGER   --Tipo Lote
                                         ,pr_cdoperad IN VARCHAR2  --Codigo Operador
                                         ,pr_dtmvtolt IN DATE      --Data Movimento Atual
                                         ,pr_nrdctabb IN INTEGER   --Numero Conta BB
                                         ,pr_nrdctitg IN VARCHAR2  --Numero Conta Integracao
                                         ,pr_cdhistor IN INTEGER   --Codigo Historico
                                         ,pr_cdpesqbb IN VARCHAR2  --Codigo Pesquisa
                                         ,pr_cdbanchq IN NUMBER    --Codigo Banco Cheque
                                         ,pr_cdagechq IN INTEGER   --Codigo Agencia Cheque
                                         ,pr_nrctachq IN INTEGER   --Numero Conta Cheque
                                         ,pr_flgaviso IN BOOLEAN   --Flag Aviso Debito CC
                                         ,pr_cdsecext IN INTEGER   --Codigo Extrato
                                         ,pr_tpdaviso IN INTEGER   --Tipo de Aviso
                                         ,pr_vltarifa IN NUMBER    --Valor da Tarifa
                                         ,pr_nrdocmto IN NUMBER    --Numero do Documento
                                         ,pr_cdageass IN INTEGER   --Codigo Agencia Associado
                                         ,pr_cdcoptfn IN INTEGER   --Codigo Cooperativa do Terminal
                                         ,pr_cdagetfn IN INTEGER   --Codigo Agencia do Terminal
                                         ,pr_nrterfin IN INTEGER   --Numero do Terminal
                                         ,pr_nrsequni IN INTEGER   --Numero Sequencial Unico
                                         ,pr_nrautdoc IN INTEGER   --Numero da Autenticacao do Documento
                                         ,pr_dsidenti IN VARCHAR2  --Descricao da Identificacao
                                         ,pr_inproces IN INTEGER   --Indicador do Processo
                                         ,pr_tab_erro OUT GENE0001.typ_tab_erro      --Tabela de retorno de erro
                                         ,pr_cdcritic OUT INTEGER      --C¿digo do erro
                                         ,pr_dscritic OUT VARCHAR2) IS   --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_lan_tarifa_conta_corrente        Antigo: dbo/b1wgen0153/lan_tarifa_conta_corrente
  --  Sistema  : Credito
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Agosto/2013.                   Ultima atualizacao: 26/02/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para lancar tarifa conta corrente
  --
  -- Alteracoes: 26/02/2016 - Alterado rotina para testar se o lote esta alocado antes de realizar os comandos
  --                          conforme é no progress, incluido logs de monitoramento (Odirlei-AMcom)   
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Cursores Locais

      --Buscar informacoes de lote
      CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplot.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT  craplot.nrdolote
               ,craplot.nrseqdig
               ,craplot.cdbccxlt
               ,craplot.cdcooper
               ,craplot.dtmvtolt
               ,craplot.cdagenci
               ,craplot.rowid
        FROM craplot craplot
        WHERE craplot.cdcooper = pr_cdcooper
        AND   craplot.dtmvtolt = pr_dtmvtolt
        AND   craplot.cdagenci = pr_cdagenci
        AND   craplot.cdbccxlt = pr_cdbccxlt
        AND   craplot.nrdolote = pr_nrdolote
        FOR UPDATE NOWAIT;
      rw_craplot cr_craplot%ROWTYPE;
      
      --Selecionar Historico
      CURSOR cr_craphis (pr_cdcooper IN craphis.cdcooper%type
                        ,pr_cdhistor IN craphis.cdhistor%type) IS
        SELECT craphis.indebcre
        FROM craphis
        WHERE craphis.cdcooper = pr_cdcooper
        AND   craphis.cdhistor = pr_cdhistor;
      rw_craphis cr_craphis%ROWTYPE;

      --Selecionar Lancamentos
      CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%type
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%type
                        ,pr_cdagenci IN craplcm.cdagenci%type
                        ,pr_cdbccxlt IN craplcm.cdbccxlt%type
                        ,pr_nrdolote IN craplcm.nrdolote%type
                        ,pr_nrdctabb IN craplcm.nrdctabb%type
                        ,pr_nrdocmto IN craplcm.nrdocmto%type) IS
        SELECT  craplcm.cdcooper
               ,craplcm.dtmvtolt
               ,craplcm.nrdconta
               ,craplcm.cdhistor
               ,craplcm.nrdocmto
               ,craplcm.nrseqdig
               ,craplcm.vllanmto
               ,craplcm.ROWID
        FROM craplcm
        WHERE craplcm.cdcooper = pr_cdcooper
        AND   craplcm.dtmvtolt = pr_dtmvtolt
        AND   craplcm.cdagenci = pr_cdagenci
        AND   craplcm.cdbccxlt = pr_cdbccxlt
        AND   craplcm.nrdolote = pr_nrdolote
        AND   craplcm.nrdctabb = pr_nrdctabb
        AND   craplcm.nrdocmto = pr_nrdocmto;
      rw_craplcm cr_craplcm%ROWTYPE;
      --Tipo de tabela de Documentos
      TYPE typ_tab_ctrdocmt IS VARRAY(9) OF VARCHAR2(1);
      --Tabela de Memoria de Documentos
      vr_tab_ctrdocmt typ_tab_ctrdocmt:= typ_tab_ctrdocmt('1','2','3','4','5','6','7','8','9');
      --Variaveis Locais
      vr_contapli  INTEGER;
      vr_nraplica  VARCHAR2(100);
      vr_nraplfun  VARCHAR2(100);
      vr_nraplica2 NUMBER;
      vr_errnumber BOOLEAN:= FALSE;
      vr_nrsequni  craplcm.nrsequni%TYPE;
      vr_nrdocmto  craplcm.nrdocmto%TYPE;
      --Variaveis de Erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);

      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      --Tipo de Dados para cursor cooperativa
      rw_crabcop  cr_crapcop%ROWTYPE;
      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      --Rowid lancamento tarifa
      vr_rowid_craplat ROWID;
      
      vr_flgerlog VARCHAR2(100) := NULL;
      
      -- saidas para pc_gerar_lancamento_conta
      vr_tab_retorno LANC0001.typ_reg_retorno;
      vr_incrineg INTEGER;
      
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
        
        pc_gera_log_lote_uso(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => pr_nrdconta,
                             pr_nrdolote => vr_nrdolote,
                             pr_flgerlog => vr_flgerlog,
                             pr_des_log  => 'Alocando lote -> '||
                                           'cdcooper: '||pr_cdcooper ||' '||           
                                           'dtmvtolt: '|| to_char(pr_dtmvtolt,'DD/MM/RRRR')||' '||           
                                           'cdagenci: '|| pr_cdagenci||' '||           
                                           'cdbccxlt: '|| pr_cdbccxlt||' '||           
                                           'nrdolote: '|| vr_nrdolote||' '|| 
                                           'nrdconta: '|| pr_nrdconta||' '|| 
                                           'cdhistor: '|| pr_cdhistor||' '|| 
                                           'rotina: TARI0001.pc_lan_tarifa_conta_corrente ');
        
        FOR vr_contador IN 1..100 LOOP
          BEGIN
            
            -- verificar lote
            OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                             pr_dtmvtolt  => pr_dtmvtolt,
                             pr_cdagenci  => pr_cdagenci,
                             pr_cdbccxlt  => pr_cdbccxlt,
                             pr_nrdolote  => vr_nrdolote);
            FETCH cr_craplot INTO rw_craplot;
            -- se não deu erro no fecth é pq o registro não esta em lock
            EXIT;           
              
          EXCEPTION
            WHEN OTHERS THEN
              IF cr_craplot%ISOPEN THEN
                CLOSE cr_craplot;
              END IF;
              
              pc_gera_log_lote_uso(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrdolote => vr_nrdolote,
                                   pr_flgerlog => vr_flgerlog,
                                   pr_des_log  => 'Lote ja alocado('||vr_contador||') -> '||
                                               'cdcooper: '|| pr_cdcooper||' '||           
                                               'dtmvtolt: '|| to_char(pr_dtmvtolt,'DD/MM/RRRR')||' '||           
                                               'cdagenci: '|| pr_cdagenci||' '||           
                                               'cdbccxlt: '|| pr_cdbccxlt||' '||           
                                               'nrdolote: '|| vr_nrdolote||' '|| 
                                               'nrdconta: '|| pr_nrdconta||' '|| 
                                               'cdhistor: '|| pr_cdhistor||' '|| 
                                               'rotina: TARI0001.pc_lan_tarifa_conta_corrente ');
              
              -- se for a ultima tentativa, guardar a critica
              IF vr_contador = 100 THEN
                pr_dscritic := 'Registro de lote '||vr_nrdolote||' em uso. Tente novamente.';                                
              END IF;
              sys.dbms_lock.sleep(0.1);  
          END;
        END LOOP;
        
        -- se encontrou erro ao buscar lote, abortar programa
        IF pr_dscritic IS NOT NULL THEN
          ROLLBACK;
          RETURN;
        END IF;
          
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
            
        ELSE
          -- Atualizar lote para reservar nrseqdig
          UPDATE craplot
             SET craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
           WHERE craplot.rowid = rw_craplot.rowid
          RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig; 
          
        END IF;
        CLOSE cr_craplot;
        pr_craplot := rw_craplot;
          
        COMMIT;
        
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;
          
          ROLLBACK;        
          -- se ocorreu algum erro durante a criac?o
          pr_dscritic := 'Erro ao inserir/atualizar lote '||rw_craplot.nrdolote||': '||SQLERRM;
      END pc_insere_lote;
      
      --> Procedimento autonomo para atualizar o lote e liberar lock da tabela
      PROCEDURE pc_atualiza_lote(pr_cdcooper   IN crapcop.cdcooper%TYPE,
                                 pr_cdhistor   IN craphis.cdhistor%TYPE,
                                 pr_vltarifa   IN craplat.vltarifa%TYPE,
                                 pr_rw_craplot IN cr_craplot%ROWTYPE,
                                 pr_cdcritic  OUT INTEGER, 
                                 pr_dscritic  OUT VARCHAR2  ) IS
        -- Pragma - abre nova sessao para tratar a atualizacao
        PRAGMA AUTONOMOUS_TRANSACTION;
            
      BEGIN
      
        OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                        ,pr_cdhistor => pr_cdhistor);
        --Posicionar no primeiro registro
        FETCH cr_craphis INTO rw_craphis;
        --Se encontrou
        IF cr_craphis%FOUND THEN
          --Fechar Cursor
          CLOSE cr_craphis;
          
          pc_gera_log_lote_uso(pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => pr_nrdconta,
                               pr_nrdolote => pr_rw_craplot.nrdolote,
                               pr_flgerlog => vr_flgerlog,
                               pr_des_log  => 'Alocando lote -> '||
                                               'cdcooper: '|| pr_rw_craplot.cdcooper ||' '||           
                                               'dtmvtolt: '|| to_char(pr_rw_craplot.dtmvtolt,'DD/MM/RRRR')||' '||
                                               'cdagenci: '|| pr_rw_craplot.cdagenci||' '||           
                                               'cdbccxlt: '|| pr_rw_craplot.cdbccxlt||' '||           
                                               'nrdolote: '|| pr_rw_craplot.nrdolote||' '|| 
                                               'nrdconta: '|| pr_nrdconta||' '|| 
                                               'cdhistor: '|| pr_cdhistor||' '|| 
                                               'rotina: TARI0001.pc_lan_tarifa_conta_corrente(update final)');
          
          --> Verificar se lote esta lockado antes de realizar o update
          IF CXON0020.fn_verifica_lote_uso(pr_rowid => pr_rw_craplot.rowid ) = 1 THEN
            vr_dscritic:= 'Registro de lote '||pr_rw_craplot.nrdolote||' em uso. Tente novamente.';  
            
            pc_gera_log_lote_uso(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrdolote => pr_rw_craplot.nrdolote,
                                 pr_flgerlog => vr_flgerlog,
                                 pr_des_log  => 'ERRO: Lote ja alocado -> '||
                                               'cdcooper: '|| pr_rw_craplot.cdcooper ||' '||           
                                               'dtmvtolt: '|| to_char(pr_rw_craplot.dtmvtolt,'DD/MM/RRRR')||' '||           
                                               'cdagenci: '|| pr_rw_craplot.cdagenci||' '||           
                                               'cdbccxlt: '|| pr_rw_craplot.cdbccxlt||' '||           
                                               'nrdolote: '|| pr_rw_craplot.nrdolote||' '|| 
                                               'nrdconta: '|| pr_nrdconta||' '|| 
                                               'cdhistor: '|| pr_cdhistor||' '|| 
                                               'rotina: TARI0001.pc_lan_tarifa_conta_corrente(update final)');
            
            -- apensa jogar critica em log
            RAISE vr_exc_erro;
          END IF;
            
          --Debito
          IF  rw_craphis.indebcre = 'D' THEN
            BEGIN
              UPDATE craplot SET craplot.vlinfodb = Nvl(craplot.vlinfodb,0) + pr_vltarifa
                                ,craplot.vlcompdb = Nvl(craplot.vlcompdb,0) + pr_vltarifa
                                ,craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                                ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
              WHERE craplot.ROWID = pr_rw_craplot.ROWID;
            EXCEPTION
              WHEN Others THEN
                vr_dscritic:= 'Erro ao atualizar lote. '||sqlerrm;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
          ELSE
            BEGIN
              UPDATE craplot SET craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + pr_vltarifa
                                ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + pr_vltarifa
                                ,craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                                ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
              WHERE craplot.ROWID = pr_rw_craplot.ROWID;
            EXCEPTION
              WHEN Others THEN
                vr_dscritic:= 'Erro ao atualizar lote. '||sqlerrm;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
          END IF;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Historico nao encontrado!';
          RAISE vr_exc_erro;
          
        END IF;
        --Fechar Cursor
        IF cr_craphis%ISOPEN THEN
          CLOSE cr_craphis;
        END IF; 
        
        -- Commit apensa na sessao autonoma
        COMMIT;
      
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- rollback apenas na sessao autonoma
          ROLLBACK;
          pr_cdcritic := nvl(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;          
          
        WHEN OTHERS THEN
          -- rollback apenas na sessao autonoma
          ROLLBACK;
          
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar lote. '||sqlerrm;
         
      END pc_atualiza_lote;
      
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Limpar tabela erro
      pr_tab_erro.DELETE;

      --Inicializar conta aplicacao
      vr_contapli:= 9;

      --Se a tarifa for zero
      IF pr_vltarifa = 0 THEN
        RETURN;
      END IF;
      
      
      -- Procedimento para inserir o lote e não deixar tabela lockada
      pc_insere_lote (pr_cdcooper => pr_cdcooper,
                      pr_dtmvtolt => pr_dtmvtolt,
                      pr_cdagenci => pr_cdagenci,
                      pr_cdbccxlt => pr_cdbccxlt,
                      pr_nrdolote => pr_nrdolote,
                      pr_tplotmov => pr_tplotmov,
                      pr_cdhistor => 0,
                      pr_cdoperad => pr_cdoperad,
                      pr_nrdcaixa => 0,
                      pr_cdopecxa => 0,
                      pr_dscritic => vr_dscritic,
                      pr_craplot  => rw_craplot);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      --Selecionar informacoes do lote
     /* OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                      ,pr_dtmvtolt => pr_dtmvtolt
                      ,pr_cdagenci => pr_cdagenci
                      ,pr_cdbccxlt => pr_cdbccxlt
                      ,pr_nrdolote => pr_nrdolote);
      --Posicionar no proximo registro
      FETCH cr_craplot INTO rw_craplot;
      --Se nao encontrar
      IF cr_craplot%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_craplot;
        --Criar Lote
         BEGIN
           INSERT INTO craplot
              (craplot.cdcooper
              ,craplot.dtmvtolt
              ,craplot.cdagenci
              ,craplot.cdbccxlt
              ,craplot.nrdolote
              ,craplot.tplotmov
              ,craplot.cdoperad)
           VALUES
              (pr_cdcooper
              ,pr_dtmvtolt
              ,pr_cdagenci
              ,pr_cdbccxlt
              ,pr_nrdolote
              ,pr_tplotmov
              ,pr_cdoperad)
           RETURNING craplot.ROWID
                    ,craplot.cdcooper
                    ,craplot.dtmvtolt
                    ,craplot.cdagenci
                    ,craplot.cdbccxlt
                    ,craplot.nrdolote
                    ,craplot.nrseqdig
           INTO rw_craplot.ROWID
               ,rw_craplot.cdcooper
               ,rw_craplot.dtmvtolt
               ,rw_craplot.cdagenci
               ,rw_craplot.cdbccxlt
               ,rw_craplot.nrdolote
               ,rw_craplot.nrseqdig;
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Erro ao inserir na tabela de lotes. '||sqlerrm;
             RAISE vr_exc_erro;
         END;
      END IF;
      --Fechar Cursor
      IF cr_craplot%ISOPEN THEN
        CLOSE cr_craplot;
      END IF;*/

      --Selecionar Historico
      /*OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                      ,pr_cdhistor => pr_cdhistor);
      --Posicionar no primeiro registro
      FETCH cr_craphis INTO rw_craphis;
      --Se encontrou
      IF cr_craphis%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craphis;
        --Debito
        IF  rw_craphis.indebcre = 'D' THEN
          BEGIN
            UPDATE craplot SET craplot.vlinfodb = Nvl(craplot.vlinfodb,0) + pr_vltarifa
                              ,craplot.vlcompdb = Nvl(craplot.vlcompdb,0) + pr_vltarifa
            WHERE craplot.ROWID = rw_craplot.ROWID;
          EXCEPTION
            WHEN Others THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar lote. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        ELSE
          BEGIN
            UPDATE craplot SET craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + pr_vltarifa
                              ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + pr_vltarifa
            WHERE craplot.ROWID = rw_craplot.ROWID;
          EXCEPTION
            WHEN Others THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar lote. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
      ELSE
        --Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Historico nao encontrado!';

        --Gerar Erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      END IF;
      --Fechar Cursor
      IF cr_craphis%ISOPEN THEN
        CLOSE cr_craphis;
      END IF;
      --Atualizar Lote
      BEGIN
        UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                          ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                          ,craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1.
        WHERE craplot.ROWID = rw_craplot.ROWID
        RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar lote. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;*/
      --Numero Aplicacao
      vr_nraplica:= pr_nrdocmto;
      --Numero Aplicacao Funcionario
      vr_nraplfun:= pr_nrdocmto;

      LOOP
        --Numero documento
        IF pr_nrdocmto > 0 THEN
          vr_nrdocmto:= To_Number(vr_nraplica);
        ELSE
          vr_nrdocmto:= Nvl(rw_craplot.nrseqdig,0);
        END IF;

          --Determinar Sequencial Unico
          IF pr_nrsequni = 0 THEN
            vr_nrsequni:= Nvl(rw_craplot.nrseqdig,0);
          ELSE
            vr_nrsequni:= pr_nrsequni;
          END IF;

          --Inserir Lancamento
          BEGIN
            LANC0001.pc_gerar_lancamento_conta( pr_cdagenci => pr_cdagenci
                                              , pr_cdbccxlt => pr_cdbccxlt
                                              , pr_cdhistor => pr_cdhistor
                                              , pr_dtmvtolt => rw_craplot.dtmvtolt
                                              , pr_dtrefere => rw_craplot.dtmvtolt
                                              , pr_nrdconta => pr_nrdconta
                                              , pr_nrdctabb => pr_nrdctabb
                                              , pr_nrdctitg => pr_nrdctitg
                                              , pr_nrdocmto => vr_nrdocmto
                                              , pr_nrdolote => pr_nrdolote
                                              , pr_nrseqdig => rw_craplot.nrseqdig
                                              , pr_cdcooper => pr_cdcooper
                                              , pr_vllanmto => pr_vltarifa
                                              , pr_cdoperad => pr_cdoperad
                                              , pr_hrtransa => GENE0002.fn_busca_time
                                              , pr_nrsequni => vr_nrsequni
                                              , pr_cdpesqbb => pr_cdpesqbb
                                              , pr_cdbanchq => pr_cdbanchq
                                              , pr_cdagechq => pr_cdagechq
                                              , pr_nrctachq => pr_nrctachq
                                              , pr_cdcoptfn => pr_cdcoptfn
                                              , pr_cdagetfn => pr_cdagetfn 
                                              , pr_nrterfin => pr_nrterfin
                                              , pr_nrautdoc => pr_nrautdoc
                                              , pr_dsidenti => pr_dsidenti
                                              , pr_tab_retorno => vr_tab_retorno
                                              , pr_incrineg => vr_incrineg
                                              , pr_cdcritic => vr_cdcritic
                                              , pr_dscritic => vr_dscritic
                                              );
            IF vr_cdcritic <> 0 or vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_erro;
            END IF;

            -- atualiza valores do cursor                                              
            rw_craplcm.cdcooper := pr_cdcooper;
            rw_craplcm.dtmvtolt := rw_craplot.dtmvtolt;
            rw_craplcm.nrdconta := pr_nrdconta;
            rw_craplcm.cdhistor := pr_cdhistor;
            rw_craplcm.nrdocmto := vr_nrdocmto;
            rw_craplcm.nrseqdig := rw_craplot.nrseqdig;
            rw_craplcm.vllanmto := pr_vltarifa;
            
          EXCEPTION
            WHEN vr_exc_erro THEN
              IF vr_cdcritic = 92 THEN --> DUP_VAL_ON_INDEX 
          --Se o numero documento igual zero
          IF pr_nrdocmto = 0 THEN
            
            -- Gerar novo nrseqdig que será utilizado como numero de documento
            pc_insere_lote (pr_cdcooper => pr_cdcooper,
                            pr_dtmvtolt => pr_dtmvtolt,
                            pr_cdagenci => pr_cdagenci,
                            pr_cdbccxlt => pr_cdbccxlt,
                            pr_nrdolote => pr_nrdolote,
                            pr_tplotmov => pr_tplotmov,
                            pr_cdhistor => 0,
                            pr_cdoperad => pr_cdoperad,
                            pr_nrdcaixa => 0,
                            pr_cdopecxa => 0,
                            pr_dscritic => vr_dscritic,
                            pr_craplot  => rw_craplot);
            
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            
            --Proximo registro loop
            CONTINUE;
          END IF;
          --Montar Numero Aplicacao
          vr_nraplica:= vr_tab_ctrdocmt(vr_contapli)||vr_nraplica;
          --Verificar se eh numerico
          vr_errnumber:= FALSE;
          BEGIN
            vr_nraplica2:= To_Number(vr_nraplica);
          EXCEPTION
            WHEN OTHERS THEN
              vr_errnumber:= TRUE;
          END;
          --Se ocorreu erro na conversao number
          IF vr_errnumber OR NOT GENE0002.fn_numerico(vr_nraplica) THEN
            --Diminuir conta aplicacao
            vr_contapli:= Nvl(vr_contapli,0) - 1;
            --Montar Numero Aplicacao Funcionario
            vr_nraplica:= vr_tab_ctrdocmt(vr_contapli)||vr_nraplfun;
            --Proximo registro loop
            CONTINUE;
          END IF;
          --Proximo registro loop
          CONTINUE;
          
              ELSE
                RAISE vr_exc_erro;
              END IF; --> FIM IF vr_cdcritic = 92  
                     
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir lancamento. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;

        EXIT;
      END LOOP;
      /* Cria aviso de debito em CC se necessario */
      IF pr_flgaviso THEN
        BEGIN
          INSERT INTO crapavs
            (crapavs.cdcooper
            ,crapavs.dtmvtolt
            ,crapavs.nrdconta
            ,crapavs.cdhistor
            ,crapavs.nrdocmto
            ,crapavs.nrseqdig
            ,crapavs.cdagenci
            ,crapavs.cdsecext
            ,crapavs.dtdebito
            ,crapavs.dtrefere
            ,crapavs.tpdaviso
            ,crapavs.vllanmto
            ,crapavs.flgproce)
          VALUES
            (rw_craplcm.cdcooper
            ,rw_craplcm.dtmvtolt
            ,rw_craplcm.nrdconta
            ,rw_craplcm.cdhistor
            ,rw_craplcm.nrdocmto
            ,rw_craplcm.nrseqdig
            ,pr_cdageass
            ,pr_cdsecext
            ,rw_craplcm.dtmvtolt
            ,rw_craplcm.dtmvtolt
            ,pr_tpdaviso
            ,rw_craplcm.vllanmto
            ,0);
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir na tabela crapavs. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;
      
      --> Procedimento autonomo para atualizar o lote e liberar lock da tabela
      pc_atualiza_lote(pr_cdcooper   => pr_cdcooper,
                       pr_cdhistor   => pr_cdhistor,
                       pr_vltarifa   => pr_vltarifa,
                       pr_rw_craplot => rw_craplot,
                       pr_cdcritic   => vr_cdcritic,
                       pr_dscritic   => vr_dscritic);
      
      IF TRIM(vr_dscritic) IS NOT NULL OR 
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;
                       
      
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;

         --Gerar Erro
         GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_nrdcaixa => 1
                              ,pr_nrsequen => 1
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic
                              ,pr_tab_erro => pr_tab_erro);

       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina TARI0001.pc_lan_tarifa_conta_corrente. '||SQLERRM;

         --Gerar Erro
         GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_nrdcaixa => 1
                              ,pr_nrsequen => 1
                              ,pr_cdcritic => pr_cdcritic
                              ,pr_dscritic => pr_dscritic
                              ,pr_tab_erro => pr_tab_erro);

    END;
  END pc_lan_tarifa_conta_corrente;


  /* Realizar Lancamento Tarifa Online */
  PROCEDURE pc_lan_tarifa_online (pr_cdcooper IN INTEGER  --Codigo Cooperativa
                                 ,pr_cdagenci IN INTEGER  --Codigo Agencia destino
                                 ,pr_nrdconta IN INTEGER  --Numero da Conta Destino
                                 ,pr_cdbccxlt IN INTEGER  --Codigo banco/caixa
                                 ,pr_nrdolote IN INTEGER  --Numero do Lote
                                 ,pr_tplotmov IN INTEGER  --Tipo Lote
                                 ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                 ,pr_dtmvtlat IN DATE     --Data Tarifa
                                 ,pr_dtmvtlcm IN DATE     --Data lancamento
                                 ,pr_nrdctabb IN INTEGER  --Numero Conta BB
                                 ,pr_nrdctitg IN VARCHAR2 --Conta Integracao
                                 ,pr_cdhistor IN INTEGER  --Codigo Historico
                                 ,pr_cdpesqbb IN VARCHAR2 --Codigo pesquisa
                                 ,pr_cdbanchq IN NUMBER   --Codigo Banco Cheque
                                 ,pr_cdagechq IN INTEGER  --Codigo Agencia Cheque
                                 ,pr_nrctachq IN INTEGER  --Numero Conta Cheque
                                 ,pr_flgaviso IN BOOLEAN  --Flag Aviso
                                 ,pr_tpdaviso IN INTEGER  --Tipo Aviso
                                 ,pr_vltarifa IN NUMBER   --Valor tarifa
                                 ,pr_nrdocmto IN NUMBER   --Numero Documento
                                 ,pr_cdcoptfn IN INTEGER  --Codigo Cooperativa Terminal
                                 ,pr_cdagetfn IN INTEGER  --Codigo Agencia Terminal
                                 ,pr_nrterfin IN INTEGER  --Numero Terminal Financeiro
                                 ,pr_nrsequni IN INTEGER  --Numero Sequencial Unico
                                 ,pr_nrautdoc IN INTEGER  --Numero Autenticacao Documento
                                 ,pr_dsidenti IN VARCHAR2 --Descricao Identificacao
                                 ,pr_cdfvlcop IN INTEGER  --Codigo Faixa Valor Cooperativa
                                 ,pr_inproces IN INTEGER  --Indicador Processo
                                 ,pr_cdlantar OUT craplat.cdlantar%type --Codigo Lancamento tarifa
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela de erro
                                 ,pr_cdcritic OUT INTEGER       --C¿digo do erro
                                 ,pr_dscritic OUT VARCHAR2) IS   --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_lan_tarifa_online        Antigo: dbo/b1wgen0153/lan-tarifa-online
  --  Sistema  : Credito
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para lancar tarifa online

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Cursores Locais

      --Selecionar Lancamento Tarifa
      CURSOR cr_craplat (pr_rowid IN ROWID) IS
        SELECT craplat.cdlantar
              ,craplat.rowid
        FROM craplat
        WHERE craplat.ROWID = pr_rowid;
      rw_craplat cr_craplat%ROWTYPE;

      --Variaveis Locais
      vr_flgtrans BOOLEAN:= FALSE;

      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      --Rowid lancamento tarifa
      vr_rowid_craplat ROWID;
      
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Se valor estiver zerado retorna
      IF pr_vltarifa = 0 THEN
        RETURN;
      END IF;

      --Verificar Associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      --Posicionar primeiro registro
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrou
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        --Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Associado nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      --Inicializar variavel retorno erro
      TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                       ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                       ,pr_dtmvtolt => pr_dtmvtlat   --Data Lancamento
                                       ,pr_cdhistor => pr_cdhistor   --Codigo Historico
                                       ,pr_vllanaut => pr_vltarifa   --Valor lancamento automatico
                                       ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                       ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                       ,pr_cdbccxlt => pr_cdbccxlt   --Codigo banco caixa
                                       ,pr_nrdolote => pr_nrdolote   --Numero do lote
                                       ,pr_tpdolote => pr_tplotmov   --Tipo do lote
                                       ,pr_nrdocmto => pr_nrdocmto   --Numero do documento
                                       ,pr_nrdctabb => pr_nrdctabb   --Numero da conta
                                       ,pr_nrdctitg => pr_nrdctitg   --Numero da conta integracao
                                       ,pr_cdpesqbb => pr_cdpesqbb   --Codigo pesquisa
                                       ,pr_cdbanchq => pr_cdbanchq   --Codigo Banco Cheque
                                       ,pr_cdagechq => pr_cdagechq   --Codigo Agencia Cheque
                                       ,pr_nrctachq => pr_nrctachq   --Numero Conta Cheque
                                       ,pr_flgaviso => pr_flgaviso   --Flag aviso
                                       ,pr_tpdaviso => pr_tpdaviso   --Tipo aviso
                                       ,pr_cdfvlcop => pr_cdfvlcop   --Codigo cooperativa
                                       ,pr_inproces => pr_inproces   --Indicador processo
                                       ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                       ,pr_tab_erro => pr_tab_erro   --Tabela retorno erro
                                       ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                       ,pr_dscritic => vr_dscritic); --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Efetuar lancamento da tarifa na conta corrente
      pc_lan_tarifa_conta_corrente (pr_cdcooper => pr_cdcooper     --Codigo Cooperativa
                                   ,pr_cdagenci => pr_cdagenci     --Codigo Agencia
                                   ,pr_nrdconta => pr_nrdconta     --Numero da Conta
                                   ,pr_cdbccxlt => pr_cdbccxlt     --Codigo Banco/Agencia/Caixa
                                   ,pr_nrdolote => pr_nrdolote     --Numero do Lote
                                   ,pr_tplotmov => pr_tplotmov     --Tipo Lote
                                   ,pr_cdoperad => pr_cdoperad     --Codigo Operador
                                   ,pr_dtmvtolt => pr_dtmvtlcm     --Data Movimento Atual
                                   ,pr_nrdctabb => pr_nrdctabb     --Numero Conta BB
                                   ,pr_nrdctitg => pr_nrdctitg     --Numero Conta Integracao
                                   ,pr_cdhistor => pr_cdhistor     --Codigo Historico
                                   ,pr_cdpesqbb => pr_cdpesqbb     --Codigo Pesquisa
                                   ,pr_cdbanchq => pr_cdbanchq     --Codigo Banco Cheque
                                   ,pr_cdagechq => pr_cdagechq     --Codigo Agencia Cheque
                                   ,pr_nrctachq => pr_nrctachq     --Numero Conta Cheque
                                   ,pr_flgaviso => pr_flgaviso     --Flag Aviso
                                   ,pr_cdsecext => rw_crapass.cdsecext   --Codigo Extrato Externo
                                   ,pr_tpdaviso => pr_tpdaviso     --Tipo de Aviso
                                   ,pr_vltarifa => pr_vltarifa     --Valor da Tarifa
                                   ,pr_nrdocmto => pr_nrdocmto     --Numero do Documento
                                   ,pr_cdageass => rw_crapass.cdagenci   --Codigo Agencia Associado
                                   ,pr_cdcoptfn => pr_cdcoptfn     --Codigo Cooperativa do Terminal
                                   ,pr_cdagetfn => pr_cdagetfn     --Codigo Agencia do Terminal
                                   ,pr_nrterfin => pr_nrterfin     --Numero do Terminal
                                   ,pr_nrsequni => pr_nrsequni     --Numero Sequencial Unico
                                   ,pr_nrautdoc => pr_nrautdoc     --Numero da Autenticacao do Documento
                                   ,pr_dsidenti => pr_dsidenti     --Descricao da Identificacao
                                   ,pr_inproces => pr_inproces     --Indicador do Processo
                                   ,pr_tab_erro => pr_tab_erro     --Tabela de retorno de erro
                                   ,pr_cdcritic => vr_cdcritic     --C¿digo do erro
                                   ,pr_dscritic => vr_dscritic);   --Descricao do erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Selecionar Lancamento Tarifa
      OPEN cr_craplat (pr_rowid => vr_rowid_craplat);
      --Posicionar no primeiro registro
      FETCH cr_craplat INTO rw_craplat;
      --Se nao encontrou
      IF cr_craplat%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_craplat;
        --Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Agendamento de tarifa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_craplat;

      --Atualizar tabela lancamento
      BEGIN
        UPDATE craplat SET craplat.dtefetiv = pr_dtmvtlcm
                          ,craplat.insitlat = 2  /** Efetivado **/
        WHERE craplat.ROWID = rw_craplat.ROWID;
        --Indicar que ocorreu transacao
        vr_flgtrans:= TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar tabela craplat. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
      --Retornar Codigo lancamento
      pr_cdlantar:= rw_craplat.cdlantar;

      --Se nao realizou transacao
      IF NOT vr_flgtrans THEN
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          vr_dscritic:= 'Erro no lancamento da tarifa.';

          --Gerar erro
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => 1
                               ,pr_nrdcaixa => 1
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;

       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina TARI0001.pc_lan_tarifa_online. '||SQLERRM;

    END;
  END pc_lan_tarifa_online;

  /* Procedure para criar log da tarifa de cobranca */
  PROCEDURE pc_cria_log_tarifa_cobranca (pr_idtabcob IN ROWID --ROWID da Cobranca
                                        ,pr_dsmensag IN VARCHAR2 --Descricao do erro
                                        ,pr_cdcritic OUT INTEGER  --Codigo Critica
                                        ,pr_dscritic OUT VARCHAR2) IS  --Descricao Critica
    -- ........................................................................
    --
    --  Programa : pc_cria_log_tarifa_cobranca           Antigo: b1wgen0089.p/cria-log-tarifa-cobranca
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Setembro/2013.                   Ultima atualizacao: 27/09/2013
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para criar log da tarifa de cobranca
    --
    --   Atualiza¿¿o: 27/09/2013 - Conversão Oracle - Progress
    --
  BEGIN
    DECLARE
      --Cursores Locais
      CURSOR cr_crapcob (pr_rowid IN ROWID) IS
        SELECT crapcob.cdcooper
              ,crapcob.nrdconta
              ,crapcob.nrdocmto
              ,crapcob.nrcnvcob
        FROM crapcob
        WHERE crapcob.rowid = pr_rowid;
      rw_crapcob cr_crapcob%ROWTYPE;
      --Variaveis Locais
      vr_achou    BOOLEAN;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Verificar se a cobranca esta criada
      OPEN cr_crapcob (pr_rowid => pr_idtabcob);
      --Posicionar no primeiro registro
      FETCH cr_crapcob INTO rw_crapcob;
      --Se Encontrou
      vr_achou:= cr_crapcob%FOUND;
      --Fechar Cursor
      CLOSE cr_crapcob;

      --Se encontrou
      IF vr_achou THEN
        BEGIN
          INSERT INTO crapcol
            (crapcol.cdcooper
            ,crapcol.nrdconta
            ,crapcol.nrdocmto
            ,crapcol.nrcnvcob
            ,crapcol.dslogtit
            ,crapcol.cdoperad
            ,crapcol.dtaltera
            ,crapcol.hrtransa)
          VALUES
            (rw_crapcob.cdcooper
            ,rw_crapcob.nrdconta
            ,rw_crapcob.nrdocmto
            ,rw_crapcob.nrcnvcob
            ,pr_dsmensag
            ,'TARIFA'
            ,SYSDATE
            ,GENE0002.fn_busca_time);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir na crapcol. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina TARI0001.pc_cria_log_tarifa_cobranca. '||sqlerrm;
    END;
  END pc_cria_log_tarifa_cobranca;

  /* Procedure para buscar dados da tarifa */
  PROCEDURE pc_busca_dados_tarifa (pr_cdcooper  IN  INTEGER               --Codigo Cooperativa
                                  ,pr_nrdconta  IN  INTEGER               --Numero da Conta
                                  ,pr_nrconven  IN  crapcco.nrconven%TYPE --Numero Convenio
                                  ,pr_dsincide  IN  VARCHAR2              --Descricao Incidencia
                                  ,pr_cdocorre  IN  craptar.cdocorre%TYPE --Codigo Ocorrencia
                                  ,pr_cdmotivo  IN  craptar.cdmotivo%TYPE --Codigo Motivo
                                  ,pr_idtabcob  IN  ROWID                 --ROWID Cobranca
                                  ,pr_flaputar  IN  NUMBER DEFAULT 0      --Flag (0/1) para indicar que haverá apuração desta tarifa
                                  ,pr_cdhistor  OUT INTEGER               --Codigo Historico
                                  ,pr_cdhisest  OUT INTEGER               --Historico Estorno
                                  ,pr_vltarifa  OUT NUMBER                --Valor Tarifa
                                  ,pr_dtdivulg  OUT DATE                  --Data Divulgacao
                                  ,pr_dtvigenc  OUT DATE                  --Data Vigencia
                                  ,pr_cdfvlcop  OUT INTEGER               --Codigo Cooperativa
                                  ,pr_cdcritic  OUT INTEGER               --Codigo Critica
                                  ,pr_dscritic  OUT VARCHAR2              --Descricao Critica
                                  ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS --Tabela erros
    -- ........................................................................
    --
    --  Programa : pc_busca_dados_tarifa           Antigo: b1wgen0089.p/busca_dados_tarifa
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Setembro/2013.                   Ultima atualizacao: 15/02/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para buscar dados da tarifa cobranca
    --
    --   Atualizacao: 27/09/2013 - Conversão Oracle - Progress
    --
    --                09/05/2014 - Ajustado para somente buscar tarifa se for inpessoa <> 3 (sem fins lucartivos) (Odirlei/AMcom)
    --
    --                15/02/2016 - Inclusao do parametro conta na chamada da
    --                             TARI0001.pc_carrega_dados_tarifa_cobr. (Jaison/Marcos)
    --
    --.........................................................................

  BEGIN
    DECLARE
      --Variaveis Locais
      vr_inpessoa crapass.inpessoa%type;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Limpar tabela erro
      pr_tab_erro.DELETE;

      /* Assume como padrao pessoa juridica*/
      vr_inpessoa:= 2;

      --Verificar Associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      --Posicionar primeiro registro
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrou
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        --Mensagem erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Associado nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Tipo de pessoa
        vr_inpessoa:= rw_crapass.inpessoa;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;

      --Zerar valores de retorno
      pr_vltarifa:= 0;
      pr_cdhistor:= 0;
      pr_cdfvlcop:= 0;

      --só buscar tarifa se for inpessoa <> 3(sem fins lucartivos)
      -- se for 3 pr_vltarifa ficará zero
      IF vr_inpessoa <> 3 THEN

        --Buscar dados tarifa cobranca
        TARI0001.pc_carrega_dados_tarifa_cobr (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                              ,pr_nrdconta  => pr_nrdconta  --Numero Conta
                                              ,pr_nrconven  => pr_nrconven  --Numero Convenio
                                              ,pr_dsincide  => pr_dsincide  --Descricao Incidencia
                                              ,pr_cdocorre  => pr_cdocorre  --Codigo Ocorrencia
                                              ,pr_cdmotivo  => pr_cdmotivo  --Codigo Motivo
                                              ,pr_inpessoa  => vr_inpessoa  --Tipo Pessoa
                                              ,pr_vllanmto  => 1            --Valor Lancamento
                                              ,pr_cdprogra  => NULL         --Nome Programa
                                              ,pr_flaputar  => pr_flaputar  --Apuração Sim/Não
                                              ,pr_cdhistor  => pr_cdhistor  --Codigo Historico
                                              ,pr_cdhisest  => pr_cdhisest  --Historico Estorno
                                              ,pr_vltarifa  => pr_vltarifa  --Valor Tarifa
                                              ,pr_dtdivulg  => pr_dtdivulg  --Data Divulgacao
                                              ,pr_dtvigenc  => pr_dtvigenc  --Data Vigencia
                                              ,pr_cdfvlcop  => pr_cdfvlcop  --Codigo Faixa
                                              ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                              ,pr_dscritic  => vr_dscritic); --Descricao Critica
        --Se ocorrer erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --verificar o erro e criar log
          IF pr_tab_erro.COUNT > 0 THEN
            --Criar log tarifa
            TARI0001.pc_cria_log_tarifa_cobranca (pr_idtabcob => pr_idtabcob --ROWID da Cobranca
                                                 ,pr_dsmensag => pr_tab_erro(pr_tab_erro.FIRST).dscritic --Descricao do erro
                                                 ,pr_cdcritic => vr_cdcritic    --Codigo Critica
                                                 ,pr_dscritic => vr_dscritic);  --Descricao Critica)
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;
      END IF; -- FIM IF inpessoa <> 3

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina TARI0001.pc_busca_dados_tarifa. '||sqlerrm;
    END;
  END pc_busca_dados_tarifa;

  /* Procedure para buscar tarifa vigente */
    PROCEDURE pc_carrega_par_tarifa_vigente (pr_cdcooper  IN  INTEGER                   --Codigo Cooperativa
                                            ,pr_cdbattar  IN VARCHAR2                   --Sigla da Tarifa
                                            ,pr_dsconteu  OUT VARCHAR2                  --Descricao do parametro de tarifa
                                            ,pr_cdcritic  OUT INTEGER                   --Codigo Critica
                                            ,pr_dscritic  OUT VARCHAR2                  --Descricao Critica
                                            ,pr_des_erro  OUT VARCHAR2 --Indicador de erro OK/NOK
                                            ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS --Tabela erros
    -- ........................................................................
    --
    --  Programa : pc_carrega_par_tarifa_vigente           Antigo: b1wgen0153.p/carrega_par_tarifa_vigente
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Jean Michel - CECRED
    --  Data     : Novembro/2013.                   Ultima atualizacao: 23/10/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure responsavel por carregar parametros da tarifa vigente
    --
    --   Atualizacao: 21/11/2013 - Conversão Oracle - Progress
    --
    --                23/10/2018 - Padrões: Others, Modulo/Action, PC Internal Exception, PC Log Programa
    --                             SELECT's, Parâmetros, troca de mensagens por código                             
    --                             (Envolti - Belli - REQ0011726)
    --
  BEGIN
    DECLARE

      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      -- Variaveis de Log e Modulo - 23/10/2018 - REQ0011726
      vr_dsparame VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
      vr_nmrotpro VARCHAR2  (100) := 'pc_carrega_par_tarifa_vigente';
      vr_cdproint VARCHAR2  (100);
    BEGIN
      -- Posiciona procedure - 23/10/2018 - REQ0011726
      vr_cdproint := vr_cdproexe||'.'||vr_nmrotpro;
      -- Inclusão do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);    
      vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                     ', pr_cdbattar:' || pr_cdbattar; 
      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Verificar tarifas referentes ao processo
      OPEN cr_crapbat(pr_cdbattar => pr_cdbattar);
      --Posicionar primeiro registro
      FETCH cr_crapbat INTO rw_crapbat;
      --Se nao encontrou
      IF cr_crapbat%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapbat;
        --Mensagem erro
        vr_cdcritic := 1393; -- Sigla do parametro nao cadastrado
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);	

        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Variavel de retorno
        pr_des_erro:= 'NOK';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crapbat%ISOPEN THEN
        CLOSE cr_crapbat;
      END IF;

      --Verificar tarifas por cooperativa
      OPEN cr_crappco(pr_cdcooper => pr_cdcooper           -- Codigo da cooperativa
                     ,pr_cdcadast => rw_crapbat.cdcadast); -- Codigo do cadastro
      --Posicionar primeiro registro
      FETCH cr_crappco INTO rw_crappco;
      --Se encontrou
      IF cr_crappco%FOUND THEN
        pr_dsconteu := rw_crappco.dsconteu;
      ELSE
        --Fechar Cursor
        CLOSE cr_crappco;
        --Mensagem erro
        vr_cdcritic := 1398; -- Conteudo do parametro nao encontrado
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);	

        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Variavel de retorno
        pr_des_erro:= 'NOK';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crappco%ISOPEN THEN
        CLOSE cr_crappco;
      END IF;
      -- Limpa do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);   

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic; 
        -- Controlar geração de log de execução dos jobs   
        tari0001.pc_log(pr_cdcooper => pr_cdcooper
                       ,pr_dscritic => vr_dscritic         ||
                                       ' '  || vr_nmrotpro || 
                                       '. ' || vr_dsparame
                       ,pr_cdcritic => pr_cdcritic);    
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       ' '  || vr_nmrotpro || 
                       ' '  || SQLERRM     ||
                       '. ' || vr_dsparame; 
        -- Controlar geração de log de execução dos jobs   
        tari0001.pc_log(pr_cdcooper => pr_cdcooper
                       ,pr_dscritic => pr_dscritic
                       ,pr_cdcritic => pr_cdcritic); 
        pr_cdcritic := 1224; --Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);     
    END;

  END pc_carrega_par_tarifa_vigente;


  PROCEDURE  pc_taa_lancamento_tarifas_ext(pr_cdcooper        IN  crapcop.cdcooper%TYPE, 
                                           pr_cdcoptfn        IN  craplcm.cdcoptfn%TYPE, 
                                           pr_tpextrat        IN  crapext.tpextrat%TYPE,
                                           pr_insitext        IN  VARCHAR2,
                                           pr_dtmvtoin        IN  DATE,
                                           pr_dtmvtofi        IN  DATE,
                                           pr_cdtplanc        IN  PLS_INTEGER,
                                           pr_dscritic        OUT VARCHAR2,
                                           pr_tab_lancamentos OUT cada0001.typ_tab_lancamentos) IS
    -- ........................................................................
    --
    --  Programa : pc_taa_lancamento_tarifas_ext           Antigo: b1wgen0025.p/taa_lancamento_tarifas_ext
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Andrino Carlos de Souza Junior - RKAM
    --  Data     : 07/05/2014.                      Ultima atualizacao: 23/10/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Consulta por:                                       
    --                 Saques feitos no meu TAA por outras Coops (pr_cdcoptfn <> 0)     
    --                 Saques feitos por meus Assoc. em outras Coops (pr_cdcooper <> 0) 
    --                
    --   Atualizacao:    
    --     23/10/2018 - Padrões: Others, Modulo/Action, PC Internal Exception, PC Log Programa                          
    --                 (Envolti - Belli - REQ0011726)           
    --                
    -- Cursor sobre os arquivos de contas que deverao ter seus extratos impressos
    CURSOR cr_crapext(pr_insitext crapext.insitext%TYPE) IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             count(*) qtdmovto
        FROM crapext
       WHERE crapext.cdcoptfn =  pr_cdcoptfn
         AND crapext.tpextrat =  pr_tpextrat
         AND crapext.insitext =  nvl(pr_insitext,crapext.insitext)
         AND crapext.dtreffim >= pr_dtmvtoin 
         AND crapext.dtreffim <= pr_dtmvtofi
         AND crapext.cdcooper <> crapext.cdcoptfn
       GROUP BY cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta;

    -- Cursor sobre os arquivos de contas que deverao ter seus extratos impressos
    CURSOR cr_crapext_2(pr_insitext crapext.insitext%TYPE) IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             count(*) qtdmovto
        FROM crapext
       WHERE crapext.cdcooper =  pr_cdcooper
         AND crapext.tpextrat =  pr_tpextrat
         AND crapext.insitext =  nvl(pr_insitext,crapext.insitext)
         AND crapext.dtreffim >= pr_dtmvtoin 
         AND crapext.dtreffim <= pr_dtmvtofi
         AND crapext.cdcooper <> crapext.cdcoptfn
         AND crapext.cdcoptfn <> 0
       GROUP BY cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta;

    -- Variaveis gerais
    vr_ind           VARCHAR2(38);              --> Indice da Pl_table pr_tab_lancamentos
    vr_dstplanc      VARCHAR2(25);              --> Destino de plano de contas
    vr_insitext      crapext.insitext%TYPE;     --> Situacao do extrato
    vr_insitext_tmp  VARCHAR2(400);             --> Situacoes dos extratos passados como parametro
    -- Variaveis de Log e Modulo - 23/10/2018 - REQ0011726
    vr_dsparame VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotpro VARCHAR2  (100) := 'pc_taa_lancamento_tarifas_ext';
    vr_cdproint VARCHAR2  (100);
  BEGIN
    -- Posiciona procedure - 23/10/2018 - REQ0011726
    vr_cdproint := vr_cdproexe||'.'||vr_nmrotpro;
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);    
    vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                   ', pr_cdcoptfn:' || pr_cdcoptfn ||
                   ', pr_tpextrat:' || pr_tpextrat ||
                   ', pr_insitext:' || pr_insitext ||
                   ', pr_dtmvtoin:' || pr_dtmvtoin ||
                   ', pr_dtmvtofi:' || pr_dtmvtofi ||
                   ', pr_cdtplanc:' || pr_cdtplanc;   
    --Inicializar parametros erro
    pr_dscritic:= NULL;
    
    -- Limpa a tabela temporaria
    pr_tab_lancamentos.delete;

    CASE pr_cdtplanc
      WHEN  5 THEN vr_dstplanc := 'Consulta de Saldo';
      WHEN  6 THEN vr_dstplanc := 'Consulta de Saldo';
      WHEN  7 THEN vr_dstplanc := 'Impressao de Saldo';
      WHEN  8 THEN vr_dstplanc := 'Impressao de Saldo';
      WHEN  9 THEN vr_dstplanc := 'Impressao de Extrato';
      WHEN 10 THEN vr_dstplanc := 'Impressao de Extrato';
      WHEN 11 THEN vr_dstplanc := 'Imp. Extr. Aplicacao';
      WHEN 12 THEN vr_dstplanc := 'Imp. Extr. Aplicacao';
      WHEN 13 THEN vr_dstplanc := 'Consulta de Agendamento';
      WHEN 14 THEN vr_dstplanc := 'Consulta de Agendamento';
      WHEN 15 THEN vr_dstplanc := 'Exclusao de Agendamento';
      WHEN 16 THEN vr_dstplanc := 'Exclusao de Agendamento';
      WHEN 23 THEN vr_dstplanc := 'Impressao comprovantes';
      WHEN 24 THEN vr_dstplanc := 'Impressao comprovantes';
    END CASE;

    vr_insitext_tmp := pr_insitext;
    LOOP
      -- Verifica se existe mais de uma situacao de extrato 
      IF instr(vr_insitext_tmp,',') <> 0 THEN
        vr_insitext     := substr(vr_insitext_tmp,1,instr(vr_insitext_tmp,',')-1);
        vr_insitext_tmp := substr(vr_insitext_tmp,instr(vr_insitext_tmp,',')+1);
      ELSE
        vr_insitext     := vr_insitext_tmp;
        vr_insitext_tmp := NULL;
      END IF;

      -- Saques feitos no meu TAA por outras Coops
      IF pr_cdcoptfn <> 0 THEN

        -- Efetua loop sobre os extratos impressos automaticamente
        FOR rw_crapext IN cr_crapext(vr_insitext) LOOP

          -- Atualiza o indice
          vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_crapext.cdcooper,10,'0')||lpad(rw_crapext.cdcoptfn,10,'0')||
                    lpad(rw_crapext.cdagetfn,5,'0') ||lpad(rw_crapext.nrdconta,10,'0');
              
          -- Atualiza a temp-table de retorno
          pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
          pr_tab_lancamentos(vr_ind).cdcooper := rw_crapext.cdcooper;
          pr_tab_lancamentos(vr_ind).cdcoptfn := rw_crapext.cdcoptfn;
          pr_tab_lancamentos(vr_ind).cdagetfn := rw_crapext.cdagetfn;
          pr_tab_lancamentos(vr_ind).nrdconta := rw_crapext.nrdconta;
          pr_tab_lancamentos(vr_ind).qtdecoop := 1;
          pr_tab_lancamentos(vr_ind).dstplanc := vr_dstplanc;
          pr_tab_lancamentos(vr_ind).tpconsul := 'TAA';
          pr_tab_lancamentos(vr_ind).qtdmovto := rw_crapext.qtdmovto;
        
        END LOOP;
         
      END IF; /* END do IF pr_cdcoptfn */
      
      IF pr_cdcooper <> 0 THEN

        -- Efetua loop sobre os extratos impressos automaticamente
        FOR rw_crapext IN cr_crapext_2(vr_insitext) LOOP

          -- Atualiza o indice
          vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_crapext.cdcooper,10,'0')||lpad(rw_crapext.cdcoptfn,10,'0')||
                    lpad(rw_crapext.cdagetfn,5,'0') ||lpad(rw_crapext.nrdconta,10,'0');
              
          -- Atualiza a temp-table de retorno
          pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
          pr_tab_lancamentos(vr_ind).cdcooper := rw_crapext.cdcooper;
          pr_tab_lancamentos(vr_ind).cdcoptfn := rw_crapext.cdcoptfn;
          pr_tab_lancamentos(vr_ind).cdagetfn := rw_crapext.cdagetfn;
          pr_tab_lancamentos(vr_ind).nrdconta := rw_crapext.nrdconta;
          pr_tab_lancamentos(vr_ind).qtdecoop := 1;
          pr_tab_lancamentos(vr_ind).dstplanc := vr_dstplanc;
          pr_tab_lancamentos(vr_ind).tpconsul := 'Outras Coop';
          pr_tab_lancamentos(vr_ind).qtdmovto := rw_crapext.qtdmovto;
        
        END LOOP;
         
      END IF; /* END do IF pr_cdcooper */
                
      -- Caso nao existir mais situacoes de extrato, sai do loop
      EXIT WHEN vr_insitext_tmp IS NULL;
    END LOOP;    
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);   
    -- Trata exceções - 23/10/2018 - REQ0011726
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
      -- Efetuar retorno do erro não tratado
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 9999) ||
                     ' '  || vr_nmrotpro || 
                     ' '  || SQLERRM     ||
                     '. ' || vr_dsparame; 
      -- Controlar geração de log de execução dos jobs   
      tari0001.pc_log(pr_cdcooper => pr_cdcooper
                     ,pr_dscritic => pr_dscritic
                     ,pr_cdcritic => 9999); 
      -- 1224 - Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1224); 
  END pc_taa_lancamento_tarifas_ext;

  PROCEDURE pc_busca_tarifa_pendente(pr_cdcooper        IN  crapcop.cdcooper%TYPE,
                                     pr_cdcopatu        IN  crapcop.cdcooper%TYPE,
                                     pr_cdagenci        IN  crapage.cdagenci%TYPE,
                                     pr_cdoperad        IN  crapope.cdoperad%TYPE,
                                     pr_inpessoa        IN  crapass.inpessoa%TYPE,
                                     pr_nrdconta        IN  crapass.nrdconta%TYPE,
                                     pr_cdhistor        IN  craphis.cdhistor%TYPE,
                                     pr_cddgrupo        IN  crapgru.cddgrupo%TYPE,
                                     pr_cdsubgru        IN  crapsgr.cdsubgru%TYPE,                        
                                     pr_dtinicio        IN  DATE,
                                     pr_dtafinal        IN  DATE,                                     
                                     pr_dscritic        OUT VARCHAR2,
                                     pr_tab_tari_pend   OUT TARI0001.typ_tab_tarifas_pend)IS
    -- ........................................................................
    --
    --  Programa : pc_busca_tarifa_pentende          
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Tiago Machado Flor
    --  Data     : 19/01/2015.                      Ultima atualizacao: -
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Consulta por:                                       
    --                 Busca tarifas pendentes de acordo com os parametros passados
    --
    --   Alteracoes: 22/06/2015 - Retirado validacao do DTDEMISS pois ainda deve gerar
    --                            tarifa (Tiago/Rodrigo).
    
    CURSOR cr_craplat(pr_dtinicio DATE,
                      pr_dtafinal DATE,
                      pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_nrdconta craplat.nrdconta%TYPE) IS
      SELECT craplat.ROWID   , craplat.cdcooper, 
             craplat.nrdconta, craplat.dtmvtolt,
             craptar.cdtarifa, craptar.dstarifa,
             craplat.vltarifa
        FROM craplat, crapfco,  
             crapfvl, craptar
       WHERE craplat.cdfvlcop = crapfco.cdfvlcop
         AND crapfco.cdfaixav = crapfvl.cdfaixav
         AND crapfvl.cdtarifa = craptar.cdtarifa
         AND craplat.cdcooper = DECODE(pr_cdcooper,0,craplat.cdcooper,pr_cdcooper)
         AND craplat.nrdconta = DECODE(pr_nrdconta,0,craplat.nrdconta,pr_nrdconta)
         AND craplat.dtmvtolt BETWEEN pr_dtinicio AND pr_dtafinal         
         AND craplat.insitlat = 1; -- Pendente
    
    -- lista de tarifas pendentes
    CURSOR cr_craplat_2(pr_tarrowid ROWID,                      
                        pr_cdagenci crapage.cdagenci%TYPE,
                        pr_inpessoa crapass.inpessoa%TYPE,                      
                        pr_cdhistor craplat.cdhistor%TYPE,
                        pr_cddgrupo crapgru.cddgrupo%TYPE,
                        pr_cdsubgru crapsgr.cdsubgru%TYPE) IS
      SELECT craplat.rowid
        FROM craplat, crapass, 
             crapfco, crapfvl, 
             craptar, crapsgr
       WHERE craplat.cdcooper = crapass.cdcooper         
         AND craplat.nrdconta = crapass.nrdconta         
         AND craplat.cdfvlcop = crapfco.cdfvlcop
         AND crapfco.cdfaixav = crapfvl.cdfaixav
         AND crapfvl.cdtarifa = craptar.cdtarifa
         AND craptar.cdsubgru = crapsgr.cdsubgru
         AND craplat.insitlat = 1 /*Pendente*/
         AND craplat.rowid    = pr_tarrowid
         AND crapass.inpessoa = DECODE(pr_inpessoa,0,crapass.inpessoa,pr_inpessoa)
         AND crapass.cdagenci = DECODE(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
         AND craplat.cdhistor = DECODE(pr_cdhistor,0,craplat.cdhistor,pr_cdhistor)
         --AND crapass.dtdemiss IS NULL         
         AND crapsgr.cddgrupo IN ( SELECT crapgru.cddgrupo 
                                     FROM crapgru
                                    WHERE crapgru.cddgrupo = DECODE(pr_cddgrupo,0,crapgru.cddgrupo,pr_cddgrupo) )
         AND crapsgr.cdsubgru = DECODE(pr_cdsubgru,0,crapsgr.cdsubgru,pr_cdsubgru);

    rw_craplat_2 cr_craplat_2%ROWTYPE;

    CURSOR cr_crapcop IS
      SELECT crapcop.cdcooper,
             crapcop.nmrescop
        FROM crapcop;       
        
    CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapass.vllimcre, crapass.cdagenci,
             crapass.nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper AND
             crapass.nrdconta = pr_nrdconta;
         
    rw_crapass cr_crapass%ROWTYPE;    

    vr_ind PLS_INTEGER;
    vr_flsalvar BOOLEAN;
    vr_tab_coop typ_tab_coop;
    vr_tab_ass  typ_tab_associado;
    vr_dscritic VARCHAR2(2000);
    -- Cursor genérico de calendário
    TYPE typ_tab_dat IS TABLE OF btch0001.cr_crapdat%ROWTYPE
    INDEX BY PLS_INTEGER;
    
    vr_tab_dat typ_tab_dat;
    
    --Obtem Saldo
    vr_tab_sald EXTR0001.typ_tab_saldos;
    
  BEGIN 
                
        IF btch0001.cr_crapdat%ISOPEN THEN
           CLOSE btch0001.cr_crapdat;
        END IF;  

        --Carregar pltable com as coops pra nao precisar fazer select na tabela depois
        FOR rw_crapcop IN cr_crapcop LOOP
          vr_tab_coop(rw_crapcop.cdcooper).nmrescop := rw_crapcop.nmrescop;
          
          -- Leitura do calendário da cooperativa
          OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
          FETCH btch0001.cr_crapdat
           INTO vr_tab_dat(rw_crapcop.cdcooper);
          -- Se não encontrar
          IF btch0001.cr_crapdat%NOTFOUND THEN
            CLOSE btch0001.cr_crapdat;
          END IF;
          
          CLOSE btch0001.cr_crapdat;
          
        END LOOP;

        -- zera o indice da tabela de retorno com as tarifas pendentes
        vr_ind := 0;
        
        FOR rw_craplat IN cr_craplat(pr_dtinicio => pr_dtinicio,
                                     pr_dtafinal => pr_dtafinal,
                                     pr_cdcooper => pr_cdcopatu,
                                     pr_nrdconta => pr_nrdconta) LOOP
          
          -- indica se vai salvar registro na pltable tarifas pend(pr_tab_tari_pend)
          vr_flsalvar := FALSE; 
                                   
          -- se nao informou filtros, nao preciso de todas estas condicoes no select da craplat
          IF pr_cdagenci > 0 OR pr_inpessoa > 0 OR
             pr_cddgrupo > 0 OR pr_cdsubgru > 0 OR
             pr_cdhistor > 0 THEN
             
             OPEN cr_craplat_2(pr_tarrowid => rw_craplat.rowid,
                               pr_cdagenci => pr_cdagenci,
                               pr_inpessoa => pr_inpessoa,
                               pr_cdhistor => pr_cdhistor,
                               pr_cddgrupo => pr_cddgrupo,
                               pr_cdsubgru => pr_cdsubgru);
                               
             FETCH cr_craplat_2 INTO rw_craplat_2;
             
             IF cr_craplat_2%NOTFOUND THEN
                CLOSE cr_craplat_2;
                CONTINUE;
             END IF;   
             
             CLOSE cr_craplat_2;
             
          END IF;   
          
          IF NOT vr_tab_ass.exists(rw_craplat.nrdconta) THEN            
           
            --Busca limite credito do cooperado
            OPEN cr_crapass(pr_cdcooper => rw_craplat.cdcooper,                          
                            pr_nrdconta => rw_craplat.nrdconta);
               
            FETCH cr_crapass INTO rw_crapass;
               
            IF cr_crapass%NOTFOUND THEN
               CLOSE cr_crapass;
               CONTINUE;
            END IF;   
               
            CLOSE cr_crapass;          
            
            vr_tab_ass(rw_craplat.nrdconta).nrdconta := rw_craplat.nrdconta;
            vr_tab_ass(rw_craplat.nrdconta).cdagenci := rw_crapass.cdagenci;
            vr_tab_ass(rw_craplat.nrdconta).nmprimtl := rw_crapass.nmprimtl;
            vr_tab_ass(rw_craplat.nrdconta).flgsaldo := FALSE;
            
            --verificar se o cooperado possui lançamento de credito e saldo positivo
            pc_verifica_credito (pr_cdcooper => rw_craplat.cdcooper,                      --> Codigo da cooperativa    
                                 pr_nrdconta => rw_craplat.nrdconta,                      --> Numero da conta do cooperaro
                                 pr_vllimcre => rw_crapass.vllimcre,                      --> limite de credito do cooperado
                                 pr_rcrapdat => vr_tab_dat(rw_craplat.cdcooper),          --> data da cooperativa 
                                 pr_flgvflcm => TRUE,                                     --> flag de controle se deve verificar lançamentos de credito 
                                 pr_flgvfsld => TRUE,                                     --> flag de controle se deve verificar saldo do cooperado
                                 --- out ---                                              
                                 pr_fposcred => vr_tab_ass(rw_craplat.nrdconta).flgsaldo, --> Retorna flag se cooperado possui credito
                                 pr_tab_sald => vr_tab_sald,                              --> Retorna saldo do cooperado
                                 pr_dscritic => vr_dscritic);                             --> Retorna critica
            
            -- atribui valor para a variavel de controle
            vr_flsalvar := vr_tab_ass(rw_craplat.nrdconta).flgsaldo;
                                     
          ELSE
            IF vr_tab_ass(rw_craplat.nrdconta).flgsaldo THEN
               vr_flsalvar := TRUE;
            END IF;   
          END IF;    

          IF vr_flsalvar THEN
            -- Atualiza o indice
            vr_ind := vr_ind + 1;
              
            -- Atualiza a temp-table de retorno
            pr_tab_tari_pend(vr_ind).cdtarifa := rw_craplat.cdtarifa; 
            pr_tab_tari_pend(vr_ind).cdcooper := rw_craplat.cdcooper;
            pr_tab_tari_pend(vr_ind).nmrescop := vr_tab_coop(rw_craplat.cdcooper).nmrescop;
            pr_tab_tari_pend(vr_ind).cdagenci := vr_tab_ass(rw_craplat.nrdconta).cdagenci; 
            pr_tab_tari_pend(vr_ind).nrdconta := rw_craplat.nrdconta;
            pr_tab_tari_pend(vr_ind).nmprimtl := vr_tab_ass(rw_craplat.nrdconta).nmprimtl; 
            pr_tab_tari_pend(vr_ind).dtmvtolt := rw_craplat.dtmvtolt;
            pr_tab_tari_pend(vr_ind).dstarifa := rw_craplat.dstarifa;
            pr_tab_tari_pend(vr_ind).vltarifa := rw_craplat.vltarifa;
            pr_tab_tari_pend(vr_ind).tarrowid := rw_craplat.rowid;

          END IF;
          
        END LOOP;                             

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na TARI0001.pc_busca_tarifa_pendente_v2: '||SQLerrm;
  END pc_busca_tarifa_pendente;  

  PROCEDURE pc_busca_tarifa_pend_web(pr_cdcooper IN  crapcop.cdcooper%TYPE 
                                    ,pr_cdcopatu IN  crapcop.cdcooper%TYPE 
                                    ,pr_cdagenci IN  crapage.cdagenci%TYPE
                                    ,pr_cdoperad IN  crapope.cdoperad%TYPE
                                    ,pr_inpessoa IN  crapass.inpessoa%TYPE
                                    ,pr_nrdconta IN  crapass.nrdconta%TYPE
                                    ,pr_cdhistor IN  craphis.cdhistor%TYPE
                                    ,pr_cddgrupo IN  crapgru.cddgrupo%TYPE
                                    ,pr_cdsubgru IN  crapsgr.cdsubgru%TYPE                                    
                                    ,pr_dtinicio IN  VARCHAR2
                                    ,pr_dtafinal IN  VARCHAR2                                                                          
                                    ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    -- ........................................................................
    --
    --  Programa : pc_busca_tarifa_pentende          
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Tiago Machado Flor
    --  Data     : 19/01/2015.                      Ultima atualizacao: -
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Consulta por:                                       
    --                 Busca tarifas pendentes de acordo com os parametros passados
    --
    --.............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_contador PLS_INTEGER := 0;
      vr_auxconta PLS_INTEGER := 0;
      vr_vltottar NUMBER(25,2):= 0;

      -- Temp Table
      vr_tab_tari_pend TARI0001.typ_tab_tarifas_pend;
      
      vr_dtinicio DATE;
      vr_dtafinal DATE;            
  BEGIN 
      vr_dtinicio := to_DATE(pr_dtinicio,'dd/mm/RRRR');      
      vr_dtafinal := to_DATE(pr_dtafinal,'dd/mm/RRRR');

      -- Leitura 
      TARI0001.pc_busca_tarifa_pendente(pr_cdcooper      =>  pr_cdcooper, 
                                        pr_cdcopatu      =>  pr_cdcopatu,
                                        pr_cdagenci      =>  pr_cdagenci,
                                        pr_cdoperad      =>  pr_cdoperad,
                                        pr_inpessoa      =>  pr_inpessoa,
                                        pr_nrdconta      =>  pr_nrdconta,
                                        pr_cdhistor      =>  pr_cdhistor,
                                        pr_cddgrupo      =>  pr_cddgrupo,
                                        pr_cdsubgru      =>  pr_cdsubgru,                                        
                                        pr_dtinicio      =>  vr_dtinicio,
                                        pr_dtafinal      =>  vr_dtafinal,                                     
                                        pr_dscritic      =>  vr_dscritic,
                                        pr_tab_tari_pend =>  vr_tab_tari_pend);
                                        
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      IF vr_tab_tari_pend.COUNT() = 0 THEN
         vr_dscritic := 'Nao foram encontradas tarifas pendentes possiveis de debito.';
         RAISE vr_exc_saida;
      END IF;  
      

      IF vr_tab_tari_pend.count() > 0 THEN
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        -- Leitura da tabela temporaria para retornar XML para a WEB
        FOR vr_contador IN vr_tab_tari_pend.FIRST..vr_tab_tari_pend.LAST LOOP

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdtarifa', pr_tag_cont => TO_CHAR(vr_tab_tari_pend(vr_contador).cdtarifa ), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdcooper', pr_tag_cont => TO_CHAR(vr_tab_tari_pend(vr_contador).cdcooper ), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmrescop', pr_tag_cont => vr_tab_tari_pend(vr_contador).nmrescop          , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdagenci', pr_tag_cont => TO_CHAR(vr_tab_tari_pend(vr_contador).cdagenci ), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta', pr_tag_cont => gene0002.fn_mask_conta(pr_nrdconta => vr_tab_tari_pend(vr_contador).nrdconta), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmprimtl', pr_tag_cont => vr_tab_tari_pend(vr_contador).nmprimtl          , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(vr_tab_tari_pend(vr_contador).dtmvtolt,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dstarifa', pr_tag_cont => vr_tab_tari_pend(vr_contador).dstarifa          , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vltarifa', pr_tag_cont => TO_CHAR(vr_tab_tari_pend(vr_contador).vltarifa,'fm9G90D00'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'rowid', pr_tag_cont => TO_CHAR(vr_tab_tari_pend(vr_contador).tarrowid ), pr_des_erro => vr_dscritic);

          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;
          vr_vltottar := vr_vltottar + vr_tab_tari_pend(vr_contador).vltarifa;
        END LOOP;
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados',  pr_posicao => 0, pr_tag_nova => 'resumo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'resumo', pr_posicao => 0, pr_tag_nova => 'vltottar', pr_tag_cont => TO_CHAR(vr_vltottar,'fm999G990D00'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'resumo', pr_posicao => 0, pr_tag_nova => 'qtregtar', pr_tag_cont => TO_CHAR(vr_auxconta,'fm9G9000'), pr_des_erro => vr_dscritic);

      ELSE
        vr_dscritic := 'Nao foram encontradas tarifas pendentes possiveis de debito.';
        RAISE vr_exc_saida;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TARI0001.pc_busca_tarifa_pend_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_tarifa_pend_web;
  
  -- Rotina para gerar impressao das efetivacoes das tarifas pendentes crrl684
  PROCEDURE pc_imprimir_tarifa_pend(pr_cdcooper        IN crapcop.cdcooper%TYPE
                                   ,pr_tab_tari_pend   IN  TARI0001.typ_tab_tarifas_pend
                                   ,pr_nmarqpdf        OUT Varchar2             --> Arquivo PDF
                                   ,pr_cdcritic        OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic        OUT VARCHAR2) IS
  BEGIN

    /* .............................................................................

     Programa: pc_imprimir_tarifa_pend
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Tiago Machado Flor
     Data    : Fevereiro/15.                    Ultima atualizacao: 26/02/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para gerar impressao das tarifas pendentes que foram processadas.
     Observacao: -----

     Alteracoes: -----
     ..............................................................................*/
    DECLARE

      vr_xml           CLOB;            --> CLOB com conteudo do XML do relatório
      vr_xmlbuffer     VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
      vr_strbuffer     VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
      
      -- Variaveis para a geracao do relatorio
      vr_nom_direto    VARCHAR2(500);
      vr_nmarqimp      VARCHAR2(100);
      -- contador de controle
      vr_indice     PLS_INTEGER;

      vr_qttardeb PLS_INTEGER;
      vr_vltardeb NUMBER(25,2);
      vr_qttarndb PLS_INTEGER;
      vr_vltarndb NUMBER(25,2);

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_des_reto VARCHAR2(10);
      vr_typ_saida VARCHAR2(3);
      vr_tab_erro gene0001.typ_tab_erro;
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN
      --Posicionar no primeiro registro da tabela
      vr_indice:= pr_tab_tari_pend.FIRST;
      -- Inicializar XML do relatório
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

      vr_strbuffer := '<?xml version="1.0" encoding="utf-8"?><crrl698><tarifas>';
      
      -- Enviar ao CLOB
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xmlbuffer
                             ,pr_texto_novo     => vr_strbuffer);
      -- Limpar a auxiliar
      vr_strbuffer := NULL;

      vr_qttardeb := 0;
      vr_vltardeb := 0;
      vr_qttarndb := 0;
      vr_vltarndb := 0;
      
      --Percorrer as tarifas encontradas
      WHILE vr_indice IS NOT NULL LOOP
        
        vr_strbuffer := vr_strbuffer
                     || '<registro>'
                     ||   '<nmrescop>'||pr_tab_tari_pend(vr_indice).nmrescop||'</nmrescop>'                     
                     ||   '<cdagenci>'||to_char(pr_tab_tari_pend(vr_indice).cdagenci)||'</cdagenci>'
                     ||   '<nrdconta>'||TRIM(gene0002.fn_mask_conta(pr_tab_tari_pend(vr_indice).nrdconta))||'</nrdconta>'
                     ||   '<nmprimtl>'||pr_tab_tari_pend(vr_indice).nmprimtl||'</nmprimtl>'
                     ||   '<dtmvtolt>'||to_char(pr_tab_tari_pend(vr_indice).dtmvtolt,'DD/MM/RRRR')||'</dtmvtolt>'
                     ||   '<dstarifa>'||pr_tab_tari_pend(vr_indice).dstarifa||'</dstarifa>'
                     ||   '<vltarifa>'||TO_CHAR(pr_tab_tari_pend(vr_indice).vltarifa,'fm9G990D00')||'</vltarifa>'
                     ||   '<dsstatus>'||pr_tab_tari_pend(vr_indice).dsstatus||'</dsstatus>'
                     ||   '<cdoperad>'||pr_tab_tari_pend(vr_indice).cdoperad||'</cdoperad>'
                     || '</registro>';
                
        -- Enviar ao CLOB
        gene0002.pc_escreve_xml(pr_xml            => vr_xml
                               ,pr_texto_completo => vr_xmlbuffer
                               ,pr_texto_novo     => vr_strbuffer);
        -- Limpar a auxiliar
        vr_strbuffer := NULL;
        
        IF pr_tab_tari_pend(vr_indice).dsstatus = 'OK' THEN
           vr_qttardeb := vr_qttardeb + 1;
           vr_vltardeb := vr_vltardeb + pr_tab_tari_pend(vr_indice).vltarifa;
        ELSE
           vr_qttarndb := vr_qttarndb + 1;
           vr_vltarndb := vr_vltarndb + pr_tab_tari_pend(vr_indice).vltarifa;
        END IF;   
          
        vr_indice  := pr_tab_tari_pend.NEXT(vr_indice);        
      END LOOP; -- FIM WHILE

      -- Inicializar tag empresa
      vr_strbuffer := vr_strbuffer
                   || '</tarifas><sumario>'
                   ||   '<qttardeb>'||TO_CHAR(vr_qttardeb)||'</qttardeb>'
                   ||   '<vltardeb>'||TO_CHAR(vr_vltardeb,'fm9G990D00')||'</vltardeb>'
                   ||   '<qttarndb>'||TO_CHAR(vr_qttarndb)||'</qttarndb>'
                   ||   '<vltarndb>'||TO_CHAR(vr_vltarndb,'fm9G990D00')||'</vltarndb>'
                   || '</sumario></crrl698>';

      -- Enviar ao CLOB
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xmlbuffer
                             ,pr_texto_novo     => vr_strbuffer
                             ,pr_fecha_xml      => TRUE); --> Ultima chamada);

      -- Busca do diretório base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper   
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      -- Definir nome do relatorio
      vr_nmarqimp   := 'crrl698_'||to_char(gene0002.fn_busca_time())||'.pdf';

      -- Solicitar geração do relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => 'DEBTAR'                             --> Programa chamador
                                 ,pr_dtmvtolt  => SYSDATE                              --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml                               --> Arquivo XML de dados
                                 ,pr_dsxmlnode => 'crrl698/tarifas/registro'           --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl698.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nmarqimp      --> Arquivo final com o path
                                 ,pr_cdrelato  => 698
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'S'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'N'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
      -- Tratar erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        raise vr_exc_saida;
      END IF;

      -- Enviar relatorio para intranet
      gene0002.pc_efetua_copia_pdf
                            (pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                            ,pr_cdagenci => 1             --> Codigo da agencia para erros
                            ,pr_nrdcaixa => 100           --> Codigo do caixa para erros
                            ,pr_nmarqpdf => vr_nom_direto||'/'||vr_nmarqimp --> Arquivo PDF  a ser gerado
                            ,pr_des_reto => vr_des_reto    --> Saída com erro
                            ,pr_tab_erro => vr_tab_erro);  --> tabela de erros

      -- caso apresente erro na operação
      IF nvl(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Remover relatorio da pasta rl apos gerar
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_nom_direto||'/'||vr_nmarqimp
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;


      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml);
      dbms_lob.freetemporary(vr_xml);
      
      pr_nmarqpdf := vr_nmarqimp;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Geracao Relatorio: ' || SQLERRM;

        ROLLBACK;
    END;

  END pc_imprimir_tarifa_pend;
  
  PROCEDURE pc_debita_tarifa_online(pr_cdcooper        IN  crapcop.cdcooper%TYPE,
                                    pr_cdoperad        IN  crapope.cdoperad%TYPE,
                                    pr_idorigem        IN  PLS_INTEGER,
                                    pr_nmdatela        IN  VARCHAR2,
                                    pr_listalat        IN  CLOB,
                                    pr_flimprim        IN  PLS_INTEGER DEFAULT 0,
                                    pr_nmarqpdf        OUT VARCHAR2,
                                    pr_dscritic        OUT VARCHAR2,
                                    pr_tab_tari_pend   IN OUT TARI0001.typ_tab_tarifas_pend)IS
    -- .......................................................................................
    --
    --  Programa : pc_debita_tarifa_online
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Tiago Machado Flor
    --  Data     : 30/01/2015.                      Ultima atualizacao: -
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  :   Realiza os lancamentos das tarifas pendentes 
    --                 de acordo com os parametros passados
    /*
	Alteracoes: 10/04/2018 - Alterado para incluir o débito Parcial (Elton Giusti)
	*/
    -- .......................................................................................
  BEGIN
    DECLARE
       CURSOR cr_craplat(pr_rowid IN ROWID) IS
         SELECT craplat.rowid, craplat.*
           FROM craplat
          WHERE craplat.rowid = pr_rowid;
          
       rw_craplat cr_craplat%ROWTYPE;
       
       CURSOR cr_craptar(pr_rowid IN ROWID) IS
         SELECT lat.cdcooper, tar.dstarifa, 
                lat.vltarifa, tar.cdtarifa,
                cop.nmrescop 
           FROM craptar tar, craplat lat, 
                crapfvl fvl, crapfco fco,
                crapcop cop
          WHERE fvl.cdfaixav = fco.cdfaixav
            AND fco.cdfvlcop = lat.cdfvlcop
            AND fvl.cdtarifa = tar.cdtarifa
            AND lat.cdcooper = cop.cdcooper
            AND lat.rowid    = pr_rowid;
           
       rw_craptar cr_craptar%ROWTYPE;
       
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;
                     
       vr_tab_sald EXTR0001.typ_tab_saldos;
       vr_tab_erro GENE0001.typ_tab_erro;
       vr_tab_ctassld typ_tab_conta_ssaldo;
       
       vr_listalat gene0002.typ_split := gene0002.typ_split();   
       vr_indice   PLS_INTEGER;
       vr_ind_tari PLS_INTEGER := 0;
       vr_nrdrowid ROWID;
       vr_dsorigem VARCHAR2(500) := 'AIMARO,CAIXA,INTERNET,TAA,AIMARO WEB,URA';
       vr_fposcred BOOLEAN;
       
       vr_dscritic VARCHAR2(4000);       
       vr_cdcritic PLS_INTEGER;
              
       vr_vlpendente craplat.vltarifa%TYPE;
	   vr_intipoope INTEGER;

			--Rowid lancamento tarifa efetivada
      vr_rowid_craplat_new ROWID;
              
       --Variaveis de Excecao
       vr_exc_erro EXCEPTION;

      vr_tab_erro_tar GENE0001.typ_tab_erro;

    BEGIN
      
      IF pr_listalat IS NOT NULL THEN
        vr_listalat := gene0002.fn_quebra_string(pr_string => pr_listalat, pr_delimit => ';');
      ELSE
        vr_indice := pr_tab_tari_pend.FIRST;
         
        WHILE vr_indice IS NOT NULL LOOP   
          vr_listalat.EXTEND;        
          vr_listalat(vr_indice) :=  pr_tab_tari_pend(vr_indice).tarrowid;
          vr_indice := pr_tab_tari_pend.NEXT(vr_indice);  
        END LOOP;
        
        pr_tab_tari_pend.delete;
        
      END IF;   
               
      --Posicionar no primeiro registro da tabela
      vr_indice:= vr_listalat.FIRST;
      vr_ind_tari:= pr_tab_tari_pend.COUNT() + 1;
      
      --Percorrer as tarifas encontradas
      WHILE vr_indice IS NOT NULL LOOP
        
        OPEN cr_craplat(vr_listalat(vr_indice));
        --Posicionar no proximo registro
        FETCH cr_craplat INTO rw_craplat;
        --Se nao encontrar
        IF cr_craplat%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_craplat;
          
          --ERRO nao achou rowid
          -- log na lgm nao encontrado
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => 'ERRO ROWID'
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => '' 
                              ,pr_dttransa => SYSDATE
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => pr_nmdatela 
                              ,pr_nrdconta => 0 
                              ,pr_nrdrowid => vr_nrdrowid);
          /*
          pr_tab_tari_pend(vr_ind_tari).cdcooper := rw_craplat.cdcooper;
          pr_tab_tari_pend(vr_ind_tari).tarrowid := rw_craplat.rowid;
          pr_tab_tari_pend(vr_ind_tari).vltarifa := rw_craplat.vltarifa;
          pr_tab_tari_pend(vr_ind_tari).dsstatus := 'ERRO ROWID';
          
          vr_ind_tari:= pr_tab_tari_pend.COUNT() + 1;  erro */
          vr_indice  := vr_listalat.NEXT(vr_indice);
          
          CONTINUE;
        END IF;

        --Fechar Cursor
        CLOSE cr_craplat;
        
        -- Se encontrar na lista de contas sem saldo nao continua
        -- o processo
        IF vr_tab_ctassld.exists(rw_craplat.nrdconta) THEN
           vr_indice  := vr_listalat.NEXT(vr_indice);
           CONTINUE;
        END IF;
        
        OPEN cr_craptar(rw_craplat.rowid);
        --Posicionar no proximo registro
        FETCH cr_craptar INTO rw_craptar;
        --Se nao encontrar
        IF cr_craptar%NOTFOUND THEN
          --PRB0040208
          CLOSE cr_craptar;
          -- Envia e-mail para área, relatando tarifa não entontrada
          pc_envia_email_tarifa(rw_craplat.rowid,vr_dscritic);
          if vr_dscritic is not null then
            gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_dscritic
                                ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                                ,pr_dstransa => '' 
                                ,pr_dttransa => SYSDATE
                                ,pr_flgtrans => 0
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => pr_nmdatela 
                                ,pr_nrdconta => 0 
                                ,pr_nrdrowid => vr_nrdrowid);
          end if;
          CONTINUE;
        END IF;
        
        --Fechar Cursor
        CLOSE cr_craptar;
         
        -- jogar dentro de uma pltable
        OPEN BTCH0001.cr_crapdat (pr_cdcooper => rw_craplat.cdcooper);
        --Posicionar primeiro registro
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        --Se nao encontrou
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
           CLOSE BTCH0001.cr_crapdat;
           
           --ERRO nao encontrou DAT
           
        END IF; 

        CLOSE BTCH0001.cr_crapdat;
        
        --------------------------------------        
             
        OPEN cr_crapass(pr_cdcooper => rw_craplat.cdcooper
                       ,pr_nrdconta => rw_craplat.nrdconta);
                       
        FETCH cr_crapass INTO rw_crapass;
        --Se nao encontrou
        IF cr_crapass%NOTFOUND THEN
           -- log lgm
           CLOSE cr_crapass;
           
           gene0001.pc_gera_log(pr_cdcooper => rw_craplat.cdcooper
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_dscritic => 'ERRO ASSOCIADO'
                               ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                               ,pr_dstransa => '' --Descricao da tarifa (Buscar via select)
                               ,pr_dttransa => rw_crapdat.dtmvtocd
                               ,pr_flgtrans => 0
                               ,pr_hrtransa => gene0002.fn_busca_time
                               ,pr_idseqttl => 1
                               ,pr_nmdatela => pr_nmdatela 
                               ,pr_nrdconta => rw_craplat.nrdconta
                               ,pr_nrdrowid => vr_nrdrowid);

           pr_tab_tari_pend(vr_ind_tari).cdcooper := rw_craptar.cdcooper;
           pr_tab_tari_pend(vr_ind_tari).cdtarifa := rw_craptar.cdtarifa;
           pr_tab_tari_pend(vr_ind_tari).dstarifa := rw_craptar.dstarifa;
           pr_tab_tari_pend(vr_ind_tari).nmrescop := rw_craptar.nmrescop;
           pr_tab_tari_pend(vr_ind_tari).cdagenci := rw_craplat.cdagenci;
           pr_tab_tari_pend(vr_ind_tari).nrdconta := rw_craplat.nrdconta;
           pr_tab_tari_pend(vr_ind_tari).nmprimtl := rw_crapass.nmprimtl;
           pr_tab_tari_pend(vr_ind_tari).dtmvtolt := rw_craplat.dtmvtolt;
           pr_tab_tari_pend(vr_ind_tari).tarrowid := rw_craplat.rowid;
           pr_tab_tari_pend(vr_ind_tari).vltarifa := rw_craplat.vltarifa;
           pr_tab_tari_pend(vr_ind_tari).cdoperad := pr_cdoperad;
           pr_tab_tari_pend(vr_ind_tari).dsstatus := 'ERRO ASSOCIADO';
          
           vr_ind_tari:= pr_tab_tari_pend.COUNT() + 1; 
           vr_indice  := vr_listalat.NEXT(vr_indice);
           
           CONTINUE;
        END IF; 

        CLOSE cr_crapass;                       
         
        --verificar se o cooperado possui lançamento de credito e saldo positivo
        pc_verifica_credito (pr_cdcooper => rw_craplat.cdcooper,  --> Codigo da cooperativa    
                             pr_nrdconta => rw_craplat.nrdconta,  --> Numero da conta do cooperaro
                             pr_vllimcre => rw_crapass.vllimcre,                    --> limite de credito do cooperado
                             pr_rcrapdat => rw_crapdat,           --> data da cooperativa 
                             pr_flgvflcm => FALSE,                --> flag de controle se deve verificar lançamentos de credito 
                             pr_flgvfsld => TRUE,                 --> flag de controle se deve verificar saldo do cooperado
                             --- out ---                                              
                             pr_fposcred => vr_fposcred,          --> Retorna flag se cooperado possui credito
                             pr_tab_sald => vr_tab_sald,          --> Retorna saldo do cooperado
                             pr_dscritic => vr_dscritic);         --> Retorna critica
        
        -- OBTENÇÃO DO SALDO DA CONTA SEM O DIA FECHADO
        /*extr0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_craplat.cdcooper,
                                    pr_rw_crapdat => rw_crapdat,
                                    pr_cdagenci   => 0,
                                    pr_nrdcaixa   => 0,
                                    pr_cdoperad   => pr_cdoperad,
                                    pr_nrdconta   => rw_craplat.nrdconta,
                                    pr_vllimcre   => rw_crapass.vllimcre,
                                    pr_dtrefere   => rw_crapdat.dtmvtopr,
                                    pr_des_reto   => vr_des_erro,
                                    pr_tab_sald   => vr_tab_sald,
                                    pr_tab_erro   => vr_tab_erro);*/
      

        -- VERIFICA SE HOUVE ERRO NO RETORNO
        --IF vr_des_erro = 'NOK' THEN
          -- ENVIO CENTRALIZADO DE LOG DE ERRO
        --  IF vr_tab_erro.count > 0 THEN
        IF vr_dscritic IS NOT NULL THEN
            --log lgm 'ERRO SALDO'  
            gene0001.pc_gera_log(pr_cdcooper => rw_craplat.cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => 'ERRO SALDO'
                                ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                                ,pr_dstransa => '' --Descricao da tarifa (Buscar via select)
                                ,pr_dttransa => rw_crapdat.dtmvtocd
                                ,pr_flgtrans => 0
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'DEBTAR' --deve vir por parametro
                                ,pr_nrdconta => rw_craplat.nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
          
            -- RECEBE DESCRICAO DO ERRO QUE OCORREU NA PC_CARREGA_PAR_TARIFA_VIGENTE
            --vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;            
          --END IF;
          --Levantar Excecao
          --RAISE vr_exc_erro;
        END IF;
      
	    vr_intipoope := 0; --inicia a variável
        -- CRIA LANCAMENTO APENAS SE SALDO EM CC FOR MAIOR QUE ZERO
        IF vr_tab_sald.COUNT > 0 THEN
          IF (vr_tab_sald(vr_tab_sald.FIRST).vlsddisp + vr_tab_sald(vr_tab_sald.FIRST).vllimcre) >= rw_craplat.vltarifa THEN

            -- LANCAMENTO DE TARIFAS NA CONTA CORRENTE
            TARI0001.pc_lan_tarifa_conta_corrente(pr_cdcooper => rw_craplat.cdcooper --Codigo Cooperativa
                                                 ,pr_cdagenci => rw_craplat.cdagenci --Codigo Agencia
                                                 ,pr_nrdconta => rw_craplat.nrdconta --Numero da Conta
                                                 ,pr_cdbccxlt => rw_craplat.cdbccxlt --Codigo Bco/Ag/Caixa
                                                 ,pr_nrdolote => rw_craplat.nrdolote --Numero do Lote
                                                 ,pr_tplotmov => rw_craplat.tpdolote --Tipo Lote
                                                 ,pr_cdoperad => rw_craplat.cdoperad --Codigo Operador
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimento Atual
                                                 ,pr_nrdctabb => rw_craplat.nrdctabb --Numero Conta BB
                                                 ,pr_nrdctitg => rw_craplat.nrdctitg --Numero Conta Integr.
                                                 ,pr_cdhistor => rw_craplat.cdhistor --Codigo Historico
                                                 ,pr_cdpesqbb => rw_craplat.cdpesqbb --Codigo Pesquisa
                                                 ,pr_cdbanchq => rw_craplat.cdbanchq --Codigo Banco Cheque
                                                 ,pr_cdagechq => rw_craplat.cdagechq --Codigo Agencia Cheque
                                                 ,pr_nrctachq => rw_craplat.nrctachq --Numero Conta Cheque
                                                 ,pr_flgaviso => (rw_craplat.flgaviso = 1) --Flag Aviso
                                                 ,pr_cdsecext => rw_crapass.cdsecext --Cod Extrato Externo
                                                 ,pr_tpdaviso => rw_craplat.tpdaviso --Tipo de Aviso
                                                 ,pr_vltarifa => rw_craplat.vltarifa --Valor da Tarifa
                                                 ,pr_nrdocmto => rw_craplat.nrdocmto --Numero do Documento
                                                 ,pr_cdageass => rw_crapass.cdagenci --Cod Ag Associado
                                                 ,pr_cdcoptfn => 0 --Codigo Coop Terminal
                                                 ,pr_cdagetfn => 0 --Codigo Ag do Terminal
                                                 ,pr_nrterfin => 0 --Numero do Terminal
                                                 ,pr_nrsequni => 0 --Num Sequencial Unico
                                                 ,pr_nrautdoc => 0 --Num Autentic. Docmnto
                                                 ,pr_dsidenti => NULL --Descr da Identificacao
                                                 ,pr_inproces => rw_crapdat.inproces --Indicador do Processo
                                                 ,pr_tab_erro => vr_tab_erro --Tabela de retorno de erro
                                                 ,pr_cdcritic => vr_cdcritic --Código do erro
                                                 ,pr_dscritic => vr_dscritic); --Descricao do erro


            -- SE OCORREU ERRO
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --  log lgm 'ERRO LANCAMENTO'
              gene0001.pc_gera_log(pr_cdcooper => rw_craplat.cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_dscritic => 'ERRO LANCTO'
                                  ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                                  ,pr_dstransa => '' --Descricao da tarifa (Buscar via select)
                                  ,pr_dttransa => rw_crapdat.dtmvtocd
                                  ,pr_flgtrans => 0
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'DEBTAR' --deve vir por parametro
                                  ,pr_nrdconta => rw_craplat.nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);
            
              pr_tab_tari_pend(vr_ind_tari).cdcooper := rw_craptar.cdcooper;
              pr_tab_tari_pend(vr_ind_tari).cdtarifa := rw_craptar.cdtarifa;
              pr_tab_tari_pend(vr_ind_tari).dstarifa := rw_craptar.dstarifa;
              pr_tab_tari_pend(vr_ind_tari).nmrescop := rw_craptar.nmrescop;
              pr_tab_tari_pend(vr_ind_tari).cdagenci := rw_craplat.cdagenci;
              pr_tab_tari_pend(vr_ind_tari).nrdconta := rw_craplat.nrdconta;
              pr_tab_tari_pend(vr_ind_tari).nmprimtl := rw_crapass.nmprimtl;
              pr_tab_tari_pend(vr_ind_tari).dtmvtolt := rw_craplat.dtmvtolt;
              pr_tab_tari_pend(vr_ind_tari).tarrowid := rw_craplat.rowid;
              pr_tab_tari_pend(vr_ind_tari).vltarifa := rw_craplat.vltarifa;
              pr_tab_tari_pend(vr_ind_tari).cdoperad := pr_cdoperad;
              pr_tab_tari_pend(vr_ind_tari).dsstatus := 'ERRO LANCTO';
              
              vr_ind_tari:= pr_tab_tari_pend.COUNT() + 1;                                   
              vr_indice := vr_listalat.NEXT(vr_indice);
              
              CONTINUE;
            ELSE
              
              BEGIN
                UPDATE craplat 
                   SET craplat.dtefetiv = rw_crapdat.dtmvtolt,
                       craplat.insitlat = 2 --Efetivado
                 WHERE craplat.rowid    = rw_craplat.rowid;
				 
                vr_intipoope := 1;	-- lançamento total da tarifa				 
              EXCEPTION
                WHEN OTHERS THEN        
                  vr_dscritic := 'Problemas na atualizacao da tarifa pendente.';
                  RAISE vr_exc_erro;
                  
              END;
  
            END IF;
          -- Debito Parcial, para quando chamado a partir do programa do debitador unico-----------
          ELSIF (vr_tab_sald(vr_tab_sald.FIRST).vlsddisp + vr_tab_sald(vr_tab_sald.FIRST).vllimcre) > 0 
               AND pr_nmdatela in ('DEBITADOR') THEN			
            
            vr_vlpendente := rw_craplat.vltarifa - (vr_tab_sald(vr_tab_sald.FIRST).vlsddisp + vr_tab_sald(vr_tab_sald.FIRST).vllimcre);
	      	   --- Tarifa assume saldo disponível
     		    rw_craplat.vltarifa  := (vr_tab_sald(vr_tab_sald.FIRST).vlsddisp + vr_tab_sald(vr_tab_sald.FIRST).vllimcre);

			      -- LANCAMENTO DE TARIFAS NA CONTA CORRENTE
            TARI0001.pc_lan_tarifa_conta_corrente(pr_cdcooper => rw_craplat.cdcooper --Codigo Cooperativa
                                                 ,pr_cdagenci => rw_craplat.cdagenci --Codigo Agencia
                                                 ,pr_nrdconta => rw_craplat.nrdconta --Numero da Conta
                                                 ,pr_cdbccxlt => rw_craplat.cdbccxlt --Codigo Bco/Ag/Caixa
                                                 ,pr_nrdolote => rw_craplat.nrdolote --Numero do Lote
                                                 ,pr_tplotmov => rw_craplat.tpdolote --Tipo Lote
                                                 ,pr_cdoperad => rw_craplat.cdoperad --Codigo Operador
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimento Atual
                                                 ,pr_nrdctabb => rw_craplat.nrdctabb --Numero Conta BB
                                                 ,pr_nrdctitg => rw_craplat.nrdctitg --Numero Conta Integr.
                                                 ,pr_cdhistor => rw_craplat.cdhistor --Codigo Historico
                                                 ,pr_cdpesqbb => rw_craplat.cdpesqbb --Codigo Pesquisa
                                                 ,pr_cdbanchq => rw_craplat.cdbanchq --Codigo Banco Cheque
                                                 ,pr_cdagechq => rw_craplat.cdagechq --Codigo Agencia Cheque
                                                 ,pr_nrctachq => rw_craplat.nrctachq --Numero Conta Cheque
                                                 ,pr_flgaviso => (rw_craplat.flgaviso = 1) --Flag Aviso  ?????????
                                                 ,pr_cdsecext => rw_crapass.cdsecext --Cod Extrato Externo
                                                 ,pr_tpdaviso => rw_craplat.tpdaviso --Tipo de Aviso
                                                 ,pr_vltarifa => rw_craplat.vltarifa --Valor da Tarifa
                                                 ,pr_nrdocmto => rw_craplat.nrdocmto --Numero do Documento
                                                 ,pr_cdageass => rw_crapass.cdagenci --Cod Ag Associado
                                                 ,pr_cdcoptfn => 0 --Codigo Coop Terminal
                                                 ,pr_cdagetfn => 0 --Codigo Ag do Terminal
                                                 ,pr_nrterfin => 0 --Numero do Terminal
                                                 ,pr_nrsequni => 0 --Num Sequencial Unico
                                                 ,pr_nrautdoc => 0 --Num Autentic. Docmnto
                                                 ,pr_dsidenti => NULL --Descr da Identificacao
                                                 ,pr_inproces => rw_crapdat.inproces --Indicador do Processo
                                                 ,pr_tab_erro => vr_tab_erro --Tabela de retorno de erro
                                                 ,pr_cdcritic => vr_cdcritic --Código do erro
                                                 ,pr_dscritic => vr_dscritic); --Descricao do erro
            
            -- SE OCORREU ERRO
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --  log lgm 'ERRO LANCAMENTO'
              gene0001.pc_gera_log(pr_cdcooper => rw_craplat.cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_dscritic => 'ERRO LANCTO PARCIAL'
                                  ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                                  ,pr_dstransa => '' --Descricao da tarifa (Buscar via select)
                                  ,pr_dttransa => rw_crapdat.dtmvtocd
                                  ,pr_flgtrans => 0
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'DEBTAR' --deve vir por parametro
                                  ,pr_nrdconta => rw_craplat.nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);
            
              pr_tab_tari_pend(vr_ind_tari).cdcooper := rw_craptar.cdcooper;
              pr_tab_tari_pend(vr_ind_tari).cdtarifa := rw_craptar.cdtarifa;
              pr_tab_tari_pend(vr_ind_tari).dstarifa := rw_craptar.dstarifa;
              pr_tab_tari_pend(vr_ind_tari).nmrescop := rw_craptar.nmrescop;
              pr_tab_tari_pend(vr_ind_tari).cdagenci := rw_craplat.cdagenci;
              pr_tab_tari_pend(vr_ind_tari).nrdconta := rw_craplat.nrdconta;
              pr_tab_tari_pend(vr_ind_tari).nmprimtl := rw_crapass.nmprimtl;
              pr_tab_tari_pend(vr_ind_tari).dtmvtolt := rw_craplat.dtmvtolt;
              pr_tab_tari_pend(vr_ind_tari).tarrowid := rw_craplat.rowid;
              pr_tab_tari_pend(vr_ind_tari).vltarifa := rw_craplat.vltarifa;
              pr_tab_tari_pend(vr_ind_tari).cdoperad := pr_cdoperad;
              pr_tab_tari_pend(vr_ind_tari).dsstatus := 'ERRO LANCTO PARCIAL';
              
              vr_ind_tari:= pr_tab_tari_pend.COUNT() + 1;                                   
              vr_indice := vr_listalat.NEXT(vr_indice);
              
              CONTINUE;
          ELSE
              
              BEGIN
                UPDATE craplat 
                   SET craplat.vltarifa = vr_vlpendente
                 WHERE craplat.rowid    = rw_craplat.rowid;
            
			     vr_intipoope := 2;	-- lançamento parcial da tarifa				 

           
                  -- gera uma nova tarifa (pendente) com o valor parcial
                  -- isso é necessário para o caso de estorno da tarifa, pois no estorno exige que 
                  -- exista esse registro.
                  TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => rw_craptar.cdcooper   --Codigo Cooperativa
                                                   ,pr_nrdconta => rw_craplat.nrdconta  --Numero da Conta
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt    --Data Lancamento
                                                   ,pr_cdhistor => rw_craplat.cdhistor   --Codigo Historico
                                                   ,pr_vllanaut => rw_craplat.vltarifa   --Valor lancamento automatico
                                                   ,pr_cdoperad => rw_craplat.cdoperad   --Codigo Operador
                                                   ,pr_cdagenci => rw_craplat.cdagenci   --Codigo Agencia
                                                   ,pr_cdbccxlt => rw_craplat.cdbccxlt   --Codigo banco caixa
                                                   ,pr_nrdolote => rw_craplat.nrdolote   --Numero do lote
                                                   ,pr_tpdolote => rw_craplat.tpdolote   --Tipo do lote
                                                   ,pr_nrdocmto => rw_craplat.nrdocmto   --Numero do documento
                                                   ,pr_nrdctabb => rw_craplat.nrdctabb   --Numero da conta
                                                   ,pr_nrdctitg => rw_craplat.nrdctitg    --Numero da conta integracao
                                                   ,pr_cdpesqbb => rw_craplat.cdpesqbb  --Codigo pesquisa
                                                   ,pr_cdbanchq => rw_craplat.cdbanchq  --Codigo Banco Cheque
                                                   ,pr_cdagechq => rw_craplat.cdagechq  --Codigo Agencia Cheque
                                                   ,pr_nrctachq => rw_craplat.nrctachq   --Numero Conta Cheque
                                                   ,pr_flgaviso => false--rw_craplat.flgaviso  --Flag aviso
                                                   ,pr_tpdaviso => rw_craplat.tpdaviso   --Tipo aviso
                                                   ,pr_cdfvlcop => rw_craplat.cdfvlcop   --Codigo cooperativa
                                                   ,pr_inproces => rw_crapdat.inproces --Indicador do Processo                 --Indicador processo, já controlado pelo Debitador
                                                   ,pr_rowid_craplat => vr_rowid_craplat_new --Rowid do lancamento tarifa
                                                   ,pr_tab_erro => vr_tab_erro_tar   --Tabela retorno erro
                                                   ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                   ,pr_dscritic => vr_dscritic); --Descricao Critica
           	 
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
                -- efetiva a tarifa gerada acima
                TARI0001.pc_efetiva_tarifa (pr_rowid_craplat => vr_rowid_craplat_new     --Rowid da tarifa
                                           ,pr_dtmvtolt      => rw_crapdat.dtmvtolt       --Data Lancamento
                                           ,pr_cdcritic      => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic      => vr_dscritic); --Descricao Critica

                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;


              EXCEPTION
                WHEN OTHERS THEN        
                  vr_dscritic := 'Problemas na atualizacao da tarifa pendente - Parcial.';
                  RAISE vr_exc_erro;
                  
              END;
  
            END IF;
		  
            ------------------ fim debito parcial ---------------------------------------		  
          ELSE
            -- log lgm 'SEM SALDO'  
            gene0001.pc_gera_log(pr_cdcooper => rw_craplat.cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => 'SEM SALDO'
                                ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                                ,pr_dstransa => '' --Descricao da tarifa (Buscar via select)
                                ,pr_dttransa => rw_crapdat.dtmvtocd
                                ,pr_flgtrans => 0
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'DEBTAR' --deve vir por parametro
                                ,pr_nrdconta => rw_craplat.nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);                                               
                    
            --lista de controle de contas sem saldo
            vr_tab_ctassld(rw_craplat.nrdconta) := rw_craplat.nrdconta;
                        
            pr_tab_tari_pend(vr_ind_tari).cdcooper := rw_craptar.cdcooper;
            pr_tab_tari_pend(vr_ind_tari).cdtarifa := rw_craptar.cdtarifa;
            pr_tab_tari_pend(vr_ind_tari).dstarifa := rw_craptar.dstarifa;
            pr_tab_tari_pend(vr_ind_tari).nmrescop := rw_craptar.nmrescop;
            pr_tab_tari_pend(vr_ind_tari).cdagenci := rw_craplat.cdagenci;
            pr_tab_tari_pend(vr_ind_tari).nrdconta := rw_craplat.nrdconta;
            pr_tab_tari_pend(vr_ind_tari).nmprimtl := rw_crapass.nmprimtl;
            pr_tab_tari_pend(vr_ind_tari).dtmvtolt := rw_craplat.dtmvtolt;
            pr_tab_tari_pend(vr_ind_tari).tarrowid := rw_craplat.rowid;
            pr_tab_tari_pend(vr_ind_tari).vltarifa := rw_craplat.vltarifa;
            pr_tab_tari_pend(vr_ind_tari).cdoperad := pr_cdoperad;
            pr_tab_tari_pend(vr_ind_tari).dsstatus := 'SEM SALDO';
          
            vr_ind_tari:= pr_tab_tari_pend.COUNT() + 1; 
                                
            vr_indice := vr_listalat.NEXT(vr_indice);
                                
            CONTINUE;                    
          END IF;
          
        END IF;

        pr_tab_tari_pend(vr_ind_tari).cdcooper := rw_craptar.cdcooper;
        pr_tab_tari_pend(vr_ind_tari).cdtarifa := rw_craptar.cdtarifa;
        pr_tab_tari_pend(vr_ind_tari).dstarifa := rw_craptar.dstarifa;
        pr_tab_tari_pend(vr_ind_tari).nmrescop := rw_craptar.nmrescop;
        pr_tab_tari_pend(vr_ind_tari).cdagenci := rw_craplat.cdagenci;
        pr_tab_tari_pend(vr_ind_tari).nrdconta := rw_craplat.nrdconta;
        pr_tab_tari_pend(vr_ind_tari).nmprimtl := rw_crapass.nmprimtl;
        pr_tab_tari_pend(vr_ind_tari).dtmvtolt := rw_craplat.dtmvtolt;
        pr_tab_tari_pend(vr_ind_tari).tarrowid := rw_craplat.rowid;
        pr_tab_tari_pend(vr_ind_tari).vltarifa := rw_craplat.vltarifa;
        pr_tab_tari_pend(vr_ind_tari).cdoperad := pr_cdoperad;
        if vr_intipoope = 1 then --- lançamento total da tarifa
        pr_tab_tari_pend(vr_ind_tari).dsstatus := 'OK';
		else 	
		  pr_tab_tari_pend(vr_ind_tari).dsstatus := 'PARCIAL';
        end if;                
        vr_indice  := vr_listalat.NEXT(vr_indice);
        vr_ind_tari:= pr_tab_tari_pend.COUNT() + 1; 
      END LOOP; -- FIM WHILE
 
      IF pr_flimprim = 1 THEN     
         TARI0001.pc_imprimir_tarifa_pend(pr_cdcooper      => pr_cdcooper
                                         ,pr_tab_tari_pend => pr_tab_tari_pend
                                         ,pr_nmarqpdf      => pr_nmarqpdf
                                         ,pr_cdcritic      => vr_cdcritic
                                         ,pr_dscritic      => vr_dscritic);                                         
      END IF;   
      
    EXCEPTION
      WHEN vr_exc_erro THEN        
        pr_dscritic:= vr_dscritic;        
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na TARI0001.pc_debita_tarifa_online: '||SQLerrm;
    END;
  END pc_debita_tarifa_online;


  PROCEDURE pc_deb_tarifa_online_web(pr_listalat IN  CLOB
                                    ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN  
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_auxconta PLS_INTEGER := 0;
      vr_nmarqpdf VARCHAR2(500);

      -- Temp Table
      vr_tab_tari_pend TARI0001.typ_tab_tarifas_pend;
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
    BEGIN 
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Efetivar 
      TARI0001.pc_debita_tarifa_online(pr_cdcooper => vr_cdcooper
                                      ,pr_cdoperad => vr_cdoperad
                                      ,pr_idorigem => vr_idorigem
                                      ,pr_nmdatela => vr_nmdatela
                                      ,pr_listalat => pr_listalat
                                      ,pr_flimprim => 1
                                      ,pr_nmarqpdf => vr_nmarqpdf
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_tab_tari_pend => vr_tab_tari_pend);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TARI0001.pc_deb_tarifa_online_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;    
  END pc_deb_tarifa_online_web;
  
  /*  Procedimento para verificar se a conta possui lançamento de credito no dia
      e se possui saldo */
  PROCEDURE pc_verifica_credito (pr_cdcooper  IN crapcop.cdcooper%TYPE,      --> Codigo da cooperativa    
                                 pr_nrdconta  IN craplat.nrdconta%TYPE,      --> Numero da conta do cooperaro
                                 pr_vllimcre  IN crapass.vllimcre%TYPE,      --> limite de credito do cooperado
                                 pr_rcrapdat  IN btch0001.cr_crapdat%ROWTYPE,--> data da cooperativa 
                                 pr_flgvflcm  IN BOOLEAN,                    --> flag de controle se deve verificar lançamentos de credito    
                                 pr_flgvfsld  IN BOOLEAN,                    --> flag de controle se deve verificar saldo do cooperado
                                 pr_fposcred OUT BOOLEAN,                    --> Retorna flag se cooperado possui credito
                                 pr_tab_sald OUT EXTR0001.typ_tab_saldos,    --> Retorna saldo do cooperado
                                 pr_dscritic OUT VARCHAR2                    --> Retorna critica
                                 )IS 
                 
    ------------------- CURSOR --------------------
    CURSOR cr_craplcm(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT craplcm.rowid 
        FROM craplcm, craphis 
       WHERE craplcm.cdcooper = craphis.cdcooper AND
             craplcm.cdhistor = craphis.cdhistor AND
             craplcm.nrdconta = pr_nrdconta      AND
             craplcm.cdcooper = pr_cdcooper      AND
             craplcm.dtmvtolt = pr_dtmvtolt      AND
             craphis.indebcre = 'C'              AND
             rownum < 2; 
             
    rw_craplcm cr_craplcm%ROWTYPE;
    
    ------------------ VARIAVEIS ------------------
    --Obtem Saldo
    vr_des_erro VARCHAR2(100);
    vr_tab_erro GENE0001.typ_tab_erro;
    
    
  BEGIN
    -- Inicializar variavel de possui credito com false
    pr_fposcred := FALSE;
    
    -- verificar se possui novos lançamentos de credito
    IF pr_flgvflcm THEN 
      --Verifica se houve algum credito pra conta no dia
      OPEN cr_craplcm(pr_cdcooper => pr_cdcooper,
                      pr_dtmvtolt => pr_rcrapdat.dtmvtolt,
                      pr_nrdconta => pr_nrdconta);
                 
      FETCH cr_craplcm INTO rw_craplcm;
      
      -- se encontrou marcar como possui           
      IF cr_craplcm%FOUND THEN
        pr_fposcred := TRUE;
      END IF;                    
      CLOSE cr_craplcm;
    END IF;
    
    -- verificar saldo se estiver marcado como true
    IF pr_flgvfsld AND
       -- e caso a flg de verificar lançamento estiver como true e encontrou algum lançamento
      ((pr_flgvflcm AND pr_flgvflcm) OR 
        -- ou se não verificou lançamento de credito
        pr_flgvflcm = FALSE )THEN
        
      -- obtencao do saldo da conta sem o dia fechado
      extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                  pr_rw_crapdat => pr_rcrapdat,
                                  pr_cdagenci   => 0,
                                  pr_nrdcaixa   => 0,
                                  pr_cdoperad   => 1,
                                  pr_nrdconta   => pr_nrdconta,
                                  pr_vllimcre   => pr_vllimcre,
                                  pr_flgcrass   => TRUE, 
                                  pr_dtrefere   => pr_rcrapdat.dtmvtolt,
                                  pr_tipo_busca => 'A', --Chamado 291693 (Heitor - RKAM)
                                  pr_des_reto   => vr_des_erro,
                                  pr_tab_sald   => pr_tab_sald,
                                  pr_tab_erro   => vr_tab_erro);
              
      -- VERIFICA SE HOUVE ERRO NO RETORNO
      IF vr_des_erro = 'NOK' THEN
        -- se retornou erro, definir como não possui credito
        pr_fposcred := FALSE;
      ELSE
        -- Considerar a conta somente se houver saldo
        IF pr_tab_sald.COUNT > 0 AND
           (pr_tab_sald(pr_tab_sald.FIRST).vlsddisp + pr_tab_sald(pr_tab_sald.FIRST).vllimcre) > 0 THEN
          -- se possuir saldo, marcar como possui credito
          pr_fposcred := TRUE;
        ELSE  
          -- se for negativo marcar como false
          pr_fposcred := FALSE;
        END IF;
        
      END IF;
    END IF;  
     
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na pc_verifica_credito para conta '||pr_nrdconta||':'||SQLERRM;
  END pc_verifica_credito;
  
  
  /* Procedimento para buscar todas as tarifas pendentes de debito e tentar debita-las */
  PROCEDURE pc_deb_tarifa_pend ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                ,pr_dtinicio IN DATE                    --> data de inicio para verificação das tarifas               
                                ,pr_dtafinal IN DATE                    --> data final para verificação das tarifas               
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  /* .............................................................................

     Programa: pc_deb_tarifa_pend 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : fevereiro/2014                     Ultima atualizacao: 25/02/2014

     Dados referentes ao programa:

     Frequencia: Será rodado atraves de Job(verificar na configuração do job)
     Objetivo  : Listar as taridas pendentes e debita-las

     Alteracoes: 25/02/2015 - Criação do procedimento
         10/04/2018 - Alterado para que na primeira execução do dia
                     verifique o saldo e não o credito na pc_verifica_credito pois
               esta rotina passara a ser chamada pelo Debitador (Elton Giusti)

  ............................................................................ */

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'DEBUNITAR';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdcooper
        FROM crapcop cop
       WHERE (cop.cdcooper = pr_cdcooper AND
              pr_cdcooper IS NOT NULL)
          OR (cop.cdcooper <> 3 AND
              cop.flgativo = 1 AND -- Somente coops ativas
              pr_cdcooper IS NULL);
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Busca de tarifas pendentes
    CURSOR cr_craplat_pendente (pr_cdcooper craplat.cdcooper%TYPE,
                                pr_dtinicio crapdat.dtmvtolt%TYPE,
                                pr_dtafinal crapdat.dtmvtolt%TYPE) IS
      SELECT lat.cdcooper
            ,lat.nrdconta
            ,lat.dttransa
            ,lat.rowid
            ,COUNT(*) over (PARTITION BY lat.cdcooper 
                                ORDER BY lat.cdcooper) qtdtotcop
            ,COUNT(*) over (PARTITION BY lat.cdcooper, lat.nrdconta 
                                ORDER BY lat.cdcooper, lat.nrdconta) qtdreg
            ,row_number() over(PARTITION BY lat.cdcooper, lat.nrdconta 
                                   ORDER BY lat.cdcooper, lat.nrdconta) seqreg
        FROM craplat lat
       WHERE lat.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
         AND lat.dtmvtolt >= pr_dtinicio -- DATA DE MOVIMENTAÇÃO
         AND lat.dtmvtolt <= pr_dtafinal -- DATA DE MOVIMENTAÇÃO
		 AND lat.vltarifa IS NOT NULL    
         AND lat.insitlat = 1; -- SITUAÇÃO DE LANÇAMENTO 1-PENDENTE, 2-EFETIVADO, 3-ESTORNADO, 4-BAIXADO
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- BUSCA DE ASSOCIADOS
   CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapass.vllimcre, crapass.cdagenci,
             crapass.nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper AND
             crapass.nrdconta = pr_nrdconta;
         
    rw_crapass cr_crapass%ROWTYPE;   

 -- TIPOS DE TABELAS TEMPORARIAS
    
    TYPE typ_reg_craplat_baixado IS RECORD
      (insitlat craplat.insitlat%type,
       cdopeest craplat.cdopeest%type,
       dtdestor craplat.dtdestor%type,
       cdmotest craplat.cdmotest%type,
       dsjusest craplat.dsjusest%type,
       vr_rowid rowid);
    TYPE typ_tab_craplat_baixado IS TABLE OF typ_reg_craplat_baixado INDEX BY PLS_INTEGER;
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    vr_tab_tari_pend    TARI0001.typ_tab_tarifas_pend;
    vr_tab_sald         EXTR0001.typ_tab_saldos;
    vr_tab_craplat_baixado typ_tab_craplat_baixado;
    
    ------------------------------- VARIAVEIS -------------------------------  
    vr_idxlat   PLS_INTEGER;
    vr_qtretok  NUMBER;
    vr_qtretpar NUMBER;
	
    vr_qttotcop NUMBER;
    vr_nmarqlog VARCHAR2(80) := 'debunitar';
    vr_dtinicio DATE;
    vr_dtafinal DATE;
    vr_nmarqpdf VARCHAR2(500);
    vr_fposcred BOOLEAN;
       
    vr_flgerlog BOOLEAN      := FALSE;
       
    --Obtem Saldo
    vr_flgvflcm  BOOLEAN;
    vr_flgvfsld  BOOLEAN;
    -- controle execuções programa
    vr_flultexe     INTEGER;
    vr_qtdexec      INTEGER;
    
    --
    vr_dsconteu VARCHAR2(4000);
    vr_des_erro VARCHAR2(4000);
    vr_inttoday INTEGER;
    vr_dttransa INTEGER;
    vr_index    PLS_INTEGER;
    vr_tab_erro GENE0001.typ_tab_erro;
     
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- procedimento para gerar log da debtar
    PROCEDURE pc_gera_log(pr_ind_tipo_log IN NUMBER DEFAULT 1,
                          pr_des_log IN VARCHAR2) IS
    BEGIN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => pr_ind_tipo_log
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || pr_des_log );
    END pc_gera_log;
        

    -- PROCEDURE PARA ATUALIZACAO DE TARIFAS
    PROCEDURE pc_atualiza_tarifa_vigente IS
      
  /*............................................................................ 	
    05/07/2018 - Alterado para considerar data de vigencia maior que a data do movimento 
                    anterior da cooperativa e menor ou igual a data atual da cooperativa
                  (Elton Giusti)
  ............................................................................ */	
      -- Buscar todas as faixas que devem entrar em vigencia
      CURSOR cr_crapfco IS
        SELECT cdfaixav,
               cdcooper,
               nrconven,
               cdlcremp,
               rowid
          FROM crapfco
         WHERE crapfco.cdcooper = pr_cdcooper
         AND crapfco.dtvigenc > rw_crapdat.dtmvtoan  
         AND crapfco.dtvigenc <= rw_crapdat.dtmvtolt 
           ORDER BY dtvigenc;
           
      TYPE typ_tab_crapfco IS TABLE OF cr_crapfco%rowtype INDEX BY PLS_INTEGER;
      vr_tab_crapfco typ_tab_crapfco;     
    
  BEGIN
      -- Ler todas as faixas que devem entrar em vigencia
      OPEN cr_crapfco;
      LOOP
        FETCH cr_crapfco BULK COLLECT INTO vr_tab_crapfco LIMIT 10000;
        EXIT WHEN vr_tab_crapfco.COUNT = 0;
        
  BEGIN
          -- Atualizar todas as faixas existentes para esse convenio e faixa para inativa, 
          --pois em seguida irá ativar somente a que esta iniciando a vigencia
          FORALL idx IN 1..vr_tab_crapfco.COUNT SAVE EXCEPTIONS
            UPDATE crapfco
               SET crapfco.flgvigen = 0
             WHERE crapfco.cdcooper = vr_tab_crapfco(idx).cdcooper -- CODIGO DA COOPERATIVA
             AND   crapfco.cdfaixav = vr_tab_crapfco(idx).cdfaixav
             AND   crapfco.nrconven = vr_tab_crapfco(idx).nrconven
             AND   crapfco.cdlcremp = vr_tab_crapfco(idx).cdlcremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro primeira atualizacao crapfco. ERRO:' ||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
            RAISE vr_exc_saida;
        END;

        -- Ativar faixas de valores de tarifas que esta iniciando a vigencia
  BEGIN
          FORALL idx IN 1..vr_tab_crapfco.COUNT SAVE EXCEPTIONS
            UPDATE crapfco
            SET crapfco.flgvigen = 1
            WHERE crapfco.rowid = vr_tab_crapfco(idx).rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro segunda atualizacao crapfco. ERRO:' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
            RAISE vr_exc_saida;

        END;
      END LOOP;
      CLOSE cr_crapfco;
    EXCEPTION
      WHEN vr_exc_saida THEN
        RAISE vr_exc_saida;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro não tratado na rotina pc_atualiza_tarifa_vigente: ' || sqlerrm;
        RAISE vr_exc_saida;
        
    END;
    -- fim das procedures 
  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

  --- para verificar a primeira execução do programa por coop, as demais são iguais
      SICR0001.pc_controle_exec_deb ( pr_cdcooper  => pr_cdcooper        --> Código da coopertiva
                                      ,pr_cdtipope  => 'I'                         --> Tipo de operacao I-incrementar e C-Consultar
                                      ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento
                                      ,pr_cdprogra  => vr_cdprogra                 --> Codigo do programa
                                      ,pr_flultexe  => vr_flultexe                 --> Retorna se é a ultima execução do procedimento
                                      ,pr_qtdexec   => vr_qtdexec                  --> Retorna a quantidade
                                      ,pr_cdcritic  => vr_cdcritic                 --> Codigo da critica de erro
                                      ,pr_dscritic  => vr_dscritic);               --> descrição do erro se ocorrer

       IF nvl(vr_cdcritic,0) > 0 OR
          TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_saida;
       END IF;

       --Commit para garantir o
       --controle de execucao do programa
       COMMIT;
    
    -- Verificar se a data atual é uma data util, se retornar uma data diferente
    -- indica que não é um dia util, então deve abortar o programa sem executa-lo
    IF gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper ,
                                   pr_dtmvtolt => TRUNC(SYSDATE)) <> TRUNC(SYSDATE) THEN
      -- para fazer somente na primeira execução do dia
      IF vr_qtdexec = 1 then
		-- ATUALIZA TARIFA VIGENTE
		pc_atualiza_tarifa_vigente;
      end if;  
	  
      RETURN;                               
    END IF;                               

	-- para fazer somente na primeira execução do dia
    IF vr_qtdexec = 1 then
        -- CHAMADA DE FUNCAO PARA ATUALIZACAO DE TARIFA
		pc_atualiza_tarifa_vigente;
    end if; 

   -- PROCEDURE PARA BUSCAR TARIFA VIGENTE
    tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper,
                                           pr_cdbattar => 'TEMPLAUTOM',
                                           pr_dsconteu => vr_dsconteu,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic,
                                           pr_des_erro => vr_des_erro,
                                           pr_tab_erro => vr_tab_erro);

    -- VERIFICA SE HOUVE ERRO NO RETORNO
    IF vr_des_erro = 'NOK' THEN
      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      IF vr_tab_erro.count > 0 THEN

        -- RECEBE DESCRICAO DO ERRO QUE OCORREU NA PC_CARREGA_PAR_TARIFA_VIGENTE
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

        -- GERA LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- ERRO TRATATO
                                   pr_des_log      => to_char(sysdate, 'hh24:mi:ss') || ' -' || vr_cdprogra || ' --> ' || vr_dscritic);
      END IF;
      RAISE vr_exc_saida;
    END IF;


    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    --Data de inicio poderá vir nula, porém será substituida por uma bem antiga
    -- visto que a rotina de busca necessita de uma data
    vr_dtinicio := pr_dtinicio;
    
    --caso as datas estejam em branco, definir um range de um ano para os filtros
    IF pr_dtafinal IS NULL THEN
      vr_dtafinal := rw_crapdat.dtmvtoan; 
    ELSE
      vr_dtafinal := pr_dtafinal;  
    END IF;
    

    pc_gera_log(pr_des_log => 'Inicio da execucao: '||
                              (CASE pr_cdcooper
                               WHEN 3 THEN 'Todas as coop.'
                               ELSE 'Coop. '||pr_cdcooper END) ||
                               ' periodo inicio ' || nvl(to_char(vr_dtinicio,'DD/MM/RRRR'),'nao definida')||
                               ' final '|| nvl(to_char(vr_dtafinal,'DD/MM/RRRR'),'nao definida')
                             );
                                                 
    -- RECEBE DIA ATUAL
    vr_inttoday := TO_CHAR(SYSDATE, 'dd');
    
    -- buscar todas as cooperativas caso seja rodado para a cooper Cecred
    FOR rw_crapcop IN cr_crapcop(pr_cdcooper => (CASE pr_cdcooper
                                                  WHEN 3 THEN NULL ELSE pr_cdcooper
                                                  END) ) LOOP
      --iniciar variaveis   
      vr_tab_tari_pend.delete;
      vr_qtretok := 0;
      vr_qttotcop := 0;
	  vr_qtretpar := 0;
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      --  Buscar tarifas pendentes da cooperativa
      FOR rw_craplat IN cr_craplat_pendente(pr_cdcooper => rw_crapcop.cdcooper ,
                                            pr_dtinicio => nvl(vr_dtinicio, to_date('22/04/1500','DD/MM/RRRR')),
                                            pr_dtafinal => vr_dtafinal) LOOP
                                            
        -- limpar temptable de armazenamento das cooperativas
        -- a cada conta nova
        IF rw_craplat.seqreg = 1 THEN
          vr_tab_tari_pend.delete;
        END IF;                                
               
        -- armazenar tarifas da conta na temptable
        vr_idxlat := vr_tab_tari_pend.count +1 ;        
        vr_tab_tari_pend(vr_idxlat).tarrowid := rw_craplat.rowid;
        
        -- caso seja o ultima tarifa da conta, chamar a rotina para tentar debitar a tariga
        IF rw_craplat.seqreg = rw_craplat.qtdreg THEN
          
       --   vr_primeira_execucao := 'S';
          --Verifica se primeira execução do dia.
          IF vr_qtdexec = 1 then
            --- verifica saldo e não crédito.
            vr_flgvflcm := FALSE;
            vr_flgvfsld := TRUE;

           -- RECEBE SOMENTO O DIA DA TRANSACAO REFERENTE AO LANCAMENTO DA TARIFA
            vr_dttransa := NVL(to_number(to_char(rw_craplat.dttransa, 'dd')), 0);

            -- VERIFICA SE A TARIFA ESTA DENTRO DO PERIODO PARAMETRIZADO PARA COBRANCA,
            -- SE ESTOUROU O PRAZO PARA COBRANCA, DEVERA SER FEITA BAIXA DA TARIFA.
            IF vr_dsconteu < (vr_inttoday - vr_dttransa) THEN
              vr_index:= vr_tab_craplat_baixado.count+1;
              vr_tab_craplat_baixado(vr_index).insitlat:= 3; --BAIXADO
              vr_tab_craplat_baixado(vr_index).cdopeest:= '1'; -- CODIGO DO OPERADOR QUE EFETUOU O ESTORNO/BAIXA DA TARIFA
              vr_tab_craplat_baixado(vr_index).dtdestor:= rw_crapdat.dtmvtolt; -- DATA DE MOVIMENTO ATUAL
              vr_tab_craplat_baixado(vr_index).cdmotest:= 99999; -- CODIGO DO MOTIVO DE ESTORNO/BAIXA DA TARIFA
              vr_tab_craplat_baixado(vr_index).dsjusest:= 'Estouro de prazo da cobranca.'; -- JUSTIFICATIVA PARA TER EFETUADO O ESTORNO/BAIXA DA TARIFA
              vr_tab_craplat_baixado(vr_index).vr_rowid:= rw_craplat.rowid;
              --Proximo Registro
              CONTINUE;
            END IF;

          ELSE
            vr_flgvflcm := TRUE;
            vr_flgvfsld := FALSE;
          END IF;
          
                    --Busca limite credito do cooperado
          OPEN cr_crapass(pr_cdcooper => rw_craplat.cdcooper,                          
                          pr_nrdconta => rw_craplat.nrdconta);
               
          FETCH cr_crapass INTO rw_crapass;
               
          IF cr_crapass%NOTFOUND THEN
             CLOSE cr_crapass;
             CONTINUE;
          END IF;   
               
          CLOSE cr_crapass;  

          --verificar se o cooperado possui lançamento de credito
          -- sinal que possivelmente possui credito para debitar
          pc_verifica_credito (pr_cdcooper => rw_craplat.cdcooper,  --> Codigo da cooperativa    
                               pr_nrdconta => rw_craplat.nrdconta,  --> Numero da conta do cooperaro
                                 pr_vllimcre => rw_crapass.vllimcre,  --> limite de credito do cooperado
                               pr_rcrapdat => rw_crapdat,           --> data da cooperativa 
                                 pr_flgvflcm => vr_flgvflcm,          --> flag de controle se deve verificar lançamentos de credito
                                 pr_flgvfsld => vr_flgvfsld,          --> flag de controle se deve verificar saldo do cooperado
                               --- out ---                                              
                               pr_fposcred => vr_fposcred,          --> Retorna flag se cooperado possui credito
                               pr_tab_sald => vr_tab_sald,          --> Retorna saldo do cooperado
                               pr_dscritic => vr_dscritic);         --> Retorna critica

          -- se possui lançamento de credito ou saldo (quando primeira execução do dia pelo Debitador)
          ---, tenta debitar
          -- senão não é necessario, visto que já tentou na primeira execução e não conseguiu por não possuir saldo
          IF vr_fposcred THEN
            TARI0001.pc_debita_tarifa_online(pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_cdoperad => 1 -- Ususario Master
                                            ,pr_idorigem => 1 -- Ayllos
                                            ,pr_nmdatela => 'DEBITADOR'-- era 'DEBTAR'
                                            ,pr_flimprim => 0 --> não gerar relatorio
                                            ,pr_nmarqpdf => vr_nmarqpdf
                                            ,pr_listalat => NULL
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_tab_tari_pend => vr_tab_tari_pend);
            
            IF vr_tab_tari_pend.count > 0 THEN
              -- contar quantas tarifas foram debitadas com sucesso
              FOR idx_ret IN vr_tab_tari_pend.first..vr_tab_tari_pend.last LOOP
                IF vr_tab_tari_pend(idx_ret).dsstatus = 'OK' THEN
                  vr_qtretok  := vr_qtretok + 1;
                ELSIF  vr_tab_tari_pend(idx_ret).dsstatus = 'PARCIAL' THEN
				  vr_qtretpar := vr_qtretpar + 1;
                END IF;
              END LOOP;
            END IF;
            
            -- guardar qtd total de tarifas da cooperativa
            vr_qttotcop := rw_craplat.qtdtotcop;
              
            IF vr_dscritic IS NOT NULL THEN
              -- exibir critica no log e ir para o proximo
              pc_gera_log(pr_ind_tipo_log => 2,
                        pr_des_log => 'Coop. '||rw_crapcop.cdcooper||' conta: '||rw_craplat.nrdconta|| 
                                      ' Erro: '|| vr_dscritic );
                                                     
              CONTINUE;                                         
            END IF;
            
          END IF; -- Fim IF vr_tab_sald 
        END IF; -- fim if controle ultimo registro da conta
        
      END LOOP;
      
      -- Incluir no log totalizador da coop
      pc_gera_log(pr_des_log => 'Coop.:'||to_char(rw_crapcop.cdcooper,90) ||
                                ' Qtd Tar.Pendente:'||to_char(vr_qttotcop,'99G999G990') ||
                                ' Qtd Tar.Debitada:'||to_char(vr_qtretok,'99G999G990') ||
                                ' Qtd Tar.Deb.Parcial:'||to_char(vr_qtretpar,'99G999G990'));
      
    END LOOP;
    
-- ATUALIZAR CRAPLAT BAIXADOS
    BEGIN
      FORALL idx IN 1..vr_tab_craplat_baixado.COUNT SAVE EXCEPTIONS
        UPDATE craplat 
        SET craplat.insitlat = vr_tab_craplat_baixado(idx).insitlat,
            craplat.cdopeest = vr_tab_craplat_baixado(idx).cdopeest,
            craplat.dtdestor = vr_tab_craplat_baixado(idx).dtdestor,
            craplat.cdmotest = vr_tab_craplat_baixado(idx).cdmotest,
            craplat.dsjusest = vr_tab_craplat_baixado(idx).dsjusest
        WHERE  craplat.rowid = vr_tab_craplat_baixado(idx).vr_rowid;     
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro de atualização na CRAPLAT (1). ERRO:' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_saida;
    END;

 
	
	
    -- informar no log o final do processo    
    pc_gera_log(pr_des_log => 'Final da execucao: '||
                              (CASE pr_cdcooper
                               WHEN 3 THEN 'Todas as coop.'
                               ELSE 'Coop. '||pr_cdcooper END) ||' periodo inicio ' ||
                               nvl(to_char(vr_dtinicio,'DD/MM/RRRR'),'nao definida')||
                               ' final '|| nvl(to_char(vr_dtafinal,'DD/MM/RRRR'),'nao definida')
                               );

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
                                                 
      pr_dscritic := vr_dscritic;                                           
      -- Efetuar commit
      COMMIT;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || pr_dscritic );

      -- Efetuar rollback
      ROLLBACK;
  END pc_deb_tarifa_pend;   

  /* Efetua cobrança de tarifa */
  PROCEDURE pc_cobra_tarifa_imgchq (pr_cdagechq  IN NUMBER
                            ,pr_nrctachq  IN NUMBER
                            ,pr_xmllog    IN VARCHAR2             --> XML com informac?es de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                            ,pr_retxml    IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  /* ............................................................................

     Programa: pc_cobra_tarifa_imgchq
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lombardi
     Data    : Agosto/2015                     Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Efetua cobrança de tarifa

     Alteracoes: ----

  ............................................................................ */

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    
    CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrctachq IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrctachq;
    
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Variaveis extraídas do log
    vr_cdcooper INTEGER := 0;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_cdoperad VARCHAR2(100);
    vr_chegoaki VARCHAR2(100);
    
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_hasfound BOOLEAN;
    
    vr_cdhistor      INTEGER;
    vr_cdhisest      NUMBER;
    vr_vltarifa      NUMBER;
    vr_dtdivulg      DATE;
    vr_dtvigenc      DATE;
    vr_cdfvlcop      INTEGER;
    vr_tab_erro      GENE0001.typ_tab_erro;
    vr_rowid_craplat ROWID;
    vr_cdbattar      VARCHAR2(10);
    
  BEGIN         
    
    CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                   ,pr_cdcooper => vr_cdcooper
                                   ,pr_nmdatela => vr_nmdatela
                                   ,pr_nmeacao  => vr_nmeacao
                                   ,pr_cdagenci => vr_cdagenci
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_idorigem => vr_idorigem
                                   ,pr_cdoperad => vr_cdoperad
                                   ,pr_dscritic => vr_dscritic);
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    OPEN cr_crapass(vr_cdcooper, pr_nrctachq);
    FETCH cr_crapass INTO rw_crapass;
    vr_hasfound := cr_crapass%FOUND;
    CLOSE cr_crapass;
    IF vr_hasfound THEN
      IF rw_crapass.inpessoa = 1 THEN
        vr_cdbattar := 'COPIADOCPF';
      ELSE
        vr_cdbattar := 'COPIADOCPJ';
      END IF;
    ELSE
      vr_cdcritic := 9;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    
    pc_carrega_dados_tar_vigente (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa
                                 ,pr_cdbattar => vr_cdbattar   --Codigo Tarifa
                                 ,pr_vllanmto => 0             --Valor Lancamento
                                 ,pr_cdprogra => 'IMGCHQ'      --Codigo Programa
                                 ,pr_cdhistor => vr_cdhistor   --Codigo Historico
                                 ,pr_cdhisest => vr_cdhisest   --Historico Estorno
                                 ,pr_vltarifa => vr_vltarifa   --Valor tarifa
                                 ,pr_dtdivulg => vr_dtdivulg   --Data Divulgacao
                                 ,pr_dtvigenc => vr_dtvigenc   --Data Vigencia
                                 ,pr_cdfvlcop => vr_cdfvlcop   --Codigo faixa valor cooperativa
                                 ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                 ,pr_dscritic => vr_dscritic   --Descricao Critica
                                 ,pr_tab_erro => vr_tab_erro); --Tabela de erros
    
    -- Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      -- Se possui erro no vetor
      IF vr_tab_erro.Count > 0 THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := '(2) Nao foi possivel carregar a tarifa.';
      END IF;
      -- Levantar Excecao
      RAISE vr_exc_saida;
    END IF;
    
    pc_cria_lan_auto_tarifa (pr_cdcooper => vr_cdcooper
                            ,pr_nrdconta => pr_nrctachq
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_cdhistor => vr_cdhistor
                            ,pr_vllanaut => vr_vltarifa
                            ,pr_cdoperad => 1
                            ,pr_cdagenci => 1
                            ,pr_cdbccxlt => 100
                            ,pr_nrdolote => 10136
                            ,pr_tpdolote => 0
                            ,pr_nrdocmto => 0
                            ,pr_nrdctabb => vr_cdcooper
                            ,pr_nrdctitg => 0
                            ,pr_cdpesqbb => ''
                            ,pr_cdbanchq => 85
                            ,pr_cdagechq => pr_cdagechq
                            ,pr_nrctachq => vr_cdcooper
                            ,pr_flgaviso => FALSE
                            ,pr_tpdaviso => 0
                            ,pr_cdfvlcop => vr_cdfvlcop
                            ,pr_inproces => rw_crapdat.inproces
                            ,pr_rowid_craplat => vr_rowid_craplat
                            ,pr_tab_erro => vr_tab_erro
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
    -- Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      -- Se possui erro no vetor
      IF vr_tab_erro.Count > 0 THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel lancar a tarifa.';
      END IF;
      -- Levantar Excecao
      RAISE vr_exc_saida;
    END IF;
    
    -- Salvar informações atualizadas
    COMMIT;
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'Dados'
                          ,pr_posicao => 0
                          ,pr_tag_nova => 'ConfereDados'
                          ,pr_tag_cont => 'Lançamento efetuado com sucesso!'
                          ,pr_des_erro => vr_dscritic);
                          
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
        
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;        

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro Geral no Lancamento de Tarifa: ' || SQLERRM || ' ' || vr_chegoaki;
        
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;  
  END pc_cobra_tarifa_imgchq;
  
    /*função para verificar se operação de saque foi realizada no intervalo definido */
  Function f_verifica_intervalo_saque(p_data_operacao date
                                     ,p_nrdconta number
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE)     --> Descricao da critica
  --criada por Valéria (Supero)  em outubro/2018
  --intervalo:deve ser informado em minutos e refere-se ao período para verificação de saldos realizados
  --data em que ocorreu a operação
  return number
  as
    ------------------- CURSOR --------------------
    CURSOR cr_pat_pco IS
      SELECT b.dsconteu
      FROM cecred.crappat a, cecred.crappco b
      WHERE a.NMPARTAR LIKE 'TEMPO_GRATUIDADE_SAQUE'
        AND a.cdpartar = b.cdpartar
        AND rownum = 1;
        
    CURSOR cr_operacoes_diarias(pr_data_operacao DATE,
                                pr_nrdconta NUMBER,
                                pr_dsconteu crappco.dsconteu%TYPE) IS
    SELECT COUNT(*)
    FROM cecred.tbcc_operacoes_diarias op
    WHERE op.cdoperacao = 1
      AND op.nrdconta = pr_nrdconta
      AND op.hroperacao BETWEEN (pr_data_operacao - pr_dsconteu / 1440) AND (pr_data_operacao + pr_dsconteu /1440)
      AND op.hroperacao <> pr_data_operacao;
    
    ------------------ VARIAVEIS ------------------
    vr_dsconteu crappco.dsconteu%TYPE;
    vr_retorno number;
    
    -- Variaveis de critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida  EXCEPTION;
    vr_exc_null  EXCEPTION;
    
  begin
      begin
        --parametro de intervalo cadastrado 
        OPEN cr_pat_pco();
        FETCH cr_pat_pco INTO vr_dsconteu;
        -- Se não encontrar
        IF cr_pat_pco%NOTFOUND THEN
          -- Fechar o cursor pois efetuaremos raise
          CLOSE cr_pat_pco;
          -- Montar mensagem de critica
          vr_cdcritic := 1;

          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_pat_pco;
        END IF;
        
        OPEN cr_operacoes_diarias(pr_data_operacao => p_data_operacao,
                                  pr_nrdconta => p_nrdconta,
                                  pr_dsconteu => vr_dsconteu);
        FETCH cr_operacoes_diarias INTO vr_retorno;
        -- Se não encontrar
        IF cr_operacoes_diarias%NOTFOUND THEN
          -- Fechar o cursor pois efetuaremos raise
          CLOSE cr_operacoes_diarias;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_operacoes_diarias;
        END IF;
        
        if vr_retorno > 0 then
          return 1; -- possui saques no intervarlo informado
        else
          return 0; -- não possui saque no intervalo informado;
        end if;
      exception
          when no_data_found then 
            dbms_output.put_line('Intervalo de saque não cadastrado');
      end;
  end f_verifica_intervalo_saque;
  /* Efetua verificacao para cobrancas de tarifas sobre operacoes */
  PROCEDURE pc_verifica_tarifa_operacao(pr_cdcooper IN NUMBER                     --> Codigo da Cooperativa
                                       ,pr_cdoperad IN VARCHAR2                   --> Codigo Operador
                                       ,pr_cdagenci IN INTEGER                    --> Codigo Agencia
                                       ,pr_cdbccxlt IN INTEGER                    --> Codigo banco caixa
                                       ,pr_dtmvtolt IN DATE                       --> Data Lancamento
                                       ,pr_cdprogra IN crapprg.cdprogra%TYPE      --> Nome do Programa que chama a rotina
                                       ,pr_idorigem IN INTEGER                    --> Identificador Origem(1-AYLLOS,2-CAIXA,3-INTERNET,4-TAA,5-AYLLOS WEB,6-URA)
                                       ,pr_nrdconta IN INTEGER                    --> Numero da Conta
                                       ,pr_tipotari IN INTEGER                    --> Tipo de Tarifa(1-Saque,2-Consulta)
                                       ,pr_tipostaa IN INTEGER                    --> Tipo de TAA que foi efetuado a operacao(0-Cooperativas Filiadas,1-BB, 2-Banco 24h, 3-Banco 24h compartilhado, 4-Rede Cirrus)
                                       ,pr_qtoperac IN INTEGER                    --> Quantidade de registros da operação (Custódia, contra-ordem, folhas de cheque)
                                       ,pr_nrdocumento IN NUMBER default null     --> numero do documento (somente para saque)
                                       ,pr_hroperacao  IN NUMBER default null     --> hora de realização da operação de saque
                                       ,pr_qtacobra OUT INTEGER                   --> Quantidade de registros a cobrar tarifa na operação
                                       ,pr_fliseope OUT INTEGER                   --> Flag indica se ira isentar tarifa:0-Não isenta,1-Isenta
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE     --> Descricao da critica        
                                       ) IS

    /* ............................................................................

     Programa: pc_verifica_tarifa_operacao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Jean Michel
     Data    : Setembro/2015                     Ultima atualizacao: 17/01/2019

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Efetua verificacao de tarifas e efetua cobrança caso necessário

     Alteracoes: 26/11/2015 - Alterado parametro pr_dtmvtolt da 
                              TARI0001.pc_cria_lan_auto_tarifa (Jean Michel).
                                      
                 14/12/2015 - Incluido tratamento para inpessoa = 3 (Jean Michel).

				 10/02/2016 - Alteracao de parametro Fato Geradorde, rw_crapdat.dtmvtolt para
							  pr_dtmvtolt, SD 397975 (Jean Michel).

                 04/04/2016 - Inclusão de novos parametros, Prj. 218-2 Tarifas (Jean Michel).             

                 14/12/2018 - Andreatta - Mouts : Ajustar para utilizar fn_Sequence e 
                             não mais max na busca no nrsequen para tbcc_operacoes_diarias            

				 17/01/2019 - SCTASK0043529 - Inclusao dos campos da chave primaria da
                              TBCC_OPERACOES_DIARIAS no log, incluido tambem um indentificador
                              nas excecoes para facilitar a localizacao do erro gerado.

  ............................................................................ */

    ------------------- CURSOR --------------------
    CURSOR cr_crapass IS
      SELECT
        ass.cdcooper
       ,ass.nrdconta
       ,ass.inpessoa
      FROM
        crapass ass
      WHERE
            ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;    

    -- alterado por Valéria Supero out/2018
    --se tipo de operação = 1 (saque) verifica se o flag para determinar o saque foi descontado do pacote ou não (flag fldescontapacote)
    --somente não será descontado se estiver no intervalo de 30min e ou quando houver estorno do saque
    CURSOR cr_tbcc_operacoes_diarias(pr_tpoperacao tbcc_operacoes_diarias.cdoperacao%TYPE) IS

      SELECT
        nvl(sum(tbc2.soma),0)       AS numregis
      from
      (select tbc.fldescontapacote, tbc.nrsequen,
              (CASE WHEN (tbc.cdoperacao = 1 and tbc.fldescontapacote = 1)
                  THEN 1
                  WHEN (tbc.cdoperacao = 1 and tbc.fldescontapacote = 0)
                  THEN 0
                  ELSE 1
               END) soma
      FROM
        tbcc_operacoes_diarias tbc
      WHERE
            tbc.cdcooper = pr_cdcooper
        AND tbc.nrdconta = pr_nrdconta
        and ((pr_tpoperacao IN(1) AND  tbc.cdoperacao IN(1)) OR tbc.cdoperacao = pr_tpoperacao)
        AND TO_CHAR(tbc.dtoperacao,'MM/RRRR') = TO_CHAR(pr_dtmvtolt,'MM/RRRR')) tbc2;

    rw_tbcc_operacoes_diarias cr_tbcc_operacoes_diarias%ROWTYPE;

    -- Verifica pacote de tarifas
    CURSOR cr_tbtarif_contas_pacote(pr_cdcooper crapcop.cdcooper%TYPE
                                   ,pr_nrdconta crapass.nrdconta%TYPE
                                   ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT cta.cdcooper
            ,cta.nrdconta
            ,cta.cdpacote
        FROM tbtarif_contas_pacote cta
       WHERE cta.cdcooper = pr_cdcooper
         AND cta.nrdconta = pr_nrdconta
         AND cta.flgsituacao = 1
         AND cta.dtinicio_vigencia <= pr_dtmvtolt;

    rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;

    --Selecionar faixa valor por cooperativa
    CURSOR cr_crapfco(pr_cdfvlcop IN crapfco.cdfvlcop%TYPE) IS
      SELECT crapfco.cdfaixav
        FROM crapfco
       WHERE crapfco.cdfvlcop = pr_cdfvlcop;

    rw_crapfco cr_crapfco%ROWTYPE;

    -- Consultar faixas de valores
    CURSOR cr_crapfvl(pr_cdfaixav IN crapfvl.cdfaixav%TYPE) IS
      SELECT crapfvl.cdtarifa
        FROM crapfvl
       WHERE crapfvl.cdfaixav = pr_cdfaixav;

    rw_crapfvl cr_crapfvl%ROWTYPE;

    CURSOR cr_tbtarif_servicos(pr_cdpacote tbtarif_servicos.cdpacote%TYPE
                              ,pr_cdtarif  tbtarif_servicos.cdtarifa%TYPE) IS
    SELECT tbtarif_servicos.qtdoperacoes 
      FROM tbtarif_servicos
     WHERE tbtarif_servicos.cdpacote = pr_cdpacote
       AND tbtarif_servicos.cdtarifa = pr_cdtarif;

    rw_tbtarif_servicos cr_tbtarif_servicos%ROWTYPE;   

    --Tipo de Dados para cursor data
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    
    CURSOR cr_lat_cdlantar(pr_rowid ROWID) IS
      SELECT cdlantar
      FROM   cecred.craplat
      WHERE ROWID = pr_rowid;
      
    ------------------ VARIAVEIS ------------------
    
    -- Variaveis de critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida  EXCEPTION;
    vr_exc_null  EXCEPTION;
    
    -- Variaveis locais
    vr_cdbattar crapbat.cdbattar%TYPE;
    vr_dsconteu VARCHAR(100); --> Auxiliar para retornar da funcao de busca de parametro
    vr_des_erro VARCHAR2(100);
    vr_nrsequen tbcc_operacoes_diarias.nrsequen%TYPE := 0;
    vr_dserropk VARCHAR(200);
    vr_tab_erro GENE0001.typ_tab_erro;
    vr_rowid_craplat ROWID;
    vr_cdlantar number;
    vr_rowid_insert ROWID;
    vr_hroperacao_aux varchar2(100);
    vr_hroperacao date;

    vr_cdhistor INTEGER; --Codigo Historico
    vr_nrdolote INTEGER; --Codigo Lote
    vr_cdhisest NUMBER;  --Historico Estorno
    vr_vltarifa NUMBER;  --Valor tarifa
    vr_dtdivulg DATE;    --Data Divulgacao
    vr_dtvigenc DATE;    --Data Vigencia
    vr_cdfvlcop INTEGER; --Codigo faixa valor cooperativa
    vr_cdparame VARCHAR2(10);
    vr_cdbatsaq VARCHAR2(50);
    vr_qtoperac INTEGER := 0;
    vr_saqativo BOOLEAN := FALSE;
    vr_qtdopera INTEGER := 0;

  BEGIN
                                  
    --  hora da operação será a data do movimento concatenato com a hora extraída do sysdate (adicionado por Valéria Supero out/2018)
   select cecred.gene0002.fn_converte_time_data(pr_nrsegs => pr_hroperacao,
                                                   pr_tipsaida => 'S')
    into vr_hroperacao_aux
    from dual;

    vr_hroperacao_aux := to_char(pr_dtmvtolt,'DD/MM/YYYY') || ' ' ||vr_hroperacao_aux;
    vr_hroperacao := to_date(vr_hroperacao_aux,'DD/MM/YYYY HH24:MI:SS');

    ---------------------------------------------------------------------------------------------------------------------------------
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      RAISE vr_exc_saida;
    END IF;
    
    CLOSE cr_crapass;

    IF rw_crapass.inpessoa = 3 THEN
      RAISE vr_exc_null;
    END IF;

    -- Inicializa a variavel utilizada nos EXCEPTIONS
    vr_dserropk := 'CDCOOPER = '     || pr_cdcooper ||
                   '; NRDCONTA = '   || pr_nrdconta ||
                   '; CDOPERACAO = ' || pr_tipotari ||
                   '; DTOPERACAO = ' || TO_CHAR(pr_dtmvtolt,'DD/MM/YYYY');

    pr_fliseope := 0; --- Não isentar tarifa
    pr_qtacobra := 0;
      
    -- Verificar se existe pacote de tarifas ativo/vigente na tabela tbtarif_contas_pacote:   
    OPEN cr_tbtarif_contas_pacote(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);

    FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;
    
    IF cr_tbtarif_contas_pacote%NOTFOUND THEN
      IF pr_tipotari NOT IN(1,2) THEN --- Saque e Consulta
        --Retorna para o programa que chamou, e executa cobrança de tarifa atual.
        CLOSE cr_tbtarif_contas_pacote;
        RAISE vr_exc_null;
      END IF;   
    END IF;
    
    IF pr_tipotari = 1 THEN -- SAQUE
      
      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdparame := 'SAQISENTPF';
        vr_cdbatsaq := 'SAQUEPACPF';  /* Tarifa do pacote */ 
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdparame := 'SAQISENTPJ';
        vr_cdbatsaq := 'SAQUEPACPJ';  /* Tarifa do pacote */ 
      END IF;

      vr_nrdolote := 10137;

      CASE pr_idorigem
        WHEN 2 THEN -- Caixa Online
          IF pr_tipostaa = 0  THEN --Tipo de saque avulso com cartao.
          IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
            vr_cdbattar := 'SAQUEPREPF';
          ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
            vr_cdbattar := 'SAQUEPREPJ';
              END IF;
           ELSE   
             IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
                vr_cdbattar := 'SAQUEAVUPF';
              ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
                vr_cdbattar := 'SAQUEAVUPJ';
           END IF;
          END IF;
        WHEN 4 THEN -- TAA
          CASE pr_tipostaa
            WHEN 0 THEN -- Cooperativas Filiadas
              IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
                vr_cdbattar := 'SAQUETAAPF';
              ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
                vr_cdbattar := 'SAQUETAAPJ';
              END IF;
            WHEN 1 THEN -- BB
              IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
                vr_cdbattar := 'SAQCRTBBPF';
              ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
                vr_cdbattar := 'SAQCRTBBPJ';
              END IF;
            WHEN 2 THEN -- Banco 24h
              IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
                vr_cdbattar := 'SAQBAN24PF';
              ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
                vr_cdbattar := 'SAQBAN24PJ';
              END IF;
            WHEN 3 THEN -- Banco 24h compartilhado
              IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
                vr_cdbattar := 'SAQREDCOPF';
              ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
                vr_cdbattar := 'SAQREDCOPJ';
              END IF;
            WHEN 4 THEN -- Rede Cirrus
              IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
                vr_cdbattar := 'SAQCIRRUPF';
              ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
                vr_cdbattar := 'SAQCIRRUPJ';
              END IF;
            ELSE
              -- Origem desconhecida
              vr_dscritic := 'Chamada de origem desconhecida.';
              RAISE vr_exc_saida; 
          END CASE;
        ELSE
          -- Origem desconhecida
          vr_dscritic := 'Origem desconhecida.';
          RAISE vr_exc_saida;
      END CASE;      
    ELSIF pr_tipotari = 2 THEN -- Trata tarifa apenas para CONSULTAS com cartão CECRED Bancoob

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdparame := 'CONISENTPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdparame := 'CONISENTPJ';
      END IF;

      vr_nrdolote := 10138;

      CASE pr_idorigem
        WHEN 4 THEN -- TAA
          CASE pr_tipostaa
            WHEN 2 THEN -- Banco 24h
              IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
                vr_cdbattar := 'CONBAN24PF';
              ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
                vr_cdbattar := 'CONBAN24PJ';
              END IF;
            WHEN 3 THEN -- Banco 24h compartilhado
              IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
                vr_cdbattar := 'CONREDCOPF';
              ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
                vr_cdbattar := 'CONREDCOPJ';
              END IF;
            WHEN 4 THEN -- Rede Cirrus
              IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
                vr_cdbattar := 'CONCIRRUPF';
              ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
                vr_cdbattar := 'CONCIRRUPJ';
              END IF;
        ELSE
          -- Origem desconhecida
          vr_dscritic := 'Chamada de origem desconhecida.';
              RAISE vr_exc_saida;
          END CASE;
        ELSE
          -- Origem desconhecida
          vr_dscritic := 'Origem desconhecida.';
          RAISE vr_exc_saida;   
      END CASE;
    ELSIF pr_tipotari = 3 THEN -- CUSTODIA DE CHEQUE 

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'CUSTDCTOPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'CUSTDCTOPJ';
    END IF;
    ELSIF pr_tipotari = 4 THEN -- CONTRA ORDEM

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'CONTRORDPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'CONTRORDPJ';
      END IF;
    ELSIF pr_tipotari = 5 THEN -- TALONARIO DE CHEQUE

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'FOLHACHQPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'FOLHACHQPJ';
      END IF;    
    ELSIF pr_tipotari = 6 THEN -- EXTRATO MENSAL PRESENCIAL

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'EXTMEPREPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'EXTMEPREPJ';
      END IF; 
    ELSIF pr_tipotari = 7 THEN -- EXTRATO MENSAL NO TAA

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'EXTMETAAPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'EXTMETAAPJ';
      END IF;
    ELSIF pr_tipotari = 8 THEN -- EXTRATO POR PERIODO PRESENCIAL

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'EXTPEPREPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'EXTPEPREPJ';
      END IF;
    ELSIF pr_tipotari = 9 THEN -- EXTRATO POR PERIODO NO TAA

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'EXTPETAAPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'EXTPETAAPJ';
      END IF;
    ELSIF pr_tipotari = 10 THEN -- DOC

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'DOCCAIXAPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'DOCCAIXAPJ';
      END IF;
    ELSIF pr_tipotari = 11 THEN -- TED PRESENCIAL

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'TEDCAIXAPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'TEDCAIXAPJ';
      END IF;
    ELSIF pr_tipotari = 12 THEN -- TED ELETRONICA

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'TEDELETRPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'TEDELETRPJ';
      END IF;
    ELSIF pr_tipotari = 13 THEN -- TRANSFERENCIA NA MESMA COOPERATIVA

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'TRANSPOPPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'TRANSPOPPJ';
      END IF;
    ELSIF pr_tipotari = 14 THEN -- SEGUNDA VIA DE CARTAO MAGNETICO

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := '2VCARMAGPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := '2VCARMAGPJ';
      END IF;
    ELSIF pr_tipotari = 15 THEN -- CONTA INTEGRACAO

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'TFCTAITGPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'TFCTAITGPJ';
      END IF; 
    ELSIF pr_tipotari = 16 THEN -- DESCONTO DE TITULO

      IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'DSTBORDEPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'DSTBORDEPJ';
      END IF;  
    ELSIF pr_tipotari = 17 THEN -- DESCONTO DE CHEQUE

	  IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
        vr_cdbattar := 'DSCCHQBOPF';
      ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
        vr_cdbattar := 'DSCCHQBOPJ';
      END IF; 
/* Prieto -- imagem de cheque */
    ELSIF pr_tipotari = 23 THEN -- IMAGEM DE CHEQUE ONLINE
       IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'IMGCHQOPF';
       ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'IMGCHQOPJ';
       END IF;  
    END IF;
      
    IF cr_tbtarif_contas_pacote%FOUND THEN

      CLOSE cr_tbtarif_contas_pacote;

      TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                           ,pr_cdbattar => CASE pr_tipotari WHEN 1 THEN vr_cdbatsaq ELSE vr_cdbattar END
                                           ,pr_vllanmto => 0  -- 
                                           ,pr_cdprogra => '' --
                                           ,pr_cdhistor => vr_cdhistor 
                                           ,pr_cdhisest => vr_cdhisest 
                                           ,pr_vltarifa => vr_vltarifa 
                                           ,pr_dtdivulg => vr_dtdivulg 
                                           ,pr_dtvigenc => vr_dtvigenc
                                           ,pr_cdfvlcop => vr_cdfvlcop
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           ,pr_tab_erro => vr_tab_erro);

      -- Verifica se Houve Erro no Retorno
      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 OR vr_tab_erro.count > 0 THEN
        -- Envio Centralizado de Log de Erro
        IF vr_tab_erro.count > 0 THEN

          -- Recebe Descrição do Erro
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
        RAISE vr_exc_saida;
      END IF;
      
      OPEN cr_crapfco(pr_cdfvlcop => vr_cdfvlcop);

      FETCH cr_crapfco INTO rw_crapfco;

      IF cr_crapfco%NOTFOUND THEN
        CLOSE cr_crapfco;
        vr_cdcritic := 0;
        vr_dscritic := 'Registro de ligacao entre faixas de valores das tarifas e cooperativa nao encontrado.';  
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapfco;
      END IF;

      OPEN cr_crapfvl(pr_cdfaixav => rw_crapfco.cdfaixav);

      FETCH cr_crapfvl INTO rw_crapfvl;
      
      IF cr_crapfvl%NOTFOUND THEN
        CLOSE cr_crapfvl;
        vr_cdcritic := 0;
        vr_dscritic := 'Registro de faixas de tarifa nao encontrado.';  
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapfvl;
      END IF;

      OPEN cr_tbtarif_servicos(pr_cdpacote => rw_tbtarif_contas_pacote.cdpacote
                              ,pr_cdtarif  => rw_crapfvl.cdtarifa);

      FETCH cr_tbtarif_servicos INTO rw_tbtarif_servicos;

      IF cr_tbtarif_servicos%NOTFOUND THEN

        CLOSE cr_tbtarif_servicos;

        IF pr_tipotari NOT IN(1,2) THEN -- Operação de saque ou consulta
          -- Retorna para o programa que chamou, e efetua cobrança de tarifa atual.
          RAISE vr_exc_null;
        END IF;   
      ELSE
        CLOSE cr_tbtarif_servicos;

        IF pr_tipotari IN(1) THEN -- Operação de saque
           vr_saqativo := TRUE; -- Possui servico de saque ativo
        END IF;

        -- Verifica quantidade de operacoes
        IF pr_qtoperac > 0 THEN
        
          LOOP
            EXIT WHEN pr_qtoperac = vr_qtoperac;
            
            -- Consulta quantidade de saques já efetuados
            OPEN cr_tbcc_operacoes_diarias(pr_tpoperacao => pr_tipotari);

            FETCH cr_tbcc_operacoes_diarias INTO rw_tbcc_operacoes_diarias;
            CLOSE cr_tbcc_operacoes_diarias;
            
            vr_nrsequen := fn_sequence('TBCC_OPERACOES_DIARIAS','NRSEQUEN',to_char(pr_cdcooper)||';'||to_char(pr_nrdconta)||';'||to_char(pr_tipotari)||';'||to_char(pr_dtmvtolt,'dd/mm/rrrr'));
            vr_qtdopera := rw_tbtarif_servicos.qtdoperacoes;

            IF rw_tbcc_operacoes_diarias.numregis < rw_tbtarif_servicos.qtdoperacoes
               --adicionado por valéria (supero) - 10/2018
               --também não será tributado se o for operação do tipo saque dentro de intervalo de 30 mim
               OR (pr_tipotari = 1
                   AND TARI0001.f_verifica_intervalo_saque(vr_hroperacao
                                                          ,pr_nrdconta
                                                          ,vr_cdcritic
                                                          ,vr_dscritic) = 1)
               AND NVL(vr_cdcritic,0) = 0 THEN --alterar

              -- INSERE NOVO REGISTRO SEM TRIBUTACAO
              BEGIN
                INSERT
                 INTO tbcc_operacoes_diarias(
                    cdcooper
                   ,nrdconta
                   ,cdoperacao
                   ,dtoperacao
                   ,nrsequen
                   ,flgisencao_tarifa
                   ,fldescontapacote
                   ,hroperacao
                   ,nrdocmto
                   )
                 VALUES(
                    pr_cdcooper
                   ,pr_nrdconta
                   ,pr_tipotari
                   ,pr_dtmvtolt
                   ,vr_nrsequen
                   ,0
                   ,1 -- desconta do pacote
                   ,vr_hroperacao
                   ,nvl(pr_nrdocumento,0)
                   ) returning rowid into vr_rowid_insert;

                   --caso tenha ficado isenta devido ao intervalo de 30 min não será descontado do pacote
                   IF (pr_tipotari = 1
                       AND TARI0001.f_verifica_intervalo_saque(vr_hroperacao
                                                              ,pr_nrdconta
                                                              ,vr_cdcritic
                                                              ,vr_dscritic) = 1)
                      AND NVL(vr_cdcritic,0) = 0 THEN
                      
                     update tbcc_operacoes_diarias
                     set fldescontapacote = 0
                     where rowid = vr_rowid_insert;
                   
                   END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := '01 - Erro ao inserir registro de lancamento de saque(TBCC_OPERACOES_DIARIAS). ' ||
                                 vr_dserropk     ||
                                 '; NRSEQUEN = ' || vr_nrsequen ||
                                 '. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;                 
              pr_fliseope := 1; -- Não tarifar    
            ELSE   
              IF pr_tipotari NOT IN(1,2) THEN --- saque e consulta        
                
                -- INSERE NOVO REGISTRO COM TRIBUTACAO
                BEGIN
                  INSERT
                    INTO tbcc_operacoes_diarias(
                       cdcooper
                      ,nrdconta
                      ,cdoperacao
                      ,dtoperacao
                      ,nrsequen
                      ,flgisencao_tarifa
                      ,fldescontapacote
                      ,hroperacao
                   	  ,nrdocmto)
                    VALUES(
                       pr_cdcooper
                      ,pr_nrdconta
                      ,pr_tipotari
                      ,pr_dtmvtolt
                      ,vr_nrsequen
                      ,1
                      ,1
                      ,vr_hroperacao
                      ,nvl(pr_nrdocumento,0)
                   );
                                      --caso tenha ficado isenta devido ao intervalo de 30 min não será descontado do pacote
                   IF (pr_tipotari = 1
                       AND TARI0001.f_verifica_intervalo_saque(vr_hroperacao
                                                              ,pr_nrdconta
                                                              ,vr_cdcritic
                                                              ,vr_dscritic) = 1)
                      AND NVL(vr_cdcritic,0) = 0 THEN
                      
                     update tbcc_operacoes_diarias
                     set fldescontapacote = 0
                     where rowid = vr_rowid_insert;
                   
                   END IF;

                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := '02 - Erro ao inserir registro de lancamento de saque(TBCC_OPERACOES_DIARIAS). ' ||
                                   vr_dserropk     ||
                                   '; NRSEQUEN = ' || vr_nrsequen ||
                                   '. Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END; 
                  
                pr_qtacobra := pr_qtacobra + 1;
                pr_fliseope := 0; -- Tarifar      
              END IF;
    END IF;

            vr_qtoperac := vr_qtoperac + 1;     

          END LOOP;

          RAISE vr_exc_null;
        ELSE
          /**/
          -- Consulta quantidade de saques já efetuados
          OPEN cr_tbcc_operacoes_diarias(pr_tpoperacao => pr_tipotari);

          FETCH cr_tbcc_operacoes_diarias INTO rw_tbcc_operacoes_diarias;
          CLOSE cr_tbcc_operacoes_diarias;
            
          vr_nrsequen := fn_sequence('TBCC_OPERACOES_DIARIAS','NRSEQUEN',to_char(pr_cdcooper)||';'||to_char(pr_nrdconta)||';'||to_char(pr_tipotari)||';'||to_char(pr_dtmvtolt,'dd/mm/rrrr'));
          vr_qtdopera := rw_tbtarif_servicos.qtdoperacoes;

          IF rw_tbcc_operacoes_diarias.numregis < rw_tbtarif_servicos.qtdoperacoes
             --adicionado por valéria (supero) - 10/2018
             --também não será tributado se o for operação do tipo saque dentro de intervalo de 30 mim
             OR (pr_tipotari = 1
                 AND TARI0001.f_verifica_intervalo_saque(vr_hroperacao
                                                        ,pr_nrdconta
                                                        ,vr_cdcritic
                                                        ,vr_dscritic) = 1)
             AND NVL(vr_cdcritic,0) = 0 THEN
            -- INSERE NOVO REGISTRO SEM TRIBUTACAO
            BEGIN
              INSERT
               INTO tbcc_operacoes_diarias(
                  cdcooper
                 ,nrdconta
                 ,cdoperacao
                 ,dtoperacao
                 ,nrsequen
                 ,flgisencao_tarifa
                 ,fldescontapacote
                 ,hroperacao)
               VALUES(
                  pr_cdcooper
                 ,pr_nrdconta
                 ,pr_tipotari
                 ,pr_dtmvtolt
                 ,vr_nrsequen
                 ,0
                 ,1 -- desconta do pacote
                 ,vr_hroperacao) returning rowid into vr_rowid_insert;
                   --caso tenha ficado isenta devido ao intervalo de 30 min não será descontado do pacote
                   if (pr_tipotari = 1 and TARI0001.f_verifica_intervalo_saque (vr_hroperacao
                                                                               ,pr_nrdconta
                                                                               ,vr_cdcritic
                                                                               ,vr_dscritic) = 1) then
                     update tbcc_operacoes_diarias
                     set fldescontapacote = 0
                     where rowid = vr_rowid_insert;
                   end if;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := '03 - Erro ao inserir registro de lancamento de saque(TBCC_OPERACOES_DIARIAS). ' ||
                               vr_dserropk     ||
                               '; NRSEQUEN = ' || vr_nrsequen ||
                               '. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;                 
            --vr_des_erro :=SQLERRM;
            pr_fliseope := 1; -- Não tarifar
            --Retornar para rotina que efetuou a chamada
            RAISE vr_exc_null;
          ELSE   
            IF pr_tipotari NOT IN(1,2) THEN --- saque e consulta        
                
              -- INSERE NOVO REGISTRO COM TRIBUTACAO
              BEGIN
                INSERT
                  INTO tbcc_operacoes_diarias(
                     cdcooper
                    ,nrdconta
                    ,cdoperacao
                    ,dtoperacao
                    ,nrsequen
                    ,flgisencao_tarifa
                    ,hroperacao
                    ,nrdocmto)
                  VALUES(
                     pr_cdcooper
                    ,pr_nrdconta
                    ,pr_tipotari
                    ,pr_dtmvtolt
                    ,vr_nrsequen
                    ,1
                    ,vr_hroperacao
                    ,nvl(pr_nrdocumento,0));
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := '04 - Erro ao inserir registro de lancamento de saque(TBCC_OPERACOES_DIARIAS). ' ||
                                 vr_dserropk     ||
                                 '; NRSEQUEN = ' || vr_nrsequen ||
                                 '. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END; 
               
              pr_qtacobra := pr_qtacobra + 1;
              RAISE vr_exc_null;      
            END IF;
          END IF;
          /**/
        END IF;
      END IF;
    
    ELSE
      CLOSE cr_tbtarif_contas_pacote;    
    END IF;    

    -- Verifica quantidade de saques isentos
    TARI0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                          ,pr_cdbattar => vr_cdparame
                                          ,pr_dsconteu => vr_dsconteu
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_des_erro => vr_des_erro
                                          ,pr_tab_erro => vr_tab_erro);

    -- Verifica se Houve Erro no Retorno
    IF vr_des_erro = 'NOK' OR vr_tab_erro.count > 0 OR vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
      -- Envio Centralizado de Log de Erro
      IF vr_tab_erro.count > 0 THEN

        -- Recebe Descrição do Erro
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        RAISE vr_exc_saida;
      END IF;
      RAISE vr_exc_saida;
    END IF;

    -- Consulta quantidade de saques já efetuados
    OPEN cr_tbcc_operacoes_diarias(pr_tpoperacao => pr_tipotari);

    FETCH cr_tbcc_operacoes_diarias INTO rw_tbcc_operacoes_diarias;
    CLOSE cr_tbcc_operacoes_diarias;
  
    vr_nrsequen := fn_sequence('TBCC_OPERACOES_DIARIAS','NRSEQUEN',to_char(pr_cdcooper)||';'||to_char(pr_nrdconta)||';'||to_char(pr_tipotari)||';'||to_char(pr_dtmvtolt,'dd/mm/rrrr'));

    -- Se nao possui servico de saque no pacote, verifica parametros de insencao da cooperativa
    IF NOT vr_saqativo THEN

      vr_qtdopera := rw_tbcc_operacoes_diarias.numregis;

      IF vr_qtdopera < vr_dsconteu
         -- adicionado Valéria Supero outubro/2018
         OR (pr_tipotari = 1
             AND TARI0001.f_verifica_intervalo_saque(vr_hroperacao
                                                    ,pr_nrdconta
                                                    ,vr_cdcritic
                                                    ,vr_dscritic) = 1)
         AND NVL(vr_cdcritic,0) = 0 THEN
         
        -- INSERE NOVO REGISTRO SEM TRIBUTACAO
        BEGIN
          INSERT
           INTO tbcc_operacoes_diarias(
             cdcooper
            ,nrdconta
          ,cdoperacao
            ,dtoperacao
            ,nrsequen
            ,flgisencao_tarifa
            ,fldescontapacote
            ,hroperacao)
           VALUES(
             pr_cdcooper
            ,pr_nrdconta
            ,pr_tipotari
            ,pr_dtmvtolt
            ,vr_nrsequen
            ,0
            ,1
            ,vr_hroperacao) returning rowid into vr_rowid_insert;
             --caso tenha ficado isenta devido ao intervalo de 30 min não será descontado do pacote
             if (pr_tipotari = 1 and TARI0001.f_verifica_intervalo_saque (vr_hroperacao
                                                                         ,pr_nrdconta
                                                                         ,vr_cdcritic
                                                                         ,vr_dscritic) = 1) then
               update tbcc_operacoes_diarias
               set fldescontapacote = 0
               where rowid = vr_rowid_insert;
             end if;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '05 - Erro ao inserir registro de lancamento de saque(TBCC_OPERACOES_DIARIAS). ' ||
                           vr_dserropk     ||
                           '; NRSEQUEN = ' || vr_nrsequen ||
                           '. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
        END;

        pr_fliseope := 1; -- Não tarifar
		RAISE vr_exc_null;

      END IF;

    END IF;  

    -- adicionado por Valéria Supero: se saque estiver dentro do intervalor não será tarifado
    IF (pr_tipotari = 1
        AND TARI0001.f_verifica_intervalo_saque(vr_hroperacao
                                               ,pr_nrdconta
                                               ,vr_cdcritic
                                               ,vr_dscritic) = 1)
        AND NVL(vr_cdcritic,0) = 0 THEN
        
        -- INSERE NOVO REGISTRO SEM TRIBUTACAO
    BEGIN
      INSERT
       INTO tbcc_operacoes_diarias(
         cdcooper
        ,nrdconta
      ,cdoperacao
        ,dtoperacao
        ,nrsequen
            ,flgisencao_tarifa
            ,fldescontapacote
            ,hroperacao
            )
       VALUES(
         pr_cdcooper
        ,pr_nrdconta
        ,pr_tipotari
        ,pr_dtmvtolt
        ,vr_nrsequen
            ,0
            ,0
            ,vr_hroperacao
            );
            vr_vltarifa := 0;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := '06 - Erro ao inserir registro de lancamento de saque(TBCC_OPERACOES_DIARIAS). ' ||
                       vr_dserropk     ||
                       '; NRSEQUEN = ' || vr_nrsequen ||
                       '. Erro: ' || SQLERRM;
      RAISE vr_exc_saida;
    END;
    else             -- INSERE NOVO REGISTRO COM TRIBUTACAO
        BEGIN
          INSERT
           INTO tbcc_operacoes_diarias(
             cdcooper
            ,nrdconta
          ,cdoperacao
            ,dtoperacao
            ,nrsequen
            ,flgisencao_tarifa
            ,fldescontapacote
            ,hroperacao
            ,nrdocmto
            )
           VALUES(
             pr_cdcooper
            ,pr_nrdconta
            ,pr_tipotari
            ,pr_dtmvtolt
            ,vr_nrsequen
            ,1
            ,1
            ,vr_hroperacao
            ,nvl(pr_nrdocumento,0)
            );
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := '07 - Erro ao inserir registro de lancamento de saque(TBCC_OPERACOES_DIARIAS). ' ||
                         vr_dserropk     ||
                         '; NRSEQUEN = ' || vr_nrsequen ||
                         '. Erro: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;
    end if;

    TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                         ,pr_cdbattar => vr_cdbattar
                                         ,pr_vllanmto => 0  --
                                         ,pr_cdprogra => '' --
                                         ,pr_cdhistor => vr_cdhistor
                                         ,pr_cdhisest => vr_cdhisest
                                         ,pr_vltarifa => vr_vltarifa
                                         ,pr_dtdivulg => vr_dtdivulg
                                         ,pr_dtvigenc => vr_dtvigenc
                                         ,pr_cdfvlcop => vr_cdfvlcop
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_tab_erro => vr_tab_erro);

    -- Verifica se Houve Erro no Retorno
    IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 OR vr_tab_erro.count > 0 THEN
        -- Envio Centralizado de Log de Erro
        IF vr_tab_erro.count > 0 THEN

          -- Recebe Descrição do Erro
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
        RAISE vr_exc_saida;
      END IF;

  IF vr_vltarifa > 0  THEN
      TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_cdhistor => vr_cdhistor
                                      ,pr_vllanaut => vr_vltarifa
                                      ,pr_cdoperad => 1
                                      ,pr_cdagenci => 1
                                      ,pr_cdbccxlt => 100
                                      ,pr_nrdolote => vr_nrdolote
                                      ,pr_tpdolote => 1
                                      ,pr_nrdocmto => 0
                                      ,pr_nrdctabb => pr_nrdconta
                                      ,pr_nrdctitg => 0
                                      ,pr_cdpesqbb => 'Fato gerador tarifa:' || TO_CHAR(pr_dtmvtolt,'DDMMYY')
                                      ,pr_cdbanchq => 0
                                      ,pr_cdagechq => 0
                                      ,pr_nrctachq => 0
                                      ,pr_flgaviso => FALSE
                                      ,pr_tpdaviso => 0
                                      ,pr_cdfvlcop => vr_cdfvlcop
                                      ,pr_inproces => rw_crapdat.inproces
                                      ,pr_rowid_craplat => vr_rowid_craplat
                                      ,pr_tab_erro => vr_tab_erro
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
    -----------------------------------------------------------------------------------------------------
    --atualiza o lancamento com o codigo do cdlantar (que será utilizado posteriormente para estorno da tarifa)
    --Adicionado por Valéria Supero out/2018
    OPEN cr_lat_cdlantar(pr_rowid => vr_rowid_craplat);
    FETCH cr_lat_cdlantar INTO vr_cdlantar;
    CLOSE cr_lat_cdlantar;

    IF vr_cdlantar IS NOT NULL THEN
      UPDATE cecred.tbcc_operacoes_diarias od
      SET od.cdlantar = vr_cdlantar
      WHERE od.nrsequen = vr_nrsequen
            AND od.nrdconta = pr_nrdconta
            AND od.dtoperacao = pr_dtmvtolt;
    END IF;
    ----------------------------------------------------------------------------------------------------------------
      -- Verifica se Houve Erro no Retorno
    IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 OR vr_tab_erro.count > 0 THEN
        -- Envio Centralizado de Log de Erro
        IF vr_tab_erro.count > 0 THEN

          -- Recebe Descrição do Erro
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
        RAISE vr_exc_saida;
      END IF;
    END IF;

  EXCEPTION
    WHEN vr_exc_null THEN
      pr_cdcritic := 0;
      pr_dscritic := '';
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TARI0001.pc_verifica_tarifa_operacao_v para conta '||pr_nrdconta||':'||SQLERRM;
      ROLLBACK;
  END pc_verifica_tarifa_operacao;
  
  /* Verificacao agencia da cooperativa */
  PROCEDURE pc_busca_agencia_cop(pr_cdagectl IN crapcop.cdagectl%TYPE
                                ,pr_xmllog    IN VARCHAR2             --> XML com informac?es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* ............................................................................

     Programa: pc_busca_agencia_cop
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lombardi
     Data    : Novembro/2015                     Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Verifica se a agencia da cooperativa é a mesma que a que 
                 foi passada por parametro.

     Alteracoes: ----

  ............................................................................ */

    ------------------- CURSOR --------------------
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdagectl IN crapcop.cdagectl%TYPE) IS
      SELECT cdcooper
      FROM crapcop
     WHERE cdcooper = pr_cdcooper
       AND cdagectl = pr_cdagectl;

    rw_crapcop cr_crapcop%ROWTYPE;
    ------------------ VARIAVEIS ------------------
    
    -- Variaveis extraídas do log
    vr_cdcooper INTEGER := 0;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_cdoperad VARCHAR2(100);
    
    --Variaveis de critica
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida  EXCEPTION;


    -- Variaveis locais
    vr_achou_coop crapcop.cdagectl%TYPE;
    
  BEGIN
    
    CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                   ,pr_cdcooper => vr_cdcooper
                                   ,pr_nmdatela => vr_nmdatela
                                   ,pr_nmeacao  => vr_nmeacao
                                   ,pr_cdagenci => vr_cdagenci
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_idorigem => vr_idorigem
                                   ,pr_cdoperad => vr_cdoperad
                                   ,pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    OPEN cr_crapcop (pr_cdcooper => vr_cdcooper
                    ,pr_cdagectl => pr_cdagectl);
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%FOUND THEN
      vr_achou_coop := pr_cdagectl;
    ELSE
      vr_achou_coop := 0;
    END IF;
    CLOSE cr_crapcop;
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados>' || vr_achou_coop || '</Dados>');
    
  EXCEPTION
    WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TARI0001.pc_busca_agencia_coop:'||SQLERRM;
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_agencia_cop;

  /*Efetua débitos de tarifas para contas integração*/
  PROCEDURE pc_integra_deb_tarifa (pr_cdcooper IN crapcop.cdcooper%TYPE) IS   --> Cooperativa solicitada             

    CURSOR cr_crapcop(pr_cdcooper crapass.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE (cop.cdcooper = pr_cdcooper OR pr_cdcooper IS NULL)
         AND cop.flgativo = 1
         AND cop.cdcooper <> 3;

    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE) IS
      SELECT ass.nrdconta
            ,ass.inpessoa 
        FROM crapass ass
       WHERE ass.flgctitg = 2
         AND ass.cdcooper = pr_cdcooper
         AND ass.dtdemiss IS NULL
         AND NOT EXISTS (SELECT 1
                           FROM craplcm lcm
                          WHERE ass.cdcooper = lcm.cdcooper
                            AND ass.nrdconta = lcm.nrdconta
                            AND lcm.dtmvtolt >= last_day(add_months(TRUNC(SYSDATE), -4)) + 1
                            AND lcm.cdhistor IN (444, 584))
         AND NOT EXISTS (SELECT 1
                           FROM crawcrd crd
                          WHERE ass.cdcooper = crd.cdcooper
                            AND ass.nrdconta = crd.nrdconta
                            AND cdadmcrd >= 83
                            AND cdadmcrd <= 88
                            AND insitcrd IN (4, 5));

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'TARIFA';
      
      -- Tratamento de erros
      vr_exc_erro   EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      
      -- Variaveis Tarifa
      vr_cdcooper   crapcop.cdcooper%TYPE;
      vr_cdhistpf   craphis.cdhistor%TYPE;
      vr_cdhistpj   craphis.cdhistor%TYPE;
      vr_cdhisepf   craphis.cdhistor%TYPE;
      vr_cdhisepj   craphis.cdhistor%TYPE;
      vr_vltarfpf   crapfco.vltarifa%TYPE;
      vr_vltarfpj   crapfco.vltarifa%TYPE;
      vr_cdfvlcpf   crapfco.cdfvlcop%TYPE;
      vr_cdfvlcpj   crapfco.cdfvlcop%TYPE;
      vr_dtdivupf   DATE;
      vr_dtdivupj   DATE;
      vr_dtvigepf   DATE;      
      vr_dtvigepj   DATE;      
      
      vr_cdhistor   craphis.cdhistor%TYPE;
      vr_cdhisest   craphis.cdhistor%TYPE;
      vr_dtdivulg   DATE;
      vr_dtvigenc   DATE;
      vr_cdfvlcop   crapfco.cdfvlcop%TYPE;
      vr_vlrtarif   crapfco.vltarifa%TYPE;
      vr_cdbattar   VARCHAR2(100) := ' ';
      vr_nmarqpdf   VARCHAR2(500);
      vr_listalat   CLOB;
      vr_contador   NUMBER(6);
			vr_qtacobra   INTEGER;
			vr_fliseope   INTEGER;
      
      
      -- Rowid de retorno lançamento de tarifa
      vr_rowid      ROWID;
      
      -------------------------- TABELAS TEMPORARIAS --------------------------
      -- Tabela Temporaria para erros
      vr_tab_erro GENE0001.typ_tab_erro; 
      vr_tab_tari_pend TARI0001.typ_tab_tarifas_pend;   

  BEGIN
    
      vr_contador := 0;
    
      FOR rw_crapcop IN cr_crapcop(pr_cdcooper) LOOP
        
        vr_cdcooper := rw_crapcop.cdcooper;
        vr_cdhistpf := 0;
        vr_cdhistpj := 0;
        vr_cdhisepf := 0;
        vr_cdhisepj := 0;
        vr_vltarfpf := 0;
        vr_vltarfpj := 0;
        vr_cdfvlcpf := 0;
        vr_cdfvlcpj := 0;
        vr_dtdivupf := NULL;
        vr_dtdivupj := NULL;
        vr_dtvigepf := NULL;
        vr_dtvigepj := NULL;
        
        -- Verifica se a data esta cadastrada
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Se nao encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic:= 1;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;
        
        /*Busca as informações das tarifas PF*/
        TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => rw_crapcop.cdcooper
                                             ,pr_cdbattar => 'TFCTAITGPF'
                                             ,pr_vllanmto => 0 --> faixa de valor 0..999
                                             ,pr_cdprogra => vr_cdprogra
                                             ,pr_cdhistor => vr_cdhistpf
                                             ,pr_cdhisest => vr_cdhisepf
                                             ,pr_vltarifa => vr_vltarfpf
                                             ,pr_dtdivulg => vr_dtdivupf
                                             ,pr_dtvigenc => vr_dtvigepf
                                             ,pr_cdfvlcop => vr_cdfvlcpf
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
          
        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     =>  rw_crapcop.cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic 
                                    ,pr_nmarqlog     => 'proc_message.log');
          CONTINUE;
        END IF;
        
        /*Busca as informações das tarifas PJ*/                  
        TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => rw_crapcop.cdcooper
                                             ,pr_cdbattar => 'TFCTAITGPJ'
                                             ,pr_vllanmto => 0 --> faixa de valor 0..999
                                             ,pr_cdprogra => vr_cdprogra
                                             ,pr_cdhistor => vr_cdhistpj
                                             ,pr_cdhisest => vr_cdhisepj
                                             ,pr_vltarifa => vr_vltarfpj
                                             ,pr_dtdivulg => vr_dtdivupj
                                             ,pr_dtvigenc => vr_dtvigepj
                                             ,pr_cdfvlcop => vr_cdfvlcpj
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
            
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     =>  rw_crapcop.cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic 
                                      ,pr_nmarqlog     => 'proc_message.log');
            CONTINUE;
          END IF;
        
        FOR rw_crapass IN cr_crapass(rw_crapcop.cdcooper) LOOP         
          
          IF rw_crapass.inpessoa = 1 THEN
             vr_cdhistor := vr_cdhistpf;
             vr_vlrtarif := vr_vltarfpf;
             vr_cdfvlcop := vr_cdfvlcpf;
             vr_dtdivulg := vr_dtdivupf;
             vr_dtvigenc := vr_dtvigepf;
             vr_cdfvlcop := vr_cdfvlcpf;
             vr_cdbattar := 'TFCTAITGPF';
          ELSE
             vr_cdhistor := vr_cdhistpj;
             vr_vlrtarif := vr_vltarfpj;
             vr_cdfvlcop := vr_cdfvlcpj;
             vr_dtdivulg := vr_dtdivupj;
             vr_dtvigenc := vr_dtvigepj;
             vr_cdfvlcop := vr_cdfvlcpj;  
             vr_cdbattar := 'TFCTAITGPJ';         
          END IF;   
        
				  -- Zera valor do rowid
				  vr_rowid := NULL;
				
					-- Verificar se deve ser isento de tarifa ou não
					TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => rw_crapcop.cdcooper  -- Cooperativa
																											,pr_cdoperad => '1'                  -- Operador
																											,pr_cdagenci => 1                    -- PA
																											,pr_cdbccxlt => 100                  -- Cód. Banco
																											,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento
																											,pr_cdprogra => vr_cdprogra          -- Cód. programa
																											,pr_idorigem => 7                    -- Identificador de origem
																											,pr_nrdconta => rw_crapass.nrdconta  -- Nr. da conta
																											,pr_tipotari => 15                   -- Tipo de tarifa 
																											,pr_tipostaa => 0                    -- Tipo TAA
																											,pr_qtoperac => 1                    -- Qtd. de operações
																											,pr_qtacobra => vr_qtacobra          -- Qtd. de operações cobradas
																											,pr_fliseope => vr_fliseope          -- Flag de isenção de operações 0 - não isenta/ 1 - isenta
																											,pr_cdcritic => vr_cdcritic          -- Cód. da crítica
																											,pr_dscritic => vr_dscritic);        -- Desc. da crítica
        
					-- Se ocorreu erro
					IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						-- gera log do erro ocorrido
						vr_dscritic:= vr_dscritic ||' Conta: '||gene0002.fn_mask_conta(rw_crapass.nrdconta)||' - '||vr_cdbattar;
						-- Envio centralizado de log de erro
							btch0001.pc_gera_log_batch(pr_cdcooper     =>  rw_crapcop.cdcooper
																				,pr_ind_tipo_log => 2 -- Erro tratato
																				,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
																												 || vr_cdprogra || ' --> '
																												 || vr_dscritic 
																				,pr_nmarqlog     => 'proc_message.log');
						-- Limpa valores das variaveis de critica
						vr_cdcritic:= 0;
						vr_dscritic:= NULL;                                           
						CONTINUE;
					END IF;																								
					
					-- Se não isenta tarifa
          IF vr_fliseope <> 1 THEN
				
          -- Criar Lançamento automatico tarifa
          TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => rw_crapcop.cdcooper
                                          , pr_nrdconta     => rw_crapass.nrdconta
                                          , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                          , pr_cdhistor     => vr_cdhistor
                                          , pr_vllanaut     => vr_vlrtarif
                                          , pr_cdoperad     => '1'
                                          , pr_cdagenci     => 1
                                          , pr_cdbccxlt     => 100
                                          , pr_nrdolote     => 10138
                                          , pr_tpdolote     => 1
                                          , pr_nrdocmto     => 0 /*rw_crabepr.nrctremp*/
                                          , pr_nrdctabb     => rw_crapass.nrdconta
                                          , pr_nrdctitg     => gene0002.fn_mask(rw_crapass.nrdconta,'99999999')
                                          , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crapdat.dtmvtolt,'MMYY')
                                          , pr_cdbanchq     => 0
                                          , pr_cdagechq     => 0
                                          , pr_nrctachq     => 0
                                          , pr_flgaviso     => FALSE
                                          , pr_tpdaviso     => 0
                                          , pr_cdfvlcop     => vr_cdfvlcop
                                          , pr_inproces     => rw_crapdat.inproces
                                          , pr_rowid_craplat=> vr_rowid
                                          , pr_tab_erro     => vr_tab_erro
                                          , pr_cdcritic     => vr_cdcritic
                                          , pr_dscritic     => vr_dscritic);

          --Se ocorreu erro
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= vr_tab_erro(1).cdcritic;
              vr_dscritic:= vr_tab_erro(1).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro no lancamento tarifa.';
            END IF;
            -- gera log do erro ocorrido
            vr_dscritic:= vr_dscritic ||' Conta: '||gene0002.fn_mask_conta(rw_crapass.nrdconta)||' - '||vr_cdbattar;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     =>  rw_crapcop.cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic 
                                      ,pr_nmarqlog     => 'proc_message.log');
            CONTINUE;
          END IF;
          
          END IF;          
          
          IF vr_rowid IS NOT NULL THEN
            vr_contador := vr_contador + 1;
            IF vr_listalat IS NULL THEN
               vr_listalat := to_char(vr_rowid);                               
            ELSE
              vr_listalat := vr_listalat || ';' || to_char(vr_rowid);         
            END IF; 
          END IF;
          
          --A cada 1000 registros para não ultrapassar o limite da funcao
          IF vr_contador = 1000  AND
             vr_listalat IS NOT NULL THEN
            -- Efetivar
            TARI0001.pc_debita_tarifa_online(pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_cdoperad => '1'
                                            ,pr_idorigem => 1
                                            ,pr_nmdatela => vr_cdprogra
                                            ,pr_listalat => vr_listalat
                                            ,pr_flimprim => 0
                                            ,pr_nmarqpdf => vr_nmarqpdf
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_tab_tari_pend => vr_tab_tari_pend);  
                                            
            vr_contador := 0;
            vr_listalat := NULL;
            
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              btch0001.pc_gera_log_batch(pr_cdcooper     =>  rw_crapcop.cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic 
                                        ,pr_nmarqlog     => 'proc_message.log');
              CONTINUE;
            END IF;
                                              
          END IF;
          
        END LOOP;    
        
        IF vr_listalat IS NOT NULL THEN
         
          TARI0001.pc_debita_tarifa_online(pr_cdcooper => rw_crapcop.cdcooper
                                           ,pr_cdoperad => '1'
                                           ,pr_idorigem => 1
                                           ,pr_nmdatela => vr_cdprogra
                                           ,pr_listalat => vr_listalat
                                           ,pr_flimprim => 0
                                           ,pr_nmarqpdf => vr_nmarqpdf
                                           ,pr_dscritic => vr_dscritic
                                           ,pr_tab_tari_pend => vr_tab_tari_pend);
            
          vr_listalat := NULL;
          vr_contador := 0;
          
        END IF;
        
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     =>  rw_crapcop.cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic 
                                    ,pr_nmarqlog     => 'proc_message.log');
          CONTINUE;
        END IF;
        
      END LOOP;
      
      COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_dscritic 
                                ,pr_nmarqlog     => 'proc_message.log');
      ROLLBACK;                             
    WHEN OTHERS THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_dscritic 
                                 ,pr_nmarqlog     => 'proc_message.log');
      
      ROLLBACK;
  END pc_integra_deb_tarifa;    
  
  
  --> Gerar log de monitoração de lote
  PROCEDURE pc_gera_log_lote_uso(pr_cdcooper IN craplot.cdcooper%TYPE,
                                 pr_nrdconta IN crapass.nrdconta%TYPE,
                                 pr_nrdolote IN craplot.nrdolote%TYPE,
                                 pr_flgerlog IN OUT VARCHAR2,
                                 pr_des_log  IN VARCHAR2) IS
    /* ............................................................................    
       Programa: pc_gera_log_lote_uso
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : xxxxx
       Data    : xxx/0000                        Ultima atualizacao: 23/10/2018
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que chamado
       Objetivo  : Gerar Log em arquivo       
       Disparado por:        
       Alteracoes: 
       23/10/2018 - Processo não executa hoje e negociado com o Rodrigo para não padronizar. 
                    (Envolti - Belli - REQ0011726)          
     ............................................................................ */                                 
    PRAGMA AUTONOMOUS_TRANSACTION;
    vr_lotmonit VARCHAR2(4000);
    
    
  BEGIN
    
    --> Tratamento para não carregar sempre a variavel
    IF pr_flgerlog IS NULL THEN
      pr_flgerlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                              pr_cdcooper => pr_cdcooper, 
                                              pr_cdacesso => 'GERA_LOG_LOTE_USO');
    END IF;
    
    --> Verificar se deve gerar o log
    IF pr_flgerlog = 'S' THEN
    
      vr_lotmonit := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                               pr_cdcooper => pr_cdcooper, 
                                               pr_cdacesso => 'MONIT_LOTE_USO'); 
        
      -- Verificar se deve monitorar o lote em questão
      IF gene0002.fn_existe_valor(vr_lotmonit,pr_nrdolote,',') = 'S' THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => to_char(systimestamp,'DD/MM/RRRR HH24:MI:SSFF3') 
                                                      ||' -> '||pr_des_log, 
                                   pr_nmarqlog     => 'monitlot');
      END IF;     
    END IF;
     
    COMMIT; 
  EXCEPTION 
    WHEN OTHERS THEN
         
      ROLLBACK;
      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper
                                 ,pr_ind_tipo_log => 2
                                 ,pr_des_log      => 'Erro ao gravar log de monitoramento de lote: '|| SQLERRM
                                 ,pr_nmarqlog     => 'proc_message.log');
      
  END;                               
                                 
  -- Rotina para verificar pacote de tarifas
  PROCEDURE pc_verifica_pacote_tarifas(pr_cdcooper  IN craprac.cdcooper%TYPE     --> Código da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                      ,pr_idorigem  IN NUMBER                    --> Origem
                                      ,pr_tpservic  IN NUMBER                    --> Tipo de Servico
                                      ,pr_flpacote OUT NUMBER                    --> Flag de Pacote
                                      ,pr_flservic OUT NUMBER                    --> Flag de Sevico
                                      ,pr_qtopdisp OUT NUMBER                    --> Quantidade de Operacoes Disponiveis
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descrição da crítica 

    /* .............................................................................

     Programa: pc_verifica_pacote_tarifas
     Sistema : Tarifas Bancarias
     Sigla   : TARI
     Autor   : 
     Data    :                                Ultima atualizacao: 23/10/2018

     Dados referentes ao programa:
     Frequencia: Sempre que for chamado
     Objetivo  : 
     Alteracoes:
                23/10/2018 - Padrões: Others, Modulo/Action, PC Internal Exception, PC Log Programa
                             SELECT's, Parâmetros, troca de mensagens por código                             
                               (Envolti - Belli - REQ0011726)
    ..............................................................................*/
        
    -- Cursores
    CURSOR cr_tbtarif_contas_pacote(pr_cdcooper crapcop.cdcooper%TYPE
                                   ,pr_nrdconta crapass.nrdconta%TYPE
                                   ,pr_flgsituacao tbtarif_contas_pacote.flgsituacao%TYPE
                                   ,pr_dtinicio_vigencia tbtarif_contas_pacote.dtinicio_vigencia%TYPE) IS
      SELECT pct.cdcooper
            ,pct.cdpacote
        FROM tbtarif_contas_pacote pct
       WHERE pct.cdcooper = pr_cdcooper
         AND pct.nrdconta = pr_nrdconta
         AND pct.flgsituacao = pr_flgsituacao
         AND pct.dtinicio_vigencia <= pr_dtinicio_vigencia;
    
    rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;
    
    CURSOR cr_tbtarif_servicos(pr_cdpacote tbtarif_servicos.cdpacote%TYPE
                              ,pr_cdtarifa tbtarif_servicos.cdtarifa%TYPE) IS
      SELECT serv.cdtarifa
            ,serv.qtdoperacoes
        FROM tbtarif_servicos serv
       WHERE serv.cdpacote = pr_cdpacote
         AND serv.cdtarifa = pr_cdtarifa;

    rw_tbtarif_servicos cr_tbtarif_servicos%ROWTYPE;

    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.cdcooper
            ,ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_crapfco(pr_cdfvlcop crapfco.cdfvlcop%TYPE) IS
      SELECT fco.cdfvlcop
            ,fco.cdfaixav
        FROM crapfco fco
       WHERE fco.cdfvlcop = pr_cdfvlcop;

    rw_crapfco cr_crapfco%ROWTYPE;

    CURSOR cr_crapfvl(pr_cdfaixav crapfvl.cdfaixav%TYPE) IS
      SELECT fvl.cdtarifa
        FROM crapfvl fvl
       WHERE fvl.cdfaixav = pr_cdfaixav;

    rw_crapfvl cr_crapfvl%ROWTYPE;

    CURSOR cr_tbcc_operacoes_diarias(pr_cdcooper crapcop.cdcooper%TYPE
                                    ,pr_nrdconta crapass.nrdconta%TYPE
                                    ,pr_tpoperacao tbcc_operacoes_diarias.cdoperacao%TYPE
                                    ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
    SELECT COUNT(tbc.cdcooper) AS cont 
      FROM tbcc_operacoes_diarias tbc
     WHERE tbc.cdcooper = pr_cdcooper
       AND tbc.nrdconta = pr_nrdconta
       AND tbc.cdoperacao = pr_tpoperacao
       AND tbc.flgisencao_tarifa = 0 -- Nao tarifadas
       AND TO_CHAR(tbc.dtoperacao,'MM/RRRR') = TO_CHAR(pr_dtmvtolt,'MM/RRRR');
    
    rw_tbcc_operacoes_diarias cr_tbcc_operacoes_diarias%ROWTYPE;   

    --Registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
        
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_exc_null EXCEPTION;
    vr_tab_erro GENE0001.typ_tab_erro;

    -- Variaveis de critic
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);

    vr_cdbattar VARCHAR2(10);
    vr_cdhistor craphis.cdhistor%TYPE;   
    vr_cdhisest craphis.cdhistor%TYPE;
    vr_vltarifa crapfco.vltarifa%TYPE;
    vr_dtdivulg crapdat.dtmvtolt%TYPE;
    vr_dtvigenc crapdat.dtmvtolt%TYPE;
    vr_cdfvlcop crapcop.cdcooper%TYPE;
    -- Variaveis de Log e Modulo - 23/10/2018 - REQ0011726
    vr_dsparame VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotpro VARCHAR2  (100) := 'pc_verifica_pacote_tarifas';
    vr_cdproint VARCHAR2  (100);

  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe||'.'||vr_nmrotpro;
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);    
    vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                   ', pr_nrdconta:' || pr_nrdconta ||
                   ', pr_idorigem:' || pr_idorigem ||
                   ', pr_tpservic:' || pr_tpservic;
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);

    FETCH cr_crapass INTO rw_crapass;
    
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 1; -- Associado nao cadastrado - 23/10/2018 - REQ0011726
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;

    OPEN cr_tbtarif_contas_pacote(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_flgsituacao => 1
                                 ,pr_dtinicio_vigencia => rw_crapdat.dtmvtolt);

    FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;

    IF cr_tbtarif_contas_pacote%NOTFOUND THEN
      CLOSE cr_tbtarif_contas_pacote;
      pr_flpacote := 0;
      pr_flservic := 0;
      pr_qtopdisp := 0;
      RAISE vr_exc_null;
    ELSE
      CLOSE cr_tbtarif_contas_pacote;
    END IF;
    
    CASE pr_tpservic
      WHEN 3 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'CUSTDCTOPF'; -- CUSTODIA POR DOCUMENTO PESSOA FISICA
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'CUSTDCTOPJ'; -- CUSTODIA POR DOCUMENTO PESSOA JURIDICA
        END IF;
      WHEN 4 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'CONTRORDPF'; -- CONTRA ORDEM (OU REVOGACAO) E OPOSICAO (OU SUSTACAO) AO PAGAMENTO DE CHEQUE PESSOA FISICA -PERMANENTE
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'CONTRORDPJ'; -- CONTRA ORDEM (OU REVOGACAO) E OPOSICAO (OU SUSTACAO) AO PAGAMENTO DE CHEQUE PESSOA JURIDICA  PERMANENTE
        END IF;
      WHEN 5 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'FOLHACHQPF'; -- FORNECIMENTO DE FOLHAS DE CHEQUE PESSOA FISICA
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'FOLHACHQPJ'; -- FORNECIMENTO DE FOLHAS DE CHEQUE PESSOA JURIDICA
        END IF;    
      WHEN 6 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'EXTMEPREPF'; -- FORNECIMENTO DE EXTRATO MENSAL DE CONTA DE DEPOSITOS A VISTA PESSOA FISICA  PRESENCIAL
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'EXTMEPREPJ'; -- FORNECIMENTO DE EXTRATO MENSAL DE CONTA DE DEPOSITOS A VISTA  PESSOA JURIDICA  PRESENCIAL
        END IF; 
      WHEN 7 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'EXTMETAAPF'; -- FORNECIMENTO DE EXTRATO MENSAL DE CONTA DE DEPOSITOS A VISTA PESSOA FISICA - TERMINAL DE AUTOATENDIMENTO
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'EXTMETAAPJ'; -- FORNECIMENTO DE EXTRATO MENSAL DE CONTA DE DEPOSITOS A VISTA PESSOA JURIDICA - TERMINAL DE AUTOATENDIMENTO
        END IF;
      WHEN 8 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'EXTPEPREPF'; -- FORNECIMENTO DE EXTRATO DE UM PERIODO DE CONTA DE DEPOSITOS A VISTA PESSOA FISICA  PRESENCIAL
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'EXTPEPREPJ'; -- FORNECIMENTO DE EXTRATO DE UM PERIODO DE CONTA DE DEPOSITOS A VISTA PESSOA JURIDICA  PRESENCIAL
        END IF;
      WHEN 9 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'EXTPETAAPF'; -- FORNECIMENTO DE EXTRATO DE UM PERIODO DE CONTA DE DEPOSITOS A VISTA PESSOA FISICA - TERMINAL DE AUTOATENDIMENTO
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'EXTPETAAPJ'; -- FORNECIMENTO DE EXTRATO DE UM PERIODO DE CONTA DE DEPOSITOS A VISTA PESSOA JURIDICA - TERMINAL DE AUTOATENDIMENTO
        END IF;
      WHEN 10 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'DOCCAIXAPF'; -- TRANSFERENCIA DE RECURSOS POR MEIO DE DOC PESSOA FISICA  PESSOAL
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'DOCCAIXAPJ'; -- TRANSFERENCIA DE RECURSOS POR MEIO DE DOC PESSOA JURIDICA - PESSOAL
        END IF;
      WHEN 11 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'TEDCAIXAPF'; -- TRANSFERENCIA DE RECURSOS POR MEIO DE TED PESSOA FISICA  PRESENCIAL
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'TEDCAIXAPJ'; -- TRANSFERENCIA DE RECURSOS POR MEIO DE TED PESSOA JURIDICA  PRESENCIAL
        END IF;
      WHEN 12 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'TEDELETRPF'; -- TRANSFERENCIA DE RECURSOS POR MEIO DE TED PESSOA FISICA  TAA
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'TEDELETRPJ'; -- TRANSFERENCIA DE RECURSOS POR MEIO DE TED PESSOA JURIDICA  TAA
        END IF;
      WHEN 13 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'TRANSPOPPF'; -- TRANSFERENCIA ENTRE CONTAS DA PROPRIA INSTITUICAO PESSOA FISICA
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'TRANSPOPPJ'; -- TRANSFERENCIA ENTRE CONTAS DA PROPRIA INSTITUICAO PESSOA JURIDICA
        END IF;
      WHEN 14 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := '2VCARMAGPF'; -- SEGUNDA VIA DE CARTAO MAGNETICO PESSOA FISICA
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := '2VCARMAGPJ'; -- SEGUNDA VIA DE CARTAO MAGNETICO PESSOA JURIDICA
        END IF;
      WHEN 15 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'DSCCHQBOPF'; -- DESCONTO DE CHEQUE POR BORDERO PESSOA FISICA
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'DSCCHQBOPJ'; -- DESCONTO DE CHEQUE POR BORDERO PESSOA JURIDICA
        END IF;
      WHEN 16 THEN
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'DSTBORDEPF'; -- EMISSAO BORDERO DESCONTO DE TITULO PESSOA FISICA
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'DSTBORDEPJ'; -- EMISSAO BORDERO DESCONTO DE TITULO PESSOA JURIDICA
        END IF;                     
/* Prieto -- imagem de cheque */
      WHEN 23 THEN -- IMAGEM DE CHEQUE ONLINE
        IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'IMGCHQOPF';
        ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'IMGCHQOPJ';
        END IF;                           
    END CASE;
   
    TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                         ,pr_cdbattar => vr_cdbattar
                                         ,pr_vllanmto => 0
                                         ,pr_cdprogra => 'TARIFA'
                                         ,pr_cdhistor => vr_cdhistor
                                         ,pr_cdhisest => vr_cdhisest
                                         ,pr_vltarifa => vr_vltarifa
                                         ,pr_dtdivulg => vr_dtdivulg
                                         ,pr_dtvigenc => vr_dtvigenc
                                         ,pr_cdfvlcop => vr_cdfvlcop
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic 
                                         ,pr_tab_erro => vr_tab_erro);

    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Se possui erro no vetor
      IF vr_tab_erro.Count > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic := NVL(vr_cdcritic,0); -- Grava erro original - 23/10/2018 - REQ0011726        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic,pr_dscritic => vr_dscritic)||
                       '(3)';	
        -- Controlar geração de log de execução dos jobs   
        tari0001.pc_log(pr_cdcooper => pr_cdcooper
                       ,pr_dscritic => vr_dscritic         ||
                                       ' '  || vr_nmrotpro || 
                                       '. ' || vr_dsparame
                       ,pr_cdcritic => vr_cdcritic); 
        vr_cdcritic := 1058; -- Nao foi possivel carregar a tarifa - 23/10/2018 - REQ0011726        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       '(3)';	
      END IF;
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);    

    OPEN cr_crapfco(pr_cdfvlcop => vr_cdfvlcop);

    FETCH cr_crapfco INTO rw_crapfco;

    IF cr_crapfco%NOTFOUND THEN
      CLOSE cr_crapfco;
      -- 23/10/2018 - REQ0011726
      vr_cdcritic := 1391; -- Registro de ligacao entre faixas de valores das tarifas e cooperativa nao encontrado
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapfco;
    END IF;    
    
    OPEN cr_crapfvl(pr_cdfaixav => rw_crapfco.cdfaixav);

    FETCH cr_crapfvl INTO rw_crapfvl;

    IF cr_crapfvl%NOTFOUND THEN
      CLOSE cr_crapfvl;
      -- 23/10/2018 - REQ0011726
      vr_cdcritic := 1392; -- Registro de faixas de valores das tarifas nao encontrado
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapfvl;
    END IF;   

    OPEN cr_tbtarif_servicos(pr_cdpacote => rw_tbtarif_contas_pacote.cdpacote
                            ,pr_cdtarifa => rw_crapfvl.cdtarifa);

    FETCH cr_tbtarif_servicos INTO rw_tbtarif_servicos;
    
    IF cr_tbtarif_servicos%NOTFOUND THEN
      CLOSE cr_tbtarif_servicos;
      pr_flpacote := 1;
      pr_flservic := 0;
      pr_qtopdisp := 0;
      RAISE vr_exc_null;
    ELSE
      CLOSE cr_tbtarif_servicos;      
    END IF;

    OPEN cr_tbcc_operacoes_diarias(pr_cdcooper   => pr_cdcooper
                                  ,pr_nrdconta   => pr_nrdconta
                                  ,pr_tpoperacao => pr_tpservic
                                  ,pr_dtmvtolt   => rw_crapdat.dtmvtolt);

    FETCH cr_tbcc_operacoes_diarias INTO rw_tbcc_operacoes_diarias;

    CLOSE cr_tbcc_operacoes_diarias;        

    pr_flpacote := 1;
    pr_flservic := 1;
    pr_qtopdisp := rw_tbtarif_servicos.qtdoperacoes - rw_tbcc_operacoes_diarias.cont;
    
    IF pr_qtopdisp < 0 THEN
      pr_qtopdisp := 0;
    END IF;
    
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);   
  -- Trata exceções - 23/10/2018 - REQ0011726
  EXCEPTION
    WHEN vr_exc_null THEN
      pr_cdcritic := 0;      
      pr_dscritic := '';
    WHEN vr_exc_saida THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic );			
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic; 
      -- Controlar geração de log de execução dos jobs   
      tari0001.pc_log(pr_cdcooper => pr_cdcooper
                     ,pr_dscritic => pr_dscritic         ||
                                     ' '  || vr_nmrotpro || 
                                     '. ' || vr_dsparame
                     ,pr_cdcritic => pr_cdcritic); 
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' '  || vr_nmrotpro || 
                     ' '  || SQLERRM     ||
                     '. ' || vr_dsparame; 
      -- Controlar geração de log de execução dos jobs   
      tari0001.pc_log(pr_cdcooper => pr_cdcooper
                     ,pr_dscritic => pr_dscritic
                     ,pr_cdcritic => pr_cdcritic); 
  END pc_verifica_pacote_tarifas;

  -- Rotina para verificar pacote de tarifas via web
  PROCEDURE pc_verifica_pct_tari_web(pr_cdcooper IN craprac.cdcooper%TYPE  --> Código da Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da Conta
                                    ,pr_tpservic IN NUMBER                 --> Tipo de Servico
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_verifica_pct_tari_web
     Sistema : Pacotes de tarifas - 2
     Sigla   : TARI
     Autor   : Jean Michel
     Data    : Abril/2016                    Ultima atualizacao: 23/10/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para verificar pacote de tarifas via web

     Observacao: -----

     Alteracoes:
                23/10/2018 - Padrões: Others, Modulo/Action, PC Internal Exception, PC Log Programa
                             Parâmetros, troca de mensagens por código                             
                               (Envolti - Belli - REQ0011726)
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_flpacote NUMBER := 0; --> Flag de Pacote
      vr_flservic NUMBER := 0; --> Flag de Sevico
      vr_qtopdisp NUMBER := 0; --> Quantidade de Operacoes Disponiveis
      -- Variaveis de Log e Modulo - 23/10/2018 - REQ0011726
      vr_dsparame VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
      vr_nmrotpro VARCHAR2  (100) := 'pc_verifica_pct_tari_web';
      vr_cdproint VARCHAR2  (100);

    BEGIN
      -- Posiciona procedure
      vr_cdproint := vr_cdproexe||'.'||vr_nmrotpro;
      -- Inclusão do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);    
      vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                     ', pr_nrdconta:' || pr_nrdconta ||
                     ', pr_tpservic:' || pr_tpservic ||
                     ', pr_xmllog  :' || SUBSTR(pr_xmllog,1,3600);
      vr_cdcritic := 1201;
      -- Controlar geração de log de execução dos jobs   
      tari0001.pc_log(pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || vr_dsparame      
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                     ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                     ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                     ,pr_cdcooper => pr_cdcooper
                     );
      -- Leitura de carencias do produto informado
      TARI0001.pc_verifica_pacote_tarifas(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                         ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                         ,pr_idorigem => 5             --> Origem
                                         ,pr_tpservic => pr_tpservic   --> Tipo de Servico
                                         ,pr_flpacote => vr_flpacote   --> Flag de Pacote
                                         ,pr_flservic => vr_flservic   --> Flag de Sevico
                                         ,pr_qtopdisp => vr_qtopdisp   --> Quantidade de Operacoes Disponiveis
                                         ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                         ,pr_dscritic => vr_dscritic); --> Descrição da crítica    
      
      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_saida;
      END IF;
      -- Retorno do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);   
    -- Trata exceções - 23/10/2018 - REQ0011726
    EXCEPTION
      WHEN vr_exc_saida THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic );			
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic         ||
                       ' '  || vr_nmrotpro || 
                       '. ' || vr_dsparame; 
        -- Controlar geração de log de execução dos jobs   
        tari0001.pc_log(pr_cdcooper => pr_cdcooper
                       ,pr_dscritic => pr_dscritic
                       ,pr_cdcritic => pr_cdcritic);                                        
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA.
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);	                                       
        pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'Dados'
                              ,pr_posicao => 0
                              ,pr_tag_nova => 'Erro'
                              ,pr_tag_cont => vr_dscritic
                              ,pr_des_erro => vr_dscritic );

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' '  || vr_nmrotpro || 
                     ' '  || SQLERRM     ||
                     '. ' || vr_dsparame; 
        -- Controlar geração de log de execução dos jobs   
        tari0001.pc_log(pr_cdcooper => pr_cdcooper
                       ,pr_dscritic => pr_dscritic
                       ,pr_cdcritic => pr_cdcritic);                                       
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA.
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);	                                       
        pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'Dados'
                              ,pr_posicao => 0
                              ,pr_tag_nova => 'Erro'
                              ,pr_tag_cont => vr_dscritic
                              ,pr_des_erro => vr_dscritic );                              
    END;

  END pc_verifica_pct_tari_web;

  /*****************************************************************************
  Estorno/Baixa de lancamento de tarifas
  ******************************************************************************/
  PROCEDURE pc_estorno_baixa_tarifa (pr_cdcooper  IN INTEGER  --> Codigo Cooperativa
                                    ,pr_cdagenci  IN INTEGER  --> Codigo Agencia
                                    ,pr_nrdcaixa  IN INTEGER  --> Numero do caixa
                                    ,pr_cdoperad  IN VARCHAR2 --> Codigo Operador
                                    ,pr_dtmvtolt  IN DATE     --> Data Lancamento
                                    ,pr_nmdatela  IN VARCHAR2 --> Nome da tela       
                                    ,pr_idorigem  IN INTEGER  --> Indicador de origem
                                    ,pr_inproces  IN INTEGER  --> Indicador processo
                                    ,pr_nrdconta  IN INTEGER  --> Numero da Conta
                                    ,pr_cddopcap  IN INTEGER  --> Codigo de opcao --> 1 - Estorno de tarifa
                                                                                  --> 2 - Baixa de tarifa
                                    ,pr_lscdlant  IN VARCHAR2 --> Lista de lancamentos de tarifa(delimitador ;)
                                    ,pr_lscdmote  IN VARCHAR2 --> Lista de motivos de estorno (delimitador ;)
                                    ,pr_flgerlog  IN VARCHAR2 --> Indicador se deve gerar log (S-sim N-Nao)
                                    ,pr_cdcritic OUT INTEGER      --> Codigo Critica
                                    ,pr_dscritic OUT VARCHAR2) IS --> Descricao Critica
    /* ........................................................................
    
      Programa : pc_estorno_baixa_tarifa           Antigo: b1wgen0153.p/estorno-baixa-tarifa
      Sistema  : Cred
      Sigla    : TARI0001
      Autor    : Odirlei Busana - AMcom
      Data     : janeiro/2017.                   Ultima atualizacao: 23/10/2018
    
      Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado
       
       Objetivo  : Estorno/Baixa de lancamento de tarifas
       
       Alterações: 10/01/2017 - Conversão Progress -> Oracle (Odirlei-AMcom)

                   23/10/2018 - Padrões: Others, Modulo/Action, PC Internal Exception, PC Log Programa
                                Inserts, Updates, Deletes e SELECT's, Parâmetros, troca de mensagens por código
                                (Envolti - Belli - REQ0011726) 
                                      
      ........................................................................ */

    -----------> CURSORES <----------
    -- Lockar registro da lat
    CURSOR cr_craplat (pr_cdlantar craplat.cdlantar%TYPE)IS
      SELECT lat.rowid,
             lat.cdfvlcop,
             lat.nrdctabb,
             lat.nrdctitg,            
             lat.cdpesqbb,
             lat.cdbanchq,
             lat.cdagechq,
             lat.nrctachq,
             lat.cdagenci,            
             lat.cdbccxlt,
             lat.nrdolote,
             lat.vltarifa,
             lat.nrdocmto,
             lat.cdhistor
             
        FROM craplat lat
       WHERE lat.cdlantar = pr_cdlantar
         FOR UPDATE NOWAIT; 
    rw_craplat cr_craplat%ROWTYPE;
    
    --> Buscar dados da tarifa
    CURSOR cr_crapfvl (pr_cdfvlcop crapfco.cdfvlcop%TYPE)IS
      SELECT fvl.cdhisest
        FROM crapfco fco,
             crapfvl fvl
       WHERE fco.cdfvlcop = pr_cdfvlcop
         AND fvl.cdfaixav = fco.cdfaixav;
    rw_crapfvl cr_crapfvl%ROWTYPE;
    
    --> Buscar dados do associado
    CURSOR cr_crapass (pr_nrdconta crapass.nrdconta%TYPE,
                       pr_cdcooper crapass.cdcooper%type) IS
      SELECT ass.cdagenci
        FROM crapass ass
       WHERE ass.nrdconta = pr_nrdconta 
         AND ass.cdcooper = pr_cdcooper;
    rw_crapass cr_crapass%ROWTYPE;
    
    -----------> VARIAVEIS <----------
    -- Tratamento de erros
    vr_cdcritic        NUMBER;
    vr_dscritic        VARCHAR2(4000);
    -- Variavel não utilizada vr_dscritic_aux    VARCHAR2(4000); - 23/10/2018 - REQ0011726
    vr_exc_erro        EXCEPTION;
    vr_tab_erro        gene0001.typ_tab_erro;
    
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    
    vr_tab_cdlantar    gene0002.typ_split;
    vr_tab_cdmotest    gene0002.typ_split;
    
    vr_cont            INTEGER;
    vr_cdlantar        craplat.cdlantar%TYPE;
    vr_cdmotest        craplat.cdmotest%TYPE;
    vr_fcraplat        BOOLEAN;
    vr_fcrapfvl        BOOLEAN;
    vr_fcrapass        BOOLEAN;
    -- Variaveis de Log e Modulo - 23/10/2018 - REQ0011726
    vr_dsparame VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotpro VARCHAR2  (100) := 'pc_estorno_baixa_tarifa';
    vr_cdproint VARCHAR2  (100);
    
    --> Gerar log para o cooperado
    PROCEDURE pr_gera_log(pr_dscrilog IN VARCHAR2 DEFAULT NULL,
                          pr_cdlantar IN VARCHAR2 DEFAULT NULL,
                          pr_cdhistor IN VARCHAR2 DEFAULT NULL,
                          pr_cdmotest IN VARCHAR2 DEFAULT NULL) IS
    /* ........................................................................
    
      Programa : pc_estorno_baixa_tarifa           Antigo: b1wgen0153.p/estorno-baixa-tarifa
      Sistema  : Cred
      Sigla    : TARI0001
      Autor    : Odirlei Busana - AMcom
      Data     : janeiro/2017.                   Ultima atualizacao: 23/10/2018
    
      Dados referentes ao programa:    
       Frequencia: Sempre que for chamado       
       Objetivo  : Tabela principal do log das transacoes do sistema ( CRAP LGM )
       
       Alterações: 23/10/2018 - Padrões: Others, Modulo/Action, PC Internal Exception, PC Log Programa
                                (Envolti - Belli - REQ0011726) 
                                      
      ........................................................................ */
    
      vr_nrdrowid ROWID;
      -- Variaveis de Log e Modulo - 23/10/2018 - REQ0011726
      vr_nmrotpro        VARCHAR2  (100) := 'pr_gera_log';
      -- Tratamento de erros
      vr_cdcrilog        NUMBER;
      vr_dscrilog        VARCHAR2 (4000);
      vr_dsparlog        VARCHAR2 (4000) := NULL;
      
    BEGIN
      -- Posiciona procedure - 23/10/2018 - REQ0011726
      vr_cdproint := vr_cdproexe||'.'||vr_nmrotpro;
      -- Inclusão do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);   

      vr_dsparlog  := 'GENE0001.pc_gera_log';    
      -- Gerar log ao cooperado 
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscrilog
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => (CASE WHEN pr_dscrilog IS NULL THEN 1 ELSE 0 END)
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      vr_dsparlog  := 'GENE0001.pc_gera_log_item cdlantar, vr_nrdrowid:' || vr_nrdrowid;          
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'cdlantar',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_cdlantar);

      vr_dsparlog  := 'GENE0001.pc_gera_log_item cdhistor';         
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'cdhistor',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_cdhistor);                                

      vr_dsparlog  := 'GENE0001.pc_gera_log_item dtdestor';                                 
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'dtdestor',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_dtmvtolt);

      vr_dsparlog  := 'GENE0001.pc_gera_log_item cdmotest';       
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'cdmotest',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_cdmotest);                                                     

      vr_dsparlog  := 'GENE0001.pc_gera_log_item cdopeest';                                 
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'cdopeest',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_cdoperad);
                                
      -- Retorno do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);   
    EXCEPTION      
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 23/10/2018 - REQ0011726
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        -- Efetuar retorno do erro não tratado - 23/10/2018 - REQ0011726
        vr_cdcrilog := 9999;
        vr_dscrilog := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcrilog) ||
                       ' '  || vr_nmrotpro || 
                       ' '  || SQLERRM     ||
                       '. ' || vr_dsparame ||
                       '. ' || vr_dsparlog; 
        -- Controlar geração de log de execução dos jobs - 23/10/2018 - REQ0011726
        tari0001.pc_log(pr_cdcooper => pr_cdcooper
                       ,pr_dscritic => vr_dscrilog
                       ,pr_cdcritic => vr_cdcrilog);                                                                                            
    END pr_gera_log;
    
  BEGIN
    -- Posiciona procedure - 23/10/2018 - REQ0011726
    vr_cdproint := vr_cdproexe||'.'||vr_nmrotpro;
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);    
    vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                   ', pr_cdagenci:' || pr_cdagenci ||
                   ', pr_nrdcaixa:' || pr_nrdcaixa ||
                   ', pr_cdoperad:' || pr_cdoperad ||
                   ', pr_dtmvtolt:' || pr_dtmvtolt ||
                   ', pr_nmdatela:' || pr_nmdatela ||
                   ', pr_idorigem:' || pr_idorigem ||
                   ', pr_inproces:' || pr_inproces ||
                   ', pr_nrdconta:' || pr_nrdconta ||
                   ', pr_cddopcap:' || pr_cddopcap ||
                   ', pr_lscdlant:' || pr_lscdlant ||
                   ', pr_lscdmote:' || pr_lscdmote ||
                   ', pr_flgerlog:' || pr_flgerlog;
    
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    IF pr_cddopcap = 1 THEN 
      vr_dstransa := 'Estorno de tarifa.';
    ELSE
      vr_dstransa := 'Baixa de tarifa.';
    END IF;
    
    --> Codigo Lantar
    vr_tab_cdlantar := gene0002.fn_quebra_string(pr_lscdlant,';');
    --> Motivo Estorno
    vr_tab_cdmotest := gene0002.fn_quebra_string(pr_lscdmote,';');
    -- Retorna do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint); 
    
    SAVEPOINT TRANS_ESTTAR;
    --Buscar lançamentos passados por parametro  
    FOR idx IN vr_tab_cdlantar.first..vr_tab_cdlantar.last LOOP
    
      vr_cdlantar := vr_tab_cdlantar(idx);
      vr_cdmotest := NULL;
      IF vr_tab_cdmotest.exists(idx) THEN
        vr_cdmotest := vr_tab_cdmotest(idx);
      END IF;
      
      --> Tentar lockar a craplat
      LOOP
        BEGIN
          OPEN cr_craplat(pr_cdlantar => vr_cdlantar);
          FETCH cr_craplat INTO rw_craplat;
          vr_fcraplat := cr_craplat%FOUND;
          CLOSE cr_craplat;
          
          EXIT;
        EXCEPTION  
          WHEN OTHERS THEN
            IF vr_cont = 10 THEN
              CLOSE cr_craplat;
              vr_cdcritic := 1399; -- Registro de tarifa em uso - 23/10/2018 - REQ0011726
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              RAISE vr_exc_erro;
            ELSE
              vr_cont := nvl(vr_cont,0) + 1; 
              CLOSE cr_craplat;
              dbms_lock.sleep(1);
            END IF;
        END;
      
      END LOOP; --> Fim loop lockar craplat
      
      --> Se localizou o lancamento
      IF vr_fcraplat =  TRUE THEN
      
        --> 1 - Estorno 
        IF pr_cddopcap = 1 THEN
        
          BEGIN
            UPDATE craplat lat
               SET lat.insitlat = 4 --> Estornado 
                  ,lat.cdmotest = vr_cdmotest 
                  ,lat.dtdestor = pr_dtmvtolt
                  ,lat.cdopeest = pr_cdoperad
             WHERE lat.rowid = rw_craplat.rowid; 
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
              -- Monta Log
              vr_cdcritic := 1035;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'craplat:'||
                             ' insitlat:'  || '4'||
                             ', cdmotest:' || vr_cdmotest||
                             ', dtdestor:' || pr_dtmvtolt||
                             ', cdopeest:' || pr_cdoperad||
                             ', com rowid:'|| rw_craplat.rowid||
                             '. '||SQLERRM;
              RAISE vr_exc_erro;  
          END;
          
          --> Buscar dados da tarifa
          OPEN cr_crapfvl (pr_cdfvlcop => rw_craplat.cdfvlcop );
          FETCH cr_crapfvl INTO rw_crapfvl;
          vr_fcrapfvl := cr_crapfvl%FOUND;
          CLOSE cr_crapfvl;
          
          IF vr_fcrapfvl = TRUE THEN
            --> Buscar dados do associado
            OPEN cr_crapass (pr_nrdconta => pr_nrdconta,
                             pr_cdcooper => pr_cdcooper);
            FETCH cr_crapass INTO rw_crapass;
            vr_fcrapass := cr_crapass%FOUND;
            CLOSE cr_crapass;
            
            IF vr_fcrapass = TRUE THEN
              -- Gerar Lancamento Estorno CRAPLCM
              pc_lan_tarifa_conta_corrente (pr_cdcooper => pr_cdcooper          --Codigo Cooperativa
                                           ,pr_cdagenci => rw_craplat.cdagenci  --Codigo Agencia
                                           ,pr_nrdconta => pr_nrdconta          --Numero da Conta
                                           ,pr_cdbccxlt => rw_craplat.cdbccxlt  --Codigo Banco/Agencia/Caixa
                                           ,pr_nrdolote => rw_craplat.nrdolote  --Numero do Lote
                                           ,pr_tplotmov => 1                    --Tipo Lote
                                           ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                           ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento Atual
                                           ,pr_nrdctabb => rw_craplat.nrdctabb  --Numero Conta BB
                                           ,pr_nrdctitg => rw_craplat.nrdctitg  --Numero Conta Integracao
                                           ,pr_cdhistor => rw_crapfvl.cdhisest  --Codigo Historico
                                           ,pr_cdpesqbb => rw_craplat.cdpesqbb  --Codigo Pesquisa
                                           ,pr_cdbanchq => rw_craplat.cdbanchq  --Codigo Banco Cheque
                                           ,pr_cdagechq => rw_craplat.cdagechq  --Codigo Agencia Cheque
                                           ,pr_nrctachq => rw_craplat.nrctachq  --Numero Conta Cheque
                                           ,pr_flgaviso => FALSE                --Flag Aviso
                                           ,pr_cdsecext => 0                    --Codigo Extrato Externo
                                           ,pr_tpdaviso => 0                    --Tipo de Aviso
                                           ,pr_vltarifa => rw_craplat.vltarifa  --Valor da Tarifa
                                           ,pr_nrdocmto => rw_craplat.nrdocmto  --Numero do Documento
                                           ,pr_cdageass => rw_crapass.cdagenci  --Codigo Agencia Associado
                                           ,pr_cdcoptfn => 0                    --Codigo Cooperativa do Terminal
                                           ,pr_cdagetfn => 0                    --Codigo Agencia do Terminal
                                           ,pr_nrterfin => 0                    --Numero do Terminal
                                           ,pr_nrsequni => 0                    --Numero Sequencial Unico
                                           ,pr_nrautdoc => 0                    --Numero da Autenticacao do Documento
                                           ,pr_dsidenti => NULL                 --Descricao da Identificacao
                                           ,pr_inproces => pr_inproces          --Indicador do Processo
                                           ,pr_tab_erro => vr_tab_erro          --Tabela de retorno de erro
                                           ,pr_cdcritic => vr_cdcritic          --Codigo do erro
                                           ,pr_dscritic => vr_dscritic);        --Descricao do erro
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR 
                 vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              -- Retorno do módulo e ação logado
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);   
            END IF;          
          END IF; --crapfvl          
        
        ELSE --> 2 - Baixa
          BEGIN
            UPDATE craplat lat
               SET lat.insitlat = 3 --> Baixado 
                  ,lat.cdmotest = vr_cdmotest 
                  ,lat.dtdestor = pr_dtmvtolt
                  ,lat.cdopeest = pr_cdoperad
             WHERE lat.rowid = rw_craplat.rowid; 
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
              -- Monta Log
              vr_cdcritic := 1035;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'craplat(2):'||
                             ' insitlat:'  || '3'||
                             ', cdmotest:' || vr_cdmotest||
                             ', dtdestor:' || pr_dtmvtolt||
                             ', cdopeest:' || pr_cdoperad||
                             ', com rowid:'|| rw_craplat.rowid||
                             '. '||SQLERRM;
              RAISE vr_exc_erro;  
          END;          
        END IF;

      END IF; --> craplat
      
      --> Gerar log para o cooperado
      pr_gera_log(pr_cdlantar => vr_cdlantar,
                  pr_cdhistor => rw_craplat.cdhistor,
                  pr_cdmotest => vr_cdmotest);
      -- Retorno do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);        
      
    END LOOP;
                                
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);      
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Efetuar retorno do erro tratado - 23/10/2018 - REQ0011726
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);		
      pr_dscritic := vr_dscritic;	
      pr_cdcritic := vr_cdcritic;
      -- Controlar geração de log de execução dos jobs - 23/10/2018 - REQ0011726   
      tari0001.pc_log(pr_cdcooper => pr_cdcooper
                     ,pr_dscritic => pr_dscritic         ||
                                     ' '  || vr_nmrotpro || 
                                     '. ' || vr_dsparame
                     ,pr_cdcritic => pr_cdcritic); 
        
      ROLLBACK TO TRANS_ESTTAR;
      
      --> Gerar log para o cooperado
       pr_gera_log(pr_dscrilog => pr_dscritic,
                   pr_cdlantar => vr_cdlantar,
                   pr_cdhistor => rw_craplat.cdhistor,
                   pr_cdmotest => vr_cdmotest);
      
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 23/10/2018 - REQ0011726
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
      -- Efetuar retorno do erro não tratado - 23/10/2018 - REQ0011726
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' '  || vr_nmrotpro || 
                     ' '  || SQLERRM     ||
                     '. ' || vr_dsparame; 
      -- Controlar geração de log de execução dos jobs - 23/10/2018 - REQ0011726
      tari0001.pc_log(pr_cdcooper => pr_cdcooper
                     ,pr_dscritic => pr_dscritic
                     ,pr_cdcritic => pr_cdcritic); 
      
      ROLLBACK TO TRANS_ESTTAR;
      
      --> Gerar log para o cooperado
      pr_gera_log(pr_dscrilog => pr_dscritic,
                  pr_cdlantar => vr_cdlantar,
                  pr_cdhistor => rw_craplat.cdhistor,
                  pr_cdmotest => vr_cdmotest);
                  
      pr_cdcritic := 1224; --Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic); 
    
  END pc_estorno_baixa_tarifa;

  PROCEDURE pc_calcula_tarifa (pr_cdcooper  IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                              ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta do associado
                              ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE --> Codigo da linha de credito do emprestimo.
                              ,pr_vlemprst  IN crapepr.vlemprst%TYPE --> Valor do emprestimo.
                              ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE --> Codigo de uso da linha de credito (0-Normal/1-CDC/2-Boletos)
                              ,pr_tpctrato  IN craplcr.tpctrato%TYPE --> Tipo de contrato utilizado por esta linha de credito.
                              ,pr_dsbemgar  IN VARCHAR2              --> Relação de categoria de bens em garantia
                                                                     --- Deve iniciar com o primeiro tipo de bem em garantia
                                                                     --- deve ser separado por |
                                                                     --- deve terminar com |
                              ,pr_cdprogra  IN VARCHAR2              --> Nome do programa chamador
                              ,pr_flgemail  IN VARCHAR2              --> Envia e-mail S/N, se N interrompe o processo em caso de erro
                              ,pr_tpemprst  in crapepr.tpemprst%type DEFAULT NULL --> tipo de emprestimo
                              ,pr_idfiniof  IN crapepr.idfiniof%type DEFAULT 0
                              --
                              ,pr_vlrtarif OUT crapfco.vltarifa%TYPE --> Valor da tarifa calculada
                              ,pr_vltrfesp OUT craplcr.vltrfesp%TYPE --> Valor da tarifa especial calculada
                              ,pr_vltrfgar OUT crapfco.vltarifa%TYPE --> Valor da tarifa garantia calculada
                              ,pr_cdhistor OUT craphis.cdhistor%TYPE --> Codigo do historico do lancamento.
                              ,pr_cdfvlcop OUT crapfco.cdfvlcop%TYPE --> Codigo da faixa de valor por cooperativa.
                              ,pr_cdhisgar OUT craphis.cdhistor%TYPE --> Codigo do historico de bens em garantia
                              ,pr_cdfvlgar OUT crapfco.cdfvlcop%TYPE --> Código da faixa de valor dos bens em garantia
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                              ,pr_dscritic OUT VARCHAR2              --> Texto de erro/critica encontrada
                              ) IS
    -- ........................................................................
    --
    --  Programa : pc_calcula_tarifa           Antigo: 
    --  Sistema  : Cred
    --  Sigla    : TARI0001
    --  Autor    : Marcelo Telles Coelho
    --  Data     : Fevereiro/2018.                   Ultima atualizacao: 19/10/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar o cálculo de tarifa
    --
    --   Alterações: 09/07/2018 - Alterado para buscar tarifas diferenciadas para emprestimos CDC
    --                            PRJ439 - CDC(Odirlei - AMcom)
    --
    --
    --               19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)
    vr_cdbattar VARCHAR2(100) := ' ';
    vr_cdhistor craphis.cdhistor%TYPE;
    vr_cdhisgar craphis.cdhistor%type;
    vr_cdhisest craphis.cdhistor%TYPE;
    vr_cdfvlcop crapfco.cdfvlcop%TYPE;
    vr_cdfvlgar crapfco.cdfvlcop%type;
    vr_vltrfgar crapfco.vltarifa%TYPE;
    vr_dtdivulg DATE;
    vr_dtvigenc DATE;
    vr_cdhistmp craphis.cdhistor%TYPE;
    vr_cdfvltmp crapfco.cdfvlcop%TYPE;
    -- Variaveis Envio de Email
    vr_nmrescop    VARCHAR2(100);
    vr_des_corpo   VARCHAR2(1000);
    vr_des_destino VARCHAR2(1000);
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(4000);
    -- Flag para tarifas moveis diferente de bens alienáveis
    vr_flgoutrosbens BOOLEAN;
    -- Tabela Temporaria
    vr_tab_erro GENE0001.typ_tab_erro;
    -- Variaveis para separar os tipos de bens em garantia em pr_dsbemgar
    w_dsbemgar VARCHAR2(32000);
    w_nrposini NUMBER;
    w_nrposfim NUMBER;
    w_qtcaract NUMBER;
    w_nrcatbem NUMBER;
    w_dscatbem crapbpr.dscatbem%TYPE;
    
    vr_cdbattar_cad VARCHAR2(100) := ' ';
    vr_cdbattar_ava VARCHAR2(100) := ' ';
    vr_cdhiscad_lem craphis.cdhistor%TYPE;
    vr_cdhisgar_lem craphis.cdhistor%TYPE;
    
    vr_cdmotivo  VARCHAR2(10);
    
    -- Tabela temporaria para tipos de bens em garantia
    TYPE typ_reg_dscatbem IS
     RECORD(dscatbem crapbpr.dscatbem%TYPE);
    TYPE typ_tab_dscatbem IS
      TABLE OF typ_reg_dscatbem
        INDEX BY PLS_INTEGER;
    -- Vetor para armazenar tipos de bens em garantia
    vr_tab_dscatbem typ_tab_dscatbem;
    -- Cursor Associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa,
             ass.nrdconta,
             ass.cdsecext,
             ass.cdagenci,
             ass.cdtipsfx
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;  

    CURSOR cr_craplcr (pr_cdcooper in crapass.cdcooper%type,
                       pr_cdlcremp in craplcr.cdlcremp%type) is
       select dsoperac
              ,decode(craplcr.cdhistor,2013,1,2014,1,0) inlcrcdc
              ,craplcr.tplcremp
       from   craplcr
       where  cdcooper = pr_cdcooper
       and    cdlcremp = pr_cdlcremp;
       
    rw_craplcr cr_craplcr%rowtype;
    
  BEGIN
    -- Limpa Variaveis de Tarifa     
    pr_vlrtarif := 0;
    pr_vltrfesp := 0;
    pr_vltrfgar := 0;
/*    
-- retirar a gravação do loh antes de ir para produção
BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                          ,pr_ind_tipo_log => 2 -- Erro tratato
                          ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '||chr(10)
                                           || 'pr_cdcooper='||pr_cdcooper || ' - '||chr(10)
                                           || 'pr_nrdconta='||pr_nrdconta || ' - '||chr(10)
                                           || 'pr_cdlcremp='||pr_cdlcremp || ' - '||chr(10)
                                           || 'pr_vlemprst='||pr_vlemprst || ' - '||chr(10)
                                           || 'pr_cdusolcr='||pr_cdusolcr || ' - '||chr(10)
                                           || 'pr_tpctrato='||pr_tpctrato || ' - '||chr(10)
                                           || 'pr_dsbemgar='||pr_dsbemgar 
                          ,pr_nmarqlog => 'TARIFA');
-- FIM - retirar a gravação do loh antes de ir para produção
*/
    -- Separar os tipos de bens em garantia em pr_dsbemgar
    BEGIN
      vr_tab_dscatbem.delete;
      w_dsbemgar := TRIM(pr_dsbemgar);
      IF w_dsbemgar IS NOT NULL AND trim(pr_dsbemgar) <> '|' THEN
        IF SUBSTR(w_dsbemgar,1,1) = '|' THEN
          w_dsbemgar := SUBSTR(w_dsbemgar,2,LENGTH(w_dsbemgar));
        END IF;
        IF SUBSTR(w_dsbemgar,LENGTH(w_dsbemgar),1) <> '|' THEN
          w_dsbemgar := w_dsbemgar || '|';
        END IF;
        --
        w_nrcatbem := 0;
        w_nrposini := 1;
        w_nrposfim := INSTR(w_dsbemgar, '|', w_nrposini);
        w_qtcaract := w_nrposfim - w_nrposini;
        LOOP
          w_nrcatbem := w_nrcatbem +1;
          vr_tab_dscatbem(w_nrcatbem).dscatbem := NVL(SUBSTR(w_dsbemgar, w_nrposini, w_qtcaract),' ');
          --
          EXIT WHEN w_nrposfim = LENGTH(w_dsbemgar);
          --
          w_nrposini := w_nrposfim + 1;
          w_nrposfim := INSTR(w_dsbemgar, '|', w_nrposini);
          w_qtcaract := w_nrposfim - w_nrposini;
        END LOOP;
      END IF;
    END;
    -- Selecionar Associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;
    
    open cr_craplcr (pr_cdcooper => pr_cdcooper
                    ,pr_cdlcremp => pr_cdlcremp);
    fetch cr_craplcr into rw_craplcr;
    close cr_craplcr;
    
    IF pr_cdusolcr = 1 THEN
      IF rw_crapass.inpessoa = 1 THEN
        vr_cdbattar := 'MICROCREPF'; -- Microcredito Pessoa Fisica
      ELSE
        vr_cdbattar := 'MICROCREPJ'; -- Microcredito Pessoa Juridica
      END IF;
        
      TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                           ,pr_cdbattar => vr_cdbattar
                                           ,pr_vllanmto => pr_vlemprst
                                           ,pr_cdprogra => pr_cdprogra
                                           ,pr_cdhistor => vr_cdhistor
                                           ,pr_cdhisest => vr_cdhisest
                                           ,pr_vltarifa => pr_vlrtarif
                                           ,pr_dtdivulg => vr_dtdivulg
                                           ,pr_dtvigenc => vr_dtvigenc
                                           ,pr_cdfvlcop => vr_cdfvlcop
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           ,pr_tab_erro => vr_tab_erro);
                                                        
      --Se ocorreu erro
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Se possui erro no vetor
        IF vr_tab_erro.Count() > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= '(4) Nao foi possivel carregar a tarifa.';
        END IF;
          
        IF pr_flgemail = 'N' THEN
          RAISE vr_exc_saida;
        else
          --Corpo para o Email
          vr_des_corpo := to_char(sysdate,'hh24:mi:ss')||' - '
                          || pr_cdprogra || ' --> '
                          || vr_dscritic || ' - ' || vr_cdbattar;
          
          -- Envio do arquivo detalhado via e-mail
          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => pr_cdprogra
                                    ,pr_des_destino     => vr_des_destino
                                    ,pr_des_assunto     => 'Erros log de tarifas(' || vr_nmrescop || ')'
                                    ,pr_des_corpo       => vr_des_corpo
                                    ,pr_des_anexo       => NULL
                                    ,pr_des_erro        => vr_des_erro);
          --Se ocorreu algum erro
          IF vr_des_erro IS NOT NULL  THEN
            RAISE vr_exc_saida;
          END IF;
           
          -- Efetua Limpeza das variaveis de critica
          vr_cdcritic  := 0;
          vr_dscritic  := NULL;
          vr_des_corpo := NULL;
        END IF;
      END IF;
      
      pr_cdhistor := vr_cdhistor;
      pr_cdfvlcop := vr_cdfvlcop;
    ELSE
    
      vr_cdmotivo := 'EM';
      --> Definir tarifas para CDC
      IF rw_craplcr.inlcrcdc = 1 THEN
        IF rw_craplcr.dsoperac = 'FINANCIAMENTO' THEN
          vr_cdmotivo := 'Q4';
        ELSE --> Emprestimo
          vr_cdmotivo := 'Q2';
        END IF;
      END IF;
    
      -- Buscar tarifa emprestimo
      TARI0001.pc_carrega_dados_tarifa_empr(pr_cdcooper => pr_cdcooper
                                           ,pr_cdlcremp => pr_cdlcremp
                                           ,pr_cdmotivo => vr_cdmotivo
                                           ,pr_inpessoa => rw_crapass.inpessoa
                                           ,pr_vllanmto => pr_vlemprst
                                           ,pr_cdprogra => pr_cdprogra
                                           ,pr_cdhistor => vr_cdhistor
                                           ,pr_cdhisest => vr_cdhisest
                                           ,pr_vltarifa => pr_vlrtarif
                                           ,pr_dtdivulg => vr_dtdivulg
                                           ,pr_dtvigenc => vr_dtvigenc
                                           ,pr_cdfvlcop => vr_cdfvlcop
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           ,pr_tab_erro => vr_tab_erro);                                                                                            
          
      --Se ocorreu erro
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Se possui erro no vetor
        IF vr_tab_erro.Count() > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= '(5) Nao foi possivel carregar a tarifa. ' || vr_dscritic;
        END IF;
        IF pr_flgemail = 'N' THEN
          RAISE vr_exc_saida;
        ELSE
          --Corpo do Email
          vr_des_corpo := to_char(SYSDATE,'hh24:mi:ss')||' - '
                          || pr_cdprogra || ' --> '
                          || vr_dscritic || ' - ' || vr_cdbattar;
          
          
          -- Envio do arquivo detalhado via e-mail
          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => pr_cdprogra
                                    ,pr_des_destino     => vr_des_destino
                                    ,pr_des_assunto     => 'Erros log de tarifas(' || vr_nmrescop || ')'
                                    ,pr_des_corpo       => vr_des_corpo
                                    ,pr_des_anexo       => NULL
                                    ,pr_des_erro        => vr_des_erro);
          --Se ocorreu algum erro
          IF vr_des_erro IS NOT NULL  THEN
            RAISE vr_exc_saida;
          END IF;

          -- Efetua Limpeza das variaveis de critica
          vr_cdcritic  := 0;
          vr_dscritic  := NULL;
          vr_des_corpo := NULL;
        END IF;
      END IF; 
        
      --Codigo historico
      vr_cdhistmp := vr_cdhistor;
      vr_cdfvltmp := vr_cdfvlcop;

      -- Buscar tarifa emprestimo Especial
      TARI0001.pc_carrega_dados_tarifa_empr(pr_cdcooper => pr_cdcooper
                                           ,pr_cdlcremp => pr_cdlcremp
                                           ,pr_cdmotivo => 'ES'
                                           ,pr_inpessoa => rw_crapass.inpessoa
                                           ,pr_vllanmto => pr_vlemprst
                                           ,pr_cdprogra => pr_cdprogra
                                           ,pr_cdhistor => vr_cdhistor
                                           ,pr_cdhisest => vr_cdhisest
                                           ,pr_vltarifa => pr_vltrfesp
                                           ,pr_dtdivulg => vr_dtdivulg
                                           ,pr_dtvigenc => vr_dtvigenc
                                           ,pr_cdfvlcop => vr_cdfvlcop
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           ,pr_tab_erro => vr_tab_erro);
                                               
      --Se ocorreu erro
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Se possui erro no vetor
        IF vr_tab_erro.Count() > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= '(6) Nao foi possivel carregar a tarifa.';
        END IF;
        IF pr_flgemail = 'N' THEN
          RAISE vr_exc_saida;
        ELSE
          --Corpo do Email
          vr_des_corpo := to_char(SYSDATE,'hh24:mi:ss')||' - '
                          || pr_cdprogra || ' --> '
                          || vr_dscritic || ' - ' || vr_cdbattar;
        
          -- Envio do arquivo detalhado via e-mail
          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => pr_cdprogra
                                    ,pr_des_destino     => vr_des_destino
                                    ,pr_des_assunto     => 'Erros log de tarifas(' || vr_nmrescop || ')'
                                    ,pr_des_corpo       => vr_des_corpo
                                    ,pr_des_anexo       => NULL
                                    ,pr_des_erro        => vr_des_erro);
          --Se ocorreu algum erro
          IF vr_des_erro IS NOT NULL  THEN
            RAISE vr_exc_saida;
          END IF;

          -- Efetua Limpeza das variaveis de critica
          vr_cdcritic  := 0;
          vr_dscritic  := NULL;
          vr_des_corpo := NULL;
        END IF;
      END IF; 

      IF nvl(vr_cdhistor,0) = 0 AND nvl(vr_cdfvlcop,0) = 0 THEN
        --Retornar Valores Salvos
        vr_cdhistor:= vr_cdhistmp;
        vr_cdfvlcop:= vr_cdfvltmp;
      END IF;                 

      pr_cdhistor := vr_cdhistor;
      pr_cdfvlcop := vr_cdfvlcop;
      
    END IF;
      
    --pr_cdhislcm := vr_cdhistor;
          
    -- Cobranca da tarifa de avaliacao de bens em garantia
    vr_cdhistor := 0;
    vr_cdhisest := 0;
    vr_cdfvlcop := 0;
      
    /*------------------------------------------
    -- 2 - Avaliacao de garantia de bem movel
    -- 3 - Avaliacao de garantia de bem imovel
    --------------------------------------------*/
    IF pr_tpctrato IN (2,3) THEN 
      IF pr_tpctrato = 2 THEN -- Ben Movel
        IF rw_crapass.inpessoa = 1 THEN -- Fisica 
          vr_cdbattar := 'AVALBMOVPF'; -- Avaliacao de Garantia de Bem Movel - PF

          -- se for CDC busca nova tarifa
          IF rw_craplcr.inlcrcdc = 1 THEN
             IF rw_craplcr.dsoperac = 'FINANCIAMENTO' THEN
               vr_cdbattar := 'CDCFALBMPF'; -- Financiamento Tarifa alienação PF	386
             ELSE -- EMPRESTIMO
               vr_cdbattar := 'CDCEALBMPF'; -- Tarifa alienação PF	381
             END IF;
          END IF;
        ELSE -- Juridica
          vr_cdbattar := 'AVALBMOVPJ'; -- Avaliacao de Garantia de Bem Movel - PJ

          -- se for CDC busca nova tarifa
          IF rw_craplcr.inlcrcdc = 1 THEN
             IF rw_craplcr.dsoperac = 'FINANCIAMENTO' THEN
               vr_cdbattar := 'CDCFALBMPJ'; -- Financiamento Tarifa alienação PJ	387
             ELSE -- EMPRESTIMO
               vr_cdbattar := 'CDCEALBMPJ'; -- Tarifa alienação PJ	382
        END IF;
          END IF;
        END IF;
      ELSE -- Bens Imoveis
        IF rw_crapass.inpessoa = 1 THEN -- Fisica
          vr_cdbattar := 'AVALBIMVPF'; -- Avaliacao de Garantia de Bem Imovel - PF
        ELSE
          vr_cdbattar := 'AVALBIMVPJ'; -- Avaliacao de Garantia de Bem Imovel - PF
        END IF;    
      END IF;
        
      -- Busca Valor da Tarifa
      TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                           ,pr_cdbattar => vr_cdbattar
                                           ,pr_vllanmto => 1
                                           ,pr_cdprogra => pr_cdprogra
                                           ,pr_cdhistor => vr_cdhisgar --vr_cdhistor
                                           ,pr_cdhisest => vr_cdhisest
                                           ,pr_vltarifa => vr_vltrfgar
                                           ,pr_dtdivulg => vr_dtdivulg
                                           ,pr_dtvigenc => vr_dtvigenc
                                           ,pr_cdfvlcop => vr_cdfvlgar --vr_cdfvlcop
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           ,pr_tab_erro => vr_tab_erro);
                                                        
      -- Se ocorreu erro
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Se possui erro no vetor
        IF vr_tab_erro.Count() > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= '(7) Nao foi possivel carregar a tarifa.';
        END IF;
        IF pr_flgemail = 'N' THEN
          RAISE vr_exc_saida;
        ELSE
          --Concatenar Conta e tarifa
          vr_dscritic:= vr_dscritic ||'Conta: '||gene0002.fn_mask_conta(pr_nrdconta)||'- '||vr_cdbattar;
          -- Envio centralizado de log de erro
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                     || pr_cdprogra || ' --> '
                                                     || vr_dscritic || ' - ' || vr_cdbattar);
          -- Efetua Limpeza das variaveis de critica
          vr_cdcritic := 0;
          vr_dscritic := NULL;
        END IF;
      ELSE
        IF pr_tpctrato = 2 THEN -- Ben Movel
          vr_flgoutrosbens := FALSE;
          IF vr_tab_dscatbem.count() > 0 THEN
            FOR i IN 1..vr_tab_dscatbem.count()
            LOOP
              IF vr_tab_dscatbem(i).dscatbem <> ' ' THEN
                IF grvm0001.fn_valida_categoria_alienavel(vr_tab_dscatbem(i).dscatbem) = 'S' THEN 
                  -- Acumula o valor da tarifa para cada um dos bens em garantia alienáveis
                  pr_vltrfgar := pr_vltrfgar + vr_vltrfgar;
                ELSE
                  vr_flgoutrosbens := TRUE;
                END IF;
              END IF;
            END LOOP;
          END IF;
          -- Se houver outros bens cobrar mais uma tarifa
          IF vr_flgoutrosbens THEN
            -- Acumula o valor da tarifa uma única vez para bens em garantia que não são alienáveis
            pr_vltrfgar := pr_vltrfgar + vr_vltrfgar;
          END IF;
        ELSE
          -- Acumula o valor da tarifa uma única vez para o cálculo
          pr_vltrfgar := pr_vltrfgar + vr_vltrfgar;
        END IF;
        pr_cdhisgar := vr_cdhisgar; -- Historico da tarifa de bens em garantia
        pr_cdfvlgar := vr_cdfvlgar;
      END IF;
      --pr_cdgarlcm := pr_cdhisgar;
    END IF; -- Fim cobranca da tarifa de avaliacao de bens em garantia
    
    
    IF pr_idfiniof = 1 THEN
      IF pr_tpemprst = 1 THEN  -- PP
        IF rw_craplcr.dsoperac = 'FINANCIAMENTO' THEN
          vr_cdbattar_cad := 'FINCADPP';
          vr_cdbattar_ava := 'FINAVAPP';        
        ELSE
          vr_cdbattar_cad := 'EMPCADPP';
          vr_cdbattar_ava := 'EMPAVAPP';
        END IF;      
      ELSIF pr_tpemprst = 2 THEN  -- Pós
        IF rw_craplcr.dsoperac = 'FINANCIAMENTO' THEN
          vr_cdbattar_cad := 'FINCADPOS';
          vr_cdbattar_ava := 'FINAVAPOS';        
        ELSE
          vr_cdbattar_cad := 'EMPCADPOS';
          vr_cdbattar_ava := 'EMPAVAPOS';
        END IF;            
      END IF;
      
      IF rw_crapass.inpessoa = 1 THEN
        vr_cdbattar_cad := 'PF'||vr_cdbattar_cad;
        vr_cdbattar_ava := 'PF'||vr_cdbattar_ava;
      
      ELSE
        vr_cdbattar_cad := 'PJ'||vr_cdbattar_cad;
        vr_cdbattar_ava := 'PJ'||vr_cdbattar_ava;
      END IF;
      
      -- Buscar historico para lancamento na craplem de tarifa de cadastro
      TARI0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => vr_cdbattar_cad
                                            ,pr_dsconteu => vr_cdhiscad_lem
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_erro
                                            ,pr_tab_erro => vr_tab_erro);

      -- Verifica se Houve Erro no Retorno
      IF vr_des_erro = 'NOK' OR vr_tab_erro.count > 0 OR vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        -- Envio Centralizado de Log de Erro
        IF vr_tab_erro.count > 0 THEN

          -- Recebe Descrição do Erro
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
        RAISE vr_exc_saida;
      END IF;
      
      -- Buscar historico para lancamento na craplem de tarifa de avaliacao de garantia 
      TARI0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => vr_cdbattar_ava
                                            ,pr_dsconteu => vr_cdhisgar_lem
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_erro
                                            ,pr_tab_erro => vr_tab_erro);

      -- Verifica se Houve Erro no Retorno
      IF vr_des_erro = 'NOK' OR vr_tab_erro.count > 0 OR vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        -- Envio Centralizado de Log de Erro
        IF vr_tab_erro.count > 0 THEN

          -- Recebe Descrição do Erro
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
        RAISE vr_exc_saida;
      END IF;
      
      pr_cdhistor := vr_cdhiscad_lem;
      pr_cdhisgar := vr_cdhisgar_lem;
      
        
    END IF;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;
  END pc_calcula_tarifa;
  
 PROCEDURE pc_envia_email_tarifa(pr_rowid  IN rowid,
                                 pr_des_erro OUT varchar2) IS
                              
    cursor c_dados is 
    select l.cdcooper,
           c.nmrescop,
           l.nrdconta,
           l.vltarifa,
           l.cdlantar,
           l.cdhistor,
           h.dshistor,
           l.progress_recid
      from craplat l,
           crapcop c,
           craphis h
     where l.rowid    = pr_rowid        
       and l.cdcooper = c.cdcooper
       and l.cdcooper = h.cdcooper
       and l.cdhistor = h.cdhistor;    
   r_dados c_dados%rowtype;                    
                              
  vr_des_erro   varchar2(500);
  vr_exc_erro   exception;
  vr_assunto    varchar2(4000);
  vr_prm_emails varchar2(4000) := gene0001.fn_param_sistema('CRED',0,'EMAIL_TARIFAS_NENC');
  vr_corpo      varchar2(4000);  
  vr_proxima_linha   varchar2(100) := '<br /><br />';  
  vr_flg_remove_anex char(1) := 'N';
  

  BEGIN
    --    Autor   : Paulo Martins (Mout-s)
    --    Data    : Julho/2018                         
    --
    --    Objetivo  : Caso não encontre tarifa, envia e-mail para área avisando
    IF vr_prm_emails IS NULL THEN
       vr_des_erro := 'Não localizou o parâmetro "EMAIL_TARIFAS_NENC" com os e-mails para envio.';
       RAISE vr_exc_erro;    
    END IF; 
    --
    vr_assunto := 'Não encontrado a tarifa no processo de lançamento na conta do cooperado';      
    
    open c_dados;
     fetch c_dados into r_dados;
      --
      vr_corpo := 'Cooperativa: '||r_dados.cdcooper||' -  '||r_dados.nmrescop||vr_proxima_linha;
      vr_corpo := vr_corpo||'Conta: '||r_dados.nrdconta||vr_proxima_linha;
      vr_corpo := vr_corpo||vr_proxima_linha;
      vr_corpo := vr_corpo||'Código Lançamento: '||r_dados.cdlantar||vr_proxima_linha;
      vr_corpo := vr_corpo||'Valor da Tarifa: '||r_dados.vltarifa||vr_proxima_linha;      
      vr_corpo := vr_corpo||'Código Histórico: '||r_dados.cdhistor||' - '||r_dados.dshistor||vr_proxima_linha;      
      vr_corpo := vr_corpo||'Data/Hora: '||to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||vr_proxima_linha;  
      vr_corpo := vr_corpo||vr_proxima_linha;
      vr_corpo := vr_corpo||vr_proxima_linha;
      vr_corpo := vr_corpo||vr_proxima_linha;
      vr_corpo := vr_corpo||'Informação para T.I - Progress_recid: '||r_dados.progress_recid;
      --
    close c_dados;
    -- Chamar o agendamento deste e-mail
    gene0003.pc_solicita_email(pr_cdcooper    => r_dados.cdcooper
                              ,pr_cdprogra    => 'TARI0001'
                              ,pr_des_destino => vr_prm_emails
                              ,pr_flg_remove_anex => 'S' --> Remove os anexos
                              ,pr_des_assunto => vr_assunto
                              ,pr_des_corpo   => vr_corpo
                              ,pr_des_anexo   => Null
                              ,pr_des_erro    => vr_des_erro);
    -- Se houver erro
    IF vr_des_erro IS NOT NULL THEN
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN --> Erro tratado
      -- Efetuar rollback
      ROLLBACK;
      pr_des_erro := 'TARI0001.pc_envia_email_tarifa --> : '|| sqlerrm;                                        
    WHEN OTHERS THEN -- Gerar log de erro
      -- Efetuar rollback
      ROLLBACK;
      pr_des_erro := 'TARI0001.pc_envia_email_tarifa --> : '|| sqlerrm;
  END pc_envia_email_tarifa;   
  
  
  /* Verificar se o saque será tarifado e o valor da tarifa */
  PROCEDURE pc_verifica_tarifa_saque(pr_cdcooper IN NUMBER                     --> Codigo da Cooperativa
                                    ,pr_dtmvtolt IN DATE                       --> Data Lancamento
                                    ,pr_idorigem IN INTEGER                    --> Identificador Origem(1-AYLLOS,2-CAIXA,3-INTERNET,4-TAA,5-AYLLOS WEB,6-URA)
                                    ,pr_nrdconta IN INTEGER                    --> Numero da Conta
                                    ,pr_tipostaa IN INTEGER                    --> Tipo de TAA que foi efetuado a operacao(0-Cooperativas Filiadas,1-BB, 2-Banco 24h, 3-Banco 24h compartilhado, 4-Rede Cirrus)
                                    ,pr_fliseope OUT INTEGER                   --> Flag indica se ira isentar tarifa:0-Não isenta,1-Isenta
                                    ,pr_vltarifa OUT NUMBER                    --> Valor da Tarifa
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica  
    /* ............................................................................
    
       Programa: pc_verifica_tarifa_saque
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Douglas Quisinski
       Data    : Abril/2018                        Ultima atualizacao: 23/10/2018
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que chamado
       Objetivo  : Verificar se o saque será tarifado e o valor da tarifa
       
       Disparado por: Sistema SOA
       
       Alteracoes: 
       23/10/2018 - Padrões: Others, Modulo/Action, PC Internal Exception, PC Log Programa
                    SELECT's, Parâmetros, troca de mensagens por código
                    (Envolti - Belli - REQ0011726)          
     ............................................................................ */
  
    ------------------- CURSOR --------------------
    CURSOR cr_crapass IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    CURSOR cr_tbcc_operacoes_diarias IS
      SELECT COUNT(tbc.cdcooper) AS numregis,
             NVL(MAX(tbc.nrsequen), 0) AS nrsequen
        FROM tbcc_operacoes_diarias tbc
       WHERE tbc.cdcooper = pr_cdcooper
         AND tbc.nrdconta = pr_nrdconta
         AND tbc.cdoperacao = 1 -- SAQUE
         AND TO_CHAR(tbc.dtoperacao, 'MM/RRRR') = TO_CHAR(pr_dtmvtolt, 'MM/RRRR');
    rw_tbcc_operacoes_diarias cr_tbcc_operacoes_diarias%ROWTYPE;
  
    -- Verifica pacote de tarifas
    CURSOR cr_tbtarif_contas_pacote(pr_cdcooper crapcop.cdcooper%TYPE,
                                    pr_nrdconta crapass.nrdconta%TYPE,
                                    pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT cta.cdcooper, cta.nrdconta, cta.cdpacote
        FROM tbtarif_contas_pacote cta
       WHERE cta.cdcooper = pr_cdcooper
         AND cta.nrdconta = pr_nrdconta
         AND cta.flgsituacao = 1
         AND cta.dtinicio_vigencia <= pr_dtmvtolt;
    rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;
  
    --Selecionar faixa valor por cooperativa
    CURSOR cr_crapfco(pr_cdfvlcop IN crapfco.cdfvlcop%TYPE) IS
      SELECT crapfco.cdfaixav
        FROM crapfco
       WHERE crapfco.cdfvlcop = pr_cdfvlcop;
    rw_crapfco cr_crapfco%ROWTYPE;
  
    -- Consultar faixas de valores
    CURSOR cr_crapfvl(pr_cdfaixav IN crapfvl.cdfaixav%TYPE) IS
      SELECT crapfvl.cdtarifa
        FROM crapfvl
       WHERE crapfvl.cdfaixav = pr_cdfaixav;
    rw_crapfvl cr_crapfvl%ROWTYPE;
  
    CURSOR cr_tbtarif_servicos(pr_cdpacote tbtarif_servicos.cdpacote%TYPE,
                               pr_cdtarif  tbtarif_servicos.cdtarifa%TYPE) IS
      SELECT tbtarif_servicos.qtdoperacoes
        FROM tbtarif_servicos
       WHERE tbtarif_servicos.cdpacote = pr_cdpacote
         AND tbtarif_servicos.cdtarifa = pr_cdtarif;
    rw_tbtarif_servicos cr_tbtarif_servicos%ROWTYPE;
  
    --Tipo de Dados para cursor data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    ------------------ VARIAVEIS ------------------
  
    -- Variaveis de critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida EXCEPTION;
    vr_exc_null  EXCEPTION;
  
    -- Variaveis locais
    vr_cdbattar      crapbat.cdbattar%TYPE;
    vr_dsconteu      VARCHAR(100); --> Auxiliar para retornar da funcao de busca de parametro
    
    vr_des_erro      VARCHAR2(100);
    vr_tab_erro      GENE0001.typ_tab_erro;
  
    vr_cdhistor INTEGER; --Codigo Historico
    vr_cdhisest NUMBER; --Historico Estorno
    vr_vltarifa NUMBER; --Valor tarifa
    vr_dtdivulg DATE; --Data Divulgacao
    vr_dtvigenc DATE; --Data Vigencia
    vr_cdfvlcop INTEGER; --Codigo faixa valor cooperativa
    vr_cdparame VARCHAR2(10);
    vr_cdbatsaq VARCHAR2(50);
    vr_saqativo BOOLEAN := FALSE;
    -- Variaveis de Log e Modulo - 23/10/2018 - REQ0011726
    vr_dsparame VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotpro VARCHAR2  (100) := 'pc_verifica_tarifa_saque';
    vr_cdproint VARCHAR2  (100);
  BEGIN
    -- Posiciona procedure - 23/10/2018 - REQ0011726
    vr_cdproint := vr_cdproexe||'.'||vr_nmrotpro;
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);    
    vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                   ', pr_dtmvtolt:' || pr_dtmvtolt ||
                   ', pr_idorigem:' || pr_idorigem ||
                   ', pr_nrdconta:' || pr_nrdconta ||
                   ', pr_tipostaa:' || pr_tipostaa;
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
  
    -- Buscar os dados do cooperado
    OPEN cr_crapass;
    FETCH cr_crapass
      INTO rw_crapass;
  
    -- Se não encontrar
    IF cr_crapass%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE cr_crapass;
      -- Montar mensagem de critica
      vr_cdcritic := 9;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapass;
    END IF;

    -- Verificar o tipo de pessoa
    IF rw_crapass.inpessoa = 3 THEN
      RAISE vr_exc_null;
    END IF;
  
    pr_fliseope := 0; -- Não isentar tarifa
    pr_vltarifa := 0; -- Inicializar o valor da tarifa
  
    IF rw_crapass.inpessoa = 1 THEN
      -- Pessoa Fisica
      vr_cdparame := 'SAQISENTPF';
      vr_cdbatsaq := 'SAQUEPACPF'; /* Tarifa do pacote */
    ELSIF rw_crapass.inpessoa = 2 THEN
      -- Pessoa Juridica
      vr_cdparame := 'SAQISENTPJ';
      vr_cdbatsaq := 'SAQUEPACPJ'; /* Tarifa do pacote */
    END IF;
    
    CASE pr_idorigem
      WHEN 2 THEN -- Caixa Online
        IF pr_tipostaa = 0  THEN --Tipo de saque avulso com cartao.
            IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
          vr_cdbattar := 'SAQUEPREPF';
            ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
          vr_cdbattar := 'SAQUEPREPJ';
            END IF;
        ELSE   
          IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
            vr_cdbattar := 'SAQUEAVUPF';
            --vr_cdbatsaq := 'SAQUEAVUPF';
          ELSIF rw_crapass.inpessoa = 2 THEN -- Pessoa Juridica
            vr_cdbattar := 'SAQUEAVUPJ';
            --vr_cdbatsaq := 'SAQUEAVUPJ';
          END IF;
        END IF;
      WHEN 4 THEN
        -- TAA
        CASE pr_tipostaa
          WHEN 0 THEN
            -- Cooperativas Filiadas
            IF rw_crapass.inpessoa = 1 THEN
              -- Pessoa Fisica
              vr_cdbattar := 'SAQUETAAPF';
            ELSIF rw_crapass.inpessoa = 2 THEN
              -- Pessoa Juridica
              vr_cdbattar := 'SAQUETAAPJ';
            END IF;
          WHEN 1 THEN
            -- BB
            IF rw_crapass.inpessoa = 1 THEN
              -- Pessoa Fisica
              vr_cdbattar := 'SAQCRTBBPF';
            ELSIF rw_crapass.inpessoa = 2 THEN
              -- Pessoa Juridica
              vr_cdbattar := 'SAQCRTBBPJ';
            END IF;
          WHEN 2 THEN
            -- Banco 24h
            IF rw_crapass.inpessoa = 1 THEN
              -- Pessoa Fisica
              vr_cdbattar := 'SAQBAN24PF';
            ELSIF rw_crapass.inpessoa = 2 THEN
              -- Pessoa Juridica
              vr_cdbattar := 'SAQBAN24PJ';
            END IF;
          WHEN 3 THEN
            -- Banco 24h compartilhado
            IF rw_crapass.inpessoa = 1 THEN
              -- Pessoa Fisica
              vr_cdbattar := 'SAQREDCOPF';
            ELSIF rw_crapass.inpessoa = 2 THEN
              -- Pessoa Juridica
              vr_cdbattar := 'SAQREDCOPJ';
            END IF;
          WHEN 4 THEN
            -- Rede Cirrus
            IF rw_crapass.inpessoa = 1 THEN
              -- Pessoa Fisica
              vr_cdbattar := 'SAQCIRRUPF';
            ELSIF rw_crapass.inpessoa = 2 THEN
              -- Pessoa Juridica
              vr_cdbattar := 'SAQCIRRUPJ';
            END IF;
          ELSE
            -- Origem desconhecida
            vr_dscritic := 1396; -- Chamada de origem desconhecida - Trata exceções - 23/10/2018 - REQ0011726
            RAISE vr_exc_saida;
        END CASE;
      ELSE
        -- Origem desconhecida
        vr_cdcritic := 1395; -- Origem desconhecida - Trata exceções - 23/10/2018 - REQ0011726
        RAISE vr_exc_saida;
    END CASE;    
    
    vr_dsparame := vr_dsparame ||
                   ', vr_cdparame:' || vr_cdparame ||
                   ', vr_cdbatsaq:' || vr_cdbatsaq ||
                   ', vr_cdbattar:' || vr_cdbattar;
  
    -- Verificar se existe pacote de tarifas ativo/vigente na tabela tbtarif_contas_pacote:   
    OPEN cr_tbtarif_contas_pacote(pr_cdcooper => pr_cdcooper,
                                  pr_nrdconta => pr_nrdconta,
                                  pr_dtmvtolt => rw_crapdat.dtmvtolt);
  
    FETCH cr_tbtarif_contas_pacote
      INTO rw_tbtarif_contas_pacote;

    IF cr_tbtarif_contas_pacote%FOUND THEN
    
      CLOSE cr_tbtarif_contas_pacote;
    
      TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper,
                                            pr_cdbattar => vr_cdbatsaq,
                                            pr_vllanmto => 0,
                                            pr_cdprogra => '',
                                            pr_cdhistor => vr_cdhistor,
                                            pr_cdhisest => vr_cdhisest,
                                            pr_vltarifa => vr_vltarifa,
                                            pr_dtdivulg => vr_dtdivulg,
                                            pr_dtvigenc => vr_dtvigenc,
                                            pr_cdfvlcop => vr_cdfvlcop,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic,
                                            pr_tab_erro => vr_tab_erro);
    
      -- Verifica se Houve Erro no Retorno
      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 OR
         vr_tab_erro.count > 0 THEN
        -- Envio Centralizado de Log de Erro
        IF vr_tab_erro.count > 0 THEN
        
          -- Recebe Descrição do Erro
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- Trata exceções - 23/10/2018 - REQ0011726  
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
        RAISE vr_exc_saida;
      END IF;
      -- Retorna módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);  
    
      OPEN cr_crapfco(pr_cdfvlcop => vr_cdfvlcop);
    
      FETCH cr_crapfco
        INTO rw_crapfco;
    
      IF cr_crapfco%NOTFOUND THEN
        CLOSE cr_crapfco;
        vr_cdcritic := 1391; -- Registro de ligacao entre faixas de valores das tarifas e cooperativa nao encontrado - Trata exceções - 23/10/2018 - REQ0011726
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapfco;
      END IF;
    
      OPEN cr_crapfvl(pr_cdfaixav => rw_crapfco.cdfaixav);
    
      FETCH cr_crapfvl
        INTO rw_crapfvl;
    
      IF cr_crapfvl%NOTFOUND THEN
        CLOSE cr_crapfvl;
        vr_cdcritic := 1392; -- Registro de faixas de tarifa nao encontrado - Trata exceções - 23/10/2018 - REQ0011726
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapfvl;
      END IF;
    
      OPEN cr_tbtarif_servicos(pr_cdpacote => rw_tbtarif_contas_pacote.cdpacote,
                               pr_cdtarif  => rw_crapfvl.cdtarifa);
    
      FETCH cr_tbtarif_servicos
        INTO rw_tbtarif_servicos;
    
      IF cr_tbtarif_servicos%NOTFOUND THEN
      
        CLOSE cr_tbtarif_servicos;
      ELSE
        CLOSE cr_tbtarif_servicos;
      
        -- Operação de saque
        vr_saqativo := TRUE; -- Possui servico de saque ativo
      
        -- Consulta quantidade de saques já efetuados
        OPEN cr_tbcc_operacoes_diarias;
          
        FETCH cr_tbcc_operacoes_diarias
          INTO rw_tbcc_operacoes_diarias;
        CLOSE cr_tbcc_operacoes_diarias;
        
        -- Verificar se o próximo saque é tarifado
        IF rw_tbcc_operacoes_diarias.numregis < rw_tbtarif_servicos.qtdoperacoes THEN
          pr_fliseope := 1; -- Não tarifar    
        END IF;
        
        RAISE vr_exc_null;
      
      END IF;
    ELSE
      CLOSE cr_tbtarif_contas_pacote;
    END IF;
  
    -- Verifica quantidade de saques isentos
    TARI0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper,
                                           pr_cdbattar => vr_cdparame,
                                           pr_dsconteu => vr_dsconteu,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic,
                                           pr_des_erro => vr_des_erro,
                                           pr_tab_erro => vr_tab_erro);
  
    -- Verifica se Houve Erro no Retorno
    IF vr_des_erro = 'NOK' OR vr_tab_erro.count > 0 OR
       vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
      -- Envio Centralizado de Log de Erro
      IF vr_tab_erro.count > 0 THEN
      
        -- Recebe Descrição do Erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- Trata exceções - 23/10/2018 - REQ0011726
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        RAISE vr_exc_saida;
      END IF;
      RAISE vr_exc_saida;
    END IF;
    -- Retorna módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);  
  
    -- Consulta quantidade de saques já efetuados
    OPEN cr_tbcc_operacoes_diarias;
  
    FETCH cr_tbcc_operacoes_diarias
      INTO rw_tbcc_operacoes_diarias;
    CLOSE cr_tbcc_operacoes_diarias;
  
    -- Se nao possui servico de saque no pacote, verifica parametros de insencao da cooperativa
    IF NOT vr_saqativo THEN
    
      -- Verificar se o próximo saque é tarifado
      IF rw_tbcc_operacoes_diarias.numregis < vr_dsconteu THEN
      
        pr_fliseope := 1; -- Não tarifar
        RAISE vr_exc_null;
      
      END IF;
    
    END IF;
  
    TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper,
                                          pr_cdbattar => vr_cdbattar,
                                          pr_vllanmto => 0,
                                          pr_cdprogra => '',
                                          pr_cdhistor => vr_cdhistor,
                                          pr_cdhisest => vr_cdhisest,
                                          pr_vltarifa => vr_vltarifa,
                                          pr_dtdivulg => vr_dtdivulg,
                                          pr_dtvigenc => vr_dtvigenc,
                                          pr_cdfvlcop => vr_cdfvlcop,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic,
                                          pr_tab_erro => vr_tab_erro);
  
    -- Verifica se Houve Erro no Retorno
    IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 OR
       vr_tab_erro.count > 0 THEN
      -- Envio Centralizado de Log de Erro
      IF vr_tab_erro.count > 0 THEN
      
        -- Recebe Descrição do Erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- Trata exceções - 23/10/2018 - REQ0011726
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        RAISE vr_exc_saida;
      END IF;
      RAISE vr_exc_saida;
    END IF;
    -- Retorna módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_cdproint);  
  
    IF vr_vltarifa > 0 THEN
      pr_vltarifa := vr_vltarifa;
    END IF;
    
    -- Retorna módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);  
    
  -- Trata exceções - 23/10/2018 - REQ0011726  
  EXCEPTION
    WHEN vr_exc_null THEN
      pr_cdcritic := 0;
      pr_dscritic := '';
      -- Retorna módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);  
    WHEN vr_exc_saida THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic );			
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic; 
      -- Controlar geração de log de execução dos jobs   
      tari0001.pc_log(pr_cdcooper => pr_cdcooper
                     ,pr_dscritic => pr_dscritic ||
                                     ' '  || vr_nmrotpro || 
                                     '. ' || vr_dsparame
                     ,pr_cdcritic => pr_cdcritic);    
      ROLLBACK;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' '  || vr_nmrotpro || 
                     ' '  || SQLERRM     ||
                     '. ' || vr_dsparame; 
      -- Controlar geração de log de execução dos jobs   
      tari0001.pc_log(pr_cdcooper => pr_cdcooper
                     ,pr_dscritic => pr_dscritic
                     ,pr_cdcritic => pr_cdcritic);
      ROLLBACK;
  END pc_verifica_tarifa_saque;
	--
	-- Estorno da tarifa de ADP
	PROCEDURE pc_estorno_tarifa_adp(pr_cdcooper IN  craplat.cdcooper%TYPE
																 ,pr_nrdconta IN  craplat.nrdconta%TYPE
																 ,pr_dscritic OUT VARCHAR2
		                             ) IS
		/* ............................................................................
    
       Programa: pc_estorno_tarifa_adp
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Adriano Nagasava
       Data    : Novembro/2018                        Ultima atualizacao: 
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que chamado
       Objetivo  : Verifica se existe cobrança de tarifa de adiantamento a depositante e se o saldo do cooperado foi regularizado
			             ao ter sido devolvido o(s) cheque(s). Caso positivo, estorna a tarifa de adiantamento a depositante (APD).
    
       Alteracoes: 
    ............................................................................ */
		
		-- Busca a cobrança de tarifa de adiantamento a depositante
		CURSOR cr_busca_adp(pr_cdcooper craplat.cdcooper%TYPE
											 ,pr_nrdconta craplat.nrdconta%TYPE
											 ,pr_dtmvtolt craplat.dtmvtolt%TYPE
											 ) IS
			SELECT craplat.cdlantar
						,craplat.dtefetiv
						,craplat.insitlat
						,craplat.cdpesqbb
						,craplat.cdhistor
				FROM craplat
			 WHERE cdcooper = pr_cdcooper
				 AND nrdconta = pr_nrdconta
				 AND cdhistor IN(SELECT crapfvl.cdhistor
													 FROM crapbat
															 ,craptar
															 ,crapfvl
													WHERE crapbat.cdcadast = craptar.cdtarifa
														AND craptar.cdtarifa = crapfvl.cdtarifa
														AND 1 BETWEEN crapfvl.vlinifvl AND crapfvl.vlfinfvl
														AND crapbat.cdbattar IN('ADTODEPOPF', 'ADTODEPOPJ')
												)
				 AND insitlat IN(1, 2)
				 AND dtmvtolt = pr_dtmvtolt
				 AND dtdestor IS NULL;
		--
		rw_busca_adp cr_busca_adp%ROWTYPE;
					 
		-- Busca o valor total dos cheques devolvidos
		CURSOR cr_busca_cheques_devolvidos(pr_cdcooper crapdev.cdcooper%TYPE
																			,pr_nrdconta crapdev.nrdconta%TYPE
																			,pr_dtmvtolt crapdev.dtmvtolt%TYPE
																			) IS
			SELECT sum(crapdev.vllanmto) vllanmto_tot
				FROM crapdev
			 WHERE crapdev.cdcooper = pr_cdcooper
				 AND crapdev.nrdconta = pr_nrdconta
				 AND crapdev.cdhistor = 47 -- CHQ.DEVOL.
				 AND crapdev.insitdev = 1 -- Devolvido
				 AND crapdev.dtmvtolt = pr_dtmvtolt;

		-- Busca o saldo do dia anterior
		CURSOR cr_saldo_dia_anterior(pr_cdcooper crapsda.cdcooper%TYPE
																,pr_nrdconta crapsda.nrdconta%TYPE
																,pr_dtmvtolt crapsda.dtmvtolt%TYPE
																) IS
		SELECT crapsda.vlsddisp + crapsda.vlsdchsl + NVL(crapsda.vllimcre,0) vlsldant
			FROM crapsda
		 WHERE crapsda.cdcooper = pr_cdcooper
			 AND crapsda.nrdconta = pr_nrdconta
			 AND crapsda.dtmvtolt = pr_dtmvtolt;
			 
		-- Busca o histórico de estorno da tarifa de adiantamento a depositante
		CURSOR cr_busca_hist_estorno(pr_cdhistor crapfvl.cdhisest%TYPE
		                            ) IS
			SELECT crapfvl.cdhisest
				FROM crapbat
						,craptar
						,crapfvl
			 WHERE crapbat.cdcadast = craptar.cdtarifa
				 AND craptar.cdtarifa = crapfvl.cdtarifa
				 AND 1 BETWEEN crapfvl.vlinifvl AND crapfvl.vlfinfvl
				 AND crapbat.cdbattar IN('ADTODEPOPF', 'ADTODEPOPJ')
				 AND crapfvl.cdhistor = pr_cdhistor;
		
		-- Busca cobrança da tarifa parcial ou total
		CURSOR cr_cobr_tarifa(pr_cdcooper crapsda.cdcooper%TYPE
												 ,pr_dtmvtolt crapsda.dtmvtolt%TYPE
												 ,pr_cdhistor craplat.cdhistor%TYPE
												 ,pr_nrdconta crapsda.nrdconta%TYPE
												 ,pr_cdpesqbb craplcm.cdpesqbb%TYPE
												 ) IS
			SELECT craplcm.cdcooper
						,craplcm.dtmvtolt
						,craplcm.cdagenci
						,craplcm.cdbccxlt
						,craplcm.nrdolote
						,craplcm.nrdctabb
						,craplcm.nrdocmto
						,craplcm.nrdctitg
						,craplcm.cdpesqbb
						,craplcm.cdbanchq
						,craplcm.cdagechq
						,craplcm.nrctachq
						,craplcm.vllanmto
						,craplcm.cdcoptfn
						,craplcm.cdagetfn
						,craplcm.nrterfin
						,craplcm.nrsequni
						,craplcm.nrautdoc
						,craplcm.dsidenti
				FROM craplcm
			 WHERE craplcm.cdcooper = pr_cdcooper
				 AND craplcm.dtmvtolt = pr_dtmvtolt
				 AND craplcm.cdhistor = pr_cdhistor
				 AND craplcm.nrdconta = pr_nrdconta
				 AND craplcm.cdpesqbb = pr_cdpesqbb;
		--
		rw_cobr_tarifa cr_cobr_tarifa%ROWTYPE;
	  --
		vr_vllanmto_tot NUMBER := 0;
		vr_vlsldant     NUMBER := 0;
		vr_vlslnegat    NUMBER := -20.0;
		vr_dscritic     VARCHAR2(4000);
		--
		vr_exc_erro     EXCEPTION;
		--
		vr_cdhistor     craplcm.cdhistor%TYPE;
		-- Tipo de dados para cursor data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
		--
		vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
		--
		PROCEDURE pc_atualiza_craplat(pr_cdlantar IN  craplat.cdlantar%TYPE
																 ,pr_insitlat IN  craplat.insitlat%TYPE
																 ,pr_dtdestor IN  craplat.dtdestor%TYPE
																 ,pr_dscritic OUT VARCHAR2
																 ) IS
			--
		BEGIN
			/*-- Carrega os dados
			GENE0002.pc_escreve_xml(pr_xml            => vr_clob           
														 ,pr_texto_completo => vr_xml_temp
														 ,pr_texto_novo     => 'Achou pc_atualiza_craplat'
														 );*/
			--
			UPDATE craplat
				 SET craplat.insitlat = pr_insitlat
						,craplat.cdmotest = 1 -- Cobrança Indevida
						,craplat.dtdestor = pr_dtdestor
						,craplat.cdopeest = '1' -- Fixo
			 WHERE craplat.cdlantar = pr_cdlantar;
			--
		EXCEPTION
			WHEN OTHERS THEN
				pr_dscritic := 'Erro ao atualizar a craplat: ' || SQLERRM;
		END pc_atualiza_craplat;
		--
		PROCEDURE pc_gera_lancto_estorno_cc(pr_cdcooper IN  craplcm.cdcooper%TYPE
																			 ,pr_cdagenci IN  craplcm.cdagenci%TYPE
																			 ,pr_nrdconta IN  craplcm.nrdconta%TYPE
																			 ,pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
																			 ,pr_nrdolote IN  craplcm.nrdolote%TYPE
																			 ,pr_tplotmov IN  craplot.tplotmov%TYPE
																			 ,pr_cdoperad IN  craplcm.cdoperad%TYPE
																			 ,pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
																			 ,pr_nrdctabb IN  craplcm.nrdctabb%TYPE
																			 ,pr_nrdctitg IN  craplcm.nrdctitg%TYPE
																			 ,pr_cdhistor IN  craplcm.cdhistor%TYPE
																			 ,pr_cdpesqbb IN  craplcm.cdpesqbb%TYPE
																			 ,pr_cdbanchq IN  craplcm.cdbanchq%TYPE
																			 ,pr_cdagechq IN  craplcm.cdagechq%TYPE
																			 ,pr_nrctachq IN  craplcm.nrctachq%TYPE
																			 ,pr_vltarifa IN  NUMBER
																			 ,pr_nrdocmto IN  craplcm.nrdocmto%TYPE
																			 ,pr_cdcoptfn IN  craplcm.cdcoptfn%TYPE
																			 ,pr_cdagetfn IN  craplcm.cdagetfn%TYPE
																			 ,pr_nrterfin IN  craplcm.nrterfin%TYPE
																			 ,pr_nrsequni IN  craplcm.nrsequni%TYPE
																			 ,pr_nrautdoc IN  craplcm.nrautdoc%TYPE
																			 ,pr_dsidenti IN  craplcm.dsidenti%TYPE
																			 ,pr_dscritic OUT VARCHAR2
																			 ) IS
		--
		rw_craplot lote0001.cr_craplot%ROWTYPE;
		--
		vr_nrdocmto craplcm.nrdocmto%TYPE;
		--
		BEGIN
			-- Gera a CRAPLOT
			LOTE0001.pc_insere_lote(pr_cdcooper => pr_cdcooper
														 ,pr_dtmvtolt => pr_dtmvtolt
														 ,pr_cdagenci => pr_cdagenci
														 ,pr_cdbccxlt => pr_cdbccxlt
														 ,pr_nrdolote => pr_nrdolote
														 ,pr_cdoperad => pr_cdoperad
														 ,pr_nrdcaixa => NULL
														 ,pr_tplotmov => pr_tplotmov
														 ,pr_cdhistor => pr_cdhistor
														 -- Out 
														 ,pr_craplot  => rw_craplot
														 ,pr_dscritic => pr_dscritic
														 );
			--
			IF pr_dscritic IS NULL THEN
				--
				BEGIN
					--
					IF pr_nrdocmto > 0 THEN
						--
						vr_nrdocmto := pr_nrdocmto;
						--
					ELSE
						--
						vr_nrdocmto := rw_craplot.nrseqdig;
						--
					END IF;
					--
					INSERT INTO craplcm(cdcooper
														 ,dtmvtolt
														 ,cdagenci
														 ,cdbccxlt
														 ,nrdolote
														 ,dtrefere
														 ,hrtransa
														 ,cdoperad
														 ,nrdconta
														 ,nrdctabb
														 ,nrdctitg
														 ,nrseqdig
														 ,nrsequni
														 ,nrdocmto
														 ,cdhistor
														 ,vllanmto
														 ,cdpesqbb
														 ,cdbanchq
														 ,cdagechq
														 ,nrctachq
														 ,cdcoptfn
														 ,cdagetfn
														 ,nrterfin
														 ,nrautdoc
														 ,dsidenti
														 )
											 VALUES(pr_cdcooper
														 ,rw_craplot.dtmvtolt
														 ,pr_cdagenci
														 ,pr_cdbccxlt
														 ,pr_nrdolote
														 ,rw_craplot.dtmvtolt
														 ,to_char(SYSDATE, 'sssss')
														 ,pr_cdoperad
														 ,pr_nrdconta
														 ,pr_nrdctabb
														 ,pr_nrdctitg
														 ,rw_craplot.nrseqdig
														 ,decode(pr_nrsequni, 0, rw_craplot.nrseqdig, pr_nrsequni)
														 ,vr_nrdocmto
														 ,pr_cdhistor
														 ,pr_vltarifa
														 ,pr_cdpesqbb
														 ,pr_cdbanchq
														 ,pr_cdagechq
														 ,pr_nrctachq
														 ,pr_cdcoptfn
														 ,pr_cdagetfn
														 ,pr_nrterfin
														 ,pr_nrautdoc
														 ,pr_dsidenti
														 );
					--
				EXCEPTION
					WHEN OTHERS THEN
						pr_dscritic := 'Erro ao gerar o lancamento na CRAPLCM: ' || SQLERRM;
				END;
				--
			END IF;
			--
		END pc_gera_lancto_estorno_cc;
		--
	BEGIN
		/*-- Cria a variavel CLOB
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);*/

		/*-- Carrega os dados
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob           
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => 'Chamou a pc_estorno_tarifa_adp'
													 );*/

		-- Leitura do calendário da cooperativa
		OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
		FETCH btch0001.cr_crapdat
			INTO rw_crapdat;
		-- Se não encontrar
		IF btch0001.cr_crapdat%NOTFOUND THEN
			-- Fechar o cursor pois efetuaremos raise
			CLOSE btch0001.cr_crapdat;
			-- Montar mensagem de critica
			vr_dscritic := 'Erro ao buscar a data do movimento.';
			RAISE vr_exc_erro;
		ELSE
			-- Apenas fechar o cursor
			CLOSE btch0001.cr_crapdat;
		END IF;	
		-- Busca a cobrança de tarifa de adiantamento a depositante
		OPEN cr_busca_adp(pr_cdcooper
										 ,pr_nrdconta
										 ,rw_crapdat.dtmvtoan
										 );
		--
		FETCH cr_busca_adp INTO rw_busca_adp;
		--
		CLOSE cr_busca_adp;
		-- Verifica se achou a cobrança de tarifa de adiantamento a depositante
		IF nvl(rw_busca_adp.cdlantar, 0) > 0 THEN
			/*-- Carrega os dados
			GENE0002.pc_escreve_xml(pr_xml            => vr_clob           
														 ,pr_texto_completo => vr_xml_temp
														 ,pr_texto_novo     => 'Achou cr_busca_adp'
														 );*/

			OPEN cr_busca_cheques_devolvidos(pr_cdcooper
																			,pr_nrdconta
																			,rw_crapdat.dtmvtoan
																			);
			--
			FETCH cr_busca_cheques_devolvidos INTO vr_vllanmto_tot;
			--
			CLOSE cr_busca_cheques_devolvidos;
			-- Verifica se achou devoluções de cheques
			IF nvl(vr_vllanmto_tot, 0) > 0 THEN
				/*-- Carrega os dados
				GENE0002.pc_escreve_xml(pr_xml            => vr_clob           
															 ,pr_texto_completo => vr_xml_temp
															 ,pr_texto_novo     => 'Achou cr_busca_cheques_devolvidos'
															 );*/

				OPEN cr_saldo_dia_anterior(pr_cdcooper
																	,pr_nrdconta
																	,rw_crapdat.dtmvtoan
																	);
				--
				FETCH cr_saldo_dia_anterior INTO vr_vlsldant;
				--
				CLOSE cr_saldo_dia_anterior;
				-- Verifica se a soma do saldo do dia anterior com o valor dos cheques devolvidos regulariza o saldo da conta
				IF NVL((vr_vlsldant + vr_vllanmto_tot), 0) >= vr_vlslnegat THEN
					/*-- Carrega os dados
					GENE0002.pc_escreve_xml(pr_xml            => vr_clob           
																 ,pr_texto_completo => vr_xml_temp
																 ,pr_texto_novo     => 'Achou cr_saldo_dia_anterior'
																 );*/

					-- Busca o histórico de estorno da tarifa de adiantamento a depositante
					OPEN cr_busca_hist_estorno(rw_busca_adp.cdhistor
		                                );
					--
					FETCH cr_busca_hist_estorno INTO vr_cdhistor;
					--
					IF cr_busca_hist_estorno%NOTFOUND THEN
						--
						vr_dscritic := 'Historico de estorno nao encontrado para o lancamento de historico: ' || rw_busca_adp.cdhistor;
            --
						CLOSE cr_busca_hist_estorno;
						--
						RAISE vr_exc_erro;
						--
					ELSE
						--
						CLOSE cr_busca_hist_estorno;
						--
					END IF;
					-- Se o lançamento estiver pendente, deve ser baixado
					IF rw_busca_adp.insitlat = 1 THEN
						/*-- Carrega os dados
						GENE0002.pc_escreve_xml(pr_xml            => vr_clob           
																	 ,pr_texto_completo => vr_xml_temp
																	 ,pr_texto_novo     => 'Achou cr_busca_hist_estorno'
																	 );*/

						-- Atualiza o lançamento de tarifa para Baixado
						pc_atualiza_craplat(pr_cdlantar => rw_busca_adp.cdlantar -- IN
															 ,pr_insitlat => 3                     -- IN -- Baixado
															 ,pr_dtdestor => rw_crapdat.dtmvtolt   -- IN
															 ,pr_dscritic => vr_dscritic           -- OUT
															 );
						--
						IF vr_dscritic IS NOT NULL THEN
							--
							RAISE vr_exc_erro;
							--
						END IF;
						-- Verifica se houve cobrança parcial
						OPEN cr_cobr_tarifa(pr_cdcooper
															 ,rw_crapdat.dtmvtolt
															 ,rw_busca_adp.cdhistor
															 ,pr_nrdconta
															 ,rw_busca_adp.cdpesqbb
															 );
						--
						LOOP
							--
							FETCH cr_cobr_tarifa INTO rw_cobr_tarifa;
							EXIT WHEN cr_cobr_tarifa%NOTFOUND;
								
							-- Gera estorno caso encontre a cobrança de tarifa
							pc_gera_lancto_estorno_cc(pr_cdcooper => pr_cdcooper             -- IN
																			 ,pr_cdagenci => rw_cobr_tarifa.cdagenci -- IN
																			 ,pr_nrdconta => pr_nrdconta             -- IN
																			 ,pr_cdbccxlt => rw_cobr_tarifa.cdbccxlt -- IN
																			 ,pr_nrdolote => 10030                   -- IN -- Fixo
																			 ,pr_tplotmov => 1                       -- IN
																			 ,pr_cdoperad => 1                       -- IN
																			 ,pr_dtmvtolt => rw_crapdat.dtmvtolt     -- IN
																			 ,pr_nrdctabb => rw_cobr_tarifa.nrdctabb -- IN
																			 ,pr_nrdctitg => rw_cobr_tarifa.nrdctitg -- IN
																			 ,pr_cdhistor => vr_cdhistor             -- IN
																			 ,pr_cdpesqbb => rw_cobr_tarifa.cdpesqbb -- IN
																			 ,pr_cdbanchq => rw_cobr_tarifa.cdbanchq -- IN
																			 ,pr_cdagechq => rw_cobr_tarifa.cdagechq -- IN
																			 ,pr_nrctachq => rw_cobr_tarifa.nrctachq -- IN
																			 ,pr_vltarifa => rw_cobr_tarifa.vllanmto -- IN
																			 ,pr_nrdocmto => rw_cobr_tarifa.nrdocmto -- IN
																			 ,pr_cdcoptfn => rw_cobr_tarifa.cdcoptfn -- IN
																			 ,pr_cdagetfn => rw_cobr_tarifa.cdagetfn -- IN
																			 ,pr_nrterfin => rw_cobr_tarifa.nrterfin -- IN
																			 ,pr_nrsequni => rw_cobr_tarifa.nrsequni -- IN
																			 ,pr_nrautdoc => rw_cobr_tarifa.nrautdoc -- IN
																			 ,pr_dsidenti => rw_cobr_tarifa.dsidenti -- IN
																			 ,pr_dscritic => vr_dscritic             -- OUT
																			 );
							--
							IF vr_dscritic IS NOT NULL THEN
								--
								CLOSE cr_cobr_tarifa;
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
						END LOOP;
						--
						CLOSE cr_cobr_tarifa;
						--
					-- Se o lançamento estiver efetivado, deve ser estornado
					ELSIF rw_busca_adp.insitlat = 2 THEN
						-- Atualiza o lançamento de tarifa para Estornado
						pc_atualiza_craplat(pr_cdlantar => rw_busca_adp.cdlantar -- IN
															 ,pr_insitlat => 4                     -- IN -- Estornado
															 ,pr_dtdestor => rw_crapdat.dtmvtolt   -- IN
															 ,pr_dscritic => vr_dscritic           -- OUT
															 );
						--
						IF vr_dscritic IS NOT NULL THEN
							--
							RAISE vr_exc_erro;
							--
						END IF;
						-- Verifica se houve cobrança total
						OPEN cr_cobr_tarifa(pr_cdcooper
															 ,rw_crapdat.dtmvtolt
															 ,rw_busca_adp.cdhistor
															 ,pr_nrdconta
															 ,rw_busca_adp.cdpesqbb
															 );
						--
						LOOP
							--
							FETCH cr_cobr_tarifa INTO rw_cobr_tarifa;
							EXIT WHEN cr_cobr_tarifa%NOTFOUND;
								
							-- Gera estorno caso encontre a cobrança de tarifa
							pc_gera_lancto_estorno_cc(pr_cdcooper => pr_cdcooper             -- IN
																			 ,pr_cdagenci => rw_cobr_tarifa.cdagenci -- IN
																			 ,pr_nrdconta => pr_nrdconta             -- IN
																			 ,pr_cdbccxlt => rw_cobr_tarifa.cdbccxlt -- IN
																			 ,pr_nrdolote => 10030                   -- IN -- Fixo
																			 ,pr_tplotmov => 1                       -- IN
																			 ,pr_cdoperad => 1                       -- IN
																			 ,pr_dtmvtolt => rw_crapdat.dtmvtolt     -- IN
																			 ,pr_nrdctabb => rw_cobr_tarifa.nrdctabb -- IN
																			 ,pr_nrdctitg => rw_cobr_tarifa.nrdctitg -- IN
																			 ,pr_cdhistor => vr_cdhistor             -- IN
																			 ,pr_cdpesqbb => rw_cobr_tarifa.cdpesqbb -- IN
																			 ,pr_cdbanchq => rw_cobr_tarifa.cdbanchq -- IN
																			 ,pr_cdagechq => rw_cobr_tarifa.cdagechq -- IN
																			 ,pr_nrctachq => rw_cobr_tarifa.nrctachq -- IN
																			 ,pr_vltarifa => rw_cobr_tarifa.vllanmto -- IN
																			 ,pr_nrdocmto => rw_cobr_tarifa.nrdocmto -- IN
																			 ,pr_cdcoptfn => rw_cobr_tarifa.cdcoptfn -- IN
																			 ,pr_cdagetfn => rw_cobr_tarifa.cdagetfn -- IN
																			 ,pr_nrterfin => rw_cobr_tarifa.nrterfin -- IN
																			 ,pr_nrsequni => rw_cobr_tarifa.nrsequni -- IN
																			 ,pr_nrautdoc => rw_cobr_tarifa.nrautdoc -- IN
																			 ,pr_dsidenti => rw_cobr_tarifa.dsidenti -- IN
																			 ,pr_dscritic => vr_dscritic             -- OUT
																			 );
							--
							IF vr_dscritic IS NOT NULL THEN
								--
								CLOSE cr_cobr_tarifa;
								--
								RAISE vr_exc_erro;
								--
							END IF;
							--
						END LOOP;
						--
						CLOSE cr_cobr_tarifa;
						--
					END IF;
					--
				END IF;
				--
			END IF;
				--
			END IF;
		--
		/*GENE0002.pc_escreve_xml(pr_xml => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo => 'FIM'
                           ,pr_fecha_xml => TRUE
                           );
		-- Gera o relatorio
    GENE0002.pc_clob_para_arquivo(pr_clob => vr_clob
                                 ,pr_caminho => '/usr/coop/viacredi/upload/'
                                 ,pr_arquivo => 'pc_estorno_tarifa_adp.txt'
                                 ,pr_des_erro => pr_dscritic
																 );*/
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			pr_dscritic := vr_dscritic;
		WHEN OTHERS THEN
			pr_dscritic := 'Erro ao gerar estorno de tarifa de adiantamento a depositante: ' || SQLERRM;
	END pc_estorno_tarifa_adp;
	--
  
  /* Procedure para estorno de tarifa de saque*/
  procedure pc_estorno_tarifa_saque (pr_cdcooper  IN INTEGER  --> Codigo Cooperativa
                                    ,pr_cdagenci  IN INTEGER  --> Codigo Agencia
                                    ,pr_nrdcaixa  IN INTEGER  --> Numero do caixa
                                    ,pr_cdoperad  IN VARCHAR2 --> Codigo Operador
                                    ,pr_dtmvtolt  IN DATE     --> Data Lancamento
                                    ,pr_nmdatela  IN VARCHAR2 --> Nome da tela       
                                    ,pr_idorigem  IN INTEGER  --> Indicador de origem
                                    ,pr_nrdconta  IN INTEGER  --> Numero da Conta
                                    ,pr_nrdocmto  IN INTEGER  --> Numero do documento
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) as     --> Descricao da critica
    
    ------------------- CURSOR --------------------

    CURSOR cr_ope_tarifa IS
      select op.cdlantar, op.fldescontapacote, op.dtoperacao
      from tbcc_operacoes_diarias op
      WHERE op.cdcooper = pr_cdcooper
            AND op.nrdconta = pr_nrdconta
            and op.nrdocmto = pr_nrdocmto
            and op.flgisencao_tarifa = 1;

    CURSOR cr_lat (pr_cdlantar IN craplat.cdlantar%TYPE) IS
      SELECT
           * 
      from CRAPLAT LAT
      WHERE 
      LAT.CDLANTAR = pr_cdlantar;  

      
    ------------------ VARIAVEIS ------------------
    vr_cddopcap  NUMERIC(1);
    vr_lscdlant  VARCHAR2(255);

    rw_ope_tarifa cr_ope_tarifa%ROWTYPE;
    rw_lat    cr_lat%ROWTYPE;
  
    -- Variaveis de critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida  EXCEPTION;
    vr_exc_null  EXCEPTION;
  
  begin 
    OPEN cr_ope_tarifa;
    FETCH cr_ope_tarifa INTO rw_ope_tarifa;
    
    IF cr_ope_tarifa%FOUND THEN
    -- se cdlantar é diferente de nulo significa que foi cobrada a tarifa
        if rw_ope_tarifa.cdlantar is not null THEN
           OPEN cr_lat(rw_ope_tarifa.cdlantar);
           FETCH cr_lat INTO RW_LAT;           
	         
           IF cr_lat%FOUND THEN
              
              IF RW_LAT.INSITLAT = 2 THEN
                   vr_cddopcap  := 1; /* Tarida efetivada. Precisa estornar */
               ELSE
                   vr_cddopcap  := 2; /* Tarida NAO efetivada. Precisa baixar */
              END IF;
          
              pc_estorno_baixa_tarifa( pr_cdcooper 	=> pr_cdcooper,
                                          pr_cdagenci => pr_cdagenci,
                                          pr_nrdcaixa => pr_nrdcaixa,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_dtmvtolt => pr_dtmvtolt,
                                          pr_nmdatela => pr_nmdatela,
                                          pr_idorigem => pr_idorigem,
                                          pr_inproces => 0,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_cddopcap => vr_cddopcap,
                                          pr_lscdlant => TO_CHAR(rw_ope_tarifa.cdlantar),
                                          pr_lscdmote => '',
                                          pr_flgerlog => 1,
                                          pr_cdcritic => pr_cdcritic,
                                          pr_dscritic => pr_dscritic);
                
				IF pr_dscritic IS NOT NULL  THEN
                  UPDATE TBCC_OPERACOES_DIARIAS OP
                  SET FLDESCONTAPACOTE = 0
                  WHERE OP.CDCOOPER = pr_cdcooper
                      AND OP.NRDCONTA = pr_nrdconta
                      AND OP.NRDOCMTO = pr_nrdocmto
                      AND OP.DTOPERACAO = rw_ope_tarifa.dtoperacao
                      AND OP.FLGISENCAO_TARIFA = 1;
                END IF;

           END IF;      
        end if; --rw_ope_tarifa.cdlantar
     END IF; -- cr_ope_tarifa%FOUND
     EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar estorno de tarifa de saque: ' || SQLERRM;

  end pc_estorno_tarifa_saque;

  /*Procedures Rotina de Log - tabela: tbgen prglog ocorrencia*/     
  PROCEDURE pc_log(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                  ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                  ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                  ,pr_tpexecuc IN NUMBER   DEFAULT 0   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                  ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                  ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                  ,pr_nmrotina IN VARCHAR2 DEFAULT 'TARI0001'
                  ,pr_cdcooper IN VARCHAR2 DEFAULT 0
                  ) 
  IS
    /* ..........................................................................    
    Programa : pc_log
    Sistema  : Rotina de Log - tabela: tbgen prglog ocorrencia
    Sigla    : GENE
    Autor    : Envolti - Belli - Chamado REQ0011726
    Data     : 23/10/2018                       Ultima atualizacao: 
    
    Dados referentes ao programa:    
    Frequencia: Sempre que for chamado
    Objetivo  : Chamar a rotina de Log para gravação de criticas.
    
    Alteracoes: 
    
     .............................................................................
    */    
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;        
  BEGIN   
    -- Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                          ,pr_dsmensagem    => SUBSTR(pr_dscritic,1,3900)
                          ,pr_cdmensagem    => pr_cdcritic
                          ,pr_cdprograma    => pr_nmrotina
                          ,pr_cdcooper      => pr_cdcooper 
                          ,pr_idprglog      => vr_idprglog
                          );
    -- Se chegar um tamanho não programado
    IF LENGTH(pr_dscritic) > 3900 THEN 
      -- Controlar geração de log de execução dos jobs                                
      CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                            ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                            ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                            ,pr_dsmensagem    => SUBSTR(pr_dscritic,3901,3900)
                            ,pr_cdmensagem    => pr_cdcritic
                            ,pr_cdprograma    => pr_nmrotina
                            ,pr_cdcooper      => pr_cdcooper 
                            ,pr_idprglog      => vr_idprglog
                            ); 
    END IF;  
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
  END pc_log;
  
  
END TARI0001;
/
