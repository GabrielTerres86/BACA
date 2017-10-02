CREATE OR REPLACE PACKAGE CECRED.EMPR0011 IS

  /* Type das parcelas do Pos-Fixado */
  TYPE typ_reg_tab_parcelas IS RECORD(
       nrparepr     crappep.nrparepr%TYPE
      ,vlparepr     crappep.vlparepr%TYPE
      ,dtvencto     crappep.dtvencto%TYPE
      ,insitpar     PLS_INTEGER -- (1 - Em dia, 2 - Vencida, 3 - A Vencer)
      ,vlpagpar     crappep.vlpagpar%TYPE
      ,vlmtapar     crappep.vlmtapar%TYPE
      ,vlmrapar     crappep.vlmrapar%TYPE
      ,vlsdvpar     crappep.vlsdvpar%TYPE
      ,vldescto     crappep.vldespar%TYPE
      ,vlatupar     NUMBER(25,2)
      ,flcarenc     PLS_INTEGER
      ,vlrdtaxa     craptxi.vlrdtaxa%TYPE
      ,taxa_periodo NUMBER(25,10));
    
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_parcelas IS TABLE OF typ_reg_tab_parcelas INDEX BY BINARY_INTEGER;
  
  /* Type das parcelas do Pos-Fixado */
  TYPE typ_reg_tab_price IS RECORD(
       vlparepr             crappep.vlparepr%TYPE := 0
      ,taxa_periodo         NUMBER(25,8)          := 0
      ,fator_juros_nominais NUMBER(25,10)         := 0
      ,fator_correcao       NUMBER(25,10)         := 0
      ,fator_acumulado      NUMBER(25,10)         := 0
      ,fator_price          NUMBER(25,10)         := 0
      ,juros_correcao       NUMBER(25,2)          := 0
      ,juros_remuneratorio  NUMBER(25,2)          := 0
      ,saldo_projetado      NUMBER(25,2)          := 0
      ,saldo_devedor        NUMBER(25,2)          := 0
      ,vlrdtaxa             craptxi.vlrdtaxa%TYPE);
        
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_price IS TABLE OF typ_reg_tab_price INDEX BY BINARY_INTEGER;
  
  -- Tipos e tabelas de memória para armazenar os dados do feriado
  TYPE typ_tab_feriado IS
    TABLE OF crapfer.dtferiad%TYPE
      INDEX BY VARCHAR2(20); --> A chave será a cdcooper(10) + data(10)
  -- Vetor para armazenamento
  vr_tab_feriado typ_tab_feriado;
  
  -- Tipos e tabelas de memória para armazenar os dados do feriado
  TYPE typ_tab_data_calculo IS
    TABLE OF DATE
      INDEX BY VARCHAR2(8);

  PROCEDURE pc_calcula_prox_parcela_pos(pr_cdcooper        IN  crapepr.cdcooper%TYPE --> Codigo da Cooperativa
                                       ,pr_flgbatch        IN  BOOLEAN DEFAULT FALSE --> Indica se o processo noturno estah rodando
                                       ,pr_dtcalcul        IN  crapdat.dtmvtolt%TYPE --> Data do cálculo
                                       ,pr_dtefetiv        IN  crapepr.dtmvtolt%TYPE --> Data de efetivação da proposta
                                       ,pr_dtpripgt        IN  crawepr.dtdpagto%TYPE --> Data do Primeiro Pagamento
                                       ,pr_dtcarenc        IN  crawepr.dtcarenc%TYPE --> Data da Carencia
                                       ,pr_txmensal        IN  crapepr.txmensal%TYPE --> Taxa Mensal do Contrato
                                       ,pr_qtpreemp        IN  crapepr.qtpreemp%TYPE --> Quantidade de Prestacoes do Emprestimo
                                       ,pr_vlsprojt        IN  crapepr.vlsprojt%TYPE --> Saldo Devedor Projetado
                                       ,pr_qtdias_carencia IN  tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias de Carencia
                                       ,pr_vlrdtaxa        IN  craptxi.vlrdtaxa%TYPE --> Valor da Taxa
                                       ,pr_nrparepr        IN  crappep.nrparepr%TYPE --> Numero da Parcela
                                       ,pr_dtvencto        IN  crappep.dtvencto%TYPE --> Data de Vencimento da Parcela                                   
                                       ,pr_tab_parcelas    OUT typ_tab_parcelas      --> Temp-Table das parcelas
                                       ,pr_cdcritic        OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                       ,pr_dscritic        OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_calcula_parcelas_pos_fixado(pr_cdcooper        IN crapcop.cdcooper%TYPE      --> Codigo da Cooperativa
                                          ,pr_flgbatch        IN BOOLEAN DEFAULT FALSE      --> Indica se o processo noturno estah rodando
                                          ,pr_dtcalcul        IN crapdat.dtmvtolt%TYPE      --> Data de Calculo
                                          ,pr_cdlcremp        IN craplcr.cdlcremp%TYPE      --> Codigo da Linha de Credito
                                          ,pr_dtcarenc        IN crawepr.dtcarenc%TYPE      --> Data da Carencia do Contrato
                                          ,pr_qtdias_carencia IN tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias de Carencia
                                          ,pr_dtdpagto        IN crapepr.dtdpagto%TYPE      --> Data de Pagamento
                                          ,pr_qtpreemp        IN crapepr.qtpreemp%type      --> Quantidade de Prestacoes
                                          ,pr_vlemprst        IN crapepr.vlemprst%TYPE      --> Valor do Emprestimo
                                          ,pr_tab_parcelas    OUT typ_tab_parcelas          --> Parcelas do Emprestimo
                                          ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                          ,pr_dscritic        OUT crapcri.dscritic%TYPE);
                                       
  PROCEDURE pc_calcula_atraso_pos_fixado (pr_dtcalcul IN  crapdat.dtmvtolt%TYPE   --> Data de Calculo
                                         ,pr_vlparepr IN  crappep.vlparepr%TYPE   --> Valor da Parcela
                                         ,pr_dtvencto IN  crappep.dtvencto%TYPE   --> Data de Vencimento da Parcela
                                         ,pr_dtultpag IN  crappep.dtultpag%TYPE   --> Data do Ultimo Pagamento
                                         ,pr_vlsdvpar IN  crappep.vlsdvpar%TYPE   --> Saldo Devedor da Parcela
                                         ,pr_perjurmo IN  craplcr.perjurmo%TYPE   --> Percentual do Juros de Mora
                                         ,pr_vlpagmta IN  crappep.vlpagmta%TYPE   --> Valor Pago de Mula
                                         ,pr_percmult IN  NUMBER                  --> Percentual de Multa
                                         ,pr_qttolatr IN  crapepr.qttolatr%TYPE   --> Quantidade de Tolerancia para Cobrar Multa/Juros de Mora
                                         ,pr_vlmrapar OUT NUMBER                  --> Juros de Mora Atualizado
                                         ,pr_vlmtapar OUT NUMBER                  --> Multa Atualizado
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo da critica
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_calcula_desconto_pos_web(pr_dtcalcul     IN VARCHAR2              --> Data do calculo
                                       ,pr_cdcooper     IN crapepr.cdcooper%TYPE --> Codigo da Cooperativa
                                       ,pr_nrdconta     IN crapepr.nrdconta%TYPE --> Numero da Conta
                                       ,pr_nrctremp     IN crapepr.nrctremp%TYPE --> Numero do Contrato                                          
                                       ,pr_nrparepr     IN crappep.nrparepr%TYPE --> Numero da Parcela
                                       ,pr_vlsdvpar     IN crappep.vlsdvpar%TYPE --> Saldo Devedor da Parcela
                                       ,pr_xmllog       IN VARCHAR2              --> XML com informacoes de LOG
                                       ,pr_cdcritic    OUT PLS_INTEGER           --> Codigo da critica
                                       ,pr_dscritic    OUT VARCHAR2              --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                       ,pr_nmdcampo    OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro    OUT VARCHAR2);            --> Erros do processo
                                           
  PROCEDURE pc_busca_pagto_parc_pos(pr_cdcooper     IN  crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                   ,pr_flgbatch     IN BOOLEAN DEFAULT FALSE      --> Indica se o processo noturno estah rodando
                                   ,pr_dtcalcul     IN  crapdat.dtmvtolt%TYPE     --> Data de calculo das parcelas
                                   ,pr_nrdconta     IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                   ,pr_nrctremp     IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                   ,pr_tab_parcelas OUT EMPR0011.typ_tab_parcelas --> Temp-Table contendo todas as parcelas calculadas
                                   ,pr_cdcritic     OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                   ,pr_dscritic     OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_busca_pagto_parc_pos_prog(pr_cdcooper  IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                        ,pr_dtcalcul  IN VARCHAR2                  --> Data de calculo das parcelas
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do Contrato
                                        ,pr_vlpreapg OUT NUMBER                    --> Valor atualizado
                                        ,pr_vlprvenc OUT NUMBER                    --> Parcela Vencida
                                        ,pr_vlpraven OUT NUMBER                    --> Parcela EM DIA + Parcela A VENCER
                                        ,pr_vlmtapar OUT NUMBER                    --> Valor da multa por atraso
                                        ,pr_vlmrapar OUT NUMBER                    --> Valor de juros pelo atraso
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_busca_pagto_parc_pos_web(pr_cdcooper     IN crapepr.cdcooper%TYPE      --> Codigo da Cooperativa
                                       ,pr_dtcalcul     IN VARCHAR2                   --> Data de calculo das parcelas
                                       ,pr_nrdconta     IN crapepr.nrdconta%TYPE      --> Numero da Conta Corrente
                                       ,pr_nrctremp     IN crapepr.nrctremp%TYPE      --> Numero do Contrato
                                       ,pr_xmllog       IN VARCHAR2                   --> XML com informacoes de LOG
                                       ,pr_cdcritic    OUT PLS_INTEGER                --> Codigo da critica
                                       ,pr_dscritic    OUT VARCHAR2                   --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype             --> Arquivo de retorno do XML
                                       ,pr_nmdcampo    OUT VARCHAR2                   --> Nome do campo com erro
                                       ,pr_des_erro    OUT VARCHAR2);                 --> Erros do processo
                                       
  /*PROCEDURE pc_calcula_iof_pos_fixado(pr_vltariof OUT NUMBER                    --> Valor de IOF
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica
                                     */

  PROCEDURE pc_valida_dados_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                      ,pr_qtparepr  IN crapepr.qtpreemp%TYPE     --> Quantidade de parcelas
                                      ,pr_dtlibera  IN crawepr.dtlibera%TYPE     --> Data da liberacao
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_dtcarenc  IN crawepr.dtcarenc%TYPE     --> Data da Carencia
                                      ,pr_flgpagto  IN crapepr.flgpagto%TYPE     --> Debito Folha: 0-Nao/1-Sim
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_grava_parcel_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                      ,pr_dtcalcul  IN crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                      ,pr_qtparepr  IN crapepr.qtpreemp%TYPE     --> Quantidade de parcelas
                                      ,pr_dtcarenc  IN crawepr.dtcarenc%TYPE     --> Data da Carência
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_vlpreemp OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                      ,pr_txdiaria OUT crawepr.txdiaria%TYPE     --> Taxa diaria
                                      ,pr_txmensal OUT crawepr.txmensal%TYPE     --> Taxa mensal
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_busca_vl_prest_pos_prog(pr_cdcooper  IN crapepr.cdcooper%TYPE   --> Codigo da Cooperativa
                                      ,pr_dtcalcul  IN crapdat.dtmvtoan%TYPE   --> Data de Calculo
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE   --> Codigo da linha de credito
                                      ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE   --> Quantidade de prestacoes
                                      ,pr_dtcarenc  IN crawepr.dtcarenc%TYPE   --> Data de Pagamento da Primeira Carência
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE   --> Data do pagamento
                                      ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE   --> Valor do saldo devedor
                                      ,pr_vlpreemp OUT crapepr.vlpreemp%TYPE   --> Valor da prestacao
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao da critica

  PROCEDURE pc_alt_numero_parcelas_pos(pr_cdcooper      IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_nrdconta      IN crapass.nrdconta%TYPE     --> Numero da Conta
                                      ,pr_nrctremp_old  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_nrctremp_new  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_cdcritic     OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic     OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_exclui_prop_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                     ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_efetua_credito_conta(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                   ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                   ,pr_cdprogra  IN crapprg.cdprogra%TYPE     --> Codigo Programa
                                   ,pr_inpessoa  IN crapass.inpessoa%TYPE     --> Tipo de pessoa
                                   ,pr_cdagenci  IN crapage.cdagenci%TYPE     --> Codigo da agencia
                                   ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                   ,pr_cdpactra  IN crapage.cdagenci%TYPE     --> Codigo do PA de Transacao
                                   ,pr_cdoperad  IN crapope.cdoperad%TYPE     --> Codigo do Operador
                                   ,pr_vltottar OUT NUMBER                    --> Valor da tarifa
                                   ,pr_vltariof OUT NUMBER                    --> Valor do IOF
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_busca_tip_atualiz_index(pr_cddindex       IN tbepr_posfix_param_index.cddindex%TYPE      --> Codigo do indice (FK crapind)
                                      ,pr_tpatualizacao OUT tbepr_posfix_param_index.tpatualizacao%TYPE --> Tipo de Atualizacao Indexador
                                      ,pr_cdcritic      OUT crapcri.cdcritic%TYPE                       --> Codigo da critica
                                      ,pr_dscritic      OUT crapcri.dscritic%TYPE);                     --> Descricao da critica
  
  PROCEDURE pc_efetua_lcto_juros_remun(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtcalcul IN  crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                      ,pr_cdagenci IN  crapage.cdagenci%TYPE     --> Codigo da Agencia
                                      ,pr_cdpactra IN  crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                      ,pr_cdoperad IN  crapope.cdoperad%TYPE     --> Codigo do Operador
                                      ,pr_cdorigem IN  NUMBER                    --> Codigo da Origem
                                      ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                      ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                      ,pr_txjuremp IN  crapepr.txjuremp%TYPE     --> Taxa de Juros do Emprestimo
                                      ,pr_vlpreemp IN  crapepr.vlpreemp%TYPE     --> Valor da prestacao do Emprestimo
                                      ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de Liberacao do Contrato
                                      ,pr_dtrefjur IN  crapepr.dtrefjur%TYPE     --> Data do lancamento de Juros
                                      ,pr_floperac IN  BOOLEAN                   --> Flag do contrato de Financiamento
                                      ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                      ,pr_vlsprojt IN  crapepr.vlsdeved%TYPE     --> Valor do Saldo Devedor Projetado
                                      ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando a mensal
                                      ,pr_txdiaria IN  NUMBER                    --> Taxa Diaria do Contrato
                                      ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                      ,pr_vljuremu OUT NUMBER                    --> Juros Remuneratorios
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_efetua_lcto_juros_correc (pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                        ,pr_dtcalcul IN  crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                        ,pr_cdagenci IN  crapage.cdagenci%TYPE     --> Codigo da Agencia
                                        ,pr_cdpactra IN  crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                        ,pr_cdoperad IN  crapope.cdoperad%TYPE     --> Codigo do Operador
                                        ,pr_cdorigem IN  NUMBER                    --> Codigo da Origem
                                        ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                        ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente                                        
                                        ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                        ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de liberacao do Contrato
                                        ,pr_dtrefjur IN  DATE                      --> Data de Referencia de lancamento de Juros
                                        ,pr_vlrdtaxa IN  NUMBER                    --> Valor da Taxa de Atualizacao da Parcela
                                        ,pr_txjuremp IN  crapepr.txjuremp%TYPE     --> Taxa de Juros do Emprestimo
                                        ,pr_vlpreemp IN  crapepr.vlpreemp%TYPE     --> Valor da prestacao do Emprestimo
                                        ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                        ,pr_vlsprojt IN  NUMBER                    --> Saldo Devedor Projetado
                                        ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando a mensal
                                        ,pr_floperac IN  BOOLEAN                   --> Indicador se a Operacao eh Financiamento
                                        ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                        ,pr_vljurcor OUT NUMBER                    --> Juros de Correcao
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_efetua_pagamento_em_dia(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtcalcul IN  crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                      ,pr_cdagenci IN  crapage.cdagenci%TYPE     --> Codigo da Agencia
                                      ,pr_cdpactra IN  crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                      ,pr_cdoperad IN  crapope.cdoperad%TYPE     --> Codigo do Operador
                                      ,pr_cdorigem IN  NUMBER                    --> Codigo da Origem
                                      ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                      ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                      ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                      ,pr_vlpreemp IN  crapepr.vlpreemp%TYPE     --> Valor da prestacao do emprestimo
                                      ,pr_qtprepag IN  crapepr.qtprepag%TYPE     --> Quantidade de prestacoes pagas
                                      ,pr_qtprecal IN  crapepr.qtprecal%TYPE     --> Quantidade de prestacoes calculadas
                                      ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de liberacao do Contrato
                                      ,pr_dtrefjur IN  DATE                      --> Data de Referencia de lancamento de Juros
                                      ,pr_vlrdtaxa IN  NUMBER                    --> Valor da Taxa de Atualizacao da Parcela
                                      ,pr_txdiaria IN  NUMBER                    --> Taxa diaria
                                      ,pr_txjuremp IN  crapepr.txjuremp%TYPE     --> Taxa de Juros do Emprestimo
                                      ,pr_vlsprojt IN  NUMBER                    --> Saldo Devedor Projetado
                                      ,pr_floperac IN  BOOLEAN                   --> Indicador se a Operacao eh Financiamento
                                      ,pr_nrseqava IN  PLS_INTEGER               --> Sequencia de pagamento de avalista
                                      ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                      ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de vencimento
                                      ,pr_vlpagpar IN  crappep.vlparepr%TYPE     --> Valor a pagar da Parcela
                                      ,pr_vlsdvpar IN  crappep.vlsdvpar%TYPE     --> Saldo Devedor da Parcela
                                      ,pr_vlsdvatu IN  NUMBER                    --> Saldo Atualizado da Parcela
                                      ,pr_vljura60 IN  crappep.vljura60%TYPE     --> Valor do Juros60
                                      ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando a mensal
                                      ,pr_vlsldisp IN  NUMBER DEFAULT 0          --> Valor Saldo Disponivel
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_efetua_pagamento_em_atraso(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                         ,pr_dtcalcul IN  crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                         ,pr_cdagenci IN  crapage.cdagenci%TYPE     --> Codigo da Agencia
                                         ,pr_cdpactra IN  crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                         ,pr_cdoperad IN  crapope.cdoperad%TYPE     --> Codigo do Operador
                                         ,pr_cdorigem IN  NUMBER                    --> Codigo da Origem
                                         ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                         ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                         ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                         ,pr_vlpreemp IN  crapepr.vlpreemp%TYPE     --> Valor da prestacao do emprestimo
                                         ,pr_qtprepag IN  crapepr.qtprepag%TYPE     --> Quantidade de prestacoes pagas
                                         ,pr_qtprecal IN  crapepr.qtprecal%TYPE     --> Quantidade de prestacoes calculadas
                                         ,pr_txjuremp IN  crapepr.txjuremp%TYPE     --> Taxa de Juros do Emprestimo
                                         ,pr_qttolatr IN  crapepr.qttolatr%TYPE     --> Tolerancia para cobranca de multa e mora em atraso
                                         ,pr_floperac IN  BOOLEAN                   --> Indicador se a Operacao eh Financiamento
                                         ,pr_nrseqava IN  PLS_INTEGER               --> Sequencia de pagamento de avalista
                                         ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                         ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de vencimento
                                         ,pr_dtultpag IN  crappep.dtultpag%TYPE     --> Data do ultimo pagamento
                                         ,pr_vlparepr IN  crappep.vlparepr%TYPE     --> Valor da parcela
                                         ,pr_vlpagpar IN  crappep.vlparepr%TYPE     --> Valor a pagar da Parcela
                                         ,pr_vlsdvpar IN  crappep.vlsdvpar%TYPE     --> Saldo Devedor da Parcela
                                         ,pr_vlsdvatu IN  NUMBER                    --> Saldo Atualizado da Parcela
                                         ,pr_vljura60 IN  crappep.vljura60%TYPE     --> Valor do Juros60
                                         ,pr_vlpagmta IN  crappep.vlpagmta%TYPE     --> Valor pago da multa
                                         ,pr_perjurmo IN  craplcr.perjurmo%TYPE     --> Contem o percentual de juros de mora por atraso
                                         ,pr_percmult IN  NUMBER                    --> Percentual de Multa
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_valida_pagamentos_pos(pr_cdcooper    IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                    ,pr_nrdconta    IN crapass.nrdconta%TYPE     --> Numero da conta
                                    ,pr_cdagenci    IN crapage.cdagenci%TYPE     --> Codigo Agencia
                                    ,pr_nrdcaixa    IN crapbcx.nrdcaixa%TYPE     --> Numero do caixa
                                    ,pr_cdoperad    IN crapope.cdoperad%TYPE     --> Codigo do operador
                                    ,pr_rw_crapdat  IN BTCH0001.cr_crapdat%ROWTYPE --> Calendario
                                    ,pr_tpemprst    IN crawepr.tpemprst%TYPE     --> Tipo do emprestimo
                                    ,pr_dtlibera    IN crawepr.dtlibera%TYPE     --> Data da liberacao
                                    ,pr_vllimcre    IN crapass.vllimcre%TYPE     --> Valor do limite de credito
                                    ,pr_flgcrass    IN BOOLEAN                   --> Flag de controle do BATCH
                                    ,pr_nrctrliq_1  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 1
                                    ,pr_nrctrliq_2  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 2
                                    ,pr_nrctrliq_3  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 3
                                    ,pr_nrctrliq_4  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 4
                                    ,pr_nrctrliq_5  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 5
                                    ,pr_nrctrliq_6  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 6
                                    ,pr_nrctrliq_7  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 7
                                    ,pr_nrctrliq_8  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 8
                                    ,pr_nrctrliq_9  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 9
                                    ,pr_nrctrliq_10 IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 10
                                    ,pr_vlapagar    IN NUMBER                    --> Valor a Pagar
                                    ,pr_vlsldisp   OUT NUMBER                    --> Valor Saldo Disponivel
                                    ,pr_cdcritic   OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                    ,pr_dscritic   OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_valida_pagamentos_pos_web(pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                                        ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                                        ,pr_vlapagar   IN NUMBER                --> Valor a Pagar
                                        ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_gera_pagto_pos_web(pr_dtcalcul   IN VARCHAR2              --> Data de calculo das parcelas
                                 ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                                 ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                                 ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Sequencia do titular
                                 ,pr_cdpactra   IN crapage.cdagenci%TYPE --> Codigo da Agencia Trabalho
                                 ,pr_nrseqava   IN PLS_INTEGER           --> Sequencia de pagamento de avalista
                                 ,pr_dadosprc   IN CLOB                  --> Dados das parcelas selecionadas
                                 ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                 ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_busca_prest_pago_mes_pos(pr_cdcooper  IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                       ,pr_nrdconta  IN crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                       ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do Contrato
                                       ,pr_dtmvtolt  IN VARCHAR2                  --> Data de calculo das parcelas
                                       ,pr_vllanmto OUT NUMBER                    --> Valor do lancamento
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_busca_prest_principal_pos(pr_cdcooper  IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                        ,pr_dtefetiv  IN crapepr.dtmvtolt%TYPE     --> Data de Efetivação do Emprestimo
                                        ,pr_dtcalcul  IN crapdat.dtmvtolt%TYPE     --> Data de calculo das parcelas
                                        ,pr_cdlcremp  IN craplcr.cdlcremp%TYPE     --> Codigo da Linha de Credito
                                        ,pr_dtcarenc  IN crawepr.dtcarenc%TYPE     --> Data de Pagamento da Primeira Carencia
                                        ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                        ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE     --> Quantidade de prestacoes
                                        ,pr_vlemprst  IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                        ,pr_vlpreemp OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                        ,pr_vljurcor OUT crapepr.vlpreemp%TYPE     --> Valor do Juros de Correcao
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_efetua_liquidacao_empr_pos(pr_cdcooper   IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                         ,pr_nrdconta   IN crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                         ,pr_nrctremp   IN crapepr.nrctremp%TYPE     --> Numero do Contrato
                                         ,pr_rw_crapdat IN BTCH0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                         ,pr_cdagenci   IN crapage.cdagenci%TYPE     --> Codigo da Agencia
                                         ,pr_cdpactra   IN crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                         ,pr_cdoperad   IN crapope.cdoperad%TYPE     --> Codigo do Operador
                                         ,pr_nrdcaixa   IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                         ,pr_cdorigem   IN NUMBER                    --> Codigo da Origem
                                         ,pr_nmdatela   IN VARCHAR2                  --> Nome da tela
                                         ,pr_floperac   IN BOOLEAN                   --> Indicador se a Operacao eh Financiamento
                                         ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                         ,pr_dscritic  OUT crapcri.dscritic%TYPE);   --> Descricao da critica
                                         
END EMPR0011;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0011 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0011
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Jaison Fernando
  --  Data     : Abril - 2017                 Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas para calculo do emprestimo Pos-Fixado.
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------
  PROCEDURE pc_calcula_qtd_dias_uteis(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_flgbatch     IN BOOLEAN DEFAULT FALSE --> Indica se o processo noturno estah rodando
                                     ,pr_dtefetiv     IN crapepr.dtmvtolt%TYPE --> Data de Efetivação da Proposta
                                     ,pr_datainicial  IN DATE                  --> Data Inicial
                                     ,pr_datafinal    IN DATE                  --> Data Final
                                     ,pr_qtdiaute    OUT PLS_INTEGER           --> Quantidade de dias uteis
                                     ,pr_cdcritic    OUT PLS_INTEGER           --> Codigo da critica
                                     ,pr_dscritic    OUT VARCHAR2 ) IS         --> Descricao da critica
    BEGIN
      /* ..............................................................................
      Programa: pc_calcula_qtd_dias_uteis
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : James Prust Junior
      Data    : Abril/2017                        Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina de calculo de dias uteis.

      Alteracoes: 
      .................................................................................*/
      DECLARE
        vr_dtmvtolt  DATE;
        vr_dtferiado DATE;
        vr_indx      VARCHAR2(20);

        CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE
                         ,pr_dtferiad IN crapfer.dtferiad%TYPE) IS
          SELECT dtferiad
            FROM crapfer
           WHERE cdcooper = pr_cdcooper
             AND (dtferiad = pr_dtferiad OR pr_dtferiad IS NULL);
        rw_crapfer cr_crapfer%ROWTYPE;

      BEGIN
        -- Caso a data inicial seja igual a data da efetivação, o cálculo irá iniciar no dia
        IF pr_datainicial = pr_dtefetiv THEN
          vr_dtmvtolt := pr_datainicial;  
        ELSE
          vr_dtmvtolt := pr_datainicial + 1;
        END IF;
        
        -- Condicao para verificar se está sendo calculado no processo noturno
        IF pr_flgbatch THEN
          IF NOT vr_tab_feriado.EXISTS(lpad(pr_cdcooper,10,'0')||LPAD(TO_CHAR(vr_dtmvtolt,'RRRRMMDD'),10,'0')) THEN
            -- Buscar todos os associados
            FOR rw_crapfer IN cr_crapfer (pr_cdcooper => pr_cdcooper
                                         ,pr_dtferiad => NULL) LOOP
              -- Carregar o vetor chaveando pela conta
              vr_tab_feriado(lpad(pr_cdcooper,10,'0')||lpad(LPAD(TO_CHAR(rw_crapfer.dtferiad,'RRRRMMDD'),10,'0'),10,'0')) := rw_crapfer.dtferiad;
            END LOOP;
          END IF;
        END IF;
        
        pr_qtdiaute := 0;
        WHILE vr_dtmvtolt <= pr_datafinal LOOP
          vr_dtferiado := NULL;          
          -- Condicao para verificar se estah rodando o processo noturno
          IF pr_flgbatch THEN
            -- Indixe para procurar na temp-table
            vr_indx := lpad(pr_cdcooper,10,'0')||LPAD(TO_CHAR(vr_dtmvtolt,'RRRRMMDD'),10,'0');
            -- Condicao para verificar se a data é um feriado
            IF vr_tab_feriado.EXISTS(vr_indx) THEN
              vr_dtferiado := vr_tab_feriado(vr_indx);
            END IF;
          ELSE
            OPEN cr_crapfer(pr_cdcooper, vr_dtmvtolt);
            FETCH cr_crapfer INTO vr_dtferiado;
            CLOSE cr_crapfer;
          END IF;          
          -- Se não encontrar
          IF vr_dtferiado IS NULL AND TO_CHAR(vr_dtmvtolt, 'D') NOT IN (1,7) THEN
            pr_qtdiaute := pr_qtdiaute + 1;
          END IF;

          vr_dtmvtolt := vr_dtmvtolt + 1;
        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em pc_calcula_qtd_dias_uteis: ' || SQLERRM;        
      END;

  END pc_calcula_qtd_dias_uteis;
  
  PROCEDURE pc_calcula_dias360(pr_ehmensal   IN BOOLEAN                -- Indica se juros esta rodando na mensal
                              ,pr_dtvencto   IN crappep.dtvencto%TYPE  --> Data de Vencimento
                              ,pr_dtrefjur   IN DATE                   --> Data de Referencia do lancamento de juros
                              ,pr_data_final IN DATE                   --> Data Final
                              ,pr_qtdedias   OUT PLS_INTEGER            --> Quantidade de Dias entre duas Datas
                              ,pr_cdcritic   OUT PLS_INTEGER           --> Codigo da critica
                              ,pr_dscritic   OUT VARCHAR2) IS          --> Descricao da critica
    BEGIN
      /* ..............................................................................
      Programa: pc_calcula_dias360
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : James Prust Junior
      Data    : Abril/2017                        Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para calcular os dias 360

      Alteracoes: 
      .................................................................................*/
      DECLARE
        vr_dia_data_inicial INTEGER; --> Dia do lancamento de Juros
        vr_mes_data_inicial INTEGER; --> Mes do lancamento de Juros
        vr_ano_data_inicial INTEGER; --> Ano do lancamento de Juros
        
        vr_dia_data_final   INTEGER; --> Dia de vencimento
        vr_mes_data_final   INTEGER; --> Mes de vencimento
        vr_ano_data_final   INTEGER; --> Ano de vencimento
      BEGIN
        vr_dia_data_inicial := to_char(pr_dtrefjur,'DD');
        vr_mes_data_inicial := to_char(pr_dtrefjur,'MM');
        vr_ano_data_inicial := to_char(pr_dtrefjur,'RRRR');
      
        -- Condicao para verificar se eh Mensal
        --IF pr_ehmensal THEN          
          IF vr_dia_data_inicial >= 28 THEN
            vr_dia_data_inicial := 30;
          END IF;
        --END IF;
      
        -- Guardar dia, mes e ano separamente do vencimento
        vr_dia_data_final := to_char(pr_data_final, 'DD');
        vr_mes_data_final := to_char(pr_data_final, 'MM');
        vr_ano_data_final := to_char(pr_data_final, 'RRRR');
        
        -- Calcula a diferenca entre duas datas e retorna os dias corridos
        EMPR0001.pc_calc_dias360(pr_ehmensal => pr_ehmensal
                                ,pr_dtdpagto => to_char(pr_dtvencto,'DD') -- Dia do primeiro vencimento do emprestimo
                                ,pr_diarefju => vr_dia_data_inicial       -- Dia da data de referência da última vez que rodou juros
                                ,pr_mesrefju => vr_mes_data_inicial       -- Mes da data de referência da última vez que rodou juros
                                ,pr_anorefju => vr_ano_data_inicial       -- Ano da data de referência da última vez que rodou juros
                                ,pr_diafinal => vr_dia_data_final         -- Dia data final
                                ,pr_mesfinal => vr_mes_data_final         -- Mes data final
                                ,pr_anofinal => vr_ano_data_final         -- Ano data final
                                ,pr_qtdedias => pr_qtdedias);             -- Quantidade de dias calculada

      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em pc_calcula_dias360: ' || SQLERRM;        
      END;

  END pc_calcula_dias360;

  PROCEDURE pc_calcula_fator_price(pr_cdcooper          IN crapepr.cdcooper%TYPE  --> Codigo da Cooperativa
                                  ,pr_flgbatch          IN BOOLEAN DEFAULT FALSE  --> Indica se o processo noturno estah rodando
                                  ,pr_dtefetiv          IN crapepr.dtmvtolt%TYPE  --> Data de Efetivação da Proposta
                                  ,pr_dtvencto          IN crappep.dtvencto%TYPE  --> Data de Vencimento
                                  ,pr_txmensal          IN crapepr.txmensal%TYPE  --> Taxa Mensal do Contrato
                                  ,pr_vlrdtaxa          IN craptxi.vlrdtaxa%TYPE  --> Valor da Taxa do Indexador
                                  ,pr_qtparcel          IN PLS_INTEGER            --> Quantidade de prestacoes                                  
                                  ,pr_tab_price         OUT typ_tab_price         --> Temp-Table das parcelas
                                  ,pr_fator_price_total OUT NUMBER                --> Valor do Fator Price Total
                                  ,pr_cdcritic          OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                  ,pr_dscritic          OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_calcula_fator_price
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o fator price das parcelas

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis Calculo da Parcela
      vr_txdiaria              craplcr.txdiaria%TYPE;
      vr_taxa_periodo_anterior NUMBER(25,8)  := 0;
      vr_qtdia_corridos        PLS_INTEGER;
      vr_qtdia_uteis           PLS_INTEGER;
      vr_data_inicial          DATE;
      vr_data_final            DATE;
      
      -- Variaveis tratamento de erros
      vr_cdcritic              crapcri.cdcritic%TYPE;
      vr_dscritic              VARCHAR2(4000);
      vr_exc_erro              EXCEPTION;
      
      -- Procedure para calcular a taxa no periodo no mês anterior
      PROCEDURE pc_calc_taxa_periodo_mensal (pr_cdcooper              IN  crapdat.cdcooper%TYPE
                                            ,pr_flgbatch              IN  BOOLEAN DEFAULT FALSE
                                            ,pr_dtefetiv              IN  crapepr.dtmvtolt%TYPE
                                            ,pr_vlrdtaxa              IN  craptxi.vlrdtaxa%TYPE
                                            ,pr_dtvencto              IN  crappep.dtvencto%TYPE
                                            ,pr_taxa_periodo_anterior OUT NUMBER
                                            ,pr_cdcritic              OUT crapcri.cdcritic%TYPE
                                            ,pr_dscritic              OUT crapcri.dscritic%TYPE) IS
        vr_qtdia_uteis PLS_INTEGER;
        vr_data_inicial DATE;
        
        -- Variaveis tratamento de erros
        vr_cdcritic    crapcri.cdcritic%TYPE;
        vr_dscritic    VARCHAR2(4000);
        vr_exc_erro    EXCEPTION;
      BEGIN
        vr_data_inicial := ADD_MONTHS(pr_dtvencto,-1);
        -- Condicao para verificar qual data inicial será calculada
        IF pr_dtefetiv >= vr_data_inicial THEN
          vr_data_inicial := pr_dtefetiv;	
        END IF;
      
        -- Calcula a diferenca entre duas datas e retorna os dias Uteis
        pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper
                                 ,pr_flgbatch    => pr_flgbatch
                                 ,pr_dtefetiv    => pr_dtefetiv
                                 ,pr_datainicial => vr_data_inicial
                                 ,pr_datafinal   => last_day(vr_data_inicial)
                                 ,pr_qtdiaute    => vr_qtdia_uteis
                                 ,pr_cdcritic    => vr_cdcritic
                                 ,pr_dscritic    => vr_dscritic);
                                  
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Calculo da taxa no periodo Anterior
        pr_taxa_periodo_anterior := ROUND(POWER((1 + (pr_vlrdtaxa / 100)),(vr_qtdia_uteis / 252)) - 1,8);
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro na procedure pc_calc_taxa_periodo_mensal: ' || SQLERRM; 
      END pc_calc_taxa_periodo_mensal;

    BEGIN
      pr_tab_price.DELETE;
      
      -- Transformar a taxa mensal para taxa diaria
      vr_txdiaria     := POWER(1 + (NVL(pr_txmensal,0) / 100),(1 / 30)) - 1;
      vr_data_inicial := ADD_MONTHS(pr_dtvencto,-1);
      vr_data_final   := pr_dtvencto;
      
      -- Condicao para verificar qual data inicial será calculada
      IF pr_dtefetiv >= vr_data_inicial THEN
        vr_data_inicial := pr_dtefetiv;
      END IF;
      
      -- Calcular o Fator Price para cada parcela
      FOR vr_indice IN 1..pr_qtparcel LOOP
        -- Calcula a diferenca entre duas datas e retorna os dias corridos
        pc_calcula_dias360(pr_ehmensal   => FALSE
                          ,pr_dtvencto   => pr_dtvencto
                          ,pr_dtrefjur   => vr_data_inicial
                          ,pr_data_final => vr_data_final
                          ,pr_qtdedias   => vr_qtdia_corridos
                          ,pr_cdcritic   => vr_cdcritic
                          ,pr_dscritic   => vr_dscritic);
      
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
        /*  
        Condicao para calcular o fator price quando ocorrer o pagamento da parcela dentro do mês da efetivação
            Exemplo:
            Data Efetivação: 01/01
            Data Pagamento: 13/01            
            * Precisamos calcular os dias uteis entre o dia 01 até 13 */
        IF TO_CHAR(pr_dtefetiv,'mmyyyy') = TO_CHAR(pr_dtvencto,'mmyyyy') AND NOT pr_tab_price.EXISTS(vr_indice - 1) THEN
          -- Calcula a diferenca entre duas datas e retorna os dias Uteis
          pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper
                                   ,pr_flgbatch    => pr_flgbatch
                                   ,pr_dtefetiv    => pr_dtefetiv
                                   ,pr_datainicial => vr_data_inicial
                                   ,pr_datafinal   => vr_data_final 
                                   ,pr_qtdiaute    => vr_qtdia_uteis
                                   ,pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic);
                                      
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        ELSE
          -- Calcula a diferenca entre duas datas e retorna os dias Uteis
          pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper
                                   ,pr_flgbatch    => pr_flgbatch
                                   ,pr_dtefetiv    => pr_dtefetiv
                                   ,pr_datainicial => last_day(vr_data_inicial)
                                   ,pr_datafinal   => vr_data_final
                                   ,pr_qtdiaute    => vr_qtdia_uteis
                                   ,pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic);
                                      
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Procedure para calcular a taxa no periodo no mes anterior
          pc_calc_taxa_periodo_mensal(pr_cdcooper              => pr_cdcooper
                                     ,pr_flgbatch              => pr_flgbatch
                                     ,pr_dtefetiv              => pr_dtefetiv
                                     ,pr_vlrdtaxa              => pr_vlrdtaxa
                                     ,pr_dtvencto              => vr_data_final
                                     ,pr_taxa_periodo_anterior => vr_taxa_periodo_anterior
                                     ,pr_cdcritic              => vr_cdcritic
                                     ,pr_dscritic              => vr_dscritic);
                                        
          -- Condicao para verificar se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        -- Calculo da taxa no Periodo
        pr_tab_price(vr_indice).taxa_periodo := POWER((1 + (pr_vlrdtaxa / 100)),(vr_qtdia_uteis / 252)) - 1;      
        -- Condicao para verificar se a parcela anterior já foi calculada, pois o juros nominais é acumulativo
        IF pr_tab_price.EXISTS(vr_indice - 1) THEN
                                                          -- Fator Acumulado da parcela Anterior
          pr_tab_price(vr_indice).fator_juros_nominais := (pr_tab_price(vr_indice - 1).fator_acumulado * 
                                                          -- Calculo do Juros Nominais
                                                          (POWER(1 + vr_txdiaria,vr_qtdia_corridos) - 1)) +
                                                          -- Fator Juros Nominais da parcela Anterior
                                                          pr_tab_price(vr_indice - 1).fator_juros_nominais;

          -- Calculo do Fator Correcao Monetaria      -- Fator Acumulado da parcela Anterior
          pr_tab_price(vr_indice).fator_correcao := (pr_tab_price(vr_indice - 1).fator_acumulado * 
                                                    (((1 + vr_taxa_periodo_anterior) * pr_tab_price(vr_indice).taxa_periodo) + vr_taxa_periodo_anterior)) +
                                                    pr_tab_price(vr_indice - 1).fator_correcao;

        ELSE
          -- Calculo do Fator Juros Nominais 
          pr_tab_price(vr_indice).fator_juros_nominais := POWER(1 + vr_txdiaria,vr_qtdia_corridos);           
          -- Calculo do Fator Correcao Monetaria
          pr_tab_price(vr_indice).fator_correcao := (1 + vr_taxa_periodo_anterior) * (1 + pr_tab_price(vr_indice).taxa_periodo);
        END IF;

        -- Calculo do Fator Acumulado
        pr_tab_price(vr_indice).fator_acumulado := pr_tab_price(vr_indice).fator_juros_nominais + 
                                                   pr_tab_price(vr_indice).fator_correcao - 1;
        -- Calculo fator Price
        pr_tab_price(vr_indice).fator_price := 1 / pr_tab_price(vr_indice).fator_acumulado;
        pr_tab_price(vr_indice).vlrdtaxa    := pr_vlrdtaxa;
        
        pr_fator_price_total                := NVL(pr_fator_price_total,0) + pr_tab_price(vr_indice).fator_price;
        -- Incrementar a data de pagamento para o proximo mês
        vr_data_inicial := vr_data_final;
        vr_data_final   := ADD_MONTHS(vr_data_final,1);        
      END LOOP;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_calcula_fator_price: ' || SQLERRM;
    END;

  END pc_calcula_fator_price;

  PROCEDURE pc_calcula_saldo_projetado(pr_cdcooper    IN  crapepr.cdcooper%TYPE  --> Codigo da Cooperativa
                                      ,pr_flgbatch    IN  BOOLEAN DEFAULT FALSE  --> Indica se o processo noturno estah rodando
                                      ,pr_dtefetiv    IN  crapepr.dtmvtolt%TYPE  --> Data de Efetivação da Proposta
                                      ,pr_datainicial IN  DATE                   --> Data Inicial
                                      ,pr_datafinal   IN  DATE                   --> Data Calculo
                                      ,pr_dtdpagto    IN  crawepr.dtdpagto%TYPE  --> Data de Pagamento do Contrato
                                      ,pr_dtcarenc    IN  crawepr.dtcarenc%TYPE  --> Data da Carencia do Contrato
                                      ,pr_vlrdtaxa    IN  craptxi.vlrdtaxa%TYPE  --> Taxa do CDI/TR
                                      ,pr_txmensal    IN  crapepr.txmensal%TYPE  --> Taxa Mensal do Emprestimo
                                      ,pr_vlsprojt    IN  crapepr.vlsprojt%TYPE  --> Saldo Projetado
                                      ,pr_tab_price   IN OUT typ_tab_price      --> Tabela contendo os valores do price
                                      ,pr_cdcritic    OUT crapcri.cdcritic%TYPE  --> Codigo da critica
                                      ,pr_dscritic    OUT crapcri.dscritic%TYPE) IS
  BEGIN                                      
    /* .............................................................................
       Programa: pc_calcula_saldo_projetado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Junho/2017                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o valor da parcela do juros da carencia

       Alteracoes: 
    ............................................................................. */
    DECLARE                  
      vr_txdiaria                   craplcr.txdiaria%TYPE;      
      vr_qtdias_corridos            PLS_INTEGER;
      vr_qtdia_uteis                PLS_INTEGER;
      vr_indice                     PLS_INTEGER;
      vr_saldo_juros_correcao       NUMBER(25,2) := 0;
      vr_saldo_juros_remuneratorio  NUMBER(25,2) := 0;
      vr_saldo_projetado            NUMBER(25,2) := 0;
      vr_ehmensal                   BOOLEAN := FALSE;
      
      -- Variaveis tratamento de erros
      vr_cdcritic                   crapcri.cdcritic%TYPE;
      vr_dscritic                   VARCHAR2(4000);
      vr_exc_erro                   EXCEPTION;
    BEGIN
      -- Condicao para verificar se estamos calculando a mensal
      IF TO_CHAR(pr_datafinal,'DD') = TO_CHAR(LAST_DAY(pr_datafinal),'DD') THEN
        vr_ehmensal := TRUE;
      END IF;
      
      vr_txdiaria := POWER(1 + (NVL(pr_txmensal,0) / 100),(1 / 30)) - 1;
      
      -- Quantidade de dias corridos entre a data atual e o lancamento de juros remuneratorio
      pc_calcula_dias360(pr_ehmensal   => vr_ehmensal
                        ,pr_dtvencto   => pr_dtdpagto
                        ,pr_dtrefjur   => pr_datainicial
                        ,pr_data_final => pr_datafinal
                        ,pr_qtdedias   => vr_qtdias_corridos
                        ,pr_cdcritic   => vr_cdcritic
                        ,pr_dscritic   => vr_dscritic);
      
      -- Condicao para verificar se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Calcula a diferenca entre duas datas e retorna os dias Uteis
      pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper
                               ,pr_flgbatch    => pr_flgbatch
                               ,pr_dtefetiv    => pr_dtefetiv
                               ,pr_datainicial => pr_datainicial
                               ,pr_datafinal   => pr_datafinal
                               ,pr_qtdiaute    => vr_qtdia_uteis
                               ,pr_cdcritic    => vr_cdcritic
                               ,pr_dscritic    => vr_dscritic);
      
      -- Condicao para verificar se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      vr_indice := pr_tab_price.COUNT;
      IF pr_tab_price.EXISTS(vr_indice) THEN
        vr_saldo_juros_correcao      := pr_tab_price(vr_indice).saldo_projetado;
        vr_saldo_juros_remuneratorio := pr_tab_price(vr_indice).saldo_projetado;
        vr_saldo_projetado           := pr_tab_price(vr_indice).saldo_projetado;
      ELSE
        vr_saldo_juros_correcao      := pr_vlsprojt;
        vr_saldo_juros_remuneratorio := pr_vlsprojt;
        vr_saldo_projetado           := pr_vlsprojt;
      END IF;
      
      vr_indice := pr_tab_price.COUNT + 1;
      -- Calculo da taxa no periodo
      pr_tab_price(vr_indice).taxa_periodo := POWER((1 + (pr_vlrdtaxa / 100)),(vr_qtdia_uteis / 252)) - 1;
          
      --------------------------------------------------------------------------------------------------
      --  Condicao para verificar se estamos calculando o vencimento da Parcela
      --------------------------------------------------------------------------------------------------
      IF TO_CHAR(pr_dtdpagto,'DD') = TO_CHAR(pr_datafinal,'DD') THEN
        IF pr_tab_price.EXISTS(vr_indice - 1) THEN
          -- O Saldo do Juros Remuneratorio será o Saldo da Mensal
          vr_saldo_juros_remuneratorio := pr_tab_price(vr_indice - 1).saldo_projetado + pr_tab_price(vr_indice - 1).juros_remuneratorio;
          -- O Saldo do Juros de Correcao será o Saldo da Mensal
          vr_saldo_juros_correcao      := pr_tab_price(vr_indice - 1).saldo_projetado + pr_tab_price(vr_indice - 1).juros_correcao;
        END IF;
      END IF;
      -- Calculo do Juros Remuneratorio
      pr_tab_price(vr_indice).juros_remuneratorio := vr_saldo_juros_remuneratorio * ((POWER(1 + vr_txdiaria,vr_qtdias_corridos))-1);
      -- Calculo do Juros de Correcao
      pr_tab_price(vr_indice).juros_correcao      := vr_saldo_juros_correcao * pr_tab_price(vr_indice).taxa_periodo;      
      
      --------------------------------------------------------------------------------------------------
      --  Condicao para verificar se estamos calculando o Juros de Carencia
      --------------------------------------------------------------------------------------------------
      IF pr_dtcarenc = pr_datafinal THEN
        
      END IF;
      
      --------------------------------------------------------------------------------------------------
      --  Condicao para calcular o saldo projetado
      --------------------------------------------------------------------------------------------------
      IF TO_CHAR(pr_datafinal,'DD') = TO_CHAR(LAST_DAY(pr_datafinal),'DD') THEN
        -- Calculo do saldo devedor projetado
        pr_tab_price(vr_indice).saldo_projetado := vr_saldo_projetado;
      ELSE
        pr_tab_price(vr_indice).saldo_projetado := vr_saldo_projetado + 
                                                   pr_tab_price(vr_indice).juros_correcao + 
                                                   pr_tab_price(vr_indice).juros_remuneratorio - 
                                                   pr_tab_price(vr_indice).vlparepr;
        -- Computar o Saldo Projetado + Mensal
        IF pr_tab_price.EXISTS(vr_indice - 1) THEN
          pr_tab_price(vr_indice).saldo_projetado := pr_tab_price(vr_indice).saldo_projetado +
                                                     pr_tab_price(vr_indice - 1).juros_remuneratorio + 
                                                     pr_tab_price(vr_indice - 1).juros_correcao;
        END IF;                                                     
      END IF;      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;        
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure pc_calcula_saldo_projetado: ' || SQLERRM;
    END;
     
  END pc_calcula_saldo_projetado;
      
  PROCEDURE pc_calcula_prox_parcela_pos(pr_cdcooper        IN  crapepr.cdcooper%TYPE --> Codigo da Cooperativa
                                       ,pr_flgbatch        IN  BOOLEAN DEFAULT FALSE --> Indica se o processo noturno estah rodando
                                       ,pr_dtcalcul        IN  crapdat.dtmvtolt%TYPE --> Data do cálculo
                                       ,pr_dtefetiv        IN  crapepr.dtmvtolt%TYPE --> Data de efetivação da proposta
                                       ,pr_dtpripgt        IN  crawepr.dtdpagto%TYPE --> Data do Primeiro Pagamento
                                       ,pr_dtcarenc        IN  crawepr.dtcarenc%TYPE --> Data da Carencia
                                       ,pr_txmensal        IN  crapepr.txmensal%TYPE --> Taxa Mensal do Contrato
                                       ,pr_qtpreemp        IN  crapepr.qtpreemp%TYPE --> Quantidade de Prestacoes do Emprestimo
                                       ,pr_vlsprojt        IN  crapepr.vlsprojt%TYPE --> Saldo Devedor Projetado
                                       ,pr_qtdias_carencia IN  tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias de Carencia
                                       ,pr_vlrdtaxa        IN  craptxi.vlrdtaxa%TYPE --> Valor da Taxa
                                       ,pr_nrparepr        IN  crappep.nrparepr%TYPE --> Numero da Parcela
                                       ,pr_dtvencto        IN  crappep.dtvencto%TYPE --> Data de Vencimento da Parcela
                                       ,pr_tab_parcelas    OUT typ_tab_parcelas      --> Temp-Table das parcelas
                                       ,pr_cdcritic        OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                       ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS
  BEGIN
    /* .............................................................................
       Programa: pc_calcula_prox_parcela_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Junho/2017                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular valor da proxima parcela

       Alteracoes: 
    ............................................................................. */

    DECLARE    
      -- Variaveis tratamento de erros
      vr_cdcritic          crapcri.cdcritic%TYPE;
      vr_dscritic          VARCHAR2(4000);
      vr_exc_erro          EXCEPTION;
      
      -- Vetores
      vr_tab_data_calculo  typ_tab_data_calculo;
      vr_tab_price         typ_tab_price;
      
      -- Variaveis
      vr_qtparcel          PLS_INTEGER := 1;
      vr_nrparepr          crappep.nrparepr%TYPE;
      vr_vlparepr          crappep.vlparepr%TYPE;
      vr_datainicial       DATE;
      vr_dtlancto          DATE;
      vr_dtcarenc          DATE;
      vr_fator_price_total NUMBER(25,10);
      vr_indice            VARCHAR2(10);
    BEGIN
      vr_tab_price.DELETE;
      vr_tab_data_calculo.DELETE;
      -- Numero da parcela inicial
      vr_nrparepr := pr_nrparepr;
     
      -----------------------------------------------------------------------------------------------------------
      --  REGRAS PARA CALCULAR O VALOR DA PARCELA DO JUROS DA CARENCIA
      -----------------------------------------------------------------------------------------------------------      
      -- Condicao para verificar se precisamos calcular a Parcela do Juros na Carência
      IF pr_dtcarenc IS NOT NULL AND pr_dtpripgt > pr_dtvencto THEN
        -- Data que devera ser calculado os Juros
        vr_dtlancto := LAST_DAY(ADD_MONTHS(pr_dtvencto,-1));
        vr_dtcarenc := pr_dtcarenc;
        -- Loop para percorrer todas as datas que deverao ser calculadas
        WHILE vr_dtlancto < pr_dtpripgt LOOP
          -- Vencimento da ultima mensal não será calculada 
          IF LAST_DAY(ADD_MONTHS(pr_dtpripgt,-1)) = vr_dtlancto THEN
            EXIT;
          END IF;
          
          -- Condicao para verificar se eh mensal
          IF vr_dtlancto = LAST_DAY(vr_dtlancto) THEN
            -- Efetua o lancamento no dia da carencia
            vr_tab_data_calculo(TO_CHAR(vr_dtlancto,'RRRRMMDD')) := vr_dtlancto;
          END IF;
          
          -- Condicao para verificar se eh o dia da carencia
          IF TO_CHAR(vr_dtlancto,'DD') = TO_CHAR(pr_dtpripgt,'DD') THEN
            -- Incrementar o proximo lancamento de juros de carencia
            vr_dtcarenc := TO_DATE(TO_CHAR(vr_dtcarenc,'DD')||'/'||TO_CHAR(vr_dtcarenc + pr_qtdias_carencia,'MM/RRRR'),'DD/MM/RRRR');
            -- Efetua o lancamento no dia da carencia
            vr_tab_data_calculo(TO_CHAR(vr_dtlancto,'RRRRMMDD')) := vr_dtlancto;
          END IF;
            
          -- Condicao para avancar a data do lancamento
          IF TO_CHAR(vr_dtlancto,'DD') = TO_CHAR(vr_dtcarenc,'DD') AND vr_dtlancto <> LAST_DAY(vr_dtlancto) THEN
            vr_dtlancto := LAST_DAY(vr_dtlancto);
          ELSE
            vr_dtlancto := ADD_MONTHS(TO_DATE(TO_CHAR(vr_dtcarenc,'DD')||TO_CHAR(vr_dtlancto,'/MM/RRRR'),'DD/MM/RRRR'),1);
          END IF;
        END LOOP;
          
        -- Percorrer as datas que deverão ser calculadas
        vr_datainicial := pr_dtcalcul;
        vr_dtcarenc    := pr_dtcarenc;        
        vr_indice      := vr_tab_data_calculo.FIRST;
        WHILE vr_indice IS NOT NULL LOOP
          -- Procedure para calcular o saldo projetado
          pc_calcula_saldo_projetado(pr_cdcooper    => pr_cdcooper
                                    ,pr_flgbatch    => pr_flgbatch
                                    ,pr_dtefetiv    => pr_dtcalcul
                                    ,pr_datainicial => vr_datainicial
                                    ,pr_datafinal   => vr_tab_data_calculo(vr_indice)
                                    ,pr_dtdpagto    => pr_dtvencto
                                    ,pr_dtcarenc    => vr_dtcarenc
                                    ,pr_vlrdtaxa    => pr_vlrdtaxa
                                    ,pr_txmensal    => pr_txmensal
                                    ,pr_vlsprojt    => pr_vlsprojt
                                    ,pr_tab_price   => vr_tab_price
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
                                            
          -- Condicao para verificar se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Valor da parcela será a somatório do Juros de Correção + Juros Remuneratorio
          vr_vlparepr := NVL(vr_vlparepr,0) + 
                         vr_tab_price(vr_tab_price.LAST).juros_correcao + 
                         vr_tab_price(vr_tab_price.LAST).juros_remuneratorio;
          
          -- Condicao para verificar 
          IF vr_tab_data_calculo(vr_indice) = vr_dtcarenc THEN
            -- Grava o valor do Juros Correção/Juros Remuneratorio da Parcela
            pr_tab_parcelas(vr_nrparepr).nrparepr := vr_nrparepr;
            pr_tab_parcelas(vr_nrparepr).vlparepr := vr_vlparepr;
            pr_tab_parcelas(vr_nrparepr).vlrdtaxa := pr_vlrdtaxa;
            -- Avanca da data da carencia para o proximo mês
            vr_dtcarenc := TO_DATE(TO_CHAR(vr_dtcarenc,'DD')||'/'||TO_CHAR(vr_dtcarenc + pr_qtdias_carencia,'MM/RRRR'),'DD/MM/RRRR');
            -- Zera a variavel
            vr_vlparepr := 0;
          END IF;

          -- Inicial recebe a final
          vr_datainicial := vr_tab_data_calculo(vr_indice);
          vr_indice      := vr_tab_data_calculo.NEXT(vr_indice);
        END LOOP;
      END IF;

      -----------------------------------------------------------------------------------------------------------
      --  REGRAS PARA CALCULAR O VALOR DA PARCELA PRINCIPAL            
      -----------------------------------------------------------------------------------------------------------      
      -- Quantidade de parcelas que será calculado o Price
      vr_qtparcel := vr_qtparcel + NVL(pr_qtpreemp,0) - NVL(vr_nrparepr,0);     
      -- Calcula o fator price para as parcelas
      pc_calcula_fator_price(pr_cdcooper          => pr_cdcooper
                            ,pr_flgbatch          => pr_flgbatch
                            ,pr_dtefetiv          => pr_dtefetiv
                            ,pr_dtvencto          => pr_dtvencto                            
                            ,pr_txmensal          => pr_txmensal
                            ,pr_vlrdtaxa          => pr_vlrdtaxa
                            ,pr_qtparcel          => vr_qtparcel
                            ,pr_tab_price         => vr_tab_price
                            ,pr_fator_price_total => vr_fator_price_total
                            ,pr_cdcritic          => pr_cdcritic
                            ,pr_dscritic          => pr_dscritic);
      
      -- Condicao para verificar se houve erro
      IF NVL(pr_cdcritic,0) > 0 OR pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Loop para calcular os valores das parcelas
      FOR vr_indice IN 1..vr_qtparcel LOOP
        pr_tab_parcelas(vr_nrparepr).nrparepr := vr_nrparepr;
        pr_tab_parcelas(vr_nrparepr).vlparepr := NVL(pr_vlsprojt,0) / vr_fator_price_total;
        pr_tab_parcelas(vr_nrparepr).vlrdtaxa := pr_vlrdtaxa;
        vr_nrparepr := vr_nrparepr + 1;
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_calcula_prox_parcela_pos: ' || SQLERRM;
    END;

  END pc_calcula_prox_parcela_pos;
  
  PROCEDURE pc_calcula_parcelas_pos_fixado(pr_cdcooper        IN crapcop.cdcooper%TYPE      --> Codigo da Cooperativa
                                          ,pr_flgbatch        IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                          ,pr_dtcalcul        IN crapdat.dtmvtolt%TYPE      --> Data de Calculo
                                          ,pr_cdlcremp        IN craplcr.cdlcremp%TYPE      --> Codigo da Linha de Credito
                                          ,pr_dtcarenc        IN crawepr.dtcarenc%TYPE      --> Data da Carencia do Contrato
                                          ,pr_qtdias_carencia IN tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias de Carencia
                                          ,pr_dtdpagto        IN crapepr.dtdpagto%TYPE      --> Data de Pagamento
                                          ,pr_qtpreemp        IN crapepr.qtpreemp%type      --> Quantidade de Prestacoes
                                          ,pr_vlemprst        IN crapepr.vlemprst%TYPE      --> Valor do Emprestimo
                                          ,pr_tab_parcelas    OUT typ_tab_parcelas          --> Parcelas do Emprestimo
                                          ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                          ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_calcula_parcelas_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular as parcelas do Pos-Fixado.

       Alteracoes: 
    ............................................................................. */
    DECLARE
      -- Busca os dados da linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT txmensal
              ,cddindex
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Busca os dados da taxa do CDI
      CURSOR cr_craptxi (pr_cddindex IN craptxi.cddindex%TYPE
                        ,pr_dtiniper IN craptxi.dtiniper%TYPE) IS
        SELECT vlrdtaxa
          FROM craptxi
         WHERE cddindex = pr_cddindex
           AND dtiniper = pr_dtiniper;
      rw_craptxi cr_craptxi%ROWTYPE;
      
      -- Vetor para armazenamento
      vr_tab_data_calculo       typ_tab_data_calculo;
      vr_tab_price              typ_tab_price;
            
      -- Variaveis      
      vr_dtmvtoan               crapdat.dtmvtoan%TYPE;
      vr_dtmvtolt               crapdat.dtmvtolt%TYPE;      
      vr_dtvencto               crappep.dtvencto%TYPE;
      vr_nrparepr               crappep.nrparepr%TYPE;
      vr_dtcarenc               crawepr.dtdpagto%TYPE;
      vr_fator_price_total      NUMBER(25,10);
      vr_saldo_projetado        NUMBER(25,10);
      vr_vlparepr               crappep.vlparepr%TYPE;
      vr_datainicial            DATE;
      vr_dtlancto               DATE;
      vr_indice                 VARCHAR2(4000);
            
      -- Variaveis tratamento de erros
      vr_cdcritic               crapcri.cdcritic%TYPE;
      vr_dscritic               VARCHAR2(4000);
      vr_exc_erro               EXCEPTION;
    BEGIN
      vr_tab_price.DELETE;
      vr_tab_data_calculo.DELETE;
      
      vr_dtmvtolt := pr_dtcalcul;
      -- Função para retornar o dia anterior
      vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,       --> Cooperativa conectada
                                                 pr_dtmvtolt  => vr_dtmvtolt - 1,   --> Data do movimento
                                                 pr_tipo      => 'A');
      
      -- Buscar a taxa de juros
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- se achou registro
      IF cr_craplcr%FOUND THEN
        CLOSE cr_craplcr;
      ELSE
        CLOSE cr_craplcr;
        -- Gerar erro
        vr_cdcritic := 363;
        RAISE vr_exc_erro;
      END IF;      
      
      -- Buscar a taxa acumulada do CDI
      OPEN cr_craptxi (pr_cddindex => rw_craplcr.cddindex
                      ,pr_dtiniper => vr_dtmvtoan);
      FETCH cr_craptxi INTO rw_craptxi;
      -- se achou registro
      IF cr_craptxi%FOUND THEN
        CLOSE cr_craptxi;
      ELSE
        CLOSE cr_craptxi;
        -- Gerar erro
        vr_dscritic := 'Taxa do CDI nao cadastrada. Data: ' || TO_CHAR(vr_dtmvtoan,'DD/MM/RRRR');
        RAISE vr_exc_erro;
      END IF;
     
      -- Saldo Projetado Inicial
      vr_saldo_projetado := pr_vlemprst;
      -- Condicao para verificar qual será a data final para fins de calculo (Data do Pagamento ou Ultimo dia do Mes)
      IF TO_NUMBER(TO_CHAR(pr_dtdpagto,'DD')) >= TO_NUMBER(TO_CHAR(pr_dtcalcul,'DD')) THEN
        vr_dtlancto := TO_DATE(TO_CHAR(pr_dtdpagto,'DD')||'/'||TO_CHAR(pr_dtcalcul,'MM/RRRR'),'DD/MM/RRRR');
      ELSE
        vr_dtlancto := LAST_DAY(pr_dtcalcul);
      END IF;        
      -- Loop para percorrer todas as datas que deverao ser calculadas
      WHILE vr_dtlancto < pr_dtdpagto LOOP
        -- Vencimento da ultima mensal não será calculada 
        IF LAST_DAY(ADD_MONTHS(pr_dtdpagto,-1)) = vr_dtlancto THEN
          EXIT;
        END IF;
          
        -- Condicao para verificar se eh mensal
        IF vr_dtlancto = LAST_DAY(vr_dtlancto) THEN
          -- Efetua o lancamento no dia da carencia
          vr_tab_data_calculo(TO_CHAR(vr_dtlancto,'RRRRMMDD')) := vr_dtlancto;
        END IF;
          
        -- Condicao para verificar se eh o dia da carencia
        IF TO_CHAR(vr_dtlancto,'DD') = TO_CHAR(pr_dtdpagto,'DD') THEN
          -- Efetua o lancamento no dia da carencia
          vr_tab_data_calculo(TO_CHAR(vr_dtlancto,'RRRRMMDD')) := vr_dtlancto;
        END IF;
          
        -- Condicao para avancar a data do lancamento
        IF TO_CHAR(vr_dtlancto,'DD') = TO_CHAR(pr_dtdpagto,'DD') AND vr_dtlancto <> LAST_DAY(vr_dtlancto) THEN
          vr_dtlancto := LAST_DAY(vr_dtlancto);
        ELSE
          vr_dtlancto := ADD_MONTHS(TO_DATE(TO_CHAR(pr_dtdpagto,'DD')||TO_CHAR(vr_dtlancto,'/MM/RRRR'),'DD/MM/RRRR'),1);
        END IF;
      END LOOP;
          
      -- Percorrer as datas que deverão ser calculadas
      vr_datainicial := pr_dtcalcul;
      vr_dtcarenc    := pr_dtcarenc;        
      vr_indice      := vr_tab_data_calculo.FIRST;
      WHILE vr_indice IS NOT NULL LOOP
        -- Procedure para calcular o saldo projetado
        pc_calcula_saldo_projetado(pr_cdcooper    => pr_cdcooper
                                  ,pr_flgbatch    => pr_flgbatch
                                  ,pr_dtefetiv    => pr_dtcalcul
                                  ,pr_datainicial => vr_datainicial
                                  ,pr_datafinal   => vr_tab_data_calculo(vr_indice)
                                  ,pr_dtdpagto    => pr_dtdpagto
                                  ,pr_dtcarenc    => vr_dtcarenc
                                  ,pr_vlrdtaxa    => rw_craptxi.vlrdtaxa
                                  ,pr_txmensal    => rw_craplcr.txmensal
                                  ,pr_vlsprojt    => pr_vlemprst
                                  ,pr_tab_price   => vr_tab_price
                                  ,pr_cdcritic    => vr_cdcritic
                                  ,pr_dscritic    => vr_dscritic);
                                            
        -- Condicao para verificar se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        IF vr_dtcarenc IS NOT NULL THEN
          -- Valor da parcela será a somatório do Juros de Correção + Juros Remuneratorio
          vr_vlparepr := NVL(vr_vlparepr,0) + 
                         vr_tab_price(vr_tab_price.LAST).juros_correcao + 
                         vr_tab_price(vr_tab_price.LAST).juros_remuneratorio;
          
          -- Condicao para verificar 
          IF vr_tab_data_calculo(vr_indice) = vr_dtcarenc THEN
            -- Grava o valor do Juros Correção/Juros Remuneratorio da Parcela
            vr_nrparepr := pr_tab_parcelas.COUNT + 1;
            pr_tab_parcelas(vr_nrparepr).nrparepr := vr_nrparepr;
            pr_tab_parcelas(vr_nrparepr).vlparepr := vr_vlparepr;
            pr_tab_parcelas(vr_nrparepr).dtvencto := vr_dtcarenc;
            pr_tab_parcelas(vr_nrparepr).flcarenc := 1;
            pr_tab_parcelas(vr_nrparepr).vlrdtaxa := rw_craptxi.vlrdtaxa;
            -- Avanca da data da carencia para o proximo mês
            vr_dtcarenc := TO_DATE(TO_CHAR(vr_dtcarenc,'DD')||'/'||TO_CHAR(vr_dtcarenc + pr_qtdias_carencia,'MM/RRRR'),'DD/MM/RRRR');
            -- Zera a variavel
            vr_vlparepr := 0;
          END IF;
        END IF;
          
        -- Inicial recebe a final
        vr_datainicial := vr_tab_data_calculo(vr_indice);
        -- Proxima data
        vr_indice      := vr_tab_data_calculo.NEXT(vr_indice);
      END LOOP;      
        
      -- Condicao para verificar se foi possivel calcular o saldo projetado
      IF vr_tab_price.EXISTS(vr_tab_price.last) THEN
        -- Saldo Devedor Projetado que sera a base para o calculo da parcela
        vr_saldo_projetado := vr_tab_price(vr_tab_price.last).saldo_projetado;
      END IF;
      
      -- Procedure para calcular o Fator Price 
      pc_calcula_fator_price(pr_cdcooper          => pr_cdcooper
                            ,pr_flgbatch          => pr_flgbatch
                            ,pr_dtefetiv          => pr_dtcalcul
                            ,pr_dtvencto          => pr_dtdpagto
                            ,pr_txmensal          => rw_craplcr.txmensal
                            ,pr_vlrdtaxa          => rw_craptxi.vlrdtaxa
                            ,pr_qtparcel          => pr_qtpreemp
                            ,pr_tab_price         => vr_tab_price
                            ,pr_fator_price_total => vr_fator_price_total
                            ,pr_cdcritic          => vr_cdcritic
                            ,pr_dscritic          => vr_dscritic);
      
      -- Condicao para verificar se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Condicao para verificar se foi calculado o fator price
      IF NOT vr_tab_price.EXISTS(vr_tab_price.FIRST) THEN
        vr_dscritic := 'Nao foi possivel calcular o fator price'; 
        RAISE vr_exc_erro;
      END IF;
      
      -- Condicao para verifiar se jah possui parcela para calcular
      vr_nrparepr := pr_tab_parcelas.COUNT;
      IF vr_nrparepr IS NULL OR vr_nrparepr = 0 THEN
        vr_dtvencto := pr_dtdpagto;
        vr_nrparepr := 1;
      ELSE
        vr_dtvencto := ADD_MONTHS(pr_tab_parcelas(vr_nrparepr).dtvencto,1);
        vr_nrparepr := vr_nrparepr + 1;
      END IF;
      
      -- Loop para calcular os valores das parcelas
      FOR vr_indice IN 1..pr_qtpreemp LOOP
        pr_tab_parcelas(vr_nrparepr).nrparepr     := vr_nrparepr;
        pr_tab_parcelas(vr_nrparepr).vlparepr     := NVL(vr_saldo_projetado,0) / vr_fator_price_total;
        pr_tab_parcelas(vr_nrparepr).dtvencto     := vr_dtvencto;
        pr_tab_parcelas(vr_nrparepr).flcarenc     := 0;
        pr_tab_parcelas(vr_nrparepr).vlrdtaxa     := vr_tab_price(vr_indice).vlrdtaxa;
        pr_tab_parcelas(vr_nrparepr).taxa_periodo := vr_tab_price(vr_indice).taxa_periodo;
        
        -- Avança para o próximo mês
        vr_nrparepr := vr_nrparepr + 1;
        vr_dtvencto := ADD_MONTHS(vr_dtvencto,1);        
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_calcula_parcelas_pos_fixado: ' || SQLERRM;
    END;

  END pc_calcula_parcelas_pos_fixado;
 
  PROCEDURE pc_calcula_atraso_pos_fixado (pr_dtcalcul IN  crapdat.dtmvtolt%TYPE   --> Data de Calculo
                                         ,pr_vlparepr IN  crappep.vlparepr%TYPE   --> Valor da Parcela
                                         ,pr_dtvencto IN  crappep.dtvencto%TYPE   --> Data de Vencimento da Parcela
                                         ,pr_dtultpag IN  crappep.dtultpag%TYPE   --> Data do Ultimo Pagamento
                                         ,pr_vlsdvpar IN  crappep.vlsdvpar%TYPE   --> Saldo Devedor da Parcela
                                         ,pr_perjurmo IN  craplcr.perjurmo%TYPE   --> Percentual do Juros de Mora
                                         ,pr_vlpagmta IN  crappep.vlpagmta%TYPE   --> Valor Pago de Mula
                                         ,pr_percmult IN  NUMBER                  --> Percentual de Multa
                                         ,pr_qttolatr IN  crapepr.qttolatr%TYPE   --> Quantidade de Tolerancia para Cobrar Multa/Juros de Mora
                                         ,pr_vlmrapar OUT NUMBER                  --> Juros de Mora Atualizado
                                         ,pr_vlmtapar OUT NUMBER                  --> Multa Atualizado
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo da critica
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    /* .............................................................................
       Programa: pc_calcula_atraso_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Junho/2017                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o valor de desconto da parcela

       Alteracoes: 
    ............................................................................. */    
    DECLARE
      -- Variaveis de calculo
      vr_qtdiamor     PLS_INTEGER;
      vr_qtdiamul     PLS_INTEGER;
      vr_txdiaria     NUMBER(25,7);
      vr_percmult     NUMBER(25,2);
      vr_dtjurmora    DATE;
      
      -- Variaveis tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      vr_exc_erro     EXCEPTION;
    BEGIN
      --------------------------------------------------------------------------------------------------------------
      --                                 INICIO PARA CALCULAR O VALOR DA MULTA
      --------------------------------------------------------------------------------------------------------------
      vr_percmult := pr_percmult;
      -- Se a quantidade de dias está dentro da tolerancia
      vr_qtdiamul := pr_dtcalcul - pr_dtvencto;
      IF vr_qtdiamul <= pr_qttolatr THEN
        -- Zerar a multa
        vr_percmult := 0;
      END IF;          
      -- Calcular o valor da multa, descontando o que já foi calculado para a parcela
      pr_vlmtapar := ROUND((pr_vlparepr * (vr_percmult / 100)), 2) - NVL(pr_vlpagmta,0);
      IF pr_vlmtapar < 0 THEN
        pr_vlmtapar := 0;
      END IF;
      --------------------------------------------------------------------------------------------------------------
      --                                  FIM PARA CALCULAR O VALOR DA MULTA
      --------------------------------------------------------------------------------------------------------------

      --------------------------------------------------------------------------------------------------------------
      --                              INICIO PARA CALCULAR O VALOR DO JUROS DE MORA
      --------------------------------------------------------------------------------------------------------------
      IF pr_dtultpag IS NULL THEN
        -- Pegar a data de vencimento dela
        vr_dtjurmora := pr_dtvencto;
      ELSE
        -- Pegar a ultima data que pagou a parcela
        vr_dtjurmora := pr_dtultpag;
      END IF;
      
      vr_qtdiamor := pr_dtcalcul - vr_dtjurmora;
      -- Se a quantidade de dias está dentro da tolerancia de juros de mora
      IF vr_qtdiamor <= pr_qttolatr THEN
        -- Zerar o percentual de mora
        pr_vlmrapar := 0;
      ELSE
        -- Taxa de mora recebe o valor da linha de crédito
        vr_txdiaria := ROUND((100 * (POWER((pr_perjurmo / 100) + 1,(1 / 30)) - 1)),7);
        -- Valor de juros de mora é relativo ao juros sem inadimplencia da parcela + taxa diaria calculada + quantidade de dias de mora
        pr_vlmrapar := round((pr_vlsdvpar * (vr_txdiaria / 100) * vr_qtdiamor),2);
      END IF;		
      --------------------------------------------------------------------------------------------------------------
      --                                  FIM PARA CALCULAR O VALOR DO JUROS DE MORA
      --------------------------------------------------------------------------------------------------------------
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_calcula_atraso_pos_fixado: ' || SQLERRM;
    END;

  END pc_calcula_atraso_pos_fixado;      
      
  PROCEDURE pc_calcula_desconto_pos(pr_dtcalcul IN  crapdat.dtmvtolt%TYPE --> Data do cálculo
                                   ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE --> Indica se o processo noturno estah rodando
                                   ,pr_cdcooper IN  crapepr.cdcooper%TYPE --> Codigo da Cooperativa
                                   ,pr_nrdconta IN  crapepr.nrdconta%TYPE --> Numero da Conta
                                   ,pr_nrctremp IN  crapepr.nrctremp%TYPE --> Numero do Contrato                                          
                                   ,pr_nrparepr IN  crappep.nrparepr%TYPE --> Numero da Parcela
                                   ,pr_vlsdvpar IN  crappep.vlsdvpar%TYPE --> Saldo Devedor da Parcela
                                   ,pr_vlatupar OUT NUMBER                --> Valor Atualizado da Parcela
                                   ,pr_vldescto OUT NUMBER                --> Valor de Desconto da Parcela
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    /* .............................................................................
       Programa: pc_calcula_desconto_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Junho/2017                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o valor de desconto da parcela

       Alteracoes: 
    ............................................................................. */
    
    DECLARE
      -- Cursor do contrato de empréstimo
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crapepr.dtmvtolt
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      -- Cursor da proposta de empréstimo
      CURSOR cr_crawepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crawepr.txmensal,
               crawepr.cddindex
          FROM crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;
      
      -- Cursor da parcelaa dos Emprestimo
      CURSOR cr_crappep(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE
                       ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
        SELECT crappep.dtvencto,
               crappep.vlparepr,
               7.83     as vltaxatu
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
      
      -- Variaveis
      vr_tab_price             typ_tab_price;
      vr_qtparcel              PLS_INTEGER;
      vr_fator_price_total     NUMBER(25,10);      
      vr_vlpresente_liquido    NUMBER(25,2);
      vr_vljuros_remuneratorio NUMBER(25,2);
      vr_vljuros_correcao      NUMBER(25,2);
      vr_qtdias_juros_remun    PLS_INTEGER;
      vr_qtdia_juros_correcao  PLS_INTEGER;
      vr_dtvencto_util         DATE;
      vr_txdiaria              craplcr.txdiaria%TYPE;
      vr_dtvencto              crappep.dtvencto%TYPE;
      vr_dtmvtolt              crapdat.dtmvtolt%TYPE;

      -- Variaveis tratamento de erros
      vr_cdcritic              crapcri.cdcritic%TYPE;
      vr_dscritic              VARCHAR2(4000);
      vr_exc_erro              EXCEPTION;
    BEGIN
      vr_tab_price.DELETE;
      
      -- Buscar os dados da proposta de empréstimo
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr
        INTO rw_crawepr;
      -- Se não encotrou, incluir critica e sair do controle
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        vr_cdcritic := 535;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crawepr;
      
      -- Buscar os dados do contrato de empréstimo
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
        RAISE vr_exc_erro;
      END IF;
      -- Apenas fechar o cursor para continuar o processo
      CLOSE cr_crapepr;
    
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
        vr_dscritic := 'Parcela nao encontrada. Parcela: ' || TO_CHAR(pr_nrparepr);
        RAISE vr_exc_erro;
      END IF; 
      -- Apenas fechar o cursor
      CLOSE cr_crappep;
            
      -- Data de calculo do Price
      vr_dtmvtolt := pr_dtcalcul;
      
      -- Calculo para verificar quantos fator price deverá ser calculado
      vr_qtparcel := TO_NUMBER(TO_CHAR(rw_crappep.dtvencto,'yyyymm')) - TO_NUMBER(TO_CHAR(vr_dtmvtolt,'yyyymm'));
      IF vr_qtparcel <= 0 THEN
        vr_qtparcel := 1;
      END IF;

      -- Calculo da data de vencimento que sera comecado a calcular o fator price
      vr_dtvencto := ADD_MONTHS(rw_crappep.dtvencto,-vr_qtparcel);
      -- Rotina para calcular o price da parcela que sera antecipada
      pc_calcula_fator_price(pr_cdcooper          => pr_cdcooper
                            ,pr_flgbatch          => pr_flgbatch
                            ,pr_dtefetiv          => rw_crapepr.dtmvtolt
                            ,pr_dtvencto          => ADD_MONTHS(vr_dtvencto,1)
                            ,pr_txmensal          => rw_crawepr.txmensal
                            ,pr_vlrdtaxa          => 0 -- JFF
                            ,pr_qtparcel          => vr_qtparcel
                            ,pr_tab_price         => vr_tab_price
                            ,pr_fator_price_total => vr_fator_price_total
                            ,pr_cdcritic          => vr_cdcritic
                            ,pr_dscritic          => vr_dscritic);
                              
      -- Condicao para verificar se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      -- Condicao para verificar se foi calculado o fator price
      IF NOT vr_tab_price.EXISTS(vr_tab_price.FIRST) THEN
        vr_dscritic := 'Nao foi possivel calcular o fator price'; 
        RAISE vr_exc_erro;
      END IF;
        
      /**
        Cálculo para saber quantos dias de correção e juros remuneratorio será calculado
        Exemplo:
        Vencimento da parcela anterior: 13/11/2012
        Data Pagamento Parcela: 01/12/2012
        Cálculo será: 01/12/2012 - 13/11/2012
      */        
      vr_qtparcel := TO_NUMBER(TO_CHAR(rw_crappep.dtvencto,'yyyymm')) - TO_NUMBER(TO_CHAR(vr_dtmvtolt,'yyyymm')) + 1;
      vr_dtvencto := ADD_MONTHS(rw_crappep.dtvencto,-vr_qtparcel);
      -- Condicao para verificar se a parcela será pago dentro do mês da efetivação
      IF rw_crapepr.dtmvtolt >= vr_dtvencto THEN
        -- Vamos incrementar o mês, para a data de vencimento da parcela ficar com o mesmo mês da efetivação do contrato    
        vr_dtvencto      := ADD_MONTHS(vr_dtvencto,1);
        -- Caso a parcela venca hoje, a data de vencimento irá iniciar com a data da efetivacao do contrato
        vr_dtvencto_util := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,       --> Cooperativa conectada
                                                        pr_dtmvtolt  => vr_dtvencto,       --> Data do movimento
                                                        pr_tipo      => 'P');
        -- Condicao para verificar se a parcela vence hoje
        IF vr_dtvencto_util = vr_dtmvtolt THEN
          vr_dtvencto := rw_crapepr.dtmvtolt;
        END IF;                                              
      END IF;        
              
      -- Quantidade de dias corridos entre a data atual e o lancamento de juros remuneratorio
      pc_calcula_dias360(pr_ehmensal   => FALSE
                        ,pr_dtvencto   => rw_crappep.dtvencto
                        ,pr_dtrefjur   => vr_dtvencto
                        ,pr_data_final => vr_dtmvtolt
                        ,pr_qtdedias   => vr_qtdias_juros_remun
                        ,pr_cdcritic   => vr_cdcritic
                        ,pr_dscritic   => vr_dscritic);
      
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      -- Quantidade de dias uteis entre a data atual e o lancamento de juros remuneratorio
      pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper
                               ,pr_flgbatch    => pr_flgbatch
                               ,pr_dtefetiv    => rw_crapepr.dtmvtolt
                               ,pr_datainicial => vr_dtvencto
                               ,pr_datafinal   => vr_dtmvtolt
                               ,pr_qtdiaute    => vr_qtdia_juros_correcao
                               ,pr_cdcritic    => vr_cdcritic
                               ,pr_dscritic    => vr_dscritic);
                                      
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
          
      -- Calculo do Valor Presente Liquido
      vr_vlpresente_liquido    := rw_crappep.vlparepr / vr_tab_price(vr_tab_price.last).fator_acumulado;
      -- Calculo da taxa diaria
      vr_txdiaria              := POWER(1 + (NVL(rw_crawepr.txmensal,0) / 100),(1 / 30)) - 1;
      -- Calculo do Juros Remuneratorio
      vr_vljuros_remuneratorio := vr_vlpresente_liquido * (POWER(1 + vr_txdiaria,vr_qtdias_juros_remun) - 1);
      -- Calculo do Juros de Correção
      vr_vljuros_correcao      := vr_vlpresente_liquido * (POWER((1 + (rw_crappep.vltaxatu/100)),(vr_qtdia_juros_correcao/252)) -1);
      -- Valor da Parcela Total de Desconto
      pr_vlatupar              := vr_vlpresente_liquido + vr_vljuros_remuneratorio + vr_vljuros_correcao;      
      -- Valor de desconto
      pr_vldescto              := NVL(pr_vlsdvpar,0) - NVL(pr_vlatupar,0);
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_calcula_desconto_pos: ' || SQLERRM;
    END;

  END pc_calcula_desconto_pos;

  PROCEDURE pc_calcula_desconto_pos_web(pr_dtcalcul     IN VARCHAR2              --> Data do calculo
                                       ,pr_cdcooper     IN crapepr.cdcooper%TYPE --> Codigo da Cooperativa
                                       ,pr_nrdconta     IN crapepr.nrdconta%TYPE --> Numero da Conta
                                       ,pr_nrctremp     IN crapepr.nrctremp%TYPE --> Numero do Contrato                                          
                                       ,pr_nrparepr     IN crappep.nrparepr%TYPE --> Numero da Parcela
                                       ,pr_vlsdvpar     IN crappep.vlsdvpar%TYPE --> Saldo Devedor da Parcela
                                       ,pr_xmllog       IN VARCHAR2              --> XML com informacoes de LOG
                                       ,pr_cdcritic    OUT PLS_INTEGER           --> Codigo da critica
                                       ,pr_dscritic    OUT VARCHAR2              --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                       ,pr_nmdcampo    OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro    OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
    /* .............................................................................

       Programa: pc_calcula_desconto_pos_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Julho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para retornar o desconto.

       Alteracoes: 
    ............................................................................. */
    DECLARE
      -- Variaveis gerais
      vr_vlatupar NUMBER;
      vr_vldescto NUMBER;
      vr_dtcalcul crapdat.dtmvtolt%TYPE;

      -- Variaveis tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_calcula_desconto_pos_web'
                                ,pr_action => NULL);

      -- Converte para data
      vr_dtcalcul := TO_DATE(pr_dtcalcul,'DD/MM/RRRR');

      -- Busca ao desconto
      pc_calcula_desconto_pos(pr_dtcalcul => vr_dtcalcul
                             ,pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_nrparepr => pr_nrparepr
                             ,pr_vlsdvpar => pr_vlsdvpar
                             ,pr_vlatupar => vr_vlatupar
                             ,pr_vldescto => vr_vldescto
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlatupar'
                            ,pr_tag_cont => TO_CHAR(vr_vlatupar,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vldescto'
                            ,pr_tag_cont => TO_CHAR(vr_vldescto,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na procedure pc_calcula_desconto_pos_web: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
    
  END pc_calcula_desconto_pos_web;

  PROCEDURE pc_busca_pagto_parc_pos(pr_cdcooper     IN crapepr.cdcooper%TYPE      --> Codigo da Cooperativa
                                   ,pr_flgbatch     IN BOOLEAN DEFAULT FALSE      --> Indica se o processo noturno estah rodando
                                   ,pr_dtcalcul     IN crapdat.dtmvtolt%TYPE      --> Data de calculo das parcelas
                                   ,pr_nrdconta     IN crapepr.nrdconta%TYPE      --> Numero da Conta Corrente
                                   ,pr_nrctremp     IN crapepr.nrctremp%TYPE      --> Numero do Contrato
                                   ,pr_tab_parcelas OUT EMPR0011.typ_tab_parcelas --> Temp-Table contendo todas as parcelas calculadas
                                   ,pr_cdcritic     OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                   ,pr_dscritic     OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_busca_pagto_parc_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o saldo devedor do contrato

       Alteracoes: 
    ............................................................................. */
    DECLARE
      -- Cursor do contrato de empréstimo
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crapepr.dtmvtolt,
               crapepr.cdlcremp,
               crapepr.qttolatr
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      -- Cursor da proposta de empréstimo
      CURSOR cr_crawepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crawepr.txmensal,
               crawepr.cddindex
          FROM crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;

      -- Cursor da Linha de Crédito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT flgcobmu
              ,perjurmo
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
           AND craplcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;      

      -- Cursor da parcelaa dos Emprestimo
      CURSOR cr_crappep(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crappep.nrparepr,
               crappep.dtvencto,
               crappep.vlsdvpar,
               crappep.vlparepr,
               crappep.dtultpag,
               crappep.vlpagmta,
               crappep.vlpagpar
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           and crappep.inliquid = 0;

      -- Variveis Procedure
      vr_dstextab   craptab.dstextab%TYPE;
      vr_indice     PLS_INTEGER;
      vr_percmult   NUMBER(25,2);
      vr_dtmvtoan   DATE;

      -- Variaveis tratamento de erros
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      vr_exc_erro   EXCEPTION;
    BEGIN
      pr_tab_parcelas.DELETE;

      -- Buscar os dados da proposta de empréstimo
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr
        INTO rw_crawepr;
      -- Se não encotrou, incluir critica e sair do controle
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        vr_cdcritic := 535;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crawepr;

      -- Buscar os dados do contrato de empréstimo
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
        RAISE vr_exc_erro;
      END IF;
      -- Apenas fechar o cursor para continuar o processo
      CLOSE cr_crapepr;

      -- Buscar os dados da linha de crédito
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => rw_crapepr.cdlcremp);
      FETCH cr_craplcr
        INTO rw_craplcr;
      -- Se não encontrar informações
      IF cr_craplcr%NOTFOUND THEN
        -- Fechar o cursor pois teremos raise
        CLOSE cr_craplcr;
        -- Gerar erro com critica 363
        vr_cdcritic := 363;
        RAISE vr_exc_erro;
      END IF;
      -- Apenas fechar o cursor para continuar o processo
      CLOSE cr_craplcr;

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
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          RAISE vr_exc_erro;
        END IF;
        -- Utilizar como % de multa, as 6 primeiras posições encontradas
        vr_percmult := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,6));
      ELSE
        vr_percmult := 0;
      END IF;

      -- Funcao para retornar o dia anterior
      vr_dtmvtoan := GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                 pr_dtmvtolt  => pr_dtcalcul - 1,
                                                 pr_tipo      => 'A');

      -- Busca dos dados da parcela
      FOR rw_crappep IN cr_crappep(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp) LOOP

        -- Criar um novo indice para a temp-table
        vr_indice := pr_tab_parcelas.COUNT() + 1;
        -- Copiar as informações da tabela para a temp-table
        pr_tab_parcelas(vr_indice).nrparepr := rw_crappep.nrparepr;
        pr_tab_parcelas(vr_indice).vlparepr := rw_crappep.vlparepr;
        pr_tab_parcelas(vr_indice).dtvencto := rw_crappep.dtvencto;
        pr_tab_parcelas(vr_indice).vlsdvpar := rw_crappep.vlsdvpar;
        pr_tab_parcelas(vr_indice).vlpagpar := rw_crappep.vlpagpar;       

        -- Parcela em dia        
        IF rw_crappep.dtvencto > vr_dtmvtoan AND rw_crappep.dtvencto <= pr_dtcalcul THEN
          pr_tab_parcelas(vr_indice).vlatupar := rw_crappep.vlsdvpar;
          pr_tab_parcelas(vr_indice).insitpar := 1; -- Em Dia

        -- Parcela em Atraso
        ELSIF rw_crappep.dtvencto < pr_dtcalcul THEN
          -- Procedure para calcular o valor do atraso
          pc_calcula_atraso_pos_fixado (pr_dtcalcul => pr_dtcalcul
                                       ,pr_vlparepr => rw_crappep.vlparepr
                                       ,pr_dtvencto => rw_crappep.dtvencto
                                       ,pr_dtultpag => rw_crappep.dtultpag
                                       ,pr_vlsdvpar => rw_crappep.vlsdvpar
                                       ,pr_perjurmo => rw_craplcr.perjurmo
                                       ,pr_vlpagmta => rw_crappep.vlpagmta
                                       ,pr_percmult => vr_percmult
                                       ,pr_qttolatr => rw_crapepr.qttolatr
                                       ,pr_vlmrapar => pr_tab_parcelas(vr_indice).vlmrapar
                                       ,pr_vlmtapar => pr_tab_parcelas(vr_indice).vlmtapar
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

          -- Condicao para verificar se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Em Atraso
          pr_tab_parcelas(vr_indice).insitpar := 2;
          -- Valor da Parcela Atualizado
          pr_tab_parcelas(vr_indice).vlatupar := NVL(pr_tab_parcelas(vr_indice).vlsdvpar,0);

        -- Parcela à Vencer
        ELSIF rw_crappep.dtvencto > pr_dtcalcul THEN
          -- Calcula o desconto da parcela
          pc_calcula_desconto_pos(pr_dtcalcul => pr_dtcalcul
                                 ,pr_flgbatch => pr_flgbatch
                                 ,pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_nrparepr => rw_crappep.nrparepr
                                 ,pr_vlsdvpar => pr_tab_parcelas(vr_indice).vlsdvpar
                                 ,pr_vlatupar => pr_tab_parcelas(vr_indice).vlatupar
                                 ,pr_vldescto => pr_tab_parcelas(vr_indice).vldescto
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

          -- Condicao para verificar se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- A Vencer
          pr_tab_parcelas(vr_indice).insitpar := 3;          
        END IF;
      END LOOP;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_busca_pagto_parc_pos: ' || SQLERRM;
    END;
    
  END pc_busca_pagto_parc_pos;

  PROCEDURE pc_busca_pagto_parc_pos_prog(pr_cdcooper  IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                        ,pr_dtcalcul  IN VARCHAR2                  --> Data de calculo das parcelas
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do Contrato
                                        ,pr_vlpreapg OUT NUMBER                    --> Valor atualizado
                                        ,pr_vlprvenc OUT NUMBER                    --> Parcela Vencida
                                        ,pr_vlpraven OUT NUMBER                    --> Parcela EM DIA + Parcela A VENCER
                                        ,pr_vlmtapar OUT NUMBER                    --> Valor da multa por atraso
                                        ,pr_vlmrapar OUT NUMBER                    --> Valor de juros pelo atraso
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_busca_pagto_parc_pos_prog
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Julho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para retornar os valores das parcelas.

       Alteracoes: 
    ............................................................................. */
    DECLARE
      -- Variaveis gerais
      vr_indice       PLS_INTEGER;
      vr_dtcalcul     crapdat.dtmvtolt%TYPE;
      vr_tab_parcelas typ_tab_parcelas;
      vr_vlpreapg     NUMBER := 0;
      vr_vlprvenc     NUMBER := 0;
      vr_vlpraven     NUMBER := 0;
      vr_vlmtapar     NUMBER := 0;
      vr_vlmrapar     NUMBER := 0;

      -- Variaveis tratamento de erros
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      vr_exc_erro   EXCEPTION;

    BEGIN
      -- Converte para data
      vr_dtcalcul := TO_DATE(pr_dtcalcul,'DD/MM/RRRR');

      -- Busca as parcelas para pagamento
      pc_busca_pagto_parc_pos(pr_cdcooper => pr_cdcooper
                             ,pr_dtcalcul => vr_dtcalcul
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_tab_parcelas => vr_tab_parcelas
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Carregar as variveis de retorno
      vr_indice := vr_tab_parcelas.FIRST;
      WHILE vr_indice IS NOT NULL LOOP
        vr_vlpreapg := vr_vlpreapg + NVL(vr_tab_parcelas(vr_indice).vlatupar,0);
        vr_vlmtapar := vr_vlmtapar + NVL(vr_tab_parcelas(vr_indice).vlmtapar,0);
        vr_vlmrapar := vr_vlmrapar + NVL(vr_tab_parcelas(vr_indice).vlmrapar,0);

        CASE vr_tab_parcelas(vr_indice).insitpar
          -- Em Dia
          WHEN 1 THEN vr_vlpraven := vr_vlpraven + NVL(vr_tab_parcelas(vr_indice).vlatupar,0);
          -- Em Atraso
          WHEN 2 THEN vr_vlprvenc := vr_vlprvenc + NVL(vr_tab_parcelas(vr_indice).vlatupar,0);
          -- A Vencer
          WHEN 3 THEN vr_vlpraven := vr_vlpraven + NVL(vr_tab_parcelas(vr_indice).vlsdvpar,0);
        END CASE;

        vr_indice   := vr_tab_parcelas.NEXT(vr_indice);
      END LOOP;

      -- Retorna valores
      pr_vlpreapg := vr_vlpreapg;
      pr_vlprvenc := vr_vlprvenc;
      pr_vlpraven := vr_vlpraven;
      pr_vlmtapar := vr_vlmtapar;
      pr_vlmrapar := vr_vlmrapar;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_busca_pagto_parc_pos_prog: ' || SQLERRM;
    END;
    
  END pc_busca_pagto_parc_pos_prog;

  PROCEDURE pc_busca_pagto_parc_pos_web(pr_cdcooper     IN crapepr.cdcooper%TYPE      --> Codigo da Cooperativa
                                       ,pr_dtcalcul     IN VARCHAR2                   --> Data de calculo das parcelas
                                       ,pr_nrdconta     IN crapepr.nrdconta%TYPE      --> Numero da Conta Corrente
                                       ,pr_nrctremp     IN crapepr.nrctremp%TYPE      --> Numero do Contrato
                                       ,pr_xmllog       IN VARCHAR2                   --> XML com informacoes de LOG
                                       ,pr_cdcritic    OUT PLS_INTEGER                --> Codigo da critica
                                       ,pr_dscritic    OUT VARCHAR2                   --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype             --> Arquivo de retorno do XML
                                       ,pr_nmdcampo    OUT VARCHAR2                   --> Nome do campo com erro
                                       ,pr_des_erro    OUT VARCHAR2) IS               --> Erros do processo
  BEGIN
    /* .............................................................................

       Programa: pc_busca_pagto_parc_pos_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Julho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para retornar as parcelas do contrato.

       Alteracoes: 
    ............................................................................. */
    DECLARE
      -- Variaveis gerais
      vr_indice       PLS_INTEGER;
      vr_contador     INTEGER := 0;
      vr_dtcalcul     crapdat.dtmvtolt%TYPE;
      vr_tab_parcelas typ_tab_parcelas;

      -- Variaveis tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      vr_exc_erro     EXCEPTION;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_busca_pagto_parc_pos_web'
                                ,pr_action => NULL);

      -- Converte para data
      vr_dtcalcul := TO_DATE(pr_dtcalcul,'DD/MM/RRRR');

      -- Busca as parcelas para pagamento
      pc_busca_pagto_parc_pos(pr_cdcooper => pr_cdcooper
                             ,pr_dtcalcul => vr_dtcalcul
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_tab_parcelas => vr_tab_parcelas
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Montar XML
      vr_indice := vr_tab_parcelas.FIRST;
      WHILE vr_indice IS NOT NULL LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'parcela'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nrparepr'
                              ,pr_tag_cont => vr_tab_parcelas(vr_indice).nrparepr
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dtvencto'
                              ,pr_tag_cont => TO_CHAR(vr_tab_parcelas(vr_indice).dtvencto,'DD/MM/RRRR')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'insitpar'
                              ,pr_tag_cont => vr_tab_parcelas(vr_indice).insitpar
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlparepr'
                              ,pr_tag_cont => TO_CHAR(vr_tab_parcelas(vr_indice).vlparepr,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlpagpar'
                              ,pr_tag_cont => TO_CHAR(vr_tab_parcelas(vr_indice).vlpagpar,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlmtapar'
                              ,pr_tag_cont => TO_CHAR(NVL(vr_tab_parcelas(vr_indice).vlmtapar,0),'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlmrapar'
                              ,pr_tag_cont => TO_CHAR(NVL(vr_tab_parcelas(vr_indice).vlmrapar,0),'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vldescto'
                              ,pr_tag_cont => TO_CHAR(NVL(vr_tab_parcelas(vr_indice).vldescto,0),'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'parcela'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlatupar'
                              ,pr_tag_cont => TO_CHAR(vr_tab_parcelas(vr_indice).vlatupar,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
        vr_indice   := vr_tab_parcelas.NEXT(vr_indice);
      END LOOP;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na procedure pc_busca_pagto_parc_pos_web: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
    
  END pc_busca_pagto_parc_pos_web;
    
  PROCEDURE pc_calcula_iof_pos_fixado(pr_cdcooper        IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                     ,pr_nrdconta        IN crapass.nrdconta%TYPE     --> Numero da Conta
                                     ,pr_dtcalcul        IN crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                     ,pr_nrctremp        IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                     ,pr_cdlcremp        IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                     ,pr_vlemprst        IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                     ,pr_qtparepr        IN crapepr.qtpreemp%TYPE     --> Quantidade de parcelas
                                     ,pr_dtcarenc        IN crawepr.dtcarenc%TYPE     --> Data da Carência
                                     ,pr_dtdpagto        IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                     ,pr_vlpreemp        IN crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                     ,pr_txdiaria        IN crawepr.txdiaria%TYPE     --> Taxa diaria
                                     ,pr_txmensal        IN crawepr.txmensal%TYPE     --> Taxa mensal
                                     ,pr_qtdias_carencia IN tbepr_posfix_param_carencia.qtddias%TYPE   --> Quantidade de Dias
                                     ,pr_vltariof        OUT NUMBER                    --> Valor de IOF
                                     ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................
       Programa: pc_calcula_iof_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o IOF para Pos-Fixado.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis Calculo da Parcela
      vr_tab_parcelas typ_tab_parcelas;

      -- Variaveis tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;

    BEGIN

      -- Chama o calculo das parcelas
      pc_calcula_parcelas_pos_fixado(pr_cdcooper        => pr_cdcooper
                                    ,pr_dtcalcul        => pr_dtcalcul
                                    ,pr_cdlcremp        => pr_cdlcremp
                                    ,pr_dtcarenc        => pr_dtcarenc
                                    ,pr_qtdias_carencia => pr_qtdias_carencia
                                    ,pr_dtdpagto        => pr_dtdpagto
                                    ,pr_qtpreemp        => pr_qtparepr
                                    ,pr_vlemprst        => pr_vlemprst
                                    ,pr_tab_parcelas    => vr_tab_parcelas
                                    ,pr_cdcritic        => vr_cdcritic
                                    ,pr_dscritic        => vr_dscritic);
                                                                              
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      
      pr_vltariof := 2; -- JFF
      

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_calcula_iof_pos_fixado: ' || SQLERRM;

    END;

  END pc_calcula_iof_pos_fixado;

  PROCEDURE pc_valida_dados_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                      ,pr_qtparepr  IN crapepr.qtpreemp%TYPE     --> Quantidade de parcelas
                                      ,pr_dtlibera  IN crawepr.dtlibera%TYPE     --> Data da liberacao
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_dtcarenc  IN crawepr.dtcarenc%TYPE     --> Data da Carencia
                                      ,pr_flgpagto  IN crapepr.flgpagto%TYPE     --> Debito Folha: 0-Nao/1-Sim
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_valida_dados_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para validar as parcelas do Pos-Fixado.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis locais
      vr_blnfound            BOOLEAN;
      vr_vlminimo_emprestado tbepr_posfix_param.vlminimo_emprestado%TYPE;
      vr_vlmaximo_emprestado tbepr_posfix_param.vlmaximo_emprestado%TYPE;
      vr_qtdminima_parcela   tbepr_posfix_param.qtdminima_parcela%TYPE;
      vr_qtdmaxima_parcela   tbepr_posfix_param.qtdmaxima_parcela%TYPE;

      -- Variaveis tratamento de erros
      vr_cdcritic            crapcri.cdcritic%TYPE;
      vr_dscritic            VARCHAR2(4000);
      vr_exc_erro            EXCEPTION;

      -- Busca os dados da linha de credito
      CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%TYPE
                        ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT tpdescto
              ,dslcremp
              ,nrinipre
              ,nrfimpre
          FROM craplcr 
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

    BEGIN
      -- Buscar a taxa de juros
      OPEN cr_craplcr (pr_cdcooper => pr_cdcooper
                      ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_craplcr%FOUND;
      -- Fecha cursor
      CLOSE cr_craplcr;

      -- Se NAO achou
      IF NOT vr_blnfound THEN
        -- Gerar erro
        vr_cdcritic := 363;
        RAISE vr_exc_erro;
      END IF;

      -- Se for linha de Emprestimo Consignado
      IF rw_craplcr.tpdescto = 2 THEN
        vr_dscritic := 'Linha nao permitida para esse produto.';
        RAISE vr_exc_erro;
      END IF;    

      -- Se na decricao tiver CDC
      IF UPPER(TRIM(rw_craplcr.dslcremp)) LIKE '%CDC%' THEN
        vr_dscritic := 'Linha nao permitida para esse produto.';
        RAISE vr_exc_erro;
      END IF;

      -- Se na decricao tiver CREDITO DIRETO AO COOPERADO
      IF UPPER(TRIM(rw_craplcr.dslcremp)) LIKE '%CREDITO DIRETO AO COOPERADO%' THEN
        vr_dscritic := 'Linha nao permitida para esse produto.';
        RAISE vr_exc_erro;
      END IF;

      -- Se for debito em folha
      IF pr_flgpagto = 1 THEN
        vr_dscritic := 'Tipo de debito folha bloqueado para todas as operacoes.';
        RAISE vr_exc_erro;
      END IF;

      -- Se a quantidade de parcelas nao estiver dentro do limite
      IF pr_qtparepr < rw_craplcr.nrinipre OR
         pr_qtparepr > rw_craplcr.nrfimpre THEN
         vr_dscritic := 'Quantidade de parcelas deve estar dentro '
                     || 'da faixa limite parametrizada para a '
                     || 'linha de credito.';
         RAISE vr_exc_erro;
      END IF;

      -- Se data da liberacao menor que atual
      IF pr_dtlibera < pr_dtmvtolt THEN
        vr_dscritic := 'Data de Liberacao de Emprestimo nao pode '
                    || 'ser menor que data atual de movimento.';
        RAISE vr_exc_erro;
      END IF;

      -- Se data de pagamento menor que atual
      IF pr_dtdpagto < pr_dtmvtolt THEN
        vr_dscritic := 'Data de pagamento da primeira parcela '
                    || 'nao pode ser menor que data atual de movimento.';
        RAISE vr_exc_erro;
      END IF;

      -- Se mes do pagamento for menor ou igual ao da carencia
      IF TO_CHAR(pr_dtdpagto, 'MM') <= TO_CHAR(pr_dtcarenc, 'MM') THEN
        vr_dscritic := 'O campo Data de Pagamento nao pode ser menor ou igual ao mes do campo Data Pagto 1a Carencia.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Busca os dados parametrizados
      TELA_ATENDA_EMPRESTIMO.pc_busca_prmpos(pr_vlminimo_emprestado => vr_vlminimo_emprestado
                                            ,pr_vlmaximo_emprestado => vr_vlmaximo_emprestado
                                            ,pr_qtdminima_parcela   => vr_qtdminima_parcela  
                                            ,pr_qtdmaxima_parcela   => vr_qtdmaxima_parcela  
                                            ,pr_cdcritic            => vr_cdcritic
                                            ,pr_dscritic            => vr_dscritic);
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Se valor emprestado for menor que o minimo
      IF pr_vlemprst < vr_vlminimo_emprestado THEN
        vr_dscritic := 'O campo valor do emprestimo nao pode ser menor que o valor minimo R$ ' || to_char(vr_vlminimo_emprestado,'FM99G999G990D00') || ' parametrizado.';
        RAISE vr_exc_erro;
      END IF;

      -- Se possui valor maximo cadastrado e valor emprestado for maior que o maximo
      IF vr_vlmaximo_emprestado > 0 AND pr_vlemprst > vr_vlmaximo_emprestado THEN
        vr_dscritic := 'O campo valor do emprestimo nao pode ser maior que o valor maximo R$ ' || to_char(vr_vlmaximo_emprestado,'FM99G999G990D00') || ' parametrizado.';
        RAISE vr_exc_erro;
      END IF;

      -- Se quantidade for menor que a minima
      IF pr_qtparepr < vr_qtdminima_parcela THEN
        vr_dscritic := 'O campo quantidade de parcelas nao pode ser menor que a quantidade minima ' || vr_qtdminima_parcela || ' parametrizada.';
        RAISE vr_exc_erro;
      END IF;

      -- Se possui quantidade cadastrada e quantidade for maior que a maxima
      IF vr_qtdmaxima_parcela > 0 AND pr_qtparepr > vr_qtdmaxima_parcela THEN
        vr_dscritic := 'O campo quantidade de parcelas nao pode ser maior que a quantidade maxima ' || vr_qtdmaxima_parcela || ' parametrizada.';
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_valida_dados_pos_fixado: ' || SQLERRM;

    END;

  END pc_valida_dados_pos_fixado;

  PROCEDURE pc_grava_parcel_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                      ,pr_dtcalcul  IN crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                      ,pr_qtparepr  IN crapepr.qtpreemp%TYPE     --> Quantidade de parcelas
                                      ,pr_dtcarenc  IN crawepr.dtcarenc%TYPE     --> Data da Carência
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_vlpreemp OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                      ,pr_txdiaria OUT crawepr.txdiaria%TYPE     --> Taxa diaria
                                      ,pr_txmensal OUT crawepr.txmensal%TYPE     --> Taxa mensal
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_grava_parcel_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para gravar as parcelas do Pos-Fixado.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis locais
      vr_ind_parcelas BINARY_INTEGER;
      vr_tab_parcelas typ_tab_parcelas;
      vr_txdiaria     craplcr.txdiaria%TYPE;
      vr_vlpreemp     crapepr.vlpreemp%TYPE := 0;

      -- Variaveis tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      vr_exc_erro     EXCEPTION;

      -- Busca os dados da linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT txmensal
          FROM craplcr 
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
    BEGIN

      BEGIN
        DELETE
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      EXCEPTION
	      WHEN OTHERS THEN
          vr_dscritic := 'Problema ao deletar dados da crappep: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Chama o calculo das parcelas
      pc_calcula_parcelas_pos_fixado(pr_cdcooper        => pr_cdcooper
                                    ,pr_dtcalcul        => pr_dtcalcul
                                    ,pr_cdlcremp        => pr_cdlcremp
                                    ,pr_dtcarenc        => pr_dtcarenc
                                    ,pr_qtdias_carencia => 0 -- JFF
                                    ,pr_dtdpagto        => pr_dtdpagto
                                    ,pr_qtpreemp        => pr_qtparepr
                                    ,pr_vlemprst        => pr_vlemprst
                                    ,pr_tab_parcelas    => vr_tab_parcelas
                                    ,pr_cdcritic        => vr_cdcritic
                                    ,pr_dscritic        => vr_dscritic);
                                                                              
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Buscar Primeiro registro
      vr_ind_parcelas := vr_tab_parcelas.FIRST;

      -- Percorrer todos os registros
      WHILE vr_ind_parcelas IS NOT NULL LOOP

        -- Guarda a prestacao apenas uma vez
        IF vr_vlpreemp = 0 THEN
          vr_vlpreemp := vr_tab_parcelas(vr_ind_parcelas).vlparepr;
        END IF;

        BEGIN
          INSERT INTO crappep
                     (cdcooper
                     ,nrdconta
                     ,nrctremp
                     ,nrparepr
                     ,vlparepr
                     ,vlsdvpar
                     ,dtvencto
                     ,inliquid
                     ,vltaxatu)
               VALUES(pr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrctremp
                     ,vr_tab_parcelas(vr_ind_parcelas).nrparepr
                     ,vr_tab_parcelas(vr_ind_parcelas).vlparepr
                     ,vr_tab_parcelas(vr_ind_parcelas).vlparepr
                     ,vr_tab_parcelas(vr_ind_parcelas).dtvencto
                     ,0
                     ,vr_tab_parcelas(vr_ind_parcelas).vlrdtaxa);                     
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir dados na crappep: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        -- Proximo Registro
        vr_ind_parcelas:= vr_tab_parcelas.NEXT(vr_ind_parcelas);
      END LOOP;
      
      -- Buscar a taxa de juros
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      CLOSE cr_craplcr;

      -- Taxa de juros remunerados mensal
      vr_txdiaria := POWER(1 + (NVL(rw_craplcr.txmensal,0) / 100),(1 / 30)) - 1;

      BEGIN
        UPDATE crawepr
           SET vlpreemp = vr_vlpreemp
              ,txdiaria = vr_txdiaria
              ,txmensal = rw_craplcr.txmensal
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      EXCEPTION
	      WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar dados da crawepr: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Retorna os valores
      pr_vlpreemp := vr_vlpreemp;
      pr_txdiaria := vr_txdiaria;
      pr_txmensal := rw_craplcr.txmensal;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_grava_parcel_pos_fixado: ' || SQLERRM;

    END;

  END pc_grava_parcel_pos_fixado;

  PROCEDURE pc_busca_vl_prest_pos_prog(pr_cdcooper  IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtcalcul  IN crapdat.dtmvtoan%TYPE     --> Data do movimento anterior
                                      ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE     --> Quantidade de prestacoes
                                      ,pr_dtcarenc  IN crawepr.dtcarenc%TYPE     --> Data de Pagamento da Primeira Carência
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_vlsdeved  IN crapepr.vlsdeved%TYPE     --> Valor do saldo devedor
                                      ,pr_vlpreemp OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_busca_vl_prest_pos_prog
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para buscar o valor da prestacao do Pos-Fixado.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis Calculo da Parcela
      vr_tab_parcelas typ_tab_parcelas;

      -- Variaveis tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      vr_exc_erro     EXCEPTION;

    BEGIN
      -- Chama o calculo da parcela
      pc_calcula_parcelas_pos_fixado(pr_cdcooper        => pr_cdcooper
                                    ,pr_dtcalcul        => pr_dtcalcul
                                    ,pr_cdlcremp        => pr_cdlcremp
                                    ,pr_dtcarenc        => pr_dtcarenc
                                    ,pr_qtdias_carencia => 0 -- JFF
                                    ,pr_dtdpagto        => pr_dtdpagto
                                    ,pr_qtpreemp        => pr_qtpreemp
                                    ,pr_vlemprst        => pr_vlsdeved
                                    ,pr_tab_parcelas    => vr_tab_parcelas
                                    ,pr_cdcritic        => vr_cdcritic
                                    ,pr_dscritic        => vr_dscritic);
                                                                              
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Condicao para verificar se foi calculado parcelas do emprestimo
      IF NOT vr_tab_parcelas.EXISTS(vr_tab_parcelas.first) THEN
        vr_dscritic := 'Nao foi possivel calcular o valor da parcela';
        RAISE vr_exc_erro;
      END IF;
        
      pr_vlpreemp := vr_tab_parcelas(vr_tab_parcelas.first).vlparepr;
      
      /* 
      FOR vr_indice IN 1..vr_tab_parcelas.COUNT LOOP
        -- O valor da prestacao que sera apresentado em tela, sera o valor da parcela principal
        IF vr_tab_parcelas(vr_indice).flcarenc = 0 THEN
          pr_vlpreemp := vr_tab_parcelas(vr_indice).vlparepr;
          EXIT;
        END IF;
               
      END LOOP;
      */

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_busca_vl_prest_pos_prog: ' || SQLERRM;

    END;

  END pc_busca_vl_prest_pos_prog;

  PROCEDURE pc_alt_numero_parcelas_pos(pr_cdcooper      IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_nrdconta      IN crapass.nrdconta%TYPE     --> Numero da Conta
                                      ,pr_nrctremp_old  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_nrctremp_new  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_cdcritic     OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic     OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_alt_numero_parcelas_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para alterar o numero de contrato nas pascelas.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;

    BEGIN

      BEGIN
        UPDATE crappep
           SET nrctremp = pr_nrctremp_new
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp_old;
      EXCEPTION
	      WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar dados da crappep: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_alt_numero_parcelas_pos: ' || SQLERRM;

    END;

  END pc_alt_numero_parcelas_pos;

  PROCEDURE pc_exclui_prop_pos_fixado(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                     ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_exclui_prop_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Abril/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para excluir proposta do Pos-Fixado.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;

    BEGIN

      BEGIN
        DELETE
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      EXCEPTION
	      WHEN OTHERS THEN
          vr_dscritic := 'Problema ao excluir dados da crappep: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_exclui_prop_pos_fixado: ' || SQLERRM;

    END;

  END pc_exclui_prop_pos_fixado;

  PROCEDURE pc_efetua_credito_conta(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                   ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                   ,pr_cdprogra  IN crapprg.cdprogra%TYPE     --> Codigo Programa
                                   ,pr_inpessoa  IN crapass.inpessoa%TYPE     --> Tipo de pessoa
                                   ,pr_cdagenci  IN crapage.cdagenci%TYPE     --> Codigo da agencia
                                   ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                   ,pr_cdpactra  IN crapage.cdagenci%TYPE     --> Codigo do PA de Transacao
                                   ,pr_cdoperad  IN crapope.cdoperad%TYPE     --> Codigo do Operador
                                   ,pr_vltottar OUT NUMBER                    --> Valor da tarifa
                                   ,pr_vltariof OUT NUMBER                    --> Valor do IOF
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_efetua_credito_conta
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar o credito do emprestimo direto na conta online.

       Alteracoes: 
    ............................................................................. */

    DECLARE

      -- Busca o associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.vllimcre
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor de Emprestimo
      CURSOR cr_crawepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT qtpreemp
              ,vlpreemp
              ,vlemprst
              ,dtdpagto
              ,dtlibera
              ,cdfinemp
              ,cdlcremp
              ,tpemprst
          FROM crawepr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;

      -- Cursor de Portabilidade
      CURSOR cr_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapcop.nrdconta%TYPE
                             ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT 1
          FROM tbepr_portabilidade
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_portabilidade cr_portabilidade%ROWTYPE;

      -- Cursor da Linha de Credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT cdusolcr
              ,tpctrato
              ,flgcrcta
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Cursor dos Bens da Proposta
      CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT dscatbem
          FROM crapbpr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND tpctrpro = 90
           AND nrctrpro = pr_nrctremp
           AND flgalien = 1;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variaveis locais
      vr_vltottar NUMBER := 0;
      vr_vltariof NUMBER := 0;
      vr_cdhistor INTEGER;
      vr_cdhisest INTEGER;
      vr_vlrtarif NUMBER;
      vr_vltrfesp NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_cdhistmp craphis.cdhistor%TYPE;
      vr_cdfvltmp crapfco.cdfvlcop%TYPE;
      vr_cdlantar craplat.cdlantar%TYPE;
      vr_flgcrcta craplcr.flgcrcta%TYPE;
      vr_blnachou BOOLEAN;
      vr_cdbattar VARCHAR2(100) := ' ';
      vr_flgoutrosbens BOOLEAN;
      vr_index_saldo   PLS_INTEGER;
      vr_vlsldisp      NUMBER;
      vr_tab_saldos    EXTR0001.typ_tab_saldos;
      vr_rowid         ROWID;

      -- Variaveis tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_des_reto VARCHAR2(3);

    BEGIN
      -- Seleciona o calendario
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      vr_blnachou := BTCH0001.cr_crapdat%FOUND;
      CLOSE BTCH0001.cr_crapdat;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;

      -- Busca o associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      vr_blnachou := cr_crapass%FOUND;
      CLOSE cr_crapass;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      END IF;

      -- Buscar dados do emprestimo
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      vr_blnachou := cr_crawepr%FOUND;
      CLOSE cr_crawepr;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 510;
        RAISE vr_exc_erro;
      END IF;

      -- Selecionar Linha de Credito
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => rw_crawepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      vr_blnachou := cr_craplcr%FOUND;
      CLOSE cr_craplcr;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_dscritic := 'Linha de Credito nao encontrada.';
        RAISE vr_exc_erro;
      END IF;

      -- Consulta o registro na tabela de portabilidade
      OPEN cr_portabilidade(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp);
      FETCH cr_portabilidade INTO rw_portabilidade;
      vr_blnachou := cr_portabilidade%FOUND;
      CLOSE cr_portabilidade;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_flgcrcta := rw_craplcr.flgcrcta;
      ELSE
        vr_flgcrcta := 0;
      END IF;

      IF vr_flgcrcta = 1 THEN
        -- Efetua o credito na conta corrente do cooperado
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                      ,pr_cdbccxlt => 100           --> Numero do caixa
                                      ,pr_cdoperad => pr_cdoperad   --> Codigo do Operador
                                      ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                      ,pr_nrdolote => 8456          --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta   --> Numero da conta
                                      ,pr_cdhistor => 15            --> Codigo historico
                                      ,pr_vllanmto => rw_crawepr.vlemprst --> Valor do emprestimo
                                      ,pr_nrparepr => 0             --> Numero parcelas emprestimo
                                      ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                      ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao criar o lancamento de emprestimo na conta.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Calcula o IOF
      EMPR0001.pc_calcula_iof_epr(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_inpessoa => pr_inpessoa
                                 ,pr_cdlcremp => rw_crawepr.cdlcremp
                                 ,pr_qtpreemp => rw_crawepr.qtpreemp
                                 ,pr_vlpreemp => rw_crawepr.vlpreemp
                                 ,pr_vlemprst => rw_crawepr.vlemprst
                                 ,pr_dtdpagto => rw_crawepr.dtdpagto
                                 ,pr_dtlibera => rw_crawepr.dtlibera
                                 ,pr_tpemprst => rw_crawepr.tpemprst
                                 ,pr_valoriof => vr_vltariof
                                 ,pr_dscritic => vr_dscritic);
      -- Se ocorreu erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Se possuir IOF para cobranca
      IF vr_vltariof > 0 THEN

        -- Lanca o IOF na conta corrente do cooperado
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                      ,pr_cdbccxlt => 100           --> Numero do caixa
                                      ,pr_cdoperad => pr_cdoperad   --> Codigo do Operador
                                      ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                      ,pr_nrdolote => 10025         --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta   --> Numero da conta
                                      ,pr_cdhistor => 322           --> Codigo historico
                                      ,pr_vllanmto => vr_vltariof   --> Valor de IOF
                                      ,pr_nrparepr => 0             --> Numero parcelas emprestimo
                                      ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                      ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao criar o lancamento de IOF na conta.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        BEGIN
          UPDATE crapcot
             SET crapcot.vliofepr = crapcot.vliofepr + vr_vltariof
                ,crapcot.vlbsiepr = crapcot.vlbsiepr + rw_crawepr.vlemprst
           WHERE crapcot.cdcooper = pr_cdcooper
             AND crapcot.nrdconta = pr_nrdconta;
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a crapcot: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;

      END IF; -- vr_vltariof > 0

      -- Obter Saldo do Dia
      EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdagenci   => pr_cdagenci
                                 ,pr_nrdcaixa   => pr_nrdcaixa
                                 ,pr_cdoperad   => pr_cdoperad
                                 ,pr_nrdconta   => pr_nrdconta
                                 ,pr_flgcrass   => FALSE
                                 ,pr_vllimcre   => rw_crapass.vllimcre
                                 ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                 ,pr_des_reto   => vr_des_reto
                                 ,pr_tab_sald   => vr_tab_saldos
                                 ,pr_tipo_busca => 'A'
                                 ,pr_tab_erro   => vr_tab_erro);
      -- Buscar Indice
      vr_index_saldo := vr_tab_saldos.FIRST;
      IF vr_index_saldo IS NOT NULL THEN
        -- Saldo Disponivel
        vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0) +
                             NVL(vr_tab_saldos(vr_index_saldo).vllimcre, 0),2);
      END IF;

      -- Caso seja MICROCREDITO
      IF rw_craplcr.cdusolcr = 1 THEN

        IF pr_inpessoa = 1 THEN
          vr_cdbattar := 'MICROCREPF'; -- Microcredito Pessoa Fisica
        ELSE
          vr_cdbattar := 'MICROCREPJ'; -- Microcredito Pessoa Juridica
        END IF;
        
        -- Buscar tarifa emprestimo vigente
        TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                             ,pr_cdbattar => vr_cdbattar
                                             ,pr_vllanmto => rw_crawepr.vlemprst
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vlrtarif
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel carregar a tarifa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

      ELSE

        -- Buscar tarifa emprestimo
        TARI0001.pc_carrega_dados_tarifa_empr(pr_cdcooper => pr_cdcooper
                                             ,pr_cdlcremp => rw_crawepr.cdlcremp
                                             ,pr_cdmotivo => 'EM'
                                             ,pr_inpessoa => pr_inpessoa
                                             ,pr_vllanmto => rw_crawepr.vlemprst
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vlrtarif
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel carregar a tarifa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        -- Codigo historico
        vr_cdhistmp := vr_cdhistor;
        vr_cdfvltmp := vr_cdfvlcop;

        -- Buscar tarifa emprestimo Especial
        TARI0001.pc_carrega_dados_tarifa_empr(pr_cdcooper => pr_cdcooper
                                             ,pr_cdlcremp => rw_crawepr.cdlcremp
                                             ,pr_cdmotivo => 'ES'
                                             ,pr_inpessoa => pr_inpessoa
                                             ,pr_vllanmto => rw_crawepr.vlemprst
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vltrfesp
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel carregar a tarifa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        IF NVL(vr_cdhistor,0) = 0 AND NVL(vr_cdfvlcop,0) = 0 THEN
          -- Retornar Valores Salvos
          vr_cdhistor := vr_cdhistmp;
          vr_cdfvlcop := vr_cdfvltmp;
        END IF;

      END IF; -- rw_craplcr.cdusolcr = 1

      -- Total Tarifa a ser Cobrado
      vr_vltottar := NVL(vr_vlrtarif,0) + NVL(vr_vltrfesp,0);

      -- Se possuir Tarifa para cobranca
      IF vr_vltottar > 0 THEN

        -- Se possuir saldo
        IF vr_vlsldisp > vr_vltottar THEN

          -- Realizar lancamento tarifa
          TARI0001.pc_lan_tarifa_online(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                       ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia destino
                                       ,pr_nrdconta => pr_nrdconta   -- Numero da Conta Destino
                                       ,pr_cdbccxlt => 100           -- Codigo banco/caixa
                                       ,pr_nrdolote => 8452          -- Numero do Lote
                                       ,pr_tplotmov => 1             -- Tipo Lote
                                       ,pr_cdoperad => pr_cdoperad   -- Codigo Operador
                                       ,pr_dtmvtlat => pr_dtmvtolt   -- Data Tarifa
                                       ,pr_dtmvtlcm => pr_dtmvtolt   -- Data lancamento
                                       ,pr_nrdctabb => pr_nrdconta   -- Numero Conta BB
                                       ,pr_nrdctitg => TO_CHAR(pr_nrdconta,'fm00000000') -- Conta Integracao
                                       ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                       ,pr_cdpesqbb => pr_nrctremp   -- Codigo pesquisa
                                       ,pr_cdbanchq => 0             -- Codigo Banco Cheque
                                       ,pr_cdagechq => 0             -- Codigo Agencia Cheque
                                       ,pr_nrctachq => 0             -- Numero Conta Cheque
                                       ,pr_flgaviso => FALSE         -- Flag Aviso
                                       ,pr_tpdaviso => 0             -- Tipo Aviso
                                       ,pr_vltarifa => vr_vltottar   -- Valor tarifa
                                       ,pr_nrdocmto => pr_nrctremp   -- Numero Documento
                                       ,pr_cdcoptfn => 0             -- Codigo Cooperativa Terminal
                                       ,pr_cdagetfn => 0             -- Codigo Agencia Terminal
                                       ,pr_nrterfin => 0             -- Numero Terminal Financeiro
                                       ,pr_nrsequni => 0             -- Numero Sequencial Unico
                                       ,pr_nrautdoc => 0             -- Numero Autenticacao Documento
                                       ,pr_dsidenti => NULL          -- Descricao Identificacao
                                       ,pr_cdfvlcop => vr_cdfvlcop   -- Codigo Faixa Valor Cooperativa
                                       ,pr_inproces => 1             -- Indicador Processo
                                       ,pr_cdlantar => vr_cdlantar   -- Codigo Lancamento tarifa
                                       ,pr_tab_erro => vr_tab_erro   -- Tabela de erro
                                       ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                       ,pr_dscritic => vr_dscritic); -- Descricao do erro
          -- Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            -- Se possui algum erro na tabela de erros
            IF vr_tab_erro.COUNT() > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Nao foi possivel lancar a tarifa.';
            END IF;
            RAISE vr_exc_erro;
          END IF;

        ELSE

          -- Criar lancamento automatico de tarifa
          TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                          ,pr_nrdconta      => pr_nrdconta
                                          ,pr_dtmvtolt      => pr_dtmvtolt
                                          ,pr_cdhistor      => vr_cdhistor
                                          ,pr_vllanaut      => vr_vltottar
                                          ,pr_cdoperad      => pr_cdoperad
                                          ,pr_cdagenci      => pr_cdagenci
                                          ,pr_cdbccxlt 	    => 100
                                          ,pr_nrdolote      => 8452
                                          ,pr_tpdolote      => 1
                                          ,pr_nrdocmto      => pr_nrctremp
                                          ,pr_nrdctabb      => pr_nrdconta
                                          ,pr_nrdctitg      => GENE0002.fn_mask(pr_nrdconta,'99999999')
                                          ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(pr_nrctremp)
                                          ,pr_cdbanchq      => 0
                                          ,pr_cdagechq      => 0
                                          ,pr_nrctachq      => 0
                                          ,pr_flgaviso      => FALSE
                                          ,pr_tpdaviso      => 0
                                          ,pr_cdfvlcop      => vr_cdfvlcop
                                          ,pr_inproces      => 1
                                          ,pr_rowid_craplat => vr_rowid
                                          ,pr_tab_erro      => vr_tab_erro
                                          ,pr_cdcritic      => vr_cdcritic
                                          ,pr_dscritic      => vr_dscritic);
          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Subtrai do saldo o valor da tarifa
          vr_vlsldisp := vr_vlsldisp - vr_vltottar;

        END IF; -- vr_vlsldisp > vr_vltottar

      END IF; -- vr_vltottar > 0

      -- Limpa Variaveis de Tarifa     
      vr_vlrtarif := 0;
      vr_cdhistor := 0;
      vr_cdhisest := 0;
      vr_cdfvlcop := 0;

      -- 2 - Avaliacao de garantia de bem movel
      -- 3 - Avaliacao de garantia de bem imovel
      IF rw_craplcr.tpctrato IN (2,3) THEN

        IF rw_craplcr.tpctrato = 2 THEN -- Bem Movel
          IF pr_inpessoa = 1 THEN -- Fisica 
            vr_cdbattar := 'AVALBMOVPF'; -- Avaliacao de Garantia de Bem Movel - PF
          ELSE
            vr_cdbattar := 'AVALBMOVPJ'; -- Avaliacao de Garantia de Bem Movel - PJ
          END IF;
        ELSE -- Bens Imoveis
          IF pr_inpessoa = 1 THEN -- Fisica
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
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vlrtarif
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel carregar a tarifa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        IF rw_craplcr.tpctrato = 2 THEN -- Bem Movel
          vr_flgoutrosbens := FALSE;

          FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp) LOOP
            -- Se for carro, moto ou caminhao
            IF rw_crapbpr.dscatbem LIKE '%AUTOMOVEL%' 
            OR rw_crapbpr.dscatbem LIKE '%MOTO%' 
            OR rw_crapbpr.dscatbem LIKE '%CAMINHAO%' THEN

              -- Se possuir saldo
              IF vr_vlsldisp > vr_vlrtarif THEN

                -- Realizar lancamento tarifa
                TARI0001.pc_lan_tarifa_online(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                             ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia destino
                                             ,pr_nrdconta => pr_nrdconta   -- Numero da Conta Destino
                                             ,pr_cdbccxlt => 100           -- Codigo banco/caixa
                                             ,pr_nrdolote => 8452          -- Numero do Lote
                                             ,pr_tplotmov => 1             -- Tipo Lote
                                             ,pr_cdoperad => pr_cdoperad   -- Codigo Operador
                                             ,pr_dtmvtlat => pr_dtmvtolt   -- Data Tarifa
                                             ,pr_dtmvtlcm => pr_dtmvtolt   -- Data lancamento
                                             ,pr_nrdctabb => pr_nrdconta   -- Numero Conta BB
                                             ,pr_nrdctitg => TO_CHAR(pr_nrdconta,'fm00000000') -- Conta Integracao
                                             ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                             ,pr_cdpesqbb => pr_nrctremp   -- Codigo pesquisa
                                             ,pr_cdbanchq => 0             -- Codigo Banco Cheque
                                             ,pr_cdagechq => 0             -- Codigo Agencia Cheque
                                             ,pr_nrctachq => 0             -- Numero Conta Cheque
                                             ,pr_flgaviso => FALSE         -- Flag Aviso
                                             ,pr_tpdaviso => 0             -- Tipo Aviso
                                             ,pr_vltarifa => vr_vlrtarif   -- Valor tarifa
                                             ,pr_nrdocmto => pr_nrctremp   -- Numero Documento
                                             ,pr_cdcoptfn => 0             -- Codigo Cooperativa Terminal
                                             ,pr_cdagetfn => 0             -- Codigo Agencia Terminal
                                             ,pr_nrterfin => 0             -- Numero Terminal Financeiro
                                             ,pr_nrsequni => 0             -- Numero Sequencial Unico
                                             ,pr_nrautdoc => 0             -- Numero Autenticacao Documento
                                             ,pr_dsidenti => NULL          -- Descricao Identificacao
                                             ,pr_cdfvlcop => vr_cdfvlcop   -- Codigo Faixa Valor Cooperativa
                                             ,pr_inproces => 1             -- Indicador Processo
                                             ,pr_cdlantar => vr_cdlantar   -- Codigo Lancamento tarifa
                                             ,pr_tab_erro => vr_tab_erro   -- Tabela de erro
                                             ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                             ,pr_dscritic => vr_dscritic); -- Descricao do erro
                -- Se ocorreu erro
                IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  -- Se possui algum erro na tabela de erros
                  IF vr_tab_erro.COUNT() > 0 THEN
                    vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                    vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                  ELSE
                    vr_cdcritic := 0;
                    vr_dscritic := 'Nao foi possivel lancar a tarifa.';
                  END IF;
                  RAISE vr_exc_erro;
                END IF;

              ELSE

                -- Criar lancamento automatico de tarifa
                TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                                ,pr_nrdconta      => pr_nrdconta
                                                ,pr_dtmvtolt      => pr_dtmvtolt
                                                ,pr_cdhistor      => vr_cdhistor
                                                ,pr_vllanaut      => vr_vlrtarif
                                                ,pr_cdoperad      => pr_cdoperad
                                                ,pr_cdagenci      => pr_cdagenci
                                                ,pr_cdbccxlt 	    => 100
                                                ,pr_nrdolote      => 8452
                                                ,pr_tpdolote      => 1
                                                ,pr_nrdocmto      => pr_nrctremp
                                                ,pr_nrdctabb      => pr_nrdconta
                                                ,pr_nrdctitg      => GENE0002.fn_mask(pr_nrdconta,'99999999')
                                                ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(pr_nrctremp)
                                                ,pr_cdbanchq      => 0
                                                ,pr_cdagechq      => 0
                                                ,pr_nrctachq      => 0
                                                ,pr_flgaviso      => FALSE
                                                ,pr_tpdaviso      => 0
                                                ,pr_cdfvlcop      => vr_cdfvlcop
                                                ,pr_inproces      => 1
                                                ,pr_rowid_craplat => vr_rowid
                                                ,pr_tab_erro      => vr_tab_erro
                                                ,pr_cdcritic      => vr_cdcritic
                                                ,pr_dscritic      => vr_dscritic);
                -- Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;

                -- Subtrai do saldo o valor da tarifa
                vr_vlsldisp := vr_vlsldisp - vr_vlrtarif;

              END IF; -- vr_vlsldisp > vr_vlrtarif

              -- Total Tarifa a ser Cobrado
              vr_vltottar := NVL(vr_vltottar,0) + NVL(vr_vlrtarif,0);

            ELSE
              vr_flgoutrosbens := TRUE;
            END IF; -- Se for carro, moto ou caminhao

          END LOOP; -- cr_crapbpr
          
          -- Se houver outros bens cobrar mais uma tarifa
          IF vr_flgoutrosbens THEN

              -- Se possuir saldo
              IF vr_vlsldisp > vr_vlrtarif THEN

                -- Realizar lancamento tarifa
                TARI0001.pc_lan_tarifa_online(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                             ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia destino
                                             ,pr_nrdconta => pr_nrdconta   -- Numero da Conta Destino
                                             ,pr_cdbccxlt => 100           -- Codigo banco/caixa
                                             ,pr_nrdolote => 8452          -- Numero do Lote
                                             ,pr_tplotmov => 1             -- Tipo Lote
                                             ,pr_cdoperad => pr_cdoperad   -- Codigo Operador
                                             ,pr_dtmvtlat => pr_dtmvtolt   -- Data Tarifa
                                             ,pr_dtmvtlcm => pr_dtmvtolt   -- Data lancamento
                                             ,pr_nrdctabb => pr_nrdconta   -- Numero Conta BB
                                             ,pr_nrdctitg => TO_CHAR(pr_nrdconta,'fm00000000') -- Conta Integracao
                                             ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                             ,pr_cdpesqbb => pr_nrctremp   -- Codigo pesquisa
                                             ,pr_cdbanchq => 0             -- Codigo Banco Cheque
                                             ,pr_cdagechq => 0             -- Codigo Agencia Cheque
                                             ,pr_nrctachq => 0             -- Numero Conta Cheque
                                             ,pr_flgaviso => FALSE         -- Flag Aviso
                                             ,pr_tpdaviso => 0             -- Tipo Aviso
                                             ,pr_vltarifa => vr_vlrtarif   -- Valor tarifa
                                             ,pr_nrdocmto => pr_nrctremp   -- Numero Documento
                                             ,pr_cdcoptfn => 0             -- Codigo Cooperativa Terminal
                                             ,pr_cdagetfn => 0             -- Codigo Agencia Terminal
                                             ,pr_nrterfin => 0             -- Numero Terminal Financeiro
                                             ,pr_nrsequni => 0             -- Numero Sequencial Unico
                                             ,pr_nrautdoc => 0             -- Numero Autenticacao Documento
                                             ,pr_dsidenti => NULL          -- Descricao Identificacao
                                             ,pr_cdfvlcop => vr_cdfvlcop   -- Codigo Faixa Valor Cooperativa
                                             ,pr_inproces => 1             -- Indicador Processo
                                             ,pr_cdlantar => vr_cdlantar   -- Codigo Lancamento tarifa
                                             ,pr_tab_erro => vr_tab_erro   -- Tabela de erro
                                             ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                             ,pr_dscritic => vr_dscritic); -- Descricao do erro
                -- Se ocorreu erro
                IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  -- Se possui algum erro na tabela de erros
                  IF vr_tab_erro.COUNT() > 0 THEN
                    vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                    vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                  ELSE
                    vr_cdcritic := 0;
                    vr_dscritic := 'Nao foi possivel lancar a tarifa.';
                  END IF;
                  RAISE vr_exc_erro;
                END IF;

              ELSE

                -- Criar lancamento automatico de tarifa
                TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                                ,pr_nrdconta      => pr_nrdconta
                                                ,pr_dtmvtolt      => pr_dtmvtolt
                                                ,pr_cdhistor      => vr_cdhistor
                                                ,pr_vllanaut      => vr_vlrtarif
                                                ,pr_cdoperad      => pr_cdoperad
                                                ,pr_cdagenci      => pr_cdagenci
                                                ,pr_cdbccxlt 	    => 100
                                                ,pr_nrdolote      => 8452
                                                ,pr_tpdolote      => 1
                                                ,pr_nrdocmto      => pr_nrctremp
                                                ,pr_nrdctabb      => pr_nrdconta
                                                ,pr_nrdctitg      => GENE0002.fn_mask(pr_nrdconta,'99999999')
                                                ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(pr_nrctremp)
                                                ,pr_cdbanchq      => 0
                                                ,pr_cdagechq      => 0
                                                ,pr_nrctachq      => 0
                                                ,pr_flgaviso      => FALSE
                                                ,pr_tpdaviso      => 0
                                                ,pr_cdfvlcop      => vr_cdfvlcop
                                                ,pr_inproces      => 1
                                                ,pr_rowid_craplat => vr_rowid
                                                ,pr_tab_erro      => vr_tab_erro
                                                ,pr_cdcritic      => vr_cdcritic
                                                ,pr_dscritic      => vr_dscritic);
                -- Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;

              END IF; -- vr_vlsldisp > vr_vlrtarif

              -- Total Tarifa a ser Cobrado
              vr_vltottar := NVL(vr_vltottar,0) + NVL(vr_vlrtarif,0);

          END IF; -- vr_flgoutrosbens

        ELSE

          -- Se possuir saldo
          IF vr_vlsldisp > vr_vlrtarif THEN

            -- Realizar lancamento tarifa
            TARI0001.pc_lan_tarifa_online(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                         ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia destino
                                         ,pr_nrdconta => pr_nrdconta   -- Numero da Conta Destino
                                         ,pr_cdbccxlt => 100           -- Codigo banco/caixa
                                         ,pr_nrdolote => 8452          -- Numero do Lote
                                         ,pr_tplotmov => 1             -- Tipo Lote
                                         ,pr_cdoperad => pr_cdoperad   -- Codigo Operador
                                         ,pr_dtmvtlat => pr_dtmvtolt   -- Data Tarifa
                                         ,pr_dtmvtlcm => pr_dtmvtolt   -- Data lancamento
                                         ,pr_nrdctabb => pr_nrdconta   -- Numero Conta BB
                                         ,pr_nrdctitg => TO_CHAR(pr_nrdconta,'fm00000000') -- Conta Integracao
                                         ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                         ,pr_cdpesqbb => pr_nrctremp   -- Codigo pesquisa
                                         ,pr_cdbanchq => 0             -- Codigo Banco Cheque
                                         ,pr_cdagechq => 0             -- Codigo Agencia Cheque
                                         ,pr_nrctachq => 0             -- Numero Conta Cheque
                                         ,pr_flgaviso => FALSE         -- Flag Aviso
                                         ,pr_tpdaviso => 0             -- Tipo Aviso
                                         ,pr_vltarifa => vr_vlrtarif   -- Valor tarifa
                                         ,pr_nrdocmto => pr_nrctremp   -- Numero Documento
                                         ,pr_cdcoptfn => 0             -- Codigo Cooperativa Terminal
                                         ,pr_cdagetfn => 0             -- Codigo Agencia Terminal
                                         ,pr_nrterfin => 0             -- Numero Terminal Financeiro
                                         ,pr_nrsequni => 0             -- Numero Sequencial Unico
                                         ,pr_nrautdoc => 0             -- Numero Autenticacao Documento
                                         ,pr_dsidenti => NULL          -- Descricao Identificacao
                                         ,pr_cdfvlcop => vr_cdfvlcop   -- Codigo Faixa Valor Cooperativa
                                         ,pr_inproces => 1             -- Indicador Processo
                                         ,pr_cdlantar => vr_cdlantar   -- Codigo Lancamento tarifa
                                         ,pr_tab_erro => vr_tab_erro   -- Tabela de erro
                                         ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                         ,pr_dscritic => vr_dscritic); -- Descricao do erro
            -- Se ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              -- Se possui algum erro na tabela de erros
              IF vr_tab_erro.COUNT() > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Nao foi possivel lancar a tarifa.';
              END IF;
              RAISE vr_exc_erro;
            END IF;

          ELSE

            -- Criar lancamento automatico de tarifa
            TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                            ,pr_nrdconta      => pr_nrdconta
                                            ,pr_dtmvtolt      => pr_dtmvtolt
                                            ,pr_cdhistor      => vr_cdhistor
                                            ,pr_vllanaut      => vr_vlrtarif
                                            ,pr_cdoperad      => pr_cdoperad
                                            ,pr_cdagenci      => pr_cdagenci
                                            ,pr_cdbccxlt 	    => 100
                                            ,pr_nrdolote      => 8452
                                            ,pr_tpdolote      => 1
                                            ,pr_nrdocmto      => pr_nrctremp
                                            ,pr_nrdctabb      => pr_nrdconta
                                            ,pr_nrdctitg      => GENE0002.fn_mask(pr_nrdconta,'99999999')
                                            ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(pr_nrctremp)
                                            ,pr_cdbanchq      => 0
                                            ,pr_cdagechq      => 0
                                            ,pr_nrctachq      => 0
                                            ,pr_flgaviso      => FALSE
                                            ,pr_tpdaviso      => 0
                                            ,pr_cdfvlcop      => vr_cdfvlcop
                                            ,pr_inproces      => 1
                                            ,pr_rowid_craplat => vr_rowid
                                            ,pr_tab_erro      => vr_tab_erro
                                            ,pr_cdcritic      => vr_cdcritic
                                            ,pr_dscritic      => vr_dscritic);
            -- Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

          END IF; -- vr_vlsldisp > vr_vlrtarif

          -- Total Tarifa a ser Cobrado
          vr_vltottar := NVL(vr_vltottar,0) + NVL(vr_vlrtarif,0);
    
        END IF; -- rw_craplcr.tpctrato = 2

      END IF; -- rw_craplcr.tpctrato IN (2,3)

      -- Retorna as tarifas
      pr_vltottar := NVL(vr_vltottar, 0);
      pr_vltariof := NVL(vr_vltariof, 0);

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_efetua_credito_conta: ' || SQLERRM;

    END;

  END pc_efetua_credito_conta;

  PROCEDURE pc_busca_tip_atualiz_index(pr_cddindex       IN tbepr_posfix_param_index.cddindex%TYPE      --> Codigo do indice (FK crapind)
                                      ,pr_tpatualizacao OUT tbepr_posfix_param_index.tpatualizacao%TYPE --> Tipo de Atualizacao Indexador
                                      ,pr_cdcritic      OUT crapcri.cdcritic%TYPE                       --> Codigo da critica
                                      ,pr_dscritic      OUT crapcri.dscritic%TYPE) IS                   --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_busca_tip_atualiz_index
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Junho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para buscar o Tipo de Atualizacao Indexador (1-Diario / 2-Quinzenal / 3-Mensal).

       Alteracoes: 
    ............................................................................. */

    DECLARE

      -- Busca os dados do Indexador Parametros
      CURSOR cr_param_index(pr_cddindex IN tbepr_posfix_param_index.cddindex%TYPE) IS
        SELECT tpatualizacao
          FROM tbepr_posfix_param_index
         WHERE cddindex = pr_cddindex;

      -- Variaveis
      vr_tpatualizacao tbepr_posfix_param_index.tpatualizacao%TYPE;

    BEGIN
      OPEN  cr_param_index(pr_cddindex => pr_cddindex);
      FETCH cr_param_index INTO vr_tpatualizacao;
      CLOSE cr_param_index;
      pr_tpatualizacao := NVL(vr_tpatualizacao,0);
    EXCEPTION

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure pc_busca_tip_atualiz_index: ' || SQLERRM;

    END;

  END pc_busca_tip_atualiz_index;
  
  PROCEDURE pc_efetua_lcto_juros_remun(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtcalcul IN  crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                      ,pr_cdagenci IN  crapage.cdagenci%TYPE     --> Codigo da Agencia
                                      ,pr_cdpactra IN  crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                      ,pr_cdoperad IN  crapope.cdoperad%TYPE     --> Codigo do Operador
                                      ,pr_cdorigem IN  NUMBER                    --> Codigo da Origem
                                      ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                      ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                      ,pr_txjuremp IN  crapepr.txjuremp%TYPE     --> Taxa de Juros do Emprestimo
                                      ,pr_vlpreemp IN  crapepr.vlpreemp%TYPE     --> Valor da prestacao do Emprestimo
                                      ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de Liberacao do Contrato
                                      ,pr_dtrefjur IN  crapepr.dtrefjur%TYPE     --> Data do lancamento de Juros
                                      ,pr_floperac IN  BOOLEAN                   --> Flag do contrato de Financiamento
                                      ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                      ,pr_vlsprojt IN  crapepr.vlsdeved%TYPE     --> Valor do Saldo Devedor Projetado
                                      ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando na mensal
                                      ,pr_txdiaria IN  NUMBER                    --> Taxa Diaria do Contrato
                                      ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                      ,pr_vljuremu OUT NUMBER                    --> Juros Remuneratorios
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_efetua_lcto_juros_remun
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Julho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar o lancamento de Juros Remuneratorio

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Buscar ultimo lancamento de Juros
      CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE
                       ,pr_dtmvtolt IN DATE) IS
        SELECT SUM(vllanmto) vllanmto
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND cdhistor IN (2342,2343)
           AND dtmvtolt = pr_dtmvtolt;
      rw_craplem cr_craplem%ROWTYPE;

      -- Variaveis de calculo da procedure
      vr_blnachou       BOOLEAN;
      vr_cdhistor	      craphis.cdhistor%TYPE;
      vr_qtdedias       PLS_INTEGER;
      vr_vljuros        NUMBER(25,2);
      vr_vlsprojt       crapepr.vlsprojt%TYPE;
      vr_vljuros_mensal craplem.vllanmto%TYPE := 0;
      vr_data_inicial   DATE;
      vr_data_final     DATE;

      -- Variaveis tratamento de erro
      vr_cdcritic       crapcri.cdcritic%TYPE;
      vr_dscritic       VARCHAR2(4000);
      vr_exc_erro       EXCEPTION;

    BEGIN
      -- Logica para encontrar a data inicial para calculo
      IF pr_dtrefjur IS NOT NULL THEN
        IF pr_ehmensal THEN
          vr_data_inicial := pr_dtvencto;
        ELSE
          -- Ultimo dia do mes anterior
          vr_data_inicial := last_day(add_months(pr_dtcalcul,-1));
        END IF;      
      ELSE
        vr_data_inicial := pr_dtlibera;
      END IF;  
    
      -- Logica para encontrar a data final para o calculo do juros
      IF pr_ehmensal THEN
        vr_data_final := last_day(pr_dtcalcul);
      ELSE
        vr_data_final := pr_dtvencto;
      END IF;  
    
      -- Procedure para calcular os dias corridos
      pc_calcula_dias360(pr_ehmensal   => pr_ehmensal
                        ,pr_dtvencto   => pr_dtvencto
                        ,pr_dtrefjur   => vr_data_inicial
                        ,pr_data_final => vr_data_final
                        ,pr_qtdedias   => vr_qtdedias
                        ,pr_cdcritic   => vr_cdcritic
                        ,pr_dscritic   => vr_dscritic);
      
      -- Condicao para verificar se ocorreu erro                  
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Saldo Projetado Inicial
      vr_vlsprojt := pr_vlsprojt;

      -- Se NAO for mensal
      IF NOT pr_ehmensal AND pr_dtrefjur IS NOT NULL THEN

        -- Buscar o ultimo lancamento de Juros
        OPEN cr_craplem(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp
                       ,pr_dtmvtolt => pr_dtrefjur);
        FETCH cr_craplem INTO rw_craplem;
        vr_blnachou := cr_craplem%FOUND;
        CLOSE cr_craplem;
        -- Se achou
        IF vr_blnachou THEN
          -- Adiciona o Juros ao Saldo Projetado
          vr_vljuros_mensal := NVL(rw_craplem.vllanmto,0);
        END IF;

      END IF;

      -- Valor do Juros Remuneratorio
      vr_vljuros := (NVL(vr_vlsprojt,0) + NVL(vr_vljuros_mensal,0)) * NVL((POWER(1 + pr_txdiaria,vr_qtdedias)-1),0);

      -- Operacao de Financiamento
      IF pr_floperac THEN
        --Codigo historico
        vr_cdhistor := 2343;
      ELSE
        --Codigo historico
        vr_cdhistor := 2342;
      END IF;

      -- Se possui juros
      IF vr_vljuros > 0 THEN

        /* Cria lancamento e atualiza o lote  */
        EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                       ,pr_dtmvtolt => pr_dtcalcul         --Data Emprestimo
                                       ,pr_cdagenci => pr_cdagenci         --Codigo Agencia
                                       ,pr_cdbccxlt => 100                 --Codigo Caixa
                                       ,pr_cdoperad => pr_cdoperad         --Operador
                                       ,pr_cdpactra => pr_cdpactra         --Posto Atendimento
                                       ,pr_tplotmov => 5                   --Tipo movimento
                                       ,pr_nrdolote => 650004              --Numero Lote
                                       ,pr_nrdconta => pr_nrdconta         --Numero da Conta
                                       ,pr_cdhistor => vr_cdhistor         --Codigo Historico
                                       ,pr_nrctremp => pr_nrctremp         --Numero Contrato
                                       ,pr_vllanmto => vr_vljuros          --Valor Lancamento
                                       ,pr_dtpagemp => pr_dtcalcul         --Data Pagamento Emprestimo
                                       ,pr_txjurepr => pr_txjuremp         --Taxa Juros Emprestimo
                                       ,pr_vlpreemp => pr_vlpreemp         --Valor Emprestimo
                                       ,pr_nrsequni => 0                   --Numero Sequencia
                                       ,pr_nrparepr => pr_nrparepr         --Numero Parcelas Emprestimo
                                       ,pr_flgincre => TRUE                --Indicador Credito
                                       ,pr_flgcredi => TRUE                --Credito
                                       ,pr_nrseqava => 0                   --Pagamento: Sequencia do avalista
                                       ,pr_cdorigem => pr_cdorigem         -- Origem do Lançamento
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Erro
                                       ,pr_dscritic => vr_dscritic);       --Descricao Erro
        -- Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Se NAO for mensal
        IF NOT pr_ehmensal THEN
          -- Atualizar Emprestimo
          BEGIN
            UPDATE crapepr
               SET crapepr.vlsprojt = NVL(crapepr.vlsprojt,0) + NVL(vr_vljuros_mensal,0) + NVL(vr_vljuros,0) 
             WHERE crapepr.cdcooper = pr_cdcooper
               AND crapepr.nrdconta = pr_nrdconta
               AND crapepr.nrctremp = pr_nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
        
      END IF; -- vr_vljuros > 0

      -- Retorna o juros
      pr_vljuremu := NVL(vr_vljuros,0);

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
              
      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure EMPR0011.pc_efetua_lcto_juros_remun: ' || SQLERRM;
    END;

  END pc_efetua_lcto_juros_remun;

  PROCEDURE pc_efetua_lcto_juros_correc (pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                        ,pr_dtcalcul IN  crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                        ,pr_cdagenci IN  crapage.cdagenci%TYPE     --> Codigo da Agencia
                                        ,pr_cdpactra IN  crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                        ,pr_cdoperad IN  crapope.cdoperad%TYPE     --> Codigo do Operador
                                        ,pr_cdorigem IN  NUMBER                    --> Codigo da Origem
                                        ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                        ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente                                        
                                        ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                        ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de liberacao do Contrato
                                        ,pr_dtrefjur IN  DATE                      --> Data de Referencia de lancamento de Juros
                                        ,pr_vlrdtaxa IN  NUMBER                    --> Valor da Taxa de Atualizacao da Parcela
                                        ,pr_txjuremp IN  crapepr.txjuremp%TYPE     --> Taxa de Juros do Emprestimo
                                        ,pr_vlpreemp IN  crapepr.vlpreemp%TYPE     --> Valor da prestacao do Emprestimo
                                        ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                        ,pr_vlsprojt IN  NUMBER                    --> Saldo Devedor Projetado
                                        ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando a mensal
                                        ,pr_floperac IN  BOOLEAN                   --> Indicador se a Operacao eh Financiamento
                                        ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                        ,pr_vljurcor OUT NUMBER                    --> Juros de Correcao
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................
       Programa: pc_efetua_lcto_juros_correc
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Julho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar o lancamento de Juros de Correcao

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Buscar ultimo lancamento de Juros
      CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE
                       ,pr_dtmvtolt IN DATE) IS
        SELECT SUM(vllanmto) vllanmto
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND cdhistor IN (2344,2345)
           AND dtmvtolt = pr_dtmvtolt;
      rw_craplem cr_craplem%ROWTYPE;

      -- Variaveis de calculo da procedure
      vr_blnachou       BOOLEAN;
      vr_cdhistor	      craphis.cdhistor%TYPE;
      vr_qtdedias       PLS_INTEGER;
      vr_taxa_periodo   NUMBER(25,8);
      vr_vlsprojt       NUMBER(25,2);
      vr_vljuros        NUMBER(25,2);
      vr_vljuros_mensal craplem.vllanmto%TYPE := 0;
      vr_data_final     DATE;
      vr_data_inicial   date;

      -- Variaveis tratamento de erro
      vr_cdcritic       crapcri.cdcritic%TYPE;
      vr_dscritic       VARCHAR2(4000);
      vr_exc_erro       EXCEPTION;

    BEGIN
      -- Logica para encontrar a data inicial do calculo do Juros de Correcao
      IF pr_dtrefjur IS NOT NULL THEN
        IF pr_ehmensal THEN
          vr_data_inicial := pr_dtvencto;
        ELSE
          -- Ultimo dia do mes anterior
          vr_data_inicial := last_day(add_months(pr_dtcalcul,-1));
        END IF;      
      ELSE
        vr_data_inicial := pr_dtlibera;
      END IF; 
      
      -- Logica para encontrar a data final do calculo do Juros de Correcao
      IF pr_ehmensal THEN
        vr_data_final := last_day(pr_dtcalcul);
      ELSE
        vr_data_final := pr_dtvencto;
      END IF;
      
      -- Calcula a diferenca entre duas datas e retorna os dias Uteis
      pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper
                               ,pr_flgbatch    => pr_flgbatch
                               ,pr_dtefetiv    => pr_dtlibera
                               ,pr_datainicial => vr_data_inicial
                               ,pr_datafinal   => vr_data_final
                               ,pr_qtdiaute    => vr_qtdedias
                               ,pr_cdcritic    => vr_cdcritic
                               ,pr_dscritic    => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Calculo da taxa no periodo Anterior
      vr_taxa_periodo := ROUND(POWER((1 + (pr_vlrdtaxa / 100)),(vr_qtdedias / 252)) - 1,8);
      -- Condicao para verificar se devemos calcular o Juros de Correcao
      IF vr_taxa_periodo <= 0 THEN
        RETURN;
      END IF;

      -- Saldo Projetado Inicial
      vr_vlsprojt := pr_vlsprojt;

      -- Se NAO for mensal
      IF NOT pr_ehmensal AND pr_dtrefjur IS NOT NULL THEN
        -- Buscar ultimo lancamento de Juros
        OPEN cr_craplem(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp
                       ,pr_dtmvtolt => pr_dtrefjur);
        FETCH cr_craplem INTO rw_craplem;
        vr_blnachou := cr_craplem%FOUND;
        CLOSE cr_craplem;
        -- Se achou
        IF vr_blnachou THEN
          -- Adiciona o Juros ao Saldo Projetado
          vr_vljuros_mensal := NVL(rw_craplem.vllanmto,0);
        END IF;

      END IF;

      -- Valor do Juros de Correcao
      vr_vljuros := (NVL(vr_vlsprojt,0) + NVL(vr_vljuros_mensal,0)) * vr_taxa_periodo;

      -- Operacao de Financiamento
      IF pr_floperac THEN
        --Codigo historico
        vr_cdhistor := 2345;
      ELSE
        --Codigo historico
        vr_cdhistor := 2344;
      END IF;
      
      -- Se possuir juros
      IF vr_vljuros > 0 THEN

        /* Cria lancamento e atualiza o lote  */
        EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                       ,pr_dtmvtolt => pr_dtcalcul         --Data Emprestimo
                                       ,pr_cdagenci => pr_cdagenci         --Codigo Agencia
                                       ,pr_cdbccxlt => 100                 --Codigo Caixa
                                       ,pr_cdoperad => pr_cdoperad         --Operador
                                       ,pr_cdpactra => pr_cdpactra         --Posto Atendimento
                                       ,pr_tplotmov => 5                   --Tipo movimento
                                       ,pr_nrdolote => 650004              --Numero Lote
                                       ,pr_nrdconta => pr_nrdconta         --Numero da Conta
                                       ,pr_cdhistor => vr_cdhistor         --Codigo Historico
                                       ,pr_nrctremp => pr_nrctremp         --Numero Contrato
                                       ,pr_vllanmto => vr_vljuros          --Valor Lancamento
                                       ,pr_dtpagemp => pr_dtcalcul         --Data Pagamento Emprestimo
                                       ,pr_txjurepr => pr_txjuremp         --Taxa Juros Emprestimo
                                       ,pr_vlpreemp => pr_vlpreemp         --Valor Emprestimo
                                       ,pr_nrsequni => 0                   --Numero Sequencia
                                       ,pr_nrparepr => pr_nrparepr         --Numero Parcelas Emprestimo
                                       ,pr_flgincre => TRUE                --Indicador Credito
                                       ,pr_flgcredi => TRUE                --Credito
                                       ,pr_nrseqava => 0                   --Pagamento: Sequencia do avalista
                                       ,pr_cdorigem => pr_cdorigem         -- Origem do Lançamento
                                       ,pr_qtdiacal => vr_qtdedias         -- Quantidade dias usado no calculo
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Erro
                                       ,pr_dscritic => vr_dscritic);       --Descricao Erro
        -- Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Se NAO for mensal
        IF NOT pr_ehmensal THEN
          -- Atualizar Emprestimo
          BEGIN
            UPDATE crapepr
               SET crapepr.vlsprojt = NVL(crapepr.vlsprojt,0) + NVL(vr_vljuros_mensal,0) + NVL(vr_vljuros,0)
             WHERE crapepr.cdcooper = pr_cdcooper
               AND crapepr.nrdconta = pr_nrdconta
               AND crapepr.nrctremp = pr_nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;

      END IF; -- vr_vljuros > 0

      -- Retorna o juros
      pr_vljurcor := NVL(vr_vljuros,0);

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
              
      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure EMPR0011.pc_efetua_lcto_juros_correc: ' || SQLERRM;
    END;

  END pc_efetua_lcto_juros_correc;

  PROCEDURE pc_efetua_pagamento_em_dia(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtcalcul IN  crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                      ,pr_cdagenci IN  crapage.cdagenci%TYPE     --> Codigo da Agencia
                                      ,pr_cdpactra IN  crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                      ,pr_cdoperad IN  crapope.cdoperad%TYPE     --> Codigo do Operador
                                      ,pr_cdorigem IN  NUMBER                    --> Codigo da Origem
                                      ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                      ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                      ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                      ,pr_vlpreemp IN  crapepr.vlpreemp%TYPE     --> Valor da prestacao do emprestimo
                                      ,pr_qtprepag IN  crapepr.qtprepag%TYPE     --> Quantidade de prestacoes pagas
                                      ,pr_qtprecal IN  crapepr.qtprecal%TYPE     --> Quantidade de prestacoes calculadas
                                      ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de liberacao do Contrato
                                      ,pr_dtrefjur IN  DATE                      --> Data de Referencia de lancamento de Juros
                                      ,pr_vlrdtaxa IN  NUMBER                    --> Valor da Taxa de Atualizacao da Parcela
                                      ,pr_txdiaria IN  NUMBER                    --> Taxa diaria
                                      ,pr_txjuremp IN  crapepr.txjuremp%TYPE     --> Taxa de Juros do Emprestimo
                                      ,pr_vlsprojt IN  NUMBER                    --> Saldo Devedor Projetado
                                      ,pr_floperac IN  BOOLEAN                   --> Indicador se a Operacao eh Financiamento
                                      ,pr_nrseqava IN  PLS_INTEGER               --> Sequencia de pagamento de avalista
                                      ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                      ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de vencimento
                                      ,pr_vlpagpar IN  crappep.vlparepr%TYPE     --> Valor a pagar da Parcela
                                      ,pr_vlsdvpar IN  crappep.vlsdvpar%TYPE     --> Saldo Devedor da Parcela
                                      ,pr_vlsdvatu IN  NUMBER                    --> Saldo Atualizado da Parcela
                                      ,pr_vljura60 IN  crappep.vljura60%TYPE     --> Valor do Juros60
                                      ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando a mensal
                                      ,pr_vlsldisp IN  NUMBER DEFAULT 0          --> Valor Saldo Disponivel
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_efetua_pagamento_em_dia
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Julho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar o Pagamento da Parcela em dia

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis Padrao
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_inliquid crappep.inliquid%TYPE;
      vr_vljura60 crappep.vljura60%TYPE;
      vr_vlsdvatu NUMBER;
      vr_qtprepag NUMBER;
      vr_qtprecal NUMBER;
      vr_vljuremu NUMBER;
      vr_vljurcor NUMBER;
      vr_des_reto VARCHAR2(3);
      vr_vlpagpar NUMBER;
      --vr_dtrefjur DATE;

      -- Variaveis tratamento de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_des_erro VARCHAR2(1000);
      vr_exc_erro EXCEPTION;
      vr_tab_erro GENE0001.typ_tab_erro;

    BEGIN
      -- Carrega o Valor a pagar da Parcela
      vr_vlpagpar := pr_vlpagpar;

      -- Verifica se o valor informado para pagamento eh maior que o valor da parcela
      IF vr_vlpagpar > pr_vlsdvpar THEN
        vr_dscritic := 'Valor informado para pagamento maior que valor da parcela';
        RAISE vr_exc_erro;
      END IF;
      
      -- Efetuar o lancamento de Juros Remuneratorio
      pc_efetua_lcto_juros_remun(pr_cdcooper => pr_cdcooper
                                ,pr_dtcalcul => pr_dtcalcul
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdpactra => pr_cdpactra
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_cdorigem => pr_cdorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_txjuremp => pr_txjuremp
                                ,pr_vlpreemp => pr_vlpreemp
                                ,pr_dtlibera => pr_dtlibera
                                ,pr_dtrefjur => pr_dtrefjur
                                ,pr_floperac => pr_floperac
                                ,pr_dtvencto => pr_dtvencto
                                ,pr_vlsprojt => pr_vlsprojt
                                ,pr_ehmensal => pr_ehmensal
                                ,pr_txdiaria => pr_txdiaria
                                ,pr_nrparepr => pr_nrparepr
                               	,pr_vljuremu => vr_vljuremu
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Efetuar o lancameto de Juros de Correcao
      pc_efetua_lcto_juros_correc (pr_cdcooper => pr_cdcooper
                                  ,pr_dtcalcul => pr_dtcalcul
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdpactra => pr_cdpactra
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_cdorigem => pr_cdorigem
                                  ,pr_flgbatch => pr_flgbatch
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp
                                  ,pr_dtlibera => pr_dtlibera
                                  ,pr_dtrefjur => pr_dtrefjur
                                  ,pr_vlrdtaxa => pr_vlrdtaxa
                                  ,pr_txjuremp => pr_txjuremp
                                  ,pr_vlpreemp => pr_vlpreemp
                                  ,pr_dtvencto => pr_dtvencto
                                  ,pr_vlsprojt => pr_vlsprojt
                                  ,pr_ehmensal => pr_ehmensal
                                  ,pr_floperac => pr_floperac
                                  ,pr_nrparepr => pr_nrparepr
                                  ,pr_vljurcor => vr_vljurcor
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Condicao para verificar se a parcela foi paga total
      IF NVL(pr_vlsdvpar,0) - NVL(vr_vlpagpar,0) <= 0 THEN
        vr_inliquid := 1;
        vr_vljura60 := 0;
        -- Saldo Devedor da Parcela
        vr_vlsdvatu := 0;
        -- Incrementar Prestacoes Pagas
        vr_qtprepag := NVL(pr_qtprepag,0) + 1;
        -- Incrementar Prestacoes Calculadas
        vr_qtprecal := NVL(pr_qtprecal,0) + 1;
      ELSE
        vr_inliquid := 0;
        vr_vljura60 := pr_vljura60;
        -- Saldo Devedor da Parcela
        vr_vlsdvatu := pr_vlsdvatu;
        -- Incrementar Prestacoes Pagas
        vr_qtprepag := NVL(pr_qtprepag,0);
        -- Incrementar Prestacoes Calculadas
        vr_qtprecal := NVL(pr_qtprecal,0);
      END IF;
      
      -- Verifica se tem uma parcela anterior nao liquida e ja vencida
      EMPR0001.pc_verifica_parcel_anteriores (pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                             ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                             ,pr_nrctremp => pr_nrctremp   --> Número do contrato de empréstimo
                                             ,pr_nrparepr => pr_nrparepr   --> Número parcelas empréstimo
                                             ,pr_dtmvtolt => pr_dtcalcul 	 --> Movimento atual
                                             ,pr_des_reto => vr_des_erro   --> Retorno OK / NOK
                                             ,pr_dscritic => vr_dscritic); --> Descricao Erro
                                             
      -- Condicao para verificar se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        vr_vlpagpar := 0;
      END IF;
        
      -- Condicao para verificar se possui saldo disponivel em conta corrente no processo noturno
      IF (pr_flgbatch AND pr_vlsldisp <= 0) THEN
        vr_vlpagpar := 0;
      END IF;   
        
      -- Se possui valor a pagar
      IF vr_vlpagpar > 0 THEN

        -- Verificar se o pagamento foi feito por um avalista
        IF NVL(pr_nrseqava,0) = 0 THEN
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2331;
          ELSE
            vr_cdhistor := 2330;
          END IF;
        ELSE
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2335;
          ELSE
            vr_cdhistor := 2334;
          END IF;
        END IF;

        -- Efetuar o pagamento da parcela Normal
        EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                       ,pr_dtmvtolt => pr_dtcalcul   -- Data Emprestimo
                                       ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia
                                       ,pr_cdbccxlt => 100           -- Codigo Caixa
                                       ,pr_cdoperad => pr_cdoperad   -- Operador
                                       ,pr_cdpactra => pr_cdpactra   -- Posto Atendimento
                                       ,pr_tplotmov => 5             -- Tipo movimento
                                       ,pr_nrdolote => 650004        -- Numero Lote
                                       ,pr_nrdconta => pr_nrdconta   -- Numero da Conta
                                       ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                       ,pr_nrctremp => pr_nrctremp   -- Numero Contrato
                                       ,pr_vllanmto => vr_vlpagpar   -- Valor Lancamento
                                       ,pr_dtpagemp => pr_dtcalcul   -- Data Pagamento Emprestimo
                                       ,pr_txjurepr => pr_txjuremp   -- Taxa Juros Emprestimo
                                       ,pr_vlpreemp => pr_vlpreemp   -- Valor Emprestimo
                                       ,pr_nrsequni => pr_nrparepr   -- Numero Sequencia
                                       ,pr_nrparepr => pr_nrparepr   -- Numero Parcelas Emprestimo
                                       ,pr_flgincre => TRUE          -- Indicador Credito
                                       ,pr_flgcredi => TRUE          -- Credito
                                       ,pr_nrseqava => pr_nrseqava   -- Pagamento: Sequencia do avalista
                                       ,pr_cdorigem => pr_cdorigem   -- Origem do Lancamento
                                       ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                       ,pr_dscritic => vr_dscritic); -- Descricao Erro
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualizar parcela Emprestimo
        BEGIN
          UPDATE crappep
             SET crappep.dtultpag = pr_dtcalcul
                ,crappep.vlpagpar = NVL(crappep.vlpagpar,0) + NVL(vr_vlpagpar,0)
                ,crappep.vlsdvpar = NVL(crappep.vlsdvpar,0) - NVL(vr_vlpagpar,0)
                ,crappep.inliquid = vr_inliquid
                ,crappep.vlsdvatu = vr_vlsdvatu
                ,crappep.vljura60 = vr_vljura60
           WHERE crappep.cdcooper = pr_cdcooper
             AND crappep.nrdconta = pr_nrdconta
             AND crappep.nrctremp = pr_nrctremp
             AND crappep.nrparepr = pr_nrparepr;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar o registro na crappep. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;

        -- Se for Financiamento
        IF pr_floperac THEN
          -- Condicao para verificar se o pagamento foi feito por um avalista
          IF pr_nrseqava = 0 OR pr_nrseqava IS NULL THEN
            vr_cdhistor := 2333;
          ELSE
            vr_cdhistor := 2337;
          END IF;
        ELSE
          -- Condicao para verificar se o pagamento foi feito por um avalista
          IF pr_nrseqava = 0 OR pr_nrseqava IS NULL THEN
            vr_cdhistor := 2332;
          ELSE
            vr_cdhistor := 2336;
          END IF;
        END IF;

        -- Lanca em C/C e atualiza o lote
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_dtcalcul   --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                      ,pr_cdbccxlt => 100           --> Numero do caixa
                                      ,pr_cdoperad => pr_cdoperad   --> Codigo do operador
                                      ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                      ,pr_nrdolote => 650003        --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                      ,pr_cdhistor => vr_cdhistor   --> Codigo historico
                                      ,pr_vllanmto => vr_vlpagpar   --> Valor da parcela emprestimo
                                      ,pr_nrparepr => pr_nrparepr   --> Numero parcelas emprestimo
                                      ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                      ,pr_nrseqava => pr_nrseqava   --> Pagamento: Sequencia do avalista
                                      ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao criar o pagamento de emprestimo na conta.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

      END IF; -- vr_vlpagpar > 0
      
      -- Somente sera atualizado o saldo projetado caso nao possuir nenhum valor pago da parcela
      
--      NVL(crapepr.vlsprojt,0) - NVL(pr_vlpreemp,0)


      -- Atualizar Emprestimo
      BEGIN
        UPDATE crapepr
           SET crapepr.dtrefjur = pr_dtrefjur
              ,crapepr.qtprepag = vr_qtprepag
              ,crapepr.qtprecal = vr_qtprecal
              ,crapepr.vlsdeved = NVL(crapepr.vlsdeved,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0) - NVL(vr_vlpagpar,0)
              ,crapepr.vljuratu = NVL(crapepr.vljuratu,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0)
              ,crapepr.vljuracu = NVL(crapepr.vljuracu,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0)
             -- ,crapepr.vlsprojt = NVL(crapepr.vlsprojt,0) - NVL([VARIAVEL],0)
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure EMPR0011.pc_efetua_pagamento_em_dia: ' || SQLERRM;
    END;

  END pc_efetua_pagamento_em_dia;

  PROCEDURE pc_efetua_pagamento_em_atraso(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                         ,pr_dtcalcul IN  crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                         ,pr_cdagenci IN  crapage.cdagenci%TYPE     --> Codigo da Agencia
                                         ,pr_cdpactra IN  crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                         ,pr_cdoperad IN  crapope.cdoperad%TYPE     --> Codigo do Operador
                                         ,pr_cdorigem IN  NUMBER                    --> Codigo da Origem
                                         ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                         ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                         ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                         ,pr_vlpreemp IN  crapepr.vlpreemp%TYPE     --> Valor da prestacao do emprestimo
                                         ,pr_qtprepag IN  crapepr.qtprepag%TYPE     --> Quantidade de prestacoes pagas
                                         ,pr_qtprecal IN  crapepr.qtprecal%TYPE     --> Quantidade de prestacoes calculadas
                                         ,pr_txjuremp IN  crapepr.txjuremp%TYPE     --> Taxa de Juros do Emprestimo
                                         ,pr_qttolatr IN  crapepr.qttolatr%TYPE     --> Tolerancia para cobranca de multa e mora em atraso
                                         ,pr_floperac IN  BOOLEAN                   --> Indicador se a Operacao eh Financiamento
                                         ,pr_nrseqava IN  PLS_INTEGER               --> Sequencia de pagamento de avalista
                                         ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                         ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de vencimento
                                         ,pr_dtultpag IN  crappep.dtultpag%TYPE     --> Data do ultimo pagamento
                                         ,pr_vlparepr IN  crappep.vlparepr%TYPE     --> Valor da parcela
                                         ,pr_vlpagpar IN  crappep.vlparepr%TYPE     --> Valor a pagar da Parcela
                                         ,pr_vlsdvpar IN  crappep.vlsdvpar%TYPE     --> Saldo Devedor da Parcela
                                         ,pr_vlsdvatu IN  NUMBER                    --> Saldo Atualizado da Parcela
                                         ,pr_vljura60 IN  crappep.vljura60%TYPE     --> Valor do Juros60
                                         ,pr_vlpagmta IN  crappep.vlpagmta%TYPE     --> Valor pago da multa
                                         ,pr_perjurmo IN  craplcr.perjurmo%TYPE     --> Contem o percentual de juros de mora por atraso
                                         ,pr_percmult IN  NUMBER                    --> Percentual de Multa
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_efetua_pagamento_em_atraso
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Agosto/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar o Pagamento da Parcela em Atraso.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Variaveis locais
      vr_vlmtapar NUMBER;
      vr_vlmrapar NUMBER;
      vr_vlminimo NUMBER;
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_inliquid crappep.inliquid%TYPE;
      vr_vljura60 crappep.vljura60%TYPE;
      vr_vlsdvatu NUMBER;
      vr_qtprepag NUMBER;
      vr_qtprecal NUMBER;
      vr_vlpagpar NUMBER;
      vr_des_reto VARCHAR2(3);

      -- Variaveis tratamento de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      vr_tab_erro GENE0001.typ_tab_erro;

    BEGIN
      -- Calcular o valor do atraso
      pc_calcula_atraso_pos_fixado(pr_dtcalcul => pr_dtcalcul
                                  ,pr_vlparepr => pr_vlparepr
                                  ,pr_dtvencto => pr_dtvencto
                                  ,pr_dtultpag => pr_dtultpag
                                  ,pr_vlsdvpar => pr_vlsdvpar
                                  ,pr_perjurmo => pr_perjurmo
                                  ,pr_vlpagmta => pr_vlpagmta
                                  ,pr_percmult => pr_percmult
                                  ,pr_qttolatr => pr_qttolatr
                                  ,pr_vlmrapar => vr_vlmrapar
                                  ,pr_vlmtapar => vr_vlmtapar
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Valor Minimo para pagamento
      vr_vlminimo := NVL(vr_vlmtapar,0) + NVL(vr_vlmrapar,0) + 0.01;
      vr_vlpagpar := NVL(pr_vlpagpar,0);
      
      -- Condicao para verificar se estah rodando no processo batch
      IF pr_flgbatch THEN
        -- Condicao para somente pagar somente o valor do atraso
        IF NVL(vr_vlpagpar,0) > (NVL(pr_vlsdvpar,0) + NVL(vr_vlmtapar,0) + NVL(vr_vlmrapar,0)) THEN
          vr_vlpagpar := NVL(pr_vlsdvpar,0) + NVL(vr_vlmtapar,0) + NVL(vr_vlmrapar,0);
        END IF;
        
        -- No processo noturno não será pago nada, caso não conseguir pagar o valor minimo
        IF NVL(vr_vlpagpar,0) < NVL(vr_vlminimo,0) THEN
          RETURN;
        END IF;
        
      ELSE
        -- Valor Pago da Parcela nao pode ser maior que o valor de Atraso
        IF NVL(vr_vlpagpar,0) > (NVL(pr_vlsdvpar,0) + NVL(vr_vlmtapar,0) + NVL(vr_vlmrapar,0)) THEN
          vr_dscritic := 'Valor informado para pagamento maior que valor da parcela';
          RAISE vr_exc_erro;
        END IF;
        
        -- Valor da Parcela menor valor minimo
        IF NVL(vr_vlpagpar,0) < NVL(vr_vlminimo,0) THEN
          vr_dscritic := 'Valor a pagar deve ser maior ou igual que R$ ' || TO_CHAR(vr_vlminimo,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
          RAISE vr_exc_erro;
        END IF;
        
      END IF;      

      -- Efetua o Lancamento de Multa do Contrato de Emprestimo
      IF NVL(vr_vlmtapar, 0) > 0 THEN

        -- Verificar se o pagamento foi feito por um avalista
        IF NVL(pr_nrseqava,0) = 0 THEN
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2365;
          ELSE
            vr_cdhistor := 2363;
          END IF;
        ELSE
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2369;
          ELSE
            vr_cdhistor := 2367;
          END IF;
        END IF;

        -- Efetuar o lancamento da multa
        EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                       ,pr_dtmvtolt => pr_dtcalcul   -- Data Emprestimo
                                       ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia
                                       ,pr_cdbccxlt => 100           -- Codigo Caixa
                                       ,pr_cdoperad => pr_cdoperad   -- Operador
                                       ,pr_cdpactra => pr_cdpactra   -- Posto Atendimento
                                       ,pr_tplotmov => 5             -- Tipo movimento
                                       ,pr_nrdolote => 650004        -- Numero Lote
                                       ,pr_nrdconta => pr_nrdconta   -- Numero da Conta
                                       ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                       ,pr_nrctremp => pr_nrctremp   -- Numero Contrato
                                       ,pr_vllanmto => vr_vlmtapar   -- Valor Lancamento
                                       ,pr_dtpagemp => pr_dtcalcul   -- Data Pagamento Emprestimo
                                       ,pr_txjurepr => pr_txjuremp   -- Taxa Juros Emprestimo
                                       ,pr_vlpreemp => pr_vlpreemp   -- Valor Emprestimo
                                       ,pr_nrsequni => pr_nrparepr   -- Numero Sequencia
                                       ,pr_nrparepr => pr_nrparepr   -- Numero Parcelas Emprestimo
                                       ,pr_flgincre => TRUE          -- Indicador Credito
                                       ,pr_flgcredi => TRUE          -- Credito
                                       ,pr_nrseqava => pr_nrseqava   -- Pagamento: Sequencia do avalista
                                       ,pr_cdorigem => pr_cdorigem   -- Origem do Lancamento
                                       ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                       ,pr_dscritic => vr_dscritic); -- Descricao Erro
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Verificar se o pagamento foi feito por um avalista
        IF NVL(pr_nrseqava,0) = 0 THEN
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2364;
          ELSE
            vr_cdhistor := 2362;
          END IF;
        ELSE
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2368;
          ELSE
            vr_cdhistor := 2366;
          END IF;
        END IF;

        -- Lanca em C/C e atualiza o lote
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_dtcalcul   --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                      ,pr_cdbccxlt => 100           --> Numero do caixa
                                      ,pr_cdoperad => pr_cdoperad   --> Codigo do operador
                                      ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                      ,pr_nrdolote => 650003        --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                      ,pr_cdhistor => vr_cdhistor   --> Codigo historico
                                      ,pr_vllanmto => vr_vlmtapar   --> Valor da multa
                                      ,pr_nrparepr => pr_nrparepr   --> Numero parcelas emprestimo
                                      ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                      ,pr_nrseqava => pr_nrseqava   --> Pagamento: Sequencia do avalista
                                      ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao criar o lancamento da multa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

      END IF; -- NVL(vr_vlmrapar, 0) > 0

      -- Efetua o Lancamento de Juros de Mora do Contrato de Emprestimo
      IF NVL(vr_vlmrapar, 0) > 0 THEN

        -- Verificar se o pagamento foi feito por um avalista
        IF NVL(pr_nrseqava,0) = 0 THEN
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2373;
          ELSE
            vr_cdhistor := 2371;
          END IF;
        ELSE
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2377;
          ELSE
            vr_cdhistor := 2375;
          END IF;
        END IF;

        -- Efetuar o lancamento do juros de mora
        EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                       ,pr_dtmvtolt => pr_dtcalcul   -- Data Emprestimo
                                       ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia
                                       ,pr_cdbccxlt => 100           -- Codigo Caixa
                                       ,pr_cdoperad => pr_cdoperad   -- Operador
                                       ,pr_cdpactra => pr_cdpactra   -- Posto Atendimento
                                       ,pr_tplotmov => 5             -- Tipo movimento
                                       ,pr_nrdolote => 650004        -- Numero Lote
                                       ,pr_nrdconta => pr_nrdconta   -- Numero da Conta
                                       ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                       ,pr_nrctremp => pr_nrctremp   -- Numero Contrato
                                       ,pr_vllanmto => vr_vlmrapar   -- Valor Lancamento
                                       ,pr_dtpagemp => pr_dtcalcul   -- Data Pagamento Emprestimo
                                       ,pr_txjurepr => pr_txjuremp   -- Taxa Juros Emprestimo
                                       ,pr_vlpreemp => pr_vlpreemp   -- Valor Emprestimo
                                       ,pr_nrsequni => pr_nrparepr   -- Numero Sequencia
                                       ,pr_nrparepr => pr_nrparepr   -- Numero Parcelas Emprestimo
                                       ,pr_flgincre => TRUE          -- Indicador Credito
                                       ,pr_flgcredi => TRUE          -- Credito
                                       ,pr_nrseqava => pr_nrseqava   -- Pagamento: Sequencia do avalista
                                       ,pr_cdorigem => pr_cdorigem   -- Origem do Lancamento
                                       ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                       ,pr_dscritic => vr_dscritic); -- Descricao Erro
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Verificar se o pagamento foi feito por um avalista
        IF NVL(pr_nrseqava,0) = 0 THEN
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2372;
          ELSE
            vr_cdhistor := 2370;
          END IF;
        ELSE
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2376;
          ELSE
            vr_cdhistor := 2374;
          END IF;
        END IF;

        -- Lanca em C/C e atualiza o lote
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_dtcalcul   --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                      ,pr_cdbccxlt => 100           --> Numero do caixa
                                      ,pr_cdoperad => pr_cdoperad   --> Codigo do operador
                                      ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                      ,pr_nrdolote => 650003        --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                      ,pr_cdhistor => vr_cdhistor   --> Codigo historico
                                      ,pr_vllanmto => vr_vlmrapar   --> Valor do juros de mora
                                      ,pr_nrparepr => pr_nrparepr   --> Numero parcelas emprestimo
                                      ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                      ,pr_nrseqava => pr_nrseqava   --> Pagamento: Sequencia do avalista
                                      ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao criar o lancamento da multa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

      END IF; -- NVL(vr_vlmrapar, 0) > 0

      -- Condicao para verificar se a parcela sera liquidada
      IF NVL(pr_vlsdvpar,0) = NVL(vr_vlpagpar,0) - NVL(vr_vlmtapar, 0) - NVL(vr_vlmrapar, 0) THEN
        vr_inliquid := 1;
        vr_vljura60 := 0;
        -- Saldo Devedor da Parcela
        vr_vlsdvatu := 0;
        -- Incrementar Prestacoes Pagas
        vr_qtprepag := NVL(pr_qtprepag,0) + 1;
        -- Incrementar Prestacoes Calculadas
        vr_qtprecal := NVL(pr_qtprecal,0) + 1;
      ELSE
        vr_inliquid := 0;
        vr_vljura60 := pr_vljura60;
        -- Saldo Devedor da Parcela
        vr_vlsdvatu := pr_vlsdvatu;
        -- Incrementar Prestacoes Pagas
        vr_qtprepag := NVL(pr_qtprepag,0);
        -- Incrementar Prestacoes Calculadas
        vr_qtprecal := NVL(pr_qtprecal,0);
      END IF;

      -- Atualizar parcela Emprestimo
      BEGIN
        UPDATE crappep
           SET crappep.dtultpag = pr_dtcalcul
              ,crappep.vlpagpar = NVL(crappep.vlpagpar,0) + NVL(vr_vlpagpar,0) - NVL(vr_vlmtapar,0) - NVL(vr_vlmrapar,0)
			        ,crappep.vlpagmta = NVL(crappep.vlpagmta,0) + NVL(vr_vlmtapar,0)
			        ,crappep.vlpagmra = NVL(crappep.vlpagmra,0) + NVL(vr_vlmrapar,0)
              ,crappep.vlsdvpar = NVL(crappep.vlsdvpar,0) + NVL(vr_vlmtapar,0) + NVL(vr_vlmrapar,0) - NVL(vr_vlpagpar,0)
              ,crappep.inliquid = vr_inliquid
              ,crappep.vlsdvatu = vr_vlsdvatu
              ,crappep.vljura60 = vr_vljura60              
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr = pr_nrparepr;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar o registro na crappep. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Condicao para verificar se o pagamento foi feito por aval
      IF pr_nrseqava = 0 OR pr_nrseqava IS NULL THEN
        -- Financiamento
        IF pr_floperac THEN
          vr_cdhistor := 2331;
        ELSE
          -- Emprestimo
          vr_cdhistor := 2330;
        END IF;
      ELSE
        -- Financiamento
        IF pr_floperac THEN
          vr_cdhistor := 2335;
        ELSE
          -- Emprestimo
          vr_cdhistor := 2334;
        END IF;
      END IF;
        
      -- Cria lancamento craplem e atualiza o seu lote
      EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                     ,pr_dtmvtolt => pr_dtcalcul --Data Emprestimo
                                     ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                     ,pr_cdbccxlt => 100         --Codigo Caixa
                                     ,pr_cdoperad => pr_cdoperad --Operador
                                     ,pr_cdpactra => pr_cdpactra --Posto Atendimento
                                     ,pr_tplotmov => 5           --Tipo movimento
                                     ,pr_nrdolote => 650004      --Numero Lote
                                     ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                     ,pr_cdhistor => vr_cdhistor --Codigo Historico
                                     ,pr_nrctremp => pr_nrctremp   --Numero Contrato
                                     ,pr_vllanmto => vr_vlpagpar   --Valor pago da Parcela
                                     ,pr_dtpagemp => pr_dtcalcul   --Data Pagamento Emprestimo
                                     ,pr_txjurepr => pr_txjuremp   --Taxa Juros Emprestimo
                                     ,pr_vlpreemp => pr_vlpreemp   --Valor Emprestimo
                                     ,pr_nrsequni => pr_nrparepr   --Numero Sequencia
                                     ,pr_nrparepr => pr_nrparepr   --Numero Parcelas Emprestimo
                                     ,pr_flgincre => TRUE          --Indicador Credito
                                     ,pr_flgcredi => TRUE          --Credito
                                     ,pr_nrseqava => pr_nrseqava   --Pagamento: Sequencia do avalista
                                     ,pr_cdorigem => pr_cdorigem   --
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Erro
                                     ,pr_dscritic => vr_dscritic); --Descricao Erro	
                            
      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        -- Se possui algum erro na tabela de erros
        IF vr_tab_erro.COUNT() > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao criar o lancamento de pagamento.';
        END IF;
        RAISE vr_exc_erro;
      END IF;

      -- Se for Financiamento
      IF pr_floperac THEN
        -- Condicao para verificar se o pagamento foi feito por um avalista
        IF pr_nrseqava = 0 OR pr_nrseqava IS NULL THEN
          vr_cdhistor := 2333;
        ELSE
          vr_cdhistor := 2337;
        END IF;
      ELSE
        -- Condicao para verificar se o pagamento foi feito por um avalista
        IF pr_nrseqava = 0 OR pr_nrseqava IS NULL THEN
          vr_cdhistor := 2332;
        ELSE
          vr_cdhistor := 2336;
        END IF;
      END IF;

      -- Lanca em C/C e atualiza o lote
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                    ,pr_dtmvtolt => pr_dtcalcul   --> Movimento atual
                                    ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                    ,pr_cdbccxlt => 100           --> Numero do caixa
                                    ,pr_cdoperad => pr_cdoperad   --> Codigo do operador
                                    ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                    ,pr_nrdolote => 650003        --> Numero do Lote
                                    ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                    ,pr_cdhistor => vr_cdhistor   --> Codigo historico
                                    ,pr_vllanmto => vr_vlpagpar   --> Valor da parcela emprestimo
                                    ,pr_nrparepr => pr_nrparepr   --> Numero parcelas emprestimo
                                    ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                    ,pr_nrseqava => pr_nrseqava   --> Pagamento: Sequencia do avalista
                                    ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        -- Se possui algum erro na tabela de erros
        IF vr_tab_erro.COUNT() > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao criar o pagamento de emprestimo na conta.';
        END IF;
        RAISE vr_exc_erro;
      END IF;

      -- Atualizar Emprestimo
      BEGIN
        UPDATE crapepr
           SET --crapepr.dtultpag = pr_dtcalcul
               crapepr.qtprepag = vr_qtprepag
              ,crapepr.qtprecal = vr_qtprecal
              ,crapepr.vlsdeved = NVL(crapepr.vlsdeved,0) + NVL(vr_vlmtapar, 0) + NVL(vr_vlmrapar,0) - NVL(vr_vlpagpar,0)
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure EMPR0011.pc_efetua_pagamento_em_atraso: ' || SQLERRM;
    END;

  END pc_efetua_pagamento_em_atraso;

  PROCEDURE pc_valida_pagamentos_pos(pr_cdcooper    IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                    ,pr_nrdconta    IN crapass.nrdconta%TYPE     --> Numero da conta
                                    ,pr_cdagenci    IN crapage.cdagenci%TYPE     --> Codigo Agencia
                                    ,pr_nrdcaixa    IN crapbcx.nrdcaixa%TYPE     --> Numero do caixa
                                    ,pr_cdoperad    IN crapope.cdoperad%TYPE     --> Codigo do operador
                                    ,pr_rw_crapdat  IN BTCH0001.cr_crapdat%ROWTYPE --> Calendario
                                    ,pr_tpemprst    IN crawepr.tpemprst%TYPE     --> Tipo do emprestimo
                                    ,pr_dtlibera    IN crawepr.dtlibera%TYPE     --> Data da liberacao
                                    ,pr_vllimcre    IN crapass.vllimcre%TYPE     --> Valor do limite de credito
                                    ,pr_flgcrass    IN BOOLEAN                   --> Flag de controle do BATCH
                                    ,pr_nrctrliq_1  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 1
                                    ,pr_nrctrliq_2  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 2
                                    ,pr_nrctrliq_3  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 3
                                    ,pr_nrctrliq_4  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 4
                                    ,pr_nrctrliq_5  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 5
                                    ,pr_nrctrliq_6  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 6
                                    ,pr_nrctrliq_7  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 7
                                    ,pr_nrctrliq_8  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 8
                                    ,pr_nrctrliq_9  IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 9
                                    ,pr_nrctrliq_10 IN crawepr.nrctremp%TYPE     --> Numero contrato liquida 10
                                    ,pr_vlapagar    IN NUMBER                    --> Valor a Pagar
                                    ,pr_vlsldisp   OUT NUMBER                    --> Valor Saldo Disponivel
                                    ,pr_cdcritic   OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                    ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_valida_pagamentos_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Julho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar a validacao dos pagamentos.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Tabela de Saldos
      vr_tab_saldos EXTR0001.typ_tab_saldos;

      -- Variavel dos Indices
      vr_index_saldo PLS_INTEGER;
    
      -- Variaveis tratamento de erros
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      vr_exc_erro   EXCEPTION;
      vr_des_reto   VARCHAR2(10);
      vr_tab_erro   GENE0001.typ_tab_erro;

    BEGIN
      -- Se NAO for Pos-Fixado
      IF pr_tpemprst <> 2 THEN
        vr_dscritic := 'Tipo de emprestimo invalido.';
        RAISE vr_exc_erro;
      END IF;

      -- Verificar se foi informado o valor de pagamento
      IF NVL(pr_vlapagar,0) = 0 THEN
        vr_dscritic := 'Valor de pagamento nao informado.';
        RAISE vr_exc_erro;
      END IF;

      -- Se data atual for a mesma da liberacao
      -- E se for Refinanciamento
      IF pr_rw_crapdat.dtmvtolt = pr_dtlibera  AND
        (NVL(pr_nrctrliq_1, 0) > 0  OR
         NVL(pr_nrctrliq_2, 0) > 0  OR
         NVL(pr_nrctrliq_3, 0) > 0  OR
         NVL(pr_nrctrliq_4, 0) > 0  OR
         NVL(pr_nrctrliq_5, 0) > 0  OR
         NVL(pr_nrctrliq_6, 0) > 0  OR
         NVL(pr_nrctrliq_7, 0) > 0  OR
         NVL(pr_nrctrliq_8, 0) > 0  OR
         NVL(pr_nrctrliq_9, 0) > 0  OR
         NVL(pr_nrctrliq_10,0) > 0) THEN
         vr_dscritic := 'Atencao! contrato liberado nesta data. '
                     || 'Liquidacao/antecipacao permitida a partir de '
                     ||  TO_CHAR(pr_dtlibera + 1,'dd/mm/YYYY') || '.';
         RAISE vr_exc_erro;
      END IF;

      -- Limpar tabela saldos
      vr_tab_saldos.DELETE;

      -- Obter Saldo do Dia
      EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => pr_rw_crapdat
                                 ,pr_cdagenci   => pr_cdagenci
                                 ,pr_nrdcaixa   => pr_nrdcaixa
                                 ,pr_cdoperad   => pr_cdoperad
                                 ,pr_nrdconta   => pr_nrdconta
                                 ,pr_vllimcre   => pr_vllimcre
                                 ,pr_dtrefere   => pr_rw_crapdat.dtmvtolt
                                 ,pr_flgcrass   => pr_flgcrass
                                 ,pr_des_reto   => vr_des_reto
                                 ,pr_tab_sald   => vr_tab_saldos
                                 ,pr_tipo_busca => 'A'
                                 ,pr_tab_erro   => vr_tab_erro);
      -- Se retornou erro
      IF vr_des_reto <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic := 'Erro na procedure EMPR0011.pc_valida_pagamentos_pos.';
        END IF;
        RAISE vr_exc_erro;
      END IF;

      -- Buscar Indice
      vr_index_saldo := vr_tab_saldos.FIRST;
      IF vr_index_saldo IS NOT NULL THEN
        -- Acumular Saldo
        pr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0) +
                             NVL(vr_tab_saldos(vr_index_saldo).vllimcre, 0),2);
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
              
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure EMPR0011.pc_valida_pagamentos_pos: ' || SQLERRM;
    END;

  END pc_valida_pagamentos_pos;

  PROCEDURE pc_valida_pagamentos_pos_web(pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                                        ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                                        ,pr_vlapagar   IN NUMBER                --> Valor a Pagar
                                        ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
    /* .............................................................................

       Programa: pc_valida_pagamentos_pos_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Julho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar a validacao dos pagamentos.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Cursor da proposta de emprestimo
      CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT tpemprst
              ,dtlibera
              ,nrctrliq##1
              ,nrctrliq##2
              ,nrctrliq##3
              ,nrctrliq##4
              ,nrctrliq##5
              ,nrctrliq##6
              ,nrctrliq##7
              ,nrctrliq##8
              ,nrctrliq##9
              ,nrctrliq##10
          FROM crawepr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;

      -- Selecionar operadores
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT cdoperad
              ,vlpagchq
          FROM crapope
         WHERE cdcooper = pr_cdcooper
           AND UPPER(cdoperad) = UPPER(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;

      -- Busca dos dados do associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT vllimcre
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Registro tipo Data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variaveis Locais
      vr_crapope  BOOLEAN;
      vr_blnachou BOOLEAN;
      vr_vlsldisp NUMBER;
      vr_difpagto NUMBER;
      vr_flgativo INTEGER := 0;

      -- Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);

      -- Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Seleciona o calendario
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      vr_blnachou := BTCH0001.cr_crapdat%FOUND;
      CLOSE BTCH0001.cr_crapdat;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;
      
      -- Buscar os dados da proposta de emprestimo
      OPEN cr_crawepr(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      vr_blnachou := cr_crawepr%FOUND;
      CLOSE cr_crawepr;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 535;
        RAISE vr_exc_erro;
      END IF;

      -- Selecionar Associado
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

      -- Selecionar Operadores
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      vr_crapope := cr_crapope%FOUND;
      CLOSE cr_crapope;
      -- Se NAO achou
      IF NOT vr_crapope THEN
        vr_cdcritic := 67;
        RAISE vr_exc_erro;
      END IF;

      -- Chama validacao generica
      pc_valida_pagamentos_pos(pr_cdcooper => vr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_rw_crapdat => rw_crapdat
                              ,pr_tpemprst => rw_crawepr.tpemprst
                              ,pr_dtlibera => rw_crawepr.dtlibera
                              ,pr_vllimcre => rw_crapass.vllimcre
                              ,pr_flgcrass => FALSE
                              ,pr_nrctrliq_1 => rw_crawepr.nrctrliq##1
                              ,pr_nrctrliq_2 => rw_crawepr.nrctrliq##2
                              ,pr_nrctrliq_3 => rw_crawepr.nrctrliq##3
                              ,pr_nrctrliq_4 => rw_crawepr.nrctrliq##4
                              ,pr_nrctrliq_5 => rw_crawepr.nrctrliq##5
                              ,pr_nrctrliq_6 => rw_crawepr.nrctrliq##6
                              ,pr_nrctrliq_7 => rw_crawepr.nrctrliq##7
                              ,pr_nrctrliq_8 => rw_crawepr.nrctrliq##8
                              ,pr_nrctrliq_9 => rw_crawepr.nrctrliq##9
                              ,pr_nrctrliq_10 => rw_crawepr.nrctrliq##10
                              ,pr_vlapagar => pr_vlapagar
                              ,pr_vlsldisp => vr_vlsldisp
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Valor a Pagar Maior Soma total
      IF NVL(pr_vlapagar, 0) > NVL(vr_vlsldisp, 0) THEN
        -- Se encontrou operador
        IF vr_crapope THEN
          -- Diferenca no valor pago
          vr_difpagto := NVL(pr_vlapagar, 0) - NVL(vr_vlsldisp, 0);
          -- Valor Diferenca Maior Limite Pagamento Cheque
          IF vr_difpagto > NVL(rw_crapope.vlpagchq, 0) THEN
            vr_dscritic := 'Saldo alcada do operador insuficiente.';
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Retorna mensagem de confirmacao de pagamento
        vr_dscritic := 'Saldo em conta insuficiente para pagamento da parcela. '
                    || 'Confirma pagamento?';
        RAISE vr_exc_saida;

      END IF;

      -- Verifica se existe contrato de acordo ativo
      RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => vr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_cdorigem => 3
                                       ,pr_flgativo => vr_flgativo
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Se acordo estiver ativo
      IF vr_flgativo = 1 THEN
        vr_dscritic := 'Contrato em acordo. Pagamento permitido somente por boleto.';
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Confirmacao>' || vr_dscritic || '</Confirmacao></Root>');
      WHEN vr_exc_erro THEN
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na procedure pc_valida_pagamentos_pos_web: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_valida_pagamentos_pos_web;

  PROCEDURE pc_gera_pagto_pos_web(pr_dtcalcul   IN VARCHAR2              --> Data de calculo das parcelas
                                 ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                                 ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                                 ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Sequencia do titular
                                 ,pr_cdpactra   IN crapage.cdagenci%TYPE --> Codigo da Agencia Trabalho
                                 ,pr_nrseqava   IN PLS_INTEGER           --> Sequencia de pagamento de avalista
                                 ,pr_dadosprc   IN CLOB                  --> Dados das parcelas selecionadas
                                 ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                 ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  BEGIN
    /* .............................................................................

       Programa: pc_gera_pagto_pos_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Julho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para geracao dos pagamentos.

       Alteracoes: 
    ............................................................................. */

    DECLARE
      -- Cursor de emprestimo
      CURSOR cr_crapepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT crapepr.cdlcremp
              ,crapepr.qtprepag
              ,crapepr.vlpreemp
              ,crapepr.qtprecal
              ,crapepr.txjuremp
              ,crapepr.txmensal
              ,crapepr.dtrefjur
              ,crapepr.vlsprojt
              ,crapepr.qttolatr
              ,crapepr.dtultpag
              ,crawepr.dtlibera
          FROM crapepr
          JOIN crawepr
            ON crawepr.cdcooper = crapepr.cdcooper
           AND crawepr.nrdconta = crapepr.nrdconta
           AND crawepr.nrctremp = crapepr.nrctremp
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Busca os dados da linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT dsoperac
              ,cddindex
              ,perjurmo
              ,flgcobmu
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Buscar a taxa acumulada do CDI
      CURSOR cr_craptxi(pr_cddindex IN craptxi.cddindex%TYPE
                       ,pr_dtiniper IN craptxi.dtiniper%TYPE) IS
        SELECT craptxi.vlrdtaxa
          FROM craptxi
         WHERE cddindex = pr_cddindex
           AND dtiniper = pr_dtiniper;
      rw_craptxi cr_craptxi%ROWTYPE;
      
      -- Cursor da parcelas dos Emprestimo
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE
                       ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
        SELECT crappep.inliquid
              ,crappep.dtvencto
              ,crappep.vlsdvpar
              ,crappep.vlsdvatu
              ,crappep.vljura60
              ,crappep.dtultpag
              ,crappep.vlparepr
              ,crappep.vlpagmta
              ,crappep.vltaxatu
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
      
      -- Verifica se tem alguma parcela anterior em aberto
      CURSOR cr_pep_ant(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE
                       ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
        SELECT 1
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr < pr_nrparepr
           AND crappep.inliquid = 0;
      rw_pep_ant cr_pep_ant%ROWTYPE;
    
      -- Registro tipo Data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
      -- Variaveis Locais
      vr_dtmvtolt DATE;
      vr_dtmvtoan DATE;
      vr_dtmvtopr DATE;
      vr_blnachou BOOLEAN;
      vr_floperac BOOLEAN;
      vr_flmensal BOOLEAN;
      vr_parc_lst GENE0002.typ_split;
      vr_parc_reg GENE0002.typ_split;
      vr_nrparepr INTEGER;
      vr_vlpagpar NUMBER;
      vr_txdiaria craplcr.txdiaria%TYPE;
      vr_dsorigem VARCHAR2(50);
      vr_nrdrowid ROWID;
      vr_dstextab craptab.dstextab%TYPE;
      vr_percmult NUMBER(25,2);
    
      -- Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      -- Variaveis Excecao
      vr_exc_erro  EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gera_pagto_pos_web'
                                ,pr_action => NULL);

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Seleciona o calendario
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      vr_blnachou := BTCH0001.cr_crapdat%FOUND;
      CLOSE BTCH0001.cr_crapdat;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;

      -- Data de calculo do Price
      vr_dtmvtolt := TO_DATE(pr_dtcalcul,'DD/MM/RRRR');

      -- Funcao para retornar o dia anterior
      vr_dtmvtoan := GENE0005.fn_valida_dia_util(pr_cdcooper  => vr_cdcooper,
                                                 pr_dtmvtolt  => vr_dtmvtolt - 1,
                                                 pr_tipo      => 'A');

      -- Funcao para retornar o proximo dia
      vr_dtmvtopr := GENE0005.fn_valida_dia_util(pr_cdcooper  => vr_cdcooper,
                                                 pr_dtmvtolt  => vr_dtmvtolt + 1,
                                                 pr_tipo      => 'P');

      -- Buscar os dados de emprestimo
      OPEN cr_crapepr(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      vr_blnachou := cr_crapepr%FOUND;
      CLOSE cr_crapepr;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 356;
        RAISE vr_exc_erro;
      END IF;

      -- Buscar os dados da linha de credito
      OPEN cr_craplcr(pr_cdcooper => vr_cdcooper
                     ,pr_cdlcremp => rw_crapepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      vr_blnachou := cr_craplcr%FOUND;
      CLOSE cr_craplcr;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 363;
        RAISE vr_exc_erro;
      END IF;

      -- Buscar a taxa acumulada do CDI
      OPEN cr_craptxi(pr_cddindex => rw_craplcr.cddindex
                     ,pr_dtiniper => vr_dtmvtoan);
      FETCH cr_craptxi INTO rw_craptxi;
      vr_blnachou := cr_craptxi%FOUND;
      CLOSE cr_craptxi;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_dscritic := 'Taxa do CDI nao cadastrada. Data: ' || TO_CHAR(vr_dtmvtoan,'DD/MM/RRRR');
        RAISE vr_exc_erro;
      END IF;

      -- Se for a Mensal
      vr_flmensal := (TO_CHAR(vr_dtmvtolt, 'MM') <> TO_CHAR(vr_dtmvtopr, 'MM'));

      -- Se for Financiamento
      vr_floperac := (rw_craplcr.dsoperac = 'FINANCIAMENTO');

      -- Seta o nome da origem
      vr_dsorigem := GENE0001.vr_vet_des_origens(vr_idorigem);

      -- Calcula a taxa diaria
      vr_txdiaria := POWER(1 + (NVL(rw_crapepr.txmensal,0) / 100),(1 / 30)) - 1;

      -- Quebra string para transformar numa tabela com os registros
      vr_parc_lst := GENE0002.fn_quebra_string(pr_string  => pr_dadosprc
                                              ,pr_delimit => '|');

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
          vr_cdcritic := 55;
          RAISE vr_exc_erro;
        END IF;
        -- Utilizar como % de multa, as 6 primeiras posicoes encontradas
        vr_percmult := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,1,6));
      ELSE
        vr_percmult := 0;
      END IF;

      -- Listagem de pagamentos informados
      FOR vr_idx_lst IN 1..vr_parc_lst.COUNT LOOP

        -- Quebra string para transformar nos registros
        vr_parc_reg := GENE0002.fn_quebra_string(pr_string  => vr_parc_lst(vr_idx_lst)
                                                 ,pr_delimit => ';');
        -- Seta os valores separados
        vr_nrparepr := vr_parc_reg(1);
        vr_vlpagpar := TO_NUMBER(vr_parc_reg(2));

        -- Buscar os dados da parcela
        OPEN cr_crappep(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp
                       ,pr_nrparepr => vr_nrparepr);
        FETCH cr_crappep INTO rw_crappep;
        vr_blnachou := cr_crappep%FOUND;
        CLOSE cr_crappep;
        -- Se NAO achou
        IF NOT vr_blnachou THEN
          vr_dscritic := 'Parcela ' || vr_nrparepr + ' nao encontrada.';
          RAISE vr_exc_erro;
        END IF;

        -- Verifica se tem alguma parcela anterior em aberto
        OPEN cr_pep_ant(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp
                       ,pr_nrparepr => vr_nrparepr);
        FETCH cr_pep_ant INTO rw_pep_ant;
        vr_blnachou := cr_pep_ant%FOUND;
        CLOSE cr_pep_ant;
        -- Se achou
        IF vr_blnachou THEN
          vr_dscritic := 'Efetuar primeiro o pagamento da parcela em aberto.';
          RAISE vr_exc_erro;
        END IF;

        -- Verificar se a parcela jah esta liquidada
        IF rw_crappep.inliquid = 1 THEN
          vr_dscritic := 'Parcela ' || vr_nrparepr + ' ja liquidada!';
          RAISE vr_exc_erro;
        END IF;

        --------------------
        -- Parcela em dia --
        --------------------
        IF rw_crappep.dtvencto > vr_dtmvtoan AND rw_crappep.dtvencto <= vr_dtmvtolt THEN
          -- Efetua o pagamento da parcela em Dia
          pc_efetua_pagamento_em_dia(pr_cdcooper => vr_cdcooper
                                    ,pr_dtcalcul => vr_dtmvtolt
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_cdpactra => pr_cdpactra
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_cdorigem => vr_idorigem
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctremp => pr_nrctremp
                                    ,pr_vlpreemp => rw_crapepr.vlpreemp
                                    ,pr_qtprepag => rw_crapepr.qtprepag
                                    ,pr_qtprecal => rw_crapepr.qtprecal
                                    ,pr_dtlibera => rw_crapepr.dtlibera
                                    ,pr_dtrefjur => rw_crapepr.dtrefjur
                                    ,pr_vlrdtaxa => rw_crappep.vltaxatu
                                    ,pr_txdiaria => vr_txdiaria
                                    ,pr_txjuremp => rw_crapepr.txjuremp
                                    ,pr_vlsprojt => rw_crapepr.vlsprojt
                                    ,pr_floperac => vr_floperac
                                    ,pr_nrseqava => pr_nrseqava
                                    ,pr_nrparepr => vr_nrparepr
                                    ,pr_dtvencto => rw_crappep.dtvencto
                                    ,pr_vlpagpar => vr_vlpagpar
                                    ,pr_vlsdvpar => rw_crappep.vlsdvpar
                                    ,pr_vlsdvatu => rw_crappep.vlsdvatu
                                    ,pr_vljura60 => rw_crappep.vljura60
                                    ,pr_ehmensal => vr_flmensal
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        ---------------------
        -- Parcela Vencida --
        ---------------------
        ELSIF rw_crappep.dtvencto < vr_dtmvtolt THEN

          -- Efetua o pagamento da parcela Vencida
          pc_efetua_pagamento_em_atraso(pr_cdcooper => vr_cdcooper
                                       ,pr_dtcalcul => vr_dtmvtolt
                                       ,pr_cdagenci => vr_cdagenci
                                       ,pr_cdpactra => pr_cdpactra
                                       ,pr_cdoperad => vr_cdoperad
                                       ,pr_cdorigem => vr_idorigem
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_vlpreemp => rw_crapepr.vlpreemp
                                       ,pr_qtprepag => rw_crapepr.qtprepag
                                       ,pr_qtprecal => rw_crapepr.qtprecal
                                       ,pr_txjuremp => rw_crapepr.txjuremp
                                       ,pr_qttolatr => rw_crapepr.qttolatr
                                       ,pr_floperac => vr_floperac
                                       ,pr_nrseqava => pr_nrseqava
                                       ,pr_nrparepr => vr_nrparepr
                                       ,pr_dtvencto => rw_crappep.dtvencto
                                       ,pr_dtultpag => rw_crappep.dtultpag
                                       ,pr_vlparepr => rw_crappep.vlparepr
                                       ,pr_vlpagpar => vr_vlpagpar
                                       ,pr_vlsdvpar => rw_crappep.vlsdvpar
                                       ,pr_vlsdvatu => rw_crappep.vlsdvatu
                                       ,pr_vljura60 => rw_crappep.vljura60
                                       ,pr_vlpagmta => rw_crappep.vlpagmta
                                       ,pr_perjurmo => rw_craplcr.perjurmo
                                       ,pr_percmult => vr_percmult
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        ----------------------
        -- Parcela a Vencer --
        ----------------------
        ELSIF rw_crappep.dtvencto > vr_dtmvtolt THEN

          --  Efetua o pagamento da parcela a Vencer
          NULL;

        END IF; -- Parcela a Vencer

        -- Faz a liquidacao do contrato
        EMPR0011.pc_efetua_liquidacao_empr_pos(pr_cdcooper   => vr_cdcooper
                                              ,pr_nrdconta   => pr_nrdconta
                                              ,pr_nrctremp   => pr_nrctremp
                                              ,pr_rw_crapdat => rw_crapdat
                                              ,pr_cdagenci   => vr_cdagenci
                                              ,pr_cdpactra   => pr_cdpactra
                                              ,pr_cdoperad   => vr_cdoperad
                                              ,pr_nrdcaixa   => vr_nrdcaixa
                                              ,pr_cdorigem   => vr_idorigem
                                              ,pr_nmdatela   => vr_nmdatela
                                              ,pr_floperac   => vr_floperac
                                              ,pr_cdcritic   => vr_cdcritic
                                              ,pr_dscritic   => vr_dscritic);
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Gera log do pagamento
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Pag. Emp/Fin Nr ' || GENE0002.fn_mask_contrato(pr_nrctremp) || '/' || TO_CHAR(vr_nrparepr)
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 -- TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
            
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'nrparepr',
                                  pr_dsdadant => vr_nrparepr,
                                  pr_dsdadatu => vr_nrparepr);
            
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'vlpagpar',
                                  pr_dsdadant => TO_CHAR(vr_vlpagpar,'FM999G999G999G990D00'),
                                  pr_dsdadatu => TO_CHAR(vr_vlpagpar,'FM999G999G999G990D00'));

      END LOOP; -- vr_parc_lst

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na procedure pc_gera_pagto_pos_web: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_gera_pagto_pos_web;

  PROCEDURE pc_busca_prest_pago_mes_pos(pr_cdcooper  IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                       ,pr_nrdconta  IN crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                       ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do Contrato
                                       ,pr_dtmvtolt  IN VARCHAR2                  --> Data de calculo das parcelas
                                       ,pr_vllanmto OUT NUMBER                    --> Valor do lancamento
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_busca_prest_pago_mes_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Julho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para retornar a soma dos valores dos lancamentos.

       Alteracoes: 
    ............................................................................. */
    DECLARE
      -- Busca soma
      CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE
                       ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
        SELECT SUM(craplem.vllanmto)
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor in (2330,2331,2334,2335,2338,2239)
           AND TO_CHAR(craplem.dtmvtolt,'MM/RRRR') = TO_CHAR(pr_dtmvtolt,'MM/RRRR');

      -- Variaveis gerais
      vr_dtmvtolt crapdat.dtmvtolt%TYPE;
      vr_vllanmto NUMBER;

    BEGIN
      -- Converte para data
      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/RRRR');

      -- Busca soma
      OPEN  cr_craplem(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp
                      ,pr_dtmvtolt => vr_dtmvtolt);
      FETCH cr_craplem INTO vr_vllanmto;
      CLOSE cr_craplem;

      -- Retorna valor
      pr_vllanmto := NVL(vr_vllanmto,0);

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure pc_busca_prest_pago_mes_pos: ' || SQLERRM;
    END;
    
  END pc_busca_prest_pago_mes_pos;

  PROCEDURE pc_busca_prest_principal_pos(pr_cdcooper  IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                        ,pr_dtefetiv  IN crapepr.dtmvtolt%TYPE     --> Data de Efetivação do Emprestimo
                                        ,pr_dtcalcul  IN crapdat.dtmvtolt%TYPE     --> Data de calculo das parcelas
                                        ,pr_cdlcremp  IN craplcr.cdlcremp%TYPE     --> Codigo da Linha de Credito
                                        ,pr_dtcarenc  IN crawepr.dtcarenc%TYPE     --> Data de Pagamento da Primeira Carencia
                                        ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                        ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE     --> Quantidade de prestacoes
                                        ,pr_vlemprst  IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                        ,pr_vlpreemp OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                        ,pr_vljurcor OUT crapepr.vlpreemp%TYPE     --> Valor do Juros de Correcao
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_busca_prest_principal_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Agosto/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para retornar parcela principal do emprestimo.

       Alteracoes: 
    ............................................................................. */
    DECLARE
      -- Variaveis gerais
      vr_vlpreemp     NUMBER := 0;
      vr_vljurcor     NUMBER := 0;
      vr_tab_parcelas EMPR0011.typ_tab_parcelas;

      -- Variaveis tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     crapcri.dscritic%TYPE;
      vr_exc_erro     EXCEPTION;

    BEGIN
      -- Chama o calculo da parcela
      pc_calcula_parcelas_pos_fixado(pr_cdcooper        => pr_cdcooper
                                    ,pr_dtcalcul        => pr_dtcalcul
                                    ,pr_cdlcremp        => pr_cdlcremp
                                    ,pr_dtcarenc        => pr_dtcarenc
                                    ,pr_qtdias_carencia => 0 -- JFF
                                    ,pr_dtdpagto        => pr_dtdpagto
                                    ,pr_qtpreemp        => pr_qtpreemp
                                    ,pr_vlemprst        => pr_vlemprst
                                    ,pr_tab_parcelas    => vr_tab_parcelas
                                    ,pr_cdcritic        => vr_cdcritic
                                    ,pr_dscritic        => vr_dscritic);
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Condicao para verificar se foi calculado parcelas do emprestimo
      IF NOT vr_tab_parcelas.EXISTS(vr_tab_parcelas.first) THEN
        vr_dscritic := 'Nao foi possivel calcular o valor da parcela';
        RAISE vr_exc_erro;
      END IF;

      FOR vr_indice IN 1..vr_tab_parcelas.COUNT LOOP
        -- O valor da prestacao que sera apresentado em tela, sera o valor da parcela principal
        IF vr_tab_parcelas(vr_indice).flcarenc = 0 THEN
          vr_vlpreemp := vr_tab_parcelas(vr_indice).vlparepr;
          
          -- Se o vencimento da parcela vence no proximo mês, precisamos calcular o Juros de Correção da Mensal
          IF TO_CHAR(pr_dtefetiv,'MM') <> TO_CHAR(vr_tab_parcelas(vr_indice).dtvencto,'MM') THEN
            -- Juros de Correção na Mensal
            vr_vljurcor := pr_vlemprst * vr_tab_parcelas(vr_indice).taxa_periodo;
          END IF;
           
          -- Juros de Correção da Parcela
          vr_vljurcor := (pr_vlemprst + vr_vljurcor) * vr_tab_parcelas(vr_indice).taxa_periodo;
          EXIT;
        END IF;
      END LOOP;

      -- Retornar valores
      pr_vlpreemp := NVL(vr_vlpreemp,0);
      pr_vljurcor := NVL(vr_vljurcor,0);

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure pc_busca_prest_principal_pos: ' || SQLERRM;
    END;
    
  END pc_busca_prest_principal_pos;

  PROCEDURE pc_efetua_liquidacao_empr_pos(pr_cdcooper   IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                         ,pr_nrdconta   IN crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                         ,pr_nrctremp   IN crapepr.nrctremp%TYPE     --> Numero do Contrato
                                         ,pr_rw_crapdat IN BTCH0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                         ,pr_cdagenci   IN crapage.cdagenci%TYPE     --> Codigo da Agencia
                                         ,pr_cdpactra   IN crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                         ,pr_cdoperad   IN crapope.cdoperad%TYPE     --> Codigo do Operador
                                         ,pr_nrdcaixa   IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                         ,pr_cdorigem   IN NUMBER                    --> Codigo da Origem
                                         ,pr_nmdatela   IN VARCHAR2                  --> Nome da tela
                                         ,pr_floperac   IN BOOLEAN                   --> Indicador se a Operacao eh Financiamento
                                         ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                         ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_efetua_liquidacao_empr_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Agosto/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para liquidar o contrato de emprestimo.

       Alteracoes: 
    ............................................................................. */
    DECLARE
      -- Contabilizar as parcelas nao liquidadas
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
        SELECT COUNT(1)
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.inliquid <> 1;

      -- Contabilizar as parcelas nao liquidadas
      CURSOR cr_lem_his(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
        SELECT SUM(CASE WHEN craphis.indebcre = 'C' THEN craplem.vllanmto
                        WHEN craphis.indebcre = 'D' THEN craplem.vllanmto * -1
                   END)
          FROM craplem
          JOIN craphis
            ON craphis.cdcooper = craplem.cdcooper
           AND craphis.cdhistor = craplem.cdhistor
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor NOT IN (
                   2365,2363 -- Multa
                  ,2367,2369 -- Multa Aval
                  ,2371,2373 -- Juros de Mora
                  ,2375,2377 -- Juros de Mora Aval
               );

      -- Variaveis gerais
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_dstextab craptab.dstextab%TYPE;
      vr_flgcredi BOOLEAN;
      vr_inusatab BOOLEAN;
      vr_qtnaoliq INTEGER;
      vr_vlresidu NUMBER;

      -- Variaveis tratamento de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      vr_des_reto VARCHAR2(10);
      vr_tab_erro GENE0001.typ_tab_erro;

    BEGIN
      -- Contabilizar as parcelas nao liquidadas
      OPEN  cr_crappep(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crappep INTO vr_qtnaoliq;
      CLOSE cr_crappep;

      -- Se todas as parcelas estiverem liquidadas
      IF NVL(vr_qtnaoliq,0) = 0 THEN

        -- Contabilizar as parcelas nao liquidadas
        OPEN  cr_lem_his(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => pr_nrctremp);
        FETCH cr_lem_his INTO vr_vlresidu;
        CLOSE cr_lem_his;

        -- Se possui residuo negativo
        IF NVL(vr_vlresidu,0) < 0 THEN
          
          -- Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 1043;
          ELSE
            vr_cdhistor := 1041;
          END IF;
          
          -- Inverter sinal para efetuar o lancamento
          vr_vlresidu := vr_vlresidu * -1;
          
          vr_flgcredi := TRUE; -- Credita
          
        -- Se possui residuo positivo
        ELSIF NVL(vr_vlresidu,0) > 0 THEN
          
          -- Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 1042;  
          ELSE
            vr_cdhistor := 1040;    
          END IF;
          
          vr_flgcredi := FALSE; -- Debita
        END IF;

        -- Se possui residuo para lancamento
        IF NVL(vr_vlresidu,0) > 0 THEN

          -- Efetuar ajuste
          EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper            -- Codigo Cooperativa
                                         ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt -- Data Emprestimo
                                         ,pr_cdagenci => pr_cdagenci            -- Codigo Agencia
                                         ,pr_cdbccxlt => 100                    -- Codigo Caixa
                                         ,pr_cdoperad => pr_cdoperad            -- Operador
                                         ,pr_cdpactra => pr_cdpactra            -- Posto Atendimento
                                         ,pr_tplotmov => 5                      -- Tipo movimento
                                         ,pr_nrdolote => 650004                 -- Numero Lote
                                         ,pr_nrdconta => pr_nrdconta            -- Numero da Conta
                                         ,pr_cdhistor => vr_cdhistor            -- Codigo Historico
                                         ,pr_nrctremp => pr_nrctremp            -- Numero Contrato
                                         ,pr_vllanmto => vr_vlresidu            -- Valor Lancamento
                                         ,pr_dtpagemp => pr_rw_crapdat.dtmvtolt -- Data Pagamento Emprestimo
                                         ,pr_txjurepr => 0                      -- Taxa Juros Emprestimo
                                         ,pr_vlpreemp => 0                      -- Valor Emprestimo
                                         ,pr_nrsequni => 0                      -- Numero Sequencia
                                         ,pr_nrparepr => 0                      -- Numero Parcelas Emprestimo
                                         ,pr_flgincre => TRUE                   -- Indicador Credito
                                         ,pr_flgcredi => vr_flgcredi            -- Credito/Debito
                                         ,pr_nrseqava => 0                      -- Pagamento: Sequencia do avalista
                                         ,pr_cdorigem => pr_cdorigem            -- Origem do Lancamento
                                         ,pr_cdcritic => vr_cdcritic            -- Codigo Erro
                                         ,pr_dscritic => vr_dscritic);          -- Descricao Erro
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        END IF; -- NVL(vr_vlresidu,0) > 0

        -- Atualizar Emprestimo
        BEGIN
          UPDATE crapepr
             SET crapepr.vlajsdev = crapepr.vlsdeved
                ,crapepr.vlsdeved = 0
                ,crapepr.inliquid = 1
                ,crapepr.dtliquid = pr_rw_crapdat.dtmvtolt
           WHERE crapepr.cdcooper = pr_cdcooper
             AND crapepr.nrdconta = pr_nrdconta
             AND crapepr.nrctremp = pr_nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;

        -- Buscar parametro
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'TAXATABELA'
                                                 ,pr_tpregist => 0);
        -- Se nao encontrou parametro
        IF TRIM(vr_dstextab) IS NULL THEN
          vr_inusatab := FALSE;
        ELSE
          IF SUBSTR(vr_dstextab, 1, 1) = '0' THEN
            vr_inusatab := FALSE;
          ELSE
            vr_inusatab := TRUE;
          END IF;
        END IF;

        -- Desativa o rating da operacao
        RATI0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper   -- Cooperativa
                                   ,pr_cdagenci   => pr_cdagenci   -- Agencia
                                   ,pr_nrdcaixa   => pr_nrdcaixa   -- Numero Caixa
                                   ,pr_cdoperad   => pr_cdoperad   -- Operador
                                   ,pr_rw_crapdat => pr_rw_crapdat -- Registro Data
                                   ,pr_nrdconta   => pr_nrdconta   -- Conta Corrente
                                   ,pr_tpctrrat   => 90            -- Emprestimo -- Tipo Contrato
                                   ,pr_nrctrrat   => pr_nrctremp   -- Numero Contrato
                                   ,pr_flgefeti   => 'S'           -- Efetivar
                                   ,pr_idseqttl   => 1             -- Titular
                                   ,pr_idorigem   => pr_cdorigem   -- Origem
                                   ,pr_inusatab   => vr_inusatab   -- Uso tabela Juros
                                   ,pr_nmdatela   => pr_nmdatela   -- Nome da Tela
                                   ,pr_flgerlog   => 'N'           -- Escrever Log
                                   ,pr_des_reto   => vr_des_reto   -- Retorno OK/NOK
                                   ,pr_tab_erro   => vr_tab_erro); -- Tabela Erro
        -- Nao devera verificar se ocorreu erro

        -- Baixar do Gravames
        GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper            -- Cooperativa
                                             ,pr_nrdconta => pr_nrdconta            -- Numero da Conta
                                             ,pr_nrctrpro => pr_nrctremp            -- Contrato Emprestimo
                                             ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt -- Data Movimento
                                             ,pr_des_reto => vr_des_reto            -- Retorno OK/NOK
                                             ,pr_tab_erro => vr_tab_erro            -- Tabela de Erros
                                             ,pr_cdcritic => vr_cdcritic            -- Codigo erro
                                             ,pr_dscritic => vr_dscritic);          -- Descricao erro
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          RAISE vr_exc_erro;
        END IF;

      END IF; -- NVL(vr_qtnaoliq,0) = 0

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure pc_efetua_liquidacao_empr_pos: ' || SQLERRM;
    END;
    
  END pc_efetua_liquidacao_empr_pos;
  
END EMPR0011;
/
