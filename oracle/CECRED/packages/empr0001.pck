CREATE OR REPLACE PACKAGE CECRED."EMPR0001" AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : empr0001
  --  Sistema  : Rotinas gen¿ricas focando nas funcionalidades de empréstimos
  --  Sigla    : EMPR
  --  Autor    : Marcos Ernani Martini
  --  Data     : Fevereiro/2013.                   Ultima atualizacao: 23/08/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle
  --
  -- Alteração : 03/06/2015 - Alterado tipo variavel vllamnto da temptable typ_reg_tab_lancconta
  --                          para trabalhar com mais decimais conforme no progress (Odirlei-AMcom)
  --
  --             12/06/2015 - Adicao de campos para geracao do extrato da portabilidade de credito.
  --                          (Jaison/Diego - SD: 290027)
  --
  --             17/12/2015 - Ajustado precisão dos campos numericos SD375985 (Odirlei-AMcom)
  --
  --             11/05/2016 - Criacao do FIELD vlatraso na typ_reg_dados_epr. (Jaison/James)
  --
  --             26/09/2016 - Adicionado validacao de contratos de acordo na procedure
  --                          pc_valida_pagamentos_geral, Prj. 302 (Jean Michel).
  --
  --             22/02/2017 - Criacao dos FIELDs dsorgrec e dtinictr na typ_reg_dados_epr. (Jonatas-Supero)
  --
  --             31/03/2017 - Ajustado calculo de saldo para nao considerar valores bloqueados.
  --                          Heitor (Mouts) - Melhoria 440
  --
  --             04/04/2017 - Criacao da procedure pc_gera_arq_saldo_devedor para utilizacao na tela RELSDV
  --                          Jean (Mouts)
  --
  --             11/10/2017 - Adicionado campo vliofcpl no XML de retorno da pc_obtem_dados_empresti (Diogo - Mouts - Projeto 410)
  --             11/10/2017 - Liberacao da melhoria 442 (Heitor - Mouts)
  --
  --             17/10/2017 - No processo noturno, considerar tambem os valores bloqueados e que foram liberados
  --                          no dia atual. Como utiliza informacao de saldo da CRAPSDA, esses valores nao estao contemplados.
  --                          Heitor (Mouts) - Chamado 718395
  --
  --             24/01/2018 - Adicionada solicitacao de senha de coordenador para utilizacao do saldo bloqueado no pagamento (Luis Fernando - GFT)
  --
  --             19/04/2018 - Ajustado para so descontar do campo Valores Pagos, historicos novos de abono. Os historicos antigos nao devem descontar.
  --                          Heitor (Mouts) - Prj 324

  --             23/06/2018 - Rename da tabela tbepr_cobranca para tbrecup_cobranca e filtro tpproduto = 0 (Paulo Penteado GFT)
  --              
  --             26/03/2019 - P450 -Rating, substituir a tabela craprnc por tbrisco_operacoes (Elton AMcom)
  --              
  --             25/04/2019 - P450 -Rating, incluir a tabela craprnc quando a coopertativa for 3 - Ailos (Heckmann/AMcom)
  ---------------------------------------------------------------------------------------------------------------
  -- CURSOR para buscar o saldo que será no Extrato PP.
  -- Usado também an rotina PREJ0001
  CURSOR cr_craplem_sld(pr_cdcooper IN craplem.cdcooper%TYPE
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
                         ,craplem.vllanmto * -1
                         ,2013
                         ,craplem.vllanmto * -1
                         ,2014
                         ,craplem.vllanmto * -1
                         ,2304
                         ,craplem.vllanmto * -1
                         ,2305
                         ,craplem.vllanmto * -1
                         ,2306
                         ,craplem.vllanmto * -1
                         ,2307
                         ,craplem.vllanmto * -1
                         ,2535
                         ,craplem.vllanmto * -1
                         ,2536
                         ,craplem.vllanmto * -1
                         ,2591
                         ,craplem.vllanmto * -1
                         ,2592
                         ,craplem.vllanmto * -1
                         ,2593
                         ,craplem.vllanmto * -1
                         ,2594
                         ,craplem.vllanmto * -1
                         ,2597
                         ,craplem.vllanmto * -1
                         ,2598
                         ,craplem.vllanmto * -1
                         ,2599
                         ,craplem.vllanmto * -1
                         ,2600
                         ,craplem.vllanmto * -1
                         ,2601
                         ,craplem.vllanmto * -1
                         ,2602
                         ,craplem.vllanmto * -1
                         ,2603
                         ,craplem.vllanmto * -1
                         ,2604
                         ,craplem.vllanmto * -1
                         ,2605
                         ,craplem.vllanmto * -1
                         ,2606
                         ,craplem.vllanmto * -1)) saldo
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor IN
           (1044, 1039, 1045, 1046, 1057, 1058, 1036, 1059,
            1037, 1038, 1716, 1707, 1714, 1705, 1040, 1041,
            1042, 1043, 2013, 2014, 1036, 2305, 2304, 2536, 2535,
            2306, 2597, 2598, 2307, 2599, 2600, 2601, 2602,
            2591, 2592, 2593, 2594, 2603, 2604, 2605, 2606);
   --
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
    ,portabil VARCHAR2(100)
    ,dsorgrec craplcr.dsorgrec%TYPE
    ,dtinictr DATE
    ,tpatuidx crawepr.tpatuidx%TYPE
    ,idcarenc crawepr.idcarenc%TYPE
    ,dtcarenc crawepr.dtcarenc%TYPE
    ,nrdiacar INTEGER
    ,qttolatr crapepr.qttolatr%TYPE
    ,dsratpro VARCHAR2(30)
    ,dsratatu VARCHAR2(30)
    ,vliofcpl crapepr.vliofcpl%TYPE
    ,idfiniof crapepr.idfiniof%TYPE
    ,vliofepr crapepr.vliofepr%TYPE
    ,vlrtarif crapepr.vltarifa%TYPE
    ,vlrtotal crapepr.vlsdeved%TYPE
    ,vltiofpr crapepr.vltiofpr%TYPE
    ,vlpiofpr crapepr.vlpiofpr%TYPE
    ,cdoperad crapope.cdoperad%TYPE
    ,flintcdc crapcop.flintcdc%TYPE
    ,inintegra_cont INTEGER
    ,tpfinali crapfin.tpfinali%TYPE
    ,vlprecar crawepr.vlprecar%TYPE
    ,nrdiaatr INTEGER
    );

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_dados_epr IS TABLE OF typ_reg_dados_epr INDEX BY VARCHAR2(100);

  /* Tipo que compreende o registro da tab. tempor¿ria tt-pagamentos-parcelas */
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
    ,vliofcpl number(12,2)
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
    ,vliofcpl crappep.vliofcpl%type
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

  /* Buscar a configuracao de empr¿stimo cfme a empresa da conta */
  PROCEDURE pc_config_empresti_empresa(pr_cdcooper IN crapcop.cdcooper%TYPE --> C¿digo da Cooperativa
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data corrente
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da conta do empr¿stim
                                      ,pr_cdempres IN crapepr.cdempres%TYPE DEFAULT NULL --> Empresa do empr¿stimo ou se n¿o passada do cadastro
                                      ,pr_dtcalcul OUT DATE --> Data calculada de pagamento
                                      ,pr_diapagto OUT INTEGER --> Dia de pagamento das parcelas
                                      ,pr_flgfolha OUT BOOLEAN --> Flag de desconto em folha S/N
                                      ,pr_ddmesnov OUT INTEGER --> Configura¿¿o para m¿s novo
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> C¿digo da critica
                                      ,pr_des_erro OUT VARCHAR2); --> Retorno de Erro

  /* Processar a rotina de leitura de pagamentos do emprestimo. */
  PROCEDURE pc_leitura_lem(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa
                          ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> C¿digo do programa corrente
                          ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par¿metro (CRAPDAT)
                          ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> N¿mero da conta
                          ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero ctrato empr¿stimo
                          ,pr_dtcalcul   IN DATE --> Data para calculo do empr¿stimo
                          ,pr_diapagto   IN OUT INTEGER --> Dia para pagamento
                          ,pr_txdjuros   IN OUT crapepr.txjuremp%TYPE --> Taxa de juros aplicada
                          ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de presta¿¿es calculadas at¿ momento
                          ,pr_qtprepag   IN OUT crapepr.qtprepag%TYPE --> Quantidade de presta¿¿es paga at¿ momento
                          ,pr_vlprepag   IN OUT craplem.vllanmto%TYPE --> Valor acumulado pago no m¿s
                          ,pr_vljurmes   IN OUT crapepr.vljurmes%TYPE --> Juros no m¿s corrente
                          ,pr_vljuracu   IN OUT crapepr.vljuracu%TYPE --> Juros acumulados total
                          ,pr_vlsdeved   IN OUT crapepr.vlsdeved%TYPE --> Saldo devedor acumulado
                          ,pr_dtultpag   IN OUT crapepr.dtultpag%TYPE --> Ultimo dia de pagamento das presta¿¿es
                          ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> C¿digo da cr¿tica tratada
                          ,pr_des_erro   OUT VARCHAR2); --> Descri¿¿o de critica tratada

  /* Processar a rotina de leitura de pagamentos do emprestimo. */
  PROCEDURE pc_leitura_lem_car(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Código do programa corrente
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
                           ,pr_diarefju IN INTEGER -- Dia da data de refer¿ncia da ¿ltima vez que rodou juros
                           ,pr_mesrefju IN INTEGER -- Mes da data de refer¿ncia da ¿ltima vez que rodou juros
                           ,pr_anorefju IN INTEGER -- Ano da data de refer¿ncia da ¿ltima vez que rodou juros
                           ,pr_diafinal IN OUT INTEGER -- Dia data final
                           ,pr_mesfinal IN OUT INTEGER -- Mes data final
                           ,pr_anofinal IN OUT INTEGER -- Ano data final
                           ,pr_qtdedias OUT INTEGER); -- Quantidade de dias calculada

  /* Calculo de juros normais */
  PROCEDURE pc_calc_juros_normais_total(pr_vlpagpar IN NUMBER -- Valor a pagar originalmente
                                       ,pr_txmensal IN NUMBER -- Valor da taxa mensal
                                       ,pr_qtdiajur IN INTEGER -- Quantidade de dias de aplica¿¿o de juros
                                       ,pr_vljinpar OUT NUMBER); -- Valor com os juros aplicados

  /* Procedure para calcular valor antecipado de parcelas de empr¿stimo */
  PROCEDURE pc_calc_antecipa_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> C¿digo da ag¿ncia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N¿mero do caixa
                                    ,pr_dtvencto IN crappep.dtvencto%TYPE --> Data do vencimento
                                    ,pr_vlsdvpar IN crappep.vlsdvpar%TYPE --> Valor devido parcela
                                    ,pr_txmensal IN crapepr.txmensal%TYPE --> Taxa aplicada ao empr¿stimo
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento atual
                                    ,pr_dtdpagto IN crapdat.dtmvtolt%TYPE --> Data de pagamento
                                    ,pr_vlatupar OUT crappep.vlsdvpar%TYPE --> Valor atualizado da parcela
                                    ,pr_vldespar OUT crappep.vlsdvpar%TYPE --> Valor desconto da parcela
                                    ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro); --> Tabela com poss¿ves erros

  /* Calculo de valor atualizado de parcelas de empr¿stimo em atraso */
  PROCEDURE pc_calc_atraso_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                  ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                  ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                  ,pr_idorigem IN INTEGER --> Id do módulo de sistema
                                  ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                  ,pr_flgerlog IN VARCHAR2 --> Indicador S/N para geração de log
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                  ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                  ,pr_vlpagpar IN NUMBER --> Valor a pagar originalmente
                                  ,pr_vlpagsld OUT NUMBER --> Saldo a pagar após multa e juros
                                  ,pr_vlatupar OUT NUMBER --> Valor atual da parcela
                                  ,pr_vlmtapar OUT NUMBER --> Valor de multa
                                  ,pr_vljinpar OUT NUMBER --> Valor dos juros
                                  ,pr_vlmrapar OUT NUMBER --> Valor de mora
                                  ,pr_vliofcpl OUT NUMBER --> Valor de IOF de atraso
                                  ,pr_vljinp59 OUT NUMBER --> Juros quando período inferior a 59 dias
                                  ,pr_vljinp60 OUT NUMBER --> Juros quando período igual ou superior a 60 dias
                                  ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro); --> Tabela com possíveis erros

  /* Busca dos pagamentos das parcelas de empr¿stimo */
  PROCEDURE pc_busca_pgto_parcelas(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_cdagenci        IN crapass.cdagenci%TYPE --> C¿digo da ag¿ncia
                                  ,pr_nrdcaixa        IN craperr.nrdcaixa%TYPE --> N¿mero do caixa
                                  ,pr_cdoperad        IN crapdev.cdoperad%TYPE --> C¿digo do Operador
                                  ,pr_nmdatela        IN VARCHAR2 --> Nome da tela
                                  ,pr_idorigem        IN INTEGER --> Id do m¿dulo de sistema
                                  ,pr_nrdconta        IN crapepr.nrdconta%TYPE --> N¿mero da conta
                                  ,pr_idseqttl        IN crapttl.idseqttl%TYPE --> Seq titula
                                  ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                  ,pr_flgerlog        IN VARCHAR2 --> Indicador S/N para gera¿¿o de log
                                  ,pr_nrctremp        IN crapepr.nrctremp%TYPE --> N¿mero do contrato de empr¿stimo
                                  ,pr_dtmvtoan        IN crapdat.dtmvtolt%TYPE --> Data anterior
                                  ,pr_nrparepr        IN INTEGER --> N¿mero parcelas empr¿stimo
                                  ,pr_des_reto        OUT VARCHAR --> Retorno OK / NOK
                                  ,pr_tab_erro        OUT gene0001.typ_tab_erro --> Tabela com poss¿ves erros
                                  ,pr_tab_pgto_parcel OUT empr0001.typ_tab_pgto_parcel --> Tabela com registros de pagamentos
                                  ,pr_tab_calculado   OUT empr0001.typ_tab_calculado); --> Tabela com totais calculados

  /* Calculo de saldo devedor em emprestimos baseado na includes/lelem.i. */
  PROCEDURE pc_calc_saldo_deved_epr_lem(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Código do programa corrente
                                       ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad   IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                                       ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero ctrato empréstimo
                                       ,pr_idorigem   IN INTEGER --> Id do módulo de sistema
                                       ,pr_txdjuros   IN crapepr.txjuremp%TYPE --> Taxa de juros aplicada
                                       ,pr_dtcalcul   IN DATE --> Data para calculo do empréstimo
                                       ,pr_diapagto   IN OUT INTEGER --> Dia para pagamento
                                       ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de prestações calculadas até momento
                                       ,pr_vlprepag   IN OUT NUMBER --> Valor acumulado pago no mês
                                       ,pr_vlpreapg   IN OUT NUMBER --> Valor a pagar
                                       ,pr_vljurmes   IN OUT NUMBER --> Juros no mês corrente
                                       ,pr_vljuracu   IN OUT NUMBER --> Juros acumulados total
                                       ,pr_vlsdeved   IN OUT NUMBER --> Saldo devedor acumulado
                                       ,pr_dtultpag   IN OUT crapepr.dtultpag%TYPE --> Ultimo dia de pagamento das prestações
                                       ,pr_vlmrapar   IN OUT crappep.vlmrapar%TYPE --> Valor do Juros de Mora
                                       ,pr_vlmtapar   IN OUT crappep.vlmtapar%TYPE --> Valor da Multa
                                       ,pr_vliofcpl   IN OUT crappep.vliofcpl%TYPE --> Valor da Multa
                                       ,pr_vlprvenc   IN OUT NUMBER --> Valor a parcela a vencer
                                       ,pr_vlpraven   IN OUT NUMBER --> Valor da parcela vencida
                                       ,pr_flgerlog   IN VARCHAR2 --> Gerar log S/N
                                       ,pr_des_reto   OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro   OUT gene0001.typ_tab_erro); --> Tabela com possíves erros

  /* Procedure para obter dados de emprestimos do associado */
  PROCEDURE pc_obtem_dados_empresti(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                   ,pr_cdagenci       IN crapass.cdagenci%TYPE --> Codigo da ag¿ncia
                                   ,pr_nrdcaixa       IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                   ,pr_cdoperad       IN crapdev.cdoperad%TYPE --> Codigo do operador
                                   ,pr_nmdatela       IN VARCHAR2 --> Nome datela conectada
                                   ,pr_idorigem       IN INTEGER --> Indicador da origem da chamada
                                   ,pr_nrdconta       IN crapass.nrdconta%TYPE --> Conta do associado
                                   ,pr_idseqttl       IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                   ,pr_rw_crapdat     IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par¿metro (CRAPDAT)
                                   ,pr_dtcalcul       IN DATE --> Data solicitada do calculo
                                   ,pr_nrctremp       IN crapepr.nrctremp%TYPE --> Numero contrato empr¿stimo
                                   ,pr_cdprogra       IN crapprg.cdprogra%TYPE --> Programa conectado
                                   ,pr_inusatab       IN BOOLEAN --> Indicador de utiliza¿¿o da tabela de juros
                                   ,pr_flgerlog       IN VARCHAR2 --> Gerar log S/N
                                   ,pr_flgcondc       IN BOOLEAN --> Mostrar emprestimos liquidados sem prejuizo
                                   ,pr_nmprimtl       IN crapass.nmprimtl%TYPE --> Nome Primeiro Titular
                                   ,pr_tab_parempctl  IN craptab.dstextab%TYPE --> Dados tabela parametro
                                   ,pr_tab_digitaliza IN craptab.dstextab%TYPE --> Dados tabela parametro
                                   ,pr_nriniseq       IN INTEGER --> Numero inicial da paginacao
                                   ,pr_nrregist       IN INTEGER --> Numero de registros por pagina
                                   ,pr_qtregist       OUT INTEGER --> Qtde total de registros
                                   ,pr_tab_dados_epr  OUT typ_tab_dados_epr --> Saida com os dados do empr¿stimo
                                   ,pr_des_reto       OUT VARCHAR --> Retorno OK / NOK
                                   ,pr_tab_erro       OUT gene0001.typ_tab_erro); --> Tabela com poss¿ves erros

  /* Procedure para obter dados de emprestimos do associado - Chamada AyllosWeb */
  PROCEDURE pc_obtem_dados_empresti_web(  pr_nrdconta       IN crapass.nrdconta%TYPE    --> Conta do associado
                                         ,pr_idseqttl       IN crapttl.idseqttl%TYPE    --> Sequencia de titularidade da conta
                                         ,pr_dtcalcul       IN DATE                     --> Data solicitada do calculo
                                         ,pr_nrctremp       IN crapepr.nrctremp%TYPE    --> Número contrato empréstimo
                                         ,pr_cdprogra       IN crapprg.cdprogra%TYPE    --> Programa conectado
                                         ,pr_flgerlog       IN VARCHAR2                 --> Gerar log S/N
                                         ,pr_flgcondc       IN INTEGER                  --> Mostrar emprestimos liquidados sem prejuizo
                                         ,pr_nriniseq       IN INTEGER                  --> Numero inicial da paginacao
                                         ,pr_nrregist       IN INTEGER                  --> Numero de registros por pagina
                                         ,pr_xmllog         IN VARCHAR2                 --> XML com informações de LOG
                                          -- OUT
                                         ,pr_cdcritic OUT PLS_INTEGER                   --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2                      --> Descric?o da critica
                                         ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);                    --> Erros do processo

  /* Calcular o saldo devedor do emprestimo */
  PROCEDURE pc_calc_saldo_epr(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                             ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par¿metro (CRAPDAT)
                             ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Programa que solicitou o calculo
                             ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta do empr¿stimo
                             ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato do empr¿stimo
                             ,pr_inusatab   IN BOOLEAN --> Indicador de utiliza¿¿o da tabela de juros
                             ,pr_vlsdeved   OUT NUMBER --> Saldo devedor do empr¿stimo
                             ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de parcelas do empr¿stimo
                             ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Codigo de critica encontrada
                             ,pr_des_erro   OUT VARCHAR2); --> Retorno de Erro


  /* Procedure para calcular saldo devedor de emprestimos */
  PROCEDURE pc_saldo_devedor_epr(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Codigo da ag¿ncia
                                ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                ,pr_cdoperad   IN crapdev.cdoperad%TYPE --> Codigo do operador
                                ,pr_nmdatela   IN VARCHAR2 --> Nome datela conectada
                                ,pr_idorigem   IN INTEGER --> Indicador da origem da chamada
                                ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par¿metro (CRAPDAT)
                                ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero contrato empr¿stimo
                                ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Programa conectado
                                ,pr_inusatab   IN BOOLEAN --> Indicador de utiliza¿¿o da tabela
                                ,pr_flgerlog   IN VARCHAR2 --> Gerar log S/N
                                ,pr_vlsdeved   IN OUT NUMBER --> Saldo devedor calculado
                                ,pr_vltotpre   IN OUT NUMBER --> Valor total das presta¿¿es
                                ,pr_qtprecal   IN OUT crapepr.qtprecal%TYPE --> Parcelas calculadas
                                ,pr_des_reto   OUT VARCHAR --> Retorno OK / NOK
                                ,pr_tab_erro   OUT gene0001.typ_tab_erro); --> Tabela com poss¿ves erros

  PROCEDURE pc_saldo_devedor_epr_car(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Código da agência
                                    ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> Número do caixa
                                    ,pr_cdoperad   IN crapdev.cdoperad%TYPE --> Código do operador
                                    ,pr_nmdatela   IN VARCHAR2 --> Nome datela conectada
                                    ,pr_idorigem   IN INTEGER --> Indicador da origem da chamada
                                    ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                    ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                    ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Número contrato empréstimo
                                    ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Programa conectado
                                    ,pr_flgerlog   IN VARCHAR2 --> Gerar log S/N
                                    ,pr_vlsdeved   IN OUT NUMBER --> Saldo devedor calculado
                                    ,pr_vltotpre   IN OUT NUMBER --> Valor total das prestações
                                    ,pr_qtprecal   IN OUT crapepr.qtprecal%TYPE --> Parcelas calculadas
                                    ,pr_des_reto   OUT VARCHAR2 --> Retorno OK / NOK
                                    ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Código da crítica
                                    ,pr_dscritic   OUT crapcri.dscritic%TYPE); --> Descrição da crítica

  /* Calcular a quantidade de dias que o emprestimo está em atraso */
  FUNCTION fn_busca_dias_atraso_epr(pr_cdcooper IN crappep.cdcooper%TYPE --> Código da Cooperativa
                                   ,pr_nrdconta IN crappep.nrdconta%TYPE --> Numero da Conta do empréstimo
                                   ,pr_nrctremp IN crappep.nrctremp%TYPE --> Numero do Contrato de empréstimo
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento Atual
                                   ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) --> Data do Movimento Anterior
   RETURN INTEGER;

  /* Rotina de calculo de dias do ultimo pagamento de emprestimos em atraso*/
  PROCEDURE pc_calc_dias_atraso(pr_cdcooper   IN crapepr.cdcooper%TYPE --> Codigo da cooperativa
                               ,pr_cdprogra   IN VARCHAR2 --> Nome do programa que est¿ executando
                               ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta do emprestimo
                               ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                               ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par¿metro (CRAPDAT)
                               ,pr_inusatab   IN BOOLEAN --> Indicador de utiliza¿¿o da tabela de juros
                               ,pr_vlsdeved   OUT NUMBER --> Valor do saldo devedor
                               ,pr_qtprecal   OUT NUMBER --> Quantidade de Parcelas
                               ,pr_qtdiaatr   OUT NUMBER --> Quantidade de dias em atraso
                               ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Codigo de critica encontrada
                               ,pr_des_erro   OUT VARCHAR2); --> Retorno de erro

  /* Criar o lancamento na Conta Corrente  */
  PROCEDURE pc_cria_lancamento_cc_chave(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_cdbccxlt IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_cdpactra IN INTEGER --> P.A. da transação
                                       ,pr_nrdolote IN craplot.nrdolote%TYPE --> Numero do Lote
                                       ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo historico
                                       ,pr_vllanmto IN NUMBER --> Valor da parcela emprestimo
                                       ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                       ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                       ,pr_nrseqava IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                       ,pr_idlautom IN NUMBER DEFAULT 0 --> sequencia criada pela craplau
                                       ,pr_nrseqdig OUT INTEGER  --> Número sequencia
                                       ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro);

  /* Criar o lancamento na Conta Corrente  */
  PROCEDURE pc_cria_lancamento_cc(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                 ,pr_cdbccxlt IN craperr.nrdcaixa%TYPE --> Número do caixa
                                 ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                 ,pr_cdpactra IN INTEGER --> P.A. da transação
                                 ,pr_nrdolote IN craplot.nrdolote%TYPE --> Numero do Lote
                                 ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                 ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo historico
                                 ,pr_vllanmto IN NUMBER --> Valor da parcela emprestimo
                                 ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                 ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                 ,pr_nrseqava IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                 ,pr_idlautom IN NUMBER DEFAULT 0 --> sequencia criada pela craplau
                                 ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro);

  --Procedure para Criar lancamento e atualiza o lote
  PROCEDURE pc_cria_lancamento_lem_chave(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
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
                                        ,pr_qtdiacal IN NUMBER DEFAULT 0 --> Quantidade dias usado no calculo
                                        ,pr_vltaxprd IN NUMBER DEFAULT 0 --> Valor da Taxa no Periodo
                                        ,pr_nrseqdig OUT INTEGER --> Numero de sequencia
                                        ,pr_cdcritic OUT INTEGER --Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2);

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
                                  ,pr_qtdiacal IN NUMBER DEFAULT 0 --> Quantidade dias usado no calculo
                                  ,pr_vltaxprd IN NUMBER DEFAULT 0 --> Valor da Taxa no Periodo
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
                                      ,pr_efetresg         IN VARCHAR2 DEFAULT 'N'
                                      ,pr_vlsomato         OUT NUMBER --Soma Total
                                      ,pr_vlresgat         OUT NUMBER --Soma
                                      ,pr_tab_erro         OUT gene0001.typ_tab_erro --tabela Erros
                                      ,pr_des_reto         OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_msg_confirma OUT typ_tab_msg_confirma); --Tabela Confirmacao

  /* Validar pagamento Atrasado das parcelas de empréstimo */
  PROCEDURE pc_valida_pagto_atr_parcel(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                      ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                      ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                      ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                      ,pr_flgerlog IN VARCHAR2              --> Indicador S/N para geração de log
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                      ,pr_nrparepr IN INTEGER               --> Número parcelas empréstimo
                                      ,pr_vlpagpar IN NUMBER                --> Valor a pagar parcela
                                      ,pr_vlpagsld OUT NUMBER               --> Valor Pago Saldo
                                      ,pr_vlatupar OUT NUMBER               --> Valor Atual Parcela
                                      ,pr_vlmtapar OUT NUMBER               --> Valor Multa Parcela
                                      ,pr_vljinpar OUT NUMBER               --> Valor Juros parcela
                                      ,pr_vlmrapar OUT NUMBER               --> Valor ???
                                      ,pr_vliofcpl OUT NUMBER --> Valor ???
                                      ,pr_des_reto OUT VARCHAR              --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro); --> Tabela com possíves erros

  /* Busca dos pagamentos das parcelas de empréstimo */

  PROCEDURE pc_efetiva_pagto_atr_parcel(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                       ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                       ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                       ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                       ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                       ,pr_nrparepr    IN INTEGER --> Número parcelas empréstimo
                                       ,pr_vlpagpar    IN NUMBER --> Valor a pagar parcela
                                       ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                       ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                       ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro    OUT gene0001.typ_tab_erro); --> Tabela com possíves erros

  /* Verifica se tem uma parcela anterior nao liquida e ja vencida  */
  PROCEDURE pc_verifica_parcel_anteriores(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                         ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                         ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                         ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                         ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                         ,pr_dscritic OUT VARCHAR2); --> Descricao Erro

  /* Efetivar o pagamento da parcela  */
  PROCEDURE pc_efetiva_pagto_parcela(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                    ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                    ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                    ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                    ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                    ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                    ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                    ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                    ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                    ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                    ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                    ,pr_nrparepr    IN INTEGER --> Número parcelas empréstimo
                                    ,pr_vlparepr    IN NUMBER --> Valor da parcela emprestimo
                                    ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                    ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                    ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro    OUT gene0001.typ_tab_erro); --> Tabela com possíves erros

  /* Rotina referente a consulta de produtos cadastrados */
  PROCEDURE pc_consulta_antecipacao(pr_nrdconta IN crapass.nrdconta%TYPE --> Codigo do Produto
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Codigo do Produto
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
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
                                   ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG--> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);

  /* Procedure para validar as operacoes que serao incluidas no produto TR */
  PROCEDURE pc_valida_inclusao_tr(pr_cdcooper IN craplcr.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Codigo da linha de credito
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de inclusao
                                 ,pr_qtpreemp IN crapepr.qtpreemp%TYPE --> Quantidade de Prestacoes
                                 ,pr_flgpagto IN crapepr.flgpagto%TYPE --> Folha
                                 ,pr_dtdpagto IN crapepr.dtdpagto%TYPE --> Data de Pagamento
                                 ,pr_cdfinemp IN crapepr.cdfinemp%TYPE --> Finalidade
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Operador
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2);  --> Descrição da crítica

  /* Efetuar a Liquidacao do Emprestimo  */
  PROCEDURE pc_efetua_liquidacao_empr(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                     ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                     ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                     ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                     ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                     ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                     ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                     ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                     ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                     ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                     ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                     ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                     ,pr_dtmvtoan    IN DATE     --> Data Movimento Anterior
                                     ,pr_ehprcbat    IN VARCHAR2 --> Indicador Processo Batch (S/N)
                                     ,pr_tab_pgto_parcel IN OUT empr0001.typ_tab_pgto_parcel --Tabela com Pagamentos de Parcelas
                                     ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                     ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                     ,pr_des_erro    OUT VARCHAR --> Retorno OK / NOK
                                     ,pr_tab_erro    OUT gene0001.typ_tab_erro); --> Tabela com possíves erros
  /* Liquidação no mesmo dia */
  PROCEDURE pc_liq_mesmo_dia_web(pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                ,pr_dtmvtolt    IN VARCHAR2              --> Movimento atual
                                ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para geração de log
                                ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                ,pr_xmllog   IN VARCHAR2                 --> XML com informac?es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER             --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                --> Descric?o da critica
                                ,pr_retxml   IN OUT NOCOPY XMLType       --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);

  --Procedure de pagamentos de parcelas
  PROCEDURE pc_gera_pagamentos_parcelas( pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                        ,pr_cdoperad IN VARCHAR2              --> Código do operador
                                        ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                        ,pr_idorigem IN INTEGER               --> Id Origem do sistemas
                                        ,pr_cdpactra IN INTEGER               --> P.A. da transação
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
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro);--> Tabela com possíves erros

  -- Checagem de parcelas antecipadas
  PROCEDURE pc_verifica_parcelas_antecipa(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                                         ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Conta
                                         ,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Contrato
                                         ,pr_nrparepr IN crappep.nrparepr%TYPE  --> Nr. da parcela
                                         ,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE  --> Data de movimento
                                         ,pr_des_reto OUT VARCHAR2              --> Retorno OK/NOK
                                         ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

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
  -- Verificação da mensagem de garantia
  PROCEDURE pc_verifica_msg_garantia(pr_cdcooper IN crapbpr.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_dscatbem IN crapbpr.dscatbem%TYPE --> Descricao da categoria do bem
                                    ,pr_vlmerbem IN crapbpr.vlmerbem%TYPE --> Valor de mercado do bem
                                    ,pr_vlemprst IN crapepr.vlemprst%TYPE --> Valor do emprestimo
                                    ,pr_flgsenha OUT INTEGER              --> Verifica se solicita a senha
                                    ,pr_dsmensag OUT VARCHAR2             --> Descricao da mensagem de aviso
                                    ,pr_cdcritic OUT INTEGER              --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Validar alteração do valor da proposta
  PROCEDURE pc_valida_alt_valor_prop(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo da ag¿ncia
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

  -- Interface chamada validação da alteração do valor da proposta
  PROCEDURE pc_valida_alt_valor_prop_web(pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                        ,pr_vlemprst IN crapepr.vlemprst%TYPE --> Valor do emprestimo
                                        ,pr_dtmvtolt IN VARCHAR2              --> Movimento atual
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2             --> Descric?o da critica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);

  -- Valida imóveis
  PROCEDURE pc_valida_imoveis_epr(pr_cdcooper  IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                                 ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta do associado
                                 ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero Contrato
                                 ,pr_flimovel OUT INTEGER               --> Retorna se possui ou não imóveis pendentes de preenchimento
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2);            --> Descricão da critica

  -- Gera arquivo saldo devedor
 PROCEDURE pc_gera_arq_saldo_devedor(pr_arquivo_ent in varchar2
                                     ,pr_arquivo_sai in varchar2
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2             --> Descric?o da critica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);

  /* Retorna o tipo de finalide */
  FUNCTION fn_tipo_finalidade(pr_cdcooper IN crapfin.cdcooper%TYPE  --> Código da Cooperativa
                             ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) --> Código de finalidade
   RETURN INTEGER;

  PROCEDURE pc_busca_motivos_anulacao(pr_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE --> Tipo do produto
                                     ,pr_nrdconta  IN tbmotivo_anulacao.nrdconta%TYPE
                                     ,pr_nrctrato  IN tbmotivo_anulacao.nrctrato%TYPE
                                     ,pr_tpctrlim  IN tbmotivo_anulacao.tpctrlim%TYPE
                                     ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_motivo_anulacao(pr_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE --> Tipo do produto
                                    ,pr_nrdconta  IN tbmotivo_anulacao.nrdconta%TYPE
                                    ,pr_nrctrato  IN tbmotivo_anulacao.nrctrato%TYPE
                                    ,pr_tpctrlim  IN tbmotivo_anulacao.tpctrlim%TYPE
                                    ,pr_cdmotivo  IN VARCHAR2
                                    ,pr_dsmotivo  IN VARCHAR2
                                    ,pr_dsobservacao IN VARCHAR2
                                    ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_insere_motivo_anulacao(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                     ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Código da agência
                                     ,pr_nrdcaixa  IN craperr.nrdcaixa%TYPE --> Número do caixa
                                     ,pr_cdoperad  IN crapdev.cdoperad%TYPE --> Código do Operador
                                     ,pr_nmdatela  IN VARCHAR2 --> Nome da tela
                                     ,pr_idorigem  IN INTEGER --> Id do módulo de sistema
                                     ,pr_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE --> Tipo do produto
                                     ,pr_nrdconta  IN tbmotivo_anulacao.nrdconta%TYPE
                                     ,pr_nrctrato  IN tbmotivo_anulacao.nrctrato%TYPE
                                     ,pr_tpctrlim  IN tbmotivo_anulacao.tpctrlim%TYPE
                                     ,pr_cdmotivo  IN VARCHAR2
                                     ,pr_dsmotivo  IN VARCHAR2
                                     ,pr_dsobservacao IN VARCHAR2
                                     ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_des_erro  OUT VARCHAR2);--> Erros do processo


END empr0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED."EMPR0001" AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : empr0001
  --  Sistema  : Rotinas genéricas focando nas funcionalidades de empréstimos
  --  Sigla    : EMPR
  --  Autor    : Marcos Ernani Martini
  --  Data     : Fevereiro/2013.                   Ultima atualizacao: 27/12/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle
  --
  -- Alterações: 12/09/2013 - Ajustes na capacidade das variaveis (Gabriel).
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
  --             27/11/2015 - Ajustado pc_valida_pagamentos_geral para inicializar variável
  --                          vr_flgtrans e ROUND na pr_vlsomato. Criado procedure
  --                          pc_valida_pagto_geral_prog (Douglas - Chamado 285228)
  --
  --             02/02/2016 - Adicionado validação na procedure pc_busca_pgto_parcelas_prefix
  --                          para verificar se o emprestimo já está liquidado 389736 (Kelvin).
  --
  --
  --             31/03/2016 - Ajustes savepoints para um savepoint de um procedimento sobrepor o outro
  --                          e ao realizar o rollback fazer apenas do ultimo savepoint SD352945 (Odirlei - AMcom)
  --
  --             16/11/2016 - Realizado ajuste para corrigir o problema ao abrir o detalhamento
  --                          do emprestimo na tela prestações, conforme solicitado no chamado
  --                          553330. (Kelvin)
  --
  --             28/11/2016 - P341 - Automatização BACENJUD - Alterado para validar o departamento à partir
  --                          do código e não mais pela descrição (Renato Darosci - Supero)
  --
  --             26/09/2016 - Adicionado validacao de contratos de acordo na procedure
  --                          pc_valida_pagamentos_geral, Prj. 302 (Jean Michel).
  --
  --             25/04/2017 - na rotina pc_efetiva_pagto_parc_lem retornar valor pro rowtype da crapepr na hora
  --                          do update qdo cai na validacao do vr_ehmensal pois qdo ia atualizar o valor novamente
  --                          a crapepr estava ficando com valor incorreto (Tiago/Thiago SD644598)
  --
  --             05/05/2017 - Ajuste para gravar o idlautom (Lucas Ranghetti M338.1)
  --
  --             12/09/2017 - #749442 Alterado o tipo da variável e parametro qtprepag das
  --                          rotinas empr0001.pc_leitura_lem e pc_leitura_lem_car para
  --                          crapepr.qtprecal para suportar a quantidade de parcelas (Carlos)

  --             31/10/2017 - #778578 Na rotina pc_valida_pagto_atr_parcel, ao criticar
  --                          "Valor informado para pagamento maior que valor da parcela" informar
  --                          cdcritic 1033 para o job crps750 não logar a mensagem. (Carlos)
  --             19/10/2017 - adicionado campo vliofcpl no xml de retorno da pc_obtem_dados_empresti
  --                          (Diogo - MoutS - Proj 410 - RF 41 / 42)
  --             23/08/2018 - PRJ 438 - Gravação e Alteração de motivos de anulação de emprestimos e limite de credito
  --
  --
  --             05/06/2018 - P450 - Alteração INSERT na craplcm pela chamada da rotina lanc0001.pc_gerar_lancamento_conta
  --                          Josiane Stiehler- AMcom
  --
  --             27/12/2018 - Ajuste no tratamento das contas corrente em prejuízo (substituição da verificação através
  --                          do parâmetro "pr_nmdatela" pelo uso da função "PREJ0003.fn_verifica_preju_conta".
  --                          P450 - Reginaldo/AMcom
  --
  --             04/01/2019 - chamado INC0027294 (Fabio-Amcom)
  --
  --             19/03/2019 - Alteração na "pc_efetua_liquidacao_empr" para incluir tratamento para conta corrente 
  --                          em prejuízo (débito da conta transitória)
  --                          (Reginaldo/AMcom - P450)  	                               
  ---------------------------------------------------------------------------------------------------------------

  /* Tratamento de erro */
  vr_des_erro VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  /* Descrição e código da critica */
  --vr_cdcritic crapcri.cdcritic%TYPE;
  --vr_dscritic VARCHAR2(4000);

  /* Erro em chamadas da pc_gera_erro */
  vr_des_reto VARCHAR2(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  /* Tipo que compreende o registro de configuração DIADOPAGTO */
  TYPE typ_reg_diadopagto IS RECORD(
     diapgtom INTEGER --> Dia pagamento mensalista
    ,diapgtoh INTEGER --> Dia pagamento horista
    ,flgfolha INTEGER --> Desconto em folha
    ,ddmesnov INTEGER); --> Configuração de mês novo
  /* Definição de tabela que compreenderá os registros acima declarados */
  TYPE typ_tab_diadopagto IS TABLE OF typ_reg_diadopagto INDEX BY VARCHAR2(15);
  /* Variável que armazenará uma instancia da tabela */
  vr_tab_diadopagto typ_tab_diadopagto;

  /* Cursor genérico de parametrização */
  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nmsistem IN craptab.nmsistem%TYPE
                   ,pr_tptabela IN craptab.tptabela%TYPE
                   ,pr_cdempres IN craptab.cdempres%TYPE
                   ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
    SELECT tab.dstextab
          ,tab.tpregist
          ,tab.ROWID
      FROM craptab tab
     WHERE tab.cdcooper = pr_cdcooper
           AND UPPER(tab.nmsistem) = pr_nmsistem
           AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres = pr_cdempres
           AND UPPER(tab.cdacesso) = pr_cdacesso;
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
          ,crawepr.idcobope
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
                          ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Código do programa corrente
                          ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                          ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Número da conta
                          ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero ctrato empréstimo
                          ,pr_dtcalcul   IN DATE --> Data para calculo do empréstimo
                          ,pr_diapagto   IN OUT INTEGER --> Dia para pagamento
                          ,pr_txdjuros   IN OUT crapepr.txjuremp%TYPE --> Taxa de juros aplicada
                          ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de prestações calculadas até momento
                          ,pr_qtprepag   IN OUT crapepr.qtprepag%TYPE --> Quantidade de prestações paga até momento
                          ,pr_vlprepag   IN OUT craplem.vllanmto%TYPE --> Valor acumulado pago no mês
                          ,pr_vljurmes   IN OUT crapepr.vljurmes%TYPE --> Juros no mês corrente
                          ,pr_vljuracu   IN OUT crapepr.vljuracu%TYPE --> Juros acumulados total
                          ,pr_vlsdeved   IN OUT crapepr.vlsdeved%TYPE --> Saldo devedor acumulado
                          ,pr_dtultpag   IN OUT crapepr.dtultpag%TYPE --> Ultimo dia de pagamento das prestações
                          ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Código da crítica tratada
                          ,pr_des_erro   OUT VARCHAR2) IS --> Descrição de critica tratada

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
    --               13/11/2012 - Conversão Progress --> Oracle PLSQL (Marcos - Supero)
    -- .............................................................................
    DECLARE
      -- Cursor para busca dos dados de empréstimo
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

      -- Variáveis auxiliares ao cálculo
      vr_dtmvtolt crapdat.dtmvtolt%TYPE; --> Data de movimento auxiliar
      vr_dtmesant crapdat.dtmvtolt%TYPE; --> Data do mês anterior ao movimento
      vr_flctamig BOOLEAN; --> Conta migrada entre cooperativas
      vr_nrdiacal INTEGER; --> Número de dias para o cálculo
      vr_nrdiames INTEGER; --> Número de dias para o cálculo no mês corrente
      vr_nrdiaprx INTEGER; --> Número de dias para o cálculo no próximo mês
      vr_inhst093 BOOLEAN; --> ???
      TYPE vr_tab_vlrpgmes IS TABLE OF crapepr.vlpreemp%TYPE INDEX BY BINARY_INTEGER;
      vr_vet_vlrpgmes vr_tab_vlrpgmes; --> Vetor e tipo para acumulo de pagamentos no mês
      vr_qtdpgmes     INTEGER; --> Indice de prestações
      vr_qtprepag     NUMBER(18, 4); --> Qtde paga de prestações no mês
      vr_exipgmes     BOOLEAN; --> Teste para busca no vetor de pagamentos
      vr_vljurmes     NUMBER; --> Juros no mês corrente
      -- Verificar se existe registro de conta transferida entre
      -- cooperativas com tipo de transferência = 1 (Conta Corrente)
      CURSOR cr_craptco IS
        SELECT 1
          FROM craptco tco
         WHERE tco.cdcopant = pr_cdcooper
               AND tco.nrctaant = rw_crapepr.nrdconta
               AND tco.tpctatrf = 1
               AND tco.flgativo = 1; --> True
      vr_ind_tco NUMBER(1);
      -- Buscar informações de pagamentos do empréstimos
      --   -> Enviado um tipo de histórico para busca a partir dele
      CURSOR cr_craplem_his(pr_cdhistor IN craplem.cdhistor%TYPE) IS
        SELECT 1
          FROM craplem lem
         WHERE lem.cdcooper = pr_cdcooper
               AND lem.nrdconta = rw_crapepr.nrdconta
               AND lem.nrctremp = rw_crapepr.nrctremp
               AND lem.cdhistor = pr_cdhistor;
      vr_fllemhis NUMBER;
      -- Buscar informações de pagamentos do empréstimos
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
      -- Busca dos detalhes do empréstimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr
        INTO rw_crapepr;
      -- Se não encontrar informações
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
      -- Se encontrou registro e o tipo de débito for Conta (0-False)
      IF cr_crapemp%FOUND
         AND (vr_flgpagto_emp = 0 OR vr_flgpgtib_emp = 0) THEN
        -- Desconsiderar o dia para pagamento enviado
        pr_diapagto := 0;
      END IF;
      CLOSE cr_crapemp;
      -- Se foi enviado dia para pagamento and o tipo de débito do empréstimo for Conta (0-False)
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
      -- Mês anterior ao movimento
      vr_dtmesant := vr_dtmvtolt - to_char(vr_dtmvtolt, 'dd');
      -- Se a data de contratação do empréstimo estiver no mês corrente do movimento
      IF trunc(rw_crapepr.dtmvtolt, 'mm') = trunc(vr_dtmvtolt, 'mm') THEN
        -- Retornar o dia da data de contratação
        vr_nrdiacal := to_char(rw_crapepr.dtmvtolt, 'dd');
      ELSE
        -- Não há dias em atraso
        vr_nrdiacal := 0;
      END IF;
      -- ???
      vr_inhst093 := FALSE;
      -- Zerar juros calculados, qtdes e valor pago no mês
      vr_vljurmes := 0;
      pr_vlprepag := 0;
      pr_qtprecal := 0;
      vr_qtprepag := 0;
      vr_qtdpgmes := 0;
      -- Se estiver rodando no Batch e é processo mensal
      IF pr_rw_crapdat.inproces > 2
         AND pr_cdprogra IN ('CRPS080', 'CRPS085', 'CRPS120') THEN
        -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes próximo dia
        IF TRUNC(vr_dtmvtolt, 'mm') <> TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
          -- Data de movimento e do mês anterior recebem o ultimo dia do mês
          -- corrente da data de movimento passada originalmente
          vr_dtmvtolt := pr_rw_crapdat.dtultdia;
          vr_dtmesant := pr_rw_crapdat.dtultdia;
          -- Zerar número de dias para cálculo
          vr_nrdiacal := 0;
        END IF;
      END IF;
      -- Se o empréstimo está liquidado e não existe saldo devedor
      IF rw_crapepr.inliquid = 1
         AND NVL(pr_vlsdeved, 0) = 0 THEN
        -- Verificar se existe registro de conta transferida entre
        -- cooperativas com tipo de transferência = 1 (Conta Corrente)
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
      -- Somente buscar os pagamentos se a conta não foi migrada
      IF NOT vr_flctamig THEN
        -- Buscar todos os pagamentos do empréstimo
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
          /*
            88 - ESTORNO DE PAGAMENTO DE EMPRESTIMO
            91 - PAGTO EMPRESTIMO C/C
            92 - PAGTO EMPRESTIMO EM CAIXA
            93 - PAGTO EMPRESTIMO EM FOLHA
            94 - DESCONTO E/OU ABONO CONCEDIDO NO EMPRESTIMO
            95 - PAGTO EMPRESTIMO C/C
            120 - SOBRAS DE EMPRESTIMOS
            277 - ESTORNO DE JUROS S/EMPR. E FINANC.
            349 - EMPRESTIMO TRANSFERIDO PARA PREJUIZO
            353 - PAGAMENTO DE EMPRESTIMO COM SAQUE DE CAPITAL
            392 - ABATIMENTO CONCEDIDO NO EMPRESTIMO
            393 - PAGAMENTO EMPRESTIMO PELO FIADOR/AVALISTA
            507 - ESTORNO DE TRANSFERENCIA DE COTAS
            2381 - TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO
            2396 - TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO
            2401 - TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO
            2402 - REVERSAO JUROS +60 EMPRESTIMO TR P/ PREJUIZO
            2406 - REVERSAO JUROS +60 FINANCIAMENTO TR P/ PREJUIZO
            2405 - TRANSFERENCIA EMP/ FIN TR SUSPEITA DE FRAUDE
            2403 - ESTORNO TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO
            2404 - ESTORNO DE REVERSAO JUROS +60 TR P/ PREJUIZO
            2407 - ESTORNO DE REVERSAO JUROS +60 TR P/ PREJUIZO


          */
          IF rw_craplem.cdhistor IN
             (88, 91, 92, 93, 94, 95, 120, 277, 349, 353, 392, 393, 507, 2381,2396,2401,2402,2406,2405) THEN
            -- Zerar quantidade paga
            vr_qtprepag := 0;
            -- Garantir que não haja divisão por zero
            IF rw_craplem.vlpreemp > 0 THEN
              -- Quantidade paga é a divisão do lançamento pelo valor da prestação
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
              -- Não considerar este pagamento para abatimento de prestações
              pr_qtprecal := pr_qtprecal - vr_qtprepag;
            ELSE
              -- Considera este pagamento para abatimento de prestações
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
          /*
           91 - PAGTO EMPRESTIMO C/C
           92 - PAGTO EMPRESTIMO EM CAIXA
           94 - DESCONTO E/OU ABONO CONCEDIDO NO EMPRESTIMO
           277 - ESTORNO DE JUROS S/EMPR. E FINANC.
           349 - EMPRESTIMO TRANSFERIDO PARA PREJUIZO
           353 - PAGAMENTO DE EMPRESTIMO COM SAQUE DE CAPITAL
           392 - ABATIMENTO CONCEDIDO NO EMPRESTIMO
           393 - PAGAMENTO EMPRESTIMO PELO FIADOR/AVALISTA
           2381 - TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO
           2396 - TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO
           2401 - TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO

          */
          IF rw_craplem.cdhistor IN (91, 92, 94, 277, 349, 353, 392, 393,  2381, 2396,2401,2402,2406,2405) THEN
            -- Guardar data do ultimo pagamento
            pr_dtultpag := rw_craplem.dtmvtolt;
            -- Se houver saldo devedor
            IF pr_vlsdeved > 0 THEN
              -- Se o dia para calculo for superior ao dia de lançamento do emprestimo
              IF vr_nrdiacal > rw_craplem.ddlanmto THEN
                -- Utilizar o valor de lançamento para calculo dos juros
                vr_vljurmes := vr_vljurmes +
                               (rw_craplem.vllanmto * pr_txdjuros *
                               (rw_craplem.ddlanmto - vr_nrdiacal));
              ELSE
                -- Utilizar o saldo devedor já acumulado
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
              -- Utilizar o dia do empréstimo
              vr_nrdiacal := rw_craplem.ddlanmto;
            END IF;
            -- Diminuir saldo devedor
            pr_vlsdeved := NVL(pr_vlsdeved, 0) - rw_craplem.vllanmto;
            -- Acumular valor prestação pagos
            pr_vlprepag := pr_vlprepag + rw_craplem.vllanmto;
            -- Acumular número de pagamentos no mês
            vr_qtdpgmes := vr_qtdpgmes + 1;
            -- Incluir lançamento no vetor de pagamentos
            vr_vet_vlrpgmes(vr_qtdpgmes) := rw_craplem.vllanmto;
            -- Para os tipos abaixo relacionados
            -- --- --------------------------------------------------
            --  93 PG. EMPR. FP.
            --  95 PG. EMPR. C/C
          ELSIF rw_craplem.cdhistor IN (93, 95) THEN
            -- Guardar data do ultimo pagamento
            pr_dtultpag := rw_craplem.dtmvtolt;
            -- Se o dia do lançamento é superior ao dia de pagamento passado
            IF rw_craplem.ddlanmto > pr_diapagto THEN
              -- Se houver saldo devedor
              IF pr_vlsdeved > 0 THEN
                -- Acumular os juros
                vr_vljurmes := vr_vljurmes +
                               (pr_vlsdeved * pr_txdjuros *
                               (rw_craplem.ddlanmto - vr_nrdiacal));
                -- Dia calculo recebe o dia do lançamento
                vr_nrdiacal := rw_craplem.ddlanmto;
              ELSE
                -- Dia calculo recebe o dia do lançamento
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
            -- Acumular valor prestação pagos
            pr_vlprepag := pr_vlprepag + rw_craplem.vllanmto;
            -- Acumular número de pagamentos no mês
            vr_qtdpgmes := vr_qtdpgmes + 1;
            -- Incluir lançamento no vetor de pagamentos
            vr_vet_vlrpgmes(vr_qtdpgmes) := rw_craplem.vllanmto;
            -- Para os tipos abaixo
            -- --- --------------------------------------------------
            --  88 ESTORNO PAGTO
            -- 395 SERV./TAXAS
            -- 441 JUROS S/ATRAS
            -- 443 MULTA S/ATRAS
            -- 507 EST.TRF.COTAS
          ELSIF rw_craplem.cdhistor IN (88, 395, 441, 443, 507,2403,2404,2407) THEN
            -- Se ainda houver saldo devedor
            IF pr_vlsdeved > 0 THEN
              -- Se o dia do lançamento for inferior ao dia de pagamento enviado
              IF rw_craplem.ddlanmto < pr_diapagto THEN
                -- Se o dia calculado for igual ao dia de pagamento enviado
                IF vr_nrdiacal = pr_diapagto THEN
                  -- Acumular os juros com base na taxa e na diferença entre o dia enviado e o do lançamento
                  vr_vljurmes := vr_vljurmes +
                                 (rw_craplem.vllanmto * pr_txdjuros *
                                 (pr_diapagto - rw_craplem.ddlanmto));
                ELSE
                  -- Acumular os juros com base na taxa e na diferença entre o dia o lançamento e o dia de cálculo
                  vr_vljurmes := vr_vljurmes +
                                 (pr_vlsdeved * pr_txdjuros *
                                 (rw_craplem.ddlanmto - vr_nrdiacal));
                  -- Utilizar como dia de cálculo o dia deste lançamento
                  vr_nrdiacal := rw_craplem.ddlanmto;
                END IF;
              ELSIF rw_craplem.ddlanmto > pr_diapagto THEN
                -- Calcular o juros
                vr_vljurmes := vr_vljurmes +
                               (pr_vlsdeved * pr_txdjuros *
                               (rw_craplem.ddlanmto - vr_nrdiacal));
                -- Dia para calculo recebe o dia deste lançamento
                vr_nrdiacal := rw_craplem.ddlanmto;
              END IF;
            ELSE
              -- Atualizando nro do dia para calculo
              -- Caso o dia seja superior ao dia do lançamento do pagamento
              IF vr_nrdiacal > rw_craplem.ddlanmto THEN
                -- Mantem o mesmo valor
                vr_nrdiacal := vr_nrdiacal;
              ELSE
                -- Utilizar o dia do empréstimo
                vr_nrdiacal := rw_craplem.ddlanmto;
              END IF;
            END IF;
            -- Para estornos abaixo relacionados
            -- --- --------------------------------------------------
            --  88 ESTORNO PAGTO
            -- 507 EST.TRF.COTAS
            IF rw_craplem.cdhistor IN (88, 507) THEN
              -- Não considerar este lançamento no valor pago
              pr_vlprepag := pr_vlprepag - rw_craplem.vllanmto;
              -- Se o valor ficar negativo
              IF pr_vlprepag < 0 THEN
                -- Então zera novamente
                pr_vlprepag := 0;
              END IF;
            END IF;
            -- Acumular o lançamento no saldo devedor
            pr_vlsdeved := pr_vlsdeved + rw_craplem.vllanmto;
            -- Testar se existe pagamento com o mesmo valor no vetor de pagamentos
            vr_exipgmes := FALSE;
            -- Ler o vetor de pagamentos
            FOR vr_aux IN 1 .. vr_qtdpgmes LOOP
              -- Se o valor do vetor é igual ao do pagamento
              IF vr_vet_vlrpgmes(vr_aux) = rw_craplem.vllanmto THEN
                -- Indica que encontrou o pagamento no vetor
                vr_exipgmes := TRUE;
              END IF;
            END LOOP;
            -- Se tiver encontrado
            IF vr_exipgmes THEN
              -- Se o pagamento não for dos estornos abaixo relacionados
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
          -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes próximo dia
          IF TRUNC(vr_dtmvtolt, 'mm') <>
             TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
            -- Zerar número de dias para cálculo
            vr_nrdiacal := 0;
          ELSE
            -- Dia para cálculo recebe o dia enviado - o dia dalculado
            vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
          END IF;
        ELSE
          --> Não é processo mensal
          -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes próximo dia
          IF TRUNC(vr_dtmvtolt, 'mm') <>
             TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
            -- Dia para calculo recebe o ultimo dia do mês - o dia calculado
            vr_nrdiacal := to_char(pr_rw_crapdat.dtultdia, 'dd') -
                           vr_nrdiacal;
          ELSE
            -- Dia para cálculo recebe o dia enviado - o dia dalculado
            vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
          END IF;
        END IF;
      ELSE
        -- Dia para cálculo recebe o dia enviado - o dia dalculado
        vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
      END IF;
      -- Se existir saldo devedor
      IF pr_vlsdeved > 0 THEN
        -- Sumarizar juros do mês
        vr_vljurmes := vr_vljurmes +
                       (pr_vlsdeved * pr_txdjuros * vr_nrdiacal);
      END IF;
      -- Quantidade de prestações pagas
      pr_qtprepag := TRUNC(pr_qtprecal);
      -- Zerar qtde dias para cálculo
      vr_nrdiacal := 0;
      -- Se foi enviado data para calculo e existe saldo devedor
      IF pr_dtcalcul IS NOT NULL
         AND pr_vlsdeved > 0 THEN
        -- Dias para calculo recebe a data para calculo - dia do movimento
        vr_nrdiacal := trunc(pr_dtcalcul - vr_dtmvtolt);
        -- Se foi enviada uma data para calculo posterior ao ultimo dia do mês corrente
        IF pr_dtcalcul > pr_rw_crapdat.dtultdia THEN
          -- Qtde dias para calculo de juros no mês corrente
          -- é a diferença entre o ultimo dia - data movimento
          vr_nrdiames := TO_NUMBER(TO_CHAR(pr_rw_crapdat.dtultdia, 'DD')) -
                         TO_NUMBER(TO_CHAR(vr_dtmvtolt, 'DD'));
          -- Qtde dias para calculo de juros no próximo mês
          -- é a diferente entre o total de dias - os dias do mês corrente
          vr_nrdiaprx := vr_nrdiacal - vr_nrdiames;
        ELSE
          --> Estamos no mesmo mês
          -- Quantidade de dias no mês recebe a quantidade de dias calculada
          vr_nrdiames := vr_nrdiacal;
          -- Não existe calculo para o próximo mês
          vr_nrdiaprx := 0;
        END IF;
        -- Acumular juros com o número de dias no mês corrente
        vr_vljurmes := vr_vljurmes +
                       (pr_vlsdeved * pr_txdjuros * vr_nrdiames);
        -- Se a data enviada for do próximo mês
        IF vr_nrdiaprx > 0 THEN
          -- Arredondar os juros calculados
          vr_vljurmes := ROUND(vr_vljurmes, 2);
          -- Acumular no saldo devedor do mês corrente os juros
          pr_vlsdeved := pr_vlsdeved + vr_vljurmes;
          -- Acumular no totalizador de juros o juros calculados
          pr_vljuracu := pr_vljuracu + vr_vljurmes;
          -- Novamente calculamos os juros, porém somente com base nos dias do próximo mês
          vr_vljurmes := (pr_vlsdeved * pr_txdjuros * vr_nrdiaprx);
        END IF;
        -- Se o dia da data enviada for inferior ao dia para pagamento enviado
        IF to_char(pr_dtcalcul, 'dd') < pr_diapagto THEN
          -- Dias para pagamento recebe essa diferença
          vr_nrdiacal := pr_diapagto - to_char(pr_dtcalcul, 'dd');
        ELSE
          -- Ainda não venceu
          vr_nrdiacal := 0;
        END IF;
      ELSE
        -- Se o dia para cálculo for anterior ao dia enviado para pagamento
        --  E Não pode ser processo batch
        --  E deve haver saldo devedor
        --  E não pode ser inhst093 - ???
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
      -- Calcula juros sobre a prest. quando a consulta é menor que o data pagto
      -- Se existe dias para calculo e a data de pagamento contratada é inferior ao ultimo dias do mês corrente
      IF vr_nrdiacal > 0
         AND rw_crapepr.dtdpagto <= pr_rw_crapdat.dtultdia THEN
        -- Se o saldo devedor for superior ao valor contratado de prestação
        IF pr_vlsdeved > rw_crapepr.vlpreemp THEN
          -- Juros no mês são baseados no valor contratado
          vr_vljurmes := vr_vljurmes +
                         (rw_crapepr.vlpreemp * pr_txdjuros * vr_nrdiacal);
        ELSE
          -- Juros no mês são baseados no saldo devedor
          vr_vljurmes := vr_vljurmes +
                         (pr_vlsdeved * pr_txdjuros * vr_nrdiacal);
        END IF;
      END IF;
      -- Arredondar juros no mês
      vr_vljurmes := ROUND(vr_vljurmes, 2);
      -- Acumular juros calculados
      pr_vljuracu := pr_vljuracu + vr_vljurmes;
      -- Incluir no saldo devedor os juros do mês
      pr_vlsdeved := pr_vlsdeved + vr_vljurmes;
      -- Se houver indicação de liquidação do empréstimo
      -- E ainda existe saldo devedor
      IF pr_vlsdeved > 0
         AND rw_crapepr.inliquid > 0 THEN
        -- Se estiver rodando o processo batch no programa crps078
        IF pr_rw_crapdat.inproces > 2
           AND pr_cdprogra = 'CRPS078' THEN
          -- Se os juros do mês forem iguais ou superiores ao saldo devedor
          IF vr_vljurmes >= pr_vlsdeved THEN
            -- Remover dos juros do mês e do juros acumulados o saldo devedor
            vr_vljurmes := vr_vljurmes - pr_vlsdeved;
            pr_vljuracu := pr_vljuracu - pr_vlsdeved;
            -- Zerar o saldo devedor
            pr_vlsdeved := 0;
          ELSE
            -- Gerar crítica
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
          -- Remover dos juros do mês e do juros acumulados o saldo devedor
          vr_vljurmes := vr_vljurmes - pr_vlsdeved;
          pr_vljuracu := pr_vljuracu - pr_vlsdeved;
          -- Zerar o saldo devedor
          pr_vlsdeved := 0;
        END IF;
      END IF;
      -- Copiar para a saída os juros calculados
      pr_vljurmes := vr_vljurmes;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(pr_cdcritic, 0);
        pr_des_erro := vr_des_erro;
      WHEN OTHERS THEN
        -- Montar mensagem com o sqlerrm pois ocorreu um erro crítico
        pr_cdcritic := NVL(pr_cdcritic, 0);
        pr_des_erro := 'Problemas no procedimento empr0001.pc_leitura_lem. Erro: ' ||
                       sqlerrm;
    END;
  END pc_leitura_lem;

  /* Processar a rotina de leitura de pagamentos do emprestimo. */
  PROCEDURE pc_leitura_lem_car(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Código do programa corrente
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
      -- Cursor para busca dos dados de empréstimo
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

      -- Verificar se existe aviso de débito em conta corrente não processado
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
           AND flgproce = 0; --> Não processado
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

      -- Leitura de pagamentos de empréstimos { includes/lelem.i }
      empr0001.pc_leitura_lem(pr_cdcooper   => pr_cdcooper
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
        -- Gerar exceção
        RAISE vr_exc_erro;
      END IF;

      -- Busca dos detalhes do empréstimo
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

      -- Se o empréstimo não estiver liquidado
      IF rw_crapepr.inliquid = 0 THEN
        -- Acumular a quantidade calculada com a da tabela
        pr_qtprecal := rw_crapepr.qtprecal + pr_qtprecal;
      ELSE
        -- Utilizar apenas a quantidade de parcelas
        pr_qtprecal := rw_crapepr.qtpreemp;
      END IF;

      IF rw_crapepr.flgpagto = 0 THEN
        -- Se a parcela vence no mês corrente
        IF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapepr.dtdpagto,'mm') THEN
          -- Se ainda não foi pago
          IF rw_crapepr.dtdpagto <= rw_crapdat.dtmvtolt THEN
            -- Incrementar a quantidade de parcelas
            vr_qtmesdec := rw_crapepr.qtmesdec + 1;
          ELSE
            -- Consideramos a quantidade já calculadao
            vr_qtmesdec := rw_crapepr.qtmesdec;
          END IF;
        -- Se foi paga no mês corrente
        ELSIF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapepr.dtmvtolt,'mm') THEN
          -- Se for um contrato do mês
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
            -- Consideramos a quantidade já calculadao
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
          -- Verificar se existe aviso de débito em conta corrente não processado
          vr_flghaavs := 'N';
          OPEN cr_crapavs(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dtultdma => rw_crapdat.dtultdma);
          FETCH cr_crapavs
            INTO vr_flghaavs;
          CLOSE cr_crapavs;
          -- Se houve
          IF vr_flghaavs = 'S' THEN
            -- Utilizar a quantidade já calculada
            vr_qtmesdec := rw_crapepr.qtmesdec;
          ELSE
            -- Adicionar 1 mês a quantidade calculada
            vr_qtmesdec := rw_crapepr.qtmesdec + 1;
          END IF;
        END IF;
      END IF;

      -- Garantir que a quantidade decorrida não seja negativa
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
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar mensagem com o sqlerrm pois ocorreu um erro crítico
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Problemas no procedimento empr0001.pc_leitura_lem_car. Erro: ' ||
                       sqlerrm;
    END;
  END pc_leitura_lem_car;

  /* Calculo de dias para pagamento de empréstimo e juros */
  PROCEDURE pc_calc_dias360(pr_ehmensal IN BOOLEAN -- Indica se juros esta rodando na mensal
                           ,pr_dtdpagto IN INTEGER -- Dia do primeiro vencimento do emprestimo
                           ,pr_diarefju IN INTEGER -- Dia da data de referência da última vez que rodou juros
                           ,pr_mesrefju IN INTEGER -- Mes da data de referência da última vez que rodou juros
                           ,pr_anorefju IN INTEGER -- Ano da data de referência da última vez que rodou juros
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

       Alteracoes: 05/02/2013 - Conversão Progress >> PLSQL (Marcos-Supero)
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
      -- Copiar informações provenientes dos
      -- parâmetros para as variaveis locais
      /* final */
      vr_ano_datfinal := pr_anofinal;
      vr_mes_datfinal := pr_mesfinal;
      vr_dia_datfinal := pr_diafinal;
      /* inicial */
      vr_ano_dtinicio := pr_anorefju;
      vr_mes_dtinicio := pr_mesrefju;
      vr_dia_dtinicio := pr_diarefju;
      -- Garantir que o dia não seja 31
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
        -- Senão, se a data for superior a 28
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
      -- Se as datas estão no mesmo ano
      IF ABS(vr_ano_datfinal - vr_ano_dtinicio) = 0 THEN
        -- Quantidade de dias recebe a quantidade de meses * 30 + diferença entre os dias
        pr_qtdedias := (vr_mes_datfinal - vr_mes_dtinicio) * 30 +
                       vr_dia_datfinal - vr_dia_dtinicio;
      ELSE
        -- Quantidade de dias recebe a quantidade de anos * 360 + qtde meses * 30 + diferença entre os dias
        pr_qtdedias := ABS(vr_ano_datfinal - vr_ano_dtinicio - 1) * 360 + 360 -
                       vr_mes_dtinicio * 30 + 30 - vr_dia_dtinicio +
                       30 * (vr_mes_datfinal - 1) + vr_dia_datfinal;
      END IF;
      -- Devolver aos parâmetros as informações calculados
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
                                       ,pr_qtdiajur IN INTEGER -- Quantidade de dias de aplicação de juros
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

       Alteracoes: 05/02/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                   28/01/2014 - Inclusão da função fn_round para utilizar somente
                                10 casas decimais nos cálculos, da mesma forma que
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

  /* Procedure para calcular valor antecipado de parcelas de empréstimo */
  PROCEDURE pc_calc_antecipa_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                    ,pr_dtvencto IN crappep.dtvencto%TYPE --> Data do vencimento
                                    ,pr_vlsdvpar IN crappep.vlsdvpar%TYPE --> Valor devido parcela
                                    ,pr_txmensal IN crapepr.txmensal%TYPE --> Taxa aplicada ao empréstimo
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento atual
                                    ,pr_dtdpagto IN crapdat.dtmvtolt%TYPE --> Data de pagamento
                                    ,pr_vlatupar OUT crappep.vlsdvpar%TYPE --> Valor atualizado da parcela
                                    ,pr_vldespar OUT crappep.vlsdvpar%TYPE --> Valor desconto da parcela
                                    ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
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

       Alteracoes:  05/02/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)
    ............................................................................. */
    DECLARE
      -- variaveis auxiliares ao calculo
      vr_ndiasant INTEGER; --> Nro de dias de antecipação
      vr_diavenct INTEGER; --> Dia de vencimento
      vr_mesvenct INTEGER; --> Mes de vencimento
      vr_anovenct INTEGER; --> Ano de vencimento
      vr_dscritic VARCHAR2(4000);

    BEGIN
      -- Guardar dia, mes e ano separamente do vencimento
      vr_diavenct := to_char(pr_dtvencto, 'dd');
      vr_mesvenct := to_char(pr_dtvencto, 'mm');
      vr_anovenct := to_char(pr_dtvencto, 'yyyy');
      -- Chamar rotina para calcular a diferença de dias
      -- entre a data que deveria ter sido paga e a data paga
      empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                              ,pr_dtdpagto => to_char(pr_dtdpagto, 'dd') -- Dia do primeiro vencimento do emprestimo
                              ,pr_diarefju => to_char(pr_dtmvtolt, 'dd') -- Dia da data de referência da última vez que rodou juros
                              ,pr_mesrefju => to_char(pr_dtmvtolt, 'mm') -- Mes da data de referência da última vez que rodou juros
                              ,pr_anorefju => to_char(pr_dtmvtolt, 'yyyy') -- Ano da data de referência da última vez que rodou juros
                              ,pr_diafinal => vr_diavenct -- Dia data final
                              ,pr_mesfinal => vr_mesvenct -- Mes data final
                              ,pr_anofinal => vr_anovenct -- Ano data final
                              ,pr_qtdedias => vr_ndiasant); -- Quantidade de dias calculada
      -- Valor atual é encontrado com a fórmula:
      -- ROUND(VALOR_PARCELA * (  EXP(1+(TAXA_MENSAL*100) , - DIAS_ADIANTAMENTO /30),2)
      pr_vlatupar := ROUND(pr_vlsdvpar *
                           POWER(1 + (pr_txmensal / 100)
                                ,vr_ndiasant / 30 * -1)
                          ,2);
      -- Valor do desconto é igual ao valor devido - valor atualizado
      pr_vldespar := pr_vlsdvpar - pr_vlatupar;

      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_calc_antecipa_parcela> ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END;

  /* Procedure para calcular valor antecipado parcial de parcelas de empréstimo */
  PROCEDURE pc_calc_antec_parcel_parci(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_dtvencto IN crappep.dtvencto%TYPE --> Data do vencimento
                                      ,pr_txmensal IN crapepr.txmensal%TYPE --> Taxa aplicada ao empréstimo
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento atual
                                      ,pr_vlpagpar IN crappep.vlsdvpar%TYPE --> Valor devido parcela
                                      ,pr_dtdpagto IN crapdat.dtmvtolt%TYPE --> Data de pagamento
                                      ,pr_vldespar OUT crappep.vlsdvpar%TYPE --> Valor desconto da parcela
                                      ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves e
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

       Alteracoes:  25/03/2015 - Conversão Progress >> Oracle PLSQL (Alisson-AMcom)
    ............................................................................. */
    DECLARE
      -- variaveis auxiliares ao calculo
      vr_ndiasant INTEGER; --> Nro de dias de antecipação
      vr_vlpresen NUMBER;  --> Valor Presente
      vr_diavenct INTEGER; --> Dia de vencimento
      vr_mesvenct INTEGER; --> Mes de vencimento
      vr_anovenct INTEGER; --> Ano de vencimento
      vr_dscritic VARCHAR2(4000);
    BEGIN
      -- Guardar dia, mes e ano separamente do vencimento
      vr_diavenct := to_char(pr_dtvencto, 'dd');
      vr_mesvenct := to_char(pr_dtvencto, 'mm');
      vr_anovenct := to_char(pr_dtvencto, 'yyyy');
      -- Chamar rotina para calcular a diferença de dias
      -- entre a data que deveria ter sido paga e a data paga
      empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                              ,pr_dtdpagto => to_char(pr_dtdpagto, 'dd') -- Dia do primeiro vencimento do emprestimo
                              ,pr_diarefju => to_char(pr_dtmvtolt, 'dd') -- Dia da data de referência da última vez que rodou juros
                              ,pr_mesrefju => to_char(pr_dtmvtolt, 'mm') -- Mes da data de referência da última vez que rodou juros
                              ,pr_anorefju => to_char(pr_dtmvtolt, 'yyyy') -- Ano da data de referência da última vez que rodou juros
                              ,pr_diafinal => vr_diavenct -- Dia data final
                              ,pr_mesfinal => vr_mesvenct -- Mes data final
                              ,pr_anofinal => vr_anovenct -- Ano data final
                              ,pr_qtdedias => vr_ndiasant); -- Quantidade de dias calculada
      -- Valor presente é encontrado com a fórmula:
      -- ROUND(VALOR_PARCELA * (  EXP(1+(TAXA_MENSAL*100) , - DIAS_ADIANTAMENTO /30),2)
      vr_vlpresen := ROUND(pr_vlpagpar *
                           POWER(1 + (pr_txmensal / 100)
                                ,vr_ndiasant / 30),2);
      -- Valor do desconto é igual ao valor devido - valor atualizado
      pr_vldespar := nvl(vr_vlpresen,0) - nvl(pr_vlpagpar,0);

      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_calc_antec_parcel_parci. ' ||sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_calc_antec_parcel_parci;

  /* Calculo de valor atualizado de parcelas de empréstimo em atraso */
  PROCEDURE pc_calc_atraso_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                  ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                  ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                  ,pr_idorigem IN INTEGER --> Id do módulo de sistema
                                  ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                  ,pr_flgerlog IN VARCHAR2 --> Indicador S/N para geração de log
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                  ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                  ,pr_vlpagpar IN NUMBER --> Valor a pagar originalmente
                                  ,pr_vlpagsld OUT NUMBER --> Saldo a pagar após multa e juros
                                  ,pr_vlatupar OUT NUMBER --> Valor atual da parcela
                                  ,pr_vlmtapar OUT NUMBER --> Valor de multa
                                  ,pr_vljinpar OUT NUMBER --> Valor dos juros
                                  ,pr_vlmrapar OUT NUMBER --> Valor de mora
                                  ,pr_vliofcpl OUT NUMBER --> Valor de IOF de atraso
                                  ,pr_vljinp59 OUT NUMBER --> Juros quando período inferior a 59 dias
                                  ,pr_vljinp60 OUT NUMBER --> Juros quando período igual ou superior a 60 dias
                                  ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíveis erros
  BEGIN
    /* .............................................................................

       Programa: pc_calc_atraso_parcela (antigo b1wgen0084a.p --> calcula_atraso_parcela)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos (Supero)
       Data    : Fevereiro/2013.                         Ultima atualizacao: 07/08/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Atualizar o valor de parcelas em atraso

       Alteracoes: 05/02/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                   13/05/2014 - Ajuste para buscar o prazo de tolerancia da
                                multa da tabela crapepr. (James)

                   13/06/2014 - Ajuste para obter o ultimo lancamento de juro
                                do contrato. (James)

                   01/08/2014 - Ajuste na procedure para filtrar a parcela
                                no calculo do juros de mora. (James)

                   08/04/2015 - Ajuste para verificar os historicos de emprestimo e
                                financiamento.(James)

                   21/05/2015 - Ajuste para verificar se Cobra Multa. (James)

                   21/10/2016 - Ajuste para utilização do cursor padrão da craptab. (Rodrigo)

                   10/05/2018 - P410 - Ajustes IOF (Marcos-Envolti)

                   07/08/2018 - P410 - IOF Prejuizo - Diminuir valores já pagos (Marcos-Envolti)
    ............................................................................. */
    DECLARE
      -- Saida com erro opção 2
      vr_exc_erro_2 EXCEPTION;
      -- Rowid para inserção de log
      vr_nrdrowid ROWID;
      -- Busca dos dados de empréstimo
      CURSOR cr_crapepr IS
        SELECT epr.dtdpagto
              ,epr.cdlcremp
              ,epr.txmensal
              ,epr.qttolatr
              ,epr.qtpreemp
              ,epr.vlemprst
              ,epr.cdfinemp
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
              ,pep.vlpagiof
          FROM crappep pep
         WHERE pep.cdcooper = pr_cdcooper
               AND pep.nrdconta = pr_nrdconta
               AND pep.nrctremp = pr_nrctremp
               AND pep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
      -- Busca das linhas de crédito
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
      vr_dstextab craptab.dstextab%TYPE;
      vr_vliofpri NUMBER(18, 10); --> Taxa para calculo de mora
      vr_vltxaiof number(18, 10);
      vr_flgimune pls_integer;
      vr_vlbaseiof number;
      vr_qtdiaiof NUMBER;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

    BEGIN
      -- Criar um bloco para faciliar o tratamento de erro
      BEGIN
        -- Busca dos dados do empréstimo
        OPEN cr_crapepr;
        FETCH cr_crapepr
          INTO rw_crapepr;
        -- Se não encontrar
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

        -- Buscar informações da linha de crédito
        OPEN cr_craplcr(pr_cdlcremp => rw_crapepr.cdlcremp);
        FETCH cr_craplcr
          INTO rw_craplcr;
        -- Se não encontrar
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
          vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 3 -- Fixo 3 - Cecred
                         ,pr_nmsistem => 'CRED'
                         ,pr_tptabela => 'USUARI'
                         ,pr_cdempres => 11
                         ,pr_cdacesso => 'PAREMPCTL'
                         ,pr_tpregist => 01);
          IF vr_dstextab IS NULL THEN
            -- Gerar erro com critica 55
            vr_cdcritic := 55;
            vr_des_erro := gene0001.fn_busca_critica(55);
            RAISE vr_exc_erro;
          END IF;
          -- Utilizar como % de multa, as 6 primeiras posições encontradas
          vr_percmult := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,6));
        ELSE
          vr_percmult := 0;
        END IF;

        -- Prazo para tolerancia da multa está nas três primeiras posições do campo
        vr_nrdiamta := rw_crapepr.qttolatr;
        -- Prazo de tolerancia para incidencia de juros de mora
        -- também recebe inicialmente o mesmo valor
        vr_prtljuro := vr_nrdiamta;

        -- Busca dos dados da parcela
        OPEN cr_crappep;
        FETCH cr_crappep
          INTO rw_crappep;
        -- Se não encontrar
        IF cr_crappep%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crappep;
          -- MOntar descrição de erro
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

        -- Calcula dias para o IOF
        vr_qtdiaiof := pr_dtmvtolt - vr_dtmvtolt;

        -- Dividir a data em dia/mes/ano para utilização da rotina dia360
        vr_diavtolt := to_char(pr_dtmvtolt, 'dd');
        vr_mesvtolt := to_char(pr_dtmvtolt, 'mm');
        vr_anovtolt := to_char(pr_dtmvtolt, 'yyyy');
        -- Calcular quantidade de dias para o saldo devedor
        empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                                ,pr_dtdpagto => to_char(rw_crapepr.dtdpagto
                                                       ,'dd') -- Dia do primeiro vencimento do emprestimo
                                ,pr_diarefju => to_char(vr_dtmvtolt, 'dd') -- Dia da data de referência da última vez que rodou juros
                                ,pr_mesrefju => to_char(vr_dtmvtolt, 'mm') -- Mes da data de referência da última vez que rodou juros
                                ,pr_anorefju => to_char(vr_dtmvtolt, 'yyyy') -- Ano da data de referência da última vez que rodou juros
                                ,pr_diafinal => vr_diavtolt -- Dia data final
                                ,pr_mesfinal => vr_mesvtolt -- Mes data final
                                ,pr_anofinal => vr_anovtolt -- Ano data final
                                ,pr_qtdedias => vr_qtdiasld); -- Quantidade de dias calculada
        -- Calcula quantos dias passaram do vencimento até o parametro par_dtmvtolt
        -- Obs: Será usado para comparar se a quantidade de dias que passou está dentro da tolerância
        vr_qtdianor := pr_dtmvtolt - rw_crappep.dtvencto;
        -- Se já houve pagamento
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
        -- o ultima ocorrência de juros de mora/vencimento até o par_dtmvtolt
        vr_qtdiamor := pr_dtmvtolt - vr_dtmvtolt;
        -- Se a quantidade de dias está dentro da tolerancia
        IF vr_qtdianor <= vr_nrdiamta THEN
          -- Zerar a multa
          vr_percmult := 0;
        END IF;
        -- Calcular o valor da multa, descontando o que já foi calculado para a parcela
        pr_vlmtapar := ROUND((rw_crappep.vlparepr * vr_percmult / 100), 2) -
                       rw_crappep.vlpagmta;

        -- Calcular os juros considerando o valor da parcela
        empr0001.pc_calc_juros_normais_total(pr_vlpagpar => rw_crappep.vlsdvpar -- Valor a pagar originalmente
                                            ,pr_txmensal => rw_crapepr.txmensal -- Valor da taxa mensal
                                            ,pr_qtdiajur => vr_qtdiasld -- Quantidade de dias de aplicação de juros
                                            ,pr_vljinpar => pr_vljinpar); -- Valor com os juros aplicados

        -- Se a quantidade de dias de atraso for superior a 59
        /*IF vr_qtdiasld > 59 THEN
          -- Separar os juros até 59 dias na pr_vljinp59
          empr0001.pc_calc_juros_normais_total(pr_vlpagpar => rw_crappep.vlsdvpar -- Valor a pagar originalmente
                                              ,pr_txmensal => rw_crapepr.txmensal -- Valor da taxa mensal
                                              ,pr_qtdiajur => 59                  -- Quantidade de dias de aplicação de juros
                                              ,pr_vljinpar => pr_vljinp59);       -- Valor com os juros aplicados

          -- Comentado por Irlan. Nao eh necessario calcular, basta subtrair
          --   par_vljinpar - par_vljinpar
          -- O restante dos juros na pr_vljinp60, descontando os dias já calculados acima
          -- e acumulando ao valor os juros aplicados nos primeiros 59 dias
          --empr0001.pc_calc_juros_normais_total(pr_vlpagpar => rw_crappep.vlsdvpar + pr_vljinp59 -- Valor a pagar originalmente
                                              ,pr_txmensal => rw_crapepr.txmensal -- Valor da taxa mensal
                                              ,pr_qtdiajur => vr_qtdiasld-59      -- Quantidade de dias de aplicação de juros
                                              ,pr_vljinpar => pr_vljinp60);       -- Valor com os juros aplicados
          --vr_vljinp60 := vr_vljinpar - vr_vljinp59;
        ELSE
          -- Acumular os juros na variavel até 59 dias
          empr0001.pc_calc_juros_normais_total(pr_vlpagpar => rw_crappep.vlsdvpar -- Valor a pagar originalmente
                                              ,pr_txmensal => rw_crapepr.txmensal -- Valor da taxa mensal
                                              ,pr_qtdiajur => vr_qtdiasld         -- Quantidade de dias de aplicação de juros
                                              ,pr_vljinpar => pr_vljinp59);       -- Valor com os juros aplicados
        END IF;*/
        -- Atualizar o valor da parcela
        pr_vlatupar := rw_crappep.vlsdvpar + pr_vljinpar;

        -- Se a quantidade de dias está dentro da tolerancia de juros de mora
        IF vr_qtdianor <= vr_prtljuro THEN
          -- Zerar o percentual de mora
          pr_vlmrapar := 0;
        ELSE
          -- TAxa de mora recebe o valor da linha de crédito
          vr_txdiaria := ROUND((100 * (POWER((rw_craplcr.perjurmo / 100) + 1
                                            ,(1 / 30)) - 1))
                              ,10);
          -- Dividimos por 100
          vr_txdiaria := vr_txdiaria / 100;
          -- Valor de juros de mora é relativo ao juros sem inadimplencia da parcela + taxa diaria calculada + quantidade de dias de mora
          pr_vlmrapar := round((rw_crappep.vlsdvsji * vr_txdiaria * vr_qtdiamor),2);
        END IF;


          /* Projeto 410 - valor base para IOF:
             Valor da Parcela /((1+ tx mensal)^(qt parcelas - parcela atual))) */
        --Sempre calcular IOF complementar - ajustado com James
          vr_vlbaseiof :=   rw_crappep.vlparepr / ((power(( 1 + rw_crapepr.txmensal / 100 ),
                                (rw_crapepr.qtpreemp - rw_crappep.nrparepr + 1) )));

          -- BAse do IOF Complementar é o menor valor entre o Saldo Devedor ou O Principal
          vr_vlbaseiof := LEAST(vr_vlbaseiof,rw_crappep.vlsdvsji );

          TIOF0001.pc_calcula_valor_iof_epr(pr_tpoperac => 2 -- Só atraso
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vlemprst => vr_vlbaseiof -- valor principal
                                           ,pr_vltotope => rw_crapepr.vlemprst
                                           ,pr_dscatbem => ''
                                           ,pr_cdlcremp => rw_crapepr.cdlcremp
                                           ,pr_cdfinemp => rw_crapepr.cdfinemp
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_qtdiaiof => vr_qtdiaiof
                                           ,pr_vliofpri => vr_vliofpri
                                           ,pr_vliofadi => vr_vliofpri
                                           ,pr_vliofcpl => pr_vliofcpl
                                           ,pr_vltaxa_iof_principal => vr_vltxaiof
                                           ,pr_flgimune => vr_flgimune
                                           ,pr_dscritic => vr_dscritic);

        -- Diminuir do valor do IOF complementar o valor já pago
        IF rw_crappep.vlpagiof > 0 THEN
          pr_vliofcpl := greatest(0,pr_vliofcpl-rw_crappep.vlpagiof);
        END IF;

        -- Se o valor a pagar originalmente for diferente de zero
        IF pr_vlpagpar <> 0 THEN
          -- Valor a pagar - multa e juros de mora
          pr_vlpagsld := pr_vlpagpar -
                         (ROUND(pr_vlmtapar, 2) + ROUND(pr_vlmrapar, 2) + round(nvl(pr_vliofcpl,0),2));
        ELSE
          -- Utilizar o valor já calculado anteriormente
          pr_vlpagsld := pr_vlatupar;
        END IF;
        -- Chegou ao final sem problemas, retorna OK
        pr_des_reto := 'OK';
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Gerar rotina de gravação de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        WHEN vr_exc_erro_2 THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Copiar tabela de erro temporária para saída da rotina
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_calc_atraso_parcela> ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_calc_atraso_parcela;

  /* Busca dos pagamentos das parcelas de empréstimo prefixados*/
  PROCEDURE pc_busca_pgto_parcelas_prefix(pr_cdcooper      IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                         ,pr_cdagenci      IN crapass.cdagenci%TYPE --> Código da agência
                                         ,pr_nrdcaixa      IN craperr.nrdcaixa%TYPE --> Número do caixa
                                         ,pr_nrdconta      IN crapepr.nrdconta%TYPE --> Número da conta
                                         ,pr_nrctremp      IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                         ,pr_rw_crapdat    IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                                         ,pr_dtmvtolt      IN DATE --> Data de movimento
                                         ,pr_vlemprst      IN crapepr.vlemprst%TYPE --> Valor do emprestioms
                                         ,pr_qtpreemp      IN crapepr.qtpreemp%TYPE --> qtd de parcelas do emprestimo
                                         ,pr_dtdpagto      IN crapepr.dtdpagto%TYPE --> data de pagamento
                                         ,pr_txmensal      IN crapepr.txmensal%TYPE --> Taxa mensal do emprestimo
                                         ,pr_cdlcremp      IN crapepr.cdlcremp%TYPE --> Taxa mensal do emprestimo
                                         ,pr_qttolatr      IN crapepr.qttolatr%TYPE --> Quantidade de dias de tolerancia no atraso da parcela
                                         ,pr_des_reto      OUT VARCHAR --> Retorno OK / NOK
                                         ,pr_tab_erro      OUT gene0001.typ_tab_erro --> Tabela com possíves erros
                                         ,pr_tab_calculado OUT empr0001.typ_tab_calculado) IS
    --> Tabela com totais calculados
    /* .............................................................................

       Programa: pc_busca_pgto_parcelas_prefix (antigo includes/b1wgen0002a.i)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago.
       Data    : 06/03/2012                         Ultima atualizacao: 07/08/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Include para busca de dados da prestacao quando tpemprst = 1.

       Alteracoes:  07/01/2014 - Ajuste para melhorar a performance (James).

                    15/01/2014 - Ajuste para inicializar as variaveis com 0 (James).

                    12/03/2014 - Conversão Progress >> Oracle PLSQL (Odirlei-AMcom)

                    12/05/2014 - Ajuste para calcular multa e Juros de Mora (James).

                                 Ajuste para pegar o prazo de atraso da tabela
                                 crapepr.qttolatr e nao mais da tab089. (James)

                                 Ajuste para calcular o valor vencido e o valor a
                                 vencer para a tela LAUTOM. (James)

                                 Ajuste no calculo da tolerancia da multa e Juros
                                 de Mora.(James)

                    06/04/2015 - Ajuste para considerar o que foi pago no mes
                                 os historicos de emprestimo e financimento. (James)

                    21/05/2015 - Ajuste para verificar se a Linha de Crédito Cobra Multa. (James)

                    09/10/2015 - Inclusao de histórico de estorno PP. (Oscar)

                   21/10/2016 - Ajuste para utilização do cursor padrão da craptab. (Rodrigo)

                    14/02/2017 - Foi inicializada a vr_vlsderel com zero. (Jaison/James)

                    11/07/2017 - P337 - Não estava se comportando de acordo quando
                                  emprestimo nao liberado, usada rw_crapepr e
                                  nao rw_crawepr (Marcos-Supero)

                    10/05/2018 - P410 - Ajustes IOF (Marcos-Envolti)

                    07/08/2018 - P410 - IOF Prejuizo - Diminuir valores já pagos (Marcos-Envolti)

    ............................................................................. */

    -------------------> CURSOR <--------------------
    -- Buscar cadastro auxiliar de emprestimo
    CURSOR cr_crawepr(pr_cdcooper crawepr.cdcooper%type
                     ,pr_nrdconta crawepr.nrdconta%type
                     ,pr_nrctremp crawepr.nrctremp%type) is
      SELECT wpr.dtlibera
            ,epr.inliquid
            ,wpr.idfiniof
            ,epr.vliofepr
            ,epr.vltarifa
            ,epr.qtpreemp
            ,epr.cdfinemp
        FROM crapepr epr
            ,crawepr wpr
       WHERE epr.cdcooper = wpr.cdcooper
         AND epr.nrdconta = wpr.nrdconta
         AND epr.nrctremp = wpr.nrctremp
         AND wpr.cdcooper = pr_cdcooper
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctremp = pr_nrctremp;
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
            ,vlpagiof
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
      SELECT /*+ INDEX (lem CRAPLEM##CRAPLEM7) */ SUM(DECODE(lem.cdhistor,
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
    vr_vlsderel NUMBER := 0;
    vr_qtdianor NUMBER := 0;
    vr_qtdiamor NUMBER := 0;
    vr_prtljuro NUMBER := 0;
    vr_percmult NUMBER := 0;
    vr_txdiaria NUMBER := 0;
    vr_vlpreapg NUMBER;
    vr_vliofpri NUMBER;
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
    vr_vliofcpl crappep.vliofcpl%TYPE := 0;
    vr_vliofcpl_tmp crappep.vliofcpl%TYPE := 0;
    vr_vlprvenc NUMBER := 0;
    vr_vlpraven NUMBER := 0;
    vr_dstextab craptab.dstextab%TYPE;
    vr_vltxaiof number(18,8);
    vr_flgimune pls_integer;
    vr_vlbaseiof number;
    vr_qtdiaiof NUMBER;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

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
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 3 -- Fixo 3 - Cecred
                       ,pr_nmsistem => 'CRED'
                       ,pr_tptabela => 'USUARI'
                       ,pr_cdempres => 11
                       ,pr_cdacesso => 'PAREMPCTL'
                       ,pr_tpregist => 01);
        -- Se não encontrar
        IF vr_dstextab IS NULL THEN
          -- Gerar erro com critica 55
          vr_cdcritic := 55;
          vr_des_erro := gene0001.fn_busca_critica(55);
          RAISE vr_exc_erro;
        END IF;

        -- Utilizar como % de multa, as 6 primeiras posições encontradas
        vr_percmult := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,6));
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
      -- Se não encotrou, incluir critica e sair do controle
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
          vr_qtdiaiof := pr_dtmvtolt - vr_dtmvtolt;

          vr_diafinal := to_char(pr_dtmvtolt, 'dd'); -- Dia data final
          vr_mesfinal := to_char(pr_dtmvtolt, 'MM'); -- Mes data final
          vr_anofinal := to_char(pr_dtmvtolt, 'yyyy'); -- Ano data final

          -- Calcular quantidade de dias para o saldo devedor
          empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                                  ,pr_dtdpagto => to_char(pr_dtdpagto, 'dd') -- Dia do primeiro vencimento do emprestimo
                                  ,pr_diarefju => to_char(vr_dtmvtolt, 'dd') -- Dia da data de referência da última vez que rodou juros
                                  ,pr_mesrefju => to_char(vr_dtmvtolt, 'mm') -- Mes da data de referência da última vez que rodou juros
                                  ,pr_anorefju => to_char(vr_dtmvtolt
                                                         ,'yyyy') -- Ano da data de referência da última vez que rodou juros
                                  ,pr_diafinal => vr_diafinal -- Dia data final
                                  ,pr_mesfinal => vr_mesfinal -- Mes data final
                                  ,pr_anofinal => vr_anofinal -- Ano data final
                                  ,pr_qtdedias => vr_qtdedias); -- Quantidade de

          /* Calcula quantos dias passaram do vencimento até o parametro par_dtmvtolt será usado para comparar se a quantidade de
          dias que passou está dentro da tolerância */
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
          o ultima ocorrência de juros de mora/vencimento até o
          par_dtmvtolt */
          vr_qtdiamor := pr_dtmvtolt - vr_dtmvtolt;
          /* Verifica se esta na tolerancia da multa, aux_qtdianor é quantidade de dias que passaram
          aux_nrdiamta é quantidade de dias de tolerância parametrizada */
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

         /* Projeto 410 - valor base para IOF:
             Valor da Parcela /((1+ tx mensal)^(qt parcelas - parcela atual))) */

          vr_vlbaseiof :=   rw_crappep.vlparepr / ((power(( 1 + pr_txmensal / 100 ),
                                (rw_crawepr.qtpreemp - rw_crappep.nrparepr + 1) )));


          -- BAse do IOF Complementar é o menor valor entre o Saldo Devedor ou O Principal
          vr_vlbaseiof := LEAST(vr_vlbaseiof,rw_crappep.vlsdvsji );


          -- Valor a Vencer
          vr_vlprvenc := vr_vlprvenc + vr_vlatupar;
          /* Verifica se esta na tolerancia dos juros de mora, aux_qtdianor é quantidade de dias que passaram
          aux_prtljuro é quantidade de dias de tolerância parametrizada */
          IF vr_qtdianor <= vr_prtljuro THEN
            vr_vlmrapar := NVL(vr_vlmrapar, 0) + 0;
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

          -- Calcular IOF atraso
          TIOF0001.pc_calcula_valor_iof_epr(pr_tpoperac => 2 -- Só atraso
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vlemprst => vr_vlbaseiof
                                           ,pr_dscatbem => ''
                                           ,pr_cdlcremp => pr_cdlcremp
                                           ,pr_cdfinemp => rw_crawepr.cdfinemp
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_qtdiaiof => vr_qtdiaiof
                                           ,pr_vliofpri => vr_vliofpri
                                           ,pr_vliofadi => vr_vliofpri
                                           ,pr_vliofcpl => vr_vliofcpl_tmp
                                           ,pr_vltaxa_iof_principal => vr_vltxaiof
                                           ,pr_flgimune => vr_flgimune
                                           ,pr_dscritic => vr_dscritic);
          -- Diminuir do valor do IOF complementar o valor já pago
          IF rw_crappep.vlpagiof > 0 THEN
            vr_vliofcpl_tmp := greatest(0,vr_vliofcpl_tmp-rw_crappep.vlpagiof);
          END IF;

              --Acumula o IOF de atraso das parcelas
                                        vr_vliofcpl := NVL(vr_vliofcpl,0) + NVL(vr_vliofcpl_tmp,0);

        ELSIF rw_crappep.dtvencto > pr_dtmvtolt THEN
          /* Parcela a Vencer */

          vr_diafinal := to_char(rw_crappep.dtvencto, 'dd'); -- Dia data final
          vr_mesfinal := to_char(rw_crappep.dtvencto, 'MM'); -- Mes data final
          vr_anofinal := to_char(rw_crappep.dtvencto, 'yyyy'); -- Ano data final

          -- Calcular quantidade de dias para o saldo devedor
          empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                                  ,pr_dtdpagto => to_char(pr_dtdpagto, 'dd') -- Dia do primeiro vencimento do emprestimo
                                  ,pr_diarefju => to_char(pr_dtmvtolt, 'dd') -- Dia da data de referência da última vez que rodou juros
                                  ,pr_mesrefju => to_char(pr_dtmvtolt, 'mm') -- Mes da data de referência da última vez que rodou juros
                                  ,pr_anorefju => to_char(pr_dtmvtolt
                                                         ,'yyyy') -- Ano da data de referência da última vez que rodou juros
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
         rw_crawepr.inliquid <> 1 THEN
        /* Nao liberado */
        vr_vlsdeved := pr_vlemprst;
      /*  if rw_crawepr.idfiniof = 1 then
           vr_vlsdeved := pr_vlemprst +
                          nvl(rw_crawepr.vliofepr,0) +
                          nvl(rw_crawepr.vltarifa,0);
        end if;*/
        vr_vlprepag := 0;
        vr_vlpreapg := 0;
      ELSE
        vr_vlsdeved := vr_vlsderel;/* + nvl(vr_vliofcpl,0);*/
      END IF;

      vr_flgtrans := TRUE;
    EXCEPTION
      WHEN vr_exec_busca THEN
        NULL;
    END; /* END BUSCA */

    IF NOT vr_flgtrans THEN
      pr_des_reto := 'NOK';
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    END IF;

    -- Utilizar informações do cálculo
    pr_tab_calculado(1).vlsdeved := vr_vlsdeved;
    pr_tab_calculado(1).vlsderel := vr_vlsderel;

    pr_tab_calculado(1).vlprepag := vr_vlprepag;
    pr_tab_calculado(1).vlpreapg := vr_vlpreapg;
    -- Copiar qtde prestações calculadas
    pr_tab_calculado(1).qtprecal := rw_crapepr.qtprecal;
    pr_tab_calculado(1).vlmtapar := vr_vlmtapar;
    pr_tab_calculado(1).vlmrapar := vr_vlmrapar;
    pr_tab_calculado(1).vliofcpl := vr_vliofcpl;
    pr_tab_calculado(1).vlprvenc := vr_vlprvenc;
    pr_tab_calculado(1).vlpraven := vr_vlpraven;

  EXCEPTION

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na empr0001.pc_busca_pgto_parcelas_prefix> ' ||
                     sqlerrm;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
  END pc_busca_pgto_parcelas_prefix;

  /* Busca dos pagamentos das parcelas de empréstimo */
  PROCEDURE pc_busca_pgto_parcelas(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_cdagenci        IN crapass.cdagenci%TYPE --> Código da agência
                                  ,pr_nrdcaixa        IN craperr.nrdcaixa%TYPE --> Número do caixa
                                  ,pr_cdoperad        IN crapdev.cdoperad%TYPE --> Código do Operador
                                  ,pr_nmdatela        IN VARCHAR2 --> Nome da tela
                                  ,pr_idorigem        IN INTEGER --> Id do módulo de sistema
                                  ,pr_nrdconta        IN crapepr.nrdconta%TYPE --> Número da conta
                                  ,pr_idseqttl        IN crapttl.idseqttl%TYPE --> Seq titula
                                  ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                  ,pr_flgerlog        IN VARCHAR2 --> Indicador S/N para geração de log
                                  ,pr_nrctremp        IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                  ,pr_dtmvtoan        IN crapdat.dtmvtolt%TYPE --> Data anterior
                                  ,pr_nrparepr        IN INTEGER --> Número parcelas empréstimo
                                  ,pr_des_reto        OUT VARCHAR --> Retorno OK / NOK
                                  ,pr_tab_erro        OUT gene0001.typ_tab_erro --> Tabela com possíves erros
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
       Objetivo  : Buscar os pagamentos das parcelas de empréstimo.

       Alteracoes:  Passado parametro quantidade prestacoes calculadas(Mirtes)

                    05/02/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

                    07/10/2013 - REplicação das alterações realizadas no Progress

                    14/10/2013 - Ajustado a procedure busca_pagamentos_parcelas
                                 para atualizar o valora regularizar quando a
                                 parcela estiver em dia(James).

                    13/06/2014 - Incluir novo historico para somar o valor total pago no mes (James)

                    08/04/2015 - Ajuste para verificar os historicos de emprestimo e financiamento.(James)

                    08/10/2015 - Diminuir o valor estorno no mes do valor pago no mes. (Oscar)
    ............................................................................. */
    DECLARE
      -- Saida com erro opção 2
      vr_exc_erro_2 EXCEPTION;
      -- Rowid para inserção de log
      vr_nrdrowid ROWID;
      -- Busca dos dados de empréstimo
      CURSOR cr_crapepr IS
        SELECT epr.cdlcremp
              ,epr.txmensal
              ,epr.dtdpagto
              ,epr.qtprecal
              ,epr.vlemprst
              ,epr.qtpreemp
              ,epr.inliquid
              ,epr.idfiniof
              ,epr.vliofepr
              ,epr.vltarifa
              ,epr.vlsdeved
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
               AND epr.nrdconta = pr_nrdconta
               AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      -- Busca dos dados de complemento do empréstimo
      CURSOR cr_crawepr IS
        SELECT epr.dtlibera, epr.idfiniof
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
      vr_vlsderel   NUMBER := 0; --> Saldo para relatórios
      vr_vlsdvctr   NUMBER := 0;
      -- Buscar todas as parcelas de pagamento
      -- do empréstimo e seus valores
      CURSOR cr_crappep IS
        SELECT pep.cdcooper
              ,pep.nrdconta
              ,pep.nrctremp
              ,pep.nrparepr
              ,pep.vlparepr
              ,pep.vljinpar
              ,pep.vlmrapar
              ,pep.vliofcpl
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
               AND pep.inliquid = 0 -- Não liquidada
               AND (pr_nrparepr = 0 OR pep.nrparepr = pr_nrparepr); -- Traz todas quado zero, ou somente a passada
      -- Indica para a temp-table
      vr_ind_pag NUMBER;
      -- Buscar o total pago no mês
      CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE
                       ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS

      SELECT /*+ INDEX (lem CRAPLEM##CRAPLEM7) */ SUM(DECODE(lem.cdhistor,
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
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
    BEGIN
      --Limpar Tabelas Memoria
      pr_tab_erro.DELETE;
      pr_tab_pgto_parcel.DELETE;
      pr_tab_calculado.DELETE;
      -- Criar um bloco para faciliar o tratamento de erro
      BEGIN
        -- Busca detalhes do empréstimo
        OPEN cr_crapepr;
        FETCH cr_crapepr
          INTO rw_crapepr;
        -- Se não tiver encontrado
        IF cr_crapepr%NOTFOUND THEN
          -- Fechar o cursor e gerar critica
          CLOSE cr_crapepr;
          vr_cdcritic := 356;
          RAISE vr_exc_erro;
        ELSE
          -- fechar o cursor e continuar o processo
          CLOSE cr_crapepr;
        END IF;
        -- Busca dados complementares do empréstimo
        OPEN cr_crawepr;
        FETCH cr_crawepr
          INTO rw_crawepr;
        -- Se não tiver encontrado
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
        -- do empréstimo e seus valores
        FOR rw_crappep IN cr_crappep LOOP
          -- Criar um novo indice para a temp-table
          vr_ind_pag := pr_tab_pgto_parcel.COUNT() + 1;
          -- Copiar as informações da tabela para a temp-table
          pr_tab_pgto_parcel(vr_ind_pag).cdcooper := rw_crappep.cdcooper;
          pr_tab_pgto_parcel(vr_ind_pag).nrdconta := rw_crappep.nrdconta;
          pr_tab_pgto_parcel(vr_ind_pag).nrctremp := rw_crappep.nrctremp;
          pr_tab_pgto_parcel(vr_ind_pag).nrparepr := rw_crappep.nrparepr;
          pr_tab_pgto_parcel(vr_ind_pag).vlparepr := rw_crappep.vlparepr;
          pr_tab_pgto_parcel(vr_ind_pag).vljinpar := rw_crappep.vljinpar;
          pr_tab_pgto_parcel(vr_ind_pag).vlmrapar := rw_crappep.vlmrapar;
          pr_tab_pgto_parcel(vr_ind_pag).vlmtapar := rw_crappep.vlmtapar;
          pr_tab_pgto_parcel(vr_ind_pag).vliofcpl := rw_crappep.vliofcpl;
          pr_tab_pgto_parcel(vr_ind_pag).dtvencto := rw_crappep.dtvencto;
          pr_tab_pgto_parcel(vr_ind_pag).dtultpag := rw_crappep.dtultpag;
          pr_tab_pgto_parcel(vr_ind_pag).vlpagpar := rw_crappep.vlpagpar;
          pr_tab_pgto_parcel(vr_ind_pag).vlpagmta := rw_crappep.vlpagmta;
          pr_tab_pgto_parcel(vr_ind_pag).vlpagmra := rw_crappep.vlpagmra;
          pr_tab_pgto_parcel(vr_ind_pag).vldespar := rw_crappep.vldespar;
          pr_tab_pgto_parcel(vr_ind_pag).vlsdvpar := rw_crappep.vlsdvpar;
          pr_tab_pgto_parcel(vr_ind_pag).inliquid := rw_crappep.inliquid;

          -- Se ainda não foi liberado
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

            -- Se a parcela ainda não venceu
          ELSIF rw_crappep.dtvencto > pr_dtmvtoan
                AND rw_crappep.dtvencto <= pr_dtmvtolt THEN
            -- Parcela em dia
            pr_tab_pgto_parcel(vr_ind_pag).vlatupar := rw_crappep.vlsdvpar;
            -- Guardar quantidades calculadas
            vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;

            /* A regularizar */
            vr_vlpreapg := vr_vlpreapg + pr_tab_pgto_parcel(vr_ind_pag)
                          .vlatupar;
            -- Se a parcela está vencida
          ELSIF rw_crappep.dtvencto < pr_dtmvtolt THEN
            -- Calculo de valor atualizado de parcelas de empréstimo em atraso
            empr0001.pc_calc_atraso_parcela(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                           ,pr_cdagenci => pr_cdagenci --> Código da agência
                                           ,pr_nrdcaixa => pr_nrdcaixa --> Número do caixa
                                           ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                           ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                           ,pr_idorigem => pr_idorigem --> Id do módulo de sistema
                                           ,pr_nrdconta => pr_nrdconta --> Número da conta
                                           ,pr_idseqttl => pr_idseqttl --> Seq titula
                                           ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                           ,pr_flgerlog => pr_flgerlog --> Indicador S/N para geração de log
                                           ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                           ,pr_nrparepr => rw_crappep.nrparepr --> Número parcelas empréstimo
                                           ,pr_vlpagpar => 0 --> Valor a pagar originalmente
                                           ,pr_vlpagsld => vr_vlpagsld --> Saldo a pagar após multa e juros
                                           ,pr_vlatupar => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlatupar --> Valor atual da parcela
                                           ,pr_vlmtapar => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlmtapar --> Valor de multa
                                           ,pr_vljinpar => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vljinpar --> Valor dos juros
                                           ,pr_vlmrapar => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlmrapar --> Valor de mora
                                           ,pr_vliofcpl => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vliofcpl --> Valor de mora
                                           ,pr_vljinp59 => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vljinp59 --> Juros quando período inferior a 59 dias
                                           ,pr_vljinp60 => pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vljinp60 --> Juros quando período igual ou superior a 60 dias
                                           ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                           ,pr_tab_erro => vr_tab_erro); --> Tabela com possíveis erros
            -- Testar erro
            IF vr_des_reto = 'NOK' THEN
              -- Levantar exceção 2, onde já temos o erro na vr_tab_erro
              RAISE vr_exc_erro_2;
            END IF;
            -- Acumular o valor a regularizar
            vr_vlpreapg := vr_vlpreapg + pr_tab_pgto_parcel(vr_ind_pag)
                          .vlatupar;
            -- Guardar quantidades calculadas
            vr_vlsdvctr := vr_vlsdvctr + pr_tab_pgto_parcel(vr_ind_pag)
                          .vlatupar;

            -- Antecipação de parcela
          ELSIF rw_crappep.dtvencto > pr_dtmvtolt THEN
            -- Procedure para calcular valor antecipado de parcelas de empréstimo
            empr0001.pc_calc_antecipa_parcela(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                             ,pr_cdagenci => pr_cdagenci --> Código da agência
                                             ,pr_nrdcaixa => pr_nrdcaixa --> Número do caixa
                                             ,pr_dtvencto => rw_crappep.dtvencto --> Data do vencimento
                                             ,pr_vlsdvpar => rw_crappep.vlsdvpar --> Valor devido parcela
                                             ,pr_txmensal => rw_crapepr.txmensal --> Taxa aplicada ao empréstimo
                                             ,pr_dtmvtolt => pr_dtmvtolt --> Data do movimento atual
                                             ,pr_dtdpagto => rw_crapepr.dtdpagto --> Data de pagamento
                                             ,pr_vlatupar => pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vlatupar --> Valor atualizado da parcela
                                             ,pr_vldespar => pr_tab_pgto_parcel(vr_ind_pag)
                                                             .vldespar --> Valor desconto da parcela
                                             ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                             ,pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros
            -- Testar erro
            IF vr_des_reto = 'NOK' THEN
              -- Levantar exceção 2, onde já temos o erro na vr_tab_erro
              RAISE vr_exc_erro_2;
            END IF;
            -- Iniciar valor da flag
            pr_tab_pgto_parcel(vr_ind_pag).flgantec := TRUE;
            -- Guardar quantidades calculadas
            vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;
          END IF;
          -- Somente calcular se o empréstimo estiver liberado
          IF NOT pr_dtmvtolt <= rw_crawepr.dtlibera THEN
            /* Se liberado */
            -- Saldo devedor
            pr_tab_pgto_parcel(vr_ind_pag).vlsdvpar := rw_crappep.vlsdvpar;

            pr_tab_pgto_parcel(vr_ind_pag).vlatrpag := NVL(pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlatupar
                                                          ,0) +
                                                       NVL(pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlmtapar
                                                          ,0) +
                                                       NVL(pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vlmrapar
                                                          ,0) +
                                                       NVL(pr_tab_pgto_parcel(vr_ind_pag)
                                                           .vliofcpl
                                                          ,0);
            -- Saldo para relatorios
            vr_vlsderel := vr_vlsderel + pr_tab_pgto_parcel(vr_ind_pag)
                          .vlatupar;
            -- Saldo devedor total do emprestimo
            vr_vlsdeved := vr_vlsdeved + pr_tab_pgto_parcel(vr_ind_pag)
                          .vlatrpag;
          END IF;
        END LOOP;

        -- Limpar a variável
        vr_vllanmto := 0;

        -- Buscar o total pago no mês
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
        -- Se o empréstimo ainda não estiver liberado e não esteja liquidado
        IF pr_dtmvtolt <= rw_crawepr.dtlibera AND rw_crapepr.inliquid <> 1 THEN
          /* Nao liberado */
          -- Continuar com os valores da tabela
          pr_tab_calculado(1).vlsdeved := rw_crapepr.vlemprst;
          pr_tab_calculado(1).vlsderel := rw_crapepr.vlemprst;
          pr_tab_calculado(1).vlsdvctr := rw_crapepr.vlemprst;

         /* IF rw_crawepr.idfiniof = 1 THEN
             \*pr_tab_calculado(1).vlsdeved := rw_crapepr.vlemprst +
                                             NVL(rw_crapepr.vliofepr, 0) +
                                             NVL(rw_crapepr.vltarifa, 0);*\
             pr_tab_calculado(1).vlsdeved := rw_crapepr.vlsdeved;
           END IF;*/

          -- Zerar prestações pagas e a pagar
          pr_tab_calculado(1).vlprepag := 0;
          pr_tab_calculado(1).vlpreapg := 0;
        ELSE
          -- Utilizar informações do cálculo
          pr_tab_calculado(1).vlsdeved := vr_vlsdeved;
          pr_tab_calculado(1).vlsderel := vr_vlsderel;
          pr_tab_calculado(1).vlsdvctr := vr_vlsdvctr;

          pr_tab_calculado(1).vlprepag := vr_vlprepag;
          pr_tab_calculado(1).vlpreapg := vr_vlpreapg;
        END IF;


        -- Copiar qtde prestações calculadas
        pr_tab_calculado(1).qtprecal := rw_crapepr.qtprecal;
        -- Chegou ao final sem problemas, retorna OK
        pr_des_reto := 'OK';
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Gerar rotina de gravação de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        WHEN vr_exc_erro_2 THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Copiar tabela de erro temporária para saída da rotina
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_busca_pgto_parcelas> ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_busca_pgto_parcelas;

  /* Buscar a configuração de empréstimo cfme a empresa da conta */
  PROCEDURE pc_config_empresti_empresa(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data corrente
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da conta do empréstim
                                      ,pr_cdempres IN crapepr.cdempres%TYPE DEFAULT NULL --> Empresa do empréstimo ou se não passada do cadastro
                                      ,pr_dtcalcul OUT DATE --> Data calculada de pagamento
                                      ,pr_diapagto OUT INTEGER --> Dia de pagamento das parcelas
                                      ,pr_flgfolha OUT BOOLEAN --> Flag de desconto em folha S/N
                                      ,pr_ddmesnov OUT INTEGER --> Configuração para mês novo
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da critica
                                      ,pr_des_erro OUT VARCHAR2) IS --> Retorno de Erro
  BEGIN
    /* .............................................................................

       Programa: pc_config_empresti_empresa (antigo b1wgen0002-->obtem-parametros-tabs)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos (Supero)
       Data    : Fevereiro/2013.                    Ultima atualizacao: 21/10/2016

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : 1 - Buscar a empresa da conta ( cfme configuração de fisica ou juridica )
                   2 - Buscar a configuração do empréstimo da empresa

       Observações : As informações da CRAPTAB ficarão no vetor vr_tab_DIADOPAGTO, para
                     evitar tantos acessos na tabela, que torna o processo bastante lento

       Alteracoes: 29/05/2012 - Incluido parâmetro pr_ddmesnov para retornar os dados
                                da dstextab nas posições 1 e 2

                   20/08/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                   24/06/2015 - Ajuste para utilizar indice da tabela temporario com o
                                codigo da cooperativa juntamente com o codigo da empresa
                                na tabela vr_tab_diadopagto. (Jorge/Rodrigo)

                   03/08/2015 - Ajuste em adicionar NVL em dados do DIADOPAGTO.
                                (Jorge/Elton) - SD 303248

                   21/10/2016 - Ajuste para utilização do cursor padrão da craptab e
                                carga da temp-table completa apenas no batch. (Rodrigo)
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
      vr_dstextab craptab.dstextab%TYPE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    BEGIN
      -- Busca dos dados do associado
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_crapass;
      -- Se não encontrar
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
        -- Se já foi passada a empresa de busca
        IF nvl(pr_cdempres, 0) <> 0 THEN
          -- Utilizá-la
          vr_cdempres := pr_cdempres;
        ELSE
          -- Buscaremos cfme o tipo da pessoa
          -- Para pessoa física
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

      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
      INTO  rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Se o vetor não estiver carregado para a cooperativa e estiver no batch
      IF NOT vr_tab_diadopagto.EXISTS(pr_cdcooper) AND rw_crapdat.inproces > 1 THEN

        --Cria um primeiro registro apenas com o indice da cooperativa, para controle
        vr_tab_diadopagto(pr_cdcooper).diapgtoh := 0;

        -- Busca de todos registros para atualizar o vetor
        FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper
                                    ,pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'GENERI'
                                    ,pr_cdempres => 00
                                    ,pr_cdacesso => 'DIADOPAGTO') LOOP

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
      ELSE
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 00
                                                 ,pr_cdacesso => 'DIADOPAGTO'
                                                 ,pr_tpregist => vr_cdempres);

        -- Indice da tabela temporaria, cdcooper || cdempres Ex: 000010000000081
          vr_nrindice := LPAD(pr_cdcooper,5,'0') || LPAD(vr_cdempres,10,'0');

          -- Adicionar no vetor cmfe a empresa encontrada (tpregist)
          vr_tab_diadopagto(vr_nrindice).diapgtoh := NVL(TRIM(SUBSTR(vr_dstextab,7,2)),0);
          vr_tab_diadopagto(vr_nrindice).diapgtom := NVL(TRIM(SUBSTR(vr_dstextab,4,2)),0);
          vr_tab_diadopagto(vr_nrindice).flgfolha := NVL(TRIM(SUBSTR(vr_dstextab,14,1)),0);
          vr_tab_diadopagto(vr_nrindice).ddmesnov := NVL(TRIM(SUBSTR(vr_dstextab,1,2)),0);
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

      -- Se o tipo de salário fixo = Mensal
      IF rw_crapass.cdtipsfx IN (1, 3, 4) THEN
        -- Dia de pagamento está no campo diaphtom
        pr_diapagto := vr_tab_diadopagto(vr_nrindice).diapgtom;
      ELSE
        -- Horista
        -- Dia de pagamento está no campo diaphtoh
        pr_diapagto := vr_tab_diadopagto(vr_nrindice).diapgtoh;
      END IF;
      -- Retornar indicador de desconto em folha
      IF vr_tab_diadopagto(vr_nrindice).flgfolha = '1' THEN
        -- Desconto em folha
        pr_flgfolha := TRUE;
      ELSE
        -- Não é descontado em folha
        pr_flgfolha := FALSE;
      END IF;
      -- Retornar indicador de configuração para mês novo
      pr_ddmesnov := vr_tab_diadopagto(vr_nrindice).ddmesnov;
      -- Montar a data de pagamento cfme o dia encontrado e o mês e ano correntes
      pr_dtcalcul := to_date(to_char(pr_diapagto, 'fm00') || '/' ||
                             to_char(pr_dtmvtolt, 'mm/yyyy')
                            ,'dd/mm/yyyy');
      -- Garantir que a data de pamento caia em um dia util
      pr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper, pr_dtcalcul);
      -- Guardar agora o dia util do pagamento
      pr_diapagto := to_char(pr_dtcalcul, 'dd');
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(pr_cdcritic, 0);
        pr_des_erro := vr_des_erro;
      WHEN OTHERS THEN
        -- Montar mensagem com o sqlerrm pois ocorreu um erro crítico
        pr_cdcritic := NVL(pr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina empr0001.pc_config_empresti_empresa --> Detalhes: ' ||
                       sqlerrm;
    END;
  END pc_config_empresti_empresa;

  /* Calculo de saldo devedor em emprestimos baseado na includes/lelem.i. */
  PROCEDURE pc_calc_saldo_deved_epr_lem(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Código do programa corrente
                                       ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad   IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                                       ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero ctrato empréstimo
                                       ,pr_idorigem   IN INTEGER --> Id do módulo de sistema
                                       ,pr_txdjuros   IN crapepr.txjuremp%TYPE --> Taxa de juros aplicada
                                       ,pr_dtcalcul   IN DATE --> Data para calculo do empréstimo
                                       ,pr_diapagto   IN OUT INTEGER --> Dia para pagamento
                                       ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de prestações calculadas até momento
                                       ,pr_vlprepag   IN OUT NUMBER --> Valor acumulado pago no mês
                                       ,pr_vlpreapg   IN OUT NUMBER --> Valor a pagar
                                       ,pr_vljurmes   IN OUT NUMBER --> Juros no mês corrente
                                       ,pr_vljuracu   IN OUT NUMBER --> Juros acumulados total
                                       ,pr_vlsdeved   IN OUT NUMBER --> Saldo devedor acumulado
                                       ,pr_dtultpag   IN OUT crapepr.dtultpag%TYPE --> Ultimo dia de pagamento das prestações
                                       ,pr_vlmrapar   IN OUT crappep.vlmrapar%TYPE --> Valor do Juros de Mora
                                       ,pr_vlmtapar   IN OUT crappep.vlmtapar%TYPE --> Valor da Multa
                                       ,pr_vliofcpl   IN OUT crappep.vliofcpl%TYPE --> Valor da Multa
                                       ,pr_vlprvenc   IN OUT NUMBER --> Valor a parcela a vencer
                                       ,pr_vlpraven   IN OUT NUMBER --> Valor da parcela vencida
                                       ,pr_flgerlog   IN VARCHAR2 --> Gerar log S/N
                                       ,pr_des_reto   OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro   OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................
       Programa: pc_calc_saldo_deved_epr_lem (antigo sistema/generico/includes/b1wgen0002.i )
       Autora  : Mirtes.
       Data    : 14/09/2005                        Ultima atualizacao: 26/07/2017

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

                   23/04/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

                   26/08/2013 - Inclusão dos códigos de históricos fixos a retornar
                                no cursor cr_craplem cfme ajuste liberado em produção
                                progress em 02/08/2013 (Marcos-Supero)

                   12/09/2013 - Ordenar cursor da craplem para ficar igual ao do
                                progress.
                                Incluir somatoria do pr_vlprepag com o valor de
                                lancamento da craplem.

                   12/03/2014 - Alterada a chamada para da  pc_busca_pgto_parcelas
                                 para pc_busca_pgto_parcelas_prefix (Odirlei-AMcom)

                   26/07/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

    ............................................................................. */
    DECLARE
      -- Busca dados específicos do empréstimo para a rotina
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
              ,idfiniof
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
      -- cooperativas com tipo de transferência = 1 (Conta Corrente)
      CURSOR cr_craptco IS
        SELECT 1
          FROM craptco tco
         WHERE tco.cdcopant = pr_cdcooper
               AND tco.nrctaant = pr_nrdconta
               AND tco.tpctatrf = 1
               AND tco.flgativo = 1; --> True
      vr_ind_tco NUMBER(1);
      -- Buscar informações de pagamentos do empréstimos
      --   Enviando uma data para filtrar movimentos posteriores a mesma
      --   -> Pode ser enviado um tipo de histórico para busca a partir dele
      /*
       88 - ESTORNO DE PAGAMENTO DE EMPRESTIMO
       91 - PAGTO EMPRESTIMO C/C
       92 - PAGTO EMPRESTIMO EM CAIXA
       93 - PAGTO EMPRESTIMO EM FOLHA
       94 - DESCONTO E/OU ABONO CONCEDIDO NO EMPRESTIMO
       95 - PAGTO EMPRESTIMO C/C
       120 - SOBRAS DE EMPRESTIMOS
       277 - ESTORNO DE JUROS S/EMPR. E FINANC.
       349 - EMPRESTIMO TRANSFERIDO PARA PREJUIZO
       353 - PAGAMENTO DE EMPRESTIMO COM SAQUE DE CAPITAL
       392 - ABATIMENTO CONCEDIDO NO EMPRESTIMO
       393 - PAGAMENTO EMPRESTIMO PELO FIADOR/AVALISTA
       395 - TAXAS/SERVICOS/REGISTROS/HONORARIOS
       441 - JUROS SOBRE EMPRESTIMOS EM ATRASO
       443 - MULTA SOBRE EMPRESTIMOS EM ATRASO
       507 - ESTORNO DE TRANSFERENCIA DE COTAS
       2381 - TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO
       2396 - TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO
       2401 - TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO

      */
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
           -- Somente retornando os tipos de histórico abaixo
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
           AND lem.cdhistor IN(88,91,92,93,94,95,120,277,349,353,392,393,507,395,441,443, 2381, 2396,2401)
      ORDER BY lem.cdcooper
              ,lem.nrdconta
              ,lem.nrctremp
              ,lem.dtmvtolt
              ,lem.progress_recid
              ,lem.nrseqdig;

      rw_craplem cr_craplem%ROWTYPE;
      -- Buscar informações de pagamentos do empréstimos
      --   Enviando um tipo de histórico para busca a partir dele
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
      vr_dtmesant        crapdat.dtmvtolt%TYPE; --> Data do mês anterior ao movimento
      vr_flctamig        BOOLEAN; --> Conta migrada entre cooperativas
      vr_nrdiacal        INTEGER; --> Número de dias para o cálculo
      vr_inhst093        BOOLEAN; --> ???
      TYPE vr_tab_vlrpgmes IS TABLE OF crapepr.vlpreemp%TYPE INDEX BY BINARY_INTEGER;
      vr_vet_vlrpgmes vr_tab_vlrpgmes; --> Vetor e tipo para acumulo de pagamentos no mês
      vr_qtdpgmes     INTEGER; --> Indice de prestações
      --vr_qtprepag NUMBER(18,4);         --> Qtde paga de prestações no mês
      vr_qtprepag NUMBER; --> Qtde paga de prestações no mês
      vr_exipgmes BOOLEAN; --> Teste para busca no vetor de pagamentos
      vr_vljurmes NUMBER; --> Juros no mês corrente
      vr_nrdiames INTEGER; --> Número de dias para o cálculo no mês corrente
      vr_nrdiaprx INTEGER; --> Número de dias para o cálculo no próximo mês
      vr_exc_erro2 EXCEPTION; --> Exception especifica quando já existe erro na tab_erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

    BEGIN
      -- Busca dados específicos do empréstimo para a rotina
      OPEN cr_crapepr;
      FETCH cr_crapepr
        INTO rw_crapepr;
      -- Se não encontrar informações
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
      -- Para empréstimo pré-fixado
      IF rw_crapepr.tpemprst = 1 THEN

        /* Busca dos pagamentos das parcelas de empréstimo pre-fixados*/
        empr0001.pc_busca_pgto_parcelas_prefix(pr_cdcooper      => pr_cdcooper --> Cooperativa conectada
                                              ,pr_cdagenci      => pr_cdagenci --> Código da agência
                                              ,pr_nrdcaixa      => pr_nrdcaixa --> Número do caixa
                                              ,pr_nrdconta      => pr_nrdconta --> Número da conta
                                              ,pr_nrctremp      => pr_nrctremp --> Número do contrato de empréstimo
                                              ,pr_rw_crapdat    => pr_rw_crapdat --> Vetor com dados de parâmetro (CRAPDAT)
                                              ,pr_dtmvtolt      => pr_rw_crapdat.dtmvtolt --> Data de movimento
                                              ,pr_vlemprst      => rw_crapepr.vlemprst --> Valor do emprestioms
                                              ,pr_qtpreemp      => rw_crapepr.qtpreemp --> qtd de parcelas do emprestimo
                                              ,pr_dtdpagto      => rw_crapepr.dtdpagto --> data de pagamento
                                              ,pr_txmensal      => rw_crapepr.txmensal --> Taxa mensal do emprestimo
                                              ,pr_cdlcremp      => rw_crapepr.cdlcremp --> Taxa mensal do emprestimo
                                              ,pr_qttolatr      => rw_crapepr.qttolatr --> Quantidade de dias de tolerancia
                                              ,pr_des_reto      => vr_des_reto --> Retorno OK / NOK
                                              ,pr_tab_erro      => vr_tab_erro --> Tabela com possíves erros
                                              ,pr_tab_calculado => vr_tab_calculado); --> Tabela com totais calculados

        -- Se a rotina retornou erro
        IF vr_des_reto = 'NOK' THEN
          -- Gerar exceção
          RAISE vr_exc_erro2;
        END IF;
        -- Copiar os valores da rotina para as variaveis de saída
        pr_vlsdeved := vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved;
        pr_qtprecal := vr_tab_calculado(vr_tab_calculado.FIRST).qtprecal;
        pr_vlprepag := vr_tab_calculado(vr_tab_calculado.FIRST).vlprepag;
        pr_vlpreapg := vr_tab_calculado(vr_tab_calculado.FIRST).vlpreapg;
        pr_vljuracu := rw_crapepr.vljuracu;
        pr_vlmrapar := vr_tab_calculado(vr_tab_calculado.FIRST).vlmrapar;
        pr_vlmtapar := vr_tab_calculado(vr_tab_calculado.FIRST).vlmtapar;
        pr_vliofcpl := vr_tab_calculado(vr_tab_calculado.FIRST).vliofcpl;
        pr_vlprvenc := vr_tab_calculado(vr_tab_calculado.FIRST).vlprvenc;
        pr_vlpraven := vr_tab_calculado(vr_tab_calculado.FIRST).vlpraven;

      -- Price Pos-Fixado
      ELSIF rw_crapepr.tpemprst = 2 THEN

        -- Seta valor de saida
        pr_qtprecal := rw_crapepr.qtprecal;

        -- Busca soma paga no mes
        EMPR0011.pc_busca_prest_pago_mes_pos(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_nrctremp => pr_nrctremp
                                            ,pr_dtmvtolt => TO_CHAR(pr_rw_crapdat.dtmvtolt,'DD/MM/RRRR')
                                            ,pr_vllanmto => pr_vlprepag
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Busca os valores calculados
        EMPR0011.pc_busca_pagto_parc_pos_prog(pr_cdcooper => pr_cdcooper
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_dtmvtolt => TO_CHAR(pr_rw_crapdat.dtmvtolt,'DD/MM/RRRR')
                                             ,pr_dtmvtoan => TO_CHAR(pr_rw_crapdat.dtmvtoan,'DD/MM/RRRR')
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrctremp => pr_nrctremp
                                             --,pr_cdlcremp => rw_crapepr.cdlcremp
                                             --,pr_qttolatr => rw_crapepr.qttolatr
                                             ,pr_vlsdeved => pr_vlsdeved
                                             ,pr_vlprvenc => pr_vlpreapg
                                             ,pr_vlpraven => pr_vlpraven
                                             ,pr_vlmtapar => pr_vlmtapar
                                             ,pr_vlmrapar => pr_vlmrapar
                                             ,pr_vliofcpl => pr_vliofcpl
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        pr_vlprvenc := pr_vlpreapg;

      -- Price TR
      ELSIF rw_crapepr.tpemprst = 0 THEN

        -- Busca flag de debito em conta da empresa
        OPEN cr_crapemp;
        FETCH cr_crapemp
          INTO vr_flgpagto_emp,vr_flgpgtib_emp;
        -- Se encontrou registro e o tipo de débito for Conta (0-False)
        IF cr_crapemp%FOUND
           AND (vr_flgpagto_emp = 0 OR vr_flgpgtib_emp = 0) THEN
          -- Desconsiderar o dia para pagamento enviado
          pr_diapagto := 0;
        END IF;
        CLOSE cr_crapemp;
        -- Se foi enviado dia para pagamento and o tipo de débito do empréstimo for Conta (0-False)
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
        -- Mês anterior ao movimento
        vr_dtmesant := vr_dtmvtolt - to_char(vr_dtmvtolt, 'dd');
        -- Se a data de contratação do empréstimo estiver no mês corrente do movimento
        IF trunc(rw_crapepr.dtmvtolt, 'mm') = trunc(vr_dtmvtolt, 'mm') THEN
          -- Retornar o dia da data de contratação
          vr_nrdiacal := to_char(rw_crapepr.dtmvtolt, 'dd');
        ELSE
          -- Não há dias em atraso
          vr_nrdiacal := 0;
        END IF;
        -- Possui Historico 93
        vr_inhst093 := FALSE;
        -- Zerar juros calculados, qtdes e valor pago no mês
        vr_vljurmes := 0;
        pr_vlprepag := 0;
        pr_vlpreapg := 0;
        pr_qtprecal := 0;
        vr_qtdpgmes := 0;
        -- Se estiver rodando no Batch e é processo mensal
        IF pr_rw_crapdat.inproces > 2
           AND pr_cdprogra IN ('CRPS080', 'CRPS085', 'CRPS120') THEN
          -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes próximo dia
          IF TRUNC(vr_dtmvtolt, 'mm') <>
             TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
            -- Data de movimento e do mês anterior recebem o ultimo dia do mês
            -- corrente da data de movimento passada originalmente
            vr_dtmvtolt := pr_rw_crapdat.dtultdia;
            vr_dtmesant := pr_rw_crapdat.dtultdia;
            -- Zerar número de dias para cálculo
            vr_nrdiacal := 0;
          END IF;
        END IF;
        -- Se o empréstimo está liquidado e não existe saldo devedor
        IF rw_crapepr.inliquid = 1
           AND NVL(pr_vlsdeved, 0) = 0 THEN
          -- Verificar se existe registro de conta transferida entre
          -- cooperativas com tipo de transferência = 1 (Conta Corrente)
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
        -- Somente buscar os pagamentos se a conta não foi migrada
        IF NOT vr_flctamig THEN
          -- Buscar todos os pagamentos do empréstimo
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
            /*
              88 - ESTORNO DE PAGAMENTO DE EMPRESTIMO
              91 - PAGTO EMPRESTIMO C/C
              92 - PAGTO EMPRESTIMO EM CAIXA
              93 - PAGTO EMPRESTIMO EM FOLHA
              94 - DESCONTO E/OU ABONO CONCEDIDO NO EMPRESTIMO
              95 - PAGTO EMPRESTIMO C/C
              120 - SOBRAS DE EMPRESTIMOS
              277 - ESTORNO DE JUROS S/EMPR. E FINANC.
              349 - EMPRESTIMO TRANSFERIDO PARA PREJUIZO
              353 - PAGAMENTO DE EMPRESTIMO COM SAQUE DE CAPITAL
              392 - ABATIMENTO CONCEDIDO NO EMPRESTIMO
              393 - PAGAMENTO EMPRESTIMO PELO FIADOR/AVALISTA
              507 - ESTORNO DE TRANSFERENCIA DE COTAS
              2381 - TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO
              2396 - TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO
              2401 - TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO*/
            IF rw_craplem.cdhistor IN
               (88, 91, 92, 93, 94, 95, 120, 277, 349, 353, 392, 393, 507) THEN
              -- Zerar quantidade paga
              vr_qtprepag := 0;
              -- Garantir que não haja divisão por zero
              IF rw_craplem.vlpreemp > 0 THEN
                -- Quantidade paga é a divisão do lançamento pelo valor da prestação
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
                -- Não considerar este pagamento para abatimento de prestações
                pr_qtprecal := pr_qtprecal - vr_qtprepag;
              ELSE
                -- Considera este pagamento para abatimento de prestações
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
                -- Se o dia para calculo for superior ao dia de lançamento do emprestimo
                IF vr_nrdiacal > rw_craplem.ddlanmto THEN
                  -- Utilizar o valor de lançamento para calculo dos juros
                  vr_vljurmes := vr_vljurmes +
                                 (rw_craplem.vllanmto * pr_txdjuros *
                                 (rw_craplem.ddlanmto - vr_nrdiacal));
                ELSE
                  -- Utilizar o saldo devedor já acumulado
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
                -- Utilizar o dia do empréstimo
                vr_nrdiacal := rw_craplem.ddlanmto;
              END IF;
              -- Diminuir saldo devedor
              pr_vlsdeved := NVL(pr_vlsdeved, 0) - rw_craplem.vllanmto;
              -- Acumular valor prestação pagos
              pr_vlprepag := pr_vlprepag + rw_craplem.vllanmto;
              -- Acumular número de pagamentos no mês
              vr_qtdpgmes := vr_qtdpgmes + 1;
              -- Incluir lançamento no vetor de pagamentos
              vr_vet_vlrpgmes(vr_qtdpgmes) := rw_craplem.vllanmto;
              -- Para os tipos abaixo relacionados
              -- --- --------------------------------------------------
              --  93 PG. EMPR. FP.
              --  95 PG. EMPR. C/C
            ELSIF rw_craplem.cdhistor IN (93, 95) THEN
              -- Guardar data do ultimo pagamento
              pr_dtultpag := rw_craplem.dtmvtolt;
              -- Se o dia do lançamento é superior ao dia de pagamento passado
              IF rw_craplem.ddlanmto > pr_diapagto THEN
                -- Se houver saldo devedor
                IF pr_vlsdeved > 0 THEN
                  -- Acumular os juros
                  vr_vljurmes := vr_vljurmes +
                                 (pr_vlsdeved * pr_txdjuros *
                                 (rw_craplem.ddlanmto - vr_nrdiacal));
                  -- Dia calculo recebe o dia do lançamento
                  vr_nrdiacal := rw_craplem.ddlanmto;
                ELSE
                  -- Dia calculo recebe o dia do lançamento
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

              -- Acumular número de pagamentos no mês
              vr_qtdpgmes := vr_qtdpgmes + 1;
              -- Incluir lançamento no vetor de pagamentos
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
                -- Se o dia do lançamento for inferior ao dia de pagamento enviado
                IF rw_craplem.ddlanmto < pr_diapagto THEN
                  -- Se o dia calculado for igual ao dia de pagamento enviado
                  IF vr_nrdiacal = pr_diapagto THEN
                    -- Acumular os juros com base na taxa e na diferença entre o dia enviado e o do lançamento
                    vr_vljurmes := vr_vljurmes +
                                   (rw_craplem.vllanmto * pr_txdjuros *
                                   (pr_diapagto - rw_craplem.ddlanmto));
                  ELSE
                    -- Acumular os juros com base na taxa e na diferença entre o dia o lançamento e o dia de cálculo
                    vr_vljurmes := vr_vljurmes +
                                   (pr_vlsdeved * pr_txdjuros *
                                   (rw_craplem.ddlanmto - vr_nrdiacal));
                    -- Utilizar como dia de cálculo o dia deste lançamento
                    vr_nrdiacal := rw_craplem.ddlanmto;
                  END IF;
                ELSIF rw_craplem.ddlanmto > pr_diapagto THEN
                  -- Calcular o juros
                  vr_vljurmes := vr_vljurmes +
                                 (pr_vlsdeved * pr_txdjuros *
                                 (rw_craplem.ddlanmto - vr_nrdiacal));
                  -- Dia para calculo recebe o dia deste lançamento
                  vr_nrdiacal := rw_craplem.ddlanmto;
                END IF;
              ELSE
                -- Atualizando nro do dia para calculo
                -- Caso o dia seja superior ao dia do lançamento do pagamento
                IF vr_nrdiacal > rw_craplem.ddlanmto THEN
                  -- Mantem o mesmo valor
                  vr_nrdiacal := vr_nrdiacal;
                ELSE
                  -- Utilizar o dia do empréstimo
                  vr_nrdiacal := rw_craplem.ddlanmto;
                END IF;
              END IF;
              -- Para estornos abaixo relacionados
              -- --- --------------------------------------------------
              --  88 ESTORNO PAGTO
              -- 507 EST.TRF.COTAS
              IF rw_craplem.cdhistor IN (88, 507) THEN
                -- Não considerar este lançamento no valor pago
                pr_vlprepag := pr_vlprepag - rw_craplem.vllanmto;
                -- Se o valor ficar negativo
                IF pr_vlprepag < 0 THEN
                  -- Então zera novamente
                  pr_vlprepag := 0;
                END IF;
              END IF;
              -- Acumular o lançamento no saldo devedor
              pr_vlsdeved := pr_vlsdeved + rw_craplem.vllanmto;
              -- Testar se existe pagamento com o mesmo valor no vetor de pagamentos
              vr_exipgmes := FALSE;
              -- Ler o vetor de pagamentos
              FOR vr_aux IN 1 .. vr_qtdpgmes LOOP
                -- Se o valor do vetor é igual ao do pagamento
                IF vr_vet_vlrpgmes(vr_aux) = rw_craplem.vllanmto THEN
                  -- Indica que encontrou o pagamento no vetor
                  vr_exipgmes := TRUE;
                END IF;
              END LOOP;
              -- Se tiver encontrado
              IF vr_exipgmes THEN
                -- Se o pagamento não for dos estornos abaixo relacionados
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
          -- Se é processo mensal
          IF pr_cdprogra IN ('CRPS080', 'CRPS085', 'CRPS120') THEN
            -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes próximo dia
            IF TRUNC(vr_dtmvtolt, 'mm') <>
               TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
              -- Zerar número de dias para cálculo
              vr_nrdiacal := 0;
            ELSE
              -- Dia para cálculo recebe o dia enviado - o dia dalculado
              vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
            END IF;
          ELSE
            --> Não é processo mensal
            -- Se estivermos processando o fechamento, ou seja, mes movto atual diferente mes próximo dia
            IF TRUNC(vr_dtmvtolt, 'mm') <>
               TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') THEN
              -- Dia para calculo recebe o ultimo dia do mês - o dia calculado
              vr_nrdiacal := to_char(pr_rw_crapdat.dtultdia, 'dd') -
                             vr_nrdiacal;
            ELSE
              -- Dia para cálculo recebe o dia enviado - o dia dalculado
              vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
            END IF;
          END IF;
        ELSE
          -- Dia para cálculo recebe o dia enviado - o dia dalculado
          vr_nrdiacal := to_char(vr_dtmvtolt, 'dd') - vr_nrdiacal;
        END IF;
        -- Se existir saldo devedor
        IF pr_vlsdeved > 0 THEN
          -- Sumarizar juros do mês
          vr_vljurmes := vr_vljurmes +
                         (pr_vlsdeved * pr_txdjuros * vr_nrdiacal);
        END IF;
        -- Zerar qtde dias para cálculo
        vr_nrdiacal := 0;
        -- Se foi enviado data para calculo e existe saldo devedor
        IF pr_dtcalcul IS NOT NULL
           AND pr_vlsdeved > 0 THEN
          -- Dias para calculo recebe a data para calculo - dia do movimento
          vr_nrdiacal := trunc(pr_dtcalcul - vr_dtmvtolt);
          -- Se foi enviada uma data para calculo posterior ao ultimo dia do mês corrente
          IF pr_dtcalcul > pr_rw_crapdat.dtultdia THEN
            -- Qtde dias para calculo de juros no mês corrente
            -- É a diferença entre o ultimo dia - data movimento
            vr_nrdiames := TO_NUMBER(TO_CHAR(pr_rw_crapdat.dtultdia, 'DD')) -
                           TO_NUMBER(TO_CHAR(vr_dtmvtolt, 'DD'));
            -- Qtde dias para calculo de juros no próximo mês
            -- É a diferente entre o total de dias - os dias do mês corrente
            vr_nrdiaprx := vr_nrdiacal - vr_nrdiames;
          ELSE
            --> Estamos no mesmo mês
            -- Quantidade de dias no mês recebe a quantidade de dias calculada
            vr_nrdiames := vr_nrdiacal;
            -- Não existe calculo para o próximo mês
            vr_nrdiaprx := 0;
          END IF;
          -- Acumular juros com o número de dias no mês corrente
          vr_vljurmes := vr_vljurmes +
                         (pr_vlsdeved * pr_txdjuros * vr_nrdiames);
          -- Se a data enviada for do próximo mês
          IF vr_nrdiaprx > 0 THEN
            -- Arredondar os juros calculados
            vr_vljurmes := ROUND(vr_vljurmes, 2);
            -- Acumular no saldo devedor do mês corrente os juros
            pr_vlsdeved := pr_vlsdeved + vr_vljurmes;
            -- Acumular no totalizador de juros o juros calculados
            pr_vljuracu := pr_vljuracu + vr_vljurmes;
            -- Novamente calculamos os juros, porém somente com base nos dias do próximo mês
            vr_vljurmes := (pr_vlsdeved * pr_txdjuros * vr_nrdiaprx);
          END IF;
          -- Se o dia da data enviada for inferior ao dia para pagamento enviado
          IF to_char(pr_dtcalcul, 'dd') < pr_diapagto THEN
            -- Dias para pagamento recebe essa diferença
            vr_nrdiacal := pr_diapagto - to_char(pr_dtcalcul, 'dd');
          ELSE
            -- Ainda não venceu
            vr_nrdiacal := 0;
          END IF;
        ELSE
          -- Se o dia para cálculo for anterior ao dia enviado para pagamento
          --  E Não pode ser processo batch
          --  E deve haver saldo devedor
          --  E não pode ser inhst093 - ???
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
        -- Calcula juros sobre a prest. quando a consulta é menor que o data pagto
        -- Se existe dias para calculo e a data de pagamento contratada é inferior ao ultimo dias do mês corrente
        IF vr_nrdiacal > 0
           AND rw_crapepr.dtdpagto <= pr_rw_crapdat.dtultdia THEN
          -- Se o saldo devedor for superior ao valor contratado de prestação
          IF pr_vlsdeved > rw_crapepr.vlpreemp THEN
            -- Juros no mês são baseados no valor contratado
            vr_vljurmes := vr_vljurmes +
                           (rw_crapepr.vlpreemp * pr_txdjuros * vr_nrdiacal);
          ELSE
            -- Juros no mês são baseados no saldo devedor
            vr_vljurmes := vr_vljurmes +
                           (pr_vlsdeved * pr_txdjuros * vr_nrdiacal);
          END IF;
        END IF;
        -- Arredondar juros no mês
        vr_vljurmes := ROUND(vr_vljurmes, 2);
        -- Acumular juros calculados
        pr_vljuracu := pr_vljuracu + vr_vljurmes;
        -- Incluir no saldo devedor os juros do mês
        pr_vlsdeved := pr_vlsdeved + vr_vljurmes;
        -- Se houver indicação de liquidação do empréstimo
        -- E ainda existe saldo devedor
        IF pr_vlsdeved > 0
           AND rw_crapepr.inliquid > 0 THEN
          -- Se estiver rodando o processo batch no programa crps078
          IF pr_rw_crapdat.inproces > 2
             AND pr_cdprogra = 'CRPS078' THEN
            -- Se os juros do mês forem iguais ou superiores ao saldo devedor
            IF vr_vljurmes >= pr_vlsdeved THEN
              -- Remover dos juros do mês e do juros acumulados o saldo devedor
              vr_vljurmes := vr_vljurmes - pr_vlsdeved;
              pr_vljuracu := pr_vljuracu - pr_vlsdeved;
              -- Zerar o saldo devedor
              pr_vlsdeved := 0;
            ELSE
              -- Gerar crítica
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
            -- Remover dos juros do mês e do juros acumulados o saldo devedor
            vr_vljurmes := vr_vljurmes - pr_vlsdeved;
            pr_vljuracu := pr_vljuracu - pr_vlsdeved;
            -- Zerar o saldo devedor
            pr_vlsdeved := 0;
          END IF;
        END IF;
        -- Copiar para a saída os juros calculados
        pr_vljurmes := vr_vljurmes;
      END IF;
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      WHEN vr_exc_erro2 THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Copiar o erro já existente na variavel para
        pr_tab_erro := vr_tab_erro;
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_calc_saldo_deved_epr_lem> ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                   ,pr_cdagenci       IN crapass.cdagenci%TYPE --> Código da agência
                                   ,pr_nrdcaixa       IN craperr.nrdcaixa%TYPE --> Número do caixa
                                   ,pr_cdoperad       IN crapdev.cdoperad%TYPE --> Código do operador
                                   ,pr_nmdatela       IN VARCHAR2 --> Nome datela conectada
                                   ,pr_idorigem       IN INTEGER --> Indicador da origem da chamada
                                   ,pr_nrdconta       IN crapass.nrdconta%TYPE --> Conta do associado
                                   ,pr_idseqttl       IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                   ,pr_rw_crapdat     IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                                   ,pr_dtcalcul       IN DATE --> Data solicitada do calculo
                                   ,pr_nrctremp       IN crapepr.nrctremp%TYPE --> Número contrato empréstimo
                                   ,pr_cdprogra       IN crapprg.cdprogra%TYPE --> Programa conectado
                                   ,pr_inusatab       IN BOOLEAN --> Indicador de utilização da tabela
                                   ,pr_flgerlog       IN VARCHAR2 --> Gerar log S/N
                                   ,pr_flgcondc       IN BOOLEAN --> Mostrar emprestimos liquidados sem prejuizo
                                   ,pr_nmprimtl       IN crapass.nmprimtl%TYPE --> Nome Primeiro Titular
                                   ,pr_tab_parempctl  IN craptab.dstextab%TYPE --> Dados tabela parametro
                                   ,pr_tab_digitaliza IN craptab.dstextab%TYPE --> Dados tabela parametro
                                   ,pr_nriniseq       IN INTEGER --> Numero inicial da paginacao
                                   ,pr_nrregist       IN INTEGER --> Numero de registros por pagina
                                   ,pr_qtregist       OUT INTEGER --> Qtde total de registros
                                   ,pr_tab_dados_epr  OUT typ_tab_dados_epr --> Saida com os dados do empréstimo
                                   ,pr_des_reto       OUT VARCHAR --> Retorno OK / NOK
                                   ,pr_tab_erro       OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros

  BEGIN
    /* .............................................................................

       Programa: pc_obtem_dados_empresti (antigo b1wgen0002.p --> obtem-dados-emprestimos)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos (Supero)
       Data    : Abril/2013.                         Ultima atualizacao: 07/08/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Procedure para obter dados de emprestimos do associado

       Alteracoes:  22/04/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

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
                                 se o contrato é pre-aprovado. (James)

                    10/02/2015 - Ajuste no calculo do prejuizo para o emprestimo PP. (James)

                    20/05/2015 - Ajuste para verificar se cobra multa. (James)

                    12/06/2015 - Adicao de campos para geracao do extrato da
                                 portabilidade de credito. (Jaison/Diego - SD: 290027)

                    29/10/2015 - Ajustado busca na crappep onde identifica as parcelas vencidas,
                                 para nao considerar como vencidas as parcelas com vencimento no final de semana
                                 SD318820 (Odirlei-AMcom)

                    05/11/2015 - Ajustes identificados na validação da pc_obtem_dados_empresti_web
                                 diferenças entre a versão progress e oracle SD318820 (Odirlei-Amcom)

                    06/11/2015 - Replicar ajustes feitos no projeto portabilidade na BO b1wgen0002.obtem-dados-emprestimos
                                 Ajustado contador de paginação SD318820 (Odirlei-AMcom)

                    30/11/2015 - Ajustes de performace devido a lentidao do crps665,
                                 tratado para que select na crplcm(tratamento pre-aprovado) só seja executado
                                 se idorigem <> 7-batch (Odirlei-AMcom)

                    11/05/2016 - Calculo vlatraso na chamada pc_calcula_atraso_tr.
                                 (Jaison/James)

                    16/11/2016 - Realizado ajuste para corrigir o problema ao abrir o detalhamento
                                 do emprestimo na tela prestações, conforme solicitado no chamado
                                 553330. (Kelvin)

                    23/06/2017 - Inclusao dos campos do produto Pos-Fixado. (Jaison/James - PRJ298)

                    06/10/2017 - SD770151 - Correção de informações na proposta de empréstimo
                                 convertida (Marcos-Supero)

                    19/10/2017 - Inclusão campo vliofcpl no XML de retorno (Diogo - MoutS - Proj. 410 - RF 41/42)

                    26/10/2017 - Passagem do tpctrato fixo 90. (Jaison/Marcos Martini - PRJ404)

                    21/12/2017 - Ajuste no carregamento dos dados do avalista, pois o campo possui
                                 50 caracteres e a tabela de memória também, porém quando o valor
                                 é adicionado na tabela de memória são concatenados três caracteres
                                 (" - ") que acabam estourando o tamanho do campo.
                                 (Douglas - Chamado 819534)

                    07/06/2018 - P410 - Inclusao de campos do IOF (Marcos-Envolti)

                    07/08/2018 - P410 - Retornar pagamentos IOF Prejuizo (Marcos-Envolti)

                    23/10/2018 - PJ298.2 - Validar emprestimo migrado para listar na tela prestacoes (Rafael Faria-Supero)

                    04/01/2019 - chamado INC0027294 (Fabio-Amcom)

                    26/03/2019 - P450 -Rating, substituir a tabela craprnc por tbrisco_operacoes (Elton AMcom) 
     
                    25/04/2019 - P450 -Rating, incluir a tabela craprnc quando a coopertativa for 3 - Ailos (Heckmann/AMcom)

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
              ,qttolatr
              ,vliofcpl
              ,idfiniof
              ,vliofepr
              ,vltarifa
              ,vltiofpr
              ,vlpiofpr
          FROM crapepr
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = DECODE(pr_nrctremp, 0, nrctremp, pr_nrctremp) --> Se zero traz todos, senão só ele
         ORDER BY cdlcremp
                 ,cdfinemp;

      -- Buscar dados da linha de crédito
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

      -- Busca dos dados de complemento do empréstimo
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
              ,tpatuidx
              ,idcarenc
              ,dtcarenc
              ,epr.cdoperad
              ,vlprecar
          FROM crawepr epr
         WHERE epr.cdcooper = pr_cdcooper
               AND epr.nrdconta = pr_nrdconta
               AND epr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;

      -- Leitura da descricao da finalidade do emprestimo
      CURSOR cr_crapfin(pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
        SELECT dsfinemp,
               tpfinali
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
               AND nrctremp = pr_nrctremp
               AND tpctrato = 90; -- Emprestimo/Financiamento
      vr_qtaditiv INTEGER;

      -- Busca dos avalistas terceiros
      CURSOR cr_crapavt(pr_nrctremp IN crapavt.nrctremp%TYPE) IS
        SELECT nrcpfcgc
              ,nmdavali
          FROM crapavt
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = pr_nrctremp
               AND tpctrato = 1; --> Empréstimo

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

      -- Buscar dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper NUMBER) IS
        SELECT t.flintcdc
          FROM crapcop t
         WHERE t.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- nova M324
      CURSOR cr_craplem1(prc_nrctremp craplem.nrctremp%TYPE) IS
        SELECT sum(case when c.cdhistor in (382,384,2388,2473,2389,2390,2475) then c.vllanmto else 0 end)
               -
               sum(case when c.cdhistor in (2392,2474,2393,2394,2476) then c.vllanmto else 0 end) valor_pago
          FROM craplem c
         WHERE c.cdcooper = pr_cdcooper
           AND c.nrdconta = pr_nrdconta
           AND c.nrctremp = prc_nrctremp
           AND c.cdhistor in(382, /* Pagamentos */
                             384, /*PAGAMENTO DE PREJUIZO*/
                             2388, /* 2388 - PAGAMENTO DE PREJUIZO VALOR PRINCIPAL */
                             2473, /* 2473 - PAGAMENTO JUROS +60 PREJUIZO */
                             2389, /* 2389 - PAGAMENTO JUROS PREJUIZO */
                             2390, /* 2390 - PAGAMENTO MULTA ATRASO PREJUIZO */
                             2475, /* 2475 - PAGAMENTO JUROS MORA PREJUIZO */

                             2392, /* 2392 - ESTORNO PAGAMENTO DE PREJUIZO VALOR PRINCIPAL */
                             2474, /* 2474 - ESTORNO PAGAMENTO JUROS +60 PREJUIZO */
                             2393, /* 2393 - ESTORNO PAGAMENTO DE JUROS PREJUIZO */
                             2394, /* 2394 - ESTORNO PAGAMENTO MULTA ATRASO PREJUIZO */
                             2476);

      -- nova M324
      CURSOR cr_craplem2(prc_nrctremp craplem.nrctremp%TYPE) IS
        SELECT sum(case when c.cdhistor in (383,2391) then c.vllanmto else 0 end)
               -
               sum(case when c.cdhistor in (2395) then c.vllanmto else 0 end) valor_pago_abono
          FROM craplem c
         WHERE c.cdcooper = pr_cdcooper
           AND c.nrdconta = pr_nrdconta
           AND c.nrctremp = prc_nrctremp
           AND c.cdhistor in(383, /*ABONO DE PREJUIZO*/
                             2391, /*ABONO DE PREJUIZO*/
                             2395); /*ESTORNO ABONO DE PREJUIZO*/

      -- nova M324
      CURSOR cr_craplem3(prc_nrctremp craplem.nrctremp%TYPE) IS
        SELECT sum(case when c.cdhistor in (382,2388,2473,2389,2391) then c.vllanmto else 0 end) -
                  (sum(case when c.cdhistor in (2392,2474,2393,2395) then c.vllanmto else 0 end))sum_sldPrinc
          FROM craplem c
         WHERE c.cdcooper = pr_cdcooper
           AND c.nrdconta = pr_nrdconta
           AND c.nrctremp = prc_nrctremp
           AND c.cdhistor in (382,2388,2473,2389,2391, 2392,2474,2393,2395);

      --nova M324
      CURSOR cr_craplem4(prc_nrctremp craplem.nrctremp%TYPE) IS
        SELECT nvl(sum(case when c.cdhistor in (2391) then c.vllanmto else 0 end)
               -
               sum(case when c.cdhistor in (2395) then c.vllanmto else 0 end),0) valor_pago_abono
          FROM craplem c
         WHERE c.cdcooper = pr_cdcooper
           AND c.nrdconta = pr_nrdconta
           AND c.nrctremp = prc_nrctremp
           AND c.cdhistor in(2391, /*ABONO DE PREJUIZO*/
                             2395);

      vr_vlrabono_novo craplem.vllanmto%type;

      -- Pagamento IOF Prejuizo
      CURSOR cr_craplcm_iof(pr_nrctremp craplem.nrctremp%TYPE) IS
        SELECT sum(c.vllanmto) vllanmto
          FROM craplcm c
         WHERE c.cdcooper = pr_cdcooper
           AND c.nrdconta = pr_nrdconta
           AND c.cdpesqbb = gene0002.fn_mask(pr_nrctremp, 'zz.zzz.zz9')
           AND c.cdagenci = 1 --
           AND c.cdbccxlt = 100
           AND c.cdoperad = '1'
           AND c.nrdolote = 8457
           AND c.cdhistor = 2317; --IOF
      vr_lcmiof NUMBER := 0;

      -- Temp table para armazenar os avalistas encontrados
      TYPE typ_reg_avalist IS RECORD(nrgeneri VARCHAR2(30) --> Pode ser o CPF ou NroConta
        ,nmdavali crapavt.nmdavali%TYPE); --> Nome do avalista
      TYPE typ_tab_avalist IS TABLE OF typ_reg_avalist INDEX BY PLS_INTEGER;
      vr_ind_avalist PLS_INTEGER;
      vr_tab_avalist typ_tab_avalist;
      vr_nrctaavg    NUMBER; --> Número genérico

      -- Campos de descrição dos avalistas 1, 2 e por extenso
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
               AND inliquid = 0 -- Não liquidada
               AND dtvencto <= pr_rw_crapdat.dtmvtoan; -- Parcela Vencida

      -- Buscar quantidade de parcelas liquidadas
      CURSOR cr_crappep_qtdeparcliq(pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT count(*) qtdeparcliq
          FROM crappep
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = pr_nrctremp
               AND inliquid = 1;

      -- Busca dos lançamentos cfme lista de históricos passado
      CURSOR cr_craplem(pr_nrctremp  IN crapepr.nrctremp%TYPE
                       ,pr_lsthistor IN VARCHAR2 DEFAULT ' ') IS --> Lista comdigos de histórico a retornar
        SELECT cdhistor
              ,vllanmto
          FROM craplem
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta --> Conta enviada
               AND nrctremp = pr_nrctremp --> Empréstimo atual
           AND ',' || pr_lsthistor || ',' LIKE ('%,' || cdhistor || ',%'); --> Retornar históricos passados na listagem
      rw_craplem cr_craplem%ROWTYPE;

      -- Verificar se existe aviso de débito em conta corrente não processado
      CURSOR cr_crapavs(pr_nrdconta IN crapavs.nrdconta%TYPE) IS
        SELECT 'S'
          FROM crapavs
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND cdhistor = 108
               AND dtrefere = pr_rw_crapdat.dtultdma --> Ultimo dia mes anterior
               AND tpdaviso = 1
               AND flgproce = 0; --> Não processado
      vr_flghaavs CHAR(1);

      -- verificar se existe o lançamento de credito do emprestimo
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

      -- Busca Rating do Contrato
      cursor c_rating is
        select 1 idrating
             , t.indrisco||'-'||to_char(t.dtmvtolt,'DD/MM/RRRR')||' '||decode(t.insitrat,1,'(Pr.)','(Ef.)') dsrating
          from tbrat_hist_nota_contrato t
         where t.cdcooper (+) = pr_cdcooper
           and t.nrdconta (+) = pr_nrdconta
           and t.nrctrrat (+) = pr_nrctremp
           and t.tpctrrat (+) = 90
           and t.nrseqrat (+) = 1
        union
        select 2 idrating
             , t.indrisco||'-'||to_char(t.dtmvtolt,'DD/MM/RRRR')||' '||decode(t.insitrat,1,'(Pr.)','(Ef.)') dsrating
          from crapnrc t
         where t.cdcooper (+) = pr_cdcooper
           and t.nrdconta (+) = pr_nrdconta
           and t.nrctrrat (+) = pr_nrctremp
           and t.tpctrrat (+) = 90
           and t.cdcooper  = 3
        union
        ---P450 Rating
        select 2 idrating
             , risc0004.fn_traduz_risco(t.inrisco_rating)
                ||'-'||to_char(t.dtrisco_rating,'DD/MM/RRRR')||' '||decode(t.insituacao_rating,2,'(Pr.)','(Ef.)') dsrating
          from tbrisco_operacoes t
         where t.cdcooper (+) = pr_cdcooper
           and t.nrdconta (+) = pr_nrdconta
           and t.nrctremp (+) = pr_nrctremp
           and t.tpctrato (+) = 90
           and t.insituacao_rating IN (2,4)
           and t.cdcooper <> 3;

      CURSOR cr_crapepr_migrado (pr_cdcooper IN crapepr.cdcooper%type
                                ,pr_nrdconta IN crapepr.nrdconta%type
                                ,pr_nrctremp IN crapepr.nrctremp%type
                                ,pr_nrdialiq IN craplcr.nrdialiq%type
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%type) IS
        SELECT p.rowid
          FROM crapepr p
         WHERE p.cdcooper = pr_cdcooper
           AND p.nrdconta = pr_nrdconta
           AND p.nrctremp = pr_nrctremp
           AND NOT (UPPER(pr_nmdatela) IN ('EXTEMP', 'IMPRES') OR
                    p.inliquid = 0 OR
                    p.inprejuz = 1 OR
                   (p.inliquid = 1 AND
                    p.inprejuz = 0 AND
                    p.dtultpag + pr_nrdialiq >= pr_dtmvtolt)) ;
      rw_crapepr_migrado cr_crapepr_migrado%ROWTYPE;

      -- variaveis auxiliares a busca
      vr_nmprimtl crapass.nmprimtl%TYPE; --> Nome do associado
      vr_dsdpagto VARCHAR2(100); --> Descrição auxiliar do débito
      vr_qtmesdec NUMBER(16, 8); --> Qtde de meses decorridos
      vr_qtpreemp NUMBER; --> Quantidade de parcelas do empréstimos
      vr_qtpreapg NUMBER; --> Quantidade de parcelas a pagar
      vr_vlpreapg NUMBER; --> Valor das parcelas a pagar
      vr_vlmrapar crappep.vlmrapar%TYPE; --> Valor do Juros de Mora
      vr_vlmtapar crappep.vlmtapar%TYPE; --> Valor da Multa
      vr_vliofcpl crappep.vliofcpl%TYPE; --> Valor da Multa
      vr_vlprvenc NUMBER := 0; --> Valor Vencido
      vr_vlpraven NUMBER := 0; --> Valor a Vencer
      vr_vlpreemp NUMBER := 0; --> Valor da parcela do empréstimo
      vr_flgatras NUMBER(1); --> Indicador 0/1 de atraso no empréstimo
      vr_dslcremp VARCHAR2(60); --> Descrição da linha de crédito
      vr_txdjuros NUMBER(12, 7); --> Taxa de juros para o cálculo
      vr_qtprecal crapepr.qtprecal%TYPE; --> Qatdade de parclas calculadas até o momento
      vr_dtrefere DATE; --> Data referência para o calculo
      vr_vldescto NUMBER; --> Valor de desconto
      vr_vlprovis NUMBER; --> Valor de provisão
      vr_cdpesqui VARCHAR2(30); --> Campo de pesquisa com dados do empréstimo
      vr_dtinipag DATE; --> Data de início de pagamento do empréstimo
      vr_dsfinemp VARCHAR2(60); --> Descrição da finalidade do empréstimo
      vr_indadepr PLS_INTEGER; --> Indice para gravação na tab_dados_epr
      -- Dia e data de pagamento de empréstimo
      vr_tab_diapagto NUMBER;
      vr_tab_dtcalcul DATE;
      -- Flag para desconto em folha
      vr_tab_flgfolha BOOLEAN;
      -- Configuração para mês novo
      vr_tab_ddmesnov INTEGER;
      -- Rowid para inserção de log
      vr_nrdrowid ROWID;
      -- Busca na craptab
      vr_dstextab craptab.dstextab%TYPE;
      -- Saida para desvio de fluxo
      vr_exc_next  EXCEPTION;
      vr_exc_erro2 EXCEPTION;
      -- Variáveis para passagem a rotina pc_calcula_lelem
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
      vr_incdccon INTEGER;
      vr_qtdeparcliq INTEGER;

      vr_nrctremp_migrado crawepr.nrctremp%type := 0;
      vr_exibe_migrado    BOOLEAN := FALSE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);


    BEGIN
      -- Buscar a configuração de empréstimo cfme a empresa da conta
      pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                                ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data atual
                                ,pr_nrdconta => pr_nrdconta --> Numero da conta do empréstimo
                                ,pr_dtcalcul => vr_tab_dtcalcul --> Data calculada de pagamento
                                ,pr_diapagto => vr_tab_diapagto --> Dia de pagamento das parcelas
                                ,pr_flgfolha => vr_tab_flgfolha --> Flag de desconto em folha S/N
                                ,pr_ddmesnov => vr_tab_ddmesnov --> Configuração para mês novo
                                ,pr_cdcritic => vr_cdcritic --> Código do erro
                                ,pr_des_erro => vr_dscritic); --> Retorno de Erro
      -- Se houve erro na rotina
      IF vr_dscritic IS NOT NULL
         OR vr_cdcritic IS NOT NULL THEN
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;
      -- Busca do nome do associado
      vr_nmprimtl := pr_nmprimtl;

      -- busca o tipo de documento GED
      vr_dstextab := pr_tab_digitaliza;

      -- Se encontrar
      IF vr_dstextab IS NULL THEN
        vr_tpdocged := 0;
      ELSE
        vr_tpdocged := gene0002.fn_busca_entrada(3, vr_dstextab, ';');
      END IF;

      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab := pr_tab_parempctl;

      -- Se encontrar
      IF vr_dstextab IS NULL THEN
        -- Gerar erro
        vr_cdcritic := 0;
        vr_dscritic := 'Informacoes nao encontradas.';
      END IF;

      vr_nrregist := pr_nrregist;

      -- Buscar dados da cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;

      vr_incdccon := 0;
      --> Rotina responsavel por validar se cooperativa está em contingência
      empr0012.pc_verifica_contingencia_cdc(pr_cdcooper => pr_cdcooper
                                            ,pr_incdccon => vr_incdccon
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      vr_cdcritic := 0;
      vr_dscritic := NULL;

      -- Busca dos dados do emprestimo passado ou de todos os emprestimos da conta quando nrctremp = 0
      FOR rw_crapepr IN cr_crapepr LOOP
        BEGIN
          -- Buscar descrição da linha de crédito
          OPEN cr_craplcr(pr_cdlcremp => rw_crapepr.cdlcremp);
          FETCH cr_craplcr
            INTO rw_craplcr;
          -- Se não tiver encontrado
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


          IF pr_nmdatela = 'ATENDA' THEN
            -- verificar se o emprestimo foi migrado
            empr9999.pc_verifica_empr_migrado(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrctrnov => rw_crapepr.nrctremp
                                             ,pr_tpempmgr => 1 -- verificar através do original
                                             ,pr_nrctremp => vr_nrctremp_migrado
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

            vr_cdcritic := 0;
            vr_dscritic := NULL;

            -- se o emprestimo foi migrado carrrega os dados para validacao do regitro
            IF vr_nrctremp_migrado > 0 THEN

              OPEN cr_crapepr_migrado (pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => vr_nrctremp_migrado
                                      ,pr_nrdialiq => rw_craplcr.nrdialiq
                                      ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt);
              FETCH cr_crapepr_migrado INTO rw_crapepr_migrado;

              IF cr_crapepr_migrado%NOTFOUND THEN
                -- se nao achar registro, é sinal que deve listar o emprestimo
                vr_exibe_migrado := TRUE;
              END IF;
              CLOSE cr_crapepr_migrado;

            END IF;
          END IF;

          -- Montar a descrição da linha de crédito
          vr_dslcremp := TRIM(rw_crapepr.cdlcremp) || '-' ||rw_craplcr.dslcremp;

          -- se nao for migrado ou o contrato migrado nao aparecer
          -- quando um contrato e migrado ele somente some quando o migrado sumir
          IF vr_nrctremp_migrado = 0 OR not vr_exibe_migrado THEN
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
            -- Ignorar o restante abaixo e processar o próximo registro
            RAISE vr_exc_next;
          END IF;
          END IF;
          -- Se houver indicação para utilização da tabela de juros e o empréstimo estiver ativo
          IF pr_inusatab
             AND rw_crapepr.inliquid = 0 THEN
            -- Utilizaremos a taxa de juros da linha de crédito
            vr_txdjuros := rw_craplcr.txdiaria;
          ELSE
            -- Utilizaremos a taxa de juros do empréstimo
            vr_txdjuros := rw_crapepr.txjuremp;
          END IF;
          -- Inicializar variaveis para o calculo do saldo devedor
          vr_vlsdeved := rw_crapepr.vlsdeved;
          vr_vljuracu := rw_crapepr.vljuracu;
          vr_vlmrapar := 0;
          vr_vlmtapar := 0;
          vr_vliofcpl := 0;
          vr_qtdeparcliq := 0;
          -- Para empréstimo ainda não liquidados
          IF rw_crapepr.inliquid = 0 OR
             rw_crapepr.tpemprst IN (1,2) THEN --tratamento b1wgen0002a.i
            -- Manter o valor da tabela
            --vr_qtprecal := rw_crapepr.qtprecal;

            OPEN cr_crappep_qtdeparcliq(pr_nrctremp => rw_crapepr.nrctremp);
            FETCH cr_crappep_qtdeparcliq
              INTO vr_qtdeparcliq;
            if vr_qtdeparcliq > 0 then
               vr_qtprecal := vr_qtdeparcliq;
            else vr_qtprecal := rw_crapepr.qtprecal;
            end if;
            CLOSE cr_crappep_qtdeparcliq;

          ELSE
            -- Usar o valor total de parcelas
            vr_qtprecal := rw_crapepr.qtpreemp;
          END IF;

          -- inicializar variaveis
          vr_vlpraven := 0;
          vr_vlprvenc := 0;

          -- Calculo de saldo devedor em emprestimos baseado na includes/lelem.i.
          pc_calc_saldo_deved_epr_lem(pr_cdcooper   => pr_cdcooper --> Cooperativa conectada
                                     ,pr_cdprogra   => pr_cdprogra --> Código do programa corrente
                                     ,pr_cdagenci   => rw_crapepr.cdagenci --> Código da agência
                                     ,pr_nrdcaixa   => pr_nrdcaixa --> Número do caixa
                                     ,pr_cdoperad   => pr_cdoperad --> Código do Operador
                                     ,pr_rw_crapdat => pr_rw_crapdat --> Vetor com dados de parâmetro (CRAPDAT)
                                     ,pr_nrdconta   => pr_nrdconta --> Número da conta
                                     ,pr_idseqttl   => pr_idseqttl --> Seq titular
                                     ,pr_nrctremp   => rw_crapepr.nrctremp --> Numero ctrato empréstimo
                                     ,pr_idorigem   => pr_idorigem --> Id do módulo de sistema
                                     ,pr_txdjuros   => vr_txdjuros --> Taxa de juros aplicada
                                     ,pr_dtcalcul   => pr_dtcalcul --> Data para calculo do empréstimo
                                     ,pr_diapagto   => vr_tab_diapagto --> Dia para pagamento
                                     ,pr_qtprecal   => vr_qtprecal_lem --> Quantidade de prestações calculadas até momento
                                     ,pr_vlprepag   => vr_vlprepag --> Valor acumulado pago no mês
                                     ,pr_vlpreapg   => vr_vlpreapg --> Valor a pagar
                                     ,pr_vljurmes   => vr_vljurmes --> Juros no mês corrente
                                     ,pr_vljuracu   => vr_vljuracu --> Juros acumulados total
                                     ,pr_vlsdeved   => vr_vlsdeved --> Saldo devedor acumulado
                                     ,pr_dtultpag   => vr_dtultpag --> Ultimo dia de pagamento das prestações
                                     ,pr_vlmrapar   => vr_vlmrapar --> Valor do Juros de Mora
                                     ,pr_vlmtapar   => vr_vlmtapar --> Valor da Multa
                                     ,pr_vliofcpl   => vr_vliofcpl --> IOF complementar de atraso
                                     ,pr_vlprvenc   => vr_vlprvenc --> Valor Vencido da parcela
                                     ,pr_vlpraven   => vr_vlpraven --> Valor a Vencer
                                     ,pr_flgerlog   => pr_flgerlog --> Gerar log S/N
                                     ,pr_des_reto   => pr_des_reto --> Retorno OK / NOK
                                     ,pr_tab_erro   => vr_tab_erro); --> Tabela com possíveis erros
          -- Se a rotina retornou erro
          IF pr_des_reto = 'NOK' THEN
            -- Gerar exceção
            RAISE vr_exc_erro2;
          END IF;
          -- Verifica se deve deixar saldo provisionado no chq. sal
          IF NOT vr_tab_flgfolha THEN
            -- Utilizar o ultimo dia do mês anterior
            vr_dtrefere := pr_rw_crapdat.dtultdia -
                           to_char(pr_rw_crapdat.dtultdia, 'dd');
          ELSE
            -- Utilizar o ultimo dia do mês corrente
            vr_dtrefere := pr_rw_crapdat.dtultdia;
          END IF;
          -- Para empréstimo price não liquidados
          IF rw_crapepr.tpemprst = 0
             AND rw_crapepr.inliquid = 0 THEN
            -- Incrementar na quantidade de prestações calculadas a
            -- quantidade que foi calculada na rotina lem
            vr_qtprecal := vr_qtprecal + vr_qtprecal_lem;
          END IF;
          -- Zerar valores de desconto e provisão
          vr_vldescto := 0;
          vr_vlprovis := 0;
          -- Montar campo de pesquisa com os dados do movimento
          vr_cdpesqui := to_char(rw_crapepr.dtmvtolt, 'dd/mm/yyyy') || '-' ||
                         to_char(rw_crapepr.cdagenci, 'fm000') || '-' ||
                         to_char(rw_crapepr.cdbccxlt, 'fm000') || '-' ||
                         to_char(rw_crapepr.nrdolote, 'fm000000');
          -- Se a quantidade de parcelas calculadas for superior a
          -- quantidade de parcelas total do empréstimo
          IF vr_qtprecal > rw_crapepr.qtpreemp THEN
            -- Não há mais parcelas a pagar
            vr_qtpreapg := 0;
          ELSE
            -- Calcular a diferença
            vr_qtpreapg := rw_crapepr.qtpreemp - vr_qtprecal;
          END IF;
          -- Montar descrição genérica conforme o tipo de pagamento do empréstimo
          IF rw_crapepr.flgpagto = 1 THEN
            vr_dsdpagto := 'Debito em C/C vinculado ao credito da folha';
          ELSE
            vr_dsdpagto := 'Debito em C/C no dia ' ||
                           to_char(rw_crapepr.dtdpagto, 'dd') || ' (' ||
                           to_char(rw_crapepr.dtdpagto, 'dd/mm/yyyy') || ')';
          END IF;
          -- Busca dados complementares do empréstimo
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
            -- Utilizar do cadastro básico
            vr_dtinipag := rw_crapepr.dtdpagto;
          END IF;
          -- Se a data de vencimento for do mesmo mês que o corrente
          IF trunc(rw_crapepr.dtmvtolt, 'mm') =
             trunc(pr_rw_crapdat.dtmvtolt, 'mm') THEN
            -- Também utilizamos do cadastro básico
            vr_dtinipag := rw_crapepr.dtdpagto;
          END IF;
          -- Leitura da descricao da finalidade do emprestimo
          OPEN cr_crapfin(pr_cdfinemp => rw_crapepr.cdfinemp);
          FETCH cr_crapfin
            INTO rw_crapfin;
          -- Se não tiver encontrado
          IF cr_crapfin%NOTFOUND THEN
            -- Montar descrição genérica
            vr_dsfinemp := to_char(rw_crapepr.cdfinemp, 'fm990') || '-' ||
                           'N/CADASTRADA!';
          ELSE
            -- Montar descrição encontrada
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
          -- Busca dos avalistas do empréstimo
          vr_ind_avalist := 0;
          vr_dsdaval1    := ' ';
          vr_dsdaval2    := ' ';
          vr_dsdavali    := ' ';
          vr_tab_avalist.DELETE;
          -- Efetuar laco abaixo para buscar duas vezes cfme nrctaav1 e nrctaav2
          FOR vr_ind IN 1 .. 2 LOOP
            -- No primeiro laço
            IF vr_ind = 1 THEN
              -- Usar nrctaav1
              vr_nrctaavg := rw_crapepr.nrctaav1;
            ELSE
              -- Usar nrctaav2
              vr_nrctaavg := rw_crapepr.nrctaav2;
            END IF;
            -- Se existir informação no campo atual
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
                -- Incluir texto de associado não encontrado
                vr_tab_avalist(vr_ind).nmdavali := ': Nao cadastrado!!!';
              END IF;
              -- Fechar o cursor
              CLOSE cr_crapass;
            END IF;
          END LOOP;
          -- Se algum dos avalistas não tiver conta na cooperativa
          IF rw_crapepr.nrctaav1 = 0
             OR rw_crapepr.nrctaav2 = 0 THEN
            -- Buscar avalistas terceirizados
            FOR rw_crapavt IN cr_crapavt(pr_nrctremp => rw_crapepr.nrctremp) LOOP
              -- Adicioná-lo na tabela
              vr_ind_avalist := vr_tab_avalist.COUNT + 1;
              FOR vr_ind IN 1..2 LOOP
                IF NOT vr_tab_avalist.exists(vr_ind) THEN
                  vr_tab_avalist(vr_ind).nrgeneri := rw_crapavt.nrcpfcgc;
                  vr_tab_avalist(vr_ind).nmdavali := rw_crapavt.nmdavali;
                  EXIT;
                END IF;
              END LOOP;
            END LOOP;
          END IF;

          IF vr_ind_avalist > 0 THEN
            -- Ao final das buscas, percorrer a tabela e retornar os 2 primeiros avalistas encontrados
            FOR vr_ind_avalist IN vr_tab_avalist.FIRST .. vr_tab_avalist.LAST LOOP

              -- Na primeira interação
              IF vr_ind_avalist = 1 THEN
                -- Utilizar o campo vr_dsdaval1
                vr_dsdaval1 := vr_tab_avalist(vr_ind_avalist).nrgeneri || ' - ' ||
                               vr_tab_avalist(vr_ind_avalist).nmdavali;
                -- Preencher o campo avalistas por extenso
                vr_dsdavali := 'Aval ' || TRIM(vr_tab_avalist(vr_ind_avalist).nrgeneri);
              ELSIF vr_ind_avalist = 2 THEN
                -- Utilizar o campo vr_dsdaval2
                vr_dsdaval2 := vr_tab_avalist(vr_ind_avalist).nrgeneri || ' - ' ||
                               vr_tab_avalist(vr_ind_avalist).nmdavali;
                -- Preencher o campo avalistas por extenso
                vr_dsdavali := vr_dsdavali||'/Aval ' || vr_tab_avalist(vr_ind_avalist).nrgeneri;
              END IF;
              -- Sair também quando já tiver encontrado dois avalistas
              EXIT WHEN vr_ind_avalist = 2;
            END LOOP;
          END IF;

          IF rw_crapepr.tpemprst = 1 OR   -- Pre-Fixado
             rw_crapepr.tpemprst = 2 THEN -- Pos-Fixado
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
            -- Considerar que não houve atraso
            vr_flgatras := 0;
          END IF;

          /*** PORTABILIDADE - Verifica se eh uma proposta de portabilidade **/
          EMPR0006.pc_possui_portabilidade( pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                           ,pr_nrdconta => pr_nrdconta         --Numero da Conta
                                           ,pr_nrctremp => rw_crapepr.nrctremp --Numero de Emprestimo
                                           ,pr_err_efet => vr_err_efet         --Erro na efetivacao (0/1)
                                           ,pr_des_reto => vr_portabilidade    --Portabilidade(S/N)
                                           ,pr_cdcritic => vr_cdcritic         --Código da crítica
                                           ,pr_dscritic => vr_dscritic);       --Descrição da crítica

          -- Se houve erro na rotina
          IF TRIM(vr_dscritic) IS NOT NULL
             OR nvl(vr_cdcritic,0) <> 0 THEN
            -- Levantar exceção
            RAISE vr_exc_erro;
          END IF;
        /*** FIM - PORTABILIDADE - Verifica se eh uma proposta de portabilidade **/

          vr_liquidia := 0;

          IF pr_idorigem <> 7 THEN
            --> verificar se existe o lançamento de credito do emprestimo
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
             AND pr_nrregist <> 0
             AND pr_nrctremp = 0 THEN

            pr_qtregist := nvl(pr_qtregist,0) + 1;

            /* controles da paginação */
            IF (vr_nrregist < 1)
               OR (pr_qtregist < pr_nriniseq)
               OR (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
              RAISE vr_exc_next;
            END IF;

          END IF;

          -- Criar o indice para gravação na tab_dados_epr
          vr_indadepr := pr_tab_dados_epr.COUNT + 1;
          -- Criar o registro com as informações básicas
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
          pr_tab_dados_epr(vr_indadepr).cdtpempr := '0,1,2';
          pr_tab_dados_epr(vr_indadepr).dstpempr := 'Cálculo Atual,Pré-Fixada,Pós-Fixado';
          pr_tab_dados_epr(vr_indadepr).perjurmo := rw_craplcr.perjurmo;
          pr_tab_dados_epr(vr_indadepr).inliquid := rw_crapepr.inliquid;
          pr_tab_dados_epr(vr_indadepr).flgatras := vr_flgatras;
          pr_tab_dados_epr(vr_indadepr).flgdigit := rw_crapepr.flgdigit;
          pr_tab_dados_epr(vr_indadepr).tpdocged := vr_tpdocged;
          pr_tab_dados_epr(vr_indadepr).qtlemcal := vr_qtprecal_lem;
          pr_tab_dados_epr(vr_indadepr).vlmrapar := vr_vlmrapar;
          pr_tab_dados_epr(vr_indadepr).vlmtapar := vr_vlmtapar;
          -- Se esta em prejuizo assume o IOF complemntar que já está armazenado
          if rw_crapepr.inprejuz = 1 then
             pr_tab_dados_epr(vr_indadepr).vliofcpl := nvl(rw_crapepr.vliofcpl,0);
          else
          pr_tab_dados_epr(vr_indadepr).vliofcpl := NVL(vr_vliofcpl,0);
          end if;

          -- Copiar campos do IOF
          pr_tab_dados_epr(vr_indadepr).vlrtotal := rw_crapepr.vlemprst;
          pr_tab_dados_epr(vr_indadepr).idfiniof := rw_crapepr.idfiniof;
          pr_tab_dados_epr(vr_indadepr).vliofepr := nvl(rw_crapepr.vliofepr,0);
          pr_tab_dados_epr(vr_indadepr).vlrtarif := nvl(rw_crapepr.vltarifa,0);
          -- Caso financie IOF
          IF rw_crapepr.idfiniof = 1 THEN
            -- Remover do valor liquido o IOF e tarifa
            pr_tab_dados_epr(vr_indadepr).vlrtotal := pr_tab_dados_epr(vr_indadepr).vlrtotal - nvl(rw_crapepr.vliofepr,0) - nvl(rw_crapepr.vltarifa,0);
          END IF;

          -- inf CDC
          pr_tab_dados_epr(vr_indadepr).flintcdc := nvl(rw_crapcop.flintcdc,0);
          pr_tab_dados_epr(vr_indadepr).cdoperad := rw_crawepr.cdoperad;
          pr_tab_dados_epr(vr_indadepr).inintegra_cont := vr_incdccon;
          pr_tab_dados_epr(vr_indadepr).tpfinali := nvl(rw_crapfin.tpfinali,0);

          pr_tab_dados_epr(vr_indadepr).vlprvenc := vr_vlprvenc;
          pr_tab_dados_epr(vr_indadepr).vlpraven := vr_vlpraven;
          pr_tab_dados_epr(vr_indadepr).flgpreap := FALSE;
          pr_tab_dados_epr(vr_indadepr).cdorigem := rw_crapepr.cdorigem;
          pr_tab_dados_epr(vr_indadepr).liquidia := vr_liquidia;
          pr_tab_dados_epr(vr_indadepr).qtimpctr := rw_crapepr.qtimpctr;
          pr_tab_dados_epr(vr_indadepr).portabil := TRIM(vr_portabilidade);

          pr_tab_dados_epr(vr_indadepr).tpatuidx := rw_crawepr.tpatuidx;
          pr_tab_dados_epr(vr_indadepr).idcarenc := rw_crawepr.idcarenc;
          pr_tab_dados_epr(vr_indadepr).dtcarenc := rw_crawepr.dtcarenc;
          pr_tab_dados_epr(vr_indadepr).nrdiacar := rw_crawepr.dtdpagto - rw_crapepr.dtmvtolt;
          pr_tab_dados_epr(vr_indadepr).qttolatr := rw_crapepr.qttolatr;

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
            -- Enviar a taxa do empréstimo
            pr_tab_dados_epr(vr_indadepr).txmensal := rw_crapepr.txmensal;
            pr_tab_dados_epr(vr_indadepr).dsidenti := '*';
          ELSIF rw_crapepr.tpemprst = 2 THEN -- Price Pos-Fixado
            -- Enviar a taxa do empréstimo
            pr_tab_dados_epr(vr_indadepr).txmensal := rw_crapepr.txmensal;
            pr_tab_dados_epr(vr_indadepr).dsidenti := '';
            pr_tab_dados_epr(vr_indadepr).vlprecar := rw_crawepr.vlprecar;
          ELSIF rw_crapepr.tpemprst = 0 THEN -- Price TR
            -- Utilizar da linha de crédito
            pr_tab_dados_epr(vr_indadepr).txmensal := rw_craplcr.txmensal;
            pr_tab_dados_epr(vr_indadepr).dsidenti := '';
          END IF;

          -- Se existe cadastro de emprestimo complementar
          IF rw_crawepr.indachou = 'S' THEN
            -- Enviar informações do mesmo
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
          -- Para empréstimos de preju¿zo
          IF pr_tab_dados_epr(vr_indadepr).inprejuz > 0 THEN
            -- Copiar informações de prejuizo a tabela
            pr_tab_dados_epr(vr_indadepr).vlprejuz := rw_crapepr.vlprejuz;
            pr_tab_dados_epr(vr_indadepr).dtprejuz := rw_crapepr.dtprejuz;
            pr_tab_dados_epr(vr_indadepr).vljraprj := rw_crapepr.vljraprj;
            pr_tab_dados_epr(vr_indadepr).vljrmprj := rw_crapepr.vljrmprj;
            pr_tab_dados_epr(vr_indadepr).slprjori := rw_crapepr.vlprejuz;
            -- IOF do prejuizo
            pr_tab_dados_epr(vr_indadepr).vltiofpr := rw_crapepr.vltiofpr;
            pr_tab_dados_epr(vr_indadepr).vlpiofpr := rw_crapepr.vlpiofpr;
            pr_tab_dados_epr(vr_indadepr).nrdiaatr := pr_rw_crapdat.dtmvtolt - rw_crapepr.dtdpagto;

            /* Daniel */
            vr_flpgmujm := FALSE;
            pr_tab_dados_epr(vr_indadepr).vlsdprej := nvl(rw_crapepr.vlsdprej,0)
                                                    + (pr_tab_dados_epr(vr_indadepr).vlttmupr - pr_tab_dados_epr(vr_indadepr).vlpgmupr)
                                                    + (pr_tab_dados_epr(vr_indadepr).vlttjmpr - pr_tab_dados_epr(vr_indadepr).vlpgjmpr)
                                                    + (pr_tab_dados_epr(vr_indadepr).vltiofpr - pr_tab_dados_epr(vr_indadepr).vlpiofpr);

            /* Verificacao para saber se foi pago multa e juros de mora */
            IF pr_tab_dados_epr(vr_indadepr).vlttmupr - pr_tab_dados_epr(vr_indadepr).vlpgmupr <= 0
            AND pr_tab_dados_epr(vr_indadepr).vlttjmpr - pr_tab_dados_epr(vr_indadepr).vlpgjmpr <= 0 THEN
              vr_flpgmujm := TRUE;
            END IF;

            -- Busca dos lançamentos cfme lista de históricos passado
            -- --- ------------------------------
            -- 382 PAG.PREJ.ORIG
            -- 383 ABONO PREJUIZO
            -- 390 SERV./TAXAS
            -- 391 PAG. PREJUIZO
            -- 2388 Pagto Prejuizo - Melhoria 324
            -- 2473 Pagto Juros + 60 - Melhoria 324

            -- se for POS nao zera o saldo
           IF rw_crapepr.tpemprst = 2 AND pr_nmdatela = 'ATENDA' THEN
             pr_tab_dados_epr(vr_indadepr).vlsdeved := pr_tab_dados_epr(vr_indadepr).vlsdprej;
           ELSE
             -- NOVA M324
             pr_tab_dados_epr(vr_indadepr).vlsdeved := 0;
           END IF;

            -- Valores abono prejuizo
            FOR r_craplem2 IN cr_craplem2(prc_nrctremp => rw_crapepr.nrctremp) LOOP
              pr_tab_dados_epr(vr_indadepr).vlrabono := NVL(r_craplem2.valor_pago_abono,0);
            END LOOP;

            FOR r_craplem4 IN cr_craplem4(prc_nrctremp => rw_crapepr.nrctremp) LOOP
              vr_vlrabono_novo := NVL(r_craplem4.valor_pago_abono,0);
            END LOOP;

            -- Pagamento IOF Prejuizo
            FOR rw_lcm IN cr_craplcm_iof(pr_nrctremp => rw_crapepr.nrctremp) LOOP
              vr_lcmiof := nvl(rw_lcm.vllanmto,0);
            END LOOP;

            -- Valores pagos Prejuizo
            FOR r_craplem1 IN cr_craplem1(prc_nrctremp => rw_crapepr.nrctremp) LOOP
              pr_tab_dados_epr(vr_indadepr).vlrpagos := nvl(r_craplem1.valor_pago,0) + vr_lcmiof - vr_vlrabono_novo;
            END LOOP;

            -- Saldo original prejuizo
            FOR r_craplem3 IN cr_craplem3(prc_nrctremp => rw_crapepr.nrctremp) LOOP

              pr_tab_dados_epr(vr_indadepr).slprjori := pr_tab_dados_epr(vr_indadepr).slprjori -
                                                        NVL(r_craplem3.sum_sldPrinc,0);
            END LOOP;

            /*
            382 - PAGAMENTO DE PREJUIZO ORIGINAL TRANSFERIDO
            383 - ABONO DE PREJUIZO
            390 - DEBITO DE TAXAS/SERVICOS/CORRECAO/ATUALIZACAO
            391 - PAG. PREJUIZO (VALORES ACIMA DO PREJ.ORIGINAL)
            2388 - PAGAMENTO DE PREJUIZO VALOR PRINCIPAL
            2391 - ABONO DE PREJUIZO
            2392 - ESTORNO PAGAMENTO DE PREJUIZO VALOR PRINCIPAL
            2395 - ESTORNO ABONO DE PREJUIZO
            2473 - PAGAMENTO JUROS +60 PREJUIZO*/

            FOR rw_craplem IN cr_craplem(pr_nrctremp  => rw_crapepr.nrctremp
                                        ,pr_lsthistor => '391,382,383,390,2388,2392,2391,2395,2473') LOOP

              -- Somente para Serv.TAxas 390
              IF rw_craplem.cdhistor = 390 THEN
                -- Adicionar no campo vlr acrescimo
                pr_tab_dados_epr(vr_indadepr).vlacresc := NVL(pr_tab_dados_epr(vr_indadepr).vlacresc,0) + rw_craplem.vllanmto;
              END IF;
            END LOOP;

            -- Ao final, garantir que o saldo prejuizo original não fique inferior a zero
            IF pr_tab_dados_epr(vr_indadepr).slprjori < 0 THEN
              pr_tab_dados_epr(vr_indadepr).slprjori := 0;
            END IF;
          END IF;

          -- Para emprestimos Pre-fixado ou Pos-Fixado
          IF rw_crapepr.tpemprst = 1 OR
             rw_crapepr.tpemprst = 2 THEN
            -- Quantidade de meses decorridos vem da crapepr
            pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec;
          ELSE
            -- Para empréstimos de debito em conta
            IF rw_crapepr.flgpagto = 0 THEN
              -- Se a parcela vence no mês corrente
              IF trunc(pr_rw_crapdat.dtmvtolt, 'mm') =
                 trunc(rw_crapepr.dtdpagto, 'mm') THEN
                -- Se ainda não foi pago
                IF rw_crapepr.dtdpagto <= pr_rw_crapdat.dtmvtolt THEN
                  -- Incrementar a quantidade de parcelas
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec + 1;
                ELSE
                  -- Consideramos a quantidade já calculadao
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec;
                END IF;
                -- Se foi paga no mês corrente
              ELSIF trunc(pr_rw_crapdat.dtmvtolt, 'mm') =
                    trunc(rw_crapepr.dtmvtolt, 'mm') THEN
                -- Se for um contrato do mês
                IF to_char(vr_dtinipag, 'mm') =
                   to_char(pr_rw_crapdat.dtmvtolt, 'mm') THEN
                  -- Devia ter pago a primeira no mes do contrato
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec + 1;
                ELSE
                  -- Paga a primeira somente no mes seguinte
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec;
                END IF;
              ELSE
                -- Se a parcela vai vencer OU foi paga no mês corrEnte
                IF rw_crapepr.dtdpagto > pr_rw_crapdat.dtmvtolt
                   or (rw_crapepr.dtdpagto < pr_rw_crapdat.dtmvtolt AND
                   to_number(to_char(rw_crapepr.dtdpagto, 'dd')) <=
                   to_number(to_char(pr_rw_crapdat.dtmvtolt, 'dd'))) THEN
                  -- Incrementar a quantidade de parcelas
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec + 1;
                ELSE
                  -- Consideramos a quantidade já calculadao
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
                -- Verificar se existe aviso de débito em conta corrente não processado
                vr_flghaavs := 'N';
                OPEN cr_crapavs(pr_nrdconta => pr_nrdconta);
                FETCH cr_crapavs
                  INTO vr_flghaavs;
                CLOSE cr_crapavs;
                -- Se houve
                IF vr_flghaavs = 'S' THEN
                  -- Utilizar a quantidade já calculada
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec;
                ELSE
                  -- Adicionar 1 mês a quantidade calculada
                  pr_tab_dados_epr(vr_indadepr).qtmesdec := rw_crapepr.qtmesdec + 1;
                END IF;
              END IF;
            END IF;

            -- Garantir que a quantidade decorrida não seja negativa
            IF pr_tab_dados_epr(vr_indadepr).qtmesdec < 0 THEN
              pr_tab_dados_epr(vr_indadepr).qtmesdec := 0;
            END IF;

          END IF;

          -- Montar descrição de parcelas a pagar
          pr_tab_dados_epr(vr_indadepr).dspreapg := lpad(to_char(vr_qtprecal,'fm990d0000'),11,' ')
                                                 || '/'
                                                 || to_char(rw_crapepr.qtpreemp,'fm000')
                                                 || ' ->'
                                                 || lpad(to_char(vr_qtpreapg,'fm990d0000'),8,' ')||' ';
          pr_tab_dados_epr(vr_indadepr).qtpreapg := vr_qtpreapg;
          -- Guardar o valor prestações a pagar cfme já calculado
          IF rw_crapepr.tpemprst IN (1,2) THEN
            -- Quantidade de meses decorridos vem da crapepr
            pr_tab_dados_epr(vr_indadepr).vlpreapg := vr_vlpreapg;
          ELSE
            -- Se a quantidade calculada de parcelas for superior a de meses decorridos
            -- e a data de pagamento for inferior a data atual
            -- e não ¿ um empréstimo de débito em conta
            IF rw_crapepr.qtprecal > rw_crapepr.qtmesdec
               AND rw_crapepr.dtdpagto <= pr_rw_crapdat.dtmvtolt
               AND rw_crapepr.flgpagto = 0 THEN
              -- Valor a pagar ¿ a diferença do total e o pago
              pr_tab_dados_epr(vr_indadepr).vlpreapg := rw_crapepr.vlpreemp -
                                                        vr_vlprepag;
              -- Garantir que não fique negativo
              IF pr_tab_dados_epr(vr_indadepr).vlpreapg < 0 THEN
                pr_tab_dados_epr(vr_indadepr).vlpreapg := 0;
              END IF;
            ELSE

              -- Se a quantidade decorrida já gravada na tabela - a qtde de parcelas calculadas for superior a zero
              IF (pr_tab_dados_epr(vr_indadepr).qtmesdec - vr_qtprecal) > 0 THEN
                -- Calcular o valor pendente com base na diferença entre decorridos e calculado * valor da parcela
                pr_tab_dados_epr(vr_indadepr).vlpreapg := (pr_tab_dados_epr(vr_indadepr)
                                                          .qtmesdec -
                                                           vr_qtprecal) *
                                                          rw_crapepr.vlpreemp;
              ELSE
                -- Não há mais valor pendente
                pr_tab_dados_epr(vr_indadepr).vlpreapg := 0;
              END IF;

            END IF;

            -- Se a quantidade de meses decorridas armazenada for superior a de parcelas
            -- OU se o valor pendente a pagar for superior ao saldo devedor calculado
            IF pr_tab_dados_epr(vr_indadepr).qtmesdec > rw_crapepr.qtpreemp
                OR pr_tab_dados_epr(vr_indadepr).vlpreapg > vr_vlsdeved THEN
              -- Considerar o saldo devedor calculado como o pendente a pagar
              pr_tab_dados_epr(vr_indadepr).vlpreapg := vr_vlsdeved;
            END IF;
            -- Garantir que não fique negativo
            IF pr_tab_dados_epr(vr_indadepr).vlpreapg < 0 THEN
              pr_tab_dados_epr(vr_indadepr).vlpreapg := 0;
            END IF;
          END IF;

          -- Copiar quantidade de parcelas calculadas
          pr_tab_dados_epr(vr_indadepr).qtprecal := vr_qtprecal;
          pr_tab_dados_epr(vr_indadepr).vltotpag := nvl(pr_tab_dados_epr(vr_indadepr).vlpreapg,0)
                                                  + nvl(pr_tab_dados_epr(vr_indadepr).vlmrapar,0)
                                                  + nvl(pr_tab_dados_epr(vr_indadepr).vlmtapar,0)
                                                  + nvl(pr_tab_dados_epr(vr_indadepr).vliofcpl,0);

          -- Calcular Parcela/Atraso
          vr_qtmesdec := pr_tab_dados_epr(vr_indadepr).qtmesdec - pr_tab_dados_epr(vr_indadepr).qtprecal;
          vr_qtpreemp := pr_tab_dados_epr(vr_indadepr).qtpreemp - pr_tab_dados_epr(vr_indadepr).qtprecal;
          -- Se quantidade decorrida for superior a de parcelas
          IF vr_qtmesdec > vr_qtpreemp THEN
            -- Considerar como atraso a quantidade de parcelas
            pr_tab_dados_epr(vr_indadepr).qtmesatr := vr_qtpreemp;
          ELSE
            -- Considerar como atraso os meses decorridos
            pr_tab_dados_epr(vr_indadepr).qtmesatr := vr_qtmesdec;
          END IF;
          -- Garantir que a quantidade em atraso não fique negativa
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
          for r_rating in c_rating loop
            if r_rating.idrating = 1 then
              pr_tab_dados_epr(vr_indadepr).dsratpro := r_rating.dsrating;
            else
              pr_tab_dados_epr(vr_indadepr).dsratatu := r_rating.dsrating;
            end if;
          end loop;
          -- atribuicao para controle da paginacao
          vr_nrregist := vr_nrregist - 1;

        EXCEPTION
          WHEN vr_exc_next THEN
            null; --> Apenas ignorar e partir ao próximo registro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Copiar variavel tempor¿ria para a de sa¿da de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';


        IF SQLCODE < 0 THEN
          -- Caso ocorra exception gerar o código do erro com a linha do erro
          vr_dscritic:= vr_dscritic ||
                        dbms_utility.format_error_backtrace;

        END IF;

        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_obtem_dados_empresti --> ' ||
                       vr_dscritic || ' -- SQLERRM: ' || SQLERRM;

        -- Remover as ASPAS que quebram o texto
        vr_dscritic:= replace(vr_dscritic,'"', '');
        vr_dscritic:= replace(vr_dscritic,'''','');
        -- Remover as quebras de linha
        vr_dscritic:= replace(vr_dscritic,chr(10),'');
        vr_dscritic:= replace(vr_dscritic,chr(13),'');


        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                         ,pr_nrctremp       IN crapepr.nrctremp%TYPE    --> Número contrato empréstimo
                                         ,pr_cdprogra       IN crapprg.cdprogra%TYPE    --> Programa conectado
                                         ,pr_flgerlog       IN VARCHAR2                 --> Gerar log S/N
                                         ,pr_flgcondc       IN INTEGER                  --> Mostrar emprestimos liquidados sem prejuizo
                                         ,pr_nriniseq       IN INTEGER                  --> Numero inicial da paginacao
                                         ,pr_nrregist       IN INTEGER                  --> Numero de registros por pagina
                                         ,pr_xmllog         IN VARCHAR2                 --> XML com informações de LOG
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
       Data    : Agosto/2015.                         Ultima atualizacao: 23/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Chamada para ayllosWeb(mensageria)
                   Procedure para obter dados de emprestimos do associado

       Alteracoes: 23/11/2015 - Incluido nvl no campo pr_nrctremp devido no ayllosweb
                                as vezes vir campo nulo conforme a navegação (Odirlei-AMcom)

                   23/06/2017 - Inclusao dos campos do produto Pos-Fixado. (Jaison/James - PRJ298)

                   07/06/2018 - P410 - Inclusao dos campos do IOF (Marcos-Envolti)

    ............................................................................. */

    -------------------------- VARIAVEIS ----------------------
    -- Cursor genérico de calendário
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
    --Indicador de utilização da tabela
    vr_inusatab BOOLEAN;
    --Nome Primeiro Titular
    vr_nmprimtl crapass.nmprimtl%TYPE;

    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    vr_index           VARCHAR2(100);

    vr_dscritic VARCHAR2(4000);
    vr_cdcritic crapcri.cdcritic%TYPE;
    -------------------------------  CURSORES  -------------------------------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;


    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
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
                           ,pr_cdagenci       => vr_cdagenci           --> Código da agência
                           ,pr_nrdcaixa       => vr_nrdcaixa           --> Número do caixa
                           ,pr_cdoperad       => vr_cdoperad           --> Código do operador
                           ,pr_nmdatela       => vr_nmdatela           --> Nome datela conectada
                           ,pr_idorigem       => vr_idorigem           --> Indicador da origem da chamada
                           ,pr_nrdconta       => pr_nrdconta           --> Conta do associado
                           ,pr_idseqttl       => pr_idseqttl           --> Sequencia de titularidade da conta
                           ,pr_rw_crapdat     => rw_crapdat            --> Vetor com dados de parâmetro (CRAPDAT)
                           ,pr_dtcalcul       => pr_dtcalcul           --> Data solicitada do calculo
                           ,pr_nrctremp       => nvl(pr_nrctremp,0)    --> Número contrato empréstimo
                           ,pr_cdprogra       => pr_cdprogra           --> Programa conectado
                           ,pr_inusatab       => vr_inusatab     --> Indicador de utilização da tabela
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
                           ,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empréstimo
                           ,pr_des_reto       => vr_des_reto           --> Retorno OK / NOK
                           ,pr_tab_erro       => vr_tab_erro);         --> Tabela com possíves erros

    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN

        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      ELSE
        vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
      END IF;
      RAISE vr_exc_erro;

    END IF;


    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
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
                        '<idfiniof>' || vr_tab_dados_epr(vr_index).idfiniof || '</idfiniof>' ||
                        '<vliofepr>' || vr_tab_dados_epr(vr_index).vliofepr || '</vliofepr>' ||
                        '<vlrtarif>' || vr_tab_dados_epr(vr_index).vlrtarif || '</vlrtarif>' ||
                        '<vlrtotal>' || vr_tab_dados_epr(vr_index).vlrtotal || '</vlrtotal>' ||
                        '<vliofcpl>' || vr_tab_dados_epr(vr_index).vliofcpl || '</vliofcpl>' ||
                        '<vltiofpr>' || vr_tab_dados_epr(vr_index).vltiofpr || '</vltiofpr>' ||
                        '<vlpiofpr>' || vr_tab_dados_epr(vr_index).vlpiofpr || '</vlpiofpr>' ||
                        '<tpatuidx>' || vr_tab_dados_epr(vr_index).tpatuidx || '</tpatuidx>' ||
                        '<idcarenc>' || vr_tab_dados_epr(vr_index).idcarenc || '</idcarenc>' ||
                        '<dtcarenc>' || to_char(vr_tab_dados_epr(vr_index).dtcarenc,'DD/MM/RRRR') || '</dtcarenc>' ||
                        '<nrdiacar>' || vr_tab_dados_epr(vr_index).nrdiacar || '</nrdiacar>' ||
                        '<qttolatr>' || vr_tab_dados_epr(vr_index).qttolatr || '</qttolatr>' ||
                        '<dsratpro>' || vr_tab_dados_epr(vr_index).dsratpro || '</dsratpro>' ||
                        '<dsratatu>' || vr_tab_dados_epr(vr_index).dsratatu || '</dsratatu>' ||
                        '<flintcdc>' || vr_tab_dados_epr(vr_index).flintcdc            || '</flintcdc>' ||
                        '<cdoperad>' || vr_tab_dados_epr(vr_index).cdoperad            || '</cdoperad>' ||
                        '<inintegra_cont>' || vr_tab_dados_epr(vr_index).inintegra_cont|| '</inintegra_cont>' ||
                        '<tpfinali>' ||  vr_tab_dados_epr(vr_index).tpfinali           || '</tpfinali>' ||
                        '<vlprecar>' ||  vr_tab_dados_epr(vr_index).vlprecar           || '</vlprecar>' ||
                        '<nrdiaatr>' || vr_tab_dados_epr(vr_index).nrdiaatr || '</nrdiaatr>' ||
                      '</inf>' );

      -- buscar proximo
      vr_index := vr_tab_dados_epr.next(vr_index);
    END LOOP;

    pc_escreve_xml ('</Dados></Root>',TRUE);

    pr_retxml := XMLType.createXML(vr_des_xml);
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na empr0001.pc_obtem_dados_empresti_web ' ||
                     SQLERRM;
  END pc_obtem_dados_empresti_web;


  /* Calcular o saldo devedor do emprestimo */
  PROCEDURE pc_calc_saldo_epr(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                             ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                             ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Programa que solicitou o calculo
                             ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta do empréstimo
                             ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato do empréstimo
                             ,pr_inusatab   IN BOOLEAN --> Indicador de utilização da tabela de juros
                             ,pr_vlsdeved   OUT NUMBER --> Saldo devedor do empréstimo
                             ,pr_qtprecal   OUT crapepr.qtprecal%TYPE --> Quantidade de parcelas do empréstimo
                             ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Código de critica encontrada
                             ,pr_des_erro   OUT VARCHAR2) IS --> Retorno de Erro
  BEGIN
    /* .............................................................................

       Programa: pc_calc_saldo_epr (antigo Fontes/saldo_epr.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Edson
       Data    : Junho/2004.                         Ultima atualizacao: 08/08/2017

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

                    05/02/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

                    12/03/2014 - Alterada a chamada para da  pc_busca_pgto_parcelas
                                 para pc_busca_pgto_parcelas_prefix (Odirlei-AMcom)

                    08/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

    ............................................................................. */
    DECLARE
      -- Dia e data de pagamento de empréstimo
      vr_tab_diapagto NUMBER;
      vr_tab_dtcalcul DATE;
      -- Flag para desconto em folha
      vr_tab_flgfolha BOOLEAN;
      -- Configuração para mês novo
      vr_tab_ddmesnov INTEGER;
      /* Rowtype com informações dos empréstimos */
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
              ,epr.qtprecal
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
               AND epr.nrdconta = pr_nrdconta
               AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      -- Busca das linhas de crédito
      CURSOR cr_craplcr(pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT lcr.txdiaria
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper
               AND lcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      -- Variáveis para passagem a rotina pc_calcula_lelem e pc_busca_pgto_parcelas
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
      vr_vlpreapg        NUMBER;
      vr_vlprvenc        NUMBER;
      vr_vlpraven        NUMBER;
      vr_vlmtapar        NUMBER;
      vr_vlmrapar        NUMBER;
      vr_vliofcpl        NUMBER;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

    BEGIN
      -- Buscar a configuração de empréstimo cfme a empresa da conta
      pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                                ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data atual
                                ,pr_nrdconta => pr_nrdconta --> Numero da conta do empréstimo
                                ,pr_dtcalcul => vr_tab_dtcalcul --> Data calculada de pagamento
                                ,pr_diapagto => vr_tab_diapagto --> Dia de pagamento das parcelas
                                ,pr_flgfolha => vr_tab_flgfolha --> Flag de desconto em folha S/N
                                ,pr_ddmesnov => vr_tab_ddmesnov --> Configuração para mês novo
                                ,pr_cdcritic => pr_cdcritic --> Código do erro
                                ,pr_des_erro => vr_des_erro); --> Retorno de Erro
      -- Se houve erro na rotina
      IF vr_des_erro IS NOT NULL
         OR pr_cdcritic IS NOT NULL THEN
        -- Levantar exce¿¿o
        RAISE vr_exc_erro;
      END IF;
      -- Busca dos detalhes do empréstimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr
        INTO rw_crapepr;
      -- Se não encontrar informações
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
      -- Se está setado para utilizarmos a tabela de juros
      -- e o empréstimo ainda não está liquidado
      IF pr_inusatab
         AND rw_crapepr.inliquid = 0 THEN
        -- Iremos buscar a tabela de juros nas linhas de crédito
        OPEN cr_craplcr(pr_cdlcremp => rw_crapepr.cdlcremp);
        FETCH cr_craplcr
          INTO rw_craplcr;
        -- Se não encontrar
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
        -- Usar taxa cadastrada no empréstimo
        vr_txdjuros := rw_crapepr.txjuremp;
      END IF;
      -- Para empréstimo atual
      IF rw_crapepr.tpemprst = 0 THEN
        -- Povoar Variáveis para o calculo com os valores do empréstimo
        vr_diapagto := vr_tab_diapagto;
        vr_qtprepag := NVL(rw_crapepr.qtprepag, 0);
        vr_vlprepag := 0;
        vr_vlsdeved := NVL(rw_crapepr.vlsdeved, 0);
        vr_vljuracu := NVL(rw_crapepr.vljuracu, 0);
        vr_vljurmes := 0;
        vr_dtultpag := LAST_DAY(pr_rw_crapdat.dtmvtolt);
        -- Chamar rotina de cálculo externa
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
        -- Copiar os valores da rotina para as variaveis de sa¿da
        pr_vlsdeved := vr_vlsdeved;
        pr_qtprecal := vr_qtprecal_lem;

      -- Pre-fixada
      ELSIF rw_crapepr.tpemprst = 1 THEN

        /* Busca dos pagamentos das parcelas de empréstimo prefixados*/
        empr0001.pc_busca_pgto_parcelas_prefix(pr_cdcooper      => pr_cdcooper --> Cooperativa conectada
                                              ,pr_cdagenci      => 1 --> Código da agência
                                              ,pr_nrdcaixa      => 999 --> Número do caixa
                                              ,pr_nrdconta      => pr_nrdconta --> Número da conta
                                              ,pr_nrctremp      => rw_crapepr.nrctremp --> Número do contrato de empréstimo
                                              ,pr_rw_crapdat    => pr_rw_crapdat --> Vetor com dados de parâmetro (CRAPDAT)
                                              ,pr_dtmvtolt      => pr_rw_crapdat.dtmvtolt --> Data de movimento
                                              ,pr_vlemprst      => rw_crapepr.vlemprst --> Valor do emprestioms
                                              ,pr_qtpreemp      => rw_crapepr.qtpreemp --> qtd de parcelas do emprestimo
                                              ,pr_dtdpagto      => rw_crapepr.dtdpagto --> data de pagamento
                                              ,pr_txmensal      => rw_crapepr.txmensal --> Taxa mensal do emprestimo
                                              ,pr_cdlcremp      => rw_crapepr.cdlcremp --> Taxa mensal do emprestimo
                                              ,pr_qttolatr      => rw_crapepr.qttolatr --> Quantidade de dias de tolerancia
                                              ,pr_des_reto      => vr_des_reto --> Retorno OK / NOK
                                              ,pr_tab_erro      => vr_tab_erro --> Tabela com possíves erros
                                              ,pr_tab_calculado => vr_tab_calculado); --> Tabela com totais calculados

        -- Se a rotina retornou erro
        IF vr_des_reto = 'NOK' THEN
          -- Buscar o erro encontrado para gravar na vr_des_erro
          pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          -- Gerar exce¿¿o
          RAISE vr_exc_erro;
        END IF;
        -- Copiar os valores da rotina para as variaveis de sa¿da
        pr_vlsdeved := vr_tab_calculado(vr_tab_calculado.FIRST).vlsderel;
        pr_qtprecal := vr_tab_calculado(vr_tab_calculado.FIRST).qtprecal;

      -- Pos-fixada
      ELSIF rw_crapepr.tpemprst = 2 THEN

        -- Busca as parcelas para pagamento
        EMPR0011.pc_busca_pagto_parc_pos_prog(pr_cdcooper => pr_cdcooper
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_dtmvtolt => TO_CHAR(pr_rw_crapdat.dtmvtolt,'DD/MM/RRRR')
                                             ,pr_dtmvtoan => TO_CHAR(pr_rw_crapdat.dtmvtoan,'DD/MM/RRRR')
                                             ,pr_nrdconta => rw_crapepr.nrdconta
                                             ,pr_nrctremp => rw_crapepr.nrctremp
                                             --,pr_cdlcremp => rw_crapepr.cdlcremp
                                             --,pr_qttolatr => rw_crapepr.qttolatr
                                             ,pr_vlsdeved => pr_vlsdeved
                                             ,pr_vlprvenc => vr_vlprvenc
                                             ,pr_vlpraven => vr_vlpraven
                                             ,pr_vlmtapar => vr_vlmtapar
                                             ,pr_vlmrapar => vr_vlmrapar
                                             ,pr_vliofcpl => vr_vliofcpl
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Copiar os valores da rotina para as variaveis de saida
        pr_qtprecal := rw_crapepr.qtprecal;

      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a vari¿vel de saida
        pr_cdcritic := nvl(pr_cdcritic, 0);
        pr_des_erro := vr_des_erro;
      WHEN OTHERS THEN
        -- Montar mensagem com o sqlerrm pois ocorreu um erro cr¿tico
        pr_cdcritic := nvl(pr_cdcritic, 0);
        pr_des_erro := 'Problemas no procedimento empr0001.pc_calc_saldo_epr. Erro: ' ||
                       sqlerrm;
    END;
  END pc_calc_saldo_epr;

  /* Procedure para calcular saldo devedor de emprestimos */
  PROCEDURE pc_saldo_devedor_epr(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Código da agência
                                ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> Número do caixa
                                ,pr_cdoperad   IN crapdev.cdoperad%TYPE --> Código do operador
                                ,pr_nmdatela   IN VARCHAR2 --> Nome datela conectada
                                ,pr_idorigem   IN INTEGER --> Indicador da origem da chamada
                                ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                                ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Número contrato empréstimo
                                ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Programa conectado
                                ,pr_inusatab   IN BOOLEAN --> Indicador de utilização da tabela
                                ,pr_flgerlog   IN VARCHAR2 --> Gerar log S/N
                                ,pr_vlsdeved   IN OUT NUMBER --> Saldo devedor calculado
                                ,pr_vltotpre   IN OUT NUMBER --> Valor total das prestações
                                ,pr_qtprecal   IN OUT crapepr.qtprecal%TYPE --> Parcelas calculadas
                                ,pr_des_reto   OUT VARCHAR --> Retorno OK / NOK
                                ,pr_tab_erro   OUT gene0001.typ_tab_erro) IS --> Tabela com possíveis erros
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

       Alteracoes:  03/06/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

                    03/09/2014 - Ajustes no cursor cr_crapepr, pois quando nrctremp
                                 fosse igual a zero, ele não tratava o retorno de
                                 todos os empréstimos (Marcos-Supero)

    ............................................................................. */
    DECLARE
      -- Saida com erro alternativa
      vr_exc_erro2 exception;

      -- Dia e data de pagamento de empréstimo
      vr_tab_diapagto NUMBER;
      vr_tab_dtcalcul DATE;
      -- Flag para desconto em folha
      vr_tab_flgfolha BOOLEAN;
      -- Configuração para mês novo
      vr_tab_ddmesnov INTEGER;
      -- Rowid para inserção de log
      vr_nrdrowid ROWID;

      -- Variáveis para passagem a rotina pc_calcula_lelem
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
      vr_txdjuros NUMBER(12, 7); --> Taxa de juros para o cálculo
      vr_qtprecal crapepr.qtprecal%TYPE; --> Qatdade de parclas calculadas até o momento
      vr_vlpreapg NUMBER; --> Valor das parcelas a pagar
      vr_vlmrapar crappep.vlmrapar%TYPE; --> Valor do Juros de Mora
      vr_vlmtapar crappep.vlmtapar%TYPE; --> Valor da Multa
      vr_vliofcpl crappep.vliofcpl%TYPE; --> IOF atraso
      vr_vlprvenc NUMBER; --> Valor Vencido
      vr_vlpraven NUMBER; --> Valor a Vencer
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

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
              ,inprejuz
          FROM crapepr
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = DECODE(pr_nrctremp, 0, nrctremp, pr_nrctremp);

      -- Buscar dados da linha de crédito
      CURSOR cr_craplcr(pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT txdiaria
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
               AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

    BEGIN
      -- Buscar a configuração de empréstimo cfme a empresa da conta
      pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                                ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data atual
                                ,pr_nrdconta => pr_nrdconta --> Numero da conta do empréstimo
                                ,pr_dtcalcul => vr_tab_dtcalcul --> Data calculada de pagamento
                                ,pr_diapagto => vr_tab_diapagto --> Dia de pagamento das parcelas
                                ,pr_flgfolha => vr_tab_flgfolha --> Flag de desconto em folha S/N
                                ,pr_ddmesnov => vr_tab_ddmesnov --> Configuração para mês novo
                                ,pr_cdcritic => vr_cdcritic --> Código do erro
                                ,pr_des_erro => vr_dscritic); --> Retorno de Erro
      -- Se houve erro na rotina
      IF vr_dscritic IS NOT NULL
         OR vr_cdcritic IS NOT NULL THEN
        -- Levantar exce¿¿o
        RAISE vr_exc_erro;
      END IF;

      -- Busca dos dados do emprestimo passado como parametro
      FOR rw_crapepr IN cr_crapepr LOOP
        -- Se foi passado que haver¿ utilização da tabela de juros e o o empréstimo estiver ativo
        IF pr_inusatab
           AND rw_crapepr.inliquid = 0 THEN
          -- Buscar a taxa cfme a linha de crédito
          OPEN cr_craplcr(pr_cdlcremp => rw_crapepr.cdlcremp);
          FETCH cr_craplcr
            INTO rw_craplcr;
          -- Se não tiver encontrado
          IF cr_craplcr%NOTFOUND THEN
            -- Fechar o cursor e gerar erro
            CLOSE cr_craplcr;
            vr_cdcritic := 363;
            RAISE vr_exc_erro;
          ELSE
            -- Fechar o cursor
            CLOSE cr_craplcr;
            -- Utilizar a taxa da linha de crédito
            vr_txdjuros := rw_craplcr.txdiaria;
          END IF;
        ELSE
          -- Utilizaremos a taxa do empréstimo
          vr_txdjuros := rw_crapepr.txjuremp;
        END IF;
        -- Inicializar variaveis para o calculo do saldo devedor
        vr_vlsdeved := rw_crapepr.vlsdeved;
        vr_vljuracu := rw_crapepr.vljuracu;
        vr_vlmrapar := 0;
        vr_vlmtapar := 0;
        vr_vliofcpl := 0;

        -- Para empréstimo ainda não liquidados
        IF rw_crapepr.inliquid = 0 THEN
          -- Manter o valor da tabela
          vr_qtprecal := rw_crapepr.qtprecal;
        ELSE
          -- Usar o valor total de parcelas
          vr_qtprecal := rw_crapepr.qtpreemp;
        END IF;
        -- Calculo de saldo devedor em emprestimos baseado na includes/lelem.i.
        pc_calc_saldo_deved_epr_lem(pr_cdcooper   => pr_cdcooper --> Cooperativa conectada
                                   ,pr_cdprogra   => pr_cdprogra --> Código do programa corrente
                                   ,pr_cdagenci   => rw_crapepr.cdagenci --> Código da agência
                                   ,pr_nrdcaixa   => pr_nrdcaixa --> Número do caixa
                                   ,pr_cdoperad   => pr_cdoperad --> Código do Operador
                                   ,pr_rw_crapdat => pr_rw_crapdat --> Vetor com dados de parâmetro (CRAPDAT)
                                   ,pr_nrdconta   => pr_nrdconta --> Número da conta
                                   ,pr_idseqttl   => pr_idseqttl --> Seq titular
                                   ,pr_nrctremp   => rw_crapepr.nrctremp --> Numero ctrato empréstimo
                                   ,pr_idorigem   => pr_idorigem --> Id do módulo de sistema
                                   ,pr_txdjuros   => vr_txdjuros --> Taxa de juros aplicada
                                   ,pr_dtcalcul   => NULL --> Data para calculo do empréstimo
                                   ,pr_diapagto   => vr_tab_diapagto --> Dia para pagamento
                                   ,pr_qtprecal   => vr_qtprecal_lem --> Quantidade de prestações calculadas até momento
                                   ,pr_vlprepag   => vr_vlprepag --> Valor acumulado pago no mês
                                   ,pr_vlpreapg   => vr_vlpreapg --> Valor a pagar
                                   ,pr_vljurmes   => vr_vljurmes --> Juros no mês corrente
                                   ,pr_vljuracu   => vr_vljuracu --> Juros acumulados total
                                   ,pr_vlsdeved   => vr_vlsdeved --> Saldo devedor acumulado
                                   ,pr_dtultpag   => vr_dtultpag --> Ultimo dia de pagamento das prestações
                                   ,pr_vlmrapar   => vr_vlmrapar --> Valor do Juros de Mora
                                   ,pr_vlmtapar   => vr_vlmtapar --> Valor da Multa
                                   ,pr_vliofcpl   => vr_vliofcpl --> Valor da Multa
                                   ,pr_vlprvenc   => vr_vlprvenc --> Valor Vencido da parcela
                                   ,pr_vlpraven   => vr_vlpraven --> Valor a Vencer
                                   ,pr_flgerlog   => pr_flgerlog --> Gerar log S/N
                                   ,pr_des_reto   => pr_des_reto --> Retorno OK / NOK
                                   ,pr_tab_erro   => vr_tab_erro); --> Tabela com possíveis erros
        -- Se a rotina retornou erro
        IF pr_des_reto = 'NOK' THEN
          -- Gerar exceção 2 onde não ¿ montada a tabela de erro
          RAISE vr_exc_erro2;
        END IF;
        -- Se o saldo devedor for superior a zero
        IF vr_vlsdeved > 0 THEN
          -- Acumular ao total o valor da parcela
          pr_vltotpre := pr_vltotpre + rw_crapepr.vlpreemp;
        END IF;
        -- Acumular a quantidade de parcelas calculadas
        pr_qtprecal := pr_qtprecal + nvl(vr_qtprecal_lem,0);
        -- Acumular o saldo devedor calculado
        pr_vlsdeved := pr_vlsdeved + nvl(vr_vlsdeved,0);
        -- M324
        /*IF rw_crapepr.inprejuz > 0 THEN
          pr_vlsdeved := 0;
        END IF;*/
      END LOOP; -- Fim leitura dos empréstimos

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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Copiar variavel tempor¿ria para a de sa¿da de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_obtem_dados_empresti --> ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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

  PROCEDURE pc_saldo_devedor_epr_car(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Código da agência
                                    ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> Número do caixa
                                    ,pr_cdoperad   IN crapdev.cdoperad%TYPE --> Código do operador
                                    ,pr_nmdatela   IN VARCHAR2 --> Nome datela conectada
                                    ,pr_idorigem   IN INTEGER --> Indicador da origem da chamada
                                    ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                    ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Sequencia de titularidade da conta
                                    ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Número contrato empréstimo
                                    ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Programa conectado
                                    ,pr_flgerlog   IN VARCHAR2 --> Gerar log S/N
                                    ,pr_vlsdeved   IN OUT NUMBER --> Saldo devedor calculado
                                    ,pr_vltotpre   IN OUT NUMBER --> Valor total das prestações
                                    ,pr_qtprecal   IN OUT crapepr.qtprecal%TYPE --> Parcelas calculadas
                                    ,pr_des_reto   OUT VARCHAR2 --> Retorno OK / NOK
                                    ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Código da crítica
                                    ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS --> Descrição da crítica
  BEGIN
    /* .............................................................................

       Programa: pc_saldo_devedor_epr_car
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : David
       Data    : Agosto/2018.                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Procedure para calcular saldo devedor de emprestimos

       Alteracoes:

    ............................................................................. */
    DECLARE
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;

      vr_cdcritic     INTEGER;
      vr_dscritic     VARCHAR2(1000);
      vr_exc_erro     EXCEPTION;
      vr_tab_erro     gene0001.typ_tab_erro;
      vr_des_reto     VARCHAR2(100);

      vr_dsorigem     VARCHAR2(50);
      vr_dstransa     VARCHAR2(200);
      vr_nrdrowid     ROWID;

      vr_dstextab     craptab.dstextab%TYPE;
      vr_inusatab     BOOLEAN;
      vr_vlsldepr     NUMBER   := 0;
      vr_vltotpre     NUMBER   := 0;
      vr_qtprecal     INTEGER  := 0;
    BEGIN
      -- Leitura do calendário da cooperativa, para alguns procedimentos que precisam
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
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

      --Verificar se usa tabela juros
      vr_dstextab := TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'USUARI'
                                                ,pr_cdempres => 11
                                                ,pr_cdacesso => 'TAXATABELA'
                                                ,pr_tpregist => 0);
      -- Se a primeira posição do campo dstextab for diferente de zero
      vr_inusatab := SUBSTR(vr_dstextab,1,1) != '0';

      -- Buscar saldo devedor
      empr0001.pc_saldo_devedor_epr (pr_cdcooper   => pr_cdcooper     --> Cooperativa conectada
                                    ,pr_cdagenci   => pr_cdagenci     --> Codigo da agencia
                                    ,pr_nrdcaixa   => pr_nrdcaixa     --> Numero do caixa
                                    ,pr_cdoperad   => pr_cdoperad     --> Codigo do operador
                                    ,pr_nmdatela   => pr_nmdatela     --> Nome datela conectada
                                    ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                                    ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                    ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                                    ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parametro (CRAPDAT)
                                    ,pr_nrctremp   => pr_nrctremp     --> Numero contrato emprestimo
                                    ,pr_cdprogra   => pr_nmdatela     --> Programa conectado
                                    ,pr_inusatab   => vr_inusatab     --> Indicador de utilizacão da tabela
                                    ,pr_flgerlog   => 'N'             --> Gerar log S/N
                                    ,pr_vlsdeved   => vr_vlsldepr     --> Saldo devedor calculado
                                    ,pr_vltotpre   => vr_vltotpre     --> Valor total das prestacães
                                    ,pr_qtprecal   => vr_qtprecal     --> Parcelas calculadas
                                    ,pr_des_reto   => vr_des_reto     --> Retorno OK / NOK
                                    ,pr_tab_erro   => vr_tab_erro);   --> Tabela com possives erros

      -- Se houve retorno de erro
      IF vr_des_reto = 'NOK' THEN
        pr_des_reto := 'NOK';

        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;

        -- Limpar tabela de erros
        vr_tab_erro.DELETE;

        RAISE vr_exc_erro;
      END IF;

      pr_vlsdeved := vr_vlsldepr;
      pr_vltotpre := vr_vltotpre;
      pr_qtprecal := vr_qtprecal;

      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';

        IF NVL(vr_cdcritic,0) <> 0 AND TRIM(NVL(vr_dscritic,' ')) <> '' THEN
          -- Gerar rotina de gravação de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => vr_tab_erro);
        END IF;

        -- Se foi solicitado log
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Obter saldo devedor do associado em emprestimos'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_saldo_devedor_epr_car --> ' || SQLERRM;

        -- Se foi solicitado log
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Obter saldo devedor do associado em emprestimos'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
    END;
  END pc_saldo_devedor_epr_car;

  /* Calcular a quantidade de dias que o emprestimo está em atraso */
  FUNCTION fn_busca_dias_atraso_epr(pr_cdcooper IN crappep.cdcooper%TYPE --> Código da Cooperativa
                                   ,pr_nrdconta IN crappep.nrdconta%TYPE --> Numero da Conta do empréstimo
                                   ,pr_nrctremp IN crappep.nrctremp%TYPE --> Numero do Contrato de empréstimo
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
       Objetivo  : Rotina de calculo de dias que o emprestimo está em atraso.

       Alteracoes: 11/02/2013 - Conversão Progress para Oracle (Alisson - AMcom)

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
  PROCEDURE pc_calc_dias_atraso(pr_cdcooper   IN crapepr.cdcooper%TYPE --> Código da cooperativa
                               ,pr_cdprogra   IN VARCHAR2 --> Nome do programa que está executando
                               ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta do emprestimo
                               ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                               ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                               ,pr_inusatab   IN BOOLEAN --> Indicador de utilização da tabela de juros
                               ,pr_vlsdeved   OUT NUMBER --> Valor do saldo devedor
                               ,pr_qtprecal   OUT NUMBER --> Quantidade de Parcelas
                               ,pr_qtdiaatr   OUT NUMBER --> Quantidade de dias em atraso
                               ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Código de critica encontrada
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

                   11/02/2013 - Conversão Progress para Oracle (Alisson - AMcom)

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
        vr_des_erro := 'Contrato de Emprestimo não encontrado.';
        --Levantar Exce¿¿o
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
          --Se o dia do pagamento > dia movimento para o mesmo mês e ano
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
          --Levantar Exce¿¿o
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
        vr_qtdias := empr0001.fn_busca_dias_atraso_epr(pr_cdcooper => pr_cdcooper
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
        pr_des_erro := 'Erro na rotina empr0001.pc_calc_dias_atraso. ' ||
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

       Alteracoes: 25/02/2014 - Conversão Progress para Oracle (Alisson - AMcom)

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
        pr_dscritic := 'Erro na rotina empr0001.pc_inclui_altera_lote. ' ||
                       sqlerrm;
    END;
  END pc_inclui_altera_lote;

  /* Criar o lancamento na Conta Corrente  */
  PROCEDURE pc_cria_lancamento_cc_chave(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                 ,pr_cdbccxlt IN craperr.nrdcaixa%TYPE --> Número do caixa
                                 ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                 ,pr_cdpactra IN INTEGER --> P.A. da transação
                                 ,pr_nrdolote IN craplot.nrdolote%TYPE --> Numero do Lote
                                 ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                 ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo historico
                                 ,pr_vllanmto IN NUMBER --> Valor da parcela emprestimo
                                 ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                 ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                 ,pr_nrseqava IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                 ,pr_idlautom IN NUMBER DEFAULT 0 --> sequencia criada pela craplau
                                       ,pr_nrseqdig OUT INTEGER  --> Número sequencia
                                 ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................

       Programa: pc_cria_lancamento_cc_chave                 Antigo: b1wgen0084a.p/cria_lancamento_cc
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 05/05/2017

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Mesma regra da antiga pc_cria_lancamento_cc, mas retorna a chave nrseqdig

       Alteracoes:
    ............................................................................. */

    DECLARE
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_des_erro VARCHAR2(3);
      vr_dscritic VARCHAR2(4000);

      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;

      -- Variáveis P450 - Regultório de Crédito
      vr_incrineg    INTEGER;
      vr_tab_retorno lanc0001.typ_reg_retorno;
      vr_fldebita    BOOLEAN;

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
                             ,pr_nrseqdig => pr_nrseqdig --Numero Sequencia
                             ,pr_cdcritic => vr_cdcritic --Codigo Erro
                             ,pr_dscritic => vr_dscritic); --Descricao Erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL
           OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

         -- Atualiza lote e e Insere lançamento
         -- P450 - Regulatório de Crédito
        BEGIN
            LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt => pr_dtmvtolt
                                              ,pr_cdagenci => pr_cdpactra
                                              ,pr_cdbccxlt => pr_cdbccxlt
                                              ,pr_nrdolote => pr_nrdolote
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_nrdocmto => pr_nrseqdig
                                              ,pr_cdhistor => pr_cdhistor
                                              ,pr_nrseqdig => pr_nrseqdig
                                              ,pr_vllanmto => pr_vllanmto
                                              ,pr_nrdctabb => pr_nrdconta
                                              ,pr_cdpesqbb => gene0002.fn_mask(pr_nrctremp, 'zz.zzz.zz9')
                                              ,pr_hrtransa => gene0002.fn_busca_time
                                              ,pr_cdoperad => pr_cdoperad
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nrdctitg => gene0002.fn_mask(pr_nrdconta, '99999999')
                                              ,pr_nrparepr => pr_nrparepr
                                              ,pr_nrseqava => pr_nrseqava
                                              ,pr_idlautom => pr_idlautom
                                              -- OUTPUT --
                                              ,pr_tab_retorno => vr_tab_retorno
                                              ,pr_incrineg => vr_incrineg
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);

            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
               IF vr_incrineg = 0 THEN -- Erro de sistema/BD
            RAISE vr_exc_erro;
               ELSE -- Não foi possível debitar (crítica de negócio)

            RAISE vr_exc_erro;
               END IF;
            END IF;
        END;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_cdbccxlt
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_cria_lancamento_cc ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_cdbccxlt
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_cria_lancamento_cc_chave;

  /* Criar o lancamento na Conta Corrente  */
  PROCEDURE pc_cria_lancamento_cc(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                 ,pr_cdbccxlt IN craperr.nrdcaixa%TYPE --> Número do caixa
                                 ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                 ,pr_cdpactra IN INTEGER --> P.A. da transação
                                 ,pr_nrdolote IN craplot.nrdolote%TYPE --> Numero do Lote
                                 ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                 ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo historico
                                 ,pr_vllanmto IN NUMBER --> Valor da parcela emprestimo
                                 ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                 ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                 ,pr_nrseqava IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                 ,pr_idlautom IN NUMBER DEFAULT 0 --> sequencia criada pela craplau
                                 ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................

       Programa: pc_cria_lancamento_cc                 Antigo: b1wgen0084a.p/cria_lancamento_cc
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 05/05/2017

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para o lançamento do pagto da parcela na Conta Corrente

       Alteracoes: 28/02/2014 - Conversão Progress para Oracle (Alisson - AMcom)

                   16/06/2014 - Ajuste para atualizar o campo nrseqava. (James)

                   13/08/2014 - Ajuste para gravar o operador e a hora da transacao. (James)

                   05/05/2017 - Ajuste para gravar o idlautom (Lucas Ranghetti M338.1)
    ............................................................................. */

    DECLARE
      --Variaveis Erro
      vr_nrseqdig INTEGER;

      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_dscritic VARCHAR2(4000);
    BEGIN
      pr_des_reto := 'OK';
      empr0001.pc_cria_lancamento_cc_chave(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                       ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                       ,pr_cdagenci => pr_cdagenci --> Código da agência
                                       ,pr_cdbccxlt => pr_cdbccxlt --> Número do caixa
                                       ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                       ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                       ,pr_nrdolote => pr_nrdolote --> Numero do Lote
                                       ,pr_nrdconta => pr_nrdconta --> Número da conta
                                       ,pr_cdhistor => pr_cdhistor --> Codigo historico
                                       ,pr_vllanmto => pr_vllanmto --> Valor da parcela emprestimo
                                       ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                       ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                       ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                       ,pr_idlautom => pr_idlautom --> sequencia criada pela craplau
                                       ,pr_nrseqdig => vr_nrseqdig  --> Número sequencia
                                       ,pr_des_reto => pr_des_reto  --> Retorno OK / NOK
                                       ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros

        IF TRIM(UPPER(pr_des_reto)) = 'NOK' OR
           pr_tab_erro.COUNT() > 0 THEN
          RAISE vr_exc_erro;
        END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_cria_lancamento_cc ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                  ,pr_qtdiacal IN NUMBER DEFAULT 0 --> Quantidade dias usado no calculo
                                  ,pr_vltaxprd IN NUMBER DEFAULT 0 --> Valor da Taxa no Periodo
                                  ,pr_cdcritic OUT INTEGER --Codigo Erro
                                  ,pr_dscritic OUT VARCHAR2) IS --Descricao Erro
  BEGIN
    /* .............................................................................

       Programa: pc_cria_lancamento_lem                 Antigo: b1wgen0134.p/cria_lancamento_lem
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 15/08/2017

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Criar lancamento e atualiza o lote

       Alteracoes: 25/02/2014 - Conversão Progress para Oracle (Alisson - AMcom)

                   16/06/2014 - Ajuste para atualizar o campo nrseqava. (James)

                   15/08/2017 - Inclusao do campo qtdiacal. (Jaison/James - PRJ298)

                   01/02/2018 - Inclusao do campo vltaxprd. (James)
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
      empr0001.pc_cria_lancamento_lem_chave(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => pr_cdbccxlt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdpactra
                                         ,pr_tplotmov => pr_tplotmov
                                         ,pr_nrdolote => pr_nrdolote
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => pr_cdhistor
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => pr_vllanmto
                                         ,pr_dtpagemp => pr_dtpagemp
                                         ,pr_txjurepr => pr_txjurepr
                                         ,pr_vlpreemp => pr_vlpreemp
                                         ,pr_nrsequni => pr_nrsequni
                                         ,pr_nrparepr => pr_nrparepr
                                         ,pr_flgincre => pr_flgincre
                                         ,pr_flgcredi => pr_flgcredi
                                         ,pr_nrseqava => pr_nrseqava
                                         ,pr_cdorigem => pr_cdorigem
                                         ,pr_qtdiacal => pr_qtdiacal
                                         ,pr_vltaxprd => pr_vltaxprd
                                         ,pr_nrseqdig => vr_nrseqdig
                                         ,pr_cdcritic => pr_cdcritic
                                         ,pr_dscritic => pr_dscritic);
    EXCEPTION
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina empr0001.pc_cria_lancamento_lem. ' ||
                       sqlerrm;
    END;
  END pc_cria_lancamento_lem;

  --Procedure para Criar lancamento e atualiza o lote
  PROCEDURE pc_cria_lancamento_lem_chave(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
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
                                        ,pr_qtdiacal IN NUMBER DEFAULT 0 --> Quantidade dias usado no calculo
                                        ,pr_vltaxprd IN NUMBER DEFAULT 0 --> Valor da Taxa no Periodo
                                        ,pr_nrseqdig OUT INTEGER --> Numero de sequencia
                                        ,pr_cdcritic OUT INTEGER --Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2) IS --Descricao Erro
  BEGIN
    /* .............................................................................

       Programa: pc_cria_lancamento_lem                 Antigo: b1wgen0134.p/cria_lancamento_lem
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 15/08/2017

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Criar lancamento e atualiza o lote

       Alteracoes: 25/02/2014 - Conversão Progress para Oracle (Alisson - AMcom)

                   16/06/2014 - Ajuste para atualizar o campo nrseqava. (James)

                   15/08/2017 - Inclusao do campo qtdiacal. (Jaison/James - PRJ298)

                   01/02/2018 - Inclusao do campo vltaxprd. (James)
                   
                   28/01/2019 - P410 Ajuste para retornar o pr_nrseqdig. (Douglas Pagel / AMcom)
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
      IF ROUND(pr_vllanmto,2) > 0 THEN
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
          ,craplem.cdorigem
          ,craplem.qtdiacal
          ,craplem.vltaxprd)
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
          ,pr_cdorigem
          ,pr_qtdiacal
          ,pr_vltaxprd);
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir na craplem. ' || SQLERRM;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
        --Retornar o número sequencial para o parametro de saida.
        pr_nrseqdig := vr_nrseqdig;    
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina empr0001.pc_cria_lancamento_lem. ' ||
                       sqlerrm;
    END;
  END pc_cria_lancamento_lem_chave;

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

       Alteracoes: 25/02/2014 - Conversão Progress para Oracle (Alisson - AMcom)

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
        --Se nao encontrar a conta e contrato na tabela é problema
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

        --verificar se é financiamento
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

        -- Melhoria 324 - Se estiver em prejuizo assume histórico 2409 - Jean (MOut´S)
        if rw_crabepr.inprejuz = 1 then
            vr_cdhistor := 2409;
        end if;

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
                       ,pr_diarefju => vr_diavtolt -- Dia da data de referência da última vez que rodou juros
                       ,pr_mesrefju => vr_mesvtolt -- Mes da data de referência da última vez que rodou juros
                       ,pr_anorefju => vr_anovtolt -- Ano da data de referência da última vez que rodou juros
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
                              ,pr_cdorigem => pr_cdorigem -- Origem do Lançamento
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
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Retorno não OK
        pr_des_reto := 'NOK';
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_lanca_juro_contrato. ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                       ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                       ,pr_flgliqui OUT BOOLEAN --> Liquidado
                                       ,pr_flgopera OUT BOOLEAN --> Financiamento
                                       ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
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

       Alteracoes: 03/03/2014 - Conversão Progress para Oracle (Alisson - AMcom)

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
        -- Busca dos detalhes do empréstimo
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
        FETCH cr_crapepr
          INTO rw_crapepr;
        -- Se não encontrar informações
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
          --Determinar se a Operacao é financiamento
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_verifica_liquidacao_empr ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                      ,pr_efetresg         IN VARCHAR2 DEFAULT 'N'
                                      ,pr_vlsomato         OUT NUMBER --Soma Total
                                      ,pr_vlresgat         OUT NUMBER --Soma
                                      ,pr_tab_erro         OUT gene0001.typ_tab_erro --tabela Erros
                                      ,pr_des_reto         OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_msg_confirma OUT typ_tab_msg_confirma) IS --Tabela Confirmacao

  BEGIN
    /* .............................................................................

       Programa: pc_valida_pagamentos_geral                 Antigo: b1wgen0084b.p/valida_pagamentos_geral
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 08/02/2018

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para lancamento de Juros dos Emprestimos

       Alteracoes: 27/02/2014 - Conversão Progress para Oracle (Alisson - AMcom)

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

                   16/03/2017 - Alteracao de mensagem de Contrato em acordo. (Jaison/James)

                   07/12/2017 - Ajustar validacao de saldo em pagamento de emprestimo PP
                                para quando nao houver saldo para debito verificar aplicacoes
                                em garantia e resgata-las. (Jaison/Marcos Martini - PRJ404)

                   08/02/2018 - Incluir novamente o número 3 fixo no parâmetro pr_cdorigem
                                na chamada da procedure recp0001.pc_verifica_acordo_ativo.
                                Alterado indevidamente em 23/01/2018 SM 12158. (SD#846598 - AJFink)

                   24/01/2018 - Adicionada solicitacao de senha de coordenador para utilizacao do saldo bloqueado no pagamento (Luis Fernando - GFT)

                   06/04/2018 - Alterar o tratamento relacionado as chamadas de resgate de aplicação,
                                para que não ocorram problemas com o fluxo atual em caso de ocorrencia
                                de erros. (Renato - Supero)

                   07/04/2018 - Ajustar o calculo do valor a ser resgatado (Renato - Supero)
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

    CURSOR cr_crapdpb IS
        select nvl(sum(c.vllanmto),0)
          from craphis x
             , crapdpb c
         where c.cdcooper = pr_cdcooper
           and c.nrdconta = pr_nrdconta
           and x.cdcooper = c.cdcooper
           and x.cdhistor = c.cdhistor
           and x.inhistor in (3,4,5)
           and c.dtliblan = pr_dtrefere
           and c.inlibera = 1;

      vr_vllibera number(25,2);

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
      vr_vlresgat NUMBER;
      vr_qtdiaatr NUMBER;
      vr_vlsdbloque NUMBER;
      vr_vlsddisptotal NUMBER;

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
        --Se nao encontrar a conta e contrato na tabela é problema
        IF NOT pr_tab_crawepr.EXISTS(vr_index_crawepr) THEN
          vr_cdcritic := 510;
          RAISE vr_exc_saida;
        ELSE
          rw_crawepr.dtlibera := pr_tab_crawepr(vr_index_crawepr).dtlibera;
          rw_crawepr.tpemprst := pr_tab_crawepr(vr_index_crawepr).tpemprst;
          rw_crawepr.idcobope := pr_tab_crawepr(vr_index_crawepr).idcobope;
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

      open cr_crapdpb;
          fetch cr_crapdpb into vr_vllibera;
          close cr_crapdpb;
        ELSE
          -- Se nao estiver no BATCH, busca apenas a informacao da conta que esta sendo passada
          vr_flgcrass := FALSE;
      vr_vllibera := 0;
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
                                --nvl(vr_tab_saldos(vr_index_saldo).vlsdbloq, 0) +
                                --nvl(vr_tab_saldos(vr_index_saldo).vlsdblpr, 0) +
                                --nvl(vr_tab_saldos(vr_index_saldo).vlsdblfp, 0) +
                                nvl(vr_tab_saldos(vr_index_saldo).vllimcre, 0) +
                                vr_vllibera,2); --Valor liberado no dia
          vr_vlsdbloque := ROUND(
                                nvl(vr_tab_saldos(vr_index_saldo).vlsdbloq, 0) +
                                nvl(vr_tab_saldos(vr_index_saldo).vlsdblpr, 0) +
                                nvl(vr_tab_saldos(vr_index_saldo).vlsdblfp, 0)
                            ,2); -- Valor bloqueado total
          vr_vlsddisptotal := nvl(pr_vlsomato, 0)  + nvl(vr_vlsdbloque,0); -- Saldo disponivel total + o bloqueado
        END IF;

        -- Somente se o contrato de empréstimo tem cobertura de operação e não há saldo
        IF nvl(pr_vlapagar, 0) > nvl(pr_vlsomato, 0) AND rw_crawepr.idcobope > 0 THEN

          -- Quando a conta estiver com estouro deve desconsiderar esse negativo
          IF nvl(pr_vlsomato, 0) <= 0 THEN
            -- Valor do resgate deve ser o valor total a pagar apenas
            vr_vlresgat := nvl(pr_vlapagar, 0);
          ELSE -- Se há algum saldo para ser consumido
            -- Deve considerar apenas o valor faltante para pagamento
            vr_vlresgat := NVL(pr_vlapagar,0) - NVL(pr_vlsomato,0);
          END IF;

          -- Acionar rotina de calculo de dias em atraso
          vr_qtdiaatr := empr0001.fn_busca_dias_atraso_epr(pr_cdcooper => pr_cdcooper
                                                          ,pr_nrdconta => pr_nrdconta
                                                          ,pr_nrctremp => pr_nrctremp
                                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                          ,pr_dtmvtoan => rw_crapdat.dtmvtoan);
          -- Acionaremos rotina para solicitar o resgate afim de cobrir os valores negativos
          BLOQ0001.pc_solici_cobertura_operacao(pr_idcobope => rw_crawepr.idcobope
                                               ,pr_flgerlog => 1
                                               ,pr_cdoperad => '1'
                                               ,pr_idorigem => 1
                                               ,pr_cdprogra => pr_nmdatela
                                               ,pr_qtdiaatr => vr_qtdiaatr
                                               ,pr_vlresgat => vr_vlresgat
                                               ,pr_flefetiv => pr_efetresg
                                               ,pr_dscritic => vr_dscritic);

          -- Em caso de erro, deve prosseguir normalmente, considerando que não há valores para resgate
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Limpar a variável de crítica
            vr_dscritic := NULL;
            -- Zerar a variável de valor de resgate
            vr_vlresgat := 0;
            -- Atribuir zero para o parametro de retorno
            pr_vlresgat := 0;
          ELSE
            -- Incrementar ao saldo o total resgatado
            pr_vlresgat := vr_vlresgat;
          END IF;
        END IF;

        --Valor a Pagar Maior Soma total
        IF nvl(pr_vlapagar, 0) > nvl(pr_vlsomato, 0) THEN
          IF pr_idorigem = 5 THEN
            /* So pra pagamento online */
            --Se encontrou operador
            IF vr_crapope THEN
              --Diferenca no valor pago
              vr_difpagto := nvl(pr_vlapagar, 0) - nvl(vr_vlsddisptotal, 0) ;
              --Valor Diferenca Maior Limite Pagamento Cheque + Saldo Bloqueado
              IF vr_difpagto > nvl(rw_crapope.vlpagchq, 0) THEN
              --Caso o saldo disponivel + bloqueado + limite + alçada não atingirem o valor do pagamento, encerra o programa
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
            -- Verifica se possui saldo bloqueado
            IF (nvl(vr_vlsdbloque,0)>0 AND (nvl(vr_vlsdbloque,0)+nvl(pr_vlsomato,0))>0) THEN
              -- Verifica se o Saldo disponivel + limite + saldo bloqueado atingem o valor do pagamento
              IF (nvl(vr_vlsddisptotal,0)>=nvl(pr_vlapagar,0)) THEN
                pr_tab_msg_confirma(vr_index_confirma).inconfir := 2;
                pr_tab_msg_confirma(vr_index_confirma).dsmensag := 'Deseja utilizar o valor do saldo bloqueado?';
              ELSE -- O valor do saldo + limite + bloqueado são menores que o valor do pagamento, porém com a alçada do operador é possível realizar o pagamento
                pr_tab_msg_confirma(vr_index_confirma).inconfir := 3;
                pr_tab_msg_confirma(vr_index_confirma).dsmensag := 'Deseja utilizar o valor do saldo bloqueado e a alcada?';
              END IF;
            ELSE
            pr_tab_msg_confirma(vr_index_confirma).inconfir := 1;
            pr_tab_msg_confirma(vr_index_confirma).dsmensag := 'Saldo em conta insuficiente para pagamento da parcela. ' ||
                                                               'Confirma pagamento?';
          END IF;

          END IF;
        END IF;

        IF pr_idorigem IN(3,5) THEN
          -- Verifica se existe contrato de acordo ativo
          RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_cdorigem => 3 /*SD#846598*/
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
            vr_dscritic := 'Contrato em acordo. Pagamento permitido somente por boleto.';
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_valida_pagamentos_geral ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_valida_pagamentos_geral;

  /* Validar pagamento Atrasado das parcelas de empréstimo */
  PROCEDURE pc_valida_pagto_atr_parcel(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                      ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                      ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                      ,pr_idorigem IN INTEGER --> Id do módulo de sistema
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                      ,pr_flgerlog IN VARCHAR2 --> Indicador S/N para geração de log
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                      ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                      ,pr_vlpagpar IN NUMBER --> Valor a pagar parcela
                                      ,pr_vlpagsld OUT NUMBER --> Valor Pago Saldo
                                      ,pr_vlatupar OUT NUMBER --> Valor Atual Parcela
                                      ,pr_vlmtapar OUT NUMBER --> Valor Multa Parcela
                                      ,pr_vljinpar OUT NUMBER --> Valor Juros parcela
                                      ,pr_vlmrapar OUT NUMBER --> Valor ???
                                      ,pr_vliofcpl OUT NUMBER --> Valor ???
                                      ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
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

       Alteracoes: 03/03/2014 - Conversão Progress para Oracle (Alisson - AMcom)

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
        empr0001.pc_calc_atraso_parcela(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                       ,pr_cdagenci => pr_cdagenci --> Código da agência
                                       ,pr_nrdcaixa => pr_nrdcaixa --> Número do caixa
                                       ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                       ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                       ,pr_idorigem => pr_idorigem --> Id do módulo de sistema
                                       ,pr_nrdconta => pr_nrdconta --> Número da conta
                                       ,pr_idseqttl => pr_idseqttl --> Seq titula
                                       ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                       ,pr_flgerlog => pr_flgerlog --> Indicador S/N para geração de log
                                       ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                       ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                       ,pr_vlpagpar => pr_vlpagpar --> Valor a pagar originalmente
                                       ,pr_vlpagsld => pr_vlpagsld --> Valor Pago Saldo
                                       ,pr_vlatupar => pr_vlatupar --> Valor parcela
                                       ,pr_vlmtapar => pr_vlmtapar --> Valor Multa
                                       ,pr_vljinpar => pr_vljinpar --> Valor Juros
                                       ,pr_vlmrapar => pr_vlmrapar --> Valor Mora
                                       ,pr_vliofcpl => pr_vliofcpl --> IOF atraso
                                       ,pr_vljinp59 => vr_vljinp59 --> Juros periodo < 59 dias
                                       ,pr_vljinp60 => vr_vljinp60 --> Juros Periodo > 60dias
                                       ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                       ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
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
                           nvl(apli0001.fn_round(pr_vliofcpl, 2), 0) +
                           nvl(apli0001.fn_round(vr_vlpagmin, 2), 0);
          ELSE
            /* Multa + jr.normais */
            vr_valormin := nvl(apli0001.fn_round(pr_vlmtapar, 2), 0) +
                           nvl(apli0001.fn_round(pr_vlmrapar, 2), 0) +
                           nvl(apli0001.fn_round(pr_vliofcpl, 2), 0) +
                           nvl(apli0001.fn_round(pr_vlatupar, 2), 0);
          END IF;
        ELSE
          /* Pagamento via tela */
          /* Multa + jr.mora + qualquer valor de pagamento */
          vr_valormin := nvl(apli0001.fn_round(pr_vlmtapar, 2), 0) +
                         nvl(apli0001.fn_round(pr_vlmrapar, 2), 0) +
                         nvl(apli0001.fn_round(pr_vliofcpl, 2), 0) + 0.01;
        END IF;
        --Valor da Parcela menor valor minimo
        IF nvl(apli0001.fn_round(pr_vlpagpar, 2), 0) < nvl(vr_valormin, 0) THEN
          ----------------------------------------------------------------------------------
          -- Projeto 302 - Sistema de Acordos - Responsável: James
          -- Incluso por: Renato Darosci - 27/09/2016
          --
          -- Realizado a fixação do código de erro para pagamento do valor mínimo. O
          -- intuíto disto é poder tratar este erro em particular na rotina chamadora,
          -- pois para o sistema de acordos, esta situação não define um erro, apenas
          -- define as parcelas que puderam ou não ser liquidadas conforme o valor do
          -- boleto pago.
          --
          -- NA CRIAÇÃO DE NOVAS CRÍTICAS QUANTO AO PAGAMENTO DO VALOR MINÍMO, O CÓDIGO
          -- DE ERRO DEVE SER INCLUSO NO PARAMETRO(CRAPPRM) "CRITICA_VLR_MIN_PARCEL", para
          -- QUE O PAGAMENTO DO ACORDO, TRATE A NOVA CRITICA DA MESMA FORMA.
          -- EM CASO DE DÚVIDAS VERIFIQUE -> RECP0001
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
            nvl(apli0001.fn_round(pr_vlmrapar, 2), 0) +
            nvl(apli0001.fn_round(pr_vliofcpl, 2), 0) ) THEN
          vr_cdcritic := 1033; -- Retorna 1033 para o job não logar a mensagem.
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_valida_pagto_atr_parcel ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_valida_pagto_atr_parcel;

  /* Validar pagamento Antecipado das parcelas de empréstimo */
  PROCEDURE pc_valida_pagto_antec_parc(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                      ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                      ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                      ,pr_idorigem IN INTEGER --> Id do módulo de sistema
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                      ,pr_flgerlog IN VARCHAR2 --> Indicador S/N para geração de log
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                      ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                      ,pr_vlpagpar IN NUMBER --> Valor a pagar parcela
                                      ,pr_vlatupar OUT NUMBER --> Valor Atual Parcela
                                      ,pr_vldespar OUT NUMBER --> Valor Desconto Parcela
                                      ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
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

       Alteracoes: 25/03/2015 - Conversão Progress para Oracle (Alisson - AMcom)

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
        vr_dscritic:= 'Contrato não encontrado.';
        --Sair
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapepr;
      END IF;

      -- Procedure para calcular valor antecipado de parcelas de empréstimo
      empr0001.pc_calc_antecipa_parcela(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                       ,pr_cdagenci => pr_cdagenci         --> Código da agência
                                       ,pr_nrdcaixa => pr_nrdcaixa         --> Número do caixa
                                       ,pr_dtvencto => rw_crappep.dtvencto --> Data do vencimento
                                       ,pr_vlsdvpar => rw_crappep.vlsdvpar --> Valor devido parcela
                                       ,pr_txmensal => rw_crapepr.txmensal --> Taxa aplicada ao empréstimo
                                       ,pr_dtmvtolt => pr_dtmvtolt         --> Data do movimento atual
                                       ,pr_dtdpagto => rw_crapepr.dtdpagto --> Data de pagamento
                                       ,pr_vlatupar => pr_vlatupar         --> Valor atualizado da parcela
                                       ,pr_vldespar => pr_vldespar         --> Valor desconto da parcela
                                       ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                       ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
      -- Testar erro
      IF vr_des_reto = 'NOK' THEN
        -- Levantar exceção
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_valida_pagto_antec_parc ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE --> Numero banco/caixa
                                    ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                    ,pr_cdpactra IN INTEGER --> P.A. da transação
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                    ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                    ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                    ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                    ,pr_inproces IN crapdat.inproces%TYPE --> Indicador Processo
                                    ,pr_cdorigem IN NUMBER DEFAULT 0 --> Origem do Movimento
                                    ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................

       Programa: pc_grava_liquidacao_empr                 Antigo: b1wgen0136.p/grava_liquidacao_empr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 07/12/2017

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para verificar liquidacao emprestimo

       Alteracoes: 03/03/2014 - Conversão Progress para Oracle (Alisson - AMcom)

                   16/06/2014 - Adicionado o parametro nrseqava na prodecure
                                "pc_cria_lancamento_lem". (James)

                   08/10/2015 - Incluir os históricos de estorno do PP. (0scar)

                   20/10/2015 - Incluir os históricos de ajuste o contrato
                                liquidado pode ser reaberto (Oscar).

                   07/12/2017 - Remover possiveis bloqueios de garantia de cobertura
                                da operacao. (Jaison/Marcos Martini - PRJ404)

                   20/12/2017 - Inclusão de novos históricos: 2013 e 2014, Prj.402
                                (Jean Michel).

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
                         ,craplem.vllanmto * -1
                         ,2013
                         ,craplem.vllanmto * -1
                         ,2014
                         ,craplem.vllanmto * -1
                         ,2304
                         ,craplem.vllanmto * -1
                         ,2305
                         ,craplem.vllanmto * -1
                         ,2306
                         ,craplem.vllanmto * -1
                         ,2307
                         ,craplem.vllanmto * -1
                         ,2535
                         ,craplem.vllanmto * -1
                         ,2536
                         ,craplem.vllanmto * -1
                         ,2591
                         ,craplem.vllanmto * -1
                         ,2592
                         ,craplem.vllanmto * -1
                         ,2593
                         ,craplem.vllanmto * -1
                         ,2594
                         ,craplem.vllanmto * -1
                         ,2597
                         ,craplem.vllanmto * -1
                         ,2598
                         ,craplem.vllanmto * -1
                         ,2599
                         ,craplem.vllanmto * -1
                         ,2600
                         ,craplem.vllanmto * -1
                         ,2601
                         ,craplem.vllanmto * -1
                         ,2602
                         ,craplem.vllanmto * -1
                         ,2603
                         ,craplem.vllanmto * -1
                         ,2604
                         ,craplem.vllanmto * -1
                         ,2605
                         ,craplem.vllanmto * -1
                         ,2606
                         ,craplem.vllanmto * -1))
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor IN
           (1044, 1039, 1045, 1046, 1057, 1058, 1036, 1059,
            1037, 1038, 1716, 1707, 1714, 1705, 1040, 1041,
            1042, 1043, 2013, 2014, 1036, 2305, 2304, 2536, 2535,
            2306, 2597, 2598, 2307, 2599, 2600, 2601, 2602,
            2591, 2592, 2593, 2594, 2603, 2604, 2605, 2606);

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
        SAVEPOINT savtrans_grava_liquidacao_empr;

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
        --Verificar se jah está liquidado
        pc_verifica_liquidacao_empr(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                   ,pr_cdagenci => pr_cdagenci --> Código da agência
                                   ,pr_nrdcaixa => pr_nrdcaixa --> Número do caixa
                                   ,pr_nrdconta => pr_nrdconta --> Número da conta
                                   ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                   ,pr_flgliqui => vr_flgliqui --> Liquidado
                                   ,pr_flgopera => vr_flgopera --> Financiamento
                                   ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                   ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
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

        -- Busca dos detalhes do empréstimo
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
        FETCH cr_crapepr
          INTO rw_crapepr;
        -- Se não encontrar informações
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

        -- Busca dos detalhes da proposta de empréstimo
        OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
        FETCH cr_crawepr INTO rw_crawepr;
        -- Se não encontrar informações
        IF cr_crawepr%NOTFOUND THEN
          -- Fechar o cursor pois teremos raise
          CLOSE cr_crawepr;
          -- Gerar erro com critica 535
          vr_cdcritic := 535;
          vr_dscritic := gene0001.fn_busca_critica(535);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor para continuar o processo
          CLOSE cr_crawepr;
        END IF;

        --Zerar lancamentos a debito/credito
        vr_vllancre := 0;
        vr_vllandeb := 0;

        /* Contabilizar creditos  */
        /*  OPEN cr_craplem(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
        FETCH cr_craplem
          INTO vr_vlsdeved;
        --Fechar Cursor
        CLOSE cr_craplem;*/

        -- M324, buscar do cursor publico, este sera utilizado no
        -- PREJ0001.
        /* Contabilizar creditos  */
        OPEN cr_craplem_sld(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
        FETCH cr_craplem_sld
          INTO vr_vlsdeved;
        --Fechar Cursor
        CLOSE cr_craplem_sld;

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
                                ,pr_cdorigem => pr_cdorigem -- Origem do Lançamento
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
        -- Não era tratada o retorno de erro no Progress
        ----Se ocorreu erro
        --IF vr_des_erro <> 'OK' THEN
        --  RAISE vr_exc_saida;
        --END IF;

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

        -- Se possui cobertura vinculada
        IF rw_crawepr.idcobope > 0 THEN
          -- Chama bloqueio/desbloqueio da garantia
          BLOQ0001.pc_bloq_desbloq_cob_operacao(pr_idcobertura    => rw_crawepr.idcobope
                                               ,pr_inbloq_desbloq => 'D'
                                               ,pr_cdoperador     => '1'
                                               ,pr_vldesbloq      => 0
                                               ,pr_flgerar_log    => 'S'
                                               ,pr_dscritic       => vr_dscritic);
          -- Se houve erro
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
        END IF;
        END IF;

        --Marcar que a transacao ocorreu
        vr_flgtrans := TRUE;
      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT savtrans_grava_liquidacao_empr;
      END;

      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_grava_liquidacao_empr ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                         ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                         ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                         ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                         ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                         ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                         ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                         ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                         ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                         ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                         ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                         ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                         ,pr_nrparepr    IN INTEGER --> Número parcelas empréstimo
                                         ,pr_vlpagpar    IN NUMBER --> Valor da parcela emprestimo
                                         ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                         ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                         ,pr_vlpagsld    OUT NUMBER --> Valor Pago Saldo
                                         ,pr_vlrmulta    OUT NUMBER --> Valor Multa
                                         ,pr_vlatraso    OUT NUMBER --> Valor Atraso
                                         ,pr_vliofcpl    OUT NUMBER --> valor do IOF complementar atraso
                                         ,pr_cdhismul    OUT INTEGER --> Historico Multa
                                         ,pr_cdhisatr    OUT INTEGER --> Historico Atraso
                                         ,pr_cdhisiof    OUT INTEGER
                                         ,pr_cdhispag    OUT INTEGER --> Historico Pagamento
                                         ,pr_loteatra    OUT INTEGER --> Lote Atraso
                                         ,pr_lotemult    OUT INTEGER --> Lote Multa
                                         ,pr_lotepaga    OUT INTEGER --> Lote Pagamento
                                         ,pr_loteiof     OUT INTEGER
                                         ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                         ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
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

       Alteracoes: 04/03/2014 - Conversão Progress para Oracle (Alisson - AMcom)

                   16/06/2014 - Adicionado o parametro nrseqava na prodecure
                                "pc_cria_lancamento_lem". (James)

                   16/10/2015 - Zerar o campo vlsdvsji quando liquidar a parcela PP (Oscar)

                   17/03/2016 - Limpar campos de saldo ai liquidar crappep SD366229 (Odirlei-AMcom)

                   31/10/2016 - Validação dentro para identificar
                                parcelas ja liquidadas (AJFink - SD#545719)

    ............................................................................. */

    DECLARE

      vr_vlatupar NUMBER;
      vr_vlmtapar NUMBER;
      vr_vljinpar NUMBER;
      vr_vlmrapar NUMBER;
      vr_vliofcpl NUMBER;
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
      vr_nrseqdig INTEGER;

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
                                ,pr_cdagenci => pr_cdagenci --> Código da agência
                                ,pr_nrdcaixa => pr_nrdcaixa --> Número do caixa
                                ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                ,pr_idorigem => pr_idorigem --> Id do módulo de sistema
                                ,pr_nrdconta => pr_nrdconta --> Número da conta
                                ,pr_idseqttl => pr_idseqttl --> Seq titula
                                ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                ,pr_flgerlog => pr_flgerlog --> Indicador S/N para geração de log
                                ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                ,pr_vlpagpar => pr_vlpagpar --> Valor a pagar parcela
                                ,pr_vlpagsld => pr_vlpagsld --> Valor Pago Saldo
                                ,pr_vlatupar => vr_vlatupar --> Valor Atual Parcela
                                ,pr_vlmtapar => vr_vlmtapar --> Valor Multa Parcela
                                ,pr_vljinpar => vr_vljinpar --> Valor Juros parcela
                                ,pr_vlmrapar => vr_vlmrapar --> Valor Mora
                                ,pr_vliofcpl => vr_vliofcpl --> Valor Mora
                                ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
      --Se ocorreu erro
      IF vr_des_erro <> 'OK' THEN
        pr_des_reto := 'NOK';
        --Sair
        RETURN;
      END IF;

      BEGIN
        --Criar savepoint para desfazer transacao
        SAVEPOINT sav_efetiva_pag_atr_parcel_lem;

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

        --SD#545719 inicio
        IF rw_crappep.inliquid = 1 THEN
          -- Atribui críticas
          vr_cdcritic := 0;
          vr_dscritic := 'Parcela ja liquidada.';
          -- Gera exceção
          RAISE vr_exc_saida;
        END IF;
        --SD#545719 fim

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
          --Determinar se a Operacao é financiamento
          vr_floperac := rw_craplcr.dsoperac = 'FINANCIAMENTO';
        END IF;
        --Fechar Cursor
        CLOSE cr_craplcr;

        --Valor A pagar
        vr_vlpagpar := pr_vlpagsld;
        --Taxa Diaria
        vr_txdiaria := rw_crapepr.txjuremp;

        --Lancar Juros Contrato
        empr0001.pc_lanca_juro_contrato(pr_cdcooper    => pr_cdcooper --Codigo Cooperativa
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

        /* Pagamento de IOF de atraso */
        IF nvl(vr_vliofcpl, 0) > 0
           AND nvl(vr_vlpagpar, 0) >= 0 THEN
          IF vr_floperac THEN
            /* Financiamento */
            vr_nrdolote := 600023;
          ELSE
            vr_nrdolote := 600022; /* Emprestimo */
          END IF;

          -- Condicao para verificar se o pagamento foi feito por aval
          IF vr_floperac THEN
            /* Financiamento */
              vr_cdhistor := 2312;
          ELSE
              /* Emprestimo */
              vr_cdhistor := 2311;
          END IF;

          /* Cria lancamento craplem e atualiza o seu lote */
          pc_cria_lancamento_lem_chave(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
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
                                      ,pr_vllanmto => vr_vliofcpl --Valor Mora Parcela
                                ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                                ,pr_txjurepr => rw_crapepr.txjuremp --Taxa Juros Emprestimo
                                ,pr_vlpreemp => rw_crappep.vlparepr --Valor Emprestimo
                                ,pr_nrsequni => rw_crappep.nrparepr --Numero Sequencia
                                ,pr_nrparepr => rw_crappep.nrparepr --Numero Parcelas Emprestimo
                                ,pr_flgincre => TRUE --Indicador Credito
                                ,pr_flgcredi => TRUE --Credito
                                      ,pr_nrseqava => pr_nrseqava --Pagamento: Sequencia do avalista
                                      ,pr_nrseqdig => vr_nrseqdig --Pagamento: Sequencia do avalista
                                ,pr_cdorigem => pr_idorigem
                                ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                ,pr_dscritic => vr_dscritic); --Descricao Erro
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL
             OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- historico para lancar na LCM
          IF vr_floperac THEN
              /* Financiamento */
              vr_cdhistor := 2314;
          ELSE
              /* Emprestimo */
              vr_cdhistor := 2313;
          END IF;

          --Valor Atraso recebe Valor da Mora + IOF cpl
          pr_vliofcpl := nvl(vr_vliofcpl,0);
          --Historico IOF
          pr_cdhisiof := vr_cdhistor;
          --Lote IOF
          pr_loteiof  := vr_nrdolote;

          /* Atualizar o valor pago de iof na parcela */
          BEGIN
            UPDATE crappep
               SET crappep.vlpagiof = nvl(crappep.vlpagiof, 0) +
                                      nvl(vr_vliofcpl, 0)
             WHERE crappep.rowid = rw_crappep.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar crappep. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;

          tiof0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                                 , pr_nrdconta     => pr_nrdconta
                                 , pr_dtmvtolt     => pr_dtmvtolt
                                 , pr_tpproduto    => 1 -- Emprestimo
                                 , pr_nrcontrato   => pr_nrctremp
                                 , pr_idlautom     => null
                                 , pr_dtmvtolt_lcm => pr_dtmvtolt
                                 , pr_cdagenci_lcm => pr_cdpactra
                                 , pr_cdbccxlt_lcm => 100
                                 , pr_nrdolote_lcm => pr_loteiof
                                 , pr_nrseqdig_lcm => vr_nrseqdig
                                 , pr_vliofpri     => 0
                                 , pr_vliofadi     => 0
                                 , pr_vliofcpl     => vr_vliofcpl
                                 , pr_flgimune     => 0
                                 , pr_cdcritic     => vr_cdcritic
                                 , pr_dscritic     => vr_dscritic);

            if vr_dscritic is not null then
               RAISE vr_exc_saida;
            end if;
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

          --Determinar se está liquidado
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
                         nvl(vr_vlmrapar, 0) + nvl(vr_vliofcpl, 0);

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
        empr0001.pc_grava_liquidacao_empr(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
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
          ROLLBACK TO SAVEPOINT sav_efetiva_pag_atr_parcel_lem;
      END;

      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_efetiva_pag_atr_parcel_lem ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_efetiva_pag_atr_parcel_lem;

  /* Busca dos pagamentos das parcelas de empréstimo */
  PROCEDURE pc_efetiva_pagto_atr_parcel(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                       ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                       ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                       ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                       ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                       ,pr_nrparepr    IN INTEGER --> Número parcelas empréstimo
                                       ,pr_vlpagpar    IN NUMBER --> Valor a pagar parcela
                                       ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                       ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                       ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................

       Programa: pc_efetiva_pag_atr_parcel                 Antigo: b1wgen0084a.p/efetiva_pagamento_atrasado_parcela
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 27/12/2018

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para efetivar pagamento parcela atrasada

       Alteracoes: 28/02/2014 - Conversão Progress para Oracle (Alisson - AMcom)

                   11/10/2018 - Ajustado rotina para caso pagamento for pago pela tela
                                BLQ gerar o IOF na tabela prejuizo detalhe.
                                PRJ450 - Regulatorio(Odirlei-AMcom)

                   27/12/2018 - Ajuste no tratamento de contas corrente em prejuízo (substituição
                                da verificação através do parâmetro "pr_nmdatela" pelo uso da
                                função de verificação do prejuízo de conta corrente).
                                P450 - Reginaldo/AMcom

    ............................................................................. */

    DECLARE

      --Variaveis Locais
      vr_vlrmulta NUMBER;
      vr_vlatraso NUMBER;
      vr_cdhismul NUMBER;
      vr_cdhisatr NUMBER;
      vr_cdhispag NUMBER;
      vr_cdhisiof NUMBER;
      vr_cdhisiof_prejdet NUMBER := 0;
      vr_loteatra NUMBER;
      vr_lotemult NUMBER;
      vr_lotepaga NUMBER;
      vr_loteiof NUMBER;
      vr_flgtrans BOOLEAN;
      vr_vlpagsld NUMBER;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      vr_vliofcpl NUMBER;
      vr_nrseqdig INTEGER;

      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);

      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_exc_ok    EXCEPTION;

      vr_prejuzcc BOOLEAN; -- Indicador de conta corrente em prejuízo

      -- Retorna as contas em prejuizo
      CURSOR cr_contaprej (pr_cdcooper  IN tbcc_prejuizo.cdcooper%TYPE
                         , pr_nrdconta  IN tbcc_prejuizo.nrdconta%TYPE) IS
        SELECT tbprj.idprejuizo
          FROM tbcc_prejuizo tbprj
         WHERE tbprj.cdcooper = pr_cdcooper
           AND tbprj.nrdconta = pr_nrdconta
           AND tbprj.dtliquidacao IS NULL;
       rw_contaprej cr_contaprej%ROWTYPE;



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
        SAVEPOINT sav_efetiva_pagto_atr_parcel;

        --Efetivar Pagamento Normal parcela na craplem
        empr0001.pc_efetiva_pag_atr_parcel_lem(pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                              ,pr_cdagenci    => pr_cdagenci --> Código da agência
                                              ,pr_nrdcaixa    => pr_nrdcaixa --> Número do caixa
                                              ,pr_cdoperad    => pr_cdoperad --> Código do Operador
                                              ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                              ,pr_idorigem    => pr_idorigem --> Id do módulo de sistema
                                              ,pr_cdpactra    => pr_cdpactra --> P.A. da transação
                                              ,pr_nrdconta    => pr_nrdconta --> Número da conta
                                              ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                              ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                              ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para geração de log
                                              ,pr_nrctremp    => pr_nrctremp --> Número do contrato de empréstimo
                                              ,pr_nrparepr    => pr_nrparepr --> Número parcelas empréstimo
                                              ,pr_vlpagpar    => pr_vlpagpar --> Valor da parcela emprestimo
                                              ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                              ,pr_nrseqava    => pr_nrseqava --Pagamento: Sequencia do avalista
                                              ,pr_vlpagsld    => vr_vlpagsld --> Valor Pago Saldo
                                              ,pr_vlrmulta    => vr_vlrmulta --> Valor Multa
                                              ,pr_vlatraso    => vr_vlatraso --> Valor Atraso
                                              ,pr_vliofcpl    => vr_vliofcpl --> Valor IOF complementar atraso
                                              ,pr_cdhismul    => vr_cdhismul --> Historico Multa
                                              ,pr_cdhisatr    => vr_cdhisatr --> Historico Atraso
                                              ,pr_cdhisiof    => vr_cdhisiof --> Historico IOF complementar
                                              ,pr_cdhispag    => vr_cdhispag --> Historico Pagamento
                                              ,pr_loteatra    => vr_loteatra --> Lote Atraso
                                              ,pr_lotemult    => vr_lotemult --> Lote Multa
                                              ,pr_lotepaga    => vr_lotepaga --> Lote Pagamento
                                              ,pr_loteiof     => vr_loteiof  --> Lote IOF complementar
                                              ,pr_des_reto    => vr_des_erro --> Retorno OK / NOK
                                              ,pr_tab_erro    => pr_tab_erro); --> Tabela com possíves erros

        --Se Retornou erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se a conta corrente está em prejuízo - Reginaldo/AMcom
        vr_prejuzcc := PREJ0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper
                                                       ,pr_nrdconta => pr_nrdconta);

        /* Valor da multa */
        IF nvl(vr_vlrmulta, 0) > 0 AND NOT vr_prejuzcc THEN
          /* Lanca em C/C e atualiza o lote */
          empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci --> Código da agência
                                        ,pr_cdbccxlt => 100 --> Número do caixa
                                        ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                        ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                        ,pr_nrdolote => vr_lotemult --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta --> Número da conta
                                        ,pr_cdhistor => vr_cdhismul --> Codigo historico
                                        ,pr_vllanmto => vr_vlrmulta --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                        ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                        ,pr_nrseqava => pr_nrseqava -- Pagamento: Sequencia do avalista
                                        ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                        ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
          --Se Retornou erro
          IF vr_des_erro <> 'OK' THEN
            --Sair
            RAISE vr_exc_ok;
          END IF;
        END IF;

        /* Pagamento de juros de mora */
        IF nvl(vr_vlatraso, 0) > 0
           AND nvl(vr_vlpagsld, 0) >= 0 AND NOT vr_prejuzcc THEN
          /* Debita o pagamento da parcela da C/C */
          empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci --> Código da agência
                                        ,pr_cdbccxlt => 100 --> Número do caixa
                                        ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                        ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                        ,pr_nrdolote => vr_loteatra --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta --> Número da conta
                                        ,pr_cdhistor => vr_cdhisatr --> Codigo historico
                                        ,pr_vllanmto => vr_vlatraso --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                        ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                        ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                        ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                        ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
          --Se Retornou erro
          IF vr_des_erro <> 'OK' THEN
            --Sair
            RAISE vr_exc_ok;
          END IF;
        END IF;

        /* Projeto 410 - efetua o debito do IOF complementar de atraso */
        IF nvl(vr_vliofcpl, 0) > 0
           AND nvl(vr_vlpagsld, 0) >= 0 THEN

          IF vr_prejuzcc THEN

            -- Identificar numero do prejuizo da conta
            OPEN cr_contaprej(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta);
            FETCH cr_contaprej INTO rw_contaprej;
            CLOSE cr_contaprej;

            CASE vr_cdhisiof
              WHEN 2314 THEN vr_cdhisiof_prejdet := 2792; --> IOF S/ FINANC
              --> 2313
              ELSE vr_cdhisiof_prejdet := 2791; --> IOF S/EMPREST
            END CASE;

            -- Incluir lançamento na TBCC_PREJUIZO_DETALHE
            PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => pr_cdcooper
                                            , pr_nrdconta   => pr_nrdconta
                                            , pr_dtmvtolt   => pr_dtmvtolt
                                            , pr_cdhistor   => vr_cdhisiof_prejdet
                                            , pr_idprejuizo => rw_contaprej.idprejuizo
                                            , pr_vllanmto   => vr_vliofcpl
                                            , pr_nrctremp   => pr_nrctremp
                                            , pr_cdoperad   => pr_cdoperad
                                            , pr_cdcritic   => vr_cdcritic
                                            , pr_dscritic   => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_ok;
            END IF;
          ELSE

            /* Debita o valor do IOF complementar atraso da C/C */
            empr0001.pc_cria_lancamento_cc_chave(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci --> Código da agência
                                        ,pr_cdbccxlt => 100 --> Número do caixa
                                        ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                        ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                        ,pr_nrdolote => vr_loteiof  --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta --> Número da conta
                                        ,pr_cdhistor => vr_cdhisiof --> Codigo historico
                                        ,pr_vllanmto => vr_vliofcpl --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                        ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                        ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                        ,pr_nrseqdig => vr_nrseqdig
                                        ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                        ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_ok;
            END IF;
          END IF;

        END IF;

        /* Lancamento de Valor Pago da Parcela */
        IF nvl(vr_vlpagsld, 0) > 0 AND NOT vr_prejuzcc THEN
          /* Debita o pagamento da parcela da C/C */
          empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci --> Código da agência
                                        ,pr_cdbccxlt => 100 --> Número do caixa
                                        ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                        ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                        ,pr_nrdolote => vr_lotepaga --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta --> Número da conta
                                        ,pr_cdhistor => vr_cdhispag --> Codigo historico
                                        ,pr_vllanmto => vr_vlpagsld --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                        ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                        ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                        ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                        ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
          --Se Retornou erro
          IF vr_des_erro <> 'OK' THEN
            --Sair
            RAISE vr_exc_ok;
          END IF;
        END IF;

          --Marcar transacao como realizada
          vr_flgtrans := TRUE;
      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT sav_efetiva_pagto_atr_parcel;
        WHEN vr_exc_ok THEN
          NULL;
      END;

      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_efetiva_pagto_atr_parcel ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_efetiva_pagto_atr_parcel;

  /* Efetivar Pagamento Antecipado das parcelas de empréstimo */
  PROCEDURE pc_efetiva_pagto_antec_lem (pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_nmdatela    IN VARCHAR2              --> Nome da tela
                                       ,pr_idorigem    IN INTEGER               --> Id do módulo de sistema
                                       ,pr_cdpactra    IN INTEGER               --> P.A. da transação
                                       ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para geração de log
                                       ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                       ,pr_nrparepr    IN INTEGER               --> Número parcelas empréstimo
                                       ,pr_vlpagpar    IN NUMBER                --> Valor a pagar parcela
                                       ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                       ,pr_nrseqava    IN NUMBER DEFAULT 0       --> Pagamento: Sequencia do avalista
                                       ,pr_cdhistor    OUT craphis.cdhistor%TYPE --> Historico Pagamento
                                       ,pr_nrdolote    OUT craplot.nrdolote%TYPE --> Numero Lote Pagamento
                                       ,pr_des_reto    OUT VARCHAR               --> Retorno OK / NOK
                                       ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
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

       Alteracoes: 01/04/2015 - Conversão Progress para Oracle (Alisson - AMcom)

                   16/10/2015 - Zerar o campo vlsdvsji quando liquidar a parcela PP (Oscar)

                   17/03/2016 - Limpar campos de saldo ai liquidar crappep SD366229 (Odirlei-AMcom)

                   31/10/2016 - Validação dentro para identificar
                                parcelas ja liquidadas (AJFink - SD#545719)

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
      empr0001.pc_valida_pagto_antec_parc   (pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                            ,pr_cdagenci => pr_cdagenci --> Código da agência
                                            ,pr_nrdcaixa => pr_nrdcaixa --> Número do caixa
                                            ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                            ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                            ,pr_idorigem => pr_idorigem --> Id do módulo de sistema
                                            ,pr_nrdconta => pr_nrdconta --> Número da conta
                                            ,pr_idseqttl => pr_idseqttl --> Seq titula
                                            ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                            ,pr_flgerlog => pr_flgerlog --> Indicador S/N para geração de log
                                            ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                            ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                            ,pr_vlpagpar => pr_vlpagpar --> Valor da parcela emprestimo
                                            ,pr_vlatupar => vr_vlatupar--> Valor Atual Parcela
                                            ,pr_vldespar => vr_vldespar --> Valor Desconto Parcela
                                            ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                            ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
      --Se Retornou erro
      IF vr_des_erro <> 'OK' THEN
        --Sair
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        --Criar savepoint para desfazer transacao
        SAVEPOINT sav_efetiva_pagto_antec_lem;

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

        --SD#545719 inicio
        IF rw_crappep.inliquid = 1 THEN
          -- Atribui críticas
          vr_cdcritic := 0;
          vr_dscritic := 'Parcela ja liquidada..';
          -- Gera exceção
          RAISE vr_exc_saida;
        END IF;
        --SD#545719 fim

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
          vr_dscritic:= 'Contrato não encontrado.';
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
          vr_dscritic:= 'Linha Credito não encontrada.';
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
        empr0001.pc_lanca_juro_contrato(pr_cdcooper    => pr_cdcooper --Codigo Cooperativa
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
                                    ,pr_txmensal => rw_crapepr.txmensal --> Taxa aplicada ao empréstimo
                                    ,pr_dtmvtolt => pr_dtmvtolt         --> Data do movimento atual
                                    ,pr_vlpagpar => pr_vlpagpar         --> Valor devido parcela
                                    ,pr_dtdpagto => rw_crapepr.dtdpagto --> Data de pagamento
                                    ,pr_vldespar => vr_vldespar         --> Valor desconto da parcela
                                    ,pr_des_reto => vr_des_erro         --> Retorno OK / NOK
                                    ,pr_tab_erro => pr_tab_erro);       --> Tabela com possíves e
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
        empr0001.pc_grava_liquidacao_empr(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
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
          ROLLBACK TO SAVEPOINT sav_efetiva_pagto_antec_lem;
      END;

      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_efetiva_pagto_antec_lem ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                         ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                         ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                         ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
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

       Alteracoes: 27/02/2014 - Conversão Progress para Oracle (Alisson - AMcom)

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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na empr0001.pc_verifica_parcel_anteriores ' ||
                       sqlerrm;
    END;
  END pc_verifica_parcel_anteriores;

  /* Valida o pagamento normal da parcela */
  PROCEDURE pc_valida_pagto_normal_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                          ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                          ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                          ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                          ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                          ,pr_idorigem IN INTEGER --> Id do módulo de sistema
                                          ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                          ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                          ,pr_flgerlog IN VARCHAR2 --> Indicador S/N para geração de log
                                          ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                          ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                          ,pr_vlpagpar IN NUMBER --> Valor a pagar da parcela
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro --> Tabela com possíves erros
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

     Alteracoes: 13/05/2014 - Conversão Progress para Oracle (James)
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
        -- Se não encontrar
        IF cr_crappep%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crappep;
          -- MOntar descrição de erro
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
            -- Gerar rotina de gravação de erro
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
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_valida_pagamento_normal_parcela ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                     ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                     ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                     ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                     ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                     ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                     ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                     ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                     ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                     ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                     ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                     ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                     ,pr_nrparepr    IN INTEGER --> Número parcelas empréstimo
                                     ,pr_vlparepr    IN NUMBER --> Valor da parcela emprestimo
                                     ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                     ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                     ,pr_cdhistor    OUT craphis.cdhistor%TYPE --> Codigo historico
                                     ,pr_nrdolote    OUT craplot.nrdolote%TYPE --> Numero do Lote
                                     ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                     ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
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

       Alteracoes: 28/02/2014 - Conversão Progress para Oracle (Alisson - AMcom)

                   13/05/2014 - Ajuste para chamar a procedure
                                "pc_valida_pagamento_normal_parcela". (James)

                   16/10/2015 - Zerar o campo vlsdvsji quando liquidar a parcela PP (Oscar)

                   31/10/2016 - Validação dentro para identificar
                                parcelas ja liquidadas (AJFink - SD#545719)


                   25/04/2017 - na rotina pc_efetiva_pagto_parc_lem retornar valor pro
                                rowtype da crapepr na hora do update qdo cai na validacao
                                do vr_ehmensal pois qdo ia atualizar o valor novamente
                                a crapepr estava ficando com valor incorreto
                                (Tiago/Thiago SD644598).
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
        SAVEPOINT sav_efetiva_pagto_parc_lem;

        -- Procedure para validar se a parcela esta OK.
        empr0001.pc_valida_pagto_normal_parcela(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa
                                               ,pr_cdagenci => pr_cdagenci -- Codigo Agencia
                                               ,pr_nrdcaixa => pr_nrdcaixa -- Codigo Caixa
                                               ,pr_cdoperad => pr_cdoperad -- Operador
                                               ,pr_nmdatela => pr_nmdatela -- Nome da Tela
                                               ,pr_idorigem => pr_idorigem -- Origem
                                               ,pr_nrdconta => pr_nrdconta -- Numero da Conta
                                               ,pr_idseqttl => pr_idseqttl -- Seq Titular
                                               ,pr_dtmvtolt => pr_dtmvtolt -- Data Emprestimo
                                               ,pr_flgerlog => pr_flgerlog -- Indicador S/N para geração de log
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

        --SD#545719 inicio
        IF rw_crappep.inliquid = 1 THEN
          -- Atribui críticas
          vr_cdcritic := 0;
          vr_dscritic := 'Parcela ja liquidada...';
          -- Gera exceção
          RAISE vr_exc_saida;
        END IF;
        --SD#545719 fim

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
          --Determinar se a Operacao é financiamento
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
             WHERE crapepr.ROWID = rw_crapepr.rowid
             RETURNING crapepr.vlsdeved INTO rw_crapepr.vlsdeved;
          EXCEPTION
            WHEN OTHERS THEN
              --Mensagem erro
              vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;

        --Lancar Juro Contrato
        empr0001.pc_lanca_juro_contrato(pr_cdcooper    => pr_cdcooper --Codigo Cooperativa
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
        --Se a parcela está liquidada
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
        empr0001.pc_grava_liquidacao_empr(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                         ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                                         ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                         ,pr_cdbccxlt => 100  --banco/Caixa
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
          ROLLBACK TO SAVEPOINT sav_efetiva_pagto_parc_lem;
      END;

      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_efetiva_pagto_parc_lem ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                    ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                    ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                    ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                    ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                    ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                    ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                    ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                    ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                    ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                    ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                    ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                    ,pr_nrparepr    IN INTEGER --> Número parcelas empréstimo
                                    ,pr_vlparepr    IN NUMBER --> Valor da parcela emprestimo
                                    ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                    ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                    ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................

       Programa: pc_efetiva_pagto_parcela                 Antigo: b1wgen0084a.p/efetiva_pagamento_normal_parcela
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Fevereiro/2014                        Ultima atualizacao: 27/12/2018

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetivar o pagamento da parcela

       Alteracoes: 28/02/2014 - Conversão Progress para Oracle (Alisson - AMcom)

                   27/12/2018 - Ajuste no tratamento de contas corrente em prejuízo (substituição
                                da verificação através do parâmetro "pr_nmdatela" pelo uso da
                                função de verificação do prejuízo de conta corrente).
                                P450 - Reginaldo/AMcom

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

      vr_prejuzcc BOOLEAN; -- Indicador de conta corrente em prejuízo

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
        SAVEPOINT savtrans_efetiva_pagto_parcela;
        --Efetivar Pagamento Normal parcela na craplem
        empr0001.pc_efetiva_pagto_parc_lem(pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                          ,pr_cdagenci    => pr_cdagenci --> Código da agência
                                          ,pr_nrdcaixa    => pr_nrdcaixa --> Número do caixa
                                          ,pr_cdoperad    => pr_cdoperad --> Código do Operador
                                          ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                          ,pr_idorigem    => pr_idorigem --> Id do módulo de sistema
                                          ,pr_cdpactra    => pr_cdpactra --> P.A. da transação
                                          ,pr_nrdconta    => pr_nrdconta --> Número da conta
                                          ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                          ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                          ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para geração de log
                                          ,pr_nrctremp    => pr_nrctremp --> Número do contrato de empréstimo
                                          ,pr_nrparepr    => pr_nrparepr --> Número parcelas empréstimo
                                          ,pr_vlparepr    => pr_vlparepr --> Valor da parcela emprestimo
                                          ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                          ,pr_nrseqava    => pr_nrseqava --> Pagamento: Sequencia do avalista
                                          ,pr_cdhistor    => vr_cdhistor --> Codigo historico
                                          ,pr_nrdolote    => vr_nrdolote --> Numero do Lote
                                          ,pr_des_reto    => vr_des_erro --> Retorno OK / NOK
                                          ,pr_tab_erro    => pr_tab_erro); --> Tabela com possíves erros
        --Se Retornou erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;

    -- Verifica se a conta corrente está em prejuízo
    vr_prejuzcc:= PREJ0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);

    IF NOT vr_prejuzcc THEN

        /* Lanca em C/C e atualiza o lote */
        empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci --> Código da agência
                                      ,pr_cdbccxlt => 100 --> Número do caixa
                                      ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                      ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                      ,pr_nrdolote => vr_nrdolote --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta --> Número da conta
                                      ,pr_cdhistor => vr_cdhistor --> Codigo historico
                                      ,pr_vllanmto => pr_vlparepr --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                      ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                      ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                      ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                      ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
        --Se Retornou erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
      END IF;

        --Marcar que ocorreu transacao
        vr_flgtrans := TRUE;

      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT savtrans_efetiva_pagto_parcela;
      END;

      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_efetiva_pagto_parcela ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_efetiva_pagto_parcela;

  -- Rotina para consultar antecipação parcelas emprestimo
  PROCEDURE pc_consulta_antecipacao(pr_nrdconta IN crapass.nrdconta%TYPE --> Codigo do Produto
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Codigo do Produto
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
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

    Objetivo  : Rotina para consultar antecipação parcelas emprestimo.
    Observacao: -----

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
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

      -- variaveis com as informações recebidas via xml
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

      -- Extrair informações do xml recebido por parametro
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      --Busca parcelas antecipadas
      FOR rw_craplem IN cr_craplem(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp) LOOP
        -- incluir tags com as informações das parcelas
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

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                       pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Produtos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
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
                                   ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
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

    Alteracoes: 13/08/2015 - Incluida validação para os históricos 100,800,900 e 850.
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

      vr_xml       CLOB; --> CLOB com conteudo do XML do relatório
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
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- variaveis para extrair os valores das listas recebidas como parametro
      vr_nrparepr VARCHAR2(100);
      vr_dtvencto VARCHAR2(100);
      vr_dtpagemp VARCHAR2(100);
      vr_vllanmto NUMBER;

      -- Variável de críticas
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(10000);
      vr_des_reto  VARCHAR2(10);
      vr_typ_saida VARCHAR2(3);
      vr_tab_erro  gene0001.typ_tab_erro;
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN

      vr_auxqtd := 0;
      -- extrair informações do xml
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
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
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
      -- Se não encontrar
      IF cr_crapope%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapope;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapope;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Inicializar XML do relatório
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

      -- Somente se o CLOB contiver informações
      IF dbms_lob.getlength(vr_xml) > 0 THEN

        -- Busca do diretório base da cooperativa para PDF
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => vr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

        -- Definir nome do relatorio
        vr_nmarqimp := 'crrl684_' || pr_nrdconta || '_' || pr_nrctremp ||
                       '.pdf';

        -- Solicitar geração do relatorio
        gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper --> Cooperativa conectada
                                   ,pr_cdprogra  => 'ATENDA' --> Programa chamador
                                   ,pr_dtmvtolt  => SYSDATE --> Data do movimento atual
                                   ,pr_dsxml     => vr_xml --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/antecipacao' --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl684.jasper' --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_nom_direto || '/' ||
                                                    vr_nmarqimp --> Arquivo final com o path
                                   ,pr_cdrelato  => 684
                                   ,pr_qtcoluna  => 80 --> 80 colunas
                                   ,pr_flg_gerar => 'S' --> Geraçao na hora
                                   ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '' --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1 --> Número de cópias
                                   ,pr_sqcabrel  => 1 --> Qual a seq do cabrel
                                   ,pr_des_erro  => vr_dscritic); --> Saída com erro
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
                                    ,pr_des_reto => vr_des_reto --> Saída com erro
                                    ,pr_tab_erro => vr_tab_erro); --> tabela de erros

        -- caso apresente erro na operação
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

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml);
      dbms_lob.freetemporary(vr_xml);

      -- Criar XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
                                     vr_nmarqimp || '</nmarqpdf>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                       pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Produtos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                       pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_imprimir_antecipacao;

  PROCEDURE pc_valida_inclusao_tr(pr_cdcooper IN craplcr.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Codigo da linha de credito
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de inclusao
                                 ,pr_qtpreemp IN crapepr.qtpreemp%TYPE --> Quantidade de Prestacoes
                                 ,pr_flgpagto IN crapepr.flgpagto%TYPE --> Folha
                                 ,pr_dtdpagto IN crapepr.dtdpagto%TYPE --> Data de Pagamento
                                 ,pr_cdfinemp IN crapepr.cdfinemp%TYPE --> Finalidade
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Operador
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica

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
      SELECT cddepart
        FROM crapope
       WHERE crapope.cdcooper        = pr_cdcooper
         AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_exc_erro  EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    -- Variaveis gerais
    vr_dslcremp VARCHAR2(2000); --> Contem as linhas de microcredito que sao permitidos para o produto TR
  BEGIN

    -- Buscar informações da linha de crédito
    OPEN cr_crapfin(pr_cdcooper => pr_cdcooper
                   ,pr_cdfinemp => pr_cdfinemp);
    FETCH cr_crapfin
     INTO rw_crapfin;
    -- Se não encontrar
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

    -- Buscar informações da linha de crédito
    OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                   ,pr_cdlcremp => pr_cdlcremp);
    FETCH cr_craplcr
     INTO rw_craplcr;
    -- Se não encontrar
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

        -- Somente o departamento credito irá ter acesso para alterar as informacoes
        IF rw_crapope.cddepart IN (14,20) THEN
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

        -- Somente o departamento credito irá ter acesso para alterar as informacoes
        IF rw_crapope.cddepart IN (14,20) THEN
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
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em empr0001.pc_valida_inclusao_tr: ' ||SQLERRM;
  END;

  /* Criar e Atualizar Tabela Temporaria Lancamento Conta  */
  PROCEDURE pc_cria_atualiza_ttlanconta(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                       ,pr_cdhistor    IN craphis.cdhistor%TYPE --> Codigo Historico
                                       ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_cdpactra    IN INTEGER               --> P.A. da transação
                                       ,pr_nrdolote    IN craplot.nrdolote%TYPE --> Numero do Lote
                                       ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
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
       Data    : Março/2015                        Ultima atualizacao: 24/03/2015

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetuar Criacao/Atualizacao da ttlancconta

       Alteracoes: 24/03/2015 - Conversão Progress para Oracle (Alisson - AMcom)

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
                                     ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                     ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                     ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                     ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                     ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                     ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                     ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                     ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                     ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                     ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                     ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                     ,pr_dtmvtoan    IN DATE     --> Data Movimento Anterior
                                     ,pr_ehprcbat    IN VARCHAR2 --> Indicador Processo Batch (S/N)
                                     ,pr_tab_pgto_parcel IN OUT empr0001.typ_tab_pgto_parcel --Tabela com Pagamentos de Parcelas
                                     ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                     ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                     ,pr_des_erro    OUT VARCHAR --> Retorno OK / NOK
                                     ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................

       Programa: pc_efetua_liquidacao_empr                 Antigo: b1wgen0136.p/efetua_liquidacao_empr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson
       Data    : Março/2015                        Ultima atualizacao: 27/09/2016

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetuar a Liquidacao do Emprestimo

       Alteracoes: 24/03/2015 - Conversão Progress para Oracle (Alisson - AMcom)

                   27/09/2016 - Tornar o parametro PR_TAB_PGTO_PARCEL um parametro
                                "IN OUT" (Renato/Supero - P.302 - Acordos)

                   19/03/2019 - Tratamento para conta corrente em prejuízo (débito
                                da conta transitória)
                                (Reginaldo/AMcom - P450)

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

      cursor cr_craplcr is
        select lcr.dsoperac
        from   craplcr lcr, crapepr epr
        where  lcr.cdlcremp = epr.cdlcremp
        and    lcr.cdcooper = pr_cdcooper
        and    epr.cdcooper = pr_cdcooper
        and    epr.nrdconta = pr_nrdconta
        and    epr.nrctremp = pr_nrctremp;

      rw_craplcr cr_craplcr%rowtype;

      CURSOR cr_crapepr (pr_cdcooper IN crappep.cdcooper%type
                        ,pr_nrdconta IN crappep.nrdconta%type
                        ,pr_nrctremp IN crappep.nrctremp%type) IS
        SELECT crapepr.vlaqiofc
        FROM crapepr
        WHERE crapepr.cdcooper = pr_cdcooper
        AND   crapepr.nrdconta = pr_nrdconta
        AND   crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%rowtype;
      vr_ehimune PLS_INTEGER := 0;

      --Tabela de lancamentos na conta
      vr_tab_lanc empr0001.typ_tab_lancconta;

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
      vr_cdhisiof INTEGER;
      vr_loteatra INTEGER;
      vr_lotemult INTEGER;
      vr_lotepaga INTEGER;
      vr_loteiof  INTEGER;
      vr_vlpagsld NUMBER;
      vr_vliofcpl NUMBER;
      vr_nrseqdig INTEGER;
      vr_historicos_iof VARCHAR2(100);
      vr_hist_iof_tmp VARCHAR2(100);

      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_des_erro VARCHAR2(3);
      vr_dscritic VARCHAR2(4000);

      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;

      vr_inprejuz BOOLEAN; -- Indica se a conta corrente está em prejuízo

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
        vr_historicos_iof := '|';

        --Criar savepoint para desfazer transacao
        SAVEPOINT save_efetua_liquidacao_empr;

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
            empr0001.pc_efetiva_pagto_parc_lem (pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                               ,pr_cdagenci    => pr_cdagenci --> Código da agência
                                               ,pr_nrdcaixa    => pr_nrdcaixa --> Número do caixa
                                               ,pr_cdoperad    => pr_cdoperad --> Código do Operador
                                               ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                               ,pr_idorigem    => pr_idorigem --> Id do módulo de sistema
                                               ,pr_cdpactra    => pr_cdpactra --> P.A. da transação
                                               ,pr_nrdconta    => pr_nrdconta --> Número da conta
                                               ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                               ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                               ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para geração de log
                                               ,pr_nrctremp    => rw_crappep.nrctremp --> Número do contrato de empréstimo
                                               ,pr_nrparepr    => rw_crappep.nrparepr --> Número parcelas empréstimo
                                               ,pr_vlparepr    => vr_tab_pgto(vr_index_char).vlatupar --> Valor da parcela emprestimo
                                               ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                               ,pr_nrseqava    => pr_nrseqava --> Pagamento: Sequencia do avalista
                                               ,pr_cdhistor    => vr_cdhispag --> Codigo historico
                                               ,pr_nrdolote    => vr_lotepaga --> Numero do Lote
                                               ,pr_des_reto    => vr_des_erro --> Retorno OK / NOK
                                               ,pr_tab_erro    => pr_tab_erro); --> Tabela com possíves erros
            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
            END IF;

            --Se nao for batch
            IF nvl(pr_ehprcbat,'X') = 'N' THEN
              --Atualizar Lancamento Conta
              pc_cria_atualiza_ttlanconta (pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                          ,pr_nrctremp => pr_nrctremp   --> Número do contrato de empréstimo
                                          ,pr_cdhistor => vr_cdhispag   --> Codigo Historico
                                          ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                          ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                                          ,pr_cdpactra => pr_cdpactra   --> P.A. da transação
                                          ,pr_nrdolote => vr_lotepaga   --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta   --> Número da conta
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
            empr0001.pc_efetiva_pag_atr_parcel_lem (pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                                   ,pr_cdagenci    => pr_cdagenci --> Código da agência
                                                   ,pr_nrdcaixa    => pr_nrdcaixa --> Número do caixa
                                                   ,pr_cdoperad    => pr_cdoperad --> Código do Operador
                                                   ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                                   ,pr_idorigem    => pr_idorigem --> Id do módulo de sistema
                                                   ,pr_cdpactra    => pr_cdpactra --> P.A. da transação
                                                   ,pr_nrdconta    => pr_nrdconta --> Número da conta
                                                   ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                                   ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                                   ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para geração de log
                                                   ,pr_nrctremp    => rw_crappep.nrctremp --> Número do contrato de empréstimo
                                                   ,pr_nrparepr    => rw_crappep.nrparepr --> Número parcelas empréstimo
                                                   ,pr_vlpagpar    => vr_tab_pgto(vr_index_char).vlatrpag --> Valor da parcela emprestimo
                                                   ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                                   ,pr_nrseqava    => pr_nrseqava --Pagamento: Sequencia do avalista
                                                   ,pr_vlpagsld    => vr_vlpagsld --> Valor Pago Saldo
                                                   ,pr_vlrmulta    => vr_vlrmulta --> Valor Multa
                                                   ,pr_vlatraso    => vr_vlatraso --> Valor Atraso
                                                   ,pr_vliofcpl    => vr_vliofcpl --> Valor IOF atraso
                                                   ,pr_cdhismul    => vr_cdhismul --> Historico Multa
                                                   ,pr_cdhisatr    => vr_cdhisatr --> Historico Atraso
                                                   ,pr_cdhisiof    => vr_cdhisiof --> Historico IOF CPL atraso
                                                   ,pr_cdhispag    => vr_cdhispag --> Historico Pagamento
                                                   ,pr_loteatra    => vr_loteatra --> Lote Atraso
                                                   ,pr_lotemult    => vr_lotemult --> Lote Multa
                                                   ,pr_loteiof     => vr_loteiof  --> Lote iof
                                                   ,pr_lotepaga    => vr_lotepaga --> Lote Pagamento
                                                   ,pr_des_reto    => vr_des_erro --> Retorno OK / NOK
                                                   ,pr_tab_erro    => pr_tab_erro); --> Tabela com possíves erros

            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
            END IF;
            /* projeto 410 - lança IOF complementar de atraso */
            if nvl(vr_vliofcpl,0) > 0 then
                vr_historicos_iof := vr_historicos_iof || TO_CHAR(vr_cdhisiof) || '|';
                pc_cria_atualiza_ttlanconta (pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                            ,pr_nrctremp => pr_nrctremp   --> Número do contrato de empréstimo
                                            ,pr_cdhistor => vr_cdhisiof   --> Codigo Historico
                                            ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                            ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                                            ,pr_cdpactra => pr_cdpactra   --> P.A. da transação
                                            ,pr_nrdolote => vr_loteiof    --> Numero do Lote
                                            ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                            ,pr_vllanmto => vr_vliofcpl   --> Valor lancamento
                                            ,pr_nrseqava => pr_nrseqava   --> Pagamento: Sequencia do avalista
                                            ,pr_tab_lancconta => vr_tab_lanc    --> Tabela Lancamentos Conta
                                            ,pr_des_erro => vr_des_erro   --> Retorno OK / NOK
                                            ,pr_dscritic => vr_dscritic); --> descricao do erro
                --Se Retornou erro
                IF vr_des_erro <> 'OK' THEN
                  --Sair
                  RAISE vr_exc_saida;
                END IF;
            end if;

            /* multa */
            pc_cria_atualiza_ttlanconta (pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                        ,pr_nrctremp => pr_nrctremp   --> Número do contrato de empréstimo
                                        ,pr_cdhistor => vr_cdhismul   --> Codigo Historico
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                        ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                                        ,pr_cdpactra => pr_cdpactra   --> P.A. da transação
                                        ,pr_nrdolote => vr_lotemult   --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta   --> Número da conta
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
                                        ,pr_nrctremp => pr_nrctremp   --> Número do contrato de empréstimo
                                        ,pr_cdhistor => vr_cdhisatr   --> Codigo Historico
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                        ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                                        ,pr_cdpactra => pr_cdpactra   --> P.A. da transação
                                        ,pr_nrdolote => vr_loteatra   --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta   --> Número da conta
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
                                          ,pr_nrctremp => pr_nrctremp   --> Número do contrato de empréstimo
                                          ,pr_cdhistor => vr_cdhispag   --> Codigo Historico
                                          ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                          ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                                          ,pr_cdpactra => pr_cdpactra   --> P.A. da transação
                                          ,pr_nrdolote => vr_lotepaga   --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta   --> Número da conta
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
            empr0001.pc_efetiva_pagto_antec_lem (pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                                ,pr_cdagenci    => pr_cdagenci --> Código da agência
                                                ,pr_nrdcaixa    => pr_nrdcaixa --> Número do caixa
                                                ,pr_cdoperad    => pr_cdoperad --> Código do Operador
                                                ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                                ,pr_idorigem    => pr_idorigem --> Id do módulo de sistema
                                                ,pr_cdpactra    => pr_cdpactra --> P.A. da transação
                                                ,pr_nrdconta    => pr_nrdconta --> Número da conta
                                                ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                                ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                                ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para geração de log
                                                ,pr_nrctremp    => rw_crappep.nrctremp --> Número do contrato de empréstimo
                                                ,pr_nrparepr    => rw_crappep.nrparepr --> Número parcelas empréstimo
                                                ,pr_vlpagpar    => vr_tab_pgto(vr_index_char).vlatupar --> Valor da parcela emprestimo
                                                ,pr_tab_crawepr => pr_tab_crawepr --Tabela com Contas e Contratos
                                                ,pr_nrseqava    => pr_nrseqava --Pagamento: Sequencia do avalista
                                                ,pr_cdhistor    => vr_cdhispag --> Historico Multa
                                                ,pr_nrdolote    => vr_lotepaga --> Lote Pagamento
                                                ,pr_des_reto    => vr_des_erro --> Retorno OK / NOK
                                                ,pr_tab_erro    => pr_tab_erro); --> Tabela com possíves erros

            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
            END IF;

            IF nvl(pr_ehprcbat,'X') = 'N' THEN
              /* pagamento */
              pc_cria_atualiza_ttlanconta (pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                          ,pr_nrctremp => pr_nrctremp   --> Número do contrato de empréstimo
                                          ,pr_cdhistor => vr_cdhispag   --> Codigo Historico
                                          ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                          ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                                          ,pr_cdpactra => pr_cdpactra   --> P.A. da transação
                                          ,pr_nrdolote => vr_lotepaga   --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta   --> Número da conta
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

        -- Verifica se a conta está em prejuízo
        vr_inprejuz := PREJ0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper
                                                      , pr_nrdconta => pr_nrdconta);

        --Percorrer os Lancamentos
        vr_index_lanc:= vr_tab_lanc.FIRST;
        WHILE vr_index_lanc IS NOT NULL LOOP

          IF NOT vr_inprejuz THEN
            /* Lanca em C/C e atualiza o lote */
            empr0001.pc_cria_lancamento_cc_chave (pr_cdcooper => vr_tab_lanc(vr_index_lanc).cdcooper --> Cooperativa conectada
                                                 ,pr_dtmvtolt => vr_tab_lanc(vr_index_lanc).dtmvtolt --> Movimento atual
                                                 ,pr_cdagenci => vr_tab_lanc(vr_index_lanc).cdagenci --> Código da agência
                                                 ,pr_cdbccxlt => vr_tab_lanc(vr_index_lanc).cdbccxlt --> Número do caixa
                                                 ,pr_cdoperad => vr_tab_lanc(vr_index_lanc).cdoperad --> Código do Operador
                                                 ,pr_cdpactra => vr_tab_lanc(vr_index_lanc).cdpactra --> P.A. da transação
                                                 ,pr_nrdolote => vr_tab_lanc(vr_index_lanc).nrdolote --> Numero do Lote
                                                 ,pr_nrdconta => vr_tab_lanc(vr_index_lanc).nrdconta --> Número da conta
                                                 ,pr_cdhistor => vr_tab_lanc(vr_index_lanc).cdhistor --> Codigo historico
                                                 ,pr_vllanmto => vr_tab_lanc(vr_index_lanc).vllanmto --> Valor da parcela emprestimo
                                                 ,pr_nrparepr => 0                                   --> Número parcelas empréstimo
                                                 ,pr_nrctremp => vr_tab_lanc(vr_index_lanc).nrctremp --> Número do contrato de empréstimo
                                                 ,pr_nrseqava => vr_tab_lanc(vr_index_lanc).nrseqava --> Pagamento: Sequencia do avalista
                                                 ,pr_nrseqdig => vr_nrseqdig
                                                 ,pr_des_reto => vr_des_erro                         --> Retorno OK / NOK
                                                 ,pr_tab_erro => pr_tab_erro);                       --> Tabela com possíves erros
            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
            END IF;
          ELSE 
            IF nvl(vr_tab_lanc(vr_index_lanc).vllanmto, 0) > 0 THEN
              -- Lança débito na conta transitória (Bloqueado Prejuízo)
              PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => vr_tab_lanc(vr_index_lanc).cdcooper
                                          , pr_nrdconta => vr_tab_lanc(vr_index_lanc).nrdconta
                                          , pr_vlrlanc => vr_tab_lanc(vr_index_lanc).vllanmto
                                          , pr_dtmvtolt => vr_tab_lanc(vr_index_lanc).dtmvtolt
                                          , pr_dsoperac => 'Liq. Emprestimo: ' || vr_tab_lanc(vr_index_lanc).nrctremp || 
                                                           ' Hist. ' || vr_tab_lanc(vr_index_lanc).cdhistor
                                          , pr_cdcritic => vr_cdcritic
                                          , pr_dscritic => vr_dscritic);
                                          
              IF trim(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
                --Sair
                RAISE vr_exc_saida;
              END IF;
            END IF;
          END IF;

          --Marcar que transacao ocorreu
          vr_flgtrans:= TRUE;
          --Proximo registro
          vr_index_lanc:= vr_tab_lanc.NEXT(vr_index_lanc);
        END LOOP;

      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT save_efetua_liquidacao_empr;
      END;

      -- Renato Darosci - 27/09/2016 - Retornar a tabela de memória após processamento
      -- Limpa a tabela de memória do parametro
      pr_tab_pgto_parcel.DELETE();

      -- Devolver a tabela de memória para a rotina chamadora
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
        -- Retorno não OK
        pr_des_erro := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
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
        -- Retorno não OK
        pr_des_erro := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_efetua_liquidacao_empr. '||sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                ,pr_tab_erro    OUT gene0001.typ_tab_erro
                                ,pr_cdcritic    OUT INTEGER
                                ,pr_dscritic    OUT VARCHAR2
                                ,pr_retxml   IN OUT NOCOPY XMLType ) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................

       Programa: pc_liquida_mesmo_dia
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Daniel
       Data    : Maio/2015                        Ultima atualizacao: 14/01/2016

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetivar liquidação de contrato no mesmo dia

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
        --Determinar se a Operacao é financiamento
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
                           ,pr_cdagenci => pr_cdagenci --> Código da agência
                           ,pr_cdbccxlt => 100         --> Número do caixa
                           ,pr_cdoperad => pr_cdoperad --> Código do Operador
                           ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                           ,pr_nrdolote => vr_nrdolote --> Numero do Lote
                           ,pr_nrdconta => rw_crapepr.nrdconta --> Número da conta
                           ,pr_cdhistor => vr_cdhistor --> Codigo historico
                           ,pr_vllanmto => rw_crapepr.vlemprst --> Valor emprestimo
                           ,pr_nrparepr => 0 --> Número parcelas empréstimo
                           ,pr_nrctremp => rw_crapepr.nrctremp --> Número do contrato de empréstimo
                           ,pr_nrseqava => 0 --> Pagamento: Sequencia do avalista
                           ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                           ,pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros

      IF vr_des_erro = 'NOK' THEN
        --Se tem erro na tabela
        IF vr_tab_erro.count > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao executar empr0001.pc_liquida_mesmo_dia.';
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
          vr_dscritic:= 'Erro ao executar empr0001.pc_liquida_mesmo_dia.';
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

        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0001.pc_liquida_mesmo_dia ' ||
                       sqlerrm;
        ROLLBACK;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
  PROCEDURE pc_liq_mesmo_dia_web(pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                ,pr_dtmvtolt    IN VARCHAR2              --> Movimento atual
                                ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para geração de log
                                ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
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
       Objetivo  : Rotina para Efetivar liquidação de contrato no mesmo dia

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
                          ,pr_cdpactra => 1 --> P.A. da transação
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
        -- Levantar exceção 2, onde já temos o erro na vr_tab_erro
        pr_des_erro := vr_des_erro;

        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        ELSE
          vr_dscritic := 'Não foi possivel liquidar emprestimo.';
        END IF;

        RAISE vr_exc_erro;
      END IF;


    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN

        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na empr0001.pc_liquida_mesmo_dia ' ||
                       SQLERRM; /*
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                           ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                           ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                           ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                           ,pr_nmdatela    IN VARCHAR2              --> Nome da tela
                                           ,pr_idorigem    IN INTEGER               --> Id do módulo de sistema
                                           ,pr_cdpactra    IN INTEGER               --> P.A. da transação
                                           ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                           ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                           ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                           ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para geração de log
                                           ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                           ,pr_nrparepr    IN INTEGER               --> Número parcelas empréstimo
                                           ,pr_vlpagpar    IN NUMBER                --> Valor a pagar parcela
                                           ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                           ,pr_nrseqava    IN NUMBER DEFAULT 0       --> Pagamento: Sequencia do avalista
                                           ,pr_cdhistor    OUT craphis.cdhistor%TYPE --> Historico Pagamento
                                           ,pr_nrdolote    OUT craplot.nrdolote%TYPE --> Numero Lote Pagamento
                                           ,pr_des_reto    OUT VARCHAR               --> Retorno OK / NOK
                                           ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros

    /* .............................................................................

       Programa: pr_efetiva_pagto_antec_parcela (antigo b1wgen0084a.p --> efetiva_pagamento_antecipado_parcela)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Renato Darosci
       Data    : Setembro/2016.                         Ultima atualizacao: 27/12/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  :

       Alteracoes: 27/12/2018 - Ajuste no tratamento de contas corrente em prejuízo (substituição
                                da verificação através do parâmetro "pr_nmdatela" pelo uso da
                                função de verificação do prejuízo de conta corrente).
                                P450 - Reginaldo/AMcom

    ............................................................................. */

    vr_exc_erro  EXCEPTION;

    vr_prejuzcc BOOLEAN; -- Indicador de conta corrente em prejuízo
  BEGIN

    pr_des_reto := 'NOK';

    -- Efetivar Pagamento Antecipado parcela na craplem
    pc_efetiva_pagto_antec_lem(pr_cdcooper    => pr_cdcooper    --> Cooperativa conectada
                              ,pr_cdagenci    => pr_cdagenci    --> Código da agência
                              ,pr_nrdcaixa    => pr_nrdcaixa    --> Número do caixa
                              ,pr_cdoperad    => pr_cdoperad    --> Código do Operador
                              ,pr_nmdatela    => pr_nmdatela    --> Nome da tela
                              ,pr_idorigem    => pr_idorigem    --> Id do módulo de sistema
                              ,pr_cdpactra    => pr_cdpactra    --> P.A. da transação
                              ,pr_nrdconta    => pr_nrdconta    --> Número da conta
                              ,pr_idseqttl    => pr_idseqttl    --> Seq titula
                              ,pr_dtmvtolt    => pr_dtmvtolt    --> Movimento atual
                              ,pr_flgerlog    => pr_flgerlog    --> Indicador S/N para geração de log
                              ,pr_nrctremp    => pr_nrctremp    --> Número do contrato de empréstimo
                              ,pr_nrparepr    => pr_nrparepr    --> Número parcelas empréstimo
                              ,pr_vlpagpar    => pr_vlpagpar    --> Valor da parcela emprestimo
                              ,pr_tab_crawepr => pr_tab_crawepr --> Tabela com Contas e Contratos
                              ,pr_nrseqava    => pr_nrseqava    --> Pagamento: Sequencia do avalista
                              ,pr_cdhistor    => pr_cdhistor    --> Historico
                              ,pr_nrdolote    => pr_nrdolote    --> Lote Pagamento
                              ,pr_des_reto    => vr_des_reto    --> Retorno OK / NOK
                              ,pr_tab_erro    => vr_tab_erro);  --> Tabela com possíves erros

    --Se Retornou erro
    IF vr_des_reto <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    vr_prejuzcc := PREJ0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);

    IF NOT vr_prejuzcc THEN
    /* Lanca em C/C e atualiza o lote */
    empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                         ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                         ,pr_cdagenci => pr_cdagenci --> Código da agência
                                         ,pr_cdbccxlt => 100         --> Número do caixa
                                         ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                         ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                         ,pr_nrdolote => pr_nrdolote --> Numero do Lote
                                         ,pr_nrdconta => pr_nrdconta --> Número da conta
                                         ,pr_cdhistor => pr_cdhistor --> Codigo historico
                                         ,pr_vllanmto => pr_vlpagpar --> Valor da parcela emprestimo
                                         ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                         ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                         ,pr_nrseqava => pr_nrseqava -- Pagamento: Sequencia do avalista
                                         ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                         ,pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros
    --Se Retornou erro
    IF vr_des_reto <> 'OK' THEN
      --Sair
      RAISE vr_exc_erro;
    END IF;
    END IF;

    -- Retornar ok para as transações
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
  PROCEDURE pc_gera_pagamentos_parcelas(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                        ,pr_cdoperad IN VARCHAR2              --> Código do operador
                                        ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                        ,pr_idorigem IN INTEGER               --> Id Origem do sistemas
                                        ,pr_cdpactra IN INTEGER               --> P.A. da transação
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
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
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

       28/09/2016 - Incluir validação para contratos de acordo ativos, conforme
                    projeto 302 - Sistema de acordos ( Renato Darosci - Supero )

       29/09/2016 - Incluir o pagamento de parcela a vencer, seguindo as mesmas
                    regras da b1wgen0084a.p->gera_pagamentos_parcelas, conforme
                    projeto 302 - Sistema de acordos ( Renato Darosci - Supero )

    ............................................................................. */
    DECLARE

      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      vr_exc_erro2 EXCEPTION;
      -- Descrição e código da critica
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
           AND crappep.inliquid = 0; -- Não Liquidado
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
                     FROM tbrecup_cobranca cde
                    WHERE cde.cdcooper = pr_cdcooper
                      AND cde.nrdconta = pr_nrdconta
                      AND cde.nrctremp = pr_nrctremp
                      AND cde.tpproduto = 0);
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
                    FROM tbrecup_cobranca cde
                   WHERE cde.cdcooper = pr_cdcooper
                     AND cde.nrdconta = pr_nrdconta
                     AND cde.nrctremp = pr_nrctremp
                     AND cde.tpproduto = 0)
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
         -- Atribui crítica
         vr_cdcritic := 0;
         vr_dscritic := 'Para efetuar o pagamento selecione a(s) parcela(s).';
         -- Gera exceção
         RAISE vr_exc_erro;
       END IF;

       -- Parametro de bloqueio de resgate de valores em c/c
       -- ref ao pagto de contrato com boleto (Projeto 210)
       vr_blqresg_cc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                  pr_cdcooper => pr_cdcooper,
                                                  pr_cdacesso => 'COBEMP_BLQ_RESG_CC');

       -- Verificar se há acordo ativo para o contrato
       RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_cdorigem => 3
                                        ,pr_flgativo => vr_flgativo
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

       -- Se houve retorno de erro
       IF vr_dscritic IS NOT NULL THEN
         -- Gera exceção
         RAISE vr_exc_erro;
       END IF;

       /* verificar se existe boleto de contrato em aberto e se pode lancar juros remuneratorios no contrato */
       /* 1º) verificar se o parametro está bloqueado para realizar busca de boleto em aberto */
       /*     e... se o contrato não estiver em um acordo ativo  */
       IF vr_blqresg_cc = 'S' AND vr_flgativo = 0 THEN

          -- inicializar rows de cursores
          rw_cde := NULL;
          rw_ret := NULL;

          /* 2º se permitir, verificar se possui boletos em aberto */
          OPEN cr_cde( pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp);
          FETCH cr_cde INTO rw_cde;
          CLOSE cr_cde;

          /* 3º se existir boleto de contrato em aberto, criticar */
          IF nvl(rw_cde.nrdocmto,0) > 0 THEN
             -- Atribui crítica
             vr_cdcritic := 0;
             vr_dscritic := 'Boleto do contrato ' || to_char(pr_nrctremp) || ' em aberto.' ||
                            ' Vencto ' || to_char(rw_cde.dtvencto, 'DD/MM/RRRR') ||
                            ' R$ ' || to_char(rw_cde.vltitulo,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
             -- Gera exceção
             RAISE vr_exc_erro;

          ELSE
             /* 4º cursor para verificar se existe boleto pago pendente de processamento */
             OPEN cr_ret( pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctremp => pr_nrctremp
                         ,pr_dtmvtolt => pr_dtmvtolt);
             FETCH cr_ret INTO rw_ret;
             CLOSE cr_ret;

             /* 6º se existir boleto de contrato pago pendente de processamento, lancar juros */
             IF nvl(rw_ret.nrdocmto,0) > 0 THEN
                -- Atribui crítica
                vr_cdcritic := 0;
                vr_dscritic := 'Boleto do contrato ' || to_char(pr_nrctremp) ||
                               ' esta pago pendente de processamento.' ||
                               ' Vencto ' || to_char(rw_ret.dtvencto, 'DD/MM/RRRR') ||
                               ' R$ ' || to_char(rw_ret.vltitulo,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
                -- Gera exceção
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
           empr0001.pc_busca_pgto_parcelas(pr_cdcooper => pr_cdcooper
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
             -- Gera exceção
             RAISE vr_exc_erro2;
           END IF;

           -- Efetua liquidação do emprestimo
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
            -- Atribui críticas
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao Localizar Parcela';
            -- Gera exceção
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
              -- Atribui críticas
              vr_cdcritic := 0;
              vr_dscritic := 'Parcela nao encontrada';
              -- Gera exceção
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
             -- Gera exceção
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
             -- Gera exceção
             RAISE vr_exc_erro;
           END IF;

           IF rw_crappep.inliquid = 1 THEN
             -- Atribui críticas
             vr_cdcritic := 0;
             vr_dscritic := 'Parcela ja liquidada';
             -- Gera exceção
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
                                           ,pr_cdagenci    => pr_cdagenci --> Código da agência
                                           ,pr_nrdcaixa    => pr_nrdcaixa --> Número do caixa
                                           ,pr_cdoperad    => pr_cdoperad --> Código do Operador
                                           ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                           ,pr_idorigem    => pr_idorigem --> Id do módulo de sistema
                                           ,pr_cdpactra    => pr_cdpactra --> P.A. da transação
                                           ,pr_nrdconta    => pr_nrdconta --> Número da conta
                                           ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                           ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                           ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para geração de log
                                           ,pr_nrctremp    => rw_crappep.nrctremp --> Número do contrato de empréstimo
                                           ,pr_nrparepr    => rw_crappep.nrparepr --> Número parcelas empréstimo
                                           ,pr_vlpagpar    => vr_tab_pgto_parcel(idx).vlpagpar --> Valor da parcela emprestimo
                                           ,pr_tab_crawepr => vr_tab_crawepr --> Tabela com Contas e Contratos
                                           ,pr_nrseqava    => pr_nrseqava    --> Pagamento: Sequencia do avalista
                                           ,pr_cdhistor    => vr_cdhispag    --> Historico Multa
                                           ,pr_nrdolote    => vr_lotepaga    --> Lote Pagamento
                                           ,pr_des_reto    => vr_des_reto    --> Retorno OK / NOK
                                           ,pr_tab_erro    => vr_tab_erro);  --> Tabela com possíves erros

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

           -- Retorno não OK
           pr_des_reto := 'NOK';
           -- Gerar rotina de gravação de erro
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

           -- Retorno não OK
           pr_des_reto := 'NOK';
           -- Copiar o erro já existente na variavel para
           pr_tab_erro := vr_tab_erro;

    END;

  END pc_gera_pagamentos_parcelas;

  PROCEDURE pc_verifica_parcelas_antecipa(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                                         ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Conta
                                         ,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Contrato
                                         ,pr_nrparepr IN crappep.nrparepr%TYPE  --> Nr. da parcela
                                         ,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE  --> Data de movimento
                                         ,pr_des_reto OUT VARCHAR2              --> Retorno OK/NOK
                                         ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
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

      /* Descrição e código da critica */
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

      -- Verifica se as parcelas informadas estão em ordem
      CURSOR cr_crappep_2 IS
        SELECT 1
          FROM crappep pep
         WHERE pep.cdcooper = pr_cdcooper
           AND pep.nrdconta = pr_nrdconta
           AND pep.nrctremp = pr_nrctremp
           AND pep.nrparepr > pr_nrparepr
           AND pep.inliquid = 0;
      rw_crappep_2 cr_crappep_2%ROWTYPE;

      -- Verifica se as parcelas informadas estão em ordem
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

      -- Verifica se as parcelas informadas estão em ordem
      OPEN cr_crappep_2;
      FETCH cr_crappep_2 INTO rw_crappep_2;

      -- Verifica se as parcelas informadas estão em ordem
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

        pr_dscritic := 'Erro nao tratado na procedure empr0001.pc_verifica_parcelas_antecipa -> ' || SQLERRM;
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
        Data     : Novembro/2015                Ultima atualizacao: 07/12/2017

        Dados referentes ao programa:

         Frequencia: Sempre que for chamado
         Objetivo  : Possui a mesma funcionalidade da rotina pc_valida_pagamentos_geral,
                     para chamadas diretamente atraves de rotinas progress

        Alteração : 07/12/2017 - Passagem do crawepr.idcobope. (Jaison/Marcos Martini - PRJ404)
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
    vr_tab_crawepr      empr0001.typ_tab_crawepr;
    vr_tab_erro         GENE0001.typ_tab_erro;
    vr_tab_msg_confirma empr0001.typ_tab_msg_confirma;

    vr_vlresgat  NUMBER;

    --Selecionar Detalhes Emprestimo
    CURSOR cr_crawepr (pr_cdcooper IN crawepr.cdcooper%TYPE
                      ,pr_nrdconta IN crawepr.nrdconta%TYPE
                      ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
         SELECT crawepr.cdcooper
               ,crawepr.nrdconta
               ,crawepr.nrctremp
               ,crawepr.dtlibera
               ,crawepr.tpemprst
               ,crawepr.idcobope
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
      vr_tab_crawepr(vr_index_crawepr).idcobope:= rw_crawepr.idcobope;
    END LOOP;

    empr0001.pc_valida_pagamentos_geral(pr_cdcooper    => pr_cdcooper,
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
                                        pr_vlresgat    => vr_vlresgat,
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
      pr_dscritic := 'Erro geral(empr0001.pc_valida_pagto_geral_prog): '|| SQLERRM;

  END pc_valida_pagto_geral_prog;

  PROCEDURE pc_verifica_msg_garantia(pr_cdcooper IN crapbpr.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_dscatbem IN crapbpr.dscatbem%TYPE --> Descricao da categoria do bem
                                    ,pr_vlmerbem IN crapbpr.vlmerbem%TYPE --> Valor de mercado do bem
                                    ,pr_vlemprst IN crapepr.vlemprst%TYPE --> Valor do emprestimo
                                    ,pr_flgsenha OUT INTEGER              --> Verifica se solicita a senha
                                    ,pr_dsmensag OUT VARCHAR2             --> Descricao da mensagem de aviso
                                    ,pr_cdcritic OUT INTEGER              --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
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

    -- Caso o valor do bem for maior ou igual á 5 vezes, apresenta mensagem em tela
    IF (pr_vlemprst * vr_tipsplit(1)) <= pr_vlmerbem THEN
      pr_dsmensag := 'Atencao! Valor do bem superior ou igual a ' || vr_tipsplit(1) || ' vezes o valor do emprestimo!';
    END IF;

    -- Caso o valor do bem for maior ou igual á 10 vezes, solicita a senha de coordenador
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
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo da ag¿ncia
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
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na empr0001.pc_valida_alt_valor_prop --> ' || sqlerrm;
    END;

  END pc_valida_alt_valor_prop;

  PROCEDURE pc_valida_alt_valor_prop_web(pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
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
        -- Gerar exceção
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
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na empr0001.pc_valida_alt_valor_prop_web ' ||SQLERRM;
    END;

  END pc_valida_alt_valor_prop_web;

  PROCEDURE pc_gera_arq_saldo_devedor(pr_arquivo_ent in varchar2
                                     ,pr_arquivo_sai in varchar2
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2             --> Descric?o da critica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2)    IS
    /* Rotina: pc_gera_arq_saldo_devedor
       Autor:  Jean (Mout´s)
       Data:   03/03/2017
       Objetivo: gerar o arquivo de exportação de saldo devedor, com base nas contas importadas via CSV


    */
    vr_nm_arquivo varchar2(2000);
    vr_nm_arqsai  varchar2(2000);
    vr_nm_arqlog  varchar2(2000);

    vr_handle_arq utl_file.file_type;
    vr_handle_sai utl_file.file_type;
    vr_handle_log utl_file.file_type;

    vr_linha_arq     varchar2(2000);
    vr_linha_arq_sai varchar2(2000);
    vr_linha_arq_log varchar2(2000);

    vr_nrlinha   number;
    vr_nrdconta  number;
    vr_nrctremp  number;
    vr_cdcooper  number;
    vr_cdcooperx varchar2(10);
    vr_nrdcontax varchar2(10);
    vr_nrctrempx varchar2(10);
    vr_indice    number;
    vr_indiceant number;
    vr_vlsdeved  number;
    vr_cdcritic  number;
    vr_des_erro  varchar2(2000);
    vr_qtdprecal number;

    vr_rw_crapdat btch0001.rw_crapdat%type;
    vr_qtregist   number;
    vr_index      number;
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;
    vr_tab_erro gene0001.typ_tab_erro;
    vr_endarqui varchar2(100);
  BEGIN

     vr_endarqui:= gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros/coop
                                          ,pr_cdcooper => 3
                                          ,pr_nmsubdir => '/relsdv/');

    IF pr_arquivo_ent is null then
        vr_nm_arquivo := vr_endarqui || '/cecred.csv';
    else
       vr_nm_arquivo := pr_arquivo_ent;
    END IF;

    IF pr_arquivo_sai is null then
       vr_nm_arqsai := vr_endarqui || '/relsaida.csv';
    else
       vr_nm_arqsai  := pr_arquivo_sai;
    END IF;

    open btch0001.cr_crapdat(pr_cdcooper => 1);
    fetch btch0001.cr_crapdat into vr_rw_crapdat;
    close btch0001.cr_crapdat;


   -- vr_nm_arqlog  := pr_arquivo_sai || '_log';
    vr_nm_arqlog  := vr_endarqui || '/relsaida_log';

    /* verificar se o arquivo existe */
    if not gene0001.fn_exis_arquivo(pr_caminho => vr_nm_arquivo) then
      vr_des_erro := 'Erro rotina pc_gera_arq_saldo_devedor: Arquivo inexistente!' ||
                     sqlerrm;
            pr_cdcritic := 3;
      raise vr_exc_erro;
    end if;

    /* Abrir o arquivo de importação */
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo
                            ,pr_tipabert => 'R' --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_handle_arq --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);

    if vr_des_erro is not null then
      vr_des_erro := 'Rotina pc_gera_arq_saldo_devedor: Erro abertura arquivo importaçao!' ||
                     sqlerrm;
      pr_cdcritic := 4;
      raise vr_exc_erro;
    end if;

    /* Abrir o arquivo de saida */
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arqsai
                            ,pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_handle_sai --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);

    if vr_des_erro is not null then
       vr_des_erro := 'Rotina pc_gera_arq_saldo_devedor: Erro abertura arquivo saida!' || sqlerrm;
       pr_cdcritic := 5;
       raise vr_exc_erro;
    end if;

    /* Abrir o arquivo de LOG */
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arqlog
                            ,pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_handle_log --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);

    if vr_des_erro is not null then
       vr_des_erro := 'Rotina pc_gera_arq_saldo_devedor: Erro abertura arquivo LOG!' || sqlerrm;
       pr_cdcritic := 6;
       raise vr_exc_erro;
    end if;

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                           pr_des_text => 'Inicio da geracao Arquivo LOG');

     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);

    /* Processar linhas do arquivo */
    vr_nrlinha := 1;

    IF utl_file.IS_OPEN(vr_handle_arq) then
      -- gravar linha de cabecalho do arquivo de saida
       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_sai,
                                      pr_des_text => 'Cooperativa;Nro. Conta; Contrato; Saldo Devedor');

      BEGIN
        LOOP
         -- exit when vr_nrlinha = 1019;

          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_arq,
                                       pr_des_text => vr_linha_arq);

          -- valida a partir da linha 2, linha 1 é cabeçalho
          if vr_nrlinha >= 2 then
            -- busca cooperativa
            vr_indice    := instr(vr_linha_arq, ';');
            vr_cdcooperx := substr(vr_linha_arq, 1, vr_indice - 1);
            vr_indiceant := vr_indice;
            vr_cdcooper  := to_number(rtrim(vr_cdcooperx));

            --busca conta
            vr_indice    := instr(vr_linha_arq, ';', vr_indice + 1);
            vr_nrdcontax  := substr(vr_linha_arq,
                                   vr_indiceant + 1,
                                   vr_indice - vr_indiceant - 1);
            vr_indiceant := vr_indice;
            vr_nrdconta  := to_number(rtrim(vr_nrdcontax));

            --busca contrato
            vr_indice := instr(vr_linha_arq, ';', vr_indice + 1);

            if vr_indice = 0 then
              vr_indice := length(vr_linha_arq) + 1;
            end if;
            vr_nrctrempx := substr(vr_linha_arq,
                                  vr_indiceant + 1,
                                  vr_indice - vr_indiceant - 1);
            vr_nrctrempx := replace(vr_nrctrempx,chr(13),null);

            vr_nrctremp := to_number(rtrim(vr_nrctrempx));

            if vr_nrctremp is null then
              vr_des_erro := 'Erro no arquivo, campo número do contrato não está preenchido!';
              pr_cdcritic := 7;
              raise vr_exc_erro;
            end if;

            -- valida campos do arquivo de importaçao

            if vr_cdcooper is null then
              vr_des_erro := 'cooperativa não informada!';
              pr_cdcritic := 8;
              raise vr_exc_erro;
            end if;

            if vr_nrdconta is null then
              vr_des_erro := 'Conta não informada!';
              pr_cdcritic := 9;
              raise vr_exc_erro;
            end if;

            if vr_nrctremp is null then
              vr_des_erro := 'Contrato não informado!';
              pr_cdcritic := 10;
              raise vr_exc_erro;
            end if;

            vr_linha_arq_sai := vr_cdcooper || ';' || vr_nrdconta || ';' || vr_nrctremp;

            -- busca saldo devedor atualizado
            pc_obtem_dados_empresti(pr_cdcooper       => vr_cdcooper --> Cooperativa conectada
                                   ,pr_cdagenci               => 0 --> Código da agência
                                   ,pr_nrdcaixa               => 0 --> Número do caixa
                                   ,pr_cdoperad               => 1 --> Código do operador
                                   ,pr_nmdatela               => 'RELSDV'--> Nome datela conectada
                                   ,pr_idorigem               => 5       --> Indicador da origem da chamada
                                   ,pr_nrdconta               => vr_nrdconta --> Conta do associado
                                   ,pr_idseqttl               => 1 --> Sequencia de titularidade da conta
                                   ,pr_rw_crapdat           => vr_rw_crapdat --> Vetor com dados de parâmetro (CRAPDAT)
                                   ,pr_dtcalcul               => vr_rw_crapdat.dtmvtolt --> Data solicitada do calculo
                                   ,pr_nrctremp               => vr_nrctremp  --> Número contrato empréstimo
                                   ,pr_cdprogra               => 'empr0001'   --> Programa conectado
                                   ,pr_inusatab               => false        --> Indicador de utilização da tabela
                                   ,pr_flgerlog               => 'N'          --> Gerar log S/N
                                   ,pr_flgcondc               => true         --> Mostrar emprestimos liquidados sem prejuizo
                                   ,pr_nmprimtl               => ''           --> Nome Primeiro Titular
                                   ,pr_tab_parempctl        => ''           --> Dados tabela parametro
                                   ,pr_tab_digitaliza         => ''           --> Dados tabela parametro
                                   ,pr_nriniseq               => 0            --> Numero inicial da paginacao
                                   ,pr_nrregist               => 0            --> Numero de registros por pagina
                                   ,pr_qtregist               => vr_qtregist  --> Qtde total de registros
                                   ,pr_tab_dados_epr        => vr_tab_dados_epr --> Saida com os dados do empréstimo
                                   ,pr_des_reto               => vr_des_reto  --> Retorno OK / NOK
                                   ,pr_tab_erro               => vr_tab_erro);  --> Tabela com possíves erros

            if vr_des_reto = 'NOK' then
               vr_des_erro := 'Erro na rotina pc_obtem_dados_empresti';
               pr_cdcritic := 11;
               raise vr_exc_erro;
            end if;

            vr_index := vr_tab_dados_epr.first;
            vr_vlsdeved := 0;

            WHILE vr_index IS NOT NULL LOOP

                  /*vr_vlsdeved := vr_tab_dados_epr(vr_index).vlsdeved +
                                  nvl(vr_tab_dados_epr(vr_index).vlmrapar,0) +
                                  nvl(vr_tab_dados_epr(vr_index).vlmtapar,0);*/
                  -- de acordo com Luana, não ira calcular mais Multas e Juros
                   vr_vlsdeved := vr_tab_dados_epr(vr_index).vlsdeved ;

              -- buscar proximo
              vr_index := vr_tab_dados_epr.next(vr_index);
            END LOOP;

            vr_linha_arq_sai := vr_linha_arq_sai || ';' || vr_vlsdeved;

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_sai,
                                           pr_des_text => vr_Linha_arq_sai);
          end if;
          vr_nrlinha := vr_nrlinha + 1;
        END LOOP;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Fim das linhas do arquivo
          NULL;
      END;
    END IF;

    -- Fecha arquivos
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_sai);
    --gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    commit;
  EXCEPTION

    WHEN vr_exc_erro THEN
        pr_des_erro := vr_des_erro;
        pr_dscritic := pr_cdcritic || '-Erro na empr0001: ' || PR_DES_ERRO ;

        pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      raise_application_error(-20150,
                              'erro na rotina pc_gera_arq_saldo_devedor: ' ||
                              sqlerrm);

  END;

  PROCEDURE pc_valida_imoveis_epr(pr_cdcooper  IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                                 ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta do associado
                                 ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero Contrato
                                 ,pr_flimovel OUT INTEGER               --> Retorna se possui ou não imóveis pendentes de preenchimento
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2) IS          --> Descricão da critica

  /* .............................................................................

     Programa: pc_valida_imoveis_epr
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Renato Darosci
     Data    : Dezembro/2016                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamada
     Objetivo  : Validar se o empréstimo possui imóveis que ainda não tiveram seus
                 dados preenchidos na tela IMOVEL. Os empréstimos que devem conter
                 estas informações são os empréstimos de tipo de contrato da linha
                 de crédito igual a 3.

     Alteracoes:
  ............................................................................. */

    CURSOR cr_crapepr IS
        SELECT 1
          FROM crapbpr b
             , craplcr r
             , crawepr t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.nrctremp = pr_nrctremp
           AND r.cdcooper = t.cdcooper
           AND r.cdlcremp = t.cdlcremp
           AND r.tpctrato = 3 -- Contratos de imóvel
           AND b.cdcooper = t.cdcooper
           AND b.nrdconta = t.nrdconta
           AND b.nrctrpro = t.nrctremp
           AND b.flgalien = 1  -- Alienação
           AND b.dscatbem IN ('CASA','APARTAMENTO') -- Que seja casa ou apartamento
           AND NOT EXISTS (SELECT 1
                             FROM tbepr_imovel_alienado i
                            WHERE i.cdcooper = t.cdcooper
                              AND i.nrdconta = t.nrdconta
                              AND i.nrctrpro = t.nrctremp
                              AND i.idseqbem = b.idseqbem);

    -- VARIÁVEIS
    vr_inregist   NUMBER;

  BEGIN

    -- Setar a flag para zero indicando que não há pendencia
    pr_flimovel := 0;

    -- Buscar contratos sem informação de imóveis
    OPEN  cr_crapepr;
    FETCH cr_crapepr INTO vr_inregist;

    -- Se encontrar registros
    IF cr_crapepr%FOUND THEN
      -- Setar a flag para hum indicando que há pendencias
      pr_flimovel := 1;
    END IF;

    -- Fechar o cursor
    CLOSE cr_crapepr;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na empr0001.pc_valida_imoveis_epr --> ' || SQLERRM;
  END pc_valida_imoveis_epr;


  /* Retorna o tipo de finalide */
  FUNCTION fn_tipo_finalidade(pr_cdcooper IN crapfin.cdcooper%TYPE  --> Código da Cooperativa
                             ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) --> Código de finalidade
   RETURN INTEGER IS
  BEGIN
    /* .............................................................................

       Programa: fn_tipo_finalidade
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Lucas Reinert
       Data    : Novembro/2017                        Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamada
       Objetivo  : Função para retornar o tipo de finalidade a partir do código de
                   finalidade.

       Alteracoes:

    ............................................................................. */
    DECLARE

      -- Cursor para buscar tipo de finalidade
      CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE
                       ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
        SELECT fin.tpfinali
          FROM crapfin fin
         WHERE fin.cdcooper = pr_cdcooper
           AND fin.cdfinemp = pr_cdfinemp;
      rw_crapfin cr_crapfin%ROWTYPE;

    BEGIN
      -- Buscar tipo de finalidade
      OPEN cr_crapfin(pr_cdcooper => pr_cdcooper
                     ,pr_cdfinemp => pr_cdfinemp);
      --Posicionar no proximo registro
      FETCH cr_crapfin INTO rw_crapfin;
      --Fechar Cursor
      CLOSE cr_crapfin;
      --Retornar valor
      RETURN nvl(rw_crapfin.tpfinali, 0);
    EXCEPTION
      WHEN OTHERS THEN
        --Retornar zero
        RETURN(0);
    END;
  END;

  PROCEDURE pc_busca_motivos_anulacao(pr_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE --> Tipo do produto
                                     ,pr_nrdconta  IN tbmotivo_anulacao.nrdconta%TYPE
                                     ,pr_nrctrato  IN tbmotivo_anulacao.nrctrato%TYPE
                                     ,pr_tpctrlim  IN tbmotivo_anulacao.tpctrlim%TYPE
                                     ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN
    /* .............................................................................

    Programa: pc_busca_motivos_anulacao
    Sistema : Rotinas referentes ao PRJ438
    Sigla   :
    Autor   : Paulo Martins (Mouts)
    Data    : Agosto/18.                    Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Buscar todos os motivos de anulação de emprestimos e limite de crédito

    Observacao: -----
    ..............................................................................*/

    DECLARE

        CURSOR c_motivos(pr_cdcooper  IN tbcadast_motivo_anulacao.cdcooper%TYPE
                        ,pr_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE
                        ,pr_cdmotivo  IN tbcadast_motivo_anulacao.cdmotivo%TYPE) IS
        SELECT cdmotivo,
               dsmotivo,
               null dsobservacao,
               inobservacao,
               'N' incheck,
               'S' inaltera
          FROM tbcadast_motivo_anulacao c
         WHERE c.cdcooper  = pr_cdcooper
           AND c.tpproduto = pr_tpproduto
           AND ((c.cdmotivo != pr_cdmotivo and pr_cdmotivo is not null) or
                (pr_cdmotivo is null))
           AND c.idativo   = 1;

       CURSOR c_motivos_contrato(pr_cdcooper in number) IS
       SELECT m.cdmotivo,
              m.dsmotivo,
              m.dsobservacao,
              c.inobservacao,
              'S' incheck,
              m.dtcadastro
         FROM tbmotivo_anulacao m,
              tbcadast_motivo_anulacao c
        WHERE m.cdcooper = pr_cdcooper
          and m.nrdconta = pr_nrdconta
          and m.nrctrato = pr_nrctrato
          and nvl(m.tpctrlim,0) = nvl(pr_tpctrlim,0)
          and m.cdcooper = c.cdcooper
          and m.cdmotivo = c.cdmotivo
          and c.tpproduto = pr_tpproduto;

       CURSOR c_crawepr(pr_cdcooper in number) IS
       select e.insitapr
         from crawepr e
        where e.cdcooper = pr_cdcooper
          and e.nrdconta = pr_nrdconta
          and e.nrctremp = pr_nrctrato
          and e.insitapr = 1; -- Aprovada
          --
          r_crawepr c_crawepr%rowtype;

       CURSOR c_crawlim(pr_cdcooper in number) IS
       select l.insitapr
         from crawlim l
        where l.cdcooper = pr_cdcooper
          and l.nrdconta = pr_nrdconta
          and l.nrctrlim = pr_nrctrato
          and l.tpctrlim = pr_tpctrlim
          and l.insitapr in (1,2,3);
          --
          r_crawlim c_crawlim%rowtype;


      r_motivos_contrato  c_motivos_contrato%rowtype;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis padrao
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_contador PLS_INTEGER := 0;

      -- cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      vr_inaltera VARCHAR2(1) := 'N';

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      --Buscar Data do Sistema para a cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      --Se nao encontrou
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar Cursor
        CLOSE btch0001.cr_crapdat;
        -- montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= NULL;
        -- Levantar Excecao
        RAISE vr_exc_saida;
      ELSE
        -- apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Valida Situação das propostas
      if pr_tpproduto = 1 then -- Empréstimo
        open c_crawepr(vr_cdcooper);
         fetch c_crawepr into r_crawepr;
          if c_crawepr%notfound then
            close c_crawepr;
            vr_cdcritic := 0;
            vr_dscritic := 'Somente proposta aprovada pode ser anulada!';
            raise vr_exc_saida;
          end if;
        close c_crawepr;
      elsif pr_tpproduto = 3 then -- Limite de Crédito
        open c_crawlim(vr_cdcooper);
         fetch c_crawlim into r_crawlim;
          if c_crawlim%notfound then
            close c_crawlim;
            vr_cdcritic := 0;
            vr_dscritic := 'Somente proposta aprovada pode ser anulada!';
            raise vr_exc_saida;
          end if;
        close c_crawlim;
      else
        vr_cdcritic := 0;
        vr_dscritic := 'Este produto não pode ser anulado.';
        raise vr_exc_saida;
      end if;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      open c_motivos_contrato(vr_cdcooper);
       fetch c_motivos_contrato into r_motivos_contrato;
        if c_motivos_contrato%found then
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Dados',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'inf',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => vr_contador,
                                 pr_tag_nova => 'cdmotivo',
                                 pr_tag_cont => r_motivos_contrato.cdmotivo,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => vr_contador,
                                 pr_tag_nova => 'dsmotivo',
                                 pr_tag_cont => r_motivos_contrato.dsmotivo,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => vr_contador,
                                 pr_tag_nova => 'dsobservacao',
                                 pr_tag_cont => r_motivos_contrato.dsobservacao,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => vr_contador,
                                 pr_tag_nova => 'inobservacao',
                                 pr_tag_cont => r_motivos_contrato.inobservacao,
                                 pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => vr_contador,
                                 pr_tag_nova => 'incheck',
                                 pr_tag_cont => r_motivos_contrato.incheck,
                                 pr_des_erro => vr_dscritic);

          -- Validar se é permitido alteração do motivo, somente permitido
          if rw_crapdat.dtmvtolt = r_motivos_contrato.dtcadastro then
             vr_inaltera := 'S';
          end if;

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => vr_contador,
                                 pr_tag_nova => 'inaltera',
                                 pr_tag_cont => vr_inaltera,
                                 pr_des_erro => vr_dscritic);
        vr_contador := 1;
        end if;
      close c_motivos_contrato;

      -- Busca todos os emprestimos de acordo com o numero da conta
      FOR r_motivos IN c_motivos(pr_cdcooper => vr_cdcooper,
                                 pr_tpproduto=> pr_tpproduto,
                                 pr_cdmotivo => r_motivos_contrato.cdmotivo) LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inf',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdmotivo',
                               pr_tag_cont => r_motivos.cdmotivo,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsmotivo',
                               pr_tag_cont => r_motivos.dsmotivo,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsobservacao',
                               pr_tag_cont => r_motivos.dsobservacao,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'inobservacao',
                               pr_tag_cont => r_motivos.inobservacao,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'incheck',
                               pr_tag_cont => r_motivos.incheck,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'inaltera',
                               pr_tag_cont => r_motivos.inaltera,
                               pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;

      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em empr0001.pc_busca_motivos_anulacao: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;

  END pc_busca_motivos_anulacao;

  PROCEDURE pc_grava_motivo_anulacao(pr_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE --> Tipo do produto
                                    ,pr_nrdconta  IN tbmotivo_anulacao.nrdconta%TYPE
                                    ,pr_nrctrato  IN tbmotivo_anulacao.nrctrato%TYPE
                                    ,pr_tpctrlim  IN tbmotivo_anulacao.tpctrlim%TYPE
                                    ,pr_cdmotivo  IN VARCHAR2
                                    ,pr_dsmotivo  IN VARCHAR2
                                    ,pr_dsobservacao IN VARCHAR2
                                    ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN
    /* .............................................................................

    Programa: pc_grava_motivos_anulacao
    Sistema : Rotinas referentes ao PRJ438
    Sigla   :
    Autor   : Paulo Martins (Mouts)
    Data    : Agosto/18.                    Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Gravar ou Alterar motivo de anulação de emprestimos e limite de crédito informado em tela

    Observacao: -----
    ..............................................................................*/

    DECLARE

     CURSOR c_motivo_atual(pr_cdcooper in number) IS
     SELECT m.cdmotivo,
            m.dsmotivo,
            m.dsobservacao,
            m.dtcadastro,
            m.rowid
       FROM tbmotivo_anulacao m
      WHERE m.cdcooper = pr_cdcooper
        and m.nrdconta = pr_nrdconta
        and m.nrctrato = pr_nrctrato
        and nvl(m.tpctrlim,0) = nvl(pr_tpctrlim,0);

     CURSOR cr_motivo (prc_cdcooper IN tbcadast_motivo_anulacao.cdcooper%TYPE,
                       prc_cdmotivo IN tbcadast_motivo_anulacao.cdmotivo%TYPE,
                       prc_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE) IS
       SELECT 1
         FROM tbcadast_motivo_anulacao t
        WHERE t.cdcooper  = prc_cdcooper
          AND t.cdmotivo  = prc_cdmotivo
          AND t.tpproduto = prc_tpproduto
          AND t.inobservacao = 1
        ;
        --
        r_motivo_atual c_motivo_atual%rowtype;

        -- Tratamento de erros
        vr_exc_saida EXCEPTION;

        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);

        -- cursor genérico de calendário
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;

        -- Variaveis padrao
        vr_cdcooper NUMBER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
        vr_exigeobs NUMBER;
        vr_dstpproduto VARCHAR2(25);

        vr_nrdrowid ROWID;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      pc_insere_motivo_anulacao(pr_cdcooper => vr_cdcooper,
                                pr_cdagenci => vr_cdagenci,
                                pr_nrdcaixa => vr_nrdcaixa,
                                pr_cdoperad => vr_cdoperad,
                                pr_nmdatela => vr_nmdatela,
                                pr_idorigem => vr_idorigem,
                                pr_tpproduto => pr_tpproduto,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrctrato => pr_nrctrato,
                                pr_tpctrlim => pr_tpctrlim,
                                pr_cdmotivo => pr_cdmotivo,
                                pr_dsmotivo => pr_dsmotivo,
                                pr_dsobservacao => pr_dsobservacao,
                                pr_cdcritic => vr_cdcritic,
                                pr_dscritic => vr_dscritic,
                                pr_des_erro => pr_des_erro);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

    --Salva
    COMMIT;
    --
    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em empr0001.pc_busca_motivos_anulacao: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;

  END pc_grava_motivo_anulacao;


  PROCEDURE pc_insere_motivo_anulacao(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                     ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Código da agência
                                     ,pr_nrdcaixa  IN craperr.nrdcaixa%TYPE --> Número do caixa
                                     ,pr_cdoperad  IN crapdev.cdoperad%TYPE --> Código do Operador
                                     ,pr_nmdatela  IN VARCHAR2 --> Nome da tela
                                     ,pr_idorigem  IN INTEGER --> Id do módulo de sistema
                                     ,pr_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE --> Tipo do produto
                                     ,pr_nrdconta  IN tbmotivo_anulacao.nrdconta%TYPE
                                     ,pr_nrctrato  IN tbmotivo_anulacao.nrctrato%TYPE
                                     ,pr_tpctrlim  IN tbmotivo_anulacao.tpctrlim%TYPE
                                     ,pr_cdmotivo  IN VARCHAR2
                                     ,pr_dsmotivo  IN VARCHAR2
                                     ,pr_dsobservacao IN VARCHAR2
                                     ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN
    /* .............................................................................

    Programa: pc_grava_motivos_anulacao
    Sistema : Rotinas referentes ao PRJ438
    Sigla   :
    Autor   : AmCom
    Data    : Março/18.                    Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Gravar ou Alterar motivo de anulação de emprestimos e limite de crédito informado em tela

    Observacao: -----
    ..............................................................................*/

    DECLARE

     -- Buscar dados da cooperativa
     CURSOR cr_crapcop(pr_cdcooper NUMBER) IS
        SELECT cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     CURSOR c_motivo_atual(pr_cdcooper in number) IS
     SELECT m.cdmotivo,
            m.dsmotivo,
            m.dsobservacao,
            m.dtcadastro,
            m.rowid
       FROM tbmotivo_anulacao m
      WHERE m.cdcooper = pr_cdcooper
        and m.nrdconta = pr_nrdconta
        and m.nrctrato = pr_nrctrato
        and nvl(m.tpctrlim,0) = nvl(pr_tpctrlim,0);

     CURSOR cr_motivo (prc_cdcooper IN tbcadast_motivo_anulacao.cdcooper%TYPE,
                       prc_cdmotivo IN tbcadast_motivo_anulacao.cdmotivo%TYPE,
                       prc_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE) IS
       SELECT 1
         FROM tbcadast_motivo_anulacao t
        WHERE t.cdcooper  = prc_cdcooper
          AND t.cdmotivo  = prc_cdmotivo
          AND t.tpproduto = prc_tpproduto
          AND t.inobservacao = 1
        ;
      --
      r_motivo_atual c_motivo_atual%rowtype;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Variaveis padrao
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_exigeobs NUMBER;
      vr_dstpproduto VARCHAR2(25);

      vr_nrdrowid ROWID;

    BEGIN

      -- Buscar Dados do Sistema para a cooperativa
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
       IF cr_crapcop%NOTFOUND
        THEN
          CLOSE cr_crapcop;
          vr_cdcritic := 0;
          vr_dscritic := 'Cooperativa invalida!';
          raise vr_exc_saida;
       END IF;
      CLOSE cr_crapcop;

      vr_cdcooper := rw_crapcop.cdcooper;
      vr_cdoperad := pr_cdoperad;
      vr_cdagenci := pr_cdagenci;
      vr_nrdcaixa := pr_nrdcaixa;
      vr_idorigem := pr_idorigem;

      --Buscar Data do Sistema para a cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      --Se nao encontrou
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar Cursor
        CLOSE btch0001.cr_crapdat;
        -- montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= NULL;
        -- Levantar Excecao
        RAISE vr_exc_saida;
      ELSE
        -- apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      --Regras para alteração
      --1 dsobservacao (Opçãoes com observação) mínimo 10 máximo 50 caracteres
      --2 Alteração somente no mesmo dia
      vr_exigeobs := 0;
      FOR rw_motivo IN cr_motivo(vr_cdcooper,
                                 pr_cdmotivo,
                                 pr_tpproduto) LOOP
        vr_exigeobs := 1;
      END LOOP;
      --
      IF vr_exigeobs = 1 AND (length(pr_dsobservacao) < 10 OR length(pr_dsobservacao) > 50 OR
         TRIM(pr_dsobservacao) IS NULL) THEN
         vr_cdcritic := 1289;
         RAISE vr_exc_saida;
      END IF;
      IF pr_tpproduto = 1 THEN
        vr_dstpproduto := 'EMPRESTIMO';
        vr_nmdatela := 'PROPOSTA';
      ELSE
        vr_dstpproduto := 'LIMITE DESCTO TITULO';
        vr_nmdatela := 'TITULO';
      END IF;
      open c_motivo_atual(vr_cdcooper);
       fetch c_motivo_atual into r_motivo_atual;
        if c_motivo_atual%found then
          -- Validar se alteração é no dia.
          if rw_crapdat.dtmvtolt > r_motivo_atual.dtcadastro then
            close c_motivo_atual;
            vr_cdcritic := 1290;
            raise vr_exc_saida;
          end if;
          --
          -- Gravar LOG
          GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => pr_idorigem
                              ,pr_dstransa => 'Atualizacao do motivo de Anulacao'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => 0
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

          --Motivo é o mesmo atualiza
          if pr_cdmotivo = r_motivo_atual.cdmotivo then
            begin
              update tbmotivo_anulacao m
                 set m.dsmotivo = pr_dsmotivo,
                     m.dsobservacao = pr_dsobservacao
               where m.rowid = r_motivo_atual.rowid;
            exception
              when others then
               close c_motivo_atual;
               vr_cdcritic := 0;
               vr_dscritic := 'Erro ao atualizar motivo empr0001.pc_grava_motivo_anulacao: '||sqlerrm;
               raise vr_exc_saida;
            end;
            --
            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Cod Motivo'
                                     ,pr_dsdadant => pr_cdmotivo
                                     ,pr_dsdadatu => pr_cdmotivo);
            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Desc. Motivo'
                                     ,pr_dsdadant => pr_dsmotivo
                                     ,pr_dsdadatu => pr_dsmotivo);
            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Observacao'
                                     ,pr_dsdadant => nvl(r_motivo_atual.dsobservacao,' ')
                                     ,pr_dsdadatu => nvl(pr_dsobservacao,' '));
            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Tipo Produto'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => vr_dstpproduto);

          else
            --deleta o motivo atual e insere o novo
            begin
              delete from tbmotivo_anulacao where rowid = r_motivo_atual.rowid;
            exception
             when others then
              close c_motivo_atual;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao deletar motivo empr0001.pc_grava_motivo_anulacao: '||sqlerrm;
              raise vr_exc_saida;
            end;
            -- Insere o motivo
            begin
              insert into tbmotivo_anulacao(cdcooper,
                                            nrdconta,
                                            nrctrato,
                                            tpctrlim,
                                            dtcadastro,
                                            cdmotivo,
                                            dsmotivo,
                                            dsobservacao,
                                            cdoperad) values (vr_cdcooper,
                                                              pr_nrdconta,
                                                              pr_nrctrato,
                                                              pr_tpctrlim,
                                                              rw_crapdat.dtmvtolt,
                                                              pr_cdmotivo,
                                                              pr_dsmotivo,
                                                              pr_dsobservacao,
                                                              vr_cdoperad);
            exception
              when others then
                close c_motivo_atual;
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao inserir motivo empr0001.pc_grava_motivo_anulacao: '||sqlerrm;
                raise vr_exc_saida;
            end;
            --
            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Cod Motivo'
                                     ,pr_dsdadant => r_motivo_atual.cdmotivo
                                     ,pr_dsdadatu => pr_cdmotivo);
            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Desc. Motivo'
                                     ,pr_dsdadant => r_motivo_atual.dsmotivo
                                     ,pr_dsdadatu => pr_dsmotivo);
            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Observacao'
                                     ,pr_dsdadant => nvl(r_motivo_atual.dsobservacao,' ')
                                     ,pr_dsdadatu => nvl(pr_dsobservacao,' '));
            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Tipo Produto'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => vr_dstpproduto);
          end if;
        else
          -- Insere o motivo
          BEGIN
            insert into tbmotivo_anulacao(cdcooper,
                                          nrdconta,
                                          nrctrato,
                                          tpctrlim,
                                          dtcadastro,
                                          cdmotivo,
                                          dsmotivo,
                                          dsobservacao,
                                          cdoperad) values (vr_cdcooper,
                                                            pr_nrdconta,
                                                            pr_nrctrato,
                                                            pr_tpctrlim,
                                                            rw_crapdat.dtmvtolt,
                                                            pr_cdmotivo,
                                                            pr_dsmotivo,
                                                            pr_dsobservacao,
                                                            vr_cdoperad);
          EXCEPTION
            when others then
              close c_motivo_atual;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir motivo empr0001.pc_grava_motivo_anulacao: '||sqlerrm;
              raise vr_exc_saida;
          end;
          if pr_tpproduto = 1 then -- Empréstimo
            begin
              update crawepr e
                 set e.dtanulac = rw_crapdat.dtmvtolt,
                     e.insitest = 6 -- Anulada
               where e.cdcooper = vr_cdcooper
                 and e.nrdconta = pr_nrdconta
                 and e.nrctremp = pr_nrctrato;
            exception
              when others then
                close c_motivo_atual;
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar emprestimo empr0001.pc_grava_motivo_anulacao: '||sqlerrm;
                raise vr_exc_saida;
            end;
          elsif pr_tpproduto = 3 then -- Limite de Crédito
            begin
              update crawlim l
                 set l.dtanulac = rw_crapdat.dtmvtolt,
                     l.insitlim = 9 -- Anulada
               where l.cdcooper = vr_cdcooper
                 and l.nrdconta = pr_nrdconta
                 and l.nrctrlim = pr_nrctrato
                 and l.tpctrlim = pr_tpctrlim;
            exception
              when others then
                close c_motivo_atual;
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar limite de crédito empr0001.pc_grava_motivo_anulacao: '||sqlerrm;
                raise vr_exc_saida;
            end;
          end if;
          -- Gravar LOG
          GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_idorigem
                              ,pr_dstransa => 'Inclusao do motivo de anulacao'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => 0
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Cod Motivo'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => pr_cdmotivo);
            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Desc. Motivo'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => pr_dsmotivo);
            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Observacao'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => NVL(pr_dsobservacao,' '));
            -- Gravar Item do LOG
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Tipo Produto'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => vr_dstpproduto);
        end if;
      close c_motivo_atual;

    --
    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        pr_des_erro := 'NOK';

      WHEN OTHERS THEN

        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em empr0001.pc_insere_motivo_anulacao: ' || SQLERRM;

    END;

  END pc_insere_motivo_anulacao;

END empr0001;
/
