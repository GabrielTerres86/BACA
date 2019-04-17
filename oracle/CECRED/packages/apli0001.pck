CREATE OR REPLACE PACKAGE CECRED.APLI0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : APLI0001
  --  Sistema  : Rotinas genericas focando nas funcionalidades das aplicacoes
  --  Sigla    : APLI
  --  Autor    : Alisson C. Berrido - AMcom
  --  Data     : Dezembro/2012.                   Ultima atualizacao: 18/03/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas dos sistemas Oracle

  -- Alteracoes
  -- 19/07/2013   Criado o tipo typ_reg_resgate e ajusta a pltable typ_tab_resgate
  --              para armazenar o tipo do resgate e nao so o valor, pois devemos
  --              analizar essa informacao tambem dentro da rotina de acumulo das
  --              aplicacoes (Marcos-Supero)
  -- 21/08/2013 - Tratamento para Imunidade Tributaria (Ze).
  --
  -- 28/08/2013 - Alterada a procedure 'consulta-aplicacoes' para
  --              trazer nome do produto conforme nova regra (Lucas).
  --
  -- 04/11/2013 - Ajuste conforme liberação de Outubro 2013 (Gabriel)
  --
  -- 30/01/2013 - Inclusão da procedure pc_rdca2s (Jean Michel)
  --
  -- 09/04/2014 - Incluido rotina pc_consulta_aplicacoes e inclusao de novos campos
  --              de parametros na pc_consul_saldo_aplic_rdca30
  --
  -- 15/04/2014 - Tratamento de erro na procedure pc_rdca2s (Jean Michel)
	--
	-- 22/04/2014 - Inclusão do crapmfx.tpmoefix = 20 no cursor cr_crapmfx (Jean Michel).
	--
	-- 06/05/2014 - Ajuste na procedure pc_calc_poupanca (Jean Michel).
  --
  -- 19/05/2014 - Incluido a assinatura da pc_consulta_poupanca (Adriano).
  --
	-- 27/06/2014 - Na pc_saldo_rdc_pre, foi comentado o tratamento de erro no retorno
  --              da pc_verifica_imunidade_trib (Adriano).
  -- 
  -- 27/06/2014 - Ajuste feita na procedure pc_consulta_aplicacoes - SD 171838 (Jean Michel).
	--
  -- 17/07/2014 - Alteração da procedure pc_acumula_aplicacoes, projeto de captação (Jean Michel)
  --
  -- 28/08/2014 - Incluido conversao de CHAR para Number na procedure pc_busca_faixa_ir_rdc (Jean Michel).
  --
  -- 01/12/2014 - Alterado a ordenação da tabela crapmfx. (Jean Michel)
	--
	-- 23/12/2014 - Adicionado campos nmdindex, idtxfica, percirrf e vlsldrgt no 
	--              typ_reg_saldo_rdca. (Reinert)		
  --
  -- 05/01/2015 - Ajustar o nome das telas e a adicionar o Internet Bank na segunda validação
  --              do inproces na pc_consul_saldo_aplic_rdca30 (Douglas - Chamado 191876)
  --
  -- 05/01/2015 - Acrescentei o campo dsnomenc na PLTABLE typ_reg_saldo_rdca para montagem 
  --              do extrato de aplicacoes do INTERNET BANK.
  --              (Carlos Rafael Tanholi - Projeto Novos Produtos de Captacao)
  --              
  -- 08/01/2015 - Ajustar a validação de dia util e valor de resgate, pois o else pertence a 
  --              validação do valor de resgate e não ao dia util. Alterar parametro 
  --              pr_vllanmto somente para IN e utilizar uma variável local para cálculo na 
  --              pc_ajuste_provisao_rdc_pre (Douglas - Chamado 239950)
  --
  -- 20/01/2015 - Inclusao da nova temp-table typ_tab_saldo_rdca_tmp para reordenacao de aplicacoes
  --              (Jean Michel).            
  --
  -- 01/04/2015 - Incluido a cooperativa na pl/table typ_reg_faixa_ir_rdca e typ_reg_faixa_ir_rdc. 
  --              Isso se fez necessario para recarregar o IRRF quando mudar a cooperativa 
  --              (rotinas pc_busca_faixa_ir_rdca e pc_busca_faixa_ir_rdc). Andrino (RKAM). Chamado 272121
  --      
  -- 01/04/2015 - Adicionado o campo dtiniper na temp-table typ_reg_saldo_rdca. SD - 266191 (Kelvin)     
  --
  -- 17/11/2015 - Na verificação da IMUT0001.pc_verifica_imunidade_trib trocado log para
  --              proc_message na procedure pc_calc_poupanca (Lucas Ranghetti #314905)
  --
  -- 25/11/2016 - Incluir CRPS005 nas excessoes da procedure - Melhoria 69 
  --              (Lucas Ranghetti/Elton)          
  --
  -- 09/05/2017 - Executei a limpeza da PLTABLE vr_tab_moedatx na pc_rendi_apl_pos_com_resgate, garantindo 
  --              assim o carregamento correto das taxa de moedas por data.(Carlos Rafael Tanholi - SD 631979)
  --
  -- 07/08/2017 - #715540 Tratamento em pc_saldo_rdc_pos, verificando o vetor de dias úteis para não repetir
  --              a consulta; Correção do alias da tabela no hint index do cursor cr_craplap (Carlos)  
  --
  -- 03/10/2017 - Correcao na forma de arredondamento do campo vr_vlrgtsol na pc_saldo_rgt_rdc_pos. 
  --              Influenciava o valor de resgate superior ao saldo.(Carlos Rafael Tanholi - SD 745032)
  --
  -- 04/12/2017 - Remoção do paralelismo nas queries envolvendo as tabelas craptrd e crapmfx nos processos
  --              online - pc_saldo_rdc_pos (Rodrigo)
  --
  -- 29/01/2018 - #770327 Na rotina pc_consulta_aplicacoes, inclusão do INTERNETBANK para filtrar os 
  --              lançamentos no período informado (Carlos)
  --
  -- 18/07/2018 - P411.2 Tratamento das rotinas de Poupança Programada X Aplicação Programada - CIS Corporate
  --              Desconsiderar as aplicações automática no cálculo das aplicações tradicionais 
  --              Proc. pc_acumula_aplicacoes
  -- 19/07/2018 - Recuperar código do produto (CRAPCPC) na proc. pc_calc_poupanca
  --               
  -- 16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
  --                   Heitor (Mouts)
  /*
     18/03/2019 - PRB0040683 na rotina pc_consulta_poupanca e suas internas, feitos os tratamentos de erros para que
                  sejam identificados os possíveis pontos de correção; pular a aplicação quando a consulta for chamada
                  pelo batch (Carlos)
  */
  ---------------------------------------------------------------------------------------------------------------

  /* Tabela com o mes e a aliquota para desconto de IR nas aplicacoes
     OBS: Sempre que for necessaria sua atualizacao, chamar o
          metodo pc_busca_faixas_ir no inicio do processo */
  TYPE typ_reg_faixa_ir_rdca IS
      RECORD (qtmestab NUMBER
             ,perirtab NUMBER
             ,cdcooper crapcop.cdcooper%TYPE);
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_faixa_ir_rdca IS
    TABLE OF typ_reg_faixa_ir_rdca
    INDEX BY BINARY_INTEGER;
  /* Vetor com as informacoes de faixas*/
  vr_faixa_ir_rdca typ_tab_faixa_ir_rdca;

  /* Tabela com o dia e a aliquota para desconto de IR nas aplicacoes RDC
     OBS: Sempre que for necessaria sua atualizacao, chamar o
          metodo pc_busca_faixas_ir_rdc no inicio do processo */
  TYPE typ_reg_faixa_ir_rdc IS
      RECORD (qtdiatab NUMBER
             ,perirtab NUMBER
             ,cdcooper crapcop.cdcooper%TYPE);
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_faixa_ir_rdc IS
    TABLE OF typ_reg_faixa_ir_rdc
    INDEX BY BINARY_INTEGER;
  /* Vetor com as informacoes de faixas*/
  vr_faixa_ir_rdc typ_tab_faixa_ir_rdc;

  -- Definicao de TEMP TABLE para gerar extrato RDC.
  TYPE typ_reg_extr_rdc IS
    RECORD(dtmvtolt crapdat.dtmvtolt%TYPE
          ,cdagenci crapage.cdagenci%TYPE
          ,cdbccxlt craplap.cdbccxlt%TYPE
          ,nrdolote craplap.nrdolote%TYPE
          ,cdhistor craphis.cdhistor%TYPE
          ,dshistor craphis.dshistor%TYPE
          ,nrdocmto craplap.nrdocmto%TYPE
          ,indebcre craphis.indebcre%TYPE
          ,vllanmto craplap.vllanmto%TYPE
          ,vlsdlsap craplap.vlsdlsap%TYPE
          ,txaplica craplap.txaplica%TYPE
          ,vlpvlrgt craplap.vlpvlrgt%TYPE);

  -- Definicao de tipo de registro que vai armazenar o extrato RDC
  TYPE typ_tab_extr_rdc IS
    TABLE OF typ_reg_extr_rdc
    INDEX BY BINARY_INTEGER;

  -- Definicao de TEMP TABLE para Acumulo Aplicacoes
  TYPE typ_reg_acumula_aplic IS
    RECORD(nraplica craprda.nraplica%TYPE
          ,tpaplica VARCHAR2(50)
          ,vlsdrdca craprda.vlsdrdca%TYPE);

  -- Definicao de tipo de tabela para acumulo Aplicacoes
  TYPE typ_tab_acumula_aplic IS
    TABLE OF typ_reg_acumula_aplic
    INDEX BY BINARY_INTEGER;

  --Definicao do tipo de registro para poupanca-programada
  TYPE typ_reg_dados_rpp IS
    RECORD (nrctrrpp craprpp.nrctrrpp%TYPE
         ,cdagenci crapage.cdagenci%TYPE
         ,cdbccxlt craplot.cdbccxlt%TYPE
         ,nrdolote craplot.nrdolote%TYPE
         ,dtmvtolt crapdat.dtmvtolt%TYPE
         ,dtvctopp crapdat.dtmvtolt%TYPE
         ,dtdebito crapdat.dtmvtolt%TYPE
         ,indiadeb INTEGER
         ,vlprerpp craprpp.vlprerpp%TYPE
         ,qtprepag craprpp.qtprepag%TYPE
         ,vlprepag craprpp.vlprepag%TYPE
         ,vlsdrdpp craprpp.vlsdrdpp%TYPE
         ,vlrgtrpp NUMBER
         ,vljuracu craprpp.vljuracu%TYPE
         ,vlrgtacu craprpp.vlrgtacu%TYPE
         ,dtinirpp craprpp.dtinirpp%TYPE
         ,dtrnirpp craprpp.dtrnirpp%TYPE
         ,dtaltrpp craprpp.dtaltrpp%TYPE
         ,dtcancel craprpp.dtcancel%TYPE
         ,dssitrpp VARCHAR2(10)
         ,dsblqrpp VARCHAR2(3)
         ,dsresgat VARCHAR2(3)
         ,dsctainv VARCHAR2(3)
         ,dsmsgsaq VARCHAR2(40)
         ,cdtiparq INTEGER
         ,dtsldrpp crapdat.dtmvtolt%TYPE
         ,cdprodut crapcpc.cdprodut%TYPE
         ,dsfinali craprpp.dsfinali%TYPE
         ,nrdrowid ROWID);

  --Definicao do tipo de tabela para poupanca-programada
  TYPE typ_tab_dados_rpp IS
    TABLE OF typ_reg_dados_rpp
    INDEX BY BINARY_INTEGER;

  --Definicao do tipo de tabela para taxa
  TYPE typ_tab_tpregist IS
    TABLE OF INTEGER
    INDEX BY PLS_INTEGER;

  --Definicao do tipo de tabela para contas bloqueadas
  TYPE typ_tab_ctablq IS
    TABLE OF INTEGER
    INDEX BY VARCHAR2(20);

  --Tipo de tabela de memoria para lancamentos de poupanca
  TYPE typ_tab_craplpp IS
    TABLE OF INTEGER
    INDEX BY VARCHAR2(20);

  --Tipo de tabela de memoria para lancamentos de poupanca
  TYPE typ_reg_resgate IS
    RECORD (saldo_rdca APLI0001.typ_reg_saldo_rdca 
           ,tpresgat craplrg.tpresgat%TYPE
           ,vllanmto craplrg.vllanmto%TYPE);
  TYPE typ_tab_resgate IS
    TABLE OF typ_reg_resgate
    INDEX BY VARCHAR2(25);

  -- Definicao de TEMP TABLE para consulta do saldo de aplicacao RDCA
  TYPE typ_reg_saldo_rdca IS
    RECORD(dtmvtolt craprda.dtmvtolt%TYPE
          ,nraplica craprda.nraplica%TYPE
          ,qtdiaapl craprda.qtdiaapl%TYPE
          ,qtdiauti craprda.qtdiauti%TYPE
          ,vlaplica craprda.vlaplica%TYPE
          ,dsaplica crapdtc.dsaplica%TYPE
          ,cdoperad craprda.cdoperad%TYPE
          ,dshistor VARCHAR2(50)
          ,nrdocmto VARCHAR2(08)
          ,dtvencto craprda.dtvencto%TYPE
          ,dssitapl VARCHAR2(10)
          ,vllanmto craprda.vlaplica%TYPE
          ,vlsdrdad craprda.vlsdrdca%TYPE
          ,sldresga craprda.vlsdrdca%TYPE
          ,cddresga VARCHAR2(03)
          ,dtresgat craprda.dtmvtolt%TYPE
          ,txaplmax VARCHAR2(10)
          ,txaplmin VARCHAR2(10)
          ,tpaplica craprda.tpaplica%TYPE
          ,tpaplrdc crapdtc.tpaplrdc%TYPE
          ,qtdiacar craprda.qtdiauti%TYPE
          ,indebcre VARCHAR2(07)
          ,cdprodut craprac.cdprodut%TYPE
          ,nmprodut crapcpc.nmprodut%TYPE          
          ,idtipapl VARCHAR(2)
					,nmdindex crapind.nmdindex%TYPE
    			,idtxfixa crapcpc.idtxfixa%TYPE
					,percirrf NUMBER
					,vlsldrgt NUMBER
          ,dsnomenc crapnpc.dsnomenc%TYPE
          ,idtippro crapcpc.idtippro%TYPE
          ,dtcarenc DATE);

  -- Definicao de tipo de tabela para acumulo Aplicacoes
  TYPE typ_tab_saldo_rdca IS
    TABLE OF typ_reg_saldo_rdca
    INDEX BY BINARY_INTEGER;

  -- Definicao de tipo de tabela para reordenacao
  TYPE typ_tab_saldo_rdca_tmp IS
    TABLE OF typ_reg_saldo_rdca
    INDEX BY VARCHAR2(25);

  /* Funcao para arredondamento de valores em calculos de aplicacoes */
  FUNCTION fn_round(pr_vlorigem IN NUMBER
                   ,pr_qtarredo IN INTEGER) RETURN NUMBER;

  /* Rotina que busca as informacoes de IR parametrizadas para aplicacoes */
  PROCEDURE pc_busca_faixa_ir_rdca(pr_cdcooper IN crapcop.cdcooper%TYPE);

  /* Rotina que busca as informacoes de IR parametrizadas para aplicacoes RDC */
  PROCEDURE pc_busca_faixa_ir_rdc(pr_cdcooper IN crapcop.cdcooper%TYPE);

  /* Rotina para calcular quanto a rdcpos valera na data do vencimento para calculo do var */
  PROCEDURE pc_provisao_rdc_pos_var (pr_cdcooper         IN crapcop.cdcooper%TYPE    --> Cooperativa
                                    ,pr_nrdconta         IN craprda.nrdconta%TYPE    --> Numero da Conta
                                    ,pr_nraplica         IN craprda.nraplica%TYPE    --> Numero da Aplicacao
                                    ,pr_dtmvtolt         IN crapdat.dtmvtolt%TYPE    --> Data do movimento atual
                                    ,pr_dtmvtopr         IN crapdat.dtmvtopr%TYPE    --> Proxima data de movimento
                                    ,pr_craprda_dtmvtolt IN craprda.dtmvtolt%TYPE    --> Data do movimento atual
                                    ,pr_craprda_vlsltxmx IN craprda.vlsltxmx%TYPE    --> Valor saldo taxa Maxima
                                    ,pr_craprda_dtatslmx IN craprda.dtatslmx%TYPE    --> Valor Saldo taxa Minima
                                    ,pr_craprda_txaplica IN craplap.txaplica%TYPE    --> Taxa Aplicacao
                                    ,pr_vlsdrdca         IN OUT NUMBER               --> Valor do saldo RDCA
                                    ,pr_vlrentot         IN OUT NUMBER               --> Valor do rendimento total
                                    ,pr_cdcritic         OUT NUMBER                  --> Codigo de erro retornado
                                    ,pr_dscritic         OUT VARCHAR2);              --> Descricao do erro

  /* Rotina de calculo da provisao no final do mes e no vencimento. */
  PROCEDURE pc_provisao_rdc_pre(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa
                               ,pr_nrdconta  IN craprda.nrdconta%TYPE    --> Numero da Conta
                               ,pr_nraplica  IN craprda.nraplica%TYPE    --> Numero da Aplicacao
                               ,pr_dtiniper  IN crapdat.dtmvtolt%TYPE    --> Data base inicial
                               ,pr_dtfimper  IN crapdat.dtmvtopr%TYPE    --> Data base final
                               ,pr_vlsdrdca OUT NUMBER                   --> Valor do saldo RDCA
                               ,pr_vlrentot OUT NUMBER                   --> Valor do rendimento total
                               ,pr_vllctprv OUT NUMBER                   --> Valor dos ajustes RDC
                               ,pr_des_reto OUT VARCHAR                  --> Indicador de saida com erro (OK/NOK)
                               ,pr_tab_erro OUT GENE0001.typ_tab_erro);  --> Tabela com erros

  /* Calculo de Saldo para Resgate de Aplicacao Antiga b1wgen0005.p->saldo-rdca-resgate */
  PROCEDURE pc_saldo_rdca_resgate(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo da agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                 ,pr_cdprogra IN crapprg.cdprogra%TYPE --> Programa chamador
                                 ,pr_nrdconta IN craprda.nrdconta%TYPE --> Conta da aplicacao RDCA
                                 ,pr_dtaplica IN DATE                  --> Data pada resgate da aplicacao
                                 ,pr_nraplica IN craprda.nraplica%TYPE --> Numero da aplicacao RDCA
                                 ,pr_vlsldapl IN craprda.vlsdrdca%TYPE --> Saldo da aplicacao
                                 ,pr_vlrenper IN NUMBER                --> Valor do rendimento no periodo
                                 ,pr_tpchamad IN PLS_INTEGER           --> Tipo de chamada 1 - da BO, 2 - do Fonte
                                 ,pr_pcajsren OUT NUMBER               --> Percentual do resgate sobre o rendimento acumulado
                                 ,pr_vlrenreg OUT NUMBER               --> Valor para calculo do ajuste
                                 ,pr_vldajtir OUT NUMBER               --> Valor do ajuste de IR
                                 ,pr_sldrgttt OUT NUMBER               --> Saldo do resgate total
                                 ,pr_vlslajir OUT NUMBER               --> Saldo utilizado para calculo do ajuste
                                 ,pr_vlrenacu OUT NUMBER               --> Rendimento acumulado para calculo do ajuste
                                 ,pr_nrdmeses OUT INTEGER              --> Numero de meses da aplicacao
                                 ,pr_nrdedias OUT INTEGER              --> Numero de dias da aplicacao
                                 ,pr_dtiniapl OUT DATE                 --> data de inicio da aplicacao
                                 ,pr_cdhisren OUT craphis.cdhistor%TYPE --> Historico de lancamento no rendimento
                                 ,pr_cdhisajt OUT craphis.cdhistor%TYPE --> Historico de ajuste
                                 ,pr_perirapl OUT NUMBER                --> Percentual de IR Aplicado
                                 ,pr_sldpresg IN OUT NUMBER             --> Saldo para o resgate
                                 ,pr_des_reto OUT VARCHAR               --> Indicador de saida com erro (OK/NOK)
                                 ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela com erros
                                 );

  /* Consulta saldo aplicacao RDCA30 (Antiga includes/b1wgen0004.i) */
  PROCEDURE pc_consul_saldo_aplic_rdca30(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Cooperativa
                                        ,pr_cdoperad     IN crapope.cdoperad%TYPE DEFAULT 0 --> Operador
                                        ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE --> Data do processo
                                        ,pr_inproces     IN crapdat.inproces%TYPE --> Indicador do processo
                                        ,pr_dtmvtopr     IN crapdat.dtmvtopr%TYPE --> Proximo dia util
                                        ,pr_cdprogra     IN crapprg.cdprogra%TYPE --> Programa em execucao
                                        ,pr_cdagenci     IN crapass.cdagenci%TYPE --> Codigo da agencia
                                        ,pr_nrdcaixa     IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                        ,pr_nrdconta     IN craprda.nrdconta%TYPE --> Nro da conta da aplicacao RDCA
                                        ,pr_nraplica     IN craprda.nraplica%TYPE --> Nro da aplicacao RDCA
                                        ,pr_vlsdrdca     OUT NUMBER               --> Saldo da aplicacao
                                        ,pr_dup_vlsdrdca OUT NUMBER               --> Acumulo do saldo da aplicacao RDCA
                                        ,pr_vlsldapl     OUT NUMBER               --> Saldo da aplicacao RDCA
                                        ,pr_sldpresg     OUT NUMBER               --> Saldo para resgate
                                        ,pr_vldperda     OUT NUMBER               --> Valor calculado da perda
                                        ,pr_txaplica     OUT NUMBER               --> Taxa aplicada sob o emprestimo
                                        ,pr_des_reto     OUT VARCHAR2                  --> OK ou NOK
                                        ,pr_tab_erro     OUT GENE0001.typ_tab_erro);   --> Tabela com erros

  /* Consulta saldo aplicacao RDCA60 (Antiga includes/b1wgen0004a.i) */
  PROCEDURE pc_consul_saldo_aplic_rdca60(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movto atual
                                        ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE --> Data do proximo movimento
                                        ,pr_cdprogra IN crapprg.cdprogra%TYPE --> Programa em execucao
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo da agencia
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                        ,pr_nrdconta IN craprda.nrdconta%TYPE --> Nro da conta da aplicacao RDCA
                                        ,pr_nraplica IN craprda.nraplica%TYPE --> Nro da aplicacao RDCA
                                        ,pr_vlsdrdca OUT NUMBER               --> Saldo da aplicacao
                                        ,pr_sldpresg OUT NUMBER               --> Saldo para resgate
                                        ,pr_des_reto OUT VARCHAR2                  --> OK ou NOK
                                        ,pr_tab_erro OUT GENE0001.typ_tab_erro);   --> Tabela com erros

  /* Rotina de calculo do aniversario e atualizacao de aplicacoes RDCA2 */
  PROCEDURE pc_calc_aniver_rdca2a(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do processo
                                 ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE --> Data do processo
                                 ,pr_nrdconta IN craprda.nrdconta%TYPE --> Nro da conta da aplicacao RDCA
                                 ,pr_nraplica IN craprda.nraplica%TYPE --> Nro da aplicacao RDCA
                                 ,pr_vltotrda IN craprda.vlsdrdca%TYPE --> Saldo total das aplicacoes
                                 ,pr_cdprogra IN crapprg.cdprogra%TYPE --> Programa conectado
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo da agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                 ,pr_des_reto OUT VARCHAR2                  --> OK ou NOK
                                 ,pr_tab_erro OUT GENE0001.typ_tab_erro); --> Tabela com erros

  /* Rotina de calculo do aniversario do RDCA2 */
  PROCEDURE pc_calc_aniver_rdca2c(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do processo
                                 ,pr_nrdconta IN craprda.nrdconta%TYPE --> Nro da conta da aplicacao RDCA
                                 ,pr_nraplica IN craprda.nraplica%TYPE --> Nro da aplicacao RDCA
                                 ,pr_vlsdrdca OUT NUMBER               --> Saldo da aplicacao pos calculo
                                 ,pr_des_erro  OUT VARCHAR2);          --> Saida com com erros;

  /* Rotina de calculo do saldo das aplicacoes RDC PRE para resgate */
  PROCEDURE pc_saldo_rdc_pre(pr_cdcooper IN crapcop.cdcooper%TYPE        --> Cooperativa
                            ,pr_nrdconta IN craprda.nrdconta%TYPE        --> Nro da conta da aplicacao RDCA
                            ,pr_nraplica IN craprda.nraplica%TYPE        --> Nro da aplicacao RDCA
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE        --> Data do processo (não necessariamente da CRAPDAT)
                            ,pr_dtiniper IN craprda.dtiniper%TYPE        --> Data de inicio da aplicacao
                            ,pr_dtfimper IN craprda.dtfimper%TYPE        --> Data de termino da aplicacao
                            ,pr_txaplica IN NUMBER                       --> Taxa aplicada
                            ,pr_flggrvir    IN BOOLEAN DEFAULT FALSE        --> Identificador se deve gravar valor insento
                            ,pr_tab_crapdat IN BTCH0001.cr_crapdat%ROWTYPE  --> Dados da tabela de datas
                            ,pr_cdprogra IN VARCHAR2 DEFAULT NULL        --> Codigo do programa chamador
                            ,pr_vlsdrdca IN OUT NUMBER                   --> Saldo da aplicacao pos calculo
                            ,pr_vlrdirrf OUT craplap.vllanmto%TYPE       --> Valor de IR
                            ,pr_perirrgt OUT NUMBER                      --> Percentual de IR resgatado
                            ,pr_des_reto OUT VARCHAR2                    --> OK ou NOK
                            ,pr_tab_erro OUT GENE0001.typ_tab_erro);     --> Tabela com erros

  /* Rotina de calculo do saldo das aplicacoes RDC POS */
  PROCEDURE pc_saldo_rdc_pos(pr_cdcooper IN crapcop.cdcooper%TYPE        --> Cooperativa
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE        --> Data movimento atual
                            ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE        --> Data do movimento do proximo dia
                            ,pr_nrdconta IN craprda.nrdconta%TYPE        --> Nro da conta da aplicacao RDCA
                            ,pr_nraplica IN craprda.nraplica%TYPE        --> Nro da aplicacao RDCA
                            ,pr_dtmvtpap IN crapdat.dtmvtolt%TYPE        --> Data do processo (Não necessariamente da CRAPDAT)
                            ,pr_dtcalsld IN craprda.dtmvtolt%TYPE        --> Data para calculo do saldo
                            ,pr_flantven IN BOOLEAN                      --> Flag antecede vencimento
                            ,pr_flggrvir IN BOOLEAN DEFAULT FALSE        --> Identificador se deve gravar valor insento
                            ,pr_dtinitax IN DATE                         --> Data de inicio da utilizacao da taxa de poupanca.
                            ,pr_dtfimtax IN DATE                         --> Data de fim da utilizacao da taxa de poupanca.
                            ,pr_cdprogra IN VARCHAR2 DEFAULT NULL        --> Codigo do programa chamador
                            ,pr_vlsdrdca OUT NUMBER                      --> Saldo da aplicacao pos calculo
                            ,pr_vlrentot OUT NUMBER                      --> Valor de rendimento total
                            ,pr_vlrdirrf OUT craplap.vllanmto%TYPE       --> Valor de IR
                            ,pr_perirrgt OUT NUMBER                      --> Percentual de IR resgatado
                            ,pr_des_reto OUT VARCHAR2                    --> OK ou NOK
                            ,pr_tab_erro OUT GENE0001.typ_tab_erro);     --> Tabela com erros

  /* Rotina para montar o saldo das aplicacoes financeiras e mostrar o extrato para a Atenda */
  PROCEDURE pc_calc_sldrda(pr_cdcooper IN crapcop.cdcooper%TYPE        --> Cooperativa
                          ,pr_cdoperad IN crapope.cdoperad%TYPE DEFAULT 0 --> Operador
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE        --> Data do processo
                          ,pr_inproces IN crapdat.inproces%TYPE        --> Indicador do processo
                          ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE        --> Proximo dia util
                          ,pr_cdprogra IN crapprg.cdprogra%TYPE        --> Programa em execucao
                          ,pr_cdagenci IN crapass.cdagenci%TYPE        --> Codigo da agencia
                          ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE        --> Numero do caixa
                          ,pr_nrdconta IN crapass.nrdconta%TYPE        --> Numero da conta para o saldo
                          ,pr_flgextra IN BOOLEAN                      --> Indicar de extrato S/N
                          ,pr_tab_crapdat IN BTCH0001.cr_crapdat%ROWTYPE  --> Dados da tabela de datas
                          ,pr_tab_crawext OUT FORM0001.typ_tab_crawext --> Tabela com as informacoes de extrato
                          ,pr_vltotrda    OUT NUMBER                   --> Total aplicacao RDC ou RDCA
                          ,pr_des_reto OUT VARCHAR2                    --> OK ou NOK
                          ,pr_tab_erro OUT GENE0001.typ_tab_erro);     --> Tabela com erros

  /* Rotina de calculo do saldo da aplicacao ate a data do movimento */
  procedure pc_calc_poupanca (pr_cdcooper  in crapcop.cdcooper%type,           --> Cooperativa
                              pr_dstextab  in craptab.dstextab%type,           --> Percentual de IR da aplicacao
                              pr_cdprogra  in crapprg.cdprogra%type,           --> Programa chamador
                              pr_inproces  in crapdat.inproces%type,           --> Indicador do processo
                              pr_dtmvtolt  in crapdat.dtmvtolt%type,           --> Data do processo
                              pr_dtmvtopr  in crapdat.dtmvtopr%type,           --> Proximo dia util
                              pr_rpp_rowid in varchar2, 
                              pr_vlsdrdpp  in out craprpp.vlsdrdpp%type,       --> Saldo da poupanca programada
                              pr_cdcritic out crapcri.cdcritic%type,           --> Codigo da critica de erro
                              pr_des_erro out varchar2);                       --> Descricao do erro encontrado

  /* Rotina de calculo do ajuste da provisao a estornar nos casos de resgate antes do vencimento. */
  PROCEDURE pc_ajuste_provisao_rdc_pre (pr_cdcooper   IN crapcop.cdcooper%TYPE        --> Cooperativa
                                       ,pr_cdagenci   IN crapass.cdagenci%TYPE        --> Codigo da agencia
                                       ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE        --> Numero do caixa
                                       ,pr_nrctaapl   IN craprda.nrdconta%TYPE        --> Numero da Conta
                                       ,pr_nraplres   IN craprda.nraplica%TYPE        --> Numero da Aplicacao
                                       ,pr_vllanmto   IN NUMBER                       --> Valor movimento
                                       ,pr_vlestprv   IN OUT NUMBER                   --> Valor previsto
                                       ,pr_des_reto   OUT VARCHAR                     --> Indicador de saida com erro (OK/NOK)
                                       ,pr_tab_erro   OUT GENE0001.typ_tab_erro );    --> Tabela com erros

  /* Gera lancamentos no craplap referentes a RDCPRE e a RDCPOS para credito e debito*/
  PROCEDURE pc_gera_craplap_rdc (pr_cdcooper   IN craplap.cdcooper%TYPE      --> Cooperativa                                
                                ,pr_dtmvtolt   IN craplap.dtmvtolt%TYPE      --> Data do movimento
                                ,pr_cdagenci   IN craplap.cdagenci%TYPE      --> Numero agencia
                                ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE      --> Numero do caixa
                                ,pr_cdbccxlt   IN craplap.cdbccxlt%TYPE      --> Caixa/Agencia
                                ,pr_nrdolote   IN craplap.nrdolote%TYPE      --> Numero lote
                                ,pr_nrdconta   IN craplap.nrdconta%TYPE      --> Numero da conta
                                ,pr_nraplica   IN craplap.nraplica%TYPE      --> Numero da aplicacao
                                ,pr_nrdocmto   IN craplap.nrdocmto%TYPE      --> Numero do documento
                                ,pr_txapllap   IN craplap.txaplica%TYPE      --> Taxa aplicada
                                ,pr_cdhistor   IN craplap.cdhistor%TYPE      --> Historico
                                ,pr_nrseqdig   IN OUT craplap.nrseqdig%TYPE  --> Digito de sequencia
                                ,pr_vllanmto   IN NUMBER                     --> Valor de lancamento
                                ,pr_dtrefere   IN craplap.dtrefere%TYPE      --> Data de referencia
                                ,pr_vlrendmm   IN NUMBER                     --> Valor Rendimento
                                ,pr_tipodrdb   IN VARCHAR2                   --> Indicador de debito ou credito
                                ,pr_rowidlot   IN ROWID                      --> Identificador de registro CRAPLOT
                                ,pr_rowidlap   IN OUT ROWID                  --> Identificador de registro CRAPLAP
                                ,pr_vlinfodb   IN OUT NUMBER                 --> Total a debito
                                ,pr_vlcompdb   IN OUT NUMBER                 --> Total a debito comp.
                                ,pr_qtinfoln   IN OUT craplot.qtinfoln%TYPE  --> Total de lancamentos
                                ,pr_qtcompln   IN OUT craplot.qtcompln%TYPE  --> Total de lancamentos comp.
                                ,pr_vlinfocr   IN OUT NUMBER                 --> Total a credtio
                                ,pr_vlcompcr   IN OUT NUMBER                 --> Total a credtio comp.
                                ,pr_des_reto   IN OUT VARCHAR2               --> Retorno da execucao da procedure
                                ,pr_tab_erro   OUT GENE0001.typ_tab_erro     --> Tabela de erros
                                ,pr_cdoperad   IN crapope.cdoperad%TYPE DEFAULT 0); --> Operador

  /* Rotina de calculo do saldo das aplicacoes RDC POS para resgate com IRPF. */
  PROCEDURE pc_saldo_rgt_rdc_pos (pr_cdcooper    IN crapcop.cdcooper%TYPE        --> Cooperativa
                                 ,pr_cdagenci    IN crapass.cdagenci%TYPE        --> Codigo da agencia
                                 ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE        --> Numero do caixa
                                 ,pr_nrctaapl    IN craprda.nrdconta%TYPE        --> Numero da conta
                                 ,pr_nraplres    IN craprda.nraplica%TYPE        --> Numero da aplicacao
                                 ,pr_dtmvtolt    IN craprda.dtmvtolt%TYPE        --> Data do movimento
                                 ,pr_dtaplrgt    IN craprda.dtmvtolt%TYPE        --> Data aplicacao
                                 ,pr_vlsdorgt    IN NUMBER                       --> Valor DCA
                                 ,pr_flggrvir    IN BOOLEAN DEFAULT FALSE        --> Identificador se deve gravar valor insento
                                 ,pr_dtinitax    IN craprda.dtmvtolt%TYPE        --> Data Inicial da Utilizacao da taxa da poupanca
                                 ,pr_dtfimtax    IN craprda.dtmvtolt%TYPE        --> Data Final da Utilizacao da taxa da poupanca
                                 ,pr_vlsddrgt    OUT NUMBER                      --> Valor do resgate total sem irrf ou o solicitado
                                 ,pr_vlrenrgt    OUT NUMBER                      --> Rendimento total a ser pago quando resgate total
                                 ,pr_vlrdirrf    OUT NUMBER                      --> IRRF do que foi solicitado
                                 ,pr_perirrgt    OUT NUMBER                      --> Percentual de aliquota para calculo do IRRF
                                 ,pr_vlrgttot    OUT NUMBER                      --> Resgate para zerar a aplicacao
                                 ,pr_vlirftot    OUT NUMBER                      --> IRRF para finalizar a aplicacao
                                 ,pr_vlrendmm    OUT NUMBER                      --> Rendimento da ultima provisao ate a data do resgate
                                 ,pr_vlrvtfim    OUT NUMBER                      --> Quantia provisao reverter para zerar a aplicacao
                                 ,pr_des_reto    OUT VARCHAR                     --> Indicador de saida com erro (OK/NOK)
                                 ,pr_tab_erro    OUT GENE0001.typ_tab_erro);     --> Tabela com erros

  /* Calcula quanto o que esta sendo resgatado representa do total */
  PROCEDURE pc_valor_original_resgatado(pr_cdcooper   IN crapcop.cdcooper%TYPE         --> Codigo cooperativa
                                       ,pr_cdagenci   IN crapass.cdagenci%TYPE         --> Codigo da agencia
                                       ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE         --> Numero do caixa
                                       ,pr_nrctaapl   IN craprda.nrdconta%TYPE         --> Numero da conta
                                       ,pr_nraplres   IN craprda.nraplica%TYPE         --> Numero da aplicacao
                                       ,pr_dtaplrgt   IN craprda.dtmvtolt%TYPE         --> Data movimento atual
                                       ,pr_vlsdrdca   IN NUMBER                        --> Valor RDCA
                                       ,pr_perirrgt   IN NUMBER                        --> Percentual aplicado
                                       ,pr_dtinitax   IN craprda.dtmvtolt%TYPE         --> Data Inicial da Utilizacao da taxa da poupanca
                                       ,pr_dtfimtax   IN craprda.dtmvtolt%TYPE         --> Data Final da Utilizacao da taxa da poupanca
                                       ,pr_vlbasrgt   OUT NUMBER                       --> Valor resgatado
                                       ,pr_des_reto   OUT VARCHAR                      --> Indicador de saida com erro (OK/NOK)
                                       ,pr_tab_erro   OUT GENE0001.typ_tab_erro);      --> Tabela com erros

  /* Procedure para calculo de taxa de poupanca */
  PROCEDURE pc_calctx_poupanca (pr_cdcooper  IN crapdat.cdcooper%TYPE             --> Codigo da cooperativa
                               ,pr_qtdiaute  IN NUMBER                            --> Quantidade de dias do periodo
                               ,pr_vlmoefix  IN NUMBER                            --> Valor da moeda fixa
                               ,pr_txmespop  IN OUT NUMBER                        --> Taxa mensal da poupanca
                               ,pr_txdiapop  IN OUT NUMBER);                      --> Taxa diaria da poupanca

  /* Calcula quanto o que esta sendo resgatado rendeu ate a data */
  PROCEDURE pc_rendi_apl_pos_com_resgate (pr_cdcooper   IN crapcop.cdcooper%TYPE        --> Codigo cooperativa
                                         ,pr_cdagenci   IN crapass.cdagenci%TYPE        --> Codigo da agencia
                                         ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE        --> Numero do caixa
                                         ,pr_nrctaapl   IN craprda.nrdconta%TYPE        --> Numero da conta
                                         ,pr_nraplres   IN craprda.nraplica%TYPE        --> Numero da aplicacao
                                         ,pr_dtaplrgt   IN craprda.dtmvtolt%TYPE        --> Data movimento atual
                                         ,pr_dtinitax   IN craprda.dtmvtolt%TYPE         --> Data Inicial da Utilizacao da taxa da poupanca
                                         ,pr_dtfimtax   IN craprda.dtmvtolt%TYPE         --> Data Final da Utilizacao da taxa da poupanca
                                         ,pr_vlsdrdca   IN NUMBER                   --> Valor RDCA
                                         ,pr_flantven   IN BOOLEAN                      --> Parametro para controle
                                         ,pr_vlrenrgt   IN OUT NUMBER                   --> Saldo RDCA
                                         ,pr_des_reto   OUT VARCHAR                     --> Indicador de saida com erro (OK/NOK)
                                         ,pr_tab_erro   OUT GENE0001.typ_tab_erro);     --> Tabela com erros

  /* Rotina de calculo da provisao no final do mes e no vencimento. */
  PROCEDURE pc_provisao_rdc_pos(pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Codigo cooperativa
                               ,pr_cdagenci  IN crapass.cdagenci%TYPE        --> Codigo da agencia
                               ,pr_nrdcaixa  IN craperr.nrdcaixa%TYPE        --> Numero do caixa
                               ,pr_nrctaapl  IN craprda.nrdconta%TYPE        --> Numero da conta
                               ,pr_nraplres  IN craprda.nraplica%TYPE        --> Numero da aplicacao
                               ,pr_dtiniper  IN craprda.dtiniper%TYPE        --> Data inicio do periodo
                               ,pr_dtfimper  IN craprda.dtfimper%TYPE        --> Data fim do periodo
                               ,pr_dtinitax  IN craprda.dtmvtolt%TYPE        --> Data Inicial da Utilizacao da taxa da poupanca
                               ,pr_dtfimtax  IN craprda.dtmvtolt%TYPE        --> Data Final da Utilizacao da taxa da poupanca
                               ,pr_flantven  IN BOOLEAN                      --> Indicador de taxa minima
                               ,pr_vlsdrdca  OUT NUMBER                      --> Valor RDCA
                               ,pr_vlrentot  OUT NUMBER                      --> Valor total
                               ,pr_des_reto  OUT VARCHAR                     --> Indicador de saida com erro (OK/NOK)
                               ,pr_tab_erro  OUT GENE0001.typ_tab_erro);     --> Tabela com erros

  /* Gerar extrato RDC */
  PROCEDURE pc_extrato_rdc (pr_cdcooper          IN crapcop.cdcooper%TYPE                   --> Codigo cooperativa
                           ,pr_cdagenci          IN crapass.cdagenci%TYPE                   --> Codigo da agencia
                           ,pr_nrdcaixa          IN craperr.nrdcaixa%TYPE                   --> Numero do caixa
                           ,pr_nrctaapl          IN craprda.nrdconta%TYPE                   --> Numero de conta
                           ,pr_nraplres          IN craprda.nraplica%TYPE                   --> Numero da aplicacao
                           ,pr_dtiniper          IN craprda.dtiniper%TYPE                   --> Data inicial do periodo
                           ,pr_dtfimper          IN craprda.dtfimper%TYPE                   --> Data final do periodo
                           ,pr_typ_tab_extr_rdc  OUT typ_tab_extr_rdc                    --> TEMP TABLE de extrato
                           ,pr_des_reto          OUT VARCHAR                                --> Indicador de saida com erro (OK/NOK)
                           ,pr_tab_erro          OUT GENE0001.typ_tab_erro );               --> Tabela com erros

  /* Calcular Provisao Mensal RDCA2 */
  PROCEDURE pc_calc_provisao_mensal_rdca2 (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do processo
                                          ,pr_nrdconta IN craprda.nrdconta%TYPE  --> Nro da conta da aplicacao RDCA
                                          ,pr_nraplica IN craprda.nraplica%TYPE  --> Nro da aplicacao RDCA
                                          ,pr_vltotrda IN craprda.vlsdrdca%TYPE  --> Valor total rendimento
                                          ,pr_vlsdrdca OUT craprda.vlsdrdca%TYPE --> Valor Saldo Aplicacao
                                          ,pr_txaplica OUT NUMBER                --> Taxa de Aplicacao
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de critica
                                          ,pr_des_erro OUT VARCHAR2);            --> Saida com erros;

  /* Rotina de calculo do saldo da poupanca programada */
  PROCEDURE pc_calc_saldo_rpp (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                              ,pr_cdprogra IN crapres.cdprogra%TYPE     --> Programa que esta executando
                              ,pr_inproces IN crapdat.inproces%TYPE     --> Indicador do Processo
                              ,pr_percenir IN NUMBER                    --> Percentual IR da craptab
                              ,pr_nrdconta IN craprpp.nrdconta%TYPE     --> Numero da conta da aplicacao
                              ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE     --> Numero do contrato poupanca
                              ,pr_dtiniper IN craprpp.dtiniper%TYPE     --> Data Inicio Periodo
                              ,pr_dtfimper IN craprpp.dtfimper%TYPE     --> Data Final Periodo
                              ,pr_vlabcpmf IN craprpp.vlabcpmf%TYPE     --> Valor abono cpmf
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                              ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE     --> Data do proximo movimento
                              ,pr_vlsdrdpp IN OUT craprpp.vlsdrdpp%TYPE --> Valor do saldo da poupanca programada
                              ,pr_des_erro OUT VARCHAR2);               --> Saida com erros;

  /* Rotina de Acumulo das Aplicacoes */
  PROCEDURE pc_acumula_aplicacoes (pr_cdcooper        IN crapcop.cdcooper%TYPE           --> Cooperativa
                                  ,pr_cdoperad        IN crapope.cdoperad%TYPE DEFAULT 0 --> Operador
                                  ,pr_cdprogra        IN crapprg.cdprogra%TYPE           --> Nome do programa chamador
                                  ,pr_nrdconta        IN craprda.nrdconta%TYPE           --> Nro da conta da aplicacao RDCA
                                  ,pr_nraplica        IN craprda.nraplica%TYPE           --> Nro da Aplicacao
                                  ,pr_tpaplica        IN craprda.tpaplica%TYPE           --> Tipo de Aplicacao
                                  ,pr_vlaplica        IN craprda.vlaplica%TYPE           --> Valor da Aplicacao
                                  ,pr_cdperapl        IN crapttx.cdperapl%TYPE           --> Codigo Periodo Aplicacao
                                  ,pr_percenir        IN NUMBER                          --> % IR para Calculo Poupanca
                                  ,pr_qtdfaxir        IN INTEGER                         --> Quantidade de faixas de IR
                                  ,pr_tab_tpregist    IN APLI0001.typ_tab_tpregist       --> Tipo de Registro para loop craptab
                                  ,pr_tab_craptab     IN APLI0001.typ_tab_ctablq         --> Tipo de tabela de Conta Bloqueada
                                  ,pr_tab_craplpp     IN APLI0001.typ_tab_craplpp        --> Tipo de tabela com lancamento poupanca
                                  ,pr_tab_craplrg     IN APLI0001.typ_tab_craplpp        --> Tipo de tabela com resgates
                                  ,pr_tab_resgate     IN APLI0001.typ_tab_resgate        --> Tabela com o total resgatado por aplicacao e conta
                                  ,pr_tab_crapdat     IN BTCH0001.cr_crapdat%ROWTYPE     --> Dados da tabela de datas
                                  ,pr_cdagenci_assoc  IN crapass.cdagenci%TYPE           --> Agencia do associado
                                  ,pr_nrdconta_assoc  IN crapass.nrdconta%TYPE           --> Conta do associado
                                  ,pr_dtinitax        IN craprda.dtmvtolt%TYPE           --> Data Inicial da Utilizacao da taxa da poupanca
                                  ,pr_dtfimtax        IN craprda.dtmvtolt%TYPE           --> Data Final da Utilizacao da taxa da poupanca
                                  ,pr_vlsdrdca        OUT craprda.vlsdrdca%TYPE          --> Valor Saldo Aplicacao
                                  ,pr_txaplica        OUT craplap.txaplica%TYPE          --> Taxa Maxima de Aplicacao
                                  ,pr_txaplmes        OUT craplap.txaplmes%TYPE          --> Taxa Minima de Aplicacao
                                  ,pr_retorno         OUT VARCHAR2                       --> Descricao de erro ou sucesso
                                  ,pr_tab_acumula     IN OUT NOCOPY APLI0001.typ_tab_acumula_aplic --> Aplicacoes
                                  ,pr_tab_erro        IN OUT NOCOPY GENE0001.typ_tab_erro);        --> Saida com erros;

  /* Rotina de calculo do RDCA */
  procedure pc_calc_aplicacao (pr_cdcooper in crapcop.cdcooper%type,      --> Cooperativa
                               pr_dtmvtolt in crapdat.dtmvtolt%type,      --> Data do movimento
                               pr_dtmvtopr in crapdat.dtmvtopr%type,      --> Primeiro dia útil após a data do movimento
                               pr_rda_rowid in varchar2,                  --> Identificador do registro da tabela CRAPRDA em processamento
                               pr_cdprogra in crapprg.cdprogra%type,      --> Programa chamador
                               pr_inproces in crapdat.inproces%type,      --> Indicador do processo
                               pr_insaqtot out craprda.insaqtot%type,     --> Indicador de saque total
                               pr_vlsdrdca out craprda.vlsdrdca%type,     --> Saldo da aplicação RDCA
                               pr_sldpresg out craprda.vlsdrdca%type,     --> Saldo para resgate
                               pr_dup_vlsdrdca out craprda.vlsdrdca%type, --> Saldo da aplicação RDCA para rotina duplicada
                               pr_cdcritic out crapcri.cdcritic%type,     --> Codigo da critica de erro
                               pr_dscritic out varchar2);                 --> Descricão do erro encontrado

  /* Rotina de calculo do saldo RDCA2 */
  procedure pc_rdca2s (pr_cdcooper in crapcop.cdcooper%type,  --> Cooperativa
                       pr_nrdconta in craprda.nrdconta%TYPE, --> Num da Conta
                       pr_nraplica in craprda.nraplica%TYPE, --> Num da Aplicacao
                       pr_dtiniper IN craprda.dtiniper%TYPE,  --> Data Inicio do Periodo
                       pr_dtfimper IN craprda.dtfimper%TYPE,  --> Data Fim do Periodo
                       pr_inaniver IN craprda.inaniver%TYPE, --> Indicador de Aplicação
                       pr_dtmvtolt IN craprda.dtmvtolt%TYPE, --> Data de Movimento Atual
                       pr_dtmvtopr IN crapdat.dtmvtopr%TYPE, --> DAta do movimento Posterior
                       pr_cdprogra IN crapprg.cdprogra%TYPE, --> Programa chamador
                       pr_vlsdrdca IN OUT NUMBER           , --> Valor saldo RDCA
                       pr_sldpresg IN OUT NUMBER           , --> Saldo para o resgate
                       pr_sldrgttt IN OUT NUMBER           , --> Saldo do resgate total
                       pr_cdcritic OUT crapcri.cdcritic%type, --> Codigo da critica de erro
                       pr_dscritic OUT varchar2);             --> Descricão do erro encontrado

  /* Efetua uma consulta sobre as aplicacoes do cooperado passado como parametro */
  PROCEDURE pc_consulta_aplicacoes(pr_cdcooper    IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                   pr_cdagenci    IN crapass.cdagenci%TYPE,     --> Codigo da agencia
                                   pr_nrdcaixa    IN craperr.nrdcaixa%TYPE,     --> Numero do caixa
                                   pr_cdoperad    IN crapope.cdoperad%TYPE DEFAULT 0, --> Operador
                                   pr_nrdconta    IN crapass.nrdconta%TYPE,     --> Conta do associado
                                   pr_nraplica    IN craprda.nraplica%TYPE,     --> Numero da aplicacao
                                   pr_tpaplica    IN PLS_INTEGER,               --> Tipo de aplicacao
                                   pr_dtinicio    IN DATE,                      --> Data de inicio da aplicacao
                                   pr_dtfim       IN DATE,                      --> Data final da aplicacao
                                   pr_cdprogra    IN crapprg.cdprogra%TYPE,     --> Codigo do programa chamador da rotina
                                   pr_nrorigem    IN PLS_INTEGER,               --> Origem da chamada da rotina
                                   pr_saldo_rdca OUT typ_tab_saldo_rdca,        --> Tipo de tabela com o saldo RDCA
                                   pr_des_reto   OUT VARCHAR2,                  --> OK ou NOK
                                   pr_tab_erro   OUT GENE0001.typ_tab_erro);    --> Tabela com erros

  /* Efetua uma consulta sobre as aplicacoes do cooperado passado como parametro
     Possui a mesma funcionalidade da rotina acima, porem utiliza gravacao em tabelas para serem
     chamadas diretamente atraves de rotinas progress */
  PROCEDURE pc_consulta_aplicacoes_wt(pr_cdcooper    IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                      pr_cdagenci    IN crapass.cdagenci%TYPE,     --> Codigo da agencia
                                      pr_nrdcaixa    IN craperr.nrdcaixa%TYPE,     --> Numero do caixa
                                      pr_nrdconta    IN crapass.nrdconta%TYPE,     --> Conta do associado
                                      pr_nraplica    IN craprda.nraplica%TYPE,     --> Numero da aplicacao
                                      pr_tpaplica    IN PLS_INTEGER,               --> Tipo de aplicacao
                                      pr_dtinicio    IN DATE,                      --> Data de inicio da aplicacao
                                      pr_dtfim       IN DATE,                      --> Data final da aplicacao
                                      pr_cdprogra    IN crapprg.cdprogra%TYPE,     --> Codigo do programa chamador da rotina
                                      pr_nrorigem    IN PLS_INTEGER,               --> Origem da chamada da rotina
                                      pr_cdcritic   OUT crapcri.cdcritic%type,     --> Codigo de Erro
                                      pr_dscritic   OUT VARCHAR2);                 --> Descricao de Erro

  /* Procedure para consultar saldo e demais dados de aplicacoes programadas */
  PROCEDURE pc_consulta_poupanca (pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cooperativa
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE            --> Codigo da Agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE            --> Numero do caixa
                                 ,pr_cdoperad IN craplrg.cdoperad%TYPE            --> Codigo do Operador
                                 ,pr_idorigem IN INTEGER                          --> Identificador da Origem
                                 ,pr_nrdconta IN craprda.nrdconta%TYPE            --> Nro da conta da aplicacao RDCA
                                 ,pr_idseqttl IN INTEGER                          --> Identificador Sequencial
                                 ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE            --> Contrato Poupanca Programada
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            --> Data do movimento atual
                                 ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE            --> Data do proximo movimento
                                 ,pr_inproces IN crapdat.inproces%TYPE            --> Indicador de processo
                                 ,pr_cdprogra IN crapprg.cdprogra%TYPE            --> Nome do programa chamador
                                 ,pr_flgerlog IN BOOLEAN                          --> Flag erro log
                                 ,pr_percenir IN NUMBER                           --> % IR para Calculo Poupanca
                                 ,pr_tab_craptab IN APLI0001.typ_tab_ctablq       --> Tipo de tabela de Conta Bloqueada
                                 ,pr_tab_craplpp IN APLI0001.typ_tab_craplpp      --> Tipo de tabela com lancamento poupanca
                                 ,pr_tab_craplrg IN APLI0001.typ_tab_craplpp      --> Tipo de tabela com resgates
                                 ,pr_tab_resgate IN APLI0001.typ_tab_resgate      --> Tabela com valores dos resgates das contas por aplicacao
                                 ,pr_vlsldrpp OUT NUMBER                          --> Valor saldo poupanca programada
                                 ,pr_retorno  OUT VARCHAR2                        --> Descricao de erro ou sucesso OK/NOK
                                 ,pr_tab_dados_rpp OUT APLI0001.typ_tab_dados_rpp --> Poupancas Programadas
                                 ,pr_tab_erro      IN OUT NOCOPY GENE0001.typ_tab_erro);  --> Saida com erros;


  PROCEDURE pc_insere_tab_wrk(pr_cdcooper     in tbgen_batch_relatorio_wrk.cdcooper%type 
                             ,pr_nrdconta     in tbgen_batch_relatorio_wrk.nrdconta%type
                             ,pr_cdprogra     in tbgen_batch_relatorio_wrk.cdprograma%type
                             ,pr_dsrelatorio  in tbgen_batch_relatorio_wrk.dsrelatorio%type
                             ,pr_dtmvtolt     in tbgen_batch_relatorio_wrk.dtmvtolt%type
                             ,pr_dschave      in tbgen_batch_relatorio_wrk.dschave%type                           
                             ,pr_dsinformacao in tbgen_batch_relatorio_wrk.dscritic%type
                             ,pr_dscritic    out varchar2);

END APLI0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.APLI0001 AS

  /* Tratamento de erro */
  vr_des_erro   VARCHAR2(4000);
  vr_exc_erro   EXCEPTION;

  /* Descricao e codigo da critica */
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);

  /* Erro em chamadas da pc_gera_erro */
  vr_des_reto VARCHAR2(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  -- Aplicacoes RDCA
  CURSOR cr_craprda (pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Codigo da cooperativa
                    ,pr_nrctaapl  IN craprda.nrdconta%TYPE        --> Numero da conta
                    ,pr_nraplres  IN craprda.nraplica%TYPE) IS    --> Numero da aplicacao
    SELECT ca.dtmvtolt
          ,ca.dtatslmx
          ,ca.vlsdrdca
          ,ca.nrdconta
          ,ca.nraplica
          ,ca.vlsltxmm
          ,ca.dtatslmm
          ,ca.qtdiauti
          ,ca.vlsltxmx
          ,ca.ROWID
          ,count(1) over() retorno
    FROM craprda ca
    WHERE ca.cdcooper = pr_cdcooper
      AND ca.nrdconta = pr_nrctaapl
      AND ca.nraplica = pr_nraplres;
  rw_craprda cr_craprda%ROWTYPE;

  -- Valor de moeda fixa utilizada no sistema
  CURSOR cr_crapmfx (pr_cdcooper  IN crapdat.cdcooper%TYPE          --> Codigo da cooperativa
                    ,pr_dtiniper  IN DATE                           --> Data do movimento atual
                    ,pr_tpmoefix  IN crapmfx.tpmoefix%TYPE) IS      --> Tipo da moeda fixa
    SELECT cx.vlmoefix
    FROM crapmfx cx
    WHERE cx.cdcooper = pr_cdcooper
      AND cx.dtmvtolt = pr_dtiniper
      AND cx.tpmoefix = pr_tpmoefix;
  rw_crapmfx cr_crapmfx%rowtype;

  /* Cursor generico de calendario */
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt
          ,dat.dtmvtopr
          ,dat.dtmvtoan
          ,dat.inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,dat.dtmvtocd
          ,last_day(add_months(dat.dtmvtolt,-1)) dtultdma -- Ult. Dia Mes Ant.
          ,last_day(dat.dtmvtolt)                dtultdia -- Utl. Dia Mes Corr.
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;

  -- Definicao da tipo de registro que vai
  -- compreender as informacoes de moeda + juros aplicaveis
  -- conforme o valor da moeda no dia
  TYPE typ_reg_moedatx IS
    RECORD (vlmoefix crapmfx.vlmoefix%TYPE
           ,txaplmes NUMBER(18,8));

  -- Definicao do tipo de tabela que armazena
  -- registros do tipo acima detalhado
  TYPE typ_tab_moedatx IS
    TABLE OF typ_reg_moedatx
    INDEX BY VARCHAR2(10);
  -- Vetores para armazenar as informacoes de moedas
  vr_tab_moedatx typ_tab_moedatx;

  -- Definicao da tipo de registro que vai compreender as informacoes de moeda
  TYPE typ_tab_moeda IS
    TABLE OF NUMBER
    INDEX BY BINARY_INTEGER; --> Data como um numero
  -- Vetores para armazenar as informacoes de moedas
  vr_tab_moeda typ_tab_moeda;

  -- Definicao da tipo de tabela de registro que vai
  -- compreender as informacoes de dias uteis por mes
  TYPE typ_tab_qtdiaute IS
    TABLE OF NUMBER
      INDEX BY VARCHAR2(8);
  -- Vetor para armazenar os dias uteis
  vr_tab_qtdiaute typ_tab_qtdiaute;

  /* Funcao para arredondamento de valores em calculos de aplicacoes */
  FUNCTION fn_round(pr_vlorigem IN NUMBER
                   ,pr_qtarredo IN INTEGER) RETURN NUMBER IS
  BEGIN
    /* .............................................................................
     Programa: fn_round
     Autor   : Marcos.
     Data    : 05/03/2013                     Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Levando em consideracao o Progress possui limitacao de trabalhar com
                 no maximo 10 casas decimais, e todo calculo que exceda essa quantidade
                 efetua um round(10) implicitamente, ficou definido junto ao Guilherme
                 Strube (Cecred) em 05/03/13, que todo arredondamento em rotinas de
                 aplicacoes no Oracle deve primeiravamente efetuar um round de 10 casas
                 decimais e somente apos esse round sera efetuado o round desejado.
                 Isso deve ser feito para garantir que o Oracle tenha o mesmo comporta-
                 mento do Progress, ja que o Oracle pode trabalhar com mais casas deci-
                 mais e sem este Round podem haver diferencas nos calculos desejados.

     Parametros : pr_vlorigem => Valor original para arredondarmos
                  pr_qtarredo => Quantida de casas para arredondarmos

     Premissa  : Progress " variable decimals cannot be greater than 10. (343) "

     Alteracoes :
     */
    BEGIN
      -- Somente efetuar o arredondamento de 10 se a quantidade de
      -- casas desejadas for inferior a 10 (limite Progress)
      IF pr_qtarredo < 10 THEN
        -- Efetuar um Round com 10 internamente e apos o Round desejado
        RETURN ROUND(ROUND(pr_vlorigem,10),pr_qtarredo);
      ELSE
        -- Arredondar somente a quantidade de casas passada
        -- pois do contrario teriamos perda de valor.
        RETURN ROUND(pr_vlorigem,pr_qtarredo);
      END IF;
    END;
  END fn_round;

/* Rotina que busca as informacoes de IR parametrizadas para aplicacoes RDCA */
  PROCEDURE pc_busca_faixa_ir_rdca(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  BEGIN
    /* .............................................................................
     Programa: pc_busca_faixa_ir_rdca (Antigo trecho Includes/var_faixas_ir.i)
     Autor   : Marcos.
     Data    : 10/01/2012                     Ultima atualizacao: 01/06/2016

     Dados referentes ao programa:
     Objetivo  : Povoar a variavel vr_faixa_IR_rdca publico desta package  

     Alteracoes: 01/06/2016 - Ajustado a leitura da craptab para utilizar a rotina
                              da TABE0001 (Douglas - Chamado 454248)
     
     */
    DECLARE
      -- Array para guardar o split dos dados contidos na dstexttb
      vr_vet_dados gene0002.typ_split;
      vr_dstextab  craptab.dstextab%TYPE;
    BEGIN
      -- Somente buscar as faixas em caso do vetor estiver vazio
      IF vr_faixa_ir_rdca.COUNT = 0 OR 
         nvl(vr_faixa_ir_rdca(1).cdcooper,0) <> pr_cdcooper THEN -- Se mudar a cooperativa, deve carregar novamente
        -- Limpar o vetor
        vr_faixa_ir_rdca.DELETE;
        
        -- Buscar a descricao das faixas contido na craptab
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                       ,pr_nmsistem => 'CRED'
                       ,pr_tptabela => 'CONFIG'
                       ,pr_cdempres => 0
                       ,pr_cdacesso => 'PERCIRRDCA'
                       ,pr_tpregist => 0);
        
        -- Efetuar o split das informacoes contidas na dstextab separados por ;
        vr_vet_dados := gene0002.fn_quebra_string(pr_string  => vr_dstextab
                                                 ,pr_delimit => ';');
        -- Para cada registro encontrado
        FOR vr_pos IN 1..vr_vet_dados.COUNT LOOP
          -- Guardar a informacao antes da # no Mes
          vr_faixa_ir_rdca(vr_pos).qtmestab := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(1,vr_vet_dados(vr_pos),'#'));
          -- Guardar a informacao apos o # na aliquota
          vr_faixa_ir_rdca(vr_pos).perirtab := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(2,vr_vet_dados(vr_pos),'#'));
          -- Guardar a cooperativa para reprocessos
          vr_faixa_ir_rdca(vr_pos).cdcooper := pr_cdcooper;
        END LOOP;
      END IF;
    END;
  END pc_busca_faixa_ir_rdca;

  /* Rotina que busca as informacoes de IR parametrizadas para aplicacoes RDC */
  PROCEDURE pc_busca_faixa_ir_rdc(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  BEGIN
    /* .............................................................................
     Programa: pc_busca_faixa_ir_rdc (Antigo trecho b1wgen0001->saldo_rdc_pre)
     Autor   : Marcos.
     Data    : 04/02/2013                     Ultima atualizacao: 01/06/2016

     Dados referentes ao programa:
     Objetivo  : Povoar a variavel vr_faixa_IR_rdc publico desta package

     Alteracoes: Incluido conversao de CHAR para Number (Jean Michel).

                 01/06/2016 - Ajustado a leitura da craptab para utilizar a rotina
                              da TABE0001 (Douglas - Chamado 454248)
     */
    DECLARE
      -- Array para guardar o split dos dados contidos na dstexttb
      vr_vet_dados gene0002.typ_split;
      vr_dstextab  craptab.dstextab%TYPE;
    BEGIN
      -- Somente buscar as faixas em caso do vetor estiver vazio
      IF vr_faixa_ir_rdc.COUNT = 0 OR 
         nvl(vr_faixa_ir_rdc(1).cdcooper,0) <> pr_cdcooper THEN -- Se mudar a cooperativa, deve carregar novamente
        -- Limpar o vetor
        vr_faixa_ir_rdc.DELETE;
        
        -- Buscar a descricao das faixas contido na craptab
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                       ,pr_nmsistem => 'CRED'
                       ,pr_tptabela => 'CONFIG'
                       ,pr_cdempres => 0
                       ,pr_cdacesso => 'PERCIRFRDC'
                       ,pr_tpregist => 0);
        
        -- Efetuar o split das informacoes contidas na dstextab separados por ;
        vr_vet_dados := gene0002.fn_quebra_string(pr_string  => vr_dstextab
                                                 ,pr_delimit => ';');
        -- Para cada registro encontrado
        FOR vr_pos IN 1..vr_vet_dados.COUNT LOOP
          -- Guardar a informacao antes da # no Dia
          vr_faixa_ir_rdc(vr_pos).qtdiatab := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(1,vr_vet_dados(vr_pos),'#'));
          -- Guardar a informacao apos o # na aliquota
          vr_faixa_ir_rdc(vr_pos).perirtab := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(2,vr_vet_dados(vr_pos),'#'));
          -- Guardar a cooperativa para reprocessos
          vr_faixa_ir_rdc(vr_pos).cdcooper := pr_cdcooper;
        END LOOP;
      END IF;
    END;
  END pc_busca_faixa_ir_rdc;

  /***** Rotina para calcular quanto a rdcpos valera na data do vencimento para calculo do var *****/
  PROCEDURE pc_provisao_rdc_pos_var (pr_cdcooper        IN crapcop.cdcooper%TYPE
                                   ,pr_nrdconta         IN craprda.nrdconta%TYPE
                                   ,pr_nraplica         IN craprda.nraplica%TYPE
                                   ,pr_dtmvtolt         IN crapdat.dtmvtolt%TYPE
                                   ,pr_dtmvtopr         IN crapdat.dtmvtopr%TYPE
                                   ,pr_craprda_dtmvtolt IN craprda.dtmvtolt%TYPE
                                   ,pr_craprda_vlsltxmx IN craprda.vlsltxmx%TYPE
                                   ,pr_craprda_dtatslmx IN craprda.dtatslmx%TYPE
                                   ,pr_craprda_txaplica IN craplap.txaplica%TYPE
                                   ,pr_vlsdrdca         IN OUT NUMBER
                                   ,pr_vlrentot         IN OUT NUMBER
                                   ,pr_cdcritic         OUT NUMBER
                                   ,pr_dscritic         OUT VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_provisao_rdc_pos_var (antiga b1wgen0004.provisao_rdc_pos_var )
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Alisson (AMcom)
    --   Data    : Dezembro/2012                          Ultima Atualizacao: 10/12/2012
    --
    --   Dados referentes ao programa:
    --   Frequencia: Sempre que chamado por outros programas.
    --   Objetivo  : Calcular a provisao para o var
    --
    --   Observacoes :
    --
    --
    --   Alteracoes  : 14/08/2013 - Remover o parametro pr_tab_moeda e carrega-lo internamente
    --                              na rotina (Marcos-Supero)
    --
    --                 08/10/2013 - Ajustes na atribuição "vr_vlrendim := fn_round(vr_vlsdrdca * vr_txaplica,8)"
    --                              para "vr_vlrendim:= TRUNC(vr_vlsdrdca * vr_txaplica,8)", pois na versão
    --                              original Progress é utilizado o Truncate (Marcos-Supero)
    -- .............................................................................

    DECLARE

     -- Variaveis para a include de erros - valores fixos usados na internet
     vr_100        INTEGER:= 100;
     vr_index      NUMBER;
     vr_dtiniper   DATE;
     vr_dtfimper   DATE;
     vr_dtcalcul   DATE;
     vr_vlrendim   NUMBER(20,8);
     vr_txaplmes   NUMBER(20,8);
     vr_txaplica   NUMBER(20,8);
     vr_exc_erro   EXCEPTION;
     vr_processa   BOOLEAN;
     vr_vlmoefix   crapmfx.vlmoefix%TYPE;
     vr_vlsdrdca   NUMBER(20,4):= fn_round(NVL(pr_vlsdrdca,0),4);
     vr_vlrentot   NUMBER(20,4):= fn_round(NVL(pr_vlrentot,0),4);

     /* Buscar valores de moeda fixa */
     CURSOR cr_crapmfx (pr_cdcooper IN crapmfx.cdcooper%TYPE
                       ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS
       SELECT /*+ index (crapmfx CRAPMFX##CRAPMFX1) */
              crapmfx.cdcooper
             ,crapmfx.dtmvtolt
             ,crapmfx.tpmoefix
             ,crapmfx.vlmoefix
        FROM crapmfx crapmfx
       WHERE crapmfx.cdcooper = pr_cdcooper
         AND crapmfx.tpmoefix = pr_tpmoefix;
      rw_crapmfx cr_crapmfx%ROWTYPE;

   BEGIN

     vr_dtcalcul:= NULL;
     vr_vlrendim:= 0;

    -- Se o vetor de moedas não esta carregado ainda
    IF vr_tab_moeda.COUNT = 0 THEN
      -- Alimentar vetor com as moedas
      FOR rw_crapmfx IN cr_crapmfx (pr_cdcooper => pr_cdcooper
                                   ,pr_tpmoefix => 6) LOOP
        --Atribuir o valor selecionado ao vetor
        vr_tab_moeda(To_Char(rw_crapmfx.dtmvtolt,'YYYYMMDD')):= rw_crapmfx.vlmoefix;
      END LOOP;
    END IF;

    -- Se a taxa contratada nao foi passada como parametro
    IF pr_craprda_txaplica IS NULL THEN
      -- Montar mensagem de critica
      pr_cdcritic := 90;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 90);
      --Levantar excecao para sair do programa
      RAISE vr_exc_erro;
    ELSE

      --Associa valores para as variaveis de retorno
      vr_vlsdrdca:= pr_craprda_vlsltxmx; --rw_craprda.vlsltxmx;
      --Determina a data de inicio
      vr_dtiniper:= pr_craprda_dtatslmx; --rw_craprda.dtatslmx;
      --Determina a data final
      vr_dtfimper:= pr_dtmvtopr;
      --Atribui zero para o valor da moeda
      vr_vlmoefix:= 0;

      --Loop para encontrar o proximo dia util
      WHILE vr_dtiniper < vr_dtfimper LOOP

        -- Validar se a data auxiliar e util e se não for trazer a primeira apos
        vr_dtcalcul:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                 ,pr_dtmvtolt => vr_dtiniper
                                                 ,pr_tipo     => 'P'     -- valor padrao
                                                 ,pr_feriado  => true    -- valor padrao 
                                                 ,pr_excultdia => true); -- considera 31/12 como util

        --Se for sabado ou domingo ou feriado entao pega a proxima data
        IF Trunc(vr_dtcalcul) <> Trunc(vr_dtiniper) THEN
          --Incrementar a data de inicio
          vr_dtiniper:= vr_dtiniper + 1;
          --Variavel de controle do loop
          vr_processa:= FALSE;
        ELSE
          --Atribuir true para seguir processamento
          vr_processa:= TRUE;
        END IF;

        --Se encontrou o dia util entao processa
        IF vr_processa THEN
          --Se a data encontrada for maior que a final
          IF vr_dtiniper >= vr_dtfimper THEN
            --Sair do loop da rotina
            EXIT;
          END IF;

          --Zera o valor das variaveis
          vr_vlmoefix:= 0;
          vr_txaplmes:= 0;
          vr_txaplica:= 0;
          vr_vlrendim:= 0;

          --Se a data encontrada for menor que a data de movimento
          IF vr_dtiniper <= pr_dtmvtolt THEN
            vr_index:= To_Number(To_Char(vr_dtiniper,'YYYYMMDD'));
            --Verificar se o indice existe na tabela
            IF vr_tab_moeda.EXISTS(vr_index) THEN
              --Atribuir o valor do vetor para a variavel
              vr_vlmoefix:= vr_tab_moeda(vr_index);
            END IF;
          END IF;

          --Calcula a taxa de aplicacao no mes
          vr_txaplmes:= (POWER((1 + (vr_vlmoefix / vr_100)),(1 / 252)) - 1) * vr_100;

          --Calcula a taxa aplicacao com 8 decimais
          vr_txaplica:= fn_round((vr_txaplmes * pr_craprda_txaplica / vr_100 ) / vr_100 ,8);
          vr_vlrendim:= TRUNC(vr_vlsdrdca * vr_txaplica,8);
          vr_vlsdrdca:= vr_vlsdrdca + vr_vlrendim;
          vr_vlrentot:= vr_vlrentot + vr_vlrendim;
          vr_dtiniper:= vr_dtiniper + 1;

        END IF; /* Fim do IF vr_processa */
      END LOOP;  /* Fim do While */

      --Arredonda os parametros de retorno para 2 decimais
      pr_vlsdrdca:= fn_round(vr_vlsdrdca,2);
      pr_vlrentot:= fn_round(vr_vlrentot,2);

    END IF;

   EXCEPTION
     WHEN vr_exc_erro THEN
       pr_dscritic := 'Problemas na Rotina APLI0001.pc_provisao_rdc_pos_var '||pr_cdcooper||'. Erro: '||pr_dscritic;
     WHEN OTHERS THEN
       pr_cdcritic := 0;
       pr_dscritic := 'Problemas na Rotina APLI0001.pc_provisao_rdc_pos_var '||pr_cdcooper||'. Erro: '||sqlerrm;
   END;

  END pc_provisao_rdc_pos_var;

  /* Rotina de calculo da provisao no final do mes e no vencimento. */
  PROCEDURE pc_provisao_rdc_pre(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Cooperativa
                               ,pr_nrdconta  IN craprda.nrdconta%TYPE     --> Numero da Conta
                               ,pr_nraplica  IN craprda.nraplica%TYPE     --> Numero da Aplicacao
                               ,pr_dtiniper  IN crapdat.dtmvtolt%TYPE     --> Data base inicial
                               ,pr_dtfimper  IN crapdat.dtmvtopr%TYPE     --> Data base final
                               ,pr_vlsdrdca OUT NUMBER                    --> Valor do saldo RDCA
                               ,pr_vlrentot OUT NUMBER                    --> Valor do rendimento total
                               ,pr_vllctprv OUT NUMBER                    --> Valor dos ajustes RDC
                               ,pr_des_reto OUT VARCHAR                   --> Indicador de saida com erro (OK/NOK)
                               ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --> Tabela com erros
    /* .............................................................................

       Programa: pc_provisao_rdc_pre (Antigo BO b1wgen0001.provisao_rdc_pre)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos (Supero)
       Data    : Fevereiro/13.                    Ultima atualizacao: 21/02/2013

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado

       Objetivo  :   Rotina de calculo da provisao no final do mes e no vencimento

       Alteracoes: 21/02/2013 - Conversão Progress >> Oracle (PLSQL) (Marcos-Supero)

                   04/02/2013 - Ajuste de casas decimais (Odirlei-AMcom)

    ............................................................................. */
  BEGIN
    DECLARE
      -- Buscar os dados da aplicacao RDCA
      CURSOR cr_craprda IS
        SELECT rda.dtmvtolt
              ,rda.vlsdrdca
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;
      rw_craprda cr_craprda%ROWTYPE;
      -- Buscar as taxas contratadas
      CURSOR cr_craplap IS
        SELECT lap.txaplica
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta
           AND lap.nraplica = pr_nraplica
           AND lap.dtmvtolt = rw_craprda.dtmvtolt
         ORDER BY lap.progress_recid ASC; --> Retornar a primeira encontrada
      rw_craplap cr_craplap%ROWTYPE;
      -- Busca sumaria dos lancamentos de ajuste
      CURSOR cr_craplap_sum(pr_cdhistor IN craplap.cdhistor%TYPE) IS
        SELECT SUM(lap.vllanmto)
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta
           AND lap.nraplica = pr_nraplica
           AND lap.cdhistor = pr_cdhistor;
      vr_vllanmto craplap.vllanmto%TYPE;
      -- Auxiliares ao calculo
      vr_txaplica NUMBER(18,8); --> Taxa de aplicacao
      vr_dtcalcul DATE;         --> Receber a data de parametro a acumular os dias
      vr_vlrendim NUMBER(18,8); --> Auxiliar para calculo dos rendimentos da aplicacao
      vr_vlrentot NUMBER(18,4) := 0; --> Totalizador dos rendimentos
      vr_vlsdrdca NUMBER(18,4) := 0; --> Totalizador do saldo rdca
    BEGIN
      -- Testar existencia e retornar informacoes da CRAPRDA
      OPEN cr_craprda;
      FETCH cr_craprda
       INTO rw_craprda;
      -- Se não encontrar
      IF cr_craprda%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_craprda;
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 999
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 426 --> Critica 426
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor e continuar
        CLOSE cr_craprda;
      END IF;
      -- Buscar as taxas contratadas
      OPEN cr_craplap;
      FETCH cr_craplap
       INTO rw_craplap;
      -- Se não encontrar
      IF cr_craplap%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craplap;
        -- Gerar erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1   --> Fixo pois e irrelevante
                             ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 90 --> Critica 90
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      ELSE
        -- Fechar o cursor e continuar
        CLOSE cr_craplap;
        -- Guardar os dados da aplicacao
        vr_txaplica := TRUNC(rw_craplap.txaplica / 100,8);
      END IF;
      -- Busca sumaria dos lancamentos de ajuste
      -- 1? 474 - Ajt +
      OPEN cr_craplap_sum(pr_cdhistor => 474);
      FETCH cr_craplap_sum
       INTO vr_vllanmto;
      CLOSE cr_craplap_sum;
      -- Acumular no parametro de ajustes
      pr_vllctprv := NVL(pr_vllctprv,0) + NVL(vr_vllanmto,0);
      -- 2? 463 - Ajt -
      OPEN cr_craplap_sum(pr_cdhistor => 463);
      FETCH cr_craplap_sum
       INTO vr_vllanmto;
      CLOSE cr_craplap_sum;
      -- Diminuir no parametro de ajustes
      pr_vllctprv := NVL(pr_vllctprv,0) - NVL(vr_vllanmto,0);
      -- Acumular na variavel de saida, o saldo atual + ajustes
      vr_vlsdrdca := rw_craprda.vlsdrdca + pr_vllctprv;
      -- Iniciar data para calculo com data inicial envida
      vr_dtcalcul := pr_dtiniper;
      -- Verifica dias uteis e calcula os rendimentos
      LOOP
        -- Validar se a data auxiliar e util e se não for trazer a primeira apos
        vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => vr_dtcalcul
                                                  ,pr_tipo     => 'P'     -- valor padrao
                                                  ,pr_feriado  => true    -- valor padrao 
                                                  ,pr_excultdia => true); -- considera 31/12 como util
        -- Continuar enquanto a data auxiliar de calculo for inferior a data final
        EXIT WHEN vr_dtcalcul >= pr_dtfimper;
        -- Acumular os rendimentos com base no saldo RCA * taxa
        vr_vlrendim := TRUNC((vr_vlsdrdca * vr_txaplica),8);
        -- Acumular no saldo RCA o rendimento calculado
        vr_vlsdrdca := vr_vlsdrdca + vr_vlrendim;
        -- Acumular a variavel de rendimento total
        vr_vlrentot := vr_vlrentot + vr_vlrendim;
        -- Incrementar mais um dia na data auxiliar para processar o proximo dia
        vr_dtcalcul := vr_dtcalcul + 1;
      END LOOP; --> Fim da do calculos nos dias uteis
      -- Arredondar saidas de rendimento total e saldo
      pr_vlrentot := fn_round(vr_vlrentot,2);
      pr_vlsdrdca := fn_round(vr_vlsdrdca,2);
      -- Chegou ao final sem problemas
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_provisao_rdc_pre --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 999
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_provisao_rdc_pre;

  /* Calculo de Saldo para Resgate de Aplicacao Antiga b1wgen0005.p->saldo-rdca-resgate */
  PROCEDURE pc_saldo_rdca_resgate(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo da agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                 ,pr_cdprogra IN crapprg.cdprogra%TYPE --> Programa chamador
                                 ,pr_nrdconta IN craprda.nrdconta%TYPE --> Conta da aplicacao RDCA
                                 ,pr_dtaplica IN DATE                  --> Data pada resgate da aplicacao
                                 ,pr_nraplica IN craprda.nraplica%TYPE --> Numero da aplicacao RDCA
                                 ,pr_vlsldapl IN craprda.vlsdrdca%TYPE --> Saldo da aplicacao
                                 ,pr_vlrenper IN NUMBER                --> Valor do rendimento no periodo
                                 ,pr_tpchamad IN PLS_INTEGER           --> Tipo de chamada 1 - da BO, 2 - do Fonte
                                 ,pr_pcajsren OUT NUMBER               --> Percentual do resgate sobre o rendimento acumulado
                                 ,pr_vlrenreg OUT NUMBER               --> Valor para calculo do ajuste
                                 ,pr_vldajtir OUT NUMBER               --> Valor do ajuste de IR
                                 ,pr_sldrgttt OUT NUMBER               --> Saldo do resgate total
                                 ,pr_vlslajir OUT NUMBER               --> Saldo utilizado para calculo do ajuste
                                 ,pr_vlrenacu OUT NUMBER               --> Rendimento acumulado para calculo do ajuste
                                 ,pr_nrdmeses OUT INTEGER              --> Numero de meses da aplicacao
                                 ,pr_nrdedias OUT INTEGER              --> Numero de dias da aplicacao
                                 ,pr_dtiniapl OUT DATE                 --> data de inicio da aplicacao
                                 ,pr_cdhisren OUT craphis.cdhistor%TYPE --> Historico de lancamento no rendimento
                                 ,pr_cdhisajt OUT craphis.cdhistor%TYPE --> Historico de ajuste
                                 ,pr_perirapl OUT NUMBER                --> Percentual de IR Aplicado
                                 ,pr_sldpresg IN OUT NUMBER             --> Saldo para o resgate
                                 ,pr_des_reto OUT VARCHAR               --> Indicador de saida com erro (OK/NOK)
                                 ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela com erros
                                 ) AS
  BEGIN
    /*..............................................................................

     Programa: pc_saldo_rdca_resgate (Antigo b1wgen0005.p --> saldo-rdca-resgate)
     Autor   : Junior
     Data    : 31/10/2005                        Ultima atualizacao: 11/07/2013

     Dados referentes ao programa:

     Objetivo  : CALCULO SALDO PARA RESGATE APLICACAO
                 Baseado em fontes/saldo_rdca_resgate.p.

     Alteracoes: 22/05/2006 - Incluido codigo da cooperativa nas leituras das
                              tabelas (Diego).

                 03/08/2007 - Definicoes de temp-tables para include (David).

                 27/12/2007 - Retirada do FIND crapcop, pois este nao
                              estava sendo necessario (Julio)

                 21/02/2008 - Retirar includes/b1wge0005tt.i (Guilherme).

                 03/11/2009 - Alterar variaveis internas para parametros de
                              saida (David).

                 11/01/2013 - Conversão Progress --> Oracle (PL/SQL) (Marcos-Supero)

                 11/07/2013 - Alteracao para prever chamadas tambem da antiga
                              fontes/saldo_rdca_resgate (Marcos-Supero)

  ..............................................................................*/
    DECLARE
      -- Buscar os dados da aplicacao RDCA
      CURSOR cr_craprda IS
        SELECT rda.dtmvtolt
              ,rda.tpaplica
              ,rda.vlsdrdca
              ,rda.dtfimper
              ,rda.vlabcpmf
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;
      rw_craprda cr_craprda%ROWTYPE;
      -- Busca do ultimo lancamento da aplicacao com o historico encontrado
      -- na pr_cdhisren, neste momento trazemos apenas o MAX(progress_recid)
      CURSOR cr_craplap_max IS
        SELECT max(lap.progress_recid)
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta
           AND lap.nraplica = pr_nraplica
           AND lap.cdhistor = pr_cdhisren;
      vr_max_progress_recid craplap.progress_recid%TYPE;
      -- Busca efetiva do registro pertinente ao max
      CURSOR cr_craplap IS
        SELECT lap.vlslajir
              ,lap.vlrenacu
          FROM craplap lap
         WHERE lap.progress_recid = vr_max_progress_recid
         ORDER BY lap.progress_recid DESC;
      rw_craplap cr_craplap%ROWTYPE;
      -- Auxiliar para calulo do IR
      vr_vlrabnir NUMBER(18,8);
    BEGIN
      -- Busca do calendario da Cooperativa
      OPEN cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE cr_crapdat;
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 1 --> Critica 1
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapdat;
      END IF;
      -- Chamar rotina que atualiza o vetor vr_faixa_ir_rdca
      -- pois utilizaremos ele nesta rotina
      pc_busca_faixa_ir_rdca(pr_cdcooper => pr_cdcooper);
      -- Testar existencia e retornar informacoes da CRAPRDA
      OPEN cr_craprda;
      FETCH cr_craprda
       INTO rw_craprda;
      -- Se não encontrar
      IF cr_craprda%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_craprda;
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 426 --> Critica 426
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor e continuar
        CLOSE cr_craprda;
      END IF;
      -- Se a data de movimentacao da aplicacao for <= 22/12/2004
      IF rw_craprda.dtmvtolt <= to_date('22/12/2004','dd/mm/yyyy') THEN
        -- Utilizaremos como data base da aplicacao 01/07/2004
        pr_dtiniapl := to_date('01/07/2004','dd/mm/yyyy');
      ELSE
        -- Podemos utilizar a data constante na tabela
        pr_dtiniapl := rw_craprda.dtmvtolt;
      END IF;
      -- Chamar a rotina que calcula a diferenca de dias e meses
      -- entre a data tratada acima e a data desejada da aplicacao
      gene0005.pc_calc_mes(pr_datadini => pr_dtiniapl   --> Data base inicio
                          ,pr_datadfim => pr_dtaplica   --> Data base fim
                          ,pr_qtdadmes => pr_nrdmeses   --> Quantidade de meses
                          ,pr_qtdadias => pr_nrdedias); --> Quantidade de dias
      -- Se houver algum problema no retorno
      IF pr_nrdmeses IS NULL OR pr_nrdedias IS NULL THEN
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 840 --> Critica 840
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      END IF;
      -- Preencher os historicos conforme o tipo da aplicacao
      IF rw_craprda.tpaplica = 3 THEN -- RDCA
        pr_cdhisren := 116; -- RENDIMENTO
        pr_cdhisajt := 875; -- AJT RGT IR-30
      ELSIF rw_craprda.tpaplica = 5 THEN -- RDCAII
        pr_cdhisren := 179; -- RENDIMENTO
        pr_cdhisajt := 876; -- AJT RGT IR-60
      END IF;
      -- Se por algum motivo não preencheu  o historico
      IF pr_cdhisren = 0 THEN
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 526 --> Critica 526
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      END IF;
      -- Buscar o percentual de IR sobre a aplicacao
      -- conforme a quantidade de meses encontrada acima
      -- Obs: Efetuamos a busca do final para o inicio
      --      pois e mais facil encontrar na faixa superior
      FOR vr_cont IN REVERSE 1..vr_faixa_ir_rdca.COUNT LOOP
        -- Se a quantidade de meses encontrada for superior ao mes da faixa de IR
        -- OU igual ao mes da faixa de IR desde que a quantida de dias seja > 0
        IF pr_nrdmeses > vr_faixa_ir_rdca(vr_cont).qtmestab
        OR (pr_nrdmeses = vr_faixa_ir_rdca(vr_cont).qtmestab AND pr_nrdedias > 0) THEN
          -- Utilizar o percentual encontrado nesta faixa
          pr_perirapl := vr_faixa_ir_rdca(vr_cont).perirtab;
          -- Sair do laco pois encontrou
          EXIT;
        END IF;
      END LOOP;
      -- Se não encontrou a aliquota acima e não esta na Cecred
      IF pr_perirapl = 0 AND pr_cdcooper <> 3 THEN
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 180 --> Critica 180
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      END IF;
      -- Zerar auxiliar para calculo IR
      vr_vlrabnir := 0;
      -- Busca do ultimo lancamento da aplicacao com o historico encontrado
      -- na pr_cdhisren, neste momento trazemos apenas o MAX(progress_recid)
      OPEN cr_craplap_max;
      FETCH cr_craplap_max
       INTO vr_max_progress_recid;
      CLOSE cr_craplap_max;
      -- Busca efetiva do registro pertinente ao max
      OPEN cr_craplap;
      FETCH cr_craplap
       INTO rw_craplap;
      -- Se não encontrar
      IF cr_craplap%NOTFOUND THEN
        -- Podemos fechar o cursor
        CLOSE cr_craplap;
        -- Utilizamos o saldo da aplicacao como saldo para resgate
        pr_sldpresg := pr_vlsldapl;
        -- Saldo para ajuste IR recebe o saldo da RCDA
        pr_vlslajir := rw_craprda.vlsdrdca;
        -- Somente calcular o saldo para resgate se 1?:
        -- Se o Valor Abono CMPF > 0 desde que chamada seja da BO (pr_tpchamad = 1)
        IF rw_craprda.vlabcpmf > 0 AND pr_tpchamad = 1 OR pr_tpchamad = 2 THEN
          -- E depois validar alguma das seguintes condicoes (a, b ou c):
          -- a)  Fim do periodo aplicacao > Dt mvto Anterior
          --   E Fim do periodo aplicacao <= Dt mvto Atual
          -- b)  No programa crps105
          --   E Fim do periodo da aplicao Igual ao Proximo Dia de Movimento
          -- c)  Fim do periodo da aplicacao Menor que proximo dia de Movimento
          --   E Fim do periodo da aplicacao Maior que dia do movimento atual
          IF ( rw_craprda.dtfimper > rw_crapdat.dtmvtoan AND rw_craprda.dtfimper <= rw_crapdat.dtmvtolt)
          OR ( pr_cdprogra = 'CRPS105' AND rw_craprda.dtfimper = rw_crapdat.dtmvtopr )
          OR ( rw_craprda.dtfimper < rw_crapdat.dtmvtopr AND rw_craprda.dtfimper > rw_crapdat.dtmvtolt) THEN
            -- Abono do IR recebe a aliquota da tabela de IRs na faixa 1 * Abono CPMF
            vr_vlrabnir := TRUNC((rw_craprda.vlabcpmf * vr_faixa_ir_rdca(1).perirtab/100),2);
            -- Diminuir do saldo para resgate o Abono de IR e o valor do
            -- rendimento no periodo * aliquota da tabela de IRs na faixa 1
            pr_sldpresg := pr_sldpresg - vr_vlrabnir - TRUNC((pr_vlrenper * vr_faixa_ir_rdca(1).perirtab / 100),2);
          END IF;
        END IF;
      ELSE
        -- Podemos fechar o cursor
        CLOSE cr_craplap;
        -- Utilizar como Saldo Ajuste de IR e Rendimento Acumulado para IR os valores da CRAPLAP
        pr_vlslajir := rw_craplap.vlslajir;
        pr_vlrenacu := rw_craplap.vlrenacu;
        -- Somente continuar se houver Saldo Ajuste de IR
        IF pr_vlslajir > 0 THEN
          -- Ajuste no Rendimento recebe o Saldo da Aplicacao / Saldo Ajuste IR * 100
          pr_pcajsren := pr_vlsldapl / pr_vlslajir * 100;
          -- Ajuste não pode ser superior a 100
          IF pr_pcajsren > 100 THEN
            pr_pcajsren := 100;
          END IF;
          -- Calcular o abono de IR se Fim do periodo aplicacao > Dt mvto Anterior
          --   E Fim do periodo aplicacao <= Dt mvto Atual E Valor Abono CMPF > 0
          IF ( rw_craprda.dtfimper > rw_crapdat.dtmvtoan AND rw_craprda.dtfimper <= rw_crapdat.dtmvtolt  AND rw_craprda.vlabcpmf > 0 ) THEN
            -- Abono do IR recebe a aliquota da tabela de IRs na faixa 1 * Abono CPMF
            vr_vlrabnir := TRUNC((rw_craprda.vlabcpmf * vr_faixa_ir_rdca(1).perirtab/100),2);
          END IF;
          -- Rendimento total recebe o rendimento acumulado * percentual ajuste rendimento / 100
          pr_vlrenreg := pr_vlrenacu * pr_pcajsren / 100;
          -- Valor do ajuste do IR recebera:
          -- Rendimento acumulado * aliquota encontrada na faixa - Rendimento acumulado * Aliquota da faixa 4
          pr_vldajtir := TRUNC(((pr_vlrenreg * pr_perirapl / 100) - (pr_vlrenreg * vr_faixa_ir_rdca(4).perirtab/100)),2);
          -- Saldo para resgate sera o saldo da aplicacao - abono de IR - ajuste de IR - (rendimento periodo * aliquota encontrada)
          pr_sldpresg := fn_round((pr_vlsldapl - vr_vlrabnir - pr_vldajtir - TRUNC((pr_vlrenper * pr_perirapl / 100),2)),2);
          -- Saldo para resgate não pode ficar negativo
          IF pr_sldpresg < 0 THEN
            pr_sldpresg := 0;
          END IF;
          -- Saldo para resgate TT recebe o saldo da aplicacao
          -- diminuindo o saldo para resgate e o valor de ajuste de IR
          pr_sldrgttt := pr_vlsldapl - pr_sldpresg - pr_vldajtir;
        END IF;
      END IF;
      -- Para o tipo de aplicacao RDCA30
      IF rw_craprda.tpaplica = 3 THEN
        -- Zerar o saldo de resgate
        pr_sldrgttt := 0;
      END IF;
      -- Chegou ao final sem problemas
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_saldo_rdca_resgate --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_saldo_rdca_resgate;

  /* Consulta saldo aplicacao RDCA30 (Antiga includes/b1wgen0004.i) */
  PROCEDURE pc_consul_saldo_aplic_rdca30(pr_cdcooper     IN crapcop.cdcooper%TYPE      --> Cooperativa
                                        ,pr_cdoperad     IN crapope.cdoperad%TYPE DEFAULT 0  --> Operador
                                        ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE      --> Data do processo
                                        ,pr_inproces     IN crapdat.inproces%TYPE      --> Indicador do processo
                                        ,pr_dtmvtopr     IN crapdat.dtmvtopr%TYPE      --> Proximo dia util
                                        ,pr_cdprogra     IN crapprg.cdprogra%TYPE      --> Programa em execucao
                                        ,pr_cdagenci     IN crapass.cdagenci%TYPE      --> Codigo da agencia
                                        ,pr_nrdcaixa     IN craperr.nrdcaixa%TYPE      --> Numero do caixa
                                        ,pr_nrdconta     IN craprda.nrdconta%TYPE      --> Nro da conta da aplicacao RDCA
                                        ,pr_nraplica     IN craprda.nraplica%TYPE      --> Nro da aplicacao RDCA
                                        ,pr_vlsdrdca     OUT NUMBER                    --> Saldo da aplicacao
                                        ,pr_dup_vlsdrdca OUT NUMBER                    --> Acumulo do saldo da aplicacao RDCA
                                        ,pr_vlsldapl     OUT NUMBER                    --> Saldo da aplicacao RDCA
                                        ,pr_sldpresg     OUT NUMBER                    --> Saldo para resgate
                                        ,pr_vldperda     OUT NUMBER                    --> Valor calculado da perda
                                        ,pr_txaplica     OUT NUMBER                    --> Taxa aplicada sob o emprestimo
                                        ,pr_des_reto     OUT VARCHAR2                  --> OK ou NOK
                                        ,pr_tab_erro     OUT GENE0001.typ_tab_erro) AS --> Tabela com erros
  BEGIN
    /* .............................................................................

     Programa: pc_consul_saldo_aplic_rdca30 (Antigo b1wgen0004.i)
     Autora  : Junior.
     Data    : 24/10/2005                     Ultima atualizacao: 25/11/2016

     Dados referentes ao programa:

     Objetivo  : INCLUDE CONSULTA SALDO APLICACAO RDCA30

     Alteracoes: 19/05/2006 - Incluido codigo da cooperativa nas leituras das
                              tabelas (Diego).

                 03/10/2007 - Igualar include b1wgen0004.i com a include
                              aplicacao.i (David/Evandro).

                 30/01/2009 - Incluir programas crps175 e 176 na lista para
                              calculo do saldo (David).

                 04/11/2009 - Incluir parametros de saida para procedure
                              saldo-rdca-resgate (David).

                 22/04/2010 - Incluido programa crps563 para calculo do
                              saldo (Elton).

                 30/08/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                              no destino dos arquivos de log (Elton).

                 28/09/2010 - Melhorar critica 145 (Magui).

                 18/06/2012 - Incluir tratamento para resgate de RDCA menor que
                              R$ 1,00 (Ze).

                 09/01/2013 - Conversão de Progress >> Oracle PLSQL  (Marcos-Supero)

                 18/07/2013 - Ajustes na lista da craplap, para quando encontrar informacao
                              dos historicos 117, 124, 125 e 875 para efetuar um next ao
                              inves de continuar (Marcos-Supero)

                 29/11/2013 - Incluir IMPRES nas condicoes de programas (Marcos-Supero).

                 28/04/2014 - Incluir NVL ao criar CRAPLAP (Petter - Supero).

                 13/08/2014 - Ajuste na chamada da pc_saldo_rdca_resgate para ser enviado
                              o pr_dtmvtolt (Adriano).
                 
                 05/01/2015 - Ajustar o nome das telas e a adicionar o Internet Bank na 
                              segunda validação do inproces (Douglas - Chamado 191876)

                 25/11/2016 - Incluir CRPS005 nas excessoes da procedure - Melhoria 69 
                              (Lucas Ranghetti/Elton)
    .................................................................................... */

    DECLARE
      -- Variaveis para calculo de IR (Com base na Includes/var_faixas_ir.i)
      vr_ttajtlct NUMBER(18,8); --> Total de ajuste IR apurados durante o periodo
      vr_vlrgtper NUMBER(18,8); --> Resgates realizados no periodo
      vr_renrgper NUMBER(18,8); --> Rendimentos resgatados no periodo
      vr_ttpercrg NUMBER(18,1); --> Total do percentual IR resgatado
      vr_trergtaj NUMBER(18,8); --> Total do rendimento resgatado
      vr_flgncalc BOOLEAN;      --> Indicador de percentual IR superior a 99.9
      vr_vlrenrgt NUMBER(18,8); --> Rendimento resgatado periodo
      vr_ajtirrgt NUMBER(18,8); --> IRRF pago do que foi resgatado no periodo
      vr_pcajsren NUMBER(18,2); --> Percentual do resgate sobre o rendimento acumulado
      vr_vlrenreg NUMBER(18,8); --> Valor para calculo do ajuste
      vr_vldajtir NUMBER(18,8); --> Valor do ajuste do ir
      vr_sldrgttt NUMBER(18,8); --> Saldo do resgate total
      vr_vlslajir NUMBER(18,8); --> Saldo utilizado para calculo do ajuste
      vr_vlrenacu NUMBER(18,8); --> Rendimento acumulado para calculo do ajuste
      vr_nrmeses  INTEGER;      --> Auxiliar para contagem de meses da aplicacao
      vr_nrdias   INTEGER;      --> Auxiliar para contagem de dias da aplicacao
      vr_dtiniapl DATE;         --> Data de inicio da aplicacao
      vr_cdhisren craplap.cdhistor%TYPE; --> Historico para o lancamento do rendimento
      vr_cdhisajt craplap.cdhistor%TYPE; --> Historico para o ajuste do rendimento
      vr_perirapl NUMBER(18,2); --> Aliquota para aplicacao de IR
      vr_dtdolote DATE;         --> Data do lote
      vr_nrdolote craplot.nrdolote%TYPE; --> Numero do lote
      vr_cdhistor craplap.cdhistor%TYPE; --> Codigo do historico do lancamento
      vr_flglanca BOOLEAN := FALSE;      --> Indicador de existencia de lancamento
      vr_cdagenci INTEGER := 1;          --> Código da agencia
      vr_cdbccxlt INTEGER := 100;        --> Codigo do caixa
      vr_vlajuste NUMBER(18,2);          --> Valor de ajuste do lancamento RDCA

      -- Ultimo dia do mes anterior
      vr_dtultdia DATE;
      -- Buscar os dados da aplicacao RDCA
      CURSOR cr_craprda IS
        SELECT rda.dtiniper
              ,rda.dtfimper
              ,rda.inaniver
              ,rda.incalmes
              ,rda.qtmesext
              ,rda.vlabcpmf
              ,rda.vlsdrdca
              ,rda.dtmvtolt
              ,rda.rowid
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;
      rw_craprda cr_craprda%ROWTYPE;
      -- Buscar a taxa da RDCA
      CURSOR cr_craptrd(pr_dtiniper DATE) IS
        SELECT trd.rowid
              ,trd.txofidia
              ,trd.txofimes
              ,trd.txprodia
          FROM craptrd trd
         WHERE trd.cdcooper = pr_cdcooper
           AND trd.dtiniper = pr_dtiniper --> Periodo da aplicacao buscado acima
           AND trd.tptaxrda = 1                   --> tipo da taxa RDCA
           AND trd.incarenc = 0                   --> Sem carencia
           AND trd.vlfaixas = 0;                  --> Valor da faixa
      rw_craptrd cr_craptrd%ROWTYPE;

      -- Buscas dados da capa de lote
      CURSOR cr_craplot(pr_dtmvtolt craplot.dtmvtolt%TYPE,
                        pr_cdagenci craplot.cdagenci%TYPE,
                        pr_cdbccxlt craplot.cdbccxlt%TYPE,
                        pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov,
               vlinfocr,
               vlcompcr,
               qtinfoln,
               qtcompln,
               nrseqdig,
               ROWID
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = pr_cdagenci
           AND craplot.cdbccxlt = pr_cdbccxlt
           AND craplot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;


      -- Variaveis auxiliares ao calculo
      vr_txaplica NUMBER(18,8); --> Taxa de aplicacao
      vr_txaplmes NUMBER(18,8); --> Taxa de aplicacao mensal
      vr_dtmvtolt DATE;         --> Data auxiliar de termino
      vr_dtcalcul DATE;         --> Data auxiliar calulo no periodo
      vr_vllan117 NUMBER(18,8); --> Valor acumulado aplicacao
      vr_vlrendim NUMBER(18,8); --> Auxiliar para calculo dos rendimentos da aplicacao
      vr_vlrentot NUMBER(18,8); --> Totalizador dos rendimentos
      vr_vlprovis NUMBER(18,8); --> Acumulador da provisão
      vr_vlabcpmf craprda.vlabcpmf%TYPE; --> Valor abono CPMF
      -- Variaveis para duplicados
      vr_dup_dtcalcul DATE;         --> Data auxiliar para calculo no periodo (duplicado)
      vr_dup_dtmvtolt DATE;         --> Data auxiliar para calculo no periodo (duplicado)
      vr_dup_vlrentot NUMBER(18,8); --> Valor do rendimento total (duplicado)
      vr_sldcaren     NUMBER(18,8); --> Saldo carencia do rendimento

      -- Busca do maior Progress_Recid da CrapLap com o historico e data passada
      -- Isso e necessario para saber se o registro sendo processado atualmente
      -- e o ultimo registro daquela data passada (Simular o LAST do Progress)
      CURSOR cr_craplap_max(pr_dtmvtolt IN craplap.dtmvtolt%TYPE
                           ,pr_lsthistor IN VARCHAR2 DEFAULT ' ') IS --> Lista com codigos de historico a retornar
        SELECT /*+ index (cp1 CRAPLAP##CRAPLAP5) */
               MAX(lap.progress_recid)
          FROM craplap lap
         WHERE lap.cdcooper  = pr_cdcooper
           AND lap.nrdconta  = pr_nrdconta         --> Conta enviada
           AND lap.nraplica  = pr_nraplica         --> Aplicacao enviada
           AND lap.dtrefere  = rw_craprda.dtfimper --> Fim do periodo da aplicacao
           AND lap.dtmvtolt  = pr_dtmvtolt         --> Somente da data passada
           AND ','||pr_lsthistor||',' LIKE ('%,'||lap.cdhistor||',%'); --> Retornar historicos passados na listagem
      vr_progress_recid craplap.progress_recid%TYPE;
      vr_dtmvtolt_lap   craplap.dtmvtolt%TYPE;
      -- Leitura dos lancamentos de resgate da aplicacao
      CURSOR cr_craplap(pr_lsthistor IN VARCHAR2 DEFAULT ' ') IS --> Lista com codigos de historico a retornar
        SELECT /*+ index (cp1 CRAPLAP##CRAPLAP5) */
               lap.cdhistor
              ,lap.vllanmto
              ,lap.dtmvtolt
              ,lap.vlrenreg
              ,lap.pcajsren
              ,lap.rendatdt
              ,lap.vlslajir
              ,lap.aliaplaj
              ,lap.progress_recid
          FROM craplap lap
         WHERE lap.cdcooper  = pr_cdcooper
           AND lap.nrdconta  = pr_nrdconta         --> Conta enviada
           AND lap.nraplica  = pr_nraplica         --> Aplicacao enviada
           AND lap.dtrefere  = rw_craprda.dtfimper --> Fim do periodo da aplicacao
           AND lap.dtmvtolt >= rw_craprda.dtiniper --> Data inicio da aplicacao
           AND lap.dtmvtolt <= vr_dtmvtolt        --> Data calculada
           AND ','||pr_lsthistor||',' LIKE ('%,'||lap.cdhistor||',%') --> Retornar historicos passados na listagem
         ORDER BY lap.dtmvtolt
                 ,lap.progress_recid;
    BEGIN
      -- Buscar os dados da aplicacao RDCA
      OPEN cr_craprda;
      FETCH cr_craprda
       INTO rw_craprda;
      CLOSE cr_craprda;
      -- Chamar rotina que atualiza o vetor vr_faixa_ir_rdca
      -- pois utilizaremos ele nesta rotina
      pc_busca_faixa_ir_rdca(pr_cdcooper => pr_cdcooper);
      -- Inicializar informacoes auxiliares para o calculo
      vr_dtcalcul := rw_craprda.dtiniper;
      vr_vllan117 := 0;
      pr_vlsdrdca := rw_craprda.vlsdrdca;
      vr_vlrentot := 0;
      vr_vlprovis := 0;
      pr_vldperda := 0;
      vr_dtultdia := pr_dtmvtolt - to_char(pr_dtmvtolt,'dd'); --> Ultimo dia do mes anterior
      -- Se existir abono de CPMF
      IF rw_craprda.vlabcpmf > 0 THEN
        -- Utiliza-lo
        vr_vlabcpmf := rw_craprda.vlabcpmf;
      ELSE
        -- Utilizar zero
        vr_vlabcpmf := 0;
      END IF;
      -- Incializar variaveis de IR
      vr_ttajtlct := 0;
      vr_ttpercrg := 0;
      vr_vlrgtper := 0;
      vr_renrgper := 0;
      vr_vlrenrgt := 0;
      vr_trergtaj := 0;
      vr_flgncalc := FALSE;
      vr_ajtirrgt := 0;

      -- Se estivermos processando o Batch e o programa
      -- chamador não estiver na lista abaixo
      IF pr_inproces > 2 AND pr_cdprogra NOT IN('CRPS011','CRPS109','CRPS110','CRPS113','CRPS128'
                                               ,'CRPS175','CRPS176','CRPS168','CRPS140','CRPS169'
                                               ,'CRPS210','CRPS323','CRPS349','CRPS414','CRPS445'
                                               ,'CRPS563','CRPS029','CRPS688','CRPS005','ATENDA'
                                               ,'ANOTA','IMPRES','INTERNETBANK', 'RESGATE','GAROPC') THEN
        -- Buscar a taxa da RDCA
        OPEN cr_craptrd(rw_craprda.dtiniper);
        FETCH cr_craptrd
         INTO rw_craptrd;
        -- Se não encontrar a taxa
        IF cr_craptrd%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE cr_craptrd;
          -- Chamar rotina de gravacao de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 347 --> Critica 347
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Levantar excecao
          RAISE vr_exc_erro;
        END IF;
        -- O processo continuou, entao fechamos o cursor
        CLOSE cr_craptrd;
        -- Guardar a taxa encontrada
        pr_txaplica := rw_craptrd.txofidia;
        -- Se houve taxa oficial diarias
        IF rw_craptrd.txofidia > 0 THEN
          -- Calcular a taxa da aplicacao com base na oficial diaria
          vr_txaplica := rw_craptrd.txofidia / 100;
          vr_txaplmes := rw_craptrd.txofimes;
        -- Se houver taxa projetada
        ELSIF rw_craptrd.txprodia > 0 THEN
          -- Calcular a taxa da aplicacao com base na projetada
          vr_txaplica := rw_craptrd.txprodia / 100;
          vr_txaplmes := 0;
        ELSE
          -- Chamar rotina de gravacao de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 427 --> Critica 427
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Levantar excecao
          RAISE vr_exc_erro;
        END IF;
        -- Atualizar a taxa como calculada
        BEGIN
          UPDATE craptrd trd
             SET trd.incalcul = 1
           WHERE trd.rowid = rw_craptrd.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro 0 com critica montada com o erro do update
            vr_dscritic := 'Erro ao atualizar a CRAPTRD : '||sqlerrm;
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 --> Fixo
                                 ,pr_cdcritic => 0 --> Critica 0 para não buscar do cadastro
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
            -- Levantar excecao
            RAISE vr_exc_erro;
        END;
        -- Buscar a data para o processo conforme o programa chamador
        IF pr_cdprogra = 'CRPS103' THEN -- Mensal
          -- Usar o dia atual + 1
          vr_dtmvtolt := pr_dtmvtolt + 1;
        ELSIF pr_cdprogra = 'CRPS104' THEN -- Aniversario
          -- Atualizar a taxa como 2 - ??? (Documentacao: 0=não e 1=Sim)
          BEGIN
            UPDATE craptrd trd
               SET trd.incalcul = 2
             WHERE trd.rowid = rw_craptrd.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro 0 com critica montada com o erro do update
              vr_dscritic := 'Erro ao atualizar a CRAPTRD : '||sqlerrm;
              gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrsequen => 1 --> Fixo
                                   ,pr_cdcritic => 0 --> Critica 0 para não buscar do cadastro
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
              -- Levantar excecao
              RAISE vr_exc_erro;
          END;
          -- Data para calculo refere o fim do periodo da aplicacao
          vr_dtmvtolt := rw_craprda.dtfimper;
          -- Validar se esta data e util e se não for trazer o proximo dia util
          vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dtmvtolt
                                                    ,pr_tipo     => 'P'     -- valor padrao
                                                    ,pr_feriado  => true    -- valor padrao 
                                                    ,pr_excultdia => true); -- considera 31/12 como util
        ELSIF pr_cdprogra = 'CRPS105' THEN -- Resgate
          -- Usar a data do proximo movimento
          vr_dtmvtolt := pr_dtmvtopr;
        ELSIF pr_cdprogra IN('CRPS117','CRPS135','CRPS431') THEN -- Resgate para o dia OU Unificacao
          -- Usar a data corrente
          vr_dtmvtolt := pr_dtmvtolt;
        ELSE -- Outros programas não pode ser processados no Batch
          -- Gerar erro 145 com descricao montada
          vr_dscritic := 'batch parte taxas-b1wgen0004.i-'||pr_cdprogra;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 145 --> Critica 145
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Levantar excecao
          RAISE vr_exc_erro;
        END IF;
      ELSE --> No processo On-Line
        -- Buscar a taxa da RDCA
        OPEN cr_craptrd(rw_craprda.dtiniper);
        FETCH cr_craptrd
         INTO rw_craptrd;
        -- Se não encontrar a taxa
        IF cr_craptrd%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE cr_craptrd;
          -- Chamar rotina de gravacao de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 347 --> Critica 347
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Levantar excecao
          RAISE vr_exc_erro;
        END IF;
        -- O processo continuou, entao fechamos o cursor
        CLOSE cr_craptrd;
        -- Guardar a taxa encontrada
        pr_txaplica := rw_craptrd.txofidia;
        -- Se houve taxa oficial diarias
        IF rw_craptrd.txofidia > 0 THEN
          -- Calcular a taxa da aplicacao com base na oficial diaria
          vr_txaplica := rw_craptrd.txofidia / 100;
          vr_txaplmes := rw_craptrd.txofimes;
        -- Se houver taxa projetada
        ELSIF rw_craptrd.txprodia > 0 THEN
          -- Calcular a taxa da aplicacao com base na projetada
          vr_txaplica := rw_craptrd.txprodia / 100;
          vr_txaplmes := 0;
        ELSE
          -- Chamar rotina de gravacao de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 427 --> Critica 427
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Levantar excecao
          RAISE vr_exc_erro;
        END IF;
        -- Buscar a data para o processo conforme o programa chamador
        IF pr_cdprogra = 'CRPS110' THEN -- Emissão saldo RDCA
          -- Usar o final do periodo da aplicacao
          vr_dtmvtolt := rw_craprda.dtfimper;
        ELSIF pr_cdprogra = 'CRPS210' THEN -- Geracao arquivo sistema auto-atendimento
          -- Usar o proximo dia de movimentacao
          vr_dtmvtolt := pr_dtmvtopr;
        ELSIF pr_cdprogra IN('CRPS117','CRPS431') THEN -- Resgate para o Dia OU nao roda on_line
          -- Usar a data atual
          vr_dtmvtolt := pr_dtmvtolt;
        ELSE
          -- Usar a data atual + 1 dia
          vr_dtmvtolt := pr_dtmvtolt + 1;
        END IF;
      END IF;

      -- Leitura dos lancamentos de resgate da aplicacao (Somente os historicos listados)
      FOR rw_craplap IN cr_craplap(pr_lsthistor => '117,118,124,125,143,492,875') LOOP
        -- De acordo com os historicos
        -- 117 PROVISAO
        -- 124 AJUSTE PROV.
        IF rw_craplap.cdhistor IN(117,124) THEN
          -- Acumular o valor lancado
          vr_vllan117 := vr_vllan117 + rw_craplap.vllanmto;
          -- Terminar o processamento deste
          CONTINUE;
        -- 125 AJUSTE PROV.
        ELSIF rw_craplap.cdhistor IN(125) THEN
          -- Diminuir o valor lancado
          vr_vllan117 := vr_vllan117 - rw_craplap.vllanmto;
          -- Terminar o processamento deste
          CONTINUE;
        -- AJT RGT IR-30
        ELSIF rw_craplap.cdhistor IN(875) THEN
          -- Diminuir do saldo RCA o lancamento
          pr_vlsdrdca := pr_vlsdrdca - rw_craplap.vllanmto;
          -- Acumular no totalizador de ajuste de IR
          vr_ttajtlct := vr_ttajtlct + rw_craplap.vllanmto;
          -- Terminar o processamento deste
          CONTINUE;
        END IF;

        -- Verifica dias uteis e calcula os rendimentos
        LOOP
          -- Validar se a data auxiliar e util e se não for trazer a primeira apos
          vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dtcalcul
                                                    ,pr_tipo     => 'P'     -- valor padrao
                                                    ,pr_feriado  => true    -- valor padrao 
                                                    ,pr_excultdia => true); -- considera 31/12 como util
          -- Continuar enquanto a data auxiliar de calculo for inferior
          -- a data do movimento e houver saldo acumulado da aplicacao RDCA
          EXIT WHEN vr_dtcalcul >= rw_craplap.dtmvtolt OR pr_vlsdrdca <= 0;
          -- Acumular os rendimentos com base no saldo RCA * taxa
          vr_vlrendim := TRUNC((pr_vlsdrdca * vr_txaplica),8);
          -- Acumular no saldo RCA o rendimento calculado
          pr_vlsdrdca := pr_vlsdrdca + vr_vlrendim;
          -- Acumular a variavel de rendimento total
          vr_vlrentot := vr_vlrentot + vr_vlrendim;
          -- Se o dia auxiliar for anterior ou igual ao ultimo dia do mes anterior
          IF vr_dtcalcul <= vr_dtultdia THEN
            -- Acumular o rendimento na provisão
            vr_vlprovis := vr_vlprovis + vr_vlrendim;
          END IF;
          -- Incrementar mais um dia na data auxiliar para processar o proximo dia
          vr_dtcalcul := vr_dtcalcul + 1;
        END LOOP; --> Fim da do calculos nos dias uteis
        -- Diminuir do saldo da aplicacao o lancamento atual
        pr_vlsdrdca := pr_vlsdrdca - rw_craplap.vllanmto;
        -- Se o saldo ficou abaixo de zero
        -- e estamos ON-Line OU no programa crps104
        IF pr_vlsdrdca < 0 AND (pr_cdprogra = 'CRPS104' OR pr_inproces < 3) THEN
          -- Acumular a perda
          pr_vldperda := pr_vldperda + (pr_vlsdrdca*-1);
          -- Zerar o saldo
          pr_vlsdrdca := 0;
        END IF;

      END LOOP;

      -- Incializar controle de data da LAP para quebra
      vr_dtmvtolt_lap := to_date('01/01/1900','dd/mm/yyyy');
      -- Leitura novamente para pegar os ajustes de IR devidos
      FOR rw_craplap IN cr_craplap(pr_lsthistor => '118,492') LOOP
        -- Para cada mudanca de data (Isto e interessante para não efetuar a busca abaixo a cada registro)
        IF vr_dtmvtolt_lap <> rw_craplap.dtmvtolt THEN
          -- Guardar esta data para o proximo teste
          vr_dtmvtolt_lap := rw_craplap.dtmvtolt;
          -- Guardar qual o ultimo registro com a mesma data deste
          -- para fazer o mesmo teste que o Progress faz com o comando LAST
          OPEN cr_craplap_max(pr_dtmvtolt => rw_craplap.dtmvtolt --> Data atual
                             ,pr_lsthistor => '118,492');        --> Lista com codigos de historico a retornar
          FETCH cr_craplap_max
           INTO vr_progress_recid;
          CLOSE cr_craplap_max;
        END IF;
        -- Acumular o lancamento no totalizador de resgates
        vr_vlrgtper := vr_vlrgtper + rw_craplap.vllanmto;
        -- Acumular o lancamento de rendimento
        vr_renrgper := vr_renrgper + rw_craplap.vlrenreg;
        -- Acumular o percentual resgatado
        vr_ttpercrg := vr_ttpercrg + rw_craplap.pcajsren;
        -- Se este registro for o ultimo desta data e o total percentual IR resgatado >= 99.9
        IF rw_craplap.progress_recid = vr_progress_recid AND vr_ttpercrg > 99.9 THEN
          -- Diminuir do Rendimento resgatado no periodo o total do rendimento resgatado
          vr_vlrenrgt := rw_craplap.rendatdt - vr_trergtaj;
        ELSE
          -- Se houver saldo ajuste IR
          IF rw_craplap.vlslajir <> 0 THEN
            -- Rendimento resgatado acumula o lancamento * dias rend ate data resgate / saldo ajuste IR)
            vr_vlrenrgt := rw_craplap.vllanmto * rw_craplap.rendatdt / rw_craplap.vlslajir;
          ELSE
            -- Rendimento e zerado
            vr_vlrenrgt := 0;
          END IF;
          -- Acumular ao total do rendimento resgatado o rendimento calculado acima
          vr_trergtaj := vr_trergtaj + vr_vlrenrgt;
        END IF;
        -- Acumular IRRF pago do que foi resgatado no periodo
        -- Utilizar a seguinte formula para o calculo:
        -- ( Rendimento Resgatado * Aliq Aplicada Calculo de Ajuste / 100 ) - ( Rendimento Resgatado * Aliquota IR Rdca Faixa 4 / 100 )
        vr_ajtirrgt := vr_ajtirrgt + TRUNC((vr_vlrenrgt * rw_craplap.aliaplaj / 100),2)
                                   - TRUNC((vr_vlrenrgt * vr_faixa_ir_rdca(4).perirtab / 100),2);
        -- Se o percentual total resgatado for superior a 99.9
        IF vr_ttpercrg >= 99.9 THEN
          -- Ativar variavel
          vr_flgncalc := TRUE;
        END IF;
      END LOOP;
      -- Alimenta campos para a rotina duplicada
      vr_trergtaj := 0;
      vr_dup_dtcalcul := vr_dtcalcul;
      -- Se o programa for o CRPS105 - CALCULOS DOS RESGATES DIARIOS
      IF pr_cdprogra = 'CRPS105' THEN
        -- Utilizar a data do proximo dia
        vr_dup_dtmvtolt := pr_dtmvtopr;
      ELSE
        -- Utilizar a data corrente
        vr_dup_dtmvtolt := pr_dtmvtolt;
      END IF;
      pr_dup_vlsdrdca := pr_vlsdrdca;
      vr_dup_vlrentot := vr_vlrentot;
      vr_sldcaren     := pr_vlsdrdca;
      -- Se não foi atingido o percentual limite de rendimento, a
      -- data auxiliar do calculo não chegou na data de movimentacao atual
      -- e se ainda existe saldo na aplicacao RDCA
      IF NOT vr_flgncalc AND vr_dtcalcul < vr_dtmvtolt AND pr_vlsdrdca > 0 THEN
        -- Verifica dias uteis e calcula os rendimentos
        LOOP
          -- Validar se a data auxiliar e util e se não for trazer a primeira apos
          vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dtcalcul
                                                    ,pr_tipo     => 'P'     -- valor padrao
                                                    ,pr_feriado  => true    -- valor padrao 
                                                    ,pr_excultdia => true); -- considera 31/12 como util
          -- Continuar enquanto a data auxiliar de calculo for inferior a
          -- a data auxiliar de termino encontrada acimla
          EXIT WHEN vr_dtcalcul >= vr_dtmvtolt;
          -- Valor do rendimento do dia aplicado sobre a taxa e o saldo RDCA
          vr_vlrendim := TRUNC(pr_vlsdrdca * vr_txaplica,8);
          -- Acumular no saldo da aplicacao do rendimento do dia
          pr_vlsdrdca := pr_vlsdrdca + vr_vlrendim;
          -- Acumular no rendimento total o rendimento do dia
          vr_vlrentot := vr_vlrentot + vr_vlrendim;
          -- Se o dia auxiliar for anterior ou igual ao ultimo dia do mes anterior
          IF vr_dtcalcul <= vr_dtultdia THEN
            -- Acumular como provisão o rendimento
            vr_vlprovis := vr_vlprovis + vr_vlrendim;
          END IF;
          -- Acumular mais um dia a data para a busca do proximo dia
          vr_dtcalcul := vr_dtcalcul + 1;
        END LOOP;
      END IF;
      -- Efetuar a mesma logica acima porem trabalhando com as variaveis da rotina duplicada
      -- Se não foi atingido o percentual limite de rendimento, a
      -- data auxiliar do calculo não chegou na data de movimentacao atual
      -- e se ainda existe saldo na aplicacao RDCA
      IF NOT vr_flgncalc AND vr_dup_dtcalcul < vr_dup_dtmvtolt AND pr_dup_vlsdrdca > 0 THEN
        -- Verifica dias uteis e calcula os rendimentos
        LOOP
          -- Validar se a data auxiliar e util e se não for trazer a primeira apos
          vr_dup_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                        ,pr_dtmvtolt => vr_dup_dtcalcul
                                                        ,pr_tipo     => 'P'     -- valor padrao
                                                        ,pr_feriado  => true    -- valor padrao 
                                                        ,pr_excultdia => true); -- considera 31/12 como util
          -- Continuar enquanto a data auxiliar de calculo for inferior a
          -- a data auxiliar de termino encontrada acimla
          EXIT WHEN vr_dup_dtcalcul >= vr_dup_dtmvtolt;
          -- Valor do rendimento do dia aplicado sobre a taxa e o saldo RDCA
          vr_vlrendim := TRUNC(pr_dup_vlsdrdca * vr_txaplica,8);
          -- Acumular no saldo da aplicacao do rendimento do dia
          pr_dup_vlsdrdca := pr_dup_vlsdrdca + vr_vlrendim;
          -- Acumular no rendimento total o rendimento do dia
          vr_dup_vlrentot := vr_dup_vlrentot + vr_vlrendim;
          -- Acumular mais um dia a data para a busca do proximo dia
          vr_dup_dtcalcul := vr_dup_dtcalcul + 1;
        END LOOP;
      END IF;
      -- Efetuar arredondamento dos valores calculados
      pr_vlsdrdca     := fn_round(pr_vlsdrdca,2);
      vr_vlrentot     := fn_round(vr_vlrentot,2);
      pr_vldperda     := fn_round(pr_vldperda,2);
      vr_vlprovis     := fn_round(vr_vlprovis,2);
      pr_dup_vlsdrdca := fn_round(pr_dup_vlsdrdca,2);
      pr_vlsldapl     := pr_dup_vlsdrdca;
      -- Em caso de processo On-Line, e a aplicacao RDCA encaixa-se em:
      -- a) não completou 1 mes aniversario (inaniver = 0)
      -- b) Data do movimento aplicacao esta no inicio do periodo da aplicacao
      -- c) Data do movimento atual e inferior ao final do periodo da aplicacao
      IF pr_inproces = 1 AND rw_craprda.inaniver = 0
      AND rw_craprda.dtmvtolt = rw_craprda.dtiniper
      AND rw_craprda.dtfimper > pr_dtmvtolt THEN
        -- Saldo para resgate e o valor calculado de carencia
        pr_sldpresg := vr_sldcaren;
      ELSE
        -- Zerar saldo para resgate
        pr_sldpresg := 0;
        -- Calcular saldo para resgate enxergando as novas faixas de
        -- percentual de imposto de renda e o ajuste necessario
        pc_saldo_rdca_resgate(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                             ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                             ,pr_nrdcaixa => pr_nrdcaixa         --> Numero do caixa
                             ,pr_cdprogra => pr_cdprogra         --> Programa chamador /* Projeto 363 - Novo ATM -> estava fixo "INTERNETBANK" */
                             ,pr_nrdconta => pr_nrdconta         --> Conta da aplicacao RDCA
                             ,pr_dtaplica => pr_dtmvtolt         --> Data pada resgate da aplicacao
                             ,pr_nraplica => pr_nraplica         --> Numero da aplicacao RDCA
                             ,pr_vlsldapl => pr_dup_vlsdrdca     --> Saldo da aplicacao
                             ,pr_tpchamad => 1                   --> DA BO
                             ,pr_vlrenper => vr_dup_vlrentot     --> Valor do rendimento no periodo
                             ,pr_pcajsren => vr_pcajsren         --> Percentual do resgate sobre o rendimento acumulado
                             ,pr_vlrenreg => vr_vlrenreg         --> Valor para calculo do ajuste
                             ,pr_vldajtir => vr_vldajtir         --> Valor do ajuste do ir
                             ,pr_sldrgttt => vr_sldrgttt         --> Saldo do resgate total
                             ,pr_vlslajir => vr_vlslajir         --> Saldo utilizado para calculo do ajuste
                             ,pr_vlrenacu => vr_vlrenacu         --> Rendimento acumulado para calculo do ajuste
                             ,pr_nrdmeses => vr_nrmeses          --> Auxiliar para contagem de meses da aplicacao
                             ,pr_nrdedias => vr_nrdias           --> Auxiliar para contagem de dias da aplicacao
                             ,pr_dtiniapl => vr_dtiniapl         --> Data de inicio da aplicacao
                             ,pr_cdhisren => vr_cdhisren         --> Historico para o lancamento do rendimento
                             ,pr_cdhisajt => vr_cdhisajt         --> Historico para o ajuste do rendimento
                             ,pr_perirapl => vr_perirapl         --> Aliquota para aplicacao de IR
                             ,pr_sldpresg => pr_sldpresg         --> Saldo para o resgate
                             ,pr_des_reto => pr_des_reto         --> Indicador de saida com erro (OK/NOK)
                             ,pr_tab_erro => pr_tab_erro);       --> Tabela com erros
        -- Se retornou com erro
        IF pr_des_reto = 'NOK' THEN
          -- Efetuar raise para sair do processo
          RAISE vr_exc_erro;
        END IF;
      END IF;
      -- Se o programa for diferente do crps103 - Resumo mensal das aplicacoes RDCA
      IF pr_cdprogra <> 'CRPS103' THEN
        -- Remover do saldo da aplicacao o rendimento aplicando a aliquota da faixa 4
        pr_vlsdrdca := pr_vlsdrdca - TRUNC((vr_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2);
        -- Efetuar o mesmo calculo para a variavel da rotina duplicada
        pr_dup_vlsdrdca := pr_dup_vlsdrdca - TRUNC((vr_dup_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2);
        -- Se o periodo final da aplicacao for inferior ou igual ao movimento atual
        IF rw_craprda.dtfimper <= pr_dtmvtolt THEN
          -- Remover tambem o abono do CPMF multiplicado pela aliquota 1
          pr_vlsdrdca := pr_vlsdrdca - TRUNC((vr_vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2);
          -- Novamente o mesmo calculo para a rotina duplicada
          pr_dup_vlsdrdca := pr_dup_vlsdrdca - TRUNC((vr_vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2);
        END IF;
      END IF;

      -- Se estivermos processando o Batch e o programa
      -- chamador não estiver na lista abaixo
      IF pr_inproces > 2 AND pr_cdprogra NOT IN('CRPS011','CRPS105','CRPS109','CRPS110','CRPS113','CRPS117',
                        'CRPS128','CRPS175','CRPS176','CRPS168','CRPS135','CRPS431','CRPS140','CRPS169',
                        'CRPS210','CRPS323','CRPS349','CRPS414','CRPS445','CRPS563','CRPS029','CRPS688',
                        'CRPS005','ATENDA','ANOTA','IMPRES','INTERNETBANK', 'RESGATE', 'GAROPC') THEN

        IF pr_cdprogra = 'CRPS103' THEN                     /*  MENSAL  */
          vr_dtdolote := pr_dtmvtolt;
          vr_nrdolote := 8380;
          vr_cdhistor := 117;
          vr_flglanca := TRUE;

          -- Atualiza o indicador como nao calculado no mes no cadastro de aplicacoes RDCA
          BEGIN
            UPDATE craprda
               SET craprda.incalmes = 0
             WHERE ROWID = rw_craprda.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro 0 com critica montada com o erro do update
              vr_dscritic := 'Erro ao atualizar a CRAPRDA : '||sqlerrm;
              gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrsequen => 1 --> Fixo
                                   ,pr_cdcritic => 0 --> Critica 0 para não buscar do cadastro
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
              -- Levantar excecao
              RAISE vr_exc_erro;
          END;

        ELSE
          vr_cdcritic := 145; --> Critica 145-Programa nao cadastrado.
          vr_dscritic := 'batch atualiza craprda-b1wgen0004.i-' ||pr_cdprogra;

          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_nrsequen => 1 --> Fixo
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                ,pr_tab_erro => pr_tab_erro);

          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_nmarqlog     => pr_cdprogra,
                                     pr_ind_tipo_log => 2, -- Erro tratato
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || pr_cdprogra || ' --> '
                                                     || vr_dscritic ||
                                                     ' para esta rotina: APLI0001.pc_consul_saldo_aplic_rdca30');

          -- Levantar excecao
          RAISE vr_exc_erro;
        END IF;

        IF pr_cdprogra = 'CRPS103' THEN
          vr_vlrentot := vr_vlrentot - vr_vlprovis;
        END IF;

        IF vr_vlrentot > 0   AND
           vr_flglanca       THEN

          -- Verifica se existe capa de lote
          OPEN cr_craplot(vr_dtdolote, vr_cdagenci, vr_cdbccxlt, vr_nrdolote);
          FETCH cr_craplot INTO rw_craplot;
          IF cr_craplot%NOTFOUND THEN
            -- Se nao existir cria a capa de lote
            BEGIN
              INSERT INTO craplot
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 tplotmov,
                 cdcooper)
               VALUES
                (vr_dtdolote,
                 vr_cdagenci,
                 vr_cdbccxlt,
                 vr_nrdolote,
                 10,
                 pr_cdcooper)
               RETURNING dtmvtolt,
                         cdagenci,
                         cdbccxlt,
                         nrdolote,
                         tplotmov,
                         vlinfocr,
                         vlcompcr,
                         qtinfoln,
                         qtcompln,
                         nrseqdig,
                         ROWID
                    INTO rw_craplot.dtmvtolt,
                         rw_craplot.cdagenci,
                         rw_craplot.cdbccxlt,
                         rw_craplot.nrdolote,
                         rw_craplot.tplotmov,
                         rw_craplot.vlinfocr,
                         rw_craplot.vlcompcr,
                         rw_craplot.qtinfoln,
                         rw_craplot.qtcompln,
                         rw_craplot.nrseqdig,
                         rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro 0 com critica montada com o erro do insert
                vr_dscritic := 'Erro ao inserir na CRAPLOT : '||sqlerrm;
                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1 --> Fixo
                                     ,pr_cdcritic => 0 --> Critica 0 para não buscar do cadastro
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_tab_erro => pr_tab_erro);
                -- Levantar excecao
                RAISE vr_exc_erro;
            END;
          END IF;
          -- Fecha o cursor de capas de lote
          CLOSE cr_craplot;
          -- Gera um lancamentos de aplicacao RDCA.
          BEGIN
            INSERT INTO craplap
              (dtmvtolt,
               cdagenci,
               cdbccxlt,
               cdoperad,
               nrdolote,
               nrdconta,
               nraplica,
               nrdocmto,
               txaplica,
               txaplmes,
               cdhistor,
               nrseqdig,
               vllanmto,
               dtrefere,
               vlrenacu,
               vlslajir,
               cdcooper)
             VALUES
              (rw_craplot.dtmvtolt,
               rw_craplot.cdagenci,
               rw_craplot.cdbccxlt,
               pr_cdoperad,
               rw_craplot.nrdolote,
               pr_nrdconta,
               pr_nraplica,
               rw_craplot.nrseqdig + 1,
               (NVL(vr_txaplica, 0) * 100),
               NVL(vr_txaplmes, 0),
               vr_cdhistor,
               rw_craplot.nrseqdig + 1,
               vr_vlrentot,
               rw_craprda.dtfimper,
               greatest(trunc(vr_vlrenacu + vr_vlrentot - vr_renrgper - vr_vlrenrgt,2),0),
               trunc(vr_vlslajir + vr_vlrentot - vr_vlrgtper - vr_ttajtlct -
                    (trunc((vr_vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2)) -
                    (trunc((vr_vlrentot * vr_faixa_ir_rdca(4).perirtab /
                      100),2)),2) - vr_ajtirrgt,
               pr_cdcooper);
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro 0 com critica montada com o erro do insert
              vr_dscritic := 'Erro ao inserir na CRAPLAP : '||sqlerrm;
              gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrsequen => 1 --> Fixo
                                   ,pr_cdcritic => 0 --> Critica 0 para não buscar do cadastro
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
              -- Levantar excecao
              RAISE vr_exc_erro;
          END;

          BEGIN
            UPDATE craplot
               SET vlinfocr = vlinfocr + vr_vlrentot,
                   vlcompcr = vlcompcr + vr_vlrentot,
                   qtinfoln = qtinfoln + 1,
                   qtcompln = qtcompln + 1,
                   nrseqdig = nrseqdig + 1
             WHERE ROWID = rw_craplot.rowid
             RETURNING vlinfocr,
                       vlcompcr,
                       qtinfoln,
                       qtcompln,
                       nrseqdig
                  INTO rw_craplot.vlinfocr,
                       rw_craplot.vlcompcr,
                       rw_craplot.qtinfoln,
                       rw_craplot.qtcompln,
                       rw_craplot.nrseqdig;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro 0 com critica montada com o erro do update
              vr_dscritic := 'Erro ao atualizar a CRAPLOT : '||sqlerrm;
              gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrsequen => 1 --> Fixo
                                   ,pr_cdcritic => 0 --> Critica 0 para não buscar do cadastro
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
              -- Levantar excecao
              RAISE vr_exc_erro;
          END;


          IF vr_cdhistor = 116 AND -- RENDIMENTO
             trunc((vr_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2) > 0 THEN

            -- Gera um lancamentos de aplicacao RDCA.
            BEGIN
              INSERT INTO craplap
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 cdoperad,
                 nrdolote,
                 nrdconta,
                 nraplica,
                 nrdocmto,
                 txaplica,
                 txaplmes,
                 cdhistor,
                 nrseqdig,
                 vllanmto,
                 dtrefere,
                 cdcooper)
               VALUES
                (rw_craplot.dtmvtolt,
                 rw_craplot.cdagenci,
                 rw_craplot.cdbccxlt,
                 pr_cdoperad,
                 rw_craplot.nrdolote,
                 pr_nrdconta,
                 pr_nraplica,
                 rw_craplot.nrseqdig + 1,
                 vr_faixa_ir_rdca(4).perirtab,
                 vr_faixa_ir_rdca(4).perirtab,
                 861,
                 rw_craplot.nrseqdig + 1,
                 TRUNC((vr_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2),
                 rw_craprda.dtfimper,
                 pr_cdcooper);
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro 0 com critica montada com o erro do insert
                vr_dscritic := 'Erro ao inserir na CRAPLAP : '||sqlerrm;
                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1 --> Fixo
                                     ,pr_cdcritic => 0 --> Critica 0 para não buscar do cadastro
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_tab_erro => pr_tab_erro);
                -- Levantar excecao
                RAISE vr_exc_erro;
            END;

            -- Atualizar as informacoes no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfocr = vlinfocr + TRUNC((vr_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2),
                     vlcompcr = vlcompcr + TRUNC((vr_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2),
                     qtinfoln = qtinfoln + 1,
                     qtcompln = qtcompln + 1,
                     nrseqdig = nrseqdig + 1
               WHERE ROWID = rw_craplot.rowid
               RETURNING vlinfocr,
                         vlcompcr,
                         qtinfoln,
                         qtcompln,
                         nrseqdig
                    INTO rw_craplot.vlinfocr,
                         rw_craplot.vlcompcr,
                         rw_craplot.qtinfoln,
                         rw_craplot.qtcompln,
                         rw_craplot.nrseqdig;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro 0 com critica montada com o erro do update
                vr_dscritic := 'Erro ao atualizar a CRAPLOT : '||sqlerrm;
                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1 --> Fixo
                                     ,pr_cdcritic => 0 --> Critica 0 para não buscar do cadastro
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_tab_erro => pr_tab_erro);
                -- Levantar excecao
                RAISE vr_exc_erro;
            END;
          END IF;
        END IF;

        IF pr_cdprogra = 'CRPS103' THEN

          vr_vlajuste := vr_vlprovis - vr_vllan117;

          IF vr_vlajuste <> 0   THEN
            -- Verifica se existe capa de lote
            OPEN cr_craplot(vr_dtdolote, vr_cdagenci, vr_cdbccxlt, 8381);
            FETCH cr_craplot INTO rw_craplot;
            IF cr_craplot%NOTFOUND THEN
              -- Se nao existir cria a capa de lote
              BEGIN
                INSERT INTO craplot
                  (dtmvtolt,
                   cdagenci,
                   cdbccxlt,
                   nrdolote,
                   tplotmov,
                   cdcooper)
                 VALUES
                  (vr_dtdolote,
                   vr_cdagenci,
                   vr_cdbccxlt,
                   8381,
                   10,
                   pr_cdcooper)
                 RETURNING dtmvtolt,
                           cdagenci,
                           cdbccxlt,
                           nrdolote,
                           tplotmov,
                           vlinfocr,
                           vlcompcr,
                           qtinfoln,
                           qtcompln,
                           nrseqdig,
                           ROWID
                      INTO rw_craplot.dtmvtolt,
                           rw_craplot.cdagenci,
                           rw_craplot.cdbccxlt,
                           rw_craplot.nrdolote,
                           rw_craplot.tplotmov,
                           rw_craplot.vlinfocr,
                           rw_craplot.vlcompcr,
                           rw_craplot.qtinfoln,
                           rw_craplot.qtcompln,
                           rw_craplot.nrseqdig,
                           rw_craplot.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Gerar erro 0 com critica montada com o erro do insert
                  vr_dscritic := 'Erro ao inserir na CRAPLOT : '||sqlerrm;
                  gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_nrsequen => 1 --> Fixo
                                       ,pr_cdcritic => 0 --> Critica 0 para não buscar do cadastro
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_tab_erro => pr_tab_erro);
                  -- Levantar excecao
                  RAISE vr_exc_erro;
              END;
            END IF;

            -- Gera um lancamentos de aplicacao RDCA.
            BEGIN
              INSERT INTO craplap
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 cdoperad,
                 nrdolote,
                 nrdconta,
                 nraplica,
                 nrdocmto,
                 txaplica,
                 txaplmes,
                 cdhistor,
                 nrseqdig,
                 vllanmto,
                 dtrefere,
                 cdcooper)
               VALUES
                (rw_craplot.dtmvtolt,
                 rw_craplot.cdagenci,
                 rw_craplot.cdbccxlt,
                 pr_cdoperad,
                 rw_craplot.nrdolote,
                 pr_nrdconta,
                 pr_nraplica,
                 rw_craplot.nrseqdig + 1,
                 vr_txaplica * 100,
                 vr_txaplmes,
                 decode(greatest(vr_vlajuste,0),0,125,124),
                 rw_craplot.nrseqdig + 1,
                 abs(vr_vlajuste),
                 rw_craprda.dtfimper,
                 pr_cdcooper);
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro 0 com critica montada com o erro do insert
                vr_dscritic := 'Erro ao inserir na CRAPLAP : '||sqlerrm;
                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1 --> Fixo
                                     ,pr_cdcritic => 0 --> Critica 0 para não buscar do cadastro
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_tab_erro => pr_tab_erro);
                -- Levantar excecao
                RAISE vr_exc_erro;
            END;

            -- Atualizar as informacoes no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfocr = vlinfocr + decode(greatest(vr_vlajuste,0),0,0,abs(vr_vlajuste)),
                     vlcompcr = vlcompcr + decode(greatest(vr_vlajuste,0),0,0,abs(vr_vlajuste)),
                     vlinfodb = vlinfodb + decode(greatest(vr_vlajuste,0),0,abs(vr_vlajuste),0),
                     vlcompdb = vlcompdb + decode(greatest(vr_vlajuste,0),0,abs(vr_vlajuste),0),
                     qtinfoln = qtinfoln + 1,
                     qtcompln = qtcompln + 1,
                     nrseqdig = nrseqdig + 1
               WHERE ROWID = rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro 0 com critica montada com o erro do update
                vr_dscritic := 'Erro ao atualizar a CRAPLOT : '||sqlerrm;
                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1 --> Fixo
                                     ,pr_cdcritic => 0 --> Critica 0 para não buscar do cadastro
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_tab_erro => pr_tab_erro);
                -- Levantar excecao
                RAISE vr_exc_erro;
            END;
          END IF;
        END IF;

      END IF;
      -- Chegou ao final sem problemas
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_consul_saldo_aplic_rdca30 --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;

  END pc_consul_saldo_aplic_rdca30;

  /* Consulta saldo aplicacao RDCA60 (Antiga includes/b1wgen0004a.i) */
  PROCEDURE pc_consul_saldo_aplic_rdca60(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movto atual
                                        ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE --> Data do proximo movimento
                                        ,pr_cdprogra IN crapprg.cdprogra%TYPE --> Programa em execucao
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo da agencia
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                        ,pr_nrdconta IN craprda.nrdconta%TYPE --> Nro da conta da aplicacao RDCA
                                        ,pr_nraplica IN craprda.nraplica%TYPE --> Nro da aplicacao RDCA
                                        ,pr_vlsdrdca OUT NUMBER               --> Saldo da aplicacao
                                        ,pr_sldpresg OUT NUMBER               --> Saldo para resgate
                                        ,pr_des_reto OUT VARCHAR2                  --> OK ou NOK
                                        ,pr_tab_erro OUT GENE0001.typ_tab_erro) AS --> Tabela com erros
  BEGIN
    /* .............................................................................

       Programa: pc_consul_saldo_aplic_rdca60 (Antiga b1wgen0004a.i)
       Autora  : Junior.
       Data    : 31/10/2005                     Ultima atualizacao: 01/02/2013

       Dados referentes ao programa:

       Objetivo  : INCLUDE CONSULTA SALDO APLICACAO RDCA60

       Alteracoes: 19/05/2006 - Incluido codigo da cooperativa na leitura da
                                tabela (Diego).

                   13/11/2006 - Atualizado de acordo com a rotina fontes/rdca2s.i,
                                utilizada para mostrar os saldos no Ayllos (Jr).

                   03/10/2007 - Igualar esta include a includes/rdca2s.i (Evandro).

                   04/11/2009 - Incluir parametros de saida para procedure
                                saldo-rdca-resgate (David).

                   18/06/2012 - Incluir tratamento para resgate de RDCA menor que
                                R$ 1,00 (Ze).

                   01/02/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

    ............................................................................ */
    DECLARE
      -- Buscar os dados da aplicacao RDCA
      CURSOR cr_craprda IS
        SELECT rda.vlsdrdca
              ,rda.dtiniper
              ,rda.dtfimper
              ,rda.inaniver
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;
      rw_craprda cr_craprda%ROWTYPE;
      -- Variaveis para calculo de IR (Com base na Includes/var_faixas_ir.i)
      vr_vlrgtper NUMBER(18,8); --> Resgates realizados no periodo
      vr_renrgper NUMBER(18,8); --> Rendimentos resgatados no periodo
      vr_sldpresg NUMBER(18,8); --> Saldo para resgate
      vr_vlrenper NUMBER(18,8); --> Valor do rendimento no periodo
      vr_pcajsren NUMBER(18,2); --> Percentual do resgate sobre o rendimento acumulado
      vr_vlrenreg NUMBER(18,8); --> Valor para calculo do ajuste
      vr_vldajtir NUMBER(18,8); --> Valor do ajuste do ir
      vr_sldrgttt NUMBER(18,8); --> Saldo do resgate total
      vr_vlslajir NUMBER(18,8); --> Saldo utilizado para calculo do ajuste
      vr_vlrenacu NUMBER(18,8); --> Rendimento acumulado para calculo do ajuste
      vr_nrmeses  INTEGER;      --> Auxiliar para contagem de meses da aplicacao
      vr_nrdias   INTEGER;      --> Auxiliar para contagem de dias da aplicacao
      vr_dtiniapl DATE;         --> Data de inicio da aplicacao
      vr_cdhisren craplap.cdhistor%TYPE; --> Historico para o lancamento do rendimento
      vr_cdhisajt craplap.cdhistor%TYPE; --> Historico para o ajuste do rendimento
      vr_perirapl NUMBER(18,2); --> Aliquota para aplicacao de IR
      vr_sldpresg NUMBER(18,8); --> Saldo para resgate
      -- Variaveis auxiliares para aplicacao
      vr_dtcalcul DATE;         --> Data auxiliar calculo no periodo
      vr_dtrefere DATE;         --> Data auxiliar calculo no periodo
      vr_dtrefant DATE;         --> Data auxiliar calculo no periodo
      vr_vllan178 NUMBER(18,8); --> Valores de lancamento
      -- Leitura dos lancamentos de resgate da aplicacao
      CURSOR cr_craplap(pr_lsthistor IN VARCHAR2 DEFAULT ' ') IS --> Lista com codigos de historico a retornar
        SELECT lap.cdhistor
              ,lap.vllanmto
              ,lap.vlrenreg
          FROM craplap lap
         WHERE lap.cdcooper  = pr_cdcooper
           AND lap.nrdconta  = pr_nrdconta                            --> Conta enviada
           AND lap.nraplica  = pr_nraplica                            --> Aplicacao enviada
           AND lap.dtrefere  = vr_dtrefere                            --> Data fim do periodo aplicacao
           AND lap.dtmvtolt >= vr_dtcalcul                            --> Data base para calculo
           AND lap.dtmvtolt <= pr_dtmvtopr                            --> Data movimento proximo
           AND ','||pr_lsthistor||',' LIKE ('%,'||lap.cdhistor||',%');--> Retornar historicos passados na listagem
      -- Leitura dos lancamentos de resgate da aplicacao
      CURSOR cr_craplap_ult IS
        SELECT lap.dtmvtolt
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta   --> Conta enviada
           AND lap.nraplica = pr_nraplica;  --> Aplicacao enviada
      rw_craplap_ult cr_craplap_ult%ROWTYPE;
    BEGIN
      -- Buscar os dados da aplicacao RDCA
      OPEN cr_craprda;
      FETCH cr_craprda
       INTO rw_craprda;
      CLOSE cr_craprda;
      -- Inicializar variaveis
      vr_vlrgtper := 0;
      vr_renrgper := 0;
      vr_vllan178 := 0;
      pr_vlsdrdca := rw_craprda.vlsdrdca;
      vr_dtcalcul := rw_craprda.dtiniper;
      vr_dtrefere := rw_craprda.dtfimper;
      -- Efetuar leitura dos lancamentos de resgate na aplicacao
      -- CDHISTOR DSHISTOR
      -- --- --------------------------------------------------
      -- 178 RESGATE
      -- 494 RESGATE
      -- 876 AJT RGT IR-60
      FOR rw_craplap IN cr_craplap('178,494,876') LOOP
        -- Acumular o resgate
        vr_vllan178 := vr_vllan178 + rw_craplap.vllanmto;
        -- Se não for o 876
        IF rw_craplap.cdhistor NOT IN(876) THEN
          -- Adicionar resgates
          vr_vlrgtper := vr_vlrgtper + rw_craplap.vllanmto;
          -- Adicionar rendimento resgatado
          vr_renrgper := vr_renrgper + rw_craplap.vlrenreg;
        END IF;
      END LOOP;
      -- Diminuir do saldo os resgates efetuados
      pr_vlsdrdca := pr_vlsdrdca - vr_vllan178;
      -- Se a aplicacao não completou  1 mes aniversario (inaniver = 0)
      --  E a Data do movimento atual e diferente do inicio do periodo da aplicacao
      IF rw_craprda.inaniver = 0 AND pr_dtmvtolt <> rw_craprda.dtiniper THEN
        -- Utilizamos como data anterior, o inicio do periodo
        vr_dtrefant := rw_craprda.dtiniper;
      ELSE
        -- Utilizaremos o final do periodo
        vr_dtrefant := rw_craprda.dtfimper;
      END IF;
      -- Se a aplicacao não completou 1 mes aniversario (inaniver = 0)
      --  E a data anterior for igual ao final do periodo
      IF rw_craprda.inaniver = 0 AND vr_dtrefant = vr_dtrefere THEN
        -- Primeiro mes, utilizamos o valor aplicado
        pr_sldpresg := pr_vlsdrdca;
      ELSE
        -- Zerar saldo para resgate e rendimento
        pr_sldpresg := 0;
        vr_vlrenper := 0;
        -- Calcular saldo para resgate enxergando as novas faixas de
        -- percentual de imposto de renda e o ajuste necessario
        pc_saldo_rdca_resgate(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                             ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                             ,pr_nrdcaixa => pr_nrdcaixa         --> Numero do caixa
                             ,pr_cdprogra => pr_cdprogra         --> Programa chamador /* Projeto 363 - Novo ATM -> estava fixo 'INTERNETBANK' */
                             ,pr_nrdconta => pr_nrdconta         --> Conta da aplicacao RDCA
                             ,pr_dtaplica => pr_dtmvtopr         --> Data para resgate da aplicacao
                             ,pr_nraplica => pr_nraplica         --> Numero da aplicacao RDCA
                             ,pr_vlsldapl => pr_vlsdrdca         --> Saldo da aplicacao
                             ,pr_tpchamad => 1                   --> DA BO
                             ,pr_vlrenper => vr_vlrenper         --> Valor do rendimento no periodo
                             ,pr_pcajsren => vr_pcajsren         --> Percentual do resgate sobre o rendimento acumulado
                             ,pr_vlrenreg => vr_vlrenreg         --> Valor para calculo do ajuste
                             ,pr_vldajtir => vr_vldajtir         --> Valor do ajuste do ir
                             ,pr_sldrgttt => vr_sldrgttt         --> Saldo do resgate total
                             ,pr_vlslajir => vr_vlslajir         --> Saldo utilizado para calculo do ajuste
                             ,pr_vlrenacu => vr_vlrenacu         --> Rendimento acumulado para calculo do ajuste
                             ,pr_nrdmeses => vr_nrmeses          --> Auxiliar para contagem de meses da aplicacao
                             ,pr_nrdedias => vr_nrdias           --> Auxiliar para contagem de dias da aplicacao
                             ,pr_dtiniapl => vr_dtiniapl         --> Data de inicio da aplicacao
                             ,pr_cdhisren => vr_cdhisren         --> Historico para o lancamento do rendimento
                             ,pr_cdhisajt => vr_cdhisajt         --> Historico para o ajuste do rendimento
                             ,pr_perirapl => vr_perirapl         --> Aliquota para aplicacao de IR
                             ,pr_sldpresg => pr_sldpresg         --> Saldo para o resgate
                             ,pr_des_reto => pr_des_reto         --> Indicador de saida com erro (OK/NOK)
                             ,pr_tab_erro => pr_tab_erro);       --> Tabela com erros
        -- Se retornou com erro
        IF pr_des_reto = 'NOK' THEN
          -- Efetuar raise para sair do processo
          RAISE vr_exc_erro;
        END IF;
        -- Somente para os programas abaixo
        IF pr_cdprogra IN('CRPS117','CRPS177','ATENDA') THEN
          -- Se o saldo for menor que 1 real e o saldo for zerado
          IF rw_craprda.vlsdrdca <= 1 AND pr_sldpresg = 0 THEN
            -- Buscar o ultimo lancamento na aplicacao
            OPEN cr_craplap_ult;
            FETCH cr_craplap_ult
             INTO rw_craplap_ult;
            -- Se não encontrar OU Se o lancamento foi no ano anterior
            IF cr_craplap_ult%NOTFOUND OR trunc(rw_craplap_ult.dtmvtolt,'yyyy') <> trunc(pr_dtmvtolt,'yyyy') THEN
              -- Utilizamos o saldo da aplicacao para resgatar
              pr_sldpresg := rw_craprda.vlsdrdca;
            END IF;
            -- Fechar o cursor
            CLOSE cr_craplap_ult;
          END IF;
        END IF;
      END IF;
      -- Chegou ao final sem problemas
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_consul_saldo_aplic_rdca60 --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;

  END pc_consul_saldo_aplic_rdca60;

  /* Rotina de calculo do aniversario e atualizacao de aplicacoes RDCA2 */
  PROCEDURE pc_calc_aniver_rdca2a(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do processo
                                 ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE --> Data do processo
                                 ,pr_nrdconta IN craprda.nrdconta%TYPE --> Nro da conta da aplicacao RDCA
                                 ,pr_nraplica IN craprda.nraplica%TYPE --> Nro da aplicacao RDCA
                                 ,pr_vltotrda IN craprda.vlsdrdca%TYPE --> Saldo total das aplicacoes
                                 ,pr_cdprogra IN crapprg.cdprogra%TYPE --> Programa conectado
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo da agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                 ,pr_des_reto OUT VARCHAR2                  --> OK ou NOK
                                 ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --> Tabela com erros
  BEGIN
    /* .............................................................................

       Programa: pc_calc_aniver_rdca2a (Antigo Includes/rdca2a.i)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Dezembro/96.                    Ultima atualizacao: 04/06/2014

       Dados referentes ao programa:

       Frequencia: Diario (on-line)
       Objetivo  : Rotina de calculo do aniversario do RDCA2 - Deve ser chamada
                   dentro de um FOR EACH ou DO WHILE e com label TRANS_1.

       Alteracoes: 28/01/97 - Alterado para acertar vlsdrdan (quando for o primeiro
                              mes de extrato, deixar com 0) (Deborah).

                   11/04/97 - Alterado para capitalizar as taxas do primeiro
                              aniversario (Edson).

                   11/03/98 - Alterado para tratar taxa especial no periodo
                              de 10/02/98 a 05/03/98 (Deborah).

                   29/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   01/12/1999 - Tratar somente carencia 0 (Deborah).

                   26/04/2002 - Nova regra para pegar a taxa (Margarete).

                   10/12/2003 - Incluir cobranca de IRRF (Margarete).

                   26/01/2004 - Gerar lancamentos do abono e do IR sobre abono
                                na aplicacao (Margarete).

                   02/07/2004 - Zerar saldos do final do mes quando saque
                                total (Margarete).

                   23/09/2004 - Incluido historico 494(CI)(Mirtes)

                   14/12/2004 - Ajustes para tratar das novas aliquotas de
                               IRRF (Margarete).

                  21/01/2005 - IRRF sobre abono CPMF usara maior taxa (Margarete).

                  28/02/2005 - Efetuado acerto gravacao taxa - historico 871(Mirtes)

                  06/05/2005 - Utilizar o indice craplap5 na leitura dos
                               lancamentos (Edson).

                  06/07/2005 - Alimentado campo cdcooper das tabelas craplot e
                               craplap (Diego).

                  03/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                  03/08/2006 - Campo vlslfmes substituido por vlsdextr (Magui).

                  23/08/2006 - Nao atualizar mais craprda.dtsdfmes (Magui).

                  27/07/2007 - Alteracao para melhoria de performance (Evandro).

                  11/07/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                  04/11/2013 - Eliminar tratamento do campo lsaplica (Gabriel).

									04/06/2014 - Ajuste nas leituras da CRAPTRD para utilizar o
															 VLFAIXAS na ordenação da busca (Marcos-Supero)
    ............................................................................. */
    DECLARE
      -- Taxa fixa
      vr_tptaxrda CONSTANT PLS_INTEGER := 3;
      -- Variaveis para gravacao da craplot
      vr_cdagenci CONSTANT PLS_INTEGER := 1;
      vr_cdbccxlt CONSTANT PLS_INTEGER := 100;
      vr_nrdolote CONSTANT PLS_INTEGER := 8381;

      -- Buscar os dados da aplicacao RDCA
      CURSOR cr_craprda IS
        SELECT rda.rowid
              ,rda.vlsdrdca
              ,rda.inaniver
              ,rda.dtmvtolt
              ,rda.dtiniper
              ,rda.dtfimper
              ,rda.qtmesext
              ,rda.dtiniext
              ,rda.dtfimext
              ,rda.dtsdrdan
              ,rda.vlsdrdan
              ,rda.incalmes
              ,rda.insaqtot
              ,rda.dtsaqtot
              ,rda.vlsdextr
              ,rda.dtcalcul
              ,rda.vlabcpmf
              ,rda.vlabonrd
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;
      rw_craprda cr_craprda%ROWTYPE;

      -- Variaveis auxiliares ao calculo da aplicacao
      vr_rd2_vlrentot NUMBER(18,8);
      vr_rd2_vllan178 NUMBER(18,8);
      vr_rd2_vllan180 NUMBER(18,8);
      vr_rd2_vlprovis NUMBER(18,8);
      vr_rd2_dtcalcul DATE;
      vr_rd2_dtrefant DATE;
      vr_rd2_vlsdrdca NUMBER(18,8);
      vr_rd2_vlrendim NUMBER(18,8);
      vr_rd2_dtrefere DATE;
      vr_renrgper     NUMBER(18,8);
      vr_vlrgtper     NUMBER(18,8);
      vr_ttajtlct     NUMBER(18,8);
      vr_rd2_flgentra BOOLEAN;
      vr_rd2_txaplica NUMBER(18,8);
      vr_vlirrdca     craprda.vlsdrdca%TYPE;

      -- Taxas de aplicacao
      vr_pri_txaplica NUMBER(18,6);
      vr_seg_txaplica NUMBER(18,6);
      vr_cap_txaplica NUMBER(18,6);

      -- Leitura dos lancamentos de resgate da aplicacao
      CURSOR cr_craplap(pr_lsthistor IN VARCHAR2 DEFAULT ' ') IS --> Lista com codigos de historico a retornar
        SELECT SUM(lap.vllanmto) vllanmto
              ,SUM(lap.vlrenreg) vlrenreg
          FROM craplap lap
         WHERE lap.cdcooper  = pr_cdcooper
           AND lap.nrdconta  = pr_nrdconta                            --> Conta enviada
           AND lap.nraplica  = pr_nraplica                            --> Aplicacao enviada
           AND lap.dtrefere  IN(vr_rd2_dtrefant,vr_rd2_dtrefere)      --> Data de referencia anterior OU Data fim do periodo aplicacao
           AND lap.dtmvtolt >= vr_rd2_dtcalcul                        --> Data base para calculo
           AND lap.dtmvtolt <= pr_dtmvtolt                            --> Data movimento atual
           AND ','||pr_lsthistor||',' LIKE ('%,'||lap.cdhistor||',%');--> Retornar historicos passados na listagem

      -- Variaveis para o calculo dos rendimentos (IR)
      vr_vlrenper NUMBER(18,8) := 0; --> Valor do rendimento no periodo
      vr_sldpresg NUMBER(18,8) := 0; --> Saldo para resgate
      vr_pcajsren NUMBER(18,2); --> Percentual do resgate sobre o rendimento acumulado
      vr_vlrenreg NUMBER(18,8); --> Valor para calculo do ajuste
      vr_vldajtir NUMBER(18,8); --> Valor do ajuste do ir
      vr_sldrgttt NUMBER(18,8); --> Saldo do resgate total
      vr_vlslajir NUMBER(18,8); --> Saldo utilizado para calculo do ajuste
      vr_vlrenacu NUMBER(18,8); --> Rendimento acumulado para calculo do ajuste
      vr_nrmeses  INTEGER;      --> Auxiliar para contagem de meses da aplicacao
      vr_nrdias   INTEGER;      --> Auxiliar para contagem de dias da aplicacao
      vr_dtiniapl DATE;         --> Data de inicio da aplicacao
      vr_cdhisren craplap.cdhistor%TYPE; --> Historico para o lancamento do rendimento
      vr_cdhisajt craplap.cdhistor%TYPE; --> Historico para o ajuste do rendimento
      vr_perirapl NUMBER(18,2); --> Aliquota para aplicacao de IR

      -- Busca Taxa a ser aplicada conforme a faixa
      CURSOR cr_craptrd(pr_dtiniper DATE) IS
        SELECT trd.rowid
              ,trd.txofimes
              ,trd.incalcul
          FROM craptrd trd
         WHERE cdcooper = pr_cdcooper
           AND dtiniper = pr_dtiniper
           AND tptaxrda = vr_tptaxrda
           AND incarenc = 0 -- Sem carencia
           AND vlfaixas <= pr_vltotrda
         ORDER BY trd.vlfaixas DESC;
      rw_craptrd cr_craptrd%ROWTYPE;

      -- Buscar as capas de lote para a cooperativa e data atual
      CURSOR cr_craplot IS
        SELECT lot.cdagenci
              ,lot.cdbccxlt
              ,lot.nrdolote
              ,lot.tplotmov
              ,lot.nrseqdig
              ,lot.vlinfodb
              ,lot.vlcompdb
              ,lot.qtinfoln
              ,lot.qtcompln
              ,lot.vlinfocr
              ,lot.vlcompcr
              ,lot.dtmvtolt
              ,rowid
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtopr
           AND lot.cdagenci = vr_cdagenci
           AND lot.cdbccxlt = vr_cdbccxlt
           AND lot.nrdolote = vr_nrdolote;
      -- Criaremos um registro para cada tipo de lote utilizado
      rw_craplot cr_craplot%ROWTYPE; --> Lancamento de juros para o emprestimo

      -- Subrotina para checar a existencia de lote cfme tipo passado
      PROCEDURE pc_cria_craplot(pr_dscritic  OUT VARCHAR2) IS
      BEGIN
        -- Buscar as capas de lote cfme lote passado
        OPEN cr_craplot;
        FETCH cr_craplot
         INTO rw_craplot; --> Rowtype passado
        -- Se não tiver encontrado
        IF cr_craplot%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craplot;
          -- Efetuar a insercao de um novo registro
          BEGIN
            INSERT INTO craplot(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,tplotmov
                               ,nrseqdig
                               ,vlinfodb
                               ,vlcompdb
                               ,qtinfoln
                               ,qtcompln
                               ,vlinfocr
                               ,vlcompcr
                               ,tpdmoeda
                               ,cdhistor)
                         VALUES(pr_cdcooper
                               ,pr_dtmvtopr
                               ,vr_cdagenci
                               ,vr_cdbccxlt
                               ,vr_nrdolote --> Cfme enviado
                               ,10          --> Fixo
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,1
                               ,0)
                       RETURNING dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,nrseqdig
                                ,rowid
                            INTO rw_craplot.dtmvtolt
                                ,rw_craplot.cdagenci
                                ,rw_craplot.cdbccxlt
                                ,rw_craplot.nrdolote
                                ,rw_craplot.tplotmov
                                ,rw_craplot.nrseqdig
                                ,rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              pr_dscritic := 'Erro ao inserir capas de lotes (craplot), lote: '||vr_nrdolote||'. Detalhes: '||sqlerrm;
          END;
        ELSE
          -- apenas fechar o cursor
          CLOSE cr_craplot;
        END IF;
      END;
    BEGIN
      -- Buscar os dados da aplicacao RDCA
      OPEN cr_craprda;
      FETCH cr_craprda
       INTO rw_craprda;
      CLOSE cr_craprda;
    -- Garantir a carga das faixas de IR
      APLI0001.pc_busca_faixa_ir_rdca(pr_cdcooper => pr_cdcooper);
      -- Inicializar as variaveis para o calculo
      vr_vlrgtper     := 0;
      vr_ttajtlct     := 0;
      vr_renrgper     := 0;
      vr_rd2_vlrendim := 0;
      vr_rd2_vllan178 := 0;
      vr_rd2_vllan180 := 0;
      vr_rd2_vlrentot := 0;
      vr_rd2_vlprovis := 0;
      vr_pri_txaplica := 0;
      vr_seg_txaplica := 0;
      vr_cap_txaplica := 0;
      vr_vlirrdca     := 0;
      vr_rd2_vlsdrdca := rw_craprda.vlsdrdca;
      vr_rd2_dtrefere := rw_craprda.dtfimper;
      -- Se a aplicacao não completou um mes
      IF rw_craprda.inaniver = 0 THEN
        -- Data para calculo recebera a data de movimentacao da aplicacao
        vr_rd2_dtcalcul := rw_craprda.dtmvtolt;
        -- Se a data de movimentacao for diferente do inicio da aplicacao
        IF rw_craprda.dtmvtolt <> rw_craprda.dtiniper THEN
          -- Utilizar o inicio da aplicacao para a data referencia anterior
          vr_rd2_dtrefant := rw_craprda.dtiniper;
        ELSE
          -- Data referencia anterior recebera o fim do periodo da aplicacao
          vr_rd2_dtrefant := rw_craprda.dtfimper;
        END IF;
      ELSE
        -- Data para calculo recebera o inicio da aplicacao
        vr_rd2_dtcalcul := rw_craprda.dtiniper;
        -- Data referencia anterior recebera o fim do periodo da aplicacao
        vr_rd2_dtrefant := rw_craprda.dtfimper;
      END IF;
      -- Verifica se deve lancar apenas a provisao
      -- Se estiver no primeiro mes
      IF rw_craprda.inaniver = 0 AND vr_rd2_dtrefant = vr_rd2_dtrefere THEN
        -- Primeiro Mes
        vr_rd2_flgentra := FALSE;
      ELSE
        -- Segundo Mes
        vr_rd2_flgentra := TRUE;
      END IF;

      -- Leitura dos lancamentos --> 182 Ajuste Provisao
      FOR rw_craplap IN cr_craplap('182') LOOP
        -- Decrementar da 180
        vr_rd2_vllan180 := vr_rd2_vllan180 - NVL(rw_craplap.vllanmto,0);
      END LOOP;
      -- Leitura dos lancamentos -- 180 - Provisao ou 181 - Ajuste Provisao +
      FOR rw_craplap IN cr_craplap('180,181') LOOP
        -- Incrementar na 180
        vr_rd2_vllan180 := vr_rd2_vllan180 + NVL(rw_craplap.vllanmto,0);
      END LOOP;
      -- Leitura dos ajustes de IR no resfte - 876
      FOR rw_craplap IN cr_craplap('876') LOOP
        -- Incrementar na 178
        vr_rd2_vllan178 := vr_rd2_vllan178 + NVL(rw_craplap.vllanmto,0);
        -- Acumular ajuste
        vr_ttajtlct := vr_ttajtlct + NVL(rw_craplap.vllanmto,0);
      END LOOP;
      -- Leitura dos lancamentos de resgate
      FOR rw_craplap IN cr_craplap('178,494') LOOP
        -- Incrementar na 178
        vr_rd2_vllan178 := vr_rd2_vllan178 + NVL(rw_craplap.vllanmto,0);
        -- Acumular resgates
        vr_vlrgtper := vr_vlrgtper + NVL(rw_craplap.vllanmto,0);
        vr_renrgper := vr_renrgper + NVL(rw_craplap.vlrenreg,0);
      END LOOP;
      -- Acumular o saldo da RDCA2 diminuindo os lancamentos 178
      vr_rd2_vlsdrdca := vr_rd2_vlsdrdca - vr_rd2_vllan178;

      -- Calcular saldo para resgate enxergando as novas faixas
      -- de percentual de imposto de renda e o ajuste necessario
      pc_saldo_rdca_resgate(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                           ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                           ,pr_nrdcaixa => pr_nrdcaixa         --> Numero do caixa
                           ,pr_cdprogra => pr_cdprogra         --> Programa chamador
                           ,pr_nrdconta => pr_nrdconta         --> Conta da aplicacao RDCA
                           ,pr_dtaplica => pr_dtmvtolt         --> Data para resgate da aplicacao
                           ,pr_nraplica => pr_nraplica         --> Numero da aplicacao RDCA
                           ,pr_vlsldapl => vr_rd2_vlsdrdca     --> Saldo da aplicacao
                           ,pr_tpchamad => 2                   --> Do Fonte
                           ,pr_vlrenper => vr_vlrenper         --> Valor do rendimento no periodo
                           ,pr_pcajsren => vr_pcajsren         --> Percentual do resgate sobre o rendimento acumulado
                           ,pr_vlrenreg => vr_vlrenreg         --> Valor para calculo do ajuste
                           ,pr_vldajtir => vr_vldajtir         --> Valor do ajuste do ir
                           ,pr_sldrgttt => vr_sldrgttt         --> Saldo do resgate total
                           ,pr_vlslajir => vr_vlslajir         --> Saldo utilizado para calculo do ajuste
                           ,pr_vlrenacu => vr_vlrenacu         --> Rendimento acumulado para calculo do ajuste
                           ,pr_nrdmeses => vr_nrmeses          --> Auxiliar para contagem de meses da aplicacao
                           ,pr_nrdedias => vr_nrdias           --> Auxiliar para contagem de dias da aplicacao
                           ,pr_dtiniapl => vr_dtiniapl         --> Data de inicio da aplicacao
                           ,pr_cdhisren => vr_cdhisren         --> Historico para o lancamento do rendimento
                           ,pr_cdhisajt => vr_cdhisajt         --> Historico para o ajuste do rendimento
                           ,pr_perirapl => vr_perirapl         --> Aliquota para aplicacao de IR
                           ,pr_sldpresg => vr_sldpresg         --> Saldo para o resgate
                           ,pr_des_reto => pr_des_reto         --> Indicador de saida com erro (OK/NOK)
                           ,pr_tab_erro => pr_tab_erro);       --> Tabela com erros
      -- Se retornou com erro
      IF pr_des_reto = 'NOK' THEN
        -- Efetuar raise para sair do processo
        RAISE vr_exc_erro;
      END IF;

      -- Para recalculo no 1o mes
      IF rw_craprda.inaniver = 0 AND vr_rd2_flgentra THEN
        -- Busca taxa a ser aplicada conforme a faixa com base na data da aplicacao
        rw_craptrd := NULL;
        OPEN cr_craptrd(pr_dtiniper => rw_craprda.dtmvtolt);
        FETCH cr_craptrd
         INTO rw_craptrd;
        -- Se não encontrar
        IF cr_craptrd%NOTFOUND THEN
          -- Fechar e gerar critica 347
          CLOSE cr_craptrd;
          vr_cdcritic := 347;
          vr_dscritic := gene0001.fn_busca_critica(347) || ' DIA ' || to_char(rw_craprda.dtmvtolt,'dd/mm/yyyy');
          -- Levantar excecao
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar
          CLOSE cr_craptrd;
        END IF;
        -- Se a taxa for superior a zero
        IF rw_craptrd.txofimes > 0 THEN
          -- Atualizar a taxa como calculada
          BEGIN
            UPDATE craptrd
               SET incalcul = 2
             WHERE ROWID = rw_craptrd.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar a taxa (CRAPTRD), detalhes: '||sqlerrm;
             -- Levantar excecao
             RAISE vr_exc_erro;
          END;
          -- Guardar o valor da taxa
          vr_rd2_txaplica := rw_craptrd.txofimes / 100;
        ELSE
          -- Gerar critica 427
          vr_cdcritic := 427;
          vr_dscritic := gene0001.fn_busca_critica(427);
          -- Levantar excecao
          RAISE vr_exc_erro;
        END IF;
        -- Recalculo do rendimento
        vr_rd2_vlrendim := TRUNC(vr_rd2_vlsdrdca * vr_rd2_txaplica,8);
        vr_rd2_vlsdrdca := vr_rd2_vlsdrdca + vr_rd2_vlrendim;
        vr_pri_txaplica := vr_rd2_txaplica;
        -- Arredondamento dos valores calculados
        vr_rd2_vlsdrdca := ROUND(vr_rd2_vlsdrdca,2);
        vr_rd2_vlrendim := ROUND(vr_rd2_vlrendim,2);
        vr_rd2_vlrentot := vr_rd2_vlrendim;
      END IF;

      -- Busca taxa a ser aplicada conforme a faixa com base na data de inicio do periodo
      rw_craptrd := NULL;
      OPEN cr_craptrd(pr_dtiniper => rw_craprda.dtiniper);
      FETCH cr_craptrd
       INTO rw_craptrd;
      -- Se não encontrar
      IF cr_craptrd%NOTFOUND THEN
        -- Fechar e gerar critica 347
        CLOSE cr_craptrd;
        vr_cdcritic := 347;
        vr_dscritic := gene0001.fn_busca_critica(347) || ' DIA ' || to_char(rw_craprda.dtiniper,'dd/mm/yyyy');
        -- Levantar excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar
        CLOSE cr_craptrd;
      END IF;
      -- Se a taxa for superior a zero
      IF rw_craptrd.txofimes > 0 THEN
        -- Atualizar a taxa como calculada
        BEGIN
          UPDATE craptrd
             SET incalcul = 2
           WHERE ROWID = rw_craptrd.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a taxa (CRAPTRD), detalhes: '||sqlerrm;
           -- Levantar excecao
           RAISE vr_exc_erro;
        END;
        -- Guardar o valor da taxa
        vr_rd2_txaplica := rw_craptrd.txofimes / 100;
      ELSE
        -- Gerar critica 427
        vr_cdcritic := 427;
        vr_dscritic := gene0001.fn_busca_critica(427);
        -- Levantar excecao
        RAISE vr_exc_erro;
      END IF;

      -- Calculo do rendimento
      vr_rd2_vlrendim := TRUNC(vr_rd2_vlsdrdca * vr_rd2_txaplica,8);
      vr_rd2_vlsdrdca := vr_rd2_vlsdrdca + vr_rd2_vlrendim;
      vr_seg_txaplica := vr_rd2_txaplica;
      -- Efetuar arredondamento dos valores calculados
      vr_rd2_vlsdrdca := ROUND(vr_rd2_vlsdrdca,2);
      vr_rd2_vlrendim := ROUND(vr_rd2_vlrendim,2);
      -- Acumular rendimento total
      vr_rd2_vlrentot := vr_rd2_vlrentot + vr_rd2_vlrendim;
      -- Acumular IR da aplicacao
      vr_vlirrdca := vr_vlirrdca + TRUNC((vr_rd2_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2);
      -- Calcular taxa de aplicacao e capitalizacao
      vr_rd2_txaplica := vr_rd2_txaplica * 100;
      vr_cap_txaplica := vr_rd2_txaplica;
      -- Incrementar quantidades de meses para emissão do extrado
      rw_craprda.qtmesext := rw_craprda.qtmesext + 1;

      -- Se a quantidade de meses para emissão do extrato for 4
      IF rw_craprda.qtmesext = 4 THEN
        -- Reiniciar a quantidade
        rw_craprda.qtmesext := 1;
      END IF;

      -- Se a quantidade estiver reiniciada
      IF rw_craprda.qtmesext = 1 THEN
        -- Data inicial do extrato recebe a final anterior
        rw_craprda.dtiniext := rw_craprda.dtfimext;
        -- DAta ref do saldo anterior recebe o periodo inicial
        rw_craprda.dtsdrdan := rw_craprda.dtiniper;
        -- Se a data inicial do extrato for diferente da atual
        IF rw_craprda.dtiniext <> rw_craprda.dtmvtolt THEN
          -- Saldo anterior recebe o saldo da Rdca
          rw_craprda.vlsdrdan := rw_craprda.vlsdrdca;
        END IF;
      END IF;

      -- Se o saldo calculado estiver zerado
      IF vr_rd2_vlsdrdca = 0 THEN
        -- Considerar meses sem extrato igual a 3
        rw_craprda.qtmesext := 3;
      END IF;

      -- Atualizar flag de calculado no mes
      rw_craprda.incalmes := 1;
      -- Considerar como data final do extrato e data inicial do periodo a data final do periodo anterior
      rw_craprda.dtfimext := rw_craprda.dtfimper;
      rw_craprda.dtiniper := rw_craprda.dtfimper;

      -- Calcular nova data final do periodo
      BEGIN
        -- Primeira tentativa apenas acumula +1 mes
        -- e quanto dezembro usa fixo Janeiro
        IF to_char(rw_craprda.dtfimper,'mm') = 12 THEN
          rw_craprda.dtfimper := to_date(to_char(rw_craprda.dtfimper,'dd')||'/01/'||(to_char(rw_craprda.dtfimper,'yyyy')+1),'dd/mm/yyyy');
        ELSE
          rw_craprda.dtfimper := to_date(to_char(rw_craprda.dtfimper,'dd')||'/'||(to_char(rw_craprda.dtfimper,'MM')+1)||'/'||to_char(rw_craprda.dtfimper,'yyyy'),'dd/mm/yyyy');
        END IF;
      EXCEPTION
        -- Em qualquer erro encontrado
        WHEN OTHERS THEN
          -- Usar dia 1 dali a +2 meses e quando novembro usa 01/janeiro e quando dezembro usa 01/fevereiro
          IF to_char(rw_craprda.dtfimper,'mm') = 11 THEN
            rw_craprda.dtfimper := to_date('01/01/'||(to_char(rw_craprda.dtfimper,'yyyy')+1),'dd/mm/yyyy');
          ELSIF to_char(rw_craprda.dtfimper,'mm') = 12 THEN
            rw_craprda.dtfimper := to_date('01/02/'||(to_char(rw_craprda.dtfimper,'yyyy')+1),'dd/mm/yyyy');
          ELSE
            rw_craprda.dtfimper := to_date('01/'||(to_char(rw_craprda.dtfimper,'MM')+2)||'/'||to_char(rw_craprda.dtfimper,'yyyy'),'dd/mm/yyyy');
          END IF;
      END;

      -- Se ainda não gerou aniversario e periodo for inferior a 50 dias
      IF rw_craprda.inaniver = 0 AND rw_craprda.dtiniper - rw_craprda.dtmvtolt > 50 THEN
        -- Indica que houve aniversario
        rw_craprda.inaniver := 1;
      END IF;

      -- Se ja houve aniversario
      IF rw_craprda.inaniver = 1 THEN
        -- Atualizar saldo diminuindo o IR
        rw_craprda.vlsdrdca := vr_rd2_vlsdrdca - nvl(vr_vlirrdca,0);
      END IF;

      -- Se o saldo estiver zerado
      IF vr_rd2_vlsdrdca = 0 THEN
        -- Indicar que houve saque total
        rw_craprda.insaqtot := 1;
        rw_craprda.dtsaqtot := pr_dtmvtolt;
      END IF;

      -- Se a aplicacao tiver tido o saque total
      IF rw_craprda.insaqtot = 1 THEN
        -- Zerar valor do extrato
        rw_craprda.vlsdextr := 0;
      END IF;

      -- Atualizar data de calculo com a proxima data util
      rw_craprda.dtcalcul := pr_dtmvtopr;

      -- Se data final calculada for do mesmo mes que a proxima data util
      IF trunc(rw_craprda.dtfimper,'mm') = trunc(pr_dtmvtopr,'mm') THEN
        -- Inidica que o calculo no mes atual nao ocorreu
        rw_craprda.incalmes := 0;
      END IF;

      -- Se ha rendimento e não e no primeiro mes
      IF vr_rd2_vlrentot > 0 AND vr_rd2_flgentra THEN
        -- Se ainda não foi buscado lote
        IF rw_craplot.rowid IS NULL THEN
          -- Chamar rotina para busca-lo, e se não encontrar, ira crialo
          pc_cria_craplot(pr_dscritic  => vr_dscritic);
          -- Se houve retorno de erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levantar excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        -- Capitaliza taxas do primeiro aniversario
        IF vr_pri_txaplica > 0 THEN
          vr_cap_txaplica := TRUNC((((1 + vr_pri_txaplica) * (1 + vr_seg_txaplica)) - 1) * 100,6);
        END IF;
        -- Cria lancamento da capitalizacao na aplicacao
        BEGIN
          INSERT INTO craplap(cdcooper
                             ,dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,nrdconta
                             ,nraplica
                             ,nrdocmto
                             ,txaplica
                             ,txaplmes
                             ,cdhistor
                             ,nrseqdig
                             ,vllanmto
                             ,dtrefere
                             ,vlsdlsap
                             ,vlrenacu
                             ,vlslajir)
                       VALUES(pr_cdcooper
                             ,rw_craplot.dtmvtolt
                             ,rw_craplot.cdagenci
                             ,rw_craplot.cdbccxlt
                             ,rw_craplot.nrdolote
                             ,pr_nrdconta
                             ,pr_nraplica
                             ,rw_craplot.nrseqdig + 1
                             ,vr_cap_txaplica
                             ,vr_cap_txaplica
                             ,179 -- Rendimento
                             ,rw_craplot.nrseqdig + 1
                             ,vr_rd2_vlrentot
                             ,vr_rd2_dtrefere
                             ,pr_vltotrda
                             ,TRUNC((vr_vlrenacu + vr_rd2_vlrentot - vr_renrgper),2)
                             ,TRUNC(vr_vlslajir + vr_rd2_vlrentot - vr_vlrgtper - vr_ttajtlct - vr_vlirrdca - (TRUNC((rw_craprda.vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2)),2));
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar lancamento da capitalizacao na aplicacao (CRAPLAP) '
                        || '- Conta:'||pr_nrdconta || ' Aplicacao:'||pr_nraplica
                        || '. Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        -- Atualizar as informacoes no lote utilizado
        BEGIN
          UPDATE craplot
             SET vlinfocr = vlinfocr + vr_rd2_vlrentot
                ,vlcompcr = vlinfocr + vr_rd2_vlrentot
                ,qtinfoln = qtinfoln + 1
                ,qtcompln = qtcompln + 1
                ,nrseqdig = nrseqdig + 1
           WHERE rowid = rw_craplot.rowid
           RETURNING nrseqdig INTO rw_craplot.nrseqdig; -- Atualizamos a sequencia no rowtype
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro e fazer rollback
            vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot.nrdolote||'. Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        -- Se houver ir sobre o rendimento
        IF vr_vlirrdca > 0 THEN
          -- Lancar debito od IR
          BEGIN
            INSERT INTO craplap(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,nrdconta
                               ,nraplica
                               ,nrdocmto
                               ,txaplica
                               ,txaplmes
                               ,cdhistor
                               ,nrseqdig
                               ,vllanmto
                               ,dtrefere
                               ,vlrenacu
                               ,vlslajir)
                         VALUES(pr_cdcooper
                               ,rw_craplot.dtmvtolt
                               ,rw_craplot.cdagenci
                               ,rw_craplot.cdbccxlt
                               ,rw_craplot.nrdolote
                               ,pr_nrdconta
                               ,pr_nraplica
                               ,rw_craplot.nrseqdig + 1
                               ,vr_faixa_ir_rdca(4).perirtab
                               ,vr_faixa_ir_rdca(4).perirtab
                               ,862 -- DB. IR
                               ,rw_craplot.nrseqdig + 1
                               ,vr_vlirrdca
                               ,vr_rd2_dtrefere
                               ,0
                               ,0);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao criar lancamento de debito de IR na aplicacao (CRAPLAP) '
                          || '- Conta:'||pr_nrdconta || ' Aplicacao:'||pr_nraplica
                          || '. Detalhes: '||sqlerrm;
              RAISE vr_exc_erro;
          END;
          -- Atualizar as informacoes no lote utilizado
          BEGIN
            UPDATE craplot
               SET vlinfocr = vlinfocr + vr_vlirrdca
                  ,vlcompcr = vlinfocr + vr_vlirrdca
                  ,qtinfoln = qtinfoln + 1
                  ,qtcompln = qtcompln + 1
                  ,nrseqdig = nrseqdig + 1
             WHERE rowid = rw_craplot.rowid
             RETURNING nrseqdig INTO rw_craplot.nrseqdig; -- Atualizamos a sequencia no rowtype
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot.nrdolote||'. Detalhes: '||sqlerrm;
              RAISE vr_exc_erro;
          END;
        END IF;
      END IF;

      -- Se ha abono CPMF e na aplicacao no dia de aniversario
      IF rw_craprda.vlabcpmf > 0 AND vr_rd2_flgentra THEN
        -- Se ainda não foi buscado lote
        IF rw_craplot.rowid IS NULL THEN
          -- Chamar rotina para busca-lo, e se não encontrar, ira crialo
          pc_cria_craplot(pr_dscritic  => vr_dscritic);
          -- Se houve retorno de erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levantar excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        -- Lancar BASE ABO.CPMF
        BEGIN
          INSERT INTO craplap(cdcooper
                             ,dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,nrdconta
                             ,nraplica
                             ,nrdocmto
                             ,txaplica
                             ,txaplmes
                             ,cdhistor
                             ,nrseqdig
                             ,vllanmto
                             ,dtrefere
                             ,vlsdlsap
                             ,vlrenacu
                             ,vlslajir)
                       VALUES(pr_cdcooper
                             ,rw_craplot.dtmvtolt
                             ,rw_craplot.cdagenci
                             ,rw_craplot.cdbccxlt
                             ,rw_craplot.nrdolote
                             ,pr_nrdconta
                             ,pr_nraplica
                             ,rw_craplot.nrseqdig + 1
                             ,0
                             ,0
                             ,866 -- BASE ABO.CPMF
                             ,rw_craplot.nrseqdig + 1
                             ,rw_craprda.vlabcpmf
                             ,vr_rd2_dtrefere
                             ,0
                             ,0
                             ,0);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar lancamento base abono cpmf na aplicacao (CRAPLAP) '
                        || '- Conta:'||pr_nrdconta || ' Aplicacao:'||pr_nraplica
                        || '. Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        -- Atualizar as informacoes no lote utilizado
        BEGIN
          UPDATE craplot
             SET vlinfocr = vlinfocr + rw_craprda.vlabcpmf
                ,vlcompcr = vlinfocr + rw_craprda.vlabcpmf
                ,qtinfoln = qtinfoln + 1
                ,qtcompln = qtcompln + 1
                ,nrseqdig = nrseqdig + 1
           WHERE rowid = rw_craplot.rowid
           RETURNING nrseqdig INTO rw_craplot.nrseqdig; -- Atualizamos a sequencia no rowtype
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro e fazer rollback
            vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot.nrdolote||'. Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        -- Se houver IR sobre o abono
        IF TRUNC((rw_craprda.vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2) > 0   THEN
          -- Lancar BASE ABO.CPMF
          BEGIN
            INSERT INTO craplap(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,nrdconta
                               ,nraplica
                               ,nrdocmto
                               ,txaplica
                               ,txaplmes
                               ,cdhistor
                               ,nrseqdig
                               ,vllanmto
                               ,dtrefere
                               ,vlsdlsap
                               ,vlrenacu
                               ,vlslajir)
                         VALUES(pr_cdcooper
                               ,rw_craplot.dtmvtolt
                               ,rw_craplot.cdagenci
                               ,rw_craplot.cdbccxlt
                               ,rw_craplot.nrdolote
                               ,pr_nrdconta
                               ,pr_nraplica
                               ,rw_craplot.nrseqdig + 1
                               ,vr_faixa_ir_rdca(1).perirtab
                               ,vr_faixa_ir_rdca(1).perirtab
                               ,871 -- IR ABONO APL.
                               ,rw_craplot.nrseqdig + 1
                               ,TRUNC((rw_craprda.vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2)
                               ,vr_rd2_dtrefere
                               ,0
                               ,0
                               ,0);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao criar lancamento IR abono cpmf na aplicacao (CRAPLAP) '
                          || '- Conta:'||pr_nrdconta || ' Aplicacao:'||pr_nraplica
                          || '. Detalhes: '||sqlerrm;
              RAISE vr_exc_erro;
          END;
          -- Atualizar as informacoes no lote utilizado
          BEGIN
            UPDATE craplot
               SET vlinfocr = vlinfocr + TRUNC((rw_craprda.vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2)
                  ,vlcompcr = vlinfocr + TRUNC((rw_craprda.vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2)
                  ,qtinfoln = qtinfoln + 1
                  ,qtcompln = qtcompln + 1
                  ,nrseqdig = nrseqdig + 1
             WHERE rowid = rw_craplot.rowid
             RETURNING nrseqdig INTO rw_craplot.nrseqdig; -- Atualizamos a sequencia no rowtype
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot.nrdolote||'. Detalhes: '||sqlerrm;
              RAISE vr_exc_erro;
          END;
        END IF;
        -- Descontar do saldo da aplicacao o IR
        rw_craprda.vlsdrdca := rw_craprda.vlsdrdca - TRUNC((rw_craprda.vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2);
        -- Atualizar o abono de CPMF
        rw_craprda.vlabonrd := rw_craprda.vlabonrd + rw_craprda.vlabcpmf;
        rw_craprda.vlabcpmf := 0;
      END IF;
      -- Calcular os rendimentos de provisão
      vr_rd2_vlprovis := vr_rd2_vlrentot - vr_rd2_vllan180;
      -- Se houver valor de provisão
      IF vr_rd2_vlprovis <> 0 THEN
        -- Se ainda não foi buscado lote
        IF rw_craplot.rowid IS NULL THEN
          -- Chamar rotina para busca-lo, e se não encontrar, ira crialo
          pc_cria_craplot(pr_dscritic  => vr_dscritic);
          -- Se houve retorno de erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levantar excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        -- Criar bloco para gerar novas variaveis auxiliares neste insert
        DECLARE
          vr_cdhistor craplap.cdhistor%TYPE;
          vr_vllanmto craplap.vllanmto%TYPE;
          vr_vlinfocr craplot.vlinfocr%TYPE;
          vr_vlcompcr craplot.vlcompcr%TYPE;
          vr_vlinfodb craplot.vlinfodb%TYPE;
          vr_vlcompdb craplot.vlcompdb%TYPE;
        BEGIN
          -- Para provisão positiva
          IF vr_rd2_vlprovis > 0 THEN
            -- Armazenar a provisão no credito e com historico 180 - PROVIS.RDCA60
            vr_cdhistor := 180;
            vr_vllanmto := vr_rd2_vlprovis;
            vr_vlinfocr := vr_vllanmto;
            vr_vlcompcr := vr_vllanmto;
            vr_vlinfodb := 0;
            vr_vlcompdb := 0;
          ELSE
            -- Multiplicar por -1 para deixar o lancamento positivo, lancar nos campos de debito
            -- e gerar historio 182 - AJUSTE PROV.
            vr_cdhistor := 182;
            vr_vllanmto := vr_rd2_vlprovis*-1;
            vr_vlinfocr := 0;
            vr_vlcompcr := 0;
            vr_vlinfodb := vr_vllanmto;
            vr_vlcompdb := vr_vllanmto;
          END IF;
          -- Enfim, criar a craplap
          BEGIN
            INSERT INTO craplap(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,nrdconta
                               ,nraplica
                               ,nrdocmto
                               ,txaplica
                               ,txaplmes
                               ,cdhistor
                               ,nrseqdig
                               ,vllanmto
                               ,dtrefere
                               ,vlsdlsap
                               ,vlrenacu
                               ,vlslajir)
                         VALUES(pr_cdcooper
                               ,rw_craplot.dtmvtolt
                               ,rw_craplot.cdagenci
                               ,rw_craplot.cdbccxlt
                               ,rw_craplot.nrdolote
                               ,pr_nrdconta
                               ,pr_nraplica
                               ,rw_craplot.nrseqdig + 1
                               ,vr_rd2_txaplica
                               ,vr_rd2_txaplica
                               ,vr_cdhistor -- Cfme logica acima
                               ,rw_craplot.nrseqdig + 1
                               ,vr_vllanmto -- Cfme logica acima
                               ,vr_rd2_dtrefere
                               ,pr_vltotrda
                               ,0
                               ,0);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao criar lancamento provisão (CRAPLAP) '
                          || '- Conta:'||pr_nrdconta || ' Aplicacao:'||pr_nraplica
                          || '. Detalhes: '||sqlerrm;
              RAISE vr_exc_erro;
          END;
          -- Atualizar as informacoes no lote utilizado
          BEGIN
            UPDATE craplot
               SET vlinfocr = vlinfocr + vr_vlinfocr
                  ,vlcompcr = vlcompcr + vr_vlcompcr
                  ,vlinfodb = vlinfodb + vr_vlinfodb
                  ,vlcompdb = vlcompdb + vr_vlcompdb
                  ,qtinfoln = qtinfoln + 1
                  ,qtcompln = qtcompln + 1
                  ,nrseqdig = nrseqdig + 1
             WHERE rowid = rw_craplot.rowid
             RETURNING nrseqdig INTO rw_craplot.nrseqdig; -- Atualizamos a sequencia no rowtype
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot.nrdolote||'. Detalhes: '||sqlerrm;
              RAISE vr_exc_erro;
          END;
        END;
      END IF;
      -- Finalimente atualiza a aplicacao
      BEGIN
        UPDATE craprda
           SET qtmesext = rw_craprda.qtmesext
              ,dtsdrdan = rw_craprda.dtsdrdan
              ,vlsdrdan = rw_craprda.vlsdrdan
              ,incalmes = rw_craprda.incalmes
              ,dtiniext = rw_craprda.dtiniext
              ,dtfimext = rw_craprda.dtfimext
              ,dtiniper = rw_craprda.dtiniper
              ,dtfimper = rw_craprda.dtfimper
              ,inaniver = rw_craprda.inaniver
              ,vlsdrdca = rw_craprda.vlsdrdca
              ,insaqtot = rw_craprda.insaqtot
              ,dtsaqtot = rw_craprda.dtsaqtot
              ,vlsdextr = rw_craprda.vlsdextr
              ,dtcalcul = rw_craprda.dtcalcul
              ,vlabonrd = rw_craprda.vlabonrd
              ,vlabcpmf = rw_craprda.vlabcpmf
         WHERE rowid = rw_craprda.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar aplicacao (craprda) - Conta:'||pr_nrdconta || ' Aplicacao:'||pr_nraplica
                          || '. Detalhes: '||sqlerrm;
          RAISE vr_exc_erro;
      END;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar erro
        vr_cdcritic := nvl(vr_cdcritic,0);
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_calc_aniver_rdca2a --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_calc_aniver_rdca2a;

  /* Rotina de calculo do aniversario do RDCA2 */
  PROCEDURE pc_calc_aniver_rdca2c(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do processo
                                 ,pr_nrdconta IN craprda.nrdconta%TYPE --> Nro da conta da aplicacao RDCA
                                 ,pr_nraplica IN craprda.nraplica%TYPE --> Nro da aplicacao RDCA
                                 ,pr_vlsdrdca OUT NUMBER               --> Saldo da aplicacao pos calculo
                                 ,pr_des_erro  OUT VARCHAR2) IS        --> Saida com com erros;
  BEGIN
  /* .............................................................................

     Programa: pc_calc_aniver_rdca2c (Antigo Includes/rdca2c.i)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Deborah/Edson
     Data    : Dezembro/97.                    Ultima atualizacao: 14/01/2013

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Rotina de calculo do aniversario do RDCA2 - Deve ser chamada
                 dentro de um FOR EACH ou DO WHILE e com label TRANS_1.

     Alteracoes: 23/09/2004 - Incluido historico 494(CI)(Mirtes)

                 06/05/2005 - Utilizar o indice craplap5 na leitura dos
                              lancamentos (Edson).

                 03/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                 13/03/2006 - Incluir historico 876, ajuste ir (Margarete).

                 14/06/2007 - Alteracao para melhoria de performance (Evandro).

                 14/01/2013 - Conversão Progress >> Oracle (PLSQL) (Marcos-Supero)

                 17/12/2013 - Adição do parâmetro 180 na consulta (Petter - Supero).

  ............................................................................. */
    DECLARE
      -- Buscar os dados da aplicacao RDCA
      CURSOR cr_craprda IS
        SELECT rda.vlsdrdca
              ,rda.inaniver
              ,rda.dtmvtolt
              ,rda.dtiniper
              ,rda.dtfimper
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;
      rw_craprda cr_craprda%ROWTYPE;
      -- Variaveis auxiliares ao calculo final
      vr_rd2_vllan178 NUMBER(18,8);
      vr_rd2_vllan180 NUMBER(18,8);
      vr_rd2_dtcalcul DATE;
      vr_rd2_dtrefant DATE;
      -- Leitura dos lancamentos de resgate da aplicacao
      CURSOR cr_craplap(pr_lsthistor IN VARCHAR2 DEFAULT ' ') IS --> Lista com codigos de historico a retornar
        SELECT SUM(lap.vllanmto) vllanmto
          FROM craplap lap
         WHERE lap.cdcooper  = pr_cdcooper
           AND lap.nrdconta  = pr_nrdconta                            --> Conta enviada
           AND lap.nraplica  = pr_nraplica                            --> Aplicacao enviada
           AND lap.dtrefere  IN(vr_rd2_dtrefant,rw_craprda.dtfimper)  --> Data de referencia anterior OU Data fim do periodo aplicacao
           AND lap.dtmvtolt >= vr_rd2_dtcalcul                        --> Data base para calculo
           AND lap.dtmvtolt <= pr_dtmvtolt                            --> Data movimento atual
           AND ','||pr_lsthistor||',' LIKE ('%,'||lap.cdhistor||',%');--> Retornar historicos passados na listagem
    BEGIN
      -- Buscar os dados da aplicacao RDCA
      OPEN cr_craprda;
      FETCH cr_craprda
       INTO rw_craprda;
      CLOSE cr_craprda;
      -- Inicializar as variaveis para o calculo
      vr_rd2_vllan178 := 0;
      vr_rd2_vllan180 := 0;
      -- Se a aplicacao não completou um mes
      IF rw_craprda.inaniver = 0 THEN
        -- Data para calculo recebera a data de movimentacao da aplicacao
        vr_rd2_dtcalcul := rw_craprda.dtmvtolt;
        -- Se a data de movimentacao for diferente do inicio da aplicacao
        IF rw_craprda.dtmvtolt <> rw_craprda.dtiniper THEN
          -- Utilizar o inicio da aplicacao para a data referencia anterior
          vr_rd2_dtrefant := rw_craprda.dtiniper;
        ELSE
          -- Data referencia anterior recebera o fim do periodo da aplicacao
        vr_rd2_dtrefant := rw_craprda.dtfimper;
        END IF;
      ELSE
        -- Data para calculo recebera o inicio da aplicacao
        vr_rd2_dtcalcul := rw_craprda.dtiniper;
        -- Data referencia anterior recebera o fim do periodo da aplicacao
        vr_rd2_dtrefant := rw_craprda.dtfimper;
      END IF;
      -- Leitura dos lancamentos --> 182 Ajuste Provisao
      FOR rw_craplap IN cr_craplap('182') LOOP
        -- Decrementar da 180
        vr_rd2_vllan180 := vr_rd2_vllan180 - NVL(rw_craplap.vllanmto,0);
      END LOOP;
      -- Leitura dos lancamentos -- 181 Ajuste Provisao +
      FOR rw_craplap IN cr_craplap('180,181') LOOP
        -- Incrementar na 180
        vr_rd2_vllan180 := vr_rd2_vllan180 + NVL(rw_craplap.vllanmto,0);
      END LOOP;
      -- Leitura dos lancamentos de resgate
      FOR rw_craplap IN cr_craplap('178,494') LOOP
        -- Incrementar na 178
        vr_rd2_vllan178 := vr_rd2_vllan178 + NVL(rw_craplap.vllanmto,0);
      END LOOP;
      -- Ao final usamos o saldo da aplicacao com o valor na craprda
      -- diminuimos o acumulado na 178 e incrementamos o da 180
      pr_vlsdrdca := rw_craprda.vlsdrdca - vr_rd2_vllan178 + vr_rd2_vllan180;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro := 'Erro não tratado na APLI0001.pc_calc_aniver_rdca2c --> '||sqlerrm;
    END;

  END pc_calc_aniver_rdca2c;

  /* Rotina de calculo do saldo das aplicacoes RDC PRE para resgate */
  PROCEDURE pc_saldo_rdc_pre(pr_cdcooper IN crapcop.cdcooper%TYPE        --> Cooperativa
                            ,pr_nrdconta IN craprda.nrdconta%TYPE        --> Nro da conta da aplicacao RDCA
                            ,pr_nraplica IN craprda.nraplica%TYPE        --> Nro da aplicacao RDCA
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE        --> Data do processo (não necessariamente da CRAPDAT)
                            ,pr_dtiniper IN craprda.dtiniper%TYPE        --> Data de inicio da aplicacao
                            ,pr_dtfimper IN craprda.dtfimper%TYPE        --> Data de termino da aplicacao
                            ,pr_txaplica IN NUMBER                       --> Taxa aplicada
                            ,pr_flggrvir    IN BOOLEAN DEFAULT FALSE        --> Identificador se deve gravar valor insento
                            ,pr_tab_crapdat IN BTCH0001.cr_crapdat%ROWTYPE  --> Dados da tabela de datas
                            ,pr_cdprogra IN VARCHAR2 DEFAULT NULL        --> Codigo do programa chamador
                            ,pr_vlsdrdca IN OUT NUMBER                   --> Saldo da aplicacao pos calculo
                            ,pr_vlrdirrf OUT craplap.vllanmto%TYPE       --> Valor de IR
                            ,pr_perirrgt OUT NUMBER                      --> Percentual de IR resgatado
                            ,pr_des_reto OUT VARCHAR2                    --> OK ou NOK
                            ,pr_tab_erro OUT GENE0001.typ_tab_erro) AS   --> Tabela com erros
  BEGIN
  /* .............................................................................

     Programa: pc_saldo_rdc_pre (Antigo BO b1wgen0001.saldo_rdc_pre)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos (Supero)
     Data    : Fevereiro/13.                    Ultima atualizacao: 15/06/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  :   Rotina de calculo do saldo das aplicacoes RDC PRE para resgate
                   enxergando as novas aliquotas de imposto de renda.
                   Retorna o saldo para resgate no dia do vencimento.
                   Se resgatado antes nao recebe nada, saldo em craprda.vlsdrdca.

     Observacao:   Se a conta e o numero da aplicacao estiverem ZERADOS, o
                   programa fara uma simulacao da aplicacao.
                   O saldo sera o mesmo do craprda.vlsdrdca enquanto a
                   aplicacao estiver em carencia

     Alteracoes: 14/02/2013 - Conversão Progress >> Oracle (PLSQL) (Marcos-Supero)

                 21/05/2013 - Inclusão do parametro pr_tab_crapdat para
                              evitar novo select (Alisson-AMCom)

                 15/06/2018 - P411 - Quando acionamento vir da CUSAPL não sair em carencia (Marcos-Envolti)

  ............................................................................. */
    DECLARE
      -- Variaveis para calculo de IR (Com base na Includes/var_faixas_ir.i)
      vr_nrdias   INTEGER;      --> Auxiliar para contagem de dias da aplicacao
      vr_perirapl NUMBER(18,2); --> Aliquota para aplicacao de IR
      vr_vlrentot NUMBER(18,8); --> Totalizador dos rendimentos
      vr_vlsdrdca NUMBER(18,4); --> Rendimento da Aplicacao
      -- Variaveis para o calculo da aplicacao
      vr_txaplica NUMBER(18,8); --> Taxa aplicada
      vr_dtiniper DATE; --> Data inicial da aplicacao
      vr_dtfimper DATE; --> Data final da aplicacao
      vr_vlrendim NUMBER(18,8); --> Auxiliar para calculo dos rendimentos da aplicacao
      vr_flgimune boolean;
      -- Saida antecipada Ok
      vr_exc_ok EXCEPTION;
      -- Busca dos dados da aplicacao RDC
      CURSOR cr_craprda IS
        SELECT rda.dtvencto
              ,rda.qtdiaapl
              ,rda.vlsdrdca
              ,rda.dtmvtolt
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;
      rw_craprda cr_craprda%ROWTYPE;
      -- Buscar as taxas contratadas
      CURSOR cr_craplap IS
        SELECT lap.txaplica
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta
           AND lap.nraplica = pr_nraplica
           AND lap.dtmvtolt = rw_craprda.dtmvtolt
         ORDER BY lap.progress_recid ASC; --> Retornar a primeira encontrada
      rw_craplap cr_craplap%ROWTYPE;
    BEGIN
      -- Inicializar variaveis do calculo
      vr_nrdias   := 0;
      vr_perirapl := 0;
      vr_vlrentot := 0;
      vr_vlsdrdca := pr_vlsdrdca;
      -- Rotina que busca as informacoes de IR parametrizadas para aplicacoes RDC
      pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);
      -- Verificar se a data atual do movimento foi informada
      IF pr_tab_crapdat.dtmvtolt IS NULL THEN
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                             ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 1 --> Critica 1
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      END IF;
      -- Calcula o saldo quando foi passada uma aplicacao existente
      IF pr_nrdconta <> 0 AND pr_nraplica <> 0 THEN
        -- Buscar os dados da aplicacao RDC
        OPEN cr_craprda;
        FETCH cr_craprda
         INTO rw_craprda;
        -- Se não encontrar
        IF cr_craprda%NOTFOUND THEN
          -- Fechar o cursor e dar raise
          CLOSE cr_craprda;
          -- Chamar rotina de gravacao de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                               ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 426 --> Critica 426
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Levantar excecao
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor e continuar
          CLOSE cr_craprda;
        END IF;
        -- Caso programa chamador seja a CUSAPL, calcularemos provisão mesmo em carência
        IF NVL(pr_cdprogra,' ') <> 'CUSAPL' THEN
        -- Garantir que a aplicacao não esteja em carencia
        IF NOT(rw_craprda.dtvencto >= pr_tab_crapdat.dtmvtolt AND rw_craprda.dtvencto <= pr_tab_crapdat.dtmvtopr) THEN
          -- Se a data enviada menos a data do movimento da aplicacao, for inferior a quantidade de dias da aplicacao
          IF (pr_dtmvtolt - rw_craprda.dtmvtolt) < rw_craprda.qtdiaapl THEN
            -- Considerar o saldo da aplicacao
            vr_vlsdrdca:= rw_craprda.vlsdrdca;
            pr_vlsdrdca := vr_vlsdrdca;
            -- Ja retornar e ignorar o restante
            RAISE vr_exc_ok;
          END IF;
        END IF;
        END IF;
        -- Buscar as taxas contratadas
        OPEN cr_craplap;
        FETCH cr_craplap
         INTO rw_craplap;
        -- Se não encontrar
        IF cr_craplap%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craplap;
          -- Gerar erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                               ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 90 --> Critica 90
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Levantar excecao
          RAISE vr_exc_erro;
        ELSE
          -- Fechar o cursor e continuar
          CLOSE cr_craplap;
          -- Guardar os dados da aplicacao
          vr_txaplica := TRUNC(NVL(rw_craplap.txaplica, 0) / 100,8);
          vr_dtiniper := rw_craprda.dtmvtolt;
          vr_dtfimper := rw_craprda.dtvencto;
          vr_vlsdrdca := rw_craprda.vlsdrdca;
          pr_vlsdrdca := vr_vlsdrdca;
          --pr_vlsdrdca := rw_craprda.vlsdrdca;
        END IF;
      ELSE
        -- Utilizar informacoes enviadas por parametro
        vr_txaplica := NVL(pr_txaplica, 0);
        vr_dtiniper := pr_dtiniper;
        vr_dtfimper := pr_dtfimper;
      END IF;
      -- Calcular a quantidade de dias (Fim - Inicio)
      vr_nrdias := vr_dtfimper - vr_dtiniper;
      -- Gerar erro 840 em caso de não houver diferenca
      IF NVL(vr_nrdias,0) = 0 THEN
        -- Gerar erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                             ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 840 --> Critica 840
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      END IF;
      -- Pesquisar o vetor de faixas partindo do final ate o inicio
      FOR vr_ind IN REVERSE 1..vr_faixa_ir_rdc.COUNT LOOP
        -- Se a quantidade de dias for maior que a quantidade do vetor
        IF vr_nrdias > vr_faixa_ir_rdc(vr_ind).qtdiatab THEN
          -- Utilizar o percentual encontrado
          vr_perirapl := vr_faixa_ir_rdc(vr_ind).perirtab;
          -- Sair do LOOP
          EXIT;
        END IF;
      END LOOP;
      -- Se mesmo assim não tiver encontrado %
      IF vr_perirapl = 0 THEN
        -- Utilizar a quarta faixa do vetor
        vr_perirapl := vr_faixa_ir_rdc(4).perirtab;
      END IF;
      -- Se o % permanece zerado e não estivermos
      -- conectados a Cecred (Coop3)
      IF vr_perirapl = 0 AND pr_cdcooper <> 3 THEN
        -- Gerar erro 426
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                             ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 426 --> Critica 426
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      END IF;
      -- Efetuar laco entre o periodo encontrado
      LOOP
        -- Validar se a data auxiliar e util e se não for trazer a primeira apos
        vr_dtiniper := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => vr_dtiniper
                                                  ,pr_tipo     => 'P'     -- valor padrao
                                                  ,pr_feriado  => true    -- valor padrao 
                                                  ,pr_excultdia => true); -- considera 31/12 como util
        -- Continuar enquanto a data inicial for inferior a final
        EXIT WHEN vr_dtiniper >= vr_dtfimper;
        -- Aplicar ao rendimento a taxa
        vr_vlrendim := TRUNC(vr_vlsdrdca * vr_txaplica,8);
        -- Acumular ao saldo o rendimento calculado
        vr_vlsdrdca := vr_vlsdrdca + vr_vlrendim;
        -- Acumular ao rendimento total o rendimento calculado
        vr_vlrentot := vr_vlrentot + vr_vlrendim;
        -- Adicionar um dia para calcular a proxima data
        vr_dtiniper := vr_dtiniper + 1;
      END LOOP;
      -- Arredondar rendimento total e saldo da aplicacao
      vr_vlrentot := fn_round(vr_vlrentot,2);
      pr_vlsdrdca := fn_round(vr_vlsdrdca,2);
      -- Retornar o % aplicado
      pr_perirrgt := vr_perirapl;

      /* Procedure para verificar imunidade tributaria e inserir valor de insenção */
      IMUT0001.pc_verifica_imunidade_trib(  pr_cdcooper  => pr_cdcooper  --> Codigo Cooperativa
                                           ,pr_nrdconta  => pr_nrdconta  --> Numero da Conta
                                           ,pr_dtmvtolt  => pr_dtmvtolt  --> Data movimento
                                           ,pr_flgrvvlr  => pr_flggrvir  --> Identificador se deve gravar valor
                                           ,pr_cdinsenc  => 5            --> Codigo da insenção
                                           ,pr_vlinsenc  => TRUNC((vr_vlrentot *
                                                                   vr_perirapl / 100),2)--> Valor insento
                                           ,pr_flgimune  => vr_flgimune  --> Identificador se é imune
                                           ,pr_dsreturn  => pr_des_reto  --> Descricao Critica
                                           ,pr_tab_erro  => pr_tab_erro);--> Tabela erros

      /*O tratamento de retorno abaixo foi comentado pois, no progress, o mesmo não
        é implementado.
      -- Caso retornou com erro, levantar exceção
      IF pr_des_reto = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
      */

      -- Calcular o IRRF
      IF vr_flgimune THEN
        pr_vlrdirrf := 0;
      ELSE
        pr_vlrdirrf := TRUNC((vr_vlrentot * vr_perirapl / 100),2);
      END IF;

      -- Chegou ao final sem problemas
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_ok THEN
        -- Retorno OK, em execcao para desviar o fluxo do processo acima
        pr_des_reto := 'OK';
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_saldo_rdc_pre --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 999
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_saldo_rdc_pre;

  /* Rotina de calculo do saldo das aplicacoes RDC POS */
  PROCEDURE pc_saldo_rdc_pos(pr_cdcooper IN crapcop.cdcooper%TYPE        --> Cooperativa
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE        --> Data movimento atual
                            ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE        --> Data do movimento do proximo dia
                            ,pr_nrdconta IN craprda.nrdconta%TYPE        --> Nro da conta da aplicacao RDCA
                            ,pr_nraplica IN craprda.nraplica%TYPE        --> Nro da aplicacao RDCA
                            ,pr_dtmvtpap IN crapdat.dtmvtolt%TYPE        --> Data do processo (não necessariamente da CRAPDAT)
                            ,pr_dtcalsld IN craprda.dtmvtolt%TYPE        --> Data para calculo do saldo
                            ,pr_flantven IN BOOLEAN                      --> Flag antecede vencimento
                            ,pr_flggrvir IN BOOLEAN DEFAULT FALSE        --> Identificador se deve gravar valor insento
                            ,pr_dtinitax IN DATE                         --> Data de inicio da utilizacao da taxa de poupanca.
                            ,pr_dtfimtax IN DATE                         --> Data de fim da utilizacao da taxa de poupanca
                            ,pr_cdprogra IN VARCHAR2 DEFAULT NULL        --> Codigo do programa chamador
                            ,pr_vlsdrdca OUT NUMBER                      --> Saldo da aplicacao pos calculo
                            ,pr_vlrentot OUT NUMBER                      --> Valor de rendimento total
                            ,pr_vlrdirrf OUT craplap.vllanmto%TYPE       --> Valor de IR
                            ,pr_perirrgt OUT NUMBER                      --> Percentual de IR resgatado
                            ,pr_des_reto OUT VARCHAR2                    --> OK ou NOK
                            ,pr_tab_erro OUT GENE0001.typ_tab_erro) AS   --> Tabela com erros
  BEGIN
  /* .............................................................................

     Programa: pc_saldo_rdc_pos (Antigo BO b1wgen0001.saldo_rdc_pos)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos (Supero)
     Data    : Fevereiro/13.                    Ultima atualizacao: 15/06/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  :  Rotina de calculo do saldo das aplicacoes RDC POS enxergando as novas
                  aliquotas de imposto de renda. Retorna o saldo ate a data.

     Observacao: O saldo sera craprda.vlsdrdca sera craprda.vlaplica -
                 resgate trazidos a valor presente

     Alteracoes: 04/02/2013 - Conversão Progress >> Oracle (PLSQL) (Marcos-Supero).

                 24/09/2013 - Alterado cursor cr_craplap para utilizar todos os
                              campos do índice.

                 07/04/2014 - Alterações referente ao novo indexador de poupanca
                              (Jean Michel).
				 22/04/2014 - Inclusão do crapmfx.tpmoefix = 20 no cursor
							  cr_crapmfx (Jean Michel).

                 24/06/2014 - Retirada leitura da craptab e incluido data de
                              liberacao do projeto do novo indexador de
                              poupanca fixa - 01/07/2014 (Jean Michel).
                              
                 30/11/2015 - Ajustes de performace na leitura da craptrd
                              para restringir a quantidade de registros lidos.
                              SD 318820(Odirlei-AMcom)
                 
                 15/06/2018 - P411 - Quando acionamento vir da CUSAPL não sair em carencia (Marcos-Envolti)
                              
  ............................................................................. */
    DECLARE

      -- Busca dos dados da aplicacao RDC
      CURSOR cr_craprda IS
        SELECT rda.dtvencto
              ,rda.dtmvtolt
              ,rda.vlsdrdca
              ,rda.qtdiauti
              ,rda.vlsltxmm
              ,rda.dtatslmm
              ,rda.vlsltxmx
              ,rda.dtatslmx
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;
      rw_craprda cr_craprda%ROWTYPE;
      -- Saida antecipada Ok
      vr_exc_ok EXCEPTION;
      -- Variaveis para o calculo da aplicacao
      vr_dtiniper DATE; --> Data inicial da aplicacao
      vr_dtfimper DATE; --> Data final da aplicacao
      vr_txaplica NUMBER(18,8); --> Taxa aplicada
      vr_txaplmes NUMBER(18,8); --> Taxa de aplicacao mensal
      vr_vlrendim NUMBER(18,8); --> Auxiliar para calculo dos rendimentos da aplicacao
      vr_dtinipop DATE;         --> Data de inicio de poupanca
      vr_txmespop NUMBER(18,6); --> Taxa mes para poupanca
      vr_txdiapop NUMBER(18,6); --> Taxa dia para poupanca
      -- Variaveis para calculo de IR (Com base na Includes/var_faixas_ir.i)
      vr_nrdias   INTEGER;      --> Auxiliar para contagem de dias da aplicacao
      vr_perirapl NUMBER(18,2); --> Aliquota para aplicacao de IR
      vr_vlrentot NUMBER(18,8); --> Totalizador dos rendimentos
      vr_vlsdrdca NUMBER(18,4); --> Valor dos rendimentos
      vr_flgimune boolean;
      vr_datlibpr DATE; --> Data de liberacao de projeto sobre novo indexador de poupanca
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;      
      
      -- Buscar as taxas contratadas
      CURSOR cr_craplap IS
        SELECT /*+ Index (lap CRAPLAP##CRAPLAP5) */
               lap.txaplica
              ,lap.txaplmes
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta
           AND lap.nraplica = pr_nraplica
           AND lap.dtmvtolt = rw_craprda.dtmvtolt
         ORDER BY lap.cdcooper
                 ,lap.nrdconta
                 ,lap.nraplica
                 ,lap.dtmvtolt
                 ,lap.dtrefere
                 ,lap.cdhistor
                 ,lap.progress_recid ASC; --> Retornar a primeira encontrada
      rw_craplap cr_craplap%ROWTYPE;
      -- Variaveis para busca das informacoes de moeda
      vr_idx_moeda VARCHAR2(10) := '';
      vr_vlmoefix  crapmfx.vlmoefix%TYPE;
      -- Buscar todos os registros das moedas do tipo 6 e 8
      CURSOR cr_crapmfx(pr_cdcooper IN crapmfx.cdcooper%TYPE) IS
        SELECT crapmfx.dtmvtolt
              ,crapmfx.tpmoefix
              ,crapmfx.vlmoefix
          FROM crapmfx crapmfx
         WHERE crapmfx.cdcooper = pr_cdcooper
           AND crapmfx.tpmoefix IN(6,8,20);
      -- Buscar a qtde dias uteis na tabela de taxas
      CURSOR cr_craptrd(pr_dtiniper IN DATE) IS
        SELECT trd.qtdiaute
          FROM craptrd trd
         WHERE cdcooper = pr_cdcooper
           AND dtiniper = pr_dtiniper
         ORDER BY progress_recid;
      vr_qtdiaute craptrd.qtdiaute%TYPE;

    BEGIN
      -- Incializar variaveis
      vr_nrdias   := 0;
      vr_perirapl := 0;
      vr_vlsdrdca := 0;
      vr_vlrentot := 0;
      -- Rotina que busca as informacoes de IR parametrizadas para aplicacoes RDC
      pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);
      -- Buscar os dados da aplicacao RDC
      OPEN cr_craprda;
      FETCH cr_craprda
       INTO rw_craprda;
      -- Se não encontrar
      IF cr_craprda%NOTFOUND THEN
        -- Fechar o cursor e dar raise
        CLOSE cr_craprda;
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                             ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 426 --> Critica 426
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor e continuar
        CLOSE cr_craprda;
      END IF;
      -- Calcular a quantidade de dias (Vcto - Mvto atual)
      vr_nrdias := rw_craprda.dtvencto - rw_craprda.dtmvtolt;
      -- Gerar erro 840 em caso de não houver diferenca
      IF NVL(vr_nrdias,0) = 0 THEN
        -- Gerar erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                             ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 840 --> Critica 840
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      END IF;
      -- Pesquisar o vetor de faixas partindo do final ate o inicio
      FOR vr_ind IN REVERSE 1..vr_faixa_ir_rdc.COUNT LOOP
        -- Se a quantidade de dias for maior que a quantidade do vetor
        IF vr_nrdias > vr_faixa_ir_rdc(vr_ind).qtdiatab THEN
          -- Utilizar o percentual encontrado
          vr_perirapl := vr_faixa_ir_rdc(vr_ind).perirtab;
          -- Sair do LOOP
          EXIT;
        END IF;
      END LOOP;
      -- Se mesmo assim não tiver encontrado %
      IF vr_perirapl = 0 THEN
        -- Utilizar a quarta faixa do vetor
        vr_perirapl := vr_faixa_ir_rdc(4).perirtab;
      END IF;
      -- Se o % permanece zerado e não estivermos
      -- conectados a Cecred (Coop3)
      IF vr_perirapl = 0 AND pr_cdcooper <> 3 THEN
        -- Gerar erro 180
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                             ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 180 --> Critica 180
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      END IF;
      -- Data final e baseada na data passada
      vr_dtfimper := pr_dtcalsld;
      -- Saldo RDCA baseado no valor da tabela
      vr_vlsdrdca := rw_craprda.vlsdrdca;
      pr_vlsdrdca := vr_vlsdrdca;
      -- Percentual IR baseado no percentual achado acima
      pr_perirrgt := vr_perirapl;
      -- Caso programa chamador seja a CUSAPL, calcularemos provisão mesmo em carência
      IF NVL(pr_cdprogra,' ') <> 'CUSAPL' THEN
      -- Garantir que a aplicacao não esteja em carencia
      IF NOT(rw_craprda.dtvencto >= pr_dtmvtolt AND rw_craprda.dtvencto <= pr_dtmvtopr) THEN
        -- Se a data enviada - a data do movimento atual, for inferior a quantidade de dias uteis
        IF pr_dtmvtpap - rw_craprda.dtmvtolt < rw_craprda.qtdiauti THEN
          -- Ja retornar e ignorar o restante
          RAISE vr_exc_ok;
        END IF;
      END IF;
      END IF;
      -- Taxa minima
      IF pr_flantven THEN
        -- Utilizar taxa minima
        vr_vlsdrdca := rw_craprda.vlsltxmm;
        pr_vlsdrdca := vr_vlsdrdca;
        vr_dtiniper := rw_craprda.dtatslmm;
      ELSE
        -- Utilizar taxa maxima
        vr_vlsdrdca := rw_craprda.vlsltxmx;
        pr_vlsdrdca := vr_vlsdrdca;
        vr_dtiniper := rw_craprda.dtatslmx;
      END IF;
      -- Buscar as taxas contratadas
      OPEN cr_craplap;
      FETCH cr_craplap
       INTO rw_craplap;
      -- Se não encontrar
      IF cr_craplap%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craplap;
        -- Gerar erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                             ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 90 --> Critica 90
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_erro;
      ELSE
        -- Fechar o cursor e continuar
        CLOSE cr_craplap;
      END IF;


      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      IF rw_crapdat.inproces > 1 THEN
        -- Se o vetor de dias uteis ainda não possuir informacoes
        IF vr_tab_qtdiaute.COUNT = 0 THEN
          -- Buscar os dias uteis
          FOR rw_craptrd IN (SELECT *
                               FROM (SELECT craptrd.dtiniper
                                           ,craptrd.qtdiaute
                                           ,count(*) over (partition by craptrd.dtiniper
                                                           order by craptrd.progress_recid) registro
                                       FROM craptrd
                                       WHERE craptrd.cdcooper = pr_cdcooper)
                              WHERE registro = 1) LOOP
            -- Atribuir o valor selecionado ao vetor somente para a primeira data encontrada (mais antiga)
            IF rw_craptrd.registro = 1 THEN
              vr_tab_qtdiaute(to_char(rw_craptrd.dtiniper,'YYYYMMDD')):= rw_craptrd.qtdiaute;
            END IF;
          END LOOP;
        END IF;

      -- Se o vetor de moedas ainda não possuir informacoes
      IF vr_tab_moedatx.COUNT = 0 THEN
        -- Buscar todos os registros das moedas do tipo 6 e 8
        FOR rw_crapmfx IN cr_crapmfx(pr_cdcooper => pr_cdcooper) LOOP
          -- Montar a chave do registro com o tipo + data
          vr_idx_moeda := LPAD(rw_crapmfx.tpmoefix,2,'0')||To_Char(rw_crapmfx.dtmvtolt,'YYYYMMDD');
          -- Atribuir o valor selecionado ao vetor
          vr_tab_moedatx(vr_idx_moeda).vlmoefix := rw_crapmfx.vlmoefix;
          -- Para moeda 6 - CDI
          IF rw_crapmfx.tpmoefix = 6 THEN
            -- Calcular a taxa de aplicacao
            vr_tab_moedatx(vr_idx_moeda).txaplmes := (POWER((1 + rw_crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100;
          END IF;
        END LOOP;
      END IF;
      ELSE -- inproces <= 1

        -- Se o vetor de dias uteis ainda não possuir informacoes
        IF vr_tab_qtdiaute.COUNT = 0 THEN
          -- Buscar os dias uteis
          FOR rw_craptrd IN (SELECT craptrd.dtiniper
                                   ,craptrd.qtdiaute
                                   ,count(*) over (partition by craptrd.dtiniper
                                                       order by craptrd.progress_recid) registro
                               FROM craptrd
                              WHERE craptrd.cdcooper = pr_cdcooper
                                AND craptrd.dtiniper > vr_dtiniper -1) LOOP
            -- Atribuir o valor selecionado ao vetor somente para a primeira data encontrada (mais antiga)
            IF rw_craptrd.registro = 1 THEN
              vr_tab_qtdiaute(to_char(rw_craptrd.dtiniper,'YYYYMMDD')):= rw_craptrd.qtdiaute;
              EXIT;
            END IF;
          END LOOP;
        END IF;

        -- Buscar todos os registros das moedas do tipo 6 e 8
        FOR rw_crapmfx IN (SELECT CRAPMFX.DTMVTOLT
                                 ,CRAPMFX.TPMOEFIX
                                 ,CRAPMFX.VLMOEFIX 
                             FROM CRAPMFX
                            WHERE CRAPMFX.CDCOOPER = pr_cdcooper 
                              AND CRAPMFX.DTMVTOLT > vr_dtiniper -35
                              AND CRAPMFX.DTMVTOLT <= vr_dtfimper
                              AND CRAPMFX.TPMOEFIX IN(6,8,20)) LOOP
          -- MOntar a chave do registro com o tipo + data
          vr_idx_moeda := LPAD(rw_crapmfx.tpmoefix,2,'0')||To_Char(rw_crapmfx.dtmvtolt,'YYYYMMDD');
          -- Atribuir o valor selecionado ao vetor
          vr_tab_moedatx(vr_idx_moeda).vlmoefix := rw_crapmfx.vlmoefix;
          -- Para moeda 6 - CDI
          IF rw_crapmfx.tpmoefix = 6 THEN
            -- Calcular a taxa de aplicacao
            vr_tab_moedatx(vr_idx_moeda).txaplmes := (POWER((1 + rw_crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100;
          END IF;
        END LOOP;
      END IF;

      -- Data de liberacao do projeto novo indexador de poupanca
      vr_datlibpr := to_date('01/07/2014','dd/mm/yyyy');

      -- Efetuar laco entre o periodo encontrado
      LOOP
        -- Validar se a data auxiliar e util e se não for trazer a primeira apos
        vr_dtiniper := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => vr_dtiniper
                                                  ,pr_tipo     => 'P'     -- valor padrao
                                                  ,pr_feriado  => true    -- valor padrao 
                                                  ,pr_excultdia => true); -- considera 31/12 como util
        -- Continuar enquanto a data inicial for inferior a final
        EXIT WHEN vr_dtiniper >= vr_dtfimper;
        -- Limpar variavel de moeda
        vr_vlmoefix := NULL;
        -- Montar chave de procura de CDI ano + data atual
        vr_idx_moeda := '06'||To_Char(vr_dtiniper,'YYYYMMDD');
        -- Verificar se o indice existe na tabela
        IF vr_tab_moedatx.EXISTS(vr_idx_moeda) THEN
          -- Atribuir o valor do vetor para a variavel
          vr_vlmoefix := vr_tab_moedatx(vr_idx_moeda).vlmoefix;
        ELSE
          -- Gerar erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                               ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 211 --> Critica 211
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Levantar excecao
          RAISE vr_exc_erro;
        END IF;
        -- Guardar taxa aplicada ao mes ja calculada no vetor
        vr_txaplmes := vr_tab_moedatx(vr_idx_moeda).txaplmes;
        -- Calcula o saldo com a taxa minina se for antes do vencimento
        IF pr_flantven AND rw_craplap.txaplica <> rw_craplap.txaplmes THEN
          -- Utilizar taxa cadastrada
          vr_txaplica := fn_round((vr_txaplmes * rw_craplap.txaplmes / 100 ) / 100 ,8);
        ELSE
          -- Utilizar taxa cadastrada inicial
          vr_txaplica := fn_round((vr_txaplmes * rw_craplap.txaplica / 100 ) / 100 ,8);
          -- Se a data de inicio encontrada estiver dentre o periodo de datas das taxas
          IF vr_dtiniper > pr_dtinitax AND rw_craprda.dtmvtolt < pr_dtfimtax THEN
            -- Usar poupanca de um mes atras  --
            DECLARE
              vr_dia NUMBER;
              vr_mes NUMBER;
              vr_ano NUMBER;
            BEGIN
              -- Guardar dia, mes e ano separadamente
              vr_dia := to_char(vr_dtiniper,'dd');
              vr_mes := to_char(vr_dtiniper,'mm');
              vr_ano := to_char(vr_dtiniper,'yyyy');
              -- Se o mes for janeiro
              IF vr_mes = 1 THEN
                -- Utilizar dezembro e diminuir 1 ano
                vr_mes := 12;
                vr_ano := vr_ano - 1;
              ELSE
                -- Utilizar mesmo dia e ano, e diminuir 1 mes
                vr_mes := vr_mes - 1;
              END IF;
              -- Tenta montar data formada
              vr_dtinipop := to_date(to_char(vr_dia,'fm00')||to_char(vr_mes,'fm00')||to_char(vr_ano,'fm0000'),'dd/mm/yyyy');
            EXCEPTION
              WHEN OTHERS THEN
                -- Se ocorreu erro, e pq o dia encontrado não existe no mes proposto
                -- então devemos pegar o primeiro dia do mes
                vr_dtinipop := TRUNC(vr_dtiniper,'mm');
            END;
            -- Limpar auxiliar de moeda
            vr_vlmoefix := NULL;

            /********************************************************************/
            /** Em Maio de 2012 o novo calculo foi liberado para utilizacao,   **/
            /** portanto aplicacoes cadastradas a partir desta data poderiam   **/
            /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
            /** vamos calcular o rendimento desta aplicacao com base na nova   **/
            /** regra somente a partir da data de liberacao do projeto de novo **/
            /** indexador de poupanca, pois o passado anterior a liberacao ja  **/
            /** foi remunerado e contabilizado. 							                 **/
            /********************************************************************/

           IF rw_craprda.dtmvtolt >= to_date('04/05/2012','dd/mm/yyyy') AND
              vr_dtiniper >= vr_datlibpr THEN
             -- Montar chave de procura de moeda 8 + data poupanca
            vr_idx_moeda := '20'||To_Char(vr_dtinipop,'YYYYMMDD');
           ELSE
             -- Montar chave de procura de moeda 8 + data poupanca
            vr_idx_moeda := '08'||To_Char(vr_dtinipop,'YYYYMMDD');
           END IF;

            -- Verificar se o indice existe na tabela
            IF vr_tab_moedatx.EXISTS(vr_idx_moeda) THEN
              -- Atribuir o valor do vetor para a variavel
              vr_vlmoefix := vr_tab_moedatx(vr_idx_moeda).vlmoefix;
            ELSE
              -- Gerar erro 211
              gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                                   ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                                   ,pr_nrsequen => 1 --> Fixo
                                   ,pr_cdcritic => 211 --> Critica 211
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
              -- Levantar excecao
              RAISE vr_exc_erro;
            END IF;
            -- Verificar se esta data não existe no vetor
            IF NOT vr_tab_qtdiaute.EXISTS(to_char(vr_dtinipop,'yyyymmdd')) THEN
              -- Buscar a data na tabela
              OPEN cr_craptrd(pr_dtiniper => vr_dtinipop);
              FETCH cr_craptrd
               INTO vr_qtdiaute;
              CLOSE cr_craptrd;
              -- Adiciona-la ao vetor para evitar nova leitura na tabela
              vr_tab_qtdiaute(to_char(vr_dtinipop,'yyyymmdd')) := vr_qtdiaute;
            ELSE
              -- Buscar o valor do vetor
              vr_qtdiaute := vr_tab_qtdiaute(to_char(vr_dtinipop,'yyyymmdd'));
            END IF;
            -- Chamar rotina
            APLI0001.pc_calctx_poupanca(pr_cdcooper  => pr_cdcooper           --> Codigo da cooperativa
                                       ,pr_qtdiaute  => vr_qtdiaute    --> Quantidade de dias do periodo
                                       ,pr_vlmoefix  => vr_vlmoefix    --> Valor da moeda fixa
                                       ,pr_txmespop  => vr_txmespop    --> Taxa mensal da poupanca
                                       ,pr_txdiapop  => vr_txdiapop);  --> Taxa diaria da poupanca
            -- Se a taxa aplicada e menor que a taxa da poupanca
            IF vr_txaplica < vr_txdiapop / 100 THEN
              -- Utilizar a taxa calculada para poupanca
              vr_txaplica := vr_txdiapop / 100;
            END IF;
          END IF;
        END IF;
        -- Calcular o rendimento
        vr_vlrendim := TRUNC(vr_vlsdrdca * vr_txaplica,8);
        -- Acumular o rendimento ao saldo da aplicacao
        vr_vlsdrdca := fn_round(vr_vlsdrdca + vr_vlrendim,4);
        -- Acumular o rendimento total
        vr_vlrentot := nvl(vr_vlrentot,0) + vr_vlrendim;
        -- Adicionar um dia para calcular a proxima data
        vr_dtiniper := vr_dtiniper + 1;
      END LOOP;
      -- Arredondar rendimento total e saldo da aplicacao
      vr_vlrentot := fn_round(vr_vlrentot,2);
      -- Retornar o rendimento total
      pr_vlrentot := vr_vlrentot;
      --Retorna Saldo da Aplicacao
      pr_vlsdrdca := fn_round(vr_vlsdrdca,2);
      -- Retornar o % aplicado
      pr_perirrgt := vr_perirapl;

      /* Procedure para verificar imunidade tributaria e inserir valor de insenção */
      IMUT0001.pc_verifica_imunidade_trib(  pr_cdcooper  => pr_cdcooper  --> Codigo Cooperativa
                                           ,pr_nrdconta  => pr_nrdconta  --> Numero da Conta
                                           ,pr_dtmvtolt  => pr_dtmvtolt  --> Data movimento
                                           ,pr_flgrvvlr  => pr_flggrvir  --> Identificador se deve gravar valor
                                           ,pr_cdinsenc  => 5            --> Codigo da insenção
                                           ,pr_vlinsenc  => TRUNC((vr_vlrentot *
                                                                   vr_perirapl / 100),2)--> Valor insento
                                           ,pr_flgimune  => vr_flgimune  --> Identificador se é imune
                                           ,pr_dsreturn  => pr_des_reto  --> Descricao Critica
                                           ,pr_tab_erro  => pr_tab_erro);--> Tabela erros

      -- Caso retornou com erro, levantar exceção
      IF pr_des_reto = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Calcular o IRRF
      IF vr_flgimune THEN
        pr_vlrdirrf := 0;
      ELSE
        pr_vlrdirrf := TRUNC((vr_vlrentot * vr_perirapl / 100),2);
      END IF;

      -- Chegou ao final sem problemas
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_ok THEN
        -- Retorno OK, em execcao para desviar o fluxo do processo acima
        pr_des_reto := 'OK';
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_saldo_rdc_pos --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                             ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_saldo_rdc_pos;

  /* Rotina para montar o saldo das aplicacoes financeiras e mostrar o extrato para a Atenda */
  PROCEDURE pc_calc_sldrda(pr_cdcooper IN crapcop.cdcooper%TYPE        --> Cooperativa
                          ,pr_cdoperad IN crapope.cdoperad%TYPE DEFAULT 0  --> Operador
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE        --> Data do processo
                          ,pr_inproces IN crapdat.inproces%TYPE        --> Indicador do processo
                          ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE        --> Proximo dia util
                          ,pr_cdprogra IN crapprg.cdprogra%TYPE        --> Programa em execucao
                          ,pr_cdagenci IN crapass.cdagenci%TYPE        --> Codigo da agencia
                          ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE        --> Numero do caixa
                          ,pr_nrdconta IN crapass.nrdconta%TYPE        --> Numero da conta para o saldo
                          ,pr_flgextra IN BOOLEAN                      --> Indicar de extrato S/N
                          ,pr_tab_crapdat IN BTCH0001.cr_crapdat%ROWTYPE  --> Dados da tabela de datas
                          ,pr_tab_crawext OUT FORM0001.typ_tab_crawext --> Tabela com as informacoes de extrato
                          ,pr_vltotrda    OUT NUMBER                   --> Total aplicacao RDC ou RDCA
                          ,pr_des_reto OUT VARCHAR2                    --> OK ou NOK
                          ,pr_tab_erro OUT GENE0001.typ_tab_erro) AS   --> Tabela com erros
  BEGIN
    /* .............................................................................

       Programa: pc_calc_sldrda (Antigo Fontes/sldrda.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Junho/94.                       Ultima atualizacao: 01/06/2016

       Dados referentes ao programa:

       Frequencia: Diario (on-line)
       Objetivo  : Rotina para montar o saldo das aplicacoes financeiras e mostrar
                   o extrato das mesmas para a tela ATENDA.

       Alteracoes: 08/12/94 - Alterado para mostrar saldo e extrato de RDCA no
                              total de aplicacoes (Deborah).

                   26/04/95 - Alterado para mostrar o valor aplicado na tela atenda.
                              (Odair).

                   21/09/95 - Alterado o indice de leitura para mostrar por data
                              (Deborah).

                   17/10/95 - Alterado para mostrar "D" nas aplicacoes RDCA que
                              estao disponiveis (Deborah).

                   27/11/96 - Tratar RDCAII (Odair).

                   21/05/2001 - Disponibilizar arquivo com Extrato das Aplicacoes
                                para alimentar o auto-atendimento. (Eduardo).

                   12/04/2002 - Tratar resgate on_line (Mag).

                   06/01/2004 - Desprezar saldo negativos (Margarete).

                   09/11/2004 - Aumentado tamanho do campo do numero da aplicacao
                                para 7 posicoes, na leitura da tabela (Evandro).

                   21/01/2005 - Mostrar saldo total para resgate (Margarete).

                   01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

                   06/02/2006 - Inclusao de NO-UNDO nas temp-tables - SQLWorks -
                                Eder

                   25/04/2007 - Alterado para os novos tipos de aplicacao (Magui).

                   03/07/2007 - Tratamento para novos tipo de aplicacao (David).

                   03/12/2007 - Substituir chamada da include aplicacao.i pela
                                BO b1wgen0004.i e rdca2s pela b1wgen0004a.i
                                (Sidnei - Precise).

                   01/02/2013 - Conversão de Progress >> PLSQL (Marcos - Supero)

                   16/09/2013 - Tratamento para Imunidade Tributaria (Ze).

                   01/06/2016 - Ajustado a leitura da craptab para utilizar a rotina
                                da TABE0001 (Douglas - Chamado 454248)
    ............................................................................. */
    DECLARE
      -- Busca das aplicacoes RDCA ativas da conta passada
      CURSOR cr_craprda IS
        SELECT rda.tpaplica
              ,rda.nrdconta
              ,rda.nraplica
              ,rda.vlsdrdca
              ,rda.inaniver
              ,rda.dtfimper
              ,rda.dtmvtolt
              ,rda.vlaplica
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.insaqtot = 0; --> não sacado totalmente
      -- Busca do tipo de captacao
      CURSOR cr_crapdtc(pr_tpaplica craprda.tpaplica%TYPE) IS
        SELECT dtc.tpaplrdc
              ,dtc.dsaplica
          FROM crapdtc dtc
         WHERE dtc.cdcooper = pr_cdcooper
           AND dtc.tpaplica = pr_tpaplica;
      rw_crapdtc cr_crapdtc%ROWTYPE;
      -- Variaveis auxiliares para o calculo das aplicacoes
      vr_vlsdrdca     NUMBER(18,8); --> Saldo da aplicacao
      vr_vlsldapl     NUMBER(18,8); --> Saldo da aplicacao RDCA
      vr_sldpresg     NUMBER(18,8); --> Saldo para resgate
      vr_vldperda     NUMBER(18,8); --> Valor calculado da perda
      vr_apl_txaplica NUMBER(18,8); --> Taxa da aplicacao
      vr_vlsldrdc     NUMBER(18,4); --> Saldo de aplicacao RDC
      vr_vlrdirrf     craplap.vllanmto%TYPE; --> Valor do irrf sobre o rendimento
      vr_perirrgt     NUMBER(18,2);          --> % de IR Resgatado
      vr_vlrentot     NUMBER(18,4);          --> Totalizador dos rendimentos
      vr_vlrenrgt     NUMBER(18,8);          --> Rendimento resgatado periodo
      vr_vlrrgtot     craplap.vllanmto%TYPE; --> Resgate para zerar a aplicacao
      vr_vlirftot     craplap.vllanmto%TYPE; --> IRRF para finalizar a aplicacao
      vr_vlrendmm     craplap.vlrendmm%TYPE; --> Rendimento da ultima provisao ate a data do resgate
      vr_vlrvtfim     craplap.vllanmto%TYPE; --> Quantia provisao reverter para zerar a aplicacao
      vr_dtinitax     DATE;                  --> Data de inicio da utilizacao da taxa de poupanca.
      vr_dtfimtax     DATE;                  --> Data de fim da utilizacao da taxa de poupanca.
      vr_sldpresg_tmp craplap.vllanmto%TYPE; --> Valor saldo de resgate
      vr_dup_vlsdrdca craplap.vllanmto%TYPE; --> Acumulo do saldo da aplicacao RDCA
      vr_dstextab     craptab.dstextab%TYPE; --> Descricao da craptab
      
      -- Excetion para ignorar a aplicacao
      vr_exc_ignora EXCEPTION;
           
    BEGIN

      -- Data de fim e inicio da utilizacao da taxa de poupanca.
      -- Utiliza-se essa data quando o rendimento da aplicacao for menor que
      --  a poupanca, a cooperativa opta por usar ou nao.
      -- Buscar a descricao das faixas contido na craptab
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'MXRENDIPOS'
                     ,pr_tpregist => 1);
      
      -- Se não encontrar
      IF TRIM(vr_dstextab) IS NULL THEN
        -- Utilizar datas padrão
        vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
        vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
      ELSE
        -- Utilizar datas da tabela
        vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1,vr_dstextab,';'),'DD/MM/YYYY');
        vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2,vr_dstextab,';'),'DD/MM/YYYY');
      END IF;
      -- Busca das aplicacoes RDCA ativas da conta passada
      FOR rw_craprda IN cr_craprda LOOP
        BEGIN
          -- Para aplicacao 3 - RDCA
          IF rw_craprda.tpaplica = 3 THEN
            -- Chamar rotina de consulta do saldo RDCA30
            APLI0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                                 ,pr_cdoperad => pr_cdoperad         --> Operador
                                                 ,pr_dtmvtolt => pr_dtmvtolt         --> Data do processo
                                                 ,pr_inproces => pr_inproces         --> Indicador do processo
                                                 ,pr_dtmvtopr => pr_dtmvtopr         --> Proximo dia util
                                                 ,pr_cdprogra => pr_cdprogra         --> Programa em execucao
                                                 ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                                                 ,pr_nrdcaixa => pr_nrdcaixa         --> Numero do caixa
                                                 ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicacao RDCA
                                                 ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicacao RDCA
                                                 ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplicacao
                                                 ,pr_vlsldapl => vr_vlsldapl         --> Saldo da aplicacao RDCA
                                                 ,pr_vldperda => vr_vldperda         --> Valor calculado da perda
                                                 ,pr_sldpresg => vr_sldpresg_tmp     --> Valor saldo de resgate
                                                 ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                                 ,pr_txaplica => vr_apl_txaplica     --> Taxa aplicada sob o emprestimo
                                                 ,pr_des_reto => pr_des_reto         --> OK ou NOK
                                                 ,pr_tab_erro => pr_tab_erro);       --> Tabela com erros
            -- Se retornar erro
            IF vr_des_reto = 'NOK' THEN
              -- Levantar excecao
              RAISE vr_exc_erro;
            END IF;
            -- Acumular o valor calculado
            vr_sldpresg := vr_vlsdrdca;
          -- Para aplicacao 5 - RDCA II
          ELSIF rw_craprda.tpaplica = 5 THEN
            -- Consulta saldo aplicacao RDCA60 (Antiga includes/b1wgen0004a.i)
            APLI0001.pc_consul_saldo_aplic_rdca60(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                                 ,pr_dtmvtolt => pr_dtmvtolt         --> Data do movto atual
                                                 ,pr_dtmvtopr => pr_dtmvtopr         --> Data do proximo movimento
                                                 ,pr_cdprogra => pr_cdprogra         --> Programa em execucao
                                                 ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                                                 ,pr_nrdcaixa => pr_nrdcaixa         --> Numero do caixa
                                                 ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicacao RDCA
                                                 ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicacao RDCA
                                                 ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplicacao
                                                 ,pr_sldpresg => vr_sldpresg         --> Saldo para resgate
                                                 ,pr_des_reto => pr_des_reto         --> OK ou NOK
                                                 ,pr_tab_erro => pr_tab_erro);       --> Tabela com erros
            -- Se retornar erro
            IF vr_des_reto = 'NOK' THEN
              -- Levantar excecao
              RAISE vr_exc_erro;
            END IF;
            -- Acumular o valor calculado
            vr_sldpresg := vr_vlsdrdca;
          ELSE --> Todas outras aplicacoes
            -- Busca do tipo de captacao
            OPEN cr_crapdtc(pr_tpaplica => rw_craprda.tpaplica);
            FETCH cr_crapdtc
             INTO rw_crapdtc;
            -- Somente continuar se encontrar
            IF cr_crapdtc%FOUND THEN
              -- Fechar o cursor
              CLOSE cr_crapdtc;
              -- Para o tipo de aplicacao 1 - RDCPRE
              IF rw_crapdtc.tpaplrdc = 1 THEN
                -- Calcular saldo atualizado da aplicacao
                APLI0001.pc_saldo_rdc_pre(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                         ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicacao RDC
                                         ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicacao RDC
                                         ,pr_dtmvtolt => pr_dtmvtolt         --> Data do movimento atual passado
                                         ,pr_dtiniper => NULL                --> Data de inicio da aplicacao
                                         ,pr_dtfimper => NULL                --> Data de termino da aplicacao
                                         ,pr_txaplica => 0                   --> Taxa aplicada
                                         ,pr_flggrvir => FALSE               --> Identificador se deve gravar valor insento
                                         ,pr_tab_crapdat => pr_tab_crapdat   --> Datas
                                         ,pr_vlsdrdca => vr_vlsldrdc         --> Saldo da aplicacao pos calculo
                                         ,pr_vlrdirrf => vr_vlrdirrf         --> Valor de IR
                                         ,pr_perirrgt => vr_perirrgt         --> Percentual de IR resgatado
                                         ,pr_des_reto => pr_des_reto         --> OK ou NOK
                                         ,pr_tab_erro => pr_tab_erro);       --> Tabela com erros
                -- Se retornar erro
                IF vr_des_reto = 'NOK' THEN
                  -- Levantar excecao
                  RAISE vr_exc_erro;
                END IF;
                -- Utilizar o saldo para resgate calculado da RDC
                vr_sldpresg := vr_vlsldrdc;
              -- Para o tipo da aplicacao 2 - RDCPOS
              ELSIF rw_crapdtc.tpaplrdc = 2 THEN
                -- Rotina de calculo do saldo das aplicacoes RDC POS
                APLI0001.pc_saldo_rdc_pos(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                         ,pr_dtmvtolt => pr_dtmvtolt         --> Movimento atual
                                         ,pr_dtmvtopr => pr_dtmvtopr         --> Proximo dia util
                                         ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicacao RDC
                                         ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicacao RDC
                                         ,pr_dtmvtpap => pr_dtmvtolt         --> Data do movimento atual passado
                                         ,pr_dtcalsld => pr_dtmvtolt         --> Data do movimento atual passado
                                         ,pr_flantven => FALSE               --> Flag antecede vencimento
                                         ,pr_flggrvir => FALSE               --> Identificador se deve gravar valor insento
                                         ,pr_dtinitax => vr_dtinitax         --> Data de inicio da utilizacao da taxa de poupanca.
                                         ,pr_dtfimtax => vr_dtfimtax         --> Data de fim da utilizacao da taxa de poupanca.
                                         ,pr_vlsdrdca => vr_vlsldrdc         --> Saldo da aplicacao pos calculo
                                         ,pr_vlrentot => vr_vlrentot         --> Saldo da aplicacao pos calculo
                                         ,pr_vlrdirrf => vr_vlrdirrf         --> Valor de IR
                                         ,pr_perirrgt => vr_perirrgt         --> Percentual de IR resgatado
                                         ,pr_des_reto => pr_des_reto         --> OK ou NOK
                                         ,pr_tab_erro => pr_tab_erro);       --> Tabela com erros
                -- Se retornar erro
                IF vr_des_reto = 'NOK' THEN
                  -- Levantar excecao
                  RAISE vr_exc_erro;
                END IF;
                -- Rotina de calculo do saldo das aplicacoes RDC POS para resgate com IRPF.
                APLI0001.pc_saldo_rgt_rdc_pos(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                             ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                                             ,pr_nrdcaixa => pr_nrdcaixa         --> Numero do caixa
                                             ,pr_nrctaapl => rw_craprda.nrdconta --> Nro da conta da aplicacao RDC
                                             ,pr_nraplres => rw_craprda.nraplica --> Nro da aplicacao RDC
                                             ,pr_dtmvtolt => pr_dtmvtolt         --> Data do movimento atual passado
                                             ,pr_dtaplrgt => pr_dtmvtolt         --> Data do movimento atual passado
                                             ,pr_vlsdorgt => 0                   --> Valor RDC
                                             ,pr_flggrvir => FALSE               --> Identificador se deve gravar valor insento
                                             ,pr_dtinitax => vr_dtinitax         --> Data Inicial da Utilizacao da taxa da poupanca
                                             ,pr_dtfimtax => vr_dtfimtax         --> Data Final da Utilizacao da taxa da poupanca
                                             ,pr_vlsddrgt => vr_sldpresg         --> Valor do resgate total sem irrf ou o solicitado
                                             ,pr_vlrenrgt => vr_vlrenrgt         --> Rendimento total a ser pago quando resgate total
                                             ,pr_vlrdirrf => vr_vlrdirrf         --> IRRF do que foi solicitado
                                             ,pr_perirrgt => vr_perirrgt         --> Percentual de aliquota para calculo do IRRF
                                             ,pr_vlrgttot => vr_vlrrgtot         --> Resgate para zerar a aplicacao
                                             ,pr_vlirftot => vr_vlirftot         --> IRRF para finalizar a aplicacao
                                             ,pr_vlrendmm => vr_vlrendmm         --> Rendimento da ultima provisao ate a data do resgate
                                             ,pr_vlrvtfim => vr_vlrvtfim         --> Quantia provisao reverter para zerar a aplicacao
                                             ,pr_des_reto => pr_des_reto         --> OK ou NOK
                                             ,pr_tab_erro => pr_tab_erro);       --> Tabela com erros
                -- Se retornar erro
                IF vr_des_reto = 'NOK' THEN
                  -- Levantar excecao
                  RAISE vr_exc_erro;
                END IF;
                -- Se houver valor para zerar a aplicacao
                IF vr_vlrrgtot > 0 THEN
                  -- Utiliza-lo
                  vr_sldpresg := vr_vlrrgtot;
                ELSE
                  -- Utilizar o saldo da aplicacao
                  vr_sldpresg := rw_craprda.vlsdrdca;
                END IF;
              END IF;
            ELSE
              -- fechar o cursor
              CLOSE cr_crapdtc;
              -- Ignorar esta aplicacao
              RAISE vr_exc_ignora;
            END IF;
          END IF;
          -- Acumular ao total o valor resgatado
          pr_vltotrda := NVL(pr_vltotrda,0) + NVL(vr_sldpresg,0);
          -- Se foi solicitado a impressão de extrado
          IF pr_flgextra THEN
            -- Criar um registro de extrato
            -- Trecho de codigo abaixo não convertido pois durante a
            -- chamada do crps414 que esta sendo convertido no momento
            -- não ha solicitacao de extrato, portanto não haveria como
            -- testar essa necessidade
            NULL;
          END IF;
        EXCEPTION
          WHEN vr_exc_ignora THEN
            -- Este e um raise apenas para direcionar o fluxo
            -- ao final e não executar a aplicacao atual
            NULL;
        END;
      END LOOP; --> Fim das aplicacoes RDCA
      -- Se foi solicitado extrato e estivernos no processo on-line
      IF pr_flgextra AND pr_inproces = 1 THEN
        -- Trecho de codigo abaixo não convertido pois durante a
        -- chamada do crps414 que esta sendo convertido no momento
        -- não e passado a solicitacao de extrato
        -- fontes/atenda_e.p.
        NULL; --> Null apenas para não dar erro na compilacao
      END IF;
      -- Chegou ao final sem problemas
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_calc_sldrda --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_calc_sldrda;

  /* Rotina de calculo do saldo da aplicação ate a data do movimento */
  procedure pc_calc_poupanca (pr_cdcooper  in crapcop.cdcooper%type,          --> Cooperativa
                              pr_dstextab  in craptab.dstextab%type,          --> Percentual de IR da aplicação
                              pr_cdprogra  in crapprg.cdprogra%type,          --> Programa chamador
                              pr_inproces  in crapdat.inproces%type,          --> Indicador do processo
                              pr_dtmvtolt  in crapdat.dtmvtolt%type,          --> Data do processo
                              pr_dtmvtopr  in crapdat.dtmvtopr%type,          --> Próximo dia útil
                              pr_rpp_rowid in varchar2,                       --> Identificador do registro da tabela CRAPRPP em processamento
                              pr_vlsdrdpp  in out craprpp.vlsdrdpp%type,      --> Saldo da poupança programada
                              pr_cdcritic out crapcri.cdcritic%type,          --> Codigo da crítica de erro
                              pr_des_erro out varchar2) is                    --> Descrição do erro encontrado
/* ...........................................................................

   Programa: APLI0001.PC_CALC_POUPANCA (Antigo Includes/poupanca.i)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                       Ultima atualizacao: 19/07/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de calculo do RPP  -- Deve ser chamada de dentro de um
               FOR EACH ou DO WHILE e com label TRANS_POUP.

   Alteracoes: 04/12/96 - No acesso ao TRD complementar os campos do indice
                          (Odair).

               13/12/96 - Alterado para tratar impressao dos extratos (Odair)

               18/02/98 - Alterado para guardar no crapcot o valor abonado
                          (Deborah).

               27/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               12/11/98 - Tratar atendimento noturno (Deborah).

               25/01/99 - Tratar abono do IOF (Deborah).

               24/11/1999 - Taxas por faixa de valores (Deborah).

               16/03/2000 - Atualizar crapcot.vlrentot (Deborah).

               24/10/2003 - Incalcul = 2 somente no aniversario (Margarete).

               03/12/2003 - Atualizar novos campos crapcot para IR (Margarete).

               28/01/2004 - Gerar lançamento de abono e IR sobre o abono
                            no aniversario da aplicacao. E nao atualizar
                            abono da cpmf no crapcot (Margarete).

               23/09/2004 - Incluido histórico 496(CI)(Mirtes)

               03/01/2005 - Nao mostrar saldo negativo nas telas (Margarete).

               06/07/2005 - Alimentado campo cdcooper das tabelas craplot e
                            craplpp (Diego).

               21/07/2005 - Nao calcular rendimento sobre o imposto que
                            falta pagar (Margarete).

               07/10/2005 - Saldo do final do ano deve enxergar o IR sobre
                            o abono da CPMF (Margarete).

               24/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               24/07/2008 - Cria registros na tabela CRAPSPP com informacoes do
                            saldo do aniversario da poupanca (Elton).

               18/01/2011 - Tratar histórico 925 (Db.Trf.Aplic) (Irlan)

               18/12/2012 - Tratar histórico 1115 - Transferencia
                            Viacredi/AltoVale  (Rosangela)

               05/02/2013 - Conversão Progress >> Oracle PL-SQL (Daniel - Supero)

               24/09/2013 - Alterado o cr_craplpp para utilizar IN.

               21/08/2013 - Tratamento para Imunidade Tributaria (Ze).

               10/02/2014 - Ajustes para carregar o find-first da tabela craptrd (Odirlei-AMcom).

               07/04/2014 - Implementado consulta na craptab, referente a data de inicio
                            do novo indexador de poupancao (Jean Michel).

               06/05/2014 - Ajuste feito no insert da craplot, fixo nrdolote = 8384, alterado valor
                            de ajuste, retirado ABS e colocado * -1 quando necessário (Jean Michel) .

               24/06/2014 - Retirada leitura da craptab e incluido data de liberacao do projeto do
                            novo indexador de poupanca fixa - 01/07/2014 (Jean Michel).
                            
               26/06/2015 - Ajuste na definição da variavel vr_dtmvtolt conforme versão progress
                            (Odirlei-AMcom)  
                            
               17/11/2015 - Na verificação da IMUT0001.pc_verifica_imunidade_trib trocado log para
                            proc_message (Lucas Ranghetti #314905)
               
               03/01/2018 - Ajustes na procedure pc_calc_poupanca para contemplar paralelismo do crps148
                            Projeto Ligeirinho - Jonatas Jaqmam (AMcom)
                            
               09/03/2018 - Alteração na forma de gravação da craplpp, utilizar sequence para gerar nrseqdig
                            Projeto Ligeirinho - Jonatas Jaqmam (AMcom)  
                            
               23/06/2018 - Projeto Revitalização Sistemas - Andreatta (MOUTs)
                            Incluido crps147 na lista de programas que nao gravam CRAPTRD             
                                                      
               19/07/2018 - Proj. 411.2 - Aplicação programada
                            Alteração na pc_calc_poupanca para levar em consideração a nova apl. programada     
                                   
                                                      
................................................................................................... */
    -- Variaveis para auxiliar nos calculos
    vr_percenir         number(8,4);
    vr_vlrentot         number(25,8);
    vr_vlrendim         number(25,8);
    vr_vlajuste         number(25,8);
    vr_vlajuste_cr      number(25,8);
    vr_vlajuste_db      number(25,8);
    vr_vlsdrdpp         number(25,8);
    vr_vllan150         craplpp.vllanmto%type;
    vr_vllan152         craplpp.vllanmto%type;
    vr_vllan158         craplpp.vllanmto%type;
    vr_vllan925         craplpp.vllanmto%type;
    vr_vlprovis         number(25,8);
    vr_txaplica         number(25,8);
    vr_txaplmes         number(25,8);
    vr_vlrirrpp         number(25,8);
    vr_dtcalcul         craprpp.dtiniper%type;
    vr_dtrefere         craprpp.dtfimper%type;
    vr_dtultdia         craprpp.dtfimper%type;
    vr_dtmvtolt         crapdat.dtmvtolt%type;
    vr_qtmesext         craprpp.qtmesext%type;
    vr_dtdolote         date;
    vr_nrdolote         number(4);
    vr_cdhistor         number(3);
    vr_cdagenci         craplot.cdagenci%type := 1;
    vr_cdbccxlt         craplot.cdbccxlt%type := 100;
    vr_nrseqdig         craplot.nrseqdig%type;
    vr_cdprogra         VARCHAR2(20);
    vr_flgimune         boolean;
    vr_flggrvir         boolean;
    vr_des_reto         varchar2(10);
    vr_tptaxrda         craptrd.tptaxrda%type;
    
    --Variáveis lote
    rw_craplot          lote0001.cr_craplot_sem_lock%rowtype;


    -- Informações da poupança programada
    cursor cr_craprpp (pr_rowid in varchar2) is
      select /*+ NOPARALLEL */
             craprpp.vlsdrdpp,
             craprpp.dtiniper,
             craprpp.dtfimper,
             nvl(craprpp.vlabcpmf,0) vlabcpmf,
             craprpp.qtmesext,
             craprpp.nrdconta,
             craprpp.nrctrrpp,
             craprpp.vlabdiof,
             craprpp.dtmvtolt,
             craprpp.cdprodut
        from craprpp
       where craprpp.rowid = pr_rowid;
    rw_craprpp     cr_craprpp%rowtype;
    -- Lançamentos da poupança programada
    cursor cr_craplpp is
      select nvl(SUM(decode(craplpp.cdhistor,150,vllanmto,0)),0) vllan150,
             nvl(SUM(decode(craplpp.cdhistor,152,vllanmto,154,vllanmto,155,vllanmto*-1,0)),0) vllan152,
             nvl(SUM(decode(craplpp.cdhistor,158,vllanmto,496,vllanmto,0)),0) vllan158,
             nvl(SUM(decode(craplpp.cdhistor,925,vllanmto,1115,vllanmto,0)),0) vllan925
        from craplpp
       where craplpp.cdcooper  = pr_cdcooper
         and craplpp.nrdconta  = rw_craprpp.nrdconta
         and craplpp.nrctrrpp  = rw_craprpp.nrctrrpp
         and craplpp.dtmvtolt >= vr_dtcalcul
         and craplpp.dtmvtolt <= vr_dtmvtolt
         and craplpp.dtrefere  = vr_dtrefere
         AND craplpp.cdhistor IN (150,152,154,155,158,496,925,1115);
         
    rw_craplpp cr_craplpp%ROWTYPE;

    -- Taxas de RDCA
    cursor cr_craptrd (pr_cdcooper craptrd.cdcooper%type,
                       pr_dtiniper craptrd.dtiniper%type,
                       pr_vlsdrdpp craptrd.vlfaixas%type,
                       pr_tptaxrda craptrd.tptaxrda%type) is
      select craptrd.rowid,
             craptrd.txofidia,
             craptrd.txofimes,
             craptrd.txprodia,
             craptrd.dtfimper
        from craptrd
       where craptrd.cdcooper  = pr_cdcooper
         and craptrd.dtiniper  = pr_dtiniper
         and craptrd.tptaxrda  = pr_tptaxrda
         and craptrd.incarenc  = 0
         and craptrd.vlfaixas <= pr_vlsdrdpp
       order by craptrd.vlfaixas desc; --find first

    rw_craptrd   cr_craptrd%rowtype;
    -- Taxas de RDCA (sem considerar faixa)
    cursor cr_craptrd2 is
      select dtfimper
        from craptrd
       where craptrd.cdcooper = pr_cdcooper
         and craptrd.dtiniper = rw_craprpp.dtfimper
         and craptrd.tptaxrda = 2
         and craptrd.incarenc = 0
         and craptrd.vlfaixas = 0;
    rw_craptrd2    cr_craptrd2%rowtype;
    -- Cotas e recursos
    cursor cr_crapcot is
      select crapcot.rowid
        from crapcot
       where crapcot.cdcooper = pr_cdcooper
         and crapcot.nrdconta = rw_craprpp.nrdconta;
    rw_crapcot     cr_crapcot%rowtype;

  BEGIN
    vr_cdprogra := pr_cdprogra;

    -- Buscar informações da poupança programada
    open cr_craprpp (pr_rpp_rowid);
      fetch cr_craprpp into rw_craprpp;
    close cr_craprpp;
    --
    vr_percenir := gene0002.fn_char_para_number(pr_dstextab);
    vr_vlrentot := 0;
    vr_vlrendim := 0;
    vr_vlajuste := 0;
    vr_vllan150 := 0;
    vr_vllan152 := 0;
    vr_vllan158 := 0;
    vr_vllan925 := 0;
    vr_vlprovis := 0;
    vr_txaplica := 0;
    vr_txaplmes := 0;
    vr_vlrirrpp := 0;
    vr_dtcalcul := rw_craprpp.dtiniper;
    vr_dtrefere := rw_craprpp.dtfimper;
    vr_vlsdrdpp := rw_craprpp.vlsdrdpp;
    -- Define qual data deve utilizar como último dia
    IF vr_cdprogra = 'CRPS147' then
      vr_dtultdia := last_day(add_months(pr_dtmvtolt, -1));
    else
      vr_dtultdia := last_day(add_months(pr_dtmvtopr, -1));
    end if;
    -- Define qual data deve utilizar como data do movimento
    if pr_inproces > 2 AND /* BATCH */
       vr_cdprogra IN ('CRPS147','CRPS148') THEN -- e se forem os programas 
      IF vr_cdprogra = 'CRPS147' then /* MENSAL */
        -- Cálculo até o dia do movimento
        vr_dtmvtolt := pr_dtmvtolt + 1;
      ELSIF vr_cdprogra = 'CRPS148' then /* ANIVERSARIO */
        -- Cálculo até o primeiro dia util a partir do fim do periodo
        vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper
                                                  ,rw_craprpp.dtfimper
                                                  ,pr_tipo     => 'P'     -- valor padrao
                                                  ,pr_feriado  => true    -- valor padrao 
                                                  ,pr_excultdia => true); -- considera 31/12 como util
      end if;
    else /* ONLINE */
      IF vr_cdprogra = 'CRPS156' then /* RESGATE */
        -- Cálculo até o dia do resgate
        vr_dtmvtolt := pr_dtmvtopr;
      else
        -- Cálculo até o dia do movimento
        vr_dtmvtolt := pr_dtmvtolt + 1;
      end if;
    end if;

    -- Leitura dos lançamentos da aplicação
    if rw_craprpp.cdprodut < 1 then -- aplicacao antiga 
    OPEN cr_craplpp;
    FETCH cr_craplpp INTO rw_craplpp;
    IF cr_craplpp%FOUND THEN
      vr_vllan150 := vr_vllan150 + rw_craplpp.vllan150;
      vr_vllan152 := vr_vllan152 + rw_craplpp.vllan152;
      vr_vllan158 := vr_vllan158 + rw_craplpp.vllan158;
      vr_vllan925 := vr_vllan925 + rw_craplpp.vllan925;
    END IF;
    CLOSE cr_craplpp;
        -- Calcula o saldo da poupança
    vr_vlsdrdpp := vr_vlsdrdpp + vr_vllan150 - vr_vllan158 - vr_vllan925;
    else -- Apl. Prog
        apli0008.pc_calc_saldo_apl_prog (pr_cdcooper => pr_cdcooper
                                        ,pr_cdprogra => pr_cdprogra
                                        ,pr_cdoperad => '1'
                                        ,pr_nrdconta => rw_craprpp.nrdconta
                                        ,pr_idseqttl => 1
                                        ,pr_idorigem => 5
                                        ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_vlsdrdpp => vr_vlsdrdpp
                                        ,pr_des_erro => pr_des_erro);

         if pr_des_erro is not null then
           raise vr_exc_erro;
         end if;
    end if;

    if vr_vlsdrdpp < 0 or  vr_vlsdrdpp is null then
      vr_vlsdrdpp := 0;
    end if;
    --

    if pr_inproces > 2 and /* BATCH */
       vr_cdprogra in ('CRPS147','CRPS148') then

      /********************************************************************/
      /** Em maio de 2012 o novo calculo foi liberado para utilizacao,   **/
      /** portanto poupancas cadastradas a partir desta data poderiam    **/
      /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
      /** a nova regra sera utilizada somentepara poupancas cadastradas  **/
      /** apos a liberacao do projeto de novoindexador de poupanca,      **/
      /** pois o passado anterior a liberacaoja foi contratado com a     **/
      /** regra antiga                                                   **/
      /********************************************************************/

      -- Compara da de liberacao do projeto de novo indexador da poupanca
      IF rw_craprpp.dtmvtolt >= to_date('01/07/2014','dd/mm/yyyy') then
        vr_tptaxrda := 4; /*Novo Indexador poupanca - Lei 12.703*/
      ELSE
        vr_tptaxrda := 2; /*Regra Antiga*/
      end IF;

      -- Escolhe a taxa a utilizar
      open cr_craptrd (pr_cdcooper => pr_cdcooper,
                       pr_dtiniper => rw_craprpp.dtiniper,
                       pr_vlsdrdpp => vr_vlsdrdpp,
                       pr_tptaxrda => vr_tptaxrda);
        fetch cr_craptrd into rw_craptrd;
        if cr_craptrd%notfound then
          pr_cdcritic := 347;
          vr_des_erro := gene0001.fn_busca_critica(347)||
                         ' Data: '||to_char(rw_craprpp.dtiniper, 'dd/mm/yyyy')||
                         ' NrCtrRpp: '||to_char(rw_craprpp.nrctrrpp, 'fm999g999g990')||
                         ' Faixa: '||to_char(vr_vlsdrdpp, 'fm999g999g990d00');
          raise vr_exc_erro;
        end if;
      close cr_craptrd;
      if rw_craptrd.txofidia > 0 then
        vr_txaplica := (rw_craptrd.txofidia / 100);
        vr_txaplmes := rw_craptrd.txofimes;
      elsif rw_craptrd.txprodia > 0 then
        vr_txaplica := (rw_craptrd.txprodia / 100);
        vr_txaplmes := 0;
      else
        vr_des_erro := gene0001.fn_busca_critica(427)||
                       ' Data: '||to_char(rw_craprpp.dtiniper, 'dd/mm/yyyy');
        raise vr_exc_erro;
      end if;      
      
      -- Para os programas CRPS147 e 148, foi realizado o upate no próprio crps, visto que teríamos problemas no paralelismo           
      if vr_cdprogra IN('CRPS148','CRPS147') then
        begin

          apli0001.pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper 
                                    ,pr_nrdconta     => rw_craprpp.nrdconta
                                    ,pr_cdprogra     => vr_cdprogra
                                    ,pr_dsrelatorio  => 'CRAPTRD'
                                    ,pr_dtmvtolt     => pr_dtmvtolt
                                    ,pr_dschave      => rw_craptrd.rowid
                                    ,pr_dsinformacao => null 
                                    ,pr_dscritic     => vr_des_erro);          
        
          if vr_des_erro is not null then
            raise vr_exc_erro; 
          end if;
        
        exception
          when others then
            vr_des_erro := 'Erro ao chamar procedure apli0001.pc_insere_tab_wrk: '||sqlerrm;
            raise vr_exc_erro;              
        end;
      else
        -- Atualiza o indicador de cálculo
        begin
          update craptrd
             set incalcul = 1
           where rowid = rw_craptrd.rowid;
        exception
          when others then
            vr_des_erro := 'Erro ao atualizar indicador de calculo na craptrd: '||sqlerrm;
            raise vr_exc_erro;
        end;
      end if;
    end if;

    --
    if pr_inproces > 2 and
       vr_cdprogra in ('CRPS147', 'CRPS148') and
       vr_dtcalcul < vr_dtmvtolt and
       vr_vlsdrdpp > 0 then
      -- Acrescenta o rendimento para o período VR_DTCALCUL ate VR_DTMVTOLT
      while vr_dtcalcul < vr_dtmvtolt loop
        -- Busca o próximo dia útil
        vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper
                                                  ,vr_dtcalcul
                                                  ,pr_tipo     => 'P'     -- valor padrao
                                                  ,pr_feriado  => true    -- valor padrao 
                                                  ,pr_excultdia => true); -- considera 31/12 como util
        if vr_dtcalcul >= vr_dtmvtolt then
          exit;
        end if;
        -- Incrementa os valores
        vr_vlrendim := trunc(vr_vlsdrdpp * vr_txaplica, 8);
        vr_vlsdrdpp := vr_vlsdrdpp + vr_vlrendim;
        vr_vlrentot := vr_vlrentot + vr_vlrendim;
        if vr_dtcalcul <= vr_dtultdia then
          vr_vlprovis := vr_vlprovis + vr_vlrendim;
        end if;
        -- Próxima data
        vr_dtcalcul := vr_dtcalcul + 1;
      end loop;  /* Fim do WHILE */
    end if;      

    /*  Arredondamento dos valores calculados  */
    vr_vlsdrdpp := fn_round(vr_vlsdrdpp,2);
    vr_vlrentot := fn_round(vr_vlrentot,2);
    vr_vlprovis := fn_round(vr_vlprovis,2);
    vr_vlrirrpp := trunc((vr_vlrentot * vr_percenir / 100),2);

    /* Tratamento para Imunidade Tributaria */
    IF pr_inproces > 2  AND upper(pr_cdprogra) = 'CRPS148'   THEN
      vr_flggrvir := TRUE;
    ELSE
      vr_flggrvir := FALSE;
    END IF;

    /* Procedure para verificar imunidade tributaria e inserir valor de insenção */
    IMUT0001.pc_verifica_imunidade_trib(  pr_cdcooper  => pr_cdcooper  --> Codigo Cooperativa
                                         ,pr_nrdconta  => rw_craprpp.nrdconta  --> Numero da Conta
                                         ,pr_dtmvtolt  => pr_dtmvtolt  --> Data movimento
                                         ,pr_flgrvvlr  => vr_flggrvir  --> Identificador se deve gravar valor
                                         ,pr_cdinsenc  => 5            --> Codigo da insenção
                                         ,pr_vlinsenc  => TRUNC((vr_vlrentot *
                                                                 vr_percenir / 100),2)--> Valor insento
                                         ,pr_flgimune  => vr_flgimune  --> Identificador se é imune
                                         ,pr_dsreturn  => vr_des_reto  --> Descricao Critica
                                         ,pr_tab_erro  => vr_tab_erro);--> Tabela erros

    -- Se retornar alguma mensagem de erro
    IF vr_tab_erro.COUNT() > 0 THEN
      -- Mostrar mensagem de log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || pr_cdprogra || ' --> '
                                                 || vr_tab_erro(vr_tab_erro.FIRST).dscritic);

      -- Limpeza dos erros
      vr_tab_erro.DELETE;
    END IF;

    IF vr_flgimune THEN
      vr_vlrirrpp := 0;
    ELSE
      vr_vlrirrpp := trunc((vr_vlrentot * vr_percenir / 100),2);
    END IF;

    -- Ajusta o saldo da poupança programada
    if pr_inproces = 1 and
       vr_flgimune = false then
      vr_vlsdrdpp := vr_vlsdrdpp - trunc((rw_craprpp.vlabcpmf * vr_percenir / 100), 2);
      if vr_vlsdrdpp < 0 then
        vr_vlsdrdpp := 0;
      end if;
    end if;
    -- Atualiza a variável de retorno
    pr_vlsdrdpp := vr_vlsdrdpp;
    --
    if pr_inproces > 2 then
      IF vr_cdprogra = 'CRPS147' then /* MENSAL */
        vr_dtdolote := pr_dtmvtolt;
        vr_nrdolote := 8383;
        vr_cdhistor := 152;
        -- Atualiza indicadores da poupança programada
        begin
          update craprpp
             set incalmes = 0,
                 indebito = 0
           where craprpp.rowid = pr_rpp_rowid;
        exception
          when others then
            vr_des_erro := 'Erro ao atualizar indicadores da poupança programada: '||sqlerrm;
            raise vr_exc_erro;
        end;
      ELSIF vr_cdprogra = 'CRPS148' then /* ANIVERSARIO */
        -- Busca a taxa RDCA
        open cr_craptrd2;
          fetch cr_craptrd2 into rw_craptrd2;
          if cr_craptrd2%notfound then
            close cr_craptrd2;
            vr_des_erro := gene0001.fn_busca_critica(347)||
                           ' Data: '||to_char(rw_craprpp.dtfimper, 'dd/mm/yyyy')||
                           ' Conta: '||to_char(rw_craprpp.nrdconta, '9999G999D0')||
                           ' NrCtrRpp: '||to_char(rw_craprpp.nrctrrpp, '999g999');
            raise vr_exc_erro;
          end if;
        close cr_craptrd2;
        --
        vr_qtmesext := rw_craprpp.qtmesext + 1;
        if vr_qtmesext = 4 then
          vr_qtmesext := 1;
        end if;
        if to_char(rw_craprpp.dtfimper, 'mm') = '12' then
          vr_qtmesext := 3;
        end if;
        -- Atualiza poupança programada
        begin
          update craprpp
             set craprpp.qtmesext = vr_qtmesext,
                 craprpp.dtiniext = decode(vr_qtmesext,
                                           1, craprpp.dtfimext,
                                           craprpp.dtiniext),
                 craprpp.dtsdppan = decode(vr_qtmesext,
                                           1, craprpp.dtiniper,
                                           craprpp.dtsdppan),
                 craprpp.vlsdppan = decode(vr_qtmesext,
                                           1, craprpp.vlsdrdpp,
                                           craprpp.vlsdppan),
                 craprpp.incalmes = 1,
                 craprpp.dtfimext = craprpp.dtfimper,
                 craprpp.dtiniper = craprpp.dtfimper,
                 craprpp.dtfimper = rw_craptrd2.dtfimper,
                 craprpp.vlsdrdpp = pr_vlsdrdpp - vr_vlrirrpp,
                 craprpp.dtcalcul = pr_dtmvtopr
           where craprpp.rowid = pr_rpp_rowid;
        exception
          when others then
            vr_des_erro := 'Erro ao atualizar informações da poupança programada: '||sqlerrm;
            raise vr_exc_erro;
        end;
        --
        vr_dtdolote := pr_dtmvtopr;
        vr_nrdolote := 8384;
        vr_cdhistor := 151;
        --Para o CRPS148, vamos informar a agêcia executada no paralelismo
        --e montar a chave para buscar o nrseqdig por ela.
        --
        if rw_craprpp.vlabcpmf > 0 then
          begin
            -- Atualiza o saldo da poupança programada
            update craprpp
               set craprpp.vlsdrdpp = craprpp.vlsdrdpp - trunc((craprpp.vlabcpmf * vr_percenir / 100),2)
             where craprpp.rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar saldo da poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
        --
        if to_char(rw_craptrd2.dtfimper, 'mmyyyy') = to_char(pr_dtmvtopr, 'mmyyyy') then
          begin
            -- Atualiza o indicador de cálculo no mês
            update craprpp
               set craprpp.incalmes = 0
             where craprpp.rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar indicador de calculo no mes na poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
        -- Lê novamente as informações da craprpp para recuperar os valores atualizados
        open cr_craprpp (pr_rpp_rowid);
          fetch cr_craprpp into rw_craprpp;
        close cr_craprpp;
        --
        begin
          update crapspp
             set crapspp.vlsldrpp = rw_craprpp.vlsdrdpp,
                 crapspp.dtmvtolt = pr_dtmvtolt
           where crapspp.cdcooper = pr_cdcooper
             and crapspp.nrdconta = rw_craprpp.nrdconta
             and crapspp.nrctrrpp = rw_craprpp.nrctrrpp
             and crapspp.dtsldrpp = rw_craprpp.dtiniper;
          --
          if sql%rowcount = 0 then
            -- Não encontrou registro para atualizar, portanto deve incluir um novo
            begin
              insert into crapspp (cdcooper,
                                   nrdconta,
                                   nrctrrpp,
                                   dtsldrpp,
                                   vlsldrpp,
                                   dtmvtolt)
              values (pr_cdcooper,
                      rw_craprpp.nrdconta,
                      rw_craprpp.nrctrrpp,
                      rw_craprpp.dtiniper,
                      rw_craprpp.vlsdrdpp,
                      pr_dtmvtolt);
            exception
              when others then
                vr_des_erro := 'Erro ao inserir saldo da poupança programada no aniversario: '||sqlerrm;
                raise vr_exc_erro;
            end;
          end if;
        exception
          when vr_exc_erro then
            raise vr_exc_erro;
          when others then
            vr_des_erro := 'Erro ao atualizar saldo da poupança programada no aniversario: '||sqlerrm;
            raise vr_exc_erro;
        end;
      end if;
      --
      IF vr_cdprogra = 'CRPS147' then
        vr_vlrentot := vr_vlrentot - vr_vlprovis;
      end if;
      --
      if vr_vlrentot > 0 then
          -- Atualizar o tipo do lote
        /* Projeto Revitalizacao - Remocao de lote */
        lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                  , pr_dtmvtolt => vr_dtdolote
                                  , pr_cdagenci => vr_cdagenci
                                  , pr_cdbccxlt => vr_cdbccxlt
                                  , pr_nrdolote => vr_nrdolote
                                  , pr_cdoperad => '1'
                                  , pr_nrdcaixa => 0
                                  , pr_tplotmov => 14
                                  , pr_cdhistor => 0
                                  , pr_craplot  => rw_craplot
                                  , pr_dscritic => vr_dscritic);
        
        if vr_dscritic is not null then
          vr_des_erro := 'Erro ao inserir informações da capa de lote: '||vr_dscritic;
                raise vr_exc_erro;
          end if;
        
        --Se for CRPS147 E 148 utilizar chave do lote 8384 para adicionar os lançamentos.
        --Tratado de forma diferente devido paralelismo

        /* Projeto Revitalizacao - Remocao de lote */
        vr_nrseqdig := fn_sequence('CRAPLOT'
						                      ,'NRSEQDIG'
                    						  ,''||pr_cdcooper||';'
                    							 ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
                    							 ||vr_cdagenci||';'
							                     ||vr_cdbccxlt||';'
							                     ||vr_nrdolote);

        -- Cria um novo lançamento de poupança programada
        begin
          insert into craplpp (dtmvtolt,
                               cdagenci,
                               cdbccxlt,
                               nrdolote,
                               nrdconta,
                               nrctrrpp,
                               nrdocmto,
                               txaplica,
                               txaplmes,
                               cdhistor,
                               nrseqdig,
                               vllanmto,
                               dtrefere,
                               cdcooper)
          values (vr_dtdolote,
                  vr_cdagenci,
                  vr_cdbccxlt,
                  vr_nrdolote,
                  rw_craprpp.nrdconta,
                  rw_craprpp.nrctrrpp,
                  vr_nrseqdig,
                  (NVL(vr_txaplica, 0) * 100),
                  NVL(vr_txaplmes, 0),
                  vr_cdhistor,
                  vr_nrseqdig,
                  vr_vlrentot,
                  vr_dtrefere,
                  pr_cdcooper);
        exception
          when others then
            vr_des_erro := 'Erro ao inserir lançamento de poupança programada: '||sqlerrm;
            raise vr_exc_erro;
        end;  
        
        /* Projeto Revitalizacao - Remocao de lote */
          
        --
        IF vr_cdprogra = 'CRPS148' and
           vr_vlrirrpp > 0 then
           
          --Se for CRPS148 utilizar chave do lote 8384 para adicionar os lançamentos.
          vr_nrseqdig := fn_sequence('CRAPLOT'
                                    ,'NRSEQDIG'
                                    ,''||pr_cdcooper||';'
                                     ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
                                     ||vr_cdagenci||';'
                                     ||vr_cdbccxlt||';'
                                     ||vr_nrdolote);
           
          -- Cria o lançamento 863 na poupança programada
          begin
            insert into craplpp (dtmvtolt,
                                 cdagenci,
                                 cdbccxlt,
                                 nrdolote,
                                 nrdconta,
                                 nrctrrpp,
                                 nrdocmto,
                                 txaplica,
                                 txaplmes,
                                 cdhistor,
                                 nrseqdig,
                                 vllanmto,
                                 dtrefere,
                                 cdcooper)
            values (vr_dtdolote,
                    vr_cdagenci,
                    vr_cdbccxlt,
                    vr_nrdolote,
                    rw_craprpp.nrdconta,
                    rw_craprpp.nrctrrpp,
                    vr_nrseqdig,
                    vr_percenir,
                    vr_percenir,
                    863,
                    vr_nrseqdig,
                    vr_vlrirrpp,
                    vr_dtrefere,
                    pr_cdcooper);
          exception
            when others then
              vr_des_erro := 'Erro ao inserir o histórico 863 na poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
      end if;
      --     
      
      IF vr_cdprogra = 'CRPS148' and
         vr_cdhistor = 151 and
         (vr_vlrentot > 0 or
          rw_craprpp.vlabdiof > 0 or
          vr_vlrirrpp > 0) then
        -- Busca as informações de cotas e recursos
        open cr_crapcot;
          fetch cr_crapcot into rw_crapcot;
          if cr_crapcot%notfound then
            close cr_crapcot;
            pr_cdcritic := 169;
            vr_des_erro := gene0001.fn_busca_critica(169)||
                           ' Conta: '||to_char(rw_craprpp.nrdconta, '9999G999D0');
            raise vr_exc_erro;
          end if;
        close cr_crapcot;
        --
        if vr_vlrentot > 0 then
          -- Atualiza os juros acumulados da poupança programada
          begin
            update craprpp
               set craprpp.vljuracu = craprpp.vljuracu + vr_vlrentot
             where craprpp.rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar os juros acumulados da poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
          -- Atualiza cotas e recursos (somente os campos correspondentes ao mês de referência)
          begin
            update crapcot
               set crapcot.vlrenrpp = crapcot.vlrenrpp + vr_vlrentot,
                   crapcot.vlrenrpp_ir##1 = crapcot.vlrenrpp_ir##1 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '01', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##1 = crapcot.vlrentot##1 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '01', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##2 = crapcot.vlrenrpp_ir##2 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '02', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##2 = crapcot.vlrentot##2 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '02', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##3 = crapcot.vlrenrpp_ir##3 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '03', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##3 = crapcot.vlrentot##3 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '03', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##4 = crapcot.vlrenrpp_ir##4 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '04', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##4 = crapcot.vlrentot##4 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '04', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##5 = crapcot.vlrenrpp_ir##5 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '05', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##5 = crapcot.vlrentot##5 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '05', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##6 = crapcot.vlrenrpp_ir##6 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '06', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##6 = crapcot.vlrentot##6 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '06', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##7 = crapcot.vlrenrpp_ir##7 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '07', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##7 = crapcot.vlrentot##7 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '07', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##8 = crapcot.vlrenrpp_ir##8 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '08', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##8 = crapcot.vlrentot##8 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '08', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##9 = crapcot.vlrenrpp_ir##9 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '09', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##9 = crapcot.vlrentot##9 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '09', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##10 = crapcot.vlrenrpp_ir##10 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '10', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##10 = crapcot.vlrentot##10 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '10', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##11 = crapcot.vlrenrpp_ir##11 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '11', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##11 = crapcot.vlrentot##11 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '11', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##12 = crapcot.vlrenrpp_ir##12 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '12', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##12 = crapcot.vlrentot##12 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '12', vr_vlrentot,
                                                                      0)
             where crapcot.rowid = rw_crapcot.rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar cotas e recursos (1): '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
        --
        if rw_craprpp.vlabdiof > 0 then
          -- Atualiza os campos correspondentes ao mês de referência
          begin
            update crapcot
               set crapcot.vlabiopp = crapcot.vlabiopp + rw_craprpp.vlabdiof,
                   crapcot.vlrentot##1 = crapcot.vlrentot##1 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '01', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##2 = crapcot.vlrentot##2 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '02', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##3 = crapcot.vlrentot##3 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '03', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##4 = crapcot.vlrentot##4 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '04', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##5 = crapcot.vlrentot##5 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '05', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##6 = crapcot.vlrentot##6 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '06', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##7 = crapcot.vlrentot##7 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '07', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##8 = crapcot.vlrentot##8 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '08', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##9 = crapcot.vlrentot##9 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '09', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##10 = crapcot.vlrentot##10 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '10', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##11 = crapcot.vlrentot##11 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '11', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##12 = crapcot.vlrentot##12 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '12', rw_craprpp.vlabdiof,
                                                                      0)
             where crapcot.rowid = rw_crapcot.rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar cotas e recursos (2): '||sqlerrm;
              raise vr_exc_erro;
          end;
          -- Zerar o abono de IOF
          begin
            update craprpp
               set craprpp.vlabdiof = 0
             where craprpp.rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao zerar o abono de IOF na poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
        --
        if vr_vlrentot - vr_vlprovis > 0 then

          --Se for CRPS148 utilizar chave do lote 8384 para adicionar os lançamentos.
          vr_nrseqdig := fn_sequence('CRAPLOT'
						                        ,'NRSEQDIG'
						                        ,''||pr_cdcooper||';'
							                       ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
							                       ||vr_cdagenci||';'
							                       ||vr_cdbccxlt||';'
							                       ||vr_nrdolote);
        
          
          -- Insere o histórico 152 nos lançamentos da poupança programada
          begin
            insert into craplpp (dtmvtolt,
                                 cdagenci,
                                 cdbccxlt,
                                 nrdolote,
                                 nrdconta,
                                 nrctrrpp,
                                 nrdocmto,
                                 txaplica,
                                 txaplmes,
                                 cdhistor,
                                 nrseqdig,
                                 vllanmto,
                                 dtrefere,
                                 cdcooper)
            values (vr_dtdolote,
                    vr_cdagenci,
                    vr_cdbccxlt,
                    vr_nrdolote,
                    rw_craprpp.nrdconta,
                    rw_craprpp.nrctrrpp,
                    vr_nrseqdig,
                    (NVL(vr_txaplica, 0) * 100),
                    NVL(vr_txaplmes, 0),
                    152,
                    vr_nrseqdig,
                    vr_vlrentot - vr_vlprovis,
                    vr_dtrefere,
                    pr_cdcooper);
          exception
            when others then
              vr_des_erro := 'Erro ao inserir o histórico 152 nos lançamentos da poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
      end if;
      --        
      
      IF vr_cdprogra = 'CRPS148' and
         rw_craprpp.vlabcpmf > 0 then

        --Se for CRPS148 utilizar chave do lote 8384 para adicionar os lançamentos.
        vr_nrseqdig := fn_sequence('CRAPLOT'
						                      ,'NRSEQDIG'
						                      ,''||pr_cdcooper||';'
							                     ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
							                     ||vr_cdagenci||';'
							                     ||vr_cdbccxlt||';'
							                     ||vr_nrdolote);    
        
        -- Insere histórico 869 nos lançamentos da poupança programada
        begin
          insert into craplpp (dtmvtolt,
                               cdagenci,
                               cdbccxlt,
                               nrdolote,
                               nrdconta,
                               nrctrrpp,
                               nrdocmto,
                               txaplica,
                               txaplmes,
                               cdhistor,
                               nrseqdig,
                               vllanmto,
                               dtrefere,
                               cdcooper)
          values (vr_dtdolote,
                  vr_cdagenci,
                  vr_cdbccxlt,
                  vr_nrdolote,
                  rw_craprpp.nrdconta,
                  rw_craprpp.nrctrrpp,
                  vr_nrseqdig,
                  (NVL(vr_txaplica, 0) * 100),
                  NVL(vr_txaplmes, 0),
                  869,
                  vr_nrseqdig,
                  rw_craprpp.vlabcpmf,
                  vr_dtrefere,
                  pr_cdcooper);
        exception
          when others then
            vr_des_erro := 'Erro ao inserir o histórico 866 nos lançamentos da poupança programada: '||sqlerrm;
            raise vr_exc_erro;
        end;
        
        /* IR sobre o abono de cpmf na poupança */
        if trunc((rw_craprpp.vlabcpmf * vr_percenir / 100),2) > 0 then
          
          --Se for CRPS148 utilizar chave do lote 8384 para adicionar os lançamentos.
          vr_nrseqdig := fn_sequence('CRAPLOT'
						                        ,'NRSEQDIG'
  						                      ,''||pr_cdcooper||';'
	  						                     ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
		  					                     ||vr_cdagenci||';'
			   				                     ||vr_cdbccxlt||';'
				  			                     ||vr_nrdolote);
          
          -- Inserir o histórico 866 nos lançamentos da poupança programada
          begin
            insert into craplpp (dtmvtolt,
                                 cdagenci,
                                 cdbccxlt,
                                 nrdolote,
                                 nrdconta,
                                 nrctrrpp,
                                 nrdocmto,
                                 txaplica,
                                 txaplmes,
                                 cdhistor,
                                 nrseqdig,
                                 vllanmto,
                                 dtrefere,
                                 cdcooper)
            values (vr_dtmvtolt,
                    vr_cdagenci,
                    vr_cdbccxlt,
                    vr_nrdolote,
                    rw_craprpp.nrdconta,
                    rw_craprpp.nrctrrpp,
                    vr_nrseqdig,
                    vr_percenir,
                    vr_percenir,
                    870,
                    vr_nrseqdig,
                    trunc((rw_craprpp.vlabcpmf * vr_percenir / 100),2),
                    vr_dtrefere,
                    pr_cdcooper);
          exception
            when others then
              vr_des_erro := 'Erro ao inserir o histórico 870 nos lançamentos da poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
          
          -- Zera o abono de cpfm na poupança programada
          begin
            update craprpp
               set vlabcpmf = 0
             where rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao zerar o abono de cpmf na poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
      end if;
      --       
      if vr_cdprogra in ('CRPS147', 'CRPS148') then
        /* Ajuste */
        vr_vlajuste := vr_vlprovis - vr_vllan152;
        --
        if vr_vlajuste <> 0 then
          -- Define qual histórico será utilizado
          if vr_vlajuste > 0 then
            vr_cdhistor := 154;
            vr_vlajuste_cr := abs(vr_vlajuste);
            vr_vlajuste_db := 0;
          else
            vr_cdhistor := 155;
            vr_vlajuste_cr := 0;
            vr_vlajuste_db := abs(vr_vlajuste);
          end if;

          -- Para lote 8384 utilizar sequence da tabela de lote.
          vr_nrseqdig := fn_sequence('CRAPLOT'
						                        ,'NRSEQDIG'
  						                      ,''||pr_cdcooper||';'
	  						                     ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
		  					                     ||vr_cdagenci||';'
			  				                     ||vr_cdbccxlt||';'
				  			                     ||vr_nrdolote);
          
          -- Insere histórico de ajuste nos lançamentos da poupança programada
          begin
            insert into craplpp (dtmvtolt,
                                 cdagenci,
                                 cdbccxlt,
                                 nrdolote,
                                 nrdconta,
                                 nrctrrpp,
                                 nrdocmto,
                                 txaplica,
                                 txaplmes,
                                 cdhistor,
                                 nrseqdig,
                                 vllanmto,
                                 dtrefere,
                                 cdcooper)
            values (vr_dtdolote,
                    vr_cdagenci,
                    vr_cdbccxlt,
                    8384,
                    rw_craprpp.nrdconta,
                    rw_craprpp.nrctrrpp,
                    NVL(vr_nrseqdig,0),
                    (NVL(vr_txaplica, 0) * 100),
                    NVL(vr_txaplmes, 0),
                    vr_cdhistor,
                    NVL(vr_nrseqdig,0),
                    abs(vr_vlajuste),
                    vr_dtrefere,
                    pr_cdcooper);
          exception
            when others then
              vr_des_erro := 'Erro ao inserir o histórico '||vr_cdhistor||' nos lançamentos da poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
      end if;
    end if;    
  exception
    when vr_exc_erro THEN
      pr_cdcritic := nvl(pr_cdcritic,0);
      pr_des_erro := vr_des_erro;
    when others then
      pr_cdcritic := 0;
      pr_des_erro := 'Erro ao fazer o cálculo da poupança para a conta '||rw_craprpp.nrdconta||': '||sqlerrm;
  end pc_calc_poupanca;

  /* Rotina de calculo do ajuste da provisao a estornar nos casos de resgate antes do vencimento. */
  PROCEDURE pc_ajuste_provisao_rdc_pre (pr_cdcooper   IN crapcop.cdcooper%TYPE        --> Cooperativa
                                       ,pr_cdagenci   IN crapass.cdagenci%TYPE        --> Codigo da agencia
                                       ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE        --> Numero do caixa
                                       ,pr_nrctaapl   IN craprda.nrdconta%TYPE        --> Numero da Conta
                                       ,pr_nraplres   IN craprda.nraplica%TYPE        --> Numero da Aplicacao
                                       ,pr_vllanmto   IN NUMBER                       --> Valor movimento
                                       ,pr_vlestprv   IN OUT NUMBER                   --> Valor previsto
                                       ,pr_des_reto   OUT VARCHAR                     --> Indicador de saida com erro (OK/NOK)
                                       ,pr_tab_erro   OUT GENE0001.typ_tab_erro ) IS  --> Tabela com erros
   --  .......................................................................................
   --
   -- Programa: pc_ajuste_provisao_rdc_pre - Antiga (b1wgen0004.ajuste_provisao_rdc_pre)
   -- Autor   : Junior
   -- Data    : 12/09/2005.                        Ultima atualizacao: 08/01/2015
   --
   -- Dados referentes ao programa:
   --
   -- Objetivo  : BO CONSULTA SALDO E EXTRATO DE APLICACOES
   --             Baseada no programa fontes/impextrda.p.
   --             Rotina de calculo do ajuste da provisao a estornar nos casos
   --             de resgate antes do vencimento.
   --
   -- Alteracoes: 04/01/2013 - conversão Progress >> PL/SQL (Oracle). Petter - Supero.
   --
   --             08/01/2015 - Ajustar a validação de dia util e valor de resgate, pois
   --                          o else pertence a validação do valor de resgate e não ao
   --                          dia util. Alterar parametro pr_vllanmto somente para IN e
   --                          utilizar uma variável local para cálculo 
   --                          (Douglas - Chamado 239950)
   -- .......................................................................................
  BEGIN
    DECLARE
      vr_exc_saida  EXCEPTION;
      vr_dtmvtolt   DATE;
      vr_dtultdia   DATE;
      vr_txaplica   NUMBER(11,8);
      vr_vlrendim   NUMBER(11,8);
      vr_vllanmto   craplap.vllanmto%TYPE;
      vr_controle   EXCEPTION;

      -- Lancamento de aplicacoes RDCA
      CURSOR cr_craplap (pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Codigo da cooperativa
                        ,pr_nrdconta  IN craprda.nrdconta%TYPE        --> Numero da conta
                        ,pr_nraplica  IN craprda.nraplica%TYPE        --> Numero da aplicacao
                        ,pr_dtmvtolt  IN craprda.dtmvtolt%TYPE        --> Data movimento atual
                        ,pr_cdhistor  IN NUMBER                       --> Historico
                        ,pr_cdhistor1 IN NUMBER) IS                   --> Historico de controle
        SELECT cl.txaplica
              ,cl.vllanmto
              ,cl.cdhistor
              ,cl.rowid
        FROM craplap cl
        WHERE cl.cdcooper = pr_cdcooper
          AND cl.nrdconta = pr_nrdconta
          AND cl.nraplica = pr_nraplica
          AND cl.dtmvtolt = nvl(pr_dtmvtolt, cl.dtmvtolt)
          AND (cl.cdhistor = nvl(pr_cdhistor, cl.cdhistor)
            OR cl.cdhistor = nvl(pr_cdhistor1, cl.cdhistor));
      rw_craplap cr_craplap%ROWTYPE;

    BEGIN
      -- Inicializacao de variaveis
      pr_vlestprv := 0;

      -- Utilizamos uma variável para realizar os cálculos
      vr_vllanmto := pr_vllanmto;

      -- Busca aplicacoes RDCA
      OPEN cr_craprda (pr_cdcooper, pr_nrctaapl, pr_nraplres);
      FETCH cr_craprda INTO rw_craprda;

      -- Se não localizar registro sinaliza critica
      -- Se localizar registros faz a carga de valores para variaveis
      IF cr_craprda%notfound OR rw_craprda.retorno > 1 THEN
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => 426
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';
        CLOSE cr_craprda;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_craprda;
      END IF;

      vr_dtmvtolt := rw_craprda.dtmvtolt;
      vr_dtultdia := rw_craprda.dtatslmx;

      IF vr_dtultdia IS NOT NULL THEN
        IF vr_vllanmto != rw_craprda.vlsdrdca THEN
          -- Buscas as taxas contratadas
          OPEN cr_craplap(pr_cdcooper, rw_craprda.nrdconta, rw_craprda.nraplica, rw_craprda.dtmvtolt, NULL, NULL);
          FETCH cr_craplap INTO rw_craplap;

          -- Se não localizar taxas contratadas sinaliza critica
          IF cr_craplap%notfound THEN
            -- Chamar rotina de gravacao de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1
                                 ,pr_cdcritic => 90
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);

            pr_des_reto := 'NOK';

            CLOSE cr_craplap;
            RAISE vr_exc_saida;
          ELSE
            -- Calcula taxa aplicada
            vr_txaplica := NVL(rw_craplap.txaplica, 0) / 100;
            CLOSE cr_craplap;
          END IF;

          WHILE vr_dtmvtolt < vr_dtultdia
          LOOP
            BEGIN
              vr_dtmvtolt := gene0005.fn_valida_dia_util(1
                                                        ,vr_dtmvtolt
                                                        ,pr_tipo     => 'P'     -- valor padrao
                                                        ,pr_feriado  => true    -- valor padrao 
                                                        ,pr_excultdia => true); -- considera 31/12 como util

              IF vr_dtmvtolt >= vr_dtultdia THEN
                RAISE vr_controle;
              END IF;

              -- Atribui valores para as variaveis
              vr_vlrendim := trunc(vr_vllanmto * vr_txaplica, 8);
              vr_vllanmto := vr_vllanmto + vr_vlrendim;
              pr_vlestprv := pr_vlestprv + vr_vlrendim;
              vr_dtmvtolt := vr_dtmvtolt + 1;
            EXCEPTION
              WHEN vr_controle THEN
                -- Controle do fluxo do WHILE
                NULL;
            END;
          END LOOP;

          -- condicao de saida do loop
          pr_vlestprv := fn_round(pr_vlestprv, 2);
        ELSE
          -- Quando resgate total reverter todas as provisões
          -- Testa para condicoes especificas do historico
          FOR vr_craplap IN cr_craplap(pr_cdcooper, rw_craprda.nrdconta, rw_craprda.nraplica, NULL, 474, 463) LOOP
            IF vr_craplap.cdhistor = 474 THEN
              pr_vlestprv := pr_vlestprv + vr_craplap.vllanmto;
            ELSIF vr_craplap.cdhistor = 463 THEN
              pr_vlestprv := pr_vlestprv - vr_craplap.vllanmto;
            END IF;
          END LOOP;
        END IF;
      END IF;

      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN others THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        vr_dscritic := 'APLI0001.pc_ajuste_provisao_rdc_pre --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_ajuste_provisao_rdc_pre;

  /* Gera lancamentos no craplap referentes a RDCPRE e a RDCPOS para credito e debito */
  PROCEDURE pc_gera_craplap_rdc (pr_cdcooper   IN craplap.cdcooper%TYPE      --> Cooperativa                                
                                ,pr_dtmvtolt   IN craplap.dtmvtolt%TYPE      --> Data do movimento
                                ,pr_cdagenci   IN craplap.cdagenci%TYPE      --> Numero agencia
                                ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE      --> Numero do caixa
                                ,pr_cdbccxlt   IN craplap.cdbccxlt%TYPE      --> Caixa/Agencia
                                ,pr_nrdolote   IN craplap.nrdolote%TYPE      --> Numero lote
                                ,pr_nrdconta   IN craplap.nrdconta%TYPE      --> Numero da conta
                                ,pr_nraplica   IN craplap.nraplica%TYPE      --> Numero da aplicacao
                                ,pr_nrdocmto   IN craplap.nrdocmto%TYPE      --> Numero do documento
                                ,pr_txapllap   IN craplap.txaplica%TYPE      --> Taxa aplicada
                                ,pr_cdhistor   IN craplap.cdhistor%TYPE      --> Historico
                                ,pr_nrseqdig   IN OUT craplap.nrseqdig%TYPE  --> Digito de sequencia
                                ,pr_vllanmto   IN NUMBER                     --> Valor de lancamento
                                ,pr_dtrefere   IN craplap.dtrefere%TYPE      --> Data de referencia
                                ,pr_vlrendmm   IN NUMBER                     --> Valor Rendimento
                                ,pr_tipodrdb   IN VARCHAR2                   --> Indicador de debito ou credito
                                ,pr_rowidlot   IN ROWID                      --> Identificador de registro CRAPLOT
                                ,pr_rowidlap   IN OUT ROWID                  --> Identificador de registro CRAPLAP
                                ,pr_vlinfodb   IN OUT NUMBER                 --> Total a debito
                                ,pr_vlcompdb   IN OUT NUMBER                 --> Total a debito comp.
                                ,pr_qtinfoln   IN OUT craplot.qtinfoln%TYPE  --> Total de lancamentos
                                ,pr_qtcompln   IN OUT craplot.qtcompln%TYPE  --> Total de lancamentos comp.
                                ,pr_vlinfocr   IN OUT NUMBER                 --> Total a credtio
                                ,pr_vlcompcr   IN OUT NUMBER                 --> Total a credtio comp.
                                ,pr_des_reto   IN OUT VARCHAR2               --> Retorno da execucao da procedure
                                ,pr_tab_erro   OUT GENE0001.typ_tab_erro     --> Tabela de erros
                                ,pr_cdoperad   IN crapope.cdoperad%TYPE DEFAULT 0) IS --> Operador
   --  .......................................................................................
   --
   -- Programa: pc_gera_craplap_rdc Antigas (Includes/gera_craplap_rdc_debito.i
   --                                        Includes/gera_craplap_rdc_credito.i)
   --
   -- Sistema : Conta-Corrente - Cooperativa de Credito
   -- Sigla   : CRED
   -- Autor   : Margarete/David
   -- Data    : Maio/2007.                        Ultima atualizacao: 11/01/2013
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: Diario (on-line)
   -- Objetivo  : Gera lancamentos no craplap referentes a RDCPRE e a RDCPOS
   --             tanto para credito ou debito.
   --
   -- Alteracoes: 04/01/2013 - conversão Progress >> PL/SQL (Oracle). Petter - Supero.
   --
   --             11/01/2013 - Adicionada a funcao de update para credito.
   -- .......................................................................................

  BEGIN
    DECLARE
        vr_exc_erro    EXCEPTION;      --> Para controle de excecao personalizado
    BEGIN
      -- Lancamento na CRAPLAP e unico para credito e debito
      BEGIN
        INSERT INTO craplap(cdcooper
                           ,dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,nrdconta
                           ,nraplica
                           ,nrdocmto
                           ,txaplica
                           ,txaplmes
                           ,cdhistor
                           ,nrseqdig
                           ,vllanmto
                           ,dtrefere
                           ,vlrendmm)
          VALUES(pr_cdcooper
                ,pr_dtmvtolt
                ,pr_cdagenci
                ,pr_cdbccxlt
                ,pr_nrdolote
                ,pr_nrdconta
                ,pr_nraplica
                ,pr_nrdocmto + 555000
                ,pr_txapllap
                ,pr_txapllap
                ,pr_cdhistor
                ,NVL(pr_nrseqdig, 0) + 1
                ,pr_vllanmto
                ,pr_dtrefere
                ,pr_vlrendmm) RETURNING ROWID INTO pr_rowidlap;
      EXCEPTION
        WHEN others THEN
          pr_des_reto := 'NOK';
          vr_dscritic := 'APLI0001.pc_ajuste_provisao_rdc_pre1 --> Erro ao inserir tabela CRAPLAP: ' || sqlerrm;

          RAISE vr_exc_erro;
      END;

      -- Atualizar cfme o parametro e somente se não houve erro anteriormente
      IF pr_tipodrdb = 'D' THEN
        -- Executa UPDATE para debito
        BEGIN
          UPDATE craplot ct
          SET ct.vlinfodb = NVL(ct.vlinfodb,0) + pr_vllanmto
             ,ct.vlcompdb = NVL(ct.vlcompdb,0) + pr_vllanmto
             ,ct.qtinfoln = NVL(ct.qtinfoln,0) + 1
             ,ct.qtcompln = NVL(ct.qtcompln,0) + 1
             ,ct.nrseqdig = NVL(ct.nrseqdig,0) + 1
          WHERE ct.ROWID = pr_rowidlot
          RETURNING ct.vlinfodb, ct.vlcompdb, ct.qtinfoln, ct.qtcompln, ct.nrseqdig
          INTO pr_vlinfodb, pr_vlcompdb, pr_qtinfoln, pr_qtcompln, pr_nrseqdig;
        EXCEPTION
          WHEN others THEN
            pr_des_reto := 'NOK';
            vr_dscritic := 'APLI0001.pc_ajuste_provisao_rdc_pre2 --> Erro ao atualizar tabela CRAPLOT (debito): ' || sqlerrm;

            RAISE vr_exc_erro;
        END;
      END IF;

      -- Atualizar cfme o parametro e somente se não houve erro anteriormente
      IF pr_tipodrdb = 'C' THEN
        -- Executa UPDATE para credito
        BEGIN
          UPDATE craplot ct
          SET ct.vlinfocr = NVL(ct.vlinfocr,0) + pr_vllanmto
             ,ct.vlcompcr = NVL(ct.vlcompcr,0) + pr_vllanmto
             ,ct.qtinfoln = NVL(ct.qtinfoln,0) + 1
             ,ct.qtcompln = NVL(ct.qtcompln,0) + 1
             ,ct.nrseqdig = NVL(ct.nrseqdig,0) + 1
          WHERE ct.ROWID = pr_rowidlot
          RETURNING ct.vlinfocr, ct.vlcompcr, ct.qtinfoln, ct.qtcompln, ct.nrseqdig
          INTO pr_vlinfocr, pr_vlcompcr, pr_qtinfoln, pr_qtcompln, pr_nrseqdig;
        EXCEPTION
          WHEN others THEN
            pr_des_reto := 'NOK';
            vr_dscritic := 'APLI0001.pc_ajuste_provisao_rdc_pre3 --> Erro ao atualizar tabela CRAPLOT (credito): ' || sqlerrm;

            RAISE vr_exc_erro;
        END;
      END IF;

      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_reto := pr_des_reto;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      WHEN others THEN
        pr_des_reto := 'NOK';

        vr_dscritic := 'APLI0001.pc_ajuste_provisao_rdc_pre4 --> Erro não tratado na rotina: ' || sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_gera_craplap_rdc;

  /* Rotina de calculo do saldo das aplicacoes RDC POS para resgate com IRPF. */
  PROCEDURE pc_saldo_rgt_rdc_pos (pr_cdcooper    IN crapcop.cdcooper%TYPE        --> Cooperativa
                                 ,pr_cdagenci    IN crapass.cdagenci%TYPE        --> Codigo da agencia
                                 ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE        --> Numero do caixa
                                 ,pr_nrctaapl    IN craprda.nrdconta%TYPE        --> Numero da conta
                                 ,pr_nraplres    IN craprda.nraplica%TYPE        --> Numero da aplicacao
                                 ,pr_dtmvtolt    IN craprda.dtmvtolt%TYPE        --> Data do movimento
                                 ,pr_dtaplrgt    IN craprda.dtmvtolt%TYPE        --> Data aplicacao
                                 ,pr_vlsdorgt    IN NUMBER                       --> Valor DCA
                                 ,pr_flggrvir    IN BOOLEAN DEFAULT FALSE        --> Identificador se deve gravar valor insento
                                 ,pr_dtinitax    IN craprda.dtmvtolt%TYPE        --> Data Inicial da Utilizacao da taxa da poupanca
                                 ,pr_dtfimtax    IN craprda.dtmvtolt%TYPE        --> Data Final da Utilizacao da taxa da poupanca
                                 ,pr_vlsddrgt    OUT NUMBER                      --> Valor do resgate total sem irrf ou o solicitado
                                 ,pr_vlrenrgt    OUT NUMBER                      --> Rendimento total a ser pago quando resgate total
                                 ,pr_vlrdirrf    OUT NUMBER                      --> IRRF do que foi solicitado
                                 ,pr_perirrgt    OUT NUMBER                      --> Percentual de aliquota para calculo do IRRF
                                 ,pr_vlrgttot    OUT NUMBER                      --> Resgate para zerar a aplicacao
                                 ,pr_vlirftot    OUT NUMBER                      --> IRRF para finalizar a aplicacao
                                 ,pr_vlrendmm    OUT NUMBER                      --> Rendimento da ultima provisao ate a data do resgate
                                 ,pr_vlrvtfim    OUT NUMBER                      --> Quantia provisao reverter para zerar a aplicacao
                                 ,pr_des_reto    OUT VARCHAR                     --> Indicador de saida com erro (OK/NOK)
                                 ,pr_tab_erro    OUT GENE0001.typ_tab_erro ) IS  --> Tabela com erros
    --  .......................................................................................
    --
    -- Programa: pc_saldo_rgt_rdc_pos - Antiga b1wgen0004.saldo_rgt_rdc_pos
    -- Autor   : ---
    -- Data    : ---                        Ultima atualizacao: 03/10/2017
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : BO CONSULTA SALDO E EXTRATO DE APLICACOES
    --             Baseada no programa fontes/impextrda.p.
    --             Rotina de calculo do saldo das aplicacoes RDC POS para resgate
    --             enxergando as novas aliquotas de imposto de renda.
    --             Retorna o saldo para resgate no dia solicitado.
    --
    -- Alteracoes: 06/01/2013 - conversao Progress >> PL/SQL (Oracle). Petter - Supero.
    --
    --             24/10/2013 - Replicar manutenção progress,Tratamento para Imunidade Tributaria. Odirlei - AMcom
    --
    --             07/04/2014 - Alterações referente ao novo indexador de poupanca
    --                          (Jean Michel).
    --
    --             24/06/2014 - Retirada leitura da craptab e incluido data de liberacao do projeto
    --                          do novo indexador de poupanca fixa - 01/07/2014 (Jean Michel).
    --
    --             25/06/2014 - Ajustes no tratamento de exceção (Marcos-Supero)
    --
    --             05/08/2015 - Ajuste no cursor ca craplap para melhoria de performace
    --                          SD 281898(Odirlei-AMcom)
    --
    --             03/10/2017 - Correcao na forma de arredondamento do campo vr_vlrgtsol na pc_saldo_rgt_rdc_pos. 
    --                          Influenciava o valor de resgate superior ao saldo. (Carlos Rafael Tanholi - SD 745032)
    -- .......................................................................................
    BEGIN
      DECLARE
        vr_dtiniper   craprda.dtiniper%TYPE;
        vr_dtfimper   craprda.dtfimper %TYPE;
        vr_txaplrgt   NUMBER(20,8);
        vr_perirrgt   NUMBER(15,2);
        vr_vlrenmlt   NUMBER(20,8) := 0;
        vr_vlrgtsol   NUMBER(18,4);
        vr_vlrnttmm   craplap.vlrendmm%type;
        vr_nrdias     NUMBER := 0;
        vr_exc_saida  EXCEPTION;
        vr_idx_moeda  VARCHAR2(10);
        vr_dtinitax   DATE;
        vr_dtfimtax   DATE;
        vr_datlibpr   DATE;
        vr_txaplmes   NUMBER(20,8) := 0;
        vr_dtinipop   DATE;
        vr_txmespop   NUMBER(15,6);
        vr_txdiapop   NUMBER(15,6);
        vr_vlrenrgt   NUMBER(20,8);
        vr_controle   EXCEPTION;
        vr_fora       EXCEPTION;
        vr_final      EXCEPTION;
        vr_flgimune   BOOLEAN;

        -- Cadastro dos lancamentos das aplicacaes RDA
        CURSOR cr_craplap (pr_cdcooper  IN crapdat.cdcooper%TYPE      --> Codigo da cooperativa
                          ,pr_nrdconta  IN craprda.nrdconta%TYPE      --> Numero da conta
                          ,pr_nraplica  IN craprda.nraplica%TYPE      --> Numero da aplicacao
                          ,pr_dtmvtolt  IN craplap.dtmvtolt%TYPE
                          ) IS
          SELECT /*+ index (cp1 CRAPLAP##CRAPLAP5) */
                 cp1.cdhistor,
                 nvl(SUM(nvl(cp1.vlrendmm, 0)), 0) vlrendmm,
                 nvl(SUM(nvl(cp1.vllanmto, 0)), 0) vllanmto
            FROM craplap cp1
           WHERE cp1.cdcooper = pr_cdcooper
             AND cp1.nrdconta = pr_nrdconta
             AND cp1.nraplica = pr_nraplica
             AND cp1.dtmvtolt >= pr_dtmvtolt 
             AND cp1.cdhistor IN (529, 531) --retirado hist 532, pois nao utiliza valor carregado 
           GROUP BY cp1.cdhistor;

        -- Cursor sobre a tabela CRAPLAP, criado novamente pois o campo do anterior CDHISTOR
        -- para unificar iria demandar subselect e teria perda de performance, foi entao
        -- desnormalizado.
        CURSOR cr_craplap2 (pr_cdcooper  IN crapdat.cdcooper%TYPE          --> Codigo da cooperativa
                           ,pr_nrdconta  IN craprda.nrdconta%TYPE          --> Numero da conta
                           ,pr_nraplica  IN craprda.nraplica%TYPE          --> Numero da aplicacao
                           ,pr_dtmvtolt  IN craplap.dtmvtolt%TYPE) IS      --> Data de movimento
          SELECT /*+ Index (cp CRAPLAP##CRAPLAP5) */
                 cp.txaplmes
                ,cp.txaplica
          FROM craplap cp
          WHERE cp.cdcooper = pr_cdcooper
            AND cp.nrdconta = pr_nrdconta
            AND cp.nraplica = pr_nraplica
            AND cp.dtmvtolt = pr_dtmvtolt
          ORDER BY cdcooper,
                   nrdconta,
                   nraplica,
                   dtmvtolt,
                   dtrefere,
                   cdhistor,
                   progress_recid;
        rw_craplap2 cr_craplap2%rowtype;

        -- Cadastro de taxas do RDCA
        CURSOR cr_craptrd (pr_cdcooper  IN crapdat.cdcooper%TYPE) IS  --> Codigo da cooperativa
          SELECT ct.qtdiaute
                ,ct.dtiniper
                ,count(*) over (partition by ct.dtiniper order by ct.progress_recid) registro
          FROM craptrd ct
          WHERE ct.cdcooper = pr_cdcooper;

        rw_craptrd cr_craptrd%rowtype;

        -- Buscar dados de moedas
        CURSOR cr_crapmfx(pr_cdcooper  IN crapdat.cdcooper%TYPE) IS     --> Codigo da cooperativa
          SELECT tpmoefix, dtmvtolt, vlmoefix
            FROM crapmfx
           WHERE cdcooper = pr_cdcooper;

      BEGIN
        -- Inicializacao de variaveis com valores padrao
        pr_vlsddrgt := 0;
        pr_vlrenrgt := 0;
        pr_vlrdirrf := 0;
        pr_perirrgt := 0;
        pr_vlrgttot := 0;
        pr_vlrendmm := 0;
        pr_vlrvtfim := 0;

        -- Chamando rotina que atualiza a tabela com informacaos da PERCIRFRDC
        APLI0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);

        -- Busca cadastro da aplicacao RDA
        OPEN cr_craprda(pr_cdcooper, pr_nrctaapl, pr_nraplres);
        FETCH cr_craprda INTO rw_craprda;

        -- Se nao localizar registro sinaliza critica
        -- Se encontrar carrega valores nas variaveis
        IF cr_craprda%notfound OR rw_craprda.retorno > 1 THEN
          -- Chamar rotina de gravacao de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => 426
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

          pr_des_reto := 'NOK';

          CLOSE cr_craprda;
          RAISE vr_exc_saida;
        ELSE
          close cr_craprda;
        END IF;

        vr_dtiniper := rw_craprda.dtmvtolt;
        vr_dtfimper := pr_dtaplrgt;
        vr_vlrgtsol := pr_vlsdorgt;

        IF vr_vlrgtsol = 0 THEN
          vr_vlrgtsol := fn_round(rw_craprda.vlsltxmm, 2);
          vr_dtiniper := rw_craprda.dtatslmm;
        END IF;

        /* Provisao e estornado para zerar a aplicacao se resgate total */
        FOR vr_cr_craplap IN cr_craplap(pr_cdcooper
                                       ,rw_craprda.nrdconta
                                       ,rw_craprda.nraplica
                                       ,rw_craprda.dtmvtolt) LOOP
          -- Provisao
          IF vr_cr_craplap.cdhistor = 529 THEN
            vr_vlrnttmm := nvl(vr_vlrnttmm, 0) + vr_cr_craplap.vlrendmm;
            pr_vlrvtfim := nvl(pr_vlrvtfim, 0) + vr_cr_craplap.vllanmto;
          ELSE
            -- Rendimento credito
            --comentado pois a informacao carregada do hist. 532, não é utilizada
            IF vr_cr_craplap.cdhistor = 531 THEN
              pr_vlrvtfim := nvl(pr_vlrvtfim, 0) - vr_cr_craplap.vllanmto;
              vr_vlrnttmm := nvl(vr_vlrnttmm, 0) - vr_cr_craplap.vlrendmm;
            END IF;
          END IF;
        END LOOP;

        -- Verifica se aplicacao esta em carencia
        -- Se estiver em carencia finaliza a aplicacao emitindo raise e
        -- retornando string de OK
        IF (pr_dtaplrgt - rw_craprda.dtmvtolt) < rw_craprda.qtdiauti THEN
          pr_vlsddrgt := rw_craprda.vlsdrdca;
          pr_vlrgttot := rw_craprda.vlsdrdca;
          pr_vlrendmm := vr_vlrnttmm;

          RAISE vr_final;
        END IF;

        -- Buscar as taxas contratas
        OPEN cr_craplap2(pr_cdcooper, rw_craprda.nrdconta, rw_craprda.nraplica, rw_craprda.dtmvtolt);
        FETCH cr_craplap2 INTO rw_craplap2;

        -- Se nao encontrar registro sinaliza critica
        IF cr_craplap2%notfound THEN
          -- Chamar rotina de gravacao de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => 90
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

          pr_des_reto := 'NOK';

          CLOSE cr_craplap2;
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_craplap2;
        END IF;

        -- Retorna percentual do imposto de renda a ser cobrado no resgate
        IF rw_craplap2.txaplmes <> 0 AND pr_dtaplrgt IS NOT NULL THEN
          vr_nrdias := pr_dtaplrgt - rw_craprda.dtmvtolt;

          -- Se nao atender a condicao gera critica
          IF vr_nrdias IS NULL OR vr_nrdias = 0 THEN
            -- Chamar rotina de gravacao de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1
                                 ,pr_cdcritic => 840
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);

            pr_des_reto := 'NOK';

            RAISE vr_exc_saida;
          END IF;

          -- Pesquisar o vetor de faixas partindo do final ate o inicio
          FOR vr_ind IN REVERSE 1..APLI0001.vr_faixa_ir_rdc.COUNT LOOP
            -- Se a quantidade de dias for maior que a quantidade do vetor
            IF vr_nrdias > APLI0001.vr_faixa_ir_rdc(vr_ind).qtdiatab THEN
              -- Utilizar o percentual encontrado
              vr_perirrgt := APLI0001.vr_faixa_ir_rdc(vr_ind).perirtab;
              -- Sair do LOOP
              EXIT;
            END IF;
          END LOOP;

          -- Carrega para a variavel o registro 4 do array
          IF vr_perirrgt = 0 THEN
            vr_perirrgt := APLI0001.vr_faixa_ir_rdc(4).perirtab;
          END IF;

          -- Se o valor for zero e a cooperativa nao for 3 sinaliza critica
          IF vr_perirrgt = 0 AND pr_cdcooper <> 3 THEN
            -- Chamar rotina de gravacao de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1
                                 ,pr_cdcritic => 180
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);

            pr_des_reto := 'NOK';

            RAISE vr_exc_saida;
          END IF;
        END IF;

       -- Data de fim e inicio da utilizacao da taxa de poupanca.
       -- Utiliza-se essa data quando o rendimento da aplicacao for menor que
       -- a poupanca, a cooperativa opta por usar ou nao.
       IF pr_dtinitax IS NULL OR pr_dtfimtax IS NULL THEN
         vr_dtinitax := to_date('01/01/9999', 'DD/MM/RRRR');
         vr_dtfimtax := to_date('01/01/9999', 'DD/MM/RRRR');
       ELSE
         --Atribuir data de inicio e fim das taxas da poupanca
         vr_dtinitax := pr_dtinitax;
         vr_dtfimtax := pr_dtfimtax;
       END IF;

       -- Se o vetor de dias uteis ainda nao possuir informacoes
       IF vr_tab_qtdiaute.COUNT = 0 THEN
         -- Buscar os dias uteis
         FOR rw_craptrd IN cr_craptrd (pr_cdcooper => pr_cdcooper)  LOOP
           -- Atribuir o valor selecionado ao vetor somente para a primeira data encontrada (mais antiga)
           IF rw_craptrd.registro = 1 THEN
             vr_tab_qtdiaute(to_char(rw_craptrd.dtiniper,'YYYYMMDD')):= rw_craptrd.qtdiaute;
           END IF;
         END LOOP;
       END IF;

       -- Se o vetor de moedas ainda nao possuir informacoes
       IF vr_tab_moedatx.COUNT = 0 THEN
         -- Buscar todos os registros das moedas do tipo 6 e 8
         FOR rw_crapmfx IN cr_crapmfx(pr_cdcooper) LOOP
           -- MOntar a chave do registro com o tipo + data
           vr_idx_moeda := LPAD(rw_crapmfx.tpmoefix,2,'0')||To_Char(rw_crapmfx.dtmvtolt,'YYYYMMDD');
           -- Atribuir o valor selecionado ao vetor
           vr_tab_moedatx(vr_idx_moeda).vlmoefix := rw_crapmfx.vlmoefix;
           -- Para moeda 6 - CDI
           IF rw_crapmfx.tpmoefix = 6 THEN
             -- Calcular a taxa de aplicacao
             vr_tab_moedatx(vr_idx_moeda).txaplmes := (POWER((1 + rw_crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100;
           END IF;
         END LOOP;
       END IF;

       -- Data de liberacao do projeto novo indexador de poupanca
       vr_datlibpr := to_date('01/07/2014','dd/mm/yyyy');

       -- Itera enquanto vr_dtiniper for menor que vr_dtfimper
       WHILE vr_dtiniper < vr_dtfimper
       LOOP
         BEGIN
           vr_dtiniper := gene0005.fn_valida_dia_util(pr_cdcooper
                                                     ,vr_dtiniper
                                                     ,pr_tipo     => 'P'     -- valor padrao
                                                     ,pr_feriado  => true    -- valor padrao 
                                                     ,pr_excultdia => true); -- considera 31/12 como util

           -- Compara data inicial com data final do periodo
           IF vr_dtiniper >= vr_dtfimper THEN
             RAISE vr_controle;
           END IF;

           -- Buscar dados de moeda
           vr_idx_moeda := LPAD(6,2,'0')||To_Char(vr_dtiniper,'YYYYMMDD');
           IF vr_tab_moedatx.EXISTS(vr_idx_moeda) THEN
             vr_txaplmes:= vr_tab_moedatx(vr_idx_moeda).txaplmes;
           -- Se o registro nao for encontrado sinaliza critica
           ELSE
             -- Chamar rotina de gravacao de erro
             gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_nrdcaixa => pr_nrdcaixa
                                  ,pr_nrsequen => 1
                                  ,pr_cdcritic => 211
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tab_erro => pr_tab_erro);

             pr_des_reto := 'NOK';
             RAISE vr_exc_saida;
           END IF;

           -- Se a taxa de aplicacao for diferente da taxa mensal agrega o valor de uma forma
           -- caso contrario realiza outra metrica
           IF rw_craplap2.txaplica != rw_craplap2.txaplmes THEN
             vr_txaplrgt := fn_round(((vr_txaplmes * rw_craplap2.txaplmes / 100) / 100), 8);
           ELSE
             vr_txaplrgt := fn_round((vr_txaplmes * rw_craplap2.txaplica / 100 ) / 100 , 8);

             -- Valida regra para calculo em caso de poupanca
             IF vr_dtiniper > vr_dtinitax AND rw_craprda.dtmvtolt < vr_dtfimtax THEN
               BEGIN
                 -- Usar poupanca de um mes atras
                 vr_dtinipop := to_date(to_char(vr_dtiniper, 'DD') || '/' || to_char(to_char(vr_dtiniper, 'MM') - 1) || '/' || to_char(vr_dtiniper, 'RRRR'), 'DD/MM/RRRR');

               EXCEPTION
                 WHEN others THEN
                   -- Tratar anos anteriores
                   IF to_char(vr_dtiniper, 'MM') = 1 THEN
                     vr_dtinipop := vr_dtiniper - 31;
                   ELSE
                     -- Caso nao exista a data, pegar primeiro dia do mes
                     vr_dtinipop := to_date('01/' || to_char(vr_dtiniper, 'MM') || '/' || to_char(vr_dtiniper, 'RRRR'), 'DD/MM/RRRR');
                   END IF;
               END;

               /********************************************************************/
               /** Em Maio de 2012 o novo calculo foi liberado para utilizacao,   **/
               /** portanto aplicacoes cadastradas a partir desta data poderiam   **/
               /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
               /** vamos calcular o rendimento desta aplicacao com base na nova   **/
               /** regra somente a partir da data de liberacao do projeto de novo **/
               /** indexador de poupanca, pois o passado anterior a liberacao ja  **/
               /** foi remunerado e contabilizado. 							                 **/
               /********************************************************************/

               IF rw_craprda.dtmvtolt >= to_date('04/05/2012','dd/mm/yyyy') AND
                  vr_dtiniper >= vr_datlibpr THEN
                 -- Buscar dados de moeda
                 vr_idx_moeda := LPAD(20,2,'0')||To_Char(vr_dtinipop,'YYYYMMDD');
               ELSE
                 -- Buscar dados de moeda
                 vr_idx_moeda := LPAD(8,2,'0')||To_Char(vr_dtinipop,'YYYYMMDD');
               END IF;


               IF vr_tab_moedatx.EXISTS(vr_idx_moeda) THEN
                 rw_crapmfx.vlmoefix:= vr_tab_moedatx(vr_idx_moeda).vlmoefix;
               ELSE -- Se o registro nao for encontrado sinaliza critica
                 -- Chamar rotina de gravacao de erro
                 gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_nrdcaixa => pr_nrdcaixa
                                      ,pr_nrsequen => 1
                                      ,pr_cdcritic => 211
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_tab_erro => pr_tab_erro);

                 pr_des_reto := 'NOK';
                 RAISE vr_exc_saida;
               END IF;

               -- Busca das taxas do RDCA
               -- Verificar se esta data nao existe no vetor
               IF NOT vr_tab_qtdiaute.EXISTS(to_char(vr_dtinipop,'yyyymmdd')) THEN
                 -- Buscar a data na tabela
                 OPEN cr_craptrd(pr_cdcooper);
                 FETCH cr_craptrd INTO rw_craptrd;
                 CLOSE cr_craptrd;
               ELSE
                 -- Buscar o valor do vetor
                 rw_craptrd.qtdiaute:= vr_tab_qtdiaute(to_char(vr_dtinipop,'yyyymmdd'));
               END IF;

               -- Executa calculo para poupanca
               pc_calctx_poupanca (pr_cdcooper
                                  ,rw_craptrd.qtdiaute
                                  ,rw_crapmfx.vlmoefix
                                  ,vr_txmespop
                                  ,vr_txdiapop);

               IF vr_txaplrgt < vr_txdiapop / 100 THEN
                 vr_txaplrgt := vr_txdiapop / 100;
               END IF;
             END IF;
           END IF;

           -- Atribui valores as variaveis truncando ou arredondando os valores
           vr_vlrenrgt := trunc(vr_vlrgtsol * vr_txaplrgt, 8);
           vr_vlrgtsol := vr_vlrgtsol + vr_vlrenrgt;
           vr_vlrenmlt := vr_vlrenmlt + vr_vlrenrgt;

           vr_dtiniper := vr_dtiniper + 1;
         EXCEPTION
           WHEN vr_exc_saida THEN
             -- Replicar
             RAISE vr_exc_saida;
           WHEN vr_controle THEN
             -- Controle para interrupcao
             NULL;
         END;
       END LOOP;

       -- Atribui valores as variaveis truncando ou arredondando os valores
       vr_vlrenmlt := fn_round(vr_vlrenmlt, 2); -- trunc
       pr_vlrenrgt := vr_vlrenmlt;
       vr_vlrgtsol := fn_round(vr_vlrgtsol, 2);
       pr_vlrdirrf := fn_round((pr_vlrenrgt * vr_perirrgt / 100), 2); --trunc
       pr_perirrgt := vr_perirrgt;

       /* Procedure para verificar imunidade tributaria e inserir valor de insenção */
       IMUT0001.pc_verifica_imunidade_trib(  pr_cdcooper  => pr_cdcooper  --> Codigo Cooperativa
                                            ,pr_nrdconta  => pr_nrctaapl  --> Numero da Conta
                                            ,pr_dtmvtolt  => pr_dtmvtolt  --> Data movimento
                                            ,pr_flgrvvlr  => pr_flggrvir  --> Identificador se deve gravar valor
                                            ,pr_cdinsenc  => 5            --> Codigo da insenção
                                            ,pr_vlinsenc  => fn_round((pr_vlrenrgt *
                                                                       pr_perirrgt / 100),2)--> Valor insento -- trunc
                                            ,pr_flgimune  => vr_flgimune  --> Identificador se é imune
                                            ,pr_dsreturn  => pr_des_reto  --> Descricao Critica
                                            ,pr_tab_erro  => pr_tab_erro);--> Tabela erros

       -- Caso retornou com erro, levantar exceção
       IF pr_des_reto = 'NOK' THEN
         RAISE vr_exc_saida;
       END IF;

       IF vr_flgimune THEN
         pr_vlrdirrf := 0;
       END IF;

       -- Resgate parcial
       IF pr_vlsdorgt <> 0 THEN
         pr_vlsddrgt := pr_vlsdorgt;
         RAISE vr_final;
       END IF;

       -- Quando resgate total precisamos descobrir o quanto falta pagar de
       -- rendimento e de IRPF /* falta descontar o IRRF */
       pr_vlsddrgt := vr_vlrgtsol;

       -- Busca todos os rendimentos que foram calculados quando houve um
       -- lancamento 529 a taxa minima e os rendimentos ja pagos
       pr_vlrendmm := pr_vlrenrgt;
       -- No caso de resgate total, o rendimento calculado acima e so da ultima provisao ate a data do resgate
       vr_vlrnttmm := (rw_craprda.vlsltxmm - rw_craprda.vlsdrdca) + pr_vlrenrgt;
       pr_vlrenrgt := fn_round(vr_vlrnttmm, 2);

       IF vr_flgimune THEN
         pr_vlrgttot := fn_round(pr_vlsddrgt, 2);
       ELSE
         --pr_vlrgttot := fn_round(pr_vlsddrgt - TRUNC(((pr_vlrenrgt * pr_perirrgt) / 100), 2), 2); 
         pr_vlrgttot := fn_round(pr_vlsddrgt - fn_round(((pr_vlrenrgt * pr_perirrgt) / 100), 2), 2); 
       END IF;

       pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_final THEN
        -- Retorno OK
        pr_des_reto := pr_des_reto;
      WHEN vr_exc_saida THEN
        -- Retorno nao OK
        pr_des_reto := pr_des_reto;
      WHEN others THEN
        -- Retorno nao OK
        pr_des_reto := 'NOK';
        vr_dscritic := 'APLI0001.pc_saldo_rgt_rdc_pos --> Erro nao tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_saldo_rgt_rdc_pos;

  /* Calcula quanto o que esta sendo resgatado representa do total */
  PROCEDURE pc_valor_original_resgatado(pr_cdcooper   IN crapcop.cdcooper%TYPE         --> Codigo cooperativa
                                       ,pr_cdagenci   IN crapass.cdagenci%TYPE         --> Codigo da agencia
                                       ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE         --> Numero do caixa
                                       ,pr_nrctaapl   IN craprda.nrdconta%TYPE         --> Numero da conta
                                       ,pr_nraplres   IN craprda.nraplica%TYPE         --> Numero da aplicacao
                                       ,pr_dtaplrgt   IN craprda.dtmvtolt%TYPE         --> Data movimento atual
                                       ,pr_vlsdrdca   IN NUMBER                        --> Valor RDCA
                                       ,pr_perirrgt   IN NUMBER                        --> Percentual aplicado
                                       ,pr_dtinitax   IN craprda.dtmvtolt%TYPE         --> Data Inicial da Utilizacao da taxa da poupanca
                                       ,pr_dtfimtax   IN craprda.dtmvtolt%TYPE         --> Data Final da Utilizacao da taxa da poupanca
                                       ,pr_vlbasrgt   OUT NUMBER                       --> Valor resgatado
                                       ,pr_des_reto   OUT VARCHAR                      --> Indicador de saida com erro (OK/NOK)
                                       ,pr_tab_erro   OUT GENE0001.typ_tab_erro ) IS   --> Tabela com erros
    --  .......................................................................................
    --
    -- Programa: pc_valor_original_resgatado - Antiga 1wgen0004.valor_original_resgatado
    -- Autor   : ---
    -- Data    : ---                        Ultima atualizacao: 25/06/2014
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : BO CONSULTA SALDO E EXTRATO DE APLICACOES
    --             Calcula quanto o valor resgatado representa sob o valor total.
    --
    -- Alteracoes: 10/01/2013 - conversao Progress >> PL/SQL (Oracle). Petter - Supero.
    --
    --             07/04/2014 - Alterações referente ao novo indexador de poupanca
    --                          (Jean Michel).
    --             24/06/2014 - Retirada leitura da craptab e incluido data de
    --                          liberacao do projeto do novo indexador de
    --                          poupanca fixa - 01/07/2014 (Jean Michel).
    --             25/06/2014 - Ajustes no tratamento de exceção (Marcos-Supero)
    -- .......................................................................................
  BEGIN
    DECLARE
      vr_dtiniper   craprda.dtiniper%TYPE;
      vr_dtfimper   craprda.dtfimper%TYPE;
      vr_txaplrgt   NUMBER(15,8);
      vr_txaplcum   NUMBER(15,8);
      vr_percirrf   NUMBER(10,4);
      vr_erro       EXCEPTION;
      vr_dtinitax   DATE;
      vr_dtfimtax   DATE;
      vr_txaplmes   NUMBER(15,8);
      vr_dtinipop   DATE;
      vr_txmespop   NUMBER(10,8);
      vr_txdiapop   NUMBER(10,8);
      vr_idx_moeda  VARCHAR2(10);
      vr_controle   EXCEPTION;
      vr_exc_saida  EXCEPTION;
      vr_flgimune   BOOLEAN;
      vr_datlibpr DATE; --> Data de liberacao de projeto sobre novo indexador de poupanca
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Cadastro do lancamento de aplicacões
      CURSOR cr_craplap (pr_cdcooper   IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta   IN craprda.nrdconta%TYPE
                        ,pr_nraplica   IN craprda.nraplica%TYPE
                        ,pr_dtmvtolt   IN craprda.dtmvtolt%TYPE) IS
        SELECT cp.txaplica
              ,cp.txaplmes
        FROM craplap cp
        WHERE cp.cdcooper = pr_cdcooper
          AND cp.nrdconta = pr_nrdconta
          AND cp.nraplica = pr_nraplica
          AND cp.dtmvtolt = pr_dtmvtolt;
      rw_craplap cr_craplap%rowtype;

      -- Cadastro taxas RDCA
      CURSOR cr_craptrd (pr_cdcooper   IN crapcop.cdcooper%TYPE
                        ,pr_dtiniper   IN craptrd.dtiniper%TYPE) IS
        SELECT ct.qtdiaute
        FROM craptrd ct
        WHERE ct.cdcooper = pr_cdcooper
          AND ct.dtiniper = pr_dtiniper;
      rw_craptrd cr_craptrd%rowtype;

      -- Cadastro taxas RDCA
      CURSOR cr_craptrl(pr_cdcooper   IN crapcop.cdcooper%TYPE) IS
        SELECT craptrd.dtiniper
                      ,craptrd.qtdiaute
                      ,count(*) over (partition by craptrd.dtiniper order by craptrd.progress_recid) registro
                  FROM craptrd
        WHERE craptrd.cdcooper = pr_cdcooper;

      -- Cadastro de moedas
      CURSOR cr_crapmfx(pr_cdcooper   IN crapmfx.cdcooper%TYPE) IS
        SELECT cx.tpmoefix
              ,cx.dtmvtolt
              ,cx.vlmoefix
        FROM crapmfx cx
        WHERE cx.cdcooper = pr_cdcooper
          AND cx.tpmoefix IN(6,8,20);

    BEGIN
      -- Inicializacão de variaveis
      vr_txaplcum := 0;
      pr_vlbasrgt := fn_round(pr_vlsdrdca, 8);
      vr_percirrf := fn_round(pr_perirrgt / 100, 4);

      -- Busca cadastro de aplicacões RDCA
      OPEN cr_craprda (pr_cdcooper, pr_nrctaapl, pr_nraplres);
      FETCH cr_craprda INTO rw_craprda;

      -- Se não localizar registro sinaliza critica
      -- Se localizar registro agrega valor em variaveis
      IF cr_craprda%notfound OR rw_craprda.retorno > 1 THEN
        -- Chamar rotina de gravacão de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => 426
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';

        CLOSE cr_craprda;
        RAISE vr_erro;
      ELSE
        CLOSE cr_craprda;
      END IF;

      vr_dtiniper := rw_craprda.dtmvtolt;
      vr_dtfimper := pr_dtaplrgt;

      -- Fechar o cursor se estiver aberto.
      IF cr_craplap%isopen THEN
        CLOSE cr_craplap;
      END IF;

      -- Buscar as taxas contratas
      OPEN cr_craplap (pr_cdcooper, rw_craprda.nrdconta, rw_craprda.nraplica, rw_craprda.dtmvtolt);
      FETCH cr_craplap INTO rw_craplap;

      -- Se não localizar registro sinaliza critica
      IF cr_craplap%notfound THEN
        -- Chamar rotina de gravacão de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => 90
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';

        CLOSE cr_craplap;
        RAISE vr_erro;
      ELSE
        CLOSE cr_craplap;
      END IF;

      -- Data de fim e inicio da utilizacao da taxa de poupanca.
      -- Utiliza-se essa DATA quando o rendimento da aplicacao for menor que
      -- a poupanca, a cooperativa opta por usar ou não.
      IF pr_dtinitax IS NULL OR pr_dtfimtax IS NULL THEN
        vr_dtinitax := to_date('01/01/9999', 'DD/MM/RRRR');
        vr_dtfimtax := to_date('01/01/9999', 'DD/MM/RRRR');
      ELSE
        vr_dtinitax := pr_dtinitax;
        vr_dtfimtax := pr_dtfimtax;
      END IF;

      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      IF rw_crapdat.inproces > 1 THEN        
      -- Se o vetor de dias uteis ainda não possuir informacões
      IF vr_tab_qtdiaute.COUNT = 0 THEN
        -- Buscar os dias uteis
        FOR rw_craptrd IN cr_craptrl(pr_cdcooper) LOOP
          -- Atribuir o valor selecionado ao vetor somente para a primeira data encontrada (mais antiga)
          IF rw_craptrd.registro = 1 THEN
            vr_tab_qtdiaute(to_char(rw_craptrd.dtiniper,'YYYYMMDD')):= rw_craptrd.qtdiaute;
          END IF;
        END LOOP;
      END IF;

      -- Se o vetor de moedas ainda não possuir informacões
      IF vr_tab_moedatx.COUNT = 0 THEN
        -- Buscar todos os registros das moedas do tipo 6 e 8
        FOR rw_crapmfx IN cr_crapmfx(pr_cdcooper) LOOP
          -- MOntar a chave do registro com o tipo + data
          vr_idx_moeda := LPAD(rw_crapmfx.tpmoefix,2,'0')||To_Char(rw_crapmfx.dtmvtolt,'YYYYMMDD');
          -- Atribuir o valor selecionado ao vetor
          vr_tab_moedatx(vr_idx_moeda).vlmoefix := rw_crapmfx.vlmoefix;
          -- Para moeda 6 - CDI
          IF rw_crapmfx.tpmoefix = 6 THEN
            -- Calcular a taxa de aplicacao
            vr_tab_moedatx(vr_idx_moeda).txaplmes := (POWER((1 + rw_crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100;
          END IF;
        END LOOP;
      END IF;
      ELSE
        -- Buscar os dias uteis
        FOR rw_craptrd IN (SELECT craptrd.dtiniper
                                 ,craptrd.qtdiaute
                                 ,count(*) over (partition by craptrd.dtiniper
                                                     order by craptrd.progress_recid) registro
                             FROM craptrd
                            WHERE craptrd.cdcooper = pr_cdcooper
                              AND craptrd.dtiniper > vr_dtiniper -1) LOOP
          -- Atribuir o valor selecionado ao vetor somente para a primeira data encontrada (mais antiga)
          IF rw_craptrd.registro = 1 THEN
            vr_tab_qtdiaute(to_char(rw_craptrd.dtiniper,'YYYYMMDD')):= rw_craptrd.qtdiaute;
          END IF;
        END LOOP;

        -- Buscar todos os registros das moedas do tipo 6 e 8
        FOR rw_crapmfx IN (SELECT CRAPMFX.DTMVTOLT
                                 ,CRAPMFX.TPMOEFIX
                                 ,CRAPMFX.VLMOEFIX 
                             FROM CRAPMFX
                            WHERE CRAPMFX.CDCOOPER = pr_cdcooper 
                              AND CRAPMFX.DTMVTOLT > vr_dtiniper -35
                              AND CRAPMFX.DTMVTOLT <= vr_dtfimper
                              AND CRAPMFX.TPMOEFIX IN(6,8,20)) LOOP
          -- MOntar a chave do registro com o tipo + data
          vr_idx_moeda := LPAD(rw_crapmfx.tpmoefix,2,'0')||To_Char(rw_crapmfx.dtmvtolt,'YYYYMMDD');
          -- Atribuir o valor selecionado ao vetor
          vr_tab_moedatx(vr_idx_moeda).vlmoefix := rw_crapmfx.vlmoefix;
          -- Para moeda 6 - CDI
          IF rw_crapmfx.tpmoefix = 6 THEN
            -- Calcular a taxa de aplicacao
            vr_tab_moedatx(vr_idx_moeda).txaplmes := (POWER((1 + rw_crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100;
          END IF;
        END LOOP;
      END IF;

      -- Data de liberacao do projeto novo indexador de poupanca
      vr_datlibpr := to_date('01/07/2014','dd/mm/yyyy');

      -- Buscar o acumulado das taxas
      WHILE vr_dtiniper < vr_dtfimper
      LOOP
        BEGIN
          -- Busca data de feriado
          vr_dtiniper := gene0005.fn_valida_dia_util(pr_cdcooper
                                                    ,vr_dtiniper
                                                    ,pr_tipo     => 'P'     -- valor padrao
                                                    ,pr_feriado  => true    -- valor padrao 
                                                    ,pr_excultdia => true); -- considera 31/12 como util

          IF vr_dtiniper >= vr_dtfimper THEN
            RAISE vr_controle;
          END IF;

          -- Busca a moeda fixa
          -- Montar a chave do registro com o tipo + data
          vr_idx_moeda := LPAD(6,2,'0')||To_Char(vr_dtiniper,'YYYYMMDD');
          IF vr_tab_moedatx.EXISTS(vr_idx_moeda) THEN
            vr_txaplmes:= vr_tab_moedatx(vr_idx_moeda).txaplmes;
          ELSE  -- Se o registro nao for encontrado sinaliza critica
            -- Chamar rotina de gravacao de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1
                                 ,pr_cdcritic => 211
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);

            pr_des_reto := 'NOK';

            --CLOSE cr_crapmfx;
            RAISE vr_erro;
          END IF;

          -- Como e resgate antes do vencimento sempre taxa minima
          IF rw_craplap.txaplica != rw_craplap.txaplmes THEN
            vr_txaplrgt := fn_round((vr_txaplmes * rw_craplap.txaplmes / 100), 8);
          ELSE
            vr_txaplrgt := fn_round((vr_txaplmes * rw_craplap.txaplica / 100), 8);

            IF vr_dtiniper > vr_dtinitax AND rw_craprda.dtmvtolt < vr_dtfimtax THEN
              -- Usar poupanca de um mes atras
              BEGIN
                vr_dtinipop := to_date(to_char(vr_dtiniper, 'DD') || '/' || to_char(to_char(vr_dtiniper, 'MM') - 1) || '/' || to_char(vr_dtiniper, 'RRRR'), 'DD/MM/RRRR');

              EXCEPTION
                WHEN others THEN
                  -- Tratar anos anteriores
                  IF to_number(to_char(vr_dtiniper, 'MM')) = 1 THEN
                    vr_dtinipop := vr_dtiniper - 31;
                  ELSE
                    -- Caso nao exista a data, pegar primeiro dia do mes
                    vr_dtinipop := to_date('01/' || to_char(vr_dtiniper, 'MM') || '/' || to_char(vr_dtiniper, 'RRRR'), 'DD/MM/RRRR');
                  END IF;
              END;

              /********************************************************************/
              /** Em Maio de 2012 o novo calculo foi liberado para utilizacao,   **/
              /** portanto aplicacoes cadastradas a partir desta data poderiam   **/
              /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
              /** vamos calcular o rendimento desta aplicacao com base na nova   **/
              /** regra somente a partir da data de liberacao do projeto de novo **/
              /** indexador de poupanca, pois o passado anterior a liberacao ja  **/
              /** foi remunerado e contabilizado. 							                 **/
              /********************************************************************/

             IF rw_craprda.dtmvtolt >= to_date('04/05/2012','dd/mm/yyyy') AND
                vr_dtiniper >= vr_datlibpr THEN
                -- Busca valor de moeda de saida
                -- Montar a chave do registro com o tipo + data
                vr_idx_moeda := LPAD(20,2,'0')||To_Char(vr_dtinipop,'YYYYMMDD');
             ELSE
                -- Busca valor de moeda de saida
                -- Montar a chave do registro com o tipo + data
                vr_idx_moeda := LPAD(8,2,'0')||To_Char(vr_dtinipop,'YYYYMMDD');
             END IF;

              IF vr_tab_moedatx.EXISTS(vr_idx_moeda) THEN
                rw_crapmfx.vlmoefix:= vr_tab_moedatx(vr_idx_moeda).vlmoefix;
              ELSE  -- Se o registro nao for encontrado sinaliza critica
                -- Chamar rotina de gravacao de erro
                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1
                                     ,pr_cdcritic => 211
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_tab_erro => pr_tab_erro);

                pr_des_reto := 'NOK';
                RAISE vr_erro;
              END IF;

              -- Fechar o cursor se estiver aberto.
              IF cr_craptrd%isopen THEN
                CLOSE cr_craptrd;
              END IF;

              -- Busca taxas de aplicacoes
              -- Verificar se esta data nao existe no vetor
              IF NOT vr_tab_qtdiaute.EXISTS(to_char(vr_dtinipop,'yyyymmdd')) THEN
                -- Buscar a data na tabela
                OPEN cr_craptrd (pr_cdcooper, vr_dtinipop);
                FETCH cr_craptrd INTO rw_craptrd;
                CLOSE cr_craptrd;
              ELSE
                -- Buscar o valor do vetor
                rw_craptrd.qtdiaute:= vr_tab_qtdiaute(to_char(vr_dtinipop,'yyyymmdd'));
              END IF;

              -- Executa calculo poupanca
              pc_calctx_poupanca (pr_cdcooper
                                 ,rw_craptrd.qtdiaute
                                 ,rw_crapmfx.vlmoefix
                                 ,vr_txmespop
                                 ,vr_txdiapop);

              -- Compara taxas para atribuir valor
              IF vr_txaplrgt < vr_txdiapop THEN
                vr_txaplrgt := vr_txdiapop;
              END IF;
            END IF;
          END IF;

          -- Acumulando taxas
          IF nvl(vr_txaplcum, 0) = 0 THEN
            vr_txaplcum := fn_round(vr_txaplrgt, 8);
          ELSE
            vr_txaplcum := fn_round(((vr_txaplcum / 100 + 1) * (vr_txaplrgt / 100 + 1) - 1) * 100, 8);
          END IF;

          vr_dtiniper := vr_dtiniper + 1;
        EXCEPTION
          WHEN vr_erro THEN
            -- Replicar a exceção
            RAISE vr_erro;
          WHEN vr_controle THEN
            -- Controle para interrupcão do fluxo
            NULL;
        END;
      END LOOP;

      /* Procedure para verificar imunidade tributaria e inserir valor de insenção */
      IMUT0001.pc_verifica_imunidade_trib(  pr_cdcooper  => pr_cdcooper    --> Codigo Cooperativa
                                           ,pr_nrdconta  => pr_nrctaapl    --> Numero da Conta
                                           ,pr_dtmvtolt  => trunc(sysdate) --> Data movimento
                                           ,pr_flgrvvlr  => FALSE          --> Identificador se deve gravar valor
                                           ,pr_cdinsenc  => 0              --> Codigo da insenção
                                           ,pr_vlinsenc  => 0              --> Valor insento
                                           ,pr_flgimune  => vr_flgimune    --> Identificador se é imune
                                           ,pr_dsreturn  => pr_des_reto    --> Descricao Critica
                                           ,pr_tab_erro  => pr_tab_erro);  --> Tabela erros

      -- Caso retornou com erro, levantar exceção
      IF pr_des_reto = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Calcular o valor
      IF vr_flgimune THEN
        pr_vlbasrgt := trunc(pr_vlbasrgt / (1 + ( TRUNC(vr_txaplcum,6) / 100)), 2);
      ELSE
        pr_vlbasrgt := trunc(pr_vlbasrgt / (1 + (TRUNC(vr_txaplcum,6) / 100 * (1 - vr_percirrf))), 2);
      END IF;

      pr_des_reto := 'OK';
    EXCEPTION
     WHEN vr_exc_saida THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN others THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        vr_dscritic := 'APLI0001.pc_valor_original_resgatado --> Erro nao tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_valor_original_resgatado;

  /* Procedure para calculo de taxa de poupanca */
  PROCEDURE pc_calctx_poupanca (pr_cdcooper  IN crapdat.cdcooper%TYPE     --> Codigo da cooperativa
                               ,pr_qtdiaute  IN NUMBER                    --> Quantidade de dias do periodo
                               ,pr_vlmoefix  IN NUMBER                    --> Valor da moeda fixa
                               ,pr_txmespop  IN OUT NUMBER                --> Taxa mensal da poupanca
                               ,pr_txdiapop  IN OUT NUMBER) IS            --> Taxa diaria da poupanca
  --  .......................................................................................
  --
  -- Programa: pc_calctx_poupanca - Antiga b1wgen0004.calctx_poupanca
  -- Autor   : ---
  -- Data    : ---                        Ultima atualizacao: 10/01/2013
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : BO CONSULTA SALDO E EXTRATO DE APLICACOES
  --             Calcula a taxa de poupanca mensal e diaria.
  --
  -- Alteracoes: 10/01/2013 - conversao Progress >> PL/SQL (Oracle). Petter - Supero.
  --
  -- .......................................................................................
  BEGIN
    DECLARE
      
    BEGIN
      -- Chamar a atualizacao do vetor de taxas
      APLI0001.pc_busca_faixa_ir_rdca(pr_cdcooper);
      -- Retorna as taxas para poupanca
      pr_txmespop := fn_round(pr_vlmoefix / (1 - (APLI0001.vr_faixa_ir_rdca(1).perirtab / 100)), 6);
      pr_txdiapop := fn_round(((fn_round(POWER(1 + (pr_txmespop / 100), 1 / pr_qtdiaute), 10) - 1) * 100), 6);
    END;
  END pc_calctx_poupanca;

  /* Calcula quanto o que esta sendo resgatado rendeu ate a data */
  PROCEDURE pc_rendi_apl_pos_com_resgate (pr_cdcooper   IN crapcop.cdcooper%TYPE        --> Codigo cooperativa
                                         ,pr_cdagenci   IN crapass.cdagenci%TYPE        --> Codigo da agencia
                                         ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE        --> Numero do caixa
                                         ,pr_nrctaapl   IN craprda.nrdconta%TYPE        --> Numero da conta
                                         ,pr_nraplres   IN craprda.nraplica%TYPE        --> Numero da aplicacao
                                         ,pr_dtaplrgt   IN craprda.dtmvtolt%TYPE        --> Data movimento atual
                                         ,pr_dtinitax   IN craprda.dtmvtolt%TYPE        --> Data Inicial da Utilizacao da taxa da poupanca
                                         ,pr_dtfimtax   IN craprda.dtmvtolt%TYPE        --> Data Final da Utilizacao da taxa da poupanca
                                         ,pr_vlsdrdca   IN NUMBER                   --> Valor RDCA
                                         ,pr_flantven   IN BOOLEAN                      --> Parametro para controle
                                         ,pr_vlrenrgt   IN OUT NUMBER                   --> Saldo RDCA
                                         ,pr_des_reto   OUT VARCHAR                     --> Indicador de saida com erro (OK/NOK)
                                         ,pr_tab_erro   OUT GENE0001.typ_tab_erro ) IS  --> Tabela com erros
  --  .......................................................................................
  --
  -- Programa: pc_rendi_apl_pos_com_resgate - Antiga b1wgen0004.rendi_apl_pos_com_resgate
  -- Autor   : ---
  -- Data    : ---                        Ultima atualizacao: 09/05/2017
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : BO CONSULTA SALDO E EXTRATO DE APLICACOES
  --             Calcula quanto o que esta sendo resgatado rendeu ate a data.
  --
  -- Alteracoes: 11/01/2013 - conversão Progress >> PL/SQL (Oracle). Petter - Supero.
  --
  --             07/04/2014 - Alterações referente ao novo indexador de poupanca
  --                          (Jean Michel).
  --             25/06/2014 - Ajustes no tratamento de exceção (Marcos-Supero)
  --
  --             09/05/2017 - Executei a limpeza da PLTABLE vr_tab_moedatx, garantindo
  --                          assim o carregamento correto das taxa de moedas por data
  --                          (Carlos Rafael Tanholi - SD 631979)
  -- .......................................................................................
  BEGIN
    DECLARE
      vr_dtiniper  craprda.dtiniper%TYPE;
      vr_dtfimper  craprda.dtfimper%TYPE;
      vr_txaplrgt  NUMBER(15,8);
      vr_vlrentot  NUMBER;
      vr_exc_erro  EXCEPTION;
      vr_dtinitax  DATE;
      vr_dtfimtax  DATE;
      vr_controle  EXCEPTION;
      vr_txaplmes  NUMBER(15,8);
      vr_dtinipop  DATE;
      vr_idx_moeda VARCHAR2(10);
      vr_txmespop  NUMBER(10,8);
      vr_txdiapop  NUMBER(10,8);
      vr_vlrenrgt  NUMBER(15,8);
      vr_vlsdrdca  NUMBER(24,8) := pr_vlsdrdca;
      vr_datlibpr DATE; --> Data de liberacao de projeto sobre novo indexador de poupanca
      -- Cadastro de lancamentos de aplicacões RDCA
      CURSOR cr_craplap (pr_cdcooper   IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta   IN craprda.nrdconta%TYPE
                        ,pr_nraplica   IN craprda.nraplica%TYPE
                        ,pr_dtmvtolt   IN craprda.dtmvtolt%TYPE) IS
        SELECT cl.txaplica
              ,cl.txaplmes
        FROM craplap cl
        WHERE cl.cdcooper = pr_cdcooper
          AND cl.nrdconta = pr_nrdconta
          AND cl.nraplica = pr_nraplica
          AND cl.dtmvtolt = pr_dtmvtolt;
      rw_craplap cr_craplap%rowtype;

      -- Cadastro de taxas de RDCA
      CURSOR cr_craptrd (pr_cdcooper   IN crapcop.cdcooper%TYPE
                        ,pr_dtiniper   IN craptrd.dtiniper%TYPE) IS
        SELECT cr.qtdiaute
        FROM craptrd cr
        WHERE cr.cdcooper = pr_cdcooper
          AND cr.dtiniper = pr_dtiniper
          AND rownum = 1
        ORDER BY cr.progress_recid;
      rw_craptrd cr_craptrd%rowtype;

      -- Cadastro de taxas de RDCA
      CURSOR cr_craptrl(pr_cdcooper  IN crapcop.cdcooper%TYPE) IS
        SELECT cd.dtiniper
                      ,cd.qtdiaute
                      ,count(*) over (partition by cd.dtiniper order by cd.progress_recid) registro
                FROM craptrd cd
        WHERE cd.cdcooper = pr_cdcooper;

      -- Cadastro de informações de moeda
      CURSOR cr_crapmfx(pr_cdcooper  IN crapmfx.cdcooper%TYPE) IS
        SELECT cx.tpmoefix
              ,cx.dtmvtolt
              ,cx.vlmoefix
        FROM crapmfx cx
        WHERE cx.cdcooper = pr_cdcooper;

    BEGIN
      -- Inicializacão de variaveis
      vr_vlrentot := 0;

      -- Busca de aplicacões RDCA
      OPEN cr_craprda (pr_cdcooper, pr_nrctaapl, pr_nraplres);
      FETCH cr_craprda INTO rw_craprda;

      -- Se não encontrar registros gera critica
      IF cr_craprda%notfound OR rw_craprda.retorno > 1 THEN
        -- Chamar rotina de gravacão de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => 426
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';

        CLOSE cr_craprda;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craprda;
      END IF;

      vr_dtiniper := rw_craprda.dtmvtolt;
      vr_dtfimper := pr_dtaplrgt;

      -- Buscar as taxas contratas
      OPEN cr_craplap (pr_cdcooper, rw_craprda.nrdconta, rw_craprda.nraplica, rw_craprda.dtmvtolt);
      FETCH cr_craplap INTO rw_craplap;

      -- Se não encontrar registros gera critica
      IF cr_craplap%notfound THEN
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => 90
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';

        CLOSE cr_craplap;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplap;
      END IF;

      -- Data de fim e inicio da utilizacão da taxa de poupanca.
      -- Utiliza-se essa date quando o rendimento da aplicacão for menor que
      -- a poupanca, a cooperativa opta por usar ou não.
      IF pr_dtinitax IS NULL OR pr_dtfimtax IS NULL THEN
        vr_dtinitax := to_date('01/01/9999', 'DD/MM/RRRR');
        vr_dtfimtax := to_date('01/01/9999', 'DD/MM/RRRR');
      ELSE
        vr_dtinitax := pr_dtinitax;
        vr_dtfimtax := pr_dtfimtax;
      END IF;

      -- Se o vetor de dias uteis ainda não possuir informacões
      IF vr_tab_qtdiaute.COUNT = 0 THEN
        -- Buscar os dias uteis
        FOR rw_craptrd IN cr_craptrl(pr_cdcooper) LOOP
          -- Atribuir o valor selecionado ao vetor somente para a primeira data encontrada (mais antiga)
          IF rw_craptrd.registro = 1 THEN
            vr_tab_qtdiaute(to_char(rw_craptrd.dtiniper,'YYYYMMDD')):= rw_craptrd.qtdiaute;
          END IF;
        END LOOP;
      END IF;

      -- Buscar todos os registros das moedas do tipo 6 e 8
      FOR rw_crapmfx IN cr_crapmfx(pr_cdcooper) LOOP
        -- MOntar a chave do registro com o tipo + data
        vr_idx_moeda := LPAD(rw_crapmfx.tpmoefix,2,'0')||To_Char(rw_crapmfx.dtmvtolt,'YYYYMMDD');
        -- Atribuir o valor selecionado ao vetor
        vr_tab_moedatx(vr_idx_moeda).vlmoefix := rw_crapmfx.vlmoefix;
        -- Para moeda 6 - CDI
        IF rw_crapmfx.tpmoefix = 6 THEN
          -- Calcular a taxa de aplicacao
          vr_tab_moedatx(vr_idx_moeda).txaplmes := (POWER((1 + rw_crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100;
        END IF;
      END LOOP;

      -- Data de liberacao do projeto novo indexador de poupanca
      vr_datlibpr := to_date('01/07/2014','dd/mm/yyyy');

      WHILE vr_dtiniper < vr_dtfimper
      LOOP
        BEGIN
          -- Pesquisar data de feriado
          vr_dtiniper := gene0005.fn_valida_dia_util(pr_cdcooper
                                                    ,vr_dtiniper
                                                    ,pr_tipo     => 'P'     -- valor padrao
                                                    ,pr_feriado  => true    -- valor padrao 
                                                    ,pr_excultdia => true); -- considera 31/12 como util

          -- Verificar ponto de encerramento do while
          IF vr_dtiniper >= vr_dtfimper THEN
            RAISE vr_controle;
          END IF;

          -- Busca moeda fixa do sistema
          -- Montar a chave do registro com o tipo + data
          vr_idx_moeda := LPAD(6,2,'0')||To_Char(vr_dtiniper,'YYYYMMDD');
          IF vr_tab_moedatx.EXISTS(vr_idx_moeda) THEN
            vr_txaplmes:= vr_tab_moedatx(vr_idx_moeda).txaplmes;
          ELSE -- Se o registro não for encontrado sinaliza critica
            -- Chamar rotina de gravacão de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => 211
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

            vr_dscritic := vr_dscritic || ' (' || vr_idx_moeda || ')'; 

            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;

          -- Taxa minima
          IF pr_flantven = TRUE AND rw_craplap.txaplica <> rw_craplap.txaplmes THEN
            vr_txaplrgt := fn_round(((vr_txaplmes * rw_craplap.txaplmes / 100) / 100), 8);
          ELSE
            vr_txaplrgt := fn_round(((vr_txaplmes * rw_craplap.txaplica / 100) / 100), 8);

            IF vr_dtiniper > vr_dtinitax AND rw_craprda.dtmvtolt < vr_dtfimtax THEN
              -- Usar poupanca de um mes atras
              BEGIN
                vr_dtinipop := to_date(to_char(vr_dtiniper, 'DD') || '/' || to_char(to_char(vr_dtiniper, 'MM') - 1) || '/' || to_char(vr_dtiniper, 'RRRR'), 'DD/MM/RRRR');
              EXCEPTION
                WHEN others THEN
                  -- Tratar anos anteriores.
                  -- Caso nao exista a data, pegar primeiro dia do mes.
                  IF to_number(to_char(vr_dtiniper, 'MM')) = 1 THEN
                    vr_dtinipop := vr_dtiniper - 31;
                  ELSE
                    vr_dtinipop := to_date('01/' || to_char(vr_dtiniper, 'MM') || '/' || to_char(vr_dtiniper, 'RRRR'), 'DD/MM/RRRR');
                  END IF;
              END;

              /********************************************************************/
              /** Em Maio de 2012 o novo calculo foi liberado para utilizacao,   **/
              /** portanto aplicacoes cadastradas a partir desta data poderiam   **/
              /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
              /** vamos calcular o rendimento desta aplicacao com base na nova   **/
              /** regra somente a partir da data de liberacao do projeto de novo **/
              /** indexador de poupanca, pois o passado anterior a liberacao ja  **/
              /** foi remunerado e contabilizado. 							                 **/
              /********************************************************************/

             IF rw_craprda.dtmvtolt >= to_date('04/05/2012','dd/mm/yyyy') AND
                vr_dtiniper >= vr_datlibpr THEN
                -- Busca valor de moeda utilizada no sistema
                vr_idx_moeda := LPAD(20,2,'0')||To_Char(vr_dtinipop,'YYYYMMDD');
             ELSE
                -- Busca valor de moeda utilizada no sistema
                vr_idx_moeda := LPAD(8,2,'0')||To_Char(vr_dtinipop,'YYYYMMDD');
             END IF;

              IF vr_tab_moedatx.EXISTS(vr_idx_moeda) THEN
                rw_crapmfx.vlmoefix:= vr_tab_moedatx(vr_idx_moeda).vlmoefix;
              ELSE -- Se o registro não for encontrado sinaliza critica
                -- Chamar rotina de gravacão de erro
                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1
                                     ,pr_cdcritic => 211
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_tab_erro => pr_tab_erro);

                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;

              -- Busca taxa de RDCA
              -- Verificar se esta data não existe no vetor
              IF NOT vr_tab_qtdiaute.EXISTS(to_char(vr_dtinipop,'yyyymmdd')) THEN
                -- Buscar a data na tabela
                OPEN cr_craptrd (pr_cdcooper, vr_dtinipop);
                FETCH cr_craptrd INTO rw_craptrd;
                CLOSE cr_craptrd;
              ELSE
                -- Buscar o valor do vetor
                rw_craptrd.qtdiaute:= vr_tab_qtdiaute(to_char(vr_dtinipop,'yyyymmdd'));
              END IF;

              -- Executa procedure para calculo de poupanca
              pc_calctx_poupanca (pr_cdcooper
                                 ,rw_craptrd.qtdiaute
                                 ,rw_crapmfx.vlmoefix
                                 ,vr_txmespop
                                 ,vr_txdiapop);

              IF vr_txaplrgt < vr_txdiapop / 100 THEN
                vr_txaplrgt := vr_txdiapop / 100;
              END IF;
            END IF;
          END IF;

          -- Atribui valores executando para calculo
          vr_vlrenrgt := TRUNC(vr_vlsdrdca * vr_txaplrgt, 8);
          vr_vlsdrdca := vr_vlsdrdca + vr_vlrenrgt;
          vr_vlrentot := vr_vlrentot + vr_vlrenrgt;
          vr_dtiniper := vr_dtiniper + 1;
        EXCEPTION
          WHEN vr_exc_erro THEN
            -- Replicar a exceção
            RAISE vr_exc_erro;
          WHEN vr_controle THEN
            -- Controle de fluxo de saida do while.
            NULL;
        END;
      END LOOP;

      -- Atribui valores calculados para os parametros de saida
      pr_vlrenrgt := fn_round(vr_vlrentot, 2);

      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN others THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        vr_dscritic := 'APLI0001.pc_rendi_apl_pos_com_resgate --> Erro nao tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_rendi_apl_pos_com_resgate;

  /* Rotina de calculo da provisao no final do mes e no vencimento. */
  PROCEDURE pc_provisao_rdc_pos(pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Codigo cooperativa
                               ,pr_cdagenci  IN crapass.cdagenci%TYPE        --> Codigo da agencia
                               ,pr_nrdcaixa  IN craperr.nrdcaixa%TYPE        --> Numero do caixa
                               ,pr_nrctaapl  IN craprda.nrdconta%TYPE        --> Numero da conta
                               ,pr_nraplres  IN craprda.nraplica%TYPE        --> Numero da aplicacao
                               ,pr_dtiniper  IN craprda.dtiniper%TYPE        --> Data inicio do periodo
                               ,pr_dtfimper  IN craprda.dtfimper%TYPE        --> Data fim do periodo
                               ,pr_dtinitax   IN craprda.dtmvtolt%TYPE       --> Data Inicial da Utilizacao da taxa da poupanca
                               ,pr_dtfimtax   IN craprda.dtmvtolt%TYPE       --> Data Final da Utilizacao da taxa da poupanca
                               ,pr_flantven  IN BOOLEAN                      --> Indicador de taxa minima
                               ,pr_vlsdrdca  OUT NUMBER                      --> Valor RDCA
                               ,pr_vlrentot  OUT NUMBER                      --> Valor total
                               ,pr_des_reto  OUT VARCHAR                     --> Indicador de saida com erro (OK/NOK)
                               ,pr_tab_erro  OUT GENE0001.typ_tab_erro ) IS  --> Tabela com erros
  --  .......................................................................................
  --
  -- Programa: pc_provisao_rdc_pos - Antiga b1wgen0004.provisao_rdc_pos
  -- Autor   : ---
  -- Data    : ---                        Ultima atualizacao: 25/06/2014
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : BO CONSULTA SALDO E EXTRATO DE APLICACOES
  --             Calculo da provisao no final do mes e no vencimento.
  --
  -- Alteracoes: 14/01/2013 - conversao Progress >> PL/SQL (Oracle). Petter - Supero.
  --
  --             18/03/2013 - Ajustes ao calcular a vr_vlrendim,
  --                          referente a criterios de arredondamento (Odirlei-AMcom)
  --
  --             07/04/2014 - Alterações referente ao novo indexador de poupanca
  --                          (Jean Michel).
	--						 22/04/2014 - Inclusão do crapmfx.tpmoefix = 20 no cursor
	--  												cr_crapmfx (Jean Michel).
  --
  --             24/06/2014 - Retirada leitura da craptab e incluido data de
  --                          liberacao do projeto do novo indexador de
  --                          poupanca fixa - 01/07/2014 (Jean Michel).
  --             25/06/2014 - Ajustes no tratamento de exceção (Marcos-Supero)
  -- .......................................................................................
  BEGIN
    DECLARE
      vr_vlrendim   NUMBER(15,8);
      vr_exec_erro  EXCEPTION;
      vr_dtinitax   DATE;
      vr_dtfimtax   DATE;
      vr_controle   EXCEPTION;
      vr_txaplmes   NUMBER(15,8);
      vr_txaplica   NUMBER(15,8);
      vr_dtinipop   DATE;
      vr_txmespop   NUMBER(10,8);
      vr_txdiapop   NUMBER(10,8);
      vr_dtiniper   craprda.dtiniper%TYPE;
      vr_datlibpr   DATE;

      -- variaveis temporarias para armazenar o retorno
      -- com 4 casas decimais, e somente no final, retornar
      -- para os parametros de saida, pois as variaveis utilizadas
      -- na chamada podem ter menos casas decimais
      vr_vlsdrdca NUMBER(18,4) := 0; --> Valor RDCA
      vr_vlrentot NUMBER(18,4) := 0; --> Valor total

      -- Lancamentos nas aplicacoes RDCA
      CURSOR cr_craplap (pr_cdcooper  IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta  IN craprda.nrdconta%TYPE
                        ,pr_nraplica  IN craprda.nraplica%TYPE
                        ,pr_dtmvtolt  IN craprda.dtmvtolt%TYPE) IS
        SELECT cl.txaplica
              ,cl.txaplmes
        FROM craplap cl
        WHERE cl.cdcooper = pr_cdcooper
          AND cl.nrdconta = pr_nrdconta
          AND cl.nraplica = pr_nraplica
          AND cl.dtmvtolt = pr_dtmvtolt;
      rw_craplap cr_craplap%rowtype;

      -- Variaveis para busca das informacoes de moeda
      vr_idx_moeda VARCHAR2(10) := '';
      vr_vlmoefix  crapmfx.vlmoefix%TYPE;
      -- Buscar todos os registros das moedas do tipo 6 e 8
      CURSOR cr_crapmfx(pr_cdcooper IN crapmfx.cdcooper%TYPE) IS
        SELECT crapmfx.dtmvtolt
              ,crapmfx.tpmoefix
              ,crapmfx.vlmoefix
          FROM crapmfx crapmfx
         WHERE crapmfx.cdcooper = pr_cdcooper
           AND crapmfx.tpmoefix IN(6,8,20);

      -- Buscar a qtde dias uteis na tabela de taxas
      CURSOR cr_craptrd(pr_dtiniper IN DATE) IS
        SELECT trd.qtdiaute
          FROM craptrd trd
         WHERE cdcooper = pr_cdcooper
           AND dtiniper = pr_dtiniper
         ORDER BY progress_recid;
      vr_qtdiaute craptrd.qtdiaute%TYPE;

      -- Buscar dados de datas de controle
      CURSOR cr_craptrdf(pr_cdcooper IN craptrd.cdcooper%TYPE) IS
        SELECT craptrd.dtiniper
              ,craptrd.qtdiaute
              ,COUNT(*) over (PARTITION BY craptrd.dtiniper ORDER BY craptrd.progress_recid) registro
         FROM craptrd
         WHERE craptrd.cdcooper = pr_cdcooper;

    BEGIN

      -- Busca de aplicacões RDCA
      OPEN cr_craprda(pr_cdcooper, pr_nrctaapl, pr_nraplres);
      FETCH cr_craprda INTO rw_craprda;

      vr_dtiniper := pr_dtiniper;

      -- Se não encontrar registro gera critica
      IF cr_craprda%notfound OR rw_craprda.retorno > 1 THEN
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => 426
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';

        CLOSE cr_craprda;
        RAISE vr_exec_erro;
      ELSE
        CLOSE cr_craprda;
      END IF;

      -- Buscas as taxas contratadas
      OPEN cr_craplap(pr_cdcooper, rw_craprda.nrdconta, rw_craprda.nraplica, rw_craprda.dtmvtolt);
      FETCH cr_craplap INTO rw_craplap;

      -- Se não encontrou registros gera critica
      IF cr_craplap%notfound THEN
        -- Chamar rotina de gravacão de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => 90
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';

        CLOSE cr_craplap;
        RAISE vr_exec_erro;
      ELSE
        CLOSE cr_craplap;
      END IF;

      -- Controla taxa minima
      IF pr_flantven = TRUE THEN
        vr_vlsdrdca := rw_craprda.vlsltxmm;
      ELSE
        vr_vlsdrdca := rw_craprda.vlsltxmx;
      END IF;

      -- Data de fim e inicio da utilizacão da taxa de poupanca.
      -- Utiliza-se essa data quando o rendimento da aplicacão for menor que
      -- a poupanca, a cooperativa opta por usar ou não.
      IF pr_dtinitax IS NULL OR pr_dtfimtax IS NULL THEN
        vr_dtinitax := to_date('01/01/9999', 'DD/MM/RRRR');
        vr_dtfimtax := to_date('01/01/9999', 'DD/MM/RRRR');
      ELSE
        vr_dtinitax := pr_dtinitax;
        vr_dtfimtax := pr_dtfimtax;
      END IF;

      -- Se o vetor de dias uteis ainda nao possuir informacões
      IF vr_tab_qtdiaute.COUNT = 0 THEN
        -- Buscar os dias uteis
        FOR rw_craptrd IN cr_craptrdf(pr_cdcooper) LOOP
          -- Atribuir o valor selecionado ao vetor somente para a primeira data encontrada (mais antiga)
          IF rw_craptrd.registro = 1 THEN
            vr_tab_qtdiaute(to_char(rw_craptrd.dtiniper,'YYYYMMDD')):= rw_craptrd.qtdiaute;
          END IF;
        END LOOP;
      END IF;

      -- Se o vetor de moedas ainda não possuir informacões
      IF vr_tab_moedatx.COUNT = 0 THEN
        -- Buscar todos os registros das moedas do tipo 6 e 8
        FOR rw_crapmfx IN cr_crapmfx(pr_cdcooper => pr_cdcooper) LOOP
          -- MOntar a chave do registro com o tipo + data
          vr_idx_moeda := LPAD(rw_crapmfx.tpmoefix,2,'0')||To_Char(rw_crapmfx.dtmvtolt,'YYYYMMDD');
          -- Atribuir o valor selecionado ao vetor
          vr_tab_moedatx(vr_idx_moeda).vlmoefix := rw_crapmfx.vlmoefix;
          -- Para moeda 6 - CDI
          IF rw_crapmfx.tpmoefix = 6 THEN
            -- Calcular a taxa de aplicacao
            vr_tab_moedatx(vr_idx_moeda).txaplmes := (POWER((1 + rw_crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100;
          END IF;
        END LOOP;
      END IF;

      -- Data de liberacao do projeto novo indexador de poupanca
      vr_datlibpr := to_date('01/07/2014','dd/mm/yyyy');

      -- Navegar entre o periodo passado
      WHILE vr_dtiniper < pr_dtfimper
      LOOP
        BEGIN
          -- Busca feriados
          vr_dtiniper := gene0005.fn_valida_dia_util(pr_cdcooper
                                                    ,vr_dtiniper
                                                    ,pr_tipo     => 'P'     -- valor padrao
                                                    ,pr_feriado  => true    -- valor padrao 
                                                    ,pr_excultdia => true); -- considera 31/12 como util

          -- Se atender condicão de datas finaliza iteracao do WHILE.
          IF vr_dtiniper >= pr_dtfimper THEN
            RAISE vr_controle;
          END IF;

          -- Limpar variavel de moeda
          vr_vlmoefix := NULL;
          -- Montar chave de procura de CDI ano + data atual
          vr_idx_moeda := '06'||To_Char(vr_dtiniper,'YYYYMMDD');
          -- Verificar se o indice existe na tabela
          IF vr_tab_moedatx.EXISTS(vr_idx_moeda) THEN
            -- Atribuir o valor do vetor para a variavel
            vr_vlmoefix := vr_tab_moedatx(vr_idx_moeda).vlmoefix;
          ELSE
            -- Gerar erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                                 ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                                 ,pr_nrsequen => 1 --> Fixo
                                 ,pr_cdcritic => 211 --> Critica 211
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
            -- Levantar excecao
            RAISE vr_exc_erro;
          END IF;
          -- Guardar taxa aplicada ao mes ja calculada no vetor
          vr_txaplmes := vr_tab_moedatx(vr_idx_moeda).txaplmes;

          -- Calcula o saldo com a taxa minina se for antes do vencimento.
          IF pr_flantven = TRUE AND rw_craplap.txaplica <> rw_craplap.txaplmes THEN
            vr_txaplica := fn_round((vr_txaplmes * rw_craplap.txaplmes / 100 ) / 100 , 8);

          ELSE
            vr_txaplica := fn_round((vr_txaplmes * rw_craplap.txaplica / 100 ) / 100 , 8);

            IF vr_dtiniper > vr_dtinitax AND rw_craprda.dtmvtolt < vr_dtfimtax THEN
              BEGIN
                -- Usar poupanca de um mes atras.
                vr_dtinipop := to_date(to_char(vr_dtiniper, 'DD') || '/' || to_char(to_char(vr_dtiniper, 'MM') - 1) || '/' || to_char(vr_dtiniper, 'RRRR'), 'DD/MM/RRRR');
              EXCEPTION
                WHEN others THEN
                  -- Tratar anos anteriores.
                  -- Caso não exista a data, pegar primeiro dia do mes.
                  IF to_number(to_char(vr_dtiniper, 'MM')) = 1 THEN
                    vr_dtinipop := vr_dtiniper - 31;
                  ELSE
                    vr_dtinipop := to_date('01/' || to_char(vr_dtiniper, 'MM') || '/' || to_char(vr_dtiniper, 'RRRR'), 'DD/MM/RRRR');
                  END IF;
              END;

              -- Limpar auxiliar de moeda
              vr_vlmoefix := NULL;

              /********************************************************************/
              /** Em Maio de 2012 o novo calculo foi liberado para utilizacao,   **/
              /** portanto aplicacoes cadastradas a partir desta data poderiam   **/
              /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
              /** vamos calcular o rendimento desta aplicacao com base na nova   **/
              /** regra somente a partir da data de liberacao do projeto de novo **/
              /** indexador de poupanca, pois o passado anterior a liberacao ja  **/
              /** foi remunerado e contabilizado. 							                 **/
              /********************************************************************/

              IF rw_craprda.dtmvtolt >= to_date('04/05/2012','dd/mm/yyyy') AND
                 vr_dtiniper >= vr_datlibpr THEN
                 -- Busca valor de moeda de saida
                 -- Montar a chave do registro com o tipo + data
                 vr_idx_moeda := LPAD(20,2,'0')||To_Char(vr_dtinipop,'YYYYMMDD');
              ELSE
                 -- Busca valor de moeda de saida
                 -- Montar a chave do registro com o tipo + data
                 vr_idx_moeda := LPAD(8,2,'0')||To_Char(vr_dtinipop,'YYYYMMDD');
              END IF;

              -- Verificar se o indice existe na tabela
              IF vr_tab_moedatx.EXISTS(vr_idx_moeda) THEN
                -- Atribuir o valor do vetor para a variavel
                vr_vlmoefix := vr_tab_moedatx(vr_idx_moeda).vlmoefix;
              ELSE
                -- Gerar erro 211
                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => 0   --> Fixo pois e irrelevante
                                     ,pr_nrdcaixa => 999 --> Fixo pois e irrelevante
                                     ,pr_nrsequen => 1 --> Fixo
                                     ,pr_cdcritic => 211 --> Critica 211
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_tab_erro => pr_tab_erro);
                -- Levantar excecao
                RAISE vr_exc_erro;
              END IF;

              -- Verificar se esta data não existe no vetor
              IF NOT vr_tab_qtdiaute.EXISTS(to_char(vr_dtinipop,'yyyymmdd')) THEN
                -- Buscar a data na tabela
                OPEN cr_craptrd(pr_dtiniper => vr_dtinipop);
                FETCH cr_craptrd
                 INTO vr_qtdiaute;
                CLOSE cr_craptrd;
              ELSE
                -- Buscar o valor do vetor
                vr_qtdiaute := vr_tab_qtdiaute(to_char(vr_dtinipop,'yyyymmdd'));
              END IF;

              -- Calcula taxa de poupanca
              APLI0001.pc_calctx_poupanca(pr_cdcooper
                                         ,vr_qtdiaute
                                         ,vr_vlmoefix
                                         ,vr_txmespop
                                         ,vr_txdiapop);

              -- Atribuicao de taxa aplicada
              IF vr_txaplica < vr_txdiapop / 100 THEN
                vr_txaplica := vr_txdiapop / 100;
              END IF;

            END IF;
          END IF;

          -- Atribuicao de valores para paremtros de saida e calculos finais
          --Devido a limitações do progress, é necessario arredondar para 10casas, antes de truncar
          vr_vlrendim := TRUNC(APLI0001.fn_round(vr_vlsdrdca * vr_txaplica,10), 8);
          vr_vlsdrdca := vr_vlsdrdca + vr_vlrendim;
          vr_vlrentot := vr_vlrentot + vr_vlrendim;
          vr_dtiniper := vr_dtiniper + 1;

        EXCEPTION
          WHEN vr_exc_erro THEN
            -- Replicar a exceção
            RAISE vr_exc_erro;
          WHEN vr_controle THEN
            -- Controle para interrupcao da iteracao
            NULL;
        END;
      END LOOP;

      -- Atribuicao dos valores de saida no final da procedure
      pr_vlrentot := fn_round(vr_vlrentot, 4);
      pr_vlsdrdca := fn_round(vr_vlsdrdca, 4);
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN vr_exec_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN others THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_provisao_rdc_pos --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_provisao_rdc_pos;

  /* Gerar extrato RDC */
  PROCEDURE pc_extrato_rdc (pr_cdcooper          IN crapcop.cdcooper%TYPE                   --> Codigo cooperativa
                           ,pr_cdagenci          IN crapass.cdagenci%TYPE                   --> Codigo da agencia
                           ,pr_nrdcaixa          IN craperr.nrdcaixa%TYPE                   --> Numero do caixa
                           ,pr_nrctaapl          IN craprda.nrdconta%TYPE                   --> Numero de conta
                           ,pr_nraplres          IN craprda.nraplica%TYPE                   --> Numero da aplicacao
                           ,pr_dtiniper          IN craprda.dtiniper%TYPE                   --> Data inicial do periodo
                           ,pr_dtfimper          IN craprda.dtfimper%TYPE                   --> Data final do periodo
                           ,pr_typ_tab_extr_rdc  OUT typ_tab_extr_rdc                       --> TEMP TABLE de extrato
                           ,pr_des_reto          OUT VARCHAR                                --> Indicador de saida com erro (OK/NOK)
                           ,pr_tab_erro          OUT GENE0001.typ_tab_erro ) IS             --> Tabela com erros
  --  .......................................................................................
  --
  -- Programa: pc_extrato_rdc - Antiga b1wgen0004.extrato_rdc
  -- Autor   : ---
  -- Data    : ---                        Ultima atualizacao: 15/01/2013
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : BO CONSULTA SALDO E EXTRATO DE APLICACOES
  --             Gerar TEMP TABLE com o extrato RDC.
  --
  -- Alteracoes: 15/01/2013 - conversão Progress >> PL/SQL (Oracle). Petter - Supero.
  --
  -- .......................................................................................
  BEGIN
    DECLARE
      vr_exec_erro   EXCEPTION;
      vr_vlstotal    NUMBER := 0;
      vr_dshistor    VARCHAR2(400);
      vr_index       NUMBER := 0;
      vr_flgimune    BOOLEAN;
      vr_dtiniimu    DATE;
      vr_dtfimimu    DATE;

      -- Cadastro dos lancamentos de aplicacoes RDCA
      CURSOR cr_craplap (pr_cdcooper   IN crapcop.cdcooper%TYPE
                        ,pr_nrctaapl   IN craprda.nrdconta%TYPE
                        ,pr_nraplres   IN craprda.nraplica%TYPE
                        ,pr_dtiniper   IN craplap.dtmvtolt%TYPE
                        ,pr_dtfimper   IN craplap.dtmvtolt%TYPE) IS
        SELECT /*+ index (cp craplap##craplap5)*/
               cp.ROWID
              ,cp.cdhistor
              ,cp.vllanmto
              ,cp.dtmvtolt
              ,cp.cdagenci
              ,cp.cdbccxlt
              ,cp.nrdolote
              ,cp.nrdocmto
              ,cp.txaplica
              ,cp.vlpvlrgt
        FROM craplap cp
        WHERE cp.cdcooper = pr_cdcooper
          AND cp.nrdconta = pr_nrctaapl
          AND cp.nraplica = pr_nraplres
          AND cp.cdhistor IN (527,528,529,530,531,533,534,532,472,473,474,475,463,478,475,476,477,121,923,924)
          AND (cp.dtmvtolt >= pr_dtiniper OR pr_dtiniper IS NULL)
          AND (cp.dtmvtolt <= pr_dtfimper OR pr_dtfimper IS NULL)
        ORDER BY cp.dtmvtolt, cp.cdhistor;

      -- Historico do sistema
      CURSOR cr_craphis (pr_cdcooper   IN crapcop.cdcooper%TYPE
                        ,pr_cdhistor   IN craplap.cdhistor%TYPE) IS
        SELECT cs.ROWID
              ,cs.cdhistor
              ,cs.dshistor
              ,cs.indebcre
              ,count(1) over() retorno
        FROM craphis cs
        WHERE cs.cdcooper = pr_cdcooper
          AND cs.cdhistor = pr_cdhistor;
      rw_craphis cr_craphis%rowtype;

    BEGIN
      -- Busca aplicacoes RDCA
      OPEN cr_craprda (pr_cdcooper, pr_nrctaapl, pr_nraplres);
      FETCH cr_craprda INTO rw_craprda;

      -- Se não encontrar registro gera critica
      IF cr_craprda%notfound OR rw_craprda.retorno > 1 THEN
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => 426
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';

        CLOSE cr_craprda;
        RAISE vr_exec_erro;
      ELSE
        CLOSE cr_craprda;
      END IF;

      /* Procedure para verificar periodo de imunidade tributaria */
      IMUT0001.pc_verifica_periodo_imune( pr_cdcooper => pr_cdcooper  --> Codigo Cooperativa
                                         ,pr_nrdconta => pr_nrctaapl  --> Numero da Conta
                                         ,pr_flgimune => vr_flgimune  --> Identificador se é imune
                                         ,pr_dtinicio => vr_dtiniimu  --> Data de inicio da imunidade
                                         ,pr_dttermin => vr_dtfimimu  --> Data termino da imunidadeValor insento
                                         ,pr_dsreturn => pr_des_reto  --> Descricao retorno(NOK/OK)
                                         ,pr_tab_erro => pr_tab_erro);--> Tabela erros

      IF pr_des_reto = 'NOK' THEN
         RAISE vr_exec_erro;
      END IF;

      -- Busca lancamentos de aplicacoes RDCA
      FOR rw_craplap IN cr_craplap(pr_cdcooper, pr_nrctaapl, pr_nraplres, pr_dtiniper, pr_dtfimper) LOOP
        -- Busca historico no sistema
        OPEN cr_craphis (pr_cdcooper, rw_craplap.cdhistor);
        FETCH cr_craphis INTO rw_craphis;

        -- Se não encontrar registro gera critica
        IF cr_craphis%notfound OR rw_craphis.retorno > 1 THEN
          -- Chamar rotina de gravacao de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => 80
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

          pr_des_reto := 'NOK';

          CLOSE cr_craphis;
          RAISE vr_exec_erro;
        ELSE
          CLOSE cr_craphis;
        END IF;

        IF vr_flgimune THEN
          IF (rw_craplap.cdhistor = 475 OR  /*Rendimento*/
              rw_craplap.cdhistor = 532     /*Rendimento*/
              ) AND
             rw_craplap.dtmvtolt >= vr_dtiniimu   AND
             (vr_dtfimimu      is null    OR
              (vr_dtfimimu     is not null  AND
               rw_craplap.dtmvtolt <= vr_dtfimimu
               )
              ) THEN
            vr_dshistor := to_char(rw_craphis.cdhistor,'999')||'-'||rw_craphis.dshistor|| '*';
          ELSE
            vr_dshistor := to_char(rw_craphis.cdhistor,'999')||'-'||rw_craphis.dshistor;
          END IF;
        ELSE
          vr_dshistor := to_char(rw_craphis.cdhistor, '999') || '-' || rw_craphis.dshistor;
        END IF;

        -- Faz consistencia caso o historico seja 999.
        -- Calcula debito e credito ou levanta excecao em caso fora do padrão.
        IF rw_craphis.cdhistor NOT IN ('999') THEN
          IF rw_craphis.indebcre = 'C' THEN
            vr_vlstotal := vr_vlstotal + rw_craplap.vllanmto;
          ELSIF rw_craphis.indebcre = 'D' THEN
            vr_vlstotal := vr_vlstotal - rw_craplap.vllanmto;
          ELSE
            -- Chamar rotina de gravacao de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1
                                 ,pr_cdcritic => 83
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);

            pr_des_reto := 'NOK';

            RAISE vr_exec_erro;
          END IF;
        END IF;

        -- Grava extrato na TEMP TABLE
        vr_index := pr_typ_tab_extr_rdc.count() + 1;

        pr_typ_tab_extr_rdc(vr_index).dtmvtolt := rw_craplap.dtmvtolt;
        pr_typ_tab_extr_rdc(vr_index).cdagenci := rw_craplap.cdagenci;
        pr_typ_tab_extr_rdc(vr_index).cdbccxlt := rw_craplap.cdbccxlt;
        pr_typ_tab_extr_rdc(vr_index).nrdolote := rw_craplap.nrdolote;
        pr_typ_tab_extr_rdc(vr_index).cdhistor := rw_craplap.cdhistor;
        pr_typ_tab_extr_rdc(vr_index).dshistor := vr_dshistor;
        pr_typ_tab_extr_rdc(vr_index).nrdocmto := rw_craplap.nrdocmto;
        pr_typ_tab_extr_rdc(vr_index).indebcre := rw_craphis.indebcre;
        pr_typ_tab_extr_rdc(vr_index).vllanmto := rw_craplap.vllanmto;
        pr_typ_tab_extr_rdc(vr_index).vlsdlsap := vr_vlstotal;

        IF NVL(rw_craplap.txaplica, 0) < 0 THEN
          pr_typ_tab_extr_rdc(vr_index).txaplica := 0;
        ELSE
          pr_typ_tab_extr_rdc(vr_index).txaplica := rw_craplap.txaplica;
        END IF;

        IF rw_craplap.cdhistor = 534 THEN
          pr_typ_tab_extr_rdc(vr_index).vlpvlrgt := rw_craplap.vlpvlrgt;
        ELSE
          pr_typ_tab_extr_rdc(vr_index).vlpvlrgt := 0;
        END IF;
      END LOOP;

      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exec_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN others THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        vr_dscritic := 'APLI0001.pc_extrato_rdc --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_extrato_rdc;

  /* Rotina de calculo da provisao mensal do RDCA2 */
  PROCEDURE pc_calc_provisao_mensal_rdca2 (pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do processo
                                          ,pr_nrdconta IN craprda.nrdconta%TYPE --> Nro da conta da aplicacao RDCA
                                          ,pr_nraplica IN craprda.nraplica%TYPE --> Nro da aplicacao RDCA
                                          ,pr_vltotrda IN craprda.vlsdrdca%TYPE --> Valor total rendimento
                                          ,pr_vlsdrdca OUT craprda.vlsdrdca%TYPE --> Valor Saldo Aplicacao
                                          ,pr_txaplica OUT NUMBER               --> Taxa de Aplicacao
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de critica
                                          ,pr_des_erro OUT VARCHAR2) IS         --> Saida com erros;
  BEGIN
  /* .............................................................................

   Programa: pc_calcula_provisao_mensal_rdca2    Antigo: Includes/rdca2m.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/96.                        Ultima atualizacao: 04/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de calculo da provisao mensal do RDCA2 - Deve ser chamada
               dentro de um FOR EACH ou DO WHILE e com label TRANS_1.

   Alteracoes: 11/03/98 - Alterado para tratar taxa especial no periodo
                          de 10/02/98 a 05/03/98 (Deborah).

               29/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               23/03/99 - Nao marcar a taxa como utilizada no processo mensal
                          (Deborah).

               01/12/1999 - Tratar somente carencia 0 (Deborah).

               29/04/2002 - Nova regra para pegar a taxa (Margarete).

               23/09/2004 - Incluido historico 494(CI)(Mirtes)

               16/12/2004 - Ajustes para tratar das novas aliquotas de
                            IRRF (Margarete).

               06/05/2005 - Utilizar o indice craplap5 na leitura dos
                            lancamentos (Edson).

               06/07/2005 - Alimentado campo cdcooper das tabelas craplot e
                            craplap (Diego).

               03/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               27/07/2007 - Alteracao para melhoria de performance (Evandro).

               01/04/2013 - Conversão Progress >> Oracle (PLSQL) (Alisson-AMcom)

               04/11/2013 - Eliminar tratamento do campo lsaplica (Gabriel).

               07/04/2014 - Alteracao do tipo de taxa de 4 p/ 5, se data estiver
                            em periodo especial (Jean Michel).

							 04/06/2014 - Ajuste nas leituras da CRAPTRD para utilizar o
														VLFAIXAS na ordenação da busca (Marcos-Supero).
  ............................................................................. */
    DECLARE

      -- Selecionar informacoes dos rendimentos das aplicacoes
      CURSOR cr_craprda (pr_cdcooper IN craprda.cdcooper%TYPE
                        ,pr_nrdconta IN craprda.nrdconta%TYPE
                        ,pr_nraplica IN craprda.nraplica%TYPE) IS
        SELECT craprda.dtmvtolt
              ,craprda.inaniver
              ,craprda.vlsdrdca
              ,craprda.dtiniper
              ,craprda.dtfimper
              ,craprda.ROWID
        FROM craprda craprda
        WHERE craprda.cdcooper  = pr_cdcooper
        AND   craprda.nrdconta  = pr_nrdconta
        AND   craprda.nraplica  = pr_nraplica;
      rw_craprda cr_craprda%ROWTYPE;

      -- Selecionar informacoes das taxas
      CURSOR cr_craptrd (pr_cdcooper IN craptrd.cdcooper%TYPE
                        ,pr_dtiniper IN craptrd.dtiniper%TYPE
                        ,pr_tptaxrda IN craptrd.tptaxrda%TYPE
                        ,pr_vlfaixas IN craptrd.vlfaixas%TYPE)  IS
        SELECT craptrd.txofimes
        FROM craptrd craptrd
        WHERE craptrd.cdcooper  = pr_cdcooper
        AND   craptrd.dtiniper  = pr_dtiniper
        AND   craptrd.tptaxrda  = pr_tptaxrda
        AND   craptrd.incarenc  = 0
        AND   craptrd.vlfaixas <= pr_vlfaixas
        ORDER BY craptrd.vlfaixas DESC;
      rw_craptrd cr_craptrd%ROWTYPE;

      -- Leitura dos lancamentos de resgate da aplicacao
      CURSOR cr_craplap(pr_cdcooper IN craplap.cdcooper%TYPE
                       ,pr_nrdconta IN craplap.nrdconta%TYPE
                       ,pr_nraplica IN craplap.nraplica%TYPE
                       ,pr_dtrefant IN DATE
                       ,pr_dtrefere IN DATE
                       ,pr_dtcalcul IN DATE
                       ,pr_dtmvtolt IN DATE) IS
        SELECT craplap.cdhistor
              ,Nvl(SUM(Nvl(craplap.vllanmto,0)),0) vllanmto
        FROM craplap craplap
        WHERE craplap.cdcooper  = pr_cdcooper
        AND   craplap.nrdconta  = pr_nrdconta
        AND   craplap.nraplica  = pr_nraplica
        AND   (craplap.dtrefere = pr_dtrefant OR craplap.dtrefere = pr_dtrefere)
        AND   craplap.dtmvtolt  >= pr_dtcalcul
        AND   craplap.dtmvtolt  <= pr_dtmvtolt
        AND   craplap.cdhistor  IN (178,180,181,182,494,876)
        GROUP BY craplap.cdhistor;
      rw_craplap cr_craplap%ROWTYPE;

      --Selecionar Informacoes do lote
      CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplot.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT craplot.cdcooper
              ,craplot.dtmvtolt
              ,craplot.cdagenci
              ,craplot.cdbccxlt
              ,craplot.nrdolote
              ,craplot.tplotmov
              ,Nvl(craplot.qtinfoln,0) qtinfoln
              ,Nvl(craplot.qtcompln,0) qtcompln
              ,Nvl(craplot.nrseqdig,0) nrseqdig
              ,Nvl(craplot.vlinfocr,0) vlinfocr
              ,Nvl(craplot.vlcompcr,0) vlcompcr
              ,Nvl(craplot.vlinfodb,0) vlinfodb
              ,Nvl(craplot.vlcompdb,0) vlcompdb
              ,craplot.rowid
        FROM craplot craplot
        WHERE craplot.cdcooper = pr_cdcooper
        AND   craplot.dtmvtolt = pr_dtmvtolt
        AND   craplot.cdagenci = pr_cdagenci
        AND   craplot.cdbccxlt = pr_cdbccxlt
        AND   craplot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      --Variaveis Auxiliares para Calculo
      vr_tptaxrda     INTEGER:= 0;
      vr_rd2_nrdiacal INTEGER:= 0;
      vr_rd2_nrdiames INTEGER:= 0;
      vr_rd2_nrdolote INTEGER:= 0;
      vr_rd2_cdagenci INTEGER:= 1;
      vr_rd2_cdbccxlt INTEGER:= 100;
      vr_rd2_txaplica NUMBER:= 0;
      vr_rd2_vlrentot NUMBER:= 0;
      vr_rd2_vlrendim NUMBER:= 0;
      vr_rd2_vlprovis NUMBER:= 0;
      vr_rd2_vlsdrdca NUMBER:= 0;

      vr_rd2_vllan178 NUMBER;
      vr_rd2_vllan180 NUMBER;
      vr_rd2_dtcalcul DATE;
      vr_rd2_dtrefant DATE;
      vr_rd2_dtrefere DATE;
      vr_rd2_dtmvtolt DATE;
      vr_rd2_dtultdia DATE;
      vr_rd2_dtdolote DATE;
      vr_rd2_flgentra BOOLEAN;

      --Variaveis de retorno de erro
      vr_des_erro VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;

    BEGIN

      -- Buscar os dados da aplicacao RDCA
      OPEN cr_craprda (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nraplica => pr_nraplica);
      FETCH cr_craprda INTO rw_craprda;
      CLOSE cr_craprda;

      -- Inicializar as variaveis para o calculo
      vr_rd2_vlrentot:= 0;
      vr_rd2_vlrendim:= 0;
      vr_rd2_vllan178:= 0;
      vr_rd2_vllan180:= 0;
      vr_rd2_vlprovis:= 0;
      vr_rd2_vlsdrdca:= rw_craprda.vlsdrdca;

      --Se nao completou 1 mes de aviversario
      IF rw_craprda.inaniver = 0 THEN
        --Proximo dia a ser calculado recebe a data do movimento
        vr_rd2_dtcalcul:= rw_craprda.dtmvtolt;
        --Se a data do movimento for diferente da data de inicio da operacao
        IF rw_craprda.dtmvtolt <> rw_craprda.dtiniper THEN
          --Data de referencia anterior recebe a data de inicio de operacao
          vr_rd2_dtrefant:= rw_craprda.dtiniper;
        ELSE
          --Data de referencia recebe data final de operacao
          vr_rd2_dtrefant:= rw_craprda.dtfimper;
        END IF;
      ELSE
        --Proximo dia a ser calculado recebe a data de inicio da operacao
        vr_rd2_dtcalcul:= rw_craprda.dtiniper;
      END IF;

      --Data de referencia recebe a data de fim de periodo
      vr_rd2_dtrefere:= rw_craprda.dtfimper;
      --Data de movimento recebe a data do movimento da crapdat
      vr_rd2_dtmvtolt:= pr_dtmvtolt;
      --Ultimo dia do mes
      vr_rd2_dtultdia:= Last_Day(pr_dtmvtolt);

      /*   Verifica se esta no periodo especial */
      IF rw_craprda.dtmvtolt BETWEEN To_Date('09/02/1998','DD/MM/YYYY') AND To_Date('06/03/1998','DD/MM/YYYY') THEN
        --Tipo de taxa rda recebe 5
        vr_tptaxrda:= 5;
      ELSE
        --Tipo de taxa rda recebe 3
        vr_tptaxrda:= 3;
      END IF;

      /*  Verifica se deve lancar apenas a provisao  */
      -- Se a aplicacao não completou um mes e a data de referencia igual a anterior
      IF rw_craprda.inaniver = 0 AND vr_rd2_dtrefant = vr_rd2_dtrefere THEN
        --Flag controle recebe false
        vr_rd2_flgentra:= FALSE;
      ELSE
        vr_rd2_flgentra:= TRUE;
      END IF;

      /*  Leitura dos lancamentos de resgate e/ou provisao da aplicacao  */

      -- Leitura dos lancamentos
      FOR rw_craplap IN cr_craplap (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nraplica => pr_nraplica
                                   ,pr_dtrefant => vr_rd2_dtrefant
                                   ,pr_dtrefere => vr_rd2_dtrefere
                                   ,pr_dtcalcul => vr_rd2_dtcalcul
                                   ,pr_dtmvtolt => vr_rd2_dtmvtolt) LOOP
        --Se for lancamento 180 (provisao) ou 181 (Ajuste provisao)
        IF rw_craplap.cdhistor IN (180,181) THEN
          --Somar 180
          vr_rd2_vllan180:= vr_rd2_vllan180 + NVL(rw_craplap.vllanmto,0);
        ELSIF rw_craplap.cdhistor IN (182) THEN
          --Diminuir 180
          vr_rd2_vllan180:= vr_rd2_vllan180 - NVL(rw_craplap.vllanmto,0);
        ELSIF rw_craplap.cdhistor IN (178,876,494) THEN
         --Somar 178
         vr_rd2_vllan178:= vr_rd2_vllan178 + Nvl(rw_craplap.vllanmto,0);
        END IF;
      END LOOP;
      --Valor saldo recebe valor saldo menos Resgate p/ Conta Corrente
      vr_rd2_vlsdrdca:= Nvl(vr_rd2_vlsdrdca,0) - Nvl(vr_rd2_vllan178,0);

      --Se for para recalcular o primeiro mes
      IF rw_craprda.inaniver = 0 AND vr_rd2_flgentra THEN
        --Selecionar informacoes das taxas rdca
        OPEN cr_craptrd (pr_cdcooper => pr_cdcooper
                        ,pr_dtiniper => rw_craprda.dtmvtolt
                        ,pr_tptaxrda => vr_tptaxrda
                        ,pr_vlfaixas => pr_vltotrda);
        --Posicionar no primeiro registro
        FETCH cr_craptrd INTO rw_craptrd;

        --Se nao encontrou
        IF cr_craptrd%NOTFOUND THEN
          --Buscar mensagem de erro
          pr_cdcritic := 347;
          vr_des_erro := gene0001.fn_busca_critica(347)||
                         ' Dia: '||to_char(rw_craprda.dtmvtolt, 'dd/mm/yyyy');
          raise vr_exc_erro;
        ELSE
          --Se a taxa oficial for maior zero
          IF rw_craptrd.txofimes > 0 THEN
            --Taxa de aplicacao recebe a taxa oficial mes dividido por 100
            vr_rd2_txaplica:= rw_craptrd.txofimes / 100;
          ELSE
            --Buscar mensagem de erro
            pr_cdcritic := 427;
            vr_des_erro := gene0001.fn_busca_critica(427)||
                           ' Dia: '||to_char(rw_craprda.dtmvtolt, 'dd/mm/yyyy');
            raise vr_exc_erro;
          END IF;
        END IF;
        --Fechar Cursor
        CLOSE cr_craptrd;

        /*  Recalculo do rendimento  */

        --Valor rendimento recebe valor saldo * taxa
        vr_rd2_vlrendim:= TRUNC(vr_rd2_vlsdrdca * vr_rd2_txaplica,8);

        --Valor saldo rdca recebe valor saldo mais rendimento
        vr_rd2_vlsdrdca:= vr_rd2_vlsdrdca + Nvl(vr_rd2_vlrendim,0);

        /*  Arredondamento dos valores calculados  */
        vr_rd2_vlsdrdca:= fn_round(vr_rd2_vlsdrdca,2);
        vr_rd2_vlrendim:= fn_round(vr_rd2_vlrendim,2);
        vr_rd2_vlrentot:= vr_rd2_vlrendim;
      END IF;

      /*  Taxa a ser aplicada conforme a faixa  */
      --Se o indicador do aniversario completou 1 mes
      IF rw_craprda.inaniver = 1 THEN
        --Selecionar informacoes das taxas rdca
        OPEN cr_craptrd (pr_cdcooper => pr_cdcooper
                        ,pr_dtiniper => rw_craprda.dtiniper
                        ,pr_tptaxrda => 3
                        ,pr_vlfaixas => pr_vltotrda);
      ELSE
        --Selecionar informacoes das taxas rdca
        OPEN cr_craptrd (pr_cdcooper => pr_cdcooper
                        ,pr_dtiniper => rw_craprda.dtiniper
                        ,pr_tptaxrda => vr_tptaxrda
                        ,pr_vlfaixas => pr_vltotrda);
      END IF;
      --Posicionar no primeiro registro
      FETCH cr_craptrd INTO rw_craptrd;
      --Se nao encontrou registro
      IF cr_craptrd%NOTFOUND THEN
        --Buscar mensagem de erro
        pr_cdcritic := 347;
        vr_des_erro := gene0001.fn_busca_critica(347)||
                       ' Dia: '||to_char(rw_craprda.dtiniper, 'dd/mm/yyyy');
        raise vr_exc_erro;
      ELSE
        --Se a taxa oficial mes for > 0
        IF rw_craptrd.txofimes > 0 THEN
          -- Taxa de aplicacao recebe iof mes dividido 100
          vr_rd2_txaplica:= rw_craptrd.txofimes / 100;
        ELSE
          --Buscar mensagem de erro
          vr_des_erro := gene0001.fn_busca_critica(427)||
                         ' Dia: '||to_char(rw_craprda.dtiniper, 'dd/mm/yyyy');
          raise vr_exc_erro;
        END IF;
      END IF;
      --Fechar Cursor
      CLOSE cr_craptrd;

      /*  Calculo da provisao mensal  */
      --Numero dias calculados recebe fim periodo menos inicio periodo
      vr_rd2_nrdiacal:= rw_craprda.dtfimper - rw_craprda.dtiniper;
      --Numero de dias no mes recebe ultimo dia + 1 menos inicio periodo
      vr_rd2_nrdiames:= (vr_rd2_dtultdia + 1) - rw_craprda.dtiniper;
      --Valor do rendimento recebe valor saldo multiplicado pela taxa
      vr_rd2_vlrendim:= TRUNC(vr_rd2_vlsdrdca * vr_rd2_txaplica,8);
      --Valor da provisao recebe val rendimento dividido dias multiplicado dia mes

      --Os comandos abaixo nao podem ser executados juntos pois acarretam problema de arredondamento
      vr_rd2_vlprovis:= TRUNC(vr_rd2_vlrendim / vr_rd2_nrdiacal,8);
      vr_rd2_vlprovis:= Trunc(vr_rd2_vlprovis * vr_rd2_nrdiames,8);

      --Valor saldo rdca recebe valor saldo mais a provisao calculada
      vr_rd2_vlsdrdca:= Nvl(vr_rd2_vlsdrdca,0) + Nvl(vr_rd2_vlprovis,0);

      /*  Arredondamento dos valores calculados  */
      vr_rd2_vlsdrdca:= fn_round(vr_rd2_vlsdrdca,2);
      vr_rd2_vlprovis:= fn_round(vr_rd2_vlprovis,2);

      --Rendimento total recebe rendimento total mais provisao
      vr_rd2_vlrentot:= Nvl(vr_rd2_vlrentot,0) + Nvl(vr_rd2_vlprovis,0);
      --Data do lote recebe a data do movimento
      vr_rd2_dtdolote:= pr_dtmvtolt;
      --Atribuir numero para o lote
      vr_rd2_nrdolote:= 8380;
      --Diminuir o lancamento 180 do valor da provisao
      vr_rd2_vlprovis:= Nvl(vr_rd2_vlrentot,0) - Nvl(vr_rd2_vllan180,0);
      --Taxa da aplicacao recebe taxa multiplicado 100
      vr_rd2_txaplica:= vr_rd2_txaplica * 100;

      --Atualizar tabela Rendimentos
      BEGIN
        UPDATE craprda SET craprda.incalmes = 0
        WHERE craprda.ROWID = rw_craprda.ROWID;
      EXCEPTION
      WHEN OTHERS THEN
        --Determinar mensagem de erro
        vr_des_erro:= 'Erro ao atualizar tabela craprda. Rotina APLIC0001.pc_calc_provisao_mensal_rdca2. '||SQLERRM;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END;

      --Se o valor da provisao for diferente zero
      IF vr_rd2_vlprovis <> 0 THEN
        --Selecionar informacoes do lote
        OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => vr_rd2_dtdolote
                        ,pr_cdagenci => vr_rd2_cdagenci
                        ,pr_cdbccxlt => vr_rd2_cdbccxlt
                        ,pr_nrdolote => vr_rd2_nrdolote);
        --Posicionar no proximo registro
        FETCH cr_craplot INTO rw_craplot;
        --Se nao encontrar
        IF cr_craplot%NOTFOUND THEN
          --Inserir o lote
          BEGIN
            INSERT INTO craplot (craplot.cdcooper
                                ,craplot.dtmvtolt
                                ,craplot.cdagenci
                                ,craplot.cdbccxlt
                                ,craplot.nrdolote
                                ,craplot.tplotmov
                                ,craplot.vlinfocr
                                ,craplot.vlcompcr
                                ,craplot.vlinfodb
                                ,craplot.vlcompdb
                                ,craplot.nrseqdig)
            VALUES              (pr_cdcooper
                                ,vr_rd2_dtdolote
                                ,vr_rd2_cdagenci
                                ,vr_rd2_cdbccxlt
                                ,vr_rd2_nrdolote
                                ,10
                                ,0
                                ,0
                                ,0
                                ,0
                                ,0)
            RETURNING craplot.cdcooper
                     ,craplot.dtmvtolt
                     ,craplot.cdagenci
                     ,craplot.cdbccxlt
                     ,craplot.nrdolote
                     ,craplot.tplotmov
                     ,craplot.vlinfocr
                     ,craplot.vlcompcr
                     ,craplot.vlinfodb
                     ,craplot.vlcompdb
                     ,craplot.nrseqdig
                     ,craplot.rowid
            INTO     rw_craplot.cdcooper
                    ,rw_craplot.dtmvtolt
                    ,rw_craplot.cdagenci
                    ,rw_craplot.cdbccxlt
                    ,rw_craplot.nrdolote
                    ,rw_craplot.tplotmov
                    ,rw_craplot.vlinfocr
                    ,rw_craplot.vlcompcr
                    ,rw_craplot.vlinfodb
                    ,rw_craplot.vlcompdb
                    ,rw_craplot.nrseqdig
                    ,rw_craplot.rowid;
          EXCEPTION
          WHEN OTHERS THEN
            --Determinar mensagem de erro
            vr_des_erro:= 'Erro ao inserir na tabela craplot. Rotina APLIC0001.pc_calc_provisao_mensal_rdca2. '||SQLERRM;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END;
        END IF;
        --Fechar Cursor
        CLOSE cr_craplot;

        --Se o valor da provisao > 0
         IF vr_rd2_vlprovis > 0 THEN
           --Historico recebe 180
           rw_craplap.cdhistor:= 180;
           --Valor do lancamento recebe valor da provisao
           rw_craplap.vllanmto:= vr_rd2_vlprovis;
           --Incrementar Valor do credito com o valor do lancamento
           rw_craplot.vlinfocr:= Nvl(rw_craplot.vlinfocr,0) + Nvl(rw_craplap.vllanmto,0);
           --Incrementar valor compensado com o valor do lancamento
           rw_craplot.vlcompcr:= Nvl(rw_craplot.vlcompcr,0) + Nvl(rw_craplap.vllanmto,0);
         ELSE
           --Historico recebe 182
           rw_craplap.cdhistor:= 182;
           --Valor do lancamento recebe valor da provisao multiplicado por -1
           rw_craplap.vllanmto:= vr_rd2_vlprovis * -1;
           --Incrementar Valor do credito com o valor do lancamento
           rw_craplot.vlinfodb:= Nvl(rw_craplot.vlinfodb,0) + Nvl(rw_craplap.vllanmto,0);
           --Incrementar valor compensado com o valor do lancamento
           rw_craplot.vlcompdb:= Nvl(rw_craplot.vlcompdb,0) + Nvl(rw_craplap.vllanmto,0);
         END IF;

        --Atualizar tabela de lancamentos de aplicacoes rdca
        BEGIN
          INSERT INTO craplap (craplap.dtmvtolt
                              ,craplap.cdagenci
                              ,craplap.cdbccxlt
                              ,craplap.nrdolote
                              ,craplap.nrdconta
                              ,craplap.nraplica
                              ,craplap.txaplica
                              ,craplap.txaplmes
                              ,craplap.dtrefere
                              ,craplap.nrdocmto
                              ,craplap.nrseqdig
                              ,craplap.vlsdlsap
                              ,craplap.cdcooper
                              ,craplap.cdhistor
                              ,craplap.vllanmto)
          VALUES              (rw_craplot.dtmvtolt
                              ,rw_craplot.cdagenci
                              ,rw_craplot.cdbccxlt
                              ,rw_craplot.nrdolote
                              ,pr_nrdconta
                              ,pr_nraplica
                              ,NVL(vr_rd2_txaplica, 0)
                              ,NVL(vr_rd2_txaplica, 0)
                              ,vr_rd2_dtrefere
                              ,rw_craplot.nrseqdig + 1
                              ,rw_craplot.nrseqdig + 1
                              ,pr_vltotrda
                              ,pr_cdcooper
                              ,rw_craplap.cdhistor
                              ,rw_craplap.vllanmto);
        EXCEPTION
        WHEN OTHERS THEN
          --Determinar mensagem de erro
          vr_des_erro:= 'Erro ao inserir na tabela craplap. Rotina APLIC0001.pc_calc_provisao_mensal_rdca2. '||SQLERRM;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END;
        --Atualizar tabela de lotes
        BEGIN
          UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                            ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                            ,craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
                            ,craplot.vlinfocr = rw_craplot.vlinfocr
                            ,craplot.vlcompcr = rw_craplot.vlcompcr
                            ,craplot.vlinfodb = rw_craplot.vlinfodb
                            ,craplot.vlcompdb = rw_craplot.vlcompdb
          WHERE craplot.ROWID = rw_craplot.ROWID;
        EXCEPTION
        WHEN OTHERS THEN
          --Determinar mensagem de erro
          vr_des_erro:= 'Erro ao atualizar tabela craplot. Rotina APLIC0001.pc_calc_provisao_mensal_rdca2. '||SQLERRM;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END;
      END IF;
      --Atualizar variaveis de retorno
      pr_vlsdrdca:= vr_rd2_vlsdrdca;
      pr_txaplica:= vr_rd2_txaplica;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := nvl(pr_cdcritic,0);
        pr_des_erro := vr_des_erro;
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_cdcritic := nvl(pr_cdcritic,0);
        pr_des_erro := 'Erro não tratado na APLI0001.pc_calc_provisao_mensal_rdca2 --> '||sqlerrm;
    END;
  END pc_calc_provisao_mensal_rdca2;

  /* Rotina de calculo do saldo da poupanca programada */
  PROCEDURE pc_calc_saldo_rpp (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                              ,pr_cdprogra IN crapres.cdprogra%TYPE     --> Programa que esta executando
                              ,pr_inproces IN crapdat.inproces%TYPE     --> Indicador do Processo
                              ,pr_percenir IN NUMBER                    --> Percentual IR da craptab
                              ,pr_nrdconta IN craprpp.nrdconta%TYPE     --> Numero da conta da aplicacao
                              ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE     --> Numero do contrato poupanca
                              ,pr_dtiniper IN craprpp.dtiniper%TYPE     --> Data Inicio Periodo
                              ,pr_dtfimper IN craprpp.dtfimper%TYPE     --> Data Final Periodo
                              ,pr_vlabcpmf IN craprpp.vlabcpmf%TYPE     --> Valor abono cpmf
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                              ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE     --> Data do proximo movimento
                              ,pr_vlsdrdpp IN OUT craprpp.vlsdrdpp%TYPE --> Valor do saldo da poupanca programada
                              ,pr_des_erro OUT VARCHAR2) IS             --> Saida com erros;
  BEGIN

  /*..............................................................................

    Programa: pc_calc_saldo_rpp               Antigo: sistema/generico/includes/b1wgen0006.i
    Autor   : Junior
    Data    : 12/09/2005                      Ultima atualizacao: 19/07/2018 

    Dados referentes ao programa:

    Objetivo  : Include para calculo do saldo da poupanca programada
                Baseada no programa includes/poupanca.i.

    Alteracoes: 03/03/2010 - Adaptacao para rotina POUP.PROGRAMADA (David).

                18/01/2011 - Tratar historico 925 (Db.Trf.Aplic) (Irlan)
                18/12/2012 - Tratar historico 1115-Transferencia Viacredi/AltoVale (Rosangela).
                10/04/2013 - Conversão Progress >> Oracle (PLSQL) (Alisson-AMcom)
                19/07/2018 - Considerar poupança programada nos cálculos

  ..............................................................................*/
    DECLARE

      --Cursores Locais

      --Selecionar informacoes dos lancamentos da aplicacao poupanca
      CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_nrdconta IN craplpp.nrdconta%TYPE
                        ,pr_nrctrrpp IN craplpp.nrctrrpp%TYPE
                        ,pr_dtcalcul IN craplpp.dtmvtolt%TYPE
                        ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE
                        ,pr_dtrefere IN craplpp.dtmvtolt%TYPE) IS
        SELECT /* INDEX (craplpp craplpp##craplpp5) */ craplpp.cdhistor
              ,craplpp.vllanmto
        FROM craplpp craplpp
        WHERE craplpp.cdcooper = pr_cdcooper
        AND   craplpp.nrdconta = pr_nrdconta
        AND   craplpp.nrctrrpp = pr_nrctrrpp
        AND   craplpp.dtmvtolt >= pr_dtcalcul
        AND   craplpp.dtmvtolt <= pr_dtmvtolt
        AND   craplpp.dtrefere = pr_dtrefere
        AND   craplpp.cdhistor IN (150,152,154,155,158,496,925,1115)
        UNION ALL
        SELECT decode(lac.cdhistor,
                      cpc.cdhsraap,150,
                      cpc.cdhsnrap,152,
                      cpc.cdhsrvap,154,
                      2747,155,
                      cpc.cdhsrgap,158,
                      cpc.cdhsvtap,496
                      ) cdhistor
              ,lac.vllanmto
        FROM craplac lac, craprac rac,crapcpc cpc
        WHERE rac.cdcooper = pr_cdcooper
        AND   rac.nrdconta = pr_nrdconta
        AND   rac.nrctrrpp = pr_nrctrrpp
        AND   rac.cdcooper = lac.cdcooper
        AND   rac.nrdconta = lac.nrdconta
        AND   rac.nraplica = lac.nraplica
        AND   cpc.cdprodut = rac.cdprodut
        AND   lac.dtmvtolt between pr_dtcalcul and pr_dtmvtolt
        AND   lac.cdhistor IN (cpc.cdhsraap,cpc.cdhsnrap,cpc.cdhsrvap,2747,cpc.cdhsrgap,cpc.cdhsvtap);
      
      --Variaveis locais
      vr_vllan150 NUMBER;
      vr_vllan152 NUMBER;
      vr_vllan158 NUMBER;
      vr_vllan925 NUMBER;
      vr_vlsdrdpp NUMBER;
      vr_dtcalcul DATE;
      vr_dtrefere DATE;
      vr_dtmvtolt DATE;

      --Variaveis de retorno de erro
      vr_des_erro VARCHAR2(4000);
      
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      vr_exc_pula EXCEPTION;

    BEGIN

      --Inicializar controle de erro
      pr_des_erro:= NULL;

      --Inicializar variaveis
      vr_vllan150:= 0;
      vr_vllan152:= 0;
      vr_vllan158:= 0;
      vr_vllan925:= 0;
      vr_vlsdrdpp:= pr_vlsdrdpp;
      vr_dtcalcul:= pr_dtiniper;
      vr_dtrefere:= pr_dtfimper;

      --Se o processo for batch
      IF  pr_inproces > 2 AND pr_cdprogra IN ('CRPS147','CRPS148')  THEN /** BATCH **/
        --
        -- NAO IMPLEMENTADO POIS INICIALMENTE FOI DESENVOLVIDO PARA O PROGRAMA CRPS175.
        --
        NULL;
      ELSE
        --Se for o programa crps156
        IF pr_cdprogra = 'CRPS156'  THEN     /** RESGATE **/
          --Data do movimento recebe o proximo dia
          vr_dtmvtolt:= pr_dtmvtopr;
        ELSE
          --Data movimento recebe dia movimento atual + 1
          vr_dtmvtolt:= pr_dtmvtolt + 1;
        END IF;
      END IF;
      --Selecionar informacoes dos lancamentos de aplicacoes poupanca
      FOR rw_craplpp IN cr_craplpp (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctrrpp => pr_nrctrrpp
                                   ,pr_dtcalcul => vr_dtcalcul
                                   ,pr_dtmvtolt => vr_dtmvtolt
                                   ,pr_dtrefere => vr_dtrefere) LOOP
        --Verificar historicos
        CASE rw_craplpp.cdhistor
          WHEN 150 THEN /** Credito do plano **/
            --Acumula o lancamento no totalizador 150
            vr_vllan150:= Nvl(vr_vllan150,0) + Nvl(rw_craplpp.vllanmto,0);
          WHEN 152 THEN /** Provisao do mes **/
            --Acumula o lancamento no totalizador 152
            vr_vllan152:= Nvl(vr_vllan152,0) + Nvl(rw_craplpp.vllanmto,0);
          WHEN 154 THEN /** Ajuste provisao **/
            --Acumula o lancamento no totalizador 152
            vr_vllan152:= Nvl(vr_vllan152,0) + Nvl(rw_craplpp.vllanmto,0);
          WHEN 155 THEN /** Ajuste provisao **/
            --Acumula o lancamento no totalizador 152
            vr_vllan152:= Nvl(vr_vllan152,0) - Nvl(rw_craplpp.vllanmto,0);
          WHEN 158 THEN /** Resgate **/
            --Acumula o lancamento no totalizador 158
            vr_vllan158:= Nvl(vr_vllan158,0) + Nvl(rw_craplpp.vllanmto,0);
          WHEN 496 THEN /** Resgate **/
            --Acumula o lancamento no totalizador 158
            vr_vllan158:= Nvl(vr_vllan158,0) + Nvl(rw_craplpp.vllanmto,0);
          WHEN 925 THEN /* Db.Trf.Aplic. */
            --Acumula o lancamento no totalizador 925
            vr_vllan925:= Nvl(vr_vllan925,0) + Nvl(rw_craplpp.vllanmto,0);
          WHEN 1115 THEN /* Db.Trf.Aplic. */
            --Acumula o lancamento no totalizador 925
            vr_vllan925:= Nvl(vr_vllan925,0) + Nvl(rw_craplpp.vllanmto,0);
        END CASE;
      END LOOP;
      --Determinar o saldo da aplicacao poupanca
      vr_vlsdrdpp:= Nvl(vr_vlsdrdpp,0) + Nvl(vr_vllan150,0) - Nvl(vr_vllan158,0) - Nvl(vr_vllan925,0);
      --Se o saldo for negativo zerar
      IF vr_vlsdrdpp < 0 THEN
        vr_vlsdrdpp:= 0;
      END IF;

      --Se o processo for batch
      IF  pr_inproces > 2 AND pr_cdprogra IN ('CRPS147','CRPS148')  THEN /** BATCH **/
        --
        -- NAO IMPLEMENTADO POIS INICIALMENTE FOI DESENVOLVIDO PARA O PROGRAMA CRPS175.
        --
        NULL;
      END IF;

      --Se o processo for batch
      IF  pr_inproces > 2 AND
          pr_cdprogra IN ('CRPS147','CRPS148') AND
          vr_dtcalcul < vr_dtmvtolt AND
          vr_vlsdrdpp > 0 THEN
        --
        -- NAO IMPLEMENTADO POIS INICIALMENTE FOI DESENVOLVIDO PARA O PROGRAMA CRPS175.
        --
        NULL;
      END IF;

      /** Arredondamento dos valores calculados **/
      vr_vlsdrdpp:= APLI0001.fn_round(vr_vlsdrdpp,2);
      
      --Se for Online
      IF pr_inproces = 1  THEN   /** ON-LINE **/
        --Saldo recebe saldo menos valor abono * percentual IR
        vr_vlsdrdpp:= vr_vlsdrdpp - TRUNC((pr_vlabcpmf * pr_percenir / 100),2);
        --Se o valor for negativo entao zera
        IF vr_vlsdrdpp < 0 THEN
          vr_vlsdrdpp:= 0;
        END IF;
      END IF;

      --Se o processo for batch
      IF  pr_inproces > 2 AND pr_cdprogra IN ('CRPS147','CRPS148')  THEN /** BATCH **/
        --
        -- NAO IMPLEMENTADO POIS INICIALMENTE FOI DESENVOLVIDO PARA O PROGRAMA CRPS175.
        --
        NULL;
      END IF;

      --Retornar Valores para parametros OUT
      pr_vlsdrdpp:= vr_vlsdrdpp;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_erro:= vr_des_erro;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper, 
                                     pr_compleme => 'Conta: ' || pr_nrdconta ||
                                                    ' Poupanca: ' || pr_nrctrrpp);
        -- Retorno não OK
        pr_des_erro:= 'Erro na rotina APLI0001.pc_calc_saldo_rpp. '||sqlerrm;
    END;
  END pc_calc_saldo_rpp;

  /* Procedure para consultar saldo e demais dados de poupancas programadas */
  PROCEDURE pc_consulta_poupanca (pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cooperativa
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE            --> Codigo da Agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE            --> Numero do caixa
                                 ,pr_cdoperad IN craplrg.cdoperad%TYPE            --> Codigo do Operador
                                 ,pr_idorigem IN INTEGER                          --> Identificador da Origem
                                 ,pr_nrdconta IN craprda.nrdconta%TYPE            --> Nro da conta da aplicacao RDCA
                                 ,pr_idseqttl IN INTEGER                          --> Identificador Sequencial
                                 ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE            --> Contrato Poupanca Programada
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            --> Data do movimento atual
                                 ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE            --> Data do proximo movimento
                                 ,pr_inproces IN crapdat.inproces%TYPE            --> Indicador de processo
                                 ,pr_cdprogra IN crapprg.cdprogra%TYPE            --> Nome do programa chamador
                                 ,pr_flgerlog IN BOOLEAN                          --> Flag erro log
                                 ,pr_percenir IN NUMBER                           --> % IR para Calculo Poupanca
                                 ,pr_tab_craptab IN APLI0001.typ_tab_ctablq       --> Tipo de tabela de Conta Bloqueada
                                 ,pr_tab_craplpp IN APLI0001.typ_tab_craplpp      --> Tipo de tabela com lancamento poupanca
                                 ,pr_tab_craplrg IN APLI0001.typ_tab_craplpp      --> Tipo de tabela com resgates
                                 ,pr_tab_resgate IN APLI0001.typ_tab_resgate      --> Tabela com valores dos resgates das contas por aplicacao
                                 ,pr_vlsldrpp OUT NUMBER                          --> Valor saldo poupanca programada
                                 ,pr_retorno  OUT VARCHAR2                        --> Descricao de erro ou sucesso OK/NOK
                                 ,pr_tab_dados_rpp OUT APLI0001.typ_tab_dados_rpp --> Poupancas Programadas
                                 ,pr_tab_erro      IN OUT NOCOPY GENE0001.typ_tab_erro) IS  --> Saida com erros;
  BEGIN
  /* .............................................................................

   Programa: pc_consulta_poupanca               Antigo: sistema/generico/procedures/b1wgen0006.p/consulta-poupanca
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Alisson
   Data    : Abril/2013.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para consultar saldo e demais dados de poupancas programadas

   Alteracoes: 01/04/2013 - Conversão Progress >> Oracle (PLSQL) (Alisson-AMcom)

               16/07/2013 - Marcos-Supero:
                          a) Ajuste na chamada da pc_calc_saldo_rpp, pois estava
                             passando o numero da aplicacao do parametro desta
                             quando na verdade deve passar a encontrada no cursor.
                          b) Corrigido a logica de diminuicao do valor do
                             resgate, pois quando na? existia craplrg estava caindo
                             no Else e zerando o valor de resgate
                          c) Inicializado o valor do parametro pr_vlsdrdpp  na
                             chamada a pc_calc_saldo_rpp com o valor da tabela

              19/07/2013 - Incluido teste do tipo de resgate (craplrg), se for
                           craplrg.tpresgat = 2 então deve ignorar as aplicacoes
                           (Marcos - Supero)

              14/08/2013 - Remover prefixo da package ao chamar as rotinas desta (Marcos-Supero)

              26/07/2018 - Inclusão da Aplicação Programada - Proj 411.2 (CIS Corporate)

              20/09/2018 - Inclusao do campo dsfinali na pc_calc_poupanca - Proj. 411.2 (CIS Corporate)
              
  ............................................................................. */
    DECLARE

      --Selecionar informacoes das poupancas programadas
      CURSOR cr_craprpp (pr_cdcooper IN craprpp.cdcooper%TYPE
                        ,pr_nrdconta IN craprpp.nrdconta%TYPE
                        ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE) IS
        SELECT craprpp.nrctrrpp
              ,craprpp.nrdconta
              ,craprpp.cdagenci
              ,craprpp.cdbccxlt
              ,craprpp.nrdolote
              ,craprpp.dtmvtolt
              ,craprpp.dtvctopp
              ,craprpp.dtdebito
              ,craprpp.vlprerpp
              ,craprpp.qtprepag
              ,craprpp.vlprepag
              ,craprpp.vljuracu
              ,craprpp.vlrgtacu
              ,craprpp.dtinirpp
              ,craprpp.dtrnirpp
              ,craprpp.dtaltrpp
              ,craprpp.dtcancel
              ,craprpp.flgctain
              ,craprpp.dtiniper
              ,craprpp.dtfimper
              ,nvl(craprpp.vlabcpmf,0) vlabcpmf 
              ,craprpp.cdsitrpp
              ,craprpp.vlsdrdpp
              ,craprpp.cdprodut
              ,craprpp.dsfinali 
              ,craprpp.ROWID
              ,To_Char((CASE craprpp.cdsitrpp
                 WHEN 1 THEN 'Ativa'
                 WHEN 2 THEN 'Suspensa'
                 WHEN 3 THEN 'Cancelada'
                 WHEN 4 THEN 'Cancelada'
                 WHEN 5 THEN 'Vencida'
                 ELSE ''
                END ))  dssitrpp
        FROM craprpp craprpp
        WHERE craprpp.cdcooper = pr_cdcooper
        AND   craprpp.nrdconta = pr_nrdconta
        AND   (pr_nrctrrpp = 0  OR (pr_nrctrrpp > 0 AND craprpp.nrctrrpp = pr_nrctrrpp));
      rw_craprpp cr_craprpp%ROWTYPE;

      -- Seleciona informações sobre o produto para Apl. Programada
      CURSOR cr_crapcpc (pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
      SELECT cpc.nmprodut 
      FROM   crapcpc cpc
      WHERE  cpc.cdprodut = pr_cdprodut;
      rw_crapcpc cr_crapcpc%ROWTYPE;       

      --Selecionar informacoes dos saldos da poupanca no aniversario
      CURSOR cr_crapspp (pr_cdcooper IN crapspp.cdcooper%TYPE
                        ,pr_nrdconta IN crapspp.nrdconta%TYPE
                        ,pr_nrctrrpp IN crapspp.nrctrrpp%TYPE) IS
          SELECT MIN(crapspp.dtsldrpp) dtsldrpp
        FROM crapspp crapspp
        WHERE crapspp.cdcooper = pr_cdcooper
        AND   crapspp.nrdconta = pr_nrdconta
             AND crapspp.nrctrrpp = pr_nrctrrpp;
      rw_crapspp cr_crapspp%ROWTYPE;

      --Variaveis Locais
      vr_flgtrans BOOLEAN;
      vr_vlsdrdpp NUMBER(25,8);
      vr_vlrgtrpp NUMBER(25,8);
      vr_qtsaqppr INTEGER;
      vr_dsblqrpp VARCHAR2(3);
      vr_dsresgat VARCHAR2(3);
      vr_dsctainv VARCHAR2(3);
      vr_dsorigem VARCHAR2(40);
      vr_dstransa VARCHAR2(100);
      vr_dsmsgsaq VARCHAR2(4000);

      vr_vlsdappr NUMBER(25,8); -- Saldo total -  aplicacao programada
      vr_vlrgappr NUMBER(25,8);-- Saldo total para resgate - aplicacao programada

      vr_dsfinali VARCHAR2(20); -- Finalidade

      --Variaveis de retorno de erro
      vr_des_erro VARCHAR2(4000);
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);

      --Variaveis de Indice para tabela memoria
      vr_index_tab     NUMBER;
      vr_index_craptab VARCHAR2(20);
      vr_index_craplpp VARCHAR2(20);
      vr_index_craplrg VARCHAR2(20);
      vr_index_resgate VARCHAR2(25);


      -- Rowid para tabela de log
      vr_nrdrowid ROWID;

      --Variaveis de Excecao
      vr_exc_erro EXCEPTION; --ERRO
      vr_exc_pula EXCEPTION; --NEXT
      vr_exc_sair EXCEPTION; --LEAVE

    BEGIN

      --Inicializar controle de erro
      pr_retorno:= 'OK';
      --Limpar tabela de memoria
      pr_tab_erro.DELETE;
      pr_tab_dados_rpp.DELETE;

      --Se for para gerar log
      IF pr_flgerlog  THEN
        --Atribuir Descricao da Origem
        vr_dsorigem:= GENE0001.vr_vet_des_origens(pr_idorigem);
        --Atribuir Descricao da Transacao
        vr_dstransa:= 'Consulta de aplicações programadas';
      END IF;

      --Inicializar variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      vr_flgtrans:= TRUE;

      --Selecionar informacoes das poupancas programadas
      OPEN cr_craprpp (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctrrpp => pr_nrctrrpp);
      LOOP
        --Posicionar no proximo registro
        FETCH cr_craprpp INTO rw_craprpp;
        --Sair quando nao encontrar mais registros
        EXIT WHEN cr_craprpp%NOTFOUND;

        --Bloco necessario para controle fluxo
        BEGIN
          --Se for vencida e nome da tela for EXTPPR ou ADITIV ou IMPRES ignorar
          IF pr_cdprogra NOT IN ('EXTPPR','ADITIV','IMPRES') AND
             rw_craprpp.cdsitrpp = 5 /* Vencida */  THEN
            RAISE vr_exc_pula;
          END IF;

          -- Incializar o saldo com o valor da tabela
          vr_vlsdrdpp := rw_craprpp.vlsdrdpp;

          -- Verificar se é Poupança programada
          -- As aplicações programadas não serão tratadas linha a linha, mas evitaremos fazer 
          -- chamadas desnecessárias abaixo
          
          IF rw_craprpp.cdprodut < 1 THEN 
             vr_dsfinali := 'Poupança Programada';
          --Executar rotina para calcular saldo poupanca programada
          pc_calc_saldo_rpp (pr_cdcooper => pr_cdcooper
                            ,pr_cdprogra => pr_cdprogra
                            ,pr_inproces => pr_inproces
                            ,pr_percenir => pr_percenir
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                            ,pr_dtiniper => rw_craprpp.dtiniper
                            ,pr_dtfimper => rw_craprpp.dtfimper
                            ,pr_vlabcpmf => rw_craprpp.vlabcpmf
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_dtmvtopr => pr_dtmvtopr
                            ,pr_vlsdrdpp => vr_vlsdrdpp
                            ,pr_des_erro => vr_des_erro);

          Else -- Aplicacao Programada
              vr_dsfinali := trim(rw_craprpp.dsfinali); 
              If vr_dsfinali is null Then -- Nome do produto sera a finalidade
                 Open cr_crapcpc (pr_cdprodut => rw_craprpp.cdprodut);
                 Fetch cr_crapcpc Into rw_crapcpc;
                 If cr_crapcpc%NOTFOUND Then
                    vr_dsfinali := 'Aplicação Programada';
                 Else  
                    vr_dsfinali := rw_crapcpc.nmprodut;
                 End if;                 
                 Close cr_crapcpc;
              End if;
              vr_vlsdrdpp := 0;
              apli0008.pc_calc_saldo_apl_prog(pr_cdcooper => pr_cdcooper
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_idseqttl => pr_idseqttl
                                             ,pr_idorigem => pr_idorigem
                                             ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_vlsdrdpp => vr_vlsdrdpp
                                             ,pr_des_erro => vr_des_erro);

          End If; -- Aplicacao Programada

          --Se ocorreu erro
          IF vr_des_erro IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
                      
          --Ignorar se o saldo for negativo e a origem nao for AYLLOS/INTRANET
          IF vr_vlsdrdpp < 0 AND pr_idorigem NOT IN (1,5) THEN
            --Levantar excecao para pular registro
            RAISE vr_exc_pula;
          END IF;
          --Valor do Saldo da poupanca recebe atual + calculado
          pr_vlsldrpp:= Nvl(pr_vlsldrpp,0) + Nvl(vr_vlsdrdpp,0);
          --Valor resgatado recebe valor saldo
          vr_vlrgtrpp:= vr_vlsdrdpp;
          --Descricao resgate recebe N
          vr_dsresgat:= 'N';
          --Zerar quantidade sacada poupanca
          vr_qtsaqppr:= 0;
          --Mensagem de saque recebe null
          vr_dsmsgsaq:= NULL;

          /** Totalizar valores de resgate **/

          --Montar indice para selecionar total dos resgates na tabela auxiliar
          vr_index_resgate:= LPad(pr_nrdconta,10,'0')||
                             LPad(4,05,'0')||
                             LPad(rw_craprpp.nrctrrpp,10,'0');
          --Selecionar informacoes dos resgates
          IF pr_tab_resgate.EXISTS(vr_index_resgate) THEN
            -- Se for um resgate total
            IF pr_tab_resgate(vr_index_resgate).tpresgat = 2 THEN
              -- Considerar zero e encerrar
              vr_vlrgtrpp := 0;
              -- Pular
              RAISE vr_exc_pula;
            ELSE
              -- Diminuir valor resgate e continuar
              vr_vlrgtrpp:= Nvl(vr_vlrgtrpp,0) - Nvl(pr_tab_resgate(vr_index_resgate).vllanmto,0);
            END IF;
          END IF;

          --Montar indice para quantidade de lancamentos da poupanca
          vr_index_craplpp:= LPad(pr_nrdconta,10,'0')||LPad(rw_craprpp.nrctrrpp,10,'0');
          --Se ocorreram mais de 3 saques
          IF pr_tab_craplpp.EXISTS(vr_index_craplpp) THEN
            --Atribuir mensagem para a descricao
            vr_dsmsgsaq:= 'ATENCAO! Mais de 3 saques em 180 dias.';
          END IF;

          /** Verifica se poupanca esta bloqueada **/
          --Montar indice para selecionar tabela memoria
          vr_index_craptab:= LPad(rw_craprpp.nrdconta,12,'0')||LPad(rw_craprpp.nrctrrpp,8,'0');
          IF pr_tab_craptab.EXISTS(vr_index_craptab) THEN
            --Descricao recebe sim
            vr_dsblqrpp:= 'Sim';
          ELSE
            --Descricao recebe nao
            vr_dsblqrpp:= 'Nao';
          END IF;

          --Montar Indice para acesso quantidade lancamentos de resgate
          vr_index_craplrg:= LPad(rw_craprpp.nrdconta,10,'0')||LPad(rw_craprpp.nrctrrpp,10,'0');
          --Se existir 1 ou mais registros
          IF pr_tab_craplrg.EXISTS(vr_index_craplrg) AND pr_tab_craplrg(vr_index_craplrg) > 0 THEN
            vr_dsresgat:= 'Sim';
          ELSE
            vr_dsresgat:= 'Nao';
          END IF;
          --Selecionar saldo poupanca programada no aniversario
          OPEN cr_crapspp (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctrrpp => rw_craprpp.nrctrrpp);
          --Posicionar no proximo registro
          FETCH cr_crapspp INTO rw_crapspp;
          --Se nao encontrar
          IF cr_crapspp%NOTFOUND THEN
            rw_crapspp.dtsldrpp:= NULL;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapspp;

          --Se a conta estiver inativa
          IF rw_craprpp.flgctain = 1 THEN
            vr_dsctainv:= 'Sim';
          ELSE
            vr_dsctainv:= 'Nao';
          END IF;

          --Encontrar o proximo indice para a tabela
          vr_index_tab:= pr_tab_dados_rpp.Count+1;
          --Atualizar informacoes na tabela de memoria
          pr_tab_dados_rpp(vr_index_tab).nrctrrpp:= rw_craprpp.nrctrrpp;
          pr_tab_dados_rpp(vr_index_tab).cdagenci:= rw_craprpp.cdagenci;
          pr_tab_dados_rpp(vr_index_tab).cdbccxlt:= rw_craprpp.cdbccxlt;
          pr_tab_dados_rpp(vr_index_tab).nrdolote:= rw_craprpp.nrdolote;
          pr_tab_dados_rpp(vr_index_tab).dtmvtolt:= rw_craprpp.dtmvtolt;
          pr_tab_dados_rpp(vr_index_tab).dtvctopp:= rw_craprpp.dtvctopp;
          pr_tab_dados_rpp(vr_index_tab).dtdebito:= rw_craprpp.dtdebito;
          pr_tab_dados_rpp(vr_index_tab).indiadeb:= To_Number(To_Char(rw_craprpp.dtdebito,'DD'));
          pr_tab_dados_rpp(vr_index_tab).vlprerpp:= rw_craprpp.vlprerpp;
          pr_tab_dados_rpp(vr_index_tab).qtprepag:= rw_craprpp.qtprepag;
          pr_tab_dados_rpp(vr_index_tab).vlprepag:= rw_craprpp.vlprepag;
          pr_tab_dados_rpp(vr_index_tab).vlsdrdpp:= vr_vlsdrdpp;
          pr_tab_dados_rpp(vr_index_tab).vlrgtrpp:= vr_vlrgtrpp;
          pr_tab_dados_rpp(vr_index_tab).vljuracu:= rw_craprpp.vljuracu;
          pr_tab_dados_rpp(vr_index_tab).vlrgtacu:= rw_craprpp.vlrgtacu;
          pr_tab_dados_rpp(vr_index_tab).dtinirpp:= rw_craprpp.dtinirpp;
          pr_tab_dados_rpp(vr_index_tab).dtrnirpp:= rw_craprpp.dtrnirpp;
          pr_tab_dados_rpp(vr_index_tab).dtaltrpp:= rw_craprpp.dtaltrpp;
          pr_tab_dados_rpp(vr_index_tab).dtcancel:= rw_craprpp.dtcancel;
          pr_tab_dados_rpp(vr_index_tab).dssitrpp:= rw_craprpp.dssitrpp;
          pr_tab_dados_rpp(vr_index_tab).dsblqrpp:= vr_dsblqrpp;
          pr_tab_dados_rpp(vr_index_tab).dsresgat:= vr_dsresgat;
          pr_tab_dados_rpp(vr_index_tab).dsctainv:= vr_dsctainv;
          pr_tab_dados_rpp(vr_index_tab).dsmsgsaq:= vr_dsmsgsaq;
          pr_tab_dados_rpp(vr_index_tab).cdtiparq:= 0;
          pr_tab_dados_rpp(vr_index_tab).dtsldrpp:= rw_crapspp.dtsldrpp;
          pr_tab_dados_rpp(vr_index_tab).cdprodut:= rw_craprpp.cdprodut;          
          pr_tab_dados_rpp(vr_index_tab).nrdrowid:= rw_craprpp.ROWID;
          pr_tab_dados_rpp(vr_index_tab).dsfinali:= vr_dsfinali;
        EXCEPTION
          WHEN vr_exc_pula THEN
            --Atribuir TRUE para flag transacao
            vr_flgtrans:= TRUE;
          WHEN vr_exc_sair THEN
            --Atribuir FALSE para flag transacao pois ocorreu erro
            vr_flgtrans:= FALSE;
            --Sair do loop
            EXIT;
          WHEN vr_exc_erro THEN
            --Atribuir FALSE para flag transacao pois ocorreu erro
            vr_flgtrans:= FALSE;
            --Sair do loop
            EXIT;
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper, 
                                         pr_compleme => 'Conta: ' || pr_nrdconta ||
                                                        ' Poupanca: ' || rw_craprpp.nrctrrpp);

            vr_flgtrans := pr_idorigem = 7; -- pular consulta quando for batch            

            vr_dscritic := 'Erro ao consultar a poupanca: '||rw_craprpp.nrctrrpp || 
                           ' - APLI0001.pc_consulta_poupanca --> Consultar erro_sistema '||sqlerrm;
            EXIT;
        END;
      END LOOP;  --cr_craprpp
      --Fechar Cursor
      CLOSE cr_craprpp;

      --Se nao executou loop craprpp corretamente
      IF NOT vr_flgtrans THEN
        --Se nao ocorreu critica
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          --Atribuir descricao para a critica
          vr_dscritic:= 'Nao foi possivel consultar as poupancas programadas. Aplicacao: '||rw_craprpp.nrctrrpp;
        END IF;
        --Executar rotina geracao erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Se for para gerar log
        IF pr_flgerlog THEN
          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => SubStr(pr_cdoperad,1,10)
                              ,pr_dscritic => SubStr(vr_dscritic,1,159)
                              ,pr_dsorigem => SubStr(vr_dsorigem,1,13)
                              ,pr_dstransa => SubStr(vr_dstransa,1,121)
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => SubStr(pr_cdprogra,1,12)
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
        --Indicar que ocorreu erro
        pr_retorno:= 'NOK';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_cdprogra
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      --Indicar que nao ocorreu erro
      pr_retorno:= 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_retorno := 'NOK';
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper, 
                                     pr_compleme => 'Conta: ' || pr_nrdconta ||
                                                    ' Poupanca: ' || pr_nrctrrpp);
        -- Retorno não OK
        pr_retorno := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_consulta_poupanca --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 999
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_consulta_poupanca;

  /* Rotina de Acumulo das Aplicacoes */
  PROCEDURE pc_acumula_aplicacoes (pr_cdcooper        IN crapcop.cdcooper%TYPE           --> Cooperativa
                                  ,pr_cdoperad        IN crapope.cdoperad%TYPE DEFAULT 0 --> Operador
                                  ,pr_cdprogra        IN crapprg.cdprogra%TYPE           --> Nome do programa chamador
                                  ,pr_nrdconta        IN craprda.nrdconta%TYPE           --> Nro da conta da aplicacao RDCA
                                  ,pr_nraplica        IN craprda.nraplica%TYPE           --> Nro da Aplicacao
                                  ,pr_tpaplica        IN craprda.tpaplica%TYPE           --> Tipo de Aplicacao
                                  ,pr_vlaplica        IN craprda.vlaplica%TYPE           --> Valor da Aplicacao
                                  ,pr_cdperapl        IN crapttx.cdperapl%TYPE           --> Codigo Periodo Aplicacao
                                  ,pr_percenir        IN NUMBER                          --> % IR para Calculo Poupanca
                                  ,pr_qtdfaxir        IN INTEGER                         --> Quantidade de faixas de IR
                                  ,pr_tab_tpregist    IN APLI0001.typ_tab_tpregist       --> Tipo de Registro para loop craptab
                                  ,pr_tab_craptab     IN APLI0001.typ_tab_ctablq         --> Tipo de tabela de Conta Bloqueada
                                  ,pr_tab_craplpp     IN APLI0001.typ_tab_craplpp        --> Tipo de tabela com lancamento poupanca
                                  ,pr_tab_craplrg     IN APLI0001.typ_tab_craplpp        --> Tipo de tabela com resgates
                                  ,pr_tab_resgate     IN APLI0001.typ_tab_resgate        --> Tabela com o total resgatado por aplicacao e conta
                                  ,pr_tab_crapdat     IN BTCH0001.cr_crapdat%ROWTYPE     --> Dados da tabela de datas
                                  ,pr_cdagenci_assoc  IN crapass.cdagenci%TYPE           --> Agencia do associado
                                  ,pr_nrdconta_assoc  IN crapass.nrdconta%TYPE           --> Conta do associado
                                  ,pr_dtinitax        IN craprda.dtmvtolt%TYPE           --> Data Inicial da Utilizacao da taxa da poupanca
                                  ,pr_dtfimtax        IN craprda.dtmvtolt%TYPE            --> Data Final da Utilizacao da taxa da poupanca
                                  ,pr_vlsdrdca        OUT craprda.vlsdrdca%TYPE          --> Valor Saldo Aplicacao
                                  ,pr_txaplica        OUT craplap.txaplica%TYPE          --> Taxa Maxima de Aplicacao
                                  ,pr_txaplmes        OUT craplap.txaplmes%TYPE          --> Taxa Minima de Aplicacao
                                  ,pr_retorno         OUT VARCHAR2                       --> Descricao de erro ou sucesso
                                  ,pr_tab_acumula     IN OUT NOCOPY APLI0001.typ_tab_acumula_aplic --> Aplicacoes
                                  ,pr_tab_erro        IN OUT NOCOPY GENE0001.typ_tab_erro) IS      --> Saida com erros;
  BEGIN
  /* .............................................................................

   Programa: pc_acumula_aplicacoes               Antigo: b1wgen0004.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Alisson
   Data    : Abril/2013.                        Ultima atualizacao: 01/12/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para acumular aplicacoes

   Alteracoes: 01/04/2013 - Conversão Progress >> Oracle (PLSQL) (Alisson-AMcom)

               16/07/2013 - Incluido o order by no cursor cr_craprda para garantir
                            a mesma sequencia de leitura das aplicacoes do Progress
                            (Marcos - Supero)

               19/07/2013 - Incluido teste do tipo de resgate (craplrg), se for
                            craplrg.tpresgat = 2 então deve ignorar as aplicacoes
                            (Marcos - Supero)

               14/08/2013 - Remover prefixo da package ao chamar as rotinas desta (Marcos-Supero)

               17/07/2014 - Ajuste feito para os novos produtos de captação.(Jean Michel)

               01/12/2014 - Alterado a ordenação da tabela crapmfx. (Jean Michel)

               15/07/2018 - Não soma as aplicações programadas nesta rotina
                            Claudio - CIS Corporate

  ............................................................................. */
    DECLARE

      --Selecionar informacoes das aplicacoes
      CURSOR cr_craprda (pr_cdcooper IN craprda.cdcooper%TYPE
                        ,pr_tpaplica IN craprda.tpaplica%TYPE
                        ,pr_insaqtot IN craprda.insaqtot%TYPE
                        ,pr_cdageass IN craprda.cdageass%TYPE
                        ,pr_nrdconta IN craprda.nrdconta%TYPE
                        ,pr_nraplica IN craprda.nraplica%TYPE) IS
        SELECT craprda.nrdconta
              ,craprda.tpaplica
              ,craprda.nraplica
              ,craprda.dtatslmx
              ,craprda.dtmvtolt
        FROM craprda craprda
        WHERE craprda.cdcooper = pr_cdcooper
        AND   craprda.tpaplica = pr_tpaplica
        AND   craprda.insaqtot = pr_insaqtot
        AND   craprda.cdageass = pr_cdageass
        AND   craprda.nrdconta = pr_nrdconta
        AND   (pr_nraplica = 0 OR (pr_nraplica <> 0 AND pr_nraplica <> craprda.nraplica))
        ORDER BY craprda.nraplica;
      rw_craprda cr_craprda%ROWTYPE;

      --Selecionar informacoes das faixas de valores por tipo de aplicacao por periodo
      CURSOR cr_crapftx (pr_cdcooper IN crapftx.cdcooper%TYPE
                        ,pr_tptaxrdc IN crapftx.tptaxrdc%TYPE
                        ,pr_cdperapl IN crapftx.cdperapl%TYPE
                        ,pr_vlfaixas IN crapftx.vlfaixas%TYPE) IS
        SELECT crapftx.perapltx
              ,crapftx.perrdttx
              ,crapftx.vlfaixas
        FROM crapftx crapftx
        WHERE crapftx.cdcooper  = pr_cdcooper
        AND   crapftx.tptaxrdc  = pr_tptaxrdc
        AND   crapftx.cdperapl  = pr_cdperapl
        AND   crapftx.vlfaixas <= pr_vlfaixas
        ORDER BY crapftx.vlfaixas DESC;
      rw_crapftx cr_crapftx%ROWTYPE;

      --Selecionar informacoes dos cadastro de taxas do RDCA
      CURSOR cr_craptrd (pr_cdcooper IN craptrd.cdcooper%TYPE
                        ,pr_dtiniper IN craptrd.dtiniper%TYPE
                        ,pr_tptaxrda IN craptrd.tptaxrda%TYPE
                        ,pr_incarenc IN craptrd.incarenc%TYPE
                        ,pr_vlfaixas IN craptrd.vlfaixas%TYPE
                        ,pr_cdperapl IN craptrd.cdperapl%TYPE) IS
        SELECT craptrd.txofidia
        FROM craptrd craptrd
        WHERE craptrd.cdcooper = pr_cdcooper
        AND   craptrd.dtiniper = pr_dtiniper
        AND   craptrd.tptaxrda = pr_tptaxrda
        AND   craptrd.incarenc = pr_incarenc
        AND   craptrd.vlfaixas = pr_vlfaixas
        AND   craptrd.cdperapl = pr_cdperapl
        ORDER BY craptrd.progress_recid ASC;
      rw_craptrd cr_craptrd%ROWTYPE;

      --Selecionar "find first" informacoes de aplicacoes para captacao
      CURSOR cr_crapcpc(pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
        SELECT cpc.idtippro, cpc.cddindex, cpc.idtxfixa, cpc.idacumul
        FROM crapcpc cpc
        WHERE cpc.cdprodut = pr_cdprodut; -- Codigo do produto

      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Consulta sobre registros de aplicacoes de captacao
      CURSOR cr_craprac (pr_cdcooper IN craprac.cdcooper%TYPE
                        ,pr_nrdconta IN craprac.nrdconta%TYPE
                        ,pr_idsaqtot IN craprac.idsaqtot%TYPE
                        ,pr_nraplica IN craprac.nraplica%TYPE) IS
        SELECT rac.cdcooper, rac.nrdconta, rac.nraplica, rac.cdprodut,
               rac.dtmvtolt, rac.txaplica, rac.qtdiacar
        FROM craprac rac
        WHERE rac.cdcooper = pr_cdcooper
              AND rac.nrdconta = pr_nrdconta
              AND rac.idsaqtot = pr_idsaqtot
              AND rac.nrctrrpp = 0 -- Apenas Aplicações Não Programadas
              AND (pr_nraplica = 0 OR (pr_nraplica <> 0 AND pr_nraplica <> rac.nraplica));
      rw_craprac cr_craprac%ROWTYPE;

      -- Consulta resgate de aplicacoes
      CURSOR cr_craprga(pr_cdcooper IN craprga.cdcooper%TYPE
                       ,pr_nrdconta IN craprga.nrdconta%TYPE
                       ,pr_nraplica IN craprga.nraplica%TYPE
                       ,pr_dtresgat IN craprga.dtresgat%TYPE
                       ,pr_idresgat IN craprga.idresgat%TYPE) IS

      SELECT
        rga.idtiprgt
       ,rga.vlresgat
      FROM
        craprga rga
      WHERE
            rga.cdcooper = pr_cdcooper
        AND rga.nrdconta = pr_nrdconta
        AND rga.nraplica = pr_nraplica
        AND rga.dtresgat <= pr_dtresgat
        AND rga.idresgat = pr_idresgat;

      rw_craprga cr_craprga%ROWTYPE;

      --Variaveis Auxiliares para Calculo
      vr_vltotrgt craplrg.vllanmto%TYPE := 0;
      vr_vllctprv craprda.vlsdrdca%TYPE := 0;
      vr_vlsldrpp craprpp.vlsdrdpp%TYPE := 0;
      vr_dtiniper craprda.dtiniper%TYPE;

      --Variaveis de Retorno das procedures
      vr_vlsdrdca NUMBER:= 0;  --> Saldo da aplicacao
      vr_sldpresg NUMBER:= 0;  --> Saldo para resgate
      vr_vldperda NUMBER:= 0;  --> Valor calculado da perda
      vr_txaplica NUMBER:= 0;  --> Taxa aplicada sob o emprestimo
      vr_vlrentot NUMBER:= 0;  --> Valor Rendimento total
      vr_vlsldapl NUMBER:= 0;  --> Saldo da aplicacao RDCA

      vr_vlbascal NUMBER:= 0;  --> Valor de base de calculo
      vr_vlsldtot NUMBER:= 0;  --> Valor de saldo total
      vr_vlsldrgt NUMBER:= 0;  --> Valor de saldo de resgate
      vr_vlultren NUMBER:= 0;  --> Valor do ultimo rendimento
      vr_vlrevers NUMBER:= 0;  --> Valor de reversão
      vr_vlrdirrf NUMBER:= 0;  --> Valor de IRRF
      vr_percirrf NUMBER:= 0;  --> Percentual de IRRF

      vr_sldpresg_tmp craplap.vllanmto%TYPE := 0; --> Valor saldo de resgate
      vr_dup_vlsdrdca craplap.vllanmto%TYPE := 0; --> Acumulo do saldo da aplicacao RDCA

      -- Variaveis para a include de erros - valores fixos usados na internet
      vr_index_acumula INTEGER := 0;

      --Tabela de memoria para poupanca
      vr_tab_dados_rpp APLI0001.typ_tab_dados_rpp;

      --Variaveis de Indice para tabela memoria
      vr_index_resgate VARCHAR2(25);

      --Variaveis de retorno de erro
      vr_des_erro  VARCHAR2(4000);
      vr_dscritic  VARCHAR2(4000);
      vr_retorno   VARCHAR2(3);
      vr_cod_chave INTEGER;

      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      vr_exc_sair EXCEPTION;

      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      --Inicializar controle de erro
      pr_retorno:= 'OK';
      --Limpar tabela de memoria
      pr_tab_erro.DELETE;
      pr_tab_acumula.DELETE;
      vr_tab_dados_rpp.DELETE;

      --Valor saldo aplicacao recebe valor aplicacao
      pr_vlsdrdca:= pr_vlaplica;

      --percorrer tipos de registros da tabela generica
      vr_cod_chave:= pr_tab_tpregist.FIRST;
      WHILE vr_cod_chave IS NOT NULL LOOP
        IF pr_tab_tpregist(vr_cod_chave) = 0 THEN -- Novos Produtos

          -- Nova implementacao projeto de captacao
          FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_idsaqtot => 0
                                      ,pr_nraplica => pr_nraplica) LOOP

            -- Consulta referente a aplicacoes de captacao
            OPEN cr_crapcpc(pr_cdprodut => rw_craprac.cdprodut);

            FETCH cr_crapcpc INTO rw_crapcpc;

            -- Verifica se encontrou registros
            IF cr_crapcpc%NOTFOUND THEN
              vr_dscritic := 'Produto nao cadastrado.';
              RAISE vr_exc_erro;
            ELSE
              CLOSE cr_crapcpc;
                
              IF rw_crapcpc.idacumul <> 1 THEN
                CONTINUE;
              END IF;  

              vr_vltotrgt := 0;

              -- Se existir resgates para aplicação, subtrair o valor se for parcial e ignorar se for resgate total
              OPEN cr_craprga(pr_cdcooper => rw_craprac.cdcooper
                             ,pr_nrdconta => rw_craprac.nrdconta
                             ,pr_nraplica => rw_craprac.nraplica
                             ,pr_dtresgat => rw_crapdat.dtmvtopr
                             ,pr_idresgat => 0);

              LOOP

                FETCH cr_craprga INTO rw_craprga;

                EXIT WHEN cr_craprga%NOTFOUND;

                IF rw_craprga.idtiprgt = 2 THEN -- Resgate Total
                  EXIT;
                ELSE
                  vr_vltotrgt := NVL(vr_vltotrgt,0) + NVL(rw_craprga.vlresgat,0);
                END IF;

              END LOOP;
              
              CLOSE cr_craprga;

              IF rw_craprga.idtiprgt = 2 THEN
                CONTINUE;
              END IF;

            END IF;

            -- Alimenta valor de base de calculo
            vr_vlbascal := 0;

            IF rw_crapcpc.idtippro = 1 THEN -- Pré-Fixada
              APLI0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => pr_cdcooper
                                                     ,pr_nrdconta => pr_nrdconta
                                                     ,pr_nraplica => rw_craprac.nraplica
                                                     ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                     ,pr_txaplica => rw_craprac.txaplica
                                                     ,pr_idtxfixa => rw_crapcpc.idtxfixa
                                                     ,pr_cddindex => rw_crapcpc.cddindex
                                                     ,pr_qtdiacar => rw_craprac.qtdiacar
                                                     ,pr_idgravir => 0
                                                     ,pr_dtinical => rw_craprac.dtmvtolt
                                                     ,pr_dtfimcal => rw_crapdat.dtmvtolt
                                                     ,pr_idtipbas => 2
                                                     ,pr_vlbascal => vr_vlbascal
                                                     ,pr_vlsldtot => vr_vlsldtot
                                                     ,pr_vlsldrgt => vr_vlsldrgt
                                                     ,pr_vlultren => vr_vlultren
                                                     ,pr_vlrentot => vr_vlrentot
                                                     ,pr_vlrevers => vr_vlrevers
                                                     ,pr_vlrdirrf => vr_vlrdirrf
                                                     ,pr_percirrf => vr_percirrf
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);

              -- Verifica se houve erro
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;

            ELSE

              APLI0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => pr_cdcooper
                                                     ,pr_nrdconta => pr_nrdconta
                                                     ,pr_nraplica => rw_craprac.nraplica
                                                     ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                     ,pr_txaplica => rw_craprac.txaplica
                                                     ,pr_idtxfixa => rw_crapcpc.idtxfixa
                                                     ,pr_cddindex => rw_crapcpc.cddindex
                                                     ,pr_qtdiacar => rw_craprac.qtdiacar
                                                     ,pr_idgravir => 0
                                                     ,pr_dtinical => rw_craprac.dtmvtolt
                                                     ,pr_dtfimcal => rw_crapdat.dtmvtolt
                                                     ,pr_idtipbas => 2
                                                     ,pr_vlbascal => vr_vlbascal
                                                     ,pr_vlsldtot => vr_vlsldtot
                                                     ,pr_vlsldrgt => vr_vlsldrgt
                                                     ,pr_vlultren => vr_vlultren
                                                     ,pr_vlrentot => vr_vlrentot
                                                     ,pr_vlrevers => vr_vlrevers
                                                     ,pr_vlrdirrf => vr_vlrdirrf
                                                     ,pr_percirrf => vr_percirrf
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);

              -- Verifica se houve erro
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;

            END IF;

            pr_vlsdrdca := NVL(pr_vlsdrdca,0) + NVL(vr_vlsldtot,0) - NVL(vr_vltotrgt,0);

            --Buscar proximo indice para a tabela de memoria
            vr_index_acumula:= pr_tab_acumula.Count + 1;

            --Criar registro na tabela temporaria
            pr_tab_acumula(vr_index_acumula).nraplica:= rw_craprac.nraplica;
            pr_tab_acumula(vr_index_acumula).tpaplica:= 'PCAPTA';
            pr_tab_acumula(vr_index_acumula).vlsdrdca:= NVL(vr_vlsldtot,0) - NVL(vr_vltotrgt,0);

          END LOOP;          

          -- Fim Nova implementacao projeto de captacao

        ELSIF pr_tab_tpregist(vr_cod_chave) = 1 THEN -- Se for registro 1
          --Selecionar informacoes das aplicacoes
          FOR rw_craprda IN cr_craprda (pr_cdcooper => pr_cdcooper
                                       ,pr_tpaplica => 3
                                       ,pr_insaqtot => 0
                                       ,pr_cdageass => pr_cdagenci_assoc
                                       ,pr_nrdconta => pr_nrdconta_assoc
                                       ,pr_nraplica => 0) LOOP
            --Zerar valor total resgate
            vr_vltotrgt:= 0;
            --Montar indice para selecionar total dos resgates na tabela auxiliar
            vr_index_resgate:= LPad(rw_craprda.nrdconta,10,'0')||
                               LPad(rw_craprda.tpaplica,05,'0')||
                               LPad(rw_craprda.nraplica,10,'0');
            -- Selecionar informacoes dos resgates
            IF pr_tab_resgate.EXISTS(vr_index_resgate) THEN
              -- Se for um resgate total
              IF pr_tab_resgate(vr_index_resgate).tpresgat = 2 THEN
                -- Ignora
                CONTINUE;
              ELSE
                -- Acumular valores resgatados
                vr_vltotrgt:= Nvl(vr_vltotrgt,0) + Nvl(pr_tab_resgate(vr_index_resgate).vllanmto,0);
              END IF;
            END IF;

            --Executar rotina consulta saldo rdca30
            APLI0001.pc_consul_saldo_aplic_rdca30 (pr_cdcooper => pr_cdcooper           --> Cooperativa
                                                  ,pr_cdoperad => pr_cdoperad           --> Operador
                                                  ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt   --> Data do processo
                                                  ,pr_inproces => pr_tab_crapdat.inproces   --> Indicador do processo
                                                  ,pr_dtmvtopr => pr_tab_crapdat.dtmvtopr   --> Proximo dia util
                                                  ,pr_cdprogra => pr_cdprogra           --> Programa em execucao
                                                  ,pr_cdagenci => 1                     --> Codigo da agencia
                                                  ,pr_nrdcaixa => 999                   --> Numero do caixa
                                                  ,pr_nrdconta => rw_craprda.nrdconta   --> Nro da conta da aplicacao RDCA
                                                  ,pr_nraplica => rw_craprda.nraplica   --> Nro da aplicacao RDCA
                                                  ,pr_vlsdrdca => vr_vlsdrdca           --> Saldo da aplicacao
                                                  ,pr_sldpresg => vr_sldpresg_tmp       --> Valor saldo de resgate
                                                  ,pr_dup_vlsdrdca => vr_dup_vlsdrdca   --> Acumulo do saldo da aplicacao RDCA
                                                  ,pr_vlsldapl => vr_vlsldapl           --> Saldo da aplicacao RDCA
                                                  ,pr_vldperda => vr_vldperda           --> Valor calculado da perda
                                                  ,pr_txaplica => vr_txaplica           --> Taxa aplicada sob o emprestimo
                                                  ,pr_des_reto => vr_retorno            --> OK ou NOK
                                                  ,pr_tab_erro => pr_tab_erro);         --> Tabela com erros

            --Se retornou erro
            IF vr_retorno = 'NOK' THEN
              -- Tenta buscar o erro no vetor de erro
              IF pr_tab_erro.COUNT > 0 THEN
                vr_des_erro := pr_tab_erro(pr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
              ELSE
                vr_des_erro := 'Retorno "NOK" na APLI0001.pc_consul_saldo_aplic_rdca30 e sem informacao na pr_tab_erro, Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
              END IF;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            --Se o saldo for positivo
            IF vr_vlsdrdca > 0 THEN
              --Diminuir o valor resgatado do saldo
              vr_vlsdrdca:= Nvl(vr_vlsdrdca,0) - Nvl(vr_vltotrgt,0);
              --Atribuir valor do saldo para parametro saida
              pr_vlsdrdca:= Nvl(pr_vlsdrdca,0) + Nvl(vr_vlsdrdca,0);
              --Buscar proximo indice para a tabela de memoria
              vr_index_acumula:= pr_tab_acumula.Count+1;
              --Criar registro na tabela temporaria
              pr_tab_acumula(vr_index_acumula).nraplica:= rw_craprda.nraplica;
              pr_tab_acumula(vr_index_acumula).tpaplica:= 'RDCA';
              pr_tab_acumula(vr_index_acumula).vlsdrdca:= NVL(vr_vlsdrdca,0);
            END IF;
          END LOOP; --rw_craprda
        ELSIF pr_tab_tpregist(vr_cod_chave) = 2 THEN

          --Executar rotina consulta poupanca
          pc_consulta_poupanca(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => 1
                              ,pr_nrdcaixa => 999
                              ,pr_cdoperad => NULL
                              ,pr_idorigem => 1
                              ,pr_nrdconta => pr_nrdconta_assoc
                              ,pr_idseqttl => 1
                              ,pr_nrctrrpp => 0
                              ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt
                              ,pr_dtmvtopr => pr_tab_crapdat.dtmvtopr
                              ,pr_inproces => pr_tab_crapdat.inproces
                              ,pr_cdprogra => pr_cdprogra
                              ,pr_flgerlog => FALSE
                              ,pr_percenir => pr_percenir
                              ,pr_tab_craptab => pr_tab_craptab
                              ,pr_tab_craplpp => pr_tab_craplpp
                              ,pr_tab_craplrg => pr_tab_craplrg
                              ,pr_tab_resgate => pr_tab_resgate
                              ,pr_vlsldrpp => vr_vlsldrpp
                              ,pr_retorno  => vr_retorno
                              ,pr_tab_dados_rpp => vr_tab_dados_rpp
                              ,pr_tab_erro      => pr_tab_erro);
          --Se retornou erro
          IF vr_retorno = 'NOK' THEN
             -- Tenta buscar o erro no vetor de erro
            IF pr_tab_erro.COUNT > 0 THEN
              vr_des_erro := pr_tab_erro(pr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta_assoc;
            ELSE
              vr_des_erro := 'Retorno "NOK" na APLI0001.pc_consulta_poupanca e sem informacao na pr_tab_erro, Conta: '||pr_nrdconta_assoc;
            END IF;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          --Percorrer tabela memoria dados poupanca
          FOR idx IN 1..vr_tab_dados_rpp.Count LOOP
            --Se o valor do resgate for Maior zero
            IF vr_tab_dados_rpp(idx).vlrgtrpp > 0 THEN
              --Acumular valor saldo aplicacao no parametro saida
              pr_vlsdrdca:= Nvl(pr_vlsdrdca,0) + Nvl(vr_tab_dados_rpp(idx).vlrgtrpp,0);
              --Acumular valor resgate na tabela memoria
              --Buscar proximo indice para a tabela de memoria
              vr_index_acumula:= pr_tab_acumula.Count+1;
              --Criar registro na tabela temporaria
              pr_tab_acumula(vr_index_acumula).nraplica:= vr_tab_dados_rpp(idx).nrctrrpp;
              pr_tab_acumula(vr_index_acumula).tpaplica:= 'RPP';
              pr_tab_acumula(vr_index_acumula).vlsdrdca:= Nvl(vr_tab_dados_rpp(idx).vlrgtrpp,0);
            END IF;
          END LOOP;
        ELSIF pr_tab_tpregist(vr_cod_chave) = 3 THEN  /* RDCA60 */
          --Selecionar informacoes das aplicacoes
          FOR rw_craprda IN cr_craprda (pr_cdcooper => pr_cdcooper
                                       ,pr_tpaplica => 5
                                       ,pr_insaqtot => 0
                                       ,pr_cdageass => pr_cdagenci_assoc
                                       ,pr_nrdconta => pr_nrdconta_assoc
                                       ,pr_nraplica => pr_nraplica) LOOP
            --Se a aplicacao for igual ao parametro ignorar
            IF rw_craprda.nraplica = pr_nraplica THEN
              --Pular
              CONTINUE;
            END IF;
            --Zerar valor total resgate
            vr_vltotrgt:= 0;
            --Acumular valores resgatados
            --Montar indice para selecionar total dos resgates na tabela auxiliar
            vr_index_resgate:= LPad(rw_craprda.nrdconta,10,'0')||
                               LPad(rw_craprda.tpaplica,05,'0')||
                               LPad(rw_craprda.nraplica,10,'0');
            --Selecionar informacoes dos resgates
            IF pr_tab_resgate.EXISTS(vr_index_resgate) THEN
              -- Se for um resgate total
              IF pr_tab_resgate(vr_index_resgate).tpresgat = 2 THEN
                -- Ignora
                CONTINUE;
              ELSE
                -- Acumula
                vr_vltotrgt:= Nvl(vr_vltotrgt,0) + Nvl(pr_tab_resgate(vr_index_resgate).vllanmto,0);
              END IF;
            END IF;

            --Consultar o saldo da aplicacao rdca60
            APLI0001.pc_consul_saldo_aplic_rdca60 (pr_cdcooper => pr_cdcooper               --> Cooperativa
                                                  ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt   --> Data do processo
                                                  ,pr_dtmvtopr => pr_tab_crapdat.dtmvtopr   --> Data do proximo processo
                                                  ,pr_cdprogra => pr_cdprogra               --> Programa em execucao
                                                  ,pr_cdagenci => 1                         --> Codigo da agencia
                                                  ,pr_nrdcaixa => 999                       --> Numero do caixa
                                                  ,pr_nrdconta => rw_craprda.nrdconta       --> Nro da conta da aplicacao RDCA
                                                  ,pr_nraplica => rw_craprda.nraplica       --> Nro da aplicacao RDCA
                                                  ,pr_vlsdrdca => vr_vlsdrdca               --> Saldo da aplicacao
                                                  ,pr_sldpresg => vr_sldpresg               --> Saldo para resgate
                                                  ,pr_des_reto => vr_retorno                --> OK ou NOK
                                                  ,pr_tab_erro => pr_tab_erro);             --> Tabela com erros
            --Se retornou erro
            IF vr_retorno = 'NOK' THEN
              -- Tenta buscar o erro no vetor de erro
              IF pr_tab_erro.COUNT > 0 THEN
                vr_des_erro := pr_tab_erro(pr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta_assoc;
              ELSE
                vr_des_erro := 'Retorno "NOK" na APLI0001.pc_consulta_poupanca e sem informacao na pr_tab_erro, Conta: '||pr_nrdconta_assoc;
              END IF;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

            --Se o saldo da aplicacao for positivo
            IF vr_vlsdrdca > 0 THEN
              --Diminuir o valor resgatado
              vr_vlsdrdca:= Nvl(vr_vlsdrdca,0) - Nvl(vr_vltotrgt,0);
              --Atribuir valor do saldo para parametro saida
              pr_vlsdrdca:= Nvl(pr_vlsdrdca,0) + Nvl(vr_vlsdrdca,0);
              --Buscar proximo indice para a tabela de memoria
              vr_index_acumula:= pr_tab_acumula.Count + 1;
              --Criar registro na tabela temporaria
              pr_tab_acumula(vr_index_acumula).nraplica:= rw_craprda.nraplica;
              pr_tab_acumula(vr_index_acumula).tpaplica:= 'RDCA60';
              pr_tab_acumula(vr_index_acumula).vlsdrdca:= Nvl(vr_vlsdrdca,0);
            END IF;

          END LOOP; --rw_craprda
        ELSIF pr_tab_tpregist(vr_cod_chave) = 7 THEN  /* RDCPRE */
          --Selecionar informacoes das aplicacoes
          FOR rw_craprda IN cr_craprda (pr_cdcooper => pr_cdcooper
                                       ,pr_tpaplica => 7
                                       ,pr_insaqtot => 0
                                       ,pr_cdageass => pr_cdagenci_assoc
                                       ,pr_nrdconta => pr_nrdconta_assoc
                                       ,pr_nraplica => pr_nraplica) LOOP
            --Se a aplicacao for igual ao parametro ignorar
            IF rw_craprda.nraplica = pr_nraplica THEN
              --Pular
              CONTINUE;
            END IF;
            --Zerar valor total resgate
            vr_vltotrgt:= 0;
            --Acumular valores resgatados
            --Montar indice para selecionar total dos resgates na tabela auxiliar
            vr_index_resgate:= LPad(rw_craprda.nrdconta,10,'0')||
                               LPad(rw_craprda.tpaplica,05,'0')||
                               LPad(rw_craprda.nraplica,10,'0');
            --Selecionar informacoes dos resgates
            IF pr_tab_resgate.EXISTS(vr_index_resgate) THEN
              -- Se for um resgate total
              IF pr_tab_resgate(vr_index_resgate).tpresgat = 2 THEN
                -- Ignora
                CONTINUE;
              ELSE
                -- Acumular
                vr_vltotrgt:= Nvl(vr_vltotrgt,0) + Nvl(pr_tab_resgate(vr_index_resgate).vllanmto,0);
              END IF;
            END IF;

            --Determinar a data de inicio do periodo como 1? dia do mes do movimento
            vr_dtiniper:= Trunc(pr_tab_crapdat.dtmvtolt,'MM');

            --Se a data da inicio do periodo for inferior a data do movimento atual
            IF vr_dtiniper < rw_craprda.dtmvtolt THEN
              --Data inicio periodo recebe data movimento atual
              vr_dtiniper:= rw_craprda.dtmvtolt;
            END IF;

            --Consultar o saldo da aplicacao rdcpre
            APLI0001.pc_provisao_rdc_pre (pr_cdcooper => pr_cdcooper               --> Cooperativa
                                         ,pr_nrdconta => rw_craprda.nrdconta       --> Nro da conta da aplicacao RDCA
                                         ,pr_nraplica => rw_craprda.nraplica       --> Nro da aplicacao RDCA
                                         ,pr_dtiniper => vr_dtiniper               --> Data base inicial
                                         ,pr_dtfimper => pr_tab_crapdat.dtmvtolt   --> Data base final
                                         ,pr_vlsdrdca => vr_vlsdrdca               --> Valor do saldo RDCA
                                         ,pr_vlrentot => vr_vlrentot               --> Valor do rendimento total
                                         ,pr_vllctprv => vr_vllctprv               --> Valor dos ajustes RDC
                                         ,pr_des_reto => vr_retorno                --> OK ou NOK
                                         ,pr_tab_erro => pr_tab_erro);             --> Tabela com erros
            --Se retornou erro
            IF vr_retorno = 'NOK' THEN
              -- Tenta buscar o erro no vetor de erro
              IF pr_tab_erro.COUNT > 0 THEN
                vr_des_erro := pr_tab_erro(pr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
              ELSE
                vr_des_erro := 'Retorno "NOK" na APLI0001.pc_provisao_rdc_pre e sem informacao na pr_tab_erro, Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
              END IF;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

            --Diminuir o valor resgatado
            vr_vlsdrdca:= Nvl(vr_vlsdrdca,0) - Nvl(vr_vltotrgt,0);
            --Atribuir valor do saldo para parametro saida
            pr_vlsdrdca:= Nvl(pr_vlsdrdca,0) + Nvl(vr_vlsdrdca,0);
            --Buscar proximo indice para a tabela de memoria
            vr_index_acumula:= pr_tab_acumula.Count+1;
            --Criar registro na tabela temporaria
            pr_tab_acumula(vr_index_acumula).nraplica:= rw_craprda.nraplica;
            pr_tab_acumula(vr_index_acumula).tpaplica:= 'RDCPRE';
            pr_tab_acumula(vr_index_acumula).vlsdrdca:= Nvl(vr_vlsdrdca,0);

          END LOOP; --rw_craprda
        ELSIF pr_tab_tpregist(vr_cod_chave) = 8 THEN  /* RDCPOS */
          --Selecionar informacoes das aplicacoes
          FOR rw_craprda IN cr_craprda (pr_cdcooper => pr_cdcooper
                                       ,pr_tpaplica => 8
                                       ,pr_insaqtot => 0
                                       ,pr_cdageass => pr_cdagenci_assoc
                                       ,pr_nrdconta => pr_nrdconta_assoc
                                       ,pr_nraplica => pr_nraplica) LOOP
            --Se a aplicacao for igual ao parametro ignorar
            IF rw_craprda.nraplica = pr_nraplica THEN
              --Pular
              CONTINUE;
            END IF;
            --Zerar valor total resgate
            vr_vltotrgt:= 0;
            --Acumular valores resgatados
            --Montar indice para selecionar total dos resgates na tabela auxiliar
            vr_index_resgate:= LPad(rw_craprda.nrdconta,10,'0')||
                               LPad(rw_craprda.tpaplica,05,'0')||
                               LPad(rw_craprda.nraplica,10,'0');
            --Selecionar informacoes dos resgates
            IF pr_tab_resgate.EXISTS(vr_index_resgate) THEN
              -- Se for um resgate total
              IF pr_tab_resgate(vr_index_resgate).tpresgat = 2 THEN
                -- Ignora
                CONTINUE;
              ELSE
                -- Acumula
                vr_vltotrgt:= Nvl(vr_vltotrgt,0) + Nvl(pr_tab_resgate(vr_index_resgate).vllanmto,0);
              END IF;
            END IF;

            --Consultar o saldo da aplicacao rdcpos
            APLI0001.pc_provisao_rdc_pos (pr_cdcooper => pr_cdcooper              --> Cooperativa
                                         ,pr_cdagenci => 1                        --> Codigo da agencia
                                         ,pr_nrdcaixa => 999                      --> Numero do caixa
                                         ,pr_nrctaapl => rw_craprda.nrdconta      --> Nro da conta da aplicacao RDCA
                                         ,pr_nraplres => rw_craprda.nraplica      --> Nro da aplicacao RDCA
                                         ,pr_dtiniper => rw_craprda.dtatslmx      --> Data base inicial
                                         ,pr_dtfimper => pr_tab_crapdat.dtmvtolt  --> Data base final
                                         ,pr_dtinitax => pr_dtinitax              --> Data Inicial da Utilizacao da taxa da poupanca
                                         ,pr_dtfimtax => pr_dtfimtax              --> Data Final da Utilizacao da taxa da poupanca
                                         ,pr_flantven => FALSE                    --> Flag
                                         ,pr_vlsdrdca => vr_vlsdrdca              --> Valor do saldo RDCA
                                         ,pr_vlrentot => vr_vlrentot              --> Valor do rendimento total
                                         ,pr_des_reto => vr_retorno               --> OK ou NOK
                                         ,pr_tab_erro => pr_tab_erro);            --> Tabela com erros
            --Se retornou erro
            IF vr_retorno = 'NOK' THEN
              -- Tenta buscar o erro no vetor de erro
              IF pr_tab_erro.COUNT > 0 THEN
                vr_des_erro := pr_tab_erro(pr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
              ELSE
                vr_des_erro := 'Retorno "NOK" na APLI0001.pc_provisao_rdc_pos e sem informacao na pr_tab_erro, Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
              END IF;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

            --Diminuir o valor resgatado
            vr_vlsdrdca:= Nvl(vr_vlsdrdca,0) - Nvl(vr_vltotrgt,0);
            --Atribuir valor do saldo para parametro saida
            pr_vlsdrdca:= Nvl(pr_vlsdrdca,0) + Nvl(vr_vlsdrdca,0);
            --Buscar proximo indice para a tabela de memoria
            vr_index_acumula:= pr_tab_acumula.Count+1;
            --Criar registro na tabela temporaria
            pr_tab_acumula(vr_index_acumula).nraplica:= rw_craprda.nraplica;
            pr_tab_acumula(vr_index_acumula).tpaplica:= 'RDCPOS';
            pr_tab_acumula(vr_index_acumula).vlsdrdca:= Nvl(vr_vlsdrdca,0);
          END LOOP; --rw_craprda
        END IF;
        --Encontrar o proximo registro
        vr_cod_chave:= pr_tab_tpregist.NEXT(vr_cod_chave);
      END LOOP; --rw_craptab

      /*** Se nao for aplicacao RDCPRE ou RDCPOS ***/
      IF pr_tpaplica < 7 THEN
        --Levantar Excecao
        RAISE vr_exc_sair;
      END IF;
      --Se o saldo do parametro for negativo
      IF pr_vlsdrdca < 0 THEN
        --Saldo passado como parametro recebe valor aplicado
        pr_vlsdrdca:= pr_vlaplica;
      END IF;

      /*** Procurando a faixa em que aplicacao se encaixa ***/
      OPEN cr_crapftx (pr_cdcooper => pr_cdcooper
                      ,pr_tptaxrdc => pr_tpaplica
                      ,pr_cdperapl => pr_cdperapl
                      ,pr_vlfaixas => pr_vlsdrdca);
      --Posicionar no proximo registro
      FETCH cr_crapftx INTO rw_crapftx;
      --Se nao encontrar
      IF cr_crapftx%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapftx;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 999
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 891 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapftx;

      --Se o tipo de aplicacao for rdcpos
      IF pr_tpaplica = 8 THEN /* RDCPOS */
        --Retornar a taxa de aplicacao
        pr_txaplica:= rw_crapftx.perapltx;
        pr_txaplmes:= rw_crapftx.perrdttx;
        --Levantar Excecao
        RAISE vr_exc_sair;
      END IF;

      /*** Magui, quando rdcpre pegar a taxa do dia anterior porque o cdi so
         e cadastrado no final do dia ***/
      OPEN cr_craptrd (pr_cdcooper => pr_cdcooper
                      ,pr_dtiniper => pr_tab_crapdat.dtmvtoan
                      ,pr_tptaxrda => pr_tpaplica
                      ,pr_incarenc => 0
                      ,pr_vlfaixas => rw_crapftx.vlfaixas
                      ,pr_cdperapl => pr_cdperapl);
      --Posicionar no proximo registro
      FETCH cr_craptrd INTO rw_craptrd;
      --Se nao encontrar
      IF cr_craptrd%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_craptrd;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 999
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 347 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_craptrd;
      --Retornar a taxa de aplicacao
      pr_txaplica:= rw_craptrd.txofidia;
      pr_txaplmes:= rw_crapftx.perapltx;
      --Limpar tabela de dados
      vr_tab_dados_rpp.DELETE;
      --Levantar Excecao
      RAISE vr_exc_sair;
    EXCEPTION
      WHEN vr_exc_sair THEN
        -- Retorno OK
        pr_retorno:= 'OK';

      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_retorno := 'NOK';
        
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 999
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_retorno := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_acumula_aplicacoes --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 999
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_acumula_aplicacoes;

  /* Rotina de calculo do RDCA */
  procedure pc_calc_aplicacao (pr_cdcooper in crapcop.cdcooper%type,      --> Cooperativa
                               pr_dtmvtolt in crapdat.dtmvtolt%type,      --> Data do movimento
                               pr_dtmvtopr in crapdat.dtmvtopr%type,      --> Primeiro dia útil após a data do movimento
                               pr_rda_rowid in varchar2,                  --> Identificador do registro da tabela CRAPRDA em processamento
                               pr_cdprogra in crapprg.cdprogra%type,      --> Programa chamador
                               pr_inproces in crapdat.inproces%type,      --> Indicador do processo
                               pr_insaqtot out craprda.insaqtot%type,     --> Indicador de saque total
                               pr_vlsdrdca out craprda.vlsdrdca%type,     --> Saldo da aplicação RDCA
                               pr_sldpresg out craprda.vlsdrdca%type,     --> Saldo para resgate
                               pr_dup_vlsdrdca out craprda.vlsdrdca%type, --> Saldo da aplicação RDCA para rotina duplicada
                               pr_cdcritic out crapcri.cdcritic%type,     --> Codigo da critica de erro
                               pr_dscritic out varchar2) is               --> Descricão do erro encontrado
  /* .............................................................................

     Programa: APLI0001.pc_calc_aplicacao - Antigo Includes/aplicacao.i
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Deborah/Edson
     Data    : Novembro/94.                    Ultima atualizacao: 25/11/2016

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Rotina de calculo do RDCA -- Deve ser chamada de dentro de um
                 FOR EACH ou DO WHILE e com label TRANS_1.

     Alteracoes:  06/02/95 - Se o ultimo dia do mes anterior for dia util e o
                             primeiro dia do mes atual tambem, seleciona os lan-
                             camentos do primeiro dia do mes (Edson).

                  27/03/95 - Dar tratamento ao programa crps117.

                  09/05/95 - Alimentar o campo craprda.dtsaqtot quando a aplica-
                             cao foi totalmente resgatada com a data do movimento
                             (Edson).

                  25/09/95 - Alterado para tratar vlsdrdan no craprda e txaplmes
                             no craplap. (Deborah)

                  16/10/95 - Alterado para tratar historicos e porgramas da rotina
                             de unificacao (crps135, hist.143)

                  24/10/95 - Alterado para tratar craprda.dtsdrdan (Deborah).

                  30/11/95 - Alterado para calcular com 8 casas decimais e arredon-
                             dar os resultados finais para 2 casas decimais (Edson)

                  07/12/95 - Alterado para tratar o programa 133 (Deborah).

                  18/12/95 - Alterado para tratar o programa 011 (Edson).

                  22/02/96 - Alterado para tratar extrato trimestral (Edson).

                  16/09/96 - Substituido os programas 133 e 143 pelos programas
                             168 e 169 (Edson).

                  28/11/96 - Alterar para tratar 105 e 148 complementar indices
                            (Odair)

                  14/10/97 - Alterado para tratar o programa crps210 (Edson).

                  12/11/98 - Tratar atendimento noturno (Deborah).

                25/03/2002 - Tratar o programa crps323.p (Deborah)
                             Acerto no tratamento do programa crps210.p (Ze)

                19/08/2003 - Tratar o programa crps349.p (Deborah)

                24/10/2003 - Incalcul = 2 somente se aniversario (Margarete).

                09/12/2003 - Incluir cobranca de IRRF (Margarete).

                07/01/2004 - Quando resgate on_line nao pagar rendimento
                             no dia do resgate (Margarete).

                26/01/2004 - Gerar lancamento de abono e IR sobre o abono
                             no aniversario da aplicacao (Margarete).

                02/07/2004 - Zerar saldos de final do mes quando saque
                             total (Margarete).

                23/09/2004 - Incluido historico 492(CI)(Mirtes)

                10/12/2004 - Ajustes para tratar das novas aliquotas de
                             IRRF (Margarete).

                21/01/2005 - IRRF sobre abono CPMF usara maior taxa (Margarete).

                25/01/2005 - Incluido tratamento programa crps431(Mirtes)

                01/03/2005 - Incluido tratamento programa crps414 (Junior).

                08/03/2005 - Permitir acessar tela ATENDA(glb_inproces>=3)(Mirtes)

                06/05/2005 - Utilizar o indice craplap5 na leitura dos
                             lancamentos (Edson).

                05/07/2005 - Alimentado campo cdcooper das tabelas craplot e
                             craplap (Diego).

                28/07/2005 - Saldo para resgate errado quando dentro da
                             carencia (Margarete).

                24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

                24/02/2006 - Incluido programa crps445 - Mirtes

                23/03/2006 - Algumas aplicacoes com resgate total estavam
                             ficando com saldo (Magui).

                19/06/2006 - Alterado o indice na leitura do craplap (trocado o
                             craplap2 pelo craplap5 e tirado o can-do na selecao
                             do historico (Edson).

                03/08/2006 - Campo vlslfmes substituido por vlsdextr (Magui).

                23/08/2006 - Nao atualizar mais craprda.dtsdfmes (Magui).

                14/06/2007 - Alteracao para melhoria de performance (Evandro).

                30/01/2009 - Incluir programas crps175 e 176 na lista para
                             calculo do saldo (David).

                22/04/2010 - Incluido programa crps563 para calculo do saldo
                             (Elton).

                18/06/2012 - Incluir tratamento para resgate de RDCA menor que
                             R$ 1,00 (Ze).

                05/09/2013 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero)
                
                25/11/2016 - Incluir CRPS005 nas excessoes da procedure - Melhoria 69 
                             (Lucas Ranghetti/Elton)
  ............................................................................. */
    -- Aplicação RDCA
    cursor cr_craprda is
      select c.nrdconta,
             c.nraplica,
             c.dtiniper,
             c.dtfimper,
             c.vlsdrdca,
             c.inaniver,
             c.dtmvtolt,
             c.vlabcpmf,
             c.incalmes,
             c.qtmesext,
             c.dtiniext,
             c.dtfimext,
             c.dtsdrdan,
             c.vlsdrdan,
             c.tpaplica,
             c.insaqtot,
             c.dtsaqtot,
             c.dtcalcul,
             c.vlsdextr,
             c.vlabonrd
        from craprda c
       where c.rowid = pr_rda_rowid;
    rw_craprda     cr_craprda%rowtype;
    -- Taxas de RDCA
    cursor cr_craptrd (pr_cdcooper in craptrd.cdcooper%type,
                       pr_data in craptrd.dtiniper%type) is
      select trd.dtiniper,
             trd.dtfimper,
             trd.txofidia,
             trd.txprodia,
             trd.txofimes,
             trd.incalcul,
             trd.rowid
        from craptrd trd
       where trd.cdcooper = pr_cdcooper
         and trd.dtiniper = pr_data
         and trd.tptaxrda = 1
         and trd.incarenc = 0
         and trd.vlfaixas = 0;
    rw_craptrd_ini     cr_craptrd%rowtype;
    rw_craptrd_fim     cr_craptrd%rowtype;
    -- Lançamentos de aplicações RDCA
    cursor cr_craplap (pr_cdcooper in craplap.cdcooper%type,
                       pr_nrdconta in craplap.nrdconta%type,
                       pr_nraplica in craplap.nraplica%type,
                       pr_dtrefere in craplap.dtrefere%type,
                       pr_dtcalcul in craplap.dtmvtolt%type,
                       pr_dtmvtolt in craplap.dtmvtolt%type) is
      select craplap.cdhistor,
             craplap.vllanmto,
             craplap.dtmvtolt
        from craplap
       where craplap.cdcooper = pr_cdcooper
         and craplap.nrdconta = pr_nrdconta
         and craplap.nraplica = pr_nraplica
         and craplap.dtrefere = pr_dtrefere
         and craplap.cdhistor in (117, 118, 124, 125, 143, 492, 875)
         -- PROVISAO, RESGATE, AJUSTE PROV., AJUSTE PROV., RESG.P/UNIF., RESGATE, AJT RGT IR-30
         and craplap.dtmvtolt >= pr_dtcalcul
         and craplap.dtmvtolt <= pr_dtmvtolt
       order by craplap.dtmvtolt;
    -- Lançamentos de aplicações RDCA para ajustes de IR
    cursor cr_craplap2 (pr_cdcooper in craplap.cdcooper%type,
                        pr_nrdconta in craplap.nrdconta%type,
                        pr_nraplica in craplap.nraplica%type,
                        pr_dtrefere in craplap.dtrefere%type,
                        pr_dtiniper in craplap.dtmvtolt%type,
                        pr_dtmvtolt in craplap.dtmvtolt%type) is
      select craplap.cdhistor,
             craplap.vllanmto,
             craplap.dtmvtolt,
             craplap.rendatdt,
             craplap.vlslajir,
             craplap.aliaplaj,
             craplap.vlrenreg,
             craplap.pcajsren,
             craplap.vlrenacu,
             craplap.qtdmesaj,
             craplap.qtddiaaj,
             count(1) over (partition by craplap.dtmvtolt) totreg,
             row_number() over (partition by craplap.dtmvtolt order by craplap.dtmvtolt) nrseq
        from craplap
       where craplap.cdcooper = pr_cdcooper
         and craplap.nrdconta = pr_nrdconta
         and craplap.nraplica = pr_nraplica
         and craplap.dtrefere = pr_dtrefere
         and craplap.cdhistor in (118, 492)
         -- RESGATE
         and craplap.dtmvtolt >= pr_dtiniper
         and craplap.dtmvtolt <= pr_dtmvtolt
       order by craplap.dtmvtolt;
    -- Lançamentos de aplicações RDCA para ajustes de IR
    cursor cr_craplap3 (pr_cdcooper in craplap.cdcooper%type,
                        pr_nrdconta in craplap.nrdconta%type,
                        pr_nraplica in craplap.nraplica%type) is
      select craplap.dtmvtolt
        from craplap
       where craplap.cdcooper = pr_cdcooper
         and craplap.nrdconta = pr_nrdconta
         and craplap.nraplica = pr_nraplica
       order by craplap.progress_recid desc;
    rw_craplap3     cr_craplap3%rowtype;

    -- Capa do lote
    cursor cr_craplot (pr_dtdolote in craplot.dtmvtolt%type,
                       pr_cdagenci in craplot.cdagenci%type,
                       pr_cdbccxlt in craplot.cdbccxlt%type,
                       pr_nrdolote in craplot.nrdolote%type,
                       pr_cdcooper in craplot.cdcooper%type) is
      select craplot.dtmvtolt,
             craplot.cdagenci,
             craplot.cdbccxlt,
             craplot.nrdolote,
             craplot.nrseqdig,
             craplot.vlinfocr,
             craplot.vlcompcr,
             craplot.vlinfodb,
             craplot.vlcompdb,
             craplot.qtinfoln,
             craplot.qtcompln,
             craplot.rowid
        from craplot
       where craplot.dtmvtolt = pr_dtdolote
         and craplot.cdagenci = pr_cdagenci
         and craplot.cdbccxlt = pr_cdbccxlt
         and craplot.nrdolote = pr_nrdolote
         and craplot.cdcooper = pr_cdcooper;
    rw_craplot     cr_craplot%rowtype;
    -- Registro auxiliar para preparar dados de lançamento para inclusão
    tab_craplap     craplap%rowtype;

    --
    -- Indicador de cálculo, utilizado para atualizar a craptrd
    vr_incalcul    craptrd.incalcul%type;
    -- Datas utilizada para realizar o cálculo
    vr_dtmvtolt    crapdat.dtmvtolt%type;
    vr_dtcalcul    craprda.dtiniper%type;
    vr_dtcalajt    craprda.dtiniper%type;
    vr_dtrefere    craprda.dtfimper%type;
    vr_dtultdia    crapdat.dtultdia%type;
    -- Taxas para o cálculo
    vr_txaplica    number(25,8);
    vr_txaplmes    craptrd.txofimes%type;
    -- Variáveis utilizadas para execução do cálculo
    vr_vllan117    number(25,10);
    vr_vlsdrdca    number(25,8);
    vr_ttajtlct    number(25,8);
    vr_vlrendim    number(25,8);
    vr_vlrentot    number(25,8);
    vr_vlprovis    number(25,8);
    vr_vldperda    number(25,8);
    vr_vlrgtper    number(25,8);
    vr_renrgper    number(25,8);
    vr_ttpercrg    number(25,8);
    vr_vlrenrgt    number(25,8);
    vr_trergtaj    number(25,8);
    vr_ttrenrgt    number(25,8);
    vr_ajtirrgt    number(25,8);
    vr_flgncalc    boolean;
    vr_sldcaren    number(25,8);
    vr_sldpresg    number(25,8);
    vr_vlsldapl    number(25,8);
    vr_vlrenper    number(25,8);
    vr_dtregapl    crapdat.dtmvtolt%type;
    vr_vlabcpmf    number(25,8);
    vr_dtdolote    crapdat.dtmvtolt%type;
    vr_nrdolote    craplot.nrdolote%type;
    vr_cdhistor    craphis.cdhistor%type;
    vr_flglanca    boolean := false;
    vr_vlajtsld    number(25,8);
    vr_vlslajir    number(25,8);
    vr_vlrenacu    number(25,8);
    vr_vlsdrdat    number(25,8);
    vr_vlajuste    number(25,8);
    vr_vlrenreg    number(25,8);

    -- Variáveis utilizadas pela rotina duplicada
    dup_dtcalcul   craprda.dtiniper%type;
    dup_dtmvtolt   crapdat.dtmvtolt%type;
    dup_vlsdrdca   number(25,8);
    dup_vlrentot   number(25,8);

    -- Agência e caixa constantes para utilização na capa do lote
    vr_cdagenci    craplot.cdagenci%type := 1;
    vr_cdbccxlt    craplot.cdbccxlt%type := 100;

    -- Variáveis utilizadas pela pc_saldo_rdca
    vr_vldajtir    number(25,8);
    vr_sldrgttt    number(25,8);
    vr_nrdmeses    number(3);
    vr_nrdedias    number(5);
    vr_dtiniapl    crapdat.dtmvtolt%type;
    vr_cdhisren    craphis.cdhistor%type;
    vr_cdhisajt    craphis.cdhistor%type;
    vr_perirapl    number(25,8);

    --
    -- Procedimento para criar registro na craplot (caso não exista) e retornar as informações na variável rw_craplot
    procedure cria_craplot (pr_dtdolote in craplot.dtmvtolt%type,
                            pr_cdagenci in craplot.cdagenci%type,
                            pr_cdbccxlt in craplot.cdbccxlt%type,
                            pr_nrdolote in craplot.nrdolote%type,
                            pr_cdcooper in craplot.cdcooper%type) is
    begin
      open cr_craplot (pr_dtdolote,
                       pr_cdagenci,
                       pr_cdbccxlt,
                       pr_nrdolote,
                       pr_cdcooper);
        fetch cr_craplot into rw_craplot;
        if cr_craplot%notfound then
          begin
            insert into craplot (dtmvtolt,
                                 cdagenci,
                                 cdbccxlt,
                                 nrdolote,
                                 tplotmov,
                                 cdcooper)
            values (pr_dtdolote,
                    pr_cdagenci,
                    pr_cdbccxlt,
                    pr_nrdolote,
                    10,
                    pr_cdcooper)
            returning dtmvtolt,
                      cdagenci,
                      cdbccxlt,
                      nrdolote,
                      nrseqdig,
                      vlinfocr,
                      vlcompcr,
                      vlinfodb,
                      vlcompdb,
                      qtinfoln,
                      qtcompln,
                      rowid
                 into rw_craplot.dtmvtolt,
                      rw_craplot.cdagenci,
                      rw_craplot.cdbccxlt,
                      rw_craplot.nrdolote,
                      rw_craplot.nrseqdig,
                      rw_craplot.vlinfocr,
                      rw_craplot.vlcompcr,
                      rw_craplot.vlinfodb,
                      rw_craplot.vlcompdb,
                      rw_craplot.qtinfoln,
                      rw_craplot.qtcompln,
                      rw_craplot.rowid;
          exception
            when dup_val_on_index then
              null;
            when others then
              pr_cdcritic := 0;
              pr_dscritic := 'Erro ao criar capa do lote: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
      close cr_craplot;
    end;
    -- Procedimento para criar registro de lançamento de aplicação
    procedure cria_craplap is
    begin
      insert into craplap (dtmvtolt,
                           cdagenci,
                           cdbccxlt,
                           nrdolote,
                           nrdconta,
                           nraplica,
                           nrdocmto,
                           txaplica,
                           txaplmes,
                           cdhistor,
                           nrseqdig,
                           vllanmto,
                           dtrefere,
                           vlrenacu,
                           vlslajir,
                           cdcooper)
      values (tab_craplap.dtmvtolt,
              tab_craplap.cdagenci,
              tab_craplap.cdbccxlt,
              tab_craplap.nrdolote,
              tab_craplap.nrdconta,
              tab_craplap.nraplica,
              tab_craplap.nrdocmto,
              NVL(tab_craplap.txaplica, 0),
              NVL(tab_craplap.txaplmes, 0),
              tab_craplap.cdhistor,
              tab_craplap.nrseqdig,
              tab_craplap.vllanmto,
              tab_craplap.dtrefere,
              nvl(tab_craplap.vlrenacu, 0),
              nvl(tab_craplap.vlslajir, 0),
              tab_craplap.cdcooper);
    exception
      when others then
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao incluir lançamento de aplicação RDCA: '||sqlerrm;
        raise vr_exc_erro;
    end;
    -- Procedimento para alterar registro na capa do lote
    procedure altera_craplot is
    begin
      update craplot
         set craplot.vlinfocr = rw_craplot.vlinfocr,
             craplot.vlcompcr = rw_craplot.vlcompcr,
             craplot.vlinfodb = rw_craplot.vlinfodb,
             craplot.vlcompdb = rw_craplot.vlcompdb,
             craplot.qtinfoln = rw_craplot.qtinfoln,
             craplot.qtcompln = rw_craplot.qtcompln,
             craplot.nrseqdig = rw_craplot.nrseqdig
       where craplot.rowid = rw_craplot.rowid;
    exception
      when others then
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao alterar a capa do lote: '||sqlerrm;
        raise vr_exc_erro;
    end;


  begin
    -- Faz a leitura da aplicação que está sendo calculada
    open cr_craprda;
      fetch cr_craprda into rw_craprda;
    close cr_craprda;
  -- Garantir a carga das faixas de IR
    APLI0001.pc_busca_faixa_ir_rdca(pr_cdcooper => pr_cdcooper);
    -- Inicializa variáveis necessárias para o cálculo
    vr_dtultdia := last_day(add_months(pr_dtmvtolt, -1));
    vr_dtcalcul := rw_craprda.dtiniper;
    vr_dtcalajt := rw_craprda.dtiniper;
    vr_dtrefere := rw_craprda.dtfimper;
    vr_vllan117 := 0;
    vr_vlsdrdca := rw_craprda.vlsdrdca;
    vr_vlrentot := 0;
    vr_ttajtlct := 0;
    vr_vlabcpmf := greatest(rw_craprda.vlabcpmf, 0);
    vr_flgncalc := false;
    vr_ajtirrgt := 0;
    vr_vlprovis := 0;
    vr_vldperda := 0;
    vr_ttrenrgt := 0;
    vr_vlrgtper := 0;
    vr_renrgper := 0;
    vr_ttpercrg := 0;
    vr_trergtaj := 0;
    -- Busca as taxas para a data inicial da aplicação
    open cr_craptrd (pr_cdcooper,
                     rw_craprda.dtiniper);
      fetch cr_craptrd into rw_craptrd_ini;
      if cr_craptrd%notfound then
        close cr_craptrd;
        pr_cdcritic := 347;
        pr_dscritic := gene0001.fn_busca_critica(347)||' '||to_char(rw_craprda.dtiniper, 'dd/mm/yyyy');
        raise vr_exc_erro;
      end if;
    close cr_craptrd;
    -- Identifica a taxa correta a utilizar
    if rw_craptrd_ini.txofidia > 0 then
      vr_txaplica := (rw_craptrd_ini.txofidia / 100);
      vr_txaplmes :=  rw_craptrd_ini.txofimes;
    elsif rw_craptrd_ini.txprodia > 0 then
      vr_txaplica := (rw_craptrd_ini.txprodia / 100);
      vr_txaplmes :=  0;
    else
      pr_cdcritic := 427;
      pr_dscritic := gene0001.fn_busca_critica(427);
      raise vr_exc_erro;
    end if;
    -- Identifica a data correta a utilizar para o cálculo da aplicação
    if pr_inproces > 2 and -- No BATCH
       pr_cdprogra not in ('CRPS011', 'CRPS109', 'CRPS110', 'CRPS113', 'CRPS128',
                           'CRPS175', 'CRPS176', 'CRPS168', 'CRPS140', 'CRPS169',
                           'CRPS210', 'CRPS323', 'CRPS349', 'CRPS414', 'CRPS445',
                           'CRPS563', 'CRPS029', 'CRPS688', 'CRPS005', 'ATENDA', 
                           'ANOTA','INTERNETBANK', 'RESGATE','GAROPC') then
      vr_incalcul := 1;
      if pr_cdprogra = 'CRPS103' then -- mensal
        vr_dtmvtolt := pr_dtmvtolt + 1;
      elsif pr_cdprogra = 'CRPS104' then -- aniversario
        vr_incalcul := 2;
        vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper
                                                  ,rw_craprda.dtfimper
                                                  ,pr_tipo     => 'P'     -- valor padrao
                                                  ,pr_feriado  => true    -- valor padrao 
                                                  ,pr_excultdia => true); -- considera 31/12 como util
      elsif pr_cdprogra = 'CRPS105' then -- resgate
        vr_dtmvtolt := pr_dtmvtopr;
      elsif pr_cdprogra = 'CRPS117' or -- resgate para o dia
            pr_cdprogra = 'CRPS135' or -- unificacao
            pr_cdprogra = 'CRPS431' then
        vr_dtmvtolt := pr_dtmvtolt;
      else
        pr_cdcritic := 145;
        pr_dscritic := gene0001.fn_busca_critica(145)||' Rotina: includes/aplicacao.i (APLI0001.pc_calc_aplicacao)';
        raise vr_exc_erro;
      end if;
      -- Atualiza o indicador de cálculo
      begin
        update craptrd
           set incalcul = vr_incalcul
         where rowid = rw_craptrd_ini.rowid;
      exception
        when others then
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar indicador de cálculo: '||sqlerrm;
          raise vr_exc_erro;
      end;
    else -- No ON-LINE
      if pr_cdprogra = 'CRPS110' then
        vr_dtmvtolt := rw_craprda.dtfimper;
      elsif pr_cdprogra = 'CRPS210' then
        vr_dtmvtolt := pr_dtmvtopr;
      elsif pr_cdprogra = 'CRPS117' or -- resgate para o dia
            pr_cdprogra = 'CRPS431' then -- nao roda on_line
        vr_dtmvtolt := pr_dtmvtolt;
      else
        vr_dtmvtolt := pr_dtmvtolt + 1; -- calculo ate o dia do mvto
      end if;
    end if;
    -- Leitura dos lançamentos da aplicação
    for rw_craplap in cr_craplap (pr_cdcooper,
                                  rw_craprda.nrdconta,
                                  rw_craprda.nraplica,
                                  vr_dtrefere,
                                  vr_dtcalcul,
                                  vr_dtmvtolt) loop
      if rw_craplap.cdhistor in (117, 124) then
        -- PROVISAO, AJUSTE PREV.
        vr_vllan117 := vr_vllan117 + rw_craplap.vllanmto;
        continue;
      elsif rw_craplap.cdhistor = 125 then
        -- AJUSTE PREV.
        vr_vllan117 := vr_vllan117 - rw_craplap.vllanmto;
        continue;
      elsif rw_craplap.cdhistor = 875 then -- ajuste IRRF dos resgates
        -- AJT RGT IR-30
        vr_vlsdrdca := vr_vlsdrdca - rw_craplap.vllanmto;
        vr_ttajtlct := vr_ttajtlct + rw_craplap.vllanmto;
        continue;
      end if;
      -- Acrescenta o rendimento para o periodo VR_DTCALCUL até VR_DTMVTOLT
      while vr_dtcalcul < rw_craplap.dtmvtolt and
            vr_vlsdrdca > 0 loop
        -- Busca o proximo dia util
        vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper
                                                  ,vr_dtcalcul
                                                  ,pr_tipo     => 'P'     -- valor padrao
                                                  ,pr_feriado  => true    -- valor padrao 
                                                  ,pr_excultdia => true); -- considera 31/12 como util
        if vr_dtcalcul >= rw_craplap.dtmvtolt then
          exit;
        end if;
        -- Incrementa os valores
        vr_vlrendim := trunc(vr_vlsdrdca * vr_txaplica, 8);
        vr_vlsdrdca := vr_vlsdrdca + vr_vlrendim;
        vr_vlrentot := vr_vlrentot + vr_vlrendim;
        if vr_dtcalcul <= vr_dtultdia then
          vr_vlprovis := vr_vlprovis + vr_vlrendim;
        end if;
        -- Proxima data
        vr_dtcalcul := vr_dtcalcul + 1;
      end loop;
      -- Calcula o saldo
      vr_vlsdrdca := vr_vlsdrdca - rw_craplap.vllanmto;
      -- Calcula a perda
      if vr_vlsdrdca < 0 then
        if pr_cdprogra = 'CRPS104' or
           (pr_inproces < 3 and pr_cdprogra <> 'CRPS103') then
          vr_vldperda := vr_vldperda - vr_vlsdrdca;
          vr_vlsdrdca := 0;
        end if;
      end if;
    end loop;
    -- Magui pegar os ajustes de IR devidos
    for rw_craplap2 in cr_craplap2 (pr_cdcooper,
                                    rw_craprda.nrdconta,
                                    rw_craprda.nraplica,
                                    vr_dtrefere,
                                    rw_craprda.dtiniper,
                                    vr_dtmvtolt) loop
      vr_vlrgtper := vr_vlrgtper + rw_craplap2.vllanmto;
      vr_renrgper := vr_renrgper + rw_craplap2.vlrenreg;
      vr_ttpercrg := vr_ttpercrg + rw_craplap2.pcajsren;
      -- Verifica se é o último registro da data
      if rw_craplap2.nrseq = rw_craplap2.totreg and
         vr_ttpercrg >= 99.9 then
        vr_vlrenrgt := rw_craplap2.rendatdt - vr_trergtaj;
      else
        if rw_craplap2.vlslajir <> 0 then
          vr_vlrenrgt := rw_craplap2.vllanmto * rw_craplap2.rendatdt / rw_craplap2.vlslajir;
        else
          vr_vlrenrgt := 0;
        end if;
        vr_trergtaj := vr_trergtaj + vr_vlrenrgt;
      end if;
      --
      vr_trergtaj := vr_ttrenrgt + vr_vlrenrgt;
      vr_ajtirrgt := vr_ajtirrgt + (trunc((vr_vlrenrgt * rw_craplap2.aliaplaj / 100),2) -
                                    trunc((vr_vlrenrgt * vr_faixa_ir_rdca(4).perirtab / 100),2));
      if vr_ttpercrg >= 99.9 then
        -- Seta o flag para não calcular
        vr_flgncalc := true;
      end if;
    end loop;
    -- Alimenta campos para a rotina duplicada
    vr_trergtaj := 0;
    dup_dtcalcul := vr_dtcalcul;
    if pr_cdprogra = 'CRPS105' then
      dup_dtmvtolt := pr_dtmvtopr;
    else
      dup_dtmvtolt := pr_dtmvtolt;
    end if;
    dup_vlsdrdca := vr_vlsdrdca;
    dup_vlrentot := vr_vlrentot;
    vr_sldcaren := vr_vlsdrdca;
    -- fim
    if not vr_flgncalc and
       vr_dtcalcul < vr_dtmvtolt   and
       vr_vlsdrdca > 0 then
      -- Acrescenta o rendimento para o periodo VR_DTCALCUL até VR_DTMVTOLT
      while vr_dtcalcul < vr_dtmvtolt loop
        -- Busca o proximo dia util
        vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper
                                                  ,vr_dtcalcul
                                                  ,pr_tipo     => 'P'     -- valor padrao
                                                  ,pr_feriado  => true    -- valor padrao 
                                                  ,pr_excultdia => true); -- considera 31/12 como util
        if vr_dtcalcul >= vr_dtmvtolt then
          exit;
        end if;
        -- Incrementa os valores
        vr_vlrendim := trunc(vr_vlsdrdca * vr_txaplica, 8);
        vr_vlsdrdca := vr_vlsdrdca + vr_vlrendim;
        vr_vlrentot := vr_vlrentot + vr_vlrendim;
        if vr_dtcalcul <= vr_dtultdia then
          vr_vlprovis := vr_vlprovis + vr_vlrendim;
        end if;
        -- Proxima data
        vr_dtcalcul := vr_dtcalcul + 1;
      end loop;
    end if;
    --
    if not vr_flgncalc and
       dup_dtcalcul < dup_dtmvtolt and
       dup_vlsdrdca > 0 then
      -- Acrescenta o rendimento para o periodo DUP_DTCALCUL até DUP_DTMVTOLT
      while dup_dtcalcul < dup_dtmvtolt loop
        -- Busca o proximo dia util
        dup_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper
                                                   ,dup_dtcalcul
                                                   ,pr_tipo     => 'P'     -- valor padrao
                                                   ,pr_feriado  => true    -- valor padrao 
                                                   ,pr_excultdia => true); -- considera 31/12 como util
        if dup_dtcalcul >= dup_dtmvtolt then
          exit;
        end if;
        -- Incrementa os valores
        vr_vlrendim := trunc(dup_vlsdrdca * vr_txaplica, 8);
        dup_vlsdrdca := dup_vlsdrdca + vr_vlrendim;
        dup_vlrentot := dup_vlrentot + vr_vlrendim;
        -- Proxima data
        dup_dtcalcul := dup_dtcalcul + 1;
      end loop;
    end if;
    -- Arredondamento dos valores calculados
    vr_vlsdrdca := round(vr_vlsdrdca,2);
    vr_vlrentot := round(vr_vlrentot,2);
    vr_vldperda := round(vr_vldperda,2);
    vr_vlprovis := round(vr_vlprovis,2);
    dup_vlsdrdca := round(dup_vlsdrdca,2);
    --
    if pr_inproces = 1 and
       rw_craprda.inaniver = 0 and
       rw_craprda.dtmvtolt = rw_craprda.dtiniper and
       rw_craprda.dtfimper > pr_dtmvtolt then
      -- Caso seja processo online e não tenha completado um mes, atualiza saldo para resgate sem calcular
      vr_sldpresg := vr_sldcaren;

    else
      -- Calcular saldo para resgate enxergando as novas faixas de percentual de
      -- imposto de renda e o ajuste necessario
      vr_vlsldapl := dup_vlsdrdca;
      vr_vlrenper := dup_vlrentot;
      vr_sldpresg := 0;
      vr_dtregapl := pr_dtmvtolt;
      -- Calculo de Saldo para Resgate de Aplicacao
      APLI0001.pc_saldo_rdca_resgate(pr_cdcooper, --> Cooperativa conectada
                                     vr_cdagenci, --> Codigo da agencia
                                     0, --> Numero do caixa
                                     pr_cdprogra, --> Programa chamador
                                     rw_craprda.nrdconta, --> Conta da aplicac?o RDCA
                                     vr_dtregapl,                  --> Data pada resgate da aplicac?o
                                     rw_craprda.nraplica, --> Numero da aplicac?o RDCA
                                     vr_vlsldapl, --> Saldo da aplicac?o
                                     vr_vlrenper,                --> Valor do rendimento no periodo
                                     1,           --> Tipo de chamada 1 - da BO, 2 - do Fonte
                                     vr_ttpercrg,               --> Percentual do resgate sobre o rendimento acumulado
                                     vr_vlrenreg,               --> Valor para calculo do ajuste
                                     vr_vldajtir,               --> Valor do ajuste de IR
                                     vr_sldrgttt,               --> Saldo do resgate total
                                     vr_vlslajir,               --> Saldo utilizado para calculo do ajuste
                                     vr_vlrenacu,               --> Rendimento acumulado para calculo do ajuste
                                     vr_nrdmeses,              --> Numero de meses da aplicac?o
                                     vr_nrdedias,              --> Numero de dias da aplicac?o
                                     vr_dtiniapl,                 --> data de inicio da aplicac?o
                                     vr_cdhisren, --> Historico de lancamento no rendimento
                                     vr_cdhisajt, --> Historico de ajuste
                                     vr_perirapl,                --> Percentual de IR Aplicado
                                     vr_sldpresg,             --> Saldo para o resgate
                                     vr_des_reto,               --> Indicador de saida com erro (OK/NOK)
                                     vr_tab_erro); --> Tabela com erros
    end if;
    --
    if pr_cdprogra <> 'CRPS103' then -- Se não for mensal
      vr_vlsdrdca := vr_vlsdrdca - trunc((vr_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2);
      dup_vlsdrdca := dup_vlsdrdca - trunc((dup_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2);
      if rw_craprda.dtfimper <= pr_dtmvtolt then
        vr_vlsdrdca := vr_vlsdrdca - trunc((vr_vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2);
        dup_vlsdrdca := dup_vlsdrdca - trunc((vr_vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2);
      end if;
    end if;
    --
    if pr_inproces > 2 and -- No BATCH
       pr_cdprogra not in ('CRPS011', 'CRPS105', 'CRPS109', 'CRPS110', 'CRPS113', 'CRPS117',
                           'CRPS128', 'CRPS175', 'CRPS176', 'CRPS168', 'CRPS135', 'CRPS431',
                           'CRPS140', 'CRPS169', 'CRPS210', 'CRPS323', 'CRPS349', 'CRPS414',
                           'CRPS445', 'CRPS563', 'CRPS029', 'CRPS688', 'CRPS005', 'ATENDA', 
                           'ANOTA', 'INTERNETBANK', 'RESGATE', 'GAROPC') then
      if pr_cdprogra = 'CRPS103' then  -- MENSAL
        vr_dtdolote := pr_dtmvtolt;
        vr_nrdolote := 8380;
        vr_cdhistor := 117;
        vr_flglanca := true;
        rw_craprda.incalmes := 0;
      elsif pr_cdprogra = 'CRPS104' then  -- ANIVERSARIO
        -- Busca as taxas para a data inicial da aplicação
        open cr_craptrd (pr_cdcooper,
                         rw_craprda.dtfimper);
          fetch cr_craptrd into rw_craptrd_fim;
          if cr_craptrd%notfound then
            close cr_craptrd;
            pr_cdcritic := 347;
            pr_dscritic := gene0001.fn_busca_critica(347)||' '||to_char(rw_craprda.dtfimper, 'dd/mm/yyyy');
            raise vr_exc_erro;
          end if;
        close cr_craptrd;
        -- Incrementa a quantidade de meses para emissão do extrato
        rw_craprda.qtmesext := rw_craprda.qtmesext + 1;
        -- O máximo são 3 meses
        if rw_craprda.qtmesext = 4 then
          rw_craprda.qtmesext := 1;
        end if;
        if rw_craprda.qtmesext = 1 then
          rw_craprda.dtiniext := rw_craprda.dtfimext;
          rw_craprda.dtsdrdan := rw_craprda.dtiniper;
          if rw_craprda.inaniver = 0 or
             (rw_craprda.nraplica > 499999 and
              rw_craprda.dtmvtolt = rw_craprda.dtsdrdan) then
            rw_craprda.vlsdrdan := 0;
          else
            rw_craprda.vlsdrdan := rw_craprda.vlsdrdca;
          end if;
        end if;
        --
        IF TRUNC(vr_vlsdrdca - vr_ajtirrgt, 2) = 0 THEN
          rw_craprda.qtmesext := 3;
        end if;
        -- Atualiza campos para fazer ajustes
        rw_craprda.incalmes := 1;
        rw_craprda.dtfimext := rw_craprda.dtfimper;
        rw_craprda.dtiniper := rw_craprda.dtfimper;
        rw_craprda.dtfimper := rw_craptrd_fim.dtfimper;
        rw_craprda.inaniver := 1;
        vr_vlsdrdca := trunc(vr_vlsdrdca, 2);
        vr_ajtirrgt := trunc(vr_ajtirrgt, 2);
        -- Se o ajuste de IR for maior que o saldo e for aplicação RDCA
        if vr_ajtirrgt > vr_vlsdrdca and
           vr_ajtirrgt <> 0 and
           rw_craprda.tpaplica = 3 then
          pr_dscritic := to_char(pr_dtmvtolt,'dd/mm/yyyy') || ' - ' ||
                         to_char(sysdate,'hh24:mi:ss') || ' - ' ||
                         pr_cdprogra || ''' --> ''' ||
                         'Conta = ' ||
                         to_char(rw_craprda.nrdconta,'9999G999G0') ||
                         ' Aplicacao = ' ||
                         to_char(rw_craprda.nraplica,'9G999G990') ||
                         ' aux_vlsdrdca = ' ||
                         to_char(vr_vlsdrdca,'999G999G990D00-') ||
                         ' aux_ajtirrgt = ' ||
                         to_char(vr_ajtirrgt,'999G999G990D00-');
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 1,
                                     pr_des_log      => pr_dscritic,
                                     pr_nmarqlog     => 'crps104'); -- Manter o programa aqui, pois a aplicacao.i faz assim
          if vr_vlsdrdca > 0 then
            vr_ajtirrgt := vr_vlsdrdca;
          else
            vr_ajtirrgt := 0;
          end if;
        end if;
        -- Ajusta o valor de ajuste
        if vr_vlsdrdca <> vr_ajtirrgt THEN
          if vr_vlsdrdca - vr_ajtirrgt = 0.01 THEN
            vr_ajtirrgt := vr_ajtirrgt + 0.01;
            vr_vlajtsld := 0.01;
          end if;
        end if;
        -- Atualiza informações no registro rw_craprda para posterior gravação na tabela craprda
        rw_craprda.vlsdrdca := vr_vlsdrdca - vr_ajtirrgt;
        if trunc(vr_vlsdrdca - vr_ajtirrgt,2) = 0 or
           vr_flgncalc then
          rw_craprda.insaqtot := 1;
        end if;
        if vr_vlsdrdca = 0 then
          rw_craprda.dtsaqtot := pr_dtmvtolt;
        end if;
        if rw_craprda.insaqtot = 1 then
          rw_craprda.dtcalcul := pr_dtmvtolt;
        else
          rw_craprda.dtcalcul := vr_dtcalcul;
        end if;
        vr_dtdolote := pr_dtmvtolt;
        vr_nrdolote := 8381;
        vr_cdhistor := 116;
        vr_flglanca := true;
        if rw_craprda.insaqtot = 1 then -- SAQUE TOTAL
          rw_craprda.vlsdextr := 0;
        end if;
        if rw_craprda.vlabcpmf > 0 then
          rw_craprda.vlabonrd := rw_craprda.vlabonrd + rw_craprda.vlabcpmf;
        end if;
        if trunc(rw_craprda.dtfimper, 'mm') = trunc(pr_dtmvtolt, 'mm') then
          rw_craprda.incalmes := 0;
        end if;
      else
        pr_cdcritic := 145;
        pr_dscritic := gene0001.fn_busca_critica(145)||' Rotina: includes/aplicacao.i (APLI0001.pc_calc_aplicacao)';
        raise vr_exc_erro;
      end if;
      -- Atualzia tabela CRAPRDA
      begin
        update craprda
           set incalmes = rw_craprda.incalmes,
               vlabonrd = rw_craprda.vlabonrd,
               vlsdextr = rw_craprda.vlsdextr,
               dtcalcul = rw_craprda.dtcalcul,
               dtsaqtot = rw_craprda.dtsaqtot,
               insaqtot = rw_craprda.insaqtot,
               inaniver = rw_craprda.inaniver,
               vlsdrdca = rw_craprda.vlsdrdca,
               dtiniext = rw_craprda.dtiniext,
               dtfimext = rw_craprda.dtfimext,
               qtmesext = rw_craprda.qtmesext,
               dtiniper = rw_craprda.dtiniper,
               dtfimper = rw_craprda.dtfimper,
               dtsdrdan = rw_craprda.dtsdrdan,
               vlsdrdan = rw_craprda.vlsdrdan
         where rowid = pr_rda_rowid;
      exception
        when others then
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar craprda: '||sqlerrm;
          raise vr_exc_erro;
      end;
      -- Popular variáveis de saída
      pr_insaqtot := rw_craprda.insaqtot;
      pr_vlsdrdca := rw_craprda.vlsdrdca;
      pr_sldpresg := vr_sldpresg;
      pr_dup_vlsdrdca := dup_vlsdrdca;
      --
      if pr_cdprogra = 'CRPS103' then
        vr_vlrentot := vr_vlrentot - vr_vlprovis;
      end if;
      -- Se teve rendimento e teve algum lançamento, insere craplap e atualiza craplot
      if vr_vlrentot > 0 and
         vr_flglanca then
        cria_craplot (vr_dtdolote,
                      vr_cdagenci,
                      vr_cdbccxlt,
                      vr_nrdolote,
                      pr_cdcooper);
        --
        tab_craplap := null;
        tab_craplap.dtmvtolt := rw_craplot.dtmvtolt;
        tab_craplap.cdagenci := rw_craplot.cdagenci;
        tab_craplap.cdbccxlt := rw_craplot.cdbccxlt;
        tab_craplap.nrdolote := rw_craplot.nrdolote;
        tab_craplap.nrdconta := rw_craprda.nrdconta;
        tab_craplap.nraplica := rw_craprda.nraplica;
        tab_craplap.nrdocmto := rw_craplot.nrseqdig + 1;
        tab_craplap.txaplica := (NVL(vr_txaplica, 0) * 100);
        tab_craplap.txaplmes := NVL(vr_txaplmes, 0);
        tab_craplap.cdhistor := vr_cdhistor;
        tab_craplap.nrseqdig := rw_craplot.nrseqdig + 1;
        tab_craplap.vllanmto := vr_vlrentot;
        tab_craplap.dtrefere := vr_dtrefere;
        tab_craplap.vlrenacu := greatest(trunc(vr_vlrenacu + vr_vlrentot - vr_renrgper - vr_ttrenrgt,2), 0);
        tab_craplap.vlslajir := trunc(vr_vlslajir + vr_vlrentot - vr_vlrgtper - vr_ttajtlct -
                                      (trunc((vr_vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2)) -
                                      (trunc((vr_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2)), 2) - vr_ajtirrgt;
        tab_craplap.cdcooper := pr_cdcooper;
        cria_craplap;
        --
        rw_craplot.vlinfocr := rw_craplot.vlinfocr + tab_craplap.vllanmto;
        rw_craplot.vlcompcr := rw_craplot.vlcompcr + tab_craplap.vllanmto;
        rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
        rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
        rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
        altera_craplot;
        -- Lançamento de RENDIMENTO
        if vr_cdhistor = 116 and
           trunc((vr_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2) > 0 then
          tab_craplap := null;
          tab_craplap.dtmvtolt := rw_craplot.dtmvtolt;
          tab_craplap.cdagenci := rw_craplot.cdagenci;
          tab_craplap.cdbccxlt := rw_craplot.cdbccxlt;
          tab_craplap.nrdolote := rw_craplot.nrdolote;
          tab_craplap.nrdconta := rw_craprda.nrdconta;
          tab_craplap.nraplica := rw_craprda.nraplica;
          tab_craplap.nrdocmto := rw_craplot.nrseqdig + 1;
          tab_craplap.txaplica := NVL(vr_faixa_ir_rdca(4).perirtab, 0);
          tab_craplap.txaplmes := NVL(vr_faixa_ir_rdca(4).perirtab, 0);
          tab_craplap.cdhistor := 861;
          tab_craplap.nrseqdig := rw_craplot.nrseqdig + 1;
          tab_craplap.vllanmto := trunc((vr_vlrentot * vr_faixa_ir_rdca(4).perirtab / 100),2);
          tab_craplap.dtrefere := vr_dtrefere;
          tab_craplap.cdcooper := pr_cdcooper;
          cria_craplap;
          --
          rw_craplot.vlinfocr := rw_craplot.vlinfocr + tab_craplap.vllanmto;
          rw_craplot.vlcompcr := rw_craplot.vlcompcr + tab_craplap.vllanmto;
          rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
          rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
          rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
          altera_craplot;
        end if;
      end if;
      -- Aniversário
      if pr_cdprogra = 'CRPS104' then
        -- Abono do Cpmf agora e na aplicacao no dia aniver
        if rw_craprda.vlabcpmf > 0 then
          cria_craplot (vr_dtdolote,
                        vr_cdagenci,
                        vr_cdbccxlt,
                        vr_nrdolote,
                        pr_cdcooper);
          --
          tab_craplap := null;
          tab_craplap.dtmvtolt := rw_craplot.dtmvtolt;
          tab_craplap.cdagenci := rw_craplot.cdagenci;
          tab_craplap.cdbccxlt := rw_craplot.cdbccxlt;
          tab_craplap.nrdolote := rw_craplot.nrdolote;
          tab_craplap.nrdconta := rw_craprda.nrdconta;
          tab_craplap.nraplica := rw_craprda.nraplica;
          tab_craplap.nrdocmto := rw_craplot.nrseqdig + 1;
          tab_craplap.txaplica := 0;
          tab_craplap.txaplmes := 0;
          tab_craplap.cdhistor := 866;
          tab_craplap.nrseqdig := rw_craplot.nrseqdig + 1;
          tab_craplap.vllanmto := rw_craprda.vlabcpmf;
          tab_craplap.dtrefere := vr_dtrefere;
          tab_craplap.cdcooper := pr_cdcooper;
          cria_craplap;
          --
          rw_craplot.vlinfocr := rw_craplot.vlinfocr + tab_craplap.vllanmto;
          rw_craplot.vlcompcr := rw_craplot.vlcompcr + tab_craplap.vllanmto;
          rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
          rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
          rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
          altera_craplot;
          -- IR sobre o abono
          if trunc((rw_craprda.vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100),2) > 0 then
            tab_craplap := null;
            tab_craplap.dtmvtolt := rw_craplot.dtmvtolt;
            tab_craplap.cdagenci := rw_craplot.cdagenci;
            tab_craplap.cdbccxlt := rw_craplot.cdbccxlt;
            tab_craplap.nrdolote := rw_craplot.nrdolote;
            tab_craplap.nrdconta := rw_craprda.nrdconta;
            tab_craplap.nraplica := rw_craprda.nraplica;
            tab_craplap.nrdocmto := rw_craplot.nrseqdig + 1;
            tab_craplap.txaplica := NVL(vr_faixa_ir_rdca(1).perirtab, 0);
            tab_craplap.txaplmes := NVL(vr_faixa_ir_rdca(1).perirtab, 0);
            tab_craplap.cdhistor := 868;
            tab_craplap.nrseqdig := rw_craplot.nrseqdig + 1;
            tab_craplap.vllanmto := trunc((rw_craprda.vlabcpmf * vr_faixa_ir_rdca(1).perirtab / 100), 2);
            tab_craplap.dtrefere := vr_dtrefere;
            tab_craplap.cdcooper := pr_cdcooper;
            cria_craplap;
            --
            rw_craplot.vlinfocr := rw_craplot.vlinfocr + tab_craplap.vllanmto;
            rw_craplot.vlcompcr := rw_craplot.vlcompcr + tab_craplap.vllanmto;
            rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
            rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
            rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
            altera_craplot;
          end if;
          --
          rw_craprda.vlabcpmf := 0;
        end if;
        -- Ajuste IRRF sobre resgates
        if vr_ajtirrgt > 0 then
          cria_craplot (vr_dtdolote,
                        vr_cdagenci,
                        vr_cdbccxlt,
                        vr_nrdolote,
                        pr_cdcooper);

          vr_vlsdrdat := vr_vlsdrdca;
          -- Leitura dos lançamentos de resgate
          for rw_craplap5 in cr_craplap2 (pr_cdcooper,
                                          rw_craprda.nrdconta,
                                          rw_craprda.nraplica,
                                          vr_dtrefere,
                                          vr_dtcalajt,
                                          vr_dtmvtolt) loop
            -- Verifica se é o último registro da data
            if rw_craplap5.nrseq = rw_craplap5.totreg and
               vr_ttpercrg >= 99.9 then
              vr_vlrenrgt := rw_craplap5.rendatdt - vr_trergtaj;
            else
              if rw_craplap5.vlslajir <> 0 then
                vr_vlrenrgt := rw_craplap5.vllanmto * rw_craplap5.rendatdt / rw_craplap5.vlslajir;
              else
                vr_vlrenrgt := 0;
              end if;
              vr_trergtaj := vr_trergtaj + vr_vlrenrgt;
            end if;
            -- Calcula o ajuste de IR sobre resgates
            vr_ajtirrgt := trunc((vr_vlrenrgt * rw_craplap5.aliaplaj / 100),2) - trunc((vr_vlrenrgt * vr_faixa_ir_rdca(4).perirtab / 100),2);
            -- Verifica se é o último registro da data
            if rw_craplap5.nrseq = rw_craplap5.totreg and
               vr_vlajtsld <> 0 then
              vr_ajtirrgt := vr_ajtirrgt + vr_vlajtsld;
            end if;
            -- Se existir valor de ajuste de IR sobre resgates
            if vr_ajtirrgt > 0 then
              -- Se o valor for maior que o saldo
              if vr_ajtirrgt > vr_vlsdrdat and
                 vr_vlsdrdat > 0 then
                pr_dscritic := to_char(pr_dtmvtolt,'dd/mm/yyyy') || ' - ' ||
                               to_char(sysdate,'hh24:mi:ss') || ' - ' ||
                               pr_cdprogra || ''' --> ''' ||
                               'Conta = ' ||
                               to_char(rw_craprda.nrdconta,'9999G999G0') ||
                               ' Aplicacao = ' ||
                               to_char(rw_craprda.nraplica,'9G999G990') ||
                               ' aux_vlsdrdca = ' ||
                               to_char(vr_vlsdrdca,'999G999G990D00-') ||
                               ' aux_ajtirrgt = ' ||
                               to_char(vr_ajtirrgt,'999G999G990D00-');
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                           pr_ind_tipo_log => 1,
                                           pr_des_log      => pr_dscritic,
                                           pr_nmarqlog     => 'crps104b'); -- Manter o programa aqui, pois a aplicacao.i faz assim
                vr_ajtirrgt := vr_vlsdrdat;
              end if;
              -- Se o saldo não for positivo, zera o valor de ajuste
              if vr_vlsdrdat <= 0 then
                 vr_ajtirrgt := 0;
              end if;
              -- Se houver valor positivo de ajuste, gera o lançamento e atualiza a craplot
              if vr_ajtirrgt > 0 then
                tab_craplap := null;
                tab_craplap.dtmvtolt := rw_craplot.dtmvtolt;
                tab_craplap.cdagenci := rw_craplot.cdagenci;
                tab_craplap.cdbccxlt := rw_craplot.cdbccxlt;
                tab_craplap.nrdolote := rw_craplot.nrdolote;
                tab_craplap.nrdconta := rw_craprda.nrdconta;
                tab_craplap.nraplica := rw_craprda.nraplica;
                tab_craplap.nrdocmto := rw_craplot.nrseqdig + 1;
                tab_craplap.txaplica := NVL(rw_craplap5.aliaplaj, 0);
                tab_craplap.txaplmes := NVL(rw_craplap5.aliaplaj, 0);
                tab_craplap.cdhistor := 877;
                tab_craplap.nrseqdig := rw_craplot.nrseqdig + 1;
                tab_craplap.vllanmto := vr_ajtirrgt;
                tab_craplap.dtrefere := vr_dtrefere;
                tab_craplap.vlslajir := rw_craplap5.vlslajir;
                tab_craplap.vlrenacu := rw_craplap5.vlrenacu;
                tab_craplap.pcajsren := rw_craplap5.pcajsren;
                tab_craplap.vlrenreg := trunc(vr_vlrenrgt, 2);
                tab_craplap.vldajtir := trunc(vr_ajtirrgt, 2);
                tab_craplap.aliaplaj := rw_craplap5.aliaplaj;
                tab_craplap.qtdmesaj := rw_craplap5.qtdmesaj;
                tab_craplap.qtddiaaj := rw_craplap5.qtddiaaj;
                tab_craplap.rendatdt := rw_craplap5.rendatdt;
                tab_craplap.cdcooper := pr_cdcooper;
                cria_craplap;
                --
                rw_craplot.vlinfocr := rw_craplot.vlinfocr + tab_craplap.vllanmto;
                rw_craplot.vlcompcr := rw_craplot.vlcompcr + tab_craplap.vllanmto;
                rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                altera_craplot;
                --
                vr_vlsdrdat := vr_vlsdrdat - tab_craplap.vllanmto;
              end if;
            end if;
          end loop;
        end if;
      end if;
      -- Se o rendimento for maior que a provisão, gera o lançamento e atualiza a craplot
      if pr_cdprogra = 'CRPS104' and -- Aniversário
         vr_cdhistor = 116 and -- Rendimento
         vr_vlrentot - vr_vlprovis > 0 then
        cria_craplot (vr_dtdolote,
                      vr_cdagenci,
                      vr_cdbccxlt,
                      vr_nrdolote,
                      pr_cdcooper);
        --
        tab_craplap := null;
        tab_craplap.dtmvtolt := rw_craplot.dtmvtolt;
        tab_craplap.cdagenci := rw_craplot.cdagenci;
        tab_craplap.cdbccxlt := rw_craplot.cdbccxlt;
        tab_craplap.nrdolote := rw_craplot.nrdolote;
        tab_craplap.nrdconta := rw_craprda.nrdconta;
        tab_craplap.nraplica := rw_craprda.nraplica;
        tab_craplap.nrdocmto := rw_craplot.nrseqdig + 1;
        tab_craplap.txaplica := (NVL(vr_txaplica, 0) * 100);
        tab_craplap.txaplmes := NVL(vr_txaplmes, 0);
        tab_craplap.cdhistor := 117;
        tab_craplap.nrseqdig := rw_craplot.nrseqdig + 1;
        tab_craplap.vllanmto := vr_vlrentot - vr_vlprovis;
        tab_craplap.dtrefere := vr_dtrefere;
        tab_craplap.cdcooper := pr_cdcooper;
        cria_craplap;
        --
        rw_craplot.vlinfocr := rw_craplot.vlinfocr + tab_craplap.vllanmto;
        rw_craplot.vlcompcr := rw_craplot.vlcompcr + tab_craplap.vllanmto;
        rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
        rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
        rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
        altera_craplot;
      end if;
      -- Mensal ou aniversário
      if pr_cdprogra in ('CRPS103', 'CRPS104') then
        vr_vlajuste := vr_vlprovis - vr_vllan117;
        -- Se houver ajuste no valor da provisão, gera o lançamento e atualiza a craplot
        if vr_vlajuste <> 0 then
          cria_craplot (vr_dtdolote,
                        vr_cdagenci,
                        vr_cdbccxlt,
                        vr_nrdolote,
                        pr_cdcooper);
          --
          tab_craplap := null;
          tab_craplap.dtmvtolt := rw_craplot.dtmvtolt;
          tab_craplap.cdagenci := rw_craplot.cdagenci;
          tab_craplap.cdbccxlt := rw_craplot.cdbccxlt;
          tab_craplap.nrdolote := rw_craplot.nrdolote;
          tab_craplap.nrdconta := rw_craprda.nrdconta;
          tab_craplap.nraplica := rw_craprda.nraplica;
          tab_craplap.nrdocmto := rw_craplot.nrseqdig + 1;
          tab_craplap.txaplica := (NVL(vr_txaplica, 0) * 100);
          tab_craplap.txaplmes := NVL(vr_txaplmes, 0);
          if vr_vlajuste > 0 then
            tab_craplap.cdhistor := 124;
          else
            tab_craplap.cdhistor := 125;
          end if;
          tab_craplap.nrseqdig := rw_craplot.nrseqdig + 1;
          tab_craplap.vllanmto := abs(vr_vlajuste);
          tab_craplap.dtrefere := vr_dtrefere;
          tab_craplap.cdcooper := pr_cdcooper;
          cria_craplap;
          --
          if vr_vlajuste > 0 then
            rw_craplot.vlinfocr := rw_craplot.vlinfocr + tab_craplap.vllanmto;
            rw_craplot.vlcompcr := rw_craplot.vlcompcr + tab_craplap.vllanmto;
          else
            rw_craplot.vlinfodb := rw_craplot.vlinfodb + tab_craplap.vllanmto;
            rw_craplot.vlcompdb := rw_craplot.vlcompdb + tab_craplap.vllanmto;
          end if;
          rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
          rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
          rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
          altera_craplot;
        end if;
      end if;
      -- Se houver perda, gera o lançamento e atualiza a craplot
      if vr_vldperda <> 0 and
         pr_cdprogra = 'CRPS104' then -- Aniversário
        cria_craplot (vr_dtdolote,
                      vr_cdagenci,
                      vr_cdbccxlt,
                      8391,
                      pr_cdcooper);
        --
        tab_craplap := null;
        tab_craplap.dtmvtolt := rw_craplot.dtmvtolt;
        tab_craplap.cdagenci := rw_craplot.cdagenci;
        tab_craplap.cdbccxlt := rw_craplot.cdbccxlt;
        tab_craplap.nrdolote := rw_craplot.nrdolote;
        tab_craplap.nrdconta := rw_craprda.nrdconta;
        tab_craplap.nraplica := rw_craprda.nraplica;
        tab_craplap.nrdocmto := rw_craplot.nrseqdig + 1;
        tab_craplap.txaplica := (NVL(vr_txaplica, 0) * 100);
        tab_craplap.txaplmes := NVL(vr_txaplmes, 0);
        if vr_vldperda > 0 then
          tab_craplap.cdhistor := 119;
        else
          tab_craplap.cdhistor := 121;
        end if;
        tab_craplap.nrseqdig := rw_craplot.nrseqdig + 1;
        tab_craplap.vllanmto := abs(vr_vldperda);
        tab_craplap.dtrefere := vr_dtrefere;
        tab_craplap.cdcooper := pr_cdcooper;
        cria_craplap;
        --
        if vr_vldperda > 0 then
          rw_craplot.vlinfocr := rw_craplot.vlinfocr + tab_craplap.vllanmto;
          rw_craplot.vlcompcr := rw_craplot.vlcompcr + tab_craplap.vllanmto;
        else
          rw_craplot.vlinfodb := rw_craplot.vlinfodb + tab_craplap.vllanmto;
          rw_craplot.vlcompdb := rw_craplot.vlcompdb + tab_craplap.vllanmto;
        end if;
        rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
        rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
        rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
        altera_craplot;
      end if;
    end if;
    --
    if pr_cdprogra in ('CRPS117', 'CRPS177') then -- Resgates para o dia ou Resgate da aplicação RDCA60
      if rw_craprda.vlsdrdca <= 1 and
         vr_sldpresg = 0 then
        open cr_craplap3 (pr_cdcooper,
                          rw_craprda.nrdconta,
                          rw_craprda.nraplica);
          fetch cr_craplap3 into rw_craplap3;
          if cr_craplap3%notfound then
            vr_sldpresg := rw_craprda.vlsdrdca;
          else
            if to_char(rw_craplap3.dtmvtolt, 'yyyy') < to_char(pr_dtmvtolt, 'yyyy') then
              vr_sldpresg := rw_craprda.vlsdrdca;
            end if;
          end if;
      end if;
    end if;

    -- Popular variáveis de saída
    pr_insaqtot := rw_craprda.insaqtot;
    pr_vlsdrdca := ROUND(vr_vlsdrdca,2);
    pr_sldpresg := ROUND(vr_sldpresg,2);
    pr_dup_vlsdrdca := ROUND(dup_vlsdrdca,2);
  end;

  /* Rotina de calculo do saldo RDCA2 */
  PROCEDURE pc_rdca2s(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Cooperativa
                      pr_nrdconta in craprda.nrdconta%TYPE, --> Num da Conta
                      pr_nraplica in craprda.nraplica%TYPE, --> Num da Aplicacao
                      pr_dtiniper IN craprda.dtiniper%TYPE, --> Data Inicio do Periodo
                      pr_dtfimper IN craprda.dtfimper%TYPE, --> Data Fim do Periodo
                      pr_inaniver IN craprda.inaniver%TYPE, --> Indicador de Aplicação
                      pr_dtmvtolt IN craprda.dtmvtolt%TYPE, --> Data de Movimento Atual
                      pr_dtmvtopr IN crapdat.dtmvtopr%TYPE, --> DAta do movimento Posterior
                      pr_cdprogra IN crapprg.cdprogra%TYPE, --> Programa chamador
                      pr_vlsdrdca IN OUT NUMBER           , --> Valor saldo RDCA
                      pr_sldpresg IN OUT NUMBER           , --> Saldo para o resgate
                      pr_sldrgttt IN OUT NUMBER           , --> Saldo do resgate total
                      pr_cdcritic OUT crapcri.cdcritic%type,--> Codigo da critica de erro
                      pr_dscritic OUT varchar2) IS          --> Descricão do erro encontrado)

  BEGIN
    /* .............................................................................

    Programa: pc_rdca2s                              (Antigo: Includes/rdca2s.i)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Deborah/Edson
    Data    : Novembro/96.                        Ultima atualizacao: 15/04/2014

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina de calculo do saldo RDCA2.

    Alteracoes: 23/09/2004 - Incluido historico 494(CI)(Mirtes)

                13/12/2004 - Ajustes para tratar das novas aliquotas de
                             IRRF (Margarete).

                06/05/2005 - Utilizar o indice craplap5 na leitura dos
                             lancamentos (Edson).

                24/10/2005 - Saldo no dia do primeiro aniversario descontando
                             ir sobre a cpmf (Margarete).

                24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

                27/07/2007 - Alteracao para melhoria de performance (Evandro).

                30/01/2014 - Conversão Progress >> PLSQL (Jean Michel).

                15/04/2014 - Inclusao de tratamento de erro (Jean Michel).
    ............................................................................. */
    DECLARE

      vr_dtcalcul craprda.dtiniper%TYPE;
      vr_dtrefere craprda.dtfimper%TYPE;
      vr_dtmvtolt crapdat.dtmvtopr%TYPE;
      vr_dtrefant crapdat.dtmvtopr%TYPE;
      vr_vlrenper craprda.vlsdrdca%TYPE;
      vr_cdhisren craphis.cdhistor%TYPE; --> HISTORICO DE LANCAMENTO NO RENDIMENTO
      vr_cdhisajt craphis.cdhistor%TYPE; --> HISTORICO DE AJUSTE

      vr_ret_array gene0002.typ_split;   --> VARIÁVEL DO TIPO CRIADO

      vr_pcajsren NUMBER(25,8) := 0;   --> PERCENTUAL DO RESGATE SOBRE O RENDIMENTO ACUMULADO
      vr_vlrenreg NUMBER(25,8) := 0;   --> VALOR PARA CALCULO DO AJUSTE
      vr_vldajtir NUMBER(25,8) := 0;   --> VALOR DO AJUSTE DE IR
      vr_vlslajir NUMBER(25,8) := 0;   --> SALDO UTILIZADO PARA CALCULO DO AJUSTE
      vr_vlrenacu NUMBER(25,8) := 0;   --> RENDIMENTO ACUMULADO PARA CALCULO DO AJUSTE
      vr_perirapl NUMBER(25,8) := 0;   --> PERCENTUAL DE IR APLICADO
      vr_vlrgtper NUMBER(25,8) := 0;
      vr_renrgper NUMBER(25,8) := 0;
      vr_vllan178 NUMBER(25,8) := 0;

      vr_nrdmeses INTEGER;               --> NUMERO DE MESES DA APLICACAO
      vr_nrdedias INTEGER;               --> NUMERO DE DIAS DA APLICACAO
      vr_auxcont  INTEGER := 0;

      vr_dtiniapl DATE;                  --> DATA DE INICIO DA APLICACAO



      vr_des_reto VARCHAR(20);           --> INDICADOR DE SAIDA COM ERRO (OK/NOK)
      vr_tab_erro GENE0001.typ_tab_erro; --> TABELA COM ERROS

      -- Lançamentos de aplicações RDCA para ajustes de IR
      CURSOR cr_craplap (pr_cdcooper in craplap.cdcooper%type,
                         pr_nrdconta in craplap.nrdconta%type,
                         pr_nraplica in craplap.nraplica%type,
                         pr_dtrefere in craplap.dtrefere%type,
                         pr_cdhistor in craplap.cdhistor%type,
                         pr_dtcalcul in craplap.dtmvtolt%type,
                         pr_dtmvtolt in craplap.dtmvtolt%type) is

        select craplap.vllanmto,
               craplap.vlrenreg,
               craplap.cdhistor
          from craplap
         where craplap.cdcooper = pr_cdcooper
           and craplap.nrdconta = pr_nrdconta
           and craplap.nraplica = pr_nraplica
           and craplap.dtrefere = pr_dtrefere
           and craplap.cdhistor = pr_cdhistor
           and craplap.dtmvtolt >= pr_dtcalcul
           and craplap.dtmvtolt <= pr_dtmvtolt;

      rw_craplap cr_craplap%rowtype;
    BEGIN
      -- Inicializando informações para o cálculo
      vr_vlrgtper := 0;
      vr_renrgper := 0;
      vr_vllan178 := 0;
      vr_dtcalcul := pr_dtiniper;
      vr_dtrefere := pr_dtfimper;
      vr_dtmvtolt := pr_dtmvtopr;

      -- Criando um Arrar para aproveitamento de código e leitura de históris específicos
      vr_ret_array := gene0002.fn_quebra_string('178;494;876', ';');

      -- LEITURA DOS LANCAMENTOS DE RESGATE DA APLICACAO
      FOR vr_auxcont IN 1..vr_ret_array.count loop

        -- BUSCA LANCAMENTOS DE APLICACOES
        OPEN cr_craplap(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_nraplica => pr_nraplica,
                        pr_dtrefere => vr_dtrefere,
                        pr_cdhistor => vr_ret_array(vr_auxcont),
                        pr_dtcalcul => vr_dtcalcul,
                        pr_dtmvtolt => vr_dtmvtolt);
          LOOP
            FETCH cr_craplap
              INTO rw_craplap;

            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_craplap%NOTFOUND;

            vr_vllan178 := vr_vllan178 + rw_craplap.vllanmto;

            IF rw_craplap.cdhistor <> 876 THEN
              vr_vlrgtper := vr_vlrgtper + rw_craplap.vllanmto;
              vr_renrgper := vr_renrgper + rw_craplap.vlrenreg;
            END IF;

          END LOOP;
          CLOSE cr_craplap;


      END LOOP;
      -- Descontar resgates
      pr_vlsdrdca := (pr_vlsdrdca - vr_vllan178);

      -- CALCULAR SALDO PARA RESGATE ENXERGANDO AS NOVAS FAIXAS DE PERCENTUAL DE IMPOSTO DE RENDA E O AJUSTE NECESSARIO
      vr_vlrenper := 0;

      IF pr_inaniver = 0 AND pr_dtmvtolt <> pr_dtiniper THEN
        vr_dtrefant := pr_dtiniper;
      ELSE
        vr_dtrefant := pr_dtfimper;
      END IF;

      -- Para o primeiro mês
      IF pr_inaniver = 0 AND vr_dtrefant = vr_dtrefere   THEN
        pr_sldpresg := pr_vlsdrdca;
      ELSE
        -- A PARTIR DO SEGUNDO MES
        pc_saldo_rdca_resgate(pr_cdcooper => pr_cdcooper    --> Cooperativa conectada
                             ,pr_cdagenci => 1              --> Codigo da agencia
                             ,pr_nrdcaixa => 1              --> Numero do caixa
                             ,pr_cdprogra => pr_cdprogra    --> Programa chamador
                             ,pr_nrdconta => pr_nrdconta    --> Conta da aplicacao RDCA
                             ,pr_dtaplica => vr_dtrefant    --> Data para resgate da aplicacao
                             ,pr_nraplica => pr_nraplica    --> Numero da aplicacao RDCA
                             ,pr_vlsldapl => pr_vlsdrdca    --> Saldo da aplicacao
                             ,pr_vlrenper => vr_vlrenper    --> Valor do rendimento no periodo
                             ,pr_tpchamad => 2              --> Tipo de chamada 1 - da BO, 2 - do Fonte
                             ,pr_pcajsren => vr_pcajsren    --> Percentual do resgate sobre o rendimento acumulado
                             ,pr_vlrenreg => vr_vlrenreg    --> Valor para calculo do ajuste
                             ,pr_vldajtir => vr_vldajtir    --> Valor do ajuste de IR
                             ,pr_sldrgttt => pr_sldrgttt    --> Saldo do resgate total
                             ,pr_vlslajir => vr_vlslajir    --> Saldo utilizado para calculo do ajuste
                             ,pr_vlrenacu => vr_vlrenacu    --> Rendimento acumulado para calculo do ajuste
                             ,pr_nrdmeses => vr_nrdmeses    --> Numero de meses da aplicacao
                             ,pr_nrdedias => vr_nrdedias    --> Numero de dias da aplicacao
                             ,pr_dtiniapl => vr_dtiniapl    --> data de inicio da aplicacao
                             ,pr_cdhisren => vr_cdhisren    --> Historico de lancamento no rendimento
                             ,pr_cdhisajt => vr_cdhisajt    --> Historico de ajuste
                             ,pr_perirapl => vr_perirapl    --> Percentual de IR Aplicado
                             ,pr_sldpresg => pr_sldpresg    --> Saldo para o resgate
                             ,pr_des_reto => vr_des_reto    --> Indicador de saida com erro (OK/NOK)
                             ,pr_tab_erro => vr_tab_erro    --> Tabela com erros
                             );
        IF vr_des_reto <> 'OK' THEN
          pr_cdcritic := 1;
          pr_dscritic := 'Erro procedure pc_saldo_rdca_resgate.';
        END IF;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := 'Problemas na Rotina APLI0001.pc_rdca2s ' || pr_cdcooper ||'. Erro: ' || pr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Problemas na Rotina APLI0001.pc_rdca2s ' || pr_cdcooper ||'. Erro: ' || sqlerrm;
    END;

  END pc_rdca2s;

  /* Efetua uma consulta sobre as aplicacoes do cooperado passado como parametro */
  PROCEDURE pc_consulta_aplicacoes(pr_cdcooper    IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                   pr_cdagenci    IN crapass.cdagenci%TYPE,     --> Codigo da agencia
                                   pr_nrdcaixa    IN craperr.nrdcaixa%TYPE,     --> Numero do caixa
                                   pr_cdoperad    IN crapope.cdoperad%TYPE DEFAULT 0, --> Operador
                                   pr_nrdconta    IN crapass.nrdconta%TYPE,     --> Conta do associado
                                   pr_nraplica    IN craprda.nraplica%TYPE,     --> Numero da aplicacao
                                   pr_tpaplica    IN PLS_INTEGER,               --> Tipo de aplicacao
                                   pr_dtinicio    IN DATE,                      --> Data de inicio da aplicacao
                                   pr_dtfim       IN DATE,                      --> Data final da aplicacao
                                   pr_cdprogra    IN crapprg.cdprogra%TYPE,     --> Codigo do programa chamador da rotina
                                   pr_nrorigem    IN PLS_INTEGER,               --> Origem da chamada da rotina
                                   pr_saldo_rdca OUT typ_tab_saldo_rdca,        --> Tipo de tabela com o saldo RDCA
                                   pr_des_reto   OUT VARCHAR2,                  --> OK ou NOK
                                   pr_tab_erro   OUT GENE0001.typ_tab_erro) IS  --> Tabela com erros
    /*..........................................................................
    
      Programa : pc_consulta_aplicacoes (antiga b1wgen0004.consulta_aplicacoes)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Andrino (RKAM)
       Data    : Abril/2014                          Ultima Atualizacao: 06/06/2018
    
       Dados referentes ao programa:
       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Retornar a consulta de aplicacoes
    
       Observacoes :
    
       Alteracoes  :     28/04/2014 - Incluir NVL para impedir campos nulos (Petter - Supero).
    
                         04/06/2014 - Correção na lógica de encontro do cursor
                                      cr_craplrg (Marcos-Supero)
    
                         30/06/2014 - Correção da quantidade de dias uteis de
                                      aplicacao - SD 171838 (Jean Michel)
    
                         18/11/2014 - Realizado ajuste para quando esta procedure for chamada
                                      pelo crps688, ao consultar os saldos de aplicações RDCPRE/RDCPOS,
                                      passe a utilizar o dtmvtocd
                                      (Adriano).
    
                         01/04/2015 - Adicionado novo campo dtiniper na tab de retorno
                                      pr_saldo_rdca. (SD 266191 - Kelvin)
                                      
                         01/12/2015 - Tratamento para corrigir a data e os dias de carência
                                      dos diversos locais que a utilizam conforme solicitado no
                                      chamado 362034 (Kelvin).
                                      
                         01/06/2016 - Ajustado a leitura da craptab para utilizar a rotina
                                      da TABE0001 (Douglas - Chamado 454248)
                                      
                         15/05/2018 - Retirar o bloqueio para aplicações antigas (SM404).
                                      
                         06/06/2018 - P411 - Incluir a CUSAPL na lista de programas para extrado
                                      completo + usar pr_dtinicio e pr_dtfim ao inves do calendario 
                                      neste casos - Marcos (Envolti)
                                      
     .............................................................................*/

    -- Cursor sobre o cadastro de aplicacoes RDCA.
    CURSOR cr_craprda IS
      SELECT insaqtot,
             nraplica,
             tpaplica,
             vlsdrdca,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             inaniver,
             dtfimper,
             qtdiauti,
             tpnomapl,
             vlaplica,
             cdoperad,
             qtdiaapl,
             dtvencto,
             dtiniper
        FROM craprda
       WHERE craprda.cdcooper = pr_cdcooper
         AND craprda.nrdconta = pr_nrdconta
         AND craprda.nraplica = decode(pr_nraplica,0,craprda.nraplica,pr_nraplica) -- Se for informado aplicacao buscar somente esta
       ORDER BY dtmvtolt, nraplica;

    -- Cursor sobre o cadastro dos lancamentos de aplicacoes RDCA.
    CURSOR cr_craplap_2(pr_nraplica craplap.nraplica%TYPE) IS
      SELECT 1
        FROM craplap
       WHERE craplap.cdcooper  = pr_cdcooper
         AND craplap.nrdconta  = pr_nrdconta
         AND craplap.nraplica  = pr_nraplica
         AND craplap.dtmvtolt >= pr_dtinicio
         AND craplap.dtmvtolt <= pr_dtfim;
    rw_craplap_2 cr_craplap_2%ROWTYPE;

    -- Cursor sobre a descricao dos varios tipos de captacao oferecidas para o cooperado.
    CURSOR cr_crapdtc(pr_tpaplica crapdtc.tpaplica%TYPE) IS
      SELECT tpaplrdc,
             dsaplica,
             1 existe
        FROM crapdtc
       WHERE crapdtc.cdcooper = pr_cdcooper
         AND crapdtc.tpaplica = pr_tpaplica;
    rw_crapdtc cr_crapdtc%ROWTYPE;

    -- Cursor sobre o cadastro dos lancamentos de aplicacoes RDCA.
    CURSOR cr_craplap(pr_dtmvtolt craplap.dtmvtolt%TYPE,
                      pr_cdagenci craplap.cdagenci%TYPE,
                      pr_cdbccxlt craplap.cdbccxlt%TYPE,
                      pr_nrdolote craplap.nrdolote%TYPE,
                      pr_nrdconta craplap.nrdconta%TYPE,
                      pr_nraplica craplap.nraplica%TYPE) IS
      SELECT txaplica,
             txaplmes
        FROM craplap
       WHERE craplap.cdcooper = pr_cdcooper
         AND craplap.dtmvtolt = pr_dtmvtolt
         AND craplap.cdagenci = pr_cdagenci
         AND craplap.cdbccxlt = pr_cdbccxlt
         AND craplap.nrdolote = pr_nrdolote
         AND craplap.nrdconta = pr_nrdconta
         AND craplap.nraplica = pr_nraplica
       ORDER BY cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto;
    rw_craplap cr_craplap%ROWTYPE;

    -- Cursor sobre o cadastro dos lancamentos de resgates solicitados.
    CURSOR cr_craplrg(pr_nraplica craplrg.nraplica%TYPE,
                      pr_dtmvtolt craplrg.dtmvtolt%TYPE) IS
      SELECT 1
        FROM craplrg
       WHERE craplrg.cdcooper  = pr_cdcooper
         AND craplrg.nrdconta  = pr_nrdconta
         AND craplrg.nraplica  = pr_nraplica
         AND craplrg.dtresgat >= pr_dtmvtolt
         AND craplrg.dtmvtolt  = pr_dtmvtolt;
    rw_craplrg cr_craplrg%ROWTYPE;

    -- Cursor sobre o cadastro dos lancamentos de resgates solicitados.
    CURSOR cr_craplrg_2(pr_tpaplica craplrg.tpaplica%TYPE,
                        pr_nraplica craplrg.nraplica%TYPE,
                        pr_dtmvtolt craplrg.dtmvtolt%TYPE) IS
      SELECT 'SIM',
             dtresgat
        FROM craplrg
       WHERE craplrg.cdcooper = pr_cdcooper
         AND craplrg.nrdconta = pr_nrdconta
         AND craplrg.tpaplica = pr_tpaplica
         AND craplrg.nraplica = pr_nraplica
         AND (craplrg.inresgat = 0
          OR  craplrg.dtmvtolt = pr_dtmvtolt)
         AND craplrg.inresgat IN (0, 1)
        ORDER BY progress_recid DESC;

    -- Cursor sobre a descricao dos varios tipos de captacao oferecidas para o cooperado.
    CURSOR cr_crapdtc_2(pr_tpaplica crapdtc.tpaplica%TYPE) IS
      SELECT dsaplica
        FROM crapdtc
       WHERE crapdtc.cdcooper = pr_cdcooper
         AND crapdtc.tpaplica = pr_tpaplica
         AND crapdtc.tpaplrdc = 3;
    rw_crapdtc_2 cr_crapdtc_2%ROWTYPE;

    -- Cursor sobre as capas de lote
    CURSOR cr_craplot(pr_dtmvtolt craplot.dtmvtolt%TYPE,
                      pr_cdagenci craplot.cdagenci%TYPE,
                      pr_cdbccxlt craplot.cdbccxlt%TYPE,
                      pr_nrdolote craplot.nrdolote%TYPE) IS
      SELECT cdoperad
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = pr_cdagenci
         AND craplot.cdbccxlt = pr_cdbccxlt
         AND craplot.nrdolote = pr_nrdolote;
    rw_craplot cr_craplot%ROWTYPE;

		-- Cursor para se a aplicação está disponivel para saque
		CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
										 ,pr_nmsistem IN craptab.nmsistem%TYPE
										 ,pr_tptabela IN craptab.tptabela%TYPE
										 ,pr_cdempres IN craptab.cdempres%TYPE
										 ,pr_cdacesso IN craptab.cdacesso%TYPE
										 ,pr_dstextab IN craptab.dstextab%TYPE) IS
			SELECT tab.dstextab
				FROM craptab tab
			 WHERE tab.cdcooper = pr_cdcooper
				 AND UPPER(tab.nmsistem) = UPPER(pr_nmsistem)
				 AND UPPER(tab.tptabela) = UPPER(pr_tptabela)
				 AND tab.cdempres        = pr_cdempres
				 AND UPPER(tab.cdacesso) = UPPER(pr_cdacesso)
				 AND SUBSTR(tab.dstextab,1,7) = pr_dstextab;
			--rw_craptab cr_craptab%ROWTYPE;  


    -- Definicao do tipo para a tabela de datas
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- Variaveis gerais
    vr_dtinitax DATE;
    vr_dtfimtax DATE;
    vr_txaplmax VARCHAR2(20) := '0';
    vr_txaplmin VARCHAR2(20) := '0';
    vr_vlsdrdca NUMBER := 0;
    vr_dup_vlsdrdca NUMBER :=0;
    vr_vlsldapl NUMBER;
    vr_vldperda NUMBER;
    vr_txaplica NUMBER;
    vr_sldpresg NUMBER;
    vr_vlrdirrf NUMBER;
    vr_perirrgt NUMBER;
    vr_vlrentot NUMBER;
    vr_vlrenrgt NUMBER;
    vr_vlrrgtot NUMBER;
    vr_vlirftot NUMBER;
    vr_vlrendmm NUMBER;
    vr_vlrvtfim NUMBER;
    vr_sldresga NUMBER;
    vr_indebcre VARCHAR2(01);
    vr_cddresga VARCHAR2(03);
    vr_dtresgat DATE;
    vr_dshistor VARCHAR2(50);
    vr_dsaplica VARCHAR2(50);
    vr_cdoperad craprda.cdoperad%TYPE;
    vr_ind      PLS_INTEGER;
    vr_tab_craptab APLI0001.typ_tab_ctablq;
    vr_qtdiauti PLS_INTEGER;
    vr_dtmvtolt DATE;
    vr_dtmvtopr DATE;
    vr_dtmvtocd DATE;
    vr_dstextab craptab.dstextab%TYPE;
	--
	vr_idbloqueia BOOLEAN;
	--
  BEGIN
    -- Inicializa as variaveis
    vr_dscritic := NULL;
    vr_cdcritic := 0;
    vr_ind      := 0;

    -- Leitura do calendário da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE BTCH0001.cr_crapdat;
      -- Chamar rotina de gravacao de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 1 --> Critica 1-Sistema sem data de movimento.
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Somente par a CUSAPL
    IF pr_cdprogra = 'CUSAPL' THEN      
      
      -- Usar das datas enviadas
      vr_dtmvtolt := pr_dtinicio;
      vr_dtmvtopr := pr_dtfim;
      vr_dtmvtocd := pr_dtinicio;
      -- Sobescrever também no rw, pois ele é passado adiante   
      rw_crapdat.dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                         pr_dtmvtolt  => vr_dtmvtolt-1,
                                                         pr_tipo      => 'A',
                                                         pr_feriado   => true,  -- valor padrao
                                                         pr_excultdia => true); -- considera dia 31/12 como util
      rw_crapdat.dtmvtolt := vr_dtmvtolt;
      rw_crapdat.dtmvtocd := vr_dtmvtolt;
      rw_crapdat.dtmvtopr := vr_dtmvtopr;
    ELSE
      -- Usar do calendário normal
      vr_dtmvtolt := rw_crapdat.dtmvtolt;
      vr_dtmvtopr := rw_crapdat.dtmvtopr;
      vr_dtmvtocd := rw_crapdat.dtmvtocd;    
    END IF;
    

    -- Data de fim e inicio da utilizacao da taxa de poupanca.
    -- Utiliza-se essa data quando o rendimento da aplicacao for menor que
    --  a poupanca, a cooperativa opta por usar ou nao.
    -- Buscar a descricao das faixas contido na craptab
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                   ,pr_nmsistem => 'CRED'
                   ,pr_tptabela => 'USUARI'
                   ,pr_cdempres => 11
                   ,pr_cdacesso => 'MXRENDIPOS'
                   ,pr_tpregist => 1);
    
    -- Se não encontrar
    IF TRIM(vr_dstextab) IS NULL THEN
      -- Utilizar datas padrão
      vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
      vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
    ELSE
      -- Utilizar datas da tabela
      vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1,vr_dstextab,';'),'DD/MM/YYYY');
      vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2,vr_dstextab,';'),'DD/MM/YYYY');
    END IF;

    -- Popula a temp-table com as aplicacoes bloqueadas
    TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_tab_cta_bloq => vr_tab_craptab);

    FOR rw_craprda IN cr_craprda LOOP
      IF UPPER(pr_cdprogra) NOT IN ('EXTRDA','IMPRES','ADITIV','CUSAPL') AND rw_craprda.insaqtot <> 0 THEN
        continue; -- Vai para o proximo registro
      END IF;

      -- Inicializa o conteudo do registro rw_crapdtc
      rw_crapdtc := NULL;

      IF (UPPER(pr_cdprogra) = 'IMPRES' OR 
          UPPER(pr_cdprogra) = 'INTERNETBANK') AND
         pr_dtinicio IS NOT NULL AND
         pr_dtfim    IS NOT NULL THEN
        -- Busca sobre o cadastro dos lancamentos de aplicacoes RDCA.
        OPEN cr_craplap_2(rw_craprda.nraplica);
        FETCH cr_craplap_2 INTO rw_craplap_2;

        IF cr_craplap_2%NOTFOUND THEN -- Se nao encontrou registro
          CLOSE cr_craplap_2;
          continue; -- Vai para o proximo registro
        END IF;
        CLOSE cr_craplap_2;
      END IF;

      /** Inicializar variaveis para retornar taxa somente para RDCPOS **/
      vr_txaplmax := '';
      vr_txaplmin := '';

      IF rw_craprda.tpaplica = 3  AND  -- RDCA30
         pr_tpaplica IN (0,1) THEN  /** RDCA **/
        -- Consulta saldo aplicacao RDCA30
        APLI0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper,     --> Cooperativa
                                              pr_cdoperad     => pr_cdoperad,         --> Operador
                                              pr_dtmvtolt     => vr_dtmvtolt, --> Data do processo
                                              pr_inproces     => rw_crapdat.inproces, --> Indicador do processo
                                              pr_dtmvtopr     => vr_dtmvtopr, --> Proximo dia util
                                              pr_cdprogra     => UPPER(pr_cdprogra),  --> Programa em execucao
                                              pr_cdagenci     => pr_cdagenci,         --> Codigo da agencia
                                              pr_nrdcaixa     => pr_nrdcaixa,         --> Numero do caixa
                                              pr_nrdconta     => pr_nrdconta,         --> Nro da conta da aplicacao RDCA
                                              pr_nraplica     => rw_craprda.nraplica, --> Nro da aplicacao RDCA
                                              pr_vlsdrdca     => vr_vlsdrdca,         --> Saldo da aplicacao
                                              pr_dup_vlsdrdca => vr_dup_vlsdrdca,     --> Acumulo do saldo da aplicacao RDCA
                                              pr_vlsldapl => vr_vlsldapl,             --> Saldo da aplicacao RDCA
                                              pr_sldpresg => vr_sldpresg,             --> Saldo para resgate
                                              pr_vldperda => vr_vldperda,             --> Valor calculado da perda
                                              pr_txaplica => vr_txaplica,             --> Taxa aplicada sob o emprestimo
                                              pr_des_reto => pr_des_reto,             --> OK ou NOK
                                              pr_tab_erro => pr_tab_erro);            --> Tabela com erros

        IF pr_des_reto = 'NOK' THEN
          RAISE vr_exc_erro;
        END IF;
      ELSIF rw_craprda.tpaplica = 5  AND -- RDCA60
            pr_tpaplica IN (0, 1) THEN /** RDCA **/
        -- Consulta saldo aplicacao RDCA60
        pc_consul_saldo_aplic_rdca60(pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => vr_dtmvtolt,
                                     pr_dtmvtopr => vr_dtmvtopr,
                                     pr_cdprogra => UPPER(pr_cdprogra),
                                     pr_cdagenci => pr_cdagenci,
                                     pr_nrdcaixa => pr_nrdcaixa,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_nraplica => rw_craprda.nraplica,
                                     pr_vlsdrdca => vr_vlsdrdca,  --> Saida
                                     pr_sldpresg => vr_sldpresg,  --> Saida
                                     pr_des_reto => pr_des_reto,  --> Saida
                                     pr_tab_erro => pr_tab_erro); --> Saida
        IF pr_des_reto = 'NOK' THEN
          RAISE vr_exc_erro;
        END IF;
      ELSIF pr_tpaplica IN (0, 2)THEN  /** RDC **/
        -- Busca a descricao dos varios tipos de captacao oferecidas para o cooperado.
        OPEN cr_crapdtc(rw_craprda.tpaplica);
        FETCH cr_crapdtc INTO rw_crapdtc;

        IF cr_crapdtc%NOTFOUND THEN -- Se nao encontrou registro
          CLOSE cr_crapdtc;
          continue; -- Vai para o proximo registro
        END IF;
        CLOSE cr_crapdtc;
        IF UPPER(pr_cdprogra) = 'CRPS688' THEN
          vr_dtmvtolt := vr_dtmvtocd;
        END IF;

        IF rw_crapdtc.tpaplrdc = 1  THEN
          -- Rotina de calculo do saldo das aplicacoes RDC PRE para resgate
          pc_saldo_rdc_pre(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta,
                           pr_nraplica => rw_craprda.nraplica,
                           pr_dtmvtolt => vr_dtmvtolt,
                           pr_dtiniper => NULL,
                           pr_dtfimper => NULL,
                           pr_txaplica => 0,
                           pr_flggrvir => FALSE,
                           pr_tab_crapdat => rw_crapdat,
                           pr_cdprogra    => pr_cdprogra,   --> Programa chamador
                           pr_vlsdrdca => vr_vlsdrdca,      --> Saida
                           pr_vlrdirrf => vr_vlrdirrf,      --> Saida
                           pr_perirrgt => vr_perirrgt,      --> Saida
                           pr_des_reto => pr_des_reto,      --> Saida
                           pr_tab_erro => pr_tab_erro);     --> Saida
          IF pr_des_reto = 'NOK' THEN
            RAISE vr_exc_erro;
          END IF;
          vr_sldpresg := rw_craprda.vlsdrdca;

        ELSIF rw_crapdtc.tpaplrdc = 2 THEN
          -- Rotina de calculo do saldo das aplicacoes RDC POS
          pc_saldo_rdc_pos(pr_cdcooper => pr_cdcooper,         --> Cooperativa
                           pr_dtmvtolt => vr_dtmvtolt, --> Movimento atual
                           pr_dtmvtopr => vr_dtmvtopr, --> Proximo dia util
                           pr_nrdconta => pr_nrdconta,         --> Nro da conta da aplicacao RDC
                           pr_nraplica => rw_craprda.nraplica, --> Nro da aplicacao RDC
                           pr_dtmvtpap => vr_dtmvtolt,         --> Data do movimento atual passado
                           pr_dtcalsld => vr_dtmvtolt,         --> Data do movimento atual passado
                           pr_flantven => FALSE,               --> Flag antecede vencimento
                           pr_flggrvir => FALSE,               --> Identificador se deve gravar valor insento
                           pr_dtinitax => vr_dtinitax,         --> Data de inicio da utilizacao da taxa de poupanca.
                           pr_dtfimtax => vr_dtfimtax,         --> Data de fim da utilizacao da taxa de poupanca.
                           pr_cdprogra => pr_cdprogra,         --> Programa chamador
                           pr_vlsdrdca => vr_vlsdrdca,         --> Saldo da aplicacao pos calculo
                           pr_vlrentot => vr_vlrentot,         --> Saldo da aplicacao pos calculo
                           pr_vlrdirrf => vr_vlrdirrf,         --> Valor de IR
                           pr_perirrgt => vr_perirrgt,         --> Percentual de IR resgatado
                           pr_des_reto => pr_des_reto,         --> OK ou NOK
                           pr_tab_erro => pr_tab_erro);        --> Tabela com erros
          IF pr_des_reto = 'NOK' THEN
            RAISE vr_exc_erro;
          END IF;

          -- Rotina de calculo do saldo das aplicacoes RDC POS para resgate com IRPF.
          APLI0001.pc_saldo_rgt_rdc_pos(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                       ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                                       ,pr_nrdcaixa => pr_nrdcaixa         --> Numero do caixa
                                       ,pr_nrctaapl => pr_nrdconta         --> Nro da conta da aplicacao RDC
                                       ,pr_nraplres => rw_craprda.nraplica --> Nro da aplicacao RDC
                                       ,pr_dtmvtolt => vr_dtmvtolt         --> Data do movimento atual passado
                                       ,pr_dtaplrgt => vr_dtmvtolt         --> Data do movimento atual passado
                                       ,pr_vlsdorgt => 0                   --> Valor RDC
                                       ,pr_flggrvir => FALSE               --> Identificador se deve gravar valor insento
                                       ,pr_dtinitax => vr_dtinitax         --> Data Inicial da Utilizacao da taxa da poupanca
                                       ,pr_dtfimtax => vr_dtfimtax         --> Data Final da Utilizacao da taxa da poupanca
                                       ,pr_vlsddrgt => vr_sldpresg         --> Valor do resgate total sem irrf ou o solicitado
                                       ,pr_vlrenrgt => vr_vlrenrgt         --> Rendimento total a ser pago quando resgate total
                                       ,pr_vlrdirrf => vr_vlrdirrf         --> IRRF do que foi solicitado
                                       ,pr_perirrgt => vr_perirrgt         --> Percentual de aliquota para calculo do IRRF
                                       ,pr_vlrgttot => vr_vlrrgtot         --> Resgate para zerar a aplicacao
                                       ,pr_vlirftot => vr_vlirftot         --> IRRF para finalizar a aplicacao
                                       ,pr_vlrendmm => vr_vlrendmm         --> Rendimento da ultima provisao ate a data do resgate
                                       ,pr_vlrvtfim => vr_vlrvtfim         --> Quantia provisao reverter para zerar a aplicacao
                                       ,pr_des_reto => pr_des_reto         --> OK ou NOK
                                       ,pr_tab_erro => pr_tab_erro);       --> Tabela com erros
          IF pr_des_reto = 'NOK' THEN
            RAISE vr_exc_erro;
          END IF;

          IF vr_vlrrgtot > 0 THEN
            vr_sldpresg := vr_vlrrgtot;
          ELSE
            vr_sldpresg := rw_craprda.vlsdrdca;
          END IF;

          /** Procurar taxas da aplicacao **/
          OPEN cr_craplap(rw_craprda.dtmvtolt,
                          rw_craprda.cdagenci,
                          rw_craprda.cdbccxlt,
                          rw_craprda.nrdolote,
                          pr_nrdconta,
                          rw_craprda.nraplica);
          FETCH cr_craplap INTO rw_craplap;

          IF cr_craplap%NOTFOUND THEN
            CLOSE cr_craplap;
            -- Chamar rotina de gravacao de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 --> Fixo
                                 ,pr_cdcritic => 90 --> Critica 90 - Lancamento inexistente
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
            RAISE vr_exc_erro;
          END IF;
          CLOSE cr_craplap;

          vr_txaplmax := lpad(to_char(NVL(rw_craplap.txaplica, '0'), 'fm990D000000'), 10, ' ');
          vr_txaplmin := lpad(to_char(NVL(rw_craplap.txaplmes, '0'), 'fm990D000000'), 10, ' ');
        END IF;
      ELSIF UPPER(pr_cdprogra) <> 'EXTRDA' THEN
        continue;
      END IF;

      IF UPPER(pr_cdprogra) NOT IN ('EXTRDA', 'IMPRES', 'ADITIV','CUSAPL') AND
          ((vr_vlsdrdca <= 0 AND rw_craprda.tpaplica = 5) OR -- RDCA60
           (vr_vlsdrdca <= 0 AND rw_craprda.tpaplica = 3) OR     -- RDCA30
           (vr_vlsdrdca <= 0 AND rw_craprda.tpaplica <> 3 AND
            rw_craprda.tpaplica <> 5))                     THEN
         CONTINUE;
      END IF;                


      IF UPPER(pr_cdprogra) NOT IN ('EXTRDA', 'IMPRES', 'ADITIV','CUSAPL') AND
         (vr_vlsdrdca <= 0 AND rw_craprda.tpaplica = 3)    THEN --RDCA30

        /** Nao foi resgatado no dia **/
        OPEN cr_craplrg(rw_craprda.nraplica, vr_dtmvtolt);
        FETCH cr_craplrg INTO rw_craplrg;

        IF cr_craplrg%NOTFOUND THEN -- Se nao encontrou registro
          CLOSE cr_craplrg;
          continue; -- Vai para a proxima aplicacao
        ELSE
          CLOSE cr_craplrg;
        END IF;

      END IF;

      vr_sldresga := vr_sldpresg;

      -- Vefificar se a situacao da aplicacao esta bloqueada
      -- Indice composto por "Numero da conta com 12" + "Numero da aplicacao com 8"
      IF vr_tab_craptab.exists(LPAD(pr_nrdconta,12,'0') || LPAD(rw_craprda.nraplica, 8,'0')) THEN
				-- SM404
				vr_idbloqueia := TRUE;
				--
				IF pr_nrorigem = 5 AND
					upper(pr_cdprogra) = 'RESGATE' THEN -- Ayllos Web
					-- Verifica se a aplicacao esta Bloqueada
					OPEN cr_craptab(pr_cdcooper => pr_cdcooper
												 ,pr_nmsistem => 'CRED'
												 ,pr_tptabela => 'BLQRGT'
												 ,pr_cdempres => 0
												 ,pr_cdacesso => gene0002.fn_mask(to_char(pr_nrdconta),'9999999999')
												 ,pr_dstextab => gene0002.fn_mask(to_char(rw_craprda.nraplica), '9999999')
												 );
				  --
					FETCH cr_craptab INTO vr_dstextab;
					--
					IF cr_craptab%FOUND THEN
						--
						vr_idbloqueia := FALSE;
						--
					END IF;
					--
					CLOSE cr_craptab;
					--
				END IF;
				--
				IF vr_idbloqueia THEN
					--
        vr_indebcre := 'B';  -- Bloqueada
					--
				END IF;
				--
      ELSE
        IF rw_craprda.tpaplica = 3 THEN -- RDCA30
          IF rw_craprda.inaniver = 1 OR -- Completou 1 mes
            (rw_craprda.inaniver  = 0 AND -- Nao completou 1 mes
             rw_craprda.dtfimper <= vr_dtmvtolt) THEN
            vr_indebcre := 'D';  -- Disponivel
          ELSE
            vr_indebcre := ' ';
          END IF;
        ELSIF rw_craprda.tpaplica = 5 THEN -- RDCA60
          IF  rw_craprda.inaniver  = 1                      OR -- Completou 60 dias
            ((rw_craprda.dtfimper <= vr_dtmvtolt)      AND
             (rw_craprda.dtfimper -  rw_craprda.dtmvtolt) > 50) THEN
            vr_indebcre := 'D';
          ELSE
            vr_indebcre := ' ';
          END IF;
        ELSE
          vr_indebcre := ' ';
        END IF;
      END IF;

      vr_cddresga := 'NAO';
      vr_dtresgat := NULL;

      -- busca o cadastro dos lancamentos de resgates solicitados.
      OPEN cr_craplrg_2(rw_craprda.tpaplica, rw_craprda.nraplica, vr_dtmvtolt);
      FETCH cr_craplrg_2 INTO vr_cddresga, vr_dtresgat;
      CLOSE cr_craplrg_2;

      -- Variavel com valor default de dias de aplicacao
      vr_qtdiauti := rw_craprda.qtdiauti;
      
      IF pr_nrorigem IN (1,5,3) THEN  /** Ayllos e InternetBank**/
        IF UPPER(pr_cdprogra) = 'ATENDA' OR 
           UPPER(pr_cdprogra) = 'IMPRES' OR 
           UPPER(pr_cdprogra) = 'INTERNETBANK'  THEN
          -- Verifica tipo aplicacao
          IF rw_craprda.tpaplica IN (3,5,8) THEN
            -- Quantidade de dias uteis da aplicacao 
            vr_qtdiauti := rw_craprda.qtdiauti;
          ELSE
            -- Se for RDCPRE alimenta os dias corridos da aplicacao
            vr_qtdiauti := rw_craprda.qtdiaapl;
          END IF;
        END IF;
        IF rw_craprda.tpaplica = 3  THEN -- RDCA30
          vr_dshistor := 'RDCA   ';
          vr_dsaplica := vr_dshistor;
        ELSIF rw_craprda.tpaplica = 5 THEN -- RDCA60
          vr_dshistor := 'RDCA60 ';
          vr_dsaplica := vr_dshistor;
        ELSIF rw_crapdtc.tpaplrdc = 2  THEN /** RDCPOS **/
          vr_dshistor := 'RDC' || to_char(rw_craprda.qtdiauti,'fm0000');
          vr_dsaplica := rw_crapdtc.dsaplica;

          /* P.285 - Card #367 */

          IF UPPER(pr_cdprogra) = 'ATENDA' OR pr_nrorigem = 3 THEN
            -- Abre o cursor que contem a descricao dos varios tipos de captacao oferecidas para o cooperado.
            OPEN cr_crapdtc_2(rw_craprda.tpnomapl);
            FETCH cr_crapdtc_2 
            INTO rw_crapdtc_2;

            IF cr_crapdtc_2%FOUND THEN
              IF UPPER(pr_cdprogra) = 'ATENDA' THEN
              vr_dshistor := rw_crapdtc_2.dsaplica;
              ELSE
                vr_dshistor := rw_crapdtc_2.dsaplica || ' - ' || vr_dshistor;
              END IF;
            END IF;
  
            CLOSE cr_crapdtc_2;
          END IF;
          
          /** P.285 - Card #367 **/

        ELSE
          vr_dshistor := rpad(substr(rw_crapdtc.dsaplica,1,7),7,' ');
          vr_dsaplica := substr(rw_crapdtc.dsaplica,1,6);
        END IF;

      ELSE
        IF rw_craprda.tpaplica = 3  THEN -- RDCA30
          vr_dshistor := 'Apl. RDCA  :';
          vr_dsaplica := 'RDCA';
        ELSIF rw_craprda.tpaplica = 5  THEN -- RDCA60
          vr_dshistor := 'Apl. RDCA60:';
          vr_dsaplica := 'RDCA60';
        ELSIF rw_crapdtc.dsaplica = 'RDCPOS' THEN
          vr_dsaplica := rw_crapdtc.dsaplica;
          vr_dshistor := 'Apl. ' || substr(rw_crapdtc.dsaplica,1,6) || ':';
        ELSE
          vr_dshistor := 'Apl. ' || substr(rw_crapdtc.dsaplica,1,6) || ':';
          vr_dsaplica := substr(rw_crapdtc.dsaplica,1,6);
        END IF;

      END IF;

      IF trim(rw_craprda.cdoperad) IS NULL THEN
        -- Busca as capas de lote
        OPEN cr_craplot(rw_craprda.dtmvtolt,
                        rw_craprda.cdagenci,
                        rw_craprda.cdbccxlt,
                        rw_craprda.nrdolote);
        FETCH cr_craplot INTO rw_craplot;
        IF cr_craplot%FOUND THEN
          vr_cdoperad := trim(rw_craplot.cdoperad);
        ELSE
          vr_cdoperad := '';
        END IF;
        CLOSE cr_craplot;
      ELSE
         vr_cdoperad := rw_craprda.cdoperad;
      END IF;

      vr_ind := vr_ind + 1;

      pr_saldo_rdca(vr_ind).idtipapl := 'A';
      pr_saldo_rdca(vr_ind).idtippro := rw_crapdtc.tpaplrdc;
      -- Insere a aplicacao na temp-table de retorno
      pr_saldo_rdca(vr_ind).dtmvtolt := rw_craprda.dtmvtolt;
      pr_saldo_rdca(vr_ind).nraplica := rw_craprda.nraplica;
      pr_saldo_rdca(vr_ind).qtdiaapl := rw_craprda.qtdiaapl;
      --pr_saldo_rdca(vr_ind).qtdiauti := rw_craprda.qtdiauti;
      pr_saldo_rdca(vr_ind).qtdiauti := vr_qtdiauti;
      pr_saldo_rdca(vr_ind).vlaplica := rw_craprda.vlaplica;
      pr_saldo_rdca(vr_ind).dsaplica := vr_dsaplica;
      pr_saldo_rdca(vr_ind).cdoperad := vr_cdoperad;
      pr_saldo_rdca(vr_ind).dshistor := vr_dshistor;
      pr_saldo_rdca(vr_ind).dtvencto := rw_craprda.dtvencto;
      pr_saldo_rdca(vr_ind).dtcarenc := rw_craprda.dtiniper + vr_qtdiauti; 

      -- Define a mascara do numedo do documento
      IF pr_nrorigem = 1 THEN /** Ayllos **/
        pr_saldo_rdca(vr_ind).nrdocmto := lpad(to_char(rw_craprda.nraplica,'fm999990'),6,' ');
      ELSE
        pr_saldo_rdca(vr_ind).nrdocmto := lpad(to_char(rw_craprda.nraplica,'fm999G990'),7,' ');
      END IF;

      -- Define a situacao da aplicacao
      IF vr_indebcre = 'D'  THEN
        pr_saldo_rdca(vr_ind).dssitapl := 'DISPONIVEL';
      ELSIF vr_indebcre = 'B' THEN
        pr_saldo_rdca(vr_ind).dssitapl := 'BLOQUEADA';
      ELSE
        pr_saldo_rdca(vr_ind).dssitapl := ' ';
      END IF;

      pr_saldo_rdca(vr_ind).vllanmto := vr_vlsdrdca;

      IF rw_craprda.tpaplica = 3 THEN -- RDCA30
        pr_saldo_rdca(vr_ind).vlsdrdad := vr_dup_vlsdrdca;
      ELSE
        pr_saldo_rdca(vr_ind).vlsdrdad := vr_vlsdrdca;
      END IF;

      pr_saldo_rdca(vr_ind).sldresga := nvl(vr_sldresga,0);
      pr_saldo_rdca(vr_ind).cddresga := vr_cddresga;
      pr_saldo_rdca(vr_ind).dtresgat := vr_dtresgat;
      pr_saldo_rdca(vr_ind).txaplmax := vr_txaplmax;
      pr_saldo_rdca(vr_ind).txaplmin := vr_txaplmin;
      pr_saldo_rdca(vr_ind).tpaplica := rw_craprda.tpaplica;

      pr_saldo_rdca(vr_ind).tpaplrdc := nvl(rw_crapdtc.tpaplrdc,0);

      IF rw_crapdtc.existe IS NULL THEN
        pr_saldo_rdca(vr_ind).qtdiacar := 0;
      ELSE
        pr_saldo_rdca(vr_ind).qtdiacar := vr_qtdiauti;
      END IF;

      IF UPPER(pr_cdprogra) = 'EXTRDA' THEN
        IF  vr_indebcre = 'D' AND
           (pr_saldo_rdca(vr_ind).vllanmto <> 0 OR
            pr_saldo_rdca(vr_ind).vlsdrdad <> 0) THEN
          pr_saldo_rdca(vr_ind).indebcre := '*Disp.*';
        ELSE
          pr_saldo_rdca(vr_ind).indebcre := '';
        END IF;
      ELSE
        pr_saldo_rdca(vr_ind).indebcre := vr_indebcre;
      END IF;

    END LOOP; /*** Fim do LOOP craprda ***/

    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Gerar erro montado
      vr_dscritic := 'APLI0001.pc_consulta_aplicacoes --> Erro não tratado na rotina: '||sqlerrm;
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 999
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0 --> Critica 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

  END pc_consulta_aplicacoes;

  /* Efetua uma consulta sobre as aplicacoes do cooperado passado como parametro
     Possui a mesma funcionalidade da rotina acima, porem utiliza gravacao em tabelas para serem
     chamadas diretamente atraves de rotinas progress */
  PROCEDURE pc_consulta_aplicacoes_wt(pr_cdcooper    IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                      pr_cdagenci    IN crapass.cdagenci%TYPE,     --> Codigo da agencia
                                      pr_nrdcaixa    IN craperr.nrdcaixa%TYPE,     --> Numero do caixa
                                      pr_nrdconta    IN crapass.nrdconta%TYPE,     --> Conta do associado
                                      pr_nraplica    IN craprda.nraplica%TYPE,     --> Numero da aplicacao
                                      pr_tpaplica    IN PLS_INTEGER,               --> Tipo de aplicacao
                                      pr_dtinicio    IN DATE,                      --> Data de inicio da aplicacao
                                      pr_dtfim       IN DATE,                      --> Data final da aplicacao
                                      pr_cdprogra    IN crapprg.cdprogra%TYPE,     --> Codigo do programa chamador da rotina
                                      pr_nrorigem    IN PLS_INTEGER,               --> Origem da chamada da rotina
                                      pr_cdcritic   OUT crapcri.cdcritic%type,     --> Codigo de Erro
                                      pr_dscritic   OUT VARCHAR2) IS               --> Descricao de Erro
    vr_des_reto VARCHAR2(03);           --> OK ou NOK
    vr_tab_erro GENE0001.typ_tab_erro;  --> Tabela com erros
    vr_saldo_rdca  typ_tab_saldo_rdca;  --> Tabela de retorno da rotina
    vr_ind PLS_INTEGER;                 --> Indice da tabela de retorno
  BEGIN
    -- Limpa a tabela temporaria de interface
    BEGIN
      DELETE wt_saldo_rdca;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao excluir wt_saldo_rdca: '||SQLERRM;
        RETURN;
    END;

    -- Executa a rotina original
    pc_consulta_aplicacoes(pr_cdcooper   => pr_cdcooper,    --> Cooperativa
                           pr_cdagenci   => pr_cdagenci,    --> Codigo da agencia
                           pr_nrdcaixa   => pr_nrdcaixa,    --> Numero do caixa
                           pr_nrdconta   => pr_nrdconta,    --> Conta do associado
                           pr_nraplica   => pr_nraplica,    --> Numero da aplicacao
                           pr_tpaplica   => pr_tpaplica,    --> Tipo de aplicacao
                           pr_dtinicio   => pr_dtinicio,    --> Data de inicio da aplicacao
                           pr_dtfim      => pr_dtfim,       --> Data final da aplicacao
                           pr_cdprogra   => pr_cdprogra,    --> Codigo do programa chamador da rotina
                           pr_nrorigem   => pr_nrorigem,    --> Origem da chamada da rotina
                           pr_saldo_rdca => vr_saldo_rdca,  --> Tipo de tabela com o saldo RDCA
                           pr_des_reto   => vr_des_reto,    --> OK ou NOK
                           pr_tab_erro   => vr_tab_erro);   --> Tabela com erros

    -- Verifica se deu erro
    IF vr_des_reto = 'NOK' THEN
      pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      RETURN;
    ELSE -- Se nao ocorreu erro, percorre a tabela de retorno e efetua o insert na tabela de interface
      vr_ind := vr_saldo_rdca.first; -- Vai para o primeiro registro

      -- loop sobre a tabela de retorno
      WHILE vr_ind IS NOT NULL LOOP
        -- Insere na tabela de interface
        BEGIN
          INSERT INTO wt_saldo_rdca
            (dtmvtolt,
             nraplica,
             qtdiaapl,
             qtdiauti,
             vlaplica,
             dsaplica,
             cdoperad,
             dshistor,
             nrdocmto,
             dtvencto,
             dssitapl,
             vllanmto,
             vlsdrdad,
             sldresga,
             cddresga,
             dtresgat,
             txaplmax,
             txaplmin,
             tpaplica,
             tpaplrdc,
             qtdiacar,
             indebcre)
           VALUES
            (vr_saldo_rdca(vr_ind).dtmvtolt,
             vr_saldo_rdca(vr_ind).nraplica,
             vr_saldo_rdca(vr_ind).qtdiaapl,
             vr_saldo_rdca(vr_ind).qtdiauti,
             vr_saldo_rdca(vr_ind).vlaplica,
             vr_saldo_rdca(vr_ind).dsaplica,
             vr_saldo_rdca(vr_ind).cdoperad,
             vr_saldo_rdca(vr_ind).dshistor,
             vr_saldo_rdca(vr_ind).nrdocmto,
             vr_saldo_rdca(vr_ind).dtvencto,
             vr_saldo_rdca(vr_ind).dssitapl,
             vr_saldo_rdca(vr_ind).vllanmto,
             vr_saldo_rdca(vr_ind).vlsdrdad,
             vr_saldo_rdca(vr_ind).sldresga,
             vr_saldo_rdca(vr_ind).cddresga,
             vr_saldo_rdca(vr_ind).dtresgat,
             vr_saldo_rdca(vr_ind).txaplmax,
             vr_saldo_rdca(vr_ind).txaplmin,
             vr_saldo_rdca(vr_ind).tpaplica,
             vr_saldo_rdca(vr_ind).tpaplrdc,
             vr_saldo_rdca(vr_ind).qtdiacar,
             vr_saldo_rdca(vr_ind).indebcre);
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao inserir na tabela wt_saldo_rdca: '||SQLERRM;
            RETURN;
        END;

        -- Vai para o proximo registro
        vr_ind := vr_saldo_rdca.next(vr_ind);

      END LOOP;
    END IF;
  END;

  PROCEDURE pc_insere_tab_wrk(pr_cdcooper     in tbgen_batch_relatorio_wrk.cdcooper%type 
                             ,pr_nrdconta     in tbgen_batch_relatorio_wrk.nrdconta%type
                             ,pr_cdprogra     in tbgen_batch_relatorio_wrk.cdprograma%type
                             ,pr_dsrelatorio  in tbgen_batch_relatorio_wrk.dsrelatorio%type
                             ,pr_dtmvtolt     in tbgen_batch_relatorio_wrk.dtmvtolt%type
                             ,pr_dschave      in tbgen_batch_relatorio_wrk.dschave%type
                             ,pr_dsinformacao in tbgen_batch_relatorio_wrk.dscritic%type
                             ,pr_dscritic    out varchar2) IS
    
  BEGIN
    
    begin
      insert into tbgen_batch_relatorio_wrk(cdcooper,
                                            cdprograma,
                                            dsrelatorio,
                                            dtmvtolt,
                                            dschave,
                                            nrdconta,
                                            dscritic)
                                     values(pr_cdcooper,
                                            pr_cdprogra,
                                            pr_dsrelatorio,
                                            pr_dtmvtolt,
                                            pr_dschave,
                                            pr_nrdconta,
                                            pr_dsinformacao);
    exception
      when others then
        pr_dscritic := 'Erro ao inserir tbgen_batch_relatorio_wrk: '||sqlerrm;            
    end;  
  
  END pc_insere_tab_wrk;

END APLI0001;
/
