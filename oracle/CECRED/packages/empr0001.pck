CREATE OR REPLACE PACKAGE CECRED.empr0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0001
  --  Sistema  : Rotinas gen�ricas focando nas funcionalidades de empr�stimos
  --  Sigla    : EMPR
  --  Autor    : Marcos Ernani Martini
  --  Data     : Fevereiro/2013.                   Ultima atualizacao: 26/09/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas gen�ricas dos sistemas Oracle
  --
  -- Altera��o : 03/06/2015 - Alterado tipo variavel vllamnto da temptable typ_reg_tab_lancconta
  --                          para trabalhar com mais decimais conforme no progress (Odirlei-AMcom)   
  --
  --             12/06/2015 - Adicao de campos para geracao do extrato da portabilidade de credito. 
  --                          (Jaison/Diego - SD: 290027)
  --
  --             17/12/2015 - Ajustado precis�o dos campos numericos SD375985 (Odirlei-AMcom)
  --
  --             11/05/2016 - Criacao do FIELD vlatraso na typ_reg_dados_epr. (Jaison/James)
  --
  --             26/09/2016 - Adicionado validacao de contratos de acordo na procedure
  --                          pc_valida_pagamentos_geral, Prj. 302 (Jean Michel).
  ---------------------------------------------------------------------------------------------------------------

  /* Tipo com as informacoes do registro de emprestimo. Antiga: tt-dados-epr */
  TYPE typ_reg_dados_epr IS RECORD(
     nrdconta crapepr.nrdconta%TYPE
    ,cdagenci crapass.cdagenci%TYPE
    ,nmprimtl crapass.nmprimtl%TYPE
    ,nrctremp crapepr.nrctremp%TYPE
    ,vlemprst NUMBER(14, 2)
    ,vlsdeved NUMBER(25, 10)
    ,vlpreemp NUMBER(14, 2)
    ,vlprepag NUMBER(14, 2)
    ,txjuremp NUMBER(12, 7)
    ,vljurmes NUMBER(12, 2)
    ,vljuracu NUMBER(12, 2)
    ,vlprejuz NUMBER(14, 2)
    ,vlsdprej NUMBER(14, 2)
    ,dtprejuz DATE
    ,vljrmprj NUMBER(12, 2)
    ,vljraprj NUMBER(12, 2)
    ,inprejuz crapepr.inprejuz%TYPE
    ,vlprovis NUMBER(12, 2)
    ,flgpagto NUMBER(1) -- Flag 0/1
    ,dtdpagto crapepr.dtdpagto%TYPE
    ,cdpesqui VARCHAR2(25)
    ,dspreapg VARCHAR2(30)
    ,cdlcremp crapepr.cdlcremp%TYPE
    ,dslcremp VARCHAR2(60)
    ,cdfinemp crapepr.cdfinemp%type
    ,dsfinemp VARCHAR2(60)
    ,dsdaval1 VARCHAR2(300)
    ,dsdaval2 VARCHAR2(300)
    ,vlpreapg NUMBER(25, 10)
    ,qtmesdec NUMBER(10)
    ,qtprecal NUMBER(14, 4)
    ,vlacresc NUMBER(12, 2)
    ,vlrpagos NUMBER(12, 2)
    ,slprjori NUMBER(14, 2)
    ,dtmvtolt DATE
    ,qtpreemp INTEGER
    ,dtultpag DATE
    ,vlrabono craplem.vllanmto%TYPE
    ,qtaditiv INTEGER
    ,dsdpagto VARCHAR2(300)
    ,dsdavali VARCHAR2(300)
    ,qtmesatr NUMBER(16, 8)
    ,qtpromis INTEGER
    ,flgimppr NUMBER(1) -- Flag 0/1
    ,flgimpnp NUMBER(1) -- Flag 0/1
    ,idseleca VARCHAR2(1)
    ,nrdrecid crapepr.progress_recid%TYPE
    ,tplcremp craplcr.tpctrato%TYPE
    ,tpemprst crapepr.tpemprst%TYPE
    ,cdtpempr VARCHAR2(500)
    ,dstpempr VARCHAR2(500)
    ,permulta NUMBER(5, 2)
    ,perjurmo craplcr.perjurmo%TYPE
    ,dtpripgt crawepr.dtdpagto%TYPE
    ,inliquid crapepr.inliquid%TYPE
    ,txmensal crapepr.txmensal%TYPE
    ,flgatras NUMBER(1) -- Flag 0/1
    ,dsidenti VARCHAR2(1)
    ,flgdigit crapepr.flgdigit%TYPE
    ,tpdocged PLS_INTEGER
    ,vlpapgat crapepr.vlpapgat%TYPE
    ,vlsdevat crapepr.vlsdevat%TYPE
    ,qtpcalat crapepr.qtpcalat%TYPE
    ,qtmdecat crapepr.qtmdecat%TYPE
    ,tpdescto crapepr.tpdescto%TYPE
    ,qtlemcal NUMBER
    ,vlppagat crapepr.vlppagat%TYPE
    ,vlmrapar NUMBER(14, 2)
    ,vlmtapar NUMBER(14, 2)
    ,vltotpag NUMBER(20, 8)
    ,vlprvenc NUMBER(14, 2)
    ,vlpraven NUMBER(14, 2)
    ,flgpreap BOOLEAN DEFAULT FALSE
    ,cdorigem crapepr.cdorigem%TYPE
    ,vlttmupr crapepr.vlttmupr%TYPE
    ,vlttjmpr crapepr.vlttjmpr%TYPE
    ,vlpgmupr crapepr.vlpgmupr%TYPE
    ,vlpgjmpr crapepr.vlpgjmpr%TYPE
    ,percetop crawepr.percetop%TYPE
    ,cdmodali gnmodal.cdmodali%TYPE
    ,dsmodali gnmodal.dsmodali%TYPE
    ,cdsubmod gnsbmod.cdsubmod%TYPE
    ,dssubmod gnsbmod.dssubmod%TYPE
    ,txanual  crawepr.txmensal%TYPE
    ,qtpreapg NUMBER
    ,liquidia INTEGER
    ,qtimpctr crapepr.qtimpctr%TYPE
    ,portabil VARCHAR2(100));

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_dados_epr IS TABLE OF typ_reg_dados_epr INDEX BY VARCHAR2(100);

  /* Tipo que compreende o registro da tab. tempor�ria tt-pagamentos-parcelas */
  TYPE typ_reg_pgto_parcel IS RECORD(
     cdcooper crapcop.cdcooper%TYPE
    ,nrdconta crapepr.nrdconta%TYPE
    ,nrctremp crapepr.nrctremp%TYPE
    ,nrparepr INTEGER
    ,vlparepr NUMBER(12, 2)
    ,vljinpar NUMBER(12, 2)
    ,vlmrapar NUMBER(12, 2)
    ,vlmtapar NUMBER(12, 2)
    ,vlmtzepr NUMBER(12, 2)
    ,dtvencto DATE
    ,dtultpag DATE
    ,vlpagpar NUMBER(12, 2)
    ,vlpagmta NUMBER(12, 2)
    ,vlpagmra NUMBER(12, 2)
    ,indpagto INTEGER
    ,txjuremp NUMBER(9, 2)
    ,vlatupar NUMBER(12, 2)
    ,vldespar NUMBER(12, 2)
    ,vlatrpag NUMBER(12, 2)
    ,vlsdvpar NUMBER(12, 2)
    ,vljinp59 NUMBER(12, 2)
    ,vljinp60 NUMBER(12, 2)
    ,inliquid INTEGER
    ,flgantec BOOLEAN
    ,inpagmto INTEGER -- indica que o registro foi processada com sucesso 
    );

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_pgto_parcel IS TABLE OF typ_reg_pgto_parcel INDEX BY BINARY_INTEGER;

  /* Tipo que compreende o registro da tab. temporaria tt-calculado */
  TYPE typ_reg_calculado IS RECORD(
     vlsdeved NUMBER(25, 10)
    ,vlsderel NUMBER(25, 10)
    ,vlprepag NUMBER(25, 10)
    ,vlpreapg NUMBER(25, 10)
    ,qtprecal NUMBER(14, 4)
    ,vlsdvctr NUMBER(25, 10)
    ,qtlemcal NUMBER(14, 4)
    ,vlmtapar crappep.vlmtapar%TYPE
    ,vlmrapar crappep.vlmrapar%TYPE
    ,vlprvenc NUMBER(12, 2)
    ,vlpraven NUMBER(12, 2));

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_calculado IS TABLE OF typ_reg_calculado INDEX BY BINARY_INTEGER;

  /* Tipo utilizado na pc_lanca_juro_contrato */
  TYPE typ_tab_crawepr IS TABLE OF crawepr%ROWTYPE INDEX BY VARCHAR2(30);

  /* Tipo que compreende o registro da tab. temporaria tt-calculado */
  TYPE typ_reg_msg_confirma IS RECORD(
     inconfir INTEGER
    ,dsmensag VARCHAR2(4000));

  /* Tipo utilizado na pc_valida_pagamentos_geral */
  TYPE typ_tab_msg_confirma IS TABLE OF typ_reg_msg_confirma INDEX BY PLS_INTEGER;

  /* Tipo que compreende o registro da tab. temporaria tt-lancconta */
  TYPE typ_reg_tab_lancconta IS RECORD(
     cdcooper crapcop.cdcooper%type
    ,nrctremp crappep.nrctremp%type
    ,cdhistor craphis.cdhistor%type
    ,dtmvtolt crapdat.dtmvtolt%type
    ,cdagenci crapage.cdagenci%type
    ,cdbccxlt craplot.cdbccxlt%type
    ,cdoperad crapope.cdoperad%type
    ,nrdolote craplot.nrdolote%type
    ,nrdconta crapass.nrdconta%type
    ,vllanmto NUMBER(32,8)
    ,cdpactra crapage.cdagenci%type
    ,nrseqava INTEGER);

  /* Tipo utilizado na pc_valida_pagamentos_geral */
  TYPE typ_tab_lancconta IS TABLE OF typ_reg_tab_lancconta INDEX BY VARCHAR2(80);
        
  /* Buscar a configuracao de empr�stimo cfme a empresa da conta */
  PROCEDURE pc_config_empresti_empresa(pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data corrente
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da conta do empr�stim
                                      ,pr_cdempres IN crapepr.cdempres%TYPE DEFAULT NULL --> Empresa do empr�stimo ou se n�o passada do cadastro
                                      ,pr_dtcalcul OUT DATE --> Data calculada de pagamento
                                      ,pr_diapagto OUT INTEGER --> Dia de pagamento das parcelas
                                      ,pr_flgfolha OUT BOOLEAN --> Flag de desconto em folha S/N
                                      ,pr_ddmesnov OUT INTEGER --> Configura��o para m�s novo
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> C�digo da critica
                                      ,pr_des_erro OUT VARCHAR2); --> Retorno de Erro

  /* Processar a rotina de leitura de pagamentos do emprestimo. */
  PROCEDURE pc_leitura_lem(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa
                          ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> C�digo do programa corrente
                          ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                          ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> N�mero da conta
                          ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero ctrato empr�stimo
                          ,pr_dtcalcul   IN DATE --> Data para calculo do empr�stimo
                          ,pr_diapagto   IN OUT INTEGER --> Dia para pagamento
                          ,pr_txdjuros   IN OUT crapepr.txjuremp%TYPE --> Taxa de juros aplicada
                          ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de presta��es calculadas at� momento
                          ,pr_qtprepag   IN OUT crapepr.qtprepag%TYPE --> Quantidade de presta��es paga at� momento
                          ,pr_vlprepag   IN OUT craplem.vllanmto%TYPE --> Valor acumulado pago no m�s
                          ,pr_vljurmes   IN OUT crapepr.vljurmes%TYPE --> Juros no m�s corrente
                          ,pr_vljuracu   IN OUT crapepr.vljuracu%TYPE --> Juros acumulados total
                          ,pr_vlsdeved   IN OUT crapepr.vlsdeved%TYPE --> Saldo devedor acumulado
                          ,pr_dtultpag   IN OUT crapepr.dtultpag%TYPE --> Ultimo dia de pagamento das presta��es
                          ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> C�digo da cr�tica tratada
                          ,pr_des_erro   OUT VARCHAR2); --> Descri��o de critica tratada

  /* Processar a rotina de leitura de pagamentos do emprestimo. */
  PROCEDURE pc_leitura_lem_car(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> C�digo do programa corrente
                              ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta
                              ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero ctrato emprestimo
                              ,pr_dtcalcul   IN DATE --> Data para calculo do emprestimo
                              ,pr_diapagto   IN OUT INTEGER --> Dia para pagamento
                              ,pr_txdjuros   IN OUT crapepr.txjuremp%TYPE --> Taxa de juros aplicada
                              ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de prestacoes calculadas ate momento
                              ,pr_qtprepag   IN OUT crapepr.qtprepag%TYPE --> Quantidade de prestacoes paga ate momento
                              ,pr_vlprepag   IN OUT craplem.vllanmto%TYPE --> Valor acumulado pago no mes
                              ,pr_vljurmes   IN OUT crapepr.vljurmes%TYPE --> Juros no mes corrente
                              ,pr_vljuracu   IN OUT crapepr.vljuracu%TYPE --> Juros acumulados total
                              ,pr_vlsdeved   IN OUT crapepr.vlsdeved%TYPE --> Saldo devedor acumulado
                              ,pr_dtultpag   IN OUT crapepr.dtultpag%TYPE --> Ultimo dia de pagamento das prestacoes
                              ,pr_qtmesdec   OUT crapepr.qtmesdec%TYPE --> Quantidade de meses decorridos
                              ,pr_vlpreapg   OUT crapepr.vlpreemp%TYPE --> Valor a pagar
                              ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Codigo da critica tratada
                              ,pr_dscritic   OUT crapcri.dscritic%TYPE); --> Descricao de critica tratada

  /* Calculo de dias para pagamento de emprestimo e juros */
  PROCEDURE pc_calc_dias360(pr_ehmensal IN BOOLEAN -- Indica se juros esta rodando na mensal
                           ,pr_dtdpagto IN INTEGER -- Dia do primeiro vencimento do emprestimo
                           ,pr_diarefju IN INTEGER -- Dia da data de refer�ncia da �ltima vez que rodou juros
                           ,pr_mesrefju IN INTEGER -- Mes da data de refer�ncia da �ltima vez que rodou juros
                           ,pr_anorefju IN INTEGER -- Ano da data de refer�ncia da �ltima vez que rodou juros
                           ,pr_diafinal IN OUT INTEGER -- Dia data final
                           ,pr_mesfinal IN OUT INTEGER -- Mes data final
                           ,pr_anofinal IN OUT INTEGER -- Ano data final
                           ,pr_qtdedias OUT INTEGER); -- Quantidade de dias calculada

  /* Calculo de juros normais */
  PROCEDURE pc_calc_juros_normais_total(pr_vlpagpar IN NUMBER -- Valor a pagar originalmente
                                       ,pr_txmensal IN NUMBER -- Valor da taxa mensal
                                       ,pr_qtdiajur IN INTEGER -- Quantidade de dias de aplica��o de juros
                                       ,pr_vljinpar OUT NUMBER); -- Valor com os juros aplicados

  /* Procedure para calcular valor antecipado de parcelas de empr�stimo */
  PROCEDURE pc_calc_antecipa_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                    ,pr_dtvencto IN crappep.dtvencto%TYPE --> Data do vencimento
                                    ,pr_vlsdvpar IN crappep.vlsdvpar%TYPE --> Valor devido parcela
                                    ,pr_txmensal IN crapepr.txmensal%TYPE --> Taxa aplicada ao empr�stimo
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento atual
                                    ,pr_dtdpagto IN crapdat.dtmvtolt%TYPE --> Data de pagamento
                                    ,pr_vlatupar OUT crappep.vlsdvpar%TYPE --> Valor atualizado da parcela
                                    ,pr_vldespar OUT crappep.vlsdvpar%TYPE --> Valor desconto da parcela
                                    ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro); --> Tabela com poss�ves erros

  /* Calculo de valor atualizado de parcelas de empr�stimo em atraso */
  PROCEDURE pc_calc_atraso_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                  ,pr_cdoperad IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                  ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                  ,pr_idorigem IN INTEGER --> Id do m�dulo de sistema
                                  ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                  ,pr_flgerlog IN VARCHAR2 --> Indicador S/N para gera��o de log
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                  ,pr_nrparepr IN INTEGER --> N�mero parcelas empr�stimo
                                  ,pr_vlpagpar IN NUMBER --> Valor a pagar originalmente
                                  ,pr_vlpagsld OUT NUMBER --> Saldo a pagar ap�s multa e juros
                                  ,pr_vlatupar OUT NUMBER --> Valor atual da parcela
                                  ,pr_vlmtapar OUT NUMBER --> Valor de multa
                                  ,pr_vljinpar OUT NUMBER --> Valor dos juros
                                  ,pr_vlmrapar OUT NUMBER --> Valor de mora
                                  ,pr_vljinp59 OUT NUMBER --> Juros quando per�odo inferior a 59 dias
                                  ,pr_vljinp60 OUT NUMBER --> Juros quando per�odo igual ou superior a 60 dias
                                  ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro); --> Tabela com poss�ves erros

  /* Busca dos pagamentos das parcelas de empr�stimo */
  PROCEDURE pc_busca_pgto_parcelas(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_cdagenci        IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                  ,pr_nrdcaixa        IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                  ,pr_cdoperad        IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                  ,pr_nmdatela        IN VARCHAR2 --> Nome da tela
                                  ,pr_idorigem        IN INTEGER --> Id do m�dulo de sistema
                                  ,pr_nrdconta        IN crapepr.nrdconta%TYPE --> N�mero da conta
                                  ,pr_idseqttl        IN crapttl.idseqttl%TYPE --> Seq titula
                                  ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                  ,pr_flgerlog        IN VARCHAR2 --> Indicador S/N para gera��o de log
                                  ,pr_nrctremp        IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                  ,pr_dtmvtoan        IN crapdat.dtmvtolt%TYPE --> Data anterior
                                  ,pr_nrparepr        IN INTEGER --> N�mero parcelas empr�stimo
                                  ,pr_des_reto        OUT VARCHAR --> Retorno OK / NOK
                                  ,pr_tab_erro        OUT gene0001.typ_tab_erro --> Tabela com poss�ves erros
                                  ,pr_tab_pgto_parcel OUT empr0001.typ_tab_pgto_parcel --> Tabela com registros de pagamentos
                                  ,pr_tab_calculado   OUT empr0001.typ_tab_calculado); --> Tabela com totais calculados

  /* Calculo de saldo devedor em emprestimos baseado na includes/lelem.i. */
  PROCEDURE pc_calc_saldo_deved_epr_lem(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Codigo do programa corrente
                                       ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Codigo da ag�ncia
                                       ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                       ,pr_cdoperad   IN crapdev.cdoperad%TYPE --> Codigo do Operador
                                       ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                                       ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta
                                       ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero ctrato empr�stimo
                                       ,pr_idorigem   IN INTEGER --> Id do m�dulo de sistema
                                       ,pr_txdjuros   IN crapepr.txjuremp%TYPE --> Taxa de juros aplicada
                                       ,pr_dtcalcul   IN DATE --> Data para calculo do empr�stimo
                                       ,pr_diapagto   IN OUT INTEGER --> Dia para pagamento
                                       ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de presta��es calculadas at� momento
                                       ,pr_vlprepag   IN OUT NUMBER --> Valor acumulado pago no m�s
                                       ,pr_vlpreapg   IN OUT NUMBER --> Valor a pagar
                                       ,pr_vljurmes   IN OUT NUMBER --> Juros no m�s corrente
                                       ,pr_vljuracu   IN OUT NUMBER --> Juros acumulados total
                                       ,pr_vlsdeved   IN OUT NUMBER --> Saldo devedor acumulado
                                       ,pr_dtultpag   IN OUT crapepr.dtultpag%TYPE --> Ultimo dia de pagamento das presta��es
                                       ,pr_vlmrapar   IN OUT crappep.vlmrapar%TYPE --> Valor do Juros de Mora
                                       ,pr_vlmtapar   IN OUT crappep.vlmtapar%TYPE --> Valor da Multa
                                       ,pr_vlprvenc   IN OUT NUMBER --> Valor a parcela a vencer
                                       ,pr_vlpraven   IN OUT NUMBER --> Valor da parcela vencida
                                       ,pr_flgerlog   IN VARCHAR2 --> Gerar log S/N
                                       ,pr_des_reto   OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro   OUT gene0001.typ_tab_erro); --> Tabela com poss�ves erros

  /* Procedure para obter dados de emprestimos do associado */
  PROCEDURE pc_obtem_dados_empresti(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                   ,pr_cdagenci       IN crapass.cdagenci%TYPE --> Codigo da ag�ncia
                                   ,pr_nrdcaixa       IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                   ,pr_cdoperad       IN crapdev.cdoperad%TYPE --> Codigo do operador
                                   ,pr_nmdatela       IN VARCHAR2 --> Nome datela conectada
                                   ,pr_idorigem       IN INTEGER --> Indicador da origem da chamada
                                   ,pr_nrdconta       IN crapass.nrdconta%TYPE --> Conta do associado
                                   ,pr_idseqttl       IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                   ,pr_rw_crapdat     IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                                   ,pr_dtcalcul       IN DATE --> Data solicitada do calculo
                                   ,pr_nrctremp       IN crapepr.nrctremp%TYPE --> Numero contrato empr�stimo
                                   ,pr_cdprogra       IN crapprg.cdprogra%TYPE --> Programa conectado
                                   ,pr_inusatab       IN BOOLEAN --> Indicador de utiliza��o da tabela de juros
                                   ,pr_flgerlog       IN VARCHAR2 --> Gerar log S/N
                                   ,pr_flgcondc       IN BOOLEAN --> Mostrar emprestimos liquidados sem prejuizo
                                   ,pr_nmprimtl       IN crapass.nmprimtl%TYPE --> Nome Primeiro Titular
                                   ,pr_tab_parempctl  IN craptab.dstextab%TYPE --> Dados tabela parametro
                                   ,pr_tab_digitaliza IN craptab.dstextab%TYPE --> Dados tabela parametro
                                   ,pr_nriniseq       IN INTEGER --> Numero inicial da paginacao
                                   ,pr_nrregist       IN INTEGER --> Numero de registros por pagina
                                   ,pr_qtregist       OUT INTEGER --> Qtde total de registros
                                   ,pr_tab_dados_epr  OUT typ_tab_dados_epr --> Saida com os dados do empr�stimo
                                   ,pr_des_reto       OUT VARCHAR --> Retorno OK / NOK
                                   ,pr_tab_erro       OUT gene0001.typ_tab_erro); --> Tabela com poss�ves erros
  
  /* Procedure para obter dados de emprestimos do associado - Chamada AyllosWeb */
  PROCEDURE pc_obtem_dados_empresti_web(  pr_nrdconta       IN crapass.nrdconta%TYPE    --> Conta do associado
                                         ,pr_idseqttl       IN crapttl.idseqttl%TYPE    --> Sequencia de titularidade da conta
                                         ,pr_dtcalcul       IN DATE                     --> Data solicitada do calculo
                                         ,pr_nrctremp       IN crapepr.nrctremp%TYPE    --> N�mero contrato empr�stimo
                                         ,pr_cdprogra       IN crapprg.cdprogra%TYPE    --> Programa conectado
                                         ,pr_flgerlog       IN VARCHAR2                 --> Gerar log S/N
                                         ,pr_flgcondc       IN INTEGER                  --> Mostrar emprestimos liquidados sem prejuizo
                                         ,pr_nriniseq       IN INTEGER                  --> Numero inicial da paginacao
                                         ,pr_nrregist       IN INTEGER                  --> Numero de registros por pagina
                                         ,pr_xmllog         IN VARCHAR2                 --> XML com informa��es de LOG
                                          -- OUT
                                         ,pr_cdcritic OUT PLS_INTEGER                   --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2                      --> Descric?o da critica
                                         ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);                    --> Erros do processo
  
  /* Calcular o saldo devedor do emprestimo */
  PROCEDURE pc_calc_saldo_epr(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                             ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                             ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Programa que solicitou o calculo
                             ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta do empr�stimo
                             ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato do empr�stimo
                             ,pr_inusatab   IN BOOLEAN --> Indicador de utiliza��o da tabela de juros
                             ,pr_vlsdeved   OUT NUMBER --> Saldo devedor do empr�stimo
                             ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de parcelas do empr�stimo
                             ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Codigo de critica encontrada
                             ,pr_des_erro   OUT VARCHAR2); --> Retorno de Erro

  /* Procedure para calcular saldo devedor de emprestimos */
  PROCEDURE pc_saldo_devedor_epr(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Codigo da ag�ncia
                                ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                ,pr_cdoperad   IN crapdev.cdoperad%TYPE --> Codigo do operador
                                ,pr_nmdatela   IN VARCHAR2 --> Nome datela conectada
                                ,pr_idorigem   IN INTEGER --> Indicador da origem da chamada
                                ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                                ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero contrato empr�stimo
                                ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Programa conectado
                                ,pr_inusatab   IN BOOLEAN --> Indicador de utiliza��o da tabela
                                ,pr_flgerlog   IN VARCHAR2 --> Gerar log S/N
                                ,pr_vlsdeved   IN OUT NUMBER --> Saldo devedor calculado
                                ,pr_vltotpre   IN OUT NUMBER --> Valor total das presta��es
                                ,pr_qtprecal   IN OUT crapepr.qtprecal%TYPE --> Parcelas calculadas
                                ,pr_des_reto   OUT VARCHAR --> Retorno OK / NOK
                                ,pr_tab_erro   OUT gene0001.typ_tab_erro); --> Tabela com poss�ves erros

  /* Rotina de calculo de dias do ultimo pagamento de emprestimos em atraso*/
  PROCEDURE pc_calc_dias_atraso(pr_cdcooper   IN crapepr.cdcooper%TYPE --> Codigo da cooperativa
                               ,pr_cdprogra   IN VARCHAR2 --> Nome do programa que est� executando
                               ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta do emprestimo
                               ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                               ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                               ,pr_inusatab   IN BOOLEAN --> Indicador de utiliza��o da tabela de juros
                               ,pr_vlsdeved   OUT NUMBER --> Valor do saldo devedor
                               ,pr_qtprecal   OUT NUMBER --> Quantidade de Parcelas
                               ,pr_qtdiaatr   OUT NUMBER --> Quantidade de dias em atraso
                               ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Codigo de critica encontrada
                               ,pr_des_erro   OUT VARCHAR2); --> Retorno de erro
                               
  /* Criar o lancamento na Conta Corrente  */
  PROCEDURE pc_cria_lancamento_cc(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                 ,pr_cdbccxlt IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                 ,pr_cdoperad IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                 ,pr_cdpactra IN INTEGER --> P.A. da transa��o
                                 ,pr_nrdolote IN craplot.nrdolote%TYPE --> Numero do Lote
                                 ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                 ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo historico
                                 ,pr_vllanmto IN NUMBER --> Valor da parcela emprestimo
                                 ,pr_nrparepr IN INTEGER --> N�mero parcelas empr�stimo
                                 ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                 ,pr_nrseqava IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                 ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro);                             

  --Procedure para Criar lancamento e atualiza o lote
  PROCEDURE pc_cria_lancamento_lem(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE --Codigo Agencia
                                  ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE --Codigo Caixa
                                  ,pr_cdoperad IN craplot.cdoperad%TYPE --Operador
                                  ,pr_cdpactra IN INTEGER --Posto Atendimento
                                  ,pr_tplotmov IN craplot.tplotmov%TYPE --Tipo movimento
                                  ,pr_nrdolote IN craplot.nrdolote%TYPE --Numero Lote
                                  ,pr_nrdconta IN crapepr.nrdconta%TYPE --Numero da Conta
                                  ,pr_cdhistor IN craplot.cdhistor%TYPE --Codigo Historico
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --Numero Contrato
                                  ,pr_vllanmto IN craplcm.vllanmto%TYPE --Valor Lancamento
                                  ,pr_dtpagemp IN crapdat.dtmvtolt%TYPE --Data Pagamento Emprestimo
                                  ,pr_txjurepr IN NUMBER --Taxa Juros Emprestimo
                                  ,pr_vlpreemp IN crapepr.vlpreemp%TYPE --Valor Emprestimo
                                  ,pr_nrsequni IN INTEGER --Numero Sequencia
                                  ,pr_nrparepr IN INTEGER --Numero Parcelas Emprestimo
                                  ,pr_flgincre IN BOOLEAN --Indicador Credito
                                  ,pr_flgcredi IN BOOLEAN --Credito
                                  ,pr_nrseqava IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                  ,pr_cdorigem IN NUMBER DEFAULT 0
                                  ,pr_cdcritic OUT INTEGER --Codigo Erro
                                  ,pr_dscritic OUT VARCHAR2);
                                  
  --Procedure para Lancar Juros no Contrato
  PROCEDURE pc_lanca_juro_contrato(pr_cdcooper    IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                  ,pr_cdagenci    IN crapass.cdagenci%TYPE --Codigo Agencia
                                  ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE --Codigo Caixa
                                  ,pr_nrdconta    IN crapepr.nrdconta%TYPE --Numero da Conta
                                  ,pr_nrctremp    IN crapepr.nrctremp%TYPE --Numero Contrato
                                  ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                                  ,pr_cdoperad    IN craplot.cdoperad%TYPE --Operador
                                  ,pr_cdpactra    IN INTEGER --Posto Atendimento
                                  ,pr_flnormal    IN BOOLEAN --Lancamento Normal
                                  ,pr_dtvencto    IN crapdat.dtmvtolt%TYPE --Data vencimento
                                  ,pr_ehmensal    IN BOOLEAN --Indicador Mensal
                                  ,pr_dtdpagto    IN crapdat.dtmvtolt%TYPE --Data pagamento
                                  ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                  ,pr_cdorigem    IN NUMBER DEFAULT 0
                                  ,pr_vljurmes    OUT NUMBER --Valor Juros no Mes
                                  ,pr_diarefju    OUT INTEGER --Dia Referencia Juros
                                  ,pr_mesrefju    OUT INTEGER --Mes Referencia Juros
                                  ,pr_anorefju    OUT INTEGER --Ano Referencia Juros
                                  ,pr_des_reto    OUT VARCHAR2 --Retorno OK/NOK
                                  ,pr_tab_erro    OUT gene0001.typ_tab_erro); --tabela Erros

  /* Procedure para validar pagamentos */
  PROCEDURE pc_valida_pagamentos_geral(pr_cdcooper         IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                      ,pr_cdagenci         IN crapass.cdagenci%TYPE --Codigo Agencia
                                      ,pr_nrdcaixa         IN craplot.nrdcaixa%TYPE --Codigo Caixa
                                      ,pr_cdoperad         IN craplot.cdoperad%TYPE --Operador
                                      ,pr_nmdatela         IN crapprg.cdprogra%TYPE --Nome da Tela
                                      ,pr_idorigem         IN INTEGER --Identificador origem
                                      ,pr_nrdconta         IN crapepr.nrdconta%TYPE --Numero da Conta
                                      ,pr_nrctremp         IN crapepr.nrctremp%TYPE --Numero Contrato
                                      ,pr_idseqttl         IN crapttl.idseqttl%TYPE --Sequencial Titular
                                      ,pr_dtmvtolt         IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                                      ,pr_flgerlog         IN BOOLEAN --Erro no Log
                                      ,pr_dtrefere         IN crapdat.dtmvtolt%TYPE --Data Referencia
                                      ,pr_vlapagar         IN NUMBER --Valor Pagar
                                      ,pr_tab_crawepr      IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                      ,pr_vlsomato         OUT NUMBER --Soma Total
                                      ,pr_tab_erro         OUT gene0001.typ_tab_erro --tabela Erros
                                      ,pr_des_reto         OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_msg_confirma OUT typ_tab_msg_confirma); --Tabela Confirmacao
																			
  /* Validar pagamento Atrasado das parcelas de empr�stimo */
  PROCEDURE pc_valida_pagto_atr_parcel(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                      ,pr_cdoperad IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                      ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                      ,pr_idorigem IN INTEGER               --> Id do m�dulo de sistema
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                      ,pr_flgerlog IN VARCHAR2              --> Indicador S/N para gera��o de log
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                      ,pr_nrparepr IN INTEGER               --> N�mero parcelas empr�stimo
                                      ,pr_vlpagpar IN NUMBER                --> Valor a pagar parcela
                                      ,pr_vlpagsld OUT NUMBER               --> Valor Pago Saldo
                                      ,pr_vlatupar OUT NUMBER               --> Valor Atual Parcela
                                      ,pr_vlmtapar OUT NUMBER               --> Valor Multa Parcela
                                      ,pr_vljinpar OUT NUMBER               --> Valor Juros parcela
                                      ,pr_vlmrapar OUT NUMBER               --> Valor ???
                                      ,pr_des_reto OUT VARCHAR              --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro); --> Tabela com poss�ves erros																			

  /* Busca dos pagamentos das parcelas de empr�stimo */

  PROCEDURE pc_efetiva_pagto_atr_parcel(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                       ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                       ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                       ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                       ,pr_idorigem    IN INTEGER --> Id do m�dulo de sistema
                                       ,pr_cdpactra    IN INTEGER --> P.A. da transa��o
                                       ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                       ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para gera��o de log
                                       ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                       ,pr_nrparepr    IN INTEGER --> N�mero parcelas empr�stimo
                                       ,pr_vlpagpar    IN NUMBER --> Valor a pagar parcela
                                       ,pr_tab_crawepr IN EMPR0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                       ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                       ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro    OUT gene0001.typ_tab_erro); --> Tabela com poss�ves erros

  /* Verifica se tem uma parcela anterior nao liquida e ja vencida  */
  PROCEDURE pc_verifica_parcel_anteriores(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                         ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                         ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                         ,pr_nrparepr IN INTEGER --> N�mero parcelas empr�stimo
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                         ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                         ,pr_dscritic OUT VARCHAR2); --> Descricao Erro

  /* Efetivar o pagamento da parcela  */
  PROCEDURE pc_efetiva_pagto_parcela(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                    ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                    ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                    ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                    ,pr_idorigem    IN INTEGER --> Id do m�dulo de sistema
                                    ,pr_cdpactra    IN INTEGER --> P.A. da transa��o
                                    ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                    ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                    ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                    ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para gera��o de log
                                    ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                    ,pr_nrparepr    IN INTEGER --> N�mero parcelas empr�stimo
                                    ,pr_vlparepr    IN NUMBER --> Valor da parcela emprestimo
                                    ,pr_tab_crawepr IN EMPR0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                    ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                    ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro    OUT gene0001.typ_tab_erro); --> Tabela com poss�ves erros

  /* Rotina referente a consulta de produtos cadastrados */
  PROCEDURE pc_consulta_antecipacao(pr_nrdconta IN crapass.nrdconta%TYPE --> Codigo do Produto
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Codigo do Produto
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  /* Rotina rresponsavel em gerar o relatorio crrl684 de parcelas antecipadas */
  PROCEDURE pc_imprimir_antecipacao(pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Produto
                                   ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Codigo do Produto
                                   ,pr_qtdregis  IN NUMBER --> Quantidade de registro no relatorio
                                   ,pr_lstdtpgto IN VARCHAR2 --> Lista com as datas de pagto dos registros
                                   ,pr_lstdtvcto IN VARCHAR2 --> Lista com as datas do vencimento dos registros
                                   ,pr_lstparepr IN VARCHAR2 --> Lista com as parcelas de empr dos registros
                                   ,pr_lstvlrpag IN VARCHAR2 --> Lista com valores pgto dos registros
                                   ,pr_xmllog    IN VARCHAR2 --> XML com informa��es de LOG--> XML com informa��es de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER --> C�digo da cr�tica
                                   ,pr_dscritic  OUT VARCHAR2 --> Descri��o da cr�tica
                                   ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);

  /* Procedure para validar as operacoes que serao incluidas no produto TR */                    
  PROCEDURE pc_valida_inclusao_tr(pr_cdcooper IN craplcr.cdcooper%TYPE --> C�digo da cooperativa
                                 ,pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Codigo da linha de credito
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de inclusao
                                 ,pr_qtpreemp IN crapepr.qtpreemp%TYPE --> Quantidade de Prestacoes
                                 ,pr_flgpagto IN crapepr.flgpagto%TYPE --> Folha
                                 ,pr_dtdpagto IN crapepr.dtdpagto%TYPE --> Data de Pagamento
                                 ,pr_cdfinemp IN crapepr.cdfinemp%TYPE --> Finalidade
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Operador
                                 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2);  --> Descri��o da cr�tica   
                                                                    
  /* Efetuar a Liquidacao do Emprestimo  */
  PROCEDURE pc_efetua_liquidacao_empr(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                     ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                     ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                     ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                     ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                     ,pr_idorigem    IN INTEGER --> Id do m�dulo de sistema
                                     ,pr_cdpactra    IN INTEGER --> P.A. da transa��o
                                     ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                     ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                     ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                     ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para gera��o de log
                                     ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                     ,pr_dtmvtoan    IN DATE     --> Data Movimento Anterior
                                     ,pr_ehprcbat    IN VARCHAR2 --> Indicador Processo Batch (S/N)
                                     ,pr_tab_pgto_parcel IN OUT EMPR0001.typ_tab_pgto_parcel --Tabela com Pagamentos de Parcelas
                                     ,pr_tab_crawepr IN EMPR0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                     ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                     ,pr_des_erro    OUT VARCHAR --> Retorno OK / NOK
                                     ,pr_tab_erro    OUT gene0001.typ_tab_erro); --> Tabela com poss�ves erros
                                     

  PROCEDURE pc_liq_mesmo_dia_web(pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                ,pr_dtmvtolt    IN VARCHAR2              --> Movimento atual
                                ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para gera��o de log
                                ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                ,pr_xmllog   IN VARCHAR2                 --> XML com informac?es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER             --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                --> Descric?o da critica
                                ,pr_retxml   IN OUT NOCOPY XMLType       --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);
																
	--Procedure de pagamentos de parcelas
  PROCEDURE pc_gera_pagamentos_parcelas( pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da Cooperativa
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                        ,pr_cdoperad IN VARCHAR2              --> C�digo do operador
                                        ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                        ,pr_idorigem IN INTEGER               --> Id Origem do sistemas
                                        ,pr_cdpactra IN INTEGER               --> P.A. da transa��o
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Id do titular da conta
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                        ,pr_flgerlog IN VARCHAR2              --> Gera log S/N
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Nr. do contrato de emprestimo
                                        ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE --> Data de movimento do dia anterior
                                        ,pr_totatual IN crapepr.vlemprst%TYPE
                                        ,pr_totpagto IN crapepr.vlemprst%TYPE
                                        ,pr_nrseqava IN NUMBER DEFAULT 0      --> Pagamento: Sequencia do avalista
																				,pr_tab_pgto_parcel IN OUT empr0001.typ_tab_pgto_parcel
																				,pr_des_reto OUT VARCHAR
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro);--> Tabela com poss�ves erros     														

  PROCEDURE pc_verifica_parcelas_antecipa(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
																				 ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Conta
																				 ,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Contrato
																				 ,pr_nrparepr IN crappep.nrparepr%TYPE  --> Nr. da parcela
																				 ,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE  --> Data de movimento
																				 ,pr_des_reto OUT VARCHAR2              --> Retorno OK/NOK
																				 ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica

  -- Possui a mesma funcionalidade da rotina pc_valida_pagamentos_geral,
  -- para chamadas diretamente atraves de rotinas progress
  PROCEDURE pc_valida_pagto_geral_prog (pr_cdcooper  IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                       ,pr_cdagenci  IN crapass.cdagenci%TYPE --Codigo Agencia
                                       ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE --Codigo Caixa
                                       ,pr_cdoperad  IN craplot.cdoperad%TYPE --Operador
                                       ,pr_nmdatela  IN crapprg.cdprogra%TYPE --Nome da Tela
                                       ,pr_idorigem  IN INTEGER               --Identificador origem
                                       ,pr_nrdconta  IN crapepr.nrdconta%TYPE --Numero da Conta
                                       ,pr_nrctremp  IN crapepr.nrctremp%TYPE --Numero Contrato
                                       ,pr_idseqttl  IN crapttl.idseqttl%TYPE --Sequencial Titular
                                       ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                                       ,pr_flgerlog  IN INTEGER               --Erro no Log
                                       ,pr_dtrefere  IN crapdat.dtmvtolt%TYPE --Data Referencia
                                       ,pr_vlapagar  IN NUMBER                --Valor Pagar
                                       ,pr_vlsomato OUT NUMBER                --Soma Total
                                       ,pr_des_reto OUT VARCHAR               --Retorno OK / NOK
                                       ,pr_cdcritic OUT INTEGER               --Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR               --Descricao da Critica
                                       ,pr_inconfir OUT INTEGER               --Codigo da Confirmacao
                                       ,pr_dsmensag OUT VARCHAR);             --Descricao da Confirmacao

  PROCEDURE pc_verifica_msg_garantia(pr_cdcooper IN crapbpr.cdcooper%TYPE --> C�digo da cooperativa
                                    ,pr_dscatbem IN crapbpr.dscatbem%TYPE --> Descricao da categoria do bem
								                    ,pr_vlmerbem IN crapbpr.vlmerbem%TYPE --> Valor de mercado do bem
                                    ,pr_vlemprst IN crapepr.vlemprst%TYPE --> Valor do emprestimo
                                    ,pr_flgsenha OUT INTEGER              --> Verifica se solicita a senha
                                    ,pr_dsmensag OUT VARCHAR2             --> Descricao da mensagem de aviso
                                    ,pr_cdcritic OUT INTEGER              --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2);           --> Descri��o da cr�tica

  PROCEDURE pc_valida_alt_valor_prop(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo da ag�ncia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                    ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Codigo do operador
                                    ,pr_nmdatela IN VARCHAR2              --> Nome datela conectada
                                    ,pr_idorigem IN INTEGER               --> Indicador da origem da chamada
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do associado
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                    ,pr_dtmvtolt IN DATE                  --> Data de Movimentacao
                                    ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero Contrato
                                    ,pr_vlemprst IN crapepr.vlemprst%TYPE --> Valor do emprestimo
                                    ,pr_flgsenha OUT INTEGER              --> Verifica se solicita a senha
                                    ,pr_dsmensag OUT VARCHAR2             --> Descricao da mensagem de aviso
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2);
                                   
  PROCEDURE pc_valida_alt_valor_prop_web(pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                        ,pr_vlemprst IN crapepr.vlemprst%TYPE --> Valor do emprestimo
                                        ,pr_dtmvtolt IN VARCHAR2              --> Movimento atual
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2             --> Descric?o da critica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);
                                        
END empr0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.empr0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0001
  --  Sistema  : Rotinas gen�ricas focando nas funcionalidades de empr�stimos
  --  Sigla    : EMPR
  --  Autor    : Marcos Ernani Martini
  --  Data     : Fevereiro/2013.                   Ultima atualizacao: 26/09/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas gen�ricas dos sistemas Oracle
  --
  -- Altera��es: 12/09/2013 - Ajustes na capacidade das variaveis (Gabriel).
  --
  --             05/05/2014 - Criar o campo vlppagat no TYPE "typ_reg_dados_epr". (James)
  --
  --             09/05/2014 - Adicionado parametros de paginacao em pc_obtem_dados_empresti.
  --                          (Jorge/Guilherme) - SD 109570
  --
  --             12/05/2014 - Incluido "qtlemcal","vlprvenc" e "vlpraven" na tt-dados-epr (James).
  --
  --             12/09/2014 - Incluido "flgpreap" na tt-dados-epr (James).
  --
  --             21/01/2015 - Alterado o formato do campo nrctremp para 8 
  --                          caracters (Kelvin - 233714)
  --
	--             11/06/2015 - Projeto 158 - Servico Folha de Pagto
  --                          (Andre Santos - SUPERO)
  --
  --             24/06/2015 - Alterado tipo de index da tabela typ_reg_diadopagto, de BINARY_INTEGER
  --                          para VARCHAR2(15), adicionado cooperativa no indice. (Jorge/Rodrigo)
  --
  --             19/08/2015 - Adicionado tratamentos para o projeto 215. (Reinert)
  --  
  --             13/11/2015 - Ajustado leitura na CRAPOPE incluindo upper (Odirlei-AMcom)
  --
  --             27/11/2015 - Ajustado pc_valida_pagamentos_geral para inicializar vari�vel 
  --                          vr_flgtrans e ROUND na pr_vlsomato. Criado procedure
  --                          pc_valida_pagto_geral_prog (Douglas - Chamado 285228)
  --
  --             02/02/2016 - Adicionado valida��o na procedure pc_busca_pgto_parcelas_prefix
  --                          para verificar se o emprestimo j� est� liquidado 389736 (Kelvin).
  --
  --             26/09/2016 - Adicionado validacao de contratos de acordo na procedure
  --                          pc_valida_pagamentos_geral, Prj. 302 (Jean Michel). 
  ---------------------------------------------------------------------------------------------------------------

  /* Tratamento de erro */
  vr_des_erro VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  /* Descri��o e c�digo da critica */
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);

  /* Erro em chamadas da pc_gera_erro */
  vr_des_reto VARCHAR2(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  /* Tipo que compreende o registro de configura��o DIADOPAGTO */
  TYPE typ_reg_diadopagto IS RECORD(
     diapgtom INTEGER --> Dia pagamento mensalista
    ,diapgtoh INTEGER --> Dia pagamento horista
    ,flgfolha INTEGER --> Desconto em folha
    ,ddmesnov INTEGER); --> Configura��o de m�s novo
  /* Defini��o de tabela que compreender� os registros acima declarados */
  TYPE typ_tab_diadopagto IS TABLE OF typ_reg_diadopagto INDEX BY VARCHAR2(15);
  /* Vari�vel que armazenar� uma instancia da tabela */
  vr_tab_diadopagto typ_tab_diadopagto;

  /* Cursor gen�rico de parametriza��o */
  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nmsistem IN craptab.nmsistem%TYPE
                   ,pr_tptabela IN craptab.tptabela%TYPE
                   ,pr_cdempres IN craptab.cdempres%TYPE
                   ,pr_cdacesso IN craptab.cdacesso%TYPE
                   ,pr_tpregist IN craptab.tpregist%TYPE) IS
    SELECT tab.dstextab
          ,tab.tpregist
          ,tab.ROWID
      FROM craptab tab
     WHERE tab.cdcooper = pr_cdcooper
           AND UPPER(tab.nmsistem) = pr_nmsistem
           AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres = pr_cdempres
           AND UPPER(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist = NVL(pr_tpregist, tab.tpregist);
  rw_craptab cr_craptab%ROWTYPE;

  /* Cursor de Linha de Credito */
  CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                   ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
    SELECT craplcr.cdlcremp
          ,craplcr.dsoperac
      FROM craplcr
     WHERE craplcr.cdcooper = pr_cdcooper
           AND craplcr.cdlcremp = pr_cdlcremp;
  rw_craplcr cr_craplcr%ROWTYPE;

  /* Cursor de Emprestimos */
  CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT crapepr.*
          ,crapepr.rowid
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;

  /* Cursor com Detalhes dos Emprestimos */
  CURSOR cr_crawepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT crawepr.cdlcremp
          ,crawepr.vlpreemp
          ,crawepr.dtlibera
          ,crawepr.tpemprst
      FROM crawepr
     WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp;
  rw_crawepr cr_crawepr%ROWTYPE;

  /* Cursor de parcelas dos Emprestimos */
  CURSOR cr_crappep(pr_cdcooper IN crapepr.cdcooper%TYPE
                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
                   ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
    SELECT crappep.*
          ,crappep.rowid
      FROM crappep
     WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr = pr_nrparepr;
  rw_crappep cr_crappep%ROWTYPE;

  --Buscar informacoes de lote
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                   ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                   ,pr_cdagenci IN craplot.cdagenci%TYPE
                   ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                   ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT craplot.cdcooper
          ,craplot.dtmvtolt
          ,craplot.nrdolote
          ,craplot.cdagenci
          ,craplot.nrseqdig
          ,craplot.cdbccxlt
          ,craplot.qtcompln
          ,craplot.qtinfoln
          ,craplot.vlcompcr
          ,craplot.vlinfocr
          ,craplot.vlcompdb
          ,craplot.vlinfodb
          ,craplot.tplotmov
          ,craplot.rowid
      FROM craplot craplot
     WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = pr_cdagenci
           AND craplot.cdbccxlt = pr_cdbccxlt
           AND craplot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;

  /* Processar a rotina de leitura de pagamentos do emprestimo. */
  PROCEDURE pc_leitura_lem(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa
                          ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> C�digo do programa corrente
                          ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                          ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> N�mero da conta
                          ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero ctrato empr�stimo
                          ,pr_dtcalcul   IN DATE --> Data para calculo do empr�stimo
                          ,pr_diapagto   IN OUT INTEGER --> Dia para pagamento
                          ,pr_txdjuros   IN OUT crapepr.txjuremp%TYPE --> Taxa de juros aplicada
                          ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de presta��es calculadas at� momento
                          ,pr_qtprepag   IN OUT crapepr.qtprepag%TYPE --> Quantidade de presta��es paga at� momento
                          ,pr_vlprepag   IN OUT craplem.vllanmto%TYPE --> Valor acumulado pago no m�s
                          ,pr_vljurmes   IN OUT crapepr.vljurmes%TYPE --> Juros no m�s corrente
                          ,pr_vljuracu   IN OUT crapepr.vljuracu%TYPE --> Juros acumulados total
                          ,pr_vlsdeved   IN OUT crapepr.vlsdeved%TYPE --> Saldo devedor acumulado
                          ,pr_dtultpag   IN OUT crapepr.dtultpag%TYPE --> Ultimo dia de pagamento das presta��es
                          ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> C�digo da cr�tica tratada
                          ,pr_des_erro   OUT VARCHAR2) IS --> Descri��o de critica tratada
  
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_leitura_lem (Antigo includes/lelem.i)
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Deborah/Edson
    --   Data    : Agosto/93.                          Ultima atualizacao: 13/11/2012
    --
    --   Dados referentes ao programa:
    --   Frequencia: Sempre que for chamada.
    --   Objetivo  : Processar a rotina de calculo de emprestimo.
    --
    --   Alteracoes: 31/05/95 - Tratar o historico 95 (Edson).
    --
    --               12/06/96 - Calcular prestacoes pagas (Edson).
    --
    --               25/06/96 - Verificar integridade do inliquid x vlsdeved (Edson).
    --
    --               01/11/96 - Alterado para calcular ate a data do movimento no
    --                          caso de contratos com debito em conta (Edson).
    --
    --               27/01/98 - Criado historico 277 - estorno de juros (Deborah).
    --
    --               26/03/98 - Tratamento para milenio e troca para V8 (Margarete).
    --
    --               05/11/98 - Alterado a forma de tratar os emprestimos com
    --                          pagamento vinculado a conta-corrente (Edson).
    --
    --               12/11/98 - Tratar atendimento noturno (Deborah).
    --
    --               15/12/1999 - Tratar historico 349 (Edson).
    --
    --               03/03/2000 - Tirar mensagem de correcao do saldo devedor
    --                            (Deborah).
    --
    --               22/03/2000 - Tratar historico 353 (Deborah).
    --
    --               15/05/2002 - Nao descontar 88 fora do mes (Margarete).
    --
    --               05/07/2002 - Tratar historicos 392, 393 e 395 (Edson).
    --
    --               18/12/2002 - Quando estorno esta calculando prestacao
    --                            do mes errada (Margarete).
    --
    --               02/05/2003 - Tratar o historico 94 da mesma forma que o 91
    --                           (Edson).
    --
    --               10/11/2003 - Tratar historicos 441 e 443 de forma semelhante ao
    --                            historico 88 (Edson).
    --
    --               01/03/2004 - Desprezar histor 395 calculo qtprecal (Margarete).
    --
    --               06/05/2004 - Quando histor 88 estava descontando duas
    --                            vez do aux_vlprepag (Margarete).
    --               26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
    --
    --               31/05/2007 - Tratamento para historico 507 (Julio)
    --
    --               22/12/2010 - Se conta transferida nao ler o craplem.
    --                            Lancamento zerando no 1 dia util (Magui).
    --
    --               20/09/2011 - Erro no calculo do qtprepag. Quando pagto em
    --                            folha estava sempre contando como a prestacao
    --                            paga integral (Magui).
    --
    --               10/01/2012 - Melhoria de desempenho (Gabriel)
    --
    --               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
    --
    --               13/11/2012 - Convers�o Progress --> Oracle PLSQL (Marcos - Supero)
    -- .............................................................................
    DECLARE
      -- Cursor para busca dos dados de empr�stimo
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.dtmvtolt
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.vlsdeved
              ,epr.vljuracu
              ,epr.dtultpag
              ,epr.inliquid
              ,epr.qtprepag
              ,epr.cdlcremp
              ,epr.txjuremp
              ,epr.cdempres
              ,epr.flgpagto
              ,epr.dtdpagto
              ,epr.vlpreemp
              ,epr.qtprecal
              ,epr.qtpreemp
              ,epr.qtmesdec
              ,epr.tpemprst
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
               AND epr.nrdconta = pr_nrdconta
               AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      -- Teste de existencia de empresa
       CURSOR cr_crapemp IS
        SELECT emp.flgpagto
              ,emp.flgpgtib
          FROM crapemp emp
         WHERE emp.cdcooper = pr_cdcooper
           AND emp.cdempres = rw_crapepr.cdempres;
      vr_flgpagto_emp crapemp.flgpagto%TYPE;
      vr_flgpgtib_emp crapemp.flgpgtib%TYPE;

      -- Vari�veis auxiliares ao c�lculo
      vr_dtmvtolt crapdat.dtmvtolt%TYPE; --> Data de movimento auxiliar
      vr_dtmesant crapdat.dtmvtolt%TYPE; --> Data do m�s anterior ao movimento
      vr_flctamig BOOLEAN; --> Conta migrada entre cooperativas
      vr_nrdiacal INTEGER; --> N�mero de dias para o c�lculo
      vr_nrdiames INTEGER; --> N�mero de dias para o c�lculo no m�s corrente
      vr_nrdiaprx INTEGER; --> N�mero de dias para o c�lculo no pr�ximo m�s
      vr_inhst093 BOOLEAN; --> ???
      TYPE vr_tab_vlrpgmes IS TABLE OF crapepr.vlpreemp%TYPE INDEX BY BINARY_INTEGER;
      vr_vet_vlrpgmes vr_tab_vlrpgmes; --> Vetor e tipo para acumulo de pagamentos no m�s
      vr_qtdpgmes     INTEGER; --> Indice de presta��es
      vr_qtprepag     NUMBER(18, 4); --> Qtde paga de presta��es no m�s
      vr_exipgmes     BOOLEAN; --> Teste para busca no vetor de pagamentos
      vr_vljurmes     NUMBER; --> Juros no m�s corrente
      -- Verificar se existe registro de conta transferida entre
      -- cooperativas com tipo de transfer�ncia = 1 (Conta Corrente)
      CURSOR cr_craptco IS
        SELECT 1
          FROM craptco tco
         WHERE tco.cdcopant = pr_cdcooper
               AND tco.nrctaant = rw_crapepr.nrdconta
               AND tco.tpctatrf = 1
               AND tco.flgativo = 1; --> True
      vr_ind_tco NUMBER(1);
      -- Buscar informa��es de pagamentos do empr�stimos
      --   -> Enviado um tipo de hist�rico para busca a partir dele
      CURSOR cr_craplem_his(pr_cdhistor IN craplem.cdhistor%TYPE) IS
        SELECT 1
          FROM craplem lem
         WHERE lem.cdcooper = pr_cdcooper
               AND lem.nrdconta = rw_crapepr.nrdconta
               AND lem.nrctremp = rw_crapepr.nrctremp
               AND lem.cdhistor = pr_cdhistor;
      vr_fllemhis NUMBER;
      -- Buscar informa��es de pagamentos do empr�stimos
      --   -> Enviando uma data para filtrar movimentos posteriores a mesma
      CURSOR cr_craplem(pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
        SELECT /*+ INDEX (lem CRAPLEM##CRAPLEM6) */
         to_char(lem.dtmvtolt, 'dd') ddlanmto
        ,lem.dtmvtolt
        ,lem.cdhistor
        ,lem.vlpreemp
        ,lem.vllanmto
          FROM craplem lem
         WHERE lem.cdcooper = pr_cdcooper
               AND lem.nrdconta = rw_crapepr.nrdconta
               AND lem.nrctremp = rw_crapepr.nrctremp
               AND lem.dtmvtolt > pr_dtmvtolt
         ORDER BY lem.dtmvtolt
                 ,lem.cdhistor;
      rw_craplem cr_craplem%ROWTYPE;
    BEGIN
      -- Busca dos detalhes do empr�stimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr
        INTO rw_crapepr;
      -- Se n�o encontrar informa��es
      IF cr_crapepr%NOTFOUND THEN
        -- Fechar o cursor pois teremos raise
        CLOSE cr_crapepr;
        -- Gerar erro com critica 356
        pr_cdcritic := 356;
        vr_des_erro := gene0001.fn_busca_critica(356);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor para continuar o processo
        CLOSE cr_crapepr;
      END IF;
      -- Busca flag de debito em conta da empresa
       OPEN cr_crapemp;
      FETCH cr_crapemp
        INTO vr_flgpagto_emp,vr_flgpgtib_emp;
      -- Se encontrou registro e o tipo de d�bito for Conta (0-False)
      IF cr_crapemp%FOUND
         AND (vr_flgpagto_emp = 0 OR vr_flgpgtib_emp = 0) THEN
        -- Desconsiderar o dia para pagamento enviado
        pr_diapagto := 0;
      END IF;
      CLOSE cr_crapemp;
      -- Se foi enviado dia para pagamento and o tipo de d�bito do empr�stimo for Conta (0-False)
      IF pr_diapagto > 0
         AND rw_crapepr.flgpagto = 0 THEN
        -- Desconsiderar o dia enviado
        pr_diapagto := 0;
      END IF;
      -- Inciando variaveis auxiliares ao calculo --
      -- Data do processo inicia com a data enviada
      vr_dtmvtolt := pr_rw_crapdat.dtmvtolt;
      -- Flag de conta migrada
      vr_flctamig := FALSE;
      -- M�s anterior ao movimento
      vr_dtmesant := vr_dtmvtolt - to_char(vr_dtmvtolt, 'dd');
      -- Se a data de contrata��o do empr�stimo estiver no m�s corrente do movimento
      IF trunc(rw_crapepr.dtmvtolt, 'mm') = trunc(vr_dtmvtolt, 'mm') THEN
        -- Retornar o dia da data de contrata��o
        vr_nrdiacal := to_char(rw_crapepr.dtmvtolt, 'dd');
      ELSE
        -- N�o h� dias em atraso
        vr_nrdiacal := 0;
      END IF;
      -- ???
      vr_inhst093 := FALSE;
      -- Zerar juros calculados, qtdes e valor pago no m�s
      vr_vljurmes := 0;
      pr_vlprepag := 0;
      pr_qtprecal := 0;
      vr_qtprepag := 0;
      vr_qtdpgmes := 0;
      -- Se estiver rodando no Batch e � processo mensal
      IF pr_rw_crapdat.inproces > 2
         AND pr_cdprogra IN ('CRPS080', 'CRPS085', 'CRPS120') THEN
        -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes pr�ximo dia
        IF TRUNC(vr_dtmvtolt, 'mm') <> TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
          -- Data de movimento e do m�s anterior recebem o ultimo dia do m�s
          -- corrente da data de movimento passada originalmente
          vr_dtmvtolt := pr_rw_crapdat.dtultdia;
          vr_dtmesant := pr_rw_crapdat.dtultdia;
          -- Zerar n�mero de dias para c�lculo
          vr_nrdiacal := 0;
        END IF;
      END IF;
      -- Se o empr�stimo est� liquidado e n�o existe saldo devedor
      IF rw_crapepr.inliquid = 1
         AND NVL(pr_vlsdeved, 0) = 0 THEN
        -- Verificar se existe registro de conta transferida entre
        -- cooperativas com tipo de transfer�ncia = 1 (Conta Corrente)
        OPEN cr_craptco;
        FETCH cr_craptco
          INTO vr_ind_tco;
        -- Se encontrar algum registro
        IF cr_craptco%FOUND THEN
          -- Verifica se existe o movimento 921 - zerado pela migracao
          OPEN cr_craplem_his(pr_cdhistor => 921);
          FETCH cr_craplem_his
            INTO vr_fllemhis;
          -- Se tiver encontrado
          IF cr_craplem_his%FOUND THEN
            -- Indica que a conta foi migrada
            vr_flctamig := TRUE;
          END IF;
          -- Limpar var e fechar cursor
          vr_fllemhis := NULL;
          CLOSE cr_craplem_his;
        END IF;
        CLOSE cr_craptco;
      END IF;
      -- Somente buscar os pagamentos se a conta n�o foi migrada
      IF NOT vr_flctamig THEN
        -- Buscar todos os pagamentos do empr�stimo
        FOR rw_craplem IN cr_craplem(pr_dtmvtolt => vr_dtmesant) LOOP
        
          -- Calcula percentual pago na prestacao e/ou acerto --
        
          -- Se o pagamento for de algum dos tipos abaixo
          ------ --------------------------------------------------
          --  88 ESTORNO PAGTO
          --  91 PG. EMPR. C/C
          --  92 PG. EMPR. CX.
          --  93 PG. EMPR. FP.
          --  94 DESC/ABON.EMP
          --  95 PG. EMPR. C/C
          -- 120 SOBRAS EMPR.
          -- 277 ESTORNO JUROS
          -- 349 TRF. PREJUIZO
          -- 353 TRANSF. COTAS
          -- 392 ABAT.CONCEDID
          -- 393 PAGTO AVALIST
          -- 507 EST.TRF.COTAS
          IF rw_craplem.cdhistor IN
             (88, 91, 92, 93, 94, 95, 120, 277, 349, 353, 392, 393, 507) THEN
            -- Zerar quantidade paga
            vr_qtprepag := 0;
            -- Garantir que n�o haja divis�o por zero
            IF rw_craplem.vlpreemp > 0 THEN
              -- Quantidade paga � a divis�o do lan�amento pelo valor da presta��o
              vr_qtprepag := ROUND(rw_craplem.vllanmto /
                                   rw_craplem.vlpreemp
                                  ,4);
            END IF;
            -- Para os movimentos
            ------ --------------------------------------------------
            --  88 ESTORNO PAGTO
            -- 120 SOBRAS EMPR.
            -- 507 EST.TRF.COTAS
            IF rw_craplem.cdhistor IN (88, 120, 507) THEN
              -- N�o considerar este pagamento para abatimento de presta��es
              pr_qtprecal := pr_qtprecal - vr_qtprepag;
            ELSE
              -- Considera este pagamento para abatimento de presta��es
              pr_qtprecal := pr_qtprecal + vr_qtprepag;
            END IF;
          END IF;
          -- Para os tipos de movimento abaixo:
          ------ --------------------------------------------------
          --  91 PG. EMPR. C/C
          --  92 PG. EMPR. CX.
          --  94 DESC/ABON.EMP
          -- 277 ESTORNO JUROS
          -- 349 TRF. PREJUIZO
          -- 353 TRANSF. COTAS
          -- 392 ABAT.CONCEDID
          -- 393 PAGTO AVALIST
          IF rw_craplem.cdhistor IN (91, 92, 94, 277, 349, 353, 392, 393) THEN
            -- Guardar data do ultimo pagamento
            pr_dtultpag := rw_craplem.dtmvtolt;
            -- Se houver saldo devedor
            IF pr_vlsdeved > 0 THEN
              -- Se o dia para calculo for superior ao dia de lan�amento do emprestimo
              IF vr_nrdiacal > rw_craplem.ddlanmto THEN
                -- Utilizar o valor de lan�amento para calculo dos juros
                vr_vljurmes := vr_vljurmes +
                               (rw_craplem.vllanmto * pr_txdjuros *
                               (rw_craplem.ddlanmto - vr_nrdiacal));
              ELSE
                -- Utilizar o saldo devedor j� acumulado
                vr_vljurmes := vr_vljurmes +
                               (pr_vlsdeved * pr_txdjuros *
                               (rw_craplem.ddlanmto - vr_nrdiacal));
              END IF;
            END IF;
            -- Atualizando nro do dia para calculo
            -- Caso o dia seja superior ao dia do pagamento
            IF vr_nrdiacal > rw_craplem.ddlanmto THEN
              -- Mantem o mesmo valor
              vr_nrdiacal := vr_nrdiacal;
            ELSE
              -- Utilizar o dia do empr�stimo
              vr_nrdiacal := rw_craplem.ddlanmto;
            END IF;
            -- Diminuir saldo devedor
            pr_vlsdeved := NVL(pr_vlsdeved, 0) - rw_craplem.vllanmto;
            -- Acumular valor presta��o pagos
            pr_vlprepag := pr_vlprepag + rw_craplem.vllanmto;
            -- Acumular n�mero de pagamentos no m�s
            vr_qtdpgmes := vr_qtdpgmes + 1;
            -- Incluir lan�amento no vetor de pagamentos
            vr_vet_vlrpgmes(vr_qtdpgmes) := rw_craplem.vllanmto;
            -- Para os tipos abaixo relacionados
            -- --- --------------------------------------------------
            --  93 PG. EMPR. FP.
            --  95 PG. EMPR. C/C
          ELSIF rw_craplem.cdhistor IN (93, 95) THEN
            -- Guardar data do ultimo pagamento
            pr_dtultpag := rw_craplem.dtmvtolt;
            -- Se o dia do lan�amento � superior ao dia de pagamento passado
            IF rw_craplem.ddlanmto > pr_diapagto THEN
              -- Se houver saldo devedor
              IF pr_vlsdeved > 0 THEN
                -- Acumular os juros
                vr_vljurmes := vr_vljurmes +
                               (pr_vlsdeved * pr_txdjuros *
                               (rw_craplem.ddlanmto - vr_nrdiacal));
                -- Dia calculo recebe o dia do lan�amento
                vr_nrdiacal := rw_craplem.ddlanmto;
              ELSE
                -- Dia calculo recebe o dia do lan�amento
                vr_nrdiacal := rw_craplem.ddlanmto;
              END IF;
            ELSE
              -- Se houver saldo devedor
              IF pr_vlsdeved > 0 THEN
                -- Acumular os juros
                vr_vljurmes := vr_vljurmes + (pr_vlsdeved * pr_txdjuros *
                               (pr_diapagto - vr_nrdiacal));
                -- Dia calculo recebe o dia do pagamento enviado
                vr_nrdiacal := pr_diapagto;
                -- ???
                vr_inhst093 := TRUE;
              ELSE
                -- Dia calculo recebe o dia do pagamento enviado
                vr_nrdiacal := pr_diapagto;
              END IF;
            END IF;
            -- Diminuir saldo devedor
            pr_vlsdeved := NVL(pr_vlsdeved, 0) - rw_craplem.vllanmto;
            -- Acumular valor presta��o pagos
            pr_vlprepag := pr_vlprepag + rw_craplem.vllanmto;
            -- Acumular n�mero de pagamentos no m�s
            vr_qtdpgmes := vr_qtdpgmes + 1;
            -- Incluir lan�amento no vetor de pagamentos
            vr_vet_vlrpgmes(vr_qtdpgmes) := rw_craplem.vllanmto;
            -- Para os tipos abaixo
            -- --- --------------------------------------------------
            --  88 ESTORNO PAGTO
            -- 395 SERV./TAXAS
            -- 441 JUROS S/ATRAS
            -- 443 MULTA S/ATRAS
            -- 507 EST.TRF.COTAS
          ELSIF rw_craplem.cdhistor IN (88, 395, 441, 443, 507) THEN
            -- Se ainda houver saldo devedor
            IF pr_vlsdeved > 0 THEN
              -- Se o dia do lan�amento for inferior ao dia de pagamento enviado
              IF rw_craplem.ddlanmto < pr_diapagto THEN
                -- Se o dia calculado for igual ao dia de pagamento enviado
                IF vr_nrdiacal = pr_diapagto THEN
                  -- Acumular os juros com base na taxa e na diferen�a entre o dia enviado e o do lan�amento
                  vr_vljurmes := vr_vljurmes +
                                 (rw_craplem.vllanmto * pr_txdjuros *
                                 (pr_diapagto - rw_craplem.ddlanmto));
                ELSE
                  -- Acumular os juros com base na taxa e na diferen�a entre o dia o lan�amento e o dia de c�lculo
                  vr_vljurmes := vr_vljurmes +
                                 (pr_vlsdeved * pr_txdjuros *
                                 (rw_craplem.ddlanmto - vr_nrdiacal));
                  -- Utilizar como dia de c�lculo o dia deste lan�amento
                  vr_nrdiacal := rw_craplem.ddlanmto;
                END IF;
              ELSIF rw_craplem.ddlanmto > pr_diapagto THEN
                -- Calcular o juros
                vr_vljurmes := vr_vljurmes +
                               (pr_vlsdeved * pr_txdjuros *
                               (rw_craplem.ddlanmto - vr_nrdiacal));
                -- Dia para calculo recebe o dia deste lan�amento
                vr_nrdiacal := rw_craplem.ddlanmto;
              END IF;
            ELSE
              -- Atualizando nro do dia para calculo
              -- Caso o dia seja superior ao dia do lan�amento do pagamento
              IF vr_nrdiacal > rw_craplem.ddlanmto THEN
                -- Mantem o mesmo valor
                vr_nrdiacal := vr_nrdiacal;
              ELSE
                -- Utilizar o dia do empr�stimo
                vr_nrdiacal := rw_craplem.ddlanmto;
              END IF;
            END IF;
            -- Para estornos abaixo relacionados
            -- --- --------------------------------------------------
            --  88 ESTORNO PAGTO
            -- 507 EST.TRF.COTAS
            IF rw_craplem.cdhistor IN (88, 507) THEN
              -- N�o considerar este lan�amento no valor pago
              pr_vlprepag := pr_vlprepag - rw_craplem.vllanmto;
              -- Se o valor ficar negativo
              IF pr_vlprepag < 0 THEN
                -- Ent�o zera novamente
                pr_vlprepag := 0;
              END IF;
            END IF;
            -- Acumular o lan�amento no saldo devedor
            pr_vlsdeved := pr_vlsdeved + rw_craplem.vllanmto;
            -- Testar se existe pagamento com o mesmo valor no vetor de pagamentos
            vr_exipgmes := FALSE;
            -- Ler o vetor de pagamentos
            FOR vr_aux IN 1 .. vr_qtdpgmes LOOP
              -- Se o valor do vetor � igual ao do pagamento
              IF vr_vet_vlrpgmes(vr_aux) = rw_craplem.vllanmto THEN
                -- Indica que encontrou o pagamento no vetor
                vr_exipgmes := TRUE;
              END IF;
            END LOOP;
            -- Se tiver encontrado
            IF vr_exipgmes THEN
              -- Se o pagamento n�o for dos estornos abaixo relacionados
              -- --- --------------------------------------------------
              --  88 ESTORNO PAGTO
              -- 507 EST.TRF.COTAS
              IF rw_craplem.cdhistor NOT IN (88, 507) THEN
                -- Diminuir do valor acumulado pago este pagamento
                IF pr_vlprepag >= rw_craplem.vllanmto THEN
                  pr_vlprepag := pr_vlprepag - rw_craplem.vllanmto;
                ELSE
                  pr_vlprepag := 0;
                END IF;
              END IF;
            END IF;
          END IF;
        END LOOP;
      END IF;
      --
      -- Se estiver rodando no Batch
      IF pr_rw_crapdat.inproces > 2 THEN
        -- Se o processo mensal
        IF pr_cdprogra IN ('CRPS080', 'CRPS085', 'CRPS120') THEN
          -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes pr�ximo dia
          IF TRUNC(vr_dtmvtolt, 'mm') <>
             TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
            -- Zerar n�mero de dias para c�lculo
            vr_nrdiacal := 0;
          ELSE
            -- Dia para c�lculo recebe o dia enviado - o dia dalculado
            vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
          END IF;
        ELSE
          --> N�o � processo mensal
          -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes pr�ximo dia
          IF TRUNC(vr_dtmvtolt, 'mm') <>
             TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
            -- Dia para calculo recebe o ultimo dia do m�s - o dia calculado
            vr_nrdiacal := to_char(pr_rw_crapdat.dtultdia, 'dd') -
                           vr_nrdiacal;
          ELSE
            -- Dia para c�lculo recebe o dia enviado - o dia dalculado
            vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
          END IF;
        END IF;
      ELSE
        -- Dia para c�lculo recebe o dia enviado - o dia dalculado
        vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
      END IF;
      -- Se existir saldo devedor
      IF pr_vlsdeved > 0 THEN
        -- Sumarizar juros do m�s
        vr_vljurmes := vr_vljurmes +
                       (pr_vlsdeved * pr_txdjuros * vr_nrdiacal);
      END IF;
      -- Quantidade de presta��es pagas
      pr_qtprepag := TRUNC(pr_qtprecal);
      -- Zerar qtde dias para c�lculo
      vr_nrdiacal := 0;
      -- Se foi enviado data para calculo e existe saldo devedor
      IF pr_dtcalcul IS NOT NULL
         AND pr_vlsdeved > 0 THEN
        -- Dias para calculo recebe a data para calculo - dia do movimento
        vr_nrdiacal := trunc(pr_dtcalcul - vr_dtmvtolt);
        -- Se foi enviada uma data para calculo posterior ao ultimo dia do m�s corrente
        IF pr_dtcalcul > pr_rw_crapdat.dtultdia THEN
          -- Qtde dias para calculo de juros no m�s corrente
          -- � a diferen�a entre o ultimo dia - data movimento
          vr_nrdiames := TO_NUMBER(TO_CHAR(pr_rw_crapdat.dtultdia, 'DD')) -
                         TO_NUMBER(TO_CHAR(vr_dtmvtolt, 'DD'));
          -- Qtde dias para calculo de juros no pr�ximo m�s
          -- � a diferente entre o total de dias - os dias do m�s corrente
          vr_nrdiaprx := vr_nrdiacal - vr_nrdiames;
        ELSE
          --> Estamos no mesmo m�s
          -- Quantidade de dias no m�s recebe a quantidade de dias calculada
          vr_nrdiames := vr_nrdiacal;
          -- N�o existe calculo para o pr�ximo m�s
          vr_nrdiaprx := 0;
        END IF;
        -- Acumular juros com o n�mero de dias no m�s corrente
        vr_vljurmes := vr_vljurmes +
                       (pr_vlsdeved * pr_txdjuros * vr_nrdiames);
        -- Se a data enviada for do pr�ximo m�s
        IF vr_nrdiaprx > 0 THEN
          -- Arredondar os juros calculados
          vr_vljurmes := ROUND(vr_vljurmes, 2);
          -- Acumular no saldo devedor do m�s corrente os juros
          pr_vlsdeved := pr_vlsdeved + vr_vljurmes;
          -- Acumular no totalizador de juros o juros calculados
          pr_vljuracu := pr_vljuracu + vr_vljurmes;
          -- Novamente calculamos os juros, por�m somente com base nos dias do pr�ximo m�s
          vr_vljurmes := (pr_vlsdeved * pr_txdjuros * vr_nrdiaprx);
        END IF;
        -- Se o dia da data enviada for inferior ao dia para pagamento enviado
        IF to_char(pr_dtcalcul, 'dd') < pr_diapagto THEN
          -- Dias para pagamento recebe essa diferen�a
          vr_nrdiacal := pr_diapagto - to_char(pr_dtcalcul, 'dd');
        ELSE
          -- Ainda n�o venceu
          vr_nrdiacal := 0;
        END IF;
      ELSE
        -- Se o dia para c�lculo for anterior ao dia enviado para pagamento
        --  E N�o pode ser processo batch
        --  E deve haver saldo devedor
        --  E n�o pode ser inhst093 - ???
        IF to_char(vr_dtmvtolt, 'dd') < pr_diapagto
           AND pr_rw_crapdat.inproces < 3
           AND pr_vlsdeved > 0
           AND NOT vr_inhst093 THEN
          -- Dia para calculo recebe o dia enviado - dia da data de movimento
          vr_nrdiacal := pr_diapagto - to_char(vr_dtmvtolt, 'dd');
        ELSE
          -- Dia para calculo permanece zerado
          vr_nrdiacal := 0;
        END IF;
      END IF;
      -- Calcula juros sobre a prest. quando a consulta � menor que o data pagto
      -- Se existe dias para calculo e a data de pagamento contratada � inferior ao ultimo dias do m�s corrente
      IF vr_nrdiacal > 0
         AND rw_crapepr.dtdpagto <= pr_rw_crapdat.dtultdia THEN
        -- Se o saldo devedor for superior ao valor contratado de presta��o
        IF pr_vlsdeved > rw_crapepr.vlpreemp THEN
          -- Juros no m�s s�o baseados no valor contratado
          vr_vljurmes := vr_vljurmes +
                         (rw_crapepr.vlpreemp * pr_txdjuros * vr_nrdiacal);
        ELSE
          -- Juros no m�s s�o baseados no saldo devedor
          vr_vljurmes := vr_vljurmes +
                         (pr_vlsdeved * pr_txdjuros * vr_nrdiacal);
        END IF;
      END IF;
      -- Arredondar juros no m�s
      vr_vljurmes := ROUND(vr_vljurmes, 2);
      -- Acumular juros calculados
      pr_vljuracu := pr_vljuracu + vr_vljurmes;
      -- Incluir no saldo devedor os juros do m�s
      pr_vlsdeved := pr_vlsdeved + vr_vljurmes;
      -- Se houver indica��o de liquida��o do empr�stimo
      -- E ainda existe saldo devedor
      IF pr_vlsdeved > 0
         AND rw_crapepr.inliquid > 0 THEN
        -- Se estiver rodando o processo batch no programa crps078
        IF pr_rw_crapdat.inproces > 2
           AND pr_cdprogra = 'CRPS078' THEN
          -- Se os juros do m�s forem iguais ou superiores ao saldo devedor
          IF vr_vljurmes >= pr_vlsdeved THEN
            -- Remover dos juros do m�s e do juros acumulados o saldo devedor
            vr_vljurmes := vr_vljurmes - pr_vlsdeved;
            pr_vljuracu := pr_vljuracu - pr_vlsdeved;
            -- Zerar o saldo devedor
            pr_vlsdeved := 0;
          ELSE
            -- Gerar cr�tica
            vr_des_erro := 'ATENCAO: NAO FOI POSSIVEL ZERAR O SALDO - ' ||
                           ' CONTA = ' ||
                           gene0002.fn_mask_conta(rw_crapepr.nrdconta) ||
                           ' CONTRATO = ' ||
                           gene0002.fn_mask_contrato(rw_crapepr.nrctremp) ||
                           ' SALDO = ' ||
                           TO_CHAR(pr_vlsdeved, 'B999g990d00');
            RAISE vr_exc_erro;
          END IF;
        ELSE
          -- Remover dos juros do m�s e do juros acumulados o saldo devedor
          vr_vljurmes := vr_vljurmes - pr_vlsdeved;
          pr_vljuracu := pr_vljuracu - pr_vlsdeved;
          -- Zerar o saldo devedor
          pr_vlsdeved := 0;
        END IF;
      END IF;
      -- Copiar para a sa�da os juros calculados
      pr_vljurmes := vr_vljurmes;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a vari�vel de saida
        pr_cdcritic := NVL(pr_cdcritic, 0);
        pr_des_erro := vr_des_erro;
      WHEN OTHERS THEN
        -- Montar mensagem com o sqlerrm pois ocorreu um erro cr�tico
        pr_cdcritic := NVL(pr_cdcritic, 0);
        pr_des_erro := 'Problemas no procedimento empr0001.pc_leitura_lem. Erro: ' ||
                       sqlerrm;
    END;
  END pc_leitura_lem;

  /* Processar a rotina de leitura de pagamentos do emprestimo. */
  PROCEDURE pc_leitura_lem_car(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> C�digo do programa corrente
                              ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta
                              ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero ctrato emprestimo
                              ,pr_dtcalcul   IN DATE --> Data para calculo do emprestimo
                              ,pr_diapagto   IN OUT INTEGER --> Dia para pagamento
                              ,pr_txdjuros   IN OUT crapepr.txjuremp%TYPE --> Taxa de juros aplicada
                              ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de prestacoes calculadas ate momento
                              ,pr_qtprepag   IN OUT crapepr.qtprepag%TYPE --> Quantidade de prestacoes paga ate momento
                              ,pr_vlprepag   IN OUT craplem.vllanmto%TYPE --> Valor acumulado pago no mes
                              ,pr_vljurmes   IN OUT crapepr.vljurmes%TYPE --> Juros no mes corrente
                              ,pr_vljuracu   IN OUT crapepr.vljuracu%TYPE --> Juros acumulados total
                              ,pr_vlsdeved   IN OUT crapepr.vlsdeved%TYPE --> Saldo devedor acumulado
                              ,pr_dtultpag   IN OUT crapepr.dtultpag%TYPE --> Ultimo dia de pagamento das prestacoes
                              ,pr_qtmesdec   OUT crapepr.qtmesdec%TYPE --> Quantidade de meses decorridos
                              ,pr_vlpreapg   OUT crapepr.vlpreemp%TYPE --> Valor a pagar
                              ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Codigo da critica tratada
                              ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS --> Descricao de critica tratada
  
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_leitura_lem_car
    --   Sistema : Conta-Corrente - Cooperativa de Credito
    --   Sigla   : CRED
    --   Autor   : Jaison Fernando
    --   Data    : Maio/2016.                          Ultima atualizacao: 
    --
    --   Dados referentes ao programa:
    --   Frequencia: Sempre que for chamada.
    --   Objetivo  : Apenas fazer overload do procedimento acima e trazer novos campos.
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    DECLARE
      -- Cursor para busca dos dados de empr�stimo
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.dtmvtolt
              ,epr.dtdpagto
              ,epr.qtmesdec
              ,epr.qtpreemp
              ,epr.qtprecal
              ,epr.vlpreemp
              ,epr.flgpagto
              ,epr.inliquid
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      -- Verificar se existe aviso de d�bito em conta corrente n�o processado
      CURSOR cr_crapavs(pr_cdcooper IN crapavs.cdcooper%TYPE
                       ,pr_nrdconta IN crapavs.nrdconta%TYPE
                       ,pr_dtultdma IN crapdat.dtultdma%TYPE) IS
        SELECT 'S'
          FROM crapavs
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdhistor = 108
           AND dtrefere = pr_dtultdma --> Ultimo dia mes anterior
           AND tpdaviso = 1
           AND flgproce = 0; --> N�o processado
      vr_flghaavs CHAR(1);

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Tratamento de erros
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  PLS_INTEGER;
      vr_dscritic  VARCHAR2(4000);

      -- Variaveis
      vr_qtmesdec crapepr.qtmesdec%TYPE := 0;
      vr_vlpreapg crapepr.vlpreemp%TYPE := 0;
      vr_flgprepg BOOLEAN := FALSE;
      vr_blnfound BOOLEAN;

    BEGIN
      -- Verifica se a data esta cadastrada
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Alimenta a booleana
      vr_blnfound := BTCH0001.cr_crapdat%FOUND;
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;

      -- Leitura de pagamentos de empr�stimos { includes/lelem.i } 
      EMPR0001.pc_leitura_lem(pr_cdcooper   => pr_cdcooper
                             ,pr_cdprogra   => pr_cdprogra
                             ,pr_rw_crapdat => rw_crapdat
                             ,pr_nrdconta   => pr_nrdconta
                             ,pr_nrctremp   => pr_nrctremp
                             ,pr_dtcalcul   => pr_dtcalcul
                             ,pr_diapagto   => pr_diapagto
                             ,pr_txdjuros   => pr_txdjuros
                             ,pr_qtprecal   => pr_qtprecal
                             ,pr_qtprepag   => pr_qtprepag
                             ,pr_vlprepag   => pr_vlprepag
                             ,pr_vljurmes   => pr_vljurmes
                             ,pr_vljuracu   => pr_vljuracu
                             ,pr_vlsdeved   => pr_vlsdeved
                             ,pr_dtultpag   => pr_dtultpag
                             ,pr_cdcritic   => vr_cdcritic
                             ,pr_des_erro   => vr_dscritic);
      -- Se a rotina retornou com erro
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        -- Gerar exce��o
        RAISE vr_exc_erro;
      END IF;

      -- Busca dos detalhes do empr�stimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      -- Alimenta a booleana
      vr_blnfound := cr_crapepr%FOUND;
      -- Fechar o cursor
      CLOSE cr_crapepr;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 356;
        RAISE vr_exc_erro;
      END IF;
      
      -- Se o empr�stimo n�o estiver liquidado
      IF rw_crapepr.inliquid = 0 THEN
        -- Acumular a quantidade calculada com a da tabela
        pr_qtprecal := rw_crapepr.qtprecal + pr_qtprecal;
      ELSE
        -- Utilizar apenas a quantidade de parcelas
        pr_qtprecal := rw_crapepr.qtpreemp;
      END IF;

      IF rw_crapepr.flgpagto = 0 THEN
        -- Se a parcela vence no m�s corrente
        IF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapepr.dtdpagto,'mm') THEN
          -- Se ainda n�o foi pago
          IF rw_crapepr.dtdpagto <= rw_crapdat.dtmvtolt THEN
            -- Incrementar a quantidade de parcelas
            vr_qtmesdec := rw_crapepr.qtmesdec + 1;
          ELSE
            -- Consideramos a quantidade j� calculadao
            vr_qtmesdec := rw_crapepr.qtmesdec;
          END IF;
        -- Se foi paga no m�s corrente
        ELSIF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapepr.dtmvtolt,'mm') THEN
          -- Se for um contrato do m�s
          IF to_char(rw_crapepr.dtdpagto,'mm') = to_char(rw_crapdat.dtmvtolt,'mm') THEN
            -- Devia ter pago a primeira no mes do contrato
            vr_qtmesdec := rw_crapepr.qtmesdec + 1;
          ELSE
            -- Paga a primeira somente no mes seguinte
            vr_qtmesdec := rw_crapepr.qtmesdec;
          END IF;
        ELSE
          -- Se a parcela vai vencer E foi paga antes da data corrente
          IF ((rw_crapepr.dtdpagto > rw_crapdat.dtmvtolt) OR 
              (rw_crapepr.dtdpagto < rw_crapdat.dtmvtolt AND to_char(rw_crapepr.dtdpagto,'dd') <= to_char(rw_crapdat.dtmvtolt,'dd'))) THEN
            -- Incrementar a quantidade de parcelas
            vr_qtmesdec := rw_crapepr.qtmesdec + 1;
          ELSE
            -- Consideramos a quantidade j� calculadao
            vr_qtmesdec := rw_crapepr.qtmesdec;
          END IF;
        END IF;
      ELSE
        --> Para desconto em folha
        -- Para contratos do Mes
        IF trunc(rw_crapepr.dtmvtolt, 'mm') = trunc(rw_crapdat.dtmvtolt, 'mm') THEN
          -- Ainda nao atualizou o qtmesdec
          vr_qtmesdec := rw_crapepr.qtmesdec;
        ELSE
          -- Verificar se existe aviso de d�bito em conta corrente n�o processado
          vr_flghaavs := 'N';
          OPEN cr_crapavs(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dtultdma => rw_crapdat.dtultdma);
          FETCH cr_crapavs
            INTO vr_flghaavs;
          CLOSE cr_crapavs;
          -- Se houve
          IF vr_flghaavs = 'S' THEN
            -- Utilizar a quantidade j� calculada
            vr_qtmesdec := rw_crapepr.qtmesdec;
          ELSE
            -- Adicionar 1 m�s a quantidade calculada
            vr_qtmesdec := rw_crapepr.qtmesdec + 1;
          END IF;
        END IF;
      END IF;
      
      -- Garantir que a quantidade decorrida n�o seja negativa
      IF vr_qtmesdec < 0 THEN
        vr_qtmesdec := 0;
      END IF;
      
      pr_vlpreapg := 0;
      
      IF rw_crapepr.qtprecal > rw_crapepr.qtmesdec AND rw_crapepr.dtdpagto <= rw_crapdat.dtmvtolt AND rw_crapepr.flgpagto = 0 THEN
        pr_vlpreapg := rw_crapepr.vlpreemp - pr_vlprepag;
      ELSIF (vr_qtmesdec - pr_qtprecal) > 0 THEN
        pr_vlpreapg := (vr_qtmesdec - pr_qtprecal) * rw_crapepr.vlpreemp;
      END IF;
      
      IF vr_qtmesdec > rw_crapepr.qtpreemp OR pr_vlpreapg > pr_vlsdeved THEN
        pr_vlpreapg := pr_vlsdeved;
      END IF;
      
      IF pr_vlpreapg < 0 THEN
        pr_vlpreapg := 0;
      END IF;

      -- Retorna valores
      pr_qtmesdec := vr_qtmesdec;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos c�digo e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar mensagem com o sqlerrm pois ocorreu um erro cr�tico
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Problemas no procedimento empr0001.pc_leitura_lem_car. Erro: ' ||
                       sqlerrm;
    END;
  END pc_leitura_lem_car;

  /* Calculo de dias para pagamento de empr�stimo e juros */
  PROCEDURE pc_calc_dias360(pr_ehmensal IN BOOLEAN -- Indica se juros esta rodando na mensal
                           ,pr_dtdpagto IN INTEGER -- Dia do primeiro vencimento do emprestimo
                           ,pr_diarefju IN INTEGER -- Dia da data de refer�ncia da �ltima vez que rodou juros
                           ,pr_mesrefju IN INTEGER -- Mes da data de refer�ncia da �ltima vez que rodou juros
                           ,pr_anorefju IN INTEGER -- Ano da data de refer�ncia da �ltima vez que rodou juros
                           ,pr_diafinal IN OUT INTEGER -- Dia data final
                           ,pr_mesfinal IN OUT INTEGER -- Mes data final
                           ,pr_anofinal IN OUT INTEGER -- Ano data final
                           ,pr_qtdedias OUT INTEGER) IS -- Quantidade de dias calculada
  BEGIN
    /* .............................................................................
    
       Programa: pc_calc_dias360 (antigo b1wgen0084.p --> Dias360)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos (Supero)
       Data    : Fevereiro/2013.                         Ultima atualizacao: 05/02/2013
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : Calcular a quantidade de dias, mes e ano de juros passada
                   uma data de vencimento e uma data do ultimo pagamento
    
       Alteracoes: 05/02/2013 - Convers�o Progress >> PLSQL (Marcos-Supero)
    ............................................................................. */
    DECLARE
      -- Variaveis auxiliares ao calculo
      vr_ano_datfinal INTEGER;
      vr_mes_datfinal INTEGER;
      vr_dia_datfinal INTEGER;
      vr_ano_dtinicio INTEGER;
      vr_mes_dtinicio INTEGER;
      vr_dia_dtinicio INTEGER;
    BEGIN
      -- Copiar informa��es provenientes dos
      -- par�metros para as variaveis locais
      /* final */
      vr_ano_datfinal := pr_anofinal;
      vr_mes_datfinal := pr_mesfinal;
      vr_dia_datfinal := pr_diafinal;
      /* inicial */
      vr_ano_dtinicio := pr_anorefju;
      vr_mes_dtinicio := pr_mesrefju;
      vr_dia_dtinicio := pr_diarefju;
      -- Garantir que o dia n�o seja 31
      IF vr_dia_dtinicio = 31 THEN
        vr_dia_dtinicio := 30;
      END IF;
      IF vr_dia_datfinal = 31 THEN
        vr_dia_datfinal := 30;
      END IF;
      -- Se for o processo mensal
      IF pr_ehmensal THEN
        -- Utilizar dia 30
        vr_dia_datfinal := 30;
        -- Sen�o, se a data for superior a 28
      ELSIF pr_dtdpagto > 28 THEN
        -- Se for fevereiro, data final superior ou igual a 28 e diferente da data de pagamento
        IF vr_mes_datfinal = 2
           AND vr_dia_datfinal >= 28
           AND vr_dia_datfinal <> pr_dtdpagto THEN
          -- Se for enviado o dia de pagamento = 31
          IF pr_dtdpagto = 31 THEN
            -- Utilizar dia 30
            vr_dia_datfinal := 30;
          ELSE
            -- Utilizar o dia enviado
            vr_dia_datfinal := pr_dtdpagto;
          END IF;
        END IF;
      END IF;
      -- Se as datas est�o no mesmo ano
      IF ABS(vr_ano_datfinal - vr_ano_dtinicio) = 0 THEN
        -- Quantidade de dias recebe a quantidade de meses * 30 + diferen�a entre os dias
        pr_qtdedias := (vr_mes_datfinal - vr_mes_dtinicio) * 30 +
                       vr_dia_datfinal - vr_dia_dtinicio;
      ELSE
        -- Quantidade de dias recebe a quantidade de anos * 360 + qtde meses * 30 + diferen�a entre os dias
        pr_qtdedias := ABS(vr_ano_datfinal - vr_ano_dtinicio - 1) * 360 + 360 -
                       vr_mes_dtinicio * 30 + 30 - vr_dia_dtinicio +
                       30 * (vr_mes_datfinal - 1) + vr_dia_datfinal;
      END IF;
      -- Devolver aos par�metros as informa��es calculados
      pr_diafinal := vr_dia_datfinal;
      pr_mesfinal := vr_mes_datfinal;
      pr_anofinal := vr_ano_datfinal;
    EXCEPTION
      WHEN OTHERS THEN
        pr_qtdedias := NULL;
    END;
  END pc_calc_dias360;

  /* Calculo de juros normais */
  PROCEDURE pc_calc_juros_normais_total(pr_vlpagpar IN NUMBER -- Valor a pagar originalmente
                                       ,pr_txmensal IN NUMBER -- Valor da taxa mensal
                                       ,pr_qtdiajur IN INTEGER -- Quantidade de dias de aplica��o de juros
                                       ,pr_vljinpar OUT NUMBER) IS -- Valor com os juros aplicados
  BEGIN
    /* .............................................................................
    
       Programa: pc_calc_juros_normais_total (antigo b1wgen0084.p --> calcula_juros_normais_total)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos (Supero)
       Data    : Fevereiro/2013.                         Ultima atualizacao: 28/01/2014
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : Aplicar o % de juros de acordo com a quantidade de dias passada
    
       Alteracoes: 05/02/2013 - Convers�o Progress >> PLSQL (Marcos-Supero)
    
                   28/01/2014 - Inclus�o da fun��o fn_round para utilizar somente
                                10 casas decimais nos c�lculos, da mesma forma que
                                o progress trabalha
    ............................................................................. */
    BEGIN
      -- Aplicar sobre o valor original = EXP ((1+taxa/100),(dias_juros/30))
      pr_vljinpar := apli0001.fn_round(pr_vlpagpar *
                                       apli0001.fn_round(POWER((1 +
                                                               pr_txmensal / 100)
                                                              ,(pr_qtdiajur / 30))
                                                        ,10)
                                      ,10);
      -- Retornar apenas os juros
      pr_vljinpar := pr_vljinpar - pr_vlpagpar;
    EXCEPTION
      WHEN OTHERS THEN
        pr_vljinpar := 0;
    END;
  END pc_calc_juros_normais_total;

  /* Procedure para calcular valor antecipado de parcelas de empr�stimo */
  PROCEDURE pc_calc_antecipa_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                    ,pr_dtvencto IN crappep.dtvencto%TYPE --> Data do vencimento
                                    ,pr_vlsdvpar IN crappep.vlsdvpar%TYPE --> Valor devido parcela
                                    ,pr_txmensal IN crapepr.txmensal%TYPE --> Taxa aplicada ao empr�stimo
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento atual
                                    ,pr_dtdpagto IN crapdat.dtmvtolt%TYPE --> Data de pagamento
                                    ,pr_vlatupar OUT crappep.vlsdvpar%TYPE --> Valor atualizado da parcela
                                    ,pr_vldespar OUT crappep.vlsdvpar%TYPE --> Valor desconto da parcela
                                    ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_calc_antecipa_parcela (antigo b1wgen0084a.p --> calcula_antecipacao_parcela)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos (Supero)
       Data    : Fevereiro/2013.                         Ultima atualizacao: 05/02/2013
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : Calcular o valor de uma parcela paga antecipadamente
    
       Alteracoes:  05/02/2013 - Convers�o Progress >> Oracle PLSQL (Marcos-Supero)
    ............................................................................. */
    DECLARE
      -- variaveis auxiliares ao calculo
      vr_ndiasant INTEGER; --> Nro de dias de antecipa��o
      vr_diavenct INTEGER; --> Dia de vencimento
      vr_mesvenct INTEGER; --> Mes de vencimento
      vr_anovenct INTEGER; --> Ano de vencimento
    BEGIN
      -- Guardar dia, mes e ano separamente do vencimento
      vr_diavenct := to_char(pr_dtvencto, 'dd');
      vr_mesvenct := to_char(pr_dtvencto, 'mm');
      vr_anovenct := to_char(pr_dtvencto, 'yyyy');
      -- Chamar rotina para calcular a diferen�a de dias
      -- entre a data que deveria ter sido paga e a data paga
      empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                              ,pr_dtdpagto => to_char(pr_dtdpagto, 'dd') -- Dia do primeiro vencimento do emprestimo
                              ,pr_diarefju => to_char(pr_dtmvtolt, 'dd') -- Dia da data de refer�ncia da �ltima vez que rodou juros
                              ,pr_mesrefju => to_char(pr_dtmvtolt, 'mm') -- Mes da data de refer�ncia da �ltima vez que rodou juros
                              ,pr_anorefju => to_char(pr_dtmvtolt, 'yyyy') -- Ano da data de refer�ncia da �ltima vez que rodou juros
                              ,pr_diafinal => vr_diavenct -- Dia data final
                              ,pr_mesfinal => vr_mesvenct -- Mes data final
                              ,pr_anofinal => vr_anovenct -- Ano data final
                              ,pr_qtdedias => vr_ndiasant); -- Quantidade de dias calculada
      -- Valor atual � encontrado com a f�rmula:
      -- ROUND(VALOR_PARCELA * (  EXP(1+(TAXA_MENSAL*100) , - DIAS_ADIANTAMENTO /30),2)
      pr_vlatupar := ROUND(pr_vlsdvpar *
                           POWER(1 + (pr_txmensal / 100)
                                ,vr_ndiasant / 30 * -1)
                          ,2);
      -- Valor do desconto � igual ao valor devido - valor atualizado
      pr_vldespar := pr_vlsdvpar - pr_vlatupar;
    
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_calc_antecipa_parcela> ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END;

  /* Procedure para calcular valor antecipado parcial de parcelas de empr�stimo */
  PROCEDURE pc_calc_antec_parcel_parci(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_dtvencto IN crappep.dtvencto%TYPE --> Data do vencimento
                                      ,pr_txmensal IN crapepr.txmensal%TYPE --> Taxa aplicada ao empr�stimo
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento atual
                                      ,pr_vlpagpar IN crappep.vlsdvpar%TYPE --> Valor devido parcela
                                      ,pr_dtdpagto IN crapdat.dtmvtolt%TYPE --> Data de pagamento
                                      ,pr_vldespar OUT crappep.vlsdvpar%TYPE --> Valor desconto da parcela
                                      ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves e
  BEGIN
    /* .............................................................................
    
       Programa: pc_calc_antec_parcel_parci (antigo b1wgen0084a.p --> calcula_antecipacao_parcela_parcial)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson (AMcom)
       Data    : Marco/2015.                         Ultima atualizacao: 25/03/2015
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : Calcular o valor de uma parcela paga antecipadamente
    
       Alteracoes:  25/03/2015 - Convers�o Progress >> Oracle PLSQL (Alisson-AMcom)
    ............................................................................. */
    DECLARE
      -- variaveis auxiliares ao calculo
      vr_ndiasant INTEGER; --> Nro de dias de antecipa��o
      vr_vlpresen NUMBER;  --> Valor Presente
      vr_diavenct INTEGER; --> Dia de vencimento
      vr_mesvenct INTEGER; --> Mes de vencimento
      vr_anovenct INTEGER; --> Ano de vencimento
    BEGIN
      -- Guardar dia, mes e ano separamente do vencimento
      vr_diavenct := to_char(pr_dtvencto, 'dd');
      vr_mesvenct := to_char(pr_dtvencto, 'mm');
      vr_anovenct := to_char(pr_dtvencto, 'yyyy');
      -- Chamar rotina para calcular a diferen�a de dias
      -- entre a data que deveria ter sido paga e a data paga
      empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                              ,pr_dtdpagto => to_char(pr_dtdpagto, 'dd') -- Dia do primeiro vencimento do emprestimo
                              ,pr_diarefju => to_char(pr_dtmvtolt, 'dd') -- Dia da data de refer�ncia da �ltima vez que rodou juros
                              ,pr_mesrefju => to_char(pr_dtmvtolt, 'mm') -- Mes da data de refer�ncia da �ltima vez que rodou juros
                              ,pr_anorefju => to_char(pr_dtmvtolt, 'yyyy') -- Ano da data de refer�ncia da �ltima vez que rodou juros
                              ,pr_diafinal => vr_diavenct -- Dia data final
                              ,pr_mesfinal => vr_mesvenct -- Mes data final
                              ,pr_anofinal => vr_anovenct -- Ano data final
                              ,pr_qtdedias => vr_ndiasant); -- Quantidade de dias calculada
      -- Valor presente � encontrado com a f�rmula:
      -- ROUND(VALOR_PARCELA * (  EXP(1+(TAXA_MENSAL*100) , - DIAS_ADIANTAMENTO /30),2)
      vr_vlpresen := ROUND(pr_vlpagpar *
                           POWER(1 + (pr_txmensal / 100)
                                ,vr_ndiasant / 30),2);
      -- Valor do desconto � igual ao valor devido - valor atualizado
      pr_vldespar := nvl(vr_vlpresen,0) - nvl(pr_vlpagpar,0);
    
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_calc_antec_parcel_parci. ' ||sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_calc_antec_parcel_parci;

  /* Calculo de valor atualizado de parcelas de empr�stimo em atraso */
  PROCEDURE pc_calc_atraso_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                  ,pr_cdoperad IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                  ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                  ,pr_idorigem IN INTEGER --> Id do m�dulo de sistema
                                  ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                  ,pr_flgerlog IN VARCHAR2 --> Indicador S/N para gera��o de log
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                  ,pr_nrparepr IN INTEGER --> N�mero parcelas empr�stimo
                                  ,pr_vlpagpar IN NUMBER --> Valor a pagar originalmente
                                  ,pr_vlpagsld OUT NUMBER --> Saldo a pagar ap�s multa e juros
                                  ,pr_vlatupar OUT NUMBER --> Valor atual da parcela
                                  ,pr_vlmtapar OUT NUMBER --> Valor de multa
                                  ,pr_vljinpar OUT NUMBER --> Valor dos juros
                                  ,pr_vlmrapar OUT NUMBER --> Valor de mora
                                  ,pr_vljinp59 OUT NUMBER --> Juros quando per�odo inferior a 59 dias
                                  ,pr_vljinp60 OUT NUMBER --> Juros quando per�odo igual ou superior a 60 dias
                                  ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com poss�veis erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_calc_atraso_parcela (antigo b1wgen0084a.p --> calcula_atraso_parcela)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos (Supero)
       Data    : Fevereiro/2013.                         Ultima atualizacao: 21/05/2015
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : Atualizar o valor de parcelas em atraso
    
       Alteracoes: 05/02/2013 - Convers�o Progress >> PLSQL (Marcos-Supero)
    
                   13/05/2014 - Ajuste para buscar o prazo de tolerancia da
                                multa da tabela crapepr. (James)
    
                   13/06/2014 - Ajuste para obter o ultimo lancamento de juro
                                do contrato. (James)
    
                   01/08/2014 - Ajuste na procedure para filtrar a parcela
                                no calculo do juros de mora. (James)
                                
                   08/04/2015 - Ajuste para verificar os historicos de emprestimo e 
                                financiamento.(James)             
                                
                   21/05/2015 - Ajuste para verificar se Cobra Multa. (James)
    ............................................................................. */
    DECLARE
      -- Saida com erro op��o 2
      vr_exc_erro_2 EXCEPTION;
      -- Rowid para inser��o de log
      vr_nrdrowid ROWID;
      -- Busca dos dados de empr�stimo
      CURSOR cr_crapepr IS
        SELECT epr.dtdpagto
              ,epr.cdlcremp
              ,epr.txmensal
              ,epr.qttolatr
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
               AND epr.nrdconta = pr_nrdconta
               AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      -- Busca dos dados da parcela
      CURSOR cr_crappep IS
        SELECT pep.nrparepr
              ,pep.dtultpag
              ,pep.dtvencto
              ,pep.vlparepr
              ,pep.vlpagmta
              ,pep.vlsdvpar
              ,pep.vlsdvsji
              ,pep.vlpagmra
          FROM crappep pep
         WHERE pep.cdcooper = pr_cdcooper
               AND pep.nrdconta = pr_nrdconta
               AND pep.nrctremp = pr_nrctremp
               AND pep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
      -- Busca das linhas de cr�dito
      CURSOR cr_craplcr(pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT lcr.perjurmo,
               lcr.flgcobmu
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper
               AND lcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
    
      CURSOR cr_craplem(pr_cdcooper craplem.cdcooper%type
                       ,pr_nrdconta craplem.nrdconta%type
                       ,pr_nrctremp craplem.nrctremp%type
                       ,pr_nrparepr craplem.nrparepr%type) is
        SELECT dtmvtolt
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.nrparepr = pr_nrparepr
           AND craplem.cdhistor in (1078,1620,1077,1619);
           
      -- Variaveis auxiliares ao calculo
      vr_percmult NUMBER; --> % de multa para o calculo
      vr_nrdiamta INTEGER; --> Prazo para tolerancia da multa
      vr_prtljuro NUMBER; --> Prazo de tolerancia para incidencia de juros de mora
      vr_dtmvtolt DATE; --> Data de pagamento
      vr_diavtolt INTEGER; --> Dia do pagamento
      vr_mesvtolt INTEGER; --> Mes do pagamento
      vr_anovtolt INTEGER; --> Ano do pagamento
      vr_qtdiasld INTEGER; --> Qtde de dias de atraso
      vr_qtdianor INTEGER; --> Qtde de dias passados da data do vcto
      vr_qtdiamor NUMBER; --> Qtde de dias entre a data atual e a calculada
      vr_txdiaria NUMBER(18, 10); --> Taxa para calculo de mora
    
    BEGIN
      -- Criar um bloco para faciliar o tratamento de erro
      BEGIN
        -- Busca dos dados do empr�stimo
        OPEN cr_crapepr;
        FETCH cr_crapepr
          INTO rw_crapepr;
        -- Se n�o encontrar
        IF cr_crapepr%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crapepr;
          -- Gerar erro com critica 356
          vr_cdcritic := 356;
          vr_des_erro := gene0001.fn_busca_critica(356);
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor e continuar
          CLOSE cr_crapepr;
        END IF;
               
        -- Buscar informa��es da linha de cr�dito
        OPEN cr_craplcr(pr_cdlcremp => rw_crapepr.cdlcremp);
        FETCH cr_craplcr
          INTO rw_craplcr;
        -- Se n�o encontrar
        IF cr_craplcr%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craplcr;
          -- Gerar erro
          vr_cdcritic := 55;
          RAISE vr_exc_erro;
        ELSE
          -- Fechar o cursor
          CLOSE cr_craplcr;
        END IF;        
        
        -- Verifica se a Linha de Credito Cobra Multa
        IF rw_craplcr.flgcobmu = 1 THEN
          -- Obter o % de multa da CECRED - TAB090
          rw_craptab := NULL;
          OPEN cr_craptab(pr_cdcooper => 3 -- Fixo 3 - Cecred
                         ,pr_nmsistem => 'CRED'
                         ,pr_tptabela => 'USUARI'
                         ,pr_cdempres => 11
                         ,pr_cdacesso => 'PAREMPCTL'
                         ,pr_tpregist => 01);
          FETCH cr_craptab
            INTO rw_craptab;
          -- Se n�o encontrar
          IF cr_craptab%NOTFOUND THEN
            -- Fechar o cursor pois teremos raise
            CLOSE cr_craptab;
            -- Gerar erro com critica 55
            vr_cdcritic := 55;
            vr_des_erro := gene0001.fn_busca_critica(55);
            RAISE vr_exc_erro;
          ELSE
            -- Fecha o cursor para continuar o processo
            CLOSE cr_craptab;
          END IF;
          -- Utilizar como % de multa, as 6 primeiras posi��es encontradas
          vr_percmult := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,1,6));
        ELSE
          vr_percmult := 0;
        END IF;       
        
        -- Prazo para tolerancia da multa est� nas tr�s primeiras posi��es do campo
        vr_nrdiamta := rw_crapepr.qttolatr;
        -- Prazo de tolerancia para incidencia de juros de mora
        -- tamb�m recebe inicialmente o mesmo valor
        vr_prtljuro := vr_nrdiamta;
      
        -- Busca dos dados da parcela
        OPEN cr_crappep;
        FETCH cr_crappep
          INTO rw_crappep;
        -- Se n�o encontrar
        IF cr_crappep%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crappep;
          -- MOntar descri��o de erro
          vr_dscritic := 'Parcela nao encontrada.';
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor e continuar
          CLOSE cr_crappep;
        END IF; 
        -- Se ainda nao pagou nada da parcela
        IF rw_crappep.dtultpag IS NULL
           OR rw_crappep.dtultpag < rw_crappep.dtvencto THEN
          -- Pegar a data de vencimento dela
          vr_dtmvtolt := rw_crappep.dtvencto;
        ELSE
          -- Pegar a ultima data que pagou a parcela
          vr_dtmvtolt := rw_crappep.dtultpag;
        END IF;
        -- Dividir a data em dia/mes/ano para utiliza��o da rotina dia360
        vr_diavtolt := to_char(pr_dtmvtolt, 'dd');
        vr_mesvtolt := to_char(pr_dtmvtolt, 'mm');
        vr_anovtolt := to_char(pr_dtmvtolt, 'yyyy');
        -- Calcular quantidade de dias para o saldo devedor
        empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                                ,pr_dtdpagto => to_char(rw_crapepr.dtdpagto
                                                       ,'dd') -- Dia do primeiro vencimento do emprestimo
                                ,pr_diarefju => to_char(vr_dtmvtolt, 'dd') -- Dia da data de refer�ncia da �ltima vez que rodou juros
                                ,pr_mesrefju => to_char(vr_dtmvtolt, 'mm') -- Mes da data de refer�ncia da �ltima vez que rodou juros
                                ,pr_anorefju => to_char(vr_dtmvtolt, 'yyyy') -- Ano da data de refer�ncia da �ltima vez que rodou juros
                                ,pr_diafinal => vr_diavtolt -- Dia data final
                                ,pr_mesfinal => vr_mesvtolt -- Mes data final
                                ,pr_anofinal => vr_anovtolt -- Ano data final
                                ,pr_qtdedias => vr_qtdiasld); -- Quantidade de dias calculada
        -- Calcula quantos dias passaram do vencimento at� o parametro par_dtmvtolt
        -- Obs: Ser� usado para comparar se a quantidade de dias que passou est� dentro da toler�ncia
        vr_qtdianor := pr_dtmvtolt - rw_crappep.dtvencto;
        -- Se j� houve pagamento
        IF rw_crappep.dtultpag IS NOT NULL OR rw_crappep.vlpagmra > 0 THEN
          /* Obter ultimo lancamento de juro do contrato */
          FOR rw_craplem IN cr_craplem(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp
                                      ,pr_nrparepr => pr_nrparepr) LOOP
            
            IF rw_craplem.dtmvtolt > vr_dtmvtolt OR vr_dtmvtolt IS NULL THEN
              vr_dtmvtolt := rw_craplem.dtmvtolt;
            END IF;
            
          END LOOP; /* END FOR rw_craplem */
          
        END IF;
        -- Calcular quantidade de dias para o juros de mora desde
        -- o ultima ocorr�ncia de juros de mora/vencimento at� o par_dtmvtolt
        vr_qtdiamor := pr_dtmvtolt - vr_dtmvtolt;
        -- Se a quantidade de dias est� dentro da tolerancia
        IF vr_qtdianor <= vr_nrdiamta THEN
          -- Zerar a multa
          vr_percmult := 0;
        END IF;
        -- Calcular o valor da multa, descontando o que j� foi calculado para a parcela
        pr_vlmtapar := ROUND((rw_crappep.vlparepr * vr_percmult / 100), 2) -
                       rw_crappep.vlpagmta;
      
        -- Calcular os juros considerando o valor da parcela
        empr0001.pc_calc_juros_normais_total(pr_vlpagpar => rw_crappep.vlsdvpar -- Valor a pagar originalmente
                                            ,pr_txmensal => rw_crapepr.txmensal -- Valor da taxa mensal
                                            ,pr_qtdiajur => vr_qtdiasld -- Quantidade de dias de aplica��o de juros
                                            ,pr_vljinpar => pr_vljinpar); -- Valor com os juros aplicados
      
        -- Se a quantidade de dias de atraso for superior a 59
        /*IF vr_qtdiasld > 59 THEN
          -- Separar os juros at� 59 dias na pr_vljinp59
          empr0001.pc_calc_juros_normais_total(pr_vlpagpar => rw_crappep.vlsdvpar -- Valor a pagar originalmente
                                              ,pr_txmensal => rw_crapepr.txmensal -- Valor da taxa mensal
                                              ,pr_qtdiajur => 59                  -- Quantidade de dias de aplica��o de juros
                                              ,pr_vljinpar => pr_vljinp59);       -- Valor com os juros aplicados
        
          -- Comentado por Irlan. Nao eh necessario calcular, basta subtrair
          --   par_vljinpar - par_vljinpar
          -- O restante dos juros na pr_vljinp60, descontando os dias j� calculados acima
          -- e acumulando ao valor os juros aplicados nos primeiros 59 dias
          --empr0001.pc_calc_juros_normais_total(pr_vlpagpar => rw_crappep.vlsdvpar + pr_vljinp59 -- Valor a pagar originalmente
                                              ,pr_txmensal => rw_crapepr.txmensal -- Valor da taxa mensal
                                              ,pr_qtdiajur => vr_qtdiasld-59      -- Quantidade de dias de aplica��o de juros
                                              ,pr_vljinpar => pr_vljinp60);       -- Valor com os juros aplicados
          --vr_vljinp60 := vr_vljinpar - vr_vljinp59;
        ELSE
          -- Acumular os juros na variavel at� 59 dias
          empr0001.pc_calc_juros_normais_total(pr_vlpagpar => rw_crappep.vlsdvpar -- Valor a pagar originalmente
                                              ,pr_txmensal => rw_crapepr.txmensal -- Valor da taxa mensal
                                              ,pr_qtdiajur => vr_qtdiasld         -- Quantidade de dias de aplica��o de juros
                                              ,pr_vljinpar => pr_vljinp59);       -- Valor com os juros aplicados
        END IF;*/
        -- Atualizar o valor da parcela
        pr_vlatupar := rw_crappep.vlsdvpar + pr_vljinpar;
      
        -- Se a quantidade de dias est� dentro da tolerancia de juros de mora
        IF vr_qtdianor <= vr_prtljuro THEN
          -- Zerar o percentual de mora
          pr_vlmrapar := 0;
        ELSE
          -- TAxa de mora recebe o valor da linha de cr�dito
          vr_txdiaria := ROUND((100 * (POWER((rw_craplcr.perjurmo / 100) + 1
                                            ,(1 / 30)) - 1))
                              ,10);
          -- Dividimos por 100
          vr_txdiaria := vr_txdiaria / 100;
          -- Valor de juros de mora � relativo ao juros sem inadimplencia da parcela + taxa diaria calculada + quantidade de dias de mora
          pr_vlmrapar := round((rw_crappep.vlsdvsji * vr_txdiaria * vr_qtdiamor),2);
        END IF;
        -- Se o valor a pagar originalmente for diferente de zero
        IF pr_vlpagpar <> 0 THEN
          -- Valor a pagar - multa e juros de mora
          pr_vlpagsld := pr_vlpagpar -
                         (ROUND(pr_vlmtapar, 2) + ROUND(pr_vlmrapar, 2));
        ELSE
          -- Utilizar o valor j� calculado anteriormente
          pr_vlpagsld := pr_vlatupar;
        END IF;
        -- Chegou ao final sem problemas, retorna OK
        pr_des_reto := 'OK';
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Retorno n�o OK
          pr_des_reto := 'NOK';
          -- Gerar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        WHEN vr_exc_erro_2 THEN
          -- Retorno n�o OK
          pr_des_reto := 'NOK';
          -- Copiar tabela de erro tempor�ria para sa�da da rotina
          pr_tab_erro := vr_tab_erro;
      END;
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                            ,pr_dstransa => 'Calcula atraso de parcela'
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_calc_atraso_parcela> ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_calc_atraso_parcela;

  /* Busca dos pagamentos das parcelas de empr�stimo prefixados*/
  PROCEDURE pc_busca_pgto_parcelas_prefix(pr_cdcooper      IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                         ,pr_cdagenci      IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                         ,pr_nrdcaixa      IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                         ,pr_nrdconta      IN crapepr.nrdconta%TYPE --> N�mero da conta
                                         ,pr_nrctremp      IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                         ,pr_rw_crapdat    IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                                         ,pr_dtmvtolt      IN DATE --> Data de movimento
                                         ,pr_vlemprst      IN crapepr.vlemprst%TYPE --> Valor do emprestioms
                                         ,pr_qtpreemp      IN crapepr.qtpreemp%TYPE --> qtd de parcelas do emprestimo
                                         ,pr_dtdpagto      IN crapepr.dtdpagto%TYPE --> data de pagamento
                                         ,pr_txmensal      IN crapepr.txmensal%TYPE --> Taxa mensal do emprestimo
                                         ,pr_cdlcremp      IN crapepr.cdlcremp%TYPE --> Taxa mensal do emprestimo
                                         ,pr_qttolatr      IN crapepr.qttolatr%TYPE --> Quantidade de dias de tolerancia no atraso da parcela
                                         ,pr_des_reto      OUT VARCHAR --> Retorno OK / NOK
                                         ,pr_tab_erro      OUT gene0001.typ_tab_erro --> Tabela com poss�ves erros
                                         ,pr_tab_calculado OUT empr0001.typ_tab_calculado) IS
    --> Tabela com totais calculados
    /* .............................................................................
    
       Programa: pc_busca_pgto_parcelas_prefix (antigo includes/b1wgen0002a.i)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago.
       Data    : 06/03/2012                         Ultima atualizacao: 21/05/2015
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : Include para busca de dados da prestacao quando tpemprst = 1.
    
       Alteracoes:  07/01/2014 - Ajuste para melhorar a performance (James).
    
                    15/01/2014 - Ajuste para inicializar as variaveis com 0 (James).
    
                    12/03/2014 - Convers�o Progress >> Oracle PLSQL (Odirlei-AMcom)
    
                    12/05/2014 - Ajuste para calcular multa e Juros de Mora (James).
    
                                 Ajuste para pegar o prazo de atraso da tabela
                                 crapepr.qttolatr e nao mais da tab089. (James)
    
                                 Ajuste para calcular o valor vencido e o valor a
                                 vencer para a tela LAUTOM. (James)
    
                                 Ajuste no calculo da tolerancia da multa e Juros
                                 de Mora.(James)
                                 
                    06/04/2015 - Ajuste para considerar o que foi pago no mes
                                 os historicos de emprestimo e financimento. (James)
                                 
                    21/05/2015 - Ajuste para verificar se a Linha de Cr�dito Cobra Multa. (James)
                    
                    09/10/2015 - Inclusao de hist�rico de estorno PP. (Oscar)
    ............................................................................. */
  
    -------------------> CURSOR <--------------------
    -- Buscar cadastro auxiliar de emprestimo
    CURSOR cr_crawepr(pr_cdcooper crawepr.cdcooper%type
                     ,pr_nrdconta crawepr.nrdconta%type
                     ,pr_nrctremp crawepr.nrctremp%type) is
      SELECT dtlibera
        FROM crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
             AND crawepr.nrdconta = pr_nrdconta
             AND crawepr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%rowtype;
  
    -- Busca as parcelas do contrato de emprestimos e seus respectivos valores
    CURSOR cr_crappep(pr_cdcooper crawepr.cdcooper%type
                     ,pr_nrdconta crawepr.nrdconta%type
                     ,pr_nrctremp crawepr.nrctremp%type) is
      SELECT nrparepr
            ,dtvencto
            ,vlsdvpar
            ,dtultpag
            ,vlparepr
            ,vlpagmta
            ,vlsdvsji
            ,vlpagmra
        FROM crappep
       WHERE crappep.cdcooper = pr_cdcooper
             AND crappep.nrdconta = pr_nrdconta
             AND crappep.nrctremp = pr_nrctremp
             AND crappep.inliquid = 0; /* nao liquidada */
  
    -- Busca Cadastro de Linhas de Credito
    CURSOR cr_craplcr(pr_cdcooper crawepr.cdcooper%type
                     ,pr_cdlcremp craplcr.cdlcremp%type) is
      SELECT perjurmo,
             flgcobmu
        FROM craplcr
       WHERE craplcr.cdcooper = pr_cdcooper
             AND craplcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%rowtype;
  
    -- Buscar Lancamentos em emprestimos
    CURSOR cr_craplem(pr_cdcooper craplem.cdcooper%type
                     ,pr_nrdconta craplem.nrdconta%type
                     ,pr_nrctremp craplem.nrctremp%type
                     ,pr_dtmvtolt craplem.dtmvtolt%type) is
      SELECT SUM(DECODE(lem.cdhistor,
                      1044,
                      lem.vllanmto,
                      1039,
                      lem.vllanmto,
                      1045,
                      lem.vllanmto,
                      1057,
                      lem.vllanmto,
                      1716,
                      lem.vllanmto * -1,
                      1707,
                      lem.vllanmto * -1,
                      1714,
                      lem.vllanmto * -1,
                      1705,
                      lem.vllanmto * -1)) as vllanmto
      FROM craplem lem
     WHERE lem.cdcooper = pr_cdcooper
       AND lem.nrdconta = pr_nrdconta
       AND lem.nrctremp = pr_nrctremp
       AND lem.nrdolote in (600012, 600013, 600031)
       AND lem.cdhistor in (1039, 1057, 1044, 1045, 1716, 1707, 1714, 1705)
       AND TO_CHAR(lem.dtmvtolt, 'MMRRRR') = TO_CHAR(pr_dtmvtolt, 'MMRRRR');
             
    CURSOR cr_craplem_his(pr_cdcooper craplem.cdcooper%type
                         ,pr_nrdconta craplem.nrdconta%type
                         ,pr_nrctremp craplem.nrctremp%type
                         ,pr_nrparepr craplem.nrparepr%type) is
      SELECT dtmvtolt
        FROM craplem
       WHERE craplem.cdcooper = pr_cdcooper
             AND craplem.nrdconta = pr_nrdconta
             AND craplem.nrctremp = pr_nrctremp
             AND craplem.nrparepr = pr_nrparepr
             AND craplem.cdhistor in (1078,1620,1077,1619);
             
    --------------> VARIAVEIS <----------------
    vr_exec_BUSCA exception;
    --vr_vlatupar   NUMBER(11,2) := 0;
    vr_vlatupar NUMBER := 0;
    vr_vlsderel NUMBER;
    vr_qtdianor NUMBER := 0;
    vr_qtdiamor NUMBER := 0;
    vr_prtljuro NUMBER := 0;
    vr_percmult NUMBER := 0;
    vr_txdiaria NUMBER := 0;
    vr_vlpreapg NUMBER;
    --vr_vlsdeved   crapepr.vlemprst%type;
    vr_vlsdeved NUMBER := 0;
    vr_vlprepag NUMBER := 0;
    vr_dtmvtolt DATE;
    vr_dtdfinal DATE;
    vr_diafinal VARCHAR2(2); -- Dia data final
    vr_mesfinal VARCHAR2(2); -- Mes data final
    vr_anofinal VARCHAR2(4); -- Ano data final
    vr_qtdedias INTEGER;
    vr_flgtrans BOOLEAN := FALSE;
    vr_nrdiamta NUMBER := 0;
    vr_vlmtapar crappep.vlmtapar%TYPE := 0;
    vr_vlmrapar crappep.vlmrapar%TYPE := 0;
    vr_vlprvenc NUMBER := 0;
    vr_vlpraven NUMBER := 0;
  
  BEGIN

    BEGIN
      -- Busca Cadastro de Linhas de Credito
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr
        INTO rw_craplcr;
    
      IF cr_craplcr%notfound THEN
        vr_cdcritic := 363;
        CLOSE cr_craplcr;
        raise vr_exec_BUSCA;
      END IF;
      CLOSE cr_craplcr;
      
      -- Verifica se Cobra Multa
      IF rw_craplcr.flgcobmu = 1 THEN
        -- Obter o % de multa da CECRED - TAB090
        rw_craptab := NULL;
        OPEN cr_craptab(pr_cdcooper => 3 -- Fixo 3 - Cecred
                       ,pr_nmsistem => 'CRED'
                       ,pr_tptabela => 'USUARI'
                       ,pr_cdempres => 11
                       ,pr_cdacesso => 'PAREMPCTL'
                       ,pr_tpregist => 01);
        FETCH cr_craptab
          INTO rw_craptab;
        -- Se n�o encontrar
        IF cr_craptab%NOTFOUND THEN
          -- Fechar o cursor pois teremos raise
          CLOSE cr_craptab;
          -- Gerar erro com critica 55
          vr_cdcritic := 55;
          vr_des_erro := gene0001.fn_busca_critica(55);
          RAISE vr_exc_erro;
        ELSE
          -- Fecha o cursor para continuar o processo
          CLOSE cr_craptab;
        END IF;
        
        -- Utilizar como % de multa, as 6 primeiras posi��es encontradas
        vr_percmult := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,1,6));
      ELSE  
        vr_percmult := 0;
      END IF;        
      
      -- Prazo para tolerancia da multa
      vr_nrdiamta := pr_qttolatr;
      -- Prazo de tolerancia para incidencia de juros de mora
      vr_prtljuro := vr_nrdiamta;
    
      -- Buscar cadastro auxiliar de emprestimo
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr
        INTO rw_crawepr;
      -- Se n�o encotrou, incluir critica e sair do controle
      IF cr_crawepr%NOTFOUND THEN
        vr_cdcritic := 535;
        close cr_crawepr;
        raise vr_exec_BUSCA;
      END IF;
      CLOSE cr_crawepr;  
      
      -- Busca Contem as parcelas do contrato de emprestimos e seus respectivos valores
      FOR rw_crappep IN cr_crappep(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp) LOOP
      
        IF pr_dtmvtolt <= rw_crawepr.dtlibera THEN
          /* Nao liberado */
          vr_vlatupar := nvl(pr_vlemprst, 0) / nvl(pr_qtpreemp, 0);
        
        ELSIF rw_crappep.dtvencto > pr_rw_crapdat.dtmvtoan
              AND rw_crappep.dtvencto <= pr_dtmvtolt THEN
          /* Parcela em dia */
          vr_vlatupar := rw_crappep.vlsdvpar;
          vr_vlpreapg := nvl(vr_vlpreapg, 0) + nvl(vr_vlatupar, 0);
          vr_vlpraven := nvl(vr_vlpraven, 0) + nvl(vr_vlatupar, 0);
        
        ELSIF rw_crappep.dtvencto < pr_dtmvtolt THEN
          /* Parcela Vencida */
          /* Se ainda nao pagou nada da parcela, pegar a data
          de vencimento dela */
          IF rw_crappep.dtultpag is null
             OR rw_crappep.dtultpag < rw_crappep.dtvencto THEN
            vr_dtmvtolt := rw_crappep.dtvencto;
          ELSE
            /* Senao pegar a ultima data que pagou a parcela  */
            vr_dtmvtolt := rw_crappep.dtultpag;
          END IF;
        
          vr_diafinal := to_char(pr_dtmvtolt, 'dd'); -- Dia data final
          vr_mesfinal := to_char(pr_dtmvtolt, 'MM'); -- Mes data final
          vr_anofinal := to_char(pr_dtmvtolt, 'yyyy'); -- Ano data final
        
          -- Calcular quantidade de dias para o saldo devedor
          empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                                  ,pr_dtdpagto => to_char(pr_dtdpagto, 'dd') -- Dia do primeiro vencimento do emprestimo
                                  ,pr_diarefju => to_char(vr_dtmvtolt, 'dd') -- Dia da data de refer�ncia da �ltima vez que rodou juros
                                  ,pr_mesrefju => to_char(vr_dtmvtolt, 'mm') -- Mes da data de refer�ncia da �ltima vez que rodou juros
                                  ,pr_anorefju => to_char(vr_dtmvtolt
                                                         ,'yyyy') -- Ano da data de refer�ncia da �ltima vez que rodou juros
                                  ,pr_diafinal => vr_diafinal -- Dia data final
                                  ,pr_mesfinal => vr_mesfinal -- Mes data final
                                  ,pr_anofinal => vr_anofinal -- Ano data final
                                  ,pr_qtdedias => vr_qtdedias); -- Quantidade de
        
          /* Calcula quantos dias passaram do vencimento at� o parametro par_dtmvtolt ser� usado para comparar se a quantidade de
          dias que passou est� dentro da toler�ncia */
          vr_qtdianor := pr_dtmvtolt - rw_crappep.dtvencto;
          /* Se ainda nao pagou nada da parcela, pegar a data de vencimento dela */
          IF rw_crappep.dtultpag IS NOT NULL OR rw_crappep.vlpagmra > 0 THEN
            /* Obter ultimo lancamento de juro do contrato */
            FOR rw_craplem IN cr_craplem_his(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_nrctremp => pr_nrctremp
                                            ,pr_nrparepr => rw_crappep.nrparepr) LOOP                                            
              
              IF rw_craplem.dtmvtolt > vr_dtmvtolt OR vr_dtmvtolt IS NULL THEN
                vr_dtmvtolt := rw_craplem.dtmvtolt;
              END IF;
              
            END LOOP; /* END FOR rw_craplem */
            
          END IF; /* END IF rw_crappep.dtultpag IS NOT NULL */
        
          /* Calcular quantidade de dias para o juros de mora desde
          o ultima ocorr�ncia de juros de mora/vencimento at� o
          par_dtmvtolt */
          vr_qtdiamor := pr_dtmvtolt - vr_dtmvtolt;
          /* Verifica se esta na tolerancia da multa, aux_qtdianor � quantidade de dias que passaram
          aux_nrdiamta � quantidade de dias de toler�ncia parametrizada */
          IF vr_qtdianor <= vr_nrdiamta THEN
            vr_percmult := 0;
          END IF;
        
          -- Valor da Multa
          vr_vlmtapar := vr_vlmtapar +
                         apli0001.fn_round(nvl(rw_crappep.vlparepr, 0) *
                                           nvl(vr_percmult, 0) / 100
                                          ,2) - nvl(rw_crappep.vlpagmta, 0);
          -- acrescentar as taxas conforme a qtd de meses
          vr_vlatupar := apli0001.fn_round(rw_crappep.vlsdvpar *
                                           POWER((1 +
                                                 nvl(pr_txmensal, 0) / 100)
                                                ,(nvl(vr_qtdedias, 0) / 30))
                                          ,2);
        
          vr_vlpreapg := apli0001.fn_round(nvl(vr_vlpreapg, 0) +
                                           nvl(vr_vlatupar, 0)
                                          ,2);
          -- Valor a Vencer
          vr_vlprvenc := vr_vlprvenc + vr_vlatupar;
          /* Verifica se esta na tolerancia dos juros de mora, aux_qtdianor � quantidade de dias que passaram
          aux_prtljuro � quantidade de dias de toler�ncia parametrizada */
          IF vr_qtdianor <= vr_prtljuro THEN
            vr_vlmrapar := vr_vlmrapar + 0;
          ELSE
            vr_txdiaria := apli0001.fn_round((100 *
                                             (POWER((nvl(rw_craplcr.perjurmo
                                                         ,0) / 100) + 1
                                                    ,(1 / 30)) - 1))
                                            ,10);
            vr_txdiaria := vr_txdiaria / 100;
            vr_vlmrapar := vr_vlmrapar +
                           (nvl(rw_crappep.vlsdvsji, 0) *
                           nvl(vr_txdiaria, 0) * nvl(vr_qtdiamor, 0));
          END IF;
        
        ELSIF rw_crappep.dtvencto > pr_dtmvtolt THEN
          /* Parcela a Vencer */
        
          vr_diafinal := to_char(rw_crappep.dtvencto, 'dd'); -- Dia data final
          vr_mesfinal := to_char(rw_crappep.dtvencto, 'MM'); -- Mes data final
          vr_anofinal := to_char(rw_crappep.dtvencto, 'yyyy'); -- Ano data final
        
          -- Calcular quantidade de dias para o saldo devedor
          empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                                  ,pr_dtdpagto => to_char(pr_dtdpagto, 'dd') -- Dia do primeiro vencimento do emprestimo
                                  ,pr_diarefju => to_char(pr_dtmvtolt, 'dd') -- Dia da data de refer�ncia da �ltima vez que rodou juros
                                  ,pr_mesrefju => to_char(pr_dtmvtolt, 'mm') -- Mes da data de refer�ncia da �ltima vez que rodou juros
                                  ,pr_anorefju => to_char(pr_dtmvtolt
                                                         ,'yyyy') -- Ano da data de refer�ncia da �ltima vez que rodou juros
                                  ,pr_diafinal => vr_diafinal -- Dia data final
                                  ,pr_mesfinal => vr_mesfinal -- Mes data final
                                  ,pr_anofinal => vr_anofinal -- Ano data final
                                  ,pr_qtdedias => vr_qtdedias); -- Quantidade de
        
          -- acrescentar as taxas conforme a qtd de meses
          vr_vlatupar := apli0001.fn_round(rw_crappep.vlsdvpar *
                                           POWER((1 +
                                                 nvl(pr_txmensal, 0) / 100)
                                                ,(nvl(vr_qtdedias, 0) / 30) * -1)
                                          ,2);
        
          /* Valor a vencer dentro do mes */
          IF ((to_char(rw_crappep.dtvencto, 'MM') =
             to_char(pr_dtmvtolt, 'MM')) AND
             (to_char(rw_crappep.dtvencto, 'RRRR') =
             to_char(pr_dtmvtolt, 'RRRR'))) THEN
            vr_vlpraven := nvl(vr_vlpraven, 0) +
                           nvl(rw_crappep.vlsdvpar, 0);
          END IF;
        
        END IF;
      
        IF (pr_dtmvtolt > rw_crawepr.dtlibera) THEN
          /* Se liberado */
          /* Saldo devedor */
          vr_vlsderel := nvl(vr_vlsderel, 0) + nvl(vr_vlatupar, 0);
        END IF;
      
      END LOOP; /* Fim loop crappep */
    
      /* Total pago no mes */
      FOR rw_craplem IN cr_craplem(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp
                                  ,pr_dtmvtolt => pr_dtmvtolt) LOOP
        
        vr_vlprepag := nvl(vr_vlprepag, 0) + nvl(rw_craplem.vllanmto, 0);
      END LOOP;
      
      IF pr_dtmvtolt <= rw_crawepr.dtlibera AND
         rw_crapepr.inliquid <> 1 THEN
        /* Nao liberado */
        vr_vlsdeved := pr_vlemprst;
        vr_vlprepag := 0;
        vr_vlpreapg := 0;
      ELSE
        vr_vlsdeved := vr_vlsderel;
      END IF;
    
      vr_flgtrans := TRUE;
    EXCEPTION
      WHEN vr_exec_busca THEN
        NULL;
    END; /* END BUSCA */
  
    IF NOT vr_flgtrans THEN
      pr_des_reto := 'NOK';
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    END IF;
  
    -- Utilizar informa��es do c�lculo
    pr_tab_calculado(1).vlsdeved := vr_vlsdeved;
    pr_tab_calculado(1).vlsderel := vr_vlsderel;
  
    pr_tab_calculado(1).vlprepag := vr_vlprepag;
    pr_tab_calculado(1).vlpreapg := vr_vlpreapg;
    -- Copiar qtde presta��es calculadas
    pr_tab_calculado(1).qtprecal := rw_crapepr.qtprecal;
    pr_tab_calculado(1).vlmtapar := vr_vlmtapar;
    pr_tab_calculado(1).vlmrapar := vr_vlmrapar;
    pr_tab_calculado(1).vlprvenc := vr_vlprvenc;
    pr_tab_calculado(1).vlpraven := vr_vlpraven;
  
  EXCEPTION
  
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_busca_pgto_parcelas_prefix> ' ||
                     sqlerrm;
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
  END pc_busca_pgto_parcelas_prefix;

  /* Busca dos pagamentos das parcelas de empr�stimo */
  PROCEDURE pc_busca_pgto_parcelas(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_cdagenci        IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                  ,pr_nrdcaixa        IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                  ,pr_cdoperad        IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                  ,pr_nmdatela        IN VARCHAR2 --> Nome da tela
                                  ,pr_idorigem        IN INTEGER --> Id do m�dulo de sistema
                                  ,pr_nrdconta        IN crapepr.nrdconta%TYPE --> N�mero da conta
                                  ,pr_idseqttl        IN crapttl.idseqttl%TYPE --> Seq titula
                                  ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                  ,pr_flgerlog        IN VARCHAR2 --> Indicador S/N para gera��o de log
                                  ,pr_nrctremp        IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                  ,pr_dtmvtoan        IN crapdat.dtmvtolt%TYPE --> Data anterior
                                  ,pr_nrparepr        IN INTEGER --> N�mero parcelas empr�stimo
                                  ,pr_des_reto        OUT VARCHAR --> Retorno OK / NOK
                                  ,pr_tab_erro        OUT gene0001.typ_tab_erro --> Tabela com poss�ves erros
                                  ,pr_tab_pgto_parcel OUT empr0001.typ_tab_pgto_parcel --> Tabela com registros de pagamentos
                                  ,pr_tab_calculado   OUT empr0001.typ_tab_calculado) IS --> Tabela com totais calculados
  BEGIN
    /* .............................................................................
    
       Programa: pc_busca_pgto_parcelas (antigo b1wgen0084a.p --> busca_pagamentos_parcelas)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Edson
       Data    : Junho/2004.                         Ultima atualizacao: 08/10/2015
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : Buscar os pagamentos das parcelas de empr�stimo.
    
       Alteracoes:  Passado parametro quantidade prestacoes calculadas(Mirtes)
    
                    05/02/2013 - Convers�o Progress >> Oracle PLSQL (Marcos-Supero)
    
                    07/10/2013 - REplica��o das altera��es realizadas no Progress
    
                    14/10/2013 - Ajustado a procedure busca_pagamentos_parcelas
                                 para atualizar o valora regularizar quando a
                                 parcela estiver em dia(James).
    
                    13/06/2014 - Incluir novo historico para somar o valor total pago no mes (James)
                    
                    08/04/2015 - Ajuste para verificar os historicos de emprestimo e financiamento.(James)
                    
                    08/10/2015 - Diminuir o valor estorno no mes do valor pago no mes. (Oscar)
    ............................................................................. */
    DECLARE
      -- Saida com erro op��o 2
      vr_exc_erro_2 EXCEPTION;
      -- Rowid para inser��o de log
      vr_nrdrowid ROWID;
      -- Busca dos dados de empr�stimo
      CURSOR cr_crapepr IS
        SELECT epr.cdlcremp
              ,epr.txmensal
              ,epr.dtdpagto
              ,epr.qtprecal
              ,epr.vlemprst
              ,epr.qtpreemp
              ,epr.inliquid
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
               AND epr.nrdconta = pr_nrdconta
               AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      -- Busca dos dados de complemento do empr�stimo
      CURSOR cr_crawepr IS
        SELECT epr.dtlibera
          FROM crawepr epr
         WHERE epr.cdcooper = pr_cdcooper
               AND epr.nrdconta = pr_nrdconta
               AND epr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;      
    
      -- Indice para o Array de historicos
      vr_vllanmto   craplem.vllanmto%TYPE;
      vr_vlsdeved   NUMBER := 0; --> Saldo devedor
      vr_vlprepag   NUMBER := 0; --> Qtde parcela paga
      vr_vlpreapg   NUMBER := 0; --> Qtde parcela a pagar
      vr_vlpagsld   NUMBER := 0; --> Valor pago saldo
      vr_vlsderel   NUMBER := 0; --> Saldo para relat�rios
      vr_vlsdvctr   NUMBER := 0;
      -- Buscar todas as parcelas de pagamento
      -- do empr�stimo e seus valores
      CURSOR cr_crappep IS
        SELECT pep.cdcooper
              ,pep.nrdconta
              ,pep.nrctremp
              ,pep.nrparepr
              ,pep.vlparepr
              ,pep.vljinpar
              ,pep.vlmrapar
              ,pep.vlmtapar
              ,pep.dtvencto
              ,pep.dtultpag
              ,pep.vlpagpar
              ,pep.vlpagmta
              ,pep.vlpagmra
              ,pep.vldespar
              ,pep.vlsdvpar
              ,pep.inliquid
          FROM crappep pep
         WHERE pep.cdcooper = pr_cdcooper
               AND pep.nrdconta = pr_nrdconta
               AND pep.nrctremp = pr_nrctremp
               AND pep.inliquid = 0 -- N�o liquidada
               AND (pr_nrparepr = 0 OR pep.nrparepr = pr_nrparepr); -- Traz todas quado zero, ou somente a passada
      -- Indica para a temp-table
      vr_ind_pag NUMBER;
      -- Buscar o total pago no m�s
      CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE
                       ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
                       
      SELECT SUM(DECODE(lem.cdhistor,
                      1044,
                      lem.vllanmto,
                      1039,
                      lem.vllanmto,
                      1045,
                      lem.vllanmto,
                      1057,
                      lem.vllanmto,
                      1716,
                      lem.vllanmto * -1,
                      1707,
                      lem.vllanmto * -1,
                      1714,
                      lem.vllanmto * -1,
                      1705,
                      lem.vllanmto * -1)) as vllanmto
      FROM craplem lem
     WHERE lem.cdcooper = pr_cdcooper
       AND lem.nrdconta = pr_nrdconta
       AND lem.nrctremp = pr_nrctremp
       AND lem.nrdolote in (600012, 600013, 600031)
       AND lem.cdhistor in (1039, 1057, 1044, 1045, 1716, 1707, 1714, 1705)
       AND TO_CHAR(lem.dtmvtolt, 'MMRRRR') = TO_CHAR(pr_dtmvtolt, 'MMRRRR');
           
      rw_craplem cr_craplem%ROWTYPE;
      
    BEGIN
      --Limpar Tabelas Memoria
      pr_tab_erro.DELETE;
      pr_tab_pgto_parcel.DELETE;
      pr_tab_calculado.DELETE;
      -- Criar um bloco para faciliar o tratamento de erro
      BEGIN
        -- Busca detalhes do empr�stimo
        OPEN cr_crapepr;
        FETCH cr_crapepr
          INTO rw_crapepr;
        -- Se n�o tiver encontrado
        IF cr_crapepr%NOTFOUND THEN
          -- Fechar o cursor e gerar critica
          CLOSE cr_crapepr;
          vr_cdcritic := 356;
          RAISE vr_exc_erro;
        ELSE
          -- fechar o cursor e continuar o processo
          CLOSE cr_crapepr;
        END IF;
        -- Busca dados complementares do empr�stimo
        OPEN cr_crawepr;
        FETCH cr_crawepr
          INTO rw_crawepr;
        -- Se n�o tiver encontrado
        IF cr_crawepr%NOTFOUND THEN
          -- Fechar o cursor e gerar critica
          CLOSE cr_crawepr;
          vr_cdcritic := 535;
          RAISE vr_exc_erro;
        ELSE
          -- fechar o cursor e continuar o processo
          CLOSE cr_crawepr;
        END IF;
        
        -- Buscar todas as parcelas de pagamento
        -- do empr�stimo e seus valores
        FOR rw_crappep IN cr_crappep LOOP
          -- Criar um novo indice para a temp-table
          vr_ind_pag := pr_tab_pgto_parcel.COUNT() + 1;
          -- Copiar as informa��es da tabela para a temp-table
          pr_tab_pgto_parcel(vr_ind_pag).cdcooper := rw_crappep.cdcooper;
          pr_tab_pgto_parcel(vr_ind_pag).nrdconta := rw_crappep.nrdconta;
          pr_tab_pgto_parcel(vr_ind_pag).nrctremp := rw_crappep.nrctremp;
          pr_tab_pgto_parcel(vr_ind_pag).nrparepr := rw_crappep.nrparepr;
          pr_tab_pgto_parcel(vr_ind_pag).vlparepr := rw_crappep.vlparepr;
          pr_tab_pgto_parcel(vr_ind_pag).vljinpar := rw_crappep.vljinpar;
          pr_tab_pgto_parcel(vr_ind_pag).vlmrapar := rw_crappep.vlmrapar;
          pr_tab_pgto_parcel(vr_ind_pag).vlmtapar := rw_crappep.vlmtapar;
          pr_tab_pgto_parcel(vr_ind_pag).dtvencto := rw_crappep.dtvencto;
          pr_tab_pgto_parcel(vr_ind_pag).dtultpag := rw_crappep.dtultpag;
          pr_tab_pgto_parcel(vr_ind_pag).vlpagpar := rw_crappep.vlpagpar;
          pr_tab_pgto_parcel(vr_ind_pag).vlpagmta := rw_crappep.vlpagmta;
          pr_tab_pgto_parcel(vr_ind_pag).vlpagmra := rw_crappep.vlpagmra;
          pr_tab_pgto_parcel(vr_ind_pag).vldespar := rw_crappep.vldespar;
          pr_tab_pgto_parcel(vr_ind_pag).vlsdvpar := rw_crappep.vlsdvpar;
          pr_tab_pgto_parcel(vr_ind_pag).inliquid := rw_crappep.inliquid;
        
          -- Se ainda n�o foi liberado
          IF pr_dtmvtolt <= rw_crawepr.dtlibera THEN
            /* Nao liberado */
            pr_tab_pgto_parcel(vr_ind_pag).vlatupar := rw_crapepr.vlemprst /
                                                       rw_crapepr.qtpreemp;
            pr_tab_pgto_parcel(vr_ind_pag).vlsdvpar := pr_tab_pgto_parcel(vr_ind_pag)
                                                       .vlatupar;
            pr_tab_pgto_parcel(vr_ind_pag).vlatrpag := pr_tab_pgto_parcel(vr_ind_pag)
                                                       .vlatupar;
            -- Guardar quantidades calculadas
            vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;
          
            -- Se a parcela ainda n�o venceu
          ELSIF rw_crappep.dtvencto > pr_dtmvtoan
                AND rw_crappep.dtvencto <= pr_dtmvtolt THEN
            -- Parcela em dia
            pr_tab_pgto_parcel(vr_ind_pag).vlatupar := rw_crappep.vlsdvpar;
            -- Guardar quantidades calculadas
            vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;
          
            /* A regularizar */
            vr_vlpreapg := vr_vlpreapg + pr_tab_pgto_parcel(vr_ind_pag)
                          .vlatupar;
            -- Se a parcela est� vencida
          ELSIF rw_crappep.dtvencto < pr_dtmvtolt THEN
            -- Calculo de valor atualizado de parcelas de empr�stimo em atraso
            empr0001.pc_calc_atraso_parcela(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                           ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                                           ,pr_nrdcaixa => pr_nrdcaixa --> N�mero do caixa
                                           ,pr_cdoperad => pr_cdoperad --> C�digo do Operador
                                           ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                           ,pr_idorigem => pr_idorigem --> Id do m�dulo de sistema
                                           ,pr_nrdconta => pr_nrdconta --> N�mero da conta
                                           ,pr_idseqttl => pr_idseqttl --> Seq titula
                                           ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                           ,pr_flgerlog => pr_flgerlog --> Indicador S/N para gera��o de log
                                           ,pr_nrctremp => pr_nrctremp --> N�mero do contrato de empr�stimo
                                           ,pr_nrparepr => rw_crappep.nrparepr --> N�mero parcelas empr�stimo
                                           ,pr_vlpagpar => 0 --> Valor a pagar originalmente
                                           ,pr_vlpagsld => vr_vlpagsld --> Saldo a pagar ap�s multa e juros
                                           ,pr_vlatupar => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlatupar --> Valor atual da parcela
                                           ,pr_vlmtapar => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlmtapar --> Valor de multa
                                           ,pr_vljinpar => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vljinpar --> Valor dos juros
                                           ,pr_vlmrapar => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlmrapar --> Valor de mora
                                           ,pr_vljinp59 => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vljinp59 --> Juros quando per�odo inferior a 59 dias
                                           ,pr_vljinp60 => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vljinp60 --> Juros quando per�odo igual ou superior a 60 dias
                                           ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                           ,pr_tab_erro => vr_tab_erro); --> Tabela com poss�veis erros
            -- Testar erro
            IF vr_des_reto = 'NOK' THEN
              -- Levantar exce��o 2, onde j� temos o erro na vr_tab_erro
              RAISE vr_exc_erro_2;
            END IF;
            -- Acumular o valor a regularizar
            vr_vlpreapg := vr_vlpreapg + pr_tab_pgto_parcel(vr_ind_pag)
                          .vlatupar;
            -- Guardar quantidades calculadas
            vr_vlsdvctr := vr_vlsdvctr + pr_tab_pgto_parcel(vr_ind_pag)
                          .vlatupar;
          
            -- Antecipa��o de parcela
          ELSIF rw_crappep.dtvencto > pr_dtmvtolt THEN
            -- Procedure para calcular valor antecipado de parcelas de empr�stimo
            empr0001.pc_calc_antecipa_parcela(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                             ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                                             ,pr_nrdcaixa => pr_nrdcaixa --> N�mero do caixa
                                             ,pr_dtvencto => rw_crappep.dtvencto --> Data do vencimento
                                             ,pr_vlsdvpar => rw_crappep.vlsdvpar --> Valor devido parcela
                                             ,pr_txmensal => rw_crapepr.txmensal --> Taxa aplicada ao empr�stimo
                                             ,pr_dtmvtolt => pr_dtmvtolt --> Data do movimento atual
                                             ,pr_dtdpagto => rw_crapepr.dtdpagto --> Data de pagamento
                                             ,pr_vlatupar => pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vlatupar --> Valor atualizado da parcela
                                             ,pr_vldespar => pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vldespar --> Valor desconto da parcela
                                             ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                             ,pr_tab_erro => vr_tab_erro); --> Tabela com poss�ves erros
            -- Testar erro
            IF vr_des_reto = 'NOK' THEN
              -- Levantar exce��o 2, onde j� temos o erro na vr_tab_erro
              RAISE vr_exc_erro_2;
            END IF;
            -- Iniciar valor da flag
            pr_tab_pgto_parcel(vr_ind_pag).flgantec := TRUE;
            -- Guardar quantidades calculadas
            vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;
          END IF;
          -- Somente calcular se o empr�stimo estiver liberado
          IF NOT pr_dtmvtolt <= rw_crawepr.dtlibera THEN
            /* Se liberado */
            -- Saldo devedor
            pr_tab_pgto_parcel(vr_ind_pag).vlsdvpar := rw_crappep.vlsdvpar;
            -- Valor atual da parcela mais multa mais juros de mora
            pr_tab_pgto_parcel(vr_ind_pag).vlatrpag := NVL(pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlatupar
                                                          ,0) +
                                                       NVL(pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlmtapar
                                                          ,0) +
                                                       NVL(pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlmrapar
                                                          ,0);
            -- Saldo para relatorios
            vr_vlsderel := vr_vlsderel + pr_tab_pgto_parcel(vr_ind_pag)
                          .vlatupar;
            -- Saldo devedor total do emprestimo
            vr_vlsdeved := vr_vlsdeved + pr_tab_pgto_parcel(vr_ind_pag)
                          .vlatrpag;
          END IF;
        END LOOP;
        
        -- Limpar a vari�vel
        vr_vllanmto := 0;
        
        -- Buscar o total pago no m�s
        OPEN cr_craplem(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp
                       ,pr_dtmvtolt => pr_dtmvtolt);
        
        FETCH cr_craplem
         INTO rw_craplem;
        IF cr_craplem%FOUND THEN
          vr_vllanmto := nvl(vr_vllanmto, 0) + nvl(rw_craplem.vllanmto, 0);
        END IF;
        -- Fechar o cursor
        CLOSE cr_craplem;
        
        -- Adicionar o valor encontrado no valor pago
        vr_vlprepag := vr_vlprepag + NVL(vr_vllanmto, 0);
        -- Se o empr�stimo ainda n�o estiver liberado e n�o esteja liquidado
        IF pr_dtmvtolt <= rw_crawepr.dtlibera AND rw_crapepr.inliquid <> 1 THEN
          /* Nao liberado */
          -- Continuar com os valores da tabela
          pr_tab_calculado(1).vlsdeved := rw_crapepr.vlemprst;
          pr_tab_calculado(1).vlsderel := rw_crapepr.vlemprst;
          pr_tab_calculado(1).vlsdvctr := rw_crapepr.vlemprst;
        
          -- Zerar presta��es pagas e a pagar
          pr_tab_calculado(1).vlprepag := 0;
          pr_tab_calculado(1).vlpreapg := 0;
        ELSE
          -- Utilizar informa��es do c�lculo
          pr_tab_calculado(1).vlsdeved := vr_vlsdeved;
          pr_tab_calculado(1).vlsderel := vr_vlsderel;
          pr_tab_calculado(1).vlsdvctr := vr_vlsdvctr;
        
          pr_tab_calculado(1).vlprepag := vr_vlprepag;
          pr_tab_calculado(1).vlpreapg := vr_vlpreapg;
        END IF;
        -- Copiar qtde presta��es calculadas
        pr_tab_calculado(1).qtprecal := rw_crapepr.qtprecal;
        -- Chegou ao final sem problemas, retorna OK
        pr_des_reto := 'OK';
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Retorno n�o OK
          pr_des_reto := 'NOK';
          -- Gerar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        WHEN vr_exc_erro_2 THEN
          -- Retorno n�o OK
          pr_des_reto := 'NOK';
          -- Copiar tabela de erro tempor�ria para sa�da da rotina
          pr_tab_erro := vr_tab_erro;
      END;
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                            ,pr_dstransa => 'Busca pagamentos de parcelas'
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_busca_pgto_parcelas> ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_busca_pgto_parcelas;

  /* Buscar a configura��o de empr�stimo cfme a empresa da conta */
  PROCEDURE pc_config_empresti_empresa(pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data corrente
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da conta do empr�stim
                                      ,pr_cdempres IN crapepr.cdempres%TYPE DEFAULT NULL --> Empresa do empr�stimo ou se n�o passada do cadastro
                                      ,pr_dtcalcul OUT DATE --> Data calculada de pagamento
                                      ,pr_diapagto OUT INTEGER --> Dia de pagamento das parcelas
                                      ,pr_flgfolha OUT BOOLEAN --> Flag de desconto em folha S/N
                                      ,pr_ddmesnov OUT INTEGER --> Configura��o para m�s novo
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> C�digo da critica
                                      ,pr_des_erro OUT VARCHAR2) IS --> Retorno de Erro
  BEGIN
    /* .............................................................................
    
       Programa: pc_config_empresti_empresa (antigo b1wgen0002-->obtem-parametros-tabs)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos (Supero)
       Data    : Fevereiro/2013.                    Ultima atualizacao: 03/08/2015
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : 1 - Buscar a empresa da conta ( cfme configura��o de fisica ou juridica )
                   2 - Buscar a configura��o do empr�stimo da empresa
    
       Observa��es : As informa��es da CRAPTAB ficar�o no vetor vr_tab_DIADOPAGTO, para
                     evitar tantos acessos na tabela, que torna o processo bastante lento
    
       Alteracoes: 29/05/2012 - Incluido par�metro pr_ddmesnov para retornar os dados
                                da dstextab nas posi��es 1 e 2
    
                   20/08/2013 - Convers�o Progress >> PLSQL (Marcos-Supero)
                   
                   24/06/2015 - Ajuste para utilizar indice da tabela temporario com o 
                                codigo da cooperativa juntamente com o codigo da empresa
                                na tabela vr_tab_diadopagto. (Jorge/Rodrigo)
                                
                   03/08/2015 - Ajuste em adicionar NVL em dados do DIADOPAGTO.
                                (Jorge/Elton) - SD 303248
    ............................................................................. */
    DECLARE
      -- Busca dos dados do associado
      CURSOR cr_crapass IS
        SELECT ass.inpessoa
              ,ass.cdtipsfx
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
               AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      -- Busca da empresa no cadastro de titulares
      CURSOR cr_crapttl IS
        SELECT ttl.cdempres
          FROM crapttl ttl
         WHERE ttl.cdcooper = pr_cdcooper
               AND ttl.nrdconta = pr_nrdconta
               AND ttl.idseqttl = 1; --> Titular
      -- Busca da empresa no cadastro de pessoas juridicas
      CURSOR cr_crapjur IS
        SELECT jur.cdempres
          FROM crapjur jur
         WHERE jur.cdcooper = pr_cdcooper
               AND jur.nrdconta = pr_nrdconta;
      -- Empresa encontrada nos cursores acima
      vr_cdempres crapttl.cdempres%TYPE;
      vr_nrindice VARCHAR2(15);
    BEGIN 
      -- Se o vetor n�o estiver carregado para a cooperativa
      IF NOT vr_tab_diadopagto.EXISTS(pr_cdcooper) THEN
        
        --Cria um primeiro registro apenas com o indice da cooperativa, para controle
        vr_tab_diadopagto(pr_cdcooper).diapgtoh := 0;
        
        -- Busca de todos registros para atualizar o vetor
        FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper
                                    ,pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'GENERI'
                                    ,pr_cdempres => 00
                                    ,pr_cdacesso => 'DIADOPAGTO'
                                    ,pr_tpregist => NULL) LOOP
                                    
          -- Indice da tabela temporaria, cdcooper || cdempres Ex: 000010000000081
          vr_nrindice := LPAD(pr_cdcooper,5,'0') || LPAD(rw_craptab.tpregist,10,'0');
                                    
          -- Adicionar no vetor cmfe a empresa encontrada (tpregist)
          vr_tab_diadopagto(vr_nrindice).diapgtoh := NVL(TRIM(SUBSTR(
                                                     rw_craptab.dstextab,7,2)),0);
          vr_tab_diadopagto(vr_nrindice).diapgtom := NVL(TRIM(SUBSTR(
                                                     rw_craptab.dstextab,4,2)),0);
          vr_tab_diadopagto(vr_nrindice).flgfolha := NVL(TRIM(SUBSTR(
                                                     rw_craptab.dstextab,14,1)),0);
          vr_tab_diadopagto(vr_nrindice).ddmesnov := NVL(TRIM(SUBSTR(
                                                     rw_craptab.dstextab,1,2)),0);
        END LOOP;
      END IF;
      -- Busca dos dados do associado
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_crapass;
      -- Se n�o encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor para retornar
        CLOSE cr_crapass;
        -- Gerar erro com critica 9
        pr_cdcritic := 9;
        vr_des_erro := gene0001.fn_busca_critica(9);
        RAISE vr_exc_erro;
      ELSE
        -- Fechar o cursor para continuar os testes
        CLOSE cr_crapass;
        -- Se j� foi passada a empresa de busca
        IF nvl(pr_cdempres, 0) <> 0 THEN
          -- Utiliz�-la
          vr_cdempres := pr_cdempres;
        ELSE
          -- Buscaremos cfme o tipo da pessoa
          -- Para pessoa f�sica
          IF rw_crapass.inpessoa = 1 THEN
            -- Buscar empresa no cadastro de titular
            OPEN cr_crapttl;
            FETCH cr_crapttl
              INTO vr_cdempres;
            CLOSE cr_crapttl;
          ELSE
            -- Buscar empresa no cadastro de empresas
            OPEN cr_crapjur;
            FETCH cr_crapjur
              INTO vr_cdempres;
            CLOSE cr_crapjur;
          END IF;
        END IF;
      END IF;
      
      -- Indice a procurar, composto pelo codigo da empresa do cooperado
      vr_nrindice := LPAD(pr_cdcooper,5,'0') || LPAD(vr_cdempres,10,'0');
      -- Procura a empresa no vetor
      IF NOT vr_tab_diadopagto.EXISTS(vr_nrindice) THEN
        -- Gerar erro com critica 55
        pr_cdcritic := 55;
        vr_des_erro := gene0001.fn_busca_critica(55);
        RAISE vr_exc_erro;
      END IF;
      
      -- verifica se os campos estao com valor
      IF vr_tab_diadopagto(vr_nrindice).diapgtoh = 0 OR
         vr_tab_diadopagto(vr_nrindice).diapgtom = 0 OR
         vr_tab_diadopagto(vr_nrindice).ddmesnov = 0 THEN
         -- Gerar erro com critica
         pr_cdcritic := 0;
         vr_des_erro := 'Falta de dados no cadastro da empresa ' || 
                         to_char(vr_cdempres) || '.' ||
                         ' Conta: ' || to_char(pr_nrdconta) || '. ' ||
                         '(' || vr_tab_diadopagto(vr_nrindice).diapgtoh || ','
                             || vr_tab_diadopagto(vr_nrindice).diapgtom || ','
                             || vr_tab_diadopagto(vr_nrindice).ddmesnov || ')';
         RAISE vr_exc_erro;
      END IF; 
      
      -- Se o tipo de sal�rio fixo = Mensal
      IF rw_crapass.cdtipsfx IN (1, 3, 4) THEN
        -- Dia de pagamento est� no campo diaphtom
        pr_diapagto := vr_tab_diadopagto(vr_nrindice).diapgtom;
      ELSE
        -- Horista
        -- Dia de pagamento est� no campo diaphtoh
        pr_diapagto := vr_tab_diadopagto(vr_nrindice).diapgtoh;
      END IF;
      -- Retornar indicador de desconto em folha
      IF vr_tab_diadopagto(vr_nrindice).flgfolha = '1' THEN
        -- Desconto em folha
        pr_flgfolha := TRUE;
      ELSE
        -- N�o � descontado em folha
        pr_flgfolha := FALSE;
      END IF;
      -- Retornar indicador de configura��o para m�s novo
      pr_ddmesnov := vr_tab_diadopagto(vr_nrindice).ddmesnov;
      -- Montar a data de pagamento cfme o dia encontrado e o m�s e ano correntes
      pr_dtcalcul := to_date(to_char(pr_diapagto, 'fm00') || '/' ||
                             to_char(pr_dtmvtolt, 'mm/yyyy')
                            ,'dd/mm/yyyy');
      -- Garantir que a data de pamento caia em um dia util
      pr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper, pr_dtcalcul);
      -- Guardar agora o dia util do pagamento
      pr_diapagto := to_char(pr_dtcalcul, 'dd');
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a vari�vel de saida
        pr_cdcritic := NVL(pr_cdcritic, 0);
        pr_des_erro := vr_des_erro;
      WHEN OTHERS THEN
        -- Montar mensagem com o sqlerrm pois ocorreu um erro cr�tico
        pr_cdcritic := NVL(pr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina empr0001.pc_config_empresti_empresa --> Detalhes: ' ||
                       sqlerrm;
    END;
  END pc_config_empresti_empresa;

  /* Calculo de saldo devedor em emprestimos baseado na includes/lelem.i. */
  PROCEDURE pc_calc_saldo_deved_epr_lem(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> C�digo do programa corrente
                                       ,pr_cdagenci   IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                       ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                       ,pr_cdoperad   IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                       ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                                       ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> N�mero da conta
                                       ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero ctrato empr�stimo
                                       ,pr_idorigem   IN INTEGER --> Id do m�dulo de sistema
                                       ,pr_txdjuros   IN crapepr.txjuremp%TYPE --> Taxa de juros aplicada
                                       ,pr_dtcalcul   IN DATE --> Data para calculo do empr�stimo
                                       ,pr_diapagto   IN OUT INTEGER --> Dia para pagamento
                                       ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de presta��es calculadas at� momento
                                       ,pr_vlprepag   IN OUT NUMBER --> Valor acumulado pago no m�s
                                       ,pr_vlpreapg   IN OUT NUMBER --> Valor a pagar
                                       ,pr_vljurmes   IN OUT NUMBER --> Juros no m�s corrente
                                       ,pr_vljuracu   IN OUT NUMBER --> Juros acumulados total
                                       ,pr_vlsdeved   IN OUT NUMBER --> Saldo devedor acumulado
                                       ,pr_dtultpag   IN OUT crapepr.dtultpag%TYPE --> Ultimo dia de pagamento das presta��es
                                       ,pr_vlmrapar   IN OUT crappep.vlmrapar%TYPE --> Valor do Juros de Mora
                                       ,pr_vlmtapar   IN OUT crappep.vlmtapar%TYPE --> Valor da Multa
                                       ,pr_vlprvenc   IN OUT NUMBER --> Valor a parcela a vencer
                                       ,pr_vlpraven   IN OUT NUMBER --> Valor da parcela vencida
                                       ,pr_flgerlog   IN VARCHAR2 --> Gerar log S/N
                                       ,pr_des_reto   OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro   OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
       Programa: pc_calc_saldo_deved_epr_lem (antigo sistema/generico/includes/b1wgen0002.i )
       Autora  : Mirtes.
       Data    : 14/09/2005                        Ultima atualizacao: 12/09/2013
    
       Dados referentes ao programa:
    
       Objetivo  : Include para calculo de saldo devedor em emprestimos.
                   Baseado na includes/lelem.i.
    
       Alteracoes: 05/03/2008 - Adaptacao para alteracoes na BO b1wgen0002 (David).
    
                   03/06/2008 - Incluir cdcooper nos FIND's da craphis (David).
    
                   06/01/2011 - Se conta transferida nao deixar ler o craplem.
                                Lancamento do zeramento no 1 dia util (Magui).
    
                   14/02/2011 - Igualar include a lelem.i (David).
    
                   19/03/2012 - Declarar a include b1wgen0002a.i (Tiago).
    
                   18/06/2012 - Alteracao na leitura da craptco (David Kruger).
    
                   26/11/2012 - Igualar inlcude a lelem.i (Oscar).
    
                   23/04/2013 - Convers�o Progress >> Oracle PLSQL (Marcos-Supero)
    
                   26/08/2013 - Inclus�o dos c�digos de hist�ricos fixos a retornar
                                no cursor cr_craplem cfme ajuste liberado em produ��o
                                progress em 02/08/2013 (Marcos-Supero)
    
                   12/09/2013 - Ordenar cursor da craplem para ficar igual ao do
                                progress.
                                Incluir somatoria do pr_vlprepag com o valor de
                                lancamento da craplem.
    
                   12/03/2014 - Alterada a chamada para da  pc_busca_pgto_parcelas
                                 para pc_busca_pgto_parcelas_prefix (Odirlei-AMcom)
    
    ............................................................................. */
    DECLARE
      -- Busca dados espec�ficos do empr�stimo para a rotina
      CURSOR cr_crapepr IS
        SELECT tpemprst
              ,cdempres
              ,flgpagto
              ,dtmvtolt
              ,inliquid
              ,vlsdeved
              ,dtdpagto
              ,vlpreemp
              ,qtprecal
              ,vljuracu
              ,vlemprst
              ,qtpreemp
              ,txmensal
              ,cdlcremp
              ,qttolatr
          FROM crapepr
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      -- Teste de existencia de empresa
      CURSOR cr_crapemp IS
        SELECT emp.flgpagto
              ,emp.flgpgtib
          FROM crapemp emp
         WHERE emp.cdcooper = pr_cdcooper
               AND emp.cdempres = rw_crapepr.cdempres;
      vr_flgpagto_emp crapemp.flgpagto%TYPE;
      vr_flgpgtib_emp crapemp.flgpgtib%TYPE;  
      -- Verificar se existe registro de conta transferida entre
      -- cooperativas com tipo de transfer�ncia = 1 (Conta Corrente)
      CURSOR cr_craptco IS
        SELECT 1
          FROM craptco tco
         WHERE tco.cdcopant = pr_cdcooper
               AND tco.nrctaant = pr_nrdconta
               AND tco.tpctatrf = 1
               AND tco.flgativo = 1; --> True
      vr_ind_tco NUMBER(1);
      -- Buscar informa��es de pagamentos do empr�stimos
      --   Enviando uma data para filtrar movimentos posteriores a mesma
      --   -> Pode ser enviado um tipo de hist�rico para busca a partir dele
      CURSOR cr_craplem(pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
        SELECT /*+ INDEX (lem CRAPLEM##CRAPLEM6) */
               to_char(lem.dtmvtolt,'dd') ddlanmto
              ,lem.dtmvtolt
              ,lem.cdhistor
              ,lem.vlpreemp
              ,lem.vllanmto
          FROM craplem lem
         WHERE lem.cdcooper = pr_cdcooper
           AND lem.nrdconta = pr_nrdconta
           AND lem.nrctremp = pr_nrctremp
           AND lem.dtmvtolt > pr_dtmvtolt
           -- Somente retornando os tipos de hist�rico abaixo
           -- COD DESCRICAO
           --  88 ESTORNO PAGTO
           --  91 PG. EMPR. C/C
           --  92 PG. EMPR. CX.
           --  93 PG. EMPR. FP.
           --  94 DESC/ABON.EMP
           --  95 PG. EMPR. C/C
           -- 120 SOBRAS EMPR.
           -- 277 ESTORNO JUROS
           -- 349 TRF. PREJUIZO
           -- 353 TRANSF. COTAS
           -- 392 ABAT.CONCEDID
           -- 393 PAGTO AVALIST
           -- 507 EST.TRF.COTAS
           -- 395 SERV./TAXAS
           -- 441 JUROS S/ATRAS
           -- 443 MULTA S/ATRAS
           AND lem.cdhistor IN(88,91,92,93,94,95,120,277,349,353,392,393,507,395,441,443)
      ORDER BY lem.cdcooper
              ,lem.nrdconta
              ,lem.nrctremp
              ,lem.dtmvtolt
              ,lem.progress_recid
              ,lem.nrseqdig;
    
      rw_craplem cr_craplem%ROWTYPE;
      -- Buscar informa��es de pagamentos do empr�stimos
      --   Enviando um tipo de hist�rico para busca a partir dele
      CURSOR cr_craplem_his(pr_cdhistor IN craplem.cdhistor%TYPE) IS
        SELECT 1
          FROM craplem lem
         WHERE lem.cdcooper = pr_cdcooper
               AND lem.nrdconta = pr_nrdconta
               AND lem.nrctremp = pr_nrctremp
               AND lem.cdhistor = pr_cdhistor;
      vr_fllemhis NUMBER;
      -- Variaveis auxiliares
      vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel; --> Tabela com registros de pagamentos
      vr_tab_calculado   empr0001.typ_tab_calculado; --> Tabela com totais calculados
      vr_dtmvtolt        crapdat.dtmvtolt%TYPE; --> Data de movimento auxiliar
      vr_dtmesant        crapdat.dtmvtolt%TYPE; --> Data do m�s anterior ao movimento
      vr_flctamig        BOOLEAN; --> Conta migrada entre cooperativas
      vr_nrdiacal        INTEGER; --> N�mero de dias para o c�lculo
      vr_inhst093        BOOLEAN; --> ???
      TYPE vr_tab_vlrpgmes IS TABLE OF crapepr.vlpreemp%TYPE INDEX BY BINARY_INTEGER;
      vr_vet_vlrpgmes vr_tab_vlrpgmes; --> Vetor e tipo para acumulo de pagamentos no m�s
      vr_qtdpgmes     INTEGER; --> Indice de presta��es
      --vr_qtprepag NUMBER(18,4);         --> Qtde paga de presta��es no m�s
      vr_qtprepag NUMBER; --> Qtde paga de presta��es no m�s
      vr_exipgmes BOOLEAN; --> Teste para busca no vetor de pagamentos
      vr_vljurmes NUMBER; --> Juros no m�s corrente
      vr_nrdiames INTEGER; --> N�mero de dias para o c�lculo no m�s corrente
      vr_nrdiaprx INTEGER; --> N�mero de dias para o c�lculo no pr�ximo m�s
      vr_exc_erro2 EXCEPTION; --> Exception especifica quando j� existe erro na tab_erro
    BEGIN
      -- Busca dados espec�ficos do empr�stimo para a rotina
      OPEN cr_crapepr;
      FETCH cr_crapepr
        INTO rw_crapepr;
      -- Se n�o encontrar informa��es
      IF cr_crapepr%NOTFOUND THEN
        -- Fechar o cursor pois teremos raise
        CLOSE cr_crapepr;
        -- Gerar erro com critica 356
        vr_cdcritic := 356;
        vr_des_erro := gene0001.fn_busca_critica(356);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor para continuar o processo
        CLOSE cr_crapepr;
      END IF;
      -- Para empr�stimo pr�-fixado
      IF rw_crapepr.tpemprst = 1 THEN
      
        /* Busca dos pagamentos das parcelas de empr�stimo pre-fixados*/
        EMPR0001.pc_busca_pgto_parcelas_prefix(pr_cdcooper      => pr_cdcooper --> Cooperativa conectada
                                              ,pr_cdagenci      => pr_cdagenci --> C�digo da ag�ncia
                                              ,pr_nrdcaixa      => pr_nrdcaixa --> N�mero do caixa
                                              ,pr_nrdconta      => pr_nrdconta --> N�mero da conta
                                              ,pr_nrctremp      => pr_nrctremp --> N�mero do contrato de empr�stimo
                                              ,pr_rw_crapdat    => pr_rw_crapdat --> Vetor com dados de par�metro (CRAPDAT)
                                              ,pr_dtmvtolt      => pr_rw_crapdat.dtmvtolt --> Data de movimento
                                              ,pr_vlemprst      => rw_crapepr.vlemprst --> Valor do emprestioms
                                              ,pr_qtpreemp      => rw_crapepr.qtpreemp --> qtd de parcelas do emprestimo
                                              ,pr_dtdpagto      => rw_crapepr.dtdpagto --> data de pagamento
                                              ,pr_txmensal      => rw_crapepr.txmensal --> Taxa mensal do emprestimo
                                              ,pr_cdlcremp      => rw_crapepr.cdlcremp --> Taxa mensal do emprestimo
                                              ,pr_qttolatr      => rw_crapepr.qttolatr --> Quantidade de dias de tolerancia
                                              ,pr_des_reto      => vr_des_reto --> Retorno OK / NOK
                                              ,pr_tab_erro      => vr_tab_erro --> Tabela com poss�ves erros
                                              ,pr_tab_calculado => vr_tab_calculado); --> Tabela com totais calculados
      
        -- Se a rotina retornou erro
        IF vr_des_reto = 'NOK' THEN
          -- Gerar exce��o
          RAISE vr_exc_erro2;
        END IF;
        -- Copiar os valores da rotina para as variaveis de sa�da
        pr_vlsdeved := vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved;
        pr_qtprecal := vr_tab_calculado(vr_tab_calculado.FIRST).qtprecal;
        pr_vlprepag := vr_tab_calculado(vr_tab_calculado.FIRST).vlprepag;
        pr_vlpreapg := vr_tab_calculado(vr_tab_calculado.FIRST).vlpreapg;
        pr_vljuracu := rw_crapepr.vljuracu;
        pr_vlmrapar := vr_tab_calculado(vr_tab_calculado.FIRST).vlmrapar;
        pr_vlmtapar := vr_tab_calculado(vr_tab_calculado.FIRST).vlmtapar;
        pr_vlprvenc := vr_tab_calculado(vr_tab_calculado.FIRST).vlprvenc;
        pr_vlpraven := vr_tab_calculado(vr_tab_calculado.FIRST).vlpraven;
      ELSE
        -- Busca flag de debito em conta da empresa
        OPEN cr_crapemp;
        FETCH cr_crapemp
          INTO vr_flgpagto_emp,vr_flgpgtib_emp;
        -- Se encontrou registro e o tipo de d�bito for Conta (0-False)
        IF cr_crapemp%FOUND
           AND (vr_flgpagto_emp = 0 OR vr_flgpgtib_emp = 0) THEN
          -- Desconsiderar o dia para pagamento enviado
          pr_diapagto := 0;
        END IF;
        CLOSE cr_crapemp;
        -- Se foi enviado dia para pagamento and o tipo de d�bito do empr�stimo for Conta (0-False)
        IF pr_diapagto > 0
           AND rw_crapepr.flgpagto = 0 THEN
          -- Desconsiderar o dia enviado
          pr_diapagto := 0;
        END IF;
        -- Inciando variaveis auxiliares ao calculo --
        -- Data do processo inicia com a data enviada
        vr_dtmvtolt := pr_rw_crapdat.dtmvtolt;
        -- Flag de conta migrada
        vr_flctamig := FALSE;
        -- M�s anterior ao movimento
        vr_dtmesant := vr_dtmvtolt - to_char(vr_dtmvtolt, 'dd');
        -- Se a data de contrata��o do empr�stimo estiver no m�s corrente do movimento
        IF trunc(rw_crapepr.dtmvtolt, 'mm') = trunc(vr_dtmvtolt, 'mm') THEN
          -- Retornar o dia da data de contrata��o
          vr_nrdiacal := to_char(rw_crapepr.dtmvtolt, 'dd');
        ELSE
          -- N�o h� dias em atraso
          vr_nrdiacal := 0;
        END IF;
        -- Possui Historico 93
        vr_inhst093 := FALSE;
        -- Zerar juros calculados, qtdes e valor pago no m�s
        vr_vljurmes := 0;
        pr_vlprepag := 0;
        pr_vlpreapg := 0;
        pr_qtprecal := 0;
        vr_qtdpgmes := 0;
        -- Se estiver rodando no Batch e � processo mensal
        IF pr_rw_crapdat.inproces > 2
           AND pr_cdprogra IN ('CRPS080', 'CRPS085', 'CRPS120') THEN
          -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes pr�ximo dia
          IF TRUNC(vr_dtmvtolt, 'mm') <>
             TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
            -- Data de movimento e do m�s anterior recebem o ultimo dia do m�s
            -- corrente da data de movimento passada originalmente
            vr_dtmvtolt := pr_rw_crapdat.dtultdia;
            vr_dtmesant := pr_rw_crapdat.dtultdia;
            -- Zerar n�mero de dias para c�lculo
            vr_nrdiacal := 0;
          END IF;
        END IF;
        -- Se o empr�stimo est� liquidado e n�o existe saldo devedor
        IF rw_crapepr.inliquid = 1
           AND NVL(pr_vlsdeved, 0) = 0 THEN
          -- Verificar se existe registro de conta transferida entre
          -- cooperativas com tipo de transfer�ncia = 1 (Conta Corrente)
          OPEN cr_craptco;
          FETCH cr_craptco
            INTO vr_ind_tco;
          -- Se encontrar algum registro
          IF cr_craptco%FOUND THEN
            -- Verifica se existe o movimento 921 - zerado pela migracao
            OPEN cr_craplem_his(pr_cdhistor => 921);
            FETCH cr_craplem_his
              INTO vr_fllemhis;
            -- Se tiver encontrado
            IF cr_craplem_his%FOUND THEN
              -- Indica que a conta foi migrada
              vr_flctamig := TRUE;
            END IF;
            -- Limpar var e fechar cursor
            vr_fllemhis := NULL;
            CLOSE cr_craplem_his;
          END IF;
          CLOSE cr_craptco;
        END IF;
        -- Somente buscar os pagamentos se a conta n�o foi migrada
        IF NOT vr_flctamig THEN
          -- Buscar todos os pagamentos do empr�stimo
          FOR rw_craplem IN cr_craplem(pr_dtmvtolt => vr_dtmesant) LOOP
          
            -- Calcula percentual pago na prestacao e/ou acerto --
          
            -- Se o pagamento for de algum dos tipos abaixo
            ------ --------------------------------------------------
            --  88 ESTORNO PAGTO
            --  91 PG. EMPR. C/C
            --  92 PG. EMPR. CX.
            --  93 PG. EMPR. FP.
            --  94 DESC/ABON.EMP
            --  95 PG. EMPR. C/C
            -- 120 SOBRAS EMPR.
            -- 277 ESTORNO JUROS
            -- 349 TRF. PREJUIZO
            -- 353 TRANSF. COTAS
            -- 392 ABAT.CONCEDID
            -- 393 PAGTO AVALIST
            -- 507 EST.TRF.COTAS
            IF rw_craplem.cdhistor IN
               (88, 91, 92, 93, 94, 95, 120, 277, 349, 353, 392, 393, 507) THEN
              -- Zerar quantidade paga
              vr_qtprepag := 0;
              -- Garantir que n�o haja divis�o por zero
              IF rw_craplem.vlpreemp > 0 THEN
                -- Quantidade paga � a divis�o do lan�amento pelo valor da presta��o
                vr_qtprepag := ROUND(rw_craplem.vllanmto /
                                     rw_craplem.vlpreemp
                                    ,4);
              END IF;
              -- Para os movimentos
              ------ --------------------------------------------------
              --  88 ESTORNO PAGTO
              -- 120 SOBRAS EMPR.
              -- 507 EST.TRF.COTAS
              IF rw_craplem.cdhistor IN (88, 120, 507) THEN
                -- N�o considerar este pagamento para abatimento de presta��es
                pr_qtprecal := pr_qtprecal - vr_qtprepag;
              ELSE
                -- Considera este pagamento para abatimento de presta��es
                pr_qtprecal := pr_qtprecal + vr_qtprepag;
              END IF;
            END IF;
            -- Para os tipos de movimento abaixo:
            ------ --------------------------------------------------
            --  91 PG. EMPR. C/C
            --  92 PG. EMPR. CX.
            --  94 DESC/ABON.EMP
            -- 277 ESTORNO JUROS
            -- 349 TRF. PREJUIZO
            -- 353 TRANSF. COTAS
            -- 392 ABAT.CONCEDID
            -- 393 PAGTO AVALIST
            IF rw_craplem.cdhistor IN (91, 92, 94, 277, 349, 353, 392, 393) THEN
              -- Guardar data do ultimo pagamento
              pr_dtultpag := rw_craplem.dtmvtolt;
              -- Se houver saldo devedor
              IF pr_vlsdeved > 0 THEN
                -- Se o dia para calculo for superior ao dia de lan�amento do emprestimo
                IF vr_nrdiacal > rw_craplem.ddlanmto THEN
                  -- Utilizar o valor de lan�amento para calculo dos juros
                  vr_vljurmes := vr_vljurmes +
                                 (rw_craplem.vllanmto * pr_txdjuros *
                                 (rw_craplem.ddlanmto - vr_nrdiacal));
                ELSE
                  -- Utilizar o saldo devedor j� acumulado
                  vr_vljurmes := vr_vljurmes +
                                 (pr_vlsdeved * pr_txdjuros *
                                 (rw_craplem.ddlanmto - vr_nrdiacal));
                END IF;
              END IF;
              -- Atualizando nro do dia para calculo
              -- Caso o dia seja superior ao dia do pagamento
              IF vr_nrdiacal > rw_craplem.ddlanmto THEN
                -- Mantem o mesmo valor
                vr_nrdiacal := vr_nrdiacal;
              ELSE
                -- Utilizar o dia do empr�stimo
                vr_nrdiacal := rw_craplem.ddlanmto;
              END IF;
              -- Diminuir saldo devedor
              pr_vlsdeved := NVL(pr_vlsdeved, 0) - rw_craplem.vllanmto;
              -- Acumular valor presta��o pagos
              pr_vlprepag := pr_vlprepag + rw_craplem.vllanmto;
              -- Acumular n�mero de pagamentos no m�s
              vr_qtdpgmes := vr_qtdpgmes + 1;
              -- Incluir lan�amento no vetor de pagamentos
              vr_vet_vlrpgmes(vr_qtdpgmes) := rw_craplem.vllanmto;
              -- Para os tipos abaixo relacionados
              -- --- --------------------------------------------------
              --  93 PG. EMPR. FP.
              --  95 PG. EMPR. C/C
            ELSIF rw_craplem.cdhistor IN (93, 95) THEN
              -- Guardar data do ultimo pagamento
              pr_dtultpag := rw_craplem.dtmvtolt;
              -- Se o dia do lan�amento � superior ao dia de pagamento passado
              IF rw_craplem.ddlanmto > pr_diapagto THEN
                -- Se houver saldo devedor
                IF pr_vlsdeved > 0 THEN
                  -- Acumular os juros
                  vr_vljurmes := vr_vljurmes +
                                 (pr_vlsdeved * pr_txdjuros *
                                 (rw_craplem.ddlanmto - vr_nrdiacal));
                  -- Dia calculo recebe o dia do lan�amento
                  vr_nrdiacal := rw_craplem.ddlanmto;
                ELSE
                  -- Dia calculo recebe o dia do lan�amento
                  vr_nrdiacal := rw_craplem.ddlanmto;
                END IF;
              ELSE
                -- Se houver saldo devedor
                IF pr_vlsdeved > 0 THEN
                  -- Acumular os juros
                  vr_vljurmes := vr_vljurmes + (pr_vlsdeved * pr_txdjuros *
                                 (pr_diapagto - vr_nrdiacal));
                  -- Dia calculo recebe o dia do pagamento enviado
                  vr_nrdiacal := pr_diapagto;
                  -- ???
                  vr_inhst093 := TRUE;
                ELSE
                  -- Dia calculo recebe o dia do pagamento enviado
                  vr_nrdiacal := pr_diapagto;
                END IF;
              END IF;
              -- Diminuir saldo devedor
              pr_vlsdeved := NVL(pr_vlsdeved, 0) - rw_craplem.vllanmto;
              -- Acrescentar valor prestacoes pagas
              pr_vlprepag := pr_vlprepag + rw_craplem.vllanmto;
            
              -- Acumular n�mero de pagamentos no m�s
              vr_qtdpgmes := vr_qtdpgmes + 1;
              -- Incluir lan�amento no vetor de pagamentos
              vr_vet_vlrpgmes(vr_qtdpgmes) := rw_craplem.vllanmto;
              -- Para os tipos abaixo
              -- --- --------------------------------------------------
              --  88 ESTORNO PAGTO
              -- 395 SERV./TAXAS
              -- 441 JUROS S/ATRAS
              -- 443 MULTA S/ATRAS
              -- 507 EST.TRF.COTAS
            ELSIF rw_craplem.cdhistor IN (88, 395, 441, 443, 507) THEN
              -- Se ainda houver saldo devedor
              IF pr_vlsdeved > 0 THEN
                -- Se o dia do lan�amento for inferior ao dia de pagamento enviado
                IF rw_craplem.ddlanmto < pr_diapagto THEN
                  -- Se o dia calculado for igual ao dia de pagamento enviado
                  IF vr_nrdiacal = pr_diapagto THEN
                    -- Acumular os juros com base na taxa e na diferen�a entre o dia enviado e o do lan�amento
                    vr_vljurmes := vr_vljurmes +
                                   (rw_craplem.vllanmto * pr_txdjuros *
                                   (pr_diapagto - rw_craplem.ddlanmto));
                  ELSE
                    -- Acumular os juros com base na taxa e na diferen�a entre o dia o lan�amento e o dia de c�lculo
                    vr_vljurmes := vr_vljurmes +
                                   (pr_vlsdeved * pr_txdjuros *
                                   (rw_craplem.ddlanmto - vr_nrdiacal));
                    -- Utilizar como dia de c�lculo o dia deste lan�amento
                    vr_nrdiacal := rw_craplem.ddlanmto;
                  END IF;
                ELSIF rw_craplem.ddlanmto > pr_diapagto THEN
                  -- Calcular o juros
                  vr_vljurmes := vr_vljurmes +
                                 (pr_vlsdeved * pr_txdjuros *
                                 (rw_craplem.ddlanmto - vr_nrdiacal));
                  -- Dia para calculo recebe o dia deste lan�amento
                  vr_nrdiacal := rw_craplem.ddlanmto;
                END IF;
              ELSE
                -- Atualizando nro do dia para calculo
                -- Caso o dia seja superior ao dia do lan�amento do pagamento
                IF vr_nrdiacal > rw_craplem.ddlanmto THEN
                  -- Mantem o mesmo valor
                  vr_nrdiacal := vr_nrdiacal;
                ELSE
                  -- Utilizar o dia do empr�stimo
                  vr_nrdiacal := rw_craplem.ddlanmto;
                END IF;
              END IF;
              -- Para estornos abaixo relacionados
              -- --- --------------------------------------------------
              --  88 ESTORNO PAGTO
              -- 507 EST.TRF.COTAS
              IF rw_craplem.cdhistor IN (88, 507) THEN
                -- N�o considerar este lan�amento no valor pago
                pr_vlprepag := pr_vlprepag - rw_craplem.vllanmto;
                -- Se o valor ficar negativo
                IF pr_vlprepag < 0 THEN
                  -- Ent�o zera novamente
                  pr_vlprepag := 0;
                END IF;
              END IF;
              -- Acumular o lan�amento no saldo devedor
              pr_vlsdeved := pr_vlsdeved + rw_craplem.vllanmto;
              -- Testar se existe pagamento com o mesmo valor no vetor de pagamentos
              vr_exipgmes := FALSE;
              -- Ler o vetor de pagamentos
              FOR vr_aux IN 1 .. vr_qtdpgmes LOOP
                -- Se o valor do vetor � igual ao do pagamento
                IF vr_vet_vlrpgmes(vr_aux) = rw_craplem.vllanmto THEN
                  -- Indica que encontrou o pagamento no vetor
                  vr_exipgmes := TRUE;
                END IF;
              END LOOP;
              -- Se tiver encontrado
              IF vr_exipgmes THEN
                -- Se o pagamento n�o for dos estornos abaixo relacionados
                -- --- --------------------------------------------------
                --  88 ESTORNO PAGTO
                -- 507 EST.TRF.COTAS
                IF rw_craplem.cdhistor NOT IN (88, 507) THEN
                  -- Diminuir do valor acumulado pago este pagamento
                  IF pr_vlprepag >= rw_craplem.vllanmto THEN
                    pr_vlprepag := pr_vlprepag - rw_craplem.vllanmto;
                  ELSE
                    pr_vlprepag := 0;
                  END IF;
                END IF;
              END IF;
            END IF;
          END LOOP;
        END IF;
        -- Se estiver rodando no Batch
        IF pr_rw_crapdat.inproces > 2 THEN
          -- Se � processo mensal
          IF pr_cdprogra IN ('CRPS080', 'CRPS085', 'CRPS120') THEN
            -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes pr�ximo dia
            IF TRUNC(vr_dtmvtolt, 'mm') <>
               TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
              -- Zerar n�mero de dias para c�lculo
              vr_nrdiacal := 0;
            ELSE
              -- Dia para c�lculo recebe o dia enviado - o dia dalculado
              vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
            END IF;
          ELSE
            --> N�o � processo mensal
            -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes pr�ximo dia
            IF TRUNC(vr_dtmvtolt, 'mm') <>
               TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
              -- Dia para calculo recebe o ultimo dia do m�s - o dia calculado
              vr_nrdiacal := to_char(pr_rw_crapdat.dtultdia, 'dd') -
                             vr_nrdiacal;
            ELSE
              -- Dia para c�lculo recebe o dia enviado - o dia dalculado
              vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
            END IF;
          END IF;
        ELSE
          -- Dia para c�lculo recebe o dia enviado - o dia dalculado
          vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
        END IF;
        -- Se existir saldo devedor
        IF pr_vlsdeved > 0 THEN
          -- Sumarizar juros do m�s
          vr_vljurmes := vr_vljurmes +
                         (pr_vlsdeved * pr_txdjuros * vr_nrdiacal);
        END IF;
        -- Zerar qtde dias para c�lculo
        vr_nrdiacal := 0;
        -- Se foi enviado data para calculo e existe saldo devedor
        IF pr_dtcalcul IS NOT NULL
           AND pr_vlsdeved > 0 THEN
          -- Dias para calculo recebe a data para calculo - dia do movimento
          vr_nrdiacal := trunc(pr_dtcalcul - vr_dtmvtolt);
          -- Se foi enviada uma data para calculo posterior ao ultimo dia do m�s corrente
          IF pr_dtcalcul > pr_rw_crapdat.dtultdia THEN
            -- Qtde dias para calculo de juros no m�s corrente
            -- � a diferen�a entre o ultimo dia - data movimento
            vr_nrdiames := TO_NUMBER(TO_CHAR(pr_rw_crapdat.dtultdia, 'DD')) -
                           TO_NUMBER(TO_CHAR(vr_dtmvtolt, 'DD'));
            -- Qtde dias para calculo de juros no pr�ximo m�s
            -- � a diferente entre o total de dias - os dias do m�s corrente
            vr_nrdiaprx := vr_nrdiacal - vr_nrdiames;
          ELSE
            --> Estamos no mesmo m�s
            -- Quantidade de dias no m�s recebe a quantidade de dias calculada
            vr_nrdiames := vr_nrdiacal;
            -- N�o existe calculo para o pr�ximo m�s
            vr_nrdiaprx := 0;
          END IF;
          -- Acumular juros com o n�mero de dias no m�s corrente
          vr_vljurmes := vr_vljurmes +
                         (pr_vlsdeved * pr_txdjuros * vr_nrdiames);
          -- Se a data enviada for do pr�ximo m�s
          IF vr_nrdiaprx > 0 THEN
            -- Arredondar os juros calculados
            vr_vljurmes := ROUND(vr_vljurmes, 2);
            -- Acumular no saldo devedor do m�s corrente os juros
            pr_vlsdeved := pr_vlsdeved + vr_vljurmes;
            -- Acumular no totalizador de juros o juros calculados
            pr_vljuracu := pr_vljuracu + vr_vljurmes;
            -- Novamente calculamos os juros, por�m somente com base nos dias do pr�ximo m�s
            vr_vljurmes := (pr_vlsdeved * pr_txdjuros * vr_nrdiaprx);
          END IF;
          -- Se o dia da data enviada for inferior ao dia para pagamento enviado
          IF to_char(pr_dtcalcul, 'dd') < pr_diapagto THEN
            -- Dias para pagamento recebe essa diferen�a
            vr_nrdiacal := pr_diapagto - to_char(pr_dtcalcul, 'dd');
          ELSE
            -- Ainda n�o venceu
            vr_nrdiacal := 0;
          END IF;
        ELSE
          -- Se o dia para c�lculo for anterior ao dia enviado para pagamento
          --  E N�o pode ser processo batch
          --  E deve haver saldo devedor
          --  E n�o pode ser inhst093 - ???
          IF to_char(vr_dtmvtolt, 'dd') < pr_diapagto
             AND pr_rw_crapdat.inproces < 3
             AND pr_vlsdeved > 0
             AND NOT vr_inhst093 THEN
            -- Dia para calculo recebe o dia enviado - dia da data de movimento
            vr_nrdiacal := pr_diapagto - to_char(vr_dtmvtolt, 'dd');
          ELSE
            -- Dia para calculo permanece zerado
            vr_nrdiacal := 0;
          END IF;
        END IF;
        -- Calcula juros sobre a prest. quando a consulta � menor que o data pagto
        -- Se existe dias para calculo e a data de pagamento contratada � inferior ao ultimo dias do m�s corrente
        IF vr_nrdiacal > 0
           AND rw_crapepr.dtdpagto <= pr_rw_crapdat.dtultdia THEN
          -- Se o saldo devedor for superior ao valor contratado de presta��o
          IF pr_vlsdeved > rw_crapepr.vlpreemp THEN
            -- Juros no m�s s�o baseados no valor contratado
            vr_vljurmes := vr_vljurmes +
                           (rw_crapepr.vlpreemp * pr_txdjuros * vr_nrdiacal);
          ELSE
            -- Juros no m�s s�o baseados no saldo devedor
            vr_vljurmes := vr_vljurmes +
                           (pr_vlsdeved * pr_txdjuros * vr_nrdiacal);
          END IF;
        END IF;
        -- Arredondar juros no m�s
        vr_vljurmes := ROUND(vr_vljurmes, 2);
        -- Acumular juros calculados
        pr_vljuracu := pr_vljuracu + vr_vljurmes;
        -- Incluir no saldo devedor os juros do m�s
        pr_vlsdeved := pr_vlsdeved + vr_vljurmes;
        -- Se houver indica��o de liquida��o do empr�stimo
        -- E ainda existe saldo devedor
        IF pr_vlsdeved > 0
           AND rw_crapepr.inliquid > 0 THEN
          -- Se estiver rodando o processo batch no programa crps078
          IF pr_rw_crapdat.inproces > 2
             AND pr_cdprogra = 'CRPS078' THEN
            -- Se os juros do m�s forem iguais ou superiores ao saldo devedor
            IF vr_vljurmes >= pr_vlsdeved THEN
              -- Remover dos juros do m�s e do juros acumulados o saldo devedor
              vr_vljurmes := vr_vljurmes - pr_vlsdeved;
              pr_vljuracu := pr_vljuracu - pr_vlsdeved;
              -- Zerar o saldo devedor
              pr_vlsdeved := 0;
            ELSE
              -- Gerar cr�tica
              vr_dscritic := 'ATENCAO: NAO FOI POSSIVEL ZERAR O SALDO - ' ||
                             ' CONTA = ' ||
                             gene0002.fn_mask_conta(pr_nrdconta) ||
                             ' CONTRATO = ' ||
                             gene0002.fn_mask_contrato(pr_nrctremp) ||
                             ' SALDO = ' ||
                             TO_CHAR(pr_vlsdeved, 'B999g990d00');
              RAISE vr_exc_erro;
            END IF;
          ELSE
            -- Remover dos juros do m�s e do juros acumulados o saldo devedor
            vr_vljurmes := vr_vljurmes - pr_vlsdeved;
            pr_vljuracu := pr_vljuracu - pr_vlsdeved;
            -- Zerar o saldo devedor
            pr_vlsdeved := 0;
          END IF;
        END IF;
        -- Copiar para a sa�da os juros calculados
        pr_vljurmes := vr_vljurmes;
      END IF;
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      WHEN vr_exc_erro2 THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Copiar o erro j� existente na variavel para
        pr_tab_erro := vr_tab_erro;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_calc_saldo_deved_epr_lem> ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_calc_saldo_deved_epr_lem;

  /* Procedure para obter dados de emprestimos do associado */
  PROCEDURE pc_obtem_dados_empresti(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                   ,pr_cdagenci       IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                   ,pr_nrdcaixa       IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                   ,pr_cdoperad       IN crapdev.cdoperad%TYPE --> C�digo do operador
                                   ,pr_nmdatela       IN VARCHAR2 --> Nome datela conectada
                                   ,pr_idorigem       IN INTEGER --> Indicador da origem da chamada
                                   ,pr_nrdconta       IN crapass.nrdconta%TYPE --> Conta do associado
                                   ,pr_idseqttl       IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                   ,pr_rw_crapdat     IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                                   ,pr_dtcalcul       IN DATE --> Data solicitada do calculo
                                   ,pr_nrctremp       IN crapepr.nrctremp%TYPE --> N�mero contrato empr�stimo
                                   ,pr_cdprogra       IN crapprg.cdprogra%TYPE --> Programa conectado
                                   ,pr_inusatab       IN BOOLEAN --> Indicador de utiliza��o da tabela
                                   ,pr_flgerlog       IN VARCHAR2 --> Gerar log S/N
                                   ,pr_flgcondc       IN BOOLEAN --> Mostrar emprestimos liquidados sem prejuizo
                                   ,pr_nmprimtl       IN crapass.nmprimtl%TYPE --> Nome Primeiro Titular
                                   ,pr_tab_parempctl  IN craptab.dstextab%TYPE --> Dados tabela parametro
                                   ,pr_tab_digitaliza IN craptab.dstextab%TYPE --> Dados tabela parametro
                                   ,pr_nriniseq       IN INTEGER --> Numero inicial da paginacao
                                   ,pr_nrregist       IN INTEGER --> Numero de registros por pagina
                                   ,pr_qtregist       OUT INTEGER --> Qtde total de registros
                                   ,pr_tab_dados_epr  OUT typ_tab_dados_epr --> Saida com os dados do empr�stimo
                                   ,pr_des_reto       OUT VARCHAR --> Retorno OK / NOK
                                   ,pr_tab_erro       OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  
  BEGIN
    /* .............................................................................
    
       Programa: pc_obtem_dados_empresti (antigo b1wgen0002.p --> obtem-dados-emprestimos)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos (Supero)
       Data    : Abril/2013.                         Ultima atualizacao: 11/05/2016
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : Procedure para obter dados de emprestimos do associado
    
       Alteracoes:  22/04/2013 - Convers�o Progress >> Oracle PLSQL (Marcos-Supero)
    
                    12/09/2013 - Aumentar capacidade das variaveis.
                                 Enviar a data de calculo recebida nesta procedure
                                 para a procedure pc_calc_saldo_deved_epr_lem.
                                 Evitar erros na leitura dos avalistas.
                                 Corrigida concatenacao da chave pr_tab_dados_epr.
    
                    09/05/2014 - Adicionado parametros de paginacao.
                                 (Jorge/Gielow) - SD 109570
    
                    12/05/2014 - Ajuste na procedure "obtem-dados-conta-contrato"
                                 para carregar o valor da multa e juros de mora
                                 na tt-dados-epr. (James)
    
                                 Ajuste na procedure "grava-proposta-completa"
                                 para gravar o campo crawepr.qttolatr. (James)
    
                    12/09/2014 - Ajuste para carregar na temp-table tt-dados-epr
                                 se o contrato � pre-aprovado. (James)
                                 
                    10/02/2015 - Ajuste no calculo do prejuizo para o emprestimo PP. (James)
                    
                    20/05/2015 - Ajuste para verificar se cobra multa. (James)

                    12/06/2015 - Adicao de campos para geracao do extrato da 
                                 portabilidade de credito. (Jaison/Diego - SD: 290027)
                    
                    29/10/2015 - Ajustado busca na crappep onde identifica as parcelas vencidas, 
                                 para nao considerar como vencidas as parcelas com vencimento no final de semana
                                 SD318820 (Odirlei-AMcom)
                    
                    05/11/2015 - Ajustes identificados na valida��o da pc_obtem_dados_empresti_web
                                 diferen�as entre a vers�o progress e oracle SD318820 (Odirlei-Amcom)             
                                 
                    06/11/2015 - Replicar ajustes feitos no projeto portabilidade na BO b1wgen0002.obtem-dados-emprestimos             
                                 Ajustado contador de pagina��o SD318820 (Odirlei-AMcom)   
                                 
                    30/11/2015 - Ajustes de performace devido a lentidao do crps665, 
                                 tratado para que select na crplcm(tratamento pre-aprovado) s� seja executado 
                                 se idorigem <> 7-batch (Odirlei-AMcom)

                    11/05/2016 - Calculo vlatraso na chamada pc_calcula_atraso_tr.
                                 (Jaison/James)

    ............................................................................. */
    DECLARE
      -- Busca do nome do associado
      CURSOR cr_crapass(pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT nmprimtl
              ,inpessoa
          FROM crapass
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
    
      -- Busca dos dados do emprestimo passado ou de todos os emprestimos da conta quando nrctremp = 0
      CURSOR cr_crapepr IS
        SELECT nrctremp
              ,cdlcremp
              ,inliquid
              ,inprejuz
              ,dtultpag
              ,txjuremp
              ,vlsdeved
              ,vljuracu
              ,qtprecal
              ,qtpreemp
              ,tpemprst
              ,dtmvtolt
              ,cdagenci
              ,cdbccxlt
              ,nrdolote
              ,flgpagto
              ,dtdpagto
              ,cdfinemp
              ,nrctaav1
              ,nrctaav2
              ,vljurmes
              ,vlemprst
              ,txmensal
              ,vlprejuz
              ,vlsdprej
              ,dtprejuz
              ,vljraprj
              ,vljrmprj
              ,qtmesdec
              ,vlpreemp
              ,flgdigit
              ,vlttmupr
              ,vlttjmpr
              ,vlpgmupr
              ,vlpgjmpr
              ,cdorigem
              ,qtimpctr
          FROM crapepr
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = DECODE(pr_nrctremp, 0, nrctremp, pr_nrctremp) --> Se zero traz todos, sen�o s� ele
         ORDER BY cdlcremp
                 ,cdfinemp;
      -- Buscar dados da linha de cr�dito
      CURSOR cr_craplcr(pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT dslcremp
              ,nrdialiq
              ,txdiaria
              ,perjurmo
              ,tpctrato
              ,txmensal
              ,flgcobmu
              ,cdmodali
              ,cdsubmod
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
               AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      -- Busca dos dados de complemento do empr�stimo
      CURSOR cr_crawepr(pr_cdcooper  crapepr.cdcooper%TYPE,
                        pr_nrdconta  crapepr.nrdconta%TYPE,
                        pr_nrctremp  crapepr.nrctremp%TYPE) IS
        SELECT 'S' indachou
              ,dtdpagto
              ,flgimppr
              ,flgimpnp
              ,progress_recid
              ,qtpromis
              ,percetop
              ,DECODE(tpemprst,0,(txdiaria * 100),txdiaria) txdiaria
          FROM crawepr epr
         WHERE epr.cdcooper = pr_cdcooper
               AND epr.nrdconta = pr_nrdconta
               AND epr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;
      -- Leitura da descricao da finalidade do emprestimo
      CURSOR cr_crapfin(pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
        SELECT dsfinemp
          FROM crapfin
         WHERE cdcooper = pr_cdcooper
               AND cdfinemp = pr_cdfinemp;
      rw_crapfin cr_crapfin%ROWTYPE;
    
      -- Buscar os dados de parametrizacao do pre-aprovado
      CURSOR cr_crappre(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_inpessoa IN crapass.cdcooper%TYPE
                       ,pr_cdfinemp IN crapepr.cdfinemp%TYPE) IS
        SELECT cdfinemp
          FROM crappre
         WHERE crappre.cdcooper = pr_cdcooper
               AND crappre.inpessoa = pr_inpessoa
               AND crappre.cdfinemp = pr_cdfinemp;
      rw_crappre cr_crappre%ROWTYPE;
    
      -- Retornar quantidade de aditivos
      CURSOR cr_crapadt(pr_nrctremp IN crapadt.nrctremp%TYPE) IS
        SELECT COUNT(1)
          FROM crapadt
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = pr_nrctremp;
      vr_qtaditiv INTEGER;
      -- Busca dos avalistas terceiros
      CURSOR cr_crapavt(pr_nrctremp IN crapavt.nrctremp%TYPE) IS
        SELECT nrcpfcgc
              ,nmdavali
          FROM crapavt
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = pr_nrctremp
               AND tpctrato = 1; --> Empr�stimo
        -- Cursor para buscar a modalidade
        CURSOR cr_gnmodal(pr_cdmodali IN gnmodal.cdmodali%TYPE) IS
          SELECT gnmodal.cdmodali
                ,gnmodal.dsmodali
            FROM gnmodal
           WHERE upper(gnmodal.cdmodali) = upper(pr_cdmodali);
        rw_gnmodal cr_gnmodal%ROWTYPE;
        -- Cursor para buscar a sub modalidade
        CURSOR cr_gnsbmod(pr_cdmodali IN gnsbmod.cdmodali%TYPE
                         ,pr_cdsubmod IN gnsbmod.cdsubmod%TYPE) IS
          SELECT gnsbmod.cdsubmod
                ,gnsbmod.dssubmod
            FROM gnsbmod
           WHERE upper(gnsbmod.cdmodali) = upper(pr_cdmodali)
             AND upper(gnsbmod.cdsubmod) = upper(pr_cdsubmod);
        rw_gnsbmod cr_gnsbmod%ROWTYPE;
      -- Temp table para armazenar os avalistas encontrados
      TYPE typ_reg_avalist IS RECORD(
         nrgeneri VARCHAR2(30) --> Pode ser o CPF ou NroConta
        ,nmdavali crapavt.nmdavali%TYPE); --> Nome do avalista
      TYPE typ_tab_avalist IS TABLE OF typ_reg_avalist INDEX BY PLS_INTEGER;
      vr_ind_avalist PLS_INTEGER;
      vr_tab_avalist typ_tab_avalist;
      vr_nrctaavg    NUMBER; --> N�mero gen�rico
      -- Campos de descri��o dos avalistas 1, 2 e por extenso
      vr_dsdavali VARCHAR2(300);
      vr_dsdaval1 VARCHAR2(300);
      vr_dsdaval2 VARCHAR2(300);
      -- Buscar se existe alguma parcela vencida
      CURSOR cr_crappep(pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT 1
          FROM crappep
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = pr_nrctremp
               AND inliquid = 0 -- N�o liquidada
               AND dtvencto <= pr_rw_crapdat.dtmvtoan; -- Parcela Vencida
      -- Busca dos lan�amentos cfme lista de hist�ricos passado
      CURSOR cr_craplem(pr_nrctremp  IN crapepr.nrctremp%TYPE
                       ,pr_lsthistor IN VARCHAR2 DEFAULT ' ') IS --> Lista comdigos de hist�rico a retornar
        SELECT cdhistor
              ,vllanmto
          FROM craplem
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta --> Conta enviada
               AND nrctremp = pr_nrctremp --> Empr�stimo atual
               AND
               ',' || pr_lsthistor || ',' LIKE ('%,' || cdhistor || ',%'); --> Retornar hist�ricos passados na listagem
      rw_craplem cr_craplem%ROWTYPE;
      -- Verificar se existe aviso de d�bito em conta corrente n�o processado
      CURSOR cr_crapavs(pr_nrdconta IN crapavs.nrdconta%TYPE) IS
        SELECT 'S'
          FROM crapavs
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND cdhistor = 108
               AND dtrefere = pr_rw_crapdat.dtultdma --> Ultimo dia mes anterior
               AND tpdaviso = 1
               AND flgproce = 0; --> N�o processado
      vr_flghaavs CHAR(1);
    
      -- verificar se existe o lan�amento de credito do emprestimo
      CURSOR cr_craplcm ( pr_cdcooper  craplcm.cdcooper%TYPE,
                          pr_nrdconta  craplcm.nrdconta%TYPE,
                          pr_nrctremp  craplcm.nrdocmto%TYPE,
                          pr_dtmvtolt_epr craplcm.dtmvtolt%TYPE,
                          pr_dtmvtolt_dat craplcm.dtmvtolt%TYPE) IS
        SELECT 1
          FROM craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
           AND craplcm.nrdconta = pr_nrdconta
           AND craplcm.cdhistor = 15 /* Credito Emprestimo */
           AND craplcm.nrdocmto = pr_nrctremp
           AND craplcm.dtmvtolt >= pr_dtmvtolt_epr
           AND craplcm.dtmvtolt = pr_dtmvtolt_dat;
      rw_craplcm cr_craplcm%ROWTYPE;
      
      -- variaveis auxiliares a busca
      vr_nmprimtl crapass.nmprimtl%TYPE; --> Nome do associado
      vr_dsdpagto VARCHAR2(100); --> Descri��o auxiliar do d�bito
      vr_qtmesdec NUMBER(16, 8); --> Qtde de meses decorridos
      vr_qtpreemp NUMBER; --> Quantidade de parcelas do empr�stimos
      vr_qtpreapg NUMBER; --> Quantidade de parcelas a pagar
      --vr_vlpreapg NUMBER(20,7);                --> Valor das parcelas a pagar
      --vr_vlpreemp NUMBER;              --> Valor da parcela do empr�stimo
      vr_vlpreapg NUMBER; --> Valor das parcelas a pagar
      vr_vlmrapar crappep.vlmrapar%TYPE; --> Valor do Juros de Mora
      vr_vlmtapar crappep.vlmtapar%TYPE; --> Valor da Multa
      vr_vlprvenc NUMBER := 0; --> Valor Vencido
      vr_vlpraven NUMBER := 0; --> Valor a Vencer
      vr_vlpreemp NUMBER := 0; --> Valor da parcela do empr�stimo
      vr_flgatras NUMBER(1); --> Indicador 0/1 de atraso no empr�stimo
      vr_dslcremp VARCHAR2(60); --> Descri��o da linha de cr�dito
      vr_txdjuros NUMBER(12, 7); --> Taxa de juros para o c�lculo
      vr_qtprecal crapepr.qtprecal%TYPE; --> Qatdade de parclas calculadas at� o momento
      vr_dtrefere DATE; --> Data refer�ncia para o calculo
      vr_vldescto NUMBER; --> Valor de desconto
      vr_vlprovis NUMBER; --> Valor de provis�o
      vr_cdpesqui VARCHAR2(30); --> Campo de pesquisa com dados do empr�stimo
      vr_dtinipag DATE; --> Data de in�cio de pagamento do empr�stimo
      vr_dsfinemp VARCHAR2(60); --> Descri��o da finalidade do empr�stimo
      vr_indadepr PLS_INTEGER; --> Indice para grava��o na tab_dados_epr
      -- Dia e data de pagamento de empr�stimo
      vr_tab_diapagto NUMBER;
      vr_tab_dtcalcul DATE;
      -- Flag para desconto em folha
      vr_tab_flgfolha BOOLEAN;
      -- Configura��o para m�s novo
      vr_tab_ddmesnov INTEGER;
      -- Rowid para inser��o de log
      vr_nrdrowid ROWID;
      -- Busca na craptab
      vr_dstextab craptab.dstextab%TYPE;
      -- Saida para desvio de fluxo
      vr_exc_next  EXCEPTION;
      vr_exc_erro2 EXCEPTION;
      -- Vari�veis para passagem a rotina pc_calcula_lelem
      vr_diapagto     INTEGER;
      vr_qtprecal_lem crapepr.qtprecal%TYPE;
      --vr_vlprepag     craplem.vllanmto%TYPE;
      --vr_vljuracu     crapepr.vljuracu%TYPE;
      --vr_vljurmes     crapepr.vljurmes%TYPE;
      --vr_vlsdeved     crapepr.vlsdeved%TYPE;
      vr_vlprepag NUMBER;
      vr_vljuracu NUMBER;
      vr_vljurmes NUMBER;
      vr_vlsdeved NUMBER;
      vr_dtultpag crapepr.dtultpag%TYPE;
      -- Variaveis gerais
      vr_tpdocged PLS_INTEGER;
      -- Variavel de paginacao
      vr_nrregist INTEGER := 0;
      vr_flpgmujm BOOLEAN;
      vr_liquidia INTEGER := 0;
      vr_err_efet PLS_INTEGER;    
      vr_portabilidade VARCHAR2(500);
      
    
    BEGIN
      -- Buscar a configura��o de empr�stimo cfme a empresa da conta
      pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                                ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data atual
                                ,pr_nrdconta => pr_nrdconta --> Numero da conta do empr�stimo
                                ,pr_dtcalcul => vr_tab_dtcalcul --> Data calculada de pagamento
                                ,pr_diapagto => vr_tab_diapagto --> Dia de pagamento das parcelas
                                ,pr_flgfolha => vr_tab_flgfolha --> Flag de desconto em folha S/N
                                ,pr_ddmesnov => vr_tab_ddmesnov --> Configura��o para m�s novo
                                ,pr_cdcritic => vr_cdcritic --> C�digo do erro
                                ,pr_des_erro => vr_dscritic); --> Retorno de Erro
      -- Se houve erro na rotina
      IF vr_dscritic IS NOT NULL
         OR vr_cdcritic IS NOT NULL THEN
        -- Levantar exce��o
        RAISE vr_exc_erro;
      END IF;
      -- Busca do nome do associado
      vr_nmprimtl := pr_nmprimtl;
      --OPEN cr_crapass(pr_nrdconta => pr_nrdconta);
      --FETCH cr_crapass INTO vr_nmprimtl;
      --CLOSE cr_crapass;
    
      -- busca o tipo de documento GED
      vr_dstextab := pr_tab_digitaliza;
      /*vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
      ,pr_nmsistem => 'CRED'
      ,pr_tptabela => 'GENERI'
      ,pr_cdempres => 00
      ,pr_cdacesso => 'DIGITALIZA'
      ,pr_tpregist => 5);*/ /* Contrt. emprestimo/financiamento (GED) */
      -- Se encontrar
      IF vr_dstextab IS NULL THEN
        vr_tpdocged := 0;
      ELSE
        vr_tpdocged := gene0002.fn_busca_entrada(3, vr_dstextab, ';');
      END IF;
    
      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab := pr_tab_parempctl;
      /*vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
      ,pr_nmsistem => 'CRED'
      ,pr_tptabela => 'USUARI'
      ,pr_cdempres => 11
      ,pr_cdacesso => 'PAREMPCTL'
      ,pr_tpregist => 01);*/
      -- Se encontrar
      IF vr_dstextab IS NULL THEN
        -- Gerar erro
        vr_cdcritic := 0;
        vr_dscritic := 'Informacoes nao encontradas.';
      END IF;
    
      vr_nrregist := pr_nrregist;
    
      -- Busca dos dados do emprestimo passado ou de todos os emprestimos da conta quando nrctremp = 0
      FOR rw_crapepr IN cr_crapepr LOOP
        BEGIN
          
          
          -- Buscar descri��o da linha de cr�dito
          OPEN cr_craplcr(pr_cdlcremp => rw_crapepr.cdlcremp);
          FETCH cr_craplcr
            INTO rw_craplcr;
          -- Se n�o tiver encontrado
          IF cr_craplcr%NOTFOUND THEN
            -- Fechar o cursor e gerar erro
            CLOSE cr_craplcr;
            vr_cdcritic := 363;
            RAISE vr_exc_erro;
          ELSE
            -- Apenas fechar o cursor e continuar
            CLOSE cr_craplcr;
            
            --Selecionar Modalidade
            OPEN cr_gnmodal (pr_cdmodali => rw_craplcr.cdmodali);
            FETCH cr_gnmodal INTO rw_gnmodal;
            --Fechar Cursor
            CLOSE cr_gnmodal;

            --Selecionar Sub Modalidade
            OPEN cr_gnsbmod (pr_cdmodali => rw_craplcr.cdmodali
                            ,pr_cdsubmod => rw_craplcr.cdsubmod);
            FETCH cr_gnsbmod INTO rw_gnsbmod;
            --Fechar Cursor
            CLOSE cr_gnsbmod;
          END IF;
          
          -- Verifica se cobra Multa
          IF rw_craplcr.flgcobmu = 1 THEN
            vr_dstextab := pr_tab_parempctl;
          ELSE
            vr_dstextab := 0;
          END IF;
          
          -- Montar a descri��o da linha de cr�dito
          vr_dslcremp := TRIM(rw_crapepr.cdlcremp) || '-' ||
                         rw_craplcr.dslcremp;
          --  Mostrar emprestimos em aberto (nao liquidados), emprestimos que
          --  estao em prejuizo, e emprestimos liquidados sem prejuizo que ainda
          --  podem ser visualizados conforme campo craplcr.nrdialiq cadastrado
          --  na tela LCREDI. A ultima condicao e utilizada conforme o parametro
          --  par_flgcondic for alimentando.
          IF NOT (UPPER(pr_nmdatela) IN ('EXTEMP', 'IMPRES') OR
              RW_crapepr.inliquid = 0 OR rw_crapepr.inprejuz = 1 OR
              (pr_flgcondc AND rw_crapepr.inliquid = 1 AND
              rw_crapepr.inprejuz = 0 AND
              rw_crapepr.dtultpag + rw_craplcr.nrdialiq >=
              pr_rw_crapdat.dtmvtolt)) THEN
            -- Ignorar o restante abaixo e processar o pr�ximo registro
            RAISE vr_exc_next;
          END IF;
          -- Se houver indica��o para utiliza��o da tabela de juros e o empr�stimo estiver ativo
          IF pr_inusatab
             AND rw_crapepr.inliquid = 0 THEN
            -- Utilizaremos a taxa de juros da linha de cr�dito
            vr_txdjuros := rw_craplcr.txdiaria;
          ELSE
            -- Utilizaremos a taxa de juros do empr�stimo
            vr_txdjuros := rw_crapepr.txjuremp;
          END IF;
          -- Inicializar variaveis para o calculo do saldo devedor
          vr_vlsdeved := rw_crapepr.vlsdeved;
          vr_vljuracu := rw_crapepr.vljuracu;
          vr_vlmrapar := 0;
          vr_vlmtapar := 0;
          -- Para empr�stimo ainda n�o liquidados
          IF rw_crapepr.inliquid = 0 OR
             rw_crapepr.tpemprst = 1 THEN --tratamento b1wgen0002a.i
            -- Manter o valor da tabela
            vr_qtprecal := rw_crapepr.qtprecal;
          ELSE
            -- Usar o valor total de parcelas
            vr_qtprecal := rw_crapepr.qtpreemp;
          END IF;
          
          -- inicializar variaveis
          vr_vlpraven := 0;
          vr_vlprvenc := 0;
          
          -- Calculo de saldo devedor em emprestimos baseado na includes/lelem.i.
          pc_calc_saldo_deved_epr_lem(pr_cdcooper   => pr_cdcooper --> Cooperativa conectada
                                     ,pr_cdprogra   => pr_cdprogra --> C�digo do programa corrente
                                     ,pr_cdagenci   => rw_crapepr.cdagenci --> C�digo da ag�ncia
                                     ,pr_nrdcaixa   => pr_nrdcaixa --> N�mero do caixa
                                     ,pr_cdoperad   => pr_cdoperad --> C�digo do Operador
                                     ,pr_rw_crapdat => pr_rw_crapdat --> Vetor com dados de par�metro (CRAPDAT)
                                     ,pr_nrdconta   => pr_nrdconta --> N�mero da conta
                                     ,pr_idseqttl   => pr_idseqttl --> Seq titular
                                     ,pr_nrctremp   => rw_crapepr.nrctremp --> Numero ctrato empr�stimo
                                     ,pr_idorigem   => pr_idorigem --> Id do m�dulo de sistema
                                     ,pr_txdjuros   => vr_txdjuros --> Taxa de juros aplicada
                                     ,pr_dtcalcul   => pr_dtcalcul --> Data para calculo do empr�stimo
                                     ,pr_diapagto   => vr_tab_diapagto --> Dia para pagamento
                                     ,pr_qtprecal   => vr_qtprecal_lem --> Quantidade de presta��es calculadas at� momento
                                     ,pr_vlprepag   => vr_vlprepag --> Valor acumulado pago no m�s
                                     ,pr_vlpreapg   => vr_vlpreapg --> Valor a pagar
                                     ,pr_vljurmes   => vr_vljurmes --> Juros no m�s corrente
                                     ,pr_vljuracu   => vr_vljuracu --> Juros acumulados total
                                     ,pr_vlsdeved   => vr_vlsdeved --> Saldo devedor acumulado
                                     ,pr_dtultpag   => vr_dtultpag --> Ultimo dia de pagamento das presta��es
                                     ,pr_vlmrapar   => vr_vlmrapar --> Valor do Juros de Mora
                                     ,pr_vlmtapar   => vr_vlmtapar --> Valor da Multa
                                     ,pr_vlprvenc   => vr_vlprvenc --> Valor Vencido da parcela
                                     ,pr_vlpraven   => vr_vlpraven --> Valor a Vencer
                                     ,pr_flgerlog   => pr_flgerlog --> Gerar log S/N
                                     ,pr_des_reto   => pr_des_reto --> Retorno OK / NOK
                                     ,pr_tab_erro   => vr_tab_erro); --> Tabela com poss�veis erros
          -- Se a rotina retornou erro
          IF pr_des_reto = 'NOK' THEN
            -- Gerar exce��o
            RAISE vr_exc_erro2;
          END IF;
          -- Verifica se deve deixar saldo provisionado no chq. sal
          IF NOT vr_tab_flgfolha THEN
            -- Utilizar o ultimo dia do m�s anterior
            vr_dtrefere := pr_rw_crapdat.dtultdia -
                           to_char(pr_rw_crapdat.dtultdia, 'dd');
          ELSE
            -- Utilizar o ultimo dia do m�s corrente
            vr_dtrefere := pr_rw_crapdat.dtultdia;
          END IF;
          -- Para empr�stimo price n�o liquidados
          IF rw_crapepr.tpemprst = 0
             AND rw_crapepr.inliquid = 0 THEN
            -- Incrementar na quantidade de presta��es calculadas a
            -- quantidade que foi calculada na rotina lem
            vr_qtprecal := vr_qtprecal + vr_qtprecal_lem;
          END IF;
          -- Zerar valores de desconto e provis�o
          vr_vldescto := 0;
          vr_vlprovis := 0;
          -- Montar campo de pesquisa com os dados do movimento
          vr_cdpesqui := to_char(rw_crapepr.dtmvtolt, 'dd/mm/yyyy') || '-' ||
                         to_char(rw_crapepr.cdagenci, 'fm000') || '-' ||
                         to_char(rw_crapepr.cdbccxlt, 'fm000') || '-' ||
                         to_char(rw_crapepr.nrdolote, 'fm000000');
          -- Se a quantidade de parcelas calculadas for superior a
          -- quantidade de parcelas total do empr�stimo
          IF vr_qtprecal > rw_crapepr.qtpreemp THEN
            -- N�o h� mais parcelas a pagar
            vr_qtpreapg := 0;
          ELSE
            -- Calcular a diferen�a
            vr_qtpreapg := rw_crapepr.qtpreemp - vr_qtprecal;
          END IF;
          -- Montar descri��o gen�rica conforme o tipo de pagamento do empr�stimo
          IF rw_crapepr.flgpagto = 1 THEN
            vr_dsdpagto := 'Debito em C/C vinculado ao credito da folha';
          ELSE
            vr_dsdpagto := 'Debito em C/C no dia ' ||
                           to_char(rw_crapepr.dtdpagto, 'dd') || ' (' ||
                           to_char(rw_crapepr.dtdpagto, 'dd/mm/yyyy') || ')';
          END IF;
          -- Busca dados complementares do empr�stimo
          rw_crawepr := NULL;
          OPEN cr_crawepr(pr_cdcooper  => pr_cdcooper,
                          pr_nrdconta  => pr_nrdconta,
                          pr_nrctremp  => rw_crapepr.nrctremp);
          FETCH cr_crawepr
            INTO rw_crawepr;
          CLOSE cr_crawepr;
          -- Se encontrou
          IF rw_crawepr.indachou = 'S' THEN
            -- Utilizar data de pagamento do cadastro complementar
            vr_dtinipag := rw_crawepr.dtdpagto;
          ELSE
            -- Utilizar do cadastro b�sico
            vr_dtinipag := rw_crapepr.dtdpagto;
          END IF;
          -- Se a data de vencimento for do mesmo m�s que o corrente
          IF trunc(rw_crapepr.dtmvtolt, 'mm') =
             trunc(pr_rw_crapdat.dtmvtolt, 'mm') THEN
            -- Tamb�m utilizamos do cadastro b�sico
            vr_dtinipag := rw_crapepr.dtdpagto;
          END IF;
          -- Leitura da descricao da finalidade do emprestimo
          OPEN cr_crapfin(pr_cdfinemp => rw_crapepr.cdfinemp);
          FETCH cr_crapfin
            INTO rw_crapfin;
          -- Se n�o tiver encontrado
          IF cr_crapfin%NOTFOUND THEN
            -- Montar descri��o gen�rica
            vr_dsfinemp := to_char(rw_crapepr.cdfinemp, 'fm990') || '-' ||
                           'N/CADASTRADA!';
          ELSE
            -- Montar descri��o encontrada
            vr_dsfinemp := to_char(rw_crapepr.cdfinemp, 'fm990') || '-' ||
                           rw_crapfin.dsfinemp;
          END IF;
          -- Fechar o curso de pesquisa
          CLOSE cr_crapfin;
          -- Retornar quantidade de aditivos
          OPEN cr_crapadt(pr_nrctremp => rw_crapepr.nrctremp);
          FETCH cr_crapadt
            INTO vr_qtaditiv;
          CLOSE cr_crapadt;
          -- Busca dos avalistas do empr�stimo
          vr_ind_avalist := 0;
          vr_dsdaval1    := ' ';
          vr_dsdaval2    := ' ';
          vr_dsdavali    := ' ';
          vr_tab_avalist.DELETE;
          -- Efetuar laco abaixo para buscar duas vezes cfme nrctaav1 e nrctaav2
          FOR vr_ind IN 1 .. 2 LOOP
            -- No primeiro la�o
            IF vr_ind = 1 THEN
              -- Usar nrctaav1
              vr_nrctaavg := rw_crapepr.nrctaav1;
            ELSE
              -- Usar nrctaav2
              vr_nrctaavg := rw_crapepr.nrctaav2;
            END IF;
            -- Se existir informa��o no campo atual
            IF vr_nrctaavg > 0 THEN
              -- Adicionar a conta ao vetor
              vr_ind_avalist := vr_tab_avalist.COUNT + 1;
              vr_tab_avalist(vr_ind).nrgeneri := gene0002.fn_mask_conta(vr_nrctaavg);
              -- Busca nome do associado
              OPEN cr_crapass(pr_nrdconta => vr_nrctaavg);
              FETCH cr_crapass
                INTO rw_crapass;
              -- Se encontrou
              IF cr_crapass%FOUND THEN
                -- Adicionar o nome
                vr_tab_avalist(vr_ind).nmdavali := ': ' ||
                                                   SUBSTR(rw_crapass.nmprimtl
                                                         ,1
                                                         ,14) ||
                                                   '...';
              ELSE
                -- Incluir texto de associado n�o encontrado
                vr_tab_avalist(vr_ind).nmdavali := ': Nao cadastrado!!!';
              END IF;
              -- Fechar o cursor
              CLOSE cr_crapass;
            END IF;
          END LOOP;
          -- Se algum dos avalistas n�o tiver conta na cooperativa
          IF rw_crapepr.nrctaav1 = 0
             OR rw_crapepr.nrctaav2 = 0 THEN
            -- Buscar avalistas terceirizados
            FOR rw_crapavt IN cr_crapavt(pr_nrctremp => rw_crapepr.nrctremp) LOOP
              -- Adicion�-lo na tabela
              vr_ind_avalist := vr_tab_avalist.COUNT + 1;
              FOR vr_ind IN 1..2 LOOP
                IF NOT vr_tab_avalist.exists(vr_ind) THEN
                  vr_tab_avalist(vr_ind).nrgeneri := rw_crapavt.nrcpfcgc;
                  vr_tab_avalist(vr_ind).nmdavali := ' - ' ||rw_crapavt.nmdavali;
                  EXIT;
                END IF;
              END LOOP;
            END LOOP;
          END IF;
        
          IF vr_ind_avalist > 0 THEN
            -- Ao final das buscas, percorrer a tabela e retornar os 2 primeiros avalistas encontrados
            FOR vr_ind_avalist IN vr_tab_avalist.FIRST .. vr_tab_avalist.LAST LOOP
            
              -- Na primeira intera��o
              IF vr_ind_avalist = 1 THEN
                -- Utilizar o campo vr_dsdaval1
                vr_dsdaval1 := vr_tab_avalist(vr_ind_avalist).nrgeneri || vr_tab_avalist(vr_ind_avalist)
                               .nmdavali;
                -- Preencher o campo avalistas por extenso
                vr_dsdavali := 'Aval ' || TRIM(vr_tab_avalist(vr_ind_avalist).nrgeneri);
              ELSIF vr_ind_avalist = 2 THEN
                -- Utilizar o campo vr_dsdaval2
                vr_dsdaval2 := vr_tab_avalist(vr_ind_avalist).nrgeneri || vr_tab_avalist(vr_ind_avalist)
                               .nmdavali;
                -- Preencher o campo avalistas por extenso
                vr_dsdavali := vr_dsdavali||'/Aval ' || vr_tab_avalist(vr_ind_avalist).nrgeneri;
              END IF;
              -- Sair tamb�m quando j� tiver encontrado dois avalistas
              EXIT WHEN vr_ind_avalist = 2;
            END LOOP;
          END IF;
        
          -- Somente para empr�stimo pr�-fixado
          IF rw_crapepr.tpemprst = 1 THEN
            -- Inicializar flagd de atraso
            vr_flgatras := 0;
            -- Guardar o juro do mes
            vr_vljurmes := rw_crapepr.vljurmes;
            -- Buscar se existe alguma parcela vencida
            OPEN cr_crappep(pr_nrctremp => rw_crapepr.nrctremp);
            FETCH cr_crappep
              INTO vr_flgatras;
            CLOSE cr_crappep;
          ELSE
            -- Considerar que n�o houve atraso
            vr_flgatras := 0;
          END IF;
          
          /*** PORTABILIDADE - Verifica se eh uma proposta de portabilidade **/
          EMPR0006.pc_possui_portabilidade( pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                           ,pr_nrdconta => pr_nrdconta         --Numero da Conta
                                           ,pr_nrctremp => rw_crapepr.nrctremp --Numero de Emprestimo
                                           ,pr_err_efet => vr_err_efet         --Erro na efetivacao (0/1)
                                           ,pr_des_reto => vr_portabilidade    --Portabilidade(S/N)
                                           ,pr_cdcritic => vr_cdcritic         --C�digo da cr�tica
                                           ,pr_dscritic => vr_dscritic);       --Descri��o da cr�tica 
          
          -- Se houve erro na rotina
          IF TRIM(vr_dscritic) IS NOT NULL
             OR nvl(vr_cdcritic,0) <> 0 THEN
            -- Levantar exce��o
            RAISE vr_exc_erro;
          END IF;
	      /*** FIM - PORTABILIDADE - Verifica se eh uma proposta de portabilidade **/
          
          vr_liquidia := 0;
          
          IF pr_idorigem <> 7 THEN
            --> verificar se existe o lan�amento de credito do emprestimo
            OPEN cr_craplcm ( pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrctremp => rw_crapepr.nrctremp,
                              pr_dtmvtolt_epr => rw_crapepr.dtmvtolt,
                              pr_dtmvtolt_dat => pr_rw_crapdat.dtmvtolt
                              );

            FETCH cr_craplcm INTO rw_craplcm;
            IF cr_craplcm%FOUND THEN
              vr_liquidia := 1;
            END IF;
            CLOSE cr_craplcm;

            IF rw_crapepr.vlsdeved <= 0 THEN
              vr_liquidia := 0;
            END IF;
          
          END IF;
          
          
          
          -- Apenas para origem web e que venha com parametros de paginacao
          IF pr_idorigem = 5
             AND pr_nriniseq <> 0
             AND pr_nrregist <> 0 THEN
          
            pr_qtregist := nvl(pr_qtregist,0) + 1;
          
            /* controles da pagina��o */
            IF (vr_nrregist < 1)
               OR (pr_qtregist < pr_nriniseq)
               OR (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
              RAISE vr_exc_next;
            END IF;
          
          END IF;
          
          -- Criar o indice para grava��o na tab_dados_epr
          vr_indadepr := pr_tab_dados_epr.COUNT + 1;
          -- Criar o registro com as informa��es b�sicas
          pr_tab_dados_epr(vr_indadepr).nrdconta := pr_nrdconta;
          pr_tab_dados_epr(vr_indadepr).nmprimtl := vr_nmprimtl;
          pr_tab_dados_epr(vr_indadepr).cdagenci := rw_crapepr.cdagenci;
          pr_tab_dados_epr(vr_indadepr).nrctremp := rw_crapepr.nrctremp;
          pr_tab_dados_epr(vr_indadepr).vlemprst := rw_crapepr.vlemprst;
          pr_tab_dados_epr(vr_indadepr).vlsdeved := vr_vlsdeved;
          pr_tab_dados_epr(vr_indadepr).vlpreemp := rw_crapepr.vlpreemp;
          pr_tab_dados_epr(vr_indadepr).vlprepag := vr_vlprepag;
          pr_tab_dados_epr(vr_indadepr).cdpesqui := vr_cdpesqui;
          pr_tab_dados_epr(vr_indadepr).txjuremp := vr_txdjuros;
          pr_tab_dados_epr(vr_indadepr).vljurmes := vr_vljurmes;
          pr_tab_dados_epr(vr_indadepr).vljuracu := vr_vljuracu;
          pr_tab_dados_epr(vr_indadepr).vlprovis := vr_vlprovis;
          pr_tab_dados_epr(vr_indadepr).cdlcremp := rw_crapepr.cdlcremp;
          pr_tab_dados_epr(vr_indadepr).dslcremp := vr_dslcremp;
          pr_tab_dados_epr(vr_indadepr).cdfinemp := rw_crapepr.cdfinemp;
          pr_tab_dados_epr(vr_indadepr).dsfinemp := vr_dsfinemp;
          pr_tab_dados_epr(vr_indadepr).dsdaval1 := vr_dsdaval1;
          pr_tab_dados_epr(vr_indadepr).dsdaval2 := vr_dsdaval2;
          pr_tab_dados_epr(vr_indadepr).dsdavali := vr_dsdavali;
          pr_tab_dados_epr(vr_indadepr).flgpagto := rw_crapepr.flgpagto;
          pr_tab_dados_epr(vr_indadepr).dtdpagto := rw_crapepr.dtdpagto;
          pr_tab_dados_epr(vr_indadepr).inprejuz := rw_crapepr.inprejuz;
          pr_tab_dados_epr(vr_indadepr).dtmvtolt := rw_crapepr.dtmvtolt;
          pr_tab_dados_epr(vr_indadepr).qtpreemp := rw_crapepr.qtpreemp;
          pr_tab_dados_epr(vr_indadepr).dtultpag := rw_crapepr.dtultpag;
          pr_tab_dados_epr(vr_indadepr).qtaditiv := vr_qtaditiv;
          pr_tab_dados_epr(vr_indadepr).dsdpagto := vr_dsdpagto;
          pr_tab_dados_epr(vr_indadepr).tplcremp := rw_craplcr.tpctrato;
          pr_tab_dados_epr(vr_indadepr).permulta := gene0002.fn_char_para_number(SUBSTR(vr_dstextab
                                                                                       ,1
                                                                                       ,6));
          pr_tab_dados_epr(vr_indadepr).tpemprst := rw_crapepr.tpemprst;
          pr_tab_dados_epr(vr_indadepr).cdtpempr := '0,1';
          pr_tab_dados_epr(vr_indadepr).dstpempr := 'C�lculo Atual,Pr�-Fixada';
          pr_tab_dados_epr(vr_indadepr).perjurmo := rw_craplcr.perjurmo;
          pr_tab_dados_epr(vr_indadepr).inliquid := rw_crapepr.inliquid;
          pr_tab_dados_epr(vr_indadepr).flgatras := vr_flgatras;
          pr_tab_dados_epr(vr_indadepr).flgdigit := rw_crapepr.flgdigit;
          pr_tab_dados_epr(vr_indadepr).tpdocged := vr_tpdocged;
          pr_tab_dados_epr(vr_indadepr).qtlemcal := vr_qtprecal_lem;
          pr_tab_dados_epr(vr_indadepr).vlmrapar := vr_vlmrapar;
          pr_tab_dados_epr(vr_indadepr).vlmtapar := vr_vlmtapar;
          pr_tab_dados_epr(vr_indadepr).vlprvenc := vr_vlprvenc;
          pr_tab_dados_epr(vr_indadepr).vlpraven := vr_vlpraven;
          pr_tab_dados_epr(vr_indadepr).flgpreap := FALSE;
          pr_tab_dados_epr(vr_indadepr).cdorigem := rw_crapepr.cdorigem;
          pr_tab_dados_epr(vr_indadepr).liquidia := vr_liquidia;
          pr_tab_dados_epr(vr_indadepr).qtimpctr := rw_crapepr.qtimpctr;	
          pr_tab_dados_epr(vr_indadepr).portabil := TRIM(vr_portabilidade);
          
          
          pr_tab_dados_epr(vr_indadepr).vlttmupr := nvl(rw_crapepr.vlttmupr
                                                       ,0);
          pr_tab_dados_epr(vr_indadepr).vlttjmpr := nvl(rw_crapepr.vlttjmpr
                                                       ,0);
          pr_tab_dados_epr(vr_indadepr).vlpgmupr := nvl(rw_crapepr.vlpgmupr
                                                       ,0);
          pr_tab_dados_epr(vr_indadepr).vlpgjmpr := nvl(rw_crapepr.vlpgjmpr
                                                       ,0);
        
          -- Para Pre-Fixada
          IF rw_crapepr.tpemprst = 1 THEN
            -- Enviar a taxa do empr�stimo
            pr_tab_dados_epr(vr_indadepr).txmensal := rw_crapepr.txmensal;
            pr_tab_dados_epr(vr_indadepr).dsidenti := '*';
          ELSE
            -- Utilizar da linha de cr�dito
            pr_tab_dados_epr(vr_indadepr).txmensal := rw_craplcr.txmensal;
            pr_tab_dados_epr(vr_indadepr).dsidenti := '';
          END IF;
          -- Se existe cadastro de emprestimo complementar
          IF rw_crawepr.indachou = 'S' THEN
            -- Enviar informa��es do mesmo
            pr_tab_dados_epr(vr_indadepr).flgimppr := rw_crawepr.flgimppr;
            pr_tab_dados_epr(vr_indadepr).flgimpnp := rw_crawepr.flgimpnp;
            pr_tab_dados_epr(vr_indadepr).nrdrecid := rw_crawepr.progress_recid;
            pr_tab_dados_epr(vr_indadepr).qtpromis := rw_crawepr.qtpromis;
            pr_tab_dados_epr(vr_indadepr).dtpripgt := rw_crawepr.dtdpagto;
            pr_tab_dados_epr(vr_indadepr).percetop := rw_crawepr.percetop;
            pr_tab_dados_epr(vr_indadepr).cdmodali := rw_gnmodal.cdmodali;
            pr_tab_dados_epr(vr_indadepr).dsmodali := rw_gnmodal.dsmodali;
            pr_tab_dados_epr(vr_indadepr).cdsubmod := rw_gnsbmod.cdsubmod;
            pr_tab_dados_epr(vr_indadepr).dssubmod := rw_gnsbmod.dssubmod;
            -- A utilizacao da taxa diaria para conversao anual eh devido o 
            -- contrato antigo nao possuir taxa mensal
            pr_tab_dados_epr(vr_indadepr).txanual  := TRUNC((POWER(1 + (rw_crawepr.txdiaria / 100), 360) - 1) * 100, 5);
          END IF;
          -- Para empr�stimos de preju�zo
          IF pr_tab_dados_epr(vr_indadepr).inprejuz > 0 THEN
            -- Copiar informa��es de prejuizo a tabela
            pr_tab_dados_epr(vr_indadepr).vlprejuz := rw_crapepr.vlprejuz;
            pr_tab_dados_epr(vr_indadepr).dtprejuz := rw_crapepr.dtprejuz;
            pr_tab_dados_epr(vr_indadepr).vljraprj := rw_crapepr.vljraprj;
            pr_tab_dados_epr(vr_indadepr).vljrmprj := rw_crapepr.vljrmprj;
            pr_tab_dados_epr(vr_indadepr).slprjori := rw_crapepr.vlprejuz;
          
            /* Daniel */
            vr_flpgmujm := FALSE;
            pr_tab_dados_epr(vr_indadepr).vlsdprej := nvl(rw_crapepr.vlsdprej
                                                         ,0) +
                                                      (pr_tab_dados_epr(vr_indadepr)
                                                       .vlttmupr - pr_tab_dados_epr(vr_indadepr)
                                                       .vlpgmupr) +
                                                      (pr_tab_dados_epr(vr_indadepr)
                                                       .vlttjmpr - pr_tab_dados_epr(vr_indadepr)
                                                       .vlpgjmpr);
          
            /* Verificacao para saber se foi pago multa e juros de mora */
            IF pr_tab_dados_epr(vr_indadepr)
             .vlttmupr - pr_tab_dados_epr(vr_indadepr).vlpgmupr <= 0
                AND pr_tab_dados_epr(vr_indadepr)
               .vlttjmpr - pr_tab_dados_epr(vr_indadepr).vlpgjmpr <= 0 THEN
              vr_flpgmujm := TRUE;
            END IF;
          
            -- Busca dos lan�amentos cfme lista de hist�ricos passado
            -- --- ------------------------------
            -- 382 PAG.PREJ.ORIG
            -- 383 ABONO PREJUIZO
            -- 390 SERV./TAXAS
            -- 391 PAG. PREJUIZO
            FOR rw_craplem IN cr_craplem(pr_nrctremp  => rw_crapepr.nrctremp
                                        ,pr_lsthistor => '391,382,383,390') LOOP
              -- Para pagamento de prejuizos 391 e 382
              IF rw_craplem.cdhistor IN (391, 382) THEN
                -- Adicionar no campo valor pagos
                pr_tab_dados_epr(vr_indadepr).vlrpagos := NVL(pr_tab_dados_epr(vr_indadepr)
                                                              .vlrpagos
                                                             ,0) +
                                                          rw_craplem.vllanmto;
              END IF;
            
              /* Somente sera mostrado o valor do Saldo Prejuizo Original,
              quando o valor da multa e juros de mora for pago total   */
              IF ((vr_flpgmujm) AND (rw_craplem.cdhistor IN (382, 383))) THEN
                -- Decrementar no campo saldo prejuizo origem
                pr_tab_dados_epr(vr_indadepr).slprjori := NVL(pr_tab_dados_epr(vr_indadepr)
                                                              .slprjori
                                                             ,0) -
                                                          rw_craplem.vllanmto;
              END IF;
              -- Somente para o Abono Prejuizo 383
              IF rw_craplem.cdhistor = 383 THEN
                -- Considerar este como o abono
                pr_tab_dados_epr(vr_indadepr).vlrabono := rw_craplem.vllanmto;
              END IF;
              -- Somente para Serv.TAxas 390
              IF rw_craplem.cdhistor = 390 THEN
                -- Adicionar no campo vlr acrescimo
                pr_tab_dados_epr(vr_indadepr).vlacresc := NVL(pr_tab_dados_epr(vr_indadepr)
                                                              .vlacresc
                                                             ,0) +
                                                          rw_craplem.vllanmto;
              END IF;
            END LOOP;
          
            /* Como nao tem historico para multa e juros de mora, precisamos
            diminuir do valor total pago da multa e juros de mora      */
            IF vr_flpgmujm THEN
              pr_tab_dados_epr(vr_indadepr).slprjori := pr_tab_dados_epr(vr_indadepr)
                                                        .slprjori + pr_tab_dados_epr(vr_indadepr)
                                                        .vlpgmupr + pr_tab_dados_epr(vr_indadepr)
                                                        .vlpgjmpr;
            END IF;
          
            -- Ao final, garantir que o saldo prejuizo original n�o fique inferior a zero
            IF pr_tab_dados_epr(vr_indadepr).slprjori < 0 THEN
              pr_tab_dados_epr(vr_indadepr).slprjori := 0;
            END IF;
          END IF;
        
          -- Para empr�stimos Pr�-fixado
          IF rw_crapepr.tpemprst = 1 THEN
            -- Quantidade de meses decorridos vem da crapepr
            pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec;
          ELSE
            -- Para empr�stimos de debito em conta
            IF rw_crapepr.flgpagto = 0 THEN
              -- Se a parcela vence no m�s corrente
              IF trunc(pr_rw_crapdat.dtmvtolt, 'mm') =
                 trunc(rw_crapepr.dtdpagto, 'mm') THEN
                -- Se ainda n�o foi pago
                IF rw_crapepr.dtdpagto <= pr_rw_crapdat.dtmvtolt THEN
                  -- Incrementar a quantidade de parcelas
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec + 1;
                ELSE
                  -- Consideramos a quantidade j� calculadao
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec;
                END IF;
                -- Se foi paga no m�s corrente
              ELSIF trunc(pr_rw_crapdat.dtmvtolt, 'mm') =
                    trunc(rw_crapepr.dtmvtolt, 'mm') THEN
                -- Se for um contrato do m�s
                IF to_char(vr_dtinipag, 'mm') =
                   to_char(pr_rw_crapdat.dtmvtolt, 'mm') THEN
                  -- Devia ter pago a primeira no mes do contrato
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec + 1;
                ELSE
                  -- Paga a primeira somente no mes seguinte
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec;
                END IF;
              ELSE
                -- Se a parcela vai vencer OU foi paga no m�s corrEnte
                IF rw_crapepr.dtdpagto > pr_rw_crapdat.dtmvtolt
                   or (rw_crapepr.dtdpagto < pr_rw_crapdat.dtmvtolt AND
                   to_number(to_char(rw_crapepr.dtdpagto, 'dd')) <=
                   to_number(to_char(pr_rw_crapdat.dtmvtolt, 'dd'))) THEN
                  -- Incrementar a quantidade de parcelas
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec + 1;
                ELSE
                  -- Consideramos a quantidade j� calculadao
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec;
                END IF;
              END IF;
            
            ELSE
              --> Para desconto em folha
              -- Para contratos do Mes
              IF trunc(rw_crapepr.dtmvtolt, 'mm') =
                 trunc(pr_rw_crapdat.dtmvtolt, 'mm') THEN
                -- Ainda nao atualizou o qtmesdec
                pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec;
              ELSE
                -- Verificar se existe aviso de d�bito em conta corrente n�o processado
                vr_flghaavs := 'N';
                OPEN cr_crapavs(pr_nrdconta => pr_nrdconta);
                FETCH cr_crapavs
                  INTO vr_flghaavs;
                CLOSE cr_crapavs;
                -- Se houve
                IF vr_flghaavs = 'S' THEN
                  -- Utilizar a quantidade j� calculada
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec;
                ELSE
                  -- Adicionar 1 m�s a quantidade calculada
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec + 1;
                END IF;
              END IF;
            END IF;
          
            -- Garantir que a quantidade decorrida n�o seja negativa
            IF pr_tab_dados_epr(vr_indadepr).qtmesdec < 0 THEN
              pr_tab_dados_epr(vr_indadepr).qtmesdec := 0;
            END IF;
          
          END IF;
        
          -- Montar descri��o de parcelas a pagar
          pr_tab_dados_epr(vr_indadepr).dspreapg := '   ' ||
                                                    to_char(vr_qtprecal
                                                           ,'990d0000') || '/' ||
                                                    to_char(rw_crapepr.qtpreemp
                                                           ,'fm000') ||
                                                    ' ->' ||
                                                    to_char(vr_qtpreapg
                                                           ,'990d0000');
          pr_tab_dados_epr(vr_indadepr).qtpreapg := vr_qtpreapg;
          -- Guardar o valor presta��es a pagar cfme j� calculado
          IF rw_crapepr.tpemprst = 1 THEN
            -- Quantidade de meses decorridos vem da crapepr
            pr_tab_dados_epr(vr_indadepr).vlpreapg := vr_vlpreapg;
          ELSE
            -- Se a quantidade calculada de parcelas for superior a de meses decorridos
            -- e a data de pagamento for inferior a data atual
            -- e n�o � um empr�stimo de d�bito em conta
            IF rw_crapepr.qtprecal > rw_crapepr.qtmesdec
               AND rw_crapepr.dtdpagto <= pr_rw_crapdat.dtmvtolt
               AND rw_crapepr.flgpagto = 0 THEN
              -- Valor a pagar � a diferen�a do total e o pago
              pr_tab_dados_epr(vr_indadepr).vlpreapg := rw_crapepr.vlpreemp -
                                                        vr_vlprepag;
              -- Garantir que n�o fique negativo
              IF pr_tab_dados_epr(vr_indadepr).vlpreapg < 0 THEN
                pr_tab_dados_epr(vr_indadepr).vlpreapg := 0;
              END IF;
            ELSE
            
              -- Se a quantidade decorrida j� gravada na tabela - a qtde de parcelas calculadas for superior a zero
              IF (pr_tab_dados_epr(vr_indadepr).qtmesdec - vr_qtprecal) > 0 THEN
                -- Calcular o valor pendente com base na diferen�a entre decorridos e calculado * valor da parcela
                pr_tab_dados_epr(vr_indadepr).vlpreapg := (pr_tab_dados_epr(vr_indadepr)
                                                          .qtmesdec -
                                                           vr_qtprecal) *
                                                          rw_crapepr.vlpreemp;
              ELSE
                -- N�o h� mais valor pendente
                pr_tab_dados_epr(vr_indadepr).vlpreapg := 0;
              END IF;
            
            END IF;
          
            -- Se a quantidade de meses decorridas armazenada for superior a de parcelas
            -- OU se o valor pendente a pagar for superior ao saldo devedor calculado
            IF pr_tab_dados_epr(vr_indadepr)
             .qtmesdec > rw_crapepr.qtpreemp
                OR pr_tab_dados_epr(vr_indadepr).vlpreapg > vr_vlsdeved THEN
              -- Considerar o saldo devedor calculado como o pendente a pagar
              pr_tab_dados_epr(vr_indadepr).vlpreapg := vr_vlsdeved;
            END IF;
            -- Garantir que n�o fique negativo
            IF pr_tab_dados_epr(vr_indadepr).vlpreapg < 0 THEN
              pr_tab_dados_epr(vr_indadepr).vlpreapg := 0;
            END IF;
          END IF;
        
          -- Copiar quantidade de parcelas calculadas
          pr_tab_dados_epr(vr_indadepr).qtprecal := vr_qtprecal;
          pr_tab_dados_epr(vr_indadepr).vltotpag := nvl(pr_tab_dados_epr(vr_indadepr)
                                                        .vlpreapg
                                                       ,0) +
                                                    nvl(pr_tab_dados_epr(vr_indadepr)
                                                        .vlmrapar
                                                       ,0) +
                                                    nvl(pr_tab_dados_epr(vr_indadepr)
                                                        .vlmtapar
                                                       ,0);
        
          -- Calcular Parcela/Atraso
          vr_qtmesdec := pr_tab_dados_epr(vr_indadepr)
                         .qtmesdec - pr_tab_dados_epr(vr_indadepr).qtprecal;
          vr_qtpreemp := pr_tab_dados_epr(vr_indadepr)
                         .qtpreemp - pr_tab_dados_epr(vr_indadepr).qtprecal;
          -- Se quantidade decorrida for superior a de parcelas
          IF vr_qtmesdec > vr_qtpreemp THEN
            -- Considerar como atraso a quantidade de parcelas
            pr_tab_dados_epr(vr_indadepr).qtmesatr := vr_qtpreemp;
          ELSE
            -- Considerar como atraso os meses decorridos
            pr_tab_dados_epr(vr_indadepr).qtmesatr := vr_qtmesdec;
          END IF;
          -- Garantir que a quantidade em atraso n�o fique negativa
          IF pr_tab_dados_epr(vr_indadepr).qtmesatr < 0 THEN
            pr_tab_dados_epr(vr_indadepr).qtmesatr := 0;
          END IF;
        
          OPEN cr_crapass(pr_nrdconta => pr_nrdconta);
          FETCH cr_crapass
            INTO rw_crapass;
          -- Se encontrou
          IF cr_crapass%FOUND THEN
            OPEN cr_crappre(pr_cdcooper => pr_cdcooper
                           ,pr_inpessoa => rw_crapass.inpessoa
                           ,pr_cdfinemp => rw_crapepr.cdfinemp);
            FETCH cr_crappre
              INTO rw_crappre;
            -- Se encontrou
            IF cr_crappre%FOUND THEN
              pr_tab_dados_epr(vr_indadepr).flgpreap := TRUE;
            END IF;
            -- Fechar o cursor
            CLOSE cr_crappre;
          
          END IF;
          -- Fechar o cursor
          CLOSE cr_crapass;
          -- atribuicao para controle da paginacao
          vr_nrregist := vr_nrregist - 1;
        
        EXCEPTION
          WHEN vr_exc_next THEN
            null; --> Apenas ignorar e partir ao pr�ximo registro
        END;
      END LOOP;
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                            ,pr_dstransa => 'Obter dados dos emprestimos do associado'
                            ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => NVL(vr_cdcritic, 0)
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado log
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Obter dados dos emprestimos do associado'
                              ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                               ,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        
        END IF;
      WHEN vr_exc_erro2 THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Copiar variavel tempor�ria para a de sa�da de erro
        pr_tab_erro := vr_tab_erro;
        -- Se foi solicitado log
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_tab_erro(vr_tab_erro.FIRST)
                                              .dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Obter dados dos emprestimos do associado'
                              ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        
        END IF;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_obtem_dados_empresti --> ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado log
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Obter dados dos emprestimos do associado'
                              ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        
        END IF;
    END;
  END pc_obtem_dados_empresti;
  
  /* Procedure para obter dados de emprestimos do associado - Chamada AyllosWeb */
  PROCEDURE pc_obtem_dados_empresti_web(  pr_nrdconta       IN crapass.nrdconta%TYPE    --> Conta do associado
                                         ,pr_idseqttl       IN crapttl.idseqttl%TYPE    --> Sequencia de titularidade da conta
                                         ,pr_dtcalcul       IN DATE                     --> Data solicitada do calculo
                                         ,pr_nrctremp       IN crapepr.nrctremp%TYPE    --> N�mero contrato empr�stimo
                                         ,pr_cdprogra       IN crapprg.cdprogra%TYPE    --> Programa conectado
                                         ,pr_flgerlog       IN VARCHAR2                 --> Gerar log S/N
                                         ,pr_flgcondc       IN INTEGER                  --> Mostrar emprestimos liquidados sem prejuizo
                                         ,pr_nriniseq       IN INTEGER                  --> Numero inicial da paginacao
                                         ,pr_nrregist       IN INTEGER                  --> Numero de registros por pagina
                                         ,pr_xmllog         IN VARCHAR2                 --> XML com informa��es de LOG
                                          -- OUT
                                         ,pr_cdcritic OUT PLS_INTEGER                   --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2                      --> Descric?o da critica
                                         ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS                  --> Erros do processo

  /* .............................................................................

       Programa: pc_obtem_dados_empresti_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana (AMcom)
       Data    : Agosto/2015.                         Ultima atualizacao: 23/11/2015

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Chamada para ayllosWeb(mensageria)
                   Procedure para obter dados de emprestimos do associado

       Alteracoes: 23/11/2015 - Incluido nvl no campo pr_nrctremp devido no ayllosweb
                                as vezes vir campo nulo conforme a navega��o (Odirlei-AMcom)

    ............................................................................. */

    -------------------------- VARIAVEIS ----------------------
    -- Cursor gen�rico de calend�rio
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    -- variaveis de retorno
    vr_tab_dados_epr typ_tab_dados_epr;
    vr_tab_erro      gene0001.typ_tab_erro;
    vr_qtregist      NUMBER;

    --Variaveis para busca de parametros
    vr_dstextab            craptab.dstextab%TYPE;
    vr_dstextab_parempctl  craptab.dstextab%TYPE;
    vr_dstextab_digitaliza craptab.dstextab%TYPE;
    -- Variaveis de entrada vindas no xml
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    --Indicador de utiliza��o da tabela
    vr_inusatab BOOLEAN;
    --Nome Primeiro Titular
    vr_nmprimtl crapass.nmprimtl%TYPE;

    -- Vari�veis para armazenar as informa��es em XML
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    vr_index           VARCHAR2(100);
    -------------------------------  CURSORES  -------------------------------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;


    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na vari�vel CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    -- Leitura do calend�rio da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;

    -- Se n�o encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- busca o tipo de documento GED
    vr_dstextab_digitaliza := tabe0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                                        ,pr_nmsistem => 'CRED'
                                                        ,pr_tptabela => 'GENERI'
                                                        ,pr_cdempres => 00
                                                        ,pr_cdacesso => 'DIGITALIZA'
                                                        ,pr_tpregist => 5);

    -- Leitura do indicador de uso da tabela de taxa de juros
    vr_dstextab_parempctl := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'USUARI'
                                                       ,pr_cdempres => 11
                                                       ,pr_cdacesso => 'PAREMPCTL'
                                                       ,pr_tpregist => 01);


    --Buscar Indicador Uso tabela
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'TAXATABELA'
                                            ,pr_tpregist => 0);
    --Se nao encontrou
    IF vr_dstextab IS NULL THEN
      --Nao usa tabela
      vr_inusatab:= FALSE;
    ELSE
      IF  SUBSTR(vr_dstextab,1,1) = '0' THEN
        --Nao usa tabela
        vr_inusatab:= FALSE;
      ELSE
        --Nao usa tabela
        vr_inusatab:= TRUE;
      END IF;
    END IF;

    -- Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => vr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;

    /* Procedure para obter dados de emprestimos do associado */
    empr0001.pc_obtem_dados_empresti
                           (pr_cdcooper       => vr_cdcooper           --> Cooperativa conectada
                           ,pr_cdagenci       => vr_cdagenci           --> C�digo da ag�ncia
                           ,pr_nrdcaixa       => vr_nrdcaixa           --> N�mero do caixa
                           ,pr_cdoperad       => vr_cdoperad           --> C�digo do operador
                           ,pr_nmdatela       => vr_nmdatela           --> Nome datela conectada
                           ,pr_idorigem       => vr_idorigem           --> Indicador da origem da chamada
                           ,pr_nrdconta       => pr_nrdconta           --> Conta do associado
                           ,pr_idseqttl       => pr_idseqttl           --> Sequencia de titularidade da conta
                           ,pr_rw_crapdat     => rw_crapdat            --> Vetor com dados de par�metro (CRAPDAT)
                           ,pr_dtcalcul       => pr_dtcalcul           --> Data solicitada do calculo
                           ,pr_nrctremp       => nvl(pr_nrctremp,0)    --> N�mero contrato empr�stimo
                           ,pr_cdprogra       => pr_cdprogra           --> Programa conectado
                           ,pr_inusatab       => vr_inusatab     --> Indicador de utiliza��o da tabela
                           ,pr_flgerlog       => pr_flgerlog           --> Gerar log S/N
                           ,pr_flgcondc       => (CASE pr_flgcondc     --> Mostrar emprestimos liquidados sem prejuizo
                                                    WHEN 1 THEN TRUE
                                                    ELSE FALSE END)
                           ,pr_nmprimtl       => rw_crapass.nmprimtl   --> Nome Primeiro Titular
                           ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                           ,pr_tab_digitaliza => vr_dstextab_digitaliza--> Dados tabela parametro
                           ,pr_nriniseq       => pr_nriniseq           --> Numero inicial da paginacao
                           ,pr_nrregist       => pr_nrregist           --> Numero de registros por pagina
                           ,pr_qtregist       => vr_qtregist           --> Qtde total de registros
                           ,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empr�stimo
                           ,pr_des_reto       => vr_des_reto           --> Retorno OK / NOK
                           ,pr_tab_erro       => vr_tab_erro);         --> Tabela com poss�ves erros

    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN

        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      ELSE
        vr_dscritic := 'N�o foi possivel obter dados de emprestimos.';
      END IF;
      RAISE vr_exc_erro;
      
    END IF;


    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informa��es do XML
    vr_texto_completo := NULL;

    pc_escreve_xml ('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>' ||
                      '<Dados qtregist="' || vr_qtregist ||'" >');


    -- ler os registros de emprestimos e incluir no xml
    vr_index := vr_tab_dados_epr.first;
    WHILE vr_index IS NOT NULL LOOP
      pc_escreve_xml ('<inf>' ||
                        '<nrdconta>' || vr_tab_dados_epr(vr_index).nrdconta || '</nrdconta>' ||
                        '<cdagenci>' || vr_tab_dados_epr(vr_index).cdagenci || '</cdagenci>' ||
                        '<nmprimtl>' || vr_tab_dados_epr(vr_index).nmprimtl || '</nmprimtl>' ||
                        '<nrctremp>' || vr_tab_dados_epr(vr_index).nrctremp || '</nrctremp>' ||
                        '<vlemprst>' || vr_tab_dados_epr(vr_index).vlemprst || '</vlemprst>' ||
                        '<vlsdeved>' || vr_tab_dados_epr(vr_index).vlsdeved || '</vlsdeved>' ||
                        '<vlpreemp>' || vr_tab_dados_epr(vr_index).vlpreemp || '</vlpreemp>' ||
                        '<vlprepag>' || nvl(vr_tab_dados_epr(vr_index).vlprepag,0) || '</vlprepag>' ||
                        '<txjuremp>' || to_char(vr_tab_dados_epr(vr_index).txjuremp,'990D00000000') || '</txjuremp>' ||
                        '<vljurmes>' || vr_tab_dados_epr(vr_index).vljurmes || '</vljurmes>' ||
                        '<vljuracu>' || vr_tab_dados_epr(vr_index).vljuracu || '</vljuracu>' ||
                        '<vlprejuz>' || vr_tab_dados_epr(vr_index).vlprejuz || '</vlprejuz>' ||
                        '<vlsdprej>' || vr_tab_dados_epr(vr_index).vlsdprej || '</vlsdprej>' ||
                        '<dtprejuz>' || to_char(vr_tab_dados_epr(vr_index).dtprejuz,'DD/MM/RRRR') || '</dtprejuz>' ||
                        '<vljrmprj>' || vr_tab_dados_epr(vr_index).vljrmprj || '</vljrmprj>' ||
                        '<vljraprj>' || vr_tab_dados_epr(vr_index).vljraprj || '</vljraprj>' ||
                        '<inprejuz>' || vr_tab_dados_epr(vr_index).inprejuz || '</inprejuz>' ||
                        '<vlprovis>' || vr_tab_dados_epr(vr_index).vlprovis || '</vlprovis>' ||
                        '<flgpagto>' || (CASE vr_tab_dados_epr(vr_index).flgpagto 
                                            WHEN 1 THEN 'yes'
                                            ELSE 'no' 
                                          END)                              || '</flgpagto>' ||
                        '<dtdpagto>' || to_char(vr_tab_dados_epr(vr_index).dtdpagto,'DD/MM/RRRR') || '</dtdpagto>' ||
                        '<cdpesqui>' || vr_tab_dados_epr(vr_index).cdpesqui || '</cdpesqui>' ||
                        '<dspreapg>' || vr_tab_dados_epr(vr_index).dspreapg || '</dspreapg>' ||
                        '<cdlcremp>' || vr_tab_dados_epr(vr_index).cdlcremp || '</cdlcremp>' ||
                        '<dslcremp>' || vr_tab_dados_epr(vr_index).dslcremp || '</dslcremp>' ||
                        '<cdfinemp>' || vr_tab_dados_epr(vr_index).cdfinemp || '</cdfinemp>' ||
                        '<dsfinemp>' || vr_tab_dados_epr(vr_index).dsfinemp || '</dsfinemp>' ||
                        '<dsdaval1>' || vr_tab_dados_epr(vr_index).dsdaval1 || '</dsdaval1>' ||
                        '<dsdaval2>' || vr_tab_dados_epr(vr_index).dsdaval2 || '</dsdaval2>' ||
                        '<vlpreapg>' || nvl(vr_tab_dados_epr(vr_index).vlpreapg,0) || '</vlpreapg>' ||
                        '<qtmesdec>' || vr_tab_dados_epr(vr_index).qtmesdec || '</qtmesdec>' ||
                        '<qtprecal>' || vr_tab_dados_epr(vr_index).qtprecal || '</qtprecal>' ||
                        '<vlacresc>' || vr_tab_dados_epr(vr_index).vlacresc || '</vlacresc>' ||
                        '<vlrpagos>' || vr_tab_dados_epr(vr_index).vlrpagos || '</vlrpagos>' ||
                        '<slprjori>' || vr_tab_dados_epr(vr_index).slprjori || '</slprjori>' ||
                        '<dtmvtolt>' || to_char(vr_tab_dados_epr(vr_index).dtmvtolt,'DD/MM/RRRR') || '</dtmvtolt>' ||
                        '<qtpreemp>' || vr_tab_dados_epr(vr_index).qtpreemp || '</qtpreemp>' ||
                        '<dtultpag>' || to_char(vr_tab_dados_epr(vr_index).dtultpag,'DD/MM/RRRR') || '</dtultpag>' ||
                        '<vlrabono>' || vr_tab_dados_epr(vr_index).vlrabono || '</vlrabono>' ||
                        '<qtaditiv>' || vr_tab_dados_epr(vr_index).qtaditiv || '</qtaditiv>' ||
                        '<dsdpagto>' || vr_tab_dados_epr(vr_index).dsdpagto || '</dsdpagto>' ||
                        '<dsdavali>' || vr_tab_dados_epr(vr_index).dsdavali || '</dsdavali>' ||
                        '<qtmesatr>' || vr_tab_dados_epr(vr_index).qtmesatr || '</qtmesatr>' ||
                        '<qtpromis>' || vr_tab_dados_epr(vr_index).qtpromis || '</qtpromis>' ||
                        '<flgimppr>' || (CASE vr_tab_dados_epr(vr_index).flgimppr 
                                            WHEN 1 THEN 'yes'
                                            ELSE 'no' 
                                          END)                              || '</flgimppr>' ||
                        '<flgimpnp>' || (CASE vr_tab_dados_epr(vr_index).flgimpnp 
                                            WHEN 1 THEN 'yes'
                                            ELSE 'no' 
                                          END)                              || '</flgimpnp>' ||
                        '<idseleca>' || vr_tab_dados_epr(vr_index).idseleca || '</idseleca>' ||
                        '<nrdrecid>' || vr_tab_dados_epr(vr_index).nrdrecid || '</nrdrecid>' ||
                        '<tplcremp>' || vr_tab_dados_epr(vr_index).tplcremp || '</tplcremp>' ||
                        '<tpemprst>' || vr_tab_dados_epr(vr_index).tpemprst || '</tpemprst>' ||
                        '<cdtpempr>' || vr_tab_dados_epr(vr_index).cdtpempr || '</cdtpempr>' ||
                        '<dstpempr>' || vr_tab_dados_epr(vr_index).dstpempr || '</dstpempr>' ||
                        '<permulta>' || vr_tab_dados_epr(vr_index).permulta || '</permulta>' ||
                        '<perjurmo>' || vr_tab_dados_epr(vr_index).perjurmo || '</perjurmo>' ||
                        '<dtpripgt>' || to_char(vr_tab_dados_epr(vr_index).dtpripgt,'DD/MM/RRRR') || '</dtpripgt>' ||
                        '<inliquid>' || vr_tab_dados_epr(vr_index).inliquid || '</inliquid>' ||
                        '<txmensal>' || vr_tab_dados_epr(vr_index).txmensal || '</txmensal>' ||
                        '<flgatras>' || (CASE vr_tab_dados_epr(vr_index).flgatras
                                            WHEN 1 THEN 'yes'
                                            ELSE 'no' 
                                          END)                              || '</flgatras>' ||
                        '<dsidenti>' || vr_tab_dados_epr(vr_index).dsidenti || '</dsidenti>' ||
                        '<flgdigit>' || (CASE vr_tab_dados_epr(vr_index).flgdigit
                                            WHEN 1 THEN 'yes'
                                            ELSE 'no' 
                                          END)                              || '</flgdigit>' ||
                        '<tpdocged>' || vr_tab_dados_epr(vr_index).tpdocged || '</tpdocged>' ||
                        '<vlpapgat>' || vr_tab_dados_epr(vr_index).vlpapgat || '</vlpapgat>' ||
                        '<vlsdevat>' || vr_tab_dados_epr(vr_index).vlsdevat || '</vlsdevat>' ||
                        '<qtpcalat>' || vr_tab_dados_epr(vr_index).qtpcalat || '</qtpcalat>' ||
                        '<qtmdecat>' || vr_tab_dados_epr(vr_index).qtmdecat || '</qtmdecat>' ||
                        '<tpdescto>' || vr_tab_dados_epr(vr_index).tpdescto || '</tpdescto>' ||
                        '<qtlemcal>' || vr_tab_dados_epr(vr_index).qtlemcal || '</qtlemcal>' ||
                        '<vlppagat>' || vr_tab_dados_epr(vr_index).vlppagat || '</vlppagat>' ||
                        '<vlmrapar>' || vr_tab_dados_epr(vr_index).vlmrapar || '</vlmrapar>' ||
                        '<vlmtapar>' || vr_tab_dados_epr(vr_index).vlmtapar || '</vlmtapar>' ||
                        '<vltotpag>' || vr_tab_dados_epr(vr_index).vltotpag || '</vltotpag>' ||
                        '<vlprvenc>' || vr_tab_dados_epr(vr_index).vlprvenc || '</vlprvenc>' ||
                        '<vlpraven>' || vr_tab_dados_epr(vr_index).vlpraven || '</vlpraven>' ||
                        '<flgpreap>' || (CASE WHEN vr_tab_dados_epr(vr_index).flgpreap THEN 1
                                              ELSE 0 END) || '</flgpreap>' ||
                        '<cdorigem>' || vr_tab_dados_epr(vr_index).cdorigem || '</cdorigem>' ||
                        '<vlttmupr>' || vr_tab_dados_epr(vr_index).vlttmupr || '</vlttmupr>' ||
                        '<vlttjmpr>' || vr_tab_dados_epr(vr_index).vlttjmpr || '</vlttjmpr>' ||
                        '<vlpgmupr>' || vr_tab_dados_epr(vr_index).vlpgmupr || '</vlpgmupr>' ||
                        '<vlpgjmpr>' || vr_tab_dados_epr(vr_index).vlpgjmpr || '</vlpgjmpr>' ||
                        '<liquidia>' || vr_tab_dados_epr(vr_index).liquidia || '</liquidia>' ||
                        '<qtimpctr>' || vr_tab_dados_epr(vr_index).qtimpctr || '</qtimpctr>' ||
                        '<portabil>' || vr_tab_dados_epr(vr_index).portabil || '</portabil>' ||
                      '</inf>' );

      -- buscar proximo
      vr_index := vr_tab_dados_epr.next(vr_index);
    END LOOP;

    pc_escreve_xml ('</Dados></Root>',TRUE);

    pr_retxml := XMLType.createXML(vr_des_xml);
    -- Liberando a mem�ria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas c�digo
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN

      -- Montar descri��o de erro n�o tratado
      pr_dscritic := 'Erro n�o tratado na EMPR0001.pc_obtem_dados_empresti_web ' ||
                     SQLERRM;
  END pc_obtem_dados_empresti_web;
  
  
  /* Calcular o saldo devedor do emprestimo */
  PROCEDURE pc_calc_saldo_epr(pr_cdcooper   IN crapcop.cdcooper%TYPE --> C�digo da Cooperativa
                             ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                             ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Programa que solicitou o calculo
                             ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta do empr�stimo
                             ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato do empr�stimo
                             ,pr_inusatab   IN BOOLEAN --> Indicador de utiliza��o da tabela de juros
                             ,pr_vlsdeved   OUT NUMBER --> Saldo devedor do empr�stimo
                             ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de parcelas do empr�stimo
                             ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> C�digo de critica encontrada
                             ,pr_des_erro   OUT VARCHAR2) IS --> Retorno de Erro
  BEGIN
    /* .............................................................................
    
       Programa: pc_calc_saldo_epr (antigo Fontes/saldo_epr.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Edson
       Data    : Junho/2004.                         Ultima atualizacao: 05/02/2013
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : Calcular o saldo devedor do emprestimo.
    
       Alteracoes:  Passado parametro quantidade prestacoes calculadas(Mirtes)
    
                    26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
    
                    01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
    
                    12/03/2012 - Declarado variaveis necessarias para utilizacao
                                 da include lelem.i (Tiago).
    
                    21/05/2012 - Buscar saldo do novo tipo de emprestimo
                                 (Gabriel)
    
                    05/02/2013 - Convers�o Progress >> Oracle PLSQL (Marcos-Supero)
    
                    12/03/2014 - Alterada a chamada para da  pc_busca_pgto_parcelas
                                 para pc_busca_pgto_parcelas_prefix (Odirlei-AMcom)
    ............................................................................. */
    DECLARE
      -- Dia e data de pagamento de empr�stimo
      vr_tab_diapagto NUMBER;
      vr_tab_dtcalcul DATE;
      -- Flag para desconto em folha
      vr_tab_flgfolha BOOLEAN;
      -- Configura��o para m�s novo
      vr_tab_ddmesnov INTEGER;
      /* Rowtype com informa��es dos empr�stimos */
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.nrdconta
              ,epr.nrctremp
              ,epr.vljuracu
              ,epr.vlsdeved
              ,epr.vlemprst
              ,epr.qtpreemp
              ,epr.dtdpagto
              ,epr.txmensal
              ,epr.qtprepag
              ,epr.tpemprst
              ,epr.txjuremp
              ,epr.cdlcremp
              ,epr.inliquid
              ,epr.qttolatr
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
               AND epr.nrdconta = pr_nrdconta
               AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      -- Busca das linhas de cr�dito
      CURSOR cr_craplcr(pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT lcr.txdiaria
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper
               AND lcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      -- Vari�veis para passagem a rotina pc_calcula_lelem e pc_busca_pgto_parcelas
      vr_diapagto     INTEGER;
      vr_qtprepag     crapepr.qtprepag%TYPE;
      vr_qtprecal_lem crapepr.qtprecal%TYPE;
      vr_vlprepag     craplem.vllanmto%TYPE;
      --vr_vljuracu     crapepr.vljuracu%TYPE;
      --vr_vljurmes     crapepr.vljurmes%TYPE;
      --vr_vlsdeved     crapepr.vlsdeved%TYPE;
      vr_vljuracu        NUMBER;
      vr_vljurmes        NUMBER;
      vr_vlsdeved        NUMBER;
      vr_dtultpag        crapepr.dtultpag%TYPE;
      vr_txdjuros        crapepr.txjuremp%TYPE;
      vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel; --> Tabela com registros de pagamentos
      vr_tab_calculado   empr0001.typ_tab_calculado; --> Tabela com totais calculados
    BEGIN
      -- Buscar a configura��o de empr�stimo cfme a empresa da conta
      pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                                ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data atual
                                ,pr_nrdconta => pr_nrdconta --> Numero da conta do empr�stimo
                                ,pr_dtcalcul => vr_tab_dtcalcul --> Data calculada de pagamento
                                ,pr_diapagto => vr_tab_diapagto --> Dia de pagamento das parcelas
                                ,pr_flgfolha => vr_tab_flgfolha --> Flag de desconto em folha S/N
                                ,pr_ddmesnov => vr_tab_ddmesnov --> Configura��o para m�s novo
                                ,pr_cdcritic => pr_cdcritic --> C�digo do erro
                                ,pr_des_erro => vr_des_erro); --> Retorno de Erro
      -- Se houve erro na rotina
      IF vr_des_erro IS NOT NULL
         OR pr_cdcritic IS NOT NULL THEN
        -- Levantar exce��o
        RAISE vr_exc_erro;
      END IF;
      -- Busca dos detalhes do empr�stimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr
        INTO rw_crapepr;
      -- Se n�o encontrar informa��es
      IF cr_crapepr%NOTFOUND THEN
        -- Fechar o cursor pois teremos raise
        CLOSE cr_crapepr;
        -- Gerar erro com critica 356
        pr_cdcritic := 356;
        vr_des_erro := gene0001.fn_busca_critica(356);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor para continuar o processo
        CLOSE cr_crapepr;
      END IF;
      -- Se est� setado para utilizarmos a tabela de juros
      -- e o empr�stimo ainda n�o est� liquidado
      IF pr_inusatab
         AND rw_crapepr.inliquid = 0 THEN
        -- Iremos buscar a tabela de juros nas linhas de cr�dito
        OPEN cr_craplcr(pr_cdlcremp => rw_crapepr.cdlcremp);
        FETCH cr_craplcr
          INTO rw_craplcr;
        -- Se n�o encontrar
        IF cr_craplcr%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craplcr;
          -- Gerar erro
          pr_cdcritic := 363;
          vr_des_erro := gene0001.fn_busca_critica(363);
          RAISE vr_exc_erro;
        ELSE
          -- Fechar o cursor
          CLOSE cr_craplcr;
          -- Utilizar a taxa encontrada
          vr_txdjuros := rw_craplcr.txdiaria;
        END IF;
      ELSE
        -- Usar taxa cadastrada no empr�stimo
        vr_txdjuros := rw_crapepr.txjuremp;
      END IF;
      -- Para empr�stimo atual
      IF rw_crapepr.tpemprst = 0 THEN
        -- Povoar Vari�veis para o calculo com os valores do empr�stimo
        vr_diapagto := vr_tab_diapagto;
        vr_qtprepag := NVL(rw_crapepr.qtprepag, 0);
        vr_vlprepag := 0;
        vr_vlsdeved := NVL(rw_crapepr.vlsdeved, 0);
        vr_vljuracu := NVL(rw_crapepr.vljuracu, 0);
        vr_vljurmes := 0;
        vr_dtultpag := LAST_DAY(pr_rw_crapdat.dtmvtolt);
        -- Chamar rotina de c�lculo externa
        empr0001.pc_leitura_lem(pr_cdcooper   => pr_cdcooper
                               ,pr_cdprogra   => pr_cdprogra
                               ,pr_rw_crapdat => pr_rw_crapdat
                               ,pr_nrdconta   => rw_crapepr.nrdconta
                               ,pr_nrctremp   => rw_crapepr.nrctremp
                               ,pr_dtcalcul   => NULL
                               ,pr_diapagto   => vr_diapagto
                               ,pr_txdjuros   => vr_txdjuros
                               ,pr_qtprepag   => vr_qtprepag
                               ,pr_qtprecal   => vr_qtprecal_lem
                               ,pr_vlprepag   => vr_vlprepag
                               ,pr_vljuracu   => vr_vljuracu
                               ,pr_vljurmes   => vr_vljurmes
                               ,pr_vlsdeved   => vr_vlsdeved
                               ,pr_dtultpag   => vr_dtultpag
                               ,pr_cdcritic   => pr_cdcritic
                               ,pr_des_erro   => vr_des_erro);
        -- Se a rotina retornou com erro
        IF vr_des_erro IS NOT NULL
           OR pr_cdcritic IS NOT NULL THEN
          -- Gerar excecao
          RAISE vr_exc_erro;
        END IF;
        -- Copiar os valores da rotina para as variaveis de sa�da
        pr_vlsdeved := vr_vlsdeved;
        pr_qtprecal := vr_qtprecal_lem;
      ELSE
        -- Pre-fixada
      
        /* Busca dos pagamentos das parcelas de empr�stimo prefixados*/
        EMPR0001.pc_busca_pgto_parcelas_prefix(pr_cdcooper      => pr_cdcooper --> Cooperativa conectada
                                              ,pr_cdagenci      => 1 --> C�digo da ag�ncia
                                              ,pr_nrdcaixa      => 999 --> N�mero do caixa
                                              ,pr_nrdconta      => pr_nrdconta --> N�mero da conta
                                              ,pr_nrctremp      => rw_crapepr.nrctremp --> N�mero do contrato de empr�stimo
                                              ,pr_rw_crapdat    => pr_rw_crapdat --> Vetor com dados de par�metro (CRAPDAT)
                                              ,pr_dtmvtolt      => pr_rw_crapdat.dtmvtolt --> Data de movimento
                                              ,pr_vlemprst      => rw_crapepr.vlemprst --> Valor do emprestioms
                                              ,pr_qtpreemp      => rw_crapepr.qtpreemp --> qtd de parcelas do emprestimo
                                              ,pr_dtdpagto      => rw_crapepr.dtdpagto --> data de pagamento
                                              ,pr_txmensal      => rw_crapepr.txmensal --> Taxa mensal do emprestimo
                                              ,pr_cdlcremp      => rw_crapepr.cdlcremp --> Taxa mensal do emprestimo
                                              ,pr_qttolatr      => rw_crapepr.qttolatr --> Quantidade de dias de tolerancia
                                              ,pr_des_reto      => vr_des_reto --> Retorno OK / NOK
                                              ,pr_tab_erro      => vr_tab_erro --> Tabela com poss�ves erros
                                              ,pr_tab_calculado => vr_tab_calculado); --> Tabela com totais calculados
      
        -- Se a rotina retornou erro
        IF vr_des_reto = 'NOK' THEN
          -- Buscar o erro encontrado para gravar na vr_des_erro
          pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          -- Gerar exce��o
          RAISE vr_exc_erro;
        END IF;
        -- Copiar os valores da rotina para as variaveis de sa�da
        pr_vlsdeved := vr_tab_calculado(vr_tab_calculado.FIRST).vlsderel;
        pr_qtprecal := vr_tab_calculado(vr_tab_calculado.FIRST).qtprecal;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a vari�vel de saida
        pr_cdcritic := nvl(pr_cdcritic, 0);
        pr_des_erro := vr_des_erro;
      WHEN OTHERS THEN
        -- Montar mensagem com o sqlerrm pois ocorreu um erro cr�tico
        pr_cdcritic := nvl(pr_cdcritic, 0);
        pr_des_erro := 'Problemas no procedimento empr0001.pc_calc_saldo_epr. Erro: ' ||
                       sqlerrm;
    END;
  END pc_calc_saldo_epr;

  /* Procedure para calcular saldo devedor de emprestimos */
  PROCEDURE pc_saldo_devedor_epr(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                ,pr_cdagenci   IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                ,pr_cdoperad   IN crapdev.cdoperad%TYPE --> C�digo do operador
                                ,pr_nmdatela   IN VARCHAR2 --> Nome datela conectada
                                ,pr_idorigem   IN INTEGER --> Indicador da origem da chamada
                                ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                                ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> N�mero contrato empr�stimo
                                ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Programa conectado
                                ,pr_inusatab   IN BOOLEAN --> Indicador de utiliza��o da tabela
                                ,pr_flgerlog   IN VARCHAR2 --> Gerar log S/N
                                ,pr_vlsdeved   IN OUT NUMBER --> Saldo devedor calculado
                                ,pr_vltotpre   IN OUT NUMBER --> Valor total das presta��es
                                ,pr_qtprecal   IN OUT crapepr.qtprecal%TYPE --> Parcelas calculadas
                                ,pr_des_reto   OUT VARCHAR --> Retorno OK / NOK
                                ,pr_tab_erro   OUT gene0001.typ_tab_erro) IS --> Tabela com poss�veis erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_saldo_devedor_epr (antigo b1wgen0002.p --> saldo-devedor-epr)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos (Supero)
       Data    : Junho/2013.                         Ultima atualizacao: 03/09/2014
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : Procedure para calcular saldo devedor de emprestimos
    
       Alteracoes:  03/06/2013 - Convers�o Progress >> Oracle PLSQL (Marcos-Supero)
    
                    03/09/2014 - Ajustes no cursor cr_crapepr, pois quando nrctremp
                                 fosse igual a zero, ele n�o tratava o retorno de
                                 todos os empr�stimos (Marcos-Supero)
    
    ............................................................................. */
    DECLARE
      -- Saida com erro alternativa
      vr_exc_erro2 exception;
    
      -- Dia e data de pagamento de empr�stimo
      vr_tab_diapagto NUMBER;
      vr_tab_dtcalcul DATE;
      -- Flag para desconto em folha
      vr_tab_flgfolha BOOLEAN;
      -- Configura��o para m�s novo
      vr_tab_ddmesnov INTEGER;
      -- Rowid para inser��o de log
      vr_nrdrowid ROWID;
    
      -- Vari�veis para passagem a rotina pc_calcula_lelem
      vr_diapagto     INTEGER;
      vr_qtprecal_lem crapepr.qtprecal%TYPE;
      --vr_vlprepag     craplem.vllanmto%TYPE;
      --vr_vljuracu     crapepr.vljuracu%TYPE;
      --vr_vljurmes     crapepr.vljurmes%TYPE;
      --vr_vlsdeved     crapepr.vlsdeved%TYPE;
      vr_vlprepag NUMBER := 0;
      vr_vljuracu NUMBER := 0;
      vr_vljurmes NUMBER := 0;
      vr_vlsdeved NUMBER := 0;
      vr_dtultpag crapepr.dtultpag%TYPE;
      vr_txdjuros NUMBER(12, 7); --> Taxa de juros para o c�lculo
      vr_qtprecal crapepr.qtprecal%TYPE; --> Qatdade de parclas calculadas at� o momento
      vr_vlpreapg NUMBER; --> Valor das parcelas a pagar
      vr_vlmrapar crappep.vlmrapar%TYPE; --> Valor do Juros de Mora
      vr_vlmtapar crappep.vlmtapar%TYPE; --> Valor da Multa
      vr_vlprvenc NUMBER; --> Valor Vencido
      vr_vlpraven NUMBER; --> Valor a Vencer
    
      -- Busca dos dados do emprestimo passado ou de todos os emprestimos da conta quando nrctremp = 0
      CURSOR cr_crapepr IS
        SELECT nrctremp
              ,inliquid
              ,cdlcremp
              ,txjuremp
              ,vlsdeved
              ,vljuracu
              ,qtprecal
              ,qtpreemp
              ,cdagenci
              ,vlpreemp
          FROM crapepr
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = DECODE(pr_nrctremp, 0, nrctremp, pr_nrctremp);
    
      -- Buscar dados da linha de cr�dito
      CURSOR cr_craplcr(pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT txdiaria
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
               AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
    
    BEGIN
      -- Buscar a configura��o de empr�stimo cfme a empresa da conta
      pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                                ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data atual
                                ,pr_nrdconta => pr_nrdconta --> Numero da conta do empr�stimo
                                ,pr_dtcalcul => vr_tab_dtcalcul --> Data calculada de pagamento
                                ,pr_diapagto => vr_tab_diapagto --> Dia de pagamento das parcelas
                                ,pr_flgfolha => vr_tab_flgfolha --> Flag de desconto em folha S/N
                                ,pr_ddmesnov => vr_tab_ddmesnov --> Configura��o para m�s novo
                                ,pr_cdcritic => vr_cdcritic --> C�digo do erro
                                ,pr_des_erro => vr_dscritic); --> Retorno de Erro
      -- Se houve erro na rotina
      IF vr_dscritic IS NOT NULL
         OR vr_cdcritic IS NOT NULL THEN
        -- Levantar exce��o
        RAISE vr_exc_erro;
      END IF;
    
      -- Busca dos dados do emprestimo passado como parametro
      FOR rw_crapepr IN cr_crapepr LOOP
        -- Se foi passado que haver� utiliza��o da tabela de juros e o o empr�stimo estiver ativo
        IF pr_inusatab
           AND rw_crapepr.inliquid = 0 THEN
          -- Buscar a taxa cfme a linha de cr�dito
          OPEN cr_craplcr(pr_cdlcremp => rw_crapepr.cdlcremp);
          FETCH cr_craplcr
            INTO rw_craplcr;
          -- Se n�o tiver encontrado
          IF cr_craplcr%NOTFOUND THEN
            -- Fechar o cursor e gerar erro
            CLOSE cr_craplcr;
            vr_cdcritic := 363;
            RAISE vr_exc_erro;
          ELSE
            -- Fechar o cursor
            CLOSE cr_craplcr;
            -- Utilizar a taxa da linha de cr�dito
            vr_txdjuros := rw_craplcr.txdiaria;
          END IF;
        ELSE
          -- Utilizaremos a taxa do empr�stimo
          vr_txdjuros := rw_crapepr.txjuremp;
        END IF;
        -- Inicializar variaveis para o calculo do saldo devedor
        vr_vlsdeved := rw_crapepr.vlsdeved;
        vr_vljuracu := rw_crapepr.vljuracu;
        vr_vlmrapar := 0;
        vr_vlmtapar := 0;
        -- Para empr�stimo ainda n�o liquidados
        IF rw_crapepr.inliquid = 0 THEN
          -- Manter o valor da tabela
          vr_qtprecal := rw_crapepr.qtprecal;
        ELSE
          -- Usar o valor total de parcelas
          vr_qtprecal := rw_crapepr.qtpreemp;
        END IF;
        -- Calculo de saldo devedor em emprestimos baseado na includes/lelem.i.
        pc_calc_saldo_deved_epr_lem(pr_cdcooper   => pr_cdcooper --> Cooperativa conectada
                                   ,pr_cdprogra   => pr_cdprogra --> C�digo do programa corrente
                                   ,pr_cdagenci   => rw_crapepr.cdagenci --> C�digo da ag�ncia
                                   ,pr_nrdcaixa   => pr_nrdcaixa --> N�mero do caixa
                                   ,pr_cdoperad   => pr_cdoperad --> C�digo do Operador
                                   ,pr_rw_crapdat => pr_rw_crapdat --> Vetor com dados de par�metro (CRAPDAT)
                                   ,pr_nrdconta   => pr_nrdconta --> N�mero da conta
                                   ,pr_idseqttl   => pr_idseqttl --> Seq titular
                                   ,pr_nrctremp   => rw_crapepr.nrctremp --> Numero ctrato empr�stimo
                                   ,pr_idorigem   => pr_idorigem --> Id do m�dulo de sistema
                                   ,pr_txdjuros   => vr_txdjuros --> Taxa de juros aplicada
                                   ,pr_dtcalcul   => NULL --> Data para calculo do empr�stimo
                                   ,pr_diapagto   => vr_tab_diapagto --> Dia para pagamento
                                   ,pr_qtprecal   => vr_qtprecal_lem --> Quantidade de presta��es calculadas at� momento
                                   ,pr_vlprepag   => vr_vlprepag --> Valor acumulado pago no m�s
                                   ,pr_vlpreapg   => vr_vlpreapg --> Valor a pagar
                                   ,pr_vljurmes   => vr_vljurmes --> Juros no m�s corrente
                                   ,pr_vljuracu   => vr_vljuracu --> Juros acumulados total
                                   ,pr_vlsdeved   => vr_vlsdeved --> Saldo devedor acumulado
                                   ,pr_dtultpag   => vr_dtultpag --> Ultimo dia de pagamento das presta��es
                                   ,pr_vlmrapar   => vr_vlmrapar --> Valor do Juros de Mora
                                   ,pr_vlmtapar   => vr_vlmtapar --> Valor da Multa
                                   ,pr_vlprvenc   => vr_vlprvenc --> Valor Vencido da parcela
                                   ,pr_vlpraven   => vr_vlpraven --> Valor a Vencer
                                   ,pr_flgerlog   => pr_flgerlog --> Gerar log S/N
                                   ,pr_des_reto   => pr_des_reto --> Retorno OK / NOK
                                   ,pr_tab_erro   => vr_tab_erro); --> Tabela com poss�veis erros
        -- Se a rotina retornou erro
        IF pr_des_reto = 'NOK' THEN
          -- Gerar exce��o 2 onde n�o � montada a tabela de erro
          RAISE vr_exc_erro2;
        END IF;
        -- Se o saldo devedor for superior a zero
        IF vr_vlsdeved > 0 THEN
          -- Acumular ao total o valor da parcela
          pr_vltotpre := pr_vltotpre + rw_crapepr.vlpreemp;
        END IF;
        -- Acumular a quantidade de parcelas calculadas
        pr_qtprecal := pr_qtprecal + vr_qtprecal_lem;
        -- Acumular o saldo devedor calculado
        pr_vlsdeved := pr_vlsdeved + nvl(vr_vlsdeved,0);
      END LOOP; -- Fim leitura dos empr�stimos
    
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                            ,pr_dstransa => 'Obter saldo devedor do associado em emprestimos'
                            ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => NVL(vr_cdcritic, 0)
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado log
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Obter saldo devedor do associado em emprestimos'
                              ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                               ,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        
        END IF;
      WHEN vr_exc_erro2 THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Copiar variavel tempor�ria para a de sa�da de erro
        pr_tab_erro := vr_tab_erro;
        -- Se foi solicitado log
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_tab_erro(vr_tab_erro.FIRST)
                                              .dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Obter saldo devedor do associado em emprestimos'
                              ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                               ,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        
        END IF;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_obtem_dados_empresti --> ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado log
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Obter saldo devedor do associado em emprestimos'
                              ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                               ,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        
        END IF;
    END;
  END pc_saldo_devedor_epr;

  /* Calcular a quantidade de dias que o emprestimo est� em atraso */
  FUNCTION fn_busca_dias_atraso_epr(pr_cdcooper IN crappep.cdcooper%TYPE --> C�digo da Cooperativa
                                   ,pr_nrdconta IN crappep.nrdconta%TYPE --> Numero da Conta do empr�stimo
                                   ,pr_nrctremp IN crappep.nrctremp%TYPE --> Numero do Contrato de empr�stimo
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento Atual
                                   ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) --> Data do Movimento Anterior
   RETURN INTEGER IS
  BEGIN
    /* .............................................................................
    
       Programa: fn_busca_dias_atraso_epr   Antigo: busca_dias_atraso_epr da BO sistema/generico/procedures/b1wgen0136.p
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Guilherme
       Data    : Outubro/2007                        Ultima atualizacao: 13/12/2012
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina de calculo de dias que o emprestimo est� em atraso.
    
       Alteracoes: 11/02/2013 - Convers�o Progress para Oracle (Alisson - AMcom)
    
    ............................................................................. */
    DECLARE
    
      --Selecionar informacoes parcelas emprestimo
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE
                       ,pr_inliquid IN crappep.inliquid%TYPE
                       ,pr_dtvencto IN crappep.dtvencto%TYPE) IS
        SELECT crappep.dtvencto
          FROM crappep crappep
         WHERE crappep.cdcooper = pr_cdcooper
               AND crappep.nrctremp = pr_nrctremp
               AND crappep.nrdconta = pr_nrdconta
               AND crappep.inliquid = pr_inliquid
               AND crappep.dtvencto <= pr_dtvencto
         ORDER BY crappep.dtvencto ASC;
      rw_crappep cr_crappep%ROWTYPE;
    
      --Variaveis locais
      vr_qtdedias INTEGER := 0;
    
    BEGIN
      --Selecionar informacoes das parcelas
      OPEN cr_crappep(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_inliquid => 0
                     ,pr_dtvencto => pr_dtmvtoan);
      --Posicionar no proximo registro
      FETCH cr_crappep
        INTO rw_crappep;
      --Se nao encontrou
      IF cr_crappep%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crappep;
        --Retornar zero
        RETURN(0);
      END IF;
      --Fechar Cursor
      CLOSE cr_crappep;
    
      --quantidade de dias recebe a quantidade de dias entre a data do movimento e a data de vencimento do contrato
      vr_qtdedias := pr_dtmvtolt - rw_crappep.dtvencto;
      --Retornar valor
      RETURN(vr_qtdedias);
    EXCEPTION
      WHEN OTHERS THEN
        --Retornar zero
        RETURN(0);
    END;
  END;

  /* Rotina de calculo de dias do ultimo pagamento de emprestimos em atraso*/
  PROCEDURE pc_calc_dias_atraso(pr_cdcooper   IN crapepr.cdcooper%TYPE --> C�digo da cooperativa
                               ,pr_cdprogra   IN VARCHAR2 --> Nome do programa que est� executando
                               ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta do emprestimo
                               ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                               ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                               ,pr_inusatab   IN BOOLEAN --> Indicador de utiliza��o da tabela de juros
                               ,pr_vlsdeved   OUT NUMBER --> Valor do saldo devedor
                               ,pr_qtprecal   OUT NUMBER --> Quantidade de Parcelas
                               ,pr_qtdiaatr   OUT NUMBER --> Quantidade de dias em atraso
                               ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> C�digo de critica encontrada
                               ,pr_des_erro   OUT VARCHAR2) IS --> Retorno de erro
  BEGIN
    /* .............................................................................
    
       Programa: pc_calc_dias_atraso                 Antigo: includes/crps398.i
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Guilherme
       Data    : Outubro/2007                        Ultima atualizacao: 30/01/2014
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina de calculo de dias do ultimo pagamento de
                   emprestimos em atraso
    
       Alteracoes: 13/12/2012 - Diferenciar tipos de emprestimos (Gabriel).
    
                   11/02/2013 - Convers�o Progress para Oracle (Alisson - AMcom)
    
                   04/04/2013 - Retirada a restricao glb_cdprogra <> "crps005"
                                quando chama o saldo_epr.p (Lucas R.).
    
                   30/01/2014 - Remover a chamada da procedure "saldo_epr.p". (James)
    
    ............................................................................. */
    DECLARE
    
      --Selecionar informacoes dos emprestimos
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crapepr.tpemprst
              ,crapepr.qtmesdec
              ,crapepr.dtdpagto
              ,crapepr.flgpagto
              ,crapepr.vlsdeved
              ,crapepr.qtprecal
              ,crapepr.nrdconta
              ,crapepr.nrctremp
              ,crapepr.vlsdevat
              ,crapepr.qtlcalat
              ,crapepr.qtpcalat
          FROM crapepr crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
               AND crapepr.nrdconta = pr_nrdconta
               AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
    
      --Variaveis Locais
      vr_qtdias   INTEGER := 0;
      vr_tpemprst crapepr.tpemprst%TYPE;
      vr_qtmesdec crapepr.qtmesdec%TYPE;
      vr_dtdpagto crapepr.dtdpagto%TYPE;
      vr_vlsdeved crapepr.vlsdeved%TYPE;
      vr_qtprecal crapepr.qtprecal%TYPE;
    
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    
      --Variavel para tratar mensagem erro
      vr_des_erro VARCHAR2(4000);
    
    BEGIN
      --Inicializar variavel de erro
      pr_des_erro := NULL;
      --Zerar variaveis de retorno
      pr_qtprecal := 0;
      pr_vlsdeved := 0;
      pr_qtdiaatr := 0;
    
      --Selecionar informacoes do emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      --Posicionar no primeiro registro
      FETCH cr_crapepr
        INTO rw_crapepr;
      --Se nao encontrou registro
      IF cr_crapepr%NOTFOUND THEN
        CLOSE cr_crapepr;
        --Montar mensagem de erro
        pr_cdcritic := 356;
        vr_des_erro := 'Contrato de Emprestimo n�o encontrado.';
        --Levantar Exce��o
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapepr;
    
      --Se o tipo de emprestimo for anual
      IF rw_crapepr.tpemprst = 0 THEN
        --Quantidade de meses recebe o valor passado como parametro
        vr_qtmesdec := rw_crapepr.qtmesdec;
        --Se a data de pagamento nao for nula
        IF rw_crapepr.dtdpagto IS NOT NULL THEN
          /* Verif. final mes(dia nao util) */
          --Se o dia do pagamento > dia movimento para o mesmo m�s e ano
          IF to_number(to_char(rw_crapepr.dtdpagto, 'DD')) >
             to_number(to_char(pr_rw_crapdat.dtmvtolt, 'DD'))
             AND to_char(rw_crapepr.dtdpagto, 'YYYYMM') =
             to_char(pr_rw_crapdat.dtmvtolt, 'YYYYMM') THEN
            --Reduzir a Quantidade meses em 1
            vr_qtmesdec := Nvl(vr_qtmesdec, 0) - 1;
          END IF;
        END IF;
        --Quantidade dias recebe quantidade meses menos quantidade parcelas * 30
        vr_qtdias := (vr_qtmesdec - rw_crapepr.qtprecal) * 30;
      
        --Se estiver em dia
        IF vr_qtdias < 0 THEN
          --Levantar Exce��o
          RAISE vr_exc_saida;
        END IF;
      
        --Se quantidade dias for negativa e a data de pagamento nao for nula e nao tiver pago e data pagamento maior data movimento
        IF vr_qtdias <= 0
           AND rw_crapepr.dtdpagto IS NOT NULL
           AND rw_crapepr.flgpagto = 0
           AND /* Conta Corrente */
           rw_crapepr.dtdpagto >= pr_rw_crapdat.dtmvtolt THEN
          --Levantar excecao
          RAISE vr_exc_saida;
        END IF;
      ELSE
        --Buscar a quantidade de dias em atraso
        vr_qtdias := EMPR0001.fn_busca_dias_atraso_epr(pr_cdcooper => pr_cdcooper
                                                      ,pr_nrdconta => rw_crapepr.nrdconta
                                                      ,pr_nrctremp => rw_crapepr.nrctremp
                                                      ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                                      ,pr_dtmvtoan => pr_rw_crapdat.dtmvtoan);
        --Se a quantidade de dias for inferior ou igual a zero
        IF vr_qtdias <= 0 THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
      END IF;
    
      --Zerar Variaveis para chamada calculo
      vr_vlsdeved := 0;
      vr_qtprecal := 0;
    
      --Se o mes da data de movimento for diferente do mes da proxima data de movimento
      IF to_char(pr_rw_crapdat.dtmvtolt, 'MM') <>
         to_char(pr_rw_crapdat.dtmvtopr, 'MM') THEN
        --Valor do saldo devedor recebe o valor selecionado
        vr_vlsdeved := rw_crapepr.vlsdeved; /*Saldo calculado pelo 78*/
      ELSE
        /* Saldo calculado pelo crps616.p e crps665.p */
        vr_vlsdeved := rw_crapepr.vlsdevat;
      
        --Se o tipo de emprestimo for anual
        IF rw_crapepr.tpemprst = 0 THEN
          --Quantidade de parcelas calculada recebe qdade. lancamentos atualizados
          vr_qtprecal := nvl(rw_crapepr.qtlcalat, 0);
        ELSE
          --Quantidade de parcelas calculada recebe qdade. prestacoes calculadas
          vr_qtprecal := nvl(rw_crapepr.qtpcalat, 0);
        END IF;
      END IF;
    
      --Se for o programa crps398 e o saldo devedor for negativo
      IF upper(pr_cdprogra) = 'CRPS398'
         AND vr_vlsdeved <= 0 THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
    
      --Se o tipo de emprestimo for anual
      IF rw_crapepr.tpemprst = 0 THEN
        --Incrementar no parametro de retorno a quantidade de parcelas calculada
        vr_qtprecal := rw_crapepr.qtprecal + Nvl(vr_qtprecal, 0);
        --Quantidade de dias recebe a quantidade de meses menos parcelas calculadas * 30
        vr_qtdias := (vr_qtmesdec - Nvl(vr_qtprecal, 0)) * 30;
      
        --Se a quantidade de dias for menor zero
        IF vr_qtdias < 0 THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
        --Se quantidade dias for negativa e a data de pagamento nao for nula e nao tiver pago e data pagamento maior data movimento
        IF vr_qtdias <= 0
           AND rw_crapepr.dtdpagto IS NOT NULL
           AND rw_crapepr.flgpagto = 0
           AND /* Conta Corrente */
           rw_crapepr.dtdpagto >= pr_rw_crapdat.dtmvtolt THEN
          --Levantar excecao
          RAISE vr_exc_saida;
        END IF;
        --Se quantidade dias for negativa e nao tiver pago
        IF vr_qtdias <= 0
           AND rw_crapepr.flgpagto = 0 THEN
          /* Conta Corrente */
          --Quantidade de dias recebe dias entre a data movimento e data de pagamento do emprestimo
          vr_qtdias := pr_rw_crapdat.dtmvtolt - rw_crapepr.dtdpagto;
        END IF;
      END IF;
    
      --Retornar dias em atraso
      pr_qtdiaatr := vr_qtdias;
      --Retornar Saldo Devedor
      pr_vlsdeved := vr_vlsdeved;
      --Retornar quantidade parcelas
      pr_qtprecal := vr_qtprecal;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := nvl(pr_cdcritic, 0);
        pr_des_erro := vr_des_erro;
      WHEN vr_exc_saida THEN
        --Retornar dias em atraso
        pr_qtdiaatr := vr_qtdias;
        --Retornar Saldo Devedor
        pr_vlsdeved := vr_vlsdeved;
        --Retornar quantidade parcelas
        pr_qtprecal := vr_qtprecal;
      WHEN OTHERS THEN
        pr_cdcritic := nvl(pr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina EMPR0001.pc_calc_dias_atraso. ' ||
                       sqlerrm;
    END;
  END;

  --Procedure para Incluir ou atualizar o lote
  PROCEDURE pc_inclui_altera_lote(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --Codigo Agencia
                                 ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE --Codigo Caixa
                                 ,pr_nrdolote IN craplot.nrdolote%TYPE --Numero Lote
                                 ,pr_tplotmov IN craplot.tplotmov%TYPE --Tipo movimento
                                 ,pr_cdoperad IN craplot.cdoperad%TYPE --Operador
                                 ,pr_cdhistor IN craplot.cdhistor%TYPE --Codigo Historico
                                 ,pr_dtmvtopg IN crapdat.dtmvtolt%TYPE --Data Pagamento Emprestimo
                                 ,pr_vllanmto IN craplcm.vllanmto%TYPE --Valor Lancamento
                                 ,pr_flgincre IN BOOLEAN --Indicador Credito
                                 ,pr_flgcredi IN BOOLEAN --Credito
                                 ,pr_nrseqdig OUT INTEGER --Numero Sequencia
                                 ,pr_cdcritic OUT INTEGER --Codigo Erro
                                 ,pr_dscritic OUT VARCHAR2) IS --Descricao Erro
  BEGIN
    /* .............................................................................
    
       Programa: pc_inclui_altera_lote                 Antigo: includes/b1craplot.p/inclui-altera-lote
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 25/02/2014
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Incluir ou atualizar o lote
    
       Alteracoes: 25/02/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
    ............................................................................. */
  
    DECLARE
      --Variaveis Locais
      vr_nrseqdig INTEGER;
      vr_nrincrem INTEGER;
      vr_rowid    ROWID;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    
    BEGIN
    
      --Inicializar variavel erro
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      --Numero Incremento
      IF pr_flgincre THEN
        vr_nrincrem := 1;
      ELSE
        vr_nrincrem := -1;
      END IF;
    
      /* Leitura do lote */
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => pr_dtmvtolt
                     ,pr_cdagenci => pr_cdagenci
                     ,pr_cdbccxlt => pr_cdbccxlt
                     ,pr_nrdolote => pr_nrdolote);
      --Posicionar no proximo registro
      FETCH cr_craplot
        INTO rw_craplot;
      --Se encontrou registro
      IF cr_craplot%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_craplot;
      
        /* Credita ou Debita */
        IF pr_flgcredi THEN
          /*Total de valores computados a credito no lote*/
          rw_craplot.vlcompcr := (pr_vllanmto * vr_nrincrem);
          /*Total de valores a credito do lote.*/
          rw_craplot.vlinfocr := (pr_vllanmto * vr_nrincrem);
          /*Total de valores computados a debito no lote.*/
          rw_craplot.vlcompdb := 0;
          /*Total de valores a debito do lote.*/
          rw_craplot.vlinfodb := 0;
        ELSE
          /*Total de valores computados a credito no lote*/
          rw_craplot.vlcompcr := 0;
          /*Total de valores a credito do lote.*/
          rw_craplot.vlinfocr := 0;
        
          /*Total de valores computados a debito no lote.*/
          rw_craplot.vlcompdb := (pr_vllanmto * vr_nrincrem);
          /*Total de valores a debito do lote.*/
          rw_craplot.vlinfodb := (pr_vllanmto * vr_nrincrem);
        END IF;
      
        --Criar lote
        BEGIN
          INSERT INTO craplot
            (craplot.cdcooper
            ,craplot.dtmvtolt
            ,craplot.cdagenci
            ,craplot.cdbccxlt
            ,craplot.nrdolote
            ,craplot.tplotmov
            ,craplot.cdoperad
            ,craplot.cdhistor
            ,craplot.dtmvtopg
            ,craplot.nrseqdig
            ,craplot.qtcompln
            ,craplot.qtinfoln
            ,craplot.vlcompcr
            ,craplot.vlinfocr
            ,craplot.vlcompdb
            ,craplot.vlinfodb)
          VALUES
            (pr_cdcooper
            ,pr_dtmvtolt
            ,pr_cdagenci
            ,pr_cdbccxlt
            ,pr_nrdolote
            ,pr_tplotmov
            ,pr_cdoperad
            ,pr_cdhistor
            ,pr_dtmvtopg
            ,1
            ,vr_nrincrem
            ,vr_nrincrem
            ,rw_craplot.vlcompcr
            ,rw_craplot.vlinfocr
            ,rw_craplot.vlcompdb
            ,rw_craplot.vlinfodb)
          RETURNING craplot.nrseqdig, ROWID INTO pr_nrseqdig, rw_craplot.rowid;
        EXCEPTION
          WHEN Dup_Val_On_Index THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Lote ja cadastrado.';
            RAISE vr_exc_erro;
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir na tabela de lotes. ' ||
                           sqlerrm;
            RAISE vr_exc_erro;
        END;
      ELSE
        --Fechar Cursor
        CLOSE cr_craplot;
        --Incrementar Sequencial
        rw_craplot.nrseqdig := nvl(rw_craplot.nrseqdig, 0) + 1;
        /*Quantidade computada de lancamentos.*/
        rw_craplot.qtcompln := nvl(rw_craplot.qtcompln, 0) + vr_nrincrem;
        /*Quantidade de lancamentos do lote.*/
        rw_craplot.qtinfoln := nvl(rw_craplot.qtinfoln, 0) + vr_nrincrem;
      
        /* Credita ou Debita */
        IF pr_flgcredi THEN
          /*Total de valores computados a credito no lote*/
          rw_craplot.vlcompcr := nvl(rw_craplot.vlcompcr, 0) +
                                 (pr_vllanmto * vr_nrincrem);
          /*Total de valores a credito do lote.*/
          rw_craplot.vlinfocr := nvl(rw_craplot.vlinfocr, 0) +
                                 (pr_vllanmto * vr_nrincrem);
        ELSE
          /*Total de valores computados a debito no lote.*/
          rw_craplot.vlcompdb := nvl(rw_craplot.vlcompdb, 0) +
                                 (pr_vllanmto * vr_nrincrem);
          /*Total de valores a debito do lote.*/
          rw_craplot.vlinfodb := nvl(rw_craplot.vlinfodb, 0) +
                                 (pr_vllanmto * vr_nrincrem);
        END IF;
        --Atualizar Lote
        BEGIN
          UPDATE craplot
             SET craplot.nrseqdig = rw_craplot.nrseqdig
                ,craplot.qtcompln = rw_craplot.qtcompln
                ,craplot.qtinfoln = rw_craplot.qtinfoln
                ,craplot.vlcompcr = rw_craplot.vlcompcr
                ,craplot.vlinfocr = rw_craplot.vlinfocr
                ,craplot.vlcompdb = rw_craplot.vlcompdb
                ,craplot.vlinfodb = rw_craplot.vlinfodb
           WHERE craplot.rowid = rw_craplot.rowid
          RETURNING rw_craplot.nrseqdig INTO pr_nrseqdig;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar lote. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;
      --Fechar Cursor
      IF cr_craplot%ISOPEN THEN
        CLOSE cr_craplot;
      END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina EMPR0001.pc_inclui_altera_lote. ' ||
                       sqlerrm;
    END;
  END pc_inclui_altera_lote;

  /* Criar o lancamento na Conta Corrente  */
  PROCEDURE pc_cria_lancamento_cc(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                 ,pr_cdbccxlt IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                 ,pr_cdoperad IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                 ,pr_cdpactra IN INTEGER --> P.A. da transa��o
                                 ,pr_nrdolote IN craplot.nrdolote%TYPE --> Numero do Lote
                                 ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                 ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo historico
                                 ,pr_vllanmto IN NUMBER --> Valor da parcela emprestimo
                                 ,pr_nrparepr IN INTEGER --> N�mero parcelas empr�stimo
                                 ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                 ,pr_nrseqava IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                 ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_cria_lancamento_cc                 Antigo: b1wgen0084a.p/cria_lancamento_cc
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 13/08/2014
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para o lan�amento do pagto da parcela na Conta Corrente
    
       Alteracoes: 28/02/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
                   16/06/2014 - Ajuste para atualizar o campo nrseqava. (James)
    
                   13/08/2014 - Ajuste para gravar o operador e a hora da transacao. (James)
    ............................................................................. */
  
    DECLARE
      --Variaveis Locais
      vr_nrseqdig INTEGER;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_des_erro VARCHAR2(3);
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
    
      --Valor Lancamento maior zero
      IF ROUND(pr_vllanmto, 2) > 0 THEN
        /* Atualizar o lote da C/C */
        pc_inclui_altera_lote(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                             ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                             ,pr_cdagenci => pr_cdpactra --Codigo Agencia
                             ,pr_cdbccxlt => pr_cdbccxlt --Codigo Caixa
                             ,pr_nrdolote => pr_nrdolote --Numero Lote
                             ,pr_tplotmov => 1 --Tipo movimento
                             ,pr_cdoperad => pr_cdoperad --Operador
                             ,pr_cdhistor => pr_cdhistor --Codigo Historico
                             ,pr_dtmvtopg => pr_dtmvtolt --Data Pagamento Emprestimo
                             ,pr_vllanmto => pr_vllanmto --Valor Lancamento
                             ,pr_flgincre => TRUE --Indicador Credito
                             ,pr_flgcredi => TRUE --Credito
                             ,pr_nrseqdig => vr_nrseqdig --Numero Sequencia
                             ,pr_cdcritic => vr_cdcritic --Codigo Erro
                             ,pr_dscritic => vr_dscritic); --Descricao Erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL
           OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
        --Inserir Lancamento
        BEGIN
          INSERT INTO craplcm
            (craplcm.dtmvtolt
            ,craplcm.cdagenci
            ,craplcm.cdbccxlt
            ,craplcm.nrdolote
            ,craplcm.nrdconta
            ,craplcm.nrdctabb
            ,craplcm.nrdctitg
            ,craplcm.nrdocmto
            ,craplcm.cdhistor
            ,craplcm.nrseqdig
            ,craplcm.vllanmto
            ,craplcm.cdcooper
            ,craplcm.nrparepr
            ,craplcm.cdpesqbb
            ,craplcm.nrseqava
            ,craplcm.cdoperad
            ,craplcm.hrtransa)
          VALUES
            (pr_dtmvtolt
            ,pr_cdpactra
            ,pr_cdbccxlt
            ,pr_nrdolote
            ,pr_nrdconta
            ,pr_nrdconta
            ,gene0002.fn_mask(pr_nrdconta, '99999999')
            ,vr_nrseqdig
            ,pr_cdhistor
            ,vr_nrseqdig
            ,pr_vllanmto
            ,pr_cdcooper
            ,pr_nrparepr
            ,gene0002.fn_mask(pr_nrctremp, 'zz.zzz.zz9')
            ,pr_nrseqava
            ,pr_cdoperad
            ,gene0002.fn_busca_time);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir na craplcm. ' || SQLERRM;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_cdbccxlt
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_cria_lancamento_cc ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_cdbccxlt
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_cria_lancamento_cc;

  --Procedure para Criar lancamento e atualiza o lote
  PROCEDURE pc_cria_lancamento_lem(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE --Codigo Agencia
                                  ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE --Codigo Caixa
                                  ,pr_cdoperad IN craplot.cdoperad%TYPE --Operador
                                  ,pr_cdpactra IN INTEGER --Posto Atendimento
                                  ,pr_tplotmov IN craplot.tplotmov%TYPE --Tipo movimento
                                  ,pr_nrdolote IN craplot.nrdolote%TYPE --Numero Lote
                                  ,pr_nrdconta IN crapepr.nrdconta%TYPE --Numero da Conta
                                  ,pr_cdhistor IN craplot.cdhistor%TYPE --Codigo Historico
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --Numero Contrato
                                  ,pr_vllanmto IN craplcm.vllanmto%TYPE --Valor Lancamento
                                  ,pr_dtpagemp IN crapdat.dtmvtolt%TYPE --Data Pagamento Emprestimo
                                  ,pr_txjurepr IN NUMBER --Taxa Juros Emprestimo
                                  ,pr_vlpreemp IN crapepr.vlpreemp%TYPE --Valor Emprestimo
                                  ,pr_nrsequni IN INTEGER --Numero Sequencia
                                  ,pr_nrparepr IN INTEGER --Numero Parcelas Emprestimo
                                  ,pr_flgincre IN BOOLEAN --Indicador Credito
                                  ,pr_flgcredi IN BOOLEAN --Credito
                                  ,pr_nrseqava IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                  ,pr_cdorigem IN NUMBER DEFAULT 0 --> Origem do Movimento
                                  ,pr_cdcritic OUT INTEGER --Codigo Erro
                                  ,pr_dscritic OUT VARCHAR2) IS --Descricao Erro
  BEGIN
    /* .............................................................................
    
       Programa: pc_cria_lancamento_lem                 Antigo: b1wgen0134.p/cria_lancamento_lem
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 16/06/2014
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Criar lancamento e atualiza o lote
    
       Alteracoes: 25/02/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
                   16/06/2014 - Ajuste para atualizar o campo nrseqava. (James)
    ............................................................................. */
  
    DECLARE
      --Variaveis Locais
      vr_nrseqdig INTEGER;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    
    BEGIN
      --Inicializar variavel erro
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      --Atualizar Lote
      pc_inclui_altera_lote(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                           ,pr_cdagenci => pr_cdpactra --Codigo Agencia
                           ,pr_cdbccxlt => pr_cdbccxlt --Codigo Caixa
                           ,pr_nrdolote => pr_nrdolote --Numero Lote
                           ,pr_tplotmov => pr_tplotmov --Tipo movimento
                           ,pr_cdoperad => pr_cdoperad --Operador
                           ,pr_cdhistor => pr_cdhistor --Codigo Historico
                           ,pr_dtmvtopg => pr_dtmvtolt --Data Pagamento Emprestimo
                           ,pr_vllanmto => pr_vllanmto --Valor Lancamento
                           ,pr_flgincre => pr_flgincre --Indicador Credito
                           ,pr_flgcredi => pr_flgcredi --Credito
                           ,pr_nrseqdig => vr_nrseqdig --Numero Sequencia
                           ,pr_cdcritic => vr_cdcritic --Codigo Erro
                           ,pr_dscritic => vr_dscritic); --Descricao Erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL
         OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      --Inserir Lancamento
      BEGIN
        INSERT INTO craplem
          (craplem.dtmvtolt
          ,craplem.cdagenci
          ,craplem.cdbccxlt
          ,craplem.nrdolote
          ,craplem.nrdconta
          ,craplem.nrdocmto
          ,craplem.cdhistor
          ,craplem.nrseqdig
          ,craplem.nrctremp
          ,craplem.vllanmto
          ,craplem.dtpagemp
          ,craplem.txjurepr
          ,craplem.vlpreemp
          ,craplem.nrsequni
          ,craplem.cdcooper
          ,craplem.nrparepr
          ,craplem.nrseqava
          ,craplem.cdorigem)
        VALUES
          (pr_dtmvtolt
          ,pr_cdpactra
          ,pr_cdbccxlt
          ,pr_nrdolote
          ,pr_nrdconta
          ,vr_nrseqdig
          ,pr_cdhistor
          ,vr_nrseqdig
          ,pr_nrctremp
          ,pr_vllanmto
          ,pr_dtpagemp
          ,pr_txjurepr
          ,pr_vlpreemp
          ,pr_nrsequni
          ,pr_cdcooper
          ,pr_nrparepr
          ,pr_nrseqava
          ,pr_cdorigem);
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir na craplem. ' || SQLERRM;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina EMPR0001.pc_cria_lancamento_lem. ' ||
                       sqlerrm;
    END;
  END pc_cria_lancamento_lem;

  --Procedure para Lancar Juros no Contrato
  PROCEDURE pc_lanca_juro_contrato(pr_cdcooper    IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                  ,pr_cdagenci    IN crapass.cdagenci%TYPE --Codigo Agencia
                                  ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE --Codigo Caixa
                                  ,pr_nrdconta    IN crapepr.nrdconta%TYPE --Numero da Conta
                                  ,pr_nrctremp    IN crapepr.nrctremp%TYPE --Numero Contrato
                                  ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                                  ,pr_cdoperad    IN craplot.cdoperad%TYPE --Operador
                                  ,pr_cdpactra    IN INTEGER --Posto Atendimento
                                  ,pr_flnormal    IN BOOLEAN --Lancamento Normal
                                  ,pr_dtvencto    IN crapdat.dtmvtolt%TYPE --Data vencimento
                                  ,pr_ehmensal    IN BOOLEAN --Indicador Mensal
                                  ,pr_dtdpagto    IN crapdat.dtmvtolt%TYPE --Data pagamento
                                  ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                  ,pr_cdorigem IN NUMBER DEFAULT 0 --> Origem do Movimento
                                  ,pr_vljurmes    OUT NUMBER --Valor Juros no Mes
                                  ,pr_diarefju    OUT INTEGER --Dia Referencia Juros
                                  ,pr_mesrefju    OUT INTEGER --Mes Referencia Juros
                                  ,pr_anorefju    OUT INTEGER --Ano Referencia Juros
                                  ,pr_des_reto    OUT VARCHAR2 --Retorno OK/NOK
                                  ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --tabela Erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_lanca_juro_contrato                 Antigo: b1wgen0084a.p/lanca_juro_contrato
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 01/04/2015
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para lancamento de Juros dos Emprestimos
    
       Alteracoes: 25/02/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
                   16/06/2014 - Adicionado o parametro nrseqava na prodecure
                                "pc_cria_lancamento_lem". (James)
                                
                   01/04/2015 - Retornar NOK quando existir Critica. (Alisson - AMcom)
                                
    ............................................................................. */
  
    DECLARE
      --Variaveis Locais
      vr_diavtolt INTEGER;
      vr_mesvtolt INTEGER;
      vr_anovtolt INTEGER;
      vr_qtdiajur NUMBER;
      vr_potencia NUMBER(30, 10);
      vr_valor    NUMBER;
      vr_floperac BOOLEAN;
      vr_nrdolote INTEGER;
      vr_cdhistor INTEGER;
      vr_dtrefjur DATE;
    
      --Tabela dos Indices
      vr_index_crawepr VARCHAR2(30);
    
      --Tipo de Registro de Emprestimo
      rw_crabepr cr_crapepr%ROWTYPE;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
    
      --Limpar tabela erros
      pr_tab_erro.DELETE;
    
      BEGIN
      
        --Selecionar Emprestimo
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
        FETCH cr_crapepr
          INTO rw_crabepr;
        --Se nao Encontrou
        IF cr_crapepr%NOTFOUND THEN
          --Fechar CURSOR
          CLOSE cr_crapepr;
          vr_cdcritic := 55;
          RAISE vr_exc_saida;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapepr;
      
        --Montar Indice de acesso
        vr_index_crawepr := lpad(pr_cdcooper, 10, '0') ||
                            lpad(pr_nrdconta, 10, '0') ||
                            lpad(pr_nrctremp, 10, '0');
        --Se nao encontrar a conta e contrato na tabela � problema
        IF NOT pr_tab_crawepr.EXISTS(vr_index_crawepr) THEN
          vr_cdcritic := 510;
          RAISE vr_exc_saida;
        ELSE
          rw_crawepr.dtlibera := pr_tab_crawepr(vr_index_crawepr).dtlibera;
        END IF;
      
        --Selecionar Linha Credito
        OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                       ,pr_cdlcremp => rw_crabepr.cdlcremp);
        FETCH cr_craplcr
          INTO rw_craplcr;
        --Se nao encontrou
        IF cr_craplcr%NOTFOUND THEN
          --Fechar CURSOR
          CLOSE cr_craplcr;
          vr_cdcritic := 55;
          RAISE vr_exc_saida;
        END IF;
        --Fechar CURSOR
        CLOSE cr_craplcr;
      
        --verificar se � financiamento
        vr_floperac := rw_craplcr.dsoperac = 'FINANCIAMENTO';
      
        IF vr_floperac THEN
          /* Financiamento */
          --Numero Lote
          vr_nrdolote := 600011;
          --Codigo historico
          vr_cdhistor := 1038;
        ELSE
          /* Emprestimo */
          --Numero Lote
          vr_nrdolote := 600010;
          --Codigo historico
          vr_cdhistor := 1037;
        END IF;
      
        --Dia/Mes/Ano Referencia
        IF rw_crabepr.diarefju <> 0
           AND rw_crabepr.mesrefju <> 0
           AND rw_crabepr.anorefju <> 0 THEN
          --Setar Dia/mes?ano
          vr_diavtolt := rw_crabepr.diarefju;
          vr_mesvtolt := rw_crabepr.mesrefju;
          vr_anovtolt := rw_crabepr.anorefju;
        ELSE
          --Setar dia/mes/ano
          vr_diavtolt := to_number(to_char(rw_crawepr.dtlibera, 'DD'));
          vr_mesvtolt := to_number(to_char(rw_crawepr.dtlibera, 'MM'));
          vr_anovtolt := to_number(to_char(rw_crawepr.dtlibera, 'YYYY'));
        END IF;
      
        --Se for normal
        IF pr_flnormal THEN
          --Data Referencia recebe vencimento
          vr_dtrefjur := pr_dtvencto;
        ELSE
          --Data referencia recebe movimento
          vr_dtrefjur := pr_dtmvtolt;
        END IF;
      
        /* Se ainda nao foi liberado o emprestimo , volta */
        /* Modificar operador para ">" solicitado pelo Irlan */
        IF rw_crawepr.dtlibera > pr_dtmvtolt THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        --Retornar Dia/mes/ano de referencia
        pr_diarefju := to_number(to_char(vr_dtrefjur, 'DD'));
        pr_mesrefju := to_number(to_char(vr_dtrefjur, 'MM'));
        pr_anorefju := to_number(to_char(vr_dtrefjur, 'YYYY'));
      
        --Calcular Quantidade dias
        pc_calc_dias360(pr_ehmensal => pr_ehmensal -- Indica se juros esta rodando na mensal
                       ,pr_dtdpagto => to_char(pr_dtdpagto, 'DD') -- Dia do primeiro vencimento do emprestimo
                       ,pr_diarefju => vr_diavtolt -- Dia da data de refer�ncia da �ltima vez que rodou juros
                       ,pr_mesrefju => vr_mesvtolt -- Mes da data de refer�ncia da �ltima vez que rodou juros
                       ,pr_anorefju => vr_anovtolt -- Ano da data de refer�ncia da �ltima vez que rodou juros
                       ,pr_diafinal => pr_diarefju -- Dia data final
                       ,pr_mesfinal => pr_mesrefju -- Mes data final
                       ,pr_anofinal => pr_anorefju -- Ano data final
                       ,pr_qtdedias => vr_qtdiajur); -- Quantidade de dias calculada
      
        --Calcular Juros
        vr_valor    := 1 + (rw_crabepr.txjuremp / 100);
        vr_potencia := POWER(vr_valor, vr_qtdiajur);
        --Retornar Juros do Mes
        pr_vljurmes := rw_crabepr.vlsdeved * (vr_potencia - 1);
      
        --Se valor for zero ou negativo
        IF pr_vljurmes <= 0 THEN
          --zerar Valor
          pr_vljurmes := 0;
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        /* Cria lancamento e atualiza o lote  */
        pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                              ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                              ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                              ,pr_cdbccxlt => 100 --Codigo Caixa
                              ,pr_cdoperad => pr_cdoperad --Operador
                              ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                              ,pr_tplotmov => 5 --Tipo movimento
                              ,pr_nrdolote => vr_nrdolote --Numero Lote
                              ,pr_nrdconta => pr_nrdconta --Numero da Conta
                              ,pr_cdhistor => vr_cdhistor --Codigo Historico
                              ,pr_nrctremp => pr_nrctremp --Numero Contrato
                              ,pr_vllanmto => pr_vljurmes --Valor Lancamento
                              ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                              ,pr_txjurepr => rw_crabepr.txjuremp --Taxa Juros Emprestimo
                              ,pr_vlpreemp => rw_crabepr.vlpreemp --Valor Emprestimo
                              ,pr_nrsequni => 0 --Numero Sequencia
                              ,pr_nrparepr => 0 --Numero Parcelas Emprestimo
                              ,pr_flgincre => TRUE --Indicador Credito
                              ,pr_flgcredi => TRUE --Credito
                              ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                              ,pr_cdorigem => pr_cdorigem -- Origem do Lan�amento
                              ,pr_cdcritic => vr_cdcritic --Codigo Erro
                              ,pr_dscritic => vr_dscritic); --Descricao Erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL
           OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
      EXCEPTION
        WHEN vr_exc_saida THEN
          NULL;
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;
      END;
    
      --Se ocorreu erro
      IF nvl(vr_cdcritic, 0) <> 0 THEN
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Retorno n�o OK
        pr_des_reto := 'NOK';                              
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_lanca_juro_contrato. ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_lanca_juro_contrato;

  /* Verificar Liquidacao Emprestimo  */
  PROCEDURE pc_verifica_liquidacao_empr(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                       ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                       ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                       ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                       ,pr_flgliqui OUT BOOLEAN --> Liquidado
                                       ,pr_flgopera OUT BOOLEAN --> Financiamento
                                       ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_verifica_liquidacao_empr                 Antigo: b1wgen0136.p/verifica_liquidacao_empr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Marco/2014                        Ultima atualizacao: 03/03/2014
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para verificar liquidacao emprestimo
    
       Alteracoes: 03/03/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
    ............................................................................. */
  
    DECLARE
    
      --Selecionar Parcelas Liquidadas
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
        SELECT COUNT(1)
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
               AND crappep.nrdconta = pr_nrdconta
               AND crappep.nrctremp = pr_nrctremp
               AND crappep.inliquid <> 1;
    
      --Variaveis Locais
      vr_flgtrans BOOLEAN;
      vr_inliquid INTEGER;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
      vr_flgtrans := FALSE;
    
      --Inicializar retornos
      pr_flgliqui := FALSE;
      pr_flgopera := FALSE;
    
      BEGIN
        -- Busca dos detalhes do empr�stimo
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
        FETCH cr_crapepr
          INTO rw_crapepr;
        -- Se n�o encontrar informa��es
        IF cr_crapepr%NOTFOUND THEN
          -- Fechar o cursor pois teremos raise
          CLOSE cr_crapepr;
          -- Gerar erro com critica 356
          vr_cdcritic := 356;
          vr_dscritic := gene0001.fn_busca_critica(356);
          --Sair
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor para continuar o processo
          CLOSE cr_crapepr;
          /* Se ja foi liquidado ,  desconsidera */
          IF rw_crapepr.inliquid <> 0 THEN
            --Sair
            RAISE vr_exc_saida;
          END IF;
        END IF;
      
        /* Todas as parcelas devem estar liquidadas */
        OPEN cr_crappep(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
        FETCH cr_crappep
          INTO vr_inliquid;
        CLOSE cr_crappep;
      
        /* vr_inliquid > 0 indica que tem parcelas em aberto */
        IF vr_inliquid > 0 THEN
          --Sair pois tem parcelas em aberto
          RAISE vr_exc_saida;
        END IF;
      
        --Selecionar Linha Credito
        OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                       ,pr_cdlcremp => rw_crapepr.cdlcremp);
        FETCH cr_craplcr
          INTO rw_craplcr;
        --Se nao Encontrou
        IF cr_craplcr%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_craplcr;
          vr_cdcritic := 363;
          --Sair
          RAISE vr_exc_saida;
        ELSE
          --Determinar se a Operacao � financiamento
          pr_flgopera := rw_craplcr.dsoperac = 'FINANCIAMENTO';
          --marcar como liquidado
          pr_flgliqui := TRUE;
        END IF;
        --Fechar Cursor
        CLOSE cr_craplcr;
      
        -- Marcar que realizou transacao
        vr_flgtrans := TRUE;
      
      EXCEPTION
        WHEN vr_exc_saida THEN
          NULL;
      END;
    
      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans
         AND nvl(vr_cdcritic, 0) <> 0 THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_verifica_liquidacao_empr ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_verifica_liquidacao_empr;

  --Procedure para Validar Pagamentos
  PROCEDURE pc_valida_pagamentos_geral(pr_cdcooper         IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                      ,pr_cdagenci         IN crapass.cdagenci%TYPE --Codigo Agencia
                                      ,pr_nrdcaixa         IN craplot.nrdcaixa%TYPE --Codigo Caixa
                                      ,pr_cdoperad         IN craplot.cdoperad%TYPE --Operador
                                      ,pr_nmdatela         IN crapprg.cdprogra%TYPE --Nome da Tela
                                      ,pr_idorigem         IN INTEGER --Identificador origem
                                      ,pr_nrdconta         IN crapepr.nrdconta%TYPE --Numero da Conta
                                      ,pr_nrctremp         IN crapepr.nrctremp%TYPE --Numero Contrato
                                      ,pr_idseqttl         IN crapttl.idseqttl%TYPE --Sequencial Titular
                                      ,pr_dtmvtolt         IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                                      ,pr_flgerlog         IN BOOLEAN --Erro no Log
                                      ,pr_dtrefere         IN crapdat.dtmvtolt%TYPE --Data Referencia
                                      ,pr_vlapagar         IN NUMBER --Valor Pagar
                                      ,pr_tab_crawepr      IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                      ,pr_vlsomato         OUT NUMBER --Soma Total
                                      ,pr_tab_erro         OUT gene0001.typ_tab_erro --tabela Erros
                                      ,pr_des_reto         OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_msg_confirma OUT typ_tab_msg_confirma) IS --Tabela Confirmacao
  
  BEGIN
    /* .............................................................................
    
       Programa: pc_valida_pagamentos_geral                 Antigo: b1wgen0084b.p/valida_pagamentos_geral
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 01/06/2016
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para lancamento de Juros dos Emprestimos
    
       Alteracoes: 27/02/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
                   12/03/2014 - Ajuste na procedure "valida_pagamentos_geral"
                                para liberar pagamento para Acredi (James).
    
                   17/04/2015 - Ajuste nos parametros na procedure pc_obtem_saldo_dia.
                                (James)
                                
                   14/01/2016 - Inicializar variavel vr_flgtrans com FALSE
                                 (Douglas - Chamado 285228 obtem-saldo-dia)

                   01/06/2016 - Adicionado validacao para identificar se esta executando
                                no batch ou online na chamada da procedure 
                                pc_obtem_saldo_dia (Douglas - Chamado 455609)

                   26/09/2016 - Adicionado validacao de contratos de acordo na procedure,
                                Prj. 302 (Jean Michel).             
    ............................................................................. */
  
    DECLARE
    
      --Selecionar operadores
      CURSOR cr_crapope(pr_crapope  IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT crapope.cdoperad
              ,crapope.vlpagchq
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;
    
      -- Busca dos dados do associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.inpessoa
              ,ass.vllimcre
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
               AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
    
      --Registro tipo Data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
      --Tabela de Saldos
      vr_tab_saldos EXTR0001.typ_tab_saldos;
    
      --Variavel dos Indices
      vr_index_crawepr  VARCHAR2(30);
      vr_index_saldo    PLS_INTEGER;
      vr_index_confirma PLS_INTEGER;
    
      --Variaveis Locais
      vr_flgtrans BOOLEAN := FALSE;
      vr_crapope  BOOLEAN;
      vr_difpagto NUMBER;
      vr_flgcrass BOOLEAN;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    
      vr_flgativo INTEGER := 0;

    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
    
      --Limpar tabelas
      pr_tab_erro.DELETE;
      pr_tab_msg_confirma.DELETE;
    
      BEGIN
      
        -- Verifica se a data esta cadastrada
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH BTCH0001.cr_crapdat
          INTO rw_crapdat;
        -- Se nao encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;
      
        --Selecionar Associado
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass
          INTO rw_crapass;
        CLOSE cr_crapass;
      
        --Selecionar Operadores
        OPEN cr_crapope(pr_crapope  => pr_cdcooper
                       ,pr_cdoperad => pr_cdoperad);
        FETCH cr_crapope
          INTO rw_crapope;
        --Determinar se encontrou
        vr_crapope := cr_crapope%FOUND;
        --Se nao encontrou
        IF NOT vr_crapope THEN
          vr_cdcritic := 67;
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapope;
      
        --Selecionar Detalhes do Emprestimo
        --Montar Indice de acesso
        vr_index_crawepr := lpad(pr_cdcooper, 10, '0') ||
                            lpad(pr_nrdconta, 10, '0') ||
                            lpad(pr_nrctremp, 10, '0');
        --Se nao encontrar a conta e contrato na tabela � problema
        IF NOT pr_tab_crawepr.EXISTS(vr_index_crawepr) THEN
          vr_cdcritic := 510;
          RAISE vr_exc_saida;
        ELSE
          rw_crawepr.dtlibera := pr_tab_crawepr(vr_index_crawepr).dtlibera;
          rw_crawepr.tpemprst := pr_tab_crawepr(vr_index_crawepr).tpemprst;
        END IF;
      
        --Tipo de Emprestimo
        IF rw_crawepr.tpemprst <> 1 THEN
          vr_dscritic := 'Tipo de emprestimo invalido.';
          --Levantar Excecao.
          RAISE vr_exc_saida;
        END IF;
        --Data Liberacao maior ou igual data movimento
        IF rw_crawepr.dtlibera >= pr_dtmvtolt THEN
          vr_dscritic := 'Atencao! contrato liberado nesta data. ' ||
                         'Liquidacao/antecipacao permitida a partir de ' ||
                         to_char(rw_crawepr.dtlibera + 1,'dd/mm/YYYY') || '.';
          RAISE vr_exc_saida;
        END IF;
      
        -- Verificar se o BATCH esta rodando
        IF rw_crapdat.inproces <> 1 THEN
          -- Se estiver no BATCH, utiliza a verificacao da conta a partir do vetor de contas
          -- que se nao estiver carregado fara a leitura de todas as contas da cooperativa
          -- Quando eh BATCH mantem o padrao TRUE
          vr_flgcrass := TRUE;
        ELSE 
          -- Se nao estiver no BATCH, busca apenas a informacao da conta que esta sendo passada
          vr_flgcrass := FALSE;
        END IF;
        
        --Limpar tabela saldos
        vr_tab_saldos.DELETE;
      
        --Obter Saldo do Dia
        EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                   ,pr_rw_crapdat => rw_crapdat
                                   ,pr_cdagenci   => pr_cdagenci
                                   ,pr_nrdcaixa   => pr_nrdcaixa
                                   ,pr_cdoperad   => pr_cdoperad
                                   ,pr_nrdconta   => pr_nrdconta
                                   ,pr_vllimcre   => rw_crapass.vllimcre
                                   ,pr_dtrefere   => pr_dtrefere
                                   ,pr_flgcrass   => vr_flgcrass
                                   ,pr_des_reto   => vr_des_erro
                                   ,pr_tab_sald   => vr_tab_saldos
                                   ,pr_tipo_busca => 'A'
                                   ,pr_tab_erro   => pr_tab_erro);
      
        --Buscar Indice
        vr_index_saldo := vr_tab_saldos.FIRST;
        IF vr_index_saldo IS NOT NULL THEN
          --Acumular Saldo
          pr_vlsomato := ROUND( nvl(vr_tab_saldos(vr_index_saldo).vlsddisp, 0) +
                                nvl(vr_tab_saldos(vr_index_saldo).vlsdchsl, 0) +
                                nvl(vr_tab_saldos(vr_index_saldo).vlsdbloq, 0) +
                                nvl(vr_tab_saldos(vr_index_saldo).vlsdblpr, 0) +
                                nvl(vr_tab_saldos(vr_index_saldo).vlsdblfp, 0) +
                                nvl(vr_tab_saldos(vr_index_saldo).vllimcre, 0),2);
        END IF;
      
        --Valor a Pagar Maior Soma total
        IF nvl(pr_vlapagar, 0) > nvl(pr_vlsomato, 0) THEN
          IF pr_idorigem = 5 THEN
            /* So pra pagamento online */
            --Se encontrou operador
            IF vr_crapope THEN
              --Diferenca no valor pago
              vr_difpagto := nvl(pr_vlapagar, 0) - nvl(pr_vlsomato, 0);
              --Valor Diferenca Maior Limite Pagamento Cheque
              IF vr_difpagto > nvl(rw_crapope.vlpagchq, 0) THEN
                vr_dscritic := 'Saldo alcada do operador insuficiente.';
                RAISE vr_exc_saida;
              END IF;
            END IF;
          END IF;
        
          --Montar Indice para Confirmacao
          vr_index_confirma := pr_tab_msg_confirma.count + 1;
          
          IF pr_idorigem = 3   THEN -- So pra pagamento InternetBank

            --Atribuir valores
            pr_tab_msg_confirma(vr_index_confirma).inconfir := 1;
            pr_tab_msg_confirma(vr_index_confirma).dsmensag := 'Saldo em conta insuficiente para pagamento da parcela.';     
                    
          ELSE
                    
            --Atribuir valores
            pr_tab_msg_confirma(vr_index_confirma).inconfir := 1;
            pr_tab_msg_confirma(vr_index_confirma).dsmensag := 'Saldo em conta insuficiente para pagamento da parcela. ' ||
                                                               'Confirma pagamento?';
          END IF;                                                                                                                              
        END IF;
      
        IF pr_idorigem IN(3,5) THEN 
          -- Verifica se existe contrato de acordo ativo
          RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_flgativo => vr_flgativo
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

          IF NVL(vr_cdcritic,0) > 0 THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            RAISE vr_exc_saida;
          ELSIF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;      
          END IF;
                                   
          IF vr_flgativo = 1 THEN
            vr_dscritic := 'Pagamento nao permitido, emprestimo em acordo.';
            RAISE vr_exc_saida;
          END IF;
        END IF;

        --Ocorreu transacao
        vr_flgtrans := TRUE;
      EXCEPTION
        WHEN vr_exc_saida THEN
          NULL;
      END;
    
      --Nao realizou transacao
      IF NOT vr_flgtrans THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_valida_pagamentos_geral ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_valida_pagamentos_geral;

  /* Validar pagamento Atrasado das parcelas de empr�stimo */
  PROCEDURE pc_valida_pagto_atr_parcel(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                      ,pr_cdoperad IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                      ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                      ,pr_idorigem IN INTEGER --> Id do m�dulo de sistema
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                      ,pr_flgerlog IN VARCHAR2 --> Indicador S/N para gera��o de log
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                      ,pr_nrparepr IN INTEGER --> N�mero parcelas empr�stimo
                                      ,pr_vlpagpar IN NUMBER --> Valor a pagar parcela
                                      ,pr_vlpagsld OUT NUMBER --> Valor Pago Saldo
                                      ,pr_vlatupar OUT NUMBER --> Valor Atual Parcela
                                      ,pr_vlmtapar OUT NUMBER --> Valor Multa Parcela
                                      ,pr_vljinpar OUT NUMBER --> Valor Juros parcela
                                      ,pr_vlmrapar OUT NUMBER --> Valor ???
                                      ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_valida_pagto_atr_parcel                 Antigo: b1wgen0084a.p/valida_pagamento_atrasado_parcela
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Marco/2014                        Ultima atualizacao: 26/11/2015
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para validar pagamento atrasado da parcela do emprestimo
    
       Alteracoes: 03/03/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
                   27/05/2014 - Ajuste para nao permitir informar o valor maior que a
                                parcela. (James)
                                
                   26/11/2015 - Ajuste na mensagem de critica do valor minimo da
                                parcela. (Rafael)
    ............................................................................. */
  
    DECLARE
    
      --Variaveis Locais
      vr_flgtrans BOOLEAN;
      vr_vlpagmin NUMBER;
      vr_valormin NUMBER;
      vr_vljinp59 NUMBER;
      vr_vljinp60 NUMBER;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      vr_dstextab craptab.dstextab%TYPE;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
      --Nao ocorreu transacao
      vr_flgtrans := FALSE;
    
      --Limpar tabela erro
      pr_tab_erro.DELETE;
    
      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Valida pagamento atrasado de parcela';
      END IF;
    
      --Valor Zerado
      IF nvl(pr_vlpagpar, 0) = 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Valor de pagamento nao informado.';
        RAISE vr_exc_saida;
      END IF;
    
      BEGIN
        --Calcular Atraso na parcela
        EMPR0001.pc_calc_atraso_parcela(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                       ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                                       ,pr_nrdcaixa => pr_nrdcaixa --> N�mero do caixa
                                       ,pr_cdoperad => pr_cdoperad --> C�digo do Operador
                                       ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                       ,pr_idorigem => pr_idorigem --> Id do m�dulo de sistema
                                       ,pr_nrdconta => pr_nrdconta --> N�mero da conta
                                       ,pr_idseqttl => pr_idseqttl --> Seq titula
                                       ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                       ,pr_flgerlog => pr_flgerlog --> Indicador S/N para gera��o de log
                                       ,pr_nrctremp => pr_nrctremp --> N�mero do contrato de empr�stimo
                                       ,pr_nrparepr => pr_nrparepr --> N�mero parcelas empr�stimo
                                       ,pr_vlpagpar => pr_vlpagpar --> Valor a pagar originalmente
                                       ,pr_vlpagsld => pr_vlpagsld --> Valor Pago Saldo
                                       ,pr_vlatupar => pr_vlatupar --> Valor parcela
                                       ,pr_vlmtapar => pr_vlmtapar --> Valor Multa
                                       ,pr_vljinpar => pr_vljinpar --> Valor Juros
                                       ,pr_vlmrapar => pr_vlmrapar --> Valor Mora
                                       ,pr_vljinp59 => vr_vljinp59 --> Juros periodo < 59 dias
                                       ,pr_vljinp60 => vr_vljinp60 --> Juros Periodo > 60dias
                                       ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                       ,pr_tab_erro => pr_tab_erro); --> Tabela com poss�ves erros
        --Se Retornou erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
        --Consultar parametros Emprestimo
        vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'PAREMPREST'
                                                 ,pr_tpregist => 1);
        -- Se nao encontrar
        IF trim(vr_dstextab) IS NULL THEN
          vr_cdcritic := 55;
          vr_dscritic := NULL;
          --Sair
          RAISE vr_exc_saida;
        ELSE
          --Pagamento Minimo
          vr_vlpagmin := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab, 22, 12));
        END IF;
      
        IF pr_idorigem = 1 THEN
          /* Pagamento via processo batch */
          /* Se valor atual da parcela >= que o minimo a pagar */
          IF pr_vlatupar >= nvl(vr_vlpagmin, 0) THEN
            /* Multa + jr.mora + minimo a pagar */
            vr_valormin := nvl(apli0001.fn_round(pr_vlmtapar, 2), 0) +
                           nvl(apli0001.fn_round(pr_vlmrapar, 2), 0) +
                           nvl(apli0001.fn_round(vr_vlpagmin, 2), 0);
          ELSE
            /* Multa + jr.normais */
            vr_valormin := nvl(apli0001.fn_round(pr_vlmtapar, 2), 0) +
                           nvl(apli0001.fn_round(pr_vlmrapar, 2), 0) +
                           nvl(apli0001.fn_round(pr_vlatupar, 2), 0);
          END IF;
        ELSE
          /* Pagamento via tela */
          /* Multa + jr.mora + qualquer valor de pagamento */
          vr_valormin := nvl(apli0001.fn_round(pr_vlmtapar, 2), 0) +
                         nvl(apli0001.fn_round(pr_vlmrapar, 2), 0) + 0.01;
        END IF;
        --Valor da Parcela menor valor minimo
        IF nvl(apli0001.fn_round(pr_vlpagpar, 2), 0) < nvl(vr_valormin, 0) THEN
          ----------------------------------------------------------------------------------
          -- Projeto 302 - Sistema de Acordos - Respons�vel: James
          -- Incluso por: Renato Darosci - 27/09/2016
          --    
          -- Realizado a fixa��o do c�digo de erro para pagamento do valor m�nimo. O 
          -- intu�to disto � poder tratar este erro em particular na rotina chamadora,
          -- pois para o sistema de acordos, esta situa��o n�o define um erro, apenas 
          -- define as parcelas que puderam ou n�o ser liquidadas conforme o valor do 
          -- boleto pago. 
          --
          -- NA CRIA��O DE NOVAS CR�TICAS QUANTO AO PAGAMENTO DO VALOR MIN�MO, O C�DIGO 
          -- DE ERRO DEVE SER INCLUSO NO PARAMETRO(CRAPPRM) "CRITICA_VLR_MIN_PARCEL", para
          -- QUE O PAGAMENTO DO ACORDO, TRATE A NOVA CRITICA DA MESMA FORMA.
          -- EM CASO DE D�VIDAS VERIFIQUE -> RECP0001
          ----------------------------------------------------------------------------------
          vr_cdcritic := 995;
          vr_dscritic := 'Valor a pagar deve ser maior ou igual que R$ ' ||
                         to_char(vr_valormin,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
               
          --Sair
          RAISE vr_exc_saida;
        END IF;
        --Valor da Parcela maior soma juros
        IF nvl(apli0001.fn_round(pr_vlpagpar, 2), 0) >
           (nvl(apli0001.fn_round(pr_vlatupar, 2), 0) +
            nvl(apli0001.fn_round(pr_vlmtapar, 2), 0) +
            nvl(apli0001.fn_round(pr_vlmrapar, 2), 0)) THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Valor informado para pagamento maior que valor da parcela';
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        --Marcar que realizou transacao
        vr_flgtrans := TRUE;
      EXCEPTION
        WHEN vr_exc_saida THEN
          NULL;
      END;
    
      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      ELSIF pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Retorno OK
        pr_des_reto := 'OK';
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_valida_pagto_atr_parcel ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_valida_pagto_atr_parcel;

  /* Validar pagamento Antecipado das parcelas de empr�stimo */
  PROCEDURE pc_valida_pagto_antec_parc(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                      ,pr_cdoperad IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                      ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                      ,pr_idorigem IN INTEGER --> Id do m�dulo de sistema
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                      ,pr_flgerlog IN VARCHAR2 --> Indicador S/N para gera��o de log
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                      ,pr_nrparepr IN INTEGER --> N�mero parcelas empr�stimo
                                      ,pr_vlpagpar IN NUMBER --> Valor a pagar parcela
                                      ,pr_vlatupar OUT NUMBER --> Valor Atual Parcela
                                      ,pr_vldespar OUT NUMBER --> Valor Desconto Parcela
                                      ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_valida_pagto_antec_parc                 Antigo: b1wgen0084a.p/valida_pagamento_antecipado_parcela
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Marco/2015                        Ultima atualizacao: 25/03/2015
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para validar pagamento antecipado da parcela do emprestimo
    
       Alteracoes: 25/03/2015 - Convers�o Progress para Oracle (Alisson - AMcom)
    
    ............................................................................. */
  
    DECLARE
    
      --Variaveis Locais
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
    
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
    
      --Limpar tabela erro
      pr_tab_erro.DELETE;
    
      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Valida pagamento antecipado de parcela';
      END IF;
    
      --Selecionar Parcela 
      OPEN cr_crappep(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nrparepr => pr_nrparepr);
      FETCH cr_crappep INTO rw_crappep;
      --Se nao Encontrou
      IF cr_crappep%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crappep;
        --Mensagem Erro
        vr_dscritic:= 'Parcela nao encontrada.';
        --Sair
        RAISE vr_exc_erro;                
      ELSE
        --Fechar Cursor
        CLOSE cr_crappep;                
      END IF;  
      
      --Validar Valor Pagamento
      IF nvl(pr_vlpagpar,0) = 0 THEN
        --Mensagem Erro
        vr_dscritic:= 'Valor de pagamento nao informado.';
        --Sair
        RAISE vr_exc_erro;    
      END IF;

      /* Cursor de Emprestimos */
      OPEN cr_crapepr(pr_cdcooper => rw_crappep.cdcooper
                     ,pr_nrdconta => rw_crappep.nrdconta
                     ,pr_nrctremp => rw_crappep.nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      --Se nao Encontrou
      IF cr_crapepr%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapepr;
        --Mensagem Erro
        vr_dscritic:= 'Contrato n�o encontrado.';
        --Sair
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapepr;
      END IF;  
        
      -- Procedure para calcular valor antecipado de parcelas de empr�stimo
      empr0001.pc_calc_antecipa_parcela(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                       ,pr_cdagenci => pr_cdagenci         --> C�digo da ag�ncia
                                       ,pr_nrdcaixa => pr_nrdcaixa         --> N�mero do caixa
                                       ,pr_dtvencto => rw_crappep.dtvencto --> Data do vencimento
                                       ,pr_vlsdvpar => rw_crappep.vlsdvpar --> Valor devido parcela
                                       ,pr_txmensal => rw_crapepr.txmensal --> Taxa aplicada ao empr�stimo
                                       ,pr_dtmvtolt => pr_dtmvtolt         --> Data do movimento atual
                                       ,pr_dtdpagto => rw_crapepr.dtdpagto --> Data de pagamento
                                       ,pr_vlatupar => pr_vlatupar         --> Valor atualizado da parcela
                                       ,pr_vldespar => pr_vldespar         --> Valor desconto da parcela
                                       ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                       ,pr_tab_erro => vr_tab_erro);       --> Tabela com poss�ves erros
      -- Testar erro
      IF vr_des_reto = 'NOK' THEN
        -- Levantar exce��o
        RAISE vr_exc_erro;
      END IF;
    
      --Verificar Valor Informado e Valor da Parcela
      IF nvl(pr_vlpagpar,0) > nvl(pr_vlatupar,0) THEN
        --Mensagem Erro
        vr_dscritic:= 'Valor informado para pagamento maior que valor da parcela.';
        --Sair
        RAISE vr_exc_erro;
      END IF;
        
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;

      -- Retorno OK
      pr_des_reto := 'OK';
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);        
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_valida_pagto_antec_parc ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_valida_pagto_antec_parc;
  
  /* Gravar a Liquidacao do Emprestimo  */
  PROCEDURE pc_grava_liquidacao_empr(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE --> Numero banco/caixa
                                    ,pr_cdoperad IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                    ,pr_cdpactra IN INTEGER --> P.A. da transa��o
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                    ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                    ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                    ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                    ,pr_inproces IN crapdat.inproces%TYPE --> Indicador Processo
                                    ,pr_cdorigem IN NUMBER DEFAULT 0 --> Origem do Movimento
                                    ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_grava_liquidacao_empr                 Antigo: b1wgen0136.p/grava_liquidacao_empr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 20/10/2015
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para verificar liquidacao emprestimo
    
       Alteracoes: 03/03/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
                   16/06/2014 - Adicionado o parametro nrseqava na prodecure
                                "pc_cria_lancamento_lem". (James)
                                
                   08/10/2015 - Incluir os hist�ricos de estorno do PP. (0scar)
                   
                   20/10/2015 - Incluir os hist�ricos de ajuste o contrato 
                                liquidado pode ser reaberto (Oscar).
    
    ............................................................................. */
  
    DECLARE
    
      --Selecionar Lancamentos
      CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
        SELECT SUM(DECODE(craplem.cdhistor
                         ,1044
                         ,craplem.vllanmto
                         ,1039
                         ,craplem.vllanmto
                         ,1045
                         ,craplem.vllanmto
                         ,1046
                         ,craplem.vllanmto
                         ,1057
                         ,craplem.vllanmto
                         ,1058
                         ,craplem.vllanmto
                         ,1043
                         ,craplem.vllanmto
                         ,1041
                         ,craplem.vllanmto
                         ,1036
                         ,craplem.vllanmto * -1
                         ,1059
                         ,craplem.vllanmto * -1
                         ,1037
                         ,craplem.vllanmto * -1
                         ,1038
                         ,craplem.vllanmto * -1
                         ,1716
                         ,craplem.vllanmto * -1
                         ,1707
                         ,craplem.vllanmto * -1
                         ,1714
                         ,craplem.vllanmto * -1
                         ,1705
                         ,craplem.vllanmto * -1
                         ,1040
                         ,craplem.vllanmto * -1
                         ,1042
                         ,craplem.vllanmto * -1))
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor IN
           (1044, 1039, 1045, 1046, 1057, 1058, 1036, 1059, 
            1037, 1038, 1716, 1707, 1714, 1705, 1040, 1041, 
            1042, 1043);
    
      -- Selecionar registros de estorno */
      CURSOR cr_craplem_estorno(pr_cdcooper IN craplem.cdcooper%TYPE
                               ,pr_nrdconta IN craplem.nrdconta%TYPE
                               ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
        SELECT craplem.cdcooper
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor in (1052,1073)
           AND ROWNUM = 1;
      rw_craplem_estorno cr_craplem_estorno%ROWTYPE;
    
      --Variaveis Locais
      vr_inliquid INTEGER;
      vr_contador INTEGER;
      vr_flgopera BOOLEAN;
      vr_vllancre NUMBER;
      vr_vllandeb NUMBER;
      vr_vlsdeved NUMBER;
      vr_flgliqui BOOLEAN;
      vr_cdhistor INTEGER;
      vr_nrdolote INTEGER;
      vr_flgcredi BOOLEAN;
      vr_flgtrans BOOLEAN;
      vr_inusatab BOOLEAN;
      vr_dstextab craptab.dstextab%TYPE;
    
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
      --Marcar que nao realizou transacao
      vr_flgtrans := FALSE;
    
      BEGIN
      
        --Criar savepoint para desfazer transacao
        SAVEPOINT sav_trans;
      
        -- Verifica se a data esta cadastrada
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH BTCH0001.cr_crapdat
          INTO rw_crapdat;
        -- Se nao encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;
        --Verificar se jah est� liquidado
        pc_verifica_liquidacao_empr(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                   ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                                   ,pr_nrdcaixa => pr_nrdcaixa --> N�mero do caixa
                                   ,pr_nrdconta => pr_nrdconta --> N�mero da conta
                                   ,pr_nrctremp => pr_nrctremp --> N�mero do contrato de empr�stimo
                                   ,pr_flgliqui => vr_flgliqui --> Liquidado
                                   ,pr_flgopera => vr_flgopera --> Financiamento
                                   ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                   ,pr_tab_erro => pr_tab_erro); --> Tabela com poss�ves erros
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          --sair
          RAISE vr_exc_saida;
        END IF;
        --Se nao estiver Liquidado
        IF NOT vr_flgliqui THEN
          --Marcar que realizou transacao
          vr_flgtrans := TRUE;
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        -- Busca dos detalhes do empr�stimo
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
        FETCH cr_crapepr
          INTO rw_crapepr;
        -- Se n�o encontrar informa��es
        IF cr_crapepr%NOTFOUND THEN
          -- Fechar o cursor pois teremos raise
          CLOSE cr_crapepr;
          -- Gerar erro com critica 356
          vr_cdcritic := 356;
          vr_dscritic := gene0001.fn_busca_critica(356);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor para continuar o processo
          CLOSE cr_crapepr;
        END IF;
      
        --Zerar lancamentos a debito/credito
        vr_vllancre := 0;
        vr_vllandeb := 0;
      
        /* Contabilizar creditos  */
        OPEN cr_craplem(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
        FETCH cr_craplem
          INTO vr_vlsdeved;
        --Fechar Cursor
        CLOSE cr_craplem;
      
        --Se o saldo devedor for negativo
        IF nvl(vr_vlsdeved, 0) < 0 THEN
          IF vr_flgopera THEN
            /* Financiamento */
            --Historico
            vr_cdhistor := 1043;
            --Lote
            vr_nrdolote := 600009;
          ELSE
            /* Emprestimo */
            --Historico
            vr_cdhistor := 1041;
            --Lote
            vr_nrdolote := 600007;
          END IF;
          /* Inverter sinal para efetuar o lancamento */
          vr_vlsdeved := vr_vlsdeved * -1;
          vr_flgcredi := TRUE; /* Credita */
        ELSIF nvl(vr_vlsdeved, 0) > 0 THEN
          IF vr_flgopera THEN
            /* Financiamento */
            --Historico
            vr_cdhistor := 1042;
            --Lote
            vr_nrdolote := 600008;
          ELSE
            /* Emprestimo */
            --Historico
            vr_cdhistor := 1040;
            --Lote
            vr_nrdolote := 600006;
          END IF;
          vr_flgcredi := FALSE; /* Debita */
        END IF;
      
        IF nvl(vr_vlsdeved, 0) <> 0 THEN
          /* Efetuar ajuste */
          /* Cria lancamento e atualiza o lote  */
          pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                                ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                ,pr_cdbccxlt => pr_cdbccxlt --Codigo Caixa
                                ,pr_cdoperad => pr_cdoperad --Operador
                                ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                                ,pr_tplotmov => 5 --Tipo movimento
                                ,pr_nrdolote => vr_nrdolote --Numero Lote
                                ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                ,pr_cdhistor => vr_cdhistor --Codigo Historico
                                ,pr_nrctremp => pr_nrctremp --Numero Contrato
                                ,pr_vllanmto => vr_vlsdeved --Valor Lancamento
                                ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                                ,pr_txjurepr => 0 --Taxa Juros Emprestimo
                                ,pr_vlpreemp => 0 --Valor Emprestimo
                                ,pr_nrsequni => 0 --Numero Sequencia
                                ,pr_nrparepr => 0 --Numero Parcelas Emprestimo
                                ,pr_flgincre => TRUE --Indicador Credito
                                ,pr_flgcredi => vr_flgcredi --Credito/Debito
                                ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                ,pr_cdorigem => pr_cdorigem -- Origem do Lan�amento
                                ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                ,pr_dscritic => vr_dscritic); --Descricao Erro
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL
             OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
      
        IF nvl(rw_crapepr.vlsdeved, 0) <> 0 THEN          
          /* Verificar se existe registro de estorno */
          OPEN cr_craplem_estorno(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp);
          FETCH cr_craplem_estorno
            INTO rw_craplem_estorno;
          --Se nao Encontrou
          IF cr_craplem_estorno%NOTFOUND THEN
            BEGIN
              UPDATE crapepr
                 SET crapepr.vlajsdev = rw_crapepr.vlsdeved
                    ,crapepr.vlsdeved = 0
               WHERE crapepr.rowid = rw_crapepr.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                --Fechar Cursor
                CLOSE cr_craplem_estorno;
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
          END IF;
          CLOSE cr_craplem_estorno;
        END IF;
      
        --Liquidar Emprestimo
        BEGIN
          UPDATE crapepr
             SET crapepr.inliquid = 1 /* Liquidar Emprestimo */
						    ,crapepr.dtliquid = pr_dtmvtolt
           WHERE crapepr.rowid = rw_crapepr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      
        --Buscar parametro
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'TAXATABELA'
                                                 ,pr_tpregist => 0);
        --Se nao encontrou parametro
        IF trim(vr_dstextab) IS NULL THEN
          vr_inusatab := FALSE;
        ELSE
          IF SUBSTR(vr_dstextab, 1, 1) = '0' THEN
            vr_inusatab := FALSE;
          ELSE
            vr_inusatab := TRUE;
          END IF;
        END IF;
      
        --Desativar Rating
        rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper --Cooperativa
                                   ,pr_cdagenci   => pr_cdagenci --Agencia
                                   ,pr_nrdcaixa   => pr_nrdcaixa --Numero Caixa
                                   ,pr_cdoperad   => pr_cdcooper --Operador
                                   ,pr_rw_crapdat => rw_crapdat --Registro Data
                                   ,pr_nrdconta   => rw_crapepr.nrdconta --Conta Corrente
                                   ,pr_tpctrrat   => 90 /* Emprestimo */ --Tipo Contrato
                                   ,pr_nrctrrat   => rw_crapepr.nrctremp --Numero Contrato
                                   ,pr_flgefeti   => 'S ' --Efetivar
                                   ,pr_idseqttl   => 1 --Titular
                                   ,pr_idorigem   => 1 --Origem
                                   ,pr_inusatab   => vr_inusatab --Uso tabela Juros
                                   ,pr_nmdatela   => pr_nmdatela --Nome da Tela
                                   ,pr_flgerlog   => 'N' --Escrever Log
                                   ,pr_des_reto   => vr_des_erro --Retorno OK/NOK
                                   ,pr_tab_erro   => pr_tab_erro); --Tabela Erro
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          RAISE vr_exc_saida;
        END IF;
      
        /** GRAVAMES **/
        GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper -- Cooperativa
                                             ,pr_nrdconta => rw_crapepr.nrdconta -- Numero da Conta
                                             ,pr_nrctrpro => rw_crapepr.nrctremp -- Contrato Emprestimo
                                             ,pr_dtmvtolt => pr_dtmvtolt -- Data Movimento
                                             ,pr_des_reto => vr_des_erro -- Retorno OK/NOK
                                             ,pr_tab_erro => pr_tab_erro -- Tabela de Erros
                                             ,pr_cdcritic => vr_cdcritic -- Codigo erro
                                             ,pr_dscritic => vr_dscritic); -- Descricao erro
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          RAISE vr_exc_saida;
        END IF;
      
        --Marcar que a transacao ocorreu
        vr_flgtrans := TRUE;
      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT sav_trans;
      END;
    
      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_grava_liquidacao_empr ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_grava_liquidacao_empr;

  /* Efetivar o pagamento da parcela na craplem  */
  PROCEDURE pc_efetiva_pag_atr_parcel_lem(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                         ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                         ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                         ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                         ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                         ,pr_idorigem    IN INTEGER --> Id do m�dulo de sistema
                                         ,pr_cdpactra    IN INTEGER --> P.A. da transa��o
                                         ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                         ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                         ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                         ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para gera��o de log
                                         ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                         ,pr_nrparepr    IN INTEGER --> N�mero parcelas empr�stimo
                                         ,pr_vlpagpar    IN NUMBER --> Valor da parcela emprestimo
                                         ,pr_tab_crawepr IN EMPR0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                         ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                         ,pr_vlpagsld    OUT NUMBER --> Valor Pago Saldo
                                         ,pr_vlrmulta    OUT NUMBER --> Valor Multa
                                         ,pr_vlatraso    OUT NUMBER --> Valor Atraso
                                         ,pr_cdhismul    OUT INTEGER --> Historico Multa
                                         ,pr_cdhisatr    OUT INTEGER --> Historico Atraso
                                         ,pr_cdhispag    OUT INTEGER --> Historico Pagamento
                                         ,pr_loteatra    OUT INTEGER --> Lote Atraso
                                         ,pr_lotemult    OUT INTEGER --> Lote Multa
                                         ,pr_lotepaga    OUT INTEGER --> Lote Pagamento
                                         ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                         ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_efetiva_pag_atr_parcel_lem                 Antigo: b1wgen0084a.p/efetiva_pagamento_atrasado_parcela_craplem
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Marco/2014                        Ultima atualizacao: 17/03/2016
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetivar o pagamento atrasado da parcela na craplem
    
       Alteracoes: 04/03/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
                   16/06/2014 - Adicionado o parametro nrseqava na prodecure
                                "pc_cria_lancamento_lem". (James)
                                
                   16/10/2015 - Zerar o campo vlsdvsji quando liquidar a parcela PP (Oscar)             
                   
                   17/03/2016 - Limpar campos de saldo ai liquidar crappep SD366229 (Odirlei-AMcom)
    ............................................................................. */
  
    DECLARE
    
      vr_vlatupar NUMBER;
      vr_vlmtapar NUMBER;
      vr_vljinpar NUMBER;
      vr_vlmrapar NUMBER;
      vr_vlpagpar NUMBER;
      vr_txdiaria NUMBER;
      vr_vljurmes NUMBER;
      vr_floperac BOOLEAN;
      vr_inliquid INTEGER;
      vr_nrdolote INTEGER;
      vr_cdhistor INTEGER;
      vr_diarefju INTEGER;
      vr_mesrefju INTEGER;
      vr_anorefju INTEGER;
      vr_qtprepag INTEGER;
      vr_qtprecal INTEGER;
      vr_vlmuljur NUMBER;
      vr_vlsdeved NUMBER;
      vr_flgtrans BOOLEAN;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_exc_desvio EXCEPTION;
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
      --Inicializar transacao
      vr_flgtrans := FALSE;
    
      --Limpar Tabela erro
      pr_tab_erro.DELETE;
    
      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Efetiva pagamento atrasado de parcela craplem';
      END IF;
    
      --Validar Pagamento atrasado parcela
      pc_valida_pagto_atr_parcel(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                                ,pr_nrdcaixa => pr_nrdcaixa --> N�mero do caixa
                                ,pr_cdoperad => pr_cdoperad --> C�digo do Operador
                                ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                ,pr_idorigem => pr_idorigem --> Id do m�dulo de sistema
                                ,pr_nrdconta => pr_nrdconta --> N�mero da conta
                                ,pr_idseqttl => pr_idseqttl --> Seq titula
                                ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                ,pr_flgerlog => pr_flgerlog --> Indicador S/N para gera��o de log
                                ,pr_nrctremp => pr_nrctremp --> N�mero do contrato de empr�stimo
                                ,pr_nrparepr => pr_nrparepr --> N�mero parcelas empr�stimo
                                ,pr_vlpagpar => pr_vlpagpar --> Valor a pagar parcela
                                ,pr_vlpagsld => pr_vlpagsld --> Valor Pago Saldo
                                ,pr_vlatupar => vr_vlatupar --> Valor Atual Parcela
                                ,pr_vlmtapar => vr_vlmtapar --> Valor Multa Parcela
                                ,pr_vljinpar => vr_vljinpar --> Valor Juros parcela
                                ,pr_vlmrapar => vr_vlmrapar --> Valor Mora
                                ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                ,pr_tab_erro => pr_tab_erro); --> Tabela com poss�ves erros
      --Se ocorreu erro
      IF vr_des_erro <> 'OK' THEN
        pr_des_reto := 'NOK';
        --Sair
        RETURN;
      END IF;
    
      BEGIN
        --Criar savepoint para desfazer transacao
        SAVEPOINT sav_trans;
      
        --Buscar registro da parcela
        OPEN cr_crappep(pr_cdcooper => pr_cdcooper --> Cooperativa
                       ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                       ,pr_nrctremp => pr_nrctremp --> Numero Contrato
                       ,pr_nrparepr => pr_nrparepr); --> Numero da parcela
        FETCH cr_crappep
          INTO rw_crappep;
        --Se nao Encontrou
        IF cr_crappep%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crappep;
          vr_cdcritic := 55;
          RAISE vr_exc_saida;
        END IF;
        --Fechar Cursor
        CLOSE cr_crappep;
      
        --Buscar registro emprestimo
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper --> Cooperativa
                       ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                       ,pr_nrctremp => pr_nrctremp); --> Numero Contrato
        FETCH cr_crapepr
          INTO rw_crapepr;
        --Se nao Encontrou
        IF cr_crapepr%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapepr;
          vr_cdcritic := 55;
          RAISE vr_exc_saida;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapepr;
      
        --Selecionar Linha Credito
        OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                       ,pr_cdlcremp => rw_crapepr.cdlcremp);
        FETCH cr_craplcr
          INTO rw_craplcr;
        --Se nao Encontrou
        IF cr_craplcr%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_craplcr;
          vr_cdcritic := 363;
          --Sair
          RAISE vr_exc_saida;
        ELSE
          --Determinar se a Operacao � financiamento
          vr_floperac := rw_craplcr.dsoperac = 'FINANCIAMENTO';
        END IF;
        --Fechar Cursor
        CLOSE cr_craplcr;
      
        --Valor A pagar
        vr_vlpagpar := pr_vlpagsld;
        --Taxa Diaria
        vr_txdiaria := rw_crapepr.txjuremp;
      
        --Lancar Juros Contrato
        EMPR0001.pc_lanca_juro_contrato(pr_cdcooper    => pr_cdcooper --Codigo Cooperativa
                                       ,pr_cdagenci    => pr_cdagenci --Codigo Agencia
                                       ,pr_nrdcaixa    => pr_nrdcaixa --Codigo Caixa
                                       ,pr_nrdconta    => pr_nrdconta --Numero da Conta
                                       ,pr_nrctremp    => pr_nrctremp --Numero Contrato
                                       ,pr_dtmvtolt    => pr_dtmvtolt --Data Emprestimo
                                       ,pr_cdoperad    => pr_cdoperad --Operador
                                       ,pr_cdpactra    => pr_cdpactra --Posto Atendimento
                                       ,pr_flnormal    => FALSE --Lancamento Normal
                                       ,pr_dtvencto    => NULL --Data vencimento
                                       ,pr_ehmensal    => FALSE --Indicador Mensal
                                       ,pr_dtdpagto    => rw_crapepr.dtdpagto --Data pagamento
                                       ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                       ,pr_cdorigem    => pr_idorigem
                                       ,pr_vljurmes    => vr_vljurmes --Valor Juros no Mes
                                       ,pr_diarefju    => vr_diarefju --Dia Referencia Juros
                                       ,pr_mesrefju    => vr_mesrefju --Mes Referencia Juros
                                       ,pr_anorefju    => vr_anorefju --Ano Referencia Juros
                                       ,pr_des_reto    => vr_des_erro --Retorno OK/NOK
                                       ,pr_tab_erro    => pr_tab_erro); --tabela Erros
      
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          -- Se tem erro
          IF pr_tab_erro.count > 0 THEN
            vr_cdcritic := 0;
            vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          END IF;
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        /* Valor da multa */
        IF nvl(vr_vlmtapar, 0) > 0 THEN
          IF vr_floperac THEN
            /* Financiamento */
            vr_nrdolote := 600019;
          ELSE
            vr_nrdolote := 600018; /* Emprestimo */
          END IF;
        
          -- Condicao para verificar se o pagamento foi feito por aval
          IF pr_nrseqava = 0
             OR pr_nrseqava IS NULL THEN
            IF vr_floperac THEN
              vr_cdhistor := 1076;
            ELSE
              vr_cdhistor := 1047;
            END IF;
          ELSE
            IF vr_floperac THEN
              vr_cdhistor := 1618;
            ELSE
              vr_cdhistor := 1540;
            END IF;
          END IF;
        
          /* Cria lancamento craplem e atualiza o seu lote */
          pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                                ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                ,pr_cdbccxlt => 100 --Codigo Caixa
                                ,pr_cdoperad => pr_cdoperad --Operador
                                ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                                ,pr_tplotmov => 5 --Tipo movimento
                                ,pr_nrdolote => vr_nrdolote --Numero Lote
                                ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                ,pr_cdhistor => vr_cdhistor --Codigo Historico
                                ,pr_nrctremp => pr_nrctremp --Numero Contrato
                                ,pr_vllanmto => vr_vlmtapar --Valor Multa Parcela
                                ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                                ,pr_txjurepr => rw_crapepr.txjuremp --Taxa Juros Emprestimo
                                ,pr_vlpreemp => rw_crappep.vlparepr --Valor Emprestimo
                                ,pr_nrsequni => rw_crappep.nrparepr --Numero Sequencia
                                ,pr_nrparepr => rw_crappep.nrparepr --Numero Parcelas Emprestimo
                                ,pr_flgincre => TRUE --Indicador Credito
                                ,pr_flgcredi => TRUE --Credito
                                ,pr_nrseqava => pr_nrseqava --Pagamento: Sequencia do avalista
                                ,pr_cdorigem => pr_idorigem
                                ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                ,pr_dscritic => vr_dscritic); --Descricao Erro
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL
             OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        
          IF vr_floperac THEN
            /* Financiamento */
            vr_nrdolote := 600021;
          ELSE
            vr_nrdolote := 600020; /* Emprestimo */
          END IF;
        
          -- Condicao para verificar se o pagamento foi feito por aval
          IF pr_nrseqava = 0
             OR pr_nrseqava IS NULL THEN
            IF vr_floperac THEN
              /* Financiamento */
              vr_cdhistor := 1070;
            ELSE
              /* Emprestimo */
              vr_cdhistor := 1060;
            END IF;
          ELSE
            IF vr_floperac THEN
              /* Financiamento */
              vr_cdhistor := 1542;
            ELSE
              /* Emprestimo */
              vr_cdhistor := 1541;
            END IF;
          END IF;
        
          --Valor da Multa
          pr_vlrmulta := vr_vlmtapar;
          --Historico Multa
          pr_cdhismul := vr_cdhistor;
          --Lote Multa
          pr_lotemult := vr_nrdolote;
          /* Atualizar o valor pago da multa na parcela */
          BEGIN
            UPDATE crappep
               SET crappep.vlpagmta = nvl(crappep.vlpagmta, 0) +
                                      nvl(vr_vlmtapar, 0)
             WHERE crappep.rowid = rw_crappep.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar crappep. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
      
        /* Pagamento de juros de mora */
        IF nvl(vr_vlmrapar, 0) > 0
           AND nvl(vr_vlpagpar, 0) >= 0 THEN
          IF vr_floperac THEN
            /* Financiamento */
            vr_nrdolote := 600023;
          ELSE
            vr_nrdolote := 600022; /* Emprestimo */
          END IF;
        
          -- Condicao para verificar se o pagamento foi feito por aval
          IF pr_nrseqava = 0
             OR pr_nrseqava IS NULL THEN
            IF vr_floperac THEN
              /* Financiamento */
              vr_cdhistor := 1078;
            ELSE
              /* Emprestimo */
              vr_cdhistor := 1077;
            END IF;
          ELSE
            IF vr_floperac THEN
              /* Financiamento */
              vr_cdhistor := 1620;
            ELSE
              /* Emprestimo */
              vr_cdhistor := 1619;
            END IF;
          END IF;
        
          /* Cria lancamento craplem e atualiza o seu lote */
          pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                                ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                ,pr_cdbccxlt => 100 --Codigo Caixa
                                ,pr_cdoperad => pr_cdoperad --Operador
                                ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                                ,pr_tplotmov => 5 --Tipo movimento
                                ,pr_nrdolote => vr_nrdolote --Numero Lote
                                ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                ,pr_cdhistor => vr_cdhistor --Codigo Historico
                                ,pr_nrctremp => pr_nrctremp --Numero Contrato
                                ,pr_vllanmto => vr_vlmrapar --Valor Mora Parcela
                                ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                                ,pr_txjurepr => rw_crapepr.txjuremp --Taxa Juros Emprestimo
                                ,pr_vlpreemp => rw_crappep.vlparepr --Valor Emprestimo
                                ,pr_nrsequni => rw_crappep.nrparepr --Numero Sequencia
                                ,pr_nrparepr => rw_crappep.nrparepr --Numero Parcelas Emprestimo
                                ,pr_flgincre => TRUE --Indicador Credito
                                ,pr_flgcredi => TRUE --Credito
                                ,pr_nrseqava => pr_nrseqava --Pagamento: Sequencia do avalista
                                ,pr_cdorigem => pr_idorigem
                                ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                ,pr_dscritic => vr_dscritic); --Descricao Erro
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL
             OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        
          IF vr_floperac THEN
            /* Financiamento */
            vr_nrdolote := 600025;
          ELSE
            vr_nrdolote := 600024; /* Emprestimo */
          END IF;
        
          -- Condicao para verificar se o pagamento foi feito por aval
          IF pr_nrseqava = 0
             OR pr_nrseqava IS NULL THEN
            IF vr_floperac THEN
              /* Financiamento */
              vr_cdhistor := 1072;
            ELSE
              /* Emprestimo */
              vr_cdhistor := 1071;
            END IF;
          ELSE
            IF vr_floperac THEN
              /* Financiamento */
              vr_cdhistor := 1544;
            ELSE
              /* Emprestimo */
              vr_cdhistor := 1543;
            END IF;
          END IF;
        
          --Valor Atraso recebe Valor da Mora
          pr_vlatraso := vr_vlmrapar;
          --Historico Atraso
          pr_cdhisatr := vr_cdhistor;
          --Lote Atraso
          pr_loteatra := vr_nrdolote;
          /* Atualizar o valor pago de mora na parcela */
          BEGIN
            UPDATE crappep
               SET crappep.vlpagmra = nvl(crappep.vlpagmra, 0) +
                                      nvl(vr_vlmrapar, 0)
             WHERE crappep.rowid = rw_crappep.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar crappep. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
      
        /* Juros normais */
        IF nvl(vr_vljinpar, 0) > 0
           AND nvl(vr_vlpagpar, 0) > 0 THEN
          IF vr_floperac THEN
            /* Financiamento */
            vr_nrdolote := 600027;
            vr_cdhistor := 1051;
          ELSE
            vr_nrdolote := 600026; /* Emprestimo */
            vr_cdhistor := 1050;
          END IF;
          /* Cria lancamento craplem e atualiza o seu lote */
          pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                                ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                ,pr_cdbccxlt => 100 --Codigo Caixa
                                ,pr_cdoperad => pr_cdoperad --Operador
                                ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                                ,pr_tplotmov => 5 --Tipo movimento
                                ,pr_nrdolote => vr_nrdolote --Numero Lote
                                ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                ,pr_cdhistor => vr_cdhistor --Codigo Historico
                                ,pr_nrctremp => pr_nrctremp --Numero Contrato
                                ,pr_vllanmto => vr_vljinpar --Valor Juros Parcela
                                ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                                ,pr_txjurepr => rw_crapepr.txjuremp --Taxa Juros Emprestimo
                                ,pr_vlpreemp => rw_crappep.vlparepr --Valor Emprestimo
                                ,pr_nrsequni => rw_crappep.nrparepr --Numero Sequencia
                                ,pr_nrparepr => rw_crappep.nrparepr --Numero Parcelas Emprestimo
                                ,pr_flgincre => TRUE --Indicador Credito
                                ,pr_flgcredi => TRUE --Credito
                                ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                ,pr_cdorigem => pr_idorigem
                                ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                ,pr_dscritic => vr_dscritic); --Descricao Erro
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL
             OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        
          /* Atualizar o valor pago dos juros normais na parcela */
          BEGIN
            UPDATE crappep
               SET crappep.vlpagjin = nvl(crappep.vlpagjin, 0) +
                                      nvl(vr_vljinpar, 0)
             WHERE crappep.rowid = rw_crappep.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar crappep. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
      
        /* Lancamento de Valor Pago da Parcela */
        IF nvl(vr_vlpagpar, 0) > 0 THEN
          IF vr_floperac THEN
            /* Financiamento */
            vr_nrdolote := 600013;
          ELSE
            vr_nrdolote := 600012; /* Emprestimo */
          END IF;
        
          -- Condicao para verificar se o pagamento foi feito por aval
          IF pr_nrseqava = 0
             OR pr_nrseqava IS NULL THEN
            IF vr_floperac THEN
              /* Financiamento */
              vr_cdhistor := 1039;
            ELSE
              /* Emprestimo */
              vr_cdhistor := 1044;
            END IF;
          ELSE
            IF vr_floperac THEN
              /* Financiamento */
              vr_cdhistor := 1057;
            ELSE
              /* Emprestimo */
              vr_cdhistor := 1045;
            END IF;
          END IF;
        
          /* Cria lancamento craplem e atualiza o seu lote */
          pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                                ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                ,pr_cdbccxlt => 100 --Codigo Caixa
                                ,pr_cdoperad => pr_cdoperad --Operador
                                ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                                ,pr_tplotmov => 5 --Tipo movimento
                                ,pr_nrdolote => vr_nrdolote --Numero Lote
                                ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                ,pr_cdhistor => vr_cdhistor --Codigo Historico
                                ,pr_nrctremp => pr_nrctremp --Numero Contrato
                                ,pr_vllanmto => vr_vlpagpar --Valor Mora Parcela
                                ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                                ,pr_txjurepr => rw_crapepr.txjuremp --Taxa Juros Emprestimo
                                ,pr_vlpreemp => rw_crappep.vlparepr --Valor Emprestimo
                                ,pr_nrsequni => rw_crappep.nrparepr --Numero Sequencia
                                ,pr_nrparepr => rw_crappep.nrparepr --Numero Parcelas Emprestimo
                                ,pr_flgincre => TRUE --Indicador Credito
                                ,pr_flgcredi => TRUE --Credito
                                ,pr_nrseqava => pr_nrseqava --Pagamento: Sequencia do avalista
                                ,pr_cdorigem => pr_idorigem
                                ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                ,pr_dscritic => vr_dscritic); --Descricao Erro
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL
             OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        
          IF vr_floperac THEN
            /* Financiamento */
            vr_nrdolote := 600015;
          ELSE
            vr_nrdolote := 600014; /* Emprestimo */
          END IF;
        
          -- Condicao para verificar se o pagamento foi feito por aval
          IF pr_nrseqava = 0
             OR pr_nrseqava IS NULL THEN
            vr_cdhistor := 108;
          ELSE
            vr_cdhistor := 1539;
          END IF;
        
          --Historico Pagamento
          pr_cdhispag := vr_cdhistor;
          --Lote Pagamento
          pr_lotepaga := vr_nrdolote;
        
          --Determinar se est� liquidado
          IF apli0001.fn_round(vr_vlatupar, 2) =
             apli0001.fn_round(vr_vlpagpar, 2) THEN
            vr_inliquid := 1;
            --Zerar saldo devedor
            rw_crappep.vlsdvatu := 0;
            --Zerar Juros apos 60
            rw_crappep.vljura60 := 0;
            --Zerar saldo devedor sem juros de inadinplencia
            rw_crappep.vlsdvsji := 0;
          ELSE
            vr_inliquid := 0;
          END IF;
        
          --Valor Multa + Juros
          vr_vlmuljur := nvl(vr_vlmtapar, 0) + nvl(vr_vljinpar, 0) +
                         nvl(vr_vlmrapar, 0);
                         
          /* Atualizar o valor pago na parcela */
          BEGIN
            UPDATE crappep
               SET crappep.dtultpag = pr_dtmvtolt
                  ,crappep.vlpagpar = nvl(crappep.vlpagpar, 0) +
                                      nvl(vr_vlpagpar, 0)
                  ,crappep.vlsdvpar = apli0001.fn_round(vr_vlatupar, 2) -
                                      apli0001.fn_round(vr_vlpagpar, 2)
                  ,crappep.inliquid = vr_inliquid
                  ,crappep.vlsdvsji = (CASE vr_inliquid
                                         WHEN 1 THEN 
                                           rw_crappep.vlsdvsji
                                         ELSE
                                           crappep.vlsdvsji - (apli0001.fn_round(pr_vlpagpar, 2) -
                                      apli0001.fn_round(vr_vlmuljur, 2))
                                       END)                                       
                  ,crappep.vlsdvatu = rw_crappep.vlsdvatu
                  ,crappep.vljura60 = rw_crappep.vljura60
             WHERE crappep.rowid = rw_crappep.rowid
            RETURNING crappep.inliquid INTO rw_crappep.inliquid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar crappep. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
      
        --Se tem Juros no mes
        IF nvl(vr_vljurmes, 0) > 0 THEN
          rw_crapepr.diarefju := vr_diarefju;
          rw_crapepr.mesrefju := vr_mesrefju;
          rw_crapepr.anorefju := vr_anorefju;
        END IF;
      
        --Se a Parcela foi liquidada
        IF rw_crappep.inliquid = 1 THEN
          --Prestacoes Pagas
          vr_qtprepag := nvl(rw_crapepr.qtprepag, 0) + 1;
          --Prestacoes Calculadas
          vr_qtprecal := nvl(rw_crapepr.qtprecal, 0) + 1;
        ELSE
          --Prestacoes Pagas
          vr_qtprepag := nvl(rw_crapepr.qtprepag, 0);
          --Prestacoes Calculadas
          vr_qtprecal := nvl(rw_crapepr.qtprecal, 0);
        END IF;
      
        /* Atualiza o emprestimo */
        BEGIN
          UPDATE crapepr
             SET crapepr.diarefju = rw_crapepr.diarefju
                ,crapepr.mesrefju = rw_crapepr.mesrefju
                ,crapepr.anorefju = rw_crapepr.anorefju
                ,crapepr.dtultpag = pr_dtmvtolt
                ,crapepr.qtprepag = vr_qtprepag
                ,crapepr.vlsdeved = apli0001.fn_round(crapepr.vlsdeved, 10) -
                                    apli0001.fn_round(nvl(vr_vlpagpar, 0)
                                                     ,10) +
                                    apli0001.fn_round(nvl(vr_vljurmes, 0)
                                                     ,10)
                ,crapepr.vljuratu = crapepr.vljuratu +
                                    apli0001.fn_round(nvl(vr_vljurmes, 0)
                                                     ,10)
                ,crapepr.vljuracu = crapepr.vljuracu +
                                    apli0001.fn_round(nvl(vr_vljurmes, 0)
                                                     ,10)
                ,crapepr.qtprecal = vr_qtprecal
           WHERE crapepr.rowid = rw_crapepr.rowid
          RETURNING crapepr.vlsdeved INTO rw_crapepr.vlsdeved;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      
        --Gravar Liquidacao do Emprestimo
        EMPR0001.pc_grava_liquidacao_empr(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                         ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                                         ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                         ,pr_cdbccxlt => 100 --banco/Caixa
                                         ,pr_cdoperad => pr_cdoperad --Operador
                                         ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                                         ,pr_nrdcaixa => pr_nrdcaixa --Codigo Caixa
                                         ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                         ,pr_nrctremp => pr_nrctremp --Numero Contrato
                                         ,pr_nmdatela => pr_nmdatela --Nome da Tela
                                         ,pr_inproces => 0 --Indicador Processo
                                         ,pr_tab_erro => pr_tab_erro --tabela Erros
                                         ,pr_des_reto => vr_des_erro); --Descricao OK/NOK
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
        --Marcar que realizou transacao
        vr_flgtrans := TRUE;
      
      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT sav_trans;
      END;
    
      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
        --Pular LOG
        RAISE vr_exc_desvio;
      END IF;
        
      IF pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;

      -- Retorno OK
      pr_des_reto := 'OK';
    
    EXCEPTION
      WHEN vr_exc_desvio THEN
        NULL;
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_efetiva_pag_atr_parcel_lem ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_efetiva_pag_atr_parcel_lem;

  /* Busca dos pagamentos das parcelas de empr�stimo */
  PROCEDURE pc_efetiva_pagto_atr_parcel(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                       ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                       ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                       ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                       ,pr_idorigem    IN INTEGER --> Id do m�dulo de sistema
                                       ,pr_cdpactra    IN INTEGER --> P.A. da transa��o
                                       ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                       ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para gera��o de log
                                       ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                       ,pr_nrparepr    IN INTEGER --> N�mero parcelas empr�stimo
                                       ,pr_vlpagpar    IN NUMBER --> Valor a pagar parcela
                                       ,pr_tab_crawepr IN EMPR0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                       ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                       ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_efetiva_pag_atr_parcel                 Antigo: b1wgen0084a.p/efetiva_pagamento_atrasado_parcela
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 28/02/2014
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para efetivar pagamento parcela atrasada
    
       Alteracoes: 28/02/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
    ............................................................................. */
  
    DECLARE
    
      --Variaveis Locais
      vr_vlrmulta NUMBER;
      vr_vlatraso NUMBER;
      vr_cdhismul NUMBER;
      vr_cdhisatr NUMBER;
      vr_cdhispag NUMBER;
      vr_loteatra NUMBER;
      vr_lotemult NUMBER;
      vr_lotepaga NUMBER;
      vr_flgtrans BOOLEAN;
      vr_vlpagsld NUMBER;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_exc_ok    EXCEPTION;
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
    
      --Marcar que nao ocorreu transacao
      vr_flgtrans := FALSE;
    
      --Limpar tabela erro
      pr_tab_erro.DELETE;
    
      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Efetiva pagamento atrasado de parcela';
      END IF;
    
      BEGIN
        --Criar savepoint para desfazer transacao
        SAVEPOINT sav_trans;
      
        --Efetivar Pagamento Normal parcela na craplem
        EMPR0001.pc_efetiva_pag_atr_parcel_lem(pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                              ,pr_cdagenci    => pr_cdagenci --> C�digo da ag�ncia
                                              ,pr_nrdcaixa    => pr_nrdcaixa --> N�mero do caixa
                                              ,pr_cdoperad    => pr_cdoperad --> C�digo do Operador
                                              ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                              ,pr_idorigem    => pr_idorigem --> Id do m�dulo de sistema
                                              ,pr_cdpactra    => pr_cdpactra --> P.A. da transa��o
                                              ,pr_nrdconta    => pr_nrdconta --> N�mero da conta
                                              ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                              ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                              ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para gera��o de log
                                              ,pr_nrctremp    => pr_nrctremp --> N�mero do contrato de empr�stimo
                                              ,pr_nrparepr    => pr_nrparepr --> N�mero parcelas empr�stimo
                                              ,pr_vlpagpar    => pr_vlpagpar --> Valor da parcela emprestimo
                                              ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                              ,pr_nrseqava    => pr_nrseqava --Pagamento: Sequencia do avalista
                                              ,pr_vlpagsld    => vr_vlpagsld --> Valor Pago Saldo
                                              ,pr_vlrmulta    => vr_vlrmulta --> Valor Multa
                                              ,pr_vlatraso    => vr_vlatraso --> Valor Atraso
                                              ,pr_cdhismul    => vr_cdhismul --> Historico Multa
                                              ,pr_cdhisatr    => vr_cdhisatr --> Historico Atraso
                                              ,pr_cdhispag    => vr_cdhispag --> Historico Pagamento
                                              ,pr_loteatra    => vr_loteatra --> Lote Atraso
                                              ,pr_lotemult    => vr_lotemult --> Lote Multa
                                              ,pr_lotepaga    => vr_lotepaga --> Lote Pagamento
                                              ,pr_des_reto    => vr_des_erro --> Retorno OK / NOK
                                              ,pr_tab_erro    => pr_tab_erro); --> Tabela com poss�ves erros
      
        --Se Retornou erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        /* Valor da multa */
        IF nvl(vr_vlrmulta, 0) > 0 THEN
          /* Lanca em C/C e atualiza o lote */
          EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                                        ,pr_cdbccxlt => 100 --> N�mero do caixa
                                        ,pr_cdoperad => pr_cdoperad --> C�digo do Operador
                                        ,pr_cdpactra => pr_cdpactra --> P.A. da transa��o
                                        ,pr_nrdolote => vr_lotemult --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta --> N�mero da conta
                                        ,pr_cdhistor => vr_cdhismul --> Codigo historico
                                        ,pr_vllanmto => vr_vlrmulta --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparepr --> N�mero parcelas empr�stimo
                                        ,pr_nrctremp => pr_nrctremp --> N�mero do contrato de empr�stimo
                                        ,pr_nrseqava => pr_nrseqava -- Pagamento: Sequencia do avalista
                                        ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                        ,pr_tab_erro => pr_tab_erro); --> Tabela com poss�ves erros
          --Se Retornou erro
          IF vr_des_erro <> 'OK' THEN
            --Sair
            RAISE vr_exc_ok;
          END IF;
        END IF;
      
        /* Pagamento de juros de mora */
        IF nvl(vr_vlatraso, 0) > 0
           AND nvl(vr_vlpagsld, 0) >= 0 THEN
          /* Debita o pagamento da parcela da C/C */
          EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                                        ,pr_cdbccxlt => 100 --> N�mero do caixa
                                        ,pr_cdoperad => pr_cdoperad --> C�digo do Operador
                                        ,pr_cdpactra => pr_cdpactra --> P.A. da transa��o
                                        ,pr_nrdolote => vr_loteatra --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta --> N�mero da conta
                                        ,pr_cdhistor => vr_cdhisatr --> Codigo historico
                                        ,pr_vllanmto => vr_vlatraso --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparepr --> N�mero parcelas empr�stimo
                                        ,pr_nrctremp => pr_nrctremp --> N�mero do contrato de empr�stimo
                                        ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                        ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                        ,pr_tab_erro => pr_tab_erro); --> Tabela com poss�ves erros
          --Se Retornou erro
          IF vr_des_erro <> 'OK' THEN
            --Sair
            RAISE vr_exc_ok;
          END IF;
        END IF;
      
        /* Lancamento de Valor Pago da Parcela */
        IF nvl(vr_vlpagsld, 0) > 0 THEN
          /* Debita o pagamento da parcela da C/C */
          EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                                        ,pr_cdbccxlt => 100 --> N�mero do caixa
                                        ,pr_cdoperad => pr_cdoperad --> C�digo do Operador
                                        ,pr_cdpactra => pr_cdpactra --> P.A. da transa��o
                                        ,pr_nrdolote => vr_lotepaga --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta --> N�mero da conta
                                        ,pr_cdhistor => vr_cdhispag --> Codigo historico
                                        ,pr_vllanmto => vr_vlpagsld --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparepr --> N�mero parcelas empr�stimo
                                        ,pr_nrctremp => pr_nrctremp --> N�mero do contrato de empr�stimo
                                        ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                        ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                        ,pr_tab_erro => pr_tab_erro); --> Tabela com poss�ves erros
          --Se Retornou erro
          IF vr_des_erro <> 'OK' THEN
            --Sair
            RAISE vr_exc_ok;
          END IF;
          --Marcar transacao como realizada
          vr_flgtrans := TRUE;
        END IF;
      
      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT sav_trans;
        WHEN vr_exc_ok THEN
          NULL;
      END;
    
      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      ELSIF pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Retorno OK
        pr_des_reto := 'OK';
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_efetiva_pagto_atr_parcel ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_efetiva_pagto_atr_parcel;

  /* Efetivar Pagamento Antecipado das parcelas de empr�stimo */
  PROCEDURE pc_efetiva_pagto_antec_lem (pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                       ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                       ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                       ,pr_nmdatela    IN VARCHAR2              --> Nome da tela
                                       ,pr_idorigem    IN INTEGER               --> Id do m�dulo de sistema
                                       ,pr_cdpactra    IN INTEGER               --> P.A. da transa��o
                                       ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                       ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para gera��o de log
                                       ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                       ,pr_nrparepr    IN INTEGER               --> N�mero parcelas empr�stimo
                                       ,pr_vlpagpar    IN NUMBER                --> Valor a pagar parcela
                                       ,pr_tab_crawepr IN EMPR0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                       ,pr_nrseqava    IN NUMBER DEFAULT 0       --> Pagamento: Sequencia do avalista
                                       ,pr_cdhistor    OUT craphis.cdhistor%TYPE --> Historico Pagamento
                                       ,pr_nrdolote    OUT craplot.nrdolote%TYPE --> Numero Lote Pagamento
                                       ,pr_des_reto    OUT VARCHAR               --> Retorno OK / NOK
                                       ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_efetiva_pagto_antec_lem                 Antigo: b1wgen0084a.p/efetiva_pagamento_antecipado_craplem
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Marco/2014                        Ultima atualizacao: 16/10/2015
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para efetivar pagamento antecipado parcela craplem
    
       Alteracoes: 01/04/2015 - Convers�o Progress para Oracle (Alisson - AMcom)
       
                   16/10/2015 - Zerar o campo vlsdvsji quando liquidar a parcela PP (Oscar)             
    
                   17/03/2016 - Limpar campos de saldo ai liquidar crappep SD366229 (Odirlei-AMcom)
    
    ............................................................................. */
  
    DECLARE
    
      --Variaveis Locais
      vr_contador INTEGER;
      vr_vljurmes NUMBER;
      vr_vlatupar NUMBER;
      vr_vldespar NUMBER;
      vr_vlsdvpar NUMBER;
      vr_floperac BOOLEAN;
      vr_flgtrans BOOLEAN;
      vr_diarefju INTEGER;
      vr_mesrefju INTEGER;
      vr_anorefju INTEGER;
      vr_inliquid INTEGER;
      vr_pag_nrdolote INTEGER;
      vr_pag_cdhistor INTEGER;
      vr_des_nrdolote INTEGER;
      vr_des_cdhistor INTEGER;
      vr_lcm_nrdolote INTEGER;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_exc_ok    EXCEPTION;
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
    
      --Marcar que nao ocorreu transacao
      vr_flgtrans := FALSE;
    
      --Limpar tabela erro
      pr_tab_erro.DELETE;
    
      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Efetiva pagamento antecipado de parcela craplem';
      END IF;
    
      --Validar pagamento antecipado da parcela
      EMPR0001.pc_valida_pagto_antec_parc   (pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                            ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                                            ,pr_nrdcaixa => pr_nrdcaixa --> N�mero do caixa
                                            ,pr_cdoperad => pr_cdoperad --> C�digo do Operador
                                            ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                            ,pr_idorigem => pr_idorigem --> Id do m�dulo de sistema
                                            ,pr_nrdconta => pr_nrdconta --> N�mero da conta
                                            ,pr_idseqttl => pr_idseqttl --> Seq titula
                                            ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                            ,pr_flgerlog => pr_flgerlog --> Indicador S/N para gera��o de log
                                            ,pr_nrctremp => pr_nrctremp --> N�mero do contrato de empr�stimo
                                            ,pr_nrparepr => pr_nrparepr --> N�mero parcelas empr�stimo
                                            ,pr_vlpagpar => pr_vlpagpar --> Valor da parcela emprestimo
                                            ,pr_vlatupar => vr_vlatupar--> Valor Atual Parcela
                                            ,pr_vldespar => vr_vldespar --> Valor Desconto Parcela
                                            ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                            ,pr_tab_erro => pr_tab_erro); --> Tabela com poss�ves erros
      --Se Retornou erro
      IF vr_des_erro <> 'OK' THEN
        --Sair
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        --Criar savepoint para desfazer transacao
        SAVEPOINT sav_trans;

        --Selecionar Parcela 
        OPEN cr_crappep(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp
                       ,pr_nrparepr => pr_nrparepr);
        FETCH cr_crappep INTO rw_crappep;
        --Se nao Encontrou
        IF cr_crappep%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crappep;
          --Mensagem Erro
          vr_dscritic:= 'Parcela nao encontrada.';
          --Sair
          RAISE vr_exc_erro;                
        ELSE
          --Fechar Cursor
          CLOSE cr_crappep;                
        END IF;  

        /* Cursor de Emprestimos */
        OPEN cr_crapepr(pr_cdcooper => rw_crappep.cdcooper
                       ,pr_nrdconta => rw_crappep.nrdconta
                       ,pr_nrctremp => rw_crappep.nrctremp);
        FETCH cr_crapepr INTO rw_crapepr;
        --Se nao Encontrou
        IF cr_crapepr%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapepr;
          --Mensagem Erro
          vr_dscritic:= 'Contrato n�o encontrado.';
          --Sair
          RAISE vr_exc_erro;
        ELSE
          --Fechar Cursor
          CLOSE cr_crapepr;
        END IF;  

        /* Cursor de Linha de Credito */
        OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                       ,pr_cdlcremp => rw_crapepr.cdlcremp);
        FETCH cr_craplcr INTO rw_craplcr;
        --Se nao encontrou
        IF cr_craplcr%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_craplcr;
          --Mensagem Erro
          vr_dscritic:= 'Linha Credito n�o encontrada.';
          --Sair
          RAISE vr_exc_erro;
        ELSE
          --Fechar Cursor
          CLOSE cr_craplcr;
          --Operacao
          vr_floperac:= rw_craplcr.dsoperac = 'FINANCIAMENTO';               
        END IF;   
        
        /* Financiamento */
        IF vr_floperac    THEN         
          vr_pag_nrdolote:= 600013;
          vr_des_nrdolote:= 600017;
          vr_des_cdhistor:= 1049;
          vr_lcm_nrdolote:= 600015;
        ELSE  /* Emprestimo */     
          vr_pag_nrdolote:= 600012;
          vr_des_nrdolote:= 600016;
          vr_des_cdhistor:= 1048;
          vr_lcm_nrdolote:= 600014;
        END IF;  
        
        /* Condicao para verificar se o pagamento foi feito por um avalista */
        IF nvl(pr_nrseqava,0) = 0 THEN
          /* Financiamento OU Emprestimo */
          vr_pag_cdhistor:= CASE vr_floperac WHEN TRUE THEN 1039 ELSE 1044 END;
          pr_cdhistor:= 108;
        ELSE
          vr_pag_cdhistor:= CASE vr_floperac WHEN TRUE THEN 1057 ELSE 1045 END;
          pr_cdhistor:= 1539;
        END IF;
        
        --Lancar Juros do Contrato 
        EMPR0001.pc_lanca_juro_contrato(pr_cdcooper    => pr_cdcooper --Codigo Cooperativa
                                       ,pr_cdagenci    => pr_cdagenci --Codigo Agencia
                                       ,pr_nrdcaixa    => pr_nrdcaixa --Codigo Caixa
                                       ,pr_nrdconta    => pr_nrdconta --Numero da Conta
                                       ,pr_nrctremp    => pr_nrctremp --Numero Contrato
                                       ,pr_dtmvtolt    => pr_dtmvtolt --Data Emprestimo
                                       ,pr_cdoperad    => pr_cdoperad --Operador
                                       ,pr_cdpactra    => pr_cdpactra --Posto Atendimento
                                       ,pr_flnormal    => FALSE --Lancamento Normal
                                       ,pr_dtvencto    => NULL --Data vencimento
                                       ,pr_ehmensal    => FALSE --Indicador Mensal
                                       ,pr_dtdpagto    => rw_crapepr.dtdpagto --Data pagamento
                                       ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                       ,pr_cdorigem    => pr_idorigem
                                       ,pr_vljurmes    => vr_vljurmes --Valor Juros no Mes
                                       ,pr_diarefju    => vr_diarefju --Dia Referencia Juros
                                       ,pr_mesrefju    => vr_mesrefju --Mes Referencia Juros
                                       ,pr_anorefju    => vr_anorefju --Ano Referencia Juros
                                       ,pr_des_reto    => vr_des_erro --Retorno OK/NOK
                                       ,pr_tab_erro    => pr_tab_erro); --tabela Erros
      
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          -- Se tem erro
          IF pr_tab_erro.count > 0 THEN
            vr_cdcritic := pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE  
            vr_dscritic := 'Erro na rotina empr0001.pc_lanca_juro_contrato.';  
          END IF;
          --Sair
          RAISE vr_exc_saida;
        END IF;
        
        /* Se pagamento nao eh total */
        IF nvl(pr_vlpagpar,0) <> nvl(vr_vlatupar,0) THEN 
          --Calcular Antecipacao Parcial da Parcela 
          pc_calc_antec_parcel_parci(pr_cdcooper => rw_crappep.cdcooper --> Cooperativa conectada
                                    ,pr_dtvencto => rw_crappep.dtvencto --> Data do vencimento
                                    ,pr_txmensal => rw_crapepr.txmensal --> Taxa aplicada ao empr�stimo
                                    ,pr_dtmvtolt => pr_dtmvtolt         --> Data do movimento atual
                                    ,pr_vlpagpar => pr_vlpagpar         --> Valor devido parcela
                                    ,pr_dtdpagto => rw_crapepr.dtdpagto --> Data de pagamento
                                    ,pr_vldespar => vr_vldespar         --> Valor desconto da parcela
                                    ,pr_des_reto => vr_des_erro         --> Retorno OK / NOK
                                    ,pr_tab_erro => pr_tab_erro);       --> Tabela com poss�ves e
          --Se ocorreu erro
          IF vr_des_erro <> 'OK' THEN
            -- Se tem erro
            IF pr_tab_erro.count > 0 THEN
              vr_cdcritic := pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic;
            ELSE  
              vr_dscritic := 'Erro na rotina empr0001.pc_calc_antec_parcel_parci.';
            END IF;
            --Sair
            RAISE vr_exc_saida;
          END IF;
        END IF;     
        
        /* Lancamento de Desconto da Parcela e atualiza o seu lote */
        pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                              ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                              ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                              ,pr_cdbccxlt => 100         --Codigo Caixa
                              ,pr_cdoperad => pr_cdoperad --Operador
                              ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                              ,pr_tplotmov => 5           --Tipo movimento
                              ,pr_nrdolote => vr_des_nrdolote --Numero Lote
                              ,pr_nrdconta => rw_crappep.nrdconta --Numero da Conta
                              ,pr_cdhistor => vr_des_cdhistor --Codigo Historico
                              ,pr_nrctremp => rw_crappep.nrctremp --Numero Contrato
                              ,pr_vllanmto => vr_vldespar --Valor Lancamento
                              ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                              ,pr_txjurepr => rw_crapepr.txjuremp --Taxa Juros Emprestimo
                              ,pr_vlpreemp => rw_crappep.vlparepr --Valor Emprestimo
                              ,pr_nrsequni => 0           --Numero Sequencia
                              ,pr_nrparepr => rw_crappep.nrparepr --Numero Parcelas Emprestimo
                              ,pr_flgincre => TRUE        --Indicador Credito
                              ,pr_flgcredi => TRUE        --Credito
                              ,pr_nrseqava => 0           --Pagamento: Sequencia do avalista
                              ,pr_cdorigem => pr_idorigem
                              ,pr_cdcritic => vr_cdcritic --Codigo Erro
                              ,pr_dscritic => vr_dscritic); --Descricao Erro
        --Se ocorreu erro
        IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        /* Lancamento de Valor Pago da Parcela e atualiza o seu lote */
        pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                              ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                              ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                              ,pr_cdbccxlt => 100         --Codigo Caixa
                              ,pr_cdoperad => pr_cdoperad --Operador
                              ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                              ,pr_tplotmov => 5           --Tipo movimento
                              ,pr_nrdolote => vr_pag_nrdolote --Numero Lote
                              ,pr_nrdconta => rw_crappep.nrdconta --Numero da Conta
                              ,pr_cdhistor => vr_pag_cdhistor --Codigo Historico
                              ,pr_nrctremp => rw_crappep.nrctremp --Numero Contrato
                              ,pr_vllanmto => pr_vlpagpar --Valor Lancamento
                              ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                              ,pr_txjurepr => rw_crapepr.txjuremp --Taxa Juros Emprestimo
                              ,pr_vlpreemp => rw_crappep.vlparepr --Valor Emprestimo
                              ,pr_nrsequni => rw_crappep.nrparepr --Numero Sequencia
                              ,pr_nrparepr => rw_crappep.nrparepr --Numero Parcelas Emprestimo
                              ,pr_flgincre => TRUE        --Indicador Credito
                              ,pr_flgcredi => TRUE        --Credito
                              ,pr_nrseqava => pr_nrseqava --Pagamento: Sequencia do avalista
                              ,pr_cdorigem => pr_idorigem
                              ,pr_cdcritic => vr_cdcritic --Codigo Erro
                              ,pr_dscritic => vr_dscritic); --Descricao Erro
        --Se ocorreu erro
        IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        /* Verificar valor saldo devedor parcela */
        vr_vlsdvpar:= nvl(rw_crappep.vlsdvpar,0) - (nvl(pr_vlpagpar,0) + nvl(vr_vldespar,0));
        
        /* Verificar se liquidou a parcela */
        vr_inliquid:= CASE nvl(vr_vlsdvpar,0) WHEN 0 THEN 1 ELSE 0 END;
        
        --Se liquidou a parcela
        IF vr_inliquid = 1 THEN
          rw_crappep.vlsdvatu:= 0;
          rw_crappep.vljura60:= 0;
          --Zerar saldo devedor sem juros de inadinplencia
          rw_crappep.vlsdvsji:= 0;
       END IF;
         
        --Atualizar Informacoes Parcelas
        BEGIN
          UPDATE crappep SET crappep.vldespar = nvl(crappep.vldespar,0) + nvl(vr_vldespar,0)
                            ,crappep.dtultpag = pr_dtmvtolt
                            ,crappep.vlpagpar = nvl(crappep.vlpagpar,0) + nvl(pr_vlpagpar,0)
                            ,crappep.vlsdvpar = vr_vlsdvpar
                            ,crappep.vlsdvsji = (CASE vr_inliquid 
                                                   WHEN 1 THEN
                                                     rw_crappep.vlsdvsji
                                                   ELSE
                                                     nvl(crappep.vlsdvsji,0) - (nvl(pr_vlpagpar,0) + nvl(vr_vldespar,0)) 
                                                 END)    
                            ,crappep.inliquid = vr_inliquid
                            ,crappep.vlsdvatu = rw_crappep.vlsdvatu
                            ,crappep.vljura60 = rw_crappep.vljura60
          WHERE crappep.ROWID = rw_crappep.ROWID
          RETURNING crappep.inliquid INTO rw_crappep.inliquid;    
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crappep.'||sqlerrm;
            --Sair
            RAISE vr_exc_saida;  
        END;      
        
        --Juros no Mes
        IF nvl(vr_vljurmes,0) > 0 THEN
          --Usada para Atualizar a tabela posteriormente
          rw_crapepr.diarefju:= vr_diarefju;
          rw_crapepr.mesrefju:= vr_mesrefju;
          rw_crapepr.anorefju:= vr_anorefju;
        END IF;
         
        /* Atualiza o emprestimo */
        BEGIN
          UPDATE crapepr SET crapepr.dtultpag = pr_dtmvtolt
                            ,crapepr.qtprepag = nvl(crapepr.qtprepag,0) + nvl(rw_crappep.inliquid,0) 
                            ,crapepr.qtprecal = nvl(crapepr.qtprecal,0) + nvl(rw_crappep.inliquid,0)
                            ,crapepr.vlsdeved = nvl(crapepr.vlsdeved,0) + nvl(vr_vljurmes,0) - nvl(pr_vlpagpar,0)
                            ,crapepr.vljuratu = nvl(crapepr.vljuratu,0) + nvl(vr_vljurmes,0)
                            ,crapepr.vljuracu = nvl(crapepr.vljuracu,0) + nvl(vr_vljurmes,0)
                            ,crapepr.diarefju = rw_crapepr.diarefju
                            ,crapepr.mesrefju = rw_crapepr.mesrefju
                            ,crapepr.anorefju = rw_crapepr.anorefju
          WHERE crapepr.ROWID = rw_crapepr.ROWID;                  
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crapepr.'||sqlerrm;
            --Sair
            RAISE vr_exc_saida;  
        END;      
        
        --Retornar o Lote
        pr_nrdolote:= vr_lcm_nrdolote;
        
        /* Deletar avisos de Debito */
        BEGIN
          DELETE crapavs 
          WHERE crapavs.cdcooper = pr_cdcooper   
          AND   crapavs.nrdconta = pr_nrdconta   
          AND   crapavs.nrdocmto = pr_nrctremp   
          AND   crapavs.nrparepr = pr_nrparepr;  
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir crapavs.'||sqlerrm;
            --Sair
            RAISE vr_exc_saida;  
        END;      
        
        /* Verifica e efetua se necessario a liquidacao */
        --Gravar Liquidacao do Emprestimo
        EMPR0001.pc_grava_liquidacao_empr(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                         ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                                         ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                         ,pr_cdbccxlt => 100         --banco/Caixa
                                         ,pr_cdoperad => pr_cdoperad --Operador
                                         ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                                         ,pr_nrdcaixa => pr_nrdcaixa --Codigo Caixa
                                         ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                         ,pr_nrctremp => pr_nrctremp --Numero Contrato
                                         ,pr_nmdatela => pr_nmdatela --Nome da Tela
                                         ,pr_inproces => 0           --Indicador Processo
                                         ,pr_tab_erro => pr_tab_erro --tabela Erros
                                         ,pr_des_reto => vr_des_erro); --Descricao OK/NOK
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
        
        --Marcar Transacao
        vr_flgtrans:= TRUE;   
      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT sav_trans;
      END;
    
      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
        --Pular Escrever no LOG
        RAISE vr_exc_ok;
      END IF;
      
      --Escrever no LOG
      IF pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;

      -- Retorno OK
      pr_des_reto := 'OK';
    
    EXCEPTION
      WHEN vr_exc_ok THEN
        NULL;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_efetiva_pagto_antec_lem ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_efetiva_pagto_antec_lem;
  
  /* Verifica se tem uma parcela anterior nao liquida e ja vencida  */
  PROCEDURE pc_verifica_parcel_anteriores(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                         ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                         ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                         ,pr_nrparepr IN INTEGER --> N�mero parcelas empr�stimo
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                         ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                         ,pr_dscritic OUT VARCHAR2) IS --> Descricao Erro
  BEGIN
    /* .............................................................................
    
       Programa: pc_verifica_parcel_anteriores                 Antigo: b1wgen0084a.p/verifica_parcelas_anteriores
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 27/02/2014
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para verificar se tem uma parcela anterior nao liquida e ja vencida
    
       Alteracoes: 27/02/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
    ............................................................................. */
  
    DECLARE
      --Cursores Locais
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE
                       ,pr_nrparepr IN crappep.nrparepr%TYPE
                       ,pr_inliquid IN crappep.inliquid%TYPE
                       ,pr_dtvencto IN crappep.dtvencto%TYPE) IS
        SELECT crappep.cdcooper
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
               AND crappep.nrdconta = pr_nrdconta
               AND crappep.nrctremp = pr_nrctremp
               AND crappep.nrparepr < pr_nrparepr
               AND crappep.inliquid = pr_inliquid
               AND crappep.dtvencto < pr_dtvencto;
      rw_crappep cr_crappep%ROWTYPE;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
      pr_dscritic := NULL;
    
      /* Verifica se tem uma parcela anterior nao liquida e ja vencida */
      OPEN cr_crappep(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nrparepr => pr_nrparepr
                     ,pr_inliquid => 0
                     ,pr_dtvencto => pr_dtmvtolt);
      FETCH cr_crappep
        INTO rw_crappep;
      --Se encontrou
      IF cr_crappep%FOUND THEN
        --Retornar Mensagem erro
        pr_dscritic := 'Efetuar primeiro o pagamento da parcela em atraso';
        --Retornar Erro
        pr_des_reto := 'NOK';
      END IF;
      --Fechar Cursor
      CLOSE cr_crappep;
    
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        pr_dscritic := 'Erro n�o tratado na EMPR0001.pc_verifica_parcel_anteriores ' ||
                       sqlerrm;
    END;
  END pc_verifica_parcel_anteriores;

  /* Valida o pagamento normal da parcela */
  PROCEDURE pc_valida_pagto_normal_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                          ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                          ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                          ,pr_cdoperad IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                          ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                          ,pr_idorigem IN INTEGER --> Id do m�dulo de sistema
                                          ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                          ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                          ,pr_flgerlog IN VARCHAR2 --> Indicador S/N para gera��o de log
                                          ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                          ,pr_nrparepr IN INTEGER --> N�mero parcelas empr�stimo
                                          ,pr_vlpagpar IN NUMBER --> Valor a pagar da parcela
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro --> Tabela com poss�ves erros
                                          ,pr_des_reto OUT VARCHAR) IS --> Retorno OK / NOK
  
  BEGIN
    /* .............................................................................
     Programa: pc_valida_pagto_normal_parcela          Antigo: b1wgen0084a.p/valida_pagamento_normal_parcela
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : James Prust Junior
     Data    : Maio/2014                        Ultima atualizacao: 13/05/2014
    
     Dados referentes ao programa:
    
     Frequencia: Diaria - Sempre que for chamada
     Objetivo  : Rotina para validar o pagamento da parcela normal
    
     Alteracoes: 13/05/2014 - Convers�o Progress para Oracle (James)
    ............................................................................. */
    DECLARE
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE
                       ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
        SELECT vlsdvpar
          FROM crappep
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = pr_nrctremp
               AND nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
    
      -- Variaveis
      vr_flgtrans BOOLEAN;
      vr_dsorigem VARCHAR2(100);
      vr_dstransa VARCHAR2(100);
    
      -- Variaveis Erro
      vr_exc_saida EXCEPTION;
    
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_nrdrowid ROWID;
    
    BEGIN
      vr_flgtrans := FALSE;
      pr_des_reto := 'OK';
    
      --Limpar tabela erro
      pr_tab_erro.DELETE;
    
      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Valida pagamento normal de parcela';
      END IF;
    
      BEGIN
        -- Busca dos dados da parcela
        OPEN cr_crappep(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp
                       ,pr_nrparepr => pr_nrparepr);
        FETCH cr_crappep
          INTO rw_crappep;
        -- Se n�o encontrar
        IF cr_crappep%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crappep;
          -- MOntar descri��o de erro
          vr_cdcritic := 0;
          vr_dscritic := 'Parcela nao encontrada.';
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor e continuar
          CLOSE cr_crappep;
        END IF;
      
        -- Valida se o valor de pagamento eh maior que 0.
        IF nvl(pr_vlpagpar, 0) = 0 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Valor de pagamento nao informado.';
          RAISE vr_exc_saida;
        END IF;
      
        -- Verifica se o valor informado para pagamento eh maior que o valor da parcela
        IF pr_vlpagpar > rw_crappep.vlsdvpar THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Valor informado para pagamento maior que valor da parcela';
          RAISE vr_exc_saida;
        END IF;
      
        vr_flgtrans := TRUE;
      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_des_reto := 'NOK';
          IF pr_tab_erro.COUNT = 0 THEN
            -- Gerar rotina de grava��o de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 --> Fixo
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
          END IF;
      END;
    
      --Se nao ocorreu a transacao
      IF vr_flgtrans
         AND pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_valida_pagamento_normal_parcela ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  
  END pc_valida_pagto_normal_parcela;

  /* Efetivar o pagamento da parcela na craplem  */
  PROCEDURE pc_efetiva_pagto_parc_lem(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                     ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                     ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                     ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                     ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                     ,pr_idorigem    IN INTEGER --> Id do m�dulo de sistema
                                     ,pr_cdpactra    IN INTEGER --> P.A. da transa��o
                                     ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                     ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                     ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                     ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para gera��o de log
                                     ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                     ,pr_nrparepr    IN INTEGER --> N�mero parcelas empr�stimo
                                     ,pr_vlparepr    IN NUMBER --> Valor da parcela emprestimo
                                     ,pr_tab_crawepr IN EMPR0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                     ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                     ,pr_cdhistor    OUT craphis.cdhistor%TYPE --> Codigo historico
                                     ,pr_nrdolote    OUT craplot.nrdolote%TYPE --> Numero do Lote
                                     ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                     ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_efetiva_pagto_parc_lem                 Antigo: b1wgen0084a.p/efetiva_pagamento_normal_parcela_craplem
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 16/10/2015
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetivar o pagamento da parcela
    
       Alteracoes: 28/02/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
                   13/05/2014 - Ajuste para chamar a procedure
                                "pc_valida_pagamento_normal_parcela". (James)

                   16/10/2015 - Zerar o campo vlsdvsji quando liquidar a parcela PP (Oscar)                          
    ............................................................................. */
  
    DECLARE
    
      --Variaveis Locais
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_vljurmes NUMBER;
      vr_cdhistor INTEGER;
      vr_flgtrans BOOLEAN;
      vr_floperac BOOLEAN;
      vr_diarefju INTEGER;
      vr_mesrefju INTEGER;
      vr_anorefju INTEGER;
      vr_nrdolote INTEGER;
      vr_dtcalcul DATE;
      vr_ehmensal BOOLEAN;
    
      --ROWID das tabelas
      vr_nrdrowid ROWID;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_des_erro VARCHAR2(3);
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
      --Marcar que nao ocorreu transacao
      vr_flgtrans := FALSE;
    
      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Efetiva pagamento normal de parcela craplem';
      END IF;
    
      BEGIN
      
        --Criar savepoint para desfazer transacao
        SAVEPOINT sav_trans;
      
        -- Procedure para validar se a parcela esta OK.
        EMPR0001.pc_valida_pagto_normal_parcela(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa
                                               ,pr_cdagenci => pr_cdagenci -- Codigo Agencia
                                               ,pr_nrdcaixa => pr_nrdcaixa -- Codigo Caixa
                                               ,pr_cdoperad => pr_cdoperad -- Operador
                                               ,pr_nmdatela => pr_nmdatela -- Nome da Tela
                                               ,pr_idorigem => pr_idorigem -- Origem
                                               ,pr_nrdconta => pr_nrdconta -- Numero da Conta
                                               ,pr_idseqttl => pr_idseqttl -- Seq Titular
                                               ,pr_dtmvtolt => pr_dtmvtolt -- Data Emprestimo
                                               ,pr_flgerlog => pr_flgerlog -- Indicador S/N para gera��o de log
                                               ,pr_nrctremp => pr_nrctremp -- Numero Contrato
                                               ,pr_nrparepr => pr_nrparepr -- Numero da parcela
                                               ,pr_vlpagpar => pr_vlparepr -- Valor da parcela emprestimo
                                               ,pr_tab_erro => pr_tab_erro -- tabela Erros
                                               ,pr_des_reto => vr_des_erro); -- OK/NOK
      
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        --Buscar registro da parcela
        OPEN cr_crappep(pr_cdcooper => pr_cdcooper --> Cooperativa
                       ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                       ,pr_nrctremp => pr_nrctremp --> Numero Contrato
                       ,pr_nrparepr => pr_nrparepr); --> Numero da parcela
        FETCH cr_crappep
          INTO rw_crappep;
        --Se nao Encontrou
        IF cr_crappep%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crappep;
          vr_cdcritic := 55;
          RAISE vr_exc_saida;
        END IF;
        --Fechar Cursor
        CLOSE cr_crappep;
      
        --Buscar registro emprestimo
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper --> Cooperativa
                       ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                       ,pr_nrctremp => pr_nrctremp); --> Numero Contrato
        FETCH cr_crapepr
          INTO rw_crapepr;
        --Se nao Encontrou
        IF cr_crapepr%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapepr;
          vr_cdcritic := 55;
          RAISE vr_exc_saida;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapepr;
      
        --Selecionar Linha Credito
        OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                       ,pr_cdlcremp => rw_crapepr.cdlcremp);
        FETCH cr_craplcr
          INTO rw_craplcr;
        --Se nao Encontrou
        IF cr_craplcr%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_craplcr;
          vr_cdcritic := 363;
          --Sair
          RAISE vr_exc_saida;
        ELSE
          --Determinar se a Operacao � financiamento
          vr_floperac := rw_craplcr.dsoperac = 'FINANCIAMENTO';
        END IF;
        --Fechar Cursor
        CLOSE cr_craplcr;
      
        --Determinar O Lote
        IF vr_floperac THEN
          /* Financiamento */
          vr_nrdolote := 600013;
        ELSE
          vr_nrdolote := 600012; /* Emprestimo */
        END IF;
      
        -- Condicao para verificar se o pagamento foi feito por um avalista
        IF pr_nrseqava = 0
           OR pr_nrseqava IS NULL THEN
          IF vr_floperac THEN
            vr_cdhistor := 1039;
          ELSE
            vr_cdhistor := 1044;
          END IF;
        ELSE
          IF vr_floperac THEN
            vr_cdhistor := 1057;
          ELSE
            vr_cdhistor := 1045;
          END IF;
        END IF;
      
        -- Ultimo dia Util do Ano
        vr_dtcalcul := GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                  ,pr_dtmvtolt  => last_day(rw_crappep.dtvencto)
                                                  ,pr_tipo      => 'A'
                                                  ,pr_excultdia => TRUE);
        --Determinar se eh mensal
        vr_ehmensal := rw_crappep.dtvencto > vr_dtcalcul;
      
        --Se For mensal
        IF vr_ehmensal THEN
          BEGIN
            --Atualizar Saldo Devedor Emprestimo
            UPDATE crapepr
               SET crapepr.vlsdeved = crapepr.vlsdeved - pr_vlparepr
             WHERE crapepr.ROWID = rw_crapepr.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              --Mensagem erro
              vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
      
        --Lancar Juro Contrato
        EMPR0001.pc_lanca_juro_contrato(pr_cdcooper    => pr_cdcooper --Codigo Cooperativa
                                       ,pr_cdagenci    => pr_cdagenci --Codigo Agencia
                                       ,pr_nrdcaixa    => pr_nrdcaixa --Codigo Caixa
                                       ,pr_nrdconta    => pr_nrdconta --Numero da Conta
                                       ,pr_nrctremp    => pr_nrctremp --Numero Contrato
                                       ,pr_dtmvtolt    => pr_dtmvtolt --Data Emprestimo
                                       ,pr_cdoperad    => pr_cdoperad --Operador
                                       ,pr_cdpactra    => pr_cdpactra --Posto Atendimento
                                       ,pr_flnormal    => TRUE --Lancamento Normal
                                       ,pr_dtvencto    => rw_crappep.dtvencto --Data vencimento
                                       ,pr_ehmensal    => vr_ehmensal --Indicador Mensal
                                       ,pr_dtdpagto    => rw_crapepr.dtdpagto --Data pagamento
                                       ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                       ,pr_cdorigem    => pr_idorigem
                                       ,pr_vljurmes    => vr_vljurmes --Valor Juros no Mes
                                       ,pr_diarefju    => vr_diarefju --Dia Referencia Juros
                                       ,pr_mesrefju    => vr_mesrefju --Mes Referencia Juros
                                       ,pr_anorefju    => vr_anorefju --Ano Referencia Juros
                                       ,pr_tab_erro    => pr_tab_erro --tabela Erros
                                       ,pr_des_reto    => vr_des_erro); --OK/NOK
      
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        /* Cria lancamento craplem e atualiza o seu lote */
        pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                              ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                              ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                              ,pr_cdbccxlt => 100 --Codigo Caixa
                              ,pr_cdoperad => pr_cdoperad --Operador
                              ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                              ,pr_tplotmov => 5 --Tipo movimento
                              ,pr_nrdolote => vr_nrdolote --Numero Lote
                              ,pr_nrdconta => rw_crappep.nrdconta --Numero da Conta
                              ,pr_cdhistor => vr_cdhistor --Codigo Historico
                              ,pr_nrctremp => rw_crappep.nrctremp --Numero Contrato
                              ,pr_vllanmto => pr_vlparepr --Valor Lancamento
                              ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                              ,pr_txjurepr => rw_crapepr.txjuremp --Taxa Juros Emprestimo
                              ,pr_vlpreemp => rw_crappep.vlparepr --Valor Emprestimo
                              ,pr_nrsequni => rw_crappep.nrparepr --Numero Sequencia
                              ,pr_nrparepr => rw_crappep.nrparepr --Numero Parcelas Emprestimo
                              ,pr_flgincre => TRUE --Indicador Credito
                              ,pr_flgcredi => TRUE --Credito
                              ,pr_nrseqava => pr_nrseqava --Pagamento: Sequencia do avalista
                              ,pr_cdorigem => pr_idorigem
                              ,pr_cdcritic => vr_cdcritic --Codigo Erro
                              ,pr_dscritic => vr_dscritic); --Descricao Erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL
           OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
        --Atualizar valores para Update
        rw_crappep.dtultpag := pr_dtmvtolt;
        rw_crappep.vlpagpar := nvl(rw_crappep.vlpagpar, 0) +
                               nvl(pr_vlparepr, 0);
        rw_crappep.vlsdvpar := nvl(rw_crappep.vlsdvpar, 0) -
                               nvl(pr_vlparepr, 0);
        rw_crappep.vlsdvsji := nvl(rw_crappep.vlsdvsji, 0) -
                               nvl(pr_vlparepr, 0);
      
        --Valor Saldo Parcela
        IF rw_crappep.vlsdvpar = 0 THEN
          rw_crappep.inliquid := 1;
          --Zerar Saldo e Juros
          rw_crappep.vlsdvatu := 0;
          rw_crappep.vljura60 := 0;
          --Zerar saldo devedor sem juros de inadinplencia
          rw_crappep.vlsdvsji := 0;
        ELSE
          rw_crappep.inliquid := 0;
        END IF;
        --Atualizar parcela Emprestimo
        BEGIN
          UPDATE crappep
             SET crappep.dtultpag = rw_crappep.dtultpag
                ,crappep.vlpagpar = rw_crappep.vlpagpar
                ,crappep.vlsdvpar = rw_crappep.vlsdvpar
                ,crappep.vlsdvsji = rw_crappep.vlsdvsji
                ,crappep.inliquid = rw_crappep.inliquid
                ,crappep.vlsdvatu = rw_crappep.vlsdvatu
                ,crappep.vljura60 = rw_crappep.vljura60
           WHERE crappep.rowid = rw_crappep.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            --Mensagem erro
            vr_dscritic := 'Erro ao atualizar crappep. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      
        --Valor dos Juros no Mes
        IF nvl(vr_vljurmes, 0) > 0 THEN
          rw_crapepr.diarefju := vr_diarefju;
          rw_crapepr.mesrefju := vr_mesrefju;
          rw_crapepr.anorefju := vr_anorefju;
        END IF;
        --Se a parcela est� liquidada
        IF rw_crappep.inliquid = 1 THEN
          --Incrementar Prestacoes Pagas
          rw_crapepr.qtprepag := rw_crapepr.qtprepag + 1;
          --Incrementar Prestacoes Calculadas
          rw_crapepr.qtprecal := rw_crapepr.qtprecal + 1;
        END IF;
        --Data Vencimento Maior Ultimo dia util ano
        IF rw_crappep.dtvencto > vr_dtcalcul THEN
          --Atualizar saldo devedor com os juros
          rw_crapepr.vlsdeved := nvl(rw_crapepr.vlsdeved, 0) +
                                 nvl(vr_vljurmes, 0);
        ELSE
          --Diminuir valor parcela e somar juros
          rw_crapepr.vlsdeved := nvl(rw_crapepr.vlsdeved, 0) -
                                 nvl(pr_vlparepr, 0) + nvl(vr_vljurmes, 0);
        END IF;
        --Valor Juros Atual
        rw_crapepr.vljuratu := nvl(rw_crapepr.vljuratu, 0) +
                               nvl(vr_vljurmes, 0);
        --Valor Juros Acumulados
        rw_crapepr.vljuracu := nvl(rw_crapepr.vljuracu, 0) +
                               nvl(vr_vljurmes, 0);
      
        --Atualizar Emprestimo
        BEGIN
          UPDATE crapepr
             SET crapepr.diarefju = rw_crapepr.diarefju
                ,crapepr.mesrefju = rw_crapepr.mesrefju
                ,crapepr.anorefju = rw_crapepr.anorefju
                ,crapepr.dtultpag = pr_dtmvtolt
                ,crapepr.qtprepag = rw_crapepr.qtprepag
                ,crapepr.vlsdeved = rw_crapepr.vlsdeved
                ,crapepr.vljuratu = rw_crapepr.vljuratu
                ,crapepr.vljuracu = rw_crapepr.vljuracu
                ,crapepr.qtprecal = rw_crapepr.qtprecal
           WHERE crapepr.rowid = rw_crapepr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            --Mensagem erro
            vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      
        --Se for Financiamento
        IF vr_floperac THEN
          vr_nrdolote := 600015;
        ELSE
          vr_nrdolote := 600014;
        END IF;
        --Retornar numero do lote
        pr_nrdolote := vr_nrdolote;
        -- Condicao para verificar se o pagamento foi feito por um avalista
        IF pr_nrseqava = 0
           OR pr_nrseqava IS NULL THEN
          pr_cdhistor := 108;
        ELSE
          pr_cdhistor := 1539;
        END IF;
      
        /* Verifica e efetua se necessario a liquidacao */
        EMPR0001.pc_grava_liquidacao_empr(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                         ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                                         ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                         ,pr_cdbccxlt => 100 	--banco/Caixa
                                         ,pr_cdoperad => pr_cdoperad --Operador
                                         ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                                         ,pr_nrdcaixa => pr_nrdcaixa --Codigo Caixa
                                         ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                         ,pr_nrctremp => pr_nrctremp --Numero Contrato
                                         ,pr_nmdatela => pr_nmdatela --Nome da Tela
                                         ,pr_inproces => 0 --Indicador Processo
                                         ,pr_tab_erro => pr_tab_erro --tabela Erros
                                         ,pr_des_reto => vr_des_erro); --Descricao OK/NOK
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        --Marcar que ocorreu transacao
        vr_flgtrans := TRUE;
      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT sav_trans;
      END;
    
      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      ELSIF pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Retorno OK
        pr_des_reto := 'OK';
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_efetiva_pagto_parc_lem ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_efetiva_pagto_parc_lem;

  /* Efetivar o pagamento da parcela  */
  PROCEDURE pc_efetiva_pagto_parcela(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                    ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                    ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                    ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                    ,pr_idorigem    IN INTEGER --> Id do m�dulo de sistema
                                    ,pr_cdpactra    IN INTEGER --> P.A. da transa��o
                                    ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                    ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                    ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                    ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para gera��o de log
                                    ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                    ,pr_nrparepr    IN INTEGER --> N�mero parcelas empr�stimo
                                    ,pr_vlparepr    IN NUMBER --> Valor da parcela emprestimo
                                    ,pr_tab_crawepr IN EMPR0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                    ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                    ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_efetiva_pagto_parcela                 Antigo: b1wgen0084a.p/efetiva_pagamento_normal_parcela
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 27/02/2014
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetivar o pagamento da parcela
    
       Alteracoes: 28/02/2014 - Convers�o Progress para Oracle (Alisson - AMcom)
    
    ............................................................................. */
  
    DECLARE
    
      --Variaveis Locais
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      vr_flgtrans BOOLEAN;
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_nrdolote craplot.nrdolote%TYPE;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_des_erro VARCHAR2(3);
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
      --Marcar que nao ocorreu transacao
      vr_flgtrans := FALSE;
    
      --Limpar tabela erro
      pr_tab_erro.DELETE;
    
      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Efetiva pagamento normal de parcela';
      END IF;
    
      BEGIN
        --Criar savepoint para desfazer transacao
        SAVEPOINT sav_trans;
        --Efetivar Pagamento Normal parcela na craplem
        EMPR0001.pc_efetiva_pagto_parc_lem(pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                          ,pr_cdagenci    => pr_cdagenci --> C�digo da ag�ncia
                                          ,pr_nrdcaixa    => pr_nrdcaixa --> N�mero do caixa
                                          ,pr_cdoperad    => pr_cdoperad --> C�digo do Operador
                                          ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                          ,pr_idorigem    => pr_idorigem --> Id do m�dulo de sistema
                                          ,pr_cdpactra    => pr_cdpactra --> P.A. da transa��o
                                          ,pr_nrdconta    => pr_nrdconta --> N�mero da conta
                                          ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                          ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                          ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para gera��o de log
                                          ,pr_nrctremp    => pr_nrctremp --> N�mero do contrato de empr�stimo
                                          ,pr_nrparepr    => pr_nrparepr --> N�mero parcelas empr�stimo
                                          ,pr_vlparepr    => pr_vlparepr --> Valor da parcela emprestimo
                                          ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                          ,pr_nrseqava    => pr_nrseqava --> Pagamento: Sequencia do avalista
                                          ,pr_cdhistor    => vr_cdhistor --> Codigo historico
                                          ,pr_nrdolote    => vr_nrdolote --> Numero do Lote
                                          ,pr_des_reto    => vr_des_erro --> Retorno OK / NOK
                                          ,pr_tab_erro    => pr_tab_erro); --> Tabela com poss�ves erros
        --Se Retornou erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        /* Lanca em C/C e atualiza o lote */
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                                      ,pr_cdbccxlt => 100 --> N�mero do caixa
                                      ,pr_cdoperad => pr_cdoperad --> C�digo do Operador
                                      ,pr_cdpactra => pr_cdpactra --> P.A. da transa��o
                                      ,pr_nrdolote => vr_nrdolote --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta --> N�mero da conta
                                      ,pr_cdhistor => vr_cdhistor --> Codigo historico
                                      ,pr_vllanmto => pr_vlparepr --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparepr --> N�mero parcelas empr�stimo
                                      ,pr_nrctremp => pr_nrctremp --> N�mero do contrato de empr�stimo
                                      ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                      ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                      ,pr_tab_erro => pr_tab_erro); --> Tabela com poss�ves erros
        --Se Retornou erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        --Marcar que ocorreu transacao
        vr_flgtrans := TRUE;
      
      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT sav_trans;
      END;
    
      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      ELSIF pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Retorno OK
        pr_des_reto := 'OK';
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_efetiva_pagto_parcela ' ||
                       sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_efetiva_pagto_parcela;

  -- Rotina para consultar antecipa��o parcelas emprestimo
  PROCEDURE pc_consulta_antecipacao(pr_nrdconta IN crapass.nrdconta%TYPE --> Codigo do Produto
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Codigo do Produto
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_consulta_antecipacao
    Sistema :
    Sigla   :
    Autor   : Daniel Zimmermann
    Data    : Junho/14.                    Ultima atualizacao: 27/06/2014
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para consultar antecipa��o parcelas emprestimo.
    Observacao: -----
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      vr_contador INTEGER := 0;
    
      -- Buscar emprestimos e suas parcelas
      CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
        SELECT lem.nrparepr
              ,lem.dtpagemp
              ,lem.vllanmto
              ,pep.dtvencto
          FROM craplem lem
              ,crappep pep
         WHERE lem.cdcooper = pr_cdcooper
               AND lem.nrdconta = pr_nrdconta
               AND lem.nrctremp = pr_nrctremp
               AND lem.cdhistor IN (1044
                                   , -- PG. EMPR. C/C
                                    1039
                                   , -- PG.FINANC.C/C
                                    1057
                                   , -- PG.AVAL.FINA
                                    1045) -- PG.AVAL.EMPR.
               AND lem.dtmvtolt < pep.dtvencto
               AND pep.cdcooper = lem.cdcooper
               AND pep.nrdconta = lem.nrdconta
               AND pep.nrctremp = lem.nrctremp
               AND pep.nrparepr = lem.nrparepr
         ORDER BY lem.dtpagemp DESC
                 ,pep.dtvencto
                 ,lem.nrctremp;
      rw_craplem cr_craplem%ROWTYPE; -- Verificar
    
      -- variaveis com as informa��es recebidas via xml
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
    
    BEGIN
    
      -- Extrair informa��es do xml recebido por parametro
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
    
      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
      --Busca parcelas antecipadas
      FOR rw_craplem IN cr_craplem(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp) LOOP
        -- incluir tags com as informa��es das parcelas
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'parcela'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nrparepr'
                              ,pr_tag_cont => rw_craplem.nrparepr
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vllanmto'
                              ,pr_tag_cont => rw_craplem.vllanmto
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dtvencto'
                              ,pr_tag_cont => to_char(rw_craplem.dtvencto
                                                     ,'DD/MM/RRRR')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dtpagemp'
                              ,pr_tag_cont => to_char(rw_craplem.dtpagemp
                                                     ,'DD/MM/RRRR')
                              ,pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      
      END LOOP;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                       pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Produtos: ' || SQLERRM;
      
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                       pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  
  END pc_consulta_antecipacao;

  -- Rotina para gerar impressao parcelas antecipadas crrl684
  PROCEDURE pc_imprimir_antecipacao(pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Produto
                                   ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Codigo do Produto
                                   ,pr_qtdregis  IN NUMBER --> Quantidade de registro no relatorio
                                   ,pr_lstdtpgto IN VARCHAR2 --> Lista com as datas de pagto dos registros
                                   ,pr_lstdtvcto IN VARCHAR2 --> Lista com as datas do vencimento dos registros
                                   ,pr_lstparepr IN VARCHAR2 --> Lista com as parcelas de empr dos registros
                                   ,pr_lstvlrpag IN VARCHAR2 --> Lista com valores pgto dos registros
                                   ,pr_xmllog    IN VARCHAR2 --> XML com informa��es de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER --> C�digo da cr�tica
                                   ,pr_dscritic  OUT VARCHAR2 --> Descri��o da cr�tica
                                   ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_imprimir_antecipacao
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimmermann
    Data    : Maio/14.                    Ultima atualizacao: 13/08/2015
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para gerar impressao parcelas antecipadas crrl684.
    Observacao: -----
    
    Alteracoes: 13/08/2015 - Incluida valida��o para os hist�ricos 100,800,900 e 850. 
		                        (Reinert)
    ..............................................................................*/
    DECLARE
    
      -- Buscar dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper NUMBER) IS
        SELECT t.nmrescop FROM crapcop t WHERE t.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
    
      -- Buscar dados dos associados
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.nrdconta
              ,SUBSTR(ass.nmprimtl, 1, 40) nmprimtl
              ,ass.cdagenci
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
               AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
    
      -- Busca dados do operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT TRIM(ope.nmoperad) nmoperad
          FROM crapope ope
         WHERE ope.cdcooper = pr_cdcooper
           AND UPPER(ope.cdoperad) = UPPER(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;
    
      vr_xml       CLOB; --> CLOB com conteudo do XML do relat�rio
      vr_xmlbuffer VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
      vr_strbuffer VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
    
      -- Variaveis extraidas do xml pr_retxml
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
    
      -- Variaveis para a geracao do relatorio
      vr_nom_direto VARCHAR2(500);
      vr_nmarqimp   VARCHAR2(100);
      -- contador de controle
      vr_auxqtd NUMBER;
      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
      -- variaveis para extrair os valores das listas recebidas como parametro
      vr_nrparepr VARCHAR2(100);
      vr_dtvencto VARCHAR2(100);
      vr_dtpagemp VARCHAR2(100);
      vr_vllanmto NUMBER;
    
      -- Vari�vel de cr�ticas
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(10000);
      vr_des_reto  VARCHAR2(10);
      vr_typ_saida VARCHAR2(3);
      vr_tab_erro  gene0001.typ_tab_erro;
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
    BEGIN
    
      vr_auxqtd := 0;
      -- extrair informa��es do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
    
      -- Verifica se algum registro foi selecionado na tela
      IF NVL(pr_qtdregis, 0) <= 0 THEN
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>Nao foram selecionados registros para impressao.</Erro></Root>');
        RETURN;
      END IF;
    
      -- Buscar nome da cooperativa
      OPEN cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
      CLOSE cr_crapcop;
    
      -- Ler associado
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      -- Se n�o encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapass;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;
    
      -- Ler dados do operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope
        INTO rw_crapope;
      -- Se n�o encontrar
      IF cr_crapope%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapope;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapope;
      END IF;
    
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
    
      -- Inicializar XML do relat�rio
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
    
      vr_strbuffer := '<?xml version="1.0" encoding="utf-8"?><antecipacao>';
    
      -- Inicializar tag empresa
      vr_strbuffer := vr_strbuffer || '<associ>' || '<nmrescop>' ||
                      rw_crapcop.nmrescop || '</nmrescop>' || '<nrdconta>' ||
                      TRIM(gene0002.fn_mask_conta(rw_crapass.nrdconta)) ||
                      '</nrdconta>' || '<cdagenci>' ||
                      to_char(rw_crapass.cdagenci) || '</cdagenci>' ||
                      '<nmprimtl>' || rw_crapass.nmprimtl || '</nmprimtl>' ||
                      '<nrctremp>' ||
                      trim(gene0002.fn_mask_contrato(to_char(pr_nrctremp))) ||
                      '</nrctremp>' || '<nmoperad>' || rw_crapope.nmoperad ||
                      '</nmoperad>' || '<dtmvtolt>' ||
                      to_char(SYSDATE, 'DD/MM/RRRR') || '</dtmvtolt>' ||
                      '</associ>';
    
      -- Enviar ao CLOB
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xmlbuffer
                             ,pr_texto_novo     => vr_strbuffer);
      -- Limpar a auxiliar
      vr_strbuffer := NULL;
    
      -- Para cada registro encontrado
      LOOP
      
        vr_auxqtd := vr_auxqtd + 1;
      
        vr_nrparepr := GENE0002.fn_busca_entrada(vr_auxqtd
                                                ,pr_lstparepr
                                                ,';');
        vr_dtvencto := GENE0002.fn_busca_entrada(vr_auxqtd
                                                ,pr_lstdtvcto
                                                ,';');
        vr_dtpagemp := GENE0002.fn_busca_entrada(vr_auxqtd
                                                ,pr_lstdtpgto
                                                ,';');
        vr_vllanmto := GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(vr_auxqtd
                                                                             ,pr_lstvlrpag
                                                                             ,';'));
      
        -- Se a lista de datas de pagamento estiver nula
        IF NVL(vr_dtpagemp, '0') = '0' THEN
          vr_dtpagemp := to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');
        END IF;
      
        -- Inicializar tag empresa
        vr_strbuffer := vr_strbuffer || '<parcela>' || '<nrparepr>' ||
                        vr_nrparepr || '</nrparepr>' || '<dtvencto>' ||
                        vr_dtvencto || '</dtvencto>' || '<dtpagemp>' ||
                        vr_dtpagemp || '</dtpagemp>' || '<vllanmto>' ||
                        vr_vllanmto || '</vllanmto>' || '</parcela>';
      
        -- Enviar ao CLOB
        gene0002.pc_escreve_xml(pr_xml            => vr_xml
                               ,pr_texto_completo => vr_xmlbuffer
                               ,pr_texto_novo     => vr_strbuffer);
        -- Limpar a auxiliar
        vr_strbuffer := NULL;
      
        EXIT WHEN vr_auxqtd = NVL(pr_qtdregis, 1);
      END LOOP;
    
      -- Ao final da leitura dos avisos, fechar a tag empresa
      vr_strbuffer := '</antecipacao>';
      -- Enviar ao CLOB
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xmlbuffer
                             ,pr_texto_novo     => vr_strbuffer
                             ,pr_fecha_xml      => TRUE); --> Ultima chamada
    
      -- Somente se o CLOB contiver informa��es
      IF dbms_lob.getlength(vr_xml) > 0 THEN
      
        -- Busca do diret�rio base da cooperativa para PDF
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => vr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      
        -- Definir nome do relatorio
        vr_nmarqimp := 'crrl684_' || pr_nrdconta || '_' || pr_nrctremp ||
                       '.pdf';
      
        -- Solicitar gera��o do relatorio
        gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper --> Cooperativa conectada
                                   ,pr_cdprogra  => 'ATENDA' --> Programa chamador
                                   ,pr_dtmvtolt  => SYSDATE --> Data do movimento atual
                                   ,pr_dsxml     => vr_xml --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/antecipacao' --> N� base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl684.jasper' --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null --> Sem par�metros
                                   ,pr_dsarqsaid => vr_nom_direto || '/' ||
                                                    vr_nmarqimp --> Arquivo final com o path
                                   ,pr_cdrelato  => 684
                                   ,pr_qtcoluna  => 80 --> 80 colunas
                                   ,pr_flg_gerar => 'S' --> Gera�ao na hora
                                   ,pr_flg_impri => 'N' --> Chamar a impress�o (Imprim.p)
                                   ,pr_nmformul  => '' --> Nome do formul�rio para impress�o
                                   ,pr_nrcopias  => 1 --> N�mero de c�pias
                                   ,pr_sqcabrel  => 1 --> Qual a seq do cabrel
                                   ,pr_des_erro  => vr_dscritic); --> Sa�da com erro
        -- Tratar erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          raise vr_exc_saida;
        END IF;
      
        -- Enviar relatorio para intranet
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper --> Cooperativa conectada
                                    ,pr_cdagenci => vr_cdagenci --> Codigo da agencia para erros
                                    ,pr_nrdcaixa => vr_nrdcaixa --> Codigo do caixa para erros
                                    ,pr_nmarqpdf => vr_nom_direto || '/' ||
                                                    vr_nmarqimp --> Arquivo PDF  a ser gerado
                                    ,pr_des_reto => vr_des_reto --> Sa�da com erro
                                    ,pr_tab_erro => vr_tab_erro); --> tabela de erros
      
        -- caso apresente erro na opera��o
        IF nvl(vr_des_reto, 'OK') <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          
            RAISE vr_exc_saida;
          END IF;
        END IF;
      
        -- Remover relatorio da pasta rl apos gerar
        gene0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm ' || vr_nom_direto || '/' ||
                                                vr_nmarqimp
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        -- Se retornou erro
        IF vr_typ_saida = 'ERR'
           OR vr_dscritic IS NOT null THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
      
      END IF;
    
      -- Liberando a mem�ria alocada pro CLOB
      dbms_lob.close(vr_xml);
      dbms_lob.freetemporary(vr_xml);
    
      -- Criar XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
                                     vr_nmarqimp || '</nmarqpdf>');
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                       pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Produtos: ' || SQLERRM;
      
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                       pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  
  END pc_imprimir_antecipacao;  
  
  PROCEDURE pc_valida_inclusao_tr(pr_cdcooper IN craplcr.cdcooper%TYPE --> C�digo da cooperativa
                                 ,pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Codigo da linha de credito
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de inclusao
                                 ,pr_qtpreemp IN crapepr.qtpreemp%TYPE --> Quantidade de Prestacoes
                                 ,pr_flgpagto IN crapepr.flgpagto%TYPE --> Folha
                                 ,pr_dtdpagto IN crapepr.dtdpagto%TYPE --> Data de Pagamento
                                 ,pr_cdfinemp IN crapepr.cdfinemp%TYPE --> Finalidade
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Operador
                                 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2) IS --> Descri��o da cr�tica   

    -- Busca a origem da linha de credito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT cdlcremp,
             dslcremp,
             cdusolcr,
             tpdescto
        FROM craplcr
       WHERE cdcooper = pr_cdcooper
         AND cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
    
    -- Busca a origem da Finalidade
    CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE
                     ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
      SELECT tpfinali
        FROM crapfin
       WHERE cdcooper = pr_cdcooper
         AND cdfinemp = pr_cdfinemp;
    rw_crapfin cr_crapfin%ROWTYPE;
    
    -- Cursor do Operador
    CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
      SELECT dsdepart
        FROM crapope
       WHERE crapope.cdcooper        = pr_cdcooper
         AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_exc_erro  EXCEPTION;

    -- Variaveis gerais
    vr_dslcremp VARCHAR2(2000); --> Contem as linhas de microcredito que sao permitidos para o produto TR
  BEGIN   
    
    -- Buscar informa��es da linha de cr�dito
    OPEN cr_crapfin(pr_cdcooper => pr_cdcooper
                   ,pr_cdfinemp => pr_cdfinemp);
    FETCH cr_crapfin
     INTO rw_crapfin;
    -- Se n�o encontrar
    IF cr_crapfin%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapfin;
      -- Gerar erro
      RAISE vr_exc_saida;
    ELSE
      -- Fechar o cursor
      CLOSE cr_crapfin;
    END IF;      
    
    /* Caso a Finalidade for Cessao de Credito, nao podera permitir incluir */
    IF (rw_crapfin.tpfinali = 1) THEN
      vr_cdcritic := 946;
      RAISE vr_exc_erro;
      
    END IF;
    
    -- Buscar informa��es da linha de cr�dito
    OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                   ,pr_cdlcremp => pr_cdlcremp);
    FETCH cr_craplcr
     INTO rw_craplcr;
    -- Se n�o encontrar
    IF cr_craplcr%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_craplcr;
      -- Gerar erro
      vr_cdcritic := 55;
      RAISE vr_exc_erro;
    ELSE
      -- Fechar o cursor
      CLOSE cr_craplcr;
    END IF;
    
    IF (pr_cdcooper <> 2 AND
				(rw_craplcr.cdlcremp = 100 OR rw_craplcr.cdlcremp = 800 OR rw_craplcr.cdlcremp = 900))OR
			 (pr_cdcooper = 2  AND
			  (rw_craplcr.cdlcremp = 100 OR rw_craplcr.cdlcremp = 850 OR rw_craplcr.cdlcremp = 900))THEN
		  vr_dscritic := 'Linha nao permitida para esse produto.';
			vr_cdcritic := 0;
			RAISE vr_exc_erro;
		END IF;
      
    /* Chamado: 467082 */
    IF pr_dtmvtolt >= TO_DATE('06/17/2016') THEN
      -- Viacredi
      IF pr_cdcooper = 1 THEN
        
        /* Emprestimo consignado */
        IF rw_craplcr.tpdescto = 2 THEN
          RAISE vr_exc_saida;
        END IF;
        
        /* Tipo do debito do emprestimo */
        IF pr_flgpagto = 1 THEN
          vr_dscritic := 'Tipo de debito folha bloqueado para todas as operacoes';
          RAISE vr_exc_erro;
        END IF;
        
        -- Buscar Dados do Operador
        OPEN cr_crapope (pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad);
        FETCH cr_crapope INTO rw_crapope;
        -- Verifica se a retornou registro
        IF cr_crapope%NOTFOUND THEN
          CLOSE cr_crapope;
          vr_cdcritic := 67;
          RAISE vr_exc_erro;
        ELSE
          -- Apenas Fecha o Cursor
          CLOSE cr_crapope;
        END IF;
        
        -- Somente o departamento credito ir� ter acesso para alterar as informacoes
        IF rw_crapope.dsdepart = 'PRODUTOS' OR rw_crapope.dsdepart = 'TI' THEN
          RAISE vr_exc_saida;
        END IF;
        
        vr_dscritic := 'Atencao! Para as condicoes informadas utilize o produto Price Pre-Fixado. ' ||
                       'Operacao nao permitida no produto Price TR.';
        RAISE vr_exc_erro;
		END IF;
      
    END IF;
      
    /* Chamado: 363749 */
    IF pr_dtmvtolt >= TO_DATE('12/04/2015') THEN
      
      /* Tipo do debito do emprestimo */
      IF pr_flgpagto = 1 THEN
        RAISE vr_exc_saida;
      END IF;
      
      /* Emprestimo consignado */
      IF rw_craplcr.tpdescto = 2 THEN
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_cdcooper NOT IN (1,3) THEN
        -- Buscar Dados do Operador
        OPEN cr_crapope (pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad);
        FETCH cr_crapope INTO rw_crapope;
        -- Verifica se a retornou registro
        IF cr_crapope%NOTFOUND THEN
          CLOSE cr_crapope;
          vr_cdcritic := 67;
          RAISE vr_exc_erro;
        ELSE
          -- Apenas Fecha o Cursor
          CLOSE cr_crapope;
        END IF;
        
        -- Somente o departamento credito ir� ter acesso para alterar as informacoes
        IF rw_crapope.dsdepart = 'PRODUTOS' OR rw_crapope.dsdepart = 'TI' THEN
          RAISE vr_exc_saida;
        END IF;  
      
        vr_dscritic := 'Atencao! Para as condicoes informadas utilize o produto Price Pre-Fixado. ' ||
                       'Operacao nao permitida no produto Price TR.';
        RAISE vr_exc_erro;
      END IF;
      
    END IF;
    
    /* Chamado: 254183 */
    IF pr_dtmvtolt >= TO_DATE('02/26/2015') THEN
            
      -- Busca as origens que sao de microcredito
      vr_dslcremp := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'LINHA_MICRO_EMP_TR');

      -- Condicao para verificar se a linha microcredito informada em tela estah nas linhas permitidas
      IF ((rw_craplcr.cdusolcr = 1) AND (INSTR(',' || vr_dslcremp || ',',',' || rw_craplcr.cdlcremp || ',') > 0)) THEN
        RAISE vr_exc_saida;
      END IF;
        
    END IF; /* END IF pr_dtmvtolt >= TO_DATE('02/26/2015') THEN */
    
    /* Chamado: 270806 */
    IF pr_dtmvtolt >= TO_DATE('04/14/2015') THEN
      
      /* Tipo do debito do emprestimo  */ 
      IF pr_flgpagto = 1 THEN
        RAISE vr_exc_saida;
      END IF;
      
      /* Emprestimo consignado */
      IF rw_craplcr.tpdescto = 2 THEN
        RAISE vr_exc_saida;
      END IF;
      
      /* Vencimento dias 28,29,30 deverao permitir incluir */
      IF INSTR(',28,29,30,',',' || TO_CHAR(pr_dtdpagto,'DD') || ',') > 0 THEN
        RAISE vr_exc_saida;
      END IF;      
      
      /* CDC */
      IF UPPER(TRIM(rw_craplcr.dslcremp)) LIKE '%CDC%' THEN
        RAISE vr_exc_saida;
      END IF;
      
      /* CREDITO DIRETO AO COOPERADO */
      IF UPPER(TRIM(rw_craplcr.dslcremp)) LIKE '%CREDITO DIRETO AO COOPERADO%' THEN
        RAISE vr_exc_saida;       
      END IF;
    
      -- Busca as linhas de credito que serao permitidas incluir
      vr_dslcremp := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'LINHA_CREDITO_TR');      
      
      -- Condicao para verificar se permite incluir as linhas parametrizadas
      IF INSTR(',' || vr_dslcremp || ',',',' || rw_craplcr.cdlcremp || ',') > 0 THEN
        RAISE vr_exc_saida;        
      END IF;
      
      /* Quantidade de prestacoes */
      IF pr_qtpreemp <= 60 THEN
        vr_dscritic := 'Atencao! Para as condicoes informadas utilize o produto Price Pre-Fixado. Operacao nao permitida no produto Price TR.';
        RAISE vr_exc_erro;
      END IF;
      
    END IF; /* END IF pr_dtmvtolt >= TO_DATE('04/14/2015') THEN */
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      NULL;
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos c�digo e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em EMPR0001.pc_valida_inclusao_tr: ' ||SQLERRM;
  END;
  
  /* Criar e Atualizar Tabela Temporaria Lancamento Conta  */
  PROCEDURE pc_cria_atualiza_ttlanconta(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                       ,pr_cdhistor    IN craphis.cdhistor%TYPE --> Codigo Historico
                                       ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                       ,pr_cdpactra    IN INTEGER               --> P.A. da transa��o                                       
                                       ,pr_nrdolote    IN craplot.nrdolote%TYPE --> Numero do Lote
                                       ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                       ,pr_vllanmto    IN NUMBER                --> Valor lancamento
                                       ,pr_nrseqava    IN NUMBER DEFAULT 0      --> Pagamento: Sequencia do avalista
                                       ,pr_tab_lancconta IN OUT empr0001.typ_tab_lancconta --> Tabela Lancamentos Conta                                                                              
                                       ,pr_des_erro    OUT VARCHAR              --> Retorno OK / NOK
                                       ,pr_dscritic    OUT VARCHAR2) IS         --> descricao do erro
  BEGIN
    /* .............................................................................
    
       Programa: pc_cria_atualiza_ttlanconta                 Antigo: b1wgen0136.p/cria-atualiza-ttlancconta
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Mar�o/2015                        Ultima atualizacao: 24/03/2015
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetuar Criacao/Atualizacao da ttlancconta
    
       Alteracoes: 24/03/2015 - Convers�o Progress para Oracle (Alisson - AMcom)
    
    ............................................................................. */
  
    DECLARE
      --Variaveis Erro
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis de Indices
      vr_index     VARCHAR2(80); 
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    
    BEGIN  
      
      --Inicializar Variaveis Saida
      pr_dscritic:= NULL;
      pr_des_erro:= 'OK';
      
      --Montar Indice para acesso
      vr_index:= lpad(pr_cdcooper,10,'0')||
                 lpad(pr_nrctremp,10,'0')||
                 lpad(pr_cdhistor,10,'0')||
                 to_char(pr_dtmvtolt,'YYYYMMDD')||
                 lpad(pr_cdpactra,10,'0')||
                 lpad('100',10,'0')||
                 lpad(pr_nrdolote,10,'0')||
                 lpad(pr_nrdconta,10,'0');
      --Se nao encontrou
      IF pr_tab_lancconta.EXISTS(vr_index) THEN
        --Atualizar Lancamento
        pr_tab_lancconta(vr_index).vllanmto:= nvl(pr_tab_lancconta(vr_index).vllanmto,0) + pr_vllanmto;
      ELSE
        --Cadastrar Lancamento
        pr_tab_lancconta(vr_index).cdcooper:= pr_cdcooper;
        pr_tab_lancconta(vr_index).nrctremp:= pr_nrctremp;
        pr_tab_lancconta(vr_index).cdhistor:= pr_cdhistor;
        pr_tab_lancconta(vr_index).dtmvtolt:= pr_dtmvtolt;
        pr_tab_lancconta(vr_index).cdagenci:= pr_cdpactra;
        pr_tab_lancconta(vr_index).cdbccxlt:= 100;
        pr_tab_lancconta(vr_index).cdoperad:= pr_cdoperad;
        pr_tab_lancconta(vr_index).nrdolote:= pr_nrdolote;
        pr_tab_lancconta(vr_index).nrdconta:= pr_nrdconta;
        pr_tab_lancconta(vr_index).vllanmto:= pr_vllanmto;
        pr_tab_lancconta(vr_index).cdpactra:= pr_cdpactra;
        pr_tab_lancconta(vr_index).nrseqava:= pr_nrseqava;
      END IF;
          
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_des_erro:= 'NOK';
        -- Devolvemos a critica encontradas das variaveis locais
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        -- Devolvemos a critica encontradas das variaveis locais        
        pr_dscritic := 'Erro geral em empr0001.pc_cria_atualiza_ttlanconta: ' ||SQLERRM;
    END;
  END pc_cria_atualiza_ttlanconta;  

  /* Efetuar a Liquidacao do Emprestimo  */
  PROCEDURE pc_efetua_liquidacao_empr(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                     ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                     ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                     ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                     ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                     ,pr_idorigem    IN INTEGER --> Id do m�dulo de sistema
                                     ,pr_cdpactra    IN INTEGER --> P.A. da transa��o
                                     ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                     ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                     ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                     ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para gera��o de log
                                     ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                     ,pr_dtmvtoan    IN DATE     --> Data Movimento Anterior
                                     ,pr_ehprcbat    IN VARCHAR2 --> Indicador Processo Batch (S/N)
                                     ,pr_tab_pgto_parcel IN OUT EMPR0001.typ_tab_pgto_parcel --Tabela com Pagamentos de Parcelas
                                     ,pr_tab_crawepr IN EMPR0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                     ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                     ,pr_des_erro    OUT VARCHAR --> Retorno OK / NOK
                                     ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_efetua_liquidacao_empr                 Antigo: b1wgen0136.p/efetua_liquidacao_empr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Mar�o/2015                        Ultima atualizacao: 27/09/2016
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetuar a Liquidacao do Emprestimo
    
       Alteracoes: 24/03/2015 - Convers�o Progress para Oracle (Alisson - AMcom)
    
                   27/09/2016 - Tornar o parametro PR_TAB_PGTO_PARCEL um parametro 
                                "IN OUT" (Renato/Supero - P.302 - Acordos)
    
    ............................................................................. */
  
    DECLARE
    
      --Selecionar Parcelas Emprestimo
      CURSOR cr_crappep (pr_cdcooper IN crappep.cdcooper%type
                        ,pr_nrdconta IN crappep.nrdconta%type
                        ,pr_nrctremp IN crappep.nrctremp%type
                        ,pr_inliquid IN crappep.inliquid%type) IS
        SELECT crappep.cdcooper
              ,crappep.nrdconta
              ,crappep.nrctremp
              ,crappep.nrparepr
              ,crappep.dtvencto
        FROM crappep 
        WHERE crappep.cdcooper = pr_cdcooper 
        AND   crappep.nrdconta = pr_nrdconta 
        AND   crappep.nrctremp = pr_nrctremp 
        AND   crappep.inliquid = pr_inliquid 
        ORDER BY crappep.nrparepr;
       
      --Tabela de lancamentos na conta
      vr_tab_lanc EMPR0001.typ_tab_lancconta;
      
      --Tipo de Tabela
      TYPE typ_pgto_char IS TABLE OF empr0001.typ_reg_pgto_parcel INDEX BY VARCHAR2(40);
      vr_tab_pgto typ_pgto_char;
      
      --Variaveis para Indices 
      vr_index_pgto PLS_INTEGER;
      vr_index_char VARCHAR2(40);
      vr_index_lanc VARCHAR2(80);
                       
      --Variaveis Locais
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      vr_flgtrans BOOLEAN;
      vr_existe   BOOLEAN;
    
      --Variaveis 
      vr_vlrmulta NUMBER;
      vr_vlatraso NUMBER;
      vr_cdhismul INTEGER;
      vr_cdhisatr INTEGER;
      vr_cdhispag INTEGER;
      vr_loteatra INTEGER;
      vr_lotemult INTEGER;
      vr_lotepaga INTEGER;
      vr_vlpagsld NUMBER;
               
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_des_erro VARCHAR2(3);
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    
    BEGIN
      --Inicializar variavel erro
      pr_des_erro:= 'OK';
    
      --Limpar tabela erro
      pr_tab_erro.DELETE;
      vr_tab_lanc.DELETE;
      vr_tab_pgto.DELETE;
      
      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Liquida emprestimo';
      END IF;
    
      --Popular nova tabela mudando indice para facilitar consulta
      vr_index_pgto:= pr_tab_pgto_parcel.FIRST;
      WHILE vr_index_pgto IS NOT NULL LOOP
        vr_index_char:= lpad(pr_tab_pgto_parcel(vr_index_pgto).cdcooper,10,'0')||
                        lpad(pr_tab_pgto_parcel(vr_index_pgto).nrdconta,10,'0')||
                        lpad(pr_tab_pgto_parcel(vr_index_pgto).nrctremp,10,'0')||
                        lpad(pr_tab_pgto_parcel(vr_index_pgto).nrparepr,10,'0');
        --Copiar dados de uma tabela para outra
        vr_tab_pgto(vr_index_char):= pr_tab_pgto_parcel(vr_index_pgto);               
        --Proximo Registro
        vr_index_pgto:= pr_tab_pgto_parcel.NEXT(vr_index_pgto);
      END LOOP;
        
      BEGIN
        --Criar savepoint para desfazer transacao
        SAVEPOINT save_trans;
      
        --Selecionar Parcelas Emprestimo
        FOR rw_crappep IN cr_crappep (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctremp => pr_nrctremp
                                     ,pr_inliquid => 0) LOOP
            
          --Verificar se a parcela existe 
          vr_index_char:= lpad(rw_crappep.cdcooper,10,'0')||
                          lpad(rw_crappep.nrdconta,10,'0')||
                          lpad(rw_crappep.nrctremp,10,'0')||
                          lpad(rw_crappep.nrparepr,10,'0');
                          
          --Verificar se a parcela existe
          IF NOT vr_tab_pgto.EXISTS(vr_index_char) THEN                         
            --Erro
            vr_cdcritic:= 0;
            vr_dscritic:= 'Parcela nao encontrada.';
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
          
          /* Parcela em dia */ 
          IF rw_crappep.dtvencto > pr_dtmvtoan AND rw_crappep.dtvencto <= pr_dtmvtolt THEN
            --Efetivar Pagamento Normal parcela na craplem
            EMPR0001.pc_efetiva_pagto_parc_lem (pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                               ,pr_cdagenci    => pr_cdagenci --> C�digo da ag�ncia
                                               ,pr_nrdcaixa    => pr_nrdcaixa --> N�mero do caixa
                                               ,pr_cdoperad    => pr_cdoperad --> C�digo do Operador
                                               ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                               ,pr_idorigem    => pr_idorigem --> Id do m�dulo de sistema
                                               ,pr_cdpactra    => pr_cdpactra --> P.A. da transa��o
                                               ,pr_nrdconta    => pr_nrdconta --> N�mero da conta
                                               ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                               ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                               ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para gera��o de log
                                               ,pr_nrctremp    => rw_crappep.nrctremp --> N�mero do contrato de empr�stimo
                                               ,pr_nrparepr    => rw_crappep.nrparepr --> N�mero parcelas empr�stimo
                                               ,pr_vlparepr    => vr_tab_pgto(vr_index_char).vlatupar --> Valor da parcela emprestimo
                                               ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                               ,pr_nrseqava    => pr_nrseqava --> Pagamento: Sequencia do avalista
                                               ,pr_cdhistor    => vr_cdhispag --> Codigo historico
                                               ,pr_nrdolote    => vr_lotepaga --> Numero do Lote
                                               ,pr_des_reto    => vr_des_erro --> Retorno OK / NOK
                                               ,pr_tab_erro    => pr_tab_erro); --> Tabela com poss�ves erros
            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
            END IF; 
            
            --Se nao for batch
            IF nvl(pr_ehprcbat,'X') = 'N' THEN
              --Atualizar Lancamento Conta
              pc_cria_atualiza_ttlanconta (pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                          ,pr_nrctremp => pr_nrctremp   --> N�mero do contrato de empr�stimo
                                          ,pr_cdhistor => vr_cdhispag   --> Codigo Historico
                                          ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                          ,pr_cdoperad => pr_cdoperad   --> C�digo do Operador
                                          ,pr_cdpactra => pr_cdpactra   --> P.A. da transa��o                                       
                                          ,pr_nrdolote => vr_lotepaga   --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta   --> N�mero da conta
                                          ,pr_vllanmto => vr_tab_pgto(vr_index_char).vlatupar --> Valor lancamento
                                          ,pr_nrseqava => pr_nrseqava   --> Pagamento: Sequencia do avalista
                                          ,pr_tab_lancconta => vr_tab_lanc    --> Tabela Lancamentos Conta                                                                              
                                          ,pr_des_erro => vr_des_erro   --> Retorno OK / NOK
                                          ,pr_dscritic => vr_dscritic); --> descricao do erro
              --Se Retornou erro
              IF vr_des_erro <> 'OK' THEN
                --Sair
                RAISE vr_exc_saida;
              END IF;                            
            END IF; --pr_ehprcbat
            
            -- Renato Darosci - Informa que a parcela foi processada
            vr_tab_pgto(vr_index_char).inpagmto := 1;
            
          ELSIF rw_crappep.dtvencto < pr_dtmvtolt THEN /* Parcela Vencida */
            
            --Efetivar Pagamento Atrasado parcela na craplem
            EMPR0001.pc_efetiva_pag_atr_parcel_lem (pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                                   ,pr_cdagenci    => pr_cdagenci --> C�digo da ag�ncia
                                                   ,pr_nrdcaixa    => pr_nrdcaixa --> N�mero do caixa
                                                   ,pr_cdoperad    => pr_cdoperad --> C�digo do Operador
                                                   ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                                   ,pr_idorigem    => pr_idorigem --> Id do m�dulo de sistema
                                                   ,pr_cdpactra    => pr_cdpactra --> P.A. da transa��o
                                                   ,pr_nrdconta    => pr_nrdconta --> N�mero da conta
                                                   ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                                   ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                                   ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para gera��o de log
                                                   ,pr_nrctremp    => rw_crappep.nrctremp --> N�mero do contrato de empr�stimo
                                                   ,pr_nrparepr    => rw_crappep.nrparepr --> N�mero parcelas empr�stimo
                                                   ,pr_vlpagpar    => vr_tab_pgto(vr_index_char).vlatrpag --> Valor da parcela emprestimo
                                                   ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                                   ,pr_nrseqava    => pr_nrseqava --Pagamento: Sequencia do avalista
                                                   ,pr_vlpagsld    => vr_vlpagsld --> Valor Pago Saldo
                                                   ,pr_vlrmulta    => vr_vlrmulta --> Valor Multa
                                                   ,pr_vlatraso    => vr_vlatraso --> Valor Atraso
                                                   ,pr_cdhismul    => vr_cdhismul --> Historico Multa
                                                   ,pr_cdhisatr    => vr_cdhisatr --> Historico Atraso
                                                   ,pr_cdhispag    => vr_cdhispag --> Historico Pagamento
                                                   ,pr_loteatra    => vr_loteatra --> Lote Atraso
                                                   ,pr_lotemult    => vr_lotemult --> Lote Multa
                                                   ,pr_lotepaga    => vr_lotepaga --> Lote Pagamento
                                                   ,pr_des_reto    => vr_des_erro --> Retorno OK / NOK
                                                   ,pr_tab_erro    => pr_tab_erro); --> Tabela com poss�ves erros
          
            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
            END IF;
            
            /* multa */ 
            pc_cria_atualiza_ttlanconta (pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                        ,pr_nrctremp => pr_nrctremp   --> N�mero do contrato de empr�stimo
                                        ,pr_cdhistor => vr_cdhismul   --> Codigo Historico
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                        ,pr_cdoperad => pr_cdoperad   --> C�digo do Operador
                                        ,pr_cdpactra => pr_cdpactra   --> P.A. da transa��o                                       
                                        ,pr_nrdolote => vr_lotemult   --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta   --> N�mero da conta
                                        ,pr_vllanmto => vr_vlrmulta   --> Valor lancamento
                                        ,pr_nrseqava => pr_nrseqava   --> Pagamento: Sequencia do avalista
                                        ,pr_tab_lancconta => vr_tab_lanc    --> Tabela Lancamentos Conta                                                                              
                                        ,pr_des_erro => vr_des_erro   --> Retorno OK / NOK
                                        ,pr_dscritic => vr_dscritic); --> descricao do erro
            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
            END IF;                            
            
            /* juros de inadinplencia */
            pc_cria_atualiza_ttlanconta (pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                        ,pr_nrctremp => pr_nrctremp   --> N�mero do contrato de empr�stimo
                                        ,pr_cdhistor => vr_cdhisatr   --> Codigo Historico
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                        ,pr_cdoperad => pr_cdoperad   --> C�digo do Operador
                                        ,pr_cdpactra => pr_cdpactra   --> P.A. da transa��o                                       
                                        ,pr_nrdolote => vr_loteatra   --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta   --> N�mero da conta
                                        ,pr_vllanmto => vr_vlatraso   --> Valor lancamento
                                        ,pr_nrseqava => pr_nrseqava   --> Pagamento: Sequencia do avalista
                                        ,pr_tab_lancconta => vr_tab_lanc    --> Tabela Lancamentos Conta                                                                              
                                        ,pr_des_erro => vr_des_erro   --> Retorno OK / NOK
                                        ,pr_dscritic => vr_dscritic); --> descricao do erro
            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
            END IF;                            
            --Se nao for batch
            IF nvl(pr_ehprcbat,'X') = 'N' THEN
              /* pagamento */
              pc_cria_atualiza_ttlanconta (pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                          ,pr_nrctremp => pr_nrctremp   --> N�mero do contrato de empr�stimo
                                          ,pr_cdhistor => vr_cdhispag   --> Codigo Historico
                                          ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                          ,pr_cdoperad => pr_cdoperad   --> C�digo do Operador
                                          ,pr_cdpactra => pr_cdpactra   --> P.A. da transa��o                                       
                                          ,pr_nrdolote => vr_lotepaga   --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta   --> N�mero da conta
                                          ,pr_vllanmto => vr_tab_pgto(vr_index_char).vlatupar --> Valor lancamento
                                          ,pr_nrseqava => pr_nrseqava   --> Pagamento: Sequencia do avalista
                                          ,pr_tab_lancconta => vr_tab_lanc    --> Tabela Lancamentos Conta                                                                              
                                          ,pr_des_erro => vr_des_erro   --> Retorno OK / NOK
                                          ,pr_dscritic => vr_dscritic); --> descricao do erro
              --Se Retornou erro
              IF vr_des_erro <> 'OK' THEN
                --Sair
                RAISE vr_exc_saida;
              END IF;                            
            END IF; --pr_ehprcbat
            
            -- Renato Darosci - Informa que a parcela foi processada
            vr_tab_pgto(vr_index_char).inpagmto := 1;
            
          ELSIF rw_crappep.dtvencto > pr_dtmvtolt   THEN /* Parcela a Vencer */ 
             
            --Efetivar Pagamento Antecipado parcela na craplem
            EMPR0001.pc_efetiva_pagto_antec_lem (pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                                ,pr_cdagenci    => pr_cdagenci --> C�digo da ag�ncia
                                                ,pr_nrdcaixa    => pr_nrdcaixa --> N�mero do caixa
                                                ,pr_cdoperad    => pr_cdoperad --> C�digo do Operador
                                                ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                                ,pr_idorigem    => pr_idorigem --> Id do m�dulo de sistema
                                                ,pr_cdpactra    => pr_cdpactra --> P.A. da transa��o
                                                ,pr_nrdconta    => pr_nrdconta --> N�mero da conta
                                                ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                                ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                                ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para gera��o de log
                                                ,pr_nrctremp    => rw_crappep.nrctremp --> N�mero do contrato de empr�stimo
                                                ,pr_nrparepr    => rw_crappep.nrparepr --> N�mero parcelas empr�stimo
                                                ,pr_vlpagpar    => vr_tab_pgto(vr_index_char).vlatupar --> Valor da parcela emprestimo
                                                ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                                ,pr_nrseqava    => pr_nrseqava --Pagamento: Sequencia do avalista
                                                ,pr_cdhistor    => vr_cdhispag --> Historico Multa
                                                ,pr_nrdolote    => vr_lotepaga --> Lote Pagamento
                                                ,pr_des_reto    => vr_des_erro --> Retorno OK / NOK
                                                ,pr_tab_erro    => pr_tab_erro); --> Tabela com poss�ves erros
           
            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
            END IF;
            
            IF nvl(pr_ehprcbat,'X') = 'N' THEN
              /* pagamento */
              pc_cria_atualiza_ttlanconta (pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                          ,pr_nrctremp => pr_nrctremp   --> N�mero do contrato de empr�stimo
                                          ,pr_cdhistor => vr_cdhispag   --> Codigo Historico
                                          ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                          ,pr_cdoperad => pr_cdoperad   --> C�digo do Operador
                                          ,pr_cdpactra => pr_cdpactra   --> P.A. da transa��o                                       
                                          ,pr_nrdolote => vr_lotepaga   --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta   --> N�mero da conta
                                          ,pr_vllanmto => vr_tab_pgto(vr_index_char).vlatupar --> Valor lancamento
                                          ,pr_nrseqava => pr_nrseqava   --> Pagamento: Sequencia do avalista
                                          ,pr_tab_lancconta => vr_tab_lanc    --> Tabela Lancamentos Conta                                                                              
                                          ,pr_des_erro => vr_des_erro   --> Retorno OK / NOK
                                          ,pr_dscritic => vr_dscritic); --> descricao do erro
              --Se Retornou erro
              IF vr_des_erro <> 'OK' THEN
                --Sair
                RAISE vr_exc_saida;
              END IF; 
            END IF;  
            
            -- Renato Darosci - Informa que a parcela foi processada
            vr_tab_pgto(vr_index_char).inpagmto := 1;
            
          END IF;                               
        END LOOP;  --rw_crappep 
      
        --Percorrer os Lancamentos
        vr_index_lanc:= vr_tab_lanc.FIRST;
        WHILE vr_index_lanc IS NOT NULL LOOP
          
          /* Lanca em C/C e atualiza o lote */
          EMPR0001.pc_cria_lancamento_cc (pr_cdcooper => vr_tab_lanc(vr_index_lanc).cdcooper --> Cooperativa conectada
                                         ,pr_dtmvtolt => vr_tab_lanc(vr_index_lanc).dtmvtolt --> Movimento atual
                                         ,pr_cdagenci => vr_tab_lanc(vr_index_lanc).cdagenci --> C�digo da ag�ncia
                                         ,pr_cdbccxlt => vr_tab_lanc(vr_index_lanc).cdbccxlt --> N�mero do caixa
                                         ,pr_cdoperad => vr_tab_lanc(vr_index_lanc).cdoperad --> C�digo do Operador
                                         ,pr_cdpactra => vr_tab_lanc(vr_index_lanc).cdpactra --> P.A. da transa��o
                                         ,pr_nrdolote => vr_tab_lanc(vr_index_lanc).nrdolote --> Numero do Lote
                                         ,pr_nrdconta => vr_tab_lanc(vr_index_lanc).nrdconta --> N�mero da conta
                                         ,pr_cdhistor => vr_tab_lanc(vr_index_lanc).cdhistor --> Codigo historico
                                         ,pr_vllanmto => vr_tab_lanc(vr_index_lanc).vllanmto --> Valor da parcela emprestimo
                                         ,pr_nrparepr => 0                                   --> N�mero parcelas empr�stimo
                                         ,pr_nrctremp => vr_tab_lanc(vr_index_lanc).nrctremp --> N�mero do contrato de empr�stimo
                                         ,pr_nrseqava => vr_tab_lanc(vr_index_lanc).nrseqava --> Pagamento: Sequencia do avalista
                                         ,pr_des_reto => vr_des_erro                         --> Retorno OK / NOK
                                         ,pr_tab_erro => pr_tab_erro);                       --> Tabela com poss�ves erros
          --Se Retornou erro
          IF vr_des_erro <> 'OK' THEN
            --Sair
            RAISE vr_exc_saida;
          END IF;
          --Marcar que transacao ocorreu
          vr_flgtrans:= TRUE;
          --Proximo registro
          vr_index_lanc:= vr_tab_lanc.NEXT(vr_index_lanc);
        END LOOP;
          
      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT save_trans;
      END;
    
      -- Renato Darosci - 27/09/2016 - Retornar a tabela de mem�ria ap�s processamento
      -- Limpa a tabela de mem�ria do parametro
      pr_tab_pgto_parcel.DELETE();
    
      -- Devolver a tabela de mem�ria para a rotina chamadora
      vr_index_char := vr_tab_pgto.FIRST();
      WHILE vr_index_char IS NOT NULL LOOP
        -- Copiar dados de uma tabela para outra
        pr_tab_pgto_parcel(pr_tab_pgto_parcel.count() + 1) := vr_tab_pgto(vr_index_char);
        -- Proximo Registro
        vr_index_char:= vr_tab_pgto.NEXT(vr_index_char);
      END LOOP;
      --------------------
      
      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno n�o OK
        pr_des_erro := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      ELSE
        -- Retorno OK
        pr_des_erro := 'OK';  
      END IF;
        
      IF pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_erro := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_efetua_liquidacao_empr. '||sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_efetua_liquidacao_empr;
  
  /* Efetivar o pagamento da parcela  */
  PROCEDURE pc_liquida_mesmo_dia(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                ,pr_idorigem    IN INTEGER --> Id do m�dulo de sistema
                                ,pr_cdpactra    IN INTEGER --> P.A. da transa��o
                                ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para gera��o de log
                                ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                ,pr_tab_erro    OUT gene0001.typ_tab_erro
                                ,pr_cdcritic    OUT INTEGER
                                ,pr_dscritic    OUT VARCHAR2
                                ,pr_retxml   IN OUT NOCOPY XMLType ) IS --> Tabela com poss�ves erros
  BEGIN
    /* .............................................................................
    
       Programa: pc_liquida_mesmo_dia                
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Daniel
       Data    : Maio/2015                        Ultima atualizacao: 14/01/2016
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetivar liquida��o de contrato no mesmo dia
    
       Alteracoes: 16/10/2015 - Zerar o campo vlsdvsji quando liquidar a parcela PP (Oscar)             
    
                   14/01/2016 - Retirar campo vlsdvsji duplicado no update da crappep e ajustado 
                                retorno de criticas SD381067 (Odirlei-AMcom)
    
    ............................................................................. */
  
    DECLARE
    
      --Variaveis Locais
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_nrdolote craplot.nrdolote%TYPE;
      vr_floperac BOOLEAN;
      vr_inusatab BOOLEAN;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_des_erro VARCHAR2(3);
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_saida EXCEPTION;
      
      -- Busca na craptab
      vr_dstextab craptab.dstextab%TYPE;
      
      --Registro tipo Data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
      -- Cursor de Emprestimos
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crapepr.*
              ,crapepr.rowid
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
               AND crapepr.nrdconta = pr_nrdconta
               AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
    
    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
    
      --Limpar tabela erro
      pr_tab_erro.DELETE;
    
      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Efetiva liquidacao contrato mesmo dia';
      END IF;
    
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat
        INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
        
      --Selecionar Emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr
        INTO rw_crapepr;
      --Se nao Encontrou
      IF cr_crapepr%NOTFOUND THEN
        --Fechar CURSOR
        CLOSE cr_crapepr;
        vr_cdcritic := 55;
        RAISE vr_exc_saida;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapepr;
        
      IF rw_crapepr.inliquid = 1 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Contrato ja liquidado. Operacao Cancelada!';
        RAISE vr_exc_saida;
      END IF;
      
      IF rw_crapepr.vlsdeved <= 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Contrato com Saldo Devedor Zerado. Operacao Cancelada!';
        RAISE vr_exc_saida;
      END IF;
        
      --Selecionar Linha Credito
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => rw_crapepr.cdlcremp);
      FETCH cr_craplcr
        INTO rw_craplcr;
      --Se nao Encontrou
      IF cr_craplcr%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_craplcr;
        vr_cdcritic := 363;
        --Sair
        RAISE vr_exc_saida;
      ELSE
        --Determinar se a Operacao � financiamento
        vr_floperac := rw_craplcr.dsoperac = 'FINANCIAMENTO';
      END IF;
      --Fechar Cursor
      CLOSE cr_craplcr;
        
      --Determinar o Lote
      IF vr_floperac THEN
        vr_nrdolote := 600013; -- Financiamento
      ELSE
        vr_nrdolote := 600012; -- Emprestimo
      END IF;

      -- Determina Historico
      IF vr_floperac THEN
        vr_cdhistor := 1039;
      ELSE
        vr_cdhistor := 1044;
      END IF;
        
      
      -- Cria lancamento craplem e atualiza o seu lote
      pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                            ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                            ,pr_cdbccxlt => 100         --Codigo Caixa
                            ,pr_cdoperad => pr_cdoperad --Operador
                            ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                            ,pr_tplotmov => 5           --Tipo movimento
                            ,pr_nrdolote => vr_nrdolote --Numero Lote
                            ,pr_nrdconta => rw_crapepr.nrdconta --Numero da Conta
                            ,pr_cdhistor => vr_cdhistor --Codigo Historico
                            ,pr_nrctremp => rw_crapepr.nrctremp --Numero Contrato
                            ,pr_vllanmto => rw_crapepr.vlemprst --Valor Lancamento
                            ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                            ,pr_txjurepr => rw_crapepr.txjuremp --Taxa Juros Emprestimo
                            ,pr_vlpreemp => rw_crapepr.vlpreemp --Valor Parcela Emprestimo
                            ,pr_nrsequni => 0 --Numero Sequencia
                            ,pr_nrparepr => 0 --Numero Parcelas Emprestimo
                            ,pr_flgincre => TRUE --Indicador Credito
                            ,pr_flgcredi => TRUE --Credito
                            ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                            ,pr_cdorigem => pr_idorigem
                            ,pr_cdcritic => vr_cdcritic --Codigo Erro
                            ,pr_dscritic => vr_dscritic); --Descricao Erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL
         OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;      
        
      --Se for Financiamento
      IF vr_floperac THEN
        vr_nrdolote := 600015;
      ELSE
        vr_nrdolote := 600014;
      END IF;

      vr_cdhistor := 108;
      
      -- Lanca em C/C e atualiza o lote
      pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                           ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                           ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                           ,pr_cdbccxlt => 100         --> N�mero do caixa
                           ,pr_cdoperad => pr_cdoperad --> C�digo do Operador
                           ,pr_cdpactra => pr_cdpactra --> P.A. da transa��o
                           ,pr_nrdolote => vr_nrdolote --> Numero do Lote
                           ,pr_nrdconta => rw_crapepr.nrdconta --> N�mero da conta
                           ,pr_cdhistor => vr_cdhistor --> Codigo historico
                           ,pr_vllanmto => rw_crapepr.vlemprst --> Valor emprestimo
                           ,pr_nrparepr => 0 --> N�mero parcelas empr�stimo
                           ,pr_nrctremp => rw_crapepr.nrctremp --> N�mero do contrato de empr�stimo
                           ,pr_nrseqava => 0 --> Pagamento: Sequencia do avalista
                           ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                           ,pr_tab_erro => vr_tab_erro); --> Tabela com poss�ves erros
        
      IF vr_des_erro = 'NOK' THEN
        --Se tem erro na tabela 
        IF vr_tab_erro.count > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao executar EMPR0001.pc_liquida_mesmo_dia.';  
        END IF;  
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;  
        
      --Atualizar Emprestimo
       BEGIN
         UPDATE crapepr
            SET crapepr.dtultpag = pr_dtmvtolt
               ,crapepr.qtprepag = rw_crapepr.qtpreemp
               ,crapepr.vlsdeved = 0
               ,crapepr.vljuratu = 0
               ,crapepr.vljuracu = 0
               ,crapepr.inliquid = 1
               ,crapepr.qtprecal = rw_crapepr.qtpreemp
							 ,crapepr.dtliquid = pr_dtmvtolt
          WHERE crapepr.rowid = rw_crapepr.rowid;
       EXCEPTION
         WHEN OTHERS THEN
           --Mensagem erro
           vr_cdcritic := 0;
           vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
           RAISE vr_exc_saida;
       END;
         
         
      --Atualizar parcela Emprestimo
      BEGIN 
        UPDATE crappep
           SET crappep.dtultpag = pr_dtmvtolt
              ,crappep.vlpagpar = rw_crapepr.vlpreemp
              ,crappep.vlsdvpar = 0
              ,crappep.vlsdvsji = 0
              ,crappep.inliquid = 1
              ,crappep.vlsdvatu = 0
              ,crappep.vljura60 = 0
         WHERE crappep.cdcooper = rw_crapepr.cdcooper
           AND crappep.nrdconta = rw_crapepr.nrdconta
           AND crappep.nrctremp = rw_crapepr.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          --Mensagem erro
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar crappep. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
        
      -- Buscar parametro
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se nao encontrou parametro
      IF trim(vr_dstextab) IS NULL THEN
        vr_inusatab := FALSE;
      ELSE
        IF SUBSTR(vr_dstextab, 1, 1) = '0' THEN
          vr_inusatab := FALSE;
        ELSE
          vr_inusatab := TRUE;
        END IF;
      END IF;
        
      --Desativar Rating
      rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper -- Cooperativa
                                 ,pr_cdagenci   => pr_cdagenci -- Agencia
                                 ,pr_nrdcaixa   => pr_nrdcaixa -- Numero Caixa
                                 ,pr_cdoperad   => pr_cdcooper -- Operador
                                 ,pr_rw_crapdat => rw_crapdat  -- Registro Data
                                 ,pr_nrdconta   => rw_crapepr.nrdconta -- Conta Corrente
                                 ,pr_tpctrrat   => 90 /* Emprestimo */ -- Tipo Contrato
                                 ,pr_nrctrrat   => rw_crapepr.nrctremp -- Numero Contrato
                                 ,pr_flgefeti   => 'S ' -- Efetivar
                                 ,pr_idseqttl   => 1    -- Titular
                                 ,pr_idorigem   => 1    -- Origem
                                 ,pr_inusatab   => vr_inusatab -- Uso tabela Juros
                                 ,pr_nmdatela   => pr_nmdatela -- Nome da Tela
                                 ,pr_flgerlog   => 'N'         -- Escrever Log
                                 ,pr_des_reto   => vr_des_erro -- Retorno OK/NOK
                                 ,pr_tab_erro   => vr_tab_erro); -- Tabela Erro
       
       IF vr_des_erro = 'NOK' THEN
        --Se tem erro na tabela 
        IF vr_tab_erro.count > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao executar EMPR0001.pc_liquida_mesmo_dia.';  
        END IF;  
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF; 
          
      -- Se foi solicitado o envio de LOG 
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Retorno OK
        pr_des_reto := 'OK';
        
      END IF;
      
      COMMIT;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        pr_des_reto := 'NOK';

        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na EMPR0001.pc_liquida_mesmo_dia ' ||
                       sqlerrm;
        ROLLBACK;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
    END;
  END pc_liquida_mesmo_dia;
  
  
  /* Efetivar o pagamento da parcela  */
  PROCEDURE pc_liq_mesmo_dia_web(pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                ,pr_dtmvtolt    IN VARCHAR2              --> Movimento atual
                                ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para gera��o de log
                                ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                ,pr_xmllog   IN VARCHAR2                 --> XML com informac?es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER             --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                --> Descric?o da critica
                                ,pr_retxml   IN OUT NOCOPY XMLType       --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS            --> Erros do processo
  BEGIN
    /* .............................................................................
    
       Programa: pc_liquida_mesmo_dia                
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Daniel
       Data    : Maio/2015                        Ultima atualizacao: 
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetivar liquida��o de contrato no mesmo dia
    
       Alteracoes: 14/01/2016 - Ajustado tratamento de criticas SD381067 (Odirlei-AMcom)
    
    ............................................................................. */
  
    DECLARE
    
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_des_erro VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
      
    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      
      pc_liquida_mesmo_dia(pr_cdcooper => vr_cdcooper
                          ,pr_cdagenci => vr_cdagenci
                          ,pr_nrdcaixa => vr_nrdcaixa
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_idorigem => vr_idorigem
                          ,pr_cdpactra => 1 --> P.A. da transa��o
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_dtmvtolt => to_date(pr_dtmvtolt,'DD/MM/YYYY')
                          ,pr_flgerlog => pr_flgerlog
                          ,pr_nrctremp => pr_nrctremp
                          ,pr_des_reto => vr_des_erro
                          ,pr_tab_erro => vr_tab_erro
                          ,pr_cdcritic => pr_cdcritic
                          ,pr_dscritic => pr_dscritic
                          ,pr_retxml   => pr_retxml);
                          
      IF vr_des_erro = 'NOK' THEN
        -- Levantar exce��o 2, onde j� temos o erro na vr_tab_erro
        pr_des_erro := vr_des_erro;
        
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        ELSE
          vr_dscritic := 'N�o foi possivel liquidar emprestimo.';
        END IF;        
        
        RAISE vr_exc_erro;
      END IF;                    
      
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN

        -- Montar descri��o de erro n�o tratado
        pr_dscritic := 'Erro n�o tratado na EMPR0001.pc_liquida_mesmo_dia ' ||
                       SQLERRM; /*
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro); */
    END;
  END pc_liq_mesmo_dia_web;
  
  -- Procedure para pagamento antecipado da parcela
  PROCEDURE pr_efetiva_pagto_antec_parcela (pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                           ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                           ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                           ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                           ,pr_nmdatela    IN VARCHAR2              --> Nome da tela
                                           ,pr_idorigem    IN INTEGER               --> Id do m�dulo de sistema
                                           ,pr_cdpactra    IN INTEGER               --> P.A. da transa��o
                                           ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> N�mero da conta
                                           ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                           ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                           ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para gera��o de log
                                           ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                           ,pr_nrparepr    IN INTEGER               --> N�mero parcelas empr�stimo
                                           ,pr_vlpagpar    IN NUMBER                --> Valor a pagar parcela
                                           ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                           ,pr_nrseqava    IN NUMBER DEFAULT 0       --> Pagamento: Sequencia do avalista
                                           ,pr_cdhistor    OUT craphis.cdhistor%TYPE --> Historico Pagamento
                                           ,pr_nrdolote    OUT craplot.nrdolote%TYPE --> Numero Lote Pagamento
                                           ,pr_des_reto    OUT VARCHAR               --> Retorno OK / NOK
                                           ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
    
    /* .............................................................................
      
       Programa: pr_efetiva_pagto_antec_parcela (antigo b1wgen0084a.p --> efetiva_pagamento_antecipado_parcela)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Renato Darosci
       Data    : Setembro/2016.                         Ultima atualizacao: 29/09/2016
      
       Dados referentes ao programa:
      
       Frequencia: Sempre que for chamado.
       Objetivo  : 
      
       Alteracoes:
                    
    ............................................................................. */
  
    vr_exc_erro  EXCEPTION;
  
  BEGIN 
    
    pr_des_reto := 'NOK';
  
    -- Efetivar Pagamento Antecipado parcela na craplem
    pc_efetiva_pagto_antec_lem(pr_cdcooper    => pr_cdcooper    --> Cooperativa conectada
                              ,pr_cdagenci    => pr_cdagenci    --> C�digo da ag�ncia
                              ,pr_nrdcaixa    => pr_nrdcaixa    --> N�mero do caixa
                              ,pr_cdoperad    => pr_cdoperad    --> C�digo do Operador
                              ,pr_nmdatela    => pr_nmdatela    --> Nome da tela
                              ,pr_idorigem    => pr_idorigem    --> Id do m�dulo de sistema
                              ,pr_cdpactra    => pr_cdpactra    --> P.A. da transa��o
                              ,pr_nrdconta    => pr_nrdconta    --> N�mero da conta
                              ,pr_idseqttl    => pr_idseqttl    --> Seq titula
                              ,pr_dtmvtolt    => pr_dtmvtolt    --> Movimento atual
                              ,pr_flgerlog    => pr_flgerlog    --> Indicador S/N para gera��o de log
                              ,pr_nrctremp    => pr_nrctremp    --> N�mero do contrato de empr�stimo
                              ,pr_nrparepr    => pr_nrparepr    --> N�mero parcelas empr�stimo
                              ,pr_vlpagpar    => pr_vlpagpar    --> Valor da parcela emprestimo
                              ,pr_tab_crawepr => pr_tab_crawepr --> Tabela com Contas e Contratos
                              ,pr_nrseqava    => pr_nrseqava    --> Pagamento: Sequencia do avalista
                              ,pr_cdhistor    => pr_cdhistor    --> Historico 
                              ,pr_nrdolote    => pr_nrdolote    --> Lote Pagamento
                              ,pr_des_reto    => vr_des_reto    --> Retorno OK / NOK
                              ,pr_tab_erro    => vr_tab_erro);  --> Tabela com poss�ves erros
           
    --Se Retornou erro
    IF vr_des_reto <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    /* Lanca em C/C e atualiza o lote */
    empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                         ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                         ,pr_cdagenci => pr_cdagenci --> C�digo da ag�ncia
                                         ,pr_cdbccxlt => 100         --> N�mero do caixa
                                         ,pr_cdoperad => pr_cdoperad --> C�digo do Operador
                                         ,pr_cdpactra => pr_cdpactra --> P.A. da transa��o
                                         ,pr_nrdolote => pr_nrdolote --> Numero do Lote
                                         ,pr_nrdconta => pr_nrdconta --> N�mero da conta
                                         ,pr_cdhistor => pr_cdhistor --> Codigo historico
                                         ,pr_vllanmto => pr_vlpagpar --> Valor da parcela emprestimo
                                         ,pr_nrparepr => pr_nrparepr --> N�mero parcelas empr�stimo
                                         ,pr_nrctremp => pr_nrctremp --> N�mero do contrato de empr�stimo
                                         ,pr_nrseqava => pr_nrseqava -- Pagamento: Sequencia do avalista
                                         ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                         ,pr_tab_erro => vr_tab_erro); --> Tabela com poss�ves erros
    --Se Retornou erro
    IF vr_des_reto <> 'OK' THEN
      --Sair
      RAISE vr_exc_erro;
    END IF;
    
    -- Retornar ok para as transa��es
    pr_des_reto := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_reto := vr_des_reto;
      pr_tab_erro := vr_tab_erro;
    WHEN OTHERS THEN
      pr_des_reto := 'NOK';
      pr_tab_erro(pr_tab_erro.FIRST).dscritic := 'Erro PR_EFETIVA_PAGTO_ANTEC_PARCELA: '||SQLERRM;
  END pr_efetiva_pagto_antec_parcela;
  
  
  --Procedure de pagamentos de parcelas
  PROCEDURE pc_gera_pagamentos_parcelas(pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da Cooperativa
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                        ,pr_cdoperad IN VARCHAR2              --> C�digo do operador
                                        ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                        ,pr_idorigem IN INTEGER               --> Id Origem do sistemas
                                        ,pr_cdpactra IN INTEGER               --> P.A. da transa��o
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Id do titular da conta
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                        ,pr_flgerlog IN VARCHAR2              --> Gera log S/N
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Nr. do contrato de emprestimo
                                        ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE --> Data de movimento do dia anterior
                                        ,pr_totatual IN crapepr.vlemprst%TYPE
                                        ,pr_totpagto IN crapepr.vlemprst%TYPE
                                        ,pr_nrseqava IN NUMBER DEFAULT 0      --> Pagamento: Sequencia do avalista
																			 ,pr_tab_pgto_parcel IN OUT empr0001.typ_tab_pgto_parcel
																				,pr_des_reto OUT VARCHAR
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros     
  BEGIN
    /* .............................................................................
      
       Programa: pc_gera_pagamentos_parcelas (antigo b1wgen0084a.p --> gera_pagamentos_parcelas)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Carlos Rafael Tanholi
       Data    : Agosto/2015.                         Ultima atualizacao: 27/11/2015
      
       Dados referentes ao programa:
      
       Frequencia: Sempre que for chamado.
       Objetivo  : 
      
       Alteracoes:
       
       27/11/2015 - Incluido rotina de bloqueio de pagto de boletos de emprestimo
                    referente ao projeto 210 (Rafael)
                    
       28/09/2016 - Incluir valida��o para contratos de acordo ativos, conforme 
                    projeto 302 - Sistema de acordos ( Renato Darosci - Supero )
                    
       29/09/2016 - Incluir o pagamento de parcela a vencer, seguindo as mesmas
                    regras da b1wgen0084a.p->gera_pagamentos_parcelas, conforme 
                    projeto 302 - Sistema de acordos ( Renato Darosci - Supero )
       
    ............................................................................. */
    DECLARE
       
	    -- Tratamento de erro 			
			vr_exc_erro EXCEPTION;
		  vr_exc_erro2 EXCEPTION;
			-- Descri��o e c�digo da critica 
			vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic VARCHAR2(4000);
			-- Erro em chamadas da pc_gera_erro 
			vr_des_reto VARCHAR(4000);
			vr_tab_erro GENE0001.typ_tab_erro;
      vr_flgativo NUMBER;
      vr_cdhispag INTEGER;
      vr_lotepaga INTEGER;


      vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel; --> Tabela com registros de pagamentos
      vr_tab_calculado   empr0001.typ_tab_calculado;   --> Tabela com totais calculados
			vr_tab_crawepr     empr0001.typ_tab_crawepr;
      vr_index_crawepr   VARCHAR2(50);

      --Variaveis Locais
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
			vr_nrdrowid ROWID;
      
      -- Parametro de bloqueio de resgate de valores em c/c
      vr_blqresg_cc VARCHAR2(1); 		
      vr_ordem_pgto CHAR;
      vr_tab_pgto_parcel_ordenado empr0001.typ_tab_pgto_parcel; --> Tabela com registros de pagamentos

      ----------------------------- CURSORES ---------------------------
      
			--Selecionar Detalhes Emprestimo
			CURSOR cr_crawepr_carga(pr_cdcooper IN crapcop.cdcooper%TYPE
														 ,pr_nrdconta IN crappep.nrdconta%TYPE
                             ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
				SELECT crawepr.cdcooper
							,crawepr.nrdconta
							,crawepr.nrctremp
							,crawepr.dtlibera
							,crawepr.tpemprst
					FROM crawepr
				 WHERE crawepr.cdcooper = pr_cdcooper
					 AND crawepr.nrdconta = pr_nrdconta
					 AND crawepr.nrctremp = pr_nrctremp;					 
			-- Parcelas de emprestimo
			CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
			                 ,pr_nrdconta IN crappep.nrdconta%TYPE
											 ,pr_nrctremp IN crappep.nrctremp%TYPE
											 ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
				SELECT pep.nrparepr
				      ,pep.dtvencto
							,pep.inliquid
							,pep.nrctremp
					FROM crappep pep
				 WHERE pep.cdcooper = pr_cdcooper
					 AND pep.nrdconta = pr_nrdconta
					 AND pep.nrctremp = pr_nrctremp
					 AND pep.nrparepr = pr_nrparepr;
			rw_crappep cr_crappep%ROWTYPE;
      
      CURSOR cr_crappep_menor(pr_cdcooper IN crapcop.cdcooper%TYPE
														 ,pr_nrdconta IN crappep.nrdconta%TYPE
                             ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
				SELECT NVL(MIN(crappep.nrparepr),0) nrparepr
					FROM crappep
				 WHERE crappep.cdcooper = pr_cdcooper
					 AND crappep.nrdconta = pr_nrdconta
					 AND crappep.nrctremp = pr_nrctremp
           AND crappep.inliquid = 0; -- N�o Liquidado	
      rw_crappep_menor cr_crappep_menor%ROWTYPE;    

	  -- Cursor para verificar se existe algum boleto em aberto
      CURSOR cr_cde (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrctremp IN crapcob.nrctremp%TYPE) IS
           SELECT cob.nrdocmto,
                  cob.dtvencto,
                  cob.vltitulo
             FROM crapcob cob                  
            WHERE cob.cdcooper = pr_cdcooper
              AND cob.incobran = 0
              AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN 
                  (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                     FROM tbepr_cobranca cde
                    WHERE cde.cdcooper = pr_cdcooper
                      AND cde.nrdconta = pr_nrdconta
                      AND cde.nrctremp = pr_nrctremp);
      rw_cde cr_cde%ROWTYPE;
            
      -- Cursor para verificar se existe algum boleto pago pendente de processamento
      CURSOR cr_ret (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrctremp IN crapcob.nrctremp%TYPE
                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
          SELECT cob.nrdocmto,
                 cob.dtvencto,
                 cob.vltitulo
            FROM crapcob cob, crapret ret
           WHERE cob.cdcooper = pr_cdcooper
             AND cob.incobran = 5
             AND cob.dtdpagto = pr_dtmvtolt
             AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN 
                 (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                    FROM tbepr_cobranca cde
                   WHERE cde.cdcooper = pr_cdcooper
                     AND cde.nrdconta = pr_nrdconta
                     AND cde.nrctremp = pr_nrctremp)
             AND ret.cdcooper = cob.cdcooper
             AND ret.nrdconta = cob.nrdconta
             AND ret.nrcnvcob = cob.nrcnvcob
             AND ret.nrdocmto = cob.nrdocmto
             AND ret.dtocorre = cob.dtdpagto
             AND ret.cdocorre = 6
             AND ret.flcredit = 0;
             
      rw_ret cr_ret%ROWTYPE; 
    
    BEGIN 
  			 
			 IF UPPER(pr_flgerlog) = 'S' THEN
				 vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
				 vr_dstransa := 'Gera pagamentos de parcelas';
			 END IF;
    
		   IF pr_tab_pgto_parcel.count() = 0 THEN
				 -- Atribui cr�tica
				 vr_cdcritic := 0;
				 vr_dscritic := 'Para efetuar o pagamento selecione a(s) parcela(s).';
				 -- Gera exce��o
				 RAISE vr_exc_erro;
			 END IF;
			 
       -- Parametro de bloqueio de resgate de valores em c/c
       -- ref ao pagto de contrato com boleto (Projeto 210)
       vr_blqresg_cc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                  pr_cdcooper => pr_cdcooper,
                                                  pr_cdacesso => 'COBEMP_BLQ_RESG_CC');											  
												  
			 -- Verificar se h� acordo ativo para o contrato
       RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_flgativo => vr_flgativo
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
       
       -- Se houve retorno de erro
       IF vr_dscritic IS NOT NULL THEN
				 -- Gera exce��o
				 RAISE vr_exc_erro;
			 END IF;
												  
       /* verificar se existe boleto de contrato em aberto e se pode lancar juros remuneratorios no contrato */
       /* 1�) verificar se o parametro est� bloqueado para realizar busca de boleto em aberto */		   
       /*     e... se o contrato n�o estiver em um acordo ativo  */
       IF vr_blqresg_cc = 'S' AND vr_flgativo = 0 THEN                                             
             
          -- inicializar rows de cursores
          rw_cde := NULL;
          rw_ret := NULL;
           
          /* 2� se permitir, verificar se possui boletos em aberto */
          OPEN cr_cde( pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp);
          FETCH cr_cde INTO rw_cde;
          CLOSE cr_cde;

          /* 3� se existir boleto de contrato em aberto, criticar */
          IF nvl(rw_cde.nrdocmto,0) > 0 THEN           
             -- Atribui cr�tica
             vr_cdcritic := 0;
             vr_dscritic := 'Boleto do contrato ' || to_char(pr_nrctremp) || ' em aberto.' ||
				  		              ' Vencto ' || to_char(rw_cde.dtvencto, 'DD/MM/RRRR') ||
							              ' R$ ' || to_char(rw_cde.vltitulo,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';    
             -- Gera exce��o
             RAISE vr_exc_erro;
            
          ELSE              
             /* 4� cursor para verificar se existe boleto pago pendente de processamento */
             OPEN cr_ret( pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctremp => pr_nrctremp
                         ,pr_dtmvtolt => pr_dtmvtolt);
             FETCH cr_ret INTO rw_ret;
             CLOSE cr_ret;

             /* 6� se existir boleto de contrato pago pendente de processamento, lancar juros */
             IF nvl(rw_ret.nrdocmto,0) > 0 THEN           
                -- Atribui cr�tica
                vr_cdcritic := 0;               
                vr_dscritic := 'Boleto do contrato ' || to_char(pr_nrctremp) ||
                               ' esta pago pendente de processamento.' ||
  				  		               ' Vencto ' || to_char(rw_ret.dtvencto, 'DD/MM/RRRR') ||
							                 ' R$ ' || to_char(rw_ret.vltitulo,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
                -- Gera exce��o
                RAISE vr_exc_erro;				
             END IF;

          END IF; -- nvl(rw_cde.nrdocmto,0) > 0
                                            
       END IF; -- vr_blqresg_cc = 'S'
			 
			 vr_tab_pgto_parcel := pr_tab_pgto_parcel;
			 
			 FOR rw_crawepr IN cr_crawepr_carga(pr_cdcooper => pr_cdcooper
				                                 ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => pr_nrctremp) LOOP
				 --Montar Indice
				 vr_index_crawepr := lpad(rw_crawepr.cdcooper, 10, '0') ||
														 lpad(rw_crawepr.nrdconta, 10, '0') ||
														 lpad(rw_crawepr.nrctremp, 10, '0');														 
				 vr_tab_crawepr(vr_index_crawepr).dtlibera := rw_crawepr.dtlibera;
				 vr_tab_crawepr(vr_index_crawepr).tpemprst := rw_crawepr.tpemprst;
			 END LOOP;
    
       IF pr_totatual = pr_totpagto THEN -- Liquida Emprestimo
           -- Trazer todas as parcelas
           EMPR0001.pc_busca_pgto_parcelas(pr_cdcooper => pr_cdcooper
           	                              ,pr_cdagenci => pr_cdagenci
                                          ,pr_nrdcaixa => pr_nrdcaixa
                                          ,pr_cdoperad => pr_cdoperad
                                          ,pr_nmdatela => pr_nmdatela
                                          ,pr_idorigem => pr_idorigem
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_idseqttl => pr_idseqttl
                                          ,pr_dtmvtolt => pr_dtmvtolt
                                          ,pr_flgerlog => pr_flgerlog
                                          ,pr_nrctremp => pr_nrctremp
                                          ,pr_dtmvtoan => pr_dtmvtoan
                                          ,pr_nrparepr => 0
                                          ,pr_des_reto => vr_des_reto
                                          ,pr_tab_erro => pr_tab_erro
                                          ,pr_tab_pgto_parcel => vr_tab_pgto_parcel 
                                          ,pr_tab_calculado => vr_tab_calculado);
																					
		       -- Se retornou algum erro																		
			     IF vr_des_reto <> 'OK' THEN
						 -- Gera exce��o
						 RAISE vr_exc_erro2;
					 END IF;

           -- Efetua liquida��o do emprestimo
           pc_efetua_liquidacao_empr(pr_cdcooper => pr_cdcooper
																	 ,pr_cdagenci => pr_cdagenci
																	 ,pr_nrdcaixa => pr_nrdcaixa
																	 ,pr_cdoperad => pr_cdoperad
																	 ,pr_nmdatela => pr_nmdatela
																	 ,pr_idorigem => pr_idorigem
																	 ,pr_cdpactra => pr_cdpactra
																	 ,pr_nrdconta => pr_nrdconta
																	 ,pr_idseqttl => pr_idseqttl
																	 ,pr_dtmvtolt => pr_dtmvtolt
																	 ,pr_flgerlog => 'N'
																	 ,pr_nrctremp => pr_nrctremp
																	 ,pr_dtmvtoan => pr_dtmvtoan
																	 ,pr_ehprcbat => 'N'
																	 ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
																	 ,pr_tab_crawepr => vr_tab_crawepr
																	 ,pr_nrseqava => pr_nrseqava
																	 ,pr_des_erro => vr_des_reto
																	 ,pr_tab_erro => vr_tab_erro);

           -- Se retornou algum erro
           IF vr_des_reto <> 'OK' THEN
              RAISE vr_exc_erro;
           END IF;
           
       ELSE
         
         OPEN cr_crappep_menor(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrctremp => pr_nrctremp);
         FETCH cr_crappep_menor INTO rw_crappep_menor;
           
         IF rw_crappep_menor.nrparepr = 0 THEN
            CLOSE cr_crappep_menor;
            -- Atribui cr�ticas
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao Localizar Parcela';
            -- Gera exce��o
            RAISE vr_exc_erro;
         ELSE
            CLOSE cr_crappep_menor;
         END IF;
         
         vr_ordem_pgto := 'D';
         
         FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP
			 
           IF vr_tab_pgto_parcel(idx).nrparepr = rw_crappep_menor.nrparepr THEN
             vr_ordem_pgto := 'C';
             EXIT;
           END IF;
       
         END LOOP;
         
         IF vr_ordem_pgto = 'D' THEN
           
           vr_tab_pgto_parcel_ordenado.DELETE;  
         
           FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP
             vr_tab_pgto_parcel_ordenado(9999 - vr_tab_pgto_parcel(idx).nrparepr) := vr_tab_pgto_parcel(idx);          
           END LOOP;
           
           vr_tab_pgto_parcel := vr_tab_pgto_parcel_ordenado;
           
         END IF;
       
         FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP
           -- Procura parcela do emprestimo
           OPEN cr_crappep(pr_cdcooper => vr_tab_pgto_parcel(idx).cdcooper
                          ,pr_nrdconta => vr_tab_pgto_parcel(idx).nrdconta
                          ,pr_nrctremp => vr_tab_pgto_parcel(idx).nrctremp
                          ,pr_nrparepr => vr_tab_pgto_parcel(idx).nrparepr);
           FETCH cr_crappep INTO rw_crappep;

           IF cr_crappep%NOTFOUND THEN
              CLOSE cr_crappep;
              -- Atribui cr�ticas
              vr_cdcritic := 0;
              vr_dscritic := 'Parcela nao encontrada';
              -- Gera exce��o
              RAISE vr_exc_erro;
           ELSE
              CLOSE cr_crappep;
           END IF;
  				 
           -- Verifica se tem uma parcela anterior nao liquida e ja vencida
           pc_verifica_parcel_anteriores(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_nrparepr => rw_crappep.nrparepr
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_des_reto => vr_des_reto
                                        ,pr_dscritic => vr_dscritic);
  						
           -- Se retornou diferente de OK																	 
           IF vr_des_reto <> 'OK' THEN
             -- Gera exce��o
             RAISE vr_exc_erro;
           END IF;
  				 
           pc_verifica_parcelas_antecipa(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_nrparepr => rw_crappep.nrparepr
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_des_reto => vr_des_reto
                                        ,pr_dscritic => vr_dscritic);
  																									
           -- Se retornou diferente de OK																	 
           IF vr_des_reto <> 'OK' THEN
             -- Gera exce��o
             RAISE vr_exc_erro;
           END IF;

           IF rw_crappep.inliquid = 1 THEN
             -- Atribui cr�ticas
             vr_cdcritic := 0;
             vr_dscritic := 'Parcela ja liquidada';
             -- Gera exce��o
             RAISE vr_exc_erro;					 
           END IF;
  				 
           -- Parcela em dia
           IF rw_crappep.dtvencto >  pr_dtmvtoan AND
              rw_crappep.dtvencto <= pr_dtmvtolt THEN
  				
              pc_efetiva_pagto_parcela(pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_nrdcaixa => pr_nrdcaixa
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_nmdatela => pr_nmdatela
                                      ,pr_idorigem => pr_idorigem
                                      ,pr_cdpactra => pr_cdpactra
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_idseqttl => pr_idseqttl
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_flgerlog => pr_flgerlog
                                      ,pr_nrctremp => rw_crappep.nrctremp
                                      ,pr_nrparepr => rw_crappep.nrparepr
                                      ,pr_vlparepr => vr_tab_pgto_parcel(idx).vlpagpar
                                      ,pr_tab_crawepr => vr_tab_crawepr
                                      ,pr_nrseqava => pr_nrseqava
                                      ,pr_des_reto => vr_des_reto
                                      ,pr_tab_erro => vr_tab_erro);
  																		
              IF vr_des_reto <> 'OK' THEN
                RAISE vr_exc_erro2;
              END IF;
  						
           ELSIF rw_crappep.dtvencto < pr_dtmvtolt THEN -- Parcela vencida
  																			
             pc_efetiva_pagto_atr_parcel(pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nmdatela => pr_nmdatela
                                        ,pr_idorigem => pr_idorigem
                                        ,pr_cdpactra => pr_cdpactra
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_flgerlog => pr_flgerlog
                                        ,pr_nrctremp => rw_crappep.nrctremp
                                        ,pr_nrparepr => rw_crappep.nrparepr
                                        ,pr_vlpagpar => vr_tab_pgto_parcel(idx).vlpagpar
                                        ,pr_tab_crawepr => vr_tab_crawepr 
                                        ,pr_nrseqava => pr_nrseqava
                                        ,pr_des_reto => vr_des_reto
                                        ,pr_tab_erro => vr_tab_erro);
  												 
             IF vr_des_reto <> 'OK' THEN
               RAISE vr_exc_erro2;
             END IF;
  				 
           ELSIF rw_crappep.dtvencto > pr_dtmvtolt   THEN /* Parcela a Vencer */ 
             
             pr_efetiva_pagto_antec_parcela(pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                           ,pr_cdagenci    => pr_cdagenci --> C�digo da ag�ncia
                                           ,pr_nrdcaixa    => pr_nrdcaixa --> N�mero do caixa
                                           ,pr_cdoperad    => pr_cdoperad --> C�digo do Operador
                                           ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                           ,pr_idorigem    => pr_idorigem --> Id do m�dulo de sistema
                                           ,pr_cdpactra    => pr_cdpactra --> P.A. da transa��o
                                           ,pr_nrdconta    => pr_nrdconta --> N�mero da conta
                                           ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                           ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                           ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para gera��o de log
                                           ,pr_nrctremp    => rw_crappep.nrctremp --> N�mero do contrato de empr�stimo
                                           ,pr_nrparepr    => rw_crappep.nrparepr --> N�mero parcelas empr�stimo
                                           ,pr_vlpagpar    => vr_tab_pgto_parcel(idx).vlpagpar --> Valor da parcela emprestimo
                                           ,pr_tab_crawepr => vr_tab_crawepr --> Tabela com Contas e Contratos
                                           ,pr_nrseqava    => pr_nrseqava    --> Pagamento: Sequencia do avalista
                                           ,pr_cdhistor    => vr_cdhispag    --> Historico Multa
                                           ,pr_nrdolote    => vr_lotepaga    --> Lote Pagamento
                                           ,pr_des_reto    => vr_des_reto    --> Retorno OK / NOK
                                           ,pr_tab_erro    => vr_tab_erro);  --> Tabela com poss�ves erros
             
             -- Se Retornou erro
             IF vr_des_reto <> 'OK' THEN
               RAISE vr_exc_erro2;
             END IF;
  																				 
           END IF;
           
           -- Indicar que a parcela foi paga
           vr_tab_pgto_parcel(idx).inpagmto := 1;
           
         END LOOP;
       END IF;
			 
       -- atualizar tabela no parametro de retorno
       pr_tab_pgto_parcel := vr_tab_pgto_parcel;
       
       --Se escreve erro log
       IF pr_flgerlog = 'S' THEN

         gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
				                     ,pr_cdoperad => pr_cdoperad
														 ,pr_dscritic => ''
														 ,pr_dsorigem => vr_dsorigem
														 ,pr_dstransa => vr_dstransa
														 ,pr_dttransa => pr_dtmvtolt
														 ,pr_flgtrans => 1
														 ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                             ,pr_idseqttl => pr_idseqttl
                             ,pr_nmdatela => pr_nmdatela
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);
       END IF;
   
			 -- Retorno OK
			 pr_des_reto := 'OK';
	
	     EXCEPTION
	       WHEN vr_exc_erro THEN
           -- atualizar tabela no parametro de retorno
           pr_tab_pgto_parcel := vr_tab_pgto_parcel;  
         
					 -- Retorno n�o OK
					 pr_des_reto := 'NOK';
					 -- Gerar rotina de grava��o de erro
					 gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
																,pr_cdagenci => pr_cdagenci
																,pr_nrdcaixa => pr_nrdcaixa
																,pr_nrsequen => 1 --> Fixo
																,pr_cdcritic => vr_cdcritic
																,pr_dscritic => vr_dscritic
																,pr_tab_erro => pr_tab_erro);
																
         WHEN vr_exc_erro2 THEN
           -- atualizar tabela no parametro de retorno
           pr_tab_pgto_parcel := vr_tab_pgto_parcel;
    
           -- Retorno n�o OK
	         pr_des_reto := 'NOK';
					 -- Copiar o erro j� existente na variavel para
					 pr_tab_erro := vr_tab_erro;
	
    END;

  END pc_gera_pagamentos_parcelas;  

  PROCEDURE pc_verifica_parcelas_antecipa(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
																				 ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Conta
																				 ,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Contrato
																				 ,pr_nrparepr IN crappep.nrparepr%TYPE  --> Nr. da parcela
																				 ,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE  --> Data de movimento
																				 ,pr_des_reto OUT VARCHAR2              --> Retorno OK/NOK
																				 ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
	BEGIN
	/* .............................................................................
      
		 Programa: pc_verifica_parcelas_antecipacao (antigo b1wgen0084a.p --> verifica_parcelas_antecipacao)
		 Sistema : Conta-Corrente - Cooperativa de Credito
		 Sigla   : CRED
		 Autor   : Lucas Reinert
		 Data    : Setembro/2015.                      Ultima atualizacao: 11/09/2015
      
		 Dados referentes ao programa:
      
		 Frequencia: Sempre que for chamado.
		 Objetivo  : 
      
		 Alteracoes:
	............................................................................. */
		DECLARE
		
      /* Tratamento de erro */		
			vr_exc_saida EXCEPTION;

			/* Descri��o e c�digo da critica */
			vr_dscritic VARCHAR2(4000);
				
      -- Verifica se tem uma parcela anterior nao liquida e ja vencida 
		  CURSOR cr_crappep_1 IS
			  SELECT 1
				  FROM crappep pep
				 WHERE pep.cdcooper = pr_cdcooper
				   AND pep.nrdconta = pr_nrdconta
					 AND pep.nrctremp = pr_nrctremp
					 AND pep.nrparepr < pr_nrparepr
					 AND pep.inliquid = 0
					 AND pep.dtvencto < pr_dtmvtolt;
      rw_crappep_1 cr_crappep_1%ROWTYPE;
			
		  -- Verifica se as parcelas informadas est�o em ordem			
			CURSOR cr_crappep_2 IS
			  SELECT 1
				  FROM crappep pep
				 WHERE pep.cdcooper = pr_cdcooper
				   AND pep.nrdconta = pr_nrdconta
					 AND pep.nrctremp = pr_nrctremp
					 AND pep.nrparepr > pr_nrparepr
					 AND pep.inliquid = 0;
			rw_crappep_2 cr_crappep_2%ROWTYPE;
							 
		  -- Verifica se as parcelas informadas est�o em ordem			
			CURSOR cr_crappep_3 IS
			  SELECT 1
				  FROM crappep pep
				 WHERE pep.cdcooper = pr_cdcooper
				   AND pep.nrdconta = pr_nrdconta
					 AND pep.nrctremp = pr_nrctremp
					 AND pep.nrparepr < pr_nrparepr
					 AND pep.inliquid = 0;
			rw_crappep_3 cr_crappep_3%ROWTYPE;
      
							 
		BEGIN
      -- Verifica se tem uma parcela anterior nao liquida e ja vencida 			
		  OPEN cr_crappep_1;
			FETCH cr_crappep_1 INTO rw_crappep_1;
			
			IF cr_crappep_1%FOUND THEN
				vr_dscritic := 'Efetuar primeiro o pagamento da parcela em atraso';
				RAISE vr_exc_saida;
			END IF;

			-- Verifica se as parcelas informadas est�o em ordem
			OPEN cr_crappep_2;
			FETCH cr_crappep_2 INTO rw_crappep_2;

			-- Verifica se as parcelas informadas est�o em ordem
			OPEN cr_crappep_3;
			FETCH cr_crappep_3 INTO rw_crappep_2;      

 			IF cr_crappep_2%FOUND AND
         cr_crappep_3%FOUND THEN
				vr_dscritic := 'Efetuar o pagamento das parcelas na sequencia crescente ou decrescente';
				RAISE vr_exc_saida;
			END IF;
      
      CLOSE cr_crappep_2;
      CLOSE cr_crappep_3;      
      
			pr_des_reto := 'OK';
		
		EXCEPTION
      WHEN vr_exc_saida THEN
        
        IF cr_crappep_2%ISOPEN THEN CLOSE cr_crappep_2; END IF;
        IF cr_crappep_3%ISOPEN THEN CLOSE cr_crappep_3; END IF;     
              
				pr_dscritic := vr_dscritic;
				pr_des_reto := 'NOK';
			WHEN OTHERS THEN
				
        IF cr_crappep_2%ISOPEN THEN CLOSE cr_crappep_2; END IF;
        IF cr_crappep_3%ISOPEN THEN CLOSE cr_crappep_3; END IF;     
              
				pr_dscritic := 'Erro nao tratado na procedure EMPR0001.pc_verifica_parcelas_antecipa -> ' || SQLERRM;
				pr_des_reto := 'NOK';
			  
		END;
	END pc_verifica_parcelas_antecipa;

  /* Possui a mesma funcionalidade da rotina pc_valida_pagamentos_geral,
     para chamadas diretamente atraves de rotinas progress */
  PROCEDURE pc_valida_pagto_geral_prog (pr_cdcooper  IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                       ,pr_cdagenci  IN crapass.cdagenci%TYPE --Codigo Agencia
                                       ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE --Codigo Caixa
                                       ,pr_cdoperad  IN craplot.cdoperad%TYPE --Operador
                                       ,pr_nmdatela  IN crapprg.cdprogra%TYPE --Nome da Tela
                                       ,pr_idorigem  IN INTEGER               --Identificador origem
                                       ,pr_nrdconta  IN crapepr.nrdconta%TYPE --Numero da Conta
                                       ,pr_nrctremp  IN crapepr.nrctremp%TYPE --Numero Contrato
                                       ,pr_idseqttl  IN crapttl.idseqttl%TYPE --Sequencial Titular
                                       ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                                       ,pr_flgerlog  IN INTEGER               --Erro no Log
                                       ,pr_dtrefere  IN crapdat.dtmvtolt%TYPE --Data Referencia
                                       ,pr_vlapagar  IN NUMBER                --Valor Pagar
                                       ,pr_vlsomato OUT NUMBER                --Soma Total
                                       ,pr_des_reto OUT VARCHAR               --Retorno OK / NOK
                                       ,pr_cdcritic OUT INTEGER               --Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR               --Descricao da Critica
                                       ,pr_inconfir OUT INTEGER               --Codigo da Confirmacao
                                       ,pr_dsmensag OUT VARCHAR) IS           --Descricao da Confirmacao

    /* ..........................................................................

        Programa : pc_valida_pagto_geral_prog
        Sistema  : Conta-Corrente - Cooperativa de Credito
        Sigla    : CRED
        Autor    : Douglas Quisinski
        Data     : Novembro/2015                Ultima atualizacao:

        Dados referentes ao programa:

         Frequencia: Sempre que for chamado
         Objetivo  : Possui a mesma funcionalidade da rotina pc_valida_pagamentos_geral,
                     para chamadas diretamente atraves de rotinas progress

        Altera��o : 
    ..........................................................................*/

    -- Flag gerar log
    vr_flgerlog       BOOLEAN;
    
    -- Indice das tabelas
    vr_index_crawepr  VARCHAR2(30);
    vr_index_erro     PLS_INTEGER;
    vr_index_confirma PLS_INTEGER;
    
    --Variaveis Erro
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis Excecao
    vr_exc_erro  EXCEPTION;
    
    -- Tabelas utilizadas na procedure 
    vr_tab_crawepr      EMPR0001.typ_tab_crawepr;
    vr_tab_erro         GENE0001.typ_tab_erro;
    vr_tab_msg_confirma EMPR0001.typ_tab_msg_confirma;

    --Selecionar Detalhes Emprestimo
    CURSOR cr_crawepr (pr_cdcooper IN crawepr.cdcooper%TYPE
                      ,pr_nrdconta IN crawepr.nrdconta%TYPE
                      ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
         SELECT crawepr.cdcooper
               ,crawepr.nrdconta
               ,crawepr.nrctremp
               ,crawepr.dtlibera
               ,crawepr.tpemprst
         FROM crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp;
     rw_crawepr cr_crawepr%ROWTYPE;

  BEGIN
    
    vr_flgerlog := sys.diutil.int_to_bool(pr_flgerlog);
    
    --Carregar Tabela crawepr
    FOR rw_crawepr IN cr_crawepr (pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp) LOOP
      --Montar Indice
      vr_index_crawepr:= lpad(rw_crawepr.cdcooper,10,'0')||
                         lpad(rw_crawepr.nrdconta,10,'0')||
                         lpad(rw_crawepr.nrctremp,10,'0');
      vr_tab_crawepr(vr_index_crawepr).dtlibera:= rw_crawepr.dtlibera;
      vr_tab_crawepr(vr_index_crawepr).tpemprst:= rw_crawepr.tpemprst;
    END LOOP;
    
    EMPR0001.pc_valida_pagamentos_geral(pr_cdcooper    => pr_cdcooper,
                                        pr_cdagenci    => pr_cdagenci,
                                        pr_nrdcaixa    => pr_nrdcaixa,
                                        pr_cdoperad    => pr_cdoperad,
                                        pr_nmdatela    => pr_nmdatela,
                                        pr_idorigem    => pr_idorigem,
                                        pr_nrdconta    => pr_nrdconta,
                                        pr_nrctremp    => pr_nrctremp,
                                        pr_idseqttl    => pr_idseqttl,
                                        pr_dtmvtolt    => pr_dtmvtolt,
                                        pr_flgerlog    => vr_flgerlog,
                                        pr_dtrefere    => pr_dtrefere,
                                        pr_vlapagar    => pr_vlapagar,
                                        pr_tab_crawepr => vr_tab_crawepr,
                                        pr_vlsomato    => pr_vlsomato,
                                        pr_tab_erro    => vr_tab_erro,
                                        pr_des_reto    => pr_des_reto,
                                        pr_tab_msg_confirma => vr_tab_msg_confirma);
  
    IF pr_des_reto <> 'OK' THEN
      vr_index_erro := vr_tab_erro.FIRST;
      IF vr_index_erro IS NOT NULL THEN
        vr_cdcritic := vr_tab_erro(vr_index_erro).cdcritic;
        vr_dscritic := vr_tab_erro(vr_index_erro).dscritic;
        RAISE vr_exc_erro;
      END IF;
    END IF;

    vr_index_confirma := vr_tab_msg_confirma.FIRST;
    IF vr_index_confirma IS NOT NULL THEN
      pr_inconfir := vr_tab_msg_confirma(vr_index_confirma).inconfir;
      pr_dsmensag := vr_tab_msg_confirma(vr_index_confirma).dsmensag;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral(EMPR0001.pc_valida_pagto_geral_prog): '|| SQLERRM;

  END pc_valida_pagto_geral_prog;
  
  PROCEDURE pc_verifica_msg_garantia(pr_cdcooper IN crapbpr.cdcooper%TYPE --> C�digo da cooperativa
                                    ,pr_dscatbem IN crapbpr.dscatbem%TYPE --> Descricao da categoria do bem
								                    ,pr_vlmerbem IN crapbpr.vlmerbem%TYPE --> Valor de mercado do bem
                                    ,pr_vlemprst IN crapepr.vlemprst%TYPE --> Valor do emprestimo
                                    ,pr_flgsenha OUT INTEGER              --> Verifica se solicita a senha
                                    ,pr_dsmensag OUT VARCHAR2             --> Descricao da mensagem de aviso
                                    ,pr_cdcritic OUT INTEGER              --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2) IS         --> Descri��o da cr�tica
    /* .............................................................................
    
       Programa: pc_verifica_msg_garantia                
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Janeiro/2016                        Ultima atualizacao: 
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para verificar se apresenta mensagem de garantia
    
       Alteracoes:     
    ............................................................................. */
    vr_tipsplit  gene0002.typ_split;
    vr_dsvlrgar  VARCHAR2(4000);
  BEGIN
    pr_flgsenha := 0;
    
    -- Caso o valor do bem for igual a 0, nao vamos exibir a mensagem
    IF NVL(pr_vlmerbem,0) = 0 THEN
      RETURN;
    END IF;
    
    -- Busca a quantidade de vezes que ira apresentar a mensagem de garantia
    vr_dsvlrgar := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdacesso => 'GESGAR');
                                            
    vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsvlrgar, pr_delimit => ';');
    
    -- Caso o valor do bem for maior ou igual � 5 vezes, apresenta mensagem em tela
    IF (pr_vlemprst * vr_tipsplit(1)) <= pr_vlmerbem THEN
      pr_dsmensag := 'Atencao! Valor do bem superior ou igual a ' || vr_tipsplit(1) || ' vezes o valor do emprestimo!';
    END IF;
    
    -- Caso o valor do bem for maior ou igual � 10 vezes, solicita a senha de coordenador
    IF (pr_vlemprst * vr_tipsplit(2)) <= pr_vlmerbem THEN
      pr_dsmensag := 'Atencao! Valor do bem superior ou igual a ' || vr_tipsplit(2) || ' vezes o valor do emprestimo!';
      pr_flgsenha := 1;
    END IF;
    
    -- Caso o valor do bem for inferior ou igual a 5 vezes, apresenta mensagem em tela
    IF (pr_vlmerbem * vr_tipsplit(1)) <= pr_vlemprst THEN
      pr_dsmensag := 'Atencao! Valor do bem inferior ou igual a ' || vr_tipsplit(1) || ' vezes o valor do emprestimo!';
    END IF;
    
    -- Caso o valor do bem for inferior ou igual a 10 vezes, apresenta mensagem em tela
    IF (pr_vlmerbem * vr_tipsplit(2)) <= pr_vlemprst THEN
      pr_dsmensag := 'Atencao! Valor do bem inferior ou igual a ' || vr_tipsplit(2) || ' vezes o valor do emprestimo!';
      pr_flgsenha := 1;
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em EMPR0005.pc_verifica_msg_garantia: ' || SQLERRM;
                                    
  END pc_verifica_msg_garantia;
  
  PROCEDURE pc_valida_alt_valor_prop(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo da ag�ncia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                    ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Codigo do operador
                                    ,pr_nmdatela IN VARCHAR2              --> Nome datela conectada
                                    ,pr_idorigem IN INTEGER               --> Indicador da origem da chamada
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do associado
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                    ,pr_dtmvtolt IN DATE                  --> Data de Movimentacao
                                    ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero Contrato
                                    ,pr_vlemprst IN crapepr.vlemprst%TYPE --> Numero Contrato
                                    ,pr_flgsenha OUT INTEGER              --> Verifica se solicita a senha
                                    ,pr_dsmensag OUT VARCHAR2             --> Descricao da mensagem de aviso
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2) IS         --> Descric?o da critica
  BEGIN
    /* .............................................................................
    
       Programa: pc_valida_alt_valor_prop                
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Janeiro/2016                        Ultima atualizacao: 
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina "Alterar somente o valor da proposta" para validar os dados
    
       Alteracoes:     
    ............................................................................. */
  
    DECLARE
      CURSOR cr_crapbpr (pr_cdcooper IN crapbpr.cdcooper%type
                        ,pr_nrdconta IN crapbpr.nrdconta%type
                        ,pr_nrctremp IN crapbpr.nrctrpro%type) IS                             
        SELECT crapbpr.vlmerbem,
               crapbpr.dscatbem
          FROM crapbpr
         WHERE crapbpr.cdcooper = pr_cdcooper
           AND crapbpr.nrdconta = pr_nrdconta
           AND crapbpr.nrctrpro = pr_nrctremp
           AND crapbpr.tpctrpro = 90
           AND crapbpr.flgalien = 1
           AND TRIM(crapbpr.dscatbem) IS NOT NULL
      ORDER BY crapbpr.vlmerbem DESC;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      
    BEGIN
      -- Percorre todos os bens, para verificar se apresenta o valor aviso em tela
      FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp) LOOP
                                  
        -- Verifica se apresenta msg das garantias em tela
        pc_verifica_msg_garantia(pr_cdcooper => pr_cdcooper
                                ,pr_dscatbem => rw_crapbpr.dscatbem
				  	 			              ,pr_vlmerbem => rw_crapbpr.vlmerbem
                                ,pr_vlemprst => pr_vlemprst
                                ,pr_flgsenha => pr_flgsenha
                                ,pr_dsmensag => pr_dsmensag
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                                
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Verifica se apresenta o aviso na tela ou solicita senha de coordenador
        IF pr_flgsenha = 1 OR pr_dsmensag IS NOT NULL THEN
          EXIT;
        END IF;
       
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descri��o de erro n�o tratado
        pr_dscritic := 'Erro n�o tratado na EMPR0001.pc_valida_alt_valor_prop --> ' || sqlerrm;
    END;
    
  END pc_valida_alt_valor_prop;
  
  PROCEDURE pc_valida_alt_valor_prop_web(pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                        ,pr_vlemprst IN crapepr.vlemprst%TYPE --> Valor do emprestimo
                                        ,pr_dtmvtolt IN VARCHAR2              --> Movimento atual
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula                                        
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2             --> Descric?o da critica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................
    
       Programa: pc_valida_alt_valor_prop_web                
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Janeiro/2016                        Ultima atualizacao: 
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina "Alterar somente o valor da proposta" para validar os dados
    
       Alteracoes:     
    ............................................................................. */
  
    DECLARE
    
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_flgsenha INTEGER;
      vr_dsmensag VARCHAR2(4000);
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;      
      
    BEGIN
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      -- Valida os dados do valor da proposta
      pc_valida_alt_valor_prop(pr_cdcooper => vr_cdcooper
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_idorigem => vr_idorigem
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_dtmvtolt => TO_DATE(pr_dtmvtolt,'DD/MM/RRRR')
                              ,pr_nrctremp => pr_nrctremp
                              ,pr_vlemprst => pr_vlemprst
                              ,pr_flgsenha => vr_flgsenha
                              ,pr_dsmensag => vr_dsmensag
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
                               
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Gerar exce��o
        RAISE vr_exc_erro;
      END IF;
    
      -- Gera o retorno para o Progress  
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgsenha', pr_tag_cont => vr_flgsenha, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dsmensag', pr_tag_cont => vr_dsmensag, pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descri��o de erro n�o tratado
        pr_dscritic := 'Erro n�o tratado na EMPR0001.pc_valida_alt_valor_prop_web ' ||SQLERRM;
    END;
    
  END pc_valida_alt_valor_prop_web;  
  

END empr0001;
/
